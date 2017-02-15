#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --time=00:01:00
#SBATCH --output=output_test
#SBATCH --error=error_test
#SBATCH --partition=economy 
#SBATCH --account=optinetly6j

module load matlab/R2016a

echo $TMPDIR

matlab -nodesktop -r "parpool(10); pcalc1; exit" -logfile matlab_output2
