#include "bibo/kinematics.h"
#include <stdio.h>
#include <math.h>

#define ASSERT_APPROX(expected, actual, epsilon, msg) \
    if (fabs((expected) - (actual)) > (epsilon)) { \
        printf("FAIL: %s (Expected %f, got %f)\n", msg, (float)(expected), (float)(actual)); \
        return 1; \
    }

int main() {
    ActuatorState acts[4];
    for (int i = 0; i < 4; i++) {
        acts[i].length = 0.2f;
        acts[i].length_rate = 0.0f;
    }

    PlatformGeometry geom;
    geom.length = 2.0f;
    geom.width = 1.0f;

    // 1. Test perfectly flat and static platform
    PlatformState state = calculate_platform_state(acts, geom);
    ASSERT_APPROX(0.2f, state.pose.position.z, 1e-5f, "Flat Z position");
    ASSERT_APPROX(0.0f, state.pose.rotation.q[0], 1e-5f, "Flat rot x");
    ASSERT_APPROX(0.0f, state.pose.rotation.q[1], 1e-5f, "Flat rot y");
    ASSERT_APPROX(0.0f, state.pose.rotation.q[2], 1e-5f, "Flat rot z");
    ASSERT_APPROX(1.0f, state.pose.rotation.q[3], 1e-5f, "Flat rot w");
    ASSERT_APPROX(0.0f, state.angular_velocity.x, 1e-5f, "Flat ang vel");

    // 2. Test pitching motion (front actuators higher and rising, back actuators lower and dropping)
    acts[0].length = 0.1f; // Back Right
    acts[3].length = 0.1f; // Back Left
    acts[1].length = 0.3f; // Front Right
    acts[2].length = 0.3f; // Front Left
    
    acts[0].length_rate = -0.5f;
    acts[3].length_rate = -0.5f;
    acts[1].length_rate = 0.5f;
    acts[2].length_rate = 0.5f;

    state = calculate_platform_state(acts, geom);
    
    // Average Z should still be exactly 0.2m, and linear Z velocity should be exactly 0.0
    ASSERT_APPROX(0.2f, state.pose.position.z, 1e-5f, "Pitch Z position (avg)");
    ASSERT_APPROX(0.0f, state.linear_velocity.z, 1e-5f, "Pitch linear velocity Z");

    // Angular velocity around Y (pitch axis)
    // Rate of change of slope X: ( (0.5 + 0.5) - (-0.5 + -0.5) ) / (2.0 * 2.0) = (1.0 - -1.0) / 4.0 = 2.0 / 4.0 = 0.5 rad/s
    ASSERT_APPROX(0.5f, state.angular_velocity.y, 1e-5f, "Pitch angular velocity Y");
    ASSERT_APPROX(0.0f, state.angular_velocity.x, 1e-5f, "Pitch angular velocity X");

    printf("All kinematics solver tests passed!\n");
    return 0;
}
