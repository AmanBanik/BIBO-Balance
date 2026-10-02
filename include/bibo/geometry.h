#ifndef BIBO_GEOMETRY_H
#define BIBO_GEOMETRY_H

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
Vec3 platform_corner_world(Pose p, Vec3 corner_local);
Vec3 platform_normal(Pose p);
float rod_distance(Vec3 base, Vec3 platform_corner_world);

#endif // BIBO_GEOMETRY_H
