import tensorflow as tf
import numpy as np

class PPOActor(tf.keras.Model):
    def __init__(self, action_dim=4):
        super(PPOActor, self).__init__()
        self.fc1 = tf.keras.layers.Dense(64, activation='tanh')
        self.fc2 = tf.keras.layers.Dense(64, activation='tanh')
        # Tanh activation bounds the output between -1 and 1
        self.mean_out = tf.keras.layers.Dense(action_dim, activation='tanh')
        
        # Standard deviation for exploration, independent of state but trainable
        self.log_std = tf.Variable(tf.zeros((action_dim,)), trainable=True, name="log_std")

    def call(self, state):
        x = self.fc1(state)
        x = self.fc2(x)
        mean = self.mean_out(x)
        
        # Action scale: max Delta L per step is small (e.g., 0.05m)
        # We will scale this in the environment or rollout step
        
        return mean, self.log_std

class PPOCritic(tf.keras.Model):
    def __init__(self):
        super(PPOCritic, self).__init__()
        self.fc1 = tf.keras.layers.Dense(64, activation='tanh')
        self.fc2 = tf.keras.layers.Dense(64, activation='tanh')
        self.value_out = tf.keras.layers.Dense(1, activation='linear')

    def call(self, state):
        x = self.fc1(state)
        x = self.fc2(x)
        value = self.value_out(x)
        return value

if __name__ == "__main__":
    # Quick sanity check
    dummy_state = tf.random.normal((3, 21)) # Batch of 3, state dim 21
    
    actor = PPOActor()
    critic = PPOCritic()
    
    mean, log_std = actor(dummy_state)
    value = critic(dummy_state)
    
    print("Actor Mean Shape:", mean.shape)
    print("Actor Log Std:", log_std.numpy())
    print("Critic Value Shape:", value.shape)

class PPOMemory:
    def __init__(self, num_envs, rollout_steps, state_dim=21, action_dim=4):
        self.num_envs = num_envs
        self.rollout_steps = rollout_steps
        
        # Pre-allocate large continuous arrays for the entire rollout batch
        self.states = np.zeros((rollout_steps, num_envs, state_dim), dtype=np.float32)
        self.actions = np.zeros((rollout_steps, num_envs, action_dim), dtype=np.float32)
        self.rewards = np.zeros((rollout_steps, num_envs), dtype=np.float32)
        self.values = np.zeros((rollout_steps, num_envs), dtype=np.float32)
        self.log_probs = np.zeros((rollout_steps, num_envs), dtype=np.float32)
        self.dones = np.zeros((rollout_steps, num_envs), dtype=np.float32)
        
        # Advantages and Returns computed at the end of the rollout
        self.advantages = np.zeros((rollout_steps, num_envs), dtype=np.float32)
        self.returns = np.zeros((rollout_steps, num_envs), dtype=np.float32)
        
        self.step = 0

    def store(self, state, action, reward, value, log_prob, done):
        self.states[self.step] = state
        self.actions[self.step] = action
        self.rewards[self.step] = reward
        self.values[self.step] = np.squeeze(value)
        self.log_probs[self.step] = log_prob
        self.dones[self.step] = done
        self.step += 1

    def compute_gae(self, next_value, next_done, gamma=0.99, lam=0.95):
        """
        Generalized Advantage Estimation (GAE)
        Calculates how much better an action was than the Critic's prediction.
        """
        last_gae_lam = 0
        for t in reversed(range(self.rollout_steps)):
            if t == self.rollout_steps - 1:
                next_non_terminal = 1.0 - next_done
                next_val = next_value
            else:
                next_non_terminal = 1.0 - self.dones[t + 1]
                next_val = self.values[t + 1]
                
            delta = self.rewards[t] + gamma * next_val * next_non_terminal - self.values[t]
            self.advantages[t] = last_gae_lam = delta + gamma * lam * next_non_terminal * last_gae_lam
            
        self.returns = self.advantages + self.values
        
    def clear(self):
        self.step = 0

