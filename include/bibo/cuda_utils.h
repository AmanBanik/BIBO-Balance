#ifndef BIBO_CUDA_UTILS_H
#define BIBO_CUDA_UTILS_H

#ifdef __CUDACC__
    #define BIBO_FUNC __host__ __device__
#else
    #define BIBO_FUNC
#endif

#endif // BIBO_CUDA_UTILS_H
