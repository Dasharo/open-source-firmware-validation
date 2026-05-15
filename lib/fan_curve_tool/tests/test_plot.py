# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os

from lib.fan_curve_tool.cache import Cache, ProfileBlock, Sample
from lib.fan_curve_tool.plot import plot


def _sample(temp, fan, direction="rising", stable=True):
    return Sample(
        ts="2026-05-15T12:00:00+00:00",
        temp=temp,
        fan=fan,
        mode="rpm",
        workers=4,
        load=50,
        direction=direction,
        settle_dt=20.0,
        stable=stable,
    )


def test_plot_writes_png_for_combined_overlay(tmp_path):
    cache = Cache(path="", run_id="r", platform="p", fan_mode="rpm")
    silent = ProfileBlock(reachable_temp_range=(35.0, 70.0))
    perf = ProfileBlock(reachable_temp_range=(35.0, 75.0))
    for t in range(35, 71, 2):
        silent.samples.append(_sample(t, 500 + 30 * (t - 35)))
        silent.samples.append(_sample(t, 540 + 30 * (t - 35), direction="falling"))
        perf.samples.append(_sample(t, 800 + 40 * (t - 35)))
    perf.samples.append(_sample(80, 3200, stable=False))
    cache.profiles = {"silent": silent, "performance": perf}
    out = plot(cache, None, str(tmp_path))
    assert os.path.exists(out)
    assert os.path.getsize(out) > 0


def test_plot_with_specific_profile(tmp_path):
    cache = Cache(path="", run_id="r", platform="p", fan_mode="rpm")
    block = ProfileBlock(reachable_temp_range=(40.0, 60.0))
    for t in range(40, 61):
        block.samples.append(_sample(t, 1000 + 20 * t))
    cache.profiles["silent"] = block
    out = plot(cache, None, str(tmp_path), profile="silent")
    assert os.path.exists(out)
    assert out.endswith("_silent.png")
