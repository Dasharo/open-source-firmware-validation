*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${FAN_SPEED_MEASURE_SUPPORT}    Fan speed measure tests not supported
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Init FAN Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
FAN001.201 CPU fan speed measure
    [Documentation]    Check whether there's a possibility to measure CPU fan
    ...    current speed.
    ${output}=    Execute Linux Command
    ...    sensors | grep "CPU 0:" | awk 'NR==1 {print $3}'
    Should Not Be Empty    ${output}
    Should Not Be Equal    ${output}    0

FAN002.201 All available fans are running
    [Documentation]    Check if all available fans are running
    Switch To Root User
    Stress Test
    Exit From Root User
    ${output}=    Execute Linux Command
    ...    sensors | grep -E 'GPU|CPU' | grep -E 'RPM$' | awk '{print $3}'
    Should Not Be Empty    ${output}
    @{rpm_values}=    Split To Lines    ${output}
    FOR    ${element}    IN    @{rpm_values}
        Should Not Be Equal    ${output}    0
    END

FAN003.201 Fans are turning off during suspend mode with ME Enabled
    [Documentation]    Check for correct behavior
    [Tags]    semiauto
    Power On
    Set UEFI Option    MeMode    Enabled
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Log To Console    \nFan test started, please check fan state manually
    Perform Suspend Test Using FWTS
    Log To Console    \nFan state test ended, please note the result

FAN004.201 Fans are turning off during suspend mode with ME Soft disabled
    [Documentation]    Check for correct behavior
    [Tags]    semiauto
    Power On
    Set UEFI Option    MeMode    Disabled (Soft)
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Log To Console    \nFan test started, please check fan state manually
    Perform Suspend Test Using FWTS
    Log To Console    \nFan state test ended, please note the result

FAN005.201 Fans are turning off during suspend mode with ME HAP disabled
    [Documentation]    Check for correct behavior
    [Tags]    semiauto
    Power On
    Set UEFI Option    MeMode    Disabled (HAP)
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Log To Console    \nFan test started, please check fan state manually
    Perform Suspend Test Using FWTS
    Log To Console    \nFan state test ended, please note the result

FAN006.201 GPU fan speed measure
    [Documentation]    The fan has been configured to follow a custom curve.
    ...    This test aims to verify that the fan curve is configured correctly
    ...    and the fan spins up and down according to the defined values.
    Skip If    not ${NVIDIA_GRAPHICS_CARD_SUPPORT}    FAN006.201 not supported
    ${output}=    Execute Linux Command
    ...    sensors | grep "GPU 0:" | awk 'NR==1 {print $3}'
    Should Not Be Empty    ${output}
    Should Not Be Equal    ${output}    0


*** Keywords ***
Init FAN Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Detect Or Install FWTS
    Prepare Sensors
