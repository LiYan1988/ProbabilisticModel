#ifndef SIMUBP_H_INCLUDED
#define SIMUBP_H_INCLUDED

/*
Function list:
1. simulateBPMD: simulate with one traffic matrix and
    multiple shuffles
    a. load/hard-code constant parameters
    b. random seed
    c. load topology cost matrix
    d. create link data structure
    e. create topology structure
    f. parameters and data structure for traffic matrix
    g. simulation data structure
    h. select algorithm
    i. load routing data
    j. simulate -> simulateBlockProbs
    k. save simulation results
2. simulateBlockProb:
    a. load template traffic matrix, modify the data rate
        -> modifyDemandStruct
    b. simulate -> simulateOneByOneBlockProb
3. modifyDemandStruct: change data rate
4. simulateOneByOneBlockProb: simulate all shuffles in a
    for loop
5. allocateOneByOneBP: simulate one shuffle, allocate
    demands one by one and calculate if demand is blocked
    a. matlab find nonzero elements in a vector
    b. find free frequency slot, return the first one
    c. tic/toc function
    d. matlab isempty
    e. check if a demand is blocked by noise -> checkBlock
    f. allocate demand
    g. block demand
6. checkBlock: check if demand is blocked due to noise
    a. pretend new demand is allocated
    b. calculate noise -> calculateNoise
    c. if checked, allocate, otherwise block demand
7. calculateNoise: calculate noise for all demands on a
    single link
*/


#include <random>
#include <iostream>
#include <vector>
#include <algorithm>
#include <iomanip>
#include <fstream>
#include <string>
#include <sstream>
#include <math.h>
#include <ostream>
#include <numeric>
#include <thread>
#include <mutex>
#include <ctime>
#include <set>
#include <map>
#include <tuple>

using namespace std;

struct Link;

typedef vector<double> Row_double;
typedef vector<Row_double> Matrix_double;
typedef vector<Matrix_double> Tensor_double;
typedef vector<int> Row_int;
// src, dst, length
typedef tuple<int, int, double> Nodepair;
typedef vector<Nodepair> Row_nodepair;
typedef vector<Row_nodepair> Matrix_nodepair;
typedef vector<Row_int> Matrix_int;
typedef vector<Matrix_int> Tensor_int;
typedef vector<Link> Row_link;
typedef vector<Row_link> Matrix_link;
// source, destination, path length, nodes
typedef tuple<int, int, double, Row_int> Path;
typedef vector<Path> Row_path;
typedef vector<Row_path> Matrix_path;
typedef vector<signed char> Row_sc; // for +1, 0, and -1
typedef vector<Row_sc> Matrix_sc;
typedef tuple<Row_nodepair, Row_double,
    Matrix_int, Matrix_int, Matrix_int> Demand;
typedef vector<long int> Row_longint;

// The unit of frequency is GHz
const double PSD(15); //muW/GHz ~ 10e-15 W/Hz
const double ALPHA(5.065687204586902e-05); // 1/m, fiber loss
const double BETA(2.1668e-26); // s^2/m, GVD parameter
const double GAMMA(0.00132); // 1/(W*m), nonlinear parameter
const double NASE(3.583118981045100e-2); //  W/Hz, ASE noise
const double RHO(0.002110815172018); // (GHz)^(-2)
const double MU(7.579351569161363e-07); // (muW/GHz)^(-2)
const string MODULATION("PM-QPSK"); // modulation format
const double NOISE_MAX(2.133712660028449); // maximum tolerable noise
const double SLOT_SIZE(12.5); // GHz
const int GUARDBAND(1); // guardband, 1 frequency slot is 12.5 GHz
const long int FREQUENCY_MAX(25600); // #total slots, 12.5 GHz slot size
const double BANDWIDTH_MIN(30); // GHz, minimum bandwidth
const double INF(10000000000000); // infinity
const double INF2(pow(INF, 2)); // even bigger infinity

