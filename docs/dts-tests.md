<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# DTS tests

This document describes current DTS tests coverage. Tests planned:

* E2E tests;
* Unit tests.

## E2E tests

E2E - End to End tests, tests that verify how DTS goes from start to end for
every user workflow (e.g. installation, update, etc.) for every platform.

Location in OSFV: `dts/dts-e2e.robot`.

These tests include modifications for DTS platform emulation so the tests
could be launched on Qemu. Then every test case choose the workflow by
choosing DTS menu option, and provides credentials (if necessary). So, the
start conditions are: platform configuration and workflow selection.

Then every test case goes through the chosen workflow and checks for expected
behavior. If everything goes as expected - test case passes, otherwise - it
fails.

Control variables:

* `dts_ipxe_link`: useful if you are testing DTS which is not released yet. Just
  put here a link to your script which will load your DTS. By default DTS is
  being booted from `dl.3mdeb.com`;
* `dpp_email`, `dpp_password`: for DPP credentials, if tests need them.
* `dts_config_ref`: can be set to custom dts-configs revision (default is
  `main`), either by:
    - branch name: `ref/heads/<branch_name>`
    - tag: `refs/tags/<tag_name>`
    - commit: `<commit_hash>`

Launching example:

```bash
robot -b command_log.txt -v snipeit:no -L TRACE -v config:qemu -v rte_ip:127.0.0.1 -v boot_dts_from_ipxe_shell:True -v dts_ipxe_link:http://192.168.0.102:8080/ipxe -v dpp_email:'EMAIL' -v dpp_password:'PASSWORD' -v dts_config_ref:'refs/heads/develop' -t "E2E006.002*" dts/dts-e2e.robot
```

> Note: replace `EMAIL` and `PASSWORD` with appropriate credentials if required.
> `http://192.168.0.102:8080/ipxe` with your DTS iPXE
> script link.

### Adding new E2E template tests

Important variables in `default.robot`:

* `DTS_TEST_VERSION_BASE` - default firmware version used for every workflow for
  that platform unless overwritten.
* `DTS_TEST_VERSIONS` - default `TEST_BIOS_VERSION` strings for each
  workflow. At minimum this dictionary has to have defined key for each workflow
  in `DTS_TEST_WORKFLOWS`. You can use `&{DTS_TEST_VERSIONS_BASE}` as a base if
  you need to modify only a couple of values, e.g. to change `TEST_BIOS_VERSION`
  export only for `UEFI Update` while keeping rest the same:

  ```robot
  &{DTS_TEST_VERSIONS}=    &{DTS_TEST_VERSIONS_BASE}    UEFI Update=Dasharo (slimbootloader+UEFI)
  ```

* `DTS_TEST_HAS_EC` - If `${TRUE}` then sets `TEST_USING_OPENSOURCE_EC_FIRM` for
  all non-initial deployment workflows.
* `DTS_TEST_BASE_EXPORTS` - Base DTS exports, used in likely every workflow
* `DTS_TEST_EXPORTS` - List of DTS exports when testing platform, you can expand
  it similarly to `DTS_TEST_VERSIONS` variable
* `DTS_TEST_WORKFLOWS` - List of workflows that platform supports
* `DTS_TEST_DEFAULT_RELEASES` - Used in `DTS_TEST_WORKFLOW_RELEASES_BASE` to set
  releases for every workflow. If your platform supports only one type of
  release for all/most of the workflows, then you can change this variable
* `DTS_TEST_WORKFLOW_RELEASES_BASE` - Dictionary containing list of every
  release (taken from `DTS_TEST_DEFAULT_RELEASES`) supported by each workflow
* `DTS_TEST_WORKFLOW_RELEASES` - This variable is used to determine which
  releases each workflow supports.

To add new platform set `${DTS_SUPPORT}` to `${TRUE}` and add a list of
workflows that this platform supports to `@{DTS_TEST_WORKFLOWS}`. You can check
allowed values in `default.robot` in `DTS_TEST_POSSIBLE_WORKFLOWS` variable.
This is minimum required to make test run. After that you need to configure
additional variables and/or exports to correctly simulate your platform.

You can check which variables are exported by default for each workflow by
running:

```sh
robot -L TRACE -v config:<platform> -t "E2EH002*" dts/dts-e2e-helper.robot`
```

To add completely new workflow you need to at minimum add it to
`DTS_TEST_POSSIBLE_WORKFLOWS` in `default.robot` and then define keyword for
this test in `dts-e2e.robot` in format:

```robot
${platform} <your workflow name> - ${release}
```

or

```robot
${platform} <your workflow name> - DPP
${platform} <your workflow name> - DCR
```

After that you can add this workflow to `DTS_TEST_WORKFLOWS` variable in
platform that supports it.

You also need to keep in mind, that some exports are set/chosen in
`Prepare Test Exports` keyword in `dts-lib.robot`, mostly those that depend on
type of workflow.

## Unit tests

These tests have not been implemented yet.
