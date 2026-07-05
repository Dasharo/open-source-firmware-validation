#!/usr/bin/env python

# SPDX-FileCopyrightText: 2026 Amey Pawar <ameyap007aaa@gmail.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Self-tests for the documentation build extractor.

Fixtures are inlined as string literals (mirroring
``scripts/ci/regression-scope/regression_scope_selftests.py``) so the sample
docs are not reformatted by the repository's markdownlint hook.  They reproduce
the real nesting of ``docs.dasharo.com`` building manuals: firmware-type tabs,
linked device tabs that repeat across tab groups, admonition caveats, version
placeholders and prose artifact declarations.
"""

import os
import tempfile
import unittest

import mkdocs_build_extractor as ext

# A faithful trim of docs/unified/msi/building-manual.md: a UEFI branch whose
# device choice appears in *two* linked tab groups (source checkout + build),
# plus a separate Heads branch with a different device set.
MSI_DOC = """\
# Building manual

=== "Dasharo (UEFI)"

    ## Procedure

    Obtain Dasharo source code:

    === "PRO Z690-A DDR4"
        > Replace the `REVISION` with `msi_ms7d25_vVERSION`.

    === "PRO Z690-A DDR5"
        > Replace the `REVISION` with `msi_ms7d25_vVERSION`.

    ```bash
    git clone https://github.com/Dasharo/coreboot.git -b REVISION
    cd coreboot
    ```

    Start the build process:

    === "PRO Z690-A DDR4"
        ```bash
        ./build.sh z690a_ddr4
        ```

        The resulting Dasharo firmware image will be placed at `$PWD/msi_ms7d25_VERSION_ddr4.rom`.

    === "PRO Z690-A DDR5"
        ```bash
        ./build.sh z690a_ddr5
        ```

        The resulting Dasharo firmware image will be placed at `$PWD/msi_ms7d25_VERSION_ddr5.rom`.

=== "Dasharo (coreboot + Heads)"

    ## Building

    1. Clone Dasharo Heads repository

        ```bash
        git clone https://github.com/Dasharo/heads.git
        cd heads
        ```

    === "PRO Z690-A"
        ```bash
        git checkout msi_ms7d25_v0.9.0
        BOARD=msi_z690a_ddr4 make
        ```
"""

# A trim exercising package-manager tabs inside an admonition-bearing path and
# a multi-line docker invocation with backslash continuation.
NOVA_DOC = """\
# Dasharo firmware building guide

=== "Dasharo (UEFI)"

    - Git

        === "APT package manager"

            ```bash
            sudo apt -y install git
            ```

        === "DNF package manager"

            ```bash
            sudo dnf -y install git
            ```

    1. Clone the Dasharo coreboot repository:

        ```bash
        git clone https://github.com/Dasharo/coreboot.git
        cd coreboot
        ```

    !!! warning

        Releases earlier than October 2023 might not build in custom shells.

    1. Start docker container:

        ```bash
        docker run --rm -it -u $UID \\
           -v $PWD:/home/coreboot/coreboot \\
           -w /home/coreboot/coreboot \\
           coreboot/coreboot-sdk:2023-11-24 /bin/bash
        ```

        This will produce a Dasharo binary placed in `build/coreboot.rom`.
"""


# A compact doc reproducing the three defects the real MSI manual contains:
# a version choice hidden in prose, two build commands on one path, and a
# device labelled differently between the checkout and build steps.
DEFECTIVE_DOC = """\
# Building manual

=== "Dasharo (UEFI)"

    Obtain source:

    === "PRO Z690-A DDR4"
        ```bash
        git clone https://github.com/Dasharo/coreboot.git -b REVISION
        ```

    Start the build process:

    === "PRO Z690-A DDR4"
        For v1.1.1 and older:

        ```bash
        ./build.sh ddr4
        ```

        For v1.1.2 and newer:

        ```bash
        ./build.sh z690a_ddr4
        ```

=== "Dasharo (coreboot + Heads)"

    Checkout:

    === "PRO Z690-A"
        ```bash
        git checkout msi_ms7d25_heads_v0.9.0
        ```

    Inside the container:

    === "PRO Z690-A (WIFI) DDR4"
        ```bash
        BOARD=msi_z690a_ddr4 make
        ```
