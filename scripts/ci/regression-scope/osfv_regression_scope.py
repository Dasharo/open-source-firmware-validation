#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import glob
import json
import os
import subprocess
import sys

import fire
from osfv.libs.snipeit_api import SnipeIT

from lib.parser_manager import ParserManager

SNIPEIT_CUSTOM_FIELDS = {
    "RTE_IP": "RTE IP",
    "DEVICE_IP": "IP",
    "SONOFF_IP": "Sonoff IP",
    "PIKVM_IP": "PiKVM IP",
}


def run_command(cmd, env=os.environ.copy()):
    """
    Wrapper for subprocess.run to not repeat decoding the output too much
    """
    out = subprocess.run(cmd, capture_output=True, env=env)
    out = out.stdout.decode("utf-8").splitlines()
    return out


def _snipeit_env_vars(asset_id):
    """
    Return the addresses SnipeIT holds for an asset
    """
    status, asset = SnipeIT().get_asset(asset_id)
    if not status:
        raise ValueError(f"SnipeIT has no asset '{asset_id}'")

    custom_fields = asset.get("custom_fields", {})
    return {
        var: custom_fields[field]["value"]
        for var, field in SNIPEIT_CUSTOM_FIELDS.items()
        if custom_fields.get(field, {}).get("value")
    }


def _load_device_env_vars(name, devices_dir):
    candidates = []
    if os.path.isfile(name):
        candidates = [name]
    else:
        exact = os.path.join(devices_dir, f"{name}.json")
        if os.path.isfile(exact):
            candidates = [exact]
        else:
            candidates = glob.glob(os.path.join(devices_dir, f"{name}_*.json"))

    if len(candidates) != 1:
        raise ValueError(
            f"Device '{name}' matched {len(candidates)} files: {candidates}"
        )

    with open(candidates[0]) as f:
        device_cfg = json.load(f)
    if "env_vars" not in device_cfg or not isinstance(device_cfg["env_vars"], dict):
        raise ValueError(
            f"Device file '{candidates[0]}' must contain an 'env_vars' dict"
        )
    env_vars = dict(device_cfg["env_vars"])
    asset_id = env_vars.get("ASSET_ID")
    if asset_id and env_vars.get("SNIPEIT_NO") != "true":
        # whatever the config spells out wins over SnipeIT
        env_vars = {**_snipeit_env_vars(asset_id), **env_vars}

    # CI points OSFV_ROMS_DIR at the NFS share, developers get their local _roms
    roms_dir = os.getenv("OSFV_ROMS_DIR") or "_roms"
    for key, filename in (device_cfg.get("fw_files") or {}).items():
        env_vars[key] = os.path.join(roms_dir, filename)

    # on stderr, stdout carries the commands the caller parses
    print(
        f"Device '{name}' resolved from {candidates[0]}:",
        json.dumps(env_vars, indent=4, sort_keys=True),
        sep="\n",
        file=sys.stderr,
    )
    return env_vars


def get_changed_files(compare_to):
    """
    Returns a list of filenames tracked by git that are modified
    """
    cmd_dirty = ["git", "diff", compare_to, "--name-only"]
    cmd_cached = ["git", "diff", compare_to, "--name-only", "--cached"]
    files_dirty = run_command(cmd_dirty)
    files_cached = run_command(cmd_cached)
    files = files_dirty + files_cached
    return files


def get_files_from_list(list_path):
    """
    Returns a list of filenames from a list of files.
    List is a TSV in form of:
    <test ID>\t<Name>\t<Automation>\t<Result>\t<Has comment>\n
    Only the first column is required; extra columns are ignored.
    """
    files = []
    with open(list_path, encoding="utf-8") as list_file:
        for line in list_file:
            line = line.strip()
            if not line:
                continue
            if line.startswith("#"):  # skip comments
                continue
            files.append(line.split("\t", 1)[0])
    return files


class CLI:
    def __init__(
        self,
        rules_file="scripts/ci/regression-scope/configs/pr-regression-rules.json",
        devices_dir="scripts/ci/regression-scope/configs/devices",
        override_tests_list=None,
        compare_to="HEAD",
    ):
        self.compare_to = compare_to
        self.override_tests_list = override_tests_list
        self.rules_file = rules_file
        self.devices_dir = devices_dir
        if override_tests_list is None:
            self.get_changed_files = lambda: get_changed_files(compare_to)
        else:
            self.get_changed_files = lambda: get_files_from_list(override_tests_list)

    def _prepare_parser(self, device_name):
        device_env = (
            _load_device_env_vars(device_name, self.devices_dir) if device_name else {}
        )
        with open(self.rules_file) as rules_file:
            rules = json.load(rules_file)["rules"]
        changed_files = self.get_changed_files()
        parser = ParserManager(rules, changed_files, device_env=device_env)
        parser.parse()
        return parser

    def filenames(self, device_name=None):
        """
        Print the filenames of test suites that are affected by the changes
        """
        parser = self._prepare_parser(device_name)
        print(" ".join(parser.files()))

    def commands(self, device_name=None):
        """
        Print the commands that should be executed to test the changes
        """
        parser = self._prepare_parser(device_name)
        commands = parser.commands()
        if not commands:
            return

        prepare = parser._env_dict_to_commands(parser.device_env)
        prepare += ["scripts/run.sh", "util/prepare-platform.robot"]
        for command in [prepare] + commands:
            print(" ".join(command))

    def robot_args(self, device_name=None):
        """
        Print the arguments that should be passed to the run.sh robot wrapper.
        """
        parser = self._prepare_parser(device_name)
        print(" ".join(parser.wrapper_args()))


if __name__ == "__main__":
    if "--help" in sys.argv or "-h" in sys.argv:
        # remove all arguments except the script name to print
        # fire generated help message
        sys.argv = sys.argv[:1]
    fire.Fire(CLI)
