*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             TelnetLibrary    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../lib/tpm.robot
Resource            ../lib/tpm2.robot
Resource            ../lib/trenchboot.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    ${TPM_SUPPORTED_VERSION} == None
...                     AND
...                     Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
...                     AND
...                     Prepare TXT Test On Linux
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${TXT_MEASURED_LAUNCH_REPEAT}=      3
${MSR_SCRIPT}=                      import os; fd=os.open('/dev/cpu/0/msr', os.O_RDONLY);
...                                 val=os.pread(fd,8,0x3a); os.close(fd); raw=int.from_bytes(val,'little');
...                                 mask=(1<<0)|(1<<15); print(hex(raw & mask))
${METATB_LINUX}=                    0
${METATB_XEN}=                      4
${METATB_XEN_TB}=                   5


*** Test Cases ***
TXT001.201 Firmware-side State After Normal Boot (Ubuntu)
    [Documentation]    Verify that TXT-related values are correct
    ...    before any measured launch.
    # Should be run right after Prepare TXT Test On Linux, no reboot!

    # Prepare relevant logs
    # Detect Or Install Package    tboot
    Execute Command In Terminal    txt-stat --heap > txt_stat.log
    ${txt_stat}=    Execute Command In Terminal    cat txt_stat.log

    # The BIOS Startup ACM executed: TXT status registers are in
    # the expected state and TXT.ERRORCODE reports no ACM error.
    Should Contain    ${txt_stat}    ERRORCODE: 0x00000000

    # TXT public configuration space is populated consistently:
    # SINIT.BASE/SIZE and HEAP.BASE/SIZE are non-zero, aligned,
    # and do not overlap other reserved regions.
    Should Not Contain    ${txt_stat}    SINIT.BASE: 0x00000000
    Should Not Contain    ${txt_stat}    SINIT.SIZE: 0B (0x0)
    Should Not Contain    ${txt_stat}    HEAP.BASE: 0x00000000
    Should Not Contain    ${txt_stat}    HEAP.SIZE: 0B (0x0)

    ${alignment}=    Execute Command In Terminal
    ...    grep SINIT\.BASE txt_stat.log | grep -o '0x[0-9a-fA-F]*' | grep -E '000$'
    Should Not Be Empty    ${alignment}    SINIT.BASE not aligned to 4KB
    ${alignment}=    Execute Command In Terminal
    ...    grep SINIT\.SIZE txt_stat.log | grep -o '0x[0-9a-fA-F]*' | grep -E '000$'
    Should Not Be Empty    ${alignment}    SINIT.SIZE not aligned to 4KB
    ${alignment}=    Execute Command In Terminal
    ...    grep HEAP\.BASE txt_stat.log | grep -o '0x[0-9a-fA-F]*' | grep -E '000$'
    Should Not Be Empty    ${alignment}    HEAP.BASE not aligned to 4KB
    ${alignment}=    Execute Command In Terminal
    ...    grep HEAP\.SIZE txt_stat.log | grep -o '0x[0-9a-fA-F]*' | grep -E '000$'
    Should Not Be Empty    ${alignment}    HEAP.SIZE not aligned to 4KB

    # The TXT heap BIOS data region carries the version and
    # field values the SINIT ACM expects.
    Should Contain    ${txt_stat}    version: ${TXT_SINIT_ACM_VERSION}
    Should Contain    ${txt_stat}    num_logical_procs: ${DEF_THREADS_TOTAL}
    # Lcp Pd Size, Base (based on values from Protectli VP2430)
    Should Contain    ${txt_stat}    lcp_pd_base: 0x0
    Should Contain    ${txt_stat}    lcp_pd_size: 0x0 (0)

    # The SINIT ACM region and the TXT heap are reported to
    # the OS as reserved in the memory map, and are not usable by the OS.

    # Confirm reserved
    ${heap_base}=    Execute Command In Terminal
    ...    grep HEAP\.BASE txt_stat.log | grep -o '0x[0-9a-fA-F]*'
    ${heap_size}=    Execute Command In Terminal
    ...    grep HEAP\.SIZE txt_stat.log | grep -o '0x[0-9a-fA-F]*'
    ${sinit_base}=    Execute Command In Terminal
    ...    grep SINIT\.BASE txt_stat.log | grep -o '0x[0-9a-fA-F]*'
    ${sinit_size}=    Execute Command In Terminal
    ...    grep SINIT\.SIZE txt_stat.log | grep -o '0x[0-9a-fA-F]*'
    SINIT And HEAP Should Be Reserved
    ...    ${sinit_base}    ${sinit_size}    ${heap_base}    ${heap_size}

    # DPR is configured, locked, and its reported size
    # matches what the firmware programmed; the range is inaccessible from the OS.
    Should Contain Any    ${txt_stat}    lock: TRUE    lock: 1

    # PMR configuration matches what the measured launch requires.

