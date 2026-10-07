#include "bibo/simulator.h"
#include <math.h>

BIBO_FUNC void simulator_init(BiboSimulator* sim) {
    // Standard platform bounds (60cm x 20cm -> 3:1 ratio)
    sim->platform_geom.length = 0.6f;
    sim->platform_geom.width = 0.2f;

    // Standard actuator constraints
    for(int i=0; i<4; i++) {
        sim->actuators[i].length_min = 0.1f;
        sim->actuators[i].length_max = 0.3f;
        sim->actuators[i].rate_limit = 0.5f; 
        actuator_reset(&sim->actuators[i], 0.2f);
    }

    // World properties
    sim->gravity = (Vec3){0.0f, 0.0f, -9.81f};
    sim->friction_mu = 0.3f;

    // Ball properties
    sim->ball.mass = 0.5f;      // 500g
    sim->ball.radius = 0.02f;   // 2cm radius
    
    // Stability requirements: 2.0s of near-zero motion
    stability_tracker_init(&sim->stability, 2.0f, 0.05f, 0.1f);
    
    sim->step_count = 0;
    sim->time_elapsed = 0.0f;
}

BIBO_FUNC void simulator_reset(BiboSimulator* sim, Vec3 start_pos) {
    sim->ball.position = start_pos;
    sim->ball.velocity = (Vec3){0.0f, 0.0f, 0.0f};
    sim->ball.omega = (Vec3){0.0f, 0.0f, 0.0f};
    sim->ball.in_contact = 0;

    for(int i=0; i<4; i++) {
        actuator_reset(&sim->actuators[i], 0.2f);
    }

    sim->platform_state = calculate_platform_state(sim->actuators, sim->platform_geom);
    stability_tracker_init(&sim->stability, 2.0f, 0.05f, 0.1f);

    sim->step_count = 0;
    sim->time_elapsed = 0.0f;
    
    float inertia = calculate_sphere_inertia(sim->ball.mass, sim->ball.radius);
    sim->total_energy = calculate_total_energy(sim->ball, inertia, sim->gravity);
}

BIBO_FUNC void simulator_step(BiboSimulator* sim, float commands[4], float dt) {
    if (dt <= 0.0f) return;

    // 1. Update Actuators (Hardware rate limiting is applied here)
    for(int i=0; i<4; i++) {
        actuator_apply_command(&sim->actuators[i], commands[i], dt);
    }

    // 2. Solve Platform Kinematics
    sim->platform_state = calculate_platform_state(sim->actuators, sim->platform_geom);

    // 3. Collision Detection
    // The platform's normal is the local Z axis (0,0,1) rotated by its orientation
    Vec3 local_up = {0.0f, 0.0f, 1.0f};
    Vec3 plane_normal = quat_rotate_vec3(sim->platform_state.pose.rotation, local_up);
    
    ContactInfo contact = check_sphere_plane_contact(
        sim->ball.position, 
        sim->ball.radius, 
        sim->platform_state.pose.position, 
        plane_normal, 
        1e-4f // epsilon
    );
    sim->ball.in_contact = (contact.state != CONTACT_SEPARATED);

    // 4. Resolve Forces
    Vec3 total_force = vec3_scale(sim->gravity, sim->ball.mass); 
    Vec3 total_torque = {0.0f, 0.0f, 0.0f};

    if (sim->ball.in_contact) {
        // Penetration Resolution (Push ball out to prevent falling through)
        if (contact.state == CONTACT_PENETRATING) {
            float penetration_depth = -contact.distance;
            Vec3 correction = vec3_scale(contact.normal, penetration_depth);
            sim->ball.position = vec3_add(sim->ball.position, correction);
            
            // Inelastic collision (cancel velocity into the plane)
            float v_dot_n = vec3_dot(sim->ball.velocity, contact.normal);
            if (v_dot_n < 0.0f) {
                Vec3 v_normal = vec3_scale(contact.normal, v_dot_n);
                sim->ball.velocity = vec3_sub(sim->ball.velocity, v_normal);
            }
        }

        float fn = calculate_normal_force(sim->ball.mass, sim->gravity, contact.normal);
        
        if (fn > 0.0f) {
            // Apply Normal Force to cancel gravity into the plane
            Vec3 normal_force_vec = vec3_scale(contact.normal, fn);
            total_force = vec3_add(total_force, normal_force_vec);

            // Compute velocities at the specific contact point
            Vec3 plat_v = calculate_platform_surface_velocity(sim->platform_state, contact.contact_point);
            Vec3 r_rel = vec3_scale(contact.normal, -sim->ball.radius); 
            Vec3 omega_cross_r = vec3_cross(sim->ball.omega, r_rel);
            Vec3 ball_v_contact = vec3_add(sim->ball.velocity, omega_cross_r);
            
            // Derive relative velocity for friction injection
            Vec3 v_rel = calculate_relative_contact_velocity(ball_v_contact, plat_v);

            // Calculate tangential gravity for the rolling check
            float g_dot_n = vec3_dot(sim->gravity, contact.normal);
            Vec3 g_normal = vec3_scale(contact.normal, g_dot_n);
            Vec3 tangent_gravity = vec3_scale(vec3_sub(sim->gravity, g_normal), sim->ball.mass);

            // Friction Force
            Vec3 f_frict = calculate_friction_force(sim->ball.mass, fn, sim->friction_mu, v_rel, tangent_gravity);
            total_force = vec3_add(total_force, f_frict);
            
            // Friction Torque: tau = r_rel x F_frict
            total_torque = vec3_cross(r_rel, f_frict);
        }
    }

    // 5. Integrate Time (Semi-Implicit Euler)
    float inertia = calculate_sphere_inertia(sim->ball.mass, sim->ball.radius);
    integrate_ball_state(&sim->ball, total_force, total_torque, inertia, dt);

    // 6. Diagnostics & Stability window
    stability_tracker_update(&sim->stability, sim->ball, sim->platform_state.pose, sim->platform_geom, contact, dt);
    sim->total_energy = calculate_total_energy(sim->ball, inertia, sim->gravity);
    
    sim->step_count++;
    sim->time_elapsed += dt;
}
