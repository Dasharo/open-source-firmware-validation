# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# This startup script runs from the UEFI shell workspace located under
# capsule_testing. The workspace drive (fsX:) can vary, so search for it.

set CAPSULE_FS not_found
for %d in fs0 fs1 fs2 fs3 fs4 fs5 fs6 fs7 fs8 fs9
    if exist %d:capsule_testing then
        set CAPSULE_FS %d
        goto workspace_selected
    endif
endfor

:workspace_selected
if exist %CAPSULE_FS%:capsule_testing then
    goto load_workspace
endif

echo Capsule workspace not found. Ensure the variables were staged under an EFI filesystem that exposes fs0-fs9.
stall 5000000
reset

:load_workspace
set CAPSULE_WORKSPACE %CAPSULE_FS%:capsule_testing
set LOG_FILE %CAPSULE_WORKSPACE%\logs.txt

# load variables to allow saving state between runs

%CAPSULE_WORKSPACE%\variable_capsule_file.nsh
%CAPSULE_WORKSPACE%\variable_step.nsh

# Variables expected to be loaded:
# - STEP - integer flag for choosing operation mode
# - CAPSULE_FILE - path to the capsule file

# Step 0 - launch capsule update
if "%STEP%" == "0" then
    %CAPSULE_FS%:CapsuleApp.efi "%CAPSULE_WORKSPACE%\%CAPSULE_FILE%" -NR
    stall 5000000
    reset
endif

# Step 1 - check update status
if "%STEP%" == "1" then
    %CAPSULE_FS%:CapsuleApp.efi -S > "%LOG_FILE%"
    stall 5000000
    reset
endif
