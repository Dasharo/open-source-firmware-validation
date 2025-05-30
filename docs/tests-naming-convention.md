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

All the `environment_id`s of all the tested environments are defined as
Robot Framework variables in the `os-config/environment-test-ids.robot`
file.

**❗Note:** in old test cases the `environment_id` segment was used more
loosely. `environment_id`s with leading `0` don't use the convention above.

## Transitioning

When updating a test case ID to follow the convention,
append the old ID in the keyword documentation after `Previous IDs:`
to help with identifying the test cases during transition. Example:

```robot
DSP002.201 - External HDMI display in OS (Ubuntu)
    [Documentation]    Check whether an external HDMI display is visible in
    ...    Linux OS. An external HDMI display must be provided in
    ...    the platform config.
    ...
    ...    Previous IDs: DSP002.001
    (...)
```

# Synchronization with database

Each time a test name, ID or module is changed, the change must be reflected in
`test_cases.json` file. This includes previous IDs, which are saved in
`changed_to` key. Note that there is only one ID in that key. Each ID change
results in _creation_ of a new object in JSON file, and _modification_ of the
existing one by pointing to the new ID.

The file is ordered alphabetically by `_id`, keep it that way. This can be
tested with the following command:

```shell
diff -q <(jq 'sort_by(.doc._id)' test_cases.json) <(jq '.' test_cases.json)
```

Test IDs are **never removed**. This is required to keep references in the old
releases valid. It also makes sure that the ID won't be reused.

The synchronization is performed by `scripts/synchronize-db.py`. The script is
to be started from top directory and doesn't take any parameters. It will
interactively ask for user credentials. The user must have _Test case developer_
permissions.
