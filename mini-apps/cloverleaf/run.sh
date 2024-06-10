#!/usr/bin/env bash

set -eu
BASE="$PWD"

# Downloading source code
if [ ! -e cloverleaf/CMakeLists.txt ]; then
  if ! git clone -b pvc-performance-portability https://github.com/UoB-HPC/cloverleaf; then
    echo "\n Failed to fetch source code. \n"
    exit 1
  fi
fi

# Setting the environment
case "$1" in
dawn)
  source dawn.env
  case "$2" in
  tile)
    export ONEAPI_DEVICE_SELECTOR=level_zero:0.0
    export NP=1
    ;;
  gpu)
    export ONEAPI_DEVICE_SELECTOR=level_zero:0.0,0.1
    export NP=2
    ;;
  node)
    export ONEAPI_DEVICE_SELECTOR=level_zero:0.0,0.1,1.0,1.1,2.0,2.1,3.0,3.1
    export NP=8
    ;;
  esac
  ;;
*) echo "Unknown System" && exit ;;
esac

# Compiling the code
cd "$BASE/cloverleaf"

CMAKE_OPTS+="-DCMAKE_VERBOSE_MAKEFILE=ON -DENABLE_PROFILING=ON "
CMAKE_OPTS+="-DENABLE_MPI=ON "
CMAKE_OPTS+="-DMODEL=sycl-usm "
CMAKE_OPTS+="-DSYCL_COMPILER=ONEAPI-ICPX "
BENCHMARK_EXE="sycl-usm-cloverleaf"


rm -rf build
rm -rf results

cmake -Bbuild -H. -DCMAKE_BUILD_TYPE=RELEASE $CMAKE_OPTS
cmake --build build --config RELEASE -j "$NCPUS"
ldd "$BASE/cloverleaf/build/$BENCHMARK_EXE"

# Running the code

RUN() {
  cd "$BASE/cloverleaf"
  mkdir -p results
  BENCHMARK_EXE="$PWD/build/sycl-usm-cloverleaf"

  export I_MPI_PORT_RANGE=50000:50500
  export btl_tcp_port_min_v4=1024
  export I_MPI_DEBUG=3
  export I_MPI_OFFLOAD_PIN=0 # we do this by hand
  export I_MPI_OFFLOAD=1
  export I_MPI_OFFLOAD_RDMA=1
  export I_MPI_OFFLOAD_IPC=0 # TODO this needs CAP_SYS_PTRACE

  opts='--device $SELECTED_DEVICE'
  DECK="$PWD/InputDecks/clover_bm$1.in"

  echo "master=$(hostname) nproc=$NCPUS"
  echo "mpicc=$(which mpiexec)"
  echo "PWD=$PWD"
  echo "NP=$NP"
  echo "BENCHMARK_EXE=$BENCHMARK_EXE"
  echo "DECK=$DECK"
  echo "======"

  function create_command() {
      gpu_launch_prelude='export SELECTED_DEVICE=$(($MPI_LOCALRANKID % $NP)) && echo "# SELECTED_DEVICE=$SELECTED_DEVICE"'
      echo "$gpu_launch_prelude && $2"
  }

  cd "$BASE/cloverleaf/results"
  (
    set -o xtrace
    export OMP_NUM_THREADS=$NCPUS
    export OMP_PROC_BIND=true
    export OMP_PLACES=cores
    echo ">>> Using 1R/N $NP"
    mpiexec -launcher ssh -np "$NP" -map-by core -bind-to core \
      sh -c "$(create_command node "$BENCHMARK_EXE --file $DECK --out $PWD/cloverleaf_np${NP}_sycl-usm_${1}_stage_$2.out --staging-buffer $2 $opts")"

  )
}

case "$2" in
  tile)
    for bm in 4 8 16 32 64; do
      RUN $bm true
    done
    ;;
  gpu)
    for bm in 4 8 16 32 64 128; do
      RUN $bm true
    done
    ;;
  node)
    for bm in 4 8 16 32 64 128 256 512; do
      RUN $bm true
    done
    ;;
esac

# Extracting the FOM value
cd "$BASE/cloverleaf/results"

case "$2" in
  tile)
    for bm in 4 8 16 32 64; do
      echo $bm $(cat cloverleaf_np"$NP"_sycl-usm_"$bm"_stage_true.out | grep "Wall clock" | tail -n 1 | awk '{ print $3 }') >> $BASE/$1-$2.fom
    done
    ;;
  gpu)
    for bm in 4 8 16 32 64 128; do
      echo $bm $(cat cloverleaf_np"$NP"_sycl-usm_"$bm"_stage_true.out | grep "Wall clock" | tail -n 1 | awk '{ print $3 }') >> $BASE/$1-$2.fom
    done
    ;;
  node)
    for bm in 4 8 16 32 64 128 256 512; do
      echo $bm $(cat cloverleaf_np"$NP"_sycl-usm_"$bm"_stage_true.out | grep "Wall clock" | tail -n 1 | awk '{ print $3 }') >> $BASE/$1-$2.fom
    done
    ;;
esac

