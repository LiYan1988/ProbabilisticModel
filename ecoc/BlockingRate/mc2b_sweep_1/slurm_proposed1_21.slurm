#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=0-15:0:0
#SBATCH --output=proposed1_21_%a.stdout
#SBATCH --error=proposed1_21_%a.stderr
#SBATCH --partition=economy
#SBATCH --account=maite_group
#SBATCH --array=1-1

module load matlab/R2016a gurobi/6.5.1

matlab -nodesktop -nojvm -noFigureWindows -nosplash -nodisplay -r "jobArray_proposed1_21_${SLURM_ARRAY_TASK_ID};" -logfile jobArray_proposed1_21_${SLURM_ARRAY_TASK_ID}