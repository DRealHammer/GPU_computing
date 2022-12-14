#!/usr/bin/env bash

# prepares the files and environment and runs the scripts

module load cuda/11.2

make

#sbatch 6_2.sh
#sbatch 6_3.sh
#sbatch 6_4.sh
sbatch 6_5.sh