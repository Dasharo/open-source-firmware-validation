#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import unittest

from lib.parser_manager import ParserManager


def exports(env_vars):
    """
    The `export A=a;` commands expected to be prepended for a device
    """
    return [word for k, v in env_vars.items() for word in ("export", f"{k}={v};")]


class TestMiscellaneous(unittest.TestCase):
    def test_no_matches(self):
        rules = json.loads(
            """
            {
                "rules": [
                    {
                        "name": "Single match",
                        "on-changed": "(important-file.robot)",
                        "run": {
                            "custom_command": "echo hello"
                        }
                    }
                ]
            }"""
        )["rules"]
        changed_files = [
            "important-file.robot",
            "dasharo-performance/boot-time-measure.robot",
        ]
        parser = ParserManager(rules, changed_files)
        parser.parse()
        self.assertEqual(parser.files(), [])
        self.assertEqual(
            parser.commands(),
            [["echo", "hello"]],
        )

    def test_additional_robot_args(self):
        device_env = {"ASSET_ID": "00039", "CONFIG": "msi-pro-z690-a-wifi-ddr4"}
        rules = json.loads(
            """
            {
                "rules": [
                    {
                        "name": "Single match",
                        "on-changed": "(important-file.robot)",
                        "run": {
                            "files": {
                                "mode": "${FULL_FILENAME_MATCH}"
                            },
                            "robot_args": "-i minimal-regression"
                        }
                    }
                ]
            }"""
        )["rules"]
        changed_files = [
            "important-file.robot",
            "dasharo-performance/boot-time-measure.robot",
        ]
        parser = ParserManager(rules, changed_files, device_env)
        parser.parse()
        self.assertEqual(parser.files(), ["important-file.robot"])
        self.assertEqual(
            parser.commands(),
            [
                [
                    *exports(device_env),
                    "scripts/run.sh",
                    "important-file.robot",
                    "--",
                    "-i",
                    "minimal-regression",
                ]
            ],
        )


class TestModulesRules(unittest.TestCase):
    rules = json.loads(
        """
        {
            "rules": [
                {
                    "name": "Run changed test suites",
                    "on-changed": "dasharo-compatibility/(.*)",
                    "run": {
                        "files": {
                            "mode": "${FULL_FILENAME_MATCH}"
                        }
                    }
                }
            ]
        }"""
    )["rules"]
    device_env = {
        "RTE_IP": "127.0.0.1",
        "CONFIG": "qemu",
        "FW_FILE": "scripts/ci/qemu_q35.rom",
        "SNIPEIT_NO": "1",
    }
    device_exports = exports(device_env)

    def test_single_module_single_change(self):
        changed_files = [
            "dasharo-compatibility/audio-subsystem.robot",
            "dasharo-performance/platform-stability.robot",
            "lib/linux.robot",
            "platform-configs/include/msi-common.robot",
        ]
        parser = ParserManager(
            TestModulesRules.rules, changed_files, TestModulesRules.device_env
        )
        parser.parse()
        self.assertEqual(
            parser.files(), ["dasharo-compatibility/audio-subsystem.robot"]
        )
        self.assertEqual(
            parser.commands(),
            [
                [
                    *TestModulesRules.device_exports,
                    "scripts/run.sh",
                    "dasharo-compatibility/audio-subsystem.robot",
                ],
            ],
        )

    def test_single_module_multiple_changes(self):
        changed_files = [
            "dasharo-compatibility/audio-subsystem.robot",
            "dasharo-compatibility/cpu-status.robot",
            "dasharo-performance/platform-stability.robot",
            "lib/linux.robot",
            "platform-configs/include/msi-common.robot",
        ]
        parser = ParserManager(
            TestModulesRules.rules, changed_files, TestModulesRules.device_env
        )
        parser.parse()
        self.assertEqual(
            parser.files(),
            [
                "dasharo-compatibility/audio-subsystem.robot",
                "dasharo-compatibility/cpu-status.robot",
            ],
        )
        self.assertEqual(
            parser.commands(),
            [
                [
                    *TestModulesRules.device_exports,
                    "scripts/run.sh",
                    "dasharo-compatibility/audio-subsystem.robot",
                    "dasharo-compatibility/cpu-status.robot",
                ],
            ],
        )


class TestLibsRules(unittest.TestCase):
    rules = json.loads(
        """
        {
            "rules": [
                {
                    "name": "Run suites that use a modified lib",
                    "on-changed": "lib/(.*)",
                    "run": {
                        "files": {
                            "mode": "${FILE_CONTAINS_MATCH}",
                            "search_in": ["dasharo-compatibility", "dasharo-security", "dasharo-performance", "dasharo-stability"]
                        }
                    }
                }
            ]
        }
        """
    )["rules"]

    def test_single_lib_single_module(self):
        changed_files = [
            "dasharo-compatibility/audio-subsystem.robot",
            "dasharo-performance/platform-stability.robot",
            "lib/performance/gpu.robot",
            "platform-configs/include/msi-common.robot",
        ]
        parser = ParserManager(TestLibsRules.rules, changed_files)
        parser.parse()
        self.assertEqual(
            parser.files(),
            [
                "dasharo-performance/gpu-performance.robot",
            ],
        )
        self.assertEqual(
            parser.commands(),
            [
                [
                    "scripts/run.sh",
                    "dasharo-performance/gpu-performance.robot",
                ],
            ],
        )

    def test_single_lib_multiple_module(self):
        changed_files = [
            "dasharo-compatibility/audio-subsystem.robot",
            "dasharo-performance/platform-stability.robot",
            "lib/tpm2.robot",
            "platform-configs/include/msi-common.robot",
        ]
        parser = ParserManager(TestLibsRules.rules, changed_files)
        parser.parse()
        self.assertEqual(
            parser.files(),
            [
                "dasharo-security/tpm-support.robot",
                "dasharo-security/tpm2-commands.robot",
            ],
        )
        self.assertEqual(
            parser.commands(),
            [
                [
                    "scripts/run.sh",
                    "dasharo-security/tpm-support.robot",
                    "dasharo-security/tpm2-commands.robot",
                ],
            ],
        )

    def test_multiple_lib_multiple_module_overlap(self):
        changed_files = [
            "dasharo-compatibility/audio-subsystem.robot",
            "dasharo-performance/platform-stability.robot",
            "lib/tpm.robot",
            "lib/tpm2.robot",
            "platform-configs/include/msi-common.robot",
        ]
        parser = ParserManager(TestLibsRules.rules, changed_files)
        parser.parse()
        self.assertEqual(
            parser.files(),
            [
                "dasharo-security/cbnt.robot",  # tpm.robot only
                "dasharo-security/measured-boot.robot",  # tpm.robot only
                "dasharo-security/tpm-support.robot",  # tpm.robot & tpm2.robot
                "dasharo-security/tpm2-commands.robot",  # tpm.robot & tpm2.robot
            ],
        )
        self.assertEqual(
            parser.commands(),
            [
                [
                    "scripts/run.sh",
                    "dasharo-security/cbnt.robot",
                    "dasharo-security/measured-boot.robot",
                    "dasharo-security/tpm-support.robot",
                    "dasharo-security/tpm2-commands.robot",
                ],
            ],
        )


if __name__ == "__main__":
    unittest.main()
