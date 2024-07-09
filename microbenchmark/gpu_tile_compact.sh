#!/usr/bin/env bash

num_gpu=6
num_tile=2
num_socket=2

# Get the RankID from different launcher                                                                                                                                                                                    
if [[ -v MPI_LOCALRANKID ]]; then
  _MPI_RANKID=$MPI_LOCALRANKID
elif [[ -v PALS_LOCAL_RANKID ]]; then
  _MPI_RANKID=$PALS_LOCAL_RANKID
elif [[ -v OMPI_COMM_WORLD_LOCAL_RANK ]]; then
  _MPI_RANKID=$OMPI_COMM_WORLD_LOCAL_RANK
else
  echo "Unknown MPI, adjust this script."
fi

gpu_id=$((_MPI_RANKID / num_tile))
tile_id=$((_MPI_RANKID % num_tile))

# Node 1, 3 are HBM
#num_gpu_per_socket=$((num_gpu / num_socket))
#numa_id=$((1+ gpu_id / num_gpu_per_socket))

# If needed for some applications
export RANK=$_MPI_RANKID

export ZE_ENABLE_PCI_ID_DEVICE_ORDER=1
export ONEAPI_DEVICE_SELECTOR=level_zero:gpu
export ZE_FLAT_DEVICE_HIERARCHY=COMPOSITE
export ZE_AFFINITY_MASK=$gpu_id.$tile_id
#export ONEAPI_DEVICE_SELECTOR=level_zero:$gpu_id.$tile_id
#https://stackoverflow.com/a/28099707/7674852
#numactl -p $numa_id "$@"
"$@"
