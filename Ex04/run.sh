#!/usr/bin/env bash

# prepares the files and environment and runs the scripts

module load cuda/11.2

make

sbatch 4_2.sh