Matrix_double coronet_cost; // coronet cost matrix
Matrix_link coronet_connection; // coronet connection list
int n_nodes; // #nodes
int n_links; // #links
Row_int regen_list; // indexes of Regens
int n_regens; // #Regens
Matrix_int link_sub2ind; // (src, dst) pair to index
Matrix_int link_ind2sub; // index to (src, dst) pair

// Link structure for the shortest path algorithm
struct Link
{
    int to;
    double length;
};

default_random_engine generator (127849);

// Read data from csv
tuple<Matrix_double, int, Row_int> read_csv(string file_name)
{
    ifstream data(file_name);
    string line;
    Matrix_double mat;
    Row_int n_cols;
    int n_rows(0);
    while(getline(data,line)){
        Row_double row_tmp;
        stringstream lineStream(line);
        string cell;
        n_cols.push_back(0);
        while(getline(lineStream,cell,',')){
                if(cell.compare("Inf")==0){
                    row_tmp.push_back(INF);
                }
                else{
                    row_tmp.push_back(stod(cell));
                    n_cols.back()++;
                }
            }
            mat.push_back(row_tmp);
            n_rows++;
        }
    return make_tuple(mat, n_rows, n_cols);
}

// Write data to csv
template <class T>
void write_csv(string file_name, T mat)
{
    ofstream myfile(file_name);
    int n_rows = mat.size();
    for(int i=0; i<n_rows; ++i){
        for(size_t j=0; j<mat[i].size(); ++j){
            myfile<<mat[i][j]<<",";
        }
        myfile<<endl;
    }
    myfile.close();
}

// Calculate noise for all demands on a link
Matrix_double calculate_noise(Row_double demand_data_rates,
    Row_double demand_frequencies, double n_spans)
{
    // Calculate Noise of all demands on a link

    // Number of users on link
    int n_users = demand_data_rates.size();
    // ASE noise on the link
    double noise_ase = n_spans*NASE;
    // SCI
    Row_double noise_sci;
    for(int i=0; i<n_users; ++i){
        noise_sci.push_back(n_spans*MU*PSD*asinh(RHO*pow(demand_data_rates[i], 2)));
    }

    // XCI
    Matrix_double noise_xci_mat(n_users, Row_double(n_users, 0)); // XCI generated by j to i
    double tmp;
    for(int i=0; i<n_users; ++i){
        for(int j=0; j<n_users; ++j){
            if(i==j) continue;
            tmp = abs(demand_frequencies[i]-demand_frequencies[j]);
            tmp = (tmp+0.5*demand_data_rates[j])/(tmp-0.5*demand_data_rates[j]);
            noise_xci_mat[i][j] = n_spans*MU*pow(PSD, 3)*log(tmp);
        }
    }
    Row_double noise_xci(n_users, 0);
    for(int i=0; i<n_users; ++i){
        noise_xci[i] = 0;
        for(int j=0; j<n_users; ++j){
            noise_xci[i] = noise_xci[i]+noise_xci_mat[i][j];
        }
    }

    // Total noise
    Row_double noise_total(n_users, 0);
    for(int i=0; i<n_users; ++i){
        noise_total[i] = noise_ase+noise_sci[i]+noise_xci[i];
    }
    return noise_xci_mat;
}

// Read data from Regen csv files
tuple<Row_int, int> read_regen_list(tuple<Matrix_double, int, Row_int> csv_data)
{
    Matrix_double tmp_matrix_double;
    int tmp_n_regens;
    Row_int tmp_regen_list, tmp_row_int;
    tie(tmp_matrix_double, tmp_n_regens, tmp_row_int) = csv_data;
    if(tmp_n_regens==1){
        // if data is written as row vector
        for(int i=0; i<tmp_row_int[0]; ++i){
            // Note the index of Matlab starts from 1
            tmp_regen_list.push_back(int(tmp_matrix_double[0][i])-1);
        }
        tmp_n_regens = tmp_row_int[0];
    }
    else {
        // if data is in column vector
        for(int i=0; i<tmp_n_regens; ++i){
            // Note the index of Matlab starts from 1
            tmp_regen_list.push_back(int(tmp_matrix_double[i][0])-1);
        }
    }
    return make_tuple(tmp_regen_list, tmp_n_regens);
}

