#include "bibo/batched_simulator.h"
#include "bibo/simulator.h"
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

    // Host Pointers (Pinned RAM)
    float* h_actions;
    float* h_states;
    float* h_rewards;
    int* h_dones;
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

    // 2. Allocate Pinned Memory (Page-locked RAM) on the CPU.
    // This allows Python to write directly to RAM that the GPU can pull over PCI-e via DMA 
    // without the CPU needing to buffer it. Highly performant.
    CUDA_CHECK(cudaMallocHost(&ctx->h_actions, num_envs * 4 * sizeof(float)));
    CUDA_CHECK(cudaMallocHost(&ctx->h_states, num_envs * 21 * sizeof(float)));
    CUDA_CHECK(cudaMallocHost(&ctx->h_rewards, num_envs * sizeof(float)));
    CUDA_CHECK(cudaMallocHost(&ctx->h_dones, num_envs * sizeof(int)));

    return ctx;
}

void bibo_batched_env_destroy(BatchedSimulatorContext* ctx) {
    if (!ctx) return;
    
    cudaFree(ctx->d_sims);
    cudaFree(ctx->d_actions);
    cudaFree(ctx->d_states);
    cudaFree(ctx->d_rewards);
    cudaFree(ctx->d_dones);

    cudaFreeHost(ctx->h_actions);
    cudaFreeHost(ctx->h_states);
    cudaFreeHost(ctx->h_rewards);
    cudaFreeHost(ctx->h_dones);

    free(ctx);
}

float* bibo_batched_get_actions_ptr(BatchedSimulatorContext* ctx) { return ctx->h_actions; }
float* bibo_batched_get_states_ptr(BatchedSimulatorContext* ctx) { return ctx->h_states; }
float* bibo_batched_get_rewards_ptr(BatchedSimulatorContext* ctx) { return ctx->h_rewards; }
int*   bibo_batched_get_dones_ptr(BatchedSimulatorContext* ctx) { return ctx->h_dones; }

void bibo_batched_sync_actions_to_device(BatchedSimulatorContext* ctx) {
    if (!ctx) return;
    CUDA_CHECK(cudaMemcpy(ctx->d_actions, ctx->h_actions, ctx->num_envs * 4 * sizeof(float), cudaMemcpyHostToDevice));
}

void bibo_batched_sync_results_to_host(BatchedSimulatorContext* ctx) {
    if (!ctx) return;
    CUDA_CHECK(cudaMemcpy(ctx->h_states, ctx->d_states, ctx->num_envs * 21 * sizeof(float), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(ctx->h_rewards, ctx->d_rewards, ctx->num_envs * sizeof(float), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(ctx->h_dones, ctx->d_dones, ctx->num_envs * sizeof(int), cudaMemcpyDeviceToHost));
}
