#include "bibo/physics.h"
#include <math.h>

BIBO_FUNC void stability_tracker_init(StabilityTracker* tracker, float req_time, float v_thresh, float omega_thresh) {
    tracker->stable_time = 0.0f;
    tracker->threshold_v = v_thresh;
    tracker->threshold_omega = omega_thresh;
    tracker->required_time = req_time;
    tracker->is_stable = 0;
}

BIBO_FUNC void stability_tracker_update(StabilityTracker* tracker, BallState state, Pose platform_pose, PlatformGeometry plat_geom, ContactInfo contact, float dt) {
    // 1. Must be in continuous contact
    if (contact.state == CONTACT_SEPARATED) {
        tracker->stable_time = 0.0f;
        tracker->is_stable = 0;
        return;
    }

    // 2. Contact point must be strictly within the platform's physical boundaries
    // Convert world contact point to platform-local coordinates
    Vec3 offset = vec3_sub(contact.contact_point, platform_pose.position);
    Quat inv_rot = quat_conjugate(platform_pose.rotation);
    Vec3 local_contact = quat_rotate_vec3(inv_rot, offset);

    float half_length = plat_geom.length * 0.5f;
    float half_width = plat_geom.width * 0.5f;

    if (fabs(local_contact.x) > half_length || fabs(local_contact.y) > half_width) {
        // Ball is falling off the edge
        tracker->stable_time = 0.0f;
        tracker->is_stable = 0;
        return;
    }

    // 3. Evaluate Kinematic Thresholds (Near-zero speed)
    float v_mag = vec3_mag(state.velocity);
    float omega_mag = vec3_mag(state.omega);

    if (v_mag < tracker->threshold_v && omega_mag < tracker->threshold_omega) {
        tracker->stable_time += dt;
        if (tracker->stable_time >= tracker->required_time) {
            tracker->is_stable = 1;
        }
    } else {
        // Motion exceeded tolerances, reset window
        tracker->stable_time = 0.0f;
        tracker->is_stable = 0;
    }
}
