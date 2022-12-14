/**************************************************************************************************
 *
 *       Computer Engineering Group, Heidelberg University - GPU Computing Exercise 06
 *
 *                  Group : 01
 *
 *                   File : kernel.cu
 *
 *                Purpose : Reduction
 *
 **************************************************************************************************/

#include <thrust/reduce.h>
#include <thrust/device_ptr.h>

//
// Reduction_Kernel
//
__global__ void reduction_Kernel_6_3(int numElements, float* dataIn, float* dataOut)
{
	extern __shared__ float sPartials[];
	const std::size_t tid = blockIdx.x * blockDim.x + threadIdx.x;
	
	if(tid < numElements)
	{
		//Load all elements from global memory into shared memory
		sPartials[threadIdx.x] = dataIn[tid];
		for(std::size_t i = tid + gridDim.x * blockDim.x; i < numElements; i += (gridDim.x * blockDim.x))
		{
			sPartials[threadIdx.x] += dataIn[i]; 
		}

		__syncthreads();

		for(std::size_t s = 1; s < blockDim.x; s *= 2) 
		{
			if(threadIdx.x % (2 * s) == 0) 
			{
				sPartials[threadIdx.x] += sPartials[threadIdx.x + s];
			}

			__syncthreads();
		}
			
		if(threadIdx.x == 0) 
			dataOut[blockIdx.x] = sPartials[0];
	}
}

__global__ void reduction_Kernel_6_4(int numElements, float* dataIn, float* dataOut)
{
	extern __shared__ float sPartials[];
	const std::size_t tid = blockIdx.x * blockDim.x + threadIdx.x;
	
	if(tid < numElements)
	{
		//Load all elements from global memory into shared memory
		sPartials[threadIdx.x] = dataIn[tid];
		for(std::size_t i = tid + gridDim.x * blockDim.x; i < numElements; i += (gridDim.x * blockDim.x))
		{
			sPartials[threadIdx.x] += dataIn[i]; 
		}

		__syncthreads();

		//std::size_t i = blockIdx.x * (blockDim.x * 2) + threadIdx.x; //REDUCTION #4: FIRST ADD DURING LOAD
		//sPartials[tid] = dataIn[i] + dataIn[i + blockDim.x]; //REDUCTION #4: FIRST ADD DURING LOAD
		// => Reduction#4: ***ERROR*** 700 - an illegal memory access was encountered***[0m[31m***
		//for(std::size_t s = 1; s < blockDim.x; s *= 2)
		for(std::size_t o = blockDim.x / 2; o > 0 ; o >>= 1) //REDUCTION #3: SEQUENTIAL ADDRESSING NONDIVERGENT
		{//REDUCTION #5: UNROLLING THE LAST WARP (o > 32)
			//int index = 2 * s * tid; //REDUCTION #2: INTERLEAVED ADDRESSING NONDIVERGENT
			//if(threadIdx.x % (2 * s) == 0) // REDUCTION #1: INTERLEAVED ADDRESSING was already done
			//if (index < blockDim.x)
			if(tid < o)
			{
				//sPartials[index] += sPartials[index + s]; //REDUCTION #2: INTERLEAVED ADDRESSING NONDIVERGENT
				sPartials[tid] += sPartials[tid + o]; //REDUCTION #3: SEQUENTIAL ADDRESSING NONDIVERGENT
			}

			__syncthreads();
		}

		//REDUCTION #5: UNROLLING THE LAST WARP
		if ( tid < 32 && blockDim.x >= 64) sPartials[tid] += sPartials[tid + 32];
		if ( tid < 16 && blockDim.x >= 32) sPartials[tid] += sPartials[tid + 16];
		if ( tid < 8 && blockDim.x >= 16) sPartials[tid] += sPartials[tid + 8];
		if ( tid < 4 && blockDim.x >= 8) sPartials[tid] += sPartials[tid + 4];
		if ( tid < 2 && blockDim.x >= 4) sPartials[tid] += sPartials[tid + 2];
		if ( tid < 1 && blockDim.x >= 2) sPartials[tid] += sPartials[tid + 1]; 

			
		if(threadIdx.x == 0) 
			dataOut[blockIdx.x] = sPartials[0];
	}
}

__inline__ __device__ float warpReduceSum(float val) 
{
	//Calculate the sum of all elements within one warp (32 elements) 
	for(std::size_t offset = warpSize / 2; offset > 0; offset >>= 1) 
		val += __shfl_down_sync(0xFFFFFFFF, val, offset);

	return val;
}

__inline__ __device__ float blockReduceSum(float val)
{
	static __shared__ float sPartials[32];	//warpSize
	const std::size_t lane = threadIdx.x % warpSize;
	const std::size_t wid = threadIdx.x / warpSize;

	//Each warp performs partial reduction
	val = warpReduceSum(val);     	

	//First thread of each warp writes its partial sum to shared memory
	if(lane == 0) 
		sPartials[wid] = val; 		

	//Wait for all partial reductions
	__syncthreads();              	

	//Read from shared memory only if that warp existed
	val = (threadIdx.x < blockDim.x / warpSize + (blockDim.x % 32 != 0)) ? sPartials[lane] : 0;

	if(wid == 0) 
		val = warpReduceSum(val); 	//Final reduce within first warp

	return val;
}

__global__ void reduction_Kernel_6_5(int numElements, float* dataIn, float* dataOut)
{
	const std::size_t tid = blockIdx.x * blockDim.x + threadIdx.x;

	if(tid < numElements)
	{
		int sum = dataIn[tid];
		//Reduce all elements which are not covered by a thread
		for(std::size_t i = tid + gridDim.x * blockDim.x; i < numElements; i += (gridDim.x * blockDim.x))
		{
			sum += dataIn[i]; 
		}

		sum = blockReduceSum(sum);

		if(threadIdx.x == 0) 
			dataOut[blockIdx.x] = sum;
	}
}

void reduction_Kernel_Wrapper_6_3(dim3 gridSize, dim3 blockSize, int numElements, float* dataIn, float* dataOut) 
{
	reduction_Kernel_6_3<<< gridSize, blockSize, blockSize.x*sizeof(float) /*Shared Mem*/ >>>(numElements, dataIn, dataOut);
}

void reduction_Kernel_Wrapper_6_4(dim3 gridSize, dim3 blockSize, int numElements, float* dataIn, float* dataOut) 
{
	reduction_Kernel_6_4<<< gridSize, blockSize, blockSize.x*sizeof(float) /*Shared Mem*/ >>>(numElements, dataIn, dataOut);
}

void reduction_Kernel_Wrapper_6_5(dim3 gridSize, dim3 blockSize, int numElements, float* dataIn, float* dataOut) 
{
	reduction_Kernel_6_5<<< gridSize, blockSize>>>(numElements, dataIn, dataOut);
}

//
// Reduction Kernel using CUDA Thrust
//

void thrust_reduction_Wrapper(int numElements, float* dataIn, float* dataOut) 
{
	thrust::device_ptr<float> in_ptr = thrust::device_pointer_cast(dataIn);
	thrust::device_ptr<float> out_ptr = thrust::device_pointer_cast(dataOut);
	
	*out_ptr = thrust::reduce(in_ptr, in_ptr + numElements, (float) 0., thrust::plus<float>());	
}
