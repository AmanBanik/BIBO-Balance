#include "bibo/physics.h"
#include <math.h>

float calculate_normal_force(float mass, Vec3 gravity, Vec3 plane_normal) {
    // Normal force magnitude: N = max(0, -m * (g . n))
    // Assuming quasi-static normal force (platform acceleration effects ignored for V1)
    float g_dot_n = vec3_dot(gravity, plane_normal);
    float n_mag = -mass * g_dot_n;
    if (n_mag < 0.0f) {
        return 0.0f; // Ball is detaching or falling away
    }
    return n_mag;
}

Vec3 calculate_friction_force(float mass, float normal_force, float mu, Vec3 v_contact, Vec3 tangent_gravity) {
    float max_static_friction = mu * normal_force;
    float v_mag = vec3_mag(v_contact);
    
    // The force attempting to slide the ball down the plane
    Vec3 F_parallel = vec3_scale(tangent_gravity, mass);

    // If contact velocity is extremely small, we are in the static (pure rolling) regime
    if (v_mag < 1e-4f) {
        // Classic mechanics: to purely roll a solid sphere down an incline,
        // static friction must perfectly oppose exactly 2/3 of the parallel force.
        // F_req = - (2/5) / (1 + 2/5) * F_parallel = - (2/7)? 
        // Wait, I = 2/5 m r^2. a = F_net / m = (F_parallel + F_f) / m. 
        // alpha = (r x F_f) / I = r * F_f / (2/5 m r^2). 
        // a = alpha * r => F_net / m = 5/2 F_f / m => F_parallel + F_f = 2.5 F_f => F_parallel = 1.5 F_f.
        // Therefore F_f = (2/3) * F_parallel (magnitude), opposing the motion!
        // Correction: F_req = - (2/7) is for an incline where F_parallel = mg sin(theta). 
        // Wait, F_parallel - F_f = ma. r * F_f = I * alpha = (2/5 m r^2) * (a / r) => F_f = 2/5 m a.
        // => ma = 5/2 F_f. So F_parallel - F_f = 2.5 F_f => F_parallel = 3.5 F_f => F_f = 2/7 F_parallel!
        // Let's use F_f = 2/7 F_parallel.
        
        Vec3 F_req = vec3_scale(F_parallel, -2.0f / 7.0f);
        
        if (vec3_mag(F_req) <= max_static_friction) {
            return F_req; // Grip maintained (pure rolling)
        }
        
        // If required force exceeds static limit, we transition to kinetic sliding from rest.
        // Friction opposes the impending motion (F_parallel).
        Vec3 slip_dir = vec3_normalize(F_parallel);
        return vec3_scale(slip_dir, -max_static_friction);
    } else {
        // Kinetic sliding regime: friction completely opposes the actual contact sliding velocity.
        Vec3 slide_dir = vec3_normalize(v_contact);
        return vec3_scale(slide_dir, -max_static_friction);
    }
}
