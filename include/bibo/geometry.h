#ifndef BIBO_GEOMETRY_H
#define BIBO_GEOMETRY_H

#include "bibo/cuda_utils.h"

#include "bibo/types.h"
#include "bibo/vectors.h"
#include "bibo/quaternion.h"

typedef struct {
    float length;
    float width;
    float thickness;
    Vec3 corners_local[4];
} PlatformGeometry;

// Geometry calculations
BIBO_FUNC Vec3 platform_corner_world(Pose p, Vec3 corner_local);
BIBO_FUNC Vec3 platform_normal(Pose p);
BIBO_FUNC float rod_distance(Vec3 base, Vec3 platform_corner_world);

#endif // BIBO_GEOMETRY_H
