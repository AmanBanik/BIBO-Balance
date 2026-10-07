#ifndef BIBO_TYPES_H
#define BIBO_TYPES_H

#include "bibo/cuda_utils.h"

typedef struct {
    float x, y, z;
} Vec3;

typedef struct {
    float q[4];       /* x, y, z, w convention */
} Quat;

typedef struct {
    Vec3 position;
    Quat rotation;
} Pose;

typedef struct {
    float length;
    float length_rate;
    float length_min;
    float length_max;
    float rate_limit;
} ActuatorState;

typedef struct {
    Vec3 position;
    Vec3 velocity;
    Vec3 omega;
    float radius;
    float mass;
    int in_contact;
} BallState;

#endif // BIBO_TYPES_H
