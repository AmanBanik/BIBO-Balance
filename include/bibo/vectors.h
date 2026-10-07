#ifndef BIBO_VECTORS_H
#define BIBO_VECTORS_H

#include "bibo/cuda_utils.h"

#include "bibo/types.h"

// Basic 3D vector operations
BIBO_FUNC Vec3 vec3_add(Vec3 a, Vec3 b);
BIBO_FUNC Vec3 vec3_sub(Vec3 a, Vec3 b);
BIBO_FUNC Vec3 vec3_scale(Vec3 v, float s);
BIBO_FUNC float vec3_dot(Vec3 a, Vec3 b);
BIBO_FUNC Vec3 vec3_cross(Vec3 a, Vec3 b);
BIBO_FUNC float vec3_mag_sq(Vec3 v);
BIBO_FUNC float vec3_mag(Vec3 v);
BIBO_FUNC Vec3 vec3_normalize(Vec3 v);

#endif // BIBO_VECTORS_H
