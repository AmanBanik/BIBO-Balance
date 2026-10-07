import sys
import os
import time
import numpy as np

# Ensure bibo_env can be imported
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '.')))
from bibo_env import BiboEnv

def run_benchmark(steps=1_000_000):
    print(f"Initializing BIBO Environment for {steps:,} steps...")
    env = BiboEnv(build_dir="../build")
    env.reset()
    
    # Pre-generate an array of random actions to ensure Python's RNG 
    # doesn't bottleneck the benchmark of the physics step itself.
    print("Generating random action pool...")
    actions = np.random.uniform(-0.02, 0.02, size=(10000, 4)).astype(np.float32)
    
    print("Warming up CPU caches...")
    for i in range(5000):
        env.step(actions[i % 10000])
    
    env.reset()
    
    print("Starting benchmark (this will take a moment)...")
    start_time = time.perf_counter()
    
    resets = 0
    # The hot loop
    for i in range(steps):
        action = actions[i % 10000]
        _, _, terminated, _, _ = env.step(action)
        
        if terminated:
            env.reset()
            resets += 1
            
    end_time = time.perf_counter()
    
    duration = end_time - start_time
    sps = steps / duration
    
    print("\n" + "=" * 40)
    print("🚀 BENCHMARK RESULTS 🚀")
    print("=" * 40)
    print(f"Total Steps:   {steps:,}")
    print(f"Total Time:    {duration:.4f} seconds")
    print(f"Total Resets:  {resets:,}")
    print(f"Throughput:    {sps:,.2f} Steps/Second")
    print("=" * 40 + "\n")
    
    return sps

if __name__ == "__main__":
    run_benchmark(1_000_000)
