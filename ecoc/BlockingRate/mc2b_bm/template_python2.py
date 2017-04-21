#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Apr  9 15:18:04 2017

@author: li
"""

from solve_MILP import *
import os

os.chdir('/scratch/ly6j/backup/probabilisticModel/mc2p')

kwargs = {'mipfocus':1, 'presolve':2, 'timelimit':200, 'symmetry':1, 'heuristics':0.6}

array_id = 42
mat_id = 1

input_file = 'for_python_1_{}_{}.mat'.format(array_id, mat_id)
output_file = 'solution_{}_{}.pkl'.format(array_id, mat_id)
solve(input_file, output_file, **kwargs)