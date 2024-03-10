## Adding new platforms

Depending on what type of platform you're adding, the instructions here will
vary.

### Adding a brand new platform

- Create a new file for your mainboard in `platform-configs/`. For most
  platforms this file will be called `[platform-vendor]-[platform-model].robot`.
- Add the following at the top of your platform config:

```robot
*** Settings ***
Resource    default.robot
```

- Copy the contents of `include/default.robot` to your platform config
- Modify the file for your platform:
    - Modify the settings appropriately for your mainboard
    - Remove any unmodified lines - they will be sourced from `default.robot`
- Add the platform configuration to `variables.robot:
    - Create a new configuration of RTE, if you are using one, e.g.:

    ```robot
    &{RTE11}=                   ip=192.168.10.174    cpuid=02c000426621f7ea    pcb_rev=1.0.0
    ...                         platform=apu4    board-revision=4d    env=prod
    ...                         platform_vendor=PC Engines    firmware_type=UEFI
    ```

    - Add the RTE to the list:

    ```
    @{RTE_LIST}=                &{RTE05}
    ...                         &{RTE06}    &{RTE07}    &{RTE08}    &{RTE09}    &{RTE10}
    ...                         &{RTE11}
    ```

    - Do the same for any modules installed in the platform
    - Create a new CONFIG contaning the RTE and modules used for testing, and
      append it to the list:

    ```
    @{CONFIG04}=                &{RTE11}    &{SSD06}    &{CARD06}    &{USB03}
    ...                         &{MODULE06}    &{ADAPTER01}    &{MODULE10}

    @{CONFIG_LIST}=             @{CONFIG01}    @{CONFIG02}    @{CONFIG03}    @{CONFIG04}
    ```

    - Run a simple test to verify the config is working correctly - for example
      UEFI Shell:

    ```
    robot -v snipeit:no -L TRACE -v rte_ip:192.168.10.174 -v device_ip:0.0.0.0 -v config:pcengines-apu4 dasharo-compatibility/uefi-shell.robot
    ```

### Adding new variant of an existing platform

Some boards come in multiple variants, where the majority of properties and
features can be shared. For these cases, we have shared "base" configs in
`platform-configs/include/`. This way we don't need to copy-paste entire config
files, making maintenance easier. In this example we'll be adding a new PC
Engines apu variant, using an existing pcengines base config:

- Create a config file in `platform-configs` for your platform
- Add the following to your platform config

```
*** Settings ***
Resource    include/pcengines.robot
```

- Add variant-specific settings for your platform - in this case, only the
  SMBIOS product name field:

```
*** Variables ***
${DMIDECODE_PRODUCT_NAME}=      apu4
```

- Proceed with adding the platform to `variables.robot` as per
[Adding a brand new platform](#adding-a-brand-new-platform).
