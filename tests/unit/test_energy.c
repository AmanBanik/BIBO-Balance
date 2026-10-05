#include "bibo/physics.h"
#include <stdio.h>
#include <math.h>

#define ASSERT_APPROX(expected, actual, epsilon, msg) \
    if (fabs((expected) - (actual)) > (epsilon)) { \
        printf("FAIL: %s (Expected %f, got %f)\n", msg, (float)(expected), (float)(actual)); \
        return 1; \
    }

int main() {
    BallState ball;
    ball.mass = 2.0f;
    ball.radius = 0.1f;
    // z = 10m height
    ball.position = (Vec3){0.0f, 0.0f, 10.0f}; 
    // |v| = 5 m/s (v^2 = 25)
    ball.velocity = (Vec3){3.0f, 4.0f, 0.0f};  
    // |omega| = 10 rad/s (omega^2 = 100)
    ball.omega = (Vec3){10.0f, 0.0f, 0.0f};    
    
    // inertia = 2/5 * m * r^2 = 0.4 * 2.0 * 0.01 = 0.008
    float inertia = calculate_sphere_inertia(ball.mass, ball.radius); 

    // 1. Kinetic Energy
    // Trans: 0.5 * 2.0 * 25 = 25.0
    // Rot: 0.5 * 0.008 * 100 = 0.4
    // Total KE = 25.4
    float ke = calculate_kinetic_energy(ball, inertia);
    ASSERT_APPROX(25.4f, ke, 1e-4f, "Kinetic Energy Calculation");

    // 2. Potential Energy
    Vec3 gravity = {0.0f, 0.0f, -9.81f};
    // PE = mgh = 2.0 * 9.81 * 10 = 196.2
    float pe = calculate_potential_energy(ball, gravity);
    ASSERT_APPROX(196.2f, pe, 1e-4f, "Potential Energy Calculation");

    // 3. Total Energy
    float total = calculate_total_energy(ball, inertia, gravity);
    ASSERT_APPROX(221.6f, total, 1e-4f, "Total Energy Calculation");

    printf("All energy tests passed!\n");
    return 0;
}
