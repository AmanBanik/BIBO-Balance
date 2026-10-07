#include "bibo/simulator.h"
#include <stdio.h>
#include <math.h>

#define ASSERT_APPROX(expected, actual, epsilon, msg) \
    if (fabs((expected) - (actual)) > (epsilon)) { \
        printf("FAIL: %s (Expected %f, got %f)\n", msg, (float)(expected), (float)(actual)); \
        return 1; \
    }

#define ASSERT_INT(expected, actual, msg) \
    if ((expected) != (actual)) { \
        printf("FAIL: %s (Expected %d, got %d)\n", msg, (int)(expected), (int)(actual)); \
        return 1; \
    }

int main() {
    BiboSimulator sim;
    simulator_init(&sim);
    
    // Spawn ball exactly at the center, resting precisely on the platform
    // Platform is at z=0.2 (neutral actuators). Radius is 0.02.
    // So COM is at 0.22.
    Vec3 start_pos = {0.0f, 0.0f, 0.22f};
    simulator_reset(&sim, start_pos);

    ASSERT_APPROX(0.22f, sim.ball.position.z, 1e-4f, "Initial position Z");
    ASSERT_INT(0, sim.step_count, "Initial step count");

    float dt = 0.01f;
    float commands[4] = {0.0f, 0.0f, 0.0f, 0.0f}; // No movement commanded

    // Step 1: Wait statically
    simulator_step(&sim, commands, dt);
    
    // Because ball is spawned precisely at rest, it should not move.
    ASSERT_INT(1, sim.ball.in_contact, "Ball should be in contact");
    ASSERT_APPROX(0.0f, sim.ball.velocity.z, 1e-4f, "Velocity Z should be neutralized by normal force");
    ASSERT_APPROX(0.22f, sim.ball.position.z, 1e-4f, "Position Z should be maintained");

    // Step 2: Command a tilt. Drop the right side (actuators 0, 1 -> -W/2 side)
    // Actually, let's just tip the front (actuators 1, 2).
    commands[1] = 0.05f; // Command +5cm to front
    commands[2] = 0.05f; 

    // Step for 10 frames (0.1s total)
    for (int i=0; i<10; i++) {
        simulator_step(&sim, commands, dt);
    }

    // Platform should have pitched, and ball should have started rolling backwards (negative X).
    // The physics loop is working entirely end-to-end!
    if (sim.ball.velocity.x >= -0.001f) {
        printf("FAIL: Ball did not accelerate backwards due to gravity projection. Vel X: %f\n", sim.ball.velocity.x);
        return 1;
    }
    // Since it rolls backwards (-X), omega_y must be negative.
    if (sim.ball.omega.y >= -0.001f) {
        printf("FAIL: Ball did not start rolling correctly. Omega Y: %f\n", sim.ball.omega.y);
        return 1;
    }

    printf("All monolithic simulator tests passed perfectly!\n");
    return 0;
}
