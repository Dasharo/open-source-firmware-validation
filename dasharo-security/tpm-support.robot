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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Run Ansible Playbook On Supported Operating Systems    tpm-support
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
TPM001.001 TPM Support (firmware)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly and the PCRs can be accessed from the firmware.
    Skip If    not ${TPM_SUPPORT}    TPM001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Cbmem From Cloud
    ${out}=    Execute Command In Terminal    cbmem -L
    Should Contain    ${out}    TPM2 log

TPM001.002 TPM Support (Ubuntu 20.04)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from the Linux OS.
    Skip If    not ${TPM_SUPPORT}    TPM001.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    tpm2-tools
    ${out}=    Execute Command In Terminal    tpm2_pcrread
    Should Contain    ${out}    sha1:
    Should Contain    ${out}    sha256:

TPM001.003 TPM Support (Windows 11)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from Windows.
    Skip If    not ${TPM_SUPPORT}    TPM001.003 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM001.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    get-tpm
    ${tpm_present}=    Get Lines Matching Regexp    ${out}    ^TpmPresent\\s+:\\s.*$
    ${tpm_ready}=    Get Lines Matching Regexp    ${out}    ^TpmReady\\s+:\\s.*$
    ${tpm_enabled}=    Get Lines Matching Regexp    ${out}    ^TpmEnabled\\s+:\\s.*$
    Should Contain    ${tpm_present}    True
    Should Contain    ${tpm_ready}    True
    Should Contain    ${tpm_enabled}    True

TPM001.004 TPM Support (BIOS)
    [Documentation]    This test aims to verify that the TPM is initialized
    ...    correctly
    Skip If    not ${TPM_SUPPORT}    TPM001.004 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM001.004 not supported
    Power On
    ${menu}=    Enter TCG2 Menu And Return Construction
    TPM Version Should Be    ${menu}    tpm2=${TRUE}    tpm1_2=${TRUE}

