#ifndef BIBO_PHYSICS_H
#define BIBO_PHYSICS_H

#include "bibo/types.h"
#include "bibo/vectors.h"

// Configurable Gravity
typedef struct {
    float magnitude; // Acceleration (e.g. 9.81)
    float theta;     // Azimuth angle (radians)
    float phi;       // Inclination angle (radians)
} GravityConfig;

// Gravity Decomposition
Vec3 gravity_from_spherical(GravityConfig config);
Vec3 gravity_normal_component(Vec3 gravity, Vec3 plane_normal);
Vec3 gravity_tangent_component(Vec3 gravity, Vec3 plane_normal);

#endif // BIBO_PHYSICS_H
