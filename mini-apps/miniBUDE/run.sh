#!/usr/bin/env bash

set -eu
BASE="$PWD"
BM=bm1

# Downloading source code
if [ ! -e minibude/CMakeLists.txt ]; then
  if ! git clone -b v2 https://github.com/UoB-HPC/minibude; then
    echo "\n Failed to fetch source code. \n"
    exit 1
  fi
fi

# Setting the environment
case "$1" in
dawn)
  source $BASE/../../environment/dawn.env
  export ONEAPI_DEVICE_SELECTOR=level_zero:0.0 
  ;;
*) echo "Unknown System" && exit ;;
esac

# Compiling the code
cd "$BASE/minibude"

CMAKE_OPTS+="-DCMAKE_VERBOSE_MAKEFILE=ON "

if [ "$VENDOR" = "INTEL" ]; then
  MODEL="sycl"
  CMAKE_OPTS+="-DSYCL_COMPILER=ONEAPI-ICPX "
elif [ "$VENDOR" = "NVIDIA" ]; then
  MODEL="cuda"
  CMAKE_OPTS+="-DCMAKE_CUDA_COMPILER=$(which nvcc) "
  CMAKE_OPTS+="-DCUDA_ARCH=$ARCH "
  CMAKE_OPTS+="-DCMAKE_CXX_COMPILER=nvc++ "
elif [ "$VENDOR" = "AMD" ]; then
  echo "The vendor is AMD."
else
  echo "VENDOR variable is either unset or not set to INTEL/NVIDIA/AMD"
fi

CMAKE_OPTS+="-DMODEL=$MODEL "
BENCHMARK_EXE="$MODEL-bude"


rm -rf build

cmake -Bbuild -H. -DCMAKE_BUILD_TYPE=RELEASE $CMAKE_OPTS
cmake --build build --config RELEASE -j "$NCPUS"
ldd "$BASE/minibude/build/$BENCHMARK_EXE"

# Running the code
OUT=$BASE/$MODEL-bude-$BM.out

RUN() {
  cd "$BASE/minibude"
  mkdir -p results
  BENCHMARK_EXE="$PWD/build/$MODEL-bude"
  DECK="$PWD/data/$1"

  cd "$BASE"
  $BENCHMARK_EXE --deck $DECK --wgsize 4,8,16,32,64,128,256,512,1024 --ppwi 1,2,4,8,16,32,64 --csv | tee $OUT
}

RUN $BM

# FOM
cd $BASE
best=$(tail -n1 $OUT)
ppwi=$(echo "$best" | grep -oP '(?<=ppwi: )\d+')
wgsize=$(echo "$best" | grep -oP '(?<=wgsize: )\d+')
echo ========================================
echo best gflops/s = $(echo $(grep "^$ppwi,$wgsize" $OUT) | awk -F',' '{print $9}')
echo ========================================

