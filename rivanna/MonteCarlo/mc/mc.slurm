#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=0-15:0:0
#SBATCH --output=mc_%a.stdout
#SBATCH --error=mc_%a.stderr
#SBATCH --partition=economy
#SBATCH --account=maite_group
#SBATCH --array=1-40

module load matlab/R2016a

matlab -nodesktop -r "jobArray${SLURM_ARRAY_TASK_ID};" -logfile mc${SLURM_ARRAY_TASK_ID}