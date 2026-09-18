*** Comments ***
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0
#
# A power/flash backend for a platform whose "DUT" is a process the
# `benchctl` command itself launches and drives, rather than real hardware
# reachable through an RTE board. Keywords here shell out to `benchctl`.
#
# This deliberately does NOT import osfv.rf.rte_robot.RobotRTE or any other
# osfv_cli hardware-control library: there is no RTE, GPIO, relay or PSU to
# drive here, only a process `benchctl` launches. A platform config that has
# no real RTE already skips importing that library (see keywords.robot's
# `Import Osfv Libraries`, guarded on `${MANUFACTURER}`); this library is
# what such a config uses instead, for the platform's own power/flash
# actions.
#
# This file holds no board-specific knowledge of its own: ${BENCHCTL_BIN}/
# ${BENCHCTL_PLATFORM}/${BENCHCTL_HOST}/${BENCHCTL_FVP_MODEL}/
# ${BENCHCTL_FVP_WORKDIR} all default to empty, and Benchctl Run fails
# clearly, naming the missing one, if ${BENCHCTL_PLATFORM}/
# ${BENCHCTL_HOST}/${BENCHCTL_FVP_MODEL}/${BENCHCTL_FVP_WORKDIR} are still
# empty when a keyword actually needs them - a board config that imports
# this resource must set them.


*** Settings ***
Library    Collections
Library    Process


*** Variables ***
${BENCHCTL_BIN}=                benchctl
${BENCHCTL_PLATFORM}=           ${EMPTY}
${BENCHCTL_HOST}=               ${EMPTY}
${BENCHCTL_FVP_MODEL}=          ${EMPTY}
${BENCHCTL_FVP_WORKDIR}=        ${EMPTY}


*** Keywords ***
Benchctl Run
    [Documentation]    Runs `benchctl` with the given arguments, failing
    ...    with its combined stdout+stderr on a non-zero exit - benchctl
    ...    reports its own errors in plain text there, so that text is the
    ...    whole diagnosis a caller needs.
    [Arguments]    @{args}
    Should Not Be Empty    ${BENCHCTL_PLATFORM}
    ...    BENCHCTL_PLATFORM is not set - the board config must set it
    Should Not Be Empty    ${BENCHCTL_HOST}
    ...    BENCHCTL_HOST is not set - the board config must set it
    Should Not Be Empty    ${BENCHCTL_FVP_MODEL}
    ...    BENCHCTL_FVP_MODEL is not set - the board config must set it
    Should Not Be Empty    ${BENCHCTL_FVP_WORKDIR}
    ...    BENCHCTL_FVP_WORKDIR is not set - the board config must set it
    &{env}=    Create Dictionary
    ...    env:BENCHCTL_PLATFORM=${BENCHCTL_PLATFORM}
    ...    env:BENCHCTL_HOST=${BENCHCTL_HOST}
    ...    env:BENCHCTL_FVP_MODEL=${BENCHCTL_FVP_MODEL}
    ...    env:BENCHCTL_FVP_WORKDIR=${BENCHCTL_FVP_WORKDIR}
    ${result}=    Run Process    ${BENCHCTL_BIN}    @{args}    &{env}
    ...    stderr=STDOUT
    ${argv}=    Catenate    SEPARATOR=${SPACE}    @{args}
    Should Be Equal As Integers    ${result.rc}    0
    ...    benchctl ${argv} failed:\n${result.stdout}
    RETURN    ${result.stdout}

Benchctl Power AC On
    [Documentation]    Turns on the platform's PSU via benchctl utility
    Benchctl Run    power    ac    on

Benchctl Power AC Off
    [Documentation]    Turns off the platform's PSU via benchctl utility
    Benchctl Run    power    ac    off

Benchctl Power On
    [Documentation]    Puts the platform to powered on state via benchctl
    ...    utility
    Benchctl Run    power    on

Benchctl Power Off
    [Documentation]    Puts the platform to powered off state via benchctl
    ...    utility
    Benchctl Run    power    off

Benchctl Power Reset
    [Documentation]    Resets the platform via benchctl utility
    Benchctl Run    power    reset

Benchctl Flash Write
    [Documentation]    Records fw_file as the image the platform boots from
    ...    its next Benchctl Power AC On - a launch-time setting, not a
    ...    live write, so it only takes effect from the next power
    ...    application. Power the platform off first with Benchctl Power AC
    ...    Off if it is already up and needs the new image immediately.
    ...
    ...    Always passes --force: the image is an opaque binary, so there
    ...    is no cheap "does this look right" check worth doing on it
    ...    before writing.
    [Arguments]    ${fw_file}
    Benchctl Run    flash    write    host    ${fw_file}    --force
