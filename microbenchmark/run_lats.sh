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
case "$1" in
dawn)
  source ../environment/dawn.env
  export ONEAPI_DEVICE_SELECTOR=level_zero:0.0
  ;;
*) echo "Unknown System" && exit ;;
esac

# Compiling the code
cd $BASE/lats
make sycl-usm

# Running the code
cd $BASE/lats
./run.sycl

# Extracting the results
cd $BASE/lats
cat lat.csv

