# -*- coding: utf-8 -*-
"""
Created on Wed May 17 07:27:22 2017

@author: liyan
"""

import pandas as pd
import numpy as np
from gurobipy import *
import networkx as nx
from itertools import combinations
import pickle
import json

# Load cost matrix, then make the unit from number of spans to km
cost_matrix = pd.read_csv('CoronetCostMatrix.csv', header=None)
cost_matrix = cost_matrix*100
cost_matrix[np.isinf(cost_matrix)] = 0
cost_matrix = cost_matrix.as_matrix()
cost_matrix = cost_matrix.astype(int)

# Define the transmission reach, the unit is km
tr = 2000

class BenchmarkBathula(object):
    '''Solve Bathula's benchmark
    '''
    
    def __init__(self, topology_matrix, tr, c_r, c_m):
        '''
        Initialize the topology, transmission reach, and cost. Also calculate 
        the shortest paths.
        '''
        self.topology_matrix = topology_matrix
        self.tr = tr
        self.c_r = c_r # cost per RS
        self.c_m = c_m # cost per km 
        
        # Create networkx graph object for the network topology
        self.graph = nx.to_networkx_graph(topology_matrix,
                                          create_using=nx.DiGraph())
        # Calculate APSP lengths, and convert it to numpy matrix
        self.topology_apsp = pd.DataFrame(
                nx.all_pairs_dijkstra_path_length(self.graph)).as_matrix()
        
        # Create augmented graph
        # First calculate the adjacent matrix of the augmented graph
        self.augment_adjacent_matrix = self.topology_apsp<tr
        self.augment_adjacent_matrix = self.augment_adjacent_matrix.astype(int)
        np.fill_diagonal(self.augment_adjacent_matrix, 0)
        # Then calculate the length of the shortest paths in the augmented 
        # graph for each node pair
        self.augment_distance_matrix = np.zeros_like(self.topology_apsp)
        self.augment_distance_matrix[self.augment_adjacent_matrix==1] = \
            self.topology_apsp[self.augment_adjacent_matrix==1]
        # Finally, create the cost matrix in the augmented graph
        self.augment_cost_matrix = self.c_r*self.augment_adjacent_matrix+\
            self.c_m*self.augment_distance_matrix
            
        # Create networkx graph object for the augmented graph with customized
        # costs
        self.augment_graph = nx.to_networkx_graph(self.augment_cost_matrix, 
                                                  create_using=nx.DiGraph())
        # Calculate APSP lengths, and convert it to numpy matrix
        self.augment_apsp = pd.DataFrame(
                nx.all_pairs_dijkstra_path_length(
                        self.augment_graph)).as_matrix()
        
        # Calculate all the shortest paths for all pairs
        self.aspap = {(i, j):
            list(nx.all_shortest_paths(self.augment_graph, i, j))
            for i in self.graph.nodes() for j in self.graph.nodes() if i<j}
        self.len_aspap = {(i, j):len(self.aspap[i, j])
            for (i, j) in self.aspap.keys()}
        
        
    def solve(self, latitude=None, **kwargs):
        '''
        Solve the CRLP MILP
        '''
        nodes = self.graph.nodes()
        links = self.augment_graph.edges()
