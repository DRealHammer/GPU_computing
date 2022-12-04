#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o 5_2.txt

#for blocksize in 1 2 4 8 16 32
#do
#
#    bin/matMul -t $blocksize
#
#done

for width in 2 4 8 16 32 64 128 200 256 300 400 512 600 700 800 900 1024 1300 1600 2048 2500 3000 3500 4096 5000 6000 7000 8192 9000 12000 16384 32768
do

    bin/matMul -t 16 -s $(( $width )) -c --speedup

done