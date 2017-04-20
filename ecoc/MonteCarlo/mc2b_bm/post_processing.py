#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr  8 08:44:48 2017

@author: ly6j
"""

import os
import pickle
import numpy as np
import pandas as pd
from scipy import sparse

def read_data(file_name):
    with open(file_name, 'rb') as f:
        data = pickle.load(f)
        
    return data

#def extract_


os.chdir('/scratch/ly6j/backup/probabilisticModel/new_mc1')
lists = []
pkl_dict = {}
for (dirpath, dirnames, filenames) in os.walk('.'):
    for filename in filenames:
        if filename.endswith('.pkl'):
            lists.append(filename)
            array_id = int(filename.split('_')[1])
            pkl_id = int(filename.split('_')[2].split('.')[0])
            if array_id in pkl_dict.keys():
                pkl_dict[array_id].append(pkl_id)
            else:
                pkl_dict[array_id] = [pkl_id]

print(os.getcwd())

#%% 
name_list = ['Ndnx', 'Cdnx', 'Iix', 'Itotx', 'Ctot_per_demand', 
             'Ctot_per_node', 'Ctot', 'model_time', 'solve_time']
idx_list = [4, 5]
Cd = {}
Cn = {}
for k in pkl_dict.keys():
    for n in pkl_dict[k]:
        file_name = 'solution_{}_{}.pkl'.format(k, n)
        print('Loading {}'.format(file_name))
        tmp = read_data(file_name)
#        Cdn = tmp[1]
#        Cdn = {k:[Cdn[n,k] for n in range(2775)] for k in range(75)}
#        Cdn = pd.DataFrame(Cdn).values
#        Cdn = sparse.csr_matrix(Cdn)
        Cd[k, n] = tmp[4]
        Cn[k, n] = tmp[5]


#%%
Cdx = pd.DataFrame(Cd)
Cnx = pd.DataFrame(Cn)
circuit_mean_per_node = Cnx.mean(axis=1)
Iix = (Cnx>0).astype(int)
Iix_regen_sum = Iix.sum(axis=0)
Iix_regen_prob = Iix.mean(axis=1)
Iix_regen_prob_sort = Iix_regen_prob.sort(axis=0, inplace=False)
Cdx.to_csv('Cdx.csv', index=False, header=False)
Cnx.to_csv('Cnx.csv', index=False, header=False)

#%%
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt

#n, bins, patches = plt.hist(Iix_regen_sum, np.arange(10, 18, 1), normed=1, 
#                            edgecolor='black')

n, bins, patches = plt.hist(Cnx.sum(axis=0), np.arange(990, 1200, 10), normed=1, 
                            edgecolor='black')
