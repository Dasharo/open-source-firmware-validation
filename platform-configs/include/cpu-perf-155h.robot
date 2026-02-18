*** Variables ***
# Values obtained from https://openbenchmarking.org/vs/Processor/Intel+Core+Ultra+7+155H

# Ubuntu
${ZIP_MULTI_COMPRESSION}=       69245    # MIPS
${ZIP_MULTI_DECOMPRESSION}=     47858    # MIPS
${CRAY_5_K_RENDER}=             549    # sec
${CRAY_4_K_RENDER}=             319    # sec
${CRAY_1080_P_RENDER}=          79    # sec
${COREMARK_SINGLE}=             387404    # iterations/s

# Windows
# reference score for 155H from https://openbenchmarking.org/result/2508216-NE-SKIBIDI6461
&{UPP_SMALLPT_BENCHMARK}=
...                             name=smallpt
...                             score=19.02
...                             scale=lower_is_better
...                             dev=0.2
...                             type=singlecore
# reference score for 155H from https://openbenchmarking.org/test/pts/crafty
&{UPP_CRAFTY_BENCHMARK}=
...                             name=crafty
...                             score=10919999
...                             scale=higher_is_better
...                             dev=0.2
...                             type=singlecore
# reference score for 155H from https://openbenchmarking.org/result/2508217-NE-AAAAAAA9714
&{UPP_CACHEBENCH_BENCHMARK}=
...                             name=cachebench
...                             score=106987
...                             scale=higher_is_better
...                             dev=0.2
...                             type=multicore
# reference score for 155H from    https://openbenchmarking.org/result/2508292-NE-20250829131
&{UPP_BLAKE2_BENCHMARK}=
...                             name=blake2
...                             score=4.06
...                             scale=lower_is_better
...                             dev=0.2
...                             type=multicore
@{UPP_BENCHMARKS}=
...                             &{UPP_SMALLPT_BENCHMARK}
...                             &{UPP_CRAFTY_BENCHMARK}
...                             &{UPP_CACHEBENCH_BENCHMARK}
...                             &{UPP_BLAKE2_BENCHMARK}
