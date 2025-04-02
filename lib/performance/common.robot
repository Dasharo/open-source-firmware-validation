*** Settings ***
Documentation       lib/performance/common

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             RequestsLibrary
Library             SSHLibrary
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot
# IMPORTANT: This must be commented out for production
# This is here only to make LSP happy during development.
# Resource    ../../platform-configs/include/default.robot


*** Variables ***
${PTS_LATEST_URL}=
...                             https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/tags/v10.8.4.zip
${PTS_DOWNLOAD_PATH}=           C:\pts\pts.zip
${PTS_EXTRACT_PATH}=            C:\pts-extracted\
${PERF_REPORT_DIR_LINUX}=       ~/testing/reports/
${PERF_REPORT_DIR_WINDOWS}=     C:\testing\reports\


*** Keywords ***
Power Cycle Into Ubuntu
    Power On
    Boot System Or From Connected Disk    201
    Login To Linux
