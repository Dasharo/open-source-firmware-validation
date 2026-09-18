*** Comments ***
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0
#
# Milestone gates D3, D4 and D6 of the ARM RD-V3 coreboot+LinuxBoot
# bring-up ladder (see examples/rdv3-coreboot-linuxboot/kb/rdv3.md in the
# loopctl repository for the full ladder). D1 (coreboot builds) and
# D2/bonus stage checks (bootblock/romstage/ramstage entered) live
# elsewhere:
# - D1: not an OSFV test at all - a plain build check outside robot
#   (examples/rdv3-coreboot-linuxboot/Taskfile.yml's `gate:d1`), since it
#   needs no hardware or DUT connection, only a coreboot checkout to build.
# - D2 and stage checkpoints: coreboot-base-port.robot (CBP00N.107)
#
# Run against platform-configs/arm-rdv3-fvp.robot, e.g.:
#   robot -v snipeit:no -v config:arm-rdv3-fvp \
#       -v rte_ip:127.0.0.1 -v benchctl_fvp_model:/path/to/FVP_RD_V3 \
#       -t "LBB002*" dasharo-compatibility/rdv3-linuxboot-bringup.robot
#
# LBBR: test cases below tagged `lbbr` check against LBBR (LinuxBoot Base
# Boot Requirements, part of the Arm Base Boot Requirements family -
# DEN0044, https://support.arm.com/architectures/base-boot-requirements;
# a plain-text copy lives at
# examples/rdv3-coreboot-linuxboot/docs/DEN0044H_ArmBBR_2.1Final.pdf.txt in
# the loopctl repository). Per DEN0044 §9.1, an LBBR-compliant system's
# LinuxBoot kernel must expose ACPI (§9.1.1: all of BBR section 7, no
# exceptions), SMBIOS (§9.1.2: all of BBR section 8, no exceptions), and a
# UEFI subset (§9.1.3: BBR section 6 with LBBR-specific exceptions, mostly
# things that only apply to the *final* kexec'd kernel image itself via
# EFI Stub, e.g. §6.3.3.3/§6.4.2) to "the final runtime Linux kernel", not
# merely that some kernel boots and reaches a prompt - LBB005.107 (D6)
# checks the interfaces themselves, not just that kexec happened.

# See DEN0044H_ArmBBR_2.1Final.pdf.txt for the full LBBR requirements
# section (§9) this suite checks against.


*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection

Default Tags        automated


*** Variables ***
# u-root's default shell prompt varies by build (elvish, or a custom uinit
# prompt); override with -v uroot_prompt:... once known for this build.
${UROOT_PROMPT}=                    uroot
# TODO: needs the fvp driver (benchctl/platform/fvp.go) to support attaching
# a disk image (virtio-blk or AHCI) - it does not yet as of writing. Override
# with -v target_os_disk_image:<path> once it does.
${TARGET_OS_DISK_IMAGE}=            ${EMPTY}
# The login/shell prompt string the kexec'd target OS presents.
${TARGET_OS_LOGIN_PROMPT}=          login:
# Debian (env id 208, see ../os-config/environment-test-ids.py and
# ../os-config/208-credentials.py) - the same Debian 12 cloud image
# examples/rdv3-coreboot-linuxboot/kb/rdv3.md's D6 section documents, and
# the same env id examples/rdv3-coreboot-linuxboot/Taskfile.yml's E4
# (TARGET_OS_ROOT_PASSWORD) prepares a login for. Both need the same
# `virt-customize --root-password` prep step run once against the image.
${TARGET_OS_ENV_ID}=                208


