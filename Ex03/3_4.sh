#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o 3_4_results.txt

#grid_dim=1024
#threads_per_block=1024

grid_dim=32
threads_per_block=128

for offset in $(seq 0 50)
do
    bin/memCpy --global-coalesced --grid-dim $grid_dim --threads-per-block $threads_per_block --size $(($grid_dim * $threads_per_block * 4)) --iterations 10 --synchronize-kernel 1
done

for offset in $(seq 0 50)
do
    bin/memCpy --global-offset --grid-dim $grid_dim --threads-per-block $threads_per_block --offset $offset --iterations 10 --synchronize-kernel 1
done
