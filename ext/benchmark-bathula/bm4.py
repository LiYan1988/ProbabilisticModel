# -*- coding: utf-8 -*-
"""
Created on Sat Jun 10 11:08:03 2017

@author: liyan
"""

from bm1 import *

#results = read_pickle('results_min_dist_TR2900_subopt.pkl')
#
#role = results[3]
#
#x = [k for k in role.keys() if role[k]==1]
#print(x)

#%%
tr = 2000
c_r = 0
c_m = 0
b = BenchmarkBathula(cost_matrix, tr, c_r, c_m, 0)