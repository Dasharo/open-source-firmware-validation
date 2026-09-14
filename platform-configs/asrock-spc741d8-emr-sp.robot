*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Resource    include/asrock-spc-741d8-common.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=           2200

# CPF
${CPU_MAX_FREQUENCY}=               3799
${CPU_MIN_FREQUENCY}=               700
${MAX_CPU_TEMP}=                    80

${WATCHDOG_SUPPORT}=                ${FALSE}

${DEF_THREADS_TOTAL}=               48
${DEF_THREADS_PER_CORE}=            2
${DEF_CORES_PER_SOCKET}=            24
${DEF_SOCKETS}=                     1
${DEF_ONLINE_CPU}=                  0-47

# get-robot-variables suggests 3,40, but 0,80 is what setup menu shows
${PLATFORM_CPU_SPEED}=              2.2
${PLATFORM_RAM_SPEED}=              4400
${PLATFORM_RAM_SIZE}=               16384
${MAX_CPU_TEMP_THRESHOLD}=          93
${CPU}=                             Intel(R) Xeon(R) Silver 4516Y+
${DMIDECODE_SERIAL_NUMBER}=         85842258

# TXT
${TXT_SINIT_ACM_VERSION}=           6
@{TXT_EXPECTED_SHA256_PCR17_22}=    76B89A17D0E82CD28454D8281B016598CE091729E848B42B054186289FE32F52
...                                 5EF17B7BF9FB1E94895F0BC108BADFA01447199D4A38D637626C98A7F56B3D45
...                                 0000000000000000000000000000000000000000000000000000000000000000
...                                 0000000000000000000000000000000000000000000000000000000000000000
...                                 0000000000000000000000000000000000000000000000000000000000000000
...                                 0000000000000000000000000000000000000000000000000000000000000000
