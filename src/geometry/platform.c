#include "bibo/geometry.h"

Vec3 platform_corner_world(Pose p, Vec3 corner_local) {
    Vec3 rotated = quat_rotate_vec3(p.rotation, corner_local);
    return vec3_add(p.position, rotated);
}

Vec3 platform_normal(Pose p) {
    // Normal is just the rotated world up vector (+Z)
    Vec3 up = {0.0f, 0.0f, 1.0f};
    return quat_rotate_vec3(p.rotation, up);
}
