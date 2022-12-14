#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o 6_3.txt

for size in $(seq 10 30)   # vary size between 1kB and 1GB
do
    for threads_per_block in $(seq 0 10)    # threads_per_block between 1 and 1024
    do
        bin/reduction --gpu-red-initial --threads-per-block $((1 << $threads_per_block)) --size $((1 << $size))
    done
done
