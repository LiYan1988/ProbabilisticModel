#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 09:14:36 2017

@author: li
"""

from solve_MILP import *
import os

os.chdir('/scratch/ly6j/backup/probabilisticModel/new_mc1')

kwargs = {'presolve': 2, 'threads': 4, 'symmetry': 1, 'heuristics': 0.55, 'timelimit': 200, 'mipfocus': 1}

array_id = 53
mat_id = range(1, 51)

for n in mat_id:
    input_file = 'for_python_1_{}_{}.mat'.format(array_id, n)
    output_file = 'solution_{}_{}.pkl'.format(array_id, n)
    solve(input_file, output_file, **kwargs)