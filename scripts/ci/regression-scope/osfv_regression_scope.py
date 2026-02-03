#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import os
import subprocess
import sys
from pprint import pprint
import glob

import fire
import pandas as pd

from lib.parser_manager import ParserManager


def run_command(cmd, env=os.environ.copy()):
    """
    Wrapper for subprocess.run to not repeat decoding the output too much
    """
    out = subprocess.run(cmd, capture_output=True, env=env)
    out = out.stdout.decode("utf-8").splitlines()
    return out

def _load_device_env_vars(device_names, devices_dir):
    envs = []
    for name in device_names:
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
            raise ValueError(f"Device '{name}' matched {len(candidates)} files: {candidates}")

        with open(candidates[0]) as f:
            device_cfg = json.load(f)
        if "env_vars" not in device_cfg or not isinstance(device_cfg["env_vars"], dict):
            raise ValueError(f"Device file '{candidates[0]}' must contain an 'env_vars' dict")
        envs.append(device_cfg["env_vars"])
    return envs


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
    Fields other than <test ID> are optional for easy copying from dashboard.
    """
    table = pd.read_csv(list_path, header=None)
    return table.iloc[:, 0].tolist()

class CLI:
    def __init__(self, device_name="qemu", rules_file="scripts/ci/regression-scope/configs/rules-new.json", devices_dir="scripts/ci/regression-scope/configs/devices", override_tests_list=None, compare_to="HEAD"):
        self.compare_to = compare_to
        self.override_tests_list = override_tests_list
        self.rules_file = rules_file
        self.devices_dir = devices_dir
        self.device_name = device_name
        if override_tests_list is None:
            self.get_changed_files = lambda: get_changed_files(compare_to)
        else:
            self.get_changed_files = lambda: get_files_from_list(override_tests_list)


    def filenames(self, *device_name):
        """
        Print the filenames of test suites that are affected by the changes
        """
        self.device_envs = _load_device_env_vars(device_name, self.devices_dir) if device_name else None
        with open(self.rules_file) as rules_file:
            self.rules = json.load(rules_file)["rules"]
        self.changed_files = self.get_changed_files()
        parser = ParserManager(self.rules, self.changed_files, device_envs=self.device_envs)
        parser.parse()
        print(" ".join(parser.files()))

    def commands(self, *device_name):
        """
        Print the commands that should be executed to test the changes
        """
        print(self.device_name)
        self.device_envs = _load_device_env_vars(device_name, self.devices_dir) if device_name else None
        with open(self.rules_file) as rules_file:
            self.rules = json.load(rules_file)["rules"]
        self.changed_files = self.get_changed_files()
        parser = ParserManager(self.rules, self.changed_files, device_envs=self.device_envs)
        parser.parse()
        for command in parser.commands():
            print(" ".join(command))

    def robot_args(self, *device_name):
        """
        Print the parameters that should be passed to the run.sh robot wrapper to
        test the changes. Does not
        """
        self.device_envs = _load_device_env_vars(device_name, self.devices_dir) if device_name else None
        with open(self.rules_file) as rules_file:
            self.rules = json.load(rules_file)["rules"]
        self.changed_files = self.get_changed_files()
        parser = ParserManager(self.rules, self.changed_files, device_envs=self.device_envs)
        parser.parse()
        print(" ".join(parser.wrapper_args()))


if __name__ == "__main__":
    if "--help" in sys.argv or "-h" in sys.argv:
        # remove all arguments except the script name to print
        # fire generated help message
        sys.argv = sys.argv[:1]
    fire.Fire(CLI)
