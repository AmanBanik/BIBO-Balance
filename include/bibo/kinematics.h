#ifndef BIBO_KINEMATICS_H
#define BIBO_KINEMATICS_H

#include "bibo/cuda_utils.h"

#include "bibo/types.h"
#include "bibo/geometry.h"

// Fully resolved physics state of the rigid platform
typedef struct {
    Pose pose;
    Vec3 linear_velocity;
    Vec3 angular_velocity;
} PlatformState;

// Translates 4 individual actuator lengths and speeds into the 
// holistic position, orientation, and velocity of the platform.
BIBO_FUNC PlatformState calculate_platform_state(ActuatorState acts[4], PlatformGeometry geom);

#endif // BIBO_KINEMATICS_H
