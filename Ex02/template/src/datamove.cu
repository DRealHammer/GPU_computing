// Sven & Daniel

#include <stdio.h>
#include <stdlib.h>

#include "chTimer.h"


int main(int argc, char** argv) {

    int cIterations = 100000;
    chTimerTimestamp start, stop;

    // memsize in kB
    int memsize = atoi(argv[1]);

    // 1 -> host 2 device, 0 -> device 2 host
    int h2d = atoi(argv[2]);

    int pinned = atoi(argv[3]);

    void* memory;

    // get memory
    if (!pinned) {
        memory = malloc(1000 * memsize);
    } else {
        cudaMallocHost(&memory, 1000 * memsize);
    }
    
    void* d_memory;
    cudaMalloc(&d_memory, 1000 * memsize);

    chTimerGetTime( &start );

    if (h2d) {
        for (int i = 0; i < cIterations; i++) {
            cudaMemcpy(d_memory, memory, 1000 * memsize, cudaMemcpyHostToDevice);
        }
    } else {
        for (int i = 0; i < cIterations; i++) {
            cudaMemcpy(memory, d_memory, 1000 * memsize, cudaMemcpyDeviceToHost);
        }
    }
    
    chTimerGetTime( &stop );


    {
        double microseconds = 1e6*chTimerElapsedTime( &start, &stop );
        double usPerLaunch = microseconds / (float) cIterations;

        printf( "%d,%d,%d,%.2f\n", memsize, h2d, pinned, usPerLaunch);
    }  

    if (!pinned) {
        free(memory);
    } else {
        cudaFreeHost(memory);
    }

    cudaFree(d_memory);

    

    return 0;


}