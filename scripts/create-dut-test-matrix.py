#!/usr/bin/env python3

import os
import os.path
import sys
import pandas as pd
import re
import numpy as np


MATRIX_URL = r"https://docs.google.com/spreadsheets/d/1wSE6xA3K3nXewwLn5lV39_2wZL1kg5AkGb4mvmG3bwE/export?format=csv&gid=1742235393#gid=1742235393"

INCLUDE_TEST_STATUSES = [
    "AUTOMATED",
    "MANUAL",
    "SEMI-AUTOMATED",
]

ID_COLUMN = "Test ID"
MODULE_COLUMN = "Module"
NAME_COLUMN = "Product"

INCLUDE_MATRIX_COLUMNS = [
    MODULE_COLUMN,
    ID_COLUMN,
    NAME_COLUMN,
]

TEST_MATRIX_FILENAME = "test-matrix.md"

TEST_MATRIX_FILENAME


def should_be_dropped(row):
    return all(x not in INCLUDE_TEST_STATUSES for x in row)


def get_test_cases(column: str, data_from_matrix: pd.DataFrame) -> pd.DataFrame:

    # Create a mask, 1 if should be dropped, 0 otherwise
    mask = data_from_matrix.apply(should_be_dropped, axis=1)

    # Filter using the mask
    selected = data_from_matrix[~mask]
    selected = selected.dropna()

    return selected

def group_tests(test_cases: pd.DataFrame):
    modules = {}
    suites = {}
    for test in test_cases.iterrows():
        test = test[1]
        module = test[MODULE_COLUMN]
        suite = re.search('([A-Z]{3,})[0-9]{3}.[0-9]{3}', test[ID_COLUMN])

        if suite is None:
            suite = ""
        else:
            suite = suite.group(1)

        if module not in modules:
            modules[module] = {module: {}}

        if suite not in modules[module]:
            modules[module][suite] = []

        modules[module][suite].append(test)

    return modules



def write_file(file, modules):
    for module_name in modules:
        print(module_name)
        file.write(f"""
    ## Module: {module_name}

    | No. | Supported test suite                  | Test suite ID | Supported test cases                 |
    |:---:|:--------------------------------------|:-------------:|:-------------------------------------|
""")
        module = modules[module_name]
        i = 0
        for suite_id in module:
            if suite_id == module_name:
                continue
            suite = module[suite_id]
            suite_name = suite[0][NAME_COLUMN]
            test_ids = ""
            for test in suite:
                test_ids += test[ID_COLUMN] + ","
            i += 1
            file.write(f"""
    | {i}. | [{suite_name}][{suite_id}] | {suite_id} | {test_ids} |
""")
        





def print_help():
    print(
"""
Usage:
    - Create test-matrix.md documentation file basing on test matrix spreadsheet:
        $ ./create-dut-test-matrix.py <matrix column name>
""")

def main():
    args = sys.argv[1:]

    if len(args) < 1:
        print_help()
        exit()
    
    dut_model = args[0]

    # Download the Matrix
    print("-- Downloading: " + MATRIX_URL)
    INCLUDE_MATRIX_COLUMNS.append(dut_model)
    data_from_matrix: pd.DataFrame = pd.read_csv(
        MATRIX_URL, 
        usecols=INCLUDE_MATRIX_COLUMNS,
        skiprows=1)

    test_cases = get_test_cases(dut_model, data_from_matrix)
    modules = group_tests(test_cases)

    with open(TEST_MATRIX_FILENAME, "w") as matrix_file:
        write_file(matrix_file, modules)


    print ("-- Done.")

if __name__ == "__main__":
    main()
