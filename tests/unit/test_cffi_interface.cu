#include "bibo/cffi_interface.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define ASSERT_APPROX(expected, actual, epsilon, msg) \
    if (fabs((expected) - (actual)) > (epsilon)) { \
        printf("FAIL: %s (Expected %f, got %f)\n", msg, (float)(expected), (float)(actual)); \
        return 1; \
    }

int main() {
    // 1. Allocate engine
    BiboSimulator* env = bibo_env_create();
    if (!env) {
        printf("FAIL: Failed to allocate env on heap\n");
        return 1;
    }

    // 2. Reset exactly at rest
    bibo_env_reset(env, 0.0f, 0.0f, 0.22f);
    
    // 3. Command front actuators to rise, back to lower
    bibo_env_step(env, -0.01f, -0.01f, 0.01f, 0.01f, 0.01f);
    
    // 4. Extract state safely via flattened ABI
    float state[21];
    bibo_env_get_state(env, state);
    
    // Actuator 0 (Back Right):
    // Neutral = 0.2m. Command = -0.01m over 0.01s. Target rate = -1.0m/s.
    // Rate limits to -0.5m/s. Over 0.01s = -0.005m.
    // Resulting length = 0.2 - 0.005 = 0.195m.
    ASSERT_APPROX(0.195f, state[13], 1e-4f, "CFFI Extract: Actuator 0 length rate clamped");
    
    // Actuator 2 (Front Left):
    // Neutral = 0.2m. Command = +0.01m over 0.01s. Rate limits to +0.5m/s.
    // Resulting length = 0.205m
    ASSERT_APPROX(0.205f, state[15], 1e-4f, "CFFI Extract: Actuator 2 length rate clamped");

    // Clean up
    bibo_env_destroy(env);
    
    printf("All CFFI ABI interface tests passed!\n");
    return 0;
}
