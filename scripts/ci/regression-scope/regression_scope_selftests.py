#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json

import fire

from lib.rules_parser import RuleParser


def test_suites():
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
    changed_files = [
        "dasharo-compatibility/audio-subsystem.robot",
        "dasharo-performance/platform-stability.robot",
        "lib/linux.robot",
        "platform-configs/include/msi-common.robot",
    ]
    for rule in rules:
        parser = RuleParser(rule, changed_files)
        parser.match_rule()
        assert parser.tests == ["dasharo-compatibility/audio-subsystem.robot"]
        assert parser.commands == [
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
        ]


def test_libs():
    rules = json.loads(
        """
    {
        "rules": [
            {
                "name": "Run suites that use a modified lib",
                "on-changed": "lib/(.*)",
                "run": {
                    "env_vars": {
                        "RTE_IP": "127.0.0.1",
                        "FW_FILE": "scripts/ci/qemu_q35.rom",
                        "CONFIG": "qemu"
                    },
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
    changed_files = [
        "dasharo-compatibility/audio-subsystem.robot",
        "dasharo-performance/platform-stability.robot",
        "lib/linux.robot",
        "platform-configs/include/msi-common.robot",
    ]
    for rule in rules:
        parser = RuleParser(rule, changed_files)
        parser.match_rule()
        assert parser.tests == [
            "dasharo-compatibility/apu-configuration-menu.robot",
            "dasharo-performance/platform-stability.robot",
        ]
        assert parser.commands == [
            [
                "export RTE_IP=127.0.0.1",
                "export FW_FILE=scripts/ci/qemu_q35.rom",
                "export CONFIG=qemu",
            ],
            [
                "scripts/run.sh",
                "dasharo-compatibility/apu-configuration-menu.robot",
                "dasharo-performance/platform-stability.robot",
                "--",
                "-v",
                "snipeit:no",
            ],
        ]


def test_platform_configs():
    rules = json.loads(
        """
    {
        "rules": [
            {
                "name": "Minimal regression for MSI common",
                "on-changed": "(platform-configs/include/msi-common.robot)",
                "run": {
                    "env_vars": {
                        "RTE_IP": "1.2.3.4",
                        "FW_FILE": "msi-firmware.rom",
                        "CONFIG": "msi-pro-z790-p-ddr5",
                        "CAPSULE_FW_FILE": "msi-pro-z790-p-ddr5.cap"
                    },
                    "files": {
                        "mode": "${CONTENT_MATCH_REGEX}",
                        "search_in": ["dasharo-compatibility", "dasharo-security", "dasharo-performance", "dasharo-stability"],
                        "regex": ".*minimal-regression.*"
                    },
                    "custom_command": "scripts/regression.sh -- -i minimal-regression"
                }
            }
        ]
    }
    """
    )["rules"]
    changed_files = [
        "dasharo-compatibility/audio-subsystem.robot",
        "dasharo-performance/platform-stability.robot",
        "lib/linux.robot",
        "platform-configs/include/msi-common.robot",
    ]
    for rule in rules:
        parser = RuleParser(rule, changed_files)
        parser.match_rule()
        assert parser.tests == [
            "dasharo-compatibility/network-boot.robot",
            "dasharo-compatibility/auto-boot-time-out.robot",
            "dasharo-compatibility/dmidecode.robot",
            "dasharo-compatibility/usb-hid-and-msc-support.robot",
            "dasharo-compatibility/wifi-bluetooth-support.robot",
            "dasharo-security/tpm-support.robot",
            "dasharo-performance/platform-stability.robot",
        ]
        assert parser.commands == [
            [
                "export RTE_IP=1.2.3.4",
                "export FW_FILE=msi-firmware.rom",
                "export CONFIG=msi-pro-z790-p-ddr5",
                "export CAPSULE_FW_FILE=msi-pro-z790-p-ddr5.cap",
            ],
            ["scripts/regression.sh", "--", "-i", "minimal-regression"],
        ]


def tests():
    """
    CLI for running regression scope selftests.
    Returns 0 on success
    """
    test_suites()
    test_libs()
    test_platform_configs()


if __name__ == "__main__":
    fire.Fire(tests)
