#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import re
from collections import defaultdict

RULES_TAG_MATCHED_FILENAME = "${FILENAME_MATCH}"
RULES_TAG_FULL_MATCH = "${FULL_FILENAME_MATCH}"
RULES_TAG_CONTAINING_FILENAME = "${FILE_CONTAINS_MATCH}"
RULES_TAG_CONTAINS_REGEX = "${FILE_CONTAINS_REGEX}"


class RuleParser:
    """
    Class for parsing the rules file in order to create a list of commands
    that need to be executed to ensure the changes in OSFV didn't break anything
    """

    def __init__(self, rule, changed_files):
        self.rule = rule
        self.changed_files = changed_files
        self.matched_files = []
        self.matched_paths = []
        self.runs_data = []

    def get_env_modification_commands(self, run):
        """
        Returns a list of commands to set environment variables
        according to the `env_vars` section of the given "run" of a rule.
        """
        commands = []
        if "env_vars" not in run:
            return commands
        vars_dict = run["env_vars"]
        for k in vars_dict.keys():
            commands += ["export", f"{k}={vars_dict[k]};"]
        return commands

    def get_test_files_in_dirs(self, search_in):
        """
        Helper function to get all test files in the given list of directories.
        """
        test_files = []
        for module in search_in:
            for root, _, files in os.walk(module):
                for file in files:
                    if file.split(".")[-1] == "robot":
                        path = os.path.join(root, file)
                        test_files.append(path)
        # os.walk yields whatever order the filesystem has
        return sorted(test_files)

    def get_files_choice(self, files_choice):
        """
        Returns a list of test files to run according to the `files` section
        """
        mode = files_choice["mode"]
        if mode == RULES_TAG_MATCHED_FILENAME:
            result = self.matched_files
        elif mode == RULES_TAG_FULL_MATCH:
            result = self.matched_paths
        elif mode == RULES_TAG_CONTAINING_FILENAME:
            test_files = self.get_test_files_in_dirs(files_choice["search_in"])
            changes_in_deps = []
            for file in test_files:
                with open(file, "r") as f:
                    for lib in self.matched_files:
                        if lib in f.read():
                            changes_in_deps.append(file)
            result = changes_in_deps
        elif mode == RULES_TAG_CONTAINS_REGEX:
            test_files = self.get_test_files_in_dirs(files_choice["search_in"])
            regex = re.compile(files_choice["regex"])
            matching = []
            for file in test_files:
                with open(file, "r") as f:
                    if regex.search(f.read()) is not None:
                        matching.append(file)
            result = matching
        else:
            result = []
        return result

    def parse_run(self):
        """
        Parses the `run` section of the rule which means running robot on
        the files.
        Returns a dict:
        {
            "env": export_env_vars_commands, might be None,
            "files": list of test suite filenames
            "command": optional ovevrride command, might be None,
            "args": optional additional robot args list
        }
        """
        run = self.rule.get("run")
        if not isinstance(run, dict):
            raise ValueError("Rule 'run' must be a dict")

        self.runs_data = []
        run_data = {
            "env": [],
            "files": [],
            "command": [],
            "args": [],
        }
        if "env_vars" in run:
            run_data["env"] = self.get_env_modification_commands(run)
        if "files" in run:
            run_data["files"] = self.get_files_choice(run["files"])
        if "custom_command" in run:
            run_data["command"] = run["custom_command"].split(" ")
        if "robot_args" in run:
            run_data["args"] = run["robot_args"].split(" ")
        self.runs_data.append(run_data)
        return self.runs_data

    def match_rule(self):
        """
        Matches one rule in rules.json.
        Finds matching files and returns a list of commands to run
        According to the rule.runs_data
        """
        reg = re.compile(self.rule["on-changed"])
        self.matched_files = []
        self.matched_paths = []

        if self.rule["run"] is None:
            print("No `run` section in the rule")
            return False

        for line in self.changed_files:
            match = reg.match(line)
            if match is None:
                continue
            self.matched_paths.append(match.group(0))
            self.matched_files.append(match.group(1))

        if len(self.matched_files) < 1:
            return False
        self.runs_data = self.parse_run()
        return True
