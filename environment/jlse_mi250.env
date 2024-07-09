#!/usr/bin/env bash

# Setting up the compilers
module load rocm/6.0.0 cmake/3.28.3 gcc/12.2.0 openmpi/4.1.1-gcc
module list

export MPIEXEC="mpirun"
export MPIBINDINGS="-report-bindings --map-by node:PE=16"

case "$1" in
gcd)
  export NP=1
  ;;
gpu)
  export NP=2
  ;;
half-node)
  export NP=4
  ;;
node)
  export NP=8
  ;;
nompi)
  export NP=8
  ;;
*)
  echo Select one of gcd/gpu/node/half-node
  exit
esac

# MPI
export MPICOMMAND="$MPIEXEC -n $NP $MPIBINDINGS"


# Vendor          
export VENDOR=AMD

# # --offload-arch=gfx90a
export ARCH=gfx90a

# Additional configuration
export NCPUS=$(nproc --all)