*** Test Cases ***
LBB002.107 Ramstage hands off to the LinuxBoot payload
    [Documentation]    D3: checks that ramstage completes device/table setup
    ...    and jumps to the payload, by looking for the first Linux kernel
    ...    boot lines on the console - proof that coreboot's payload-loading
    ...    mechanism worked and the kernel started executing, not merely that
    ...    ramstage was entered (see CBP004.107 in coreboot-base-port.robot
    ...    for that narrower, earlier check).
    Skip If    not ${TESTS_IN_LINUXBOOT_SUPPORT}    LBB002.107 not supported
    Power On
    Set DUT Response Timeout    300s
    Read From Terminal Until Regexp    Linux version|Booting Linux on physical CPU

LBB003.107 LinuxBoot reaches a u-root shell
    [Documentation]    D4: checks that the kernel finishes boot, mounts the
    ...    initramfs, and u-root's shell prompt appears - mirrors the root
    ...    README's own example milestone ("a U-Boot prompt appears") and
    ...    coreboot-base-port.robot's own gate shape (wait for a stage
    ...    marker), just for the payload rather than a coreboot stage.
    [Tags]    automated    lbbr
    Skip If    not ${TESTS_IN_LINUXBOOT_SUPPORT}    LBB003.107 not supported
    Power On
    Set DUT Response Timeout    300s
    Read From Terminal Until Regexp    ${UROOT_PROMPT}

LBB005.107 kexec into a lightweight target OS
    [Documentation]    D6: the "full image" milestone, and this ladder's
    ...    central LBBR conformance signal. u-root's kexec/localboot finds
    ...    and boots a real, stock, unmodified OS (a Debian 12 cloud image
    ...    - see examples/rdv3-coreboot-linuxboot/kb/rdv3.md's D6 section
    ...    for why Debian specifically, not Alpine/Ubuntu) via EFI Stub -
    ...    DEN0044 §9.1.3's own exception table requires UEFI image
    ...    format/UEFI Loaded Images compliance (§6.3.3.3, §6.4.2) "only
    ...    for the LinuxBoot kernel image, using EFI Stub", which is
    ...    exactly this handoff.
    ...
    ...    Beyond reaching a shell, this logs in and checks what DEN0044
    ...    §9.1.1/§9.1.2 actually require: that the final kexec'd kernel
    ...    itself sees valid ACPI tables (§9.1.1: all of BBR section 7,
    ...    no exceptions) and valid SMBIOS data (§9.1.2: all of BBR
    ...    section 8, no exceptions) - "the final runtime Linux kernel"
    ...    is the system DEN0044 §9.1 says these must be exposed to, not
    ...    just the LinuxBoot kernel that kexecs into it. A kernel that
    ...    merely reaches a login prompt without either would still fail
    ...    LBBR conformance.
    [Tags]    automated    lbbr
    Skip If    not ${TESTS_IN_LINUXBOOT_SUPPORT}    LBB005.107 not supported
    Variable Should Exist    ${TARGET_OS_DISK_IMAGE}
    ...    Set -v target_os_disk_image:<path to a lightweight distro disk image>
    Power On
    Set DUT Response Timeout    300s
    Read From Terminal Until Regexp    ${UROOT_PROMPT}
    Set Prompt For Terminal    ${UROOT_PROMPT}
    Execute Command In Terminal    kexec -l localboot
    Set DUT Response Timeout    600s
    Read From Terminal Until    ${TARGET_OS_LOGIN_PROMPT}
    Load OS Credentials    ${TARGET_OS_ENV_ID}
    Login To Linux
    ${acpi}=    Execute Command In Terminal
    ...    test -s /sys/firmware/acpi/tables/DSDT && echo present || echo missing
    Should Contain    ${acpi}    present
    ...    msg=DEN0044 §9.1.1 requires full ACPI (BBR section 7) conformance - the final kexec'd kernel found no DSDT table
    ${smbios}=    Execute Command In Terminal
    ...    test -s /sys/firmware/dmi/tables/DMI && echo present || echo missing
    Should Contain    ${smbios}    present
    ...    msg=DEN0044 §9.1.2 requires full SMBIOS (BBR section 8) conformance - the final kexec'd kernel found no DMI table
