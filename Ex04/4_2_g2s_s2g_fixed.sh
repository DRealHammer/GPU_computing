#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o 4_2_g2s_s2g_fixed.txt

for blocks in $(seq 0 10)  # vary block-size between 1 and 1048
do
    for threads_per_block in 16 128 1024
    do  
        bin/memCpy --global2shared --grid-dim $((1 << $blocks)) --threads-per-block $threads_per_block --size $((45*1024)) --iterations 50
        bin/memCpy --shared2global --grid-dim $((1 << $blocks)) --threads-per-block $threads_per_block --size $((45*1024)) --iterations 50
    done
done

