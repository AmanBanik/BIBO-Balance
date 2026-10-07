#include "bibo/vectors.h"
#include <math.h>

BIBO_FUNC Vec3 vec3_add(Vec3 a, Vec3 b) {
    Vec3 r = {a.x + b.x, a.y + b.y, a.z + b.z};
    return r;
}

BIBO_FUNC Vec3 vec3_sub(Vec3 a, Vec3 b) {
    Vec3 r = {a.x - b.x, a.y - b.y, a.z - b.z};
    return r;
}

BIBO_FUNC Vec3 vec3_scale(Vec3 v, float s) {
    Vec3 r = {v.x * s, v.y * s, v.z * s};
    return r;
}

BIBO_FUNC float vec3_dot(Vec3 a, Vec3 b) {
    return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
}

BIBO_FUNC Vec3 vec3_cross(Vec3 a, Vec3 b) {
    Vec3 r = {
        (a.y * b.z) - (a.z * b.y),
        (a.z * b.x) - (a.x * b.z),
        (a.x * b.y) - (a.y * b.x)
    };
    return r;
}

BIBO_FUNC float vec3_mag_sq(Vec3 v) {
    return vec3_dot(v, v);
}

BIBO_FUNC float vec3_mag(Vec3 v) {
    return sqrtf(vec3_mag_sq(v));
}

BIBO_FUNC Vec3 vec3_normalize(Vec3 v) {
    float m = vec3_mag(v);
    if (m > 1e-8f) {
        return vec3_scale(v, 1.0f / m);
    }
    Vec3 zero = {0.0f, 0.0f, 0.0f};
    return zero;
}
