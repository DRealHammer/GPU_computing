#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o 6_2.txt

for size in $(seq 0 30)    # size between 1kB and 1GB
do  
    bin/6_2_O2 $((1 << $size)) "O2"
done

for size in $(seq 0 30)    # size between 1kB and 1GB
do  
    bin/6_2_O3 $((1 << $size)) "O3"
done