// Split string by delimiter
template<typename Out>
void split(const std::string &s, char delim, Out result) {
    std::stringstream ss;
    ss.str(s);
    std::string item;
    while (std::getline(ss, item, delim)) {
        *(result++) = item;
    }
}

vector<string> split(const string &s, char delim) {
    vector<string> elems;
    split(s, delim, back_inserter(elems));
    return elems;
}

// Load simulation parameters
void load_simulation_parameters(string algorithm)
{
    // Load cost matrix and #nodes
    tuple<Matrix_double, int, Row_int> csv_data;
    Row_int tmp_row_int;
    csv_data = read_csv("CoronetCostMatrix.csv");
    tie(coronet_cost, n_nodes, tmp_row_int) = csv_data;

    // Construct connection list from matrix cost
    Link tmp_edge;
    for(int i=0; i<n_nodes; ++i){
        Row_link tmp_row_link;
        for(int j=0; j<n_nodes; ++j){
            if(coronet_cost[i][j]>=INF) continue;
            tmp_edge.to = j;
            tmp_edge.length = coronet_cost[i][j];
            tmp_row_link.push_back(tmp_edge);
        }
        coronet_connection.push_back(tmp_row_link);
    }

    // Create link_sub2ind and link_ind2sub
    int link_index(0);
    Row_int link_sub;
    Row_int tmp_row_int2(n_nodes, -1);
    for (int i = 0; i < n_nodes; ++i){
        link_sub2ind.push_back(tmp_row_int2);
        for (int j = 0; j < n_nodes; ++j){
            if (coronet_cost[i][j] >= INF) continue;
            link_sub2ind[i][j] = link_index;
            link_sub = {i, j};
            link_ind2sub.push_back(link_sub);
            link_index += 1;
        }
    }
    n_links = link_index;

    // Load Regen allocation according to algorithm
    tuple<Row_int, int> tmp_regens;
    int tmp_n_regens;
    if(algorithm.compare("benchmark_Bathula_MD_subopt")==0){
        csv_data = read_csv("benchmark_Bathula_MD_subopt.csv");
    }
    else if(algorithm.compare("benchmark_Bathula_MD_opt")==0){
        csv_data = read_csv("benchmark_Bathula_MD.csv");
    }
    else if(algorithm.compare("proposed_Yan_MD_RC")==0){
        csv_data = read_csv("proposed_RC_MD.csv");
    }
    else if(algorithm.compare("proposed_Yan_MD_RS")==0){
        csv_data = read_csv("proposed_RS_MD.csv");
    }
    else if(algorithm.compare("benchmark_Predo_MD_RoutingOnly")==0){
        csv_data = read_csv("benchmark_Predo_MD_RoutingOnly.csv");
    }
    else if(algorithm.compare("benchmark_Predo_MD_RoutingReach")==0){
        csv_data = read_csv("benchmark_Predo_MD_RoutingReach.csv");
    }
    vector<string> algorithm_split = split(algorithm, '_');
    string author = algorithm_split[1];
    if(author.compare("Bathula")==0){
        // keep all the Regens in Bathula's methods
        tmp_regens = read_regen_list(csv_data);
        tie(regen_list, tmp_n_regens) = tmp_regens;
        n_regens = regen_list.size();
    }
    else{
        // change the length of the Regen list in other methods
        tmp_regens = read_regen_list(csv_data);
        tie(regen_list, tmp_n_regens) = tmp_regens;
        regen_list.resize(n_regens);
    }
}

