/******************************************************************************
 *
 *Computer Engineering Group, Heidelberg University - GPU Computing Exercise 04
 *
 *                  Group : TBD
 *
 *                   File : kernel.cu
 *
 *                Purpose : Memory Operations Benchmark
 *
 ******************************************************************************/


//
// Test Kernel
//

__global__ void  
globalMem2SharedMem(float* gMem, int dataCount)
{
	extern __shared__ float sMem[];

	int currElement = blockIdx.x * blockDim.x + threadIdx.x;

    while(currElement < dataCount) 
	{
        sMem[currElement] = gMem[currElement];
        currElement += blockDim.x * gridDim.x;
    }
}

void globalMem2SharedMem_Wrapper(dim3 gridSize, dim3 blockSize, int shmSize, float* gMem) 
{
	int dataCount = shmSize / sizeof(float);
	globalMem2SharedMem<<< gridSize, blockSize, shmSize >>>(gMem, dataCount);
}

__global__ void 
SharedMem2globalMem(float* gMem, int dataCount)
{
	extern __shared__ float sMem[];

	int currElement = blockIdx.x * blockDim.x + threadIdx.x;

    while(currElement < dataCount) 
	{
        gMem[currElement] = sMem[currElement];
        currElement += blockDim.x * gridDim.x;
    }
}

void SharedMem2globalMem_Wrapper(dim3 gridSize, dim3 blockSize, int shmSize, float* gMem) 
{
	int dataCount = shmSize / sizeof(float);
	SharedMem2globalMem<<< gridSize, blockSize, shmSize >>>(gMem, dataCount);
}

__global__ void 
SharedMem2Registers(float* out, int dataCount)
{
	extern __shared__ float sMem[];

	const int tid = blockIdx.x * blockDim.x + threadIdx.x;
	int currElement = tid;
	float reg;

    while(currElement < dataCount) 
	{
        reg = sMem[currElement];
        currElement += blockDim.x * gridDim.x;
    }

	// Prevent compiler optimizations
	if(tid == 0)
	{
		*out = reg;
	}
}

void SharedMem2Registers_Wrapper(dim3 gridSize, dim3 blockSize, int shmSize, float* out) 
{
	int dataCount = shmSize / sizeof(float);
	SharedMem2Registers<<< gridSize, blockSize, shmSize >>>(out, dataCount);
}

__global__ void 
Registers2SharedMem(int dataCount)
{
	extern __shared__ float sMem[];

	int currElement = blockIdx.x * blockDim.x + threadIdx.x;

    while(currElement < dataCount) 
	{
        sMem[currElement] = currElement;
        currElement += blockDim.x * gridDim.x;
    }
}

void Registers2SharedMem_Wrapper(dim3 gridSize, dim3 blockSize, int shmSize) 
{
	int dataCount = shmSize / sizeof(float);
	Registers2SharedMem<<< gridSize, blockSize, shmSize >>>(dataCount);
}

__global__ void 
bankConflictsRead
//(/*TODO Parameters*/)
( )
{
	/*TODO Kernel Code*/
}

void bankConflictsRead_Wrapper(dim3 gridSize, dim3 blockSize, int shmSize /* TODO Parameters*/) {
	bankConflictsRead<<< gridSize, blockSize, shmSize >>>( /* TODO Parameters */);
}
