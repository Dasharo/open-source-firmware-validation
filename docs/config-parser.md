<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: MIT
-->

# Config parser

## Intro

One significant bit of work when adding a new platform, or updating the
platform config for a new release, is listing all the features and looking up
what test flags they correspond to. The `config_parser.py` script seeks to
automate at least part of that process.

It takes the config file used to build the binary, where most if not all
features of the release should be encoded, and outputs a platform config file.

## Usage

The script should be used in the following manner:

```sh
 ./scripts/config_parser.py config.input output.robot
```

Where `config.input` is the coreboot config file, and `output.robot` is the
resulting OSFV platform config file. Both the full `.config` and a defconfig
can be used, although the `.config` will probably yield more matches.

## Extendability, contribution

The list of known option:flag pairs and value remapping rules are set in the
`scripts/lib/mappings.json` file.

By default, the script maps `y` to `${TRUE}` and `n` to `${FALSE}` or simply
copies over the value from the option to the flag. This behavior can be
overridden by editing the aforementioned json file. The format is rather easy
to figure out - it works as follows:

```json
{
  "options": {
    "CONFIG_OPTION_1": "TARGET_TEST_FLAG_1",
    "CONFIG_OPTION_2": "TARGET_TEST_FLAG_2"
  },
  "values": {
    "TARGET_TEST_FLAG_1": {
      "CONFIG_OPTION_1_VALUE_1": "TARGET_TEST_FLAG_1_VALUE_1",
      "CONFIG_OPTION_1_VALUE_2": "TARGET_TEST_FLAG_1_VALUE_2"
    },
    "TARGET_TEST_FLAG_2": {
      "CONFIG_OPTION_2_VALUE_1": "TARGET_TEST_FLAG_2_VALUE_1",
      "CONFIG_OPTION_2_VALUE_2": "TARGET_TEST_FLAG_2_VALUE_2"
    }
  }
}
```

So, for example:

```json
{
  "options": {
    "CONFIG_MAINBOARD_POWER_FAILURE_STATE": "DEFAULT_POWER_STATE_AFTER_FAIL",
  },
  "values": {
    "DEFAULT_POWER_STATE_AFTER_FAIL": {
      "0": "Powered Off",
      "1": "Powered On",
      "2": "The state at the moment of power failure"
    }
  }
}
```

will remap `CONFIG_MAINBOARD_POWER_FAILURE_STATE=0` to
`${DEFAULT_POWER_STATE_AFTER_FAIL}=    Powered Off`, and so on.

If you see a good option:flag pair that can be added, a contribution will be
very much welcome. You have a chance of speeding up the process for yourself
and for others in the future.

## Future improvements

The entire `.config` is stored in each of our release binaries. Further
automation could involve extracting the config from the binary with
`cbfstool coreboot.rom extract -n config -f dotconfig` and updating the config
with the parser automatically, e.g., as part of the regression testing process.
