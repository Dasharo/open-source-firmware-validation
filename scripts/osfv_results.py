#!/usr/bin/env python3

import argparse
import time

import gspread
from gspread.exceptions import APIError
from oauth2client.service_account import ServiceAccountCredentials
from robot.api import ExecutionResult, ResultVisitor

# Global variables
SPREADSHEET_URL = "https://docs.google.com/spreadsheets/d/1wSE6xA3K3nXewwLn5lV39_2wZL1kg5AkGb4mvmG3bwE"
WORKSHEET_NAME = "Results"
CREDS_FILE = "spreadsheet-creds.json"


class MyResultVisitor(ResultVisitor):
    def __init__(self):
        self.results = {}

    def visit_test(self, test):
        test_id = test.name.split()[
            0
        ]  # Assuming Test ID is the first part of the test name
        self.results[test_id] = test.status


def retry_function(func, *args, **kwargs):
    while True:
        try:
            return func(*args, **kwargs)
        except APIError as e:
            if e.response.status_code == 429:  # Rate limit exceeded
                print(f"Rate limit exceeded. Waiting and retrying...")
                time.sleep(10)  # Wait for 10 seconds before retrying
            else:
                raise  # Rethrow any other APIError


def read_cell(sheet, row, col):
    return retry_function(sheet.cell, row, col).value.strip()


def update_cell(sheet, row, col, value):
    retry_function(sheet.update_cell, row, col, value)


def update_spreadsheet(results, version_header, verbose=False):
    scope = [
        "https://spreadsheets.google.com/feeds",
        "https://www.googleapis.com/auth/drive",
    ]
    creds = ServiceAccountCredentials.from_json_keyfile_name(CREDS_FILE, scope)
    client = gspread.authorize(creds)
    sheet = client.open_by_url(SPREADSHEET_URL).worksheet(WORKSHEET_NAME)

    # Find the appropriate column for the given version header
    version_column = find_version_column(sheet, version_header)

    # Get all test IDs from the spreadsheet
    test_ids_raw = retry_function(
        sheet.col_values, 2
    )  # Assuming Test IDs are in the second column

    # Strip whitespace from all test IDs in the spreadsheet to normalize
    test_ids = [test_id.strip() for test_id in test_ids_raw]

    overwrite_all = False  # Flag to track if user wants to overwrite all future cells

    # Iterate over the results dictionary to update the spreadsheet
    for test_id, status in results.items():
        # Find the row number for the current test ID in the spreadsheet
        try:
            row_num = (
                test_ids.index(test_id) + 1
            )  # Adjust for 1-based indexing in Google Sheets

            # Read current value from the cell
            current_value = read_cell(sheet, row_num, version_column)

            if current_value == status:
                if verbose:
                    print(
                        f"{test_id}: Cell in Row {row_num}, Column {version_column} already contains '{status}'. Skipping update."
                    )
                continue  # Skip update if current content matches the result

            if current_value and overwrite_all is False:
                print(
                    f"{test_id}: Cell in Row {row_num}, Column {version_column} is already populated with: '{current_value}'"
                )
                while True:
                    confirmation = (
                        input(
                            f"Do you want to overwrite this cell with: {status}? [(y)es,(n)o,(a)ll,(e)xit]: "
                        )
                        .strip()
                        .lower()
                    )
                    if confirmation in ["y", "n", "a", "e", "yes", "no", "all," "exit"]:
                        break  # Exit the loop if a valid answer is given
                    else:
                        print("Please enter a valid option [(y)es,(n)o,(a)ll,(e)xit].")

                if confirmation == "n" or confirmation == "no":
                    continue  # Skip this update
                elif confirmation == "a" or confirmation == "all":
                    overwrite_all = True
                elif confirmation == "e":
                    break  # Stop updating cells and exit

            # Update the cell with the new value
            update_cell(sheet, row_num, version_column, status)
            if verbose:
                print(
                    f"Updated cell: Row {row_num}, Column {version_column} with Status '{status}' for Test ID '{test_id}'"
                )

        except ValueError:
            print(f"Test ID '{test_id}' not found in the spreadsheet. Skipping update.")


def find_version_column(sheet, version_header):
    header_row = retry_function(sheet.row_values, 2)
    if version_header in header_row:
        return header_row.index(version_header) + 1
    else:
        raise ValueError(
            f"Version header '{version_header}' not found in the spreadsheet."
        )


def parse_robot_results(xml_file):
    visitor = MyResultVisitor()
    result = ExecutionResult(xml_file)
    result.visit(visitor)
    return visitor.results


def update_command(args):
    # Parse the Robot Framework results
    results = parse_robot_results(args.xml_file)

    # Join version_header into a single string
    version_header = " ".join(args.version_header)

    # Update the spreadsheet with the parsed results
    update_spreadsheet(results, version_header, verbose=args.verbose)


def download_command(args):
    # Placeholder for download command implementation
    print("Download command is not implemented yet.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Manage Open Source Firmware Validation results in Google Sheets."
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Update command parser
    update_parser = subparsers.add_parser(
        "update", help="Update spreadsheet with Robot Framework results."
    )
    update_parser.add_argument(
        "xml_file", help="Path to the Robot Framework XML results file."
    )
    update_parser.add_argument(
        "version_header",
        nargs="+",
        help="Header name of the version column to update (enclose in quotes).",
    )
    update_parser.add_argument(
        "--verbose", action="store_true", help="Enable verbose logging for updates."
    )

    # Download command parser (placeholder)
    download_parser = subparsers.add_parser(
        "download", help="Download results from Google Sheets (not implemented yet)."
    )

    args = parser.parse_args()

    # Execute the appropriate command based on user input
    if args.command == "update":
        update_command(args)
    elif args.command == "download":
        download_command(args)
    else:
        parser.print_help()
