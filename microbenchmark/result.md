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


# Dawn
(provisional, node id pvc-s-33)

Intel oneAPI 2024.1, MPICH 4.2.1

## Micro-benchmarks

|                                     | One Tile   | Full Node   | Scaling |
|                                  ---|-----------:| -----------:|    ----:|
| Single Precision Peak Flops         | 26 TFlop/s | 207 TFlop/s |     8.0 |
| Double Precision Peak Flops         | 20 TFlop/s | 139 TFlop/s |     7.1 |
| Memory Bandwidth (triad)            | 1 TB/s     | 9 TB/s      |     8.0 |
| PCIe Unidirectional Bandwidth (H2D) | 54 GB/s    | 218 GB/s    |     4.0 |
| PCIe Unidirectional Bandwidth (D2H) | 52 GB/s    | 212 GB/s    |     4.1 |
| PCIe Bidirectional Bandwidth        | 73 GB/s    | 285 GB/s    |     3.9 |
| Tile2Tile Unidirectional Bandwidth  | 197 GB/s   | 786 GB/s    |     4.0 |
| Tile2Tile Bidirectional Bandwidth   | 287 GB/s   | 1 TB/s      |     4.0 |
| GPU2GPU Unidirectional Bandwidth    |            |             |         |
| GPU2GPU Bidirectional Bandwidth     |            |             |         |

## GEMM

|          | One Tile    | Full Node    | Scaling |
|       ---| -----------:|  -----------:|    ----:|
| DGEMM    | 18 TFlop/s  | 145 TFlop/s  |     8.1 |
| SGEMM    | 26 TFlop/s  | 205 TFlop/s  |     7.9 |
| HGEMM    | 323 TFlop/s | 1902 TFlop/s |     5.9 |
| BF16GEMM | 333 TFlop/s | 2005 TFlop/s |     6.0 |
| TF32GEMM | 145 TFlop/s | 975 TFlop/s  |     6.7 |
| I8GEMM   | 664 TFlop/s | 3987 TFlop/s |     6.0 |

## FFT

|                             | One Tile   | Full Node  | Scaling |
|                          ---|-----------:|-----------:|    ----:|
| Single-precision FFT C2C 1D | 4 TFlop/s  | 26 TFlop/s |     7.4 |
| Single-precision FFT C2C 2D | 4 TFlop/s  | 25 TFlop/s |     6.8 |
