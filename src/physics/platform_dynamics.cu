#include "bibo/physics.h"

BIBO_FUNC Vec3 calculate_platform_surface_velocity(PlatformState plat, Vec3 contact_point_world) {
    // 1. Find vector from platform's center of mass (or origin) to the contact point
    Vec3 r_plat = vec3_sub(contact_point_world, plat.pose.position);
    
    // 2. The absolute velocity of that exact point on the platform is: v_center + (omega x r)
    Vec3 omega_cross = vec3_cross(plat.angular_velocity, r_plat);
    return vec3_add(plat.linear_velocity, omega_cross);
}

BIBO_FUNC Vec3 calculate_relative_contact_velocity(Vec3 ball_v_contact, Vec3 plat_v_contact) {
    // 3. Friction and rolling resistence are driven entirely by RELATIVE velocity.
    // If both are moving the exact same speed/direction, relative velocity is zero (static grip).
    return vec3_sub(ball_v_contact, plat_v_contact);
}
