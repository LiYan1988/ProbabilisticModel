#include <iostream>
#include "simubp.h"
using namespace std;

int main()
{
    n_regens = 13;

    // benchmark
    string algorithm = "benchmark_Bathula_MD_opt";
    load_simulation_parameters(algorithm);

//    string algorithm = "proposed_Yan_MD_RC";
//    load_simulation_parameters(algorithm);

    // Generate traffic demands
    Matrix_int demands_per_pair(n_nodes, Row_int(n_nodes, 5));
    Matrix_double bandwidth_mean(n_nodes, Row_double(n_nodes, 150));
    Matrix_double bandwidth_std(n_nodes, Row_double(n_nodes, 20));
    Demand x = generate_demands(demands_per_pair, bandwidth_mean,
        bandwidth_std);

    Row_double blocking_history = simulate_blocking(x);
//
    write_csv_vec("bp_bathula_opt_.csv", blocking_history, false);

//    write_csv_vec("bp_yan_RC.csv", blocking_history, false);

//    Row_nodepair demands;
//    Row_double demand_path_length;
//    Matrix_int demand_path_node, demand_path_link, demand_on_link;
//    tie(demands, demand_path_length, demand_path_node,
//        demand_path_link, demand_on_link) = x;
//    write_demands("demands.csv", demands);

    return 0;
}
