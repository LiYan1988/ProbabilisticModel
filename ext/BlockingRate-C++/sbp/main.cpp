#include <iostream>
#include "simubp.h"
using namespace std;

int main()
{
////  Read csv
//    Matrix_double mat;
//    int n_rows;
//    Row_int n_cols;
//    tuple <Matrix_double, int, Row_int> result;
//    result = read_csv("CoronetCostMatrix.csv");
//    tie(mat, n_rows, n_cols) = result;
//
////  Write csv
//    for(int i=0; i<n_rows; ++i){
//        for(size_t j=0; j<mat[i].size(); ++j){
//            mat[i][j]++;
//        }
//    write_csv("test2.csv", mat);
//    }

////  Calculate noise on link
//    Row_double demand_data_rates{1, 1, 1};
//    Row_double demand_frequencies{1, 3, 5};
//    double n_spans(20);
//    Matrix_double x=calculate_noise(demand_data_rates, demand_frequencies, n_spans);
//    write_csv("test2.csv", x);

////  Load cost matrix

////  Check blockage due to noise
//    check_noise_block();

//  Load parameters
//    n_regens = 10;
//    string algorithm = "benchmark_Bathula_MD_subopt";
//    load_simulation_parameters(algorithm);
//    for(size_t i=0; i<regen_list.size(); ++i){
//        cout<<regen_list[i]<<endl;
//    }
//    cout<<n_regens<<endl;
//// Test construction of connection list
//    for(size_t i=0; i<coronet_connection.size(); ++i){
//        cout<<coronet_connection[i].size()<<endl;
//    }

//// Test generate_demands
//    Matrix_int demands_per_pair;
//    Matrix_double bandwidth_mean, bandwidth_std;
//    n_nodes = 75;
//    Row_int tmp_demands;
//    Row_double tmp_mean, tmp_std;
//    for(int i=0; i<n_nodes; ++i){
//        for(int j=0; j<n_nodes; ++j){
//            tmp_demands.push_back(2);
//            tmp_mean.push_back(200);
//            tmp_std.push_back(30);
//        }
//        demands_per_pair.push_back(tmp_demands);
//        bandwidth_mean.push_back(tmp_mean);
//        bandwidth_std.push_back(tmp_std);
//    }
//    Row_nodepair demands = generate_demands(demands_per_pair,
//        bandwidth_mean, bandwidth_std);
//    for(size_t i=0; i<demands.size(); ++i){
//        cout<<get<0>(demands[i])<<", "<<get<1>(demands[i])
//            <<": "<<get<2>(demands[i])<<endl;
//    }

// Prepare simulation parameters
    n_regens = 10;
    string algorithm = "benchmark_Bathula_MD_subopt";

    // Load parameters
    load_simulation_parameters(algorithm);

    // Generate traffic demands
    Matrix_int demands_per_pair(n_nodes, Row_int(n_nodes, 1));
    Matrix_double bandwidth_mean(n_nodes, Row_double(n_nodes, 150));
    Matrix_double bandwidth_std(n_nodes, Row_double(n_nodes, 20));
//    Row_nodepair demands = generate_demands(demands_per_pair,
//        bandwidth_mean, bandwidth_std);
    tuple<Row_nodepair, Row_double, Matrix_int, Matrix_int, Matrix_int>
        x = generate_demands(demands_per_pair, bandwidth_mean, bandwidth_std);
    simulate_blocking(x);

//    Row_nodepair demands;
//    Row_double demand_path_length;
//    Matrix_int demand_path_node, demand_path_link, demand_on_link;
//    tie(demands, demand_path_length, demand_path_node,
//        demand_path_link, demand_on_link) = x;
//    write_csv("test2.csv", demand_path_node);
//    write_csv("test3.csv", demand_path_link);
//    write_csv("test4.csv", demand_on_link);


//    // Calculate shortest paths and lengths for all pairs
//    Matrix_path apsp = all_pair_shortest_path();
//    Matrix_int apsp_paths;
//    Matrix_double apsp_length;
//    for(int i = 0; i < n_nodes; ++i){
//        Row_double tmp;
//        for(int j = 0; j < n_nodes; ++j){
//            tmp.push_back(get<2>(apsp[i][j]));
//            if (i == j) continue;
//            apsp_paths.push_back(get<3>(apsp[i][j]));
//        }
//        apsp_length.push_back(tmp);
//    }
//    write_csv("APSP_path.csv", apsp_paths);
//    write_csv("APSP_length.csv", apsp_length);

    // Calculate the set of nodes and links used by each demand
//    Matrix_int demand_node;
//    Matrix_nodepair demand_link;
//    int src, dst;
//    Row_int tmp_path;
//    Row_nodepair tmp_link;
//    for (size_t i = 0; i < demands.size(); ++i){
//        src = get<0>(demands[i]);
//        dst = get<1>(demands[i]);
//        tmp_path = get<3>(spap[src][dst]);
//        demand_node.push_back(tmp_path);
//        for (size_t j = 0; j < tmp_path.size()-1; ++j){
//            tmp_link.push_back(make_tuple(tmp_path[j],
//                tmp_path[j+1], 0));
//        }
//        demand_link.push_back(tmp_link);
//    }
//    cout<<get<0>(demand_link[0][0])<<endl;
//    cout<<get<1>(demand_link[0][0])<<endl;
//    cout<<get<2>(demand_link[0][0])<<endl;
//    // Calculate demands on each link
//    Row_int x = demand_on_link(10, 1, demand_link);
    return 0;
}
