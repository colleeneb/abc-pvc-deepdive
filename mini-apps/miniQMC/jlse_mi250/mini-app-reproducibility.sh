# Downloading source code
if [ ! -d ../miniqmc ] ; then
  git clone -b OMP_offload https://github.com/QMCPACK/miniqmc.git ../miniqmc
fi
# Setting the environment
module use /soft/modulefiles
module use /soft/packaging/spack-builds/modules/linux-opensuse_leap15-x86_64
module load cmake/3.28.3 public_mkl/2019 aomp/rocm-6.1.0 rocm/6.1.0 openmpi/4.1.1-llvm
module list >& module.list
# Compiling the code
build_folder=build_mi250_rocm610_offload_real_MP
cmake -B $build_folder -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_CXX_FLAGS="--gcc-toolchain=/soft/compilers/gcc/12.2.0/x86_64-suse-linux" -DQMC_MPI=ON -DQMC_ENABLE_ROCM=ON -DENABLE_OFFLOAD=ON -DQMC_GPU_ARCHS=gfx90a -DQMC_MIXED_PRECISION=ON ../miniqmc
cd $build_folder && make -j32 miniqmc_sync_move && cd ..
# Running the code
export VENDOR=AMD
export OMP_NUM_THREADS=1
export OMP_PLACES=cores
export OMP_PROC_BIND=close
export MKL_DEBUG_CPU_TYPE=5
for series in `seq 1 5`
do
  mpirun -n 1 --map-by ppr:8:node:PE=16 ../../gpu_tile_compact.sh $build_folder/bin/miniqmc_sync_move -P -g "2 2 1" -w 320 -n 1 > mi250_r1_t8.s$series.out
  mpirun -n 2 --map-by ppr:8:node:PE=16 ../../gpu_tile_compact.sh $build_folder/bin/miniqmc_sync_move -P -g "2 2 1" -w 320 -n 1 > mi250_r2_t8.s$series.out
  mpirun -n 8 --map-by ppr:8:node:PE=16 ../../gpu_tile_compact.sh $build_folder/bin/miniqmc_sync_move -P -g "2 2 1" -w 320 -n 1 > mi250_r8_t8.s$series.out
done
# Extracting the FOM value
grep "Diffusion throughput" mi250_r?_t8.s?.out
