cmake_minimum_required(VERSION 3.10)
project(BIBO-Balance VERSION 0.1.0 LANGUAGES C CXX CUDA)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED True)
set(CMAKE_CUDA_STANDARD 11)
set(CMAKE_CUDA_STANDARD_REQUIRED True)

# Core include directory
include_directories(include)

set(CORE_SRCS
    src/core/vectors.cu
    src/core/quaternion.cu
    src/core/simulator.cu
    src/core/cffi_interface.cu
    src/geometry/platform.cu
    src/geometry/rods.cu
    src/geometry/kinematics.cu
    src/physics/gravity.cu
    src/physics/contact.cu
    src/physics/friction.cu
    src/physics/rolling.cu
    src/physics/integrator.cu
    src/physics/energy.cu
    src/physics/stability.cu
    src/physics/actuator.cu
    src/physics/platform_dynamics.cu
)

# Math/Geometry Core Library
add_library(bibo_core STATIC ${CORE_SRCS})
add_library(bibo_cffi SHARED ${CORE_SRCS})

# Make sure shared library has position independent code
set_target_properties(bibo_cffi PROPERTIES POSITION_INDEPENDENT_CODE ON)

# Unit Tests
enable_testing()
add_executable(test_vectors tests/unit/test_vectors.cu)
target_link_libraries(test_vectors bibo_core m)
add_test(NAME TestVectors COMMAND test_vectors)

add_executable(test_geometry tests/unit/test_geometry.cu)
target_link_libraries(test_geometry bibo_core m)
add_test(NAME TestGeometry COMMAND test_geometry)

add_executable(test_physics tests/unit/test_physics.cu)
target_link_libraries(test_physics bibo_core m)
add_test(NAME TestPhysics COMMAND test_physics)

add_executable(test_contact tests/unit/test_contact.cu)
target_link_libraries(test_contact bibo_core m)
add_test(NAME TestContact COMMAND test_contact)

add_executable(test_friction tests/unit/test_friction.cu)
target_link_libraries(test_friction bibo_core m)
add_test(NAME TestFriction COMMAND test_friction)

add_executable(test_integrator tests/unit/test_integrator.cu)
target_link_libraries(test_integrator bibo_core m)
add_test(NAME TestIntegrator COMMAND test_integrator)

add_executable(test_energy tests/unit/test_energy.cu)
target_link_libraries(test_energy bibo_core m)
add_test(NAME TestEnergy COMMAND test_energy)

add_executable(test_stability tests/unit/test_stability.cu)
target_link_libraries(test_stability bibo_core m)
add_test(NAME TestStability COMMAND test_stability)

add_executable(test_actuator tests/unit/test_actuator.cu)
target_link_libraries(test_actuator bibo_core m)
add_test(NAME TestActuator COMMAND test_actuator)

add_executable(test_kinematics tests/unit/test_kinematics.cu)
target_link_libraries(test_kinematics bibo_core m)
add_test(NAME TestKinematics COMMAND test_kinematics)

add_executable(test_platform_dynamics tests/unit/test_platform_dynamics.cu)
target_link_libraries(test_platform_dynamics bibo_core m)
add_test(NAME TestPlatformDynamics COMMAND test_platform_dynamics)

add_executable(test_simulator tests/unit/test_simulator.cu)
target_link_libraries(test_simulator bibo_core m)
add_test(NAME TestSimulator COMMAND test_simulator)

add_executable(test_cffi_interface tests/unit/test_cffi_interface.cu)
target_link_libraries(test_cffi_interface bibo_core m)
add_test(NAME TestCffiInterface COMMAND test_cffi_interface)
