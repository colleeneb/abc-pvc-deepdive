#!/usr/bin/env bash

num_gpu=8

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

gpu_id=$((_MPI_RANKID % num_gpu))

# Node 1, 3 are HBM
#num_gpu_per_socket=$((num_gpu / num_socket))
#numa_id=$((1+ gpu_id / num_gpu_per_socket))

# If needed for some applications
export RANK=$_MPI_RANKID

export HIP_VISIBLE_DEVICES=$gpu_id
#https://stackoverflow.com/a/28099707/7674852
#numactl -p $numa_id "$@"
"$@"
