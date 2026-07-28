*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         SBOM Suite Setup
Suite Teardown      Run Keywords
...                     Execute Command In Terminal    rm -f /tmp/fw_sbom_*
...                     AND
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${SBOM_FILE}=       ${EMPTY}
&{MAPPING_SBOM}=
...                 CONFIG_SBOM_MANUFACTURER=3mdeb
...                 CONFIG_SBOM_PAYLOAD=edk2
...                 CONFIG_SBOM_EDK2_PLATFORMS=edk2-platforms
...                 CONFIG_SBOM_ME=Intel Management Engine
...                 CONFIG_SBOM_INTEL_MICROCODE=Intel-Microcode
...                 CONFIG_SBOM_INTEL_FSP=Intel Firmware Support Package
...                 CONFIG_SBOM_IFD=Intel Flash Descriptor
...                 CONFIG_SBOM_VBOOT=vboot
...                 CONFIG_SBOM_IPXE=iPXE
...                 CONFIG_SBOM_EC=Embedded Controller Firmware
...                 CONFIG_SBOM_AMD_MICROCODE=AMD-Microcode
...                 CONFIG_SBOM_OPENSIL=AMD openSIL
...                 CONFIG_SBOM_AMD_PSP_FW=AMD PSP
...                 CONFIG_SBOM_COMPILER=GCC
...                 CONFIG_SBOM_SINIT_ACM=Intel SINIT ACM
...                 CONFIG_SBOM_BIOS_ACM=Intel BIOS ACM
...                 CONFIG_SBOM_EDK2_GOP=Intel GOP driver


*** Test Cases ***
SBOM001.201 Each component from coreboot config appears in the SBOM (Ubuntu)
    [Documentation]    Tests if all CONFIG_SBOM_* keys appear in the generated SBOM component list
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBOM001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SBOM001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    # Loading config from ROM
    Execute Command In Terminal    cbfstool /tmp/fw_sbom_test.rom extract -n config -f /tmp/cbfstool_config
    ${cbfs_config}=    Execute Command In Terminal
    ...    grep CONFIG_SBOM /tmp/cbfstool_config | grep -v CONFIG_SBOM\=y | grep -v GENERATE | grep -v PATH | grep -v '#'
    Should Not Be Empty    ${cbfs_config}    No CONFIG_SBOM_* values found
    @{cbfs_config}=    Split String    ${cbfs_config}    separator=\n

    # Loading SBOM from ROM
    ${sbom_config}=    Execute Command In Terminal    /home/ubuntu/decode-sbom --rom /tmp/fw_sbom_test.rom -o -

    VAR    ${acm_fail}=    ${FALSE}
    VAR    ${fail}=    ${FALSE}
    # Checking if each component appears
    FOR    ${component}    IN    @{cbfs_config}
        ${component}=    Fetch From Left    ${component}    \=
        ${json_name}=    Map SBOM Config To JSON    ${component}
        ${acm_component}=    Component Is ACM    ${component}

        # Fail if component not in map
        IF    '${json_name}' == 'FAIL_NO_MAPPING'
            Log To Console    FAIL: No mapping for "${component}"
            VAR    ${fail}=    ${TRUE}
            CONTINUE
        END

        # Fail if component missing from SBOM
        IF    '"name": "${json_name}' not in '''${sbom_config}'''
            Log To Console    FAIL: Component "${component}" not present in SBOM!
            VAR    ${fail}=    ${TRUE}
            IF    '${acm_component}' == '${TRUE}'
                VAR    ${acm_fail}=    ${TRUE}
            END
        ELSE
            ${json_name_line}=    Get Lines Containing String    ${sbom_config}    "name": "${json_name}
            Log To Console    OK: ${component}->${json_name_line}
        END
    END
    VAR    ${fail_msg}=    Components missing in map or not found in sbom.json

    # Fail with special message if ACM component missing from SBOM
    IF    ${acm_fail}
        VAR    ${fail_msg}=
        ...    ACM FAIL: Likely running unprovisioned binaries\nComponents missing in map or not found in sbom.json
    END
    IF    ${fail}    Fail    ${fail_msg}

