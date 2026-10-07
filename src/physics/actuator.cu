#include "bibo/actuator.h"

BIBO_FUNC void actuator_apply_command(ActuatorState* act, float command_delta_L, float dt) {
    if (dt <= 0.0f) {
        act->length_rate = 0.0f;
        return;
    }

    // 1. Calculate the requested velocity
    float requested_rate = command_delta_L / dt;

    // 2. Clamp velocity to hardware rate limit
    if (requested_rate > act->rate_limit) {
        requested_rate = act->rate_limit;
    } else if (requested_rate < -act->rate_limit) {
        requested_rate = -act->rate_limit;
    }

    // 3. Project new length
    float new_length = act->length + (requested_rate * dt);

    // 4. Clamp length to absolute stroke limits
    if (new_length > act->length_max) {
        new_length = act->length_max;
    } else if (new_length < act->length_min) {
        new_length = act->length_min;
    }

    // 5. Calculate actual achieved rate (may be 0 if pegged at physical limit)
    act->length_rate = (new_length - act->length) / dt;
    act->length = new_length;
}

BIBO_FUNC void actuator_reset(ActuatorState* act, float target_length) {
    if (target_length > act->length_max) {
        act->length = act->length_max;
    } else if (target_length < act->length_min) {
        act->length = act->length_min;
    } else {
        act->length = target_length;
    }
    
    act->length_rate = 0.0f; // Reset means starting from rest
}
