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
globalMemCoalescedKernel(/*int memsize_per_thread, */int* memA, int* memB)
{
    // number of previous blocks threads + our thread number, accumulated offset
    //int offset = (blockIdx.x * blockDim.x + threadIdx.x ) * memsize_per_thread;
    //void* addr_source = (char*) (memA) + offset;
    //void* addr_target = (char*) (memB) + offset;
    //memcpy(addr_target, addr_source, memsize_per_thread);


    //int entries_per_thread = memsize_per_thread / sizeof(int);

    //int entry_offset = (blockIdx.x * blockDim.x + threadIdx.x ) * entries_per_thread;

    //memB[entry_offset] = memA[entry_offset];

    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    memB[tid] = memA[tid];

    
}

void 
globalMemCoalescedKernel_Wrapper(dim3 gridDim, dim3 blockDim, int memsize, int* memA, int* memB) {

    //int mem_per_block = memsize / gridDim.x;
    //int mem_per_thread = mem_per_block / blockDim.x;
	globalMemCoalescedKernel<<< gridDim, blockDim, 0 /*Shared Memory Size*/ >>>(/*mem_per_thread, */memA, memB);
}

__global__ void 
globalMemStrideKernel(int N,int* d_in, int* d_out, int optStride)
{
   int tid = threadIdx.x + blockIdx.x * blockDim.x;

   if (tid >= N) return;
 
   d_out[tid] = d_in[tid * optStride];
    
}

void 
globalMemStrideKernel_Wrapper(dim3 gridDim, dim3 blockDim, int mem_size, int* d_in, int* d_out, int optStride) {
	
   
    //int threads_per_block;
    //int block_count;
    //int size_per_element;
    //each thread transfers one element
    
    globalMemStrideKernel<<< gridDim, blockDim, 0 >>>(mem_size, d_in, d_out, optStride);
}

__global__ void 
globalMemOffsetKernel(int* d_in, int* d_out, int dataCount, int optOffset)
{
    const int tid = threadIdx.x + blockIdx.x * blockDim.x;

    //global thread index < available data?
    if(tid < dataCount)
    {
        d_out[tid] = d_in[tid + optOffset];
    }
}

void 
globalMemOffsetKernel_Wrapper(dim3 gridDim, dim3 blockDim, int* d_in, int* d_out,int dataCount, int optOffset) 
{
    globalMemOffsetKernel<<< gridDim, blockDim, 0 >>>(d_in, d_out, dataCount, optOffset);
}