// Find the shortest path between src and all other nodes
Row_path dijkstra(int src)
{
    Row_double min_distance(n_nodes, INF);
    min_distance[src] = 0;
    set<pair<double, int>> active_nodes;
    active_nodes.insert({0, src});
    Row_int predecessor(n_nodes);
    predecessor[src] = src;

    while(!active_nodes.empty()){
        int next_node = active_nodes.begin()->second;
        active_nodes.erase(active_nodes.begin());
        for (auto ed:coronet_connection[next_node])
        if (min_distance[ed.to]>min_distance[next_node]+ed.length){
            active_nodes.erase({min_distance[ed.to], ed.to});
            min_distance[ed.to] = min_distance[next_node]+ed.length;
            active_nodes.insert({min_distance[ed.to], ed.to});
            predecessor[ed.to] = next_node;
        }
    }

    Row_path spath;
    Row_int dummy;
    dummy.push_back(src);
    for (int i = 0; i < n_nodes; ++i){
        if (i == src) spath.push_back(make_tuple(i, i, 0, dummy));
        else {
            Row_int tmp_path;
            int tmp_node = i;
            while (tmp_node != src){
                tmp_path.insert(tmp_path.begin(), tmp_node);
                tmp_node = predecessor[tmp_node];
            }
            tmp_path.insert(tmp_path.begin(), src);
            spath.push_back(make_tuple(src, i, min_distance[i], tmp_path));
        }
    }

    return spath;
}

Matrix_path all_pair_shortest_path(void)
{
    Matrix_path spap;
    Row_path tmp;
    for (int i = 0; i < n_nodes; ++i){
        tmp = dijkstra(i);
        spap.push_back(tmp);
    }
    return spap;
}

// Generate random traffic demands, demand (1, 2) is different
// from (2, 1)
// To make the traffic demands generalize enough, all input
// arguments are vectors.
// Output: (src, dst, bandwidth), path length, demand_path_node,
// demand_path_link, demand_on_link
Demand generate_demands(Matrix_int demands_per_pair,
    Matrix_double bandwidth_mean, Matrix_double bandwidth_std)
{
    // Generate demands with normal distributed bandwidth
    Row_nodepair demands;
    double tmp_bandwidth;
    Nodepair tmp_demand;
    for(int i=0; i<n_nodes; ++i){
        for(int j=0; j<n_nodes; ++j){
            if(i==j) continue;
            normal_distribution<double> distribution(
                bandwidth_mean[i][j], bandwidth_std[i][j]);
            for(int n=0; n<demands_per_pair[i][j]; ++n){
                tmp_bandwidth = distribution(generator);
                if(tmp_bandwidth<BANDWIDTH_MIN){
                    tmp_bandwidth = BANDWIDTH_MIN;
                }
                tmp_demand = make_tuple(i, j, tmp_bandwidth);
                demands.push_back(tmp_demand);
            }
        }
    }

    // Calculate APSP
    Matrix_path apsp = all_pair_shortest_path();

    // Related to nodes
    Row_double demand_path_length; // Create path_length
    Matrix_int demand_path_node; // Create demand_path_node
    Matrix_int demand_path_link(demands.size(), Row_int());
    Matrix_int demand_on_link(n_links, Row_int());
    double tmp_path_length;
    Row_int tmp_path_node;
    int tmp_src, tmp_dst, tmp_link_idx;
    for (size_t i = 0; i < demands.size(); ++i){
        tmp_src = get<0>(demands[i]);
        tmp_dst = get<1>(demands[i]);
        tmp_path_length = get<2>(apsp[tmp_src][tmp_dst]);
        tmp_path_node = get<3>(apsp[tmp_src][tmp_dst]);
        demand_path_length.push_back(tmp_path_length);
        demand_path_node.push_back(tmp_path_node);
        for (size_t j = 0; j < tmp_path_node.size()-1; ++j){
            tmp_src = tmp_path_node[j];
            tmp_dst = tmp_path_node[j+1];
            tmp_link_idx = link_sub2ind[tmp_src][tmp_dst];
            demand_path_link[i].push_back(tmp_link_idx);
            demand_on_link[tmp_link_idx].push_back(i);
        }
    }

    return make_tuple(demands, demand_path_length,
        demand_path_node, demand_path_link, demand_on_link);
}

