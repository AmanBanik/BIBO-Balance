#ifndef BIBO_CONTACT_H
#define BIBO_CONTACT_H

#include "bibo/cuda_utils.h"

#include "bibo/types.h"
#include "bibo/vectors.h"

// Enum to strictly track contact phase
typedef enum {
    CONTACT_SEPARATED,
    CONTACT_TOUCHING,
    CONTACT_PENETRATING
} ContactState;

// Bundle of contact telemetry for the solver
typedef struct {
    float distance;       // Positive: floating, Negative: penetrating
    ContactState state;
    Vec3 normal;          // Surface normal at contact point
    Vec3 contact_point;   // Point on the platform surface
} ContactInfo;

// Plane Contact Detection
// Evaluates d = n . (r - P_0) - r_b
BIBO_FUNC ContactInfo check_sphere_plane_contact(
    Vec3 ball_center, 
    float ball_radius, 
    Vec3 plane_point, 
    Vec3 plane_normal, 
    float epsilon
);

#endif // BIBO_CONTACT_H
