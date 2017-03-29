#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --time=00:01:00
#SBATCH --output=output_test
#SBATCH --error=error_test
#SBATCH --partition=economy 
#SBATCH --account=optinetly6j

module load matlab/R2016a
#module load gurobi/6.5.1

echo $TMPDIR

matlab -nodesktop -r "poolobj=parpool(10); test_cluster; delete(poolobj); exit" -logfile matlab_output
