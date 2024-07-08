#!/usr/bin/env bash

set -eu
BASE="$PWD"
BM=256 # Problem size to run on one tile (required for scaling)

# Downloading source code
if [ ! -e cloverleaf/CMakeLists.txt ]; then
  if ! git clone -b pvc-performance-portability https://github.com/UoB-HPC/cloverleaf; then
    echo "\n Failed to fetch source code. \n"
    exit 1
  fi
fi

# Setting the environment
source $BASE/../../environment/$1.env $2

# Compiling the code
cd "$BASE/cloverleaf"

CMAKE_OPTS+="-DCMAKE_VERBOSE_MAKEFILE=ON -DENABLE_PROFILING=OFF "
CMAKE_OPTS+="-DENABLE_MPI=ON "

if [ "$VENDOR" = "INTEL" ]; then
  MODEL="sycl-usm"
  CMAKE_OPTS+="-DSYCL_COMPILER=ONEAPI-ICPX "
elif [ "$VENDOR" = "NVIDIA" ]; then
  MODEL="cuda"
  CMAKE_OPTS+="-DCMAKE_CUDA_COMPILER=$(which nvcc) "
  CMAKE_OPTS+="-DCUDA_ARCH=$ARCH "
  CMAKE_OPTS+="-DCMAKE_C_COMPILER=nvc "
  CMAKE_OPTS+="-DCMAKE_CXX_COMPILER=nvc++ "
elif [ "$VENDOR" = "AMD" ]; then
  echo "The vendor is AMD."
else
  echo "VENDOR variable is either unset or not set to INTEL/NVIDIA/AMD"
fi

CMAKE_OPTS+="-DMODEL=$MODEL "
BENCHMARK_EXE="$MODEL-cloverleaf"

rm -rf build
rm -rf results

cmake -Bbuild -H. -DCMAKE_BUILD_TYPE=RELEASE $CMAKE_OPTS
cmake --build build --config RELEASE -j "$NCPUS"
ldd "$BASE/cloverleaf/build/$BENCHMARK_EXE"

# Running the code

if [[ "$(mpiexec --version)" =~ "Intel(R) MPI" ]]; then
  gpu_launch_prelude='export SELECTED_DEVICE=$(($MPI_LOCALRANKID % $NP)) && echo "# SELECTED_DEVICE=$SELECTED_DEVICE"'
elif [[ "$(mpiexec --version)" =~ "Open MPI" ]]; then
  gpu_launch_prelude='export SELECTED_DEVICE=$(($OMPI_COMM_WORLD_LOCAL_RANK % $NP)) && echo "# SELECTED_DEVICE=$SELECTED_DEVICE"'
elif [[ "$(mpiexec --version)" =~ "mpich" ]]; then
  gpu_launch_prelude='export SELECTED_DEVICE=$(($MPI_LOCALRANKID % $NP)) && echo "# SELECTED_DEVICE=$SELECTED_DEVICE"'
else
  echo Cannot recognise the MPI Vendor
fi

RUN() {
  cd "$BASE/cloverleaf"
  mkdir -p results
  BENCHMARK_EXE="$PWD/build/$MODEL-cloverleaf"

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
      echo "$gpu_launch_prelude && $2"
  }

  cd "$BASE/cloverleaf/results"
  (
    set -o xtrace
    #export OMP_NUM_THREADS=$NCPUS
    export OMP_PROC_BIND=true
    export OMP_PLACES=cores
    echo ">>> Using 1R/N $NP"
    $MPICOMMAND -launcher ssh\
      sh -c "$(create_command node "$BENCHMARK_EXE --file $DECK --out $PWD/cloverleaf_np${NP}_${1}_stage_$2.out --staging-buffer $2 $opts")"

  )
}

bm=$(($BM * $NP))
RUN $bm true

# Extracting the FOM value
cd "$BASE/cloverleaf/results"
echo $bm $(cat cloverleaf_np"$NP"_"$bm"_stage_true.out | grep "Wall clock" | tail -n 1 | awk '{ print $3 }') >> $BASE/$1-$2.fom
