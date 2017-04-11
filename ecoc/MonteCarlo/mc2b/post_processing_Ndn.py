#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr  8 17:37:29 2017

@author: ly6j
"""

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
for k in pkl_dict.keys():
    for n in pkl_dict[k]:
        file_name = 'solution_{}_{}.pkl'.format(k, n)
        print('Loading {}'.format(file_name))
        tmp = read_data(file_name)
        Ndn = tmp[0]
        Ndn = {a:[Ndn[a, b] for b in range(75)] for a in range(2775)}
        Ndn = pd.DataFrame(Ndn)
        Ndn.to_csv('Ndn_{}_{}.csv'.format(k, n), index=False, header=None)


