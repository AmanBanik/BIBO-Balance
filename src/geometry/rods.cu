#include "bibo/geometry.h"

BIBO_FUNC float rod_distance(Vec3 base, Vec3 corner_world) {
    Vec3 diff = vec3_sub(corner_world, base);
    return vec3_mag(diff);
}
