import os
import time
import numpy as np
import tensorflow as tf
from bibo_batched_env import BiboBatchedEnv
from ppo import PPOAgent, PPOMemory

# Suppress minor TF warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2' 

# Set seeds for determinism
tf.random.set_seed(42)
np.random.seed(42)

def train():
    num_envs = 100000
    rollout_steps = 100
    epochs = 50
    batch_size = 8192
    
    print(f"Initializing GPU Simulator with {num_envs} environments...")
    env = BiboBatchedEnv(num_envs=num_envs)
    agent = PPOAgent()
    memory = PPOMemory(num_envs, rollout_steps)
    
    os.makedirs("models", exist_ok=True)
    
    best_reward = -float('inf')
    states = env.reset()
    
    # We will use this to convert network outputs [-1, 1] into actuator delta commands.
    # We allow max delta length of 0.05m per step.
    max_action = 0.05 
    
    print(f"Starting Training! (Total steps per epoch: {num_envs * rollout_steps:,.0f})")
    
    for epoch in range(epochs):
        epoch_rewards = []
        start_time = time.time()
        
        # ==========================================
        # Curriculum Domain Randomization
        # ==========================================
        if epoch < 10:
            spawn_radius_x = 0.05
            spawn_radius_y = 0.02
        elif epoch < 30:
            spawn_radius_x = 0.15
            spawn_radius_y = 0.05
        else:
            spawn_radius_x = 0.25 # Almost to the edge of 0.3
            spawn_radius_y = 0.08 # Almost to the edge of 0.1
            
        # ==========================================
        # 1. ROLLOUT COLLECTION (Simulation)
        # ==========================================
        for step in range(rollout_steps):
            # Convert states to TF tensor for fast batch execution
            tf_states = tf.convert_to_tensor(states)
            actions, values, log_probs = agent.get_action_and_value(tf_states)
            
            # Convert TF tensors back to numpy
            actions_np = actions.numpy()
            values_np = values.numpy()
            log_probs_np = log_probs.numpy()
            
            # Action clipping and scaling
            actions_np = np.clip(actions_np, -1.0, 1.0)
            scaled_actions = actions_np * max_action
            
            # We must write directly to the env's pinned memory view to sync to GPU
            env.actions_view[:] = scaled_actions
            
            # Step the batched GPU simulator (this triggers 100k CUDA threads)
            next_states, rewards, dones = env.step(spawn_radius_x=spawn_radius_x, spawn_radius_y=spawn_radius_y)
            
            # Store transition in memory buffer
            memory.store(states, actions_np, rewards, values_np, log_probs_np, dones)
            
            # Prepare for next step
            states = next_states.copy()
            epoch_rewards.append(np.mean(rewards))
            
            # Note: The C-kernel handles auto-resetting the individual environments when they fall off.
        
        # Calculate next value for GAE boundary
        _, next_values, _ = agent.get_action_and_value(tf.convert_to_tensor(states))
        memory.compute_gae(np.squeeze(next_values.numpy()), np.zeros(num_envs))
        
        # ==========================================
        # 2. PPO OPTIMIZATION (Neural Network Update)
        # ==========================================
        # Flatten the rollout buffer for mini-batch SGD
        flat_states = memory.states.reshape(-1, 21)
        flat_actions = memory.actions.reshape(-1, 4)
        flat_log_probs = memory.log_probs.reshape(-1)
        flat_returns = memory.returns.reshape(-1)
        flat_advantages = memory.advantages.reshape(-1)
        
        dataset_size = flat_states.shape[0]
        indices = np.random.permutation(dataset_size)
        
        actor_losses = []
        critic_losses = []
        
        # Train for 2 optimization epochs per rollout
        opt_epochs = 2 
        for _ in range(opt_epochs):
            for start in range(0, dataset_size, batch_size):
                end = start + batch_size
                batch_idx = indices[start:end]
                
                al, cl = agent.train_step(
                    tf.convert_to_tensor(flat_states[batch_idx]),
                    tf.convert_to_tensor(flat_actions[batch_idx]),
                    tf.convert_to_tensor(flat_log_probs[batch_idx]),
                    tf.convert_to_tensor(flat_returns[batch_idx]),
                    tf.convert_to_tensor(flat_advantages[batch_idx])
                )
                actor_losses.append(al.numpy())
                critic_losses.append(cl.numpy())
                
        memory.clear()
        
        avg_reward = np.mean(epoch_rewards)
        elapsed = time.time() - start_time
        
        print(f"Epoch {epoch+1:03d} | Avg Reward: {avg_reward:8.3f} | Actor Loss: {np.mean(actor_losses):6.3f} | Critic Loss: {np.mean(critic_losses):9.3f} | Time: {elapsed:5.2f}s")
        
        # Save best model
        if avg_reward > best_reward:
            best_reward = avg_reward
            agent.save_weights("models/ppo_best")
            
    print("Training complete! Best weights saved to models/")

if __name__ == "__main__":
    train()
