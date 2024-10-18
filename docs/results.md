<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: MIT
-->

# OSFV test results

## Publishing into spreadsheet

Results from automated tests can be published through the
`./scripts/osfv_results.py` scripts. After running `./scripts/regression.sh`,
you will have a couple of `.xml` reports in your logs directory. Results from
each of the `.xml` file can be uploaded into
[results spreadsheet](https://docs.google.com/spreadsheets/d/1wSE6xA3K3nXewwLn5lV39_2wZL1kg5AkGb4mvmG3bwE/)
as explained below.

1. Obtain the column name from the spreadsheet you wish to update - e.g. `V1211
   Protectli V1211 v0.9.2`.

2. Obtain the Google API key from BitWarden and save it under `spreadsheet-creds.json`

```shell
./scripts/osfv_results.py update \
    /home/macpijan/projects/github/dasharo/open-source-firmware-validation/logs/protectli-v1211/2024_07_03_12_31_50/dasharo-security_out.xml \
    "V1211 Protectli V1211 v0.9.2" --verbose
```

Example output:

```shell
APU001.001: Cell in Row 522, Column 28 already contains 'SKIP'. Skipping update.
APU002.001: Cell in Row 523, Column 28 already contains 'SKIP'. Skipping update.
APU003.001: Cell in Row 524, Column 28 already contains 'SKIP'. Skipping update.
APU004.001: Cell in Row 525, Column 28 already contains 'SKIP'. Skipping update.
APU005.001: Cell in Row 531, Column 28 already contains 'SKIP'. Skipping update.
APU006.001: Cell in Row 535, Column 28 already contains 'SKIP'. Skipping update.
APU006.002: Cell in Row 536, Column 28 already contains 'SKIP'. Skipping update.
AUD001.001: Cell in Row 150, Column 28 already contains 'PASS'. Skipping update.
AUD001.002: Cell in Row 151, Column 28 already contains 'FAIL'. Skipping update.
AUD004.001: Cell in Row 156, Column 28 already contains 'FAIL'. Skipping update.
BMM001.001: Cell in Row 506, Column 28 already contains 'PASS'. Skipping update.
BMM002.001: Cell in Row 507, Column 28 already contains 'PASS'. Skipping update.
BMM003.001: Cell in Row 508, Column 28 already contains 'PASS'. Skipping update.
Test ID 'BI001.001' not found in the spreadsheet. Skipping update.
BBB001.001: Cell in Row 304, Column 28 already contains 'SKIP'. Skipping update.
BBB001.002: Cell in Row 305, Column 28 already contains 'SKIP'. Skipping update.
Test ID 'CBP001.001' not found in the spreadsheet. Skipping update.
Test ID 'CBP002.001' not found in the spreadsheet. Skipping update.
Test ID 'CBP003.001' not found in the spreadsheet. Skipping update.
Test ID 'CBP004.001' not found in the spreadsheet. Skipping update.
Test ID 'CBP005.001' not found in the spreadsheet. Skipping update.
Test ID 'CBP006.001' not found in the spreadsheet. Skipping update.
Test ID 'CFN001.001' not found in the spreadsheet. Skipping update.
Test ID 'CFN002.001' not found in the spreadsheet. Skipping update.
Test ID 'FAN001.001' not found in the spreadsheet. Skipping update.
CPU001.001: Cell in Row 498, Column 28 already contains 'PASS'. Skipping update.
CPU001.002: Cell in Row 499, Column 28 already contains 'PASS'. Skipping update.
CPU002.001: Cell in Row 500, Column 28 already contains 'PASS'. Skipping update.
CPU002.002: Cell in Row 501, Column 28 already contains 'FAIL'. Skipping update.
CPU003.001: Cell in Row 502, Column 28 already contains 'PASS'. Skipping update.
CPU003.002: Cell in Row 503, Column 28 already contains 'PASS'. Skipping update.
CPU004.001: Cell in Row 504, Column 28 already contains 'PASS'. Skipping update.
CPU004.002: Cell in Row 505, Column 28 already contains 'PASS'. Skipping update.
Test ID 'THR001.001' not found in the spreadsheet. Skipping update.
Test ID 'THR001.002' not found in the spreadsheet. Skipping update.
Test ID 'THR002.001' not found in the spreadsheet. Skipping update.
CBK001.001: Cell in Row 76, Column 28 already contains 'PASS'. Skipping update.
CBK002.001: Cell in Row 77, Column 28 already contains 'PASS'. Skipping update.
Test ID 'CNB001.001' not found in the spreadsheet. Skipping update.
DTS001.001: Cell in Row 306, Column 28 already contains 'SKIP'. Skipping update.
DTS002.001: Cell in Row 307, Column 28 already contains 'SKIP'. Skipping update.
DTS003.001: Cell in Row 308, Column 28 already contains 'SKIP'. Skipping update.
DTS004.001: Cell in Row 309, Column 28 already contains 'SKIP'. Skipping update.
DTS005.001: Cell in Row 310, Column 28 already contains 'SKIP'. Skipping update.
DTS006.001: Cell in Row 311, Column 28 already contains 'SKIP'. Skipping update.
DTS007.001: Cell in Row 312, Column 28 already contains 'SKIP'. Skipping update.
DTS008.001: Cell in Row 313, Column 28 already contains 'SKIP'. Skipping update.
DCU001.001: Cell in Row 405, Column 28 is already populated with: 'NOT TESTED'
Do you want to overwrite this cell with: FAIL? [(y)yes,(n)o,(a)ll,(e)xit]: a
Updated cell: Row 405, Column 28 with Status 'FAIL' for Test ID 'DCU001.001'
DCU002.001: Cell in Row 406, Column 28 already contains 'FAIL'. Skipping update.
Updated cell: Row 407, Column 28 with Status 'FAIL' for Test ID 'DCU003.001'
DCU004.001: Cell in Row 408, Column 28 already contains 'SKIP'. Skipping update.
DSP001.002: Cell in Row 142, Column 28 already contains 'SKIP'. Skipping update.
DSP001.003: Cell in Row 143, Column 28 already contains 'SKIP'. Skipping update.
DSP002.001: Cell in Row 144, Column 28 already contains 'PASS'. Skipping update.
DSP002.002: Cell in Row 145, Column 28 already contains 'FAIL'. Skipping update.
DSP003.001: Cell in Row 147, Column 28 already contains 'FAIL'. Skipping update.
DSP003.002: Cell in Row 148, Column 28 already contains 'FAIL'. Skipping update.
DMI001.001: Cell in Row 225, Column 28 already contains 'SKIP'. Skipping update.
DMI002.001: Cell in Row 226, Column 28 already contains 'PASS'. Skipping update.
DMI003.001: Cell in Row 227, Column 28 already contains 'PASS'. Skipping update.
DMI004.001: Cell in Row 228, Column 28 already contains 'PASS'. Skipping update.
DMI005.001: Cell in Row 229, Column 28 already contains 'PASS'. Skipping update.
DMI006.001: Cell in Row 230, Column 28 already contains 'PASS'. Skipping update.
DMI007.001: Cell in Row 231, Column 28 already contains 'PASS'. Skipping update.
DMI008.001: Cell in Row 232, Column 28 already contains 'PASS'. Skipping update.
ECR001.001: Cell in Row 166, Column 28 already contains 'SKIP'. Skipping update.
ECR001.002: Cell in Row 167, Column 28 already contains 'SKIP'. Skipping update.
ECR002.001: Cell in Row 168, Column 28 already contains 'SKIP'. Skipping update.
ECR002.002: Cell in Row 169, Column 28 already contains 'SKIP'. Skipping update.
ECR003.001: Cell in Row 170, Column 28 already contains 'SKIP'. Skipping update.
ECR003.002: Cell in Row 171, Column 28 already contains 'SKIP'. Skipping update.
ECR014.001: Cell in Row 184, Column 28 already contains 'SKIP'. Skipping update.
ECR015.001: Cell in Row 185, Column 28 already contains 'SKIP'. Skipping update.
ECR016.001: Cell in Row 186, Column 28 already contains 'SKIP'. Skipping update.
ECR017.001: Cell in Row 187, Column 28 already contains 'SKIP'. Skipping update.
ECR019.001: Cell in Row 189, Column 28 already contains 'SKIP'. Skipping update.
ECR020.001: Cell in Row 191, Column 28 already contains 'SKIP'. Skipping update.
Test ID 'ECR021.001' not found in the spreadsheet. Skipping update.
ECR022.001: Cell in Row 546, Column 28 already contains 'SKIP'. Skipping update.
ECR023.001: Cell in Row 547, Column 28 already contains 'SKIP'. Skipping update.
EFI001.001: Cell in Row 95, Column 28 already contains 'PASS'. Skipping update.
EFI001.002: Cell in Row 96, Column 28 already contains 'FAIL'. Skipping update.
MMC001.001: Cell in Row 233, Column 28 already contains 'PASS'. Skipping update.
ESP001.001: Cell in Row 409, Column 28 already contains 'SKIP'. Skipping update.
Rate limit exceeded. Waiting and retrying...
Rate limit exceeded. Waiting and retrying...
Rate limit exceeded. Waiting and retrying...
Rate limit exceeded. Waiting and retrying...
Rate limit exceeded. Waiting and retrying...
ESP003.001: Cell in Row 411, Column 28 already contains 'SKIP'. Skipping update.
ESP004.001: Cell in Row 412, Column 28 already contains 'SKIP'. Skipping update.
ESP005.001: Cell in Row 413, Column 28 already contains 'SKIP'. Skipping update.
Test ID 'ESP006.001' not found in the spreadsheet. Skipping update.
ESP002.001: Cell in Row 410, Column 28 already contains 'SKIP'. Skipping update.
Test ID 'FLB001.001' not found in the spreadsheet. Skipping update.
Test ID 'FLB002.001' not found in the spreadsheet. Skipping update.
Test ID 'HWP001.001' not found in the spreadsheet. Skipping update.
Test ID 'HWP002.001' not found in the spreadsheet. Skipping update.
Test ID 'HDS001.001' not found in the spreadsheet. Skipping update.
Test ID 'HDS002.001' not found in the spreadsheet. Skipping update.
Test ID 'DVT001.001' not found in the spreadsheet. Skipping update.
Test ID 'DVT002.001' not found in the spreadsheet. Skipping update.
LCM001.001: Cell in Row 285, Column 28 already contains 'PASS'. Skipping update.
LCM001.002: Cell in Row 286, Column 28 already contains 'FAIL'. Skipping update.
LCM004.001: Cell in Row 287, Column 28 already contains 'SKIP'. Skipping update.
MPS001.001: Cell in Row 414, Column 28 already contains 'SKIP'. Skipping update.
MPS002.001: Cell in Row 415, Column 28 already contains 'SKIP'. Skipping update.
MWL001.001: Cell in Row 218, Column 28 already contains 'SKIP'. Skipping update.
MWL001.002: Cell in Row 219, Column 28 already contains 'SKIP'. Skipping update.
MWL002.001: Cell in Row 220, Column 28 already contains 'SKIP'. Skipping update.
MWL002.002: Cell in Row 221, Column 28 already contains 'SKIP'. Skipping update.
MWL003.001: Cell in Row 222, Column 28 already contains 'SKIP'. Skipping update.
MWL004.001: Cell in Row 224, Column 28 already contains 'SKIP'. Skipping update.
NBT001.001: Cell in Row 431, Column 28 already contains 'PASS'. Skipping update.
Test ID 'NBT002.001' not found in the spreadsheet. Skipping update.
Test ID 'NBT003.001' not found in the spreadsheet. Skipping update.
Test ID 'NBT004.001' not found in the spreadsheet. Skipping update.
Test ID 'NBT005.001' not found in the spreadsheet. Skipping update.
Test ID 'NBT006.001' not found in the spreadsheet. Skipping update.
Test ID 'NBT007.001' not found in the spreadsheet. Skipping update.
PXE001.001: Cell in Row 115, Column 28 already contains 'SKIP'. Skipping update.
PXE002.001: Cell in Row 116, Column 28 already contains 'SKIP'. Skipping update.
PXE003.001: Cell in Row 117, Column 28 already contains 'SKIP'. Skipping update.
PXE004.001: Cell in Row 118, Column 28 already contains 'SKIP'. Skipping update.
PXE005.001: Cell in Row 119, Column 28 already contains 'SKIP'. Skipping update.
PXE006.001: Cell in Row 120, Column 28 already contains 'SKIP'. Skipping update.
Test ID 'PXE007.001' not found in the spreadsheet. Skipping update.
NVI001.001: Cell in Row 137, Column 28 already contains 'SKIP'. Skipping update.
NVI001.002: Cell in Row 138, Column 28 already contains 'SKIP'. Skipping update.
NVI002.001: Cell in Row 139, Column 28 already contains 'SKIP'. Skipping update.
NVM001.002: Cell in Row 107, Column 28 already contains 'PASS'. Skipping update.
NVM001.003: Cell in Row 108, Column 28 already contains 'PASS'. Skipping update.
Test ID 'PBT001.001' not found in the spreadsheet. Skipping update.
Test ID 'PBT002.001' not found in the spreadsheet. Skipping update.
Test ID 'PBT003.001' not found in the spreadsheet. Skipping update.
Test ID 'PBT004.001' not found in the spreadsheet. Skipping update.
Test ID 'HIB001.001' not found in the spreadsheet. Skipping update.
SUSP005.001: Cell in Row 215, Column 28 already contains 'SKIP'. Skipping update.
SUSP005.002: Cell in Row 216, Column 28 already contains 'SKIP'. Skipping update.
SUSP005.003: Cell in Row 217, Column 28 already contains 'SKIP'. Skipping update.
PSF001.001: Cell in Row 299, Column 28 already contains 'SKIP'. Skipping update.
PSF002.001: Cell in Row 300, Column 28 already contains 'SKIP'. Skipping update.
PSF003.001: Cell in Row 301, Column 28 already contains 'SKIP'. Skipping update.
PSF004.001: Cell in Row 302, Column 28 already contains 'SKIP'. Skipping update.
PSF004.002: Cell in Row 303, Column 28 already contains 'SKIP'. Skipping update.
RTD001.001: Cell in Row 318, Column 28 already contains 'SKIP'. Skipping update.
RTD002.001: Cell in Row 319, Column 28 already contains 'SKIP'. Skipping update.
RTD003.001: Cell in Row 320, Column 28 already contains 'SKIP'. Skipping update.
RTD004.001: Cell in Row 321, Column 28 already contains 'SKIP'. Skipping update.
RTD005.001: Cell in Row 322, Column 28 already contains 'SKIP'. Skipping update.
RTD007.001: Cell in Row 324, Column 28 already contains 'SKIP'. Skipping update.
RTD008.001: Cell in Row 325, Column 28 already contains 'SKIP'. Skipping update.
RTD009.001: Cell in Row 326, Column 28 already contains 'SKIP'. Skipping update.
RTD010.001: Cell in Row 327, Column 28 already contains 'SKIP'. Skipping update.
RTD011.001: Cell in Row 328, Column 28 already contains 'SKIP'. Skipping update.
Test ID 'RTD012.001' not found in the spreadsheet. Skipping update.
Test ID 'RTD013.001' not found in the spreadsheet. Skipping update.
Test ID 'RTD014.001' not found in the spreadsheet. Skipping update.
Test ID 'RTD015.001' not found in the spreadsheet. Skipping update.
Test ID 'RTD016.001' not found in the spreadsheet. Skipping update.
Test ID 'RTD016.002' not found in the spreadsheet. Skipping update.
SDC001.001: Cell in Row 121, Column 28 already contains 'SKIP'. Skipping update.
SDC001.002: Cell in Row 122, Column 28 already contains 'SKIP'. Skipping update.
SDC002.001: Cell in Row 123, Column 28 already contains 'SKIP'. Skipping update.
SDC002.002: Cell in Row 124, Column 28 already contains 'SKIP'. Skipping update.
SET001.001: Cell in Row 450, Column 28 already contains 'PASS'. Skipping update.
SET002.001: Cell in Row 451, Column 28 already contains 'PASS'. Skipping update.
SET003.001: Cell in Row 452, Column 28 already contains 'PASS'. Skipping update.
SET004.001: Cell in Row 453, Column 28 already contains 'PASS'. Skipping update.
SET005.001: Cell in Row 454, Column 28 already contains 'PASS'. Skipping update.
SET006.001: Cell in Row 455, Column 28 already contains 'PASS'. Skipping update.
USH001.001: Cell in Row 99, Column 28 already contains 'PASS'. Skipping update.
UBT001.001: Cell in Row 441, Column 28 already contains 'FAIL'. Skipping update.
UBT002.001: Cell in Row 442, Column 28 already contains 'FAIL'. Skipping update.
UBT003.001: Cell in Row 443, Column 28 already contains 'FAIL'. Skipping update.
CAM001.001: Cell in Row 125, Column 28 already contains 'SKIP'. Skipping update.
Rate limit exceeded. Waiting and retrying...
Rate limit exceeded. Waiting and retrying...
Rate limit exceeded. Waiting and retrying...
Rate limit exceeded. Waiting and retrying...
CAM001.002: Cell in Row 126, Column 28 already contains 'SKIP'. Skipping update.
Test ID 'CAM002.001' not found in the spreadsheet. Skipping update.
UDT001.001: Cell in Row 438, Column 28 already contains 'FAIL'. Skipping update.
Test ID 'UDT002.001' not found in the spreadsheet. Skipping update.
Test ID 'UDT003.001' not found in the spreadsheet. Skipping update.
USB001.001: Cell in Row 79, Column 28 already contains 'FAIL'. Skipping update.
USB001.002: Cell in Row 80, Column 28 already contains 'FAIL'. Skipping update.
USB001.003: Cell in Row 81, Column 28 already contains 'FAIL'. Skipping update.
USB002.001: Cell in Row 82, Column 28 already contains 'PASS'. Skipping update.
USB002.002: Cell in Row 83, Column 28 already contains 'PASS'. Skipping update.
USB002.003: Cell in Row 84, Column 28 already contains 'FAIL'. Skipping update.
USB003.001: Cell in Row 85, Column 28 already contains 'SKIP'. Skipping update.
USB003.002: Cell in Row 86, Column 28 already contains 'SKIP'. Skipping update.
UTC008.001: Cell in Row 252, Column 28 already contains 'SKIP'. Skipping update.
UTC009.001: Cell in Row 254, Column 28 already contains 'SKIP'. Skipping update.
UTC010.001: Cell in Row 256, Column 28 already contains 'SKIP'. Skipping update.
UTC011.001: Cell in Row 258, Column 28 already contains 'SKIP'. Skipping update.
UTC011.002: Cell in Row 259, Column 28 already contains 'SKIP'. Skipping update.
UTC011.003: Cell in Row 260, Column 28 already contains 'SKIP'. Skipping update.
UTC008.002: Cell in Row 253, Column 28 already contains 'SKIP'. Skipping update.
UTC009.002: Cell in Row 255, Column 28 already contains 'SKIP'. Skipping update.
UTC010.002: Cell in Row 257, Column 28 already contains 'SKIP'. Skipping update.
UTC011.004: Cell in Row 261, Column 28 already contains 'SKIP'. Skipping update.
Test ID 'UTC011.005' not found in the spreadsheet. Skipping update.
Test ID 'UTC011.006' not found in the spreadsheet. Skipping update.
Test ID 'UTC008.003' not found in the spreadsheet. Skipping update.
Test ID 'UTC009.003' not found in the spreadsheet. Skipping update.
Test ID 'UTC010.003' not found in the spreadsheet. Skipping update.
Test ID 'UTC011.007' not found in the spreadsheet. Skipping update.
Test ID 'UTC011.008' not found in the spreadsheet. Skipping update.
Test ID 'UTC011.009' not found in the spreadsheet. Skipping update.
Test ID 'UTC022.001' not found in the spreadsheet. Skipping update.
Test ID 'UTC023.001' not found in the spreadsheet. Skipping update.
Test ID 'UTC024.001' not found in the spreadsheet. Skipping update.
Test ID 'UTC025.001' not found in the spreadsheet. Skipping update.
Test ID 'UTC025.002' not found in the spreadsheet. Skipping update.
Test ID 'UTC025.003' not found in the spreadsheet. Skipping update.
Test ID 'UTC022.002' not found in the spreadsheet. Skipping update.
Test ID 'UTC023.002' not found in the spreadsheet. Skipping update.
Test ID 'UTC024.002' not found in the spreadsheet. Skipping update.
Test ID 'UTC025.004' not found in the spreadsheet. Skipping update.
Test ID 'UTC025.005' not found in the spreadsheet. Skipping update.
Test ID 'UTC025.006' not found in the spreadsheet. Skipping update.
Test ID 'UTC022.003' not found in the spreadsheet. Skipping update.
Test ID 'UTC023.003' not found in the spreadsheet. Skipping update.
Test ID 'UTC024.003' not found in the spreadsheet. Skipping update.
Test ID 'UTC025.007' not found in the spreadsheet. Skipping update.
Test ID 'UTC025.008' not found in the spreadsheet. Skipping update.
Test ID 'UTC025.009' not found in the spreadsheet. Skipping update.
UTC004.001: Cell in Row 244, Column 28 already contains 'SKIP'. Skipping update.
UTC005.001: Cell in Row 246, Column 28 already contains 'SKIP'. Skipping update.
UTC005.002: Cell in Row 247, Column 28 already contains 'SKIP'. Skipping update.
UTC006.001: Cell in Row 248, Column 28 already contains 'SKIP'. Skipping update.
UTC006.002: Cell in Row 249, Column 28 already contains 'SKIP'. Skipping update.
UTC012.002: Cell in Row 263, Column 28 already contains 'SKIP'. Skipping update.
UTC012.003: Cell in Row 264, Column 28 already contains 'SKIP'. Skipping update.
UTC013.002: Cell in Row 266, Column 28 already contains 'SKIP'. Skipping update.
UTC013.003: Cell in Row 267, Column 28 already contains 'SKIP'. Skipping update.
UTC014.001: Cell in Row 268, Column 28 already contains 'SKIP'. Skipping update.
UTC015.001: Cell in Row 270, Column 28 already contains 'SKIP'. Skipping update.
Test ID 'UTC18.001' not found in the spreadsheet. Skipping update.
UTC018.002: Cell in Row 277, Column 28 already contains 'SKIP'. Skipping update.
UTC019.001: Cell in Row 278, Column 28 already contains 'SKIP'. Skipping update.
UTC019.002: Cell in Row 279, Column 28 already contains 'SKIP'. Skipping update.
UTC021.001: Cell in Row 282, Column 28 already contains 'SKIP'. Skipping update.
UTC021.002: Cell in Row 283, Column 28 already contains 'SKIP'. Skipping update.
WDT001.001: Cell in Row 526, Column 28 already contains 'SKIP'. Skipping update.
WDT002.001: Cell in Row 527, Column 28 already contains 'SKIP'. Skipping update.
WDT003.001: Cell in Row 528, Column 28 already contains 'SKIP'. Skipping update.
WDT004.001: Cell in Row 529, Column 28 already contains 'SKIP'. Skipping update.
WDT005.001: Cell in Row 530, Column 28 already contains 'SKIP'. Skipping update.
WLE001.001: Cell in Row 127, Column 28 already contains 'PASS'. Skipping update.
WLE001.002: Cell in Row 128, Column 28 already contains 'PASS'. Skipping update.
WLE002.001: Cell in Row 129, Column 28 already contains 'FAIL'. Skipping update.
WLE002.002: Cell in Row 130, Column 28 already contains 'FAIL'. Skipping update.
WLE003.001: Cell in Row 131, Column 28 already contains 'FAIL'. Skipping update.
```

## Downloading from spreadsheet as CSV

TODO, integrate <https://github.com/Dasharo/osfv-results/pull/2/files> into
osfv_results.py script.

## Publishing CSV into archive repository

TODO, repo: <https://github.com/dasharo/osfv-results>
