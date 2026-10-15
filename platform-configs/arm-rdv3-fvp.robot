*** Comments ***
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0
#
# Targets the Arm RD-V3 Fixed Virtual Platform (FVP_RD_V3), running coreboot
# as BL33 (replacing the reference EDK2/UEFI) with LinuxBoot (u-root) as
# coreboot's payload. There is no real bench: the "DUT" is a benchctl-driven
# FVP_RD_V3 process (see ../../benchctl and ../../examples/rdv3-fvp/run.md
# in the loopctl repository, which build it).
#
# Power is driven through ../lib/benchctl.robot - a backend that shells out
# to the real `benchctl` binary - rather than osfv.rf.rte_robot.RobotRTE:
# there is no RTE, GPIO, relay or PSU here, only a process benchctl itself
# launches.
#
# NOTE: `Import Osfv Libraries` in keywords.robot (which imports
# osfv.rf.rte_robot.RobotRTE) is only skipped when ${MANUFACTURER} == 'QEMU'
# (or ${CONFIG} == 'no-rte'). This config currently sets ${MANUFACTURER} to
# 'ARM', which does NOT skip that import - flag this before relying on it:
# either set ${MANUFACTURER} back to 'QEMU' (the sentinel qemu.robot itself
# uses, for the same "no real RTE/SnipeIt inventory entry" reason), or
# extend that guard in keywords.robot to also recognize this config.
#
# This suite is self-sufficient standalone: `Power On` (below) applies AC
# and starts firmware execution itself, the same "get to a known state" a
# `Power On` keyword provides everywhere else. Flashing also goes through
# the standard `Flash Firmware` keyword (lib/flash.robot) via
# ${FLASHING_METHOD}=benchctl, in addition to `Benchctl Flash Write`
# directly - but is still a deliberate, explicit action a suite or operator
# takes once, not something every test case repeats.
#
# Invoke with:
#    robot -v snipeit:no -v config:arm-rdv3-fvp -v rte_ip:127.0.0.1 \
#    -v benchctl_fvp_model:/path/to/FVP_RD_V3 \
#    -v benchctl_fvp_workdir:/path/to/a/workdir <suite>.robot
# 127.0.0.1 is already registered as RTE48 in variables.robot, shared with
# qemu.robot - no new hardware-inventory entry is needed for a virtual
# platform. Neither ${BENCHCTL_FVP_MODEL} nor ${BENCHCTL_FVP_WORKDIR} has a
# default here (see the Variables section below): both are deployment-
# specific, so both must come from the command line as shown above.


*** Settings ***
Resource    include/default.robot
Resource    ../lib/benchctl.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       Telnet
${DUT_CONNECTION_METHOD}=               ${INITIAL_DUT_CONNECTION_METHOD}
${RTE_S2_N_PORT}=                       6000
${MANUFACTURER}=                        ARM
${POWER_CTRL}=                          benchctl
${FLASHING_METHOD}=                     benchctl

${BENCHCTL_PLATFORM}=                   fvp
${BENCHCTL_HOST}=                       localhost
# Neither the model binary path nor the workdir (pidfile, logs, recorded
# flash image) is set here: both are deployment-specific, so both come from
# the command line, e.g. `-v benchctl_fvp_model:/path/to/FVP_RD_V3
# -v benchctl_fvp_workdir:/path/to/a/workdir`.

# LinuxBoot payload: drive the firmware-specific boot flow via the LinuxBoot
# payload library instead of the default EDK2/Tianocore one, same as
# asrock-turind8ud-linuxboot.robot.
${PAYLOAD}=                             linuxboot
${PAYLOAD_LIB}=                         payload-lib_linuxboot
${TESTS_IN_LINUXBOOT_SUPPORT}=          ${TRUE}
${TESTS_IN_FIRMWARE_SUPPORT}=           ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=             ${FALSE}
${DUT_HAS_CMOS_RESET}=                  ${FALSE}
${DUT_HAS_POWER_BUTTON}=                ${FALSE}

${BASE_PORT_BOOTBLOCK_SUPPORT}=         ${TRUE}
${BASE_PORT_ROMSTAGE_SUPPORT}=          ${TRUE}    # TODO: confirm this arm64 target has a distinct romstage
${BASE_PORT_POSTCAR_SUPPORT}=           ${FALSE}    # x86-only cache-as-RAM teardown; presumed not applicable
${BASE_PORT_RAMSTAGE_SUPPORT}=          ${TRUE}

# dmidecode.robot / cosmetic identification - a real port replaces these
${MANUFACTURER_VERIFICATION}=           ${FALSE}    # TODO: enable once real DMI values are known
${DMIDECODE_VENDOR}=                    3mdeb
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+LinuxBoot) RDV3 v0.0.0
${DMIDECODE_PRODUCT_NAME}=              Arm RD-V3 (FVP_RD_V3)
${DMIDECODE_MANUFACTURER}=              Arm


*** Keywords ***
Power On
    [Documentation]    Implementation of keywords.Power On. Applies AC (a
    ...    no-op if already applied - see Benchctl Power AC On) and starts
    ...    firmware execution: always a fresh boot, never a resume (see
    ...    Benchctl Power On), the same "get to a known state" contract
    ...    every other platform config's Power On has, qemu.robot's own
    ...    System Reset included.
    Benchctl Power AC On
    Benchctl Power On
    Read From Terminal

Power Off
    [Documentation]    Implementation of keywords.Power Off. Stops firmware
    ...    execution; the model process stays up, paused, for a later
    ...    Power On - does not tear the process down (Benchctl Power AC
    ...    Off does that, and is only needed to pick up a new flashed
    ...    image or to free the port a test run is done with).
    Benchctl Power Off
