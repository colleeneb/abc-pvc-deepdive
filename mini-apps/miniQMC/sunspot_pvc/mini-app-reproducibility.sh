# Downloading source code
if [ ! -d ../miniqmc ] ; then
  git clone -b OMP_offload https://github.com/QMCPACK/miniqmc.git ../miniqmc
fi
# Setting the environment
module load oneapi/release/2024.1
module list >& module.list
# Compiling the code
build_folder=build_pvc_oneapi_offload_real_MP
cmake -B $build_folder -DCMAKE_CXX_COMPILER=mpicxx -DQMC_MPI=ON -DQMC_ENABLE_SYCL=ON -DENABLE_OFFLOAD=ON -DQMC_MIXED_PRECISION=ON ../miniqmc
cd $build_folder && make -j32 miniqmc_sync_move && cd ..
# Running the code

export MPIR_CVAR_ENABLE_GPU=0
unset MPIR_CVAR_CH4_COLL_SELECTION_TUNING_JSON_FILE
unset MPIR_CVAR_COLL_SELECTION_TUNING_JSON_FILE
unset MPIR_CVAR_CH4_POSIX_COLL_SELECTION_TUNING_JSON_FILE
export FI_CXI_DEFAULT_CQ_SIZE=131072
export FI_CXI_CQ_FILL_PERCENT=20

export LIBOMP_USE_HIDDEN_HELPER_TASK=0
export ZES_ENABLE_SYSMAN=1
#export LIBOMPTARGET_DEBUG=1

#export ZE_AFFINITY_MASK=0.0 if running on 1 tile only
export ZE_FLAT_DEVICE_HIERARCHY=COMPOSITE
export NEOReadDebugKeys=1
export EnableRecoverablePageFaults=0
export SplitBcsCopy=0
#export PrintDebugSettings=1

NNODES=`wc -l < $PBS_NODEFILE`
NRANKS=12          # Number of MPI ranks per node
NDEPTH=8          # Number of hardware threads per rank, spacing between MPI ranks on a node

NTOTRANKS=$(( NNODES * NRANKS ))
echo "NUM_NODES=${NNODES}  TOTAL_RANKS=${NTOTRANKS}  RANKS_PER_NODE=${NRANKS}  THREADS_PER_RANK=${OMP_NUM_THREADS}"

export OMP_NUM_THREADS=8
CPU_BIND=list:1-8:9-16:17-24:25-32:33-40:41-48:53-60:61-68:69-76:77-84:85-92:93-100
CPU_BIND_VERBOSE=verbose,$CPU_BIND
export VENDOR=INTEL

for series in `seq 1 5`
do
  mpiexec -np 1 -ppn ${NRANKS} -d ${NDEPTH} --cpu-bind $CPU_BIND ../../gpu_tile_compact.sh $build_folder/bin/miniqmc_sync_move -P -g "2 2 1" -w 320 -n 1 > pvc_r1_t8.s$series.out
  mpiexec -np 2 -ppn ${NRANKS} -d ${NDEPTH} --cpu-bind $CPU_BIND ../../gpu_tile_compact.sh $build_folder/bin/miniqmc_sync_move -P -g "2 2 1" -w 320 -n 1 > pvc_r2_t8.s$series.out
  mpiexec -np 6 -ppn ${NRANKS} -d ${NDEPTH} --cpu-bind $CPU_BIND ../../gpu_tile_compact.sh $build_folder/bin/miniqmc_sync_move -P -g "2 2 1" -w 320 -n 1 > pvc_r6_t8.s$series.out
  mpiexec -np 12 -ppn ${NRANKS} -d ${NDEPTH} --cpu-bind $CPU_BIND ../../gpu_tile_compact.sh $build_folder/bin/miniqmc_sync_move -P -g "2 2 1" -w 320 -n 1 > pvc_r12_t8.s$series.out
done

# Extracting the FOM value
grep "Diffusion throughput" *_r*_t8.s?.out
