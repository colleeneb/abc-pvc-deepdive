#!/usr/bin/env bash

set -eu
BASE=$PWD

# Downloading source code
if [ ! -d cachebw ]; then
  if ! git clone -b pvc-deepdive https://github.com/UoB-HPC/cachebw; then
    echo "\n Failed to fetch source code. \n"
    exit 1
  fi
fi

# Setting the environment
source $BASE/../environment/$1.env tile

# Compiling the code
cd $BASE/cachebw

if [ "$VENDOR" = "INTEL" ]; then
  export COMPILER="INTEL"
  export MODEL="USM"
elif [ "$VENDOR" = "NVIDIA" ]; then
  export COMPILER=$VENDOR
elif [ "$VENDOR" = "AMD" ]; then
  export COMPILER=$VENDOR
  export HIPOPTS="--offload-arch=gfx90a --gcc-toolchain=/soft/compilers/gcc/12.2.0/x86_64-suse-linux/"
else
  echo "VENDOR variable is either unset or not set to INTEL/NVIDIA/AMD"
fi

SHMEM=0 make

# Running the code
cd $BASE/cachebw
$BASE/gpu_tile_compact.sh ./benchmark.sh -n 14 -r 1000 | tee results/$1.txt

# Compiling the code
cd $BASE/cachebw
SHMEM=1 make

# Running the code
cd $BASE/cachebw
$BASE/gpu_tile_compact.sh ./benchmark.sh -n 7 -r 1000 | tee results/$1-shmem.txt

# Extracting the results
#cd $BASE/cachebw
#cat results/$1.txt
#echo \n
#cat results/$1-shmem.txt

