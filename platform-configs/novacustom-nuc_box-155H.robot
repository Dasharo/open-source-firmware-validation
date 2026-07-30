*** Settings ***
Resource    include/novacustom-nuc_box.robot
Resource    include/novacustom-mtl.robot
Resource    include/novacustom-common.robot
Resource    include/default.robot


*** Variables ***
${CPU}=                                 Intel(R) Core(TM) Ultra 7 155H
${INITIAL_CPU_FREQUENCY}=               2800
${DEF_CORES_PER_SOCKET}=                16
${DEF_THREADS_PER_CORE}=                2
${DEF_THREADS_TOTAL}=                   22
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=                      0-21
${DEF_SOCKETS}=                         1

${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   200

${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${USB_MODEL}=                           SanDisk
${USB_DEVICE}=                          Linux
${EXPECTED_FW_SHA256}=                  7595d57fcec2d315db0b612b9aab6cf680a1151719b7a3b2d3313aea6be97c06

# cpu performance Ubuntu/Windows
&{CPP_ZIP_COMPRESSION_BENCHMARK}=
...                                     name=Test: Compression Rating
...                                     short_name=pts/compress-7zip
...                                     score=60270.9
...                                     scale=higher_is_better
...                                     dev=0.1
...                                     type=multicore
&{CPP_ZIP_DECOMPRESSION_BENCHMARK}=
...                                     name=Test: Decompression Rating
...                                     short_name=pts/compress-7zip
...                                     score=35689.3
...                                     scale=higher_is_better
...                                     dev=0.14
...                                     type=multicore
&{CPP_CACHEBENCH_BENCHMARK}=
...                                     name=Test: Read / Modify / Write
...                                     short_name=pts/cachebench
...                                     score=106987
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
&{CPP_CRAFTY_BENCHMARK}=
...                                     name=Elapsed Time
...                                     short_name=pts/crafty
...                                     score=9934550.2
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=singlecore
&{CPP_SMALLPT_BENCHMARK}=
...                                     name=Global Illumination Renderer; 128 Samples
...                                     short_name=pts/smallpt
...                                     score=10.07
...                                     scale=lower_is_better
...                                     dev=0.1
...                                     type=singlecore

&{CPP_STOCKFISH_BENCHMARK}=
...                                     name=Chess Benchmark
...                                     short_name=pts/stockfish
...                                     score=5283639
...                                     scale=higher_is_better
...                                     dev=0.1
...                                     type=multicore

@{CPP_BENCHMARKS}=
# ...                                   &{CPP_ZIP_COMPRESSION_BENCHMARK}
# ...                                   &{CPP_ZIP_DECOMPRESSION_BENCHMARK}
# ...                                   &{CPP_CACHEBENCH_BENCHMARK}
...                                     &{CPP_STOCKFISH_BENCHMARK}
# ...                                   &{CPP_SMALLPT_BENCHMARK}
...                                     &{CPP_CRAFTY_BENCHMARK}

# cpu performance Windows - deprecated
# reference score for 155H from https://openbenchmarking.org/result/2508216-NE-SKIBIDI6461
&{UPP_SMALLPT_BENCHMARK}=
...                                     name=smallpt
...                                     score=19.02
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=singlecore
# reference score for 155H from https://openbenchmarking.org/test/pts/crafty
&{UPP_CRAFTY_BENCHMARK}=
...                                     name=crafty
...                                     score=10919999
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=singlecore
# reference score for 155H from https://openbenchmarking.org/result/2508217-NE-AAAAAAA9714
&{UPP_CACHEBENCH_BENCHMARK}=
...                                     name=cachebench
...                                     score=106987
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
# reference score for 155H from    https://openbenchmarking.org/result/2508292-NE-20250829131
&{UPP_BLAKE2_BENCHMARK}=                name=blake2    score=4.06    scale=lower_is_better    dev=0.2    type=multicore
@{UPP_BENCHMARKS}=
...                                     &{UPP_SMALLPT_BENCHMARK}
...                                     &{UPP_CRAFTY_BENCHMARK}
...                                     &{UPP_CACHEBENCH_BENCHMARK}
...                                     &{UPP_BLAKE2_BENCHMARK}

# disk i-o
&{DISK_IO_REFERENCE_VALUES_UBUNTU}=
...                                     SEQ_READ_QUEUED=4677
...                                     SEQ_WRITE_QUEUED=1878
...                                     SEQ_READ_NONQUE=2232
...                                     SEQ_WRITE_NONQUE=1884
...                                     RAND_READ_QUEUED=823
...                                     RAND_WRITE_QUEUED=917
...                                     RAND_READ_NONQUE=68
...                                     RAND_WRITE_NONQUE=272

&{DISK_IO_REFERENCE_VALUES_WINDOWS}=
...                                     SEQ_READ_QUEUED=7119
...                                     SEQ_WRITE_QUEUED=6511
...                                     SEQ_READ_NONQUE=5001
...                                     SEQ_WRITE_NONQUE=5475
...                                     RAND_READ_QUEUED=886
...                                     RAND_WRITE_QUEUED=461
...                                     RAND_READ_NONQUE=82
...                                     RAND_WRITE_NONQUE=239

${UNIGINE_SUPERPOSITION_RESULT_AC}=     20.6    # FPS


*** Keywords ***
Power On
    Novacustom-common.Power On