SBOM002.201 SBOM CRA compliance (Ubuntu)
    [Documentation]    Tests the generated SBOM for CRA compliance
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBOM002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SBOM002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    # Saving sbom to json file
    Execute Command In Terminal    /home/ubuntu/decode-sbom --rom /tmp/fw_sbom_test.rom -o /tmp/fw_sbom_test.json
    ${result}=    Execute Command In Terminal
    ...    sbom-tools validate --standard cra /tmp/fw_sbom_test.json

    ${validation_erros}=    Get Lines Containing String    ${result}    [ERROR]
    Should Be Empty
    ...    ${validation_erros}
    ...    There were errors in CRA compliance validation for ${FW_FILE}:\n${validation_erros}\n\n

SBOM003.201 Generated SBOM is the same as supplied SBOM (Ubuntu)
    [Documentation]    Tests whether the SBOM generated using decode-sbom is the same
    ...    as the one supplied with SBOM_FILE environment variable.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBOM003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SBOM003.201 not supported
    Skip If    '${SBOM_FILE}' == '${EMPTY}'    No SBOM file supplied
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Send File To DUT    ${SBOM_FILE}    /tmp/fw_sbom_supplied.json
    # Saving sbom to json file
    Execute Command In Terminal    /home/ubuntu/decode-sbom --rom /tmp/fw_sbom_test.rom -o /tmp/fw_sbom_test.json
    ${diff_sbom}=    Execute Command In Terminal
    ...    sbom-tools diff /tmp/fw_sbom_supplied.json /tmp/fw_sbom_test.json -o summary
    Should Contain    ${diff_sbom}    Similarity:${SPACE}${SPACE}100.0%    Generated and supplied SBOMs dont match


*** Keywords ***
Component Is ACM
    [Arguments]    ${component}
    # ${acm_check}=    Get Lines Containing String    ${component}    ACM
    IF    'ACM' in '${component}'    RETURN    ${TRUE}
    RETURN    ${FALSE}

Map SBOM Config To JSON
    [Arguments]    ${config_val}
    ${config_mapping}=    Get From Dictionary    ${MAPPING_SBOM}    ${config_val}    FAIL_NO_MAPPING
    RETURN    ${config_mapping}

Install Sbom-tools
    Execute Command In Terminal
    ...    wget -q https://github.com/sbom-tool/sbom-tools/releases/latest/download/sbom-tools-linux-x86_64.tar.gz
    Execute Command In Terminal
    ...    tar xzf sbom-tools-linux-x86_64.tar.gz && sudo mv sbom-tools /usr/local/bin/
    ${dependency_test}=    Execute Command In Terminal
    ...    test -f /usr/local/bin/sbom-tools && echo SBOM-TOOLS
    IF    '${dependency_test}' != 'SBOM-TOOLS'
        Fail    Failed to install sbom-tools
    END

Detect Or Install SBOM Dependencies
    [Documentation]    Detects already installed or installs dependencies for the SBOM Test Suite
    Detect Or Install Package    coreboot-utils
    ${dependency_test}=    Execute Command In Terminal
    ...    test -f /home/ubuntu/decode-sbom && echo DECODE-SBOM
    IF    '${dependency_test}' != 'DECODE-SBOM'
        Fail    decode-sbom not present at /home/ubuntu/decode-sbom
    END
    Log To Console    decode-sbom present at /home/ubuntu/decode-sbom
    ${dependency_test}=    Execute Command In Terminal
    ...    test -f /usr/local/bin/sbom-tools && echo SBOM-TOOLS
    IF    '${dependency_test}' != 'SBOM-TOOLS'    Install Sbom-tools
    Log To Console    sbom-tools installed

SBOM Suite Setup
    Prepare Test Suite
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SBOM00x.201 not supported
    ${sbom_file_env}=    Get Environment Variable    SBOM_FILE    ${EMPTY}
    VAR    ${SBOM_FILE}=    ${sbom_file_env}    scope=GLOBAL
    Check Power Supply
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Detect Or Install SBOM Dependencies
    Send File To DUT    ${FW_FILE}    /tmp/fw_sbom_test.rom
