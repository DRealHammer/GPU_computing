#!/usr/bin/env bash
#SBATCH --gres=gpu:1
#SBATCH -p exercise
#SBATCH -o busyKernel.txt

# run program
bin/busyKernel #$1





