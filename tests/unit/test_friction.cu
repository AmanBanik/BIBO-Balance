#include "bibo/physics.h"
#include <stdio.h>
#include <math.h>

#define ASSERT_APPROX(expected, actual, epsilon, msg) \
    if (fabs((expected) - (actual)) > (epsilon)) { \
        printf("FAIL: %s (Expected %f, got %f)\n", msg, (float)(expected), (float)(actual)); \
        return 1; \
    }

int main() {
    float mass = 0.15f;
    float radius = 0.08f;
    
    // 1. Inertia
    float inertia = calculate_sphere_inertia(mass, radius);
    float expected_inertia = 0.4f * mass * radius * radius;
    ASSERT_APPROX(expected_inertia, inertia, 1e-6f, "Sphere inertia");

    // 2. Normal Force
    Vec3 gravity = {0.0f, 0.0f, -9.81f};
    Vec3 normal = {0.0f, 0.0f, 1.0f}; // Flat platform
    float n_force = calculate_normal_force(mass, gravity, normal);
    ASSERT_APPROX(0.15f * 9.81f, n_force, 1e-5f, "Normal force (flat)");

    // 3. Contact Velocity
    Vec3 vel = {1.0f, 0.0f, 0.0f}; // Moving along X at 1 m/s
    // If pure rolling, omega should be such that v_contact is 0.
    // v + (omega x r_rel) = 0. r_rel = (0, 0, -r).
    // omega x (0, 0, -r) = (omega_y * -r, -omega_x * -r, 0) = (-r*omega_y, r*omega_x, 0)
    // To cancel v=(1, 0, 0), we need -r*omega_y = -1 => omega_y = 1/r = 1/0.08 = 12.5.
    Vec3 omega = {0.0f, 12.5f, 0.0f};
    Vec3 v_contact = calculate_contact_velocity(vel, omega, radius, normal);
    ASSERT_APPROX(0.0f, v_contact.x, 1e-4f, "Contact vel X (pure rolling)");
    ASSERT_APPROX(0.0f, v_contact.y, 1e-4f, "Contact vel Y (pure rolling)");

    // 4. Friction Force (Pure Rolling / Static)
    // Tangent gravity pulling along X
    Vec3 tangent_g = {5.0f, 0.0f, 0.0f}; 
    // V_contact is 0, so it should be static friction = -2/7 * mass * tangent_g
    Vec3 F_f = calculate_friction_force(mass, n_force, 0.9f, v_contact, tangent_g);
    float expected_f_x = -(2.0f/7.0f) * mass * 5.0f;
    ASSERT_APPROX(expected_f_x, F_f.x, 1e-5f, "Static friction X (pure rolling grip)");
    ASSERT_APPROX(0.0f, F_f.y, 1e-5f, "Static friction Y");

    // 5. Friction Force (Sliding / Kinetic)
    // Ball sliding fast along X
    Vec3 slide_v_contact = {2.0f, 0.0f, 0.0f};
    Vec3 F_k = calculate_friction_force(mass, n_force, 0.9f, slide_v_contact, tangent_g);
    float expected_k_x = - (0.9f * n_force);
    ASSERT_APPROX(expected_k_x, F_k.x, 1e-5f, "Kinetic friction X (sliding)");

    printf("All friction/rolling tests passed!\n");
    return 0;
}
