#include "bibo/contact.h"
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
    Vec3 plane_pt = {0.0f, 0.0f, 0.0f};
    Vec3 plane_n = {0.0f, 0.0f, 1.0f};
    float radius = 0.1f;
    float epsilon = 1e-4f;

    // 1. Test Separated State
    Vec3 ball_pos_1 = {0.0f, 0.0f, 0.5f}; // center is 0.5 up, radius 0.1, dist = 0.4
    ContactInfo info1 = check_sphere_plane_contact(ball_pos_1, radius, plane_pt, plane_n, epsilon);
    ASSERT_APPROX(0.4f, info1.distance, 1e-5f, "separated distance");
    ASSERT_INT(CONTACT_SEPARATED, info1.state, "separated state");

    // 2. Test Touching State (exact surface contact)
    Vec3 ball_pos_2 = {2.0f, 1.0f, 0.1f}; // Moved laterally, but Z = 0.1
    ContactInfo info2 = check_sphere_plane_contact(ball_pos_2, radius, plane_pt, plane_n, epsilon);
    ASSERT_APPROX(0.0f, info2.distance, 1e-5f, "touching distance");
    ASSERT_INT(CONTACT_TOUCHING, info2.state, "touching state");
    
    // Contact point on plane should be directly under the ball at Z=0
    ASSERT_APPROX(2.0f, info2.contact_point.x, 1e-5f, "touching contact X");
    ASSERT_APPROX(1.0f, info2.contact_point.y, 1e-5f, "touching contact Y");
    ASSERT_APPROX(0.0f, info2.contact_point.z, 1e-5f, "touching contact Z");

    // 3. Test Penetrating State (numerical integration error scenario)
    Vec3 ball_pos_3 = {0.0f, 0.0f, 0.05f}; // distance = 0.05 - 0.1 = -0.05
    ContactInfo info3 = check_sphere_plane_contact(ball_pos_3, radius, plane_pt, plane_n, epsilon);
    ASSERT_APPROX(-0.05f, info3.distance, 1e-5f, "penetrating distance");
    ASSERT_INT(CONTACT_PENETRATING, info3.state, "penetrating state");

    printf("All contact tests passed!\n");
    return 0;
}
