#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=6350M
#SBATCH --time=2-0:0:0
#SBATCH --job-name=mc2p_1_48
#SBATCH --output=mc2p_1_48.stdout
#SBATCH --error=mc2p_1_48.stderr
#SBATCH --partition=serial
#SBATCH --account=maite_group

source ~/.bashrc_grb

python mc2p_1_48.py