#        links.extend([(x[1], x[0]) for x in links])
        links = tuplelist(links)
        requests = tuplelist(combinations(nodes, 2))
        N = len(nodes)
        
        # Create a model
        model = Model('CRLP')
        
        # Add variables
        # 1 if regenerators are placed in u, 0 otherwise
        role = model.addVars(nodes, vtype=GRB.BINARY, name='isRS')
        
        # 1 if link (u, v) is used for request k
        f = model.addVars(links, requests, vtype=GRB.BINARY, name='LinkUsage')
        # cost of the shortest path
        r = model.addVars(requests, vtype=GRB.CONTINUOUS, name='LinkLength')
        
        # Add constraints
        # The paths are shortest 
        model.addConstrs((r[k]<=self.augment_apsp[k] 
            for k in requests), 'ASAP')
        model.addConstrs((r[k]==quicksum(self.augment_cost_matrix[l]*f[l+k]
            for l in links) for k in requests), 'SP')
        
        # Flow conservation for sources
        model.addConstrs((quicksum(f[l+k] for l in links.select(k[0], '*'))-
                          quicksum(f[l+k] for l in links.select('*', k[0]))
                          ==1 for k in requests), name='FlowSrc')
        # Flow conservation for destinations
        model.addConstrs((quicksum(f[l+k] for l in links.select('*', k[1]))-
                          quicksum(f[l+k] for l in links.select(k[1], '*'))
                          ==1 for k in requests), name='FlowDst')
        # Flow conservation for intermediate nodes
        model.addConstrs((quicksum(f[l+k] for l in links.select('*', u))-
                          quicksum(f[l+k] for l in links.select(u, '*'))
                          ==0 for k in requests for u in nodes 
                          if (u!=k[0] and u!=k[1])), name='FlowInt')
        
        # RS allocation
        model.addConstrs((role[u]>=quicksum(f[l+k] 
            for l in links.select(u, '*'))/N for k in requests for u in nodes 
            if (u!=k[0] and u!=k[1])), name='placeRS')
        
        model.setObjective(quicksum(role[u] for u in nodes), GRB.MINIMIZE)
#        model.setObjective(quicksum(r[k] for k in requests))
        
        if len(kwargs):
            for key, value in kwargs.items():
                try:
                    setattr(model.params, key, value)
                except:
                    pass
        model.update()
        
        model.optimize()
        
        self.nodes = nodes
        self.links = links
        self.requests = requests
        self.N = N
        self.model = model
        self.role = role
        self.f = f
        self.r = r
        
def save_pickle(file_name, data):
    '''File name must ends with .pkl
    '''
    with open(file_name, 'wb') as f:
        pickle.dump(data, f, pickle.HIGHEST_PROTOCOL)
        
def read_pickle(file_name):
    with open(file_name, 'rb') as f:
        data = pickle.load(f)
        
    return data

def save_json(file_name, data):
    '''Save data with json
    '''
    with open(file_name, 'w') as f:
        json.dump(data, f)
        
def read_json(file_name):
    with open(file_name, 'r') as f:
        data = json.load(f)
        
    return data
        
        
if __name__=='__main__':
    scheme = ['dist', 'regen', 'cost', 'mdmr']
    c_r = [0, 1, 1000, 1]
    c_m = [1, 0, 1, 1000]
    
    for i in range(4):
        b = BenchmarkBathula(cost_matrix, tr, c_r[i], c_m[i])
        b.solve(mipfocus=1, timelimit=72000)
        # sp = {k:b.r[k].x for k in b.requests}
        
        # Calculate numbers of regens and circuits
        circuits = {u:sum(b.f[l+k].x
            for l in links.select(u, '*') for k in b.requests 
            if (k[0]!=u and k[1]!=u)) for u in b.nodes}            
        solution = pd.DataFrame(circuits, index=['circuit']).T
        solution['regen'] = solution['circuit']>0.5
        solution['regen'] = solution['regen'].astype(int)
        solution.index.names = ['node']
        solution.columns.names = ['']
        
        # Calculate regenerated pairs on regen
        pairs_on_regen = {u:[k for k in b.requests 
                             if True in (b.f[l+k].x>0.5 
                                         for l in links.select(u, '*')) 
                             if (k[0]!=u and k[1]!=u)] for u in b.nodes}  
                
        # Calculate regens on each pair
        regens_on_pair = {k:[u for u in b.nodes 
                             if True in (b.f[l+k].x>0.5
                                         for l in links.select(u, '*')) 
                             if (k[0]!=u and k[1]!=u)] for k in b.requests}
        # 
        role = {u:b.role[u].x for u in b.nodes}
        r = {k:b.r[k].x for r in b.requests}
        f = {(l, k): b.f[l+k].x for l in b.links for k in b.requests}
                
        results = [solution.to_dict(orient='index'), pairs_on_regen, 
                   regens_on_pair, role, r, f]
        save_pickle('results_min_{}.pkl'.format(scheme[i]), results)