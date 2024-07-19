# Downloading source code
if [ ! -d ../miniqmc ] ; then
  git clone -b OMP_offload https://github.com/QMCPACK/miniqmc.git ../miniqmc
fi
# Setting the environment
module use /soft/modulefiles
module use /soft/packaging/spack-builds/modules/linux-opensuse_leap15-x86_64
module load cmake/3.28.3 public_mkl/2019 llvm/release-18.1.0 cuda/12.3.0 openmpi/4.1.1-llvm
module list > module.list
# Compiling the code
build_folder=build_h100_clang18_offload_real_MP
cmake -B $build_folder -DCMAKE_CXX_COMPILER=mpicxx -DQMC_MPI=ON -DQMC_ENABLE_CUDA=ON -DENABLE_OFFLOAD=ON -DQMC_GPU_ARCHS=sm_90 -DQMC_MIXED_PRECISION=ON ../miniqmc
cd $build_folder && make -j32 miniqmc_sync_move && cd ..
# Running the code
export VENDOR=NVIDIA
export OMP_NUM_THREADS=8
export OMP_PLACES=cores
export OMP_PROC_BIND=close
for series in `seq 1 5`
do
  mpirun -n 1 --map-by ppr:4:node:PE=24 ../../gpu_tile_compact.sh $build_folder/bin/miniqmc_sync_move -P -g "2 2 1" -w 320 -n 1 > h100_r1_t8.s$series.out
  mpirun -n 4 --map-by ppr:4:node:PE=24 ../../gpu_tile_compact.sh $build_folder/bin/miniqmc_sync_move -P -g "2 2 1" -w 320 -n 1 > h100_r4_t8.s$series.out
done
# Extracting the FOM value
grep "Diffusion throughput" h100_r?_t8.s?.out