"""


class TestParsing(unittest.TestCase):
    def test_top_level_is_prose_then_group(self):
        nodes = ext.parse(MSI_DOC)
        self.assertIsInstance(nodes[0], ext.Prose)
        self.assertIsInstance(nodes[1], ext.TabGroup)
        self.assertEqual(
            nodes[1].titles,
            ["Dasharo (UEFI)", "Dasharo (coreboot + Heads)"],
        )

    def test_code_fence_is_dedented(self):
        nodes = ext.parse(MSI_DOC)
        uefi = nodes[1].tabs[0]
        fences = [n for n in uefi.children if isinstance(n, ext.CodeBlock)]
        self.assertTrue(fences)
        self.assertIn(
            "git clone https://github.com/Dasharo/coreboot.git", fences[0].code
        )
        self.assertFalse(fences[0].code.startswith(" "))


class TestEnumeration(unittest.TestCase):
    def test_linked_tabs_do_not_multiply_targets(self):
        # UEFI: 2 devices (linked across 2 groups) -> 2 targets, not 4.
        # Heads: 1 device -> 1 target. Total 3.
        targets = ext.list_targets(MSI_DOC)
        self.assertEqual(len(targets), 3)

    def test_target_selections(self):
        targets = ext.list_targets(MSI_DOC)
        selections = sorted(" / ".join(t.selections) for t in targets)
        self.assertEqual(
            selections,
            [
                "Dasharo (UEFI) / PRO Z690-A DDR4",
                "Dasharo (UEFI) / PRO Z690-A DDR5",
                "Dasharo (coreboot + Heads) / PRO Z690-A",
            ],
        )


class TestSinglePathResolution(unittest.TestCase):
    def test_selects_one_branch_only(self):
        recipe = ext.resolve(
            MSI_DOC,
            select=["Dasharo (UEFI)", "PRO Z690-A DDR4"],
            version="1.1.3",
            revision="msi_ms7d25_v1.1.3",
        )
        self.assertEqual(
            recipe.commands,
            [
                "git clone https://github.com/Dasharo/coreboot.git -b msi_ms7d25_v1.1.3",
                "cd coreboot",
                "./build.sh z690a_ddr4",
            ],
        )
        # The mutually exclusive DDR5 branch must never leak into the recipe.
        self.assertNotIn("./build.sh z690a_ddr5", recipe.commands)

    def test_shared_step_present_in_all_paths(self):
        for device in ("PRO Z690-A DDR4", "PRO Z690-A DDR5"):
            recipe = ext.resolve(MSI_DOC, select=["Dasharo (UEFI)", device])
            self.assertIn(
                "git clone https://github.com/Dasharo/coreboot.git -b REVISION",
                recipe.commands,
            )

    def test_artifact_extraction_and_version_substitution(self):
        recipe = ext.resolve(
            MSI_DOC,
            select=["Dasharo (UEFI)", "PRO Z690-A DDR5"],
            version="1.1.3",
            revision="msi_ms7d25_v1.1.3",
        )
        self.assertEqual(recipe.artifacts, ["$PWD/msi_ms7d25_1.1.3_ddr5.rom"])

    def test_version_without_revision_is_rejected(self):
        # The MSI clone step is `-b REVISION`; asking for a version but no
        # revision leaves an unresolved placeholder and must not silently ship.
        with self.assertRaises(ValueError):
            ext.resolve(
                MSI_DOC,
                select=["Dasharo (UEFI)", "PRO Z690-A DDR4"],
                version="1.1.3",
            )

    def test_heads_branch_is_independent(self):
        recipe = ext.resolve(
            MSI_DOC, select=["Dasharo (coreboot + Heads)", "PRO Z690-A"]
        )
        self.assertIn("git checkout msi_ms7d25_v0.9.0", recipe.commands)
        self.assertIn("BOARD=msi_z690a_ddr4 make", recipe.commands)
        self.assertNotIn("./build.sh z690a_ddr4", recipe.commands)

    def test_missing_choice_is_ambiguous(self):
        with self.assertRaises(ext.AmbiguousSelection) as ctx:
            ext.resolve(MSI_DOC, select=["Dasharo (UEFI)"])
        self.assertEqual(ctx.exception.options, ["PRO Z690-A DDR4", "PRO Z690-A DDR5"])


class TestAdmonitionAndContinuation(unittest.TestCase):
    def test_package_manager_choice_and_caveat(self):
        recipe = ext.resolve(NOVA_DOC, select=["Dasharo (UEFI)", "APT package manager"])
        self.assertIn("sudo apt -y install git", recipe.commands)
        self.assertNotIn("sudo dnf -y install git", recipe.commands)
        self.assertEqual(recipe.caveats, ["warning"])
        self.assertEqual(recipe.artifacts, ["build/coreboot.rom"])

    def test_backslash_continuation_stays_single_command(self):
        recipe = ext.resolve(NOVA_DOC, select=["Dasharo (UEFI)", "DNF package manager"])
        docker = [c for c in recipe.commands if c.startswith("docker run")]
        self.assertEqual(len(docker), 1)
        self.assertIn("coreboot/coreboot-sdk:2023-11-24 /bin/bash", docker[0])


class TestFenceHandling(unittest.TestCase):
    def test_unlabeled_output_fence_is_not_a_command(self):
        doc = (
            "# Build\n\n"
            "```bash\n./build.sh board\n```\n\n"
            "Expected output:\n\n"
            "```\nBuild complete\nFirmware size: 16M\n```\n"
        )
        recipe = ext.resolve(doc, select=[])
        self.assertEqual(recipe.commands, ["./build.sh board"])

    def test_attribute_list_fence_is_shell(self):
        doc = "# Build\n\n```{.bash .no-copy}\n./build.sh board\n```\n"
        recipe = ext.resolve(doc, select=[])
        self.assertEqual(recipe.commands, ["./build.sh board"])


class TestScriptRendering(unittest.TestCase):
    def test_script_is_fail_fast_and_ordered(self):
        recipe = ext.resolve(
            MSI_DOC,
            select=["Dasharo (UEFI)", "PRO Z690-A DDR4"],
            version="1.1.3",
            revision="msi_ms7d25_v1.1.3",
        )
        script = ext.to_script(recipe)
        self.assertIn("set -euo pipefail", script)
        self.assertLess(
            script.index("git clone"), script.index("./build.sh z690a_ddr4")
        )


class TestVerify(unittest.TestCase):
    def _write(self, data):
        fd, path = tempfile.mkstemp()
        os.write(fd, data)
        os.close(fd)
        self.addCleanup(os.remove, path)
        return path

    def test_identical_binaries(self):
        a = self._write(b"same-bytes")
        b = self._write(b"same-bytes")
        self.assertEqual(ext.verify(a, b).verdict, ext.IDENTICAL)

    def test_real_difference(self):
        a = self._write(b"one")
        b = self._write(b"two")
        result = ext.verify(a, b)
        self.assertEqual(result.verdict, ext.DIFFERS)
        self.assertEqual(result.romscope_report, "")

    def test_differ_surfaces_romscope_report_without_classifying_it(self):
        a = self._write(b"built")
        b = self._write(b"published")

        def fake_romscope(published, built):
            return "String differences: build_info\nCompression differences"

        result = ext.verify(a, b, romscope_runner=fake_romscope)
        # DIFFERS is not overridden by a guessed verdict; the raw romscope
        # report is surfaced for a human to interpret.
        self.assertEqual(result.verdict, ext.DIFFERS)
        self.assertIn("Compression differences", result.romscope_report)


class TestDiagnose(unittest.TestCase):
    def test_flags_all_three_defect_classes(self):
        kinds = [d.kind for d in ext.diagnose(DEFECTIVE_DOC)]
        self.assertEqual(kinds.count("version-conditional-prose"), 2)
        self.assertEqual(kinds.count("multiple-build-commands"), 1)
        self.assertEqual(kinds.count("inconsistent-tab-labels"), 1)

    def test_clean_docs_report_nothing(self):
        self.assertEqual(ext.diagnose(MSI_DOC), [])
        self.assertEqual(ext.diagnose(NOVA_DOC), [])

    def test_identical_repeated_build_command_is_not_flagged(self):
        doc = (
            "# Build\n\n"
            "```bash\n./build.sh h4\n```\n\n"
            "Or, equivalently:\n\n"
            "```bash\n./build.sh h4\n```\n"
        )
        kinds = [d.kind for d in ext.diagnose(doc)]
        self.assertNotIn("multiple-build-commands", kinds)


if __name__ == "__main__":
    unittest.main()
