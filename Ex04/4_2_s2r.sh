#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o 4_2_s2r.txt

for size in $(seq 1 4 48)   # vary size between 1kB and 48kB
do
    for threads_per_block in $(seq 0 10)    # threads_per_block between 1 and 1024
    do  
        bin/memCpy --shared2register --grid-dim 1 --threads-per-block $((1 << $threads_per_block)) --size $(($size * 1024)) --iterations 50
    done
done