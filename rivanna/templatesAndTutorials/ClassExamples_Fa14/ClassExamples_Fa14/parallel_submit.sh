#!/bin/sh
#PBS -l select=1:ncpus=1
#PBS -l walltime=01:00:00
#PBS -o matlab_output1
#PBS -q standard
#PBS -j oe
#PBS -m ea
#PBS -M teh1m@virginia.edu

cd $PBS_O_WORKDIR
matlab -singleCompThread -nodisplay -r "matlabpool_submit;exit" -logfile matlab_output2
