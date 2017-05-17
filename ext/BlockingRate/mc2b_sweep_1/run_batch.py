#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 09:51:34 2017

@author: li
"""

import os
from subprocess import call
from shutil import copyfile

for file in os.listdir('.'):
    try:
        extension = file.split('.')[1]
        if extension=='slurm':
            call(['sbatch', file])
    except:
        pass