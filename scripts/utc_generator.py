# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import pandas as pd

# Tested OS ids
oses = {"001": "Firmware", "201": "Ubuntu", "202": "Fedora", "301": "Windows"}
os_id_variable_names = {
    "001": "001",
    "201": "${ENV_ID_UBUNTU}",
    "202": "${ENV_ID_FEDORA}",
    "301": "${ENV_ID_WINDOWS}",
}

# Every test performed on two states of ME
me_states = [True, False]

# Every test on every docking station
docking_stations = {
    "1": "WL-UMD05 Pro Rev.E",
    "2": "WL-UMD05 Pro Rev.C1",
    "3": "WL-UG69PD2 Rev.A1",
}
# Every unique test case, its docs and the OS ids on which it is performed
test_names = {
    "USB Type-A charging capability": {
        "env_ids": ["001"],
        "doc": """This test verifies that the USB-A ports are able to provide
    ...    charging to a connected smartphone.""",
        "skips": "",
        "automation": "manual",
    },
    "Thunderbolt 4 USB Type-C power output": {
        "env_ids": ["001"],
        "doc": """This test verifies that the Thunderbolt 4 port is able
    ...    to provide charging to a USB Type-C accessory.""",
        "skips": "",
        "automation": "manual",
    },
    "USB Type-C PD power input": {
        "env_ids": ["201", "202", "301"],
        "doc": """Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)""",
        "skips": ["not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}"],
        "automation": "manual",
    },
    "USB Type-C Display output": {
        "env_ids": ["201", "202"],
        "doc": "Check whether the DUT can detect the USB Type-C hub.",
        "skips": ["not ${USB_TYPE_C_DISPLAY_SUPPORT}"],
        "automation": "auto",
    },
    "USB Type-C docking station HDMI display": {
        "env_ids": ["201", "202", "301"],
        "doc": """This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.""",
        "skips": ["not ${DOCKING_STATION_HDMI}"],
        "automation": "auto",
    },
    "USB Type-C docking station DP display": {
        "env_ids": ["201", "202", "301"],
        "doc": """This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.""",
        "skips": ["not ${DOCKING_STATION_DISPLAY_PORT}"],
        "automation": "auto",
    },
    "USB Type-C docking station Triple display": {
        "env_ids": ["201", "202", "301"],
        "doc": """This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.""",
        "skips": "",
        "automation": "manual",
    },
    "USB Type-C docking station USB devices recognition": {
        "env_ids": ["001", "201", "202", "301"],
        "doc": """Check whether the external USB devices connected to the
    ...    docking station are detected correctly""",
        "skips": ["not ${DOCKING_STATION_USB_SUPPORT}"],
        "automation": "auto",
    },
    "USB Type-C docking station USB keyboard": {
        "env_ids": ["001", "201", "202", "301"],
        "doc": """Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.""",
        "skips": ["not ${DOCKING_STATION_KEYBOARD_SUPPORT}"],
        "automation": "auto",
    },
    "USB Type-C docking station upload 1GB file on USB storage": {
        "env_ids": ["201", "202", "301"],
        "doc": """This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.""",
        "skips": "",
        "automation": "manual",
    },
    "USB Type-C docking station Ethernet connection": {
        "env_ids": ["201", "202", "301"],
        "doc": """This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.""",
        "skips": ["not ${DOCKING_STATION_NET_INTERFACE}"],
        "automation": "auto",
    },
    "USB Type-C docking station audio recognition": {
        "env_ids": ["201", "202"],
        "doc": """This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.""",
        "skips": ["not ${DOCKING_STATION_AUDIO_SUPPORT}"],
        "automation": "auto",
    },
    "USB Type-C docking station audio playback": {
        "env_ids": ["201", "202", "301"],
        "doc": """This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.""",
        "skips": ["not ${DOCKING_STATION_AUDIO_SUPPORT}"],
        "automation": "manual",
    },
    "USB Type-C docking station audio capture": {
        "env_ids": ["201", "202", "301"],
        "doc": """This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.""",
        "skips": ["not ${DOCKING_STATION_AUDIO_SUPPORT}"],
        "automation": "manual",
    },
    "USB Type-C docking station SD Card reader detection": {
        "env_ids": ["201", "202", "301"],
        "doc": """Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.""",
        "skips": ["not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}"],
        "automation": "auto",
    },
    "USB Type-C docking station SD Card read/write": {
        "env_ids": ["201", "202", "301"],
        "doc": """Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.""",
        "skips": ["not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}"],
        "automation": "auto",
    },
    "USB Type-C PD current limiting": {
        "env_ids": ["201", "202", "301"],
        "doc": """This test aims to verify that the power draw from a USB-C PD
    ...    power supply does not exceed the limits of the power supply's
    ...    specifications.""",
        "skips": "",
        "automation": "manual",
    },
    "Docking station detection after coldboot": {
        "env_ids": ["201", "202"],
        "doc": """Check whether he DUT properly detects the docking station
    ...    after coldboot.""",
        "skips": ["'${POWER_CTRL}' == 'none'", "not ${DOCKING_STATION_DETECT_SUPPORT}"],
        "automation": "auto",
    },
    "Docking station detection after warmboot": {
        "env_ids": ["201", "202"],
        "doc": """Check whether he DUT properly detects the docking station
    ...    after warmboot.""",
        "skips": ["not ${DOCKING_STATION_DETECT_SUPPORT}"],
        "automation": "auto",
    },
    "Docking station detection after reboot": {
        "env_ids": ["201", "202"],
        "doc": """Check whether the DUT properly detects the docking station
    ...    after reboot.""",
        "skips": ["not ${DOCKING_STATION_DETECT_SUPPORT}"],
        "automation": "auto",
    },
    "Docking station detection after suspend": {
        "env_ids": ["201", "202"],
        "doc": """Check whether the DUT properly detects the docking station
    ...    after suspend.""",
        "skips": [
            "${PLATFORM_SLEEP_TYPE_SELECTABLE}",
            "not ${DOCKING_STATION_DETECT_SUPPORT}",
        ],
        "automation": "auto",
    },
    "Docking station detection after suspend (S0ix)": {
        "env_ids": ["201", "202"],
        "doc": """Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).""",
        "skips": [
            "not ${PLATFORM_SLEEP_TYPE_SELECTABLE}",
            "not ${DOCKING_STATION_DETECT_SUPPORT}",
        ],
        "automation": "auto",
    },
    "Docking station detection after suspend (S3)": {
        "env_ids": ["201", "202"],
        "doc": """Check whether the DUT properly detects the docking station
    ...    after suspend (S3).""",
        "skips": [
            "not ${PLATFORM_SLEEP_TYPE_SELECTABLE}",
            "not ${DOCKING_STATION_DETECT_SUPPORT}",
        ],
        "automation": "auto",
    },
    "Docking station detection after coldboot then hotplug": {
        "env_ids": ["201", "202"],
        "doc": """Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.""",
        "skips": ["'${POWER_CTRL}' == 'none'", "not ${DOCKING_STATION_DETECT_SUPPORT}"],
        "automation": "semi",
    },
    "Docking station detection after warmboot then hotplug": {
        "env_ids": ["201", "202"],
        "doc": """Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.""",
        "skips": ["not ${DOCKING_STATION_DETECT_SUPPORT}"],
        "automation": "semi",
    },
    "Docking station detection after reboot then hotplug": {
        "env_ids": ["201", "202"],
        "doc": """Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.""",
        "skips": ["not ${DOCKING_STATION_DETECT_SUPPORT}"],
        "automation": "semi",
    },
    "Docking station detection after suspend then hotplug": {
        "env_ids": ["201", "202"],
        "doc": """Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.""",
        "skips": [
            "${PLATFORM_SLEEP_TYPE_SELECTABLE}",
            "not ${DOCKING_STATION_DETECT_SUPPORT}",
        ],
        "automation": "semi",
    },
    "Docking station detection after suspend then hotplug (S0ix)": {
        "env_ids": ["201", "202"],
        "doc": """Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.""",
        "skips": [
            "not ${PLATFORM_SLEEP_TYPE_SELECTABLE}",
            "not ${DOCKING_STATION_DETECT_SUPPORT}",
        ],
        "automation": "semi",
    },
    "Docking station detection after suspend then hotplug (S3)": {
        "env_ids": ["201", "202"],
        "doc": """Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.""",
        "skips": [
            "not ${PLATFORM_SLEEP_TYPE_SELECTABLE}",
            "not ${DOCKING_STATION_DETECT_SUPPORT}",
        ],
        "automation": "semi",
    },
}

