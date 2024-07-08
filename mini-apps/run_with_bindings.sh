#!/bin/bash -x

if [ "$#" -lt "2" ]
then
    echo "Need to provide at least 2 inputs, first is the name of the system (either Dawn or Aurora)"
    echo "and after is the executable and any arguments"
    echo "Usage: $0 Dawn name_of_exe exe_args"
    echo "  This launches the name_of_exe on a single tile, half-node"
    echo ",  with the cpu bindings for Dawn"
  exit 1
fi

executable="${@:2}"

export ZE_FLAT_DEVICE_HIERARCHY=COMPOSITE

if [[ "$1" == "Aurora" ]]; then
    echo "Running on a single tile on Aurora"
    mpiexec -n 1 --cpu-bind verbose,list:1-8:9-16:17-24:25-32:33-40:41-48:52-59:60-67:68-75:76-83:84-91:92-99 -- ../microbenchmark/gpu_tile_compact.sh $executable
    echo "Running on a half-node on Aurora"
    mpiexec -n 6 --cpu-bind verbose,list:1-8:9-16:17-24:25-32:33-40:41-48:52-59:60-67:68-75:76-83:84-91:92-99 -- ../microbenchmark/gpu_tile_compact.sh $executable
    echo "Running on a full node on Aurora"
    mpiexec -n 12 --cpu-bind verbose,list:1-8:9-16:17-24:25-32:33-40:41-48:52-59:60-67:68-75:76-83:84-91:92-99 -- ../microbenchmark/gpu_tile_compact.sh $executable
elif [[ "$1" == "Dawn" ]]; then
    echo "Running on a single tile on Dawn"
    mpiexec -n 1 --cpu-bind verbose,list:0,2,4,6,8,10,12,14,16,18,20,22:24,26,28,30,32,34,36,38,40,42,44,46:48,50,52,54,56,58,60,62,64,66,68,70:72,74,76,78,80,82,84,86,88,90,92.94:1,3,5,7,9,11,13,15,17,19,21,23:25,27,29,31,33,35,37,39,41,43,45,47:49,51,53,55,57,59,61,63,65,67,69,71:73,75,77,79,81,83,85,87.89,91,93,95  -- ../microbenchmark/gpu_tile_compact.sh $executable
    echo "Running on a half-node on Dawn"
    mpiexec -n 4 --cpu-bind verbose,list:0,2,4,6,8,10,12,14,16,18,20,22:24,26,28,30,32,34,36,38,40,42,44,46:48,50,52,54,56,58,60,62,64,66,68,70:72,74,76,78,80,82,84,86,88,90,92.94:1,3,5,7,9,11,13,15,17,19,21,23:25,27,29,31,33,35,37,39,41,43,45,47:49,51,53,55,57,59,61,63,65,67,69,71:73,75,77,79,81,83,85,87.89,91,93,95 -- ../microbenchmark/gpu_tile_compact.sh $executable
    echo "Running on a full node on Dawn"
    mpiexec -n 8 --cpu-bind verbose,list:0,2,4,6,8,10,12,14,16,18,20,22:24,26,28,30,32,34,36,38,40,42,44,46:48,50,52,54,56,58,60,62,64,66,68,70:72,74,76,78,80,82,84,86,88,90,92.94:1,3,5,7,9,11,13,15,17,19,21,23:25,27,29,31,33,35,37,39,41,43,45,47:49,51,53,55,57,59,61,63,65,67,69,71:73,75,77,79,81,83,85,87.89,91,93,95 -- ../microbenchmark/gpu_tile_compact.sh $executable
else
    echo "The system name (first argument to the script) must be Dawn or Aurora"
fi
