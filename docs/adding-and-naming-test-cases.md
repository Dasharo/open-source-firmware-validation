<!--
SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# Tests naming Convention

The tests in the Open Source Firmware Validation repository use the following
naming convention:

`<suite_id><case_id>.<environment_id>`

where:
- `suite_id` - It's typically 3 to 4 letters, uppercase, identifies the
  test suite. Should be related to what the test suite accomplishes.
  Examples:
- `PSW001.001` - the `PSW` test suite tests the UEFI setup password functionality.
  Name is clearly derived from the word `Password`.
- `CBO001.001` - the suite tests customizing the boot order. The name is an acronym
  of `Custom Boot Order`
- `case_id` - It's a three digit number with leading zeros. Identifies test
  cases in a test suite. Typically test cases are numbered incrementally
  starting from `001`.
  Examples:
    + `VBO001.001`
    + `VBO002.001`
    + `VBO003.001`
    + `VBO004.001`
- `environment_id` - A three digit number, unambiguously identifies the
  environment in which the test case is performed. The IDs of environments
  are separated into groups based on the leading digit:
    + `1xx` - Firmware
    Example: `101` - EDK2 UEFI
    + `2xx` - Linux
    Example: `201` - Ubuntu
    + `3xx` - Windows
    Example: `301` - Windows 11

