#ifndef BIBO_QUATERNION_H
#define BIBO_QUATERNION_H

#include "bibo/cuda_utils.h"

#include "bibo/types.h"
#include "bibo/vectors.h"

// Quaternion operations
BIBO_FUNC Quat quat_identity(void);
BIBO_FUNC Quat quat_multiply(Quat a, Quat b);
BIBO_FUNC Quat quat_conjugate(Quat q);
BIBO_FUNC Vec3 quat_rotate_vec3(Quat q, Vec3 v);
BIBO_FUNC Quat quat_from_axis_angle(Vec3 axis, float angle);

#endif // BIBO_QUATERNION_H
