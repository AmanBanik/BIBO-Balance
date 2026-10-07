#include "bibo/physics.h"

// Semi-implicit Euler integration
BIBO_FUNC void integrate_ball_state(BallState* state, Vec3 force, Vec3 torque, float inertia, float dt) {
    // 1. Calculate translational and angular accelerations
    // a = F / m
    Vec3 accel = vec3_scale(force, 1.0f / state->mass);
    
    // alpha = T / I
    Vec3 alpha = {0.0f, 0.0f, 0.0f};
    if (inertia > 0.0f) {
        alpha = vec3_scale(torque, 1.0f / inertia);
    }

    // 2. Update velocities (v_next = v + a*dt)
    Vec3 delta_v = vec3_scale(accel, dt);
    state->velocity = vec3_add(state->velocity, delta_v);

    Vec3 delta_omega = vec3_scale(alpha, dt);
    state->omega = vec3_add(state->omega, delta_omega);

    // 3. Update position (p_next = p + v_next*dt)
    Vec3 delta_p = vec3_scale(state->velocity, dt);
    state->position = vec3_add(state->position, delta_p);
}
