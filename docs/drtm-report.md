<!--
SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# DRTM criteria report

`scripts/drtm-report.py` writes the matrix of the criteria of
[drtm-criteria.md](drtm-criteria.md) against one or more runs of the
[TrenchBoot suites](../trenchboot/), each compared with the expected results
of its platform, firmware and kernel, as `report.md` and `report.html`.

```bash
CONFIG=pcengines-apu2 RTE_IP=192.168.10.172 SNIPEIT_NO=1 \
    scripts/run.sh trenchboot
scripts/drtm-report.py logs/pcengines-apu2/merged_2026_11_09_10_00_00 \
    logs/protectli-vp2430/merged_2026_11_09_11_00_00
scripts/drtm-report.py --out /tmp/report \
    logs/pcengines-apu2/merged_2026_11_09_10_00_00,firmware=seabios
scripts/drtm-report.py check
```

The report goes to `logs/drtm-report/` unless `--out` sets another directory.
Only the runs given appear in it: one column per run.

## Runs

A run is the directory `scripts/run.sh` writes, `logs/<CONFIG>/merged_<date>`,
or an `output.xml`. The platform is the `CONFIG`. OSFV records neither the
firmware nor the kernel, so a run takes `dasharo` and `trenchboot`, the kernel
meta-trenchboot builds. A run's path takes `,platform=NAME`, `,firmware=NAME`,
`,kernel=NAME` and `,label=TEXT` after it, which set what the run does not
say, or override it.

## Expectation files

One file per platform, firmware and kernel,
`trenchboot/expectations/<platform>-<firmware>-<kernel>.yaml`. Without one,
every result of the run is unknown, and the report says so.

| File                                       | Platform         | Launch                   |
| ------------------------------------------ | ---------------- | ------------------------ |
| `pcengines-apu2-dasharo-trenchboot.yaml`   | PC Engines apu2  | AMD SKINIT, with the SKL |
| `protectli-vp2430-dasharo-trenchboot.yaml` | Protectli VP2430 | Intel TXT, with SINIT    |

`trenchboot/expectations/references.yaml` holds the known deviations, by ID,
which several files can share. A reference has a `title`, the `requirement` it
deviates from, and a `link` to the code or document that shows it.

A file holds:

| Key            | Meaning                                                                                       |
| -------------- | --------------------------------------------------------------------------------------------- |
| `platform`     | the platform config, the `CONFIG` of the runs                                                 |
| `firmware`     | a name for the firmware, described in `description`                                           |
| `kernel`       | the kernel of the runs                                                                        |
| `evidence`     | the evidence path of the runs, `tpm`                                                          |
| `description`  | what the firmware and the image are                                                           |
| `basis`        | optional, where the expectations come from, for the entries that do not say                   |
| `default`      | optional, the expectation of a test the file does not list: `pass` (the default) or `unknown` |
| `expectations` | the entries, by test ID                                                                       |

An entry is a result, or a mapping:

| Key      | Meaning                                                                |
| -------- | ---------------------------------------------------------------------- |
| `result` | `pass`, `fail`, `skip` or `unknown`                                    |
| `refs`   | IDs in `references.yaml`; required for `fail`                          |
| `basis`  | a suite run with its date, a manual run, or "predicted" with what from |
| `note`   | what a reader of the result needs                                      |

```yaml
expectations:
  WTD010.001: pass
  WTD011.001:
    result: skip
    note: the platform's TPM is a TPM 1.2
```

A result predicted from code says "predicted" in its `basis` until a run shows
it, and the run's date replaces it then.

`scripts/drtm-report.py check` checks the files: their keys, their name, that
every test they list is in `trenchboot/`, the results and the references, and
that an expected failure has a reference.

## Comparing a result

Each result gets one of these verdicts:

- expected: the result is the expectation. A test the file does not list is
  expected to pass, unless `default` is `unknown`;
- regression: the result is worse than the expectation, or a test with no
  entry failed or skipped;
- improved: an expected failure or skip passed, so the entry is out of date;
- unknown: the expectation is `unknown`.

## The report

- Runs: platform, firmware, kernel, evidence, the expectation file and the
  results, with a warning for anything the report had to guess or leave out.
- Regressions: every test whose result is worse than its expectation.
- Matrix: one row per criterion, one column per run. A cell comes from the
  run's checks of the criterion, those with its `criterion:Cnn` tag: failed
  when one failed, passed when one passed, skipped otherwise. A run without
  such checks gives N/A when the Bindings table starts the run's path's cell
  with "N/A", and "not checked" otherwise.
- Drill-down: per criterion and run, its checks, with the result, the
  expectation, the verdict and the message.
- Checks without a criterion, and the known deviations the expectations refer
  to.

The tags come from the suites in this tree, not from the run, so an older run
maps to the criteria too. The report exits with 0 when it has written the
files, whatever the verdicts, and prints the regressions.

## Runs of other suites

`scripts/drtm_report/` is a library. A `Source` describes one tree of DRTM
suites: its criteria document, its suites, its expectation files and how it
reads a run directory. `scripts/drtm_report/trenchboot.py` is the one of this
repository. A repository that has DRTM suites for other platforms, and OSFV as
a submodule, can call `report.main()` with its own `Source` and this one, so
one report shows its runs and the x86 runs side by side. The first `Source`'s
criteria table gives the rows, and the report warns when another's has other
IDs or levels.
