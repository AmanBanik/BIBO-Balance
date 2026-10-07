#include "bibo/vectors.h"
#include <stdio.h>
#include <math.h>

#define ASSERT_APPROX(expected, actual, epsilon, msg) \
    if (fabs((expected) - (actual)) > (epsilon)) { \
        printf("FAIL: %s (Expected %f, got %f)\n", msg, (float)(expected), (float)(actual)); \
        return 1; \
    }

int main() {
    Vec3 a = {1.0f, 2.0f, 3.0f};
    Vec3 b = {4.0f, 5.0f, 6.0f};

    Vec3 sum = vec3_add(a, b);
    ASSERT_APPROX(5.0f, sum.x, 1e-5f, "add X");
    ASSERT_APPROX(7.0f, sum.y, 1e-5f, "add Y");
    ASSERT_APPROX(9.0f, sum.z, 1e-5f, "add Z");

    float dot = vec3_dot(a, b);
    ASSERT_APPROX(32.0f, dot, 1e-5f, "dot product");

    Vec3 cross = vec3_cross(a, b);
    ASSERT_APPROX(-3.0f, cross.x, 1e-5f, "cross X");
    ASSERT_APPROX(6.0f, cross.y, 1e-5f, "cross Y");
    ASSERT_APPROX(-3.0f, cross.z, 1e-5f, "cross Z");
    
    Vec3 norm = vec3_normalize(a);
    float norm_mag = vec3_mag(norm);
    ASSERT_APPROX(1.0f, norm_mag, 1e-5f, "normalized magnitude");

    printf("All vector tests passed!\n");
    return 0;
}
