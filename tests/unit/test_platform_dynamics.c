#include "bibo/physics.h"
#include <stdio.h>
#include <math.h>

#define ASSERT_APPROX(expected, actual, epsilon, msg) \
    if (fabs((expected) - (actual)) > (epsilon)) { \
        printf("FAIL: %s (Expected %f, got %f)\n", msg, (float)(expected), (float)(actual)); \
        return 1; \
    }

int main() {
    PlatformState plat;
    plat.pose.position = (Vec3){0.0f, 0.0f, 0.0f};
    // Platform pitching around Y axis at 2 rad/s
    plat.angular_velocity = (Vec3){0.0f, 2.0f, 0.0f};
    plat.linear_velocity = (Vec3){0.0f, 0.0f, 1.0f}; // Platform moving up at 1m/s

    Vec3 contact_point = {1.0f, 0.0f, 0.0f}; // 1m forward on X axis

    // 1. Surface Velocity Test
    // Linear Z is +1.0. 
    // Angular cross: (0, 2, 0) x (1, 0, 0) = (0, 0, -2.0)
    // Total Z velocity of that point = 1.0 - 2.0 = -1.0
    Vec3 plat_v = calculate_platform_surface_velocity(plat, contact_point);
    ASSERT_APPROX(0.0f, plat_v.x, 1e-5f, "Plat V_x");
    ASSERT_APPROX(0.0f, plat_v.y, 1e-5f, "Plat V_y");
    ASSERT_APPROX(-1.0f, plat_v.z, 1e-5f, "Plat V_z (Combined linear and angular)");

    // 2. Relative Velocity Test
    // Ball is stationary in space
    Vec3 ball_v = {0.0f, 0.0f, 0.0f};
    Vec3 v_rel = calculate_relative_contact_velocity(ball_v, plat_v);
    
    // Relative to the ball, the platform swiping DOWN means the ball feels an UPWARDS relative swipe
    ASSERT_APPROX(0.0f, v_rel.x, 1e-5f, "Rel V_x");
    ASSERT_APPROX(0.0f, v_rel.y, 1e-5f, "Rel V_y");
    ASSERT_APPROX(1.0f, v_rel.z, 1e-5f, "Rel V_z");

    printf("All platform dynamics tests passed!\n");
    return 0;
}
