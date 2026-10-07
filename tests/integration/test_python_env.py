import sys
import os
import numpy as np

# Inject the python directory into sys.path to resolve bibo_env
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../python')))
from bibo_env import BiboEnv

def test_wrapper():
    print("Initializing CFFI BiboEnv...")
    env = BiboEnv(build_dir="../build")
    
    obs = env.reset()
    assert obs.shape == (21,), f"Obs shape should be (21,), got {obs.shape}"
    print(f"Initial ball Z: {obs[2]:.4f}")
    
    print("Taking 10 steps with a tilted platform command...")
    # Command actuators to pitch the platform (Front left + Front right UP)
    # Indices 1 and 2 correspond to the front.
    action = np.array([0.0, 0.05, 0.05, 0.0], dtype=np.float32)
    
    for _ in range(10):
        obs, reward, terminated, truncated, info = env.step(action)
        
    print(f"Final ball Z: {obs[2]:.4f}")
    print(f"Final ball Vel X: {obs[3]:.4f}")
    print(f"Final ball Omega Y: {obs[7]:.4f}")
    print(f"Energy: {info['energy']:.4f}")
    
    # Assert physical response translated perfectly into Python
    assert obs[3] < -0.001, f"Ball should be rolling backwards. Vel X is {obs[3]}"
    assert obs[7] < -0.001, f"Ball should have negative omega Y. Omega Y is {obs[7]}"
    
    # Force a failure state to check termination logic
    print("Testing terminal state bounds...")
    obs, reward, terminated, truncated, info = env.step(action) # Keep stepping
    # Teleport ball way off the edge of the platform (x = 2.0m) to simulate a fall
    env.lib.bibo_env_reset(env._env_ptr, 2.0, 0.0, 0.0) 
    obs, reward, terminated, truncated, info = env.step(action)
    
    assert terminated == True, f"Environment should report terminated when ball falls. Z is {obs[2]}"
    assert reward == -100.0, "Terminal reward should be severely penalized"

    print("Python Gymnasium Wrapper Test Passed Successfully!")

if __name__ == "__main__":
    test_wrapper()
