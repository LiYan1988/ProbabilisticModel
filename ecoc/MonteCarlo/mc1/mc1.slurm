#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=0-15:0:0
#SBATCH --output=mc1_%a.stdout
#SBATCH --error=mc1_%a.stderr
#SBATCH --partition=economy
#SBATCH --account=maite_group
#SBATCH --array=1-100

module load matlab/R2016a gurobi/6.5.1

matlab -nodesktop -nojvm -noFigureWindows -nosplash -nodisplay -r "jobArray${SLURM_ARRAY_TASK_ID};" -logfile mc1${SLURM_ARRAY_TASK_ID}