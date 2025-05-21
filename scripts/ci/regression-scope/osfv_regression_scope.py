#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import os
import subprocess
import sys

import fire

from lib.rules_parser import RuleParser


def run_command(cmd, env=os.environ.copy()):
    """
    Wrapper for subprocess.run to not repeat decoding the output too much
    """
    out = subprocess.run(cmd, capture_output=True, env=env)
    out = out.stdout.decode("utf-8").splitlines()
    return out


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


class CLI:
    def filenames(
        self, rules_file="scripts/ci/regression-scope/rules.json", compare_to="HEAD"
    ):
        """
        Print the filenames of test suites to be tested
        """
        with open(rules_file) as rules_file:
            self.rules = json.load(rules_file)["rules"]
        self.changed_files = get_changed_files(compare_to)
        for rule in self.rules:
            parser = RuleParser(rule, self.changed_files)
            parser.match_rule()
            if len(parser.test_files) > 0:
                print(" ".join(parser.test_files))

    def commands(
        self, rules_file="scripts/ci/regression-scope/rules.json", compare_to="HEAD"
    ):
        """
        Print the commands that should be executed to test the changes
        """
        with open(rules_file) as rules_file:
            self.rules = json.load(rules_file)["rules"]
        self.changed_files = get_changed_files(compare_to)
        for rule in self.rules:
            parser = RuleParser(rule, self.changed_files)
            parser.match_rule()
            if len(parser.commands) > 0:
                for cmd in parser.commands:
                    print(" ".join(cmd))

    def execute(
        self, rules_file="scripts/ci/regression-scope/rules.json", compare_to="HEAD"
    ):
        """
        Run the test suites to be tested for the current changes
        """
        with open(self) as rules_file:
            self.rules = json.load(rules_file)["rules"]
        self.changed_files = get_changed_files(compare_to)
        for rule in self.rules:
            parser = RuleParser(rule, self.changed_files)
            parser.match_rule()
            for cmd in parser.commands:
                subprocess.run(cmd, env=parser.env, stdout=sys.stdout)


if __name__ == "__main__":
    if "--help" in sys.argv or "-h" in sys.argv:
        # remove all arguments except the script name to print
        # fire generated help message
        sys.argv = sys.argv[:1]
    fire.Fire(CLI)
