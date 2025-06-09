#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import subprocess

import fire
import matplotlib.pyplot as plt
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


def get_module_counts(module_dirs):
    counts = {}
    for directory in module_dirs:
        number_of_tests, _ = get_test_cases_from_dir(directory)
        counts[directory] = number_of_tests
    return counts


def plot_test_counts(
    counts,
    show_graph=True,
    save_graph=False,
    filename="test_counts.png",
    title="Number of Tests in Modules",
):
    figure = plt.figure(figsize=(10, 6))
    ax = figure.add_subplot()
    bars = ax.bar(
        counts.keys(),
        counts.values(),
        label=counts.keys(),
        color=[
            "#1f77b4",
            "#ff7f0e",
            "#2ca02c",
            "#d62728",
            "#9467bd",
            "#8c564b",
            "#e377c2",
        ],
    )

    # Add titles and labels
    ax.set_title(title)
    ax.set_xlabel("Modules")
    ax.set_ylabel("Number of Tests")

    # Add text labels on the bars
    for bar in bars:
        height = bar.get_height()
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            height,
            f"{height}",
            ha="center",
            va="bottom",
            fontsize=10,
        )

    # Display the graph
    ax.set_xticks(range(len(counts.keys())))
    ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha="right")
    ax.legend(title="Modules", loc="upper right")
    figure.tight_layout()

    if save_graph:
        plt.savefig(filename, dpi=300)
    if show_graph:
        plt.show()


class RevisionChanger:
    def __init__(self):
        self.initial_revision = (
            subprocess.check_output(["git", "rev-parse", "HEAD"])
            .strip()
            .decode("utf-8")
        )

    def change_revision(self, revision):
        try:
            subprocess.run(["git", "checkout", revision, "-q"], check=True)
            print(f"Changed to revision: {revision}")
        except subprocess.CalledProcessError as e:
            print(f"Error changing to revision {revision}: {e}")

    def restore_initial_revision(self):
        self.change_revision(self.initial_revision)


MODULE_DIRS = [
    "dasharo-compatibility",
    "dasharo-security",
    "dasharo-stability",
    "dasharo-performance",
    "self-tests",
    "trenchboot",
    "dts",
]


def generate_stats(text=True, graphs=True, compare_against=None):
    """
    Generate statistics for test cases in specified modules.
    :param text: If True, print the statistics.
    :param graphs: If True, generate graphs for the statistics.
    :param compare_against: If provided, compare against this revision.
    """
    count_per_module = get_module_counts(MODULE_DIRS)

    if compare_against:
        revision_changer = RevisionChanger()
        revision_changer.change_revision(compare_against)
        previous_count_per_module = get_module_counts(MODULE_DIRS)
        difference_per_module = {
            module: count_per_module[module] - previous_count_per_module[module]
            for module in count_per_module
        }
        revision_changer.restore_initial_revision()

        if text:
            print("\nDifference in test cases compared to previous revision:")
            for module, difference in difference_per_module.items():
                print(f"{module}: {difference}")

        if graphs:
            plot_test_counts(
                difference_per_module,
                filename="test_counts_difference.png",
                title="Difference in Number of Tests in Modules",
            )
    else:
        if text:
            for module, count in count_per_module.items():
                print(f"Number of test cases in {module}: {count}")
        if graphs:
            plot_test_counts(count_per_module, show_graph=True, save_graph=True)


if __name__ == "__main__":
    fire.Fire(generate_stats)
