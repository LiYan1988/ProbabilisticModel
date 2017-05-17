#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr  8 15:58:05 2017

@author: li
"""

import os
import pickle
import numpy as np
import pandas as pd
from scipy import sparse


#%%
Cdx = pd.read_csv('Cdx.csv', index_col=False, header=None)
Cnx = pd.read_csv('Cnx.csv', index_col=False, header=None)
circuit_mean_per_node = Cnx.mean(axis=1)
Iix = (Cnx>0).astype(int)
Iix_regen_sum = Iix.sum(axis=0)
Iix_regen_prob = Iix.mean(axis=1)
Iix_regen_prob_sort = Iix_regen_prob.sort(axis=0, inplace=False, ascending=False)
Iix_regen_prob = Iix_regen_prob.values

#%%
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt

plt.figure(1)
n, bins, patches = plt.hist(Iix_regen_sum, np.arange(10, 18, 1), normed=1, 
                            edgecolor='black')
plt.xlabel('Number of RS')
plt.ylabel('Probability')

plt.figure(2)
n, bins, patches = plt.hist(Cnx.sum(axis=0), np.arange(990, 1200, 20), normed=1, 
                            edgecolor='black')
plt.xlabel('Number of circuits')
plt.ylabel('Probability')

#%%
RS_sort = np.argsort(Iix_regen_prob)
RS_sort = RS_sort[::-1]
RS_selected = RS_sort[:17]
RS_prob = Iix_regen_prob[RS_selected]