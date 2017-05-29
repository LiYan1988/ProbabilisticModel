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
import operator

# Load cost matrix, then make the unit from number of spans to km
cost_matrix = pd.read_csv('CoronetCostMatrix.csv', header=None)
cost_matrix = cost_matrix*100
cost_matrix[np.isinf(cost_matrix)] = 0
cost_matrix = cost_matrix.as_matrix()
#cost_matrix = cost_matrix.astype(int)

# Define the transmission reach, the unit is km
tr = 2000

class BenchmarkPredo(object):
    '''Solve Bathula's benchmark
    '''
    
    def __init__(self, topology_matrix, tr):
        '''
        Initialize the topology, transmission reach, and cost. Also calculate 
        the shortest paths.
        '''
        self.topology_matrix = topology_matrix
        self.tr = tr
        
        # Create networkx graph object for the network topology
        self.graph = nx.to_networkx_graph(topology_matrix,
                                          create_using=nx.DiGraph())
        # Calculate APSP costs, and convert it to numpy matrix
        self.graph_apsp_cost = pd.DataFrame(
                nx.all_pairs_dijkstra_path_length(self.graph)).as_matrix()
        
        # Calculate all the shortest paths for all pairs in the graph
        self.graph_apsp_paths = {(i, j):
            list(nx.all_shortest_paths(self.graph, i, j))
            for i in self.graph.nodes() for j in self.graph.nodes() if i<j}
            
        # Create augment graph
        self.augment_graph_adjacent_matrix = self.graph_apsp_cost<tr
        self.augment_graph_adjacent_matrix = \
            self.augment_graph_adjacent_matrix.astype(int)
        np.fill_diagonal(self.augment_graph_adjacent_matrix, 0)
            
        # Interate over all node pairs to find Pmin(i, j)
        self.node_pairs = list(combinations(self.graph.nodes(), 2))
        self.candidate_RS_per_node_pair = dict()
        for i, j in self.node_pairs:
            tmp_nodes = set()
            # For each shortest path of node pair (i, j)
            for k in self.graph_apsp_paths[(i, j)]:
                # Remove all nodes not in the shortest path k
                tmp_augment_graph = self.augment_graph_adjacent_matrix[:, k]
                tmp_augment_graph = tmp_augment_graph[k, :]
                # Create augmented graph of nodes in the shortes path k
                tmp_augment_graph = nx.to_networkx_graph(tmp_augment_graph, 
                    create_using=nx.DiGraph())
                # Find all possible min-hop paths (min-Regen allocations)
                tmp_paths = list(nx.all_shortest_paths(
                    tmp_augment_graph, 0, len(k)-1))
                # For each min-Regen allocation, collect the RS nodes
                for p in tmp_paths:
                    if len(p)>3:
                        tmp_nodes.update([k[x] for x in p[1:-1]])
#                        print([k[x] for x in p])
            self.candidate_RS_per_node_pair[(i, j)] = tmp_nodes
            
        self.candidate_RS_sum = sum(len(self.candidate_RS_per_node_pair[k]) 
            for k in self.node_pairs)
        self.candidate_RS_per_node = {}
        self.candidate_RS_per_node_normalized = {}
        for n in self.graph.nodes():
            self.candidate_RS_per_node[n] = 0
            for i, j in self.node_pairs:
                if n in self.candidate_RS_per_node_pair[(i, j)]:
                    self.candidate_RS_per_node[n] += 1
            self.candidate_RS_per_node_normalized[n] = \
                self.candidate_RS_per_node[n]/self.candidate_RS_sum
                
        # Rank nodes according to the likelihood
        self.RS_likelihood_ranked = sorted(
                self.candidate_RS_per_node_normalized.items(), 
                key=operator.itemgetter(1), reverse=True)
        
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
    benchmark = BenchmarkPredo(cost_matrix, tr)
    x = pd.DataFrame(benchmark.RS_likelihood_ranked)
    x.columns = ['node', 'likelihood']
    x.to_csv('Predo_routing_and_reach.csv', index=None)