# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os

import matplotlib.pyplot as plt
import pandas
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn


@keyword("Plot Fan Curve")
def plot_fan_curve(file_path, title):
    in_file = file_path + ".csv"
    out_file = file_path + ".png"

    data = pandas.read_csv(in_file)
    temp = data["temp"]
    speed = data["speed"]
    tolerance = data["tolerance"]
    expected = data["expected"]

    plt.title(title)
    plt.xlabel("CPU temperature [°C]")
    plt.ylabel("Fan speed")
    plt.errorbar(temp, speed, label="speed", fmt=".")
    # plt.plot(temp, speed-tolerance, label="min", marker=".")
    # plt.plot(temp, speed+tolerance, label="max", marker=".")
    plt.errorbar(
        temp,
        expected,
        yerr=tolerance,
        label="expected",
        fmt=".",
        capsize=3,
        capthick=0.5,
        linewidth=0.5,
    )
    plt.legend()
    plt.savefig(out_file)
    plt.clf()

    out_filename = os.path.basename(out_file)
    return out_filename


def _get_over_tolerance(measurement):
    diff = abs(measurement["speed"] - measurement["expected"])
    over_tolerance = max(diff - measurement["tolerance"], 0)
    return over_tolerance


def _get_diff_from_tolerance(measurement):
    diff = abs(measurement["speed"] - measurement["expected"])
    # Measurements that are in the tolerance are always better
    # those outside tolerance. To order them according to that, the
    # weight of anything over tolerance is increased
    over_tolerance = _get_over_tolerance(measurement) * 1000
    # To also sort the measurements which fall into tolerance
    return over_tolerance * 1000 + diff


@keyword("Count Failed Fan Measurements")
def count_failed_fan_measurements(measurements):
    # RF passes a measurements as [measurements]
    if type(measurements[0]) is list:
        measurements = measurements[0]

    count = 0
    for m in measurements:
        if _get_over_tolerance(m) > 0:
            count += 1
    return count


@keyword("Filter Fan Measurements")
def filter_fan_measurements(measurements, percentile_drop):
    # RF passes a measurements as [measurements]
    if type(measurements[0]) is list:
        measurements = measurements[0]
    # sort by the amount of deviation from expected values
    m_sorted = sorted(measurements, key=_get_diff_from_tolerance)
    save_amount = int(len(m_sorted) - len(m_sorted) * percentile_drop / 100)
    m_saved = m_sorted[:save_amount]
    return m_saved
