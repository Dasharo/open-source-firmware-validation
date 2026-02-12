# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# This startup script runs from the UEFI shell workspace prepared under fs0:\capsule_testing\
set LOG_FILE fs0:\capsule_testing\logs.txt

# load variables to allow saving state between runs

fs0:\capsule_testing\variable_capsule_file.nsh
fs0:\capsule_testing\variable_step.nsh

# Variables expected to be loaded:
# - STEP - integer flag for choosing operation mode
# - CAPSULE_FILE - path to the capsule file

# Step 0 - launch capsule update
if "%STEP%" == "0" then
    fs0:\capsule_testing\CapsuleApp.efi "%CAPSULE_FILE%" -NR
    reset
endif

# Step 1 - check update status
if "%STEP%" == "1" then
    fs0:\capsule_testing\CapsuleApp.efi -S > "%LOG_FILE%"
    reset
endif
