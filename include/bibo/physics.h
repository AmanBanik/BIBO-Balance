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

// Rolling Mechanics
float calculate_sphere_inertia(float mass, float radius);
Vec3 calculate_contact_velocity(Vec3 ball_velocity, Vec3 ball_omega, float ball_radius, Vec3 plane_normal);

// Friction & Normal Force
float calculate_normal_force(float mass, Vec3 gravity, Vec3 plane_normal);
Vec3 calculate_friction_force(float mass, float normal_force, float mu, Vec3 v_contact, Vec3 tangent_gravity);

// Time Integration
void integrate_ball_state(BallState* state, Vec3 force, Vec3 torque, float inertia, float dt);

// Energy Calculations
float calculate_kinetic_energy(BallState state, float inertia);
float calculate_potential_energy(BallState state, Vec3 gravity);
float calculate_total_energy(BallState state, float inertia, Vec3 gravity);
#include "bibo/geometry.h"
#include "bibo/contact.h"

// Stability Tracker
typedef struct {
    float stable_time;       // Accumulator for continuous stable time
    float threshold_v;       // Max allowable translational speed
    float threshold_omega;   // Max allowable rotational speed
    float required_time;     // Required continuous duration (e.g. 2.0s)
    int is_stable;           // 1 if currently deemed stable, 0 otherwise
} StabilityTracker;

void stability_tracker_init(StabilityTracker* tracker, float req_time, float v_thresh, float omega_thresh);
void stability_tracker_update(StabilityTracker* tracker, BallState state, Pose platform_pose, PlatformGeometry plat_geom, ContactInfo contact, float dt);

#endif // BIBO_PHYSICS_H
