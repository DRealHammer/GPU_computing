/*************************************************************************************************
 *
 *        Computer Engineering Group, Heidelberg University - GPU Computing Exercise 03
 *
 *                           Group : TBD
 *
 *                            File : main.cu
 *
 *                         Purpose : Memory Operations Benchmark
 *
 *************************************************************************************************/

//
// Kernels
//

__global__ void 
globalMemCoalescedKernel(int memsize_per_thread, int* memA, int* memB)
{
    // number of previous blocks threads + our thread number, accumulated offset
    //int offset = (blockIdx.x * blockDim.x + threadIdx.x ) * memsize_per_thread;
    //void* addr_source = (char*) (memA) + offset;
    //void* addr_target = (char*) (memB) + offset;
    //memcpy(addr_target, addr_source, memsize_per_thread);


    int entries_per_thread = memsize_per_thread / sizeof(int);

    int entry_offset = (blockIdx.x * blockDim.x + threadIdx.x ) * entries_per_thread;

    for (int i = 0; i < entries_per_thread; i++) {
        memB[i + entry_offset] = memA[i + entry_offset];
    }

    
}

void 
globalMemCoalescedKernel_Wrapper(dim3 gridDim, dim3 blockDim, int memsize, int* memA, int* memB) {

    int mem_per_block = memsize / gridDim.x;
    int mem_per_thread = mem_per_block / blockDim.x;
	globalMemCoalescedKernel<<< gridDim, blockDim, 0 /*Shared Memory Size*/ >>>(mem_per_thread, memA, memB);
}

__global__ void 
globalMemStrideKernel(/*TODO Parameters*/)
{
    /*TODO Kernel Code*/
}

void 
globalMemStrideKernel_Wrapper(dim3 gridDim, dim3 blockDim /*TODO Parameters*/) {
	globalMemStrideKernel<<< gridDim, blockDim, 0 /*Shared Memory Size*/ >>>( /*TODO Parameters*/);
}

__global__ void 
globalMemOffsetKernel(/*TODO Parameters*/)
{
    /*TODO Kernel Code*/
}

void 
globalMemOffsetKernel_Wrapper(dim3 gridDim, dim3 blockDim /*TODO Parameters*/) {
	globalMemOffsetKernel<<< gridDim, blockDim, 0 /*Shared Memory Size*/ >>>( /*TODO Parameters*/);
}