TXT001.204 Firmware-side State After Measured Boot (TrenchBoot)
    [Documentation]    Perform a measured launch and verify
    ...    that TXT is working properly.
    # Try measured launch ${TXT_MEASURED_LAUNCH_REPEAT} times
    # Each time do a graceful reboot to properly go through SENTER and SEXIT
    FOR    ${try_num}    IN RANGE    0    ${TXT_MEASURED_LAUNCH_REPEAT}    1
        Write Into Terminal    reboot
        Sleep    10s
        Set DUT Response Timeout    120s
        Boot From Meta Trenchboot    ${METATB_XEN_TB}

        # Check multiple times - sometimes the commands over serial get scrambled
        FOR    ${_}    IN RANGE    0    5    1
            Log To Console    Checking TXT on boot ${try_num}
            ${txt_pass}=    Run Keyword And Return Status    Check TXT After Measured Launch
            ${pcr_pass}=    Run Keyword And Return Status    Verify PCR Values
            IF    '${txt_pass}'=='${TRUE}' and '${pcr_pass}'=='${TRUE}'    BREAK
        END
        IF    '${txt_pass}'!='${TRUE}' or '${pcr_pass}'!='${TRUE}'    BREAK
        Log To Console    TXT check successful on boot ${try_num}
    END

    # Shutdown properly to go through SEXIT
    Sleep    2s
    Write Into Terminal    shutdown -h now
    Sleep    5s
    IF    '${txt_pass}'!='${TRUE}' or '${pcr_pass}'!='${TRUE}'
        Fail    TXT check failed on measured boot ${try_num}
    END


*** Keywords ***
SINIT And HEAP Should Be Reserved
    [Arguments]    ${sinit_base}    ${sinit_size}    ${heap_base}    ${heap_size}
    VAR    ${script}=
    ...    import sys;
    ...    entries = [
    ...    (int(a.split('-')[0],16), int(a.split('-')[1],16)+1, b.strip())
    ...    for a,sep,b in (l.strip().partition(':') for l in open('/proc/iomem'))
    ...    if sep and '-' in a
    ...    ];
    ...    ranges = {
    ...    'SINIT': (${sinit_base}, ${sinit_base}+${sinit_size}),
    ...    'HEAP': (${heap_base}, ${heap_base}+${heap_size}),
    ...    };
    ...    hits = {
    ...    name: next((t for t in entries if t[0]<=r[0] and r[1]<=t[1]), None)
    ...    for name,r in ranges.items()
    ...    };
    ...    results = {
    ...    name: ('OK:'+v[2] if v and 'reserved' in v[2].lower()
    ...    else ('WARNING:'+v[2] if v else 'NOT FOUND'))
    ...    for name,v in hits.items()
    ...    };
    ...    print(results);
    ${result}=    Execute Command In Terminal    python3 -c \"${script}\"
    Should Contain    ${result}    \'SINIT\'\: \'OK\:Reserved\'\, \'HEAP\'\: \'OK\:Reserved\'
    ...    msg=SINIT and HEAP are not in reserved memory.

Verify PCR Values
    [Documentation]    Verify whether SHA256 PCR17-22 values match reference values
    ...    for measured launch.
    VAR    ${pcr_num}=    17
    ${pcr_val}=    Execute Command In Terminal    tpm2_pcrread
    FOR    ${pcr_ref_val}    IN    @{TXT_EXPECTED_SHA256_PCR17_22}
        ${pcr_check_success}=    Run Keyword And Return Status
        ...    Should Contain    ${pcr_val}    ${pcr_num}\: 0x${pcr_ref_val}
        IF    not ${pcr_check_success}
            Log To Console    PCR${pcr_num} does not match reference value for this platform.
            Fail
        END
        Log To Console    PCR${pcr_num} matches reference value \(0x${pcr_ref_val}\)
        ${pcr_num}=    Evaluate    ${pcr_num}+1
    END

