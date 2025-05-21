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


class ParserManager:
    def __init__(self, rules_file, changed_files):
        self.rules_file = rules_file
        self.changed_files = changed_files

    def parse(self):
        parser_commands = []
        parser_files = []
        parser_args = []
        for rule in self.rules:
            parser = RuleParser(rule, self.changed_files)
            parser.match_rule()
            parser_commands.append(parser.commands)
            parser_files.append(parser.test_files)
            parser_args.append(parser.robot_args)
