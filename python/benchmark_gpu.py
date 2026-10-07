import time
import numpy as np
import os
from bibo_batched_env import BiboBatchedEnv

def run_benchmark():
    num_envs = 100000
    steps = 1000
    total_samples = num_envs * steps
    
    print(f"Initializing Batched GPU Simulator with {num_envs} environments...")
    env = BiboBatchedEnv(num_envs=num_envs)
    
    env.reset()
    
    # Pre-fill random actions directly into the memory view
    env.actions_view[:] = np.random.uniform(-0.1, 0.1, size=(num_envs, 4)).astype(np.float32)
    
    print(f"Running {steps} steps...")
    
    start_time = time.time()
    for _ in range(steps):
        env.step()
        
    end_time = time.time()
    elapsed = end_time - start_time
    sps = total_samples / elapsed
    
    msg = (
        f"--- GPU Benchmark Results ---\n"
        f"Environments: {num_envs}\n"
        f"Steps per Env: {steps}\n"
        f"Total Samples: {total_samples}\n"
        f"Time Elapsed: {elapsed:.3f} seconds\n"
        f"Throughput: {sps:,.0f} Samples Per Second (SPS)\n"
    )
    print(msg)
    
    log_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../logs"))
    os.makedirs(log_dir, exist_ok=True)
    with open(os.path.join(log_dir, "benchmark_gpu_100k.txt"), "w") as f:
        f.write(msg)

if __name__ == "__main__":
    run_benchmark()