// Find the first running sequence with length_th available slots
long int find_first_avail_slot(Row_sc avail, int length_th)
{
    // First find running available slots
    avail.insert(avail.begin(), 0);
    avail.push_back(0);
    for (size_t i = 1; i < avail.size(); ++i)
        avail[i] = avail[i] - avail[i-1];
    avail.erase(avail.begin());
    // Then find starts and ends of running sequences
    Row_longint run_starts, run_ends;
    for (size_t i = 0; i < avail.size(); ++i){
        if (avail[i] == 1) run_starts.push_back(i);
        if (avail[i] == -1) run_ends.push_back(i);
    }
    // Calculate lengths of running sequences, stop if find
    // one with enough length
    size_t i(0);
    for (; i < run_starts.size(); ++i){
        long int tmp = run_ends[i] - run_starts[i];
        if (tmp >= (long) length_th) break;
    }
    // if not find any, return -1
    if (i == run_starts.size()) return -1;
    // else return the start index of the sequence
    else return run_starts[i];
}

void simulate_blocking(Demand demand_tuple)
{
    // Unpack demand_tuple
    Row_nodepair demands;
    Row_double demand_path_length;
    Matrix_int demand_path_node, demand_path_link, demand_on_link;
    tie(demands, demand_path_length, demand_path_node,
        demand_path_link, demand_on_link) = demand_tuple;

    // Create a shuffled demand list
    size_t n_demands = demands.size();
    Row_int demand_order(n_demands);
    iota(begin(demand_order), end(demand_order), 0);
    shuffle(demand_order.begin(), demand_order.end(), generator);

    // Initialize variables
    // record blocking rate
    Row_double blocking_history(n_demands, 0);
    // frequency slot availability, true means available
    Matrix_sc freq_slot_avail(n_links, Row_sc(FREQUENCY_MAX, 1));
    // allocation of demands
    Row_nodepair demand_allocation(n_demands);
    // noise per demand per link
    Matrix_double noise_per_demand_link(n_demands, Row_double(n_links, 0));
    int block_spectrum(0), block_noise(0), block_total(0);

    // Allocate demands one by one
    for (size_t i = 0; i < n_demands; ++i){
        int demand_id = demand_order[i];
        Row_int link_used = demand_path_link[demand_id];

        // Find available frequency slots
        Row_sc tmp_avail(FREQUENCY_MAX, 1);
        for (size_t j = 0; j < link_used.size(); ++j)
            for (long int k = 0; k < FREQUENCY_MAX; ++k)
                tmp_avail[k] = tmp_avail[k] *
                    freq_slot_avail[link_used[j]][k];
        // Find the first running ones
        int n_slots = ceil((get<2>(demands[demand_id])+GUARDBAND)/SLOT_SIZE);
        long int sequence_start = find_first_avail_slot(tmp_avail, n_slots);
        // Spectrum block
        if (sequence_start == -1) {
            block_spectrum++;
            block_total++;
            blocking_history[i] = block_total / i;
            continue;
        }
        bool block_flag = check_noise_block(demand_id, sequence_start,
            demand_allocation, noise_per_demand_link);
        // Successfully allocate one demand
        if (!block_flag){
            for (size_t j = 0; j < link_used.size(); ++j)
                fill(freq_slot_avail[link_used[j]].begin()+sequence_start,
                     freq_slot_avail[link_used[j]].begin()+sequence_start+n_slots, 0);
        }
        else{
            block_noise++;
            block_total++;
            blocking_history[i] = block_total / i;
        }
    }

}

#endif // SIMUBP_H_INCLUDED
