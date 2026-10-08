#include "bibo/batched_simulator.h"
#include "bibo/simulator.h"
#include "bibo/cffi_interface.h"
#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

struct BatchedSimulatorContext {
    int num_envs;
    
    // Device Pointers (VRAM)
    BiboSimulator* d_sims;
    float* d_actions;
    float* d_states;
    float* d_rewards;
    int* d_dones;
    unsigned int* d_seeds;

    // Host Pointers (Pinned RAM)
    float* h_actions;
    float* h_states;
    float* h_rewards;
    int* h_dones;
    unsigned int* h_seeds;
};

// Macro to wrap CUDA API calls and instantly crash on memory errors (Out of Memory, etc.)
#define CUDA_CHECK(call) \
    do { \
        cudaError_t err = call; \
        if (err != cudaSuccess) { \
            fprintf(stderr, "CUDA error in %s:%d: %s\n", __FILE__, __LINE__, cudaGetErrorString(err)); \
            exit(EXIT_FAILURE); \
        } \
    } while(0)

BatchedSimulatorContext* bibo_batched_env_create(int num_envs) {
    BatchedSimulatorContext* ctx = (BatchedSimulatorContext*)malloc(sizeof(BatchedSimulatorContext));
    if (!ctx) return NULL;
    
    ctx->num_envs = num_envs;

    // 1. Allocate massive arrays in GPU VRAM
    CUDA_CHECK(cudaMalloc(&ctx->d_sims, num_envs * sizeof(BiboSimulator)));
    CUDA_CHECK(cudaMalloc(&ctx->d_actions, num_envs * 4 * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&ctx->d_states, num_envs * 21 * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&ctx->d_rewards, num_envs * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&ctx->d_dones, num_envs * sizeof(int)));
    CUDA_CHECK(cudaMalloc(&ctx->d_seeds, num_envs * sizeof(unsigned int)));

    // 2. Allocate Pinned Memory (Page-locked RAM) on the CPU.
    CUDA_CHECK(cudaMallocHost(&ctx->h_actions, num_envs * 4 * sizeof(float)));
    CUDA_CHECK(cudaMallocHost(&ctx->h_states, num_envs * 21 * sizeof(float)));
    CUDA_CHECK(cudaMallocHost(&ctx->h_rewards, num_envs * sizeof(float)));
    CUDA_CHECK(cudaMallocHost(&ctx->h_dones, num_envs * sizeof(int)));
    CUDA_CHECK(cudaMallocHost(&ctx->h_seeds, num_envs * sizeof(unsigned int)));

    return ctx;
}

void bibo_batched_env_destroy(BatchedSimulatorContext* ctx) {
    if (!ctx) return;
    
    cudaFree(ctx->d_sims);
    cudaFree(ctx->d_actions);
    cudaFree(ctx->d_states);
    cudaFree(ctx->d_rewards);
    cudaFree(ctx->d_dones);
    cudaFree(ctx->d_seeds);

    cudaFreeHost(ctx->h_actions);
    cudaFreeHost(ctx->h_states);
    cudaFreeHost(ctx->h_rewards);
    cudaFreeHost(ctx->h_dones);
    cudaFreeHost(ctx->h_seeds);

    free(ctx);
}

float* bibo_batched_get_actions_ptr(BatchedSimulatorContext* ctx) { return ctx->h_actions; }
float* bibo_batched_get_states_ptr(BatchedSimulatorContext* ctx) { return ctx->h_states; }
float* bibo_batched_get_rewards_ptr(BatchedSimulatorContext* ctx) { return ctx->h_rewards; }
int*   bibo_batched_get_dones_ptr(BatchedSimulatorContext* ctx) { return ctx->h_dones; }
unsigned int* bibo_batched_get_seeds_ptr(BatchedSimulatorContext* ctx) { return ctx->h_seeds; }

void bibo_batched_sync_actions_to_device(BatchedSimulatorContext* ctx) {
    if (!ctx) return;
    CUDA_CHECK(cudaMemcpy(ctx->d_actions, ctx->h_actions, ctx->num_envs * 4 * sizeof(float), cudaMemcpyHostToDevice));
}

void bibo_batched_sync_seeds_to_device(BatchedSimulatorContext* ctx) {
    if (!ctx) return;
    CUDA_CHECK(cudaMemcpy(ctx->d_seeds, ctx->h_seeds, ctx->num_envs * sizeof(unsigned int), cudaMemcpyHostToDevice));
}

