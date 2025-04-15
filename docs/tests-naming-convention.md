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
loosely. `environment_id`s with leading `0` don't use the
convention above.
