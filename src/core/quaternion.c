#include "bibo/quaternion.h"
#include <math.h>

Quat quat_identity(void) {
    Quat r = {{0.0f, 0.0f, 0.0f, 1.0f}};
    return r;
}

Quat quat_multiply(Quat a, Quat b) {
    Quat r;
    r.q[0] = a.q[3]*b.q[0] + a.q[0]*b.q[3] + a.q[1]*b.q[2] - a.q[2]*b.q[1];
    r.q[1] = a.q[3]*b.q[1] - a.q[0]*b.q[2] + a.q[1]*b.q[3] + a.q[2]*b.q[0];
    r.q[2] = a.q[3]*b.q[2] + a.q[0]*b.q[1] - a.q[1]*b.q[0] + a.q[2]*b.q[3];
    r.q[3] = a.q[3]*b.q[3] - a.q[0]*b.q[0] - a.q[1]*b.q[1] - a.q[2]*b.q[2];
    return r;
}

Quat quat_conjugate(Quat q) {
    Quat r = {{-q.q[0], -q.q[1], -q.q[2], q.q[3]}};
    return r;
}

Vec3 quat_rotate_vec3(Quat q, Vec3 v) {
    Quat vq = {{v.x, v.y, v.z, 0.0f}};
    Quat inv = quat_conjugate(q);
    Quat tmp = quat_multiply(q, vq);
    Quat out = quat_multiply(tmp, inv);
    Vec3 r = {out.q[0], out.q[1], out.q[2]};
    return r;
}

Quat quat_from_axis_angle(Vec3 axis, float angle) {
    float half_angle = angle * 0.5f;
    float s = sinf(half_angle);
    Vec3 norm = vec3_normalize(axis);
    Quat r;
    r.q[0] = norm.x * s;
    r.q[1] = norm.y * s;
    r.q[2] = norm.z * s;
    r.q[3] = cosf(half_angle);
    return r;
}
