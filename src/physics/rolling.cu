#include "bibo/physics.h"

BIBO_FUNC float calculate_sphere_inertia(float mass, float radius) {
    // Solid sphere: I = 2/5 * m * r^2
    return (2.0f / 5.0f) * mass * radius * radius;
}

BIBO_FUNC Vec3 calculate_contact_velocity(Vec3 ball_velocity, Vec3 ball_omega, float ball_radius, Vec3 plane_normal) {
    // Vector from ball center to contact point: r_rel = -radius * normal
    Vec3 r_rel = vec3_scale(plane_normal, -ball_radius);
    
    // v_contact = v + (omega x r_rel)
    Vec3 omega_cross_r = vec3_cross(ball_omega, r_rel);
    return vec3_add(ball_velocity, omega_cross_r);
}
