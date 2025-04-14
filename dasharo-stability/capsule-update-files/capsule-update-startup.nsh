# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

set LOG_FILE fs0:\logs.txt

# load variables to allow saving state between runs

fs0:\variable_capsule_file.nsh
fs0:\variable_step.nsh

# Variables expected to be loaded:
# - STEP - integer flag for choosing operation mode
# - CAPSULE_FILE - path to the capsule file

# Step 0 - launch capsule update
if "%STEP%" == "0" then
    echo 'set STEP 1' > fs0:\variable_step.nsh
    fs0:\CapsuleApp.efi "%CAPSULE_FILE%" -NR
    reset
endif

# Step 1 - check update status
if "%STEP%" == "1" then
    fs0:\CapsuleApp.efi -S > "%LOG_FILE%"
    echo 'set STEP 0' > fs0:\variable_step.nsh
    reset
endif
