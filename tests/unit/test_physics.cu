#include "bibo/physics.h"
#include <stdio.h>
#include <math.h>

#define ASSERT_APPROX(expected, actual, epsilon, msg) \
    if (fabs((expected) - (actual)) > (epsilon)) { \
        printf("FAIL: %s (Expected %f, got %f)\n", msg, (float)(expected), (float)(actual)); \
        return 1; \
    }

int main() {
    // 1. Test Spherical Gravity (Pointing straight down)
    // phi = PI radians (180 degrees) means pointing entirely in -Z
    GravityConfig g_cfg = {9.81f, 0.0f, (float)M_PI};
    Vec3 g = gravity_from_spherical(g_cfg);
    
    ASSERT_APPROX(0.0f, g.x, 1e-5f, "gravity X straight down");
    ASSERT_APPROX(0.0f, g.y, 1e-5f, "gravity Y straight down");
    ASSERT_APPROX(-9.81f, g.z, 1e-5f, "gravity Z straight down");

    // 2. Test Normal and Tangent Projections
    // Imagine the platform is tilted 45 degrees around the Y axis
    // Normal vector would be [sqrt(2)/2, 0, sqrt(2)/2]
    Vec3 normal = {0.70710678f, 0.0f, 0.70710678f};
    Vec3 gn = gravity_normal_component(g, normal);
    Vec3 gt = gravity_tangent_component(g, normal);

    // The normal component and tangent component should be perfectly orthogonal (dot product = 0)
    float ortho_check = vec3_dot(gn, gt);
    ASSERT_APPROX(0.0f, ortho_check, 1e-5f, "gn and gt orthogonality");

    // Their sum should equal the original gravity vector
    Vec3 sum = vec3_add(gn, gt);
    ASSERT_APPROX(g.x, sum.x, 1e-5f, "sum X equals g.x");
    ASSERT_APPROX(g.y, sum.y, 1e-5f, "sum Y equals g.y");
    ASSERT_APPROX(g.z, sum.z, 1e-5f, "sum Z equals g.z");

    printf("All physics gravity tests passed!\n");
    return 0;
}
