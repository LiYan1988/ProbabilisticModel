#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 09:14:36 2017

@author: li
"""

from solve_MILP import *
import os

#os.chdir('/scratch/ly6j/backup/probabilisticModel/mc')

kwargs = {'threads': 4, 'symmetry': 1, 'timelimit': 1200, 'heuristics': 0.55, 'presolve': 2, 'mipfocus': 1}
Ii_hint = [2, 3, 6, 7, 16, 18, 19, 21, 22, 36, 37, 51, 58, 61, 62, 65]
array_id = 44
mat_id = range(1, 51)

for n in mat_id:
    input_file = 'for_python_1_{}_{}.mat'.format(array_id, n)
    output_file = 'solution_{}_{}.pkl'.format(array_id, n)
    solve(input_file, output_file, Ii_hint, **kwargs)