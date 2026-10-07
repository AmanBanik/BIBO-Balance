#ifndef BIBO_ACTUATOR_H
#define BIBO_ACTUATOR_H

#include "bibo/cuda_utils.h"

#include "bibo/types.h"

// Command the actuator to change length by a specific delta over dt.
// Internally applies hardware rate limits and absolute stroke limits.
BIBO_FUNC void actuator_apply_command(ActuatorState* act, float command_delta_L, float dt);

// Force the actuator to a specific length (useful for environment resets)
// Also clamps to min/max stroke limits and zeroes the velocity.
BIBO_FUNC void actuator_reset(ActuatorState* act, float target_length);

#endif // BIBO_ACTUATOR_H
