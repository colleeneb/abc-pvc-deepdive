# Aurora

## Micro-benchmarks

|                                     |   One Tile |   Full Node | Scaling |
|                                  ---|-----------:| -----------:|    ----:|
|         Single Precision Peak Flops | 23 TFlop/s | 267 TFlop/s |    11.8 |
|         Double Precision Peak Flops | 17 TFlop/s | 187 TFlop/s |    10.9 |
|            Memory Bandwidth (triad) |     1 TB/s |     12 TB/s |    11.9 |
| PCIe Unidirectional Bandwidth (H2D) |    54 GB/s |    329 GB/s |     6.1 |
| PCIe Unidirectional Bandwidth (D2H) |    55 GB/s |    263 GB/s |     4.8 |
|        PCIe Bidirectional Bandwidth |    76 GB/s |    357 GB/s |     4.7 |
|  Tile2Tile Unidirectional Bandwidth |   196 GB/s |      1 TB/s |     6.0 |
|   Tile2Tile Bidirectional Bandwidth |   287 GB/s |      2 TB/s |     5.9 |
|    GPU2GPU Unidirectional Bandwidth |    15 GB/s |     95 GB/s |     6.3 |
|     GPU2GPU Bidirectional Bandwidth |    23 GB/s |    142 GB/s |     6.2 |

## GEMM

|          |    One Tile |    Full Node | Scaling |
|       ---| -----------:|  -----------:|    ----:|
|    DGEMM |  15 TFlop/s |  179 TFlop/s |    11.9 |
|    SGEMM |  22 TFlop/s |  258 TFlop/s |    11.7 |
|    HGEMM | 263 TFlop/s | 2606 TFlop/s |     9.9 |
| BF16GEMM | 273 TFlop/s | 2645 TFlop/s |     9.7 |
| TF32GEMM | 110 TFlop/s | 1311 TFlop/s |    11.9 |
|   I8GEMM | 577 TFlop/s | 5394 TFlop/s |     9.4 |

## FFT

|                             |   One Tile |  Full Node | Scaling |
|                          ---|-----------:|-----------:|    ----:|
| Single-precision FFT C2C 1D |  3 TFlop/s | 34 TFlop/s |    10.8 |
| Single-precision FFT C2C 2D |  3 TFlop/s | 35 TFlop/s |    10.4 |
