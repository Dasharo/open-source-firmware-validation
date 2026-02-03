#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import unittest

from lib.parser_manager import ParserManager


class TestMiscellaneous(unittest.TestCase):
    def test_no_matches(self):
        rules = json.loads(
            """
            {
                "rules": [
                    {
                        "name": "Single match",
                        "on-changed": "(important-file.robot)",
                        "run": [{
                            "custom_command": "echo hello"
                        }]
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
        rules = json.loads(
            """
            {
                "rules": [
                    {
                        "name": "Single match",
                        "on-changed": "(important-file.robot)",
                        "run": [{
                            "files": {
                                "mode": "${FULL_FILENAME_MATCH}"
                            },
                            "robot_args": "-i minimal-regression"
                        }]
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
        self.assertEqual(parser.files(), ["important-file.robot"])
        self.assertEqual(
            parser.commands(),
            [
                [
                    "scripts/run.sh",
                    "important-file.robot",
                    "--",
                    "-i",
                    "minimal-regression",
                ]
            ],
        )


    def test_new_run_shorthand_dict(self):
        rules = json.loads(
            """
            {
                "rules": [
                    {
                        "name": "Single match",
                        "on-changed": "(important-file.robot)",
                        "run": {
                            "mode": "${FULL_FILENAME_MATCH}"
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
        self.assertEqual(parser.files(), ["important-file.robot"])
        self.assertEqual(
            parser.commands(),
            [["scripts/run.sh", "important-file.robot"]],
        )

    def test_device_expansion_from_external_env_vars(self):
        rules = json.loads(
            """
            {
                "rules": [
                    {
                        "name": "Single match",
                        "on-changed": "(important-file.robot)",
                        "run": {
                            "mode": "${FULL_FILENAME_MATCH}"
                        }
                    }
                ]
            }"""
        )["rules"]
        changed_files = [
            "important-file.robot",
        ]
        device_envs = [
            {"ASSET_ID": "00039", "CONFIG": "msi-pro-z690-a-wifi-ddr4"},
            {"ASSET_ID": "00252", "CONFIG": "pcengines-apu3"},
        ]
        parser = ParserManager(rules, changed_files, device_envs=device_envs)
        parser.parse()
        self.assertEqual(parser.files(), ["important-file.robot"])
        self.assertEqual(
            parser.commands(),
            [
                [
                    "export",
                    "ASSET_ID=00039;",
                    "export",
                    "CONFIG=msi-pro-z690-a-wifi-ddr4;",
                    "scripts/run.sh",
                    "important-file.robot",
                ],
                [
                    "export",
                    "ASSET_ID=00252;",
                    "export",
                    "CONFIG=pcengines-apu3;",
                    "scripts/run.sh",
                    "important-file.robot",
                ],
            ],
        )


    def test_mutliple_runs_one_rule(self):
        rules = json.loads(
            """
            {
                "rules": [
                    {
                        "name": "Single match",
                        "on-changed": "(important-file.robot)",
                        "run": [
                            {
                                "files": {
                                    "mode": "${FULL_FILENAME_MATCH}"
                                },
                                "robot_args": "-i minimal-regression"
                            },
                            {
                                "files": {
                                    "mode": "${FULL_FILENAME_MATCH}"
                                },
                                "robot_args": "-i some_other:tag"
                            }
                        ]
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
        self.assertEqual(parser.files(), ["important-file.robot"])
        self.assertEqual(
            parser.commands(),
            [
                [
                    "scripts/run.sh",
                    "important-file.robot",
                    "--",
                    "-i",
                    "minimal-regression",
                ],
                [
                    "scripts/run.sh",
                    "important-file.robot",
                    "--",
                    "-i",
                    "some_other:tag",
                ],
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
                        "run": [{
                            "env_vars": {
                                "RTE_IP": "127.0.0.1",
                                "FW_FILE": "scripts/ci/qemu_q35.rom",
                                "CONFIG": "qemu"
                            },
                            "files": {
                                "mode": "${FULL_FILENAME_MATCH}"
                            },
                            "snipeit": "no"
                        }]
                    }
                ]
            }"""
    )["rules"]

    def test_single_module_single_change(self):
        changed_files = [
            "dasharo-compatibility/audio-subsystem.robot",
            "dasharo-performance/platform-stability.robot",
            "lib/linux.robot",
            "platform-configs/include/msi-common.robot",
        ]
        parser = ParserManager(TestModulesRules.rules, changed_files)
        parser.parse()
        self.assertEqual(
            parser.files(), ["dasharo-compatibility/audio-subsystem.robot"]
        )
        self.assertEqual(
            parser.commands(),
            [
                [
                    "export",
                    "RTE_IP=127.0.0.1;",
                    "export",
                    "FW_FILE=scripts/ci/qemu_q35.rom;",
                    "export",
                    "CONFIG=qemu;",
                    "scripts/run.sh",
                    "dasharo-compatibility/audio-subsystem.robot",
                    "--",
                    "-v",
                    "snipeit:no",
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
        parser = ParserManager(TestModulesRules.rules, changed_files)
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
                    "export",
                    "RTE_IP=127.0.0.1;",
                    "export",
                    "FW_FILE=scripts/ci/qemu_q35.rom;",
                    "export",
                    "CONFIG=qemu;",
                    "scripts/run.sh",
                    "dasharo-compatibility/audio-subsystem.robot",
                    "dasharo-compatibility/cpu-status.robot",
                    "--",
                    "-v",
                    "snipeit:no",
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
                    "run": [{
                        "files": {
                            "mode": "${FILE_CONTAINS_MATCH}",
                            "search_in": ["dasharo-compatibility", "dasharo-security", "dasharo-performance", "dasharo-stability"]
                        },
                        "snipeit": "no"
                    }]
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
                    "--",
                    "-v",
                    "snipeit:no",
                ],
            ],
        )

    def test_single_lib_multiple_module(self):
        changed_files = [
            "dasharo-compatibility/audio-subsystem.robot",
            "dasharo-performance/platform-stability.robot",
            "lib/linux.robot",
            "platform-configs/include/msi-common.robot",
        ]
        parser = ParserManager(TestLibsRules.rules, changed_files)
        parser.parse()
        self.assertEqual(
            parser.files(),
            [
                "dasharo-compatibility/apu-configuration-menu.robot",
                "dasharo-performance/platform-stability.robot",
            ],
        )
        self.assertEqual(
            parser.commands(),
            [
                [
                    "scripts/run.sh",
                    "dasharo-compatibility/apu-configuration-menu.robot",
                    "dasharo-performance/platform-stability.robot",
                    "--",
                    "-v",
                    "snipeit:no",
                ],
            ],
        )

    def test_multiple_lib_multiple_module_overlap(self):
        changed_files = [
            "dasharo-compatibility/audio-subsystem.robot",
            "dasharo-performance/platform-stability.robot",
            "lib/tpm.robot",
            "lib/tpm2.robot" "platform-configs/include/msi-common.robot",
        ]
        parser = ParserManager(TestLibsRules.rules, changed_files)
        parser.parse()
        self.assertEqual(
            parser.files(),
            [
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
                    "dasharo-security/measured-boot.robot",
                    "dasharo-security/tpm-support.robot",
                    "dasharo-security/tpm2-commands.robot",
                    "--",
                    "-v",
                    "snipeit:no",
                ],
            ],
        )


class TestLibsMultipleRules(unittest.TestCase):
    changed_files = [
        "dasharo-compatibility/audio-subsystem.robot",
        "dasharo-performance/platform-stability.robot",
        "lib/tpm.robot",
        "lib/tpm2.robot" "platform-configs/include/msi-common.robot",
    ]

    def test_multiple_lib_multiple_rules_overlap(self):
        rules = json.loads(
            """
        {
            "rules": [
                {
                    "name": "Run suites that use a modified lib",
                    "on-changed": "lib/(tpm.robot)",
                    "run": [{
                        "files": {
                            "mode": "${FILE_CONTAINS_MATCH}",
                            "search_in": ["dasharo-compatibility", "dasharo-security", "dasharo-performance", "dasharo-stability"]
                        },
                        "snipeit": "no"
                    }]
                },
                {
                    "name": "Run suites that use a modified lib",
                    "on-changed": "lib/(tpm2.robot)",
                    "run": [{
                        "files": {
                            "mode": "${FILE_CONTAINS_MATCH}",
                            "search_in": ["dasharo-compatibility", "dasharo-security", "dasharo-performance", "dasharo-stability"]
                        },
                        "snipeit": "no"
                    }]
                }
            ]
        }
        """
        )["rules"]

        parser = ParserManager(rules, TestLibsMultipleRules.changed_files)
        parser.parse()
        self.assertEqual(
            parser.files(),
            [
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
                    "dasharo-security/measured-boot.robot",
                    "dasharo-security/tpm-support.robot",
                    "dasharo-security/tpm2-commands.robot",
                    "--",
                    "-v",
                    "snipeit:no",
                ],
            ],
        )

    def test_multiple_lib_multiple_rules_overlap_no_repeats(self):
        rules = json.loads(
            """
        {
            "rules": [
                {
                    "name": "Run suites that use a modified lib",
                    "on-changed": "lib/(tpm.robot)",
                    "run": [{
                        "files": {
                            "mode": "${FILE_CONTAINS_MATCH}",
                            "search_in": ["dasharo-compatibility", "dasharo-security", "dasharo-performance", "dasharo-stability"]
                        },
                        "snipeit": "no"
                    }]
                },
                {
                    "name": "Run suites that use a modified lib",
                    "on-changed": "lib/(tpm2.robot)",
                    "run": [{
                        "files": {
                            "mode": "${FILE_CONTAINS_MATCH}",
                            "search_in": ["dasharo-compatibility", "dasharo-security", "dasharo-performance", "dasharo-stability"]
                        },
                        "robot_args": "-i some_other:tag",
                        "snipeit": "no"
                    }]
                }
            ]
        }
        """
        )["rules"]

        parser = ParserManager(rules, TestLibsMultipleRules.changed_files)
        parser.parse()
        self.assertEqual(
            parser.files(),
            [
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
                    "dasharo-security/measured-boot.robot",
                    "dasharo-security/tpm-support.robot",
                    "dasharo-security/tpm2-commands.robot",
                    "--",
                    "-v",
                    "snipeit:no",
                ],
                [
                    "scripts/run.sh",
                    "dasharo-security/tpm-support.robot",
                    "dasharo-security/tpm2-commands.robot",
                    "--",
                    "-i",
                    "some_other:tag",
                    "-v",
                    "snipeit:no",
                ],
            ],
        )


if __name__ == "__main__":
    unittest.main()
