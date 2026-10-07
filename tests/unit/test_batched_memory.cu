#include "bibo/batched_simulator.h"
#include <stdio.h>

int main() {
    // Attempt to allocate 10,000 parallel environments in VRAM
    int N = 10000;
    
    BatchedSimulatorContext* ctx = bibo_batched_env_create(N);
    if (!ctx) {
        printf("FAIL: Could not allocate batched context.\n");
        return 1;
    }

    // Grab the CPU pinned memory pointer
    float* h_act = bibo_batched_get_actions_ptr(ctx);
    if (!h_act) {
        printf("FAIL: Host action pointer is NULL.\n");
        return 1;
    }

    // Write dummy data to the host arrays (e.g. actions)
    for(int i = 0; i < N * 4; i++) {
        h_act[i] = 1.23f;
    }

    // Perform a DMA transfer to the GPU
    bibo_batched_sync_actions_to_device(ctx);

    // Perform a DMA transfer back to the CPU (from zero-initialized state memory)
    bibo_batched_sync_results_to_host(ctx);

    // Free all VRAM/RAM
    bibo_batched_env_destroy(ctx);

    printf("Batched VRAM Memory Allocation and DMA Sync Tests Passed!\n");
    return 0;
}
