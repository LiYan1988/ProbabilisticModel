# -*- coding: utf-8 -*-
"""
Created on Fri Jun  9 15:30:34 2017

@author: liyan

Try TR = 2900 km, which corresponds to the real TR with my fiber parameters.
"""

from bm1 import *

scheme = ['dist_TR2900']
c_r = [0] # weight of Regens
c_m = [1] # weight of distance
tr = 2900
latitude = 0

for i in range(1): 
    b = BenchmarkBathula(cost_matrix, tr, c_r[i], c_m[i], latitude)
    b.solve(mipfocus=1, timelimit=72000, mipgap=0.0)
    # sp = {k:b.r[k].x for k in b.requests}
    
    # Calculate numbers of regens and circuits
    circuits = {u:sum(b.f[l+k].x
        for l in b.links.select(u, '*') for k in b.requests 
        if (k[0]!=u and k[1]!=u)) for u in b.nodes}            
    solution = pd.DataFrame(circuits, index=['circuit']).T
    solution['regen'] = solution['circuit']>0.5
    solution['regen'] = solution['regen'].astype(int)
    solution.index.names = ['node']
    solution.columns.names = ['']
    
    # Calculate regenerated pairs on regen
    pairs_on_regen = {u:[k for k in b.requests 
                         if True in (b.f[l+k].x>0.5 
                                     for l in b.links.select(u, '*')) 
                         if (k[0]!=u and k[1]!=u)] for u in b.nodes}  
            
    # Calculate regens on each pair
    regens_on_pair = {k:[u for u in b.nodes 
                         if True in (b.f[l+k].x>0.5
                                     for l in b.links.select(u, '*')) 
                         if (k[0]!=u and k[1]!=u)] for k in b.requests}
    # 
    role = {u:b.role[u].x for u in b.nodes}
    r = {k:b.r[k].x for k in b.requests}
    f = {(l, k): b.f[l+k].x for l in b.links for k in b.requests}
            
    results = [solution.to_dict(orient='index'), pairs_on_regen, 
               regens_on_pair, role, r, f]
    save_pickle('results_min_{}_subopt.pkl'.format(scheme[i]), results)
