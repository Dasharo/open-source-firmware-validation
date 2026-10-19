# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Runs benchctl with the board config's BENCHCTL_* settings in its environment.

The keyword logs neither the variables it reads nor the environment it builds.
Robot Framework's debug file records every message whatever the log level, and
the environment holds the BMC password.
"""

import os
import subprocess

from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn

# Robot Framework ignores case, spaces and underscores in variable names, so
# ${BENCHCTL_FVPMODEL} sets ${BENCHCTL_FVP_MODEL}. These settings reach benchctl
# under their own name whichever spelling the config uses.
SETTINGS = (
    "BENCHCTL_PLATFORM",
    "BENCHCTL_HOST",
    "BENCHCTL_FVP_MODEL",
    "BENCHCTL_FVP_WORKDIR",
)


def _normalized(name):
    return name.lower().replace("_", "").replace(" ", "")


_SETTING_NAMES = {_normalized(setting): setting for setting in SETTINGS}


def _environment():
    """Returns this process's environment with every scalar ${BENCHCTL_*}
    variable but ${BENCHCTL_BIN} added, upper-cased, spaces as underscores.
    Variables that are empty, ${None} or ${TBD} leave the environment as it
    is."""
    builtin = BuiltIn()
    tbd = builtin.get_variable_value("${TBD}", "")
    env = dict(os.environ)
    for name, value in builtin.get_variables().items():
        if not name.startswith("${"):
            continue
        key = name[2:-1].upper().replace(" ", "_")
        key = _SETTING_NAMES.get(_normalized(key), key)
        if not key.startswith("BENCHCTL_") or key == "BENCHCTL_BIN":
            continue
        if value is None or str(value) in ("", str(tbd)):
            continue
        env[key] = str(value)
    return env


@keyword("Run Benchctl Without Logging")
def run_benchctl_without_logging(binary, *args):
    """Runs binary with args and the BENCHCTL_* settings, and returns its exit
    status and its standard output and error combined."""
    try:
        result = subprocess.run(
            [binary, *args],
            env=_environment(),
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            errors="replace",
            check=False,
        )
    except OSError as error:
        raise RuntimeError(f"cannot run {binary}: {error.strerror}") from None
    return result.returncode, result.stdout.rstrip("\n")