class PPOAgent:
    def __init__(self, state_dim=21, action_dim=4, lr=3e-4, clip_ratio=0.2, gamma=0.99, lam=0.95):
        self.actor = PPOActor(action_dim)
        self.critic = PPOCritic()
        
        # Build models by passing dummy state
        dummy_state = tf.zeros((1, state_dim))
        self.actor(dummy_state)
        self.critic(dummy_state)
        
        self.actor_optimizer = tf.keras.optimizers.Adam(learning_rate=lr)
        self.critic_optimizer = tf.keras.optimizers.Adam(learning_rate=lr)
        
        self.clip_ratio = clip_ratio
        self.gamma = gamma
        self.lam = lam
        
    @tf.function
    def get_action_and_value(self, state):
        mean, log_std = self.actor(state)
        value = self.critic(state)
        
        std = tf.exp(log_std)
        
        # Sample action from normal distribution
        noise = tf.random.normal(tf.shape(mean))
        action = mean + noise * std
        
        # Calculate log probability of the sampled action
        # log_prob = -0.5 * ((action - mean) / std)^2 - 0.5 * ln(2 * pi) - log_std
        log_prob = -0.5 * tf.square((action - mean) / std) - 0.5 * tf.math.log(2.0 * np.pi) - log_std
        log_prob = tf.reduce_sum(log_prob, axis=-1)
        
        return action, value, log_prob

    @tf.function
    def train_step(self, states, actions, log_probs_old, returns, advantages):
        # Normalize advantages
        advantages = (advantages - tf.reduce_mean(advantages)) / (tf.math.reduce_std(advantages) + 1e-8)
        
        with tf.GradientTape() as actor_tape, tf.GradientTape() as critic_tape:
            # Forward pass
            mean, log_std = self.actor(states)
            values = tf.squeeze(self.critic(states))
            
            std = tf.exp(log_std)
            
            # Recalculate log probabilities of the old actions with the new network weights
            log_probs = -0.5 * tf.square((actions - mean) / std) - 0.5 * tf.math.log(2.0 * np.pi) - log_std
            log_probs = tf.reduce_sum(log_probs, axis=-1)
            
            # PPO Ratio: pi_theta / pi_theta_old
            ratio = tf.exp(log_probs - log_probs_old)
            
            # Clipped Surrogate Objective
            surr1 = ratio * advantages
            surr2 = tf.clip_by_value(ratio, 1.0 - self.clip_ratio, 1.0 + self.clip_ratio) * advantages
            
            # Entropy bonus (encourages exploration)
            entropy = tf.reduce_sum(log_std + 0.5 * tf.math.log(2.0 * np.pi * np.e), axis=-1)
            
            # Negative because we want to maximize the objective using gradient descent
            actor_loss = -tf.reduce_mean(tf.minimum(surr1, surr2)) - 0.01 * tf.reduce_mean(entropy)
            
            # Critic loss (Mean Squared Error between predicted values and actual returns)
            critic_loss = tf.reduce_mean(tf.square(returns - values))
            
        # Compute and apply gradients
        actor_grads = actor_tape.gradient(actor_loss, self.actor.trainable_variables)
        critic_grads = critic_tape.gradient(critic_loss, self.critic.trainable_variables)
        
        self.actor_optimizer.apply_gradients(zip(actor_grads, self.actor.trainable_variables))
        self.critic_optimizer.apply_gradients(zip(critic_grads, self.critic.trainable_variables))
        
        return actor_loss, critic_loss

    def save_weights(self, path="models/ppo"):
        self.actor.save_weights(f"{path}_actor.weights.h5")
        self.critic.save_weights(f"{path}_critic.weights.h5")
        
    def load_weights(self, path="models/ppo"):
        self.actor.load_weights(f"{path}_actor.weights.h5")
        self.critic.load_weights(f"{path}_critic.weights.h5")
