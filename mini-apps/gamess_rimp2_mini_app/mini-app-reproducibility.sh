# Downloading source code
$ git clone -b SC24_PMBS --single-branch https://github.com/jkwack/GAMESS_RI-MP2_MiniApp.git
$ cd GAMESS_RI-MP2_MiniApp


# Setting the environment
$ source source_me_Sunspot      # on Aurora or Sunspot
$ source source_me_JLSE_H100    # on JLSE (H100 nodes)
$ source source_me_Dawn         # on Dawn
 
# Compiling the code
$ make

# Running the code
## On a single stack on Aurora or Sunspot
$ OMP_NUM_THREADS=1 mpirun -n 1 gpu_tile_compact.sh ./rimp2-mkl-offload w90.rand

## On a single GPU (i.e., 2 stacks) on Aurora or Sunspot
$ OMP_NUM_THREADS=1 mpirun -n 2 gpu_tile_compact.sh ./rimp2-mkl-offload w90.rand

## On a half node (i.e., 3 GPUs) on Aurora or Sunspot
$ OMP_NUM_THREADS=1 mpirun -n 6 gpu_tile_compact.sh ./rimp2-mkl-offload w90.rand

## On a single node (i.e., 6 GPUs) on Aurora or Sunspot
$ OMP_NUM_THREADS=1 mpirun -n 12 gpu_tile_compact.sh ./rimp2-mkl-offload w90.rand

## On a single H100 on JLSE
$ OMP_NUM_THREADS=1 mpirun -n 1 ./set_affinity_gpu.sh ./rimp2-cublas w90.rand

## On a single node (i.e., 4 H100 GPUs) on JLSE
$ OMP_NUM_THREADS=1 mpirun -n 4 ./set_affinity_gpu.sh ./rimp2-cublas w90.rand

## On a single stak on Dawn
VENDOR=INTEL mpiexec -n 1 --bind-to core:12 ./gpu_tile_compact.sh ./rimp2-mkl-offload-mpich  w90.rand

## On a single GPU (i.e., 2 stacks) on Dawn
VENDOR=INTEL mpiexec -n 2 --bind-to core:12 ./gpu_tile_compact.sh ./rimp2-mkl-offload-mpich  w90.rand

## On a half node (i.e., 2 GPUs) on Dawn
VENDOR=INTEL mpiexec -n 4 --bind-to core:12 ./gpu_tile_compact.sh ./rimp2-mkl-offload-mpich  w90.rand

## On a single node (i.e., 4 GPUs) on Dawn
VENDOR=INTEL mpiexec -n 8 --bind-to core:12 ./gpu_tile_compact.sh ./rimp2-mkl-offload-mpich  w90.rand


# Extracting the FOM value
From the standard output, read "Wall time (maximum)" and then compute the FOM with 1/"Wall time (maximum) in hour"