TPM002.001 Verify TPM version (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    Skip If    not ${TPM_SUPPORT}    TPM002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM002.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cat /sys/class/tpm/tpm0/tpm_version_major
    # TPM 2.0
    Should Contain    ${out}    2

TPM002.002 Verify TPM version (Windows 11)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    Skip If    not ${TPM_SUPPORT}    TPM002.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM002.002 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal
    ...    wmic /namespace:\\\\root\\cimv2\\security\\microsofttpm path win32_tpm get * /format:textvaluelist.xsl
    Should Contain    ${out}    SpecVersion=2.0

TPM003.001 Check TPM Physical Presence Interface (firmware)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is supported by the firmware.
    Skip If    not ${TPM_SUPPORT}    TPM003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Cbmem From Cloud
    ${out}=    Execute Command In Terminal    cbmem -1 | grep PPI
    Should Contain    ${out}    PPI: Pending OS request
    Should Contain    ${out}    PPI: OS response

TPM003.002 Check TPM Physical Presence Interface (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    Skip If    not ${TPM_SUPPORT}    TPM003.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cat /sys/class/tpm/tpm0/ppi/version
    Should Contain    ${out}    1.3

TPM003.003 Check TPM Physical Presence Interface (Windows 11)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    Skip If    not ${TPM_SUPPORT}    TPM003.003 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM003.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    tpmtool getdeviceinformation
    Should Contain    ${out}    PPI Version: 1.3

# TPM003.004 Change active PCR banks with TPM PPI (firmware)
#    [Documentation]    This test aims to verify that the TPM Physical Presence
#    ...    Interface is working properly in the firmware by changing active TPM PCR banks.
#    Skip If    not ${tpm_support}    TPM003.004 not supported
#    Skip If    not ${tests_in_ubuntu_support}    TPM003.004 not supported
# TODO: https://docs.dasharo.com/unified-test-documentation/dasharo-security/200-tpm-support/#tpm003004-change-active-pcr-banks-with-tpm-ppi-firmware

TPM004.001 Check TPM Clear procedure
    [Documentation]    This test aims to verify whether the TPM Clear procedure
    ...    works properly, starts with running TPM Clear procudure to ensure
    ...    correct state of ownership.
    Skip If    not ${TPM_SUPPORT}    TPM004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM004.001 not supported

    Power On
    Run TPM Clear Procedure

    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    tpm2-tools
    Take Ownership Over TPM2 Module
    Check Ownership Of TPM2 Module    0

    Execute Reboot Command
    Run TPM Clear Procedure

    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check Ownership Of TPM2 Module    1

TPM005.001 Check TPM Hash Algorithm Support SHA1 (Firmware)
    [Documentation]    This test aims to verify that the TPM supports needed
    ...    hash algorithms
    Skip If    not ${TPM_SUPPORT}    TPM005.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM005.001 not supported
    Skip If    not ${TPM_FIRMWARE_CONFIG}    TPM005.001 not supported
    Power On
    ${menu}=    Enter TCG2 Menu And Return Construction
    ${hash}=    Get Matches    ${menu}    TPM2 Hardware Supported Hash Algorithm*
    Should Contain Match    ${hash}    *SHA1*

TPM005.002 Check TPM Hash Algorithm Support SHA256 (Firmware)
    [Documentation]    This test aims to verify that the TPM supports needed
    ...    hash algorithms
    Skip If    not ${TPM_SUPPORT}    TPM005.002 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM005.002 not supported
    Skip If    not ${TPM_FIRMWARE_CONFIG}    TPM005.001 not supported
    Power On
    ${menu}=    Enter TCG2 Menu And Return Construction
    ${hash}=    Get Matches    ${menu}    TPM2 Hardware Supported Hash Algorithm*
    Should Contain Match    ${hash}    *SHA256*

TPM005.003 Check TPM Hash Algorithm Support SHA384 (Firmware)
    [Documentation]    This test aims to verify that the TPM supports needed
    ...    hash algorithms
    Skip If    not ${TPM_SUPPORT}    TPM005.003 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM005.003 not supported
    Skip If    not ${TPM_FIRMWARE_CONFIG}    TPM005.001 not supported
    Power On
    ${menu}=    Enter TCG2 Menu And Return Construction
    ${hash}=    Get Matches    ${menu}    TPM2 Hardware Supported Hash Algorithm*
    Should Contain Match    ${hash}    *SHA384*

TPM005.004 Check TPM Hash Algorithm Support SHA512 (Firmware)
    [Documentation]    This test aims to verify that the TPM supports needed
    ...    hash algorithms
    Skip If    not ${TPM_SUPPORT}    TPM005.004 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM005.004 not supported
    Skip If    not ${TPM_FIRMWARE_CONFIG}    TPM005.001 not supported
    Power On
    ${menu}=    Enter TCG2 Menu And Return Construction
    ${hash}=    Get Matches    ${menu}    TPM2 Hardware Supported Hash Algorithm*
    Should Contain Match    ${hash}    *SHA512*

TPM006.001 Encrypt and Decrypt non-rootfs partition (Ubuntu 22.04)
    [Documentation]    Test encrypting and decrypting non-rootfs partition using
    ...    TPM.
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    # 1. Create sealing object:
    Execute Linux Tpm2 Tools Command    tpm2_createprimary -Q -C o -c prim.ctx
    Execute Linux Tpm2 Tools Command    cat key | tpm2_create -Q -g sha256 -u seal.pub -r seal.priv -i- -C prim.ctx
    Execute Linux Tpm2 Tools Command    tpm2_load -Q -C prim.ctx -u seal.pub -r seal.priv -n seal.name -c seal.ctx
    Execute Linux Tpm2 Tools Command    tpm2_evictcontrol -C o -c seal.ctx 0x81010001
    Execute Linux Tpm2 Tools Command    tpm2_unseal -Q -c 0x81010001 > key

    # 2. Test by checking a file stored on the partition:
    Execute Command In Terminal    cryptsetup luksOpen ./test-partition --key-file=key test-partition
    Execute Command In Terminal    mount /dev/mapper/test-partition /mnt
    ${out}=    Execute Command In Terminal    ls /mnt | grep hello-world
    Should Contain    ${out}    hello-world

    # 3. Clean:
    Execute Command In Terminal    umount /mnt
    Execute Command In Terminal    cryptsetup luksClose test-partition
    Execute Command In Terminal    rm -f key seal.* prim.* test-partition
    Execute Linux Tpm2 Tools Command    tpm2_evictcontrol -c 0x81010001

TPM007.001 Encrypt and Decrypt rootfs partition (Ubuntu 22.04)
    [Documentation]    Test encrypting and decrypting rootfs partition using
    ...    TPM. This test assumes that there is another Ubuntu with encrypted
    ...    rootfs connected to the system so it can be booted and two partitions
    ...    with specific labels: EFI partition with label ubuntu-enc and rootfs
    ...    with label encrypted-rootfs.
    Power On
    Enter Setup Menu Tianocore
    Add Boot Option    ubuntu    ubuntu-enc    ubuntu-enc-rootfs
    Save Changes And Reset    2    2

    # 2. Boot to ubuntu with encrypted rootfs:
    Boot System Or From Connected Disk    ubuntu-enc-rootfs
    Unlock Rootfs
    Login To Linux
    Switch To Root User

    # 3. Check needed packages on Ubuntu with encrypted rottfs:
    Detect Or Install Package    tpm2-tools
    Detect Or Install Package    clevis
    Detect Or Install Package    clevis-luks
    Detect Or Install Package    clevis-tpm2
    Detect Or Install Package    clevis-initramfs

    # 4. Bind clevis with the device:
    Execute Command In Terminal
    ...    echo ${UBUNTU_PASSWORD} | clevis luks bind -d /dev/disk/by-label/encrypted-rootfs tpm2 '{"pcr_ids":"0,1,2,3,7"}' -s 1

    # 5. Reboot and wait for the partition to be unlocked:
    Execute Reboot Command
    Boot System Or From Connected Disk    ubuntu-enc-rootfs
    Login To Linux
    Switch To Root User

    # 6. Clean:
    Execute Command In Terminal    clevis luks unbind -d /dev/vda3 -f -s 1
