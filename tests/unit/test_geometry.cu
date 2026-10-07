#include "bibo/geometry.h"
#include <stdio.h>
#include <math.h>

#define ASSERT_APPROX(expected, actual, epsilon, msg) \
    if (fabs((expected) - (actual)) > (epsilon)) { \
        printf("FAIL: %s (Expected %f, got %f)\n", msg, (float)(expected), (float)(actual)); \
        return 1; \
    }

int main() {
    // 1. Test quaternion identity and axis-angle
    Quat id = quat_identity();
    Vec3 up = {0.0f, 0.0f, 1.0f};
    Vec3 rot_up = quat_rotate_vec3(id, up);
    ASSERT_APPROX(0.0f, rot_up.x, 1e-5f, "id rotate X");
    ASSERT_APPROX(0.0f, rot_up.y, 1e-5f, "id rotate Y");
    ASSERT_APPROX(1.0f, rot_up.z, 1e-5f, "id rotate Z");

    Vec3 axis = {1.0f, 0.0f, 0.0f};
    // 90 deg around X-axis
    Quat q = quat_from_axis_angle(axis, M_PI / 2.0f);
    Vec3 fwd = {0.0f, 1.0f, 0.0f};
    Vec3 rot_fwd = quat_rotate_vec3(q, fwd);
    ASSERT_APPROX(0.0f, rot_fwd.x, 1e-5f, "rot_fwd X");
    ASSERT_APPROX(0.0f, rot_fwd.y, 1e-5f, "rot_fwd Y");
    ASSERT_APPROX(1.0f, rot_fwd.z, 1e-5f, "rot_fwd Z");

    // 2. Test platform geometry
    Pose p;
    p.position = (Vec3){0.0f, 0.0f, 1.0f};
    p.rotation = quat_identity();
    
    Vec3 corner_local = {1.5f, 0.5f, 0.0f};
    Vec3 corner_world = platform_corner_world(p, corner_local);
    ASSERT_APPROX(1.5f, corner_world.x, 1e-5f, "corner world X");
    ASSERT_APPROX(0.5f, corner_world.y, 1e-5f, "corner world Y");
    ASSERT_APPROX(1.0f, corner_world.z, 1e-5f, "corner world Z");

    Vec3 normal = platform_normal(p);
    ASSERT_APPROX(0.0f, normal.x, 1e-5f, "normal X");
    ASSERT_APPROX(0.0f, normal.y, 1e-5f, "normal Y");
    ASSERT_APPROX(1.0f, normal.z, 1e-5f, "normal Z");

    // 3. Test rod geometry
    Vec3 base = {1.5f, 0.5f, 0.0f};
    float dist = rod_distance(base, corner_world);
    ASSERT_APPROX(1.0f, dist, 1e-5f, "rod distance");

    printf("All geometry tests passed!\n");
    return 0;
}
