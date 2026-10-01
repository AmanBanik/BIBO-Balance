#ifndef BIBO_VECTORS_H
#define BIBO_VECTORS_H

#include "bibo/types.h"

// Basic 3D vector operations
Vec3 vec3_add(Vec3 a, Vec3 b);
Vec3 vec3_sub(Vec3 a, Vec3 b);
Vec3 vec3_scale(Vec3 v, float s);
float vec3_dot(Vec3 a, Vec3 b);
Vec3 vec3_cross(Vec3 a, Vec3 b);
float vec3_mag_sq(Vec3 v);
float vec3_mag(Vec3 v);
Vec3 vec3_normalize(Vec3 v);

#endif // BIBO_VECTORS_H
