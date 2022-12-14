CUDA_ROOT=$(CUDA_HOME)
INC=-I./inc -I. -I$(CUDA_ROOT)/include
LIB=-L$(CUDA_ROOT)/lib64
NVCC=nvcc

.PHONY: build
build: ./bin/reduction
build: ./bin/reduction_volta
build: ./bin/6_2_O2
build: ./bin/6_2_O3

.PHONY: clean
clean:
	rm -f ./bin/*
	
.PHONY: rebuild
rebuild: clean build

./bin/reduction: ./src/main.cpp ./src/kernel.cu
	$(NVCC) -arch=compute_60 -code=sm_70 -O2 --compiler-options "-O2 -Wall -Wextra" -o $@ $^ $(INC) $(LIB) -std=c++11

./bin/reduction_volta: ./src/main.cpp ./src/kernel.cu
	$(NVCC) -O2 --compiler-options "-O2 -Wall -Wextra" -o $@ $^ $(INC) $(LIB) -std=c++11

./bin/6_2_O2: ./src/6_2.cpp
	$(NVCC) -O2 --compiler-options "-O2 -Wall -Wextra" -o $@ $^ $(INC) -std=c++11

./bin/6_2_O3: ./src/6_2.cpp
	$(NVCC) -O3 --compiler-options "-O3 -Wall -Wextra" -o $@ $^ $(INC) -std=c++11
