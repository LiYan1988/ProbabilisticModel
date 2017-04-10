#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 09:14:36 2017

@author: li
"""

from solve_MILP import *
import os

os.chdir('/scratch/ly6j/backup/probabilisticModel/mc2p_1')

kwargs = {'mipfocus': 1, 'symmetry': 1, 'threads': 4, 'timelimit': 1200, 'presolve': 2, 'heuristics': 0.55}
Ii_hint = [33, 20, 19, 22, 29, 39, 15, 8, 27, 50, 4, 28, 13]
array_id = 36
mat_id = range(1, 51)

for n in mat_id:
    input_file = 'for_python_1_{}_{}.mat'.format(array_id, n)
    output_file = 'solution_{}_{}.pkl'.format(array_id, n)
    solve(input_file, output_file, Ii_hint, **kwargs)