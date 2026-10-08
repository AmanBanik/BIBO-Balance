#ifndef BIBO_BATCHED_SIMULATOR_H
#define BIBO_BATCHED_SIMULATOR_H

#ifdef __cplusplus
extern "C" {
#endif

// Opaque context holding all GPU and CPU memory arrays for batched RL
typedef struct BatchedSimulatorContext BatchedSimulatorContext;

// Allocate memory for N completely independent physics environments on the GPU
// Allocates internal VRAM (simulators, device arrays) and Pinned RAM (host arrays).
BatchedSimulatorContext* bibo_batched_env_create(int num_envs);

// Free all GPU and CPU memory to prevent massive memory leaks
void bibo_batched_env_destroy(BatchedSimulatorContext* ctx);

// Direct pointer access to Pinned Host Memory.
// Python/NumPy will write directly into these RAM blocks without overhead.
float* bibo_batched_get_actions_ptr(BatchedSimulatorContext* ctx);
float* bibo_batched_get_states_ptr(BatchedSimulatorContext* ctx);
float* bibo_batched_get_rewards_ptr(BatchedSimulatorContext* ctx);
int*   bibo_batched_get_dones_ptr(BatchedSimulatorContext* ctx);

unsigned int* bibo_batched_get_seeds_ptr(BatchedSimulatorContext* ctx);

// High-bandwidth PCI-e transfers between CPU Pinned RAM and GPU VRAM
void bibo_batched_sync_actions_to_device(BatchedSimulatorContext* ctx);
void bibo_batched_sync_seeds_to_device(BatchedSimulatorContext* ctx);
void bibo_batched_sync_results_to_host(BatchedSimulatorContext* ctx);

// GPU Execution Kernels
void bibo_batched_env_reset_cuda(BatchedSimulatorContext* ctx, float spawn_radius_x, float spawn_radius_y);
void bibo_batched_env_step_cuda(BatchedSimulatorContext* ctx, float dt, float spawn_radius_x, float spawn_radius_y);

#ifdef __cplusplus
}
#endif

#endif // BIBO_BATCHED_SIMULATOR_H
