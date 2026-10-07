#include "bibo/cffi_interface.h"
#include "bibo/simulator.h"
#include <stdlib.h>

BIBO_FUNC BiboSimulator* bibo_env_create() {
    BiboSimulator* sim = (BiboSimulator*)malloc(sizeof(BiboSimulator));
    if (sim) {
        simulator_init(sim);
    }
    return sim;
}

BIBO_FUNC void bibo_env_destroy(BiboSimulator* env) {
    if (env) {
        free(env);
    }
}

BIBO_FUNC void bibo_env_reset(BiboSimulator* env, float spawn_x, float spawn_y, float spawn_z) {
    if (!env) return;
    Vec3 spawn_pos = {spawn_x, spawn_y, spawn_z};
    simulator_reset(env, spawn_pos);
}

BIBO_FUNC void bibo_env_step(BiboSimulator* env, float a0, float a1, float a2, float a3, float dt) {
    if (!env) return;
    float commands[4] = {a0, a1, a2, a3};
    simulator_step(env, commands, dt);
}

BIBO_FUNC void bibo_env_get_state(BiboSimulator* env, float* out_state) {
    if (!env || !out_state) return;

    // Ball Position (3)
    out_state[0] = env->ball.position.x;
    out_state[1] = env->ball.position.y;
    out_state[2] = env->ball.position.z;

    // Ball Velocity (3)
    out_state[3] = env->ball.velocity.x;
    out_state[4] = env->ball.velocity.y;
    out_state[5] = env->ball.velocity.z;

    // Ball Angular Velocity (3)
    out_state[6] = env->ball.omega.x;
    out_state[7] = env->ball.omega.y;
    out_state[8] = env->ball.omega.z;

    // Platform Quat (4)
    out_state[9]  = env->platform_state.pose.rotation.q[0];
    out_state[10] = env->platform_state.pose.rotation.q[1];
    out_state[11] = env->platform_state.pose.rotation.q[2];
    out_state[12] = env->platform_state.pose.rotation.q[3];

    // Actuator Lengths (4)
    out_state[13] = env->actuators[0].length;
    out_state[14] = env->actuators[1].length;
    out_state[15] = env->actuators[2].length;
    out_state[16] = env->actuators[3].length;

    // Actuator Rates (4)
    out_state[17] = env->actuators[0].length_rate;
    out_state[18] = env->actuators[1].length_rate;
    out_state[19] = env->actuators[2].length_rate;
    out_state[20] = env->actuators[3].length_rate;
}

BIBO_FUNC int bibo_env_is_stable(BiboSimulator* env) {
    return env ? env->stability.is_stable : 0;
}

BIBO_FUNC float bibo_env_get_energy(BiboSimulator* env) {
    return env ? env->total_energy : 0.0f;
}

BIBO_FUNC int bibo_env_get_step_count(BiboSimulator* env) {
    return env ? env->step_count : 0;
}
