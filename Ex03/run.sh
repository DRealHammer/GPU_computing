#!/usr/bin/env bash

# prepares the files and environment and runs the scripts

module load cuda/11.2

make

sbatch 3_1.sh

sbatch 3_2_threads.sh
sbatch 3_2_blocks.sh
sbatch 3_2_fine.sh

sbatch 3_3.sh
sbatch 3_4.sh