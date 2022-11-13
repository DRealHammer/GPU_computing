#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o 3_2_results_threads.txt

for threads in 1 2 4 8 16 32 64 128 256 512 1024
do
    for blocks in 1
    do

        bin/memCpy --global-coalesced -g $blocks -t $threads -s $(($blocks * $threads * 4))

    done
done
