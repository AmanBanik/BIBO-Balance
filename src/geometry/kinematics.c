#include "bibo/kinematics.h"
#include "bibo/quaternion.h"
#include <math.h>

PlatformState calculate_platform_state(ActuatorState acts[4], PlatformGeometry geom) {
    PlatformState state;
    
    // Assumed corners:
    // 0: (-L/2, -W/2) -> Back Right
    // 1: ( L/2, -W/2) -> Front Right
    // 2: ( L/2,  W/2) -> Front Left
    // 3: (-L/2,  W/2) -> Back Left
    float h0 = acts[0].length;
    float h1 = acts[1].length;
    float h2 = acts[2].length;
    float h3 = acts[3].length;

    float dh0 = acts[0].length_rate;
    float dh1 = acts[1].length_rate;
    float dh2 = acts[2].length_rate;
    float dh3 = acts[3].length_rate;

    // 1. Z-Position (Center of the platform)
    state.pose.position.x = 0.0f;
    state.pose.position.y = 0.0f;
    state.pose.position.z = (h0 + h1 + h2 + h3) * 0.25f;

    // 2. Linear Velocity (Center Z-velocity)
    state.linear_velocity.x = 0.0f;
    state.linear_velocity.y = 0.0f;
    state.linear_velocity.z = (dh0 + dh1 + dh2 + dh3) * 0.25f;

    // 3. Platform Normal and Rotation
    // Slopes along X and Y axes
    float mx = ((h1 + h2) - (h0 + h3)) / (2.0f * geom.length);
    float my = ((h2 + h3) - (h0 + h1)) / (2.0f * geom.width);

    // Normal vector n = (-mx, -my, 1) normalized
    Vec3 n = {-mx, -my, 1.0f};
    n = vec3_normalize(n);

    // Calculate rotation quaternion from world Up (0,0,1) to plane Normal
    Vec3 up = {0.0f, 0.0f, 1.0f};
    Vec3 axis = vec3_cross(up, n);
    float axis_mag = vec3_mag(axis);
    
    if (axis_mag < 1e-6f) {
        state.pose.rotation = quat_identity();
    } else {
        axis = vec3_normalize(axis);
        float angle = acosf(n.z); // n.z is exactly dot(up, n)
        state.pose.rotation = quat_from_axis_angle(axis, angle);
    }

    // 4. Angular Velocity
    float dmx = ((dh1 + dh2) - (dh0 + dh3)) / (2.0f * geom.length);
    float dmy = ((dh2 + dh3) - (dh0 + dh1)) / (2.0f * geom.width);
    
    // For small/moderate angles, standard angular velocity roughly matches rate of slope change
    state.angular_velocity.x = -dmy;
    state.angular_velocity.y = dmx;
    state.angular_velocity.z = 0.0f;

    return state;
}
