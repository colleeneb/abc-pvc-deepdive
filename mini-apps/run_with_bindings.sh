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
    mpiexec -n 1 --cpu-bind verbose,list:0-11:12-23:24-35:36-47:48-59:60-71:72-83:84-95  -- ../microbenchmark/gpu_tile_compact.sh $executable
    echo "Running on a half-node on Dawn"
    mpiexec -n 4 --cpu-bind verbose,list:0-11:12-23:24-35:36-47:48-59:60-71:72-83:84-95 -- ../microbenchmark/gpu_tile_compact.sh $executable
    echo "Running on a full node on Dawn"
    mpiexec -n 8 --cpu-bind verbose,list:0-11:12-23:24-35:36-47:48-59:60-71:72-83:84-95 -- ../microbenchmark/gpu_tile_compact.sh $executable
else
    echo "The system name (first argument to the script) must be Dawn or Aurora"
fi
