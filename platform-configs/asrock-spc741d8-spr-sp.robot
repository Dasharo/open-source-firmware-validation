*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Resource    include/asrock-spc-741d8-common.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=           2000

# CPF
${CPU_MAX_FREQUENCY}=               3999
${CPU_MIN_FREQUENCY}=               700
${MAX_CPU_TEMP}=                    80

${WATCHDOG_SUPPORT}=                ${FALSE}

${DEF_THREADS_TOTAL}=               24
${DEF_THREADS_PER_CORE}=            2
${DEF_CORES_PER_SOCKET}=            12
${DEF_SOCKETS}=                     1
${DEF_ONLINE_CPU}=                  0-23

# get-robot-variables suggests 3,40, but 0,80 is what setup menu shows
${PLATFORM_CPU_SPEED}=              2.0
${PLATFORM_RAM_SPEED}=              4000
${PLATFORM_RAM_SIZE}=               16384
${MAX_CPU_TEMP_THRESHOLD}=          93
${CPU}=                             Intel(R) Xeon(R) Silver 4410Y
${DMIDECODE_SERIAL_NUMBER}=         85842258

# TXT
${TXT_SINIT_ACM_VERSION}=           6
@{TXT_EXPECTED_SHA256_PCR17_22}=    214B4B31DF15716C08FC4AD8BBE285813014D989C077F7EC72954FEDE78F1311
...                                 788C54EB03FA008004F6263274860B8EBF611AE72D435FD05B9C68B7CADF9893
...                                 0000000000000000000000000000000000000000000000000000000000000000
...                                 0000000000000000000000000000000000000000000000000000000000000000
...                                 0000000000000000000000000000000000000000000000000000000000000000
...                                 0000000000000000000000000000000000000000000000000000000000000000
