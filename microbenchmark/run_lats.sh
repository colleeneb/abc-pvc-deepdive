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
if [ "$VENDOR" = "INTEL" ]; then
  MODEL="sycl-usm"
elif [ "$VENDOR" = "NVIDIA" ]; then
  MODEL="cuda"
elif [ "$VENDOR" = "AMD" ]; then
  MODEL="hip"
  export HIPOPTS="--offload-arch=gfx90a;--gcc-toolchain=/soft/compilers/gcc/12.2.0/x86_64-suse-linux/"
else
  echo "VENDOR variable is either unset or not set to INTEL/NVIDIA/AMD"
fi

cd $BASE/lats
make $MODEL

# Running the code
cd $BASE/lats
$BASE/gpu_tile_compact.sh ./run.sycl

# Extracting the results
cd $BASE/lats
cat lat.csv

