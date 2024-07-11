#!/usr/bin/env bash

set -eu
BASE=$PWD

# Downloading source code
if [ ! -d lats ]; then
  if ! git clone -b pvc-deepdive https://github.com/UoB-HPC/lats; then
    echo "\n Failed to fetch source code. \n"
    exit 1
  fi
fi

# Setting the environment
source $BASE/../environment/$1.env tile

# Compiling the code
cd $BASE/lats
make sycl-usm

# Running the code
cd $BASE/lats
$BASE/gpu_tile_compact.sh ./run.sycl

# Extracting the results
cd $BASE/lats
cat lat.csv

