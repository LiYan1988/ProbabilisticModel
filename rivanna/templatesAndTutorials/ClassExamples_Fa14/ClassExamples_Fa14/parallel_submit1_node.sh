#!/bin/sh
#PBS -l select=1:ncpus=8
#PBS -l walltime=01:00:00
#PBS -o matlab_output1
#PBS -q standard
#PBS -j oe
#PBS -m ea
#PBS -M teh1m@virginia.edu

# Set up input for pcalc function
nloop=100


cd $PBS_O_WORKDIR
matlab -nodisplay -r "matlabpool 'local' 8; pcalc1(${nloop}); \
matlabpool close; exit" -logfile matlab_output2
