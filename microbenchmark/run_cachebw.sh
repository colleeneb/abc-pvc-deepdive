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
case "$1" in
dawn)
  source ../environment/dawn.env
  export ONEAPI_DEVICE_SELECTOR=level_zero:0.0
  ;;
*) echo "Unknown System" && exit ;;
esac

# Compiling the code
cd $BASE/cachebw
sed -i 's/SHMEM=1/SHMEM=0/g' Makefile
make

# Running the code
cd $BASE/cachebw
./benchmark.sh -n 14 -r 1000 | tee results/$1.txt

# Compiling the code
cd $BASE/cachebw
sed -i 's/SHMEM=0/SHMEM=1/g' Makefile
make

# Running the code
cd $BASE/cachebw
./benchmark.sh -n 7 -r 1000 | tee results/$1-shmem.txt

# Extracting the results
cd $BASE/cachebw
cat results/$1.txt
echo \n
cat results/$1-shmem.txt

