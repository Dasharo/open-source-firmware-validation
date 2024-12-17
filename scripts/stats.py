#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

from robot.model import SuiteVisitor
from robot.running import TestSuiteBuilder


class TestCasesFinder(SuiteVisitor):
    def __init__(self):
        self.tests = []

    def visit_test(self, test):
        self.tests.append(test)


def get_test_cases_from_dir(directory):
    builder = TestSuiteBuilder()
    testsuite = builder.build(directory)
    finder = TestCasesFinder()
    testsuite.visit(finder)

    list_of_tests = finder.tests
    number_of_tests = len(list_of_tests)

    return number_of_tests, list_of_tests


dirs = [
    "dasharo-compatibility/",
    "dasharo-security/",
    "dasharo-stability/",
    "dasharo-performance/",
    "self-tests/",
]

for directory in dirs:
    number_of_tests, list_of_tests = get_test_cases_from_dir(directory)
    print(f"Number of test cases in {directory}: {number_of_tests}\n")

    print("Test case names:\n")
    for test in list_of_tests:
        print(test.name)


# Chatgpt graph source code
# # Create the bar chart with numbers on the bars
# plt.figure(figsize=(10, 6))
# bars = plt.bar(modules, test_counts, color=['blue', 'green', 'red', 'purple', 'orange'])
#
# # Add titles and labels
# plt.title('Number of Tests in Modules')
# plt.xlabel('Modules')
# plt.ylabel('Number of Tests')
#
# # Add text labels on the bars
# for bar in bars:
#     height = bar.get_height()
#     plt.text(
#         bar.get_x() + bar.get_width() / 2, height - 10,
#         f'{height}', ha='center', va='bottom', color='white', fontsize=10
#     )
#
# # Display the graph
# plt.xticks(rotation=45, ha="right")
# plt.tight_layout()
# plt.show()
