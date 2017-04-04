#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=0-15:0:0
#SBATCH --output=mc3_%a.stdout
#SBATCH --error=mc3_%a.stderr
#SBATCH --partition=economy
#SBATCH --account=maite_group
#SBATCH --array=1-50

module load matlab/R2016a gurobi/6.5.1

matlab -nodesktop -r "jobArray${SLURM_ARRAY_TASK_ID};" -logfile mc3${SLURM_ARRAY_TASK_ID}