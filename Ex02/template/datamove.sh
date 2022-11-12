#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o datamove.txt

echo "memsize,h2d,pinned,time(us)" > datamove.txt

for memsize in 1 112 223 334 445 556 667 778 889 1000
do
    for h2d in 0 1
    do
        for pinned in 0 1
        do
        
        
            # run program
            bin/datamove $memsize $h2d $pinned


        done


    done
done


