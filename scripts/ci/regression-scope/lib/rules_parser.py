#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import re

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
        self.commands = []
        self.test_files = []
        self.robot_args = []
        self.env = os.environ.copy()

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
            commands.append(f"export {k}={vars_dict[k]}")
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
        return test_files

    def get_files_choice(self, files_choice):
        """
        Returns a list of test files to run according to the `files` section
        """
        if files_choice["mode"] == RULES_TAG_MATCHED_FILENAME:
            return self.matched_files
        elif files_choice["mode"] == RULES_TAG_FULL_MATCH:
            return self.matched_paths
        elif files_choice["mode"] == RULES_TAG_CONTAINING_FILENAME:
            test_files = self.get_test_files_in_dirs(files_choice["search_in"])
            changes_in_deps = []
            for file in test_files:
                with open(file, "r") as f:
                    for lib in self.matched_files:
                        if lib in f.read():
                            changes_in_deps.append(file)
            return changes_in_deps
        elif files_choice["mode"] == RULES_TAG_CONTAINS_REGEX:
            test_files = self.get_test_files_in_dirs(files_choice["search_in"])
            regex = re.compile(files_choice["regex"])
            matching = []
            for file in test_files:
                with open(file, "r") as f:
                    if regex.search(f.read()) is not None:
                        matching.append(file)
            return matching

    def assemble_robot_command(self, files, robot_args=[]):
        """
        Assembles the command to run given test suites with given args.
        """
        command = ["scripts/run.sh"]
        command += files
        if len(robot_args) > 0:
            command.append("--")
            command += robot_args
        return command

    def parse_run(self):
        """
        Parses the `run` section of the rule which means running robot on
        the files.
        Returns a robot command to run the tests.
        """
        run_dict = self.rule["run"]
        commands = []
        for run in run_dict:
            if "env_vars" in run:
                commands.append(self.get_env_modification_commands(run))
            if "files" in run:
                self.test_files = self.get_files_choice(run["files"])
            if "custom_command" in run:
                commands.append(run["custom_command"].split(" "))
                continue
            self.robot_args = []
            if "robot_args" in run:
                self.robot_args.extend(run["robot_args"].split(" "))
            if "snipeit" in run and run["snipeit"] == "no":
                self.robot_args += ["-v", "snipeit:no"]
            commands.append(
                self.assemble_robot_command(self.test_files, robot_args=self.robot_args)
            )
        return commands

    def match_rule(self):
        """
        Matches one rule in rules.json.
        Finds matching files and returns a list of commands to run
        According to the rule.
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

        self.commands += self.parse_run()
        return True
