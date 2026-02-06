*** Settings ***
Documentation       Common header for OSFV Performance Library

Library             Collections
Library             DateTime
Library             OperatingSystem
Library             Process
Library             String
Library             RequestsLibrary
Library             SSHLibrary
Resource            ../platform/power.robot
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Variables ***
# Phoronix Test Suite download variables
${PTS_LATEST_URL}=
...                                 https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/tags/v10.8.4.zip
${PTS_DOWNLOAD_PATH}=               C:\pts\pts.zip
${PTS_EXTRACT_PATH}=                C:\pts-extracted\
# Phoronix Test Suite test results
${PTS_RESULTS_DIR_WINDOWS}=         C:\pts\test-results\
${PTS_RESULTS_DIR_LINUX}=           ~/.phoronix-test-suite/test-results
${PTS_RESULTS_DIR_LINUX_ROOT}=      /var/lib/phoronix-test-suite/test-results


*** Keywords ***
Detect Or Install Phoronix Test Suite On Ubuntu
    [Documentation]    Detects and installs PTS if it is missing on Ubuntu.
    # Get and store current user, so we can seamlessly get root perms if missing
    ${curr_user}=    Execute Command In Terminal    whoami
    IF    '${curr_user}' != 'root'    Switch To Root User
    Detect Or Install Package    php-cli
    Detect Or Install Package    php-xml

    ${out}=    Execute Command In Terminal    test -f /usr/bin/phoronix-test-suite && echo "PTS Installed"
    IF    '${out}' != 'PTS Installed'
        Execute Command In Terminal    wget ${PTS_LATEST_URL}    60
        Execute Command In Terminal    unzip -q -o v10.8.4.zip    120
        ${out}=    Execute Command In Terminal
        ...    cd phoronix-test-suite-10.8.4 && ./install-sh && cd ..    120
        Should Contain    ${out}    Phoronix Test Suite Installation Completed
        Execute Command In Terminal
        ...    rm v10.8.4.zip && rm -r phoronix-test-suite-10.8.4
    END
    IF    '${curr_user}' != 'root'    Exit From Root User

Detect Or Install Phoronix Test Suite On Windows
    [Documentation]    Detects and installs PTS for Windows 11 via powershell.
    ${out}=    Execute Command In Terminal    Test-Path -Path C:\phoronix-test-suite
    IF    '${out}' != 'True'
        Execute Command In Terminal
        ...    Invoke-WebRequest -Uri ${PTS_LATEST_URL} -OutFile ${PTS_DOWNLOAD_PATH}    60
        Execute Command In Terminal
        ...    Expand-Archive -Path ${PTS_DOWNLOAD_PATH} -DestinationPath ${PTS_EXTRACT_PATH} -Force    60
        Execute Command In Terminal
        ...    Start-Process -FilePath ${PTS_EXTRACT_PATH}\install.bat -NoNewWindow -Wait    300
        Execute Command In Terminal
        ...    Remove-Item -Path ${PTS_DOWNLOAD_PATH} -Force
        Execute Command In Terminal
        ...    Remove-Item -Path ${PTS_EXTRACT_PATH} -Force
    END

Setup Phoronix Batch Mode
    [Documentation]    Configure batch mode required for more automated tests.
    Write Into Terminal    phoronix-test-suite batch-setup
    Read From Terminal Until    Save test results when in batch mode (Y/n):
    Write Into Terminal    y
    # Yes, this option for some reason has upper/lower case swapped...
    Read From Terminal Until    Open the web browser automatically when in batch mode (y/N):
    Write Into Terminal    n
    Read From Terminal Until    Auto upload the results to OpenBenchmarking.org (Y/n):
    Write Into Terminal    y
    Read From Terminal Until    Prompt for test identifier (Y/n):
    Write Into Terminal    n
    Read From Terminal Until    Prompt for test description (Y/n):
    Write Into Terminal    n
    Read From Terminal Until    Prompt for saved results file-name (Y/n):
    Write Into Terminal    n
    Read From Terminal Until    Run all test options (Y/n):
    Write Into Terminal    n
    Read From Terminal Until Prompt
