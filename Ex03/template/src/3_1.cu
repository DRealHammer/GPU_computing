#include <iostream>
#include <chrono>

int main()
{
    constexpr std::size_t min = 1<<10;
    constexpr std::size_t max = 1<<30;

    constexpr std::size_t measurements = 5;

    void* dmemA; 
    void* dmemB; 
    void* hmem;
    void* hmemPinned;

    //Allocate only once
    hmem = malloc(max);
    cudaMalloc(&dmemA, max);
    cudaMalloc(&dmemB, max);
    cudaMallocHost(&hmemPinned, max);

    //Warmup
    for(int i = 0; i < 2; ++i)
    {
        cudaMemcpy(dmemA, hmem, max, cudaMemcpyHostToDevice);
        cudaMemcpy(hmem, dmemA, max, cudaMemcpyDeviceToHost);  
        cudaMemcpy(dmemA, hmemPinned, max, cudaMemcpyHostToDevice);
        cudaMemcpy(hmemPinned, dmemA, max, cudaMemcpyDeviceToHost);   
        cudaMemcpy(dmemB, dmemA, max, cudaMemcpyDeviceToDevice); cudaDeviceSynchronize();
    }

    for(std::size_t i = 0; i < 5; ++i)
    {
        switch(i)
        {
            case 0: std::cout << "copyPageableMemoryHostToDevice (size|bandwidth[GB/s]):" << std::endl; break;
            case 1: std::cout << "copyPageableMemoryDeviceToHost (size|bandwidth[GB/s]):" << std::endl; break;
            case 2: std::cout << "copyPinnedMemoryHostToDevice (size|bandwidth[GB/s]):" << std::endl; break;
            case 3: std::cout << "copyPinnedMemoryDeviceToHost (size|bandwidth[GB/s]):" << std::endl; break;
            case 4: std::cout << "copyDeviceToDevice (size|bandwidth[GB/s]):" << std::endl; break;
        }

        for(std::size_t size = min; size <= max; size *= 2)
        {
            std::chrono::microseconds duration;

            for(std::size_t k = 0; k < measurements; ++k)
            {
                auto start = std::chrono::steady_clock::now();

                switch(i)
                {
                    case 0: cudaMemcpy(dmemA, hmem, size, cudaMemcpyHostToDevice); break;
                    case 1: cudaMemcpy(hmem, dmemA, size, cudaMemcpyDeviceToHost); break;
                    case 2: cudaMemcpy(dmemA, hmemPinned, size, cudaMemcpyHostToDevice); break;
                    case 3: cudaMemcpy(hmemPinned, dmemA, size, cudaMemcpyDeviceToHost); break;
                    case 4: cudaMemcpy(dmemB, dmemA, size, cudaMemcpyDeviceToDevice); cudaDeviceSynchronize(); break;
                }

                auto end = std::chrono::steady_clock::now();

                duration += std::chrono::duration_cast<std::chrono::microseconds>(end - start);
            }

            std::cout << size << " " << ((1e6*static_cast<double>(size) / duration.count()) * measurements) * 1e-9 << std::endl;

            duration = std::chrono::microseconds();
        }

        std::cout << std::endl;
    }

    cudaFree(dmemA);
    cudaFree(dmemB);
    free(hmem);
    cudaFreeHost(hmemPinned);

    return 0;
}
