#include "bibo/physics.h"
#include <math.h>

Vec3 gravity_from_spherical(GravityConfig config) {
    Vec3 out;
    // Using the master.md spherical coordinate mapping
    out.x = config.magnitude * sinf(config.phi) * cosf(config.theta);
    out.y = config.magnitude * sinf(config.phi) * sinf(config.theta);
    out.z = config.magnitude * cosf(config.phi);
    return out;
}

Vec3 gravity_normal_component(Vec3 gravity, Vec3 plane_normal) {
    float gn = vec3_dot(gravity, plane_normal);
    return vec3_scale(plane_normal, gn);
}

Vec3 gravity_tangent_component(Vec3 gravity, Vec3 plane_normal) {
    Vec3 gn = gravity_normal_component(gravity, plane_normal);
    return vec3_sub(gravity, gn);
}