**❗Note:** test IDs must be never reused, even if the test no longer exists.
This is required since old releases may still have results referencing it. All
IDs, current and obsolete, are listed in `test_cases.json` file, which is
described [below](#synchronization-with-database). This file must always be kept
in sync with the code.

All the `environment_id`s of all the tested environments are defined as
Robot Framework variables in the `os-config/environment-test-ids.py` file.

**❗Note:** in old test cases the `environment_id` segment was used more
loosely. `environment_id`s with leading `0` don't use the convention above.

The compliance to the test naming convention is verified by the pre-commit
scripts and by the CI on every Pull Request that modifies the test cases
or the `test_cases.json` file.

## Transitioning

When updating a test case ID to follow the convention,
append the old ID in the keyword documentation after `Previous IDs:`
to help with identifying the test cases during transition. Example (not from
actual test case):

```robot
DSP002.201 - External HDMI display in OS (Ubuntu)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Linux OS. An external HDMI display must be provided in
    ...    the platform config.
    ...
    ...    Previous IDs: ABC042.001 DSP002.001
    (...)
```

If the ID is changed again for the same test, the newer `Previous ID` is added
to the end of line, with single space as a separator (i.e. no comma or semicolon
between them). This format is expected by a script described [later](#validate).
In the example above, `ABC042.001` was changed to `DSP002.001`, which was later
changed to `DSP002.201`.

# Synchronization with database

`test_cases.json` is the source of truth when it comes to test cases. It is the
task of the developer that works on test cases to update this JSON in the same
pull request as changes to the code.

Few examples of test cases in the mentioned JSON file:

```json
[
...
  {
    "doc": {
      "_id": "APU006.002",
      "name": "Enabling \"Enable PCIe power management features\" enables ASPM",
      "module": "Dasharo Compatibility"
    }
  },
  {
    "doc": {
      "_id": "AUD001.001",
      "name": "Audio subsystem detection (Ubuntu)",
      "module": "Dasharo Compatibility",
      "changed_to": "AUD001.201"
    }
  },
...
  {
    "doc": {
      "_id": "AUD001.201",
      "name": "Audio subsystem detection (Ubuntu)",
      "module": "Dasharo Compatibility"
    }
  },
...
  {
    "doc": {
      "_id": "ECR017.201",
      "name": "Keyboard (function key: flight mode) in OS (Ubuntu)",
      "module": "Dasharo Compatibility"
    }
  },
...
  {
    "doc": {
      "_id": "WLE003.202",
      "name": "Bluetooth scanning (Fedora)",
      "module": "Dasharo Compatibility"
    }
  }
]
```

Important to note:

- This must be kept as a valid JSON file, so the last fields of an object and
  the last object of an array must not contain a trailing comma.
- Double quotation marks in the test name must be escaped, but parentheses,
  colons and single quotation marks must not. Other fields aren't expected to
  have any of those characters.
- Format must be preserved, `_id`, `name` and `module` fields are required. For
  ease of navigation, keep the as first fields of an object, in that order. New
  fields may be added in the future.
- `module` must be one of `Dasharo Compatibility`, `Dasharo Performance`,
  `Dasharo Security` or `Dasharo Stability`, case sensitive - both words start
  with a capital letter.
- `changed_to` is optional, if it is present, it indicates that the `_id` is
  obsolete and shouldn't be used in new releases. When it exists, it must contain
  another existing test case ID (which may also have a `changed_to` field,
  creating a chronological chain of ID modifications).
- The file is ordered alphabetically by `_id`, keep it that way. This can be
  tested with the following command:

    ```shell
    diff -q <(jq 'sort_by(.doc._id)' test_cases.json) <(jq '.' test_cases.json)
    ```

Before **creating** a new test case, check if the ID isn't and never was in use.
If the ID isn't present in JSON, it may be used, but keep in mind that other
developers may work on other PRs concurrently and may want to use the same ID.
Since both the test development and JSON update is done in the same PR, a merge
conflict clearly shows that a different ID has to be used.

Each time a test name, ID or module is **modified**, the change must be reflected
in `test_cases.json` file. This includes previous IDs, which are saved in
`changed_to` key. Note that there is only one ID in that key. Each ID change
results in _creation_ of a new object in JSON file, and _modification_ of the
existing one by pointing to the new ID.

Test IDs are **never removed**. This is required to keep references in the old
releases valid. It also makes sure that the ID won't be reused.

## Scripts

### Validate

Two scripts are used for listing existing test cases, both active ones as well
as those with deprecated IDs:

- `scripts/list-tests-from-robot.sh` - finds active (lines starting with
  something resembling an ID) and obsolete (`Previous IDs`, see
  [Transitioning](#transitioning)) IDs in files in `dasharo-*` directories
  (i.e. test cases in all Dasharo `*.robot` files), and prints a sorted list of
  all of them.
- `scripts/list-tests-from-json.sh` - finds active (without `changed_to` field)
  and obsolete (with that field) IDs in `test_cases.json` file, and prints a
  list of all of them. The script doesn't sort the output, which indirectly
  checks that JSON file is properly sorted.

Output of both of those scripts consists of ID followed by either full test name
(if the test is active) or `DEPRECATED` (if the test ID is obsolete). Comparison
of the outputs can be used to check whether test cases in source files and their
copy in `test_cases.json` are in sync. Possible use cases:

- CI that tests whether PR can be merged:

    ```shell
    diff -q <(./scripts/list-tests-from-robot.sh) \
            <(./scripts/list-tests-from-json.sh) || \
    (echo "Detected inconsistency between source files and test_cases.json" && false)
    ```

- manual inspection of differences between the two:

    ```shell
    diff --side-by-side -W200 <(./scripts/list-tests-from-robot.sh) \
                              <(./scripts/list-tests-from-json.sh) | less
    ```

**❗Note:** neither of those scripts validates whether `Previous IDs`/`changed_to`
is pointing from/to proper test case, nor that they match each other. The
responsibility for making sure the mapping is valid is shared between the author
and the reviewer.

### Synchronize

The synchronization is performed by `scripts/synchronize-db.py`. The script is
to be started from top directory and doesn't take any parameters, but it reads
database IP (and port) from environmental variable `DB_SERVER_IP`. It will
interactively ask for user credentials. The user must have _Test case developer_
permissions. Example usage, assuming database server running on localhost:

```shell
DB_SERVER_IP=127.0.0.1:5984 ./scripts/synchronize-db.py
```
