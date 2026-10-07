#ifndef BIBO_CFFI_INTERFACE_H
#define BIBO_CFFI_INTERFACE_H

#include "bibo/cuda_utils.h"

#ifdef __cplusplus
extern "C" {
#endif

// Opaque pointer for Python to hold memory reference without knowing struct layout
typedef struct BiboSimulator BiboSimulator;

// Lifecycle Management
BIBO_FUNC BiboSimulator* bibo_env_create();
BIBO_FUNC void bibo_env_destroy(BiboSimulator* env);
BIBO_FUNC void bibo_env_reset(BiboSimulator* env, float spawn_x, float spawn_y, float spawn_z);

// Action Step: Takes Delta L commands for the 4 actuators and time step dt
BIBO_FUNC void bibo_env_step(BiboSimulator* env, float a0, float a1, float a2, float a3, float dt);

// State retrieval: Populates a pre-allocated 21-element float array with the RL state
// [0:2]   Ball Pos (x, y, z)
// [3:5]   Ball Vel (x, y, z)
// [6:8]   Ball Angular Vel (x, y, z)
// [9:12]  Platform Quat Rotation (x, y, z, w)
// [13:16] Actuator Lengths (0, 1, 2, 3)
// [17:20] Actuator Rates (0, 1, 2, 3)
BIBO_FUNC void bibo_env_get_state(BiboSimulator* env, float* out_state);

// Reward / Done signaling diagnostics
BIBO_FUNC int bibo_env_is_stable(BiboSimulator* env);
BIBO_FUNC float bibo_env_get_energy(BiboSimulator* env);
BIBO_FUNC int bibo_env_get_step_count(BiboSimulator* env);

#ifdef __cplusplus
}
#endif

#endif // BIBO_CFFI_INTERFACE_H
