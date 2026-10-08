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
