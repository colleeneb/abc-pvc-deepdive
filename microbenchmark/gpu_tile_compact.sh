#!/usr/bin/env bash

num_gpu=6
num_tile=2
num_socket=2

_MPI_RANKID=$PALS_LOCAL_RANKID
gpu_id=$((_MPI_RANKID / num_tile))
tile_id=$((_MPI_RANKID % num_tile))

# Node 1, 3 are HBM
#num_gpu_per_socket=$((num_gpu / num_socket))
#numa_id=$((1+ gpu_id / num_gpu_per_socket))

export ZE_ENABLE_PCI_ID_DEVICE_ORDER=1
export ZE_AFFINITY_MASK=$gpu_id.$tile_id
#export ONEAPI_DEVICE_SELECTOR=level_zero:$gpu_id.$tile_id
#https://stackoverflow.com/a/28099707/7674852
#numactl -p $numa_id "$@"
"$@"
