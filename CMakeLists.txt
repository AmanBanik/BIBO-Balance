cmake_minimum_required(VERSION 3.10)
project(BIBO-Balance VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED True)

# Core include directory
include_directories(include)

# Math/Geometry Core Library
add_library(bibo_core STATIC
    src/core/vectors.c
    src/core/quaternion.c
    src/geometry/platform.c
    src/geometry/rods.c
    src/physics/gravity.c
    src/physics/contact.c
    src/physics/friction.c
    src/physics/rolling.c
    src/physics/integrator.c
)

# Unit Tests
enable_testing()
add_executable(test_vectors tests/unit/test_vectors.c)
target_link_libraries(test_vectors bibo_core m)
add_test(NAME TestVectors COMMAND test_vectors)

add_executable(test_geometry tests/unit/test_geometry.c)
target_link_libraries(test_geometry bibo_core m)
add_test(NAME TestGeometry COMMAND test_geometry)

add_executable(test_physics tests/unit/test_physics.c)
target_link_libraries(test_physics bibo_core m)
add_test(NAME TestPhysics COMMAND test_physics)

add_executable(test_contact tests/unit/test_contact.c)
target_link_libraries(test_contact bibo_core m)
add_test(NAME TestContact COMMAND test_contact)

add_executable(test_friction tests/unit/test_friction.c)
target_link_libraries(test_friction bibo_core m)
add_test(NAME TestFriction COMMAND test_friction)

add_executable(test_integrator tests/unit/test_integrator.c)
target_link_libraries(test_integrator bibo_core m)
add_test(NAME TestIntegrator COMMAND test_integrator)
