#include <iostream>
#include <chrono>
#include <numeric>

double globalSum = 0;

int main(int argc, char** argv)
{
    if(argc < 3 || atoi(argv[1]) <= 0)
        return -1;

    std::size_t size = atoi(argv[1]);
    float* data = new float[size];
    constexpr std::size_t measurements = 1;
    std::chrono::nanoseconds duration;

    //Fill array with 1s
    std::fill(data, data+size, 1.);

    std::cout << "CPU reduction " << argv[2] << ": size=" << size << ", ";

    for(std::size_t i = 0; i < measurements; ++i)
    {
        auto start = std::chrono::steady_clock::now();

        double sum = 0;
        for(std::size_t k = 0; k < size; ++k)
        {
            sum += data[k];
        }

        auto end = std::chrono::steady_clock::now();

        // Avoid compiler optimization
        globalSum = sum;

        duration += std::chrono::duration_cast<decltype(duration)>(end - start);
    } 

    std::cout << "us=" << duration.count() << ", bw=" << ((1e9*static_cast<double>(size) / duration.count()) * measurements) * 1e-9 << "GB/s" << std::endl;

    //Free data-array
    free(data);

    return 0;
}
