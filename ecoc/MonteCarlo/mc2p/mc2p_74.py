#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 09:14:36 2017

@author: li
"""

from solve_MILP import *
import os

os.chdir('/scratch/ly6j/backup/probabilisticModel/mc2p')

kwargs = {'mipfocus': 1, 'symmetry': 1, 'threads': 2, 'timelimit': 200, 'presolve': 2, 'heuristics': 0.55}

array_id = 74
mat_id = range(1, 51)

for n in mat_id:
    input_file = 'for_python_1_{}_{}.mat'.format(array_id, n)
    output_file = 'solution_{}_{}.pkl'.format(array_id, n)
    solve(input_file, output_file, **kwargs)