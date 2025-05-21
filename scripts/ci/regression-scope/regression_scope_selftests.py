#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import unittest

from lib.rules_parser import RuleParser
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
        for rule in rules:
            parser = RuleParser(rule, changed_files)
            parser.match_rule()
            self.assertEqual(parser.test_files, [])
            self.assertEqual(
                parser.commands,
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
                        "run": {
                            "files": {
                                "mode": "${FULL_MATCH}"
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
        for rule in rules:
            parser = RuleParser(rule, changed_files)
            parser.match_rule()
            self.assertEqual(parser.test_files, ["important-file.robot"])
            self.assertEqual(
                parser.commands,
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


class TestModulesRules(unittest.TestCase):
    rules = json.loads(
        """
            {
                "rules": [
                    {
                        "name": "Run changed test suites",
                        "on-changed": "dasharo-compatibility/(.*)",
                        "run": {
                            "env_vars": {
                                "RTE_IP": "127.0.0.1",
                                "FW_FILE": "scripts/ci/qemu_q35.rom",
                                "CONFIG": "qemu"
                            },
                            "files": {
                                "mode": "${FULL_MATCH}"
                            },
                            "snipeit": "no"
                        }
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
        for rule in TestModulesRules.rules:
            parser = RuleParser(rule, changed_files)
            parser.match_rule()
            self.assertEqual(
                parser.test_files, ["dasharo-compatibility/audio-subsystem.robot"]
            )
            self.assertEqual(
                parser.commands,
                [
                    [
                        "export RTE_IP=127.0.0.1",
                        "export FW_FILE=scripts/ci/qemu_q35.rom",
                        "export CONFIG=qemu",
                    ],
                    [
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
        for rule in TestModulesRules.rules:
            parser = RuleParser(rule, changed_files)
            parser.match_rule()
            self.assertEqual(
                parser.test_files,
                [
                    "dasharo-compatibility/audio-subsystem.robot",
                    "dasharo-compatibility/cpu-status.robot",
                ],
            )
            self.assertEqual(
                parser.commands,
                [
                    [
                        "export RTE_IP=127.0.0.1",
                        "export FW_FILE=scripts/ci/qemu_q35.rom",
                        "export CONFIG=qemu",
                    ],
                    [
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
                    "run": {
                        "files": {
                            "mode": "${CONTAINING_MATCHES}",
                            "search_in": ["dasharo-compatibility", "dasharo-security", "dasharo-performance", "dasharo-stability"]
                        },
                        "snipeit": "no"
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
        for rule in TestLibsRules.rules:
            parser = RuleParser(rule, changed_files)
            parser.match_rule()
            self.assertEqual(
                parser.test_files,
                [
                    "dasharo-performance/gpu-performance.robot",
                ],
            )
            self.assertEqual(
                parser.commands,
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
        for rule in TestLibsRules.rules:
            parser = RuleParser(rule, changed_files)
            parser.match_rule()
            self.assertEqual(
                parser.test_files,
                [
                    "dasharo-compatibility/apu-configuration-menu.robot",
                    "dasharo-performance/platform-stability.robot",
                ],
            )
            self.assertEqual(
                parser.commands,
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
        for rule in TestLibsRules.rules:
            parser = RuleParser(rule, changed_files)
            parser.match_rule()
            self.assertEqual(
                parser.test_files,
                [
                    "dasharo-security/tpm2-commands.robot",  # tpm.robot & tpm2.robot
                    "dasharo-security/measured-boot.robot",  # tpm.robot only
                    "dasharo-security/tpm-support.robot",  # tpm.robot & tpm2.robot
                ],
            )
            self.assertEqual(
                parser.commands,
                [
                    [
                        "scripts/run.sh",
                        "dasharo-security/tpm2-commands.robot",
                        "dasharo-security/measured-boot.robot",
                        "dasharo-security/tpm-support.robot",
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
                    "run": {
                        "files": {
                            "mode": "${CONTAINING_MATCHES}",
                            "search_in": ["dasharo-compatibility", "dasharo-security", "dasharo-performance", "dasharo-stability"]
                        },
                        "snipeit": "no"
                    }
                },
                {
                    "name": "Run suites that use a modified lib",
                    "on-changed": "lib/(tpm2.robot)",
                    "run": {
                        "files": {
                            "mode": "${CONTAINING_MATCHES}",
                            "search_in": ["dasharo-compatibility", "dasharo-security", "dasharo-performance", "dasharo-stability"]
                        },
                        "snipeit": "no"
                    }
                }
            ]
        }
        """
        )["rules"]

        parser = ParserManager(rules, TestLibsMultipleRules.changed_files)
        parser.parse()
        self.assertEqual(
            parser.test_files,
            [
                "dasharo-security/tpm2-commands.robot",  # tpm.robot & tpm2.robot
                "dasharo-security/measured-boot.robot",  # tpm.robot only
                "dasharo-security/tpm-support.robot",  # tpm.robot & tpm2.robot
            ],
        )
        self.assertEqual(
            parser.commands,
            [
                [
                    "scripts/run.sh",
                    "dasharo-security/tpm2-commands.robot",
                    "dasharo-security/measured-boot.robot",
                    "dasharo-security/tpm-support.robot",
                    "--",
                    "-v",
                    "snipeit:no",
                ],
            ],
        )

    def test_multiple_lib_multiple_rules_overlap_2(self):
        parser = RuleParser(
            TestLibsMultipleRules.rules[1], TestLibsMultipleRules.changed_files
        )
        parser.match_rule()
        self.assertEqual(
            parser.test_files,
            [
                "dasharo-security/tpm2-commands.robot",  # tpm.robot & tpm2.robot
                "dasharo-security/tpm-support.robot",  # tpm.robot & tpm2.robot
            ],
        )
        self.assertEqual(
            parser.commands,
            [
                [
                    "scripts/run.sh",
                    "dasharo-security/tpm2-commands.robot",
                    "dasharo-security/tpm-support.robot",
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
