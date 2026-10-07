#ifndef BIBO_SIMULATOR_H
#define BIBO_SIMULATOR_H

#include "bibo/cuda_utils.h"

#include "bibo/physics.h"
#include "bibo/actuator.h"
#include "bibo/kinematics.h"

// The monolithic state of the entire simulation environment.
// This is exactly what the Python CFFI wrapper will interact with.
typedef struct BiboSimulator {
    // Core Entities
    BallState ball;
    ActuatorState actuators[4];
    PlatformGeometry platform_geom;
    PlatformState platform_state;
    
    // Environment Parameters
    Vec3 gravity;
    float friction_mu;
    
    // Diagnostics & Tracking
    StabilityTracker stability;
    float total_energy;
    int step_count;
    float time_elapsed;
} BiboSimulator;

// Initializes the simulator with default physical hardware parameters
BIBO_FUNC void simulator_init(BiboSimulator* sim);

// Resets the simulator (level platform, specific ball spawn position)
BIBO_FUNC void simulator_reset(BiboSimulator* sim, Vec3 start_pos);

// Steps the entire simulation forward by 'dt' given 4 actuator commands
BIBO_FUNC void simulator_step(BiboSimulator* sim, float commands[4], float dt);

#endif // BIBO_SIMULATOR_H
