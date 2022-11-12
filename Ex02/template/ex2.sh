#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o kernelSync.txt

for block_num in 1 128 1024 4096 16384 #1 1821 3641 5462 7282 9102 10923 12743 14563 16384
do

    for thread_num in 1 114 228 342 455 569 683 796 910 1024
    do

        # run program
        bin/nullKernelAsync $block_num $thread_num


    done


done


