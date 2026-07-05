<!--
SPDX-FileCopyrightText: 2026 Amey Pawar <ameyap007aaa@gmail.com>

SPDX-License-Identifier: Apache-2.0
-->

# Documentation build test

A proof-of-concept harness that reads a Dasharo build manual from
`docs.dasharo.com`, resolves the exact commands a reader would run to build
one firmware variant, and checks the result against the published release.

It is a first step towards
[dasharo-issues#1153](https://github.com/Dasharo/dasharo-issues/issues/1153):
_"Create automatic tests of Dasharo build documentation"_. The goal of that
issue is to verify that following the documentation - as a person would,
not as a hand-maintained CI script would - reproduces every historic release
for every supported device.

## The problem: build manuals are decision trees

A `building-manual.md` page is authored for MkDocs Material. It is not a
linear script; it is a decision tree built out of `pymdownx.tabbed` content
tabs, admonitions and fenced code blocks. A single page routinely encodes
several mutually exclusive branches at once:

```text
=== "Dasharo (UEFI)"
    === "PRO Z690-A (WIFI) DDR4"
        ./build.sh z690a_ddr4
    === "PRO Z690-A (WIFI)"
        ./build.sh z690a_ddr5
=== "Dasharo (coreboot + Heads)"
    ...
```

Off-the-shelf "runnable docs" tools such as `codedown`, `doc-detective` and
`tuttest` extract _every_ fenced block on the page and run them in order. On
the page above that means running the DDR4 build, the DDR5 build and the Heads
build back to back - incompatible branches concatenated into one broken
script. This is why a plain run of such a tool against the Dasharo docs has
mostly failed in earlier experiments on the issue.

This harness instead resolves a _single path_ through the tree. Tab
resolution follows MkDocs' own `content.tabs.link` semantics: tabs that share
a title are the same choice, so a device selected once applies to every tab
group that offers it.

## What the harness does

The parser (`mkdocs_build_extractor.py`) turns a manual into build recipes.
The CLI (`doc_build_test.py`) exposes five subcommands:

- `list` - enumerate every build target (leaf path) the page describes.
- `extract` - print the ordered commands, expected artifact and caveats for
  one selection, with version placeholders substituted.
- `script` - emit a standalone, fail-fast shell script for one selection.
- `verify` - compare a locally built binary against a published release.
- `diagnose` - report documentation issues that block automated testing.

The parser and its tests use only the Python standard library, so they run in
CI with no extra dependencies and never touch the network.

## Reproducibility check: sha256, then romscope

The issue asks whether a build is "identical to the ones we publish". A naive
`sha256` equality check is not enough, and using it alone would report a
failure on almost every real build. Dasharo release binaries are signed with
the 3mdeb Vboot key while a local build is not, so the `VBLOCK` and `GBB`
regions legitimately differ. This is documented in the
[reproducible build verification guide](https://docs.dasharo.com/guides/reproducible-build-verification/).

`verify` therefore returns three verdicts:

- `IDENTICAL` - the binaries match byte for byte.
- `REPRODUCIBLE_MODULO_SIGNATURE` - they differ only in signed regions, as
  determined by [romscope](https://github.com/Dasharo/romscope) `compare`.
- `DIFFERS` - a real, functional difference.

The romscope comparison is delegated to an injected runner, which keeps the
verdict logic unit-testable without a romscope binary or Docker present.

## What it reveals in the current docs

Run against the live MSI building manual, the harness already surfaces three
classes of documentation issue - exactly the kind of human-error faults the
issue is about - without any change to the docs:

- _Version-conditional prose._ The UEFI build tab hides a
  "For v1.1.1 and older / For v1.1.2 and newer" choice in prose rather than in
  a tab, so the resolved recipe contains two mutually exclusive `build.sh`
  commands. A machine cannot pick one without parsing the prose.
- _Unlinkable tabs._ In the Heads branch the checkout step labels a device
  `PRO Z690-A` while the build step labels it `PRO Z690-A (WIFI) DDR4`.
  Because the labels differ, the two tab groups cannot be linked, and
  enumeration produces device combinations that make no sense.
- _Unresolvable choices._ Selecting a firmware type but omitting a required
  device choice is reported as an ambiguous path, listing the options that
  still need a decision.

The `diagnose` subcommand reports all of these for a page and exits non-zero
when any are found, so it can gate CI. On the current MSI manual it reports
eight issues across the three classes above.

## Usage

```bash
# List every build target in a manual
./doc_build_test.py list building-manual.md

# Resolve one build and print its commands
./doc_build_test.py extract building-manual.md \
    --select "Dasharo (UEFI)" \
    --select "PRO Z690-A (WIFI) DDR4" \
    --version 1.1.3 --revision msi_ms7d25_v1.1.3

# Emit a runnable build script for one selection
./doc_build_test.py script building-manual.md \
    --select "Dasharo (UEFI)" --select "PRO Z690-A (WIFI) DDR4" \
    --version 1.1.3 --revision msi_ms7d25_v1.1.3 -o build.sh

# Compare a locally built binary against a published release
./doc_build_test.py verify --built out.rom --published release.rom \
    --romscope ./romscope

# Report documentation issues that block automated testing
./doc_build_test.py diagnose building-manual.md
```

## Scope and limitations

This is a proof of concept focused on the deterministic, testable core:
turning a tabbed manual into a single correct build recipe and deciding a
reproducibility verdict. Deliberately out of scope for now:

- _Running the build._ Building firmware needs Docker and takes minutes per
  target; the issue itself flags CI time as a concern. `script` produces a
  runnable recipe, but actually executing it and downloading release binaries
  is left to a follow-up, run outside pull-request CI.
- _Release discovery._ Mapping a device to its published releases and hashes
  (from the per-device `releases.md` pages) is a follow-up.
- _Placeholder substitution_ handles the common `X.Y.Z`, `VERSION` and
  `REVISION` tokens; richer templating is a follow-up.

## Relation to existing work

- Test specifications `[BNO] Build on a fresh OS Installation` and
  `[FLB] Firmware locally building and flashing` describe the manual
  procedure this harness is meant to automate.
- The build script trialled in
  [coreboot#579](https://github.com/Dasharo/coreboot/pull/579) and the manual
  copy in
  [osfv#545](https://github.com/Dasharo/open-source-firmware-validation/pull/545)
  both hard-code the build steps. This harness reads them from the docs
  instead, so the test and the documentation cannot drift apart.

## Running the self-tests

```bash
python3 -m unittest discover -s scripts/ci/doc-build-test \
    -t scripts/ci/doc-build-test -p "*_selftests.py"
```

The suite uses inlined markdown fixtures that reproduce the real nesting of
the Dasharo manuals, so it needs no network access and no repository
checkout of the docs.
