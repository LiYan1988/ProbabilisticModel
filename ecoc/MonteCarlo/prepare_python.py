#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 09:46:27 2017

@author: li
"""

import os
import shutil
import tempfile
from subprocess import call

def copy_template(src, dst, replace_lines):
    destination = open(dst, 'w')
    source = open(src, 'r')
    for l, line in enumerate(source):
        if l in replace_lines.keys():
            destination.write(replace_lines[l])
        else:
            destination.write(line)
    source.close()
    destination.close()

def change_eol_win2unix(file_path):
    ftmp, abs_path = tempfile.mkstemp()
    with open(file_path, 'rb') as old_file, open(abs_path, 'wb') as new_file:
        for line in old_file:
            line = line.replace(b'\r\n', b'\n')
            new_file.write(line)
#
    os.close(ftmp)
    os.remove(file_path)
    os.rename(abs_path, file_path)

def change_file(file_path, replace_lines):
    ftmp, abs_path = tempfile.mkstemp()
    with open(file_path, 'r') as old_file, open(abs_path, 'w') as new_file:
        for l, line in enumerate(old_file):
            if l in replace_lines.keys():
                new_file.write(replace_lines[l])
            else:
                new_file.write(line)
#
    os.close(ftmp)
    os.remove(file_path)
    os.rename(abs_path, file_path)

# simulation parameters
simulation_name = 'mc2p' 
partition = 'economy'
group = 'maite_group' 

# input file names
python_file_template = simulation_name+'_{}.py'
slurm_file_template = simulation_name+'_{}.slurm'

# sbatch parameters
ntasks_per_node = 1
cpus_per_task = 2
mem_per_cpu = 4000
time_days = 2
time_hours = 0
time_minutes = 0
time_seconds = 0

# python parameters
kwargs = {'mipfocus':1, 'presolve':2, 'timelimit':200, 'symmetry':1, 
          'heuristics':0.55, 'threads':cpus_per_task}

if not os.path.exists(simulation_name):
    os.makedirs(simulation_name)
shutil.copy('template_python.py', simulation_name)
shutil.copy('solve_MILP.py', simulation_name)
shutil.copy('template_slurm_python.slurm', simulation_name)
shutil.copy('run_batch.py', simulation_name)
os.chdir(simulation_name)

array_id = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
            20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
            38, 39, 40, 41, 42, 43, 44, 45, 56, 57, 58, 70, 71, 72, 73, 74, 75,
            76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86]

for batch_id in array_id:
    # write python files
    python_src = "template_python.py"
    line13 = "kwargs = {}\n".format(kwargs.__repr__())
    line15 = "array_id = {}\n".format(batch_id)
    replace_lines = {15:line15, 13:line13}
    python_dst = python_file_template.format(batch_id)
    copy_template(python_src, python_dst, replace_lines)

    # write slurm files
    slurm_src = "template_slurm_python.slurm"
    line2 = "#SBATCH --ntasks-per-node={}\n".format(ntasks_per_node)
    line3 = "#SBATCH --cpus-per-task={}\n".format(cpus_per_task)
    line4 = "#SBATCH --mem-per-cpu={}M\n".format(mem_per_cpu)
    line5 = "#SBATCH --time={}-{}:{}:{}\n".format(time_days, time_hours, time_minutes, time_seconds)
    line6 = "#SBATCH --job-name={}_{}\n".format(simulation_name, batch_id)
    line7 = "#SBATCH --output={}_{}.stdout\n".format(simulation_name, batch_id)
    line8 = "#SBATCH --error={}_{}.stderr\n".format(simulation_name, batch_id)
    line9 = "#SBATCH --partition={}\n".format(partition)
    line10 = "#SBATCH --account=maite_group\n".format(group)
    line14 = "python {}\n".format(python_dst)
    replace_lines = {2:line2, 3:line3, 4:line4, 5:line5, 6:line6, 7:line7,
                     8:line8, 9:line9, 10:line10, 14:line14}
    slurm_dst = slurm_file_template.format(batch_id)
    copy_template(slurm_src, slurm_dst, replace_lines)

#for file in os.listdir(os.curdir):
#    change_eol_win2unix(file)

os.remove('template_python.py')
os.remove('template_slurm_python.slurm')

try:
    os.rename('run_batch_template.py', 'run_batch.py')
except:
    pass
try:
    os.remove('run_batch_template.py')
except:
    pass