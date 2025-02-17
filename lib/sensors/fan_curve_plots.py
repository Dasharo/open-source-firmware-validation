# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os

import matplotlib.pyplot as plt
import pandas
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn


# @keyword("Plot Fan Curve")
def plot_fan_curve(filename):
    in_file = filename + ".csv"
    out_file = filename + ".png"
    logs_dir = BuiltIn().get_variable_value("${logs_dir}")
    if logs_dir is None:
        logs_dir = "."
    out_path = os.path.join(logs_dir, out_file)

    data = pandas.read_csv(in_file)
    temp = data["temp"]
    speed = data["speed"]
    tolerance = data["tolerance"]
    expected = data["expected"]

    plt.title(filename)
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
    plt.savefig(out_path)
    plt.clf()
    return out_file
