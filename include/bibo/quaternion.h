#ifndef BIBO_QUATERNION_H
#define BIBO_QUATERNION_H

#include "bibo/types.h"
#include "bibo/vectors.h"

// Quaternion operations
Quat quat_identity(void);
Quat quat_multiply(Quat a, Quat b);
Quat quat_conjugate(Quat q);
Vec3 quat_rotate_vec3(Quat q, Vec3 v);
Quat quat_from_axis_angle(Vec3 axis, float angle);

#endif // BIBO_QUATERNION_H
