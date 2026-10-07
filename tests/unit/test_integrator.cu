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
    ball.position = (Vec3){0.0f, 0.0f, 10.0f};
    ball.velocity = (Vec3){0.0f, 0.0f, 0.0f};
    ball.omega = (Vec3){0.0f, 0.0f, 0.0f};
    ball.in_contact = 0;

    float inertia = calculate_sphere_inertia(ball.mass, ball.radius);

    // Test 1: Falling under gravity
    Vec3 force = {0.0f, 0.0f, -19.62f}; // m * g (2.0 * -9.81)
    Vec3 torque = {0.0f, 0.0f, 0.0f};
    
    float dt = 0.1f;
    
    integrate_ball_state(&ball, force, torque, inertia, dt);
    
    // a = F/m = -9.81. v_new = 0 + -9.81 * 0.1 = -0.981
    ASSERT_APPROX(-0.981f, ball.velocity.z, 1e-4f, "velocity after step 1");
    // pos = 10.0 + (-0.981 * 0.1) = 9.9019 (Semi-implicit euler uses new velocity)
    ASSERT_APPROX(9.9019f, ball.position.z, 1e-4f, "position after step 1");

    // Test 2: Applying rotational torque
    Vec3 apply_torque = {0.1f, 0.0f, 0.0f}; // 0.1 Nm around X
    // inertia = 2/5 * 2.0 * 0.01 = 0.008
    // alpha = 0.1 / 0.008 = 12.5 rad/s^2
    // omega = 0 + 12.5 * 0.1 = 1.25 rad/s
    integrate_ball_state(&ball, (Vec3){0.0f,0.0f,0.0f}, apply_torque, inertia, dt);
    ASSERT_APPROX(1.25f, ball.omega.x, 1e-4f, "omega after torque");

    printf("All integrator tests passed!\n");
    return 0;
}
