#ifndef BIBO_PHYSICS_H
#define BIBO_PHYSICS_H

#include "bibo/cuda_utils.h"

#include "bibo/types.h"
#include "bibo/vectors.h"

// Configurable Gravity
typedef struct {
    float magnitude; // Acceleration (e.g. 9.81)
    float theta;     // Azimuth angle (radians)
    float phi;       // Inclination angle (radians)
} GravityConfig;

// Gravity Decomposition
BIBO_FUNC Vec3 gravity_from_spherical(GravityConfig config);
BIBO_FUNC Vec3 gravity_normal_component(Vec3 gravity, Vec3 plane_normal);
BIBO_FUNC Vec3 gravity_tangent_component(Vec3 gravity, Vec3 plane_normal);

// Rolling Mechanics
BIBO_FUNC float calculate_sphere_inertia(float mass, float radius);
BIBO_FUNC Vec3 calculate_contact_velocity(Vec3 ball_velocity, Vec3 ball_omega, float ball_radius, Vec3 plane_normal);

// Friction & Normal Force
BIBO_FUNC float calculate_normal_force(float mass, Vec3 gravity, Vec3 plane_normal);
BIBO_FUNC Vec3 calculate_friction_force(float mass, float normal_force, float mu, Vec3 v_contact, Vec3 tangent_gravity);

// Time Integration
BIBO_FUNC void integrate_ball_state(BallState* state, Vec3 force, Vec3 torque, float inertia, float dt);

// Energy Calculations
BIBO_FUNC float calculate_kinetic_energy(BallState state, float inertia);
BIBO_FUNC float calculate_potential_energy(BallState state, Vec3 gravity);
BIBO_FUNC float calculate_total_energy(BallState state, float inertia, Vec3 gravity);
#include "bibo/geometry.h"
#include "bibo/contact.h"
#include "bibo/kinematics.h"

// Stability Tracker
typedef struct {
    float stable_time;       // Accumulator for continuous stable time
    float threshold_v;       // Max allowable translational speed
    float threshold_omega;   // Max allowable rotational speed
    float required_time;     // Required continuous duration (e.g. 2.0s)
    int is_stable;           // 1 if currently deemed stable, 0 otherwise
} StabilityTracker;

BIBO_FUNC void stability_tracker_init(StabilityTracker* tracker, float req_time, float v_thresh, float omega_thresh);
BIBO_FUNC void stability_tracker_update(StabilityTracker* tracker, BallState state, Pose platform_pose, PlatformGeometry plat_geom, ContactInfo contact, float dt);

// Platform Dynamics
BIBO_FUNC Vec3 calculate_platform_surface_velocity(PlatformState plat, Vec3 contact_point_world);
BIBO_FUNC Vec3 calculate_relative_contact_velocity(Vec3 ball_v_contact, Vec3 plat_v_contact);

#endif // BIBO_PHYSICS_H
