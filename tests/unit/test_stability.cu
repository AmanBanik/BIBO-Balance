#include "bibo/physics.h"
#include <stdio.h>
#include <math.h>

#define ASSERT_INT(expected, actual, msg) \
    if ((expected) != (actual)) { \
        printf("FAIL: %s (Expected %d, got %d)\n", msg, (int)(expected), (int)(actual)); \
        return 1; \
    }

int main() {
    StabilityTracker tracker;
    // Require 1.0s of continuous near-zero motion to be stable
    stability_tracker_init(&tracker, 1.0f, 0.05f, 0.1f);

    BallState ball;
    ball.velocity = (Vec3){0.01f, 0.0f, 0.0f}; // Very slow
    ball.omega = (Vec3){0.0f, 0.0f, 0.0f};

    Pose plat_pose;
    plat_pose.position = (Vec3){0.0f, 0.0f, 0.0f};
    plat_pose.rotation = quat_identity();

    PlatformGeometry plat;
    plat.length = 2.0f; // Half length is 1.0
    plat.width = 1.0f;

    ContactInfo contact;
    contact.state = CONTACT_TOUCHING;
    contact.contact_point = (Vec3){0.5f, 0.2f, 0.0f}; // Safely inside bounds

    float dt = 0.6f;

    // 1. Initial stable timeframe accumulation (0.6s total)
    stability_tracker_update(&tracker, ball, plat_pose, plat, contact, dt);
    ASSERT_INT(0, tracker.is_stable, "Not stable yet (0.6s)");

    // 2. Surpassing timeframe threshold (1.2s total)
    stability_tracker_update(&tracker, ball, plat_pose, plat, contact, dt);
    ASSERT_INT(1, tracker.is_stable, "Stable after 1.2s");

    // 3. Destabilized by physical speed spike
    ball.velocity = (Vec3){0.5f, 0.0f, 0.0f}; // Too fast
    stability_tracker_update(&tracker, ball, plat_pose, plat, contact, dt);
    ASSERT_INT(0, tracker.is_stable, "Stability broken by speed");

    // 4. Destabilized by falling off platform edge
    ball.velocity = (Vec3){0.01f, 0.0f, 0.0f}; // Slow again
    contact.contact_point = (Vec3){1.5f, 0.0f, 0.0f}; // Outside half-length (1.0)
    stability_tracker_update(&tracker, ball, plat_pose, plat, contact, dt);
    stability_tracker_update(&tracker, ball, plat_pose, plat, contact, dt); // Give it enough time
    ASSERT_INT(0, tracker.is_stable, "Stability denied due to out of bounds");

    printf("All stability tests passed!\n");
    return 0;
}
