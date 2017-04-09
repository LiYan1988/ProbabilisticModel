#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=4000M
#SBATCH --time=2-0:0:0
#SBATCH --job-name=mc2p_14
#SBATCH --output=mc2p_14.stdout
#SBATCH --error=mc2p_14.stderr
#SBATCH --partition=economy
#SBATCH --account=maite_group

source ~/.bashrc_grb

python mc2p_14.py