# Generate full test list
test_rows = []
for dock_idx in docking_stations.keys():
    for me_enabled in me_states:
        for os in oses:
            # find out test cases on given os
            # to order them by OS and possibly speeding up execution
            tests_for_os = [
                name for name in test_names.keys() if os in test_names[name]["env_ids"]
            ]

            for test_name in tests_for_os:
                test_idx = list(test_names.keys()).index(test_name) * 2 + 1
                if not me_enabled:
                    test_idx += 1
                test_id = f"UTC{dock_idx}{test_idx:02d}.{os}"
                test_rows.append(
                    {
                        "Test ID": test_id,
                        "Test Name": test_name,
                        "doc": test_names[test_name]["doc"],
                        "skips": test_names[test_name]["skips"],
                        "OS ID": os,
                        "ME State": "Enabled" if me_enabled else "Disabled",
                        "Dock": docking_stations[dock_idx],
                        "automation": test_names[test_name]["automation"],
                    }
                )


def full_test_name(test_row):
    line = ""
    line += f"{test_row['Test ID']}"
    line += f" {test_row['Test Name']}"
    line += f" ({oses[test_row['OS ID']]})"
    line += f" (ME: {test_row['ME State']})"
    line += f" ({test_row['Dock']})"
    return line


robot_tests_lines = []
for idx, row in enumerate(test_rows):
    robot_tests_lines.append([])
    robot_tests_lines[idx].append(f"{full_test_name(row)}\n")
    documentation = row["doc"].splitlines()
    robot_tests_lines[idx].append(f"    [Documentation]    {documentation[0]}\n")
    if len(documentation) > 1:
        for line in documentation[1:]:
            robot_tests_lines[idx].append(f"{line}\n")

    # Semiauto tag
    if row["automation"] == "semi":
        robot_tests_lines[idx].append(f"    [Tags]    semiauto\n")

    for skip in row["skips"]:
        robot_tests_lines[idx].append(
            f"    Skip If    {skip}    {row['Test ID']} not supported\n"
        )

    # Skips dependent on env/os ID
    if row["OS ID"] == "301":
        robot_tests_lines[idx].append(
            f"    Skip If    not ${{TESTS_IN_WINDOWS_SUPPORT}}    {row['Test ID']} not supported\n"
        )
    if row["OS ID"] == "201":
        robot_tests_lines[idx].append(
            f"    Skip If    not ${{TESTS_IN_UBUNTU_SUPPORT}}    {row['Test ID']} not supported\n"
        )
    if row["OS ID"][0] == "2":
        robot_tests_lines[idx].append(
            f"    Skip If    '{os_id_variable_names[row['OS ID']]}' not in ${{TESTED_LINUX_DISTROS}}    {row['Test ID']} not supported\n"
        )

    # call the generic keyword for that test case type
    keyword_call = f"{row['Test Name'].title()}    {os_id_variable_names[row['OS ID']]}    {row['ME State']}    {row['Dock']}\n"
    robot_tests_lines[idx].append(f"    {keyword_call}\n")

    if row["automation"] == "manual" or row["OS ID"] == "001":
        robot_tests_lines[idx] = ["# " + line for line in robot_tests_lines[idx]]
        robot_tests_lines[idx].insert(0, "# Not automated\n")

# Generate keywords
keywords = []
for idx, test_name in enumerate(test_names.keys()):
    keywords.append([])
    keywords[idx].append(f"{test_name.title()}\n")
    keywords[idx].append(
        "    [Arguments]    ${env_id}    ${me_state}    ${dock_name}\n"
    )
    keywords[idx].append("    [Tags]    robot:private\n")

    if test_names[test_name]["automation"] == "manual":
        keywords[idx] = ["# " + line for line in keywords[idx]]
        keywords[idx].insert(0, "# Not automated\n")
    keywords[idx].append("\n")

# save to files
with open("utc_test_file.robot", "w") as file:
    for test in robot_tests_lines:
        file.writelines(test)

with open("utc_test_keywords.robot", "w") as file:
    file.write("*** Keywords ***\n")
    for kw in keywords:
        file.writelines(kw)
