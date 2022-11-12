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

int main()
{
    constexpr std::size_t min = 1<<10;
    constexpr std::size_t max = 1<<30;

    constexpr std::size_t measurements = 3;

    void* dmem; 
    void* hmem = malloc(max);
    void* hmemPinned;

    //Allocate only once
    cudaMalloc(&dmem, max);
    cudaMallocHost(&hmemPinned, max);

    //Warmup
    for(int i = 0; i < 2; ++i)
    {
        cudaMemcpy(dmem, hmem, 1<<30, cudaMemcpyHostToDevice);
        cudaMemcpy(hmem, dmem, 1<<30, cudaMemcpyDeviceToHost);    
    }

    for(std::size_t i = 0; i < 4; ++i)
    {
        switch(i)
        {
            case 0: std::cout << "copyPageableMemoryHostToDevice (size|time[us]):" << std::endl; break;
            case 1: std::cout << "copyPageableMemoryDeviceToHost (size|time[us]):" << std::endl; break;
            case 2: std::cout << "copyPinnedMemoryHostToDevice (size|time[us]):" << std::endl; break;
            case 3: std::cout << "copyPinnedMemoryDeviceToHost (size|time[us]):" << std::endl; break;
        }

        for(std::size_t size = min; size <= max; size *= 2)
        {
            std::chrono::microseconds duration;

            for(std::size_t k = 0; k < measurements; ++k)
            {
                auto start = std::chrono::steady_clock::now();

                switch(i)
                {
                    case 0: cudaMemcpy(dmem, hmem, size, cudaMemcpyHostToDevice); break;
                    case 1: cudaMemcpy(hmem, dmem, size, cudaMemcpyDeviceToHost); break;
                    case 2: cudaMemcpy(dmem, hmemPinned, size, cudaMemcpyHostToDevice); break;
                    case 3: cudaMemcpy(hmemPinned, dmem, size, cudaMemcpyDeviceToHost); break;
                }

                auto end = std::chrono::steady_clock::now();

                duration += std::chrono::duration_cast<std::chrono::microseconds>(end - start);
            }

            std::cout << size << " " << (double) duration.count() / measurements << std::endl;

            duration = std::chrono::microseconds();
        }

        std::cout << std::endl;
    }

    cudaFree(dmem);
    free(hmem);
    cudaFreeHost(hmemPinned);

    return 0;
}