void bibo_batched_sync_results_to_host(BatchedSimulatorContext* ctx) {
    if (!ctx) return;
    CUDA_CHECK(cudaMemcpy(ctx->h_states, ctx->d_states, ctx->num_envs * 21 * sizeof(float), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(ctx->h_rewards, ctx->d_rewards, ctx->num_envs * sizeof(float), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(ctx->h_dones, ctx->d_dones, ctx->num_envs * sizeof(int), cudaMemcpyDeviceToHost));
}

// -----------------------------------------------------------------------------
// CUDA DEVICE KERNELS
// -----------------------------------------------------------------------------

__device__ float rand_uniform(unsigned int* seed, float min_val, float max_val) {
    *seed = (*seed * 1664525u + 1013904223u);
    float t = (float)(*seed & 0x00FFFFFF) / (float)0x01000000;
    return min_val + t * (max_val - min_val);
}

__global__ void batched_env_reset_kernel(
    int num_envs,
    BiboSimulator* d_sims,
    float* d_states,
    float* d_rewards,
    int* d_dones,
    unsigned int* d_seeds,
    float spawn_radius_x,
    float spawn_radius_y,
    float gravity_tilt,
    float friction_range
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= num_envs) return;

    // Initialize/Reset physical simulator
    simulator_init(&d_sims[idx]);
    
    // Generate random spawn within bounds
    unsigned int seed = d_seeds[idx];
    float rx = rand_uniform(&seed, -spawn_radius_x, spawn_radius_x);
    float ry = rand_uniform(&seed, -spawn_radius_y, spawn_radius_y);
    
    // Domain Randomization: Gravity & Friction
    float gx = rand_uniform(&seed, -gravity_tilt, gravity_tilt);
    float gy = rand_uniform(&seed, -gravity_tilt, gravity_tilt);
    float mu = rand_uniform(&seed, 0.1f - friction_range, 0.1f + friction_range); // base is typically 0.1
    if (mu < 0.01f) mu = 0.01f; // Clamp to avoid slippery zero
    
    d_seeds[idx] = seed;

    // Apply randomization
    d_sims[idx].gravity.x = gx;
    d_sims[idx].gravity.y = gy;
    d_sims[idx].friction_mu = mu;

    // Spawn roughly at center for now, with slight Z drop
    Vec3 spawn = {rx, ry, 0.15f};
    simulator_reset(&d_sims[idx], spawn);

    // Populate initial state
    bibo_env_get_state(&d_sims[idx], &d_states[idx * 21]);
    
    d_rewards[idx] = 0.0f;
    d_dones[idx] = 0;
}

__global__ void batched_env_step_kernel(
    int num_envs,
    BiboSimulator* d_sims,
    const float* d_actions,
    float* d_states,
    float* d_rewards,
    int* d_dones,
    unsigned int* d_seeds,
    float dt,
    float spawn_radius_x,
    float spawn_radius_y,
    float gravity_tilt,
    float friction_range
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= num_envs) return;

    // Check if already done (auto-reset logic could go here)
    if (d_dones[idx]) {
        // Generate random spawn within bounds
        unsigned int seed = d_seeds[idx];
        float rx = rand_uniform(&seed, -spawn_radius_x, spawn_radius_x);
        float ry = rand_uniform(&seed, -spawn_radius_y, spawn_radius_y);
        
        float gx = rand_uniform(&seed, -gravity_tilt, gravity_tilt);
        float gy = rand_uniform(&seed, -gravity_tilt, gravity_tilt);
        float mu = rand_uniform(&seed, 0.1f - friction_range, 0.1f + friction_range);
        if (mu < 0.01f) mu = 0.01f;
        
        d_seeds[idx] = seed;

        d_sims[idx].gravity.x = gx;
        d_sims[idx].gravity.y = gy;
        d_sims[idx].friction_mu = mu;

        Vec3 spawn = {rx, ry, 0.15f};
        simulator_reset(&d_sims[idx], spawn);
        d_dones[idx] = 0;
    } else {
        // Read actions (4 floats per env)
        const float* action = &d_actions[idx * 4];
        
        // Execute physics step
        bibo_env_step(&d_sims[idx], action[0], action[1], action[2], action[3], dt);
    }

    // Write out new state
    bibo_env_get_state(&d_sims[idx], &d_states[idx * 21]);

    // Simple reward: penalize ball distance from center
    BiboSimulator* sim = &d_sims[idx];
    float x = sim->ball.position.x;
    float y = sim->ball.position.y;
    float dist_sq = x*x + y*y;
    
    // Base reward of 1.0 for staying alive, penalize distance
    d_rewards[idx] = 1.0f - dist_sq * 10.0f;

    // Check done conditions (fall off platform)
    // Physical bounds: x in [-0.3, 0.3], y in [-0.1, 0.1]
    if (x < -0.3f || x > 0.3f || y < -0.1f || y > 0.1f || sim->ball.position.z < 0.0f) {
        d_dones[idx] = 1;
        d_rewards[idx] -= 100.0f; // Terminal penalty
    } else {
        d_dones[idx] = 0;
    }
}

extern "C" void bibo_batched_env_reset_cuda(BatchedSimulatorContext* ctx, float spawn_radius_x, float spawn_radius_y, float gravity_tilt, float friction_range) {
    if (!ctx) return;
    
    int threads = 256;
    int blocks = (ctx->num_envs + threads - 1) / threads;
    
    batched_env_reset_kernel<<<blocks, threads>>>(
        ctx->num_envs,
        ctx->d_sims,
        ctx->d_states,
        ctx->d_rewards,
        ctx->d_dones,
        ctx->d_seeds,
        spawn_radius_x,
        spawn_radius_y,
        gravity_tilt,
        friction_range
    );
    CUDA_CHECK(cudaDeviceSynchronize());
}

extern "C" void bibo_batched_env_step_cuda(BatchedSimulatorContext* ctx, float dt, float spawn_radius_x, float spawn_radius_y, float gravity_tilt, float friction_range) {
    if (!ctx) return;

    int threads = 256;
    int blocks = (ctx->num_envs + threads - 1) / threads;
    
    batched_env_step_kernel<<<blocks, threads>>>(
        ctx->num_envs,
        ctx->d_sims,
        ctx->d_actions,
        ctx->d_states,
        ctx->d_rewards,
        ctx->d_dones,
        ctx->d_seeds,
        dt,
        spawn_radius_x,
        spawn_radius_y,
        gravity_tilt,
        friction_range
    );
    CUDA_CHECK(cudaDeviceSynchronize());
}
