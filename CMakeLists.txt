cmake_minimum_required(VERSION 3.10)
project(BIBO-Balance VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED True)

# Core include directory
include_directories(include)

# Math/Geometry Core Library
add_library(bibo_core STATIC
    src/core/vectors.c
)

# Unit Tests
enable_testing()
add_executable(test_vectors tests/unit/test_vectors.c)
target_link_libraries(test_vectors bibo_core m)

add_test(NAME TestVectors COMMAND test_vectors)
