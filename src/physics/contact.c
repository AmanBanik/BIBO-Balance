#include "bibo/contact.h"
#include <math.h>

ContactInfo check_sphere_plane_contact(Vec3 ball_center, float ball_radius, Vec3 plane_point, Vec3 plane_normal, float epsilon) {
    ContactInfo info;
    info.normal = plane_normal;

    // 1. Calculate distance from ball center to the infinite plane: d_center = n . (r - P_0)
    Vec3 diff = vec3_sub(ball_center, plane_point);
    float d_center = vec3_dot(plane_normal, diff);

    // 2. True distance from the sphere's surface to the plane
    info.distance = d_center - ball_radius;

    // 3. Find the exact point of contact on the plane surface
    // P_contact = ball_center - d_center * plane_normal
    Vec3 projection_offset = vec3_scale(plane_normal, d_center);
    info.contact_point = vec3_sub(ball_center, projection_offset);

    // 4. Categorize the contact state
    if (info.distance > epsilon) {
        info.state = CONTACT_SEPARATED;
    } else if (info.distance < -epsilon) {
        info.state = CONTACT_PENETRATING;
    } else {
        info.state = CONTACT_TOUCHING;
    }

    return info;
}
