*** Comments ***
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0
#
# A power/flash backend for a platform that the `benchctl` command drives
# without an RTE board: a process benchctl launches, such as the FVP, or a host
# benchctl reaches through its BMC. Keywords here shell out to `benchctl`.
#
# This deliberately does NOT import osfv.rf.rte_robot.RobotRTE or any other
# osfv_cli hardware-control library: there is no RTE, GPIO, relay or PSU to
# drive here, only what `benchctl` drives. A platform config that has
# no real RTE already skips importing that library (see keywords.robot's
# `Import Osfv Libraries`, guarded on `${MANUFACTURER}`); this library is
# what such a config uses instead, for the platform's own power/flash
# actions.
#
# This file holds no board-specific knowledge of its own. A board config that
# imports it sets ${BENCHCTL_PLATFORM}, ${BENCHCTL_HOST} and the settings its
# benchctl platform reads, as ${BENCHCTL_*} variables. Benchctl Run passes
# every set ${BENCHCTL_*} variable other than ${BENCHCTL_BIN} to benchctl as
# the environment variable of the same name, upper-cased, through benchctl.py,
# which logs neither the variables nor the environment. Prepare Test Suite logs
# every robot variable, so a credential stays out of the log and the debug file
# when it reaches benchctl from the environment. It fails, naming the missing
# setting, when ${BENCHCTL_PLATFORM} or ${BENCHCTL_HOST} is empty, ${None} or
# ${TBD}, and on the fvp platform when ${BENCHCTL_FVP_MODEL} or
# ${BENCHCTL_FVP_WORKDIR} is.


*** Settings ***
Library     benchctl.py


*** Variables ***
${BENCHCTL_BIN}=            benchctl
${BENCHCTL_PLATFORM}=       ${EMPTY}
${BENCHCTL_HOST}=           ${EMPTY}
${BENCHCTL_FVP_MODEL}=      ${EMPTY}
${BENCHCTL_FVP_WORKDIR}=    ${EMPTY}


*** Keywords ***
Benchctl Run
    [Documentation]    Runs `benchctl` with the given arguments, failing
    ...    with its combined stdout+stderr on a non-zero exit - benchctl
    ...    reports its own errors in plain text there, so that text is the
    ...    whole diagnosis a caller needs.
    ...
    ...    benchctl gets every scalar ${BENCHCTL_*} variable except
    ...    ${BENCHCTL_BIN} that is neither empty, ${None} nor ${TBD}, as
    ...    the environment variable of the same name, upper-cased, from
    ...    Run Benchctl Without Logging in benchctl.py. That keyword logs
    ...    neither the variables nor the environment. A credential from
    ...    the environment therefore stays out of the log.
    [Arguments]    @{args}
    Benchctl Check Setting    BENCHCTL_PLATFORM
    Benchctl Check Setting    BENCHCTL_HOST
    IF    $BENCHCTL_PLATFORM == 'fvp'    Benchctl Check FVP Settings
    VAR    ${argv}=    @{args}    separator=${SPACE}
    Log    benchctl ${argv}
    ${rc}    ${output}=    Run Benchctl Without Logging    ${BENCHCTL_BIN}    @{args}
    Should Be Equal As Integers    ${rc}    0
    ...    benchctl ${argv} failed:\n${output}    values=False
    RETURN    ${output}

Benchctl Check FVP Settings
    [Documentation]    Fails, naming the missing setting, unless the board
    ...    config sets the model binary and the work directory the fvp
    ...    platform runs the model with.
    Benchctl Check Setting    BENCHCTL_FVP_MODEL
    Benchctl Check Setting    BENCHCTL_FVP_WORKDIR

Benchctl Check Setting
    [Documentation]    Fails, naming the setting, when the variable is unset,
    ...    empty, ${None} or ${TBD}.
    [Arguments]    ${name}
    ${value}=    Get Variable Value    \${${name}}    ${EMPTY}
    ${tbd}=    Get Variable Value    \${TBD}    ${EMPTY}
    IF    $value is None or $value in ('', $tbd)
        Fail    ${name} is not set - the board config must set it
    END

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
