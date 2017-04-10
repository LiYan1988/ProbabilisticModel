#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 09:05:52 2017

@author: li
"""

import scipy.io as sio
from gurobipy import *
import time
import pickle


def solve(input_file, output_file, **kwargs):
    m = sio.loadmat(input_file)

    Ndemands = m['Ndemands'][0][0]
    Cmax = m['Cmax'][0][0]
    CircuitWeight = 0.5/Cmax
    bigM = m['bigM'][0][0]
    NoiseMax = m['NoiseMax'][0][0]
    RegenWeight = m['RegenWeight'][0][0]
    demandsMatrix = m['demandsMatrix']
    demandsMatrix[:, :2] = demandsMatrix[:, :2]-1
    a = m['demandPathLinks']
    # the links for each demand's path
    demandPathLinks = {k:a[k][0][0]-1 for k in range(Ndemands)} 
    # the nodes for each demand's path
    demandPaths = {k:m['demandPaths'][k][0][0]-1 for k in range(Ndemands)}
    # the noise per demand per link
    noisePerLinkDemand = m['noisePerLinkDemand']
    NNodes = m['NNodes'][0][0]
    
    del m

#%%
    tic = time.clock()
    model = Model('model_{}'.format(1))
    model.Params.UpdateMode = 1
    
    Ndn = {}
    for d in range(Ndemands):
        for n in range(NNodes):
            Ndn[d, n] = model.addVar(vtype=GRB.CONTINUOUS, lb=0, ub=NoiseMax, 
               name='Ndn[{},{}]'.format(d, n))
    
    Cdn = {}
    for d in range(Ndemands):
        for n in range(NNodes):
            Cdn[d, n] = model.addVar(vtype=GRB.BINARY, obj=CircuitWeight, 
               name='Cdn[{},{}]'.format(d, n))
    
    Ii = {}
    for n in range(NNodes):
        Ii[n] = model.addVar(vtype=GRB.BINARY, obj=RegenWeight, 
          name='Ii[{}]'.format(n))
    
    for d in range(Ndemands):
        tmpNodes = demandPaths[d]
        idxLinks = demandPathLinks[d]
        for n in range(NNodes):
            if (n not in tmpNodes) or (n==tmpNodes[0]):
                # Ndn=0
                model.addConstr(Ndn[d, n]==0, name='Ndn[{},{}]=0'.format(d, n))
                model.addConstr(Cdn[d, n]==0, name='Cdn[{},{}]=0'.format(d, n))
        for n in range(1, len(tmpNodes)):
            tmpNoise = noisePerLinkDemand[d, idxLinks[n-1]]
            # c1
            model.addConstr(Ndn[d, tmpNodes[n]]<=Ndn[d, tmpNodes[n-1]]+tmpNoise,
                            name='c1[{},{}]'.format(d, tmpNodes[n]))
            # c2
            model.addConstr(Ndn[d, tmpNodes[n]]<=bigM*(1-Cdn[d, tmpNodes[n]]),
                            name='c2[{},{}]'.format(d, tmpNodes[n]))
            # c3
            model.addConstr(Ndn[d, tmpNodes[n-1]]+tmpNoise-Ndn[d, tmpNodes[n]]<=
                            bigM*Cdn[d, tmpNodes[n]], 
                            name='c3[{},{}]'.format(d, tmpNodes[n]))
            # c4
            model.addConstr(Ndn[d, tmpNodes[n-1]]+tmpNoise<=NoiseMax, 
                            name='c4[{},{}]'.format(d, tmpNodes[n]))
    
    for n in range(NNodes):
        model.addConstr(quicksum(Cdn[d, n] for d in range(Ndemands))<=Cmax*Ii[n],
                        name='Cmax[{}]'.format(n))
        
    model_time = time.clock()-tic
#%%
    tic = time.clock()
    if len(kwargs):
        for key, value in kwargs.items():
            try:
                setattr(model.params, key, value)
            except:
                pass
    else:
        model.Params.timelimit = 100
        model.Params.presolve = 2
        model.Params.mipfocus = 1
        model.Params.symmetry = 1
        model.Params.heuristics = 0.6
    model.optimize()
    solve_time = time.clock()-tic

#%%
    Ndnx = {}
    for d in range(Ndemands):
        for n in range(NNodes):
            Ndnx[d, n] = Ndn[d, n].x
        
    Cdnx = {}
    for d in range(Ndemands):
        for n in range(NNodes):
            Cdnx[d, n] = Cdn[d, n].x
            
    Iix = {}
    for n in range(NNodes):
        Iix[n] = Ii[n].x
        
    Itotx = sum(Iix.values())
    Ctot_per_node = [sum(Cdnx[d, n] for d in range(Ndemands)) 
                     for n in range(NNodes)]
    Ctot_per_demand = [sum(Cdnx[d, n] for n in range(NNodes)) 
                    for d in range(Ndemands)]
    Ctot = sum(Ctot_per_node[n] for n in range(NNodes))
    
    solutions = (Ndnx, Cdnx, Iix, Itotx, Ctot_per_demand, Ctot_per_node, Ctot,
                 model_time, solve_time)
    
    with open(output_file, 'wb') as f:
        pickle.dump(solutions, f)
    
    return solutions