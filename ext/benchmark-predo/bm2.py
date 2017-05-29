# -*- coding: utf-8 -*-
"""
Created on Sun May 28 12:49:35 2017

@author: liyan
"""

from bm1 import *

solution1, pairs_on_regen1, regens_on_pair1, role1, r1, f1 = \
read_pickle('results_min_mdmr.pkl')

rs = [k+1 for k in role1.keys() if role1[k]>0.5]
print(rs)