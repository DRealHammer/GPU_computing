#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o 3_2_results_fine.txt


#for threads in $(seq 100 2 150)
for threads in 128 256 512 1024
do
    for blocks in 32 64 128 256 512 1024 
    do

        bin/memCpy --global-coalesced -g $blocks -t $threads -s $(($blocks * $threads * 4))

    done
done
