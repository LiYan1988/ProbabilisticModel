#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --time=01:00:00
#SBATCH --output=test_%a.stdout
#SBATCH --error=test_%a.stderr
#SBATCH --partition=economy 
#SBATCH --account=optinetly6j
#SBATCH --array=1-960

module load matlab/R2016a
#module load gurobi/6.5.1

echo $TMPDIR

matlab -nodesktop -r "parpool(10); jobArray${SLURM_ARRAY_TASK_ID}; exit" -logfile matlab_output_${SLURM_ARRAY_TASK_ID}
