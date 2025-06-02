#!/usr/bin/env python

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import os
import sys
from getpass import getpass

import requests
from requests.auth import HTTPBasicAuth

IP = os.getenv("DB_SERVER_IP")
COUCHDB_URL = f"http://{IP}/test_cases"

FAIL = "\033[91m\033[1m"
ENDC = "\033[0m"


def main():
    with open("test_cases.json", "r") as file:
        local_json = json.load(file)

    try:
        response = requests.get(
            f"{COUCHDB_URL}/_all_docs?include_docs=true",
            auth=HTTPBasicAuth("web", "site"),  # Add authentication
        )
    except Exception as e:
        print(f"{FAIL}Error connecting to the database: {repr(e)}{ENDC}")
        sys.exit(1)

    if response.status_code in (200, 201):
        print(f"Test cases successfully downloaded.")
    else:
        print(
            f"{FAIL}Failed to download test cases. HTTP {response.status_code}: {response.text}{ENDC}"
        )
        sys.exit(1)

    remote_json_full = response.json()["rows"]
    remote_json = []

    # Make remote JSON look like the copy in file
    for doc in remote_json_full:
        # skip design docs
        if doc["id"].startswith("_design"):
            continue

        # make a copy of just the body of the document (no id, key or value)
        new_doc = doc["doc"].copy()

        # remove _rev
        del new_doc["_rev"]

        remote_json.append({"doc": new_doc})

    if local_json == remote_json:
        print(f"Remote is up to date, nothing to do.")
        sys.exit(0)

    # Filter out cases that aren't changed from both lists
    for doc in remote_json[:]:
        try:
            local_json.remove(doc)
        except ValueError:
            # doc not present in local copy, meaning it has changed
            continue

        # since we're iterating over remote_json, doc will always be there
        remote_json.remove(doc)

    updated_cases = []

    # Filter out cases that were changed, but exist in DB
    for doc in remote_json[:]:
        for localdoc in local_json:
            if doc["doc"]["_id"] == localdoc["doc"]["_id"]:
                # found but not identical, will have to be updated
                updated_cases.append(doc["doc"]["_id"])
                remote_json.remove(doc)
                break

    if len(remote_json) > 0:
        print(
            f"{FAIL}Database has cases which are not present in the local copy.\n"
            f"Make sure you're using correct, up-to-date branch.{ENDC}"
        )
        sys.exit(1)

    print(f"These local changes will be uploaded:")
    print(json.dumps(local_json, indent=2))

    confirm = ""

    try:
        confirm = input(f"\nIs that correct? [N/y] ")
    finally:  # to handle ^C (KeyboardInterrupt) and ^D (EOFError) gracefully
        if confirm != "y" and confirm != "Y":
            print(f"\nAborting")
            sys.exit(0)

    try:
        user = input(f"Enter user name: ")
        # TODO: check if this works without interactive terminal
        password = getpass()
    except:
        print(f"\nAborting")
        sys.exit(1)

    for doc in local_json[:]:
        if doc["doc"]["_id"] in updated_cases:
            # existing doc, update requires _rev
            for d in remote_json_full:
                if d["id"] == doc["doc"]["_id"]:
                    rev = d["doc"]["_rev"]
                    break
            try:
                response = requests.put(
                    f"{COUCHDB_URL}/{doc['doc']['_id']}?rev={rev}",
                    json=doc["doc"],
                    auth=HTTPBasicAuth(user, password),  # Add authentication
                )
            except Exception as e:
                print(f"{FAIL}Error connecting to the database: {repr(e)}{ENDC}")
                sys.exit(1)

            if response.status_code in (200, 201):
                print(f"Test case {doc['doc']['_id']} successfully updated.")
                local_json.remove(doc)
            else:
                print(
                    f"{FAIL}Failed to update {doc['doc']['_id']}. HTTP {response.status_code}: {response.text}{ENDC}"
                )

        else:
            # new doc, POST can be used
            try:
                response = requests.post(
                    f"{COUCHDB_URL}",
                    json=doc["doc"],
                    auth=HTTPBasicAuth(user, password),  # Add authentication
                )
            except Exception as e:
                print(f"{FAIL}Error connecting to the database: {repr(e)}{ENDC}")
                sys.exit(1)

            if response.status_code in (200, 201):
                print(f"New test case {doc['doc']['_id']} successfully added.")
                local_json.remove(doc)
            else:
                print(
                    f"{FAIL}Failed to create {doc['doc']['_id']}. HTTP {response.status_code}: {response.text}{ENDC}"
                )

    print(f"Finished sending of all modified test cases.")

    if len(local_json) > 0:
        print(f"{FAIL}These documents failed to be created/updated:\n")
        print(json.dumps(local_json, indent=2))
        print(f"{ENDC}")


if __name__ == "__main__":
    main()