Check Image KM And BPM
    [Documentation]    Check if Key Manifest and Boot Policy Manifest inside FW image
    ...    are not malformed and pass verification.
    # Check if bg-prov already present
    ${bg_prov_check}=    Execute Command In Terminal    test -f converged-security-suite/bg-prov && echo found
    IF    'found' not in '${bg_prov_check}'
        Detect Or Install Package    golang
        Clone Git Repository    https://github.com/9elements/converged-security-suite.git
        Execute Command In Terminal    cd converged-security-suite; go build -o bg-prov cmd/core/bg-prov/*.go; cd ..
        ${bg_prov_check}=    Execute Command In Terminal    test -f converged-security-suite/bg-prov && echo found
        Should Contain    ${bg_prov_check}    found    Could not build bg-prov
    END
    Send File To DUT    ${FW_FILE}    /tmp/fw.rom

    # Extract KM and BPM from FW ROM (Also checking if they actually exist in FW ROM)
    ${km_export}=    Execute Command In Terminal
    ...    ./converged-security-suite/bg-prov km-export /tmp/fw.rom /tmp/km.bin
    Should Be Empty    ${km_export}
    ${bpm_export}=    Execute Command In Terminal
    ...    ./converged-security-suite/bg-prov bpm-export /tmp/fw.rom /tmp/bpm.bin
    Should Be Empty    ${bpm_export}

    # Verify extracted KM and BPM
    ${km_verify}=    Execute Command In Terminal    ./converged-security-suite/bg-prov km-verify /tmp/km.bin
    Should Be Empty    ${km_verify}
    ${bpm_verify}=    Execute Command In Terminal    ./converged-security-suite/bg-prov bpm-verify /tmp/bpm.bin
    Should Be Empty    ${bpm_verify}

Prepare TXT Test On Linux
    [Documentation]    Run common actions required for TXT tests in Linux
    [Arguments]    ${env_id}=${DEFAULT_BOOT_OS_ID}
    Skip If    ${TPM_SUPPORTED_VERSION} == None    TPM tests not supported
    Skip If    not ${TRENCHBOOT_SUPPORT}    TrenchBoot tests aren't supported
    Skip If    not ${TESTS_IN_METATB_SUPPORT}    Tests in meta-trenchboot aren't supported
    Power On
    # Boot Into Linux From Meta Trenchboot
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    # Check FW image
    Check Image KM And BPM

    # Check for TPM presence on platform
    Verify Presence Of TPM Via Sysfs

    # Check if SHA256 bank is enabled
    ${sha1_state}    ${sha256_state}=    Check Which TPM2 Banks Are Enabled
    Should Be True    ${sha256_state}    SHA256 bank disabled

    # Check SMX support
    ${smx_status}=    Check SMX Support
    Should Be True    ${smx_status}    SMX not supported on DUT's processor

    # Check TXT enabled
    ${txt_status}=    Check TXT Enabled And Lock Bits
    Should Be True    ${txt_status}    TXT not enabled on DUT's processor

    # Check TXT.DIDVID - ew. txt-stat
    ${didvid_status}=    Execute Command In Terminal
    ...    dd if=/dev/mem bs=1 skip=$((0xfed30110)) count=8 2>/dev/null | xxd
    Should Not Contain    ${didvid_status}    0000 0000 0000 0000    TXT hardware not discoverable
    Should Not Contain    ${didvid_status}    ffff ffff ffff ffff    TXT hardware not discoverable

Check SMX Support
    [Documentation]    Check if DUT's CPU supports SMX.
    ${cpuinfo_out}=    Execute Command In Terminal    cat /proc/cpuinfo | grep -o smx
    ${smx_status}=    Run Keyword And Return Status
    ...    Should Not Be Empty    ${cpuinfo_out}
    RETURN    ${smx_status}

Check TXT Enabled And Lock Bits
    [Documentation]    Check if TXT enabled bit and lock bit
    ...    are enabled in IA32_FEATURE_CONTROL
    ${txt_enabled_bits}=    Execute Command In Terminal
    ...    python3 -c \"${MSR_SCRIPT}\"
    RETURN    '${txt_enabled_bits}'=='0x8001'

Check TXT After Measured Launch
    [Documentation]    Check trenchboot-hcl-report
    ...    reference:
    ...    https://github.com/zarhus/meta-trenchboot/tree/master/recipes-tests/trenchboot-hcl-report
    ...    Most importantly - checks if PCRS 17-18 are not 00.. or FF...
    ${txt_report}=    Execute Command In Terminal
    ...    trenchboot-hcl-report
    ${txt_report_success}=    Run Keyword And Return Status
    ...    Should Contain    ${txt_report}    TrenchBoot success: success
    IF    not ${txt_report_success}
        Log To Console    trenchboot-hcl-report failed!
        Fail
    END
    Log To Console    trenchboot-hcl-report success!

Boot From Meta Trenchboot
    [Documentation]    Boot into one of the options from the meta-trenchboot image
    [Arguments]    ${option_index}
    Boot System Or From Connected Disk    ${ENV_ID_TRENCHBOOT}
    ${menu_read}=    Read From Terminal Until    Press enter to boot the selected OS
    Press Key N Times And Enter    ${option_index}    ${ARROW_DOWN}

    TrenchBoot Telnet Root Login
