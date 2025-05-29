#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0
from collections import defaultdict

from lib.rules_parser import RuleParser


class ParserManager:
    """
    Runs rule parsers on the rules file and presents the parsing results.
    """

    def __init__(self, rules, changed_files):
        self.rules = rules
        self.changed_files = changed_files
        self.runs_data = None
        self.parse()

    def _assemble_robot_command(self, files, robot_args=[]):
        """
        Assembles the command to run given test suites with given args.
        """
        command = ["scripts/run.sh"]
        command += sorted(files)
        if len(robot_args) > 0:
            command.append("--")
            command += robot_args
        return command

    def _assemble_commands_from_runs_data(self, runs_data):
        """
        Assembles all the commands for the rules file
        """
        commands = []
        for data in runs_data:
            if len(data["env"]) > 0:
                commands.append(data["env"])
            if len(data["files"]) > 0:
                commands.append(
                    self._assemble_robot_command(data["files"], data["args"])
                )
            else:
                commands.append(data["command"])
        return commands

    def _uniqeuify_runs_data(self, parser_runs_data, by=["env", "args"]):
        """
        Group the runs_data by `by` parameter.
        For every unique `by` gathers unique tests to be performed.
        Makes sure that a test is repeated for every unique combination of `by`
            fields, but no more.
        Important when multiple rules would result in running one test suite
            with the exact same env variables and robot args.
        """
        unique_scenarios = defaultdict(list)
        for data in parser_runs_data:
            key = tuple([tuple(data[key]) for key in by])
            unique_scenarios[key].append(data)
        uniqueified_runs_data = []
        for key, runs in unique_scenarios.items():
            joined = defaultdict(list)
            for i in range(len(by)):
                joined[by[i]] = list(key[i])  # copy keys
            for data in runs:
                joined["files"] += data["files"]
                joined["command"] += data["command"]
            joined["files"] = list(set(joined["files"]))
            uniqueified_runs_data.append(joined)
        return uniqueified_runs_data

    def files(self):
        """
        Return a list of unique filenames matched by rules
        """
        files = []
        for data in self.runs_data:
            files += data["files"]
        return sorted(list(set(files)))

    def commands(self):
        """
        Return a list of lines of commands for the parsed rules.
        Each line is one command.
        """
        uniquified = self._uniqeuify_runs_data(self.runs_data, ["env", "args"])
        return self._assemble_commands_from_runs_data(uniquified)

    def wrapper_args(self):
        """
        Return a list of lines containing args to `run.sh` according to the
            parsed rules.
        One line is one run.sh call
        """
        uniquified = self._uniqeuify_runs_data(self.runs_data, ["args"])
        return [" ".join(data["files"]) + " ".join(data["args"]) for data in uniquified]

    def parse(self):
        """
        Parse the rules file. Call before any other method
        """
        self.runs_data = []
        for rule in self.rules:
            parser = RuleParser(rule, self.changed_files)
            parser.match_rule()
            self.runs_data += parser.runs_data
