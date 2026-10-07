#include "bibo/physics.h"

BIBO_FUNC float calculate_kinetic_energy(BallState state, float inertia) {
    float v_sq = vec3_dot(state.velocity, state.velocity);
    float omega_sq = vec3_dot(state.omega, state.omega);
    
    // Translational Kinetic Energy: 1/2 m v^2
    float ke_trans = 0.5f * state.mass * v_sq;
    
    // Rotational Kinetic Energy: 1/2 I w^2
    float ke_rot = 0.0f;
    if (inertia > 0.0f) {
        ke_rot = 0.5f * inertia * omega_sq;
    }
    
    return ke_trans + ke_rot;
}

BIBO_FUNC float calculate_potential_energy(BallState state, Vec3 gravity) {
    // General potential energy formula: PE = -m * (g . p)
    // If g is [0, 0, -9.81], then g . p = -9.81 * z.
    // Therefore PE = -m * (-9.81 * z) = m * 9.81 * z, exactly matching standard mgh.
    return -state.mass * vec3_dot(gravity, state.position);
}

BIBO_FUNC float calculate_total_energy(BallState state, float inertia, Vec3 gravity) {
    return calculate_kinetic_energy(state, inertia) + calculate_potential_energy(state, gravity);
}
