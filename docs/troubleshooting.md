<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: MIT
-->

# Troubleshooting

## Tests fail on 'Suite Setup' - 'To Boot Directly' not found

If DUT is configured to use a PiKVM it is important to make sure that the serial
output is enabled in the firmware and this setting is turned on by default.
This issue is not related to PiKVM itself. It will occur on any DUT that uses
serial connection. However PiKVM may make it look like everything is working
correctly (video output etc). On some platforms like example on the MSI
laptops, the default setting for the Serial Redirection is off. This is why
tests that flash firmware need to have the fw file modified to have the serial
enabled. Otherwise every time firmware is flashed by the test the DUT setup
will be broken. To prepare a modified fw file use:

```shell
./dcu variable ./test/data/firmware.rom --set SerialRedirection --value Enabled
```
