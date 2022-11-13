#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o 3_3_results.txt


grid_dim=32
threads_per_block=128

for stride in $(seq 0 50)
do
    bin/memCpy --global-coalesced --grid-dim $grid_dim --threads-per-block $threads_per_block -size $(($grid_dim * $threads_per_block * 4)) --iterations 10 --synchronize-kernel 1
done

for stride in $(seq 0 50)
do
    bin/memCpy --global-stride --grid-dim $grid_dim --threads-per-block $threads_per_block --stride $stride --iterations 10 --synchronize-kernel 1
done


# size = optGridSize * optBlockSize * optStride * sizeof optMemorySize