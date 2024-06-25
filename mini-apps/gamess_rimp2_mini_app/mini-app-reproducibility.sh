# Downloading source code
$ git clone -b SC24_PMBS --single-branch https://github.com/jkwack/GAMESS_RI-MP2_MiniApp.git

# Setting the environment on Aurora or Sunspot
$ cd GAMESS_RI-MP2_MiniApp
$ source source_me_Sunspot 
 
# Compiling the code
$ make

# Running the code
## On a single stack on Aurora or Sunspot
$ OMP_NUM_THREADS=1 mpirun -n 1 gpu_tile_compact.sh ./rimp2-mkl-offload w60.rand

## On a single GPU (i.e., 2 stacks) on Aurora or Sunspot
$ OMP_NUM_THREADS=1 mpirun -n 2 gpu_tile_compact.sh ./rimp2-mkl-offload w60.rand

## On a single node (i.e., 6 GPUs) on Aurora or Sunspot
$ OMP_NUM_THREADS=1 mpirun -n 12 gpu_tile_compact.sh ./rimp2-mkl-offload w60.rand


# Extracting the FOM value
From the standard output, read "Wall time (maximum)" and then compute the FOM with 1/"Wall time (maximum)"

