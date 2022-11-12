/*
 *
 * nullKernelAsync.cu
 *
 * Microbenchmark for throughput of asynchronous kernel launch.
 *
 * Build with: nvcc -I ../chLib <options> nullKernelAsync.cu
 * Requires: No minimum SM requirement.
 *
 * Copyright (c) 2011-2012, Archaea Software, LLC.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions 
 * are met: 
 *
 * 1. Redistributions of source code must retain the above copyright 
 *    notice, this list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright 
 *    notice, this list of conditions and the following disclaimer in 
 *    the documentation and/or other materials provided with the 
 *    distribution. 
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */


#include <iostream>
#include <chrono>


__device__ clock_t device_clock;

__global__ void BusyWaitKernel(clock_t numClocks) 
{
    auto start = clock64();
    auto end = clock64();

    while (end - start < numClocks) 
    {
        end = clock64();
        
        //Avoid compiler optimization
        if(threadIdx.x == 10)
        {
            device_clock = end - start;
        }
    }
}

int main()
{
    constexpr std::size_t cIterations = 3000;
    constexpr std::size_t runs = 1000;

    //Warm-up
    for( int i = 0; i < 100; ++i ) 
    {
        BusyWaitKernel<<<1, 1>>>(10);
    } 
    cudaDeviceSynchronize();

    for( int cycles = 0; cycles <= cIterations; cycles += 100 ) 
    {
        auto start = std::chrono::steady_clock::now();

        for( int j = 0; j < runs; ++j ) 
        {
            BusyWaitKernel<<<1, 1>>>(cycles);
        }

        cudaDeviceSynchronize();
        auto end = std::chrono::steady_clock::now();

        std::cout << cycles << " " << (double) std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() / runs << std::endl;
    }

    return 0;
}
