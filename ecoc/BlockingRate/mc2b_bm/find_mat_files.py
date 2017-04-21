#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 10:21:24 2017

@author: li
"""

import os
os.chdir('/scratch/ly6j/backup/probabilisticModel/new_mc1')
lists = []
mat_dict = {}
for (dirpath, dirnames, filenames) in os.walk('.'):
    for filename in filenames:
        if filename.endswith('.mat') and (filename.split('_')[0]=='for'):
            lists.append(filename)
            array_id = int(filename.split('_')[3])
            mat_id = int(filename.split('_')[4].split('.')[0])
            if array_id in mat_dict.keys():
                mat_dict[array_id].append(mat_id)
            else:
                mat_dict[array_id] = [mat_id]
            
print(os.getcwd())