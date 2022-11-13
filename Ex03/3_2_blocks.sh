#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o 3_2_results_fine.txt


#for threads in $(seq 100 2 150)
for threads in 1024
do
    for blocks in 1 2 4 8 16 32
    do

        bin/memCpy --global-coalesced -g $blocks -t $threads -s $(($blocks * $threads * 4))

    done
done
