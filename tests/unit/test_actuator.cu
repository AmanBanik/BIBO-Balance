#include "bibo/actuator.h"
#include <stdio.h>
#include <math.h>

#define ASSERT_APPROX(expected, actual, epsilon, msg) \
    if (fabs((expected) - (actual)) > (epsilon)) { \
        printf("FAIL: %s (Expected %f, got %f)\n", msg, (float)(expected), (float)(actual)); \
        return 1; \
    }

int main() {
    ActuatorState act;
    act.length_min = 0.1f;    // 10cm min stroke
    act.length_max = 0.3f;    // 30cm max stroke
    act.rate_limit = 0.5f;    // max 50cm per second speed

    // Initialize at center
    actuator_reset(&act, 0.2f);
    ASSERT_APPROX(0.2f, act.length, 1e-4f, "Reset length");
    ASSERT_APPROX(0.0f, act.length_rate, 1e-4f, "Reset rate");

    float dt = 0.1f;

    // 1. Normal command (within rate limits)
    // Command +2cm in 0.1s => rate = 0.2m/s, which is < 0.5m/s max
    actuator_apply_command(&act, 0.02f, dt);
    ASSERT_APPROX(0.22f, act.length, 1e-4f, "Normal command length");
    ASSERT_APPROX(0.2f, act.length_rate, 1e-4f, "Normal command rate");

    // 2. Rate-limited command (trying to move too fast)
    // Command +10cm in 0.1s => rate = 1.0m/s (Exceeds 0.5m/s!)
    // Should cap at 0.5m/s * 0.1s = 0.05m movement.
    actuator_apply_command(&act, 0.10f, dt);
    ASSERT_APPROX(0.27f, act.length, 1e-4f, "Rate limited length");
    ASSERT_APPROX(0.5f, act.length_rate, 1e-4f, "Rate limited velocity");

    // 3. Absolute boundary command (hitting the ceiling)
    // Command +10cm in 0.1s again (capped at 0.05m movement).
    // Current is 0.27, wants to go to 0.32, but max is 0.30!
    actuator_apply_command(&act, 0.10f, dt);
    ASSERT_APPROX(0.30f, act.length, 1e-4f, "Stroke bounded length");
    // Actual achieved distance is 0.30 - 0.27 = 0.03m. Over 0.1s = 0.3m/s velocity
    ASSERT_APPROX(0.3f, act.length_rate, 1e-4f, "Stroke bounded velocity");

    printf("All actuator tests passed!\n");
    return 0;
}
