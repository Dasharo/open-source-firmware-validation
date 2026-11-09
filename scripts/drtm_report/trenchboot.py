# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""The Source of the TrenchBoot suites, trenchboot/, on Intel TXT and AMD
SKINIT.

A run is the directory scripts/run.sh writes, logs/<CONFIG>/merged_<date>,
whose merged_out.xml holds the results. The platform is the CONFIG. OSFV
records neither the firmware nor the kernel, so a run takes dasharo and
trenchboot, the kernel meta-trenchboot builds, unless ,firmware= and ,kernel=
set them.
"""

from pathlib import Path

from .report import RunInfo, Source

OSFV = Path(__file__).resolve().parents[2]
DEFAULTS = {"firmware": "dasharo", "kernel": "trenchboot"}


def load_dir(path, overrides):
    """The RunInfo of an OSFV run directory, logs/<CONFIG>/merged_<date>, or
    None when ``path`` is not one."""
    output = path / "merged_out.xml"
    if not path.name.startswith("merged_") or not output.is_file():
        return None
    return RunInfo(
        outputs=[output],
        platform=path.parent.name,
        date=path.name.removeprefix("merged_"),
    )


def defaults(key, info):
    return DEFAULTS.get(key)


SOURCE = Source(
    name="OSFV",
    root=OSFV,
    criteria_doc=OSFV / "docs/drtm-criteria.md",
    suite_dirs=[OSFV / "trenchboot"],
    expectations_dir=OSFV / "trenchboot/expectations",
    evidences=("tpm",),
    load_dir=load_dir,
    defaults=defaults,
)
