# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import os

from lib.fan_curve_tool import (
    Cache,
    ProfileBlock,
    Sample,
    _bin_counts,
    _bin_of,
    _default_workers_grid,
    _direction_counts,
    _get_most_underfilled_bin,
    _LoadPoint,
    _pick_direction,
    _suggest_load_params,
    plot,
)


def _sample(temp=50.0, fan=1000.0, direction="rising", stable=True):
    return Sample(
        timestamp="2026-05-15T12:00:00+00:00",
        temp=temp,
        fan=fan,
        fan_mode="rpm",
        workers=4,
        cpu_load=50,
        direction=direction,
        settle_seconds=20.0,
        stable=stable,
    )


# ---------------------------------------------------------------------------
# Cache
# ---------------------------------------------------------------------------


def test_save_writes_json(tmp_path):
    cache = Cache.open(str(tmp_path), "run-x", "vp66xx", "rpm")
    cache.profiles["silent"] = ProfileBlock(target_per_bin=5, samples=[_sample()])
    cache.save()
    with open(cache.path) as f:
        body = json.load(f)
    assert body["run_id"] == "run-x"
    assert body["profiles"]["silent"]["samples"][0]["temp"] == 50.0


def test_resume_round_trip(tmp_path):
    cache = Cache.open(str(tmp_path), "run-y", "p", "rpm")
    cache.profiles["silent"] = ProfileBlock(samples=[_sample(temp=42.0)])
    cache.save()
    again = Cache.open(str(tmp_path), "run-y", "p", "rpm", resume=True)
    assert again.profiles["silent"].samples[0].temp == 42.0


def test_non_resume_starts_empty(tmp_path):
    cache = Cache.open(str(tmp_path), "run-z", "p", "rpm")
    cache.profiles["off"] = ProfileBlock(samples=[_sample()])
    cache.save()
    fresh = Cache.open(str(tmp_path), "run-z", "p", "rpm")
    assert fresh.profiles == {}
    assert os.path.exists(cache.path)  # still on disk, just not loaded


# ---------------------------------------------------------------------------
# Measurement helpers
# ---------------------------------------------------------------------------


def test_bin_of_floors_to_bin_width():
    assert _bin_of(42.7, 1.0) == 42.0
    assert _bin_of(42.7, 2.0) == 42.0
    assert _bin_of(43.0, 2.0) == 42.0


def test_bin_counts_groups_samples():
    samples = [_sample(40.2), _sample(40.9), _sample(41.0), _sample(60.5)]
    counts = _bin_counts(samples, 1.0)
    assert counts[40.0] == 2
    assert counts[41.0] == 1
    assert counts[60.0] == 1


def test_direction_counts_per_bin():
    samples = [
        _sample(50.0, direction="rising"),
        _sample(50.5, direction="falling"),
        _sample(50.1, direction="rising"),
    ]
    rising, falling = _direction_counts(samples, 50.0, 1.0)
    assert rising == 2
    assert falling == 1


def test_least_filled_bin_returns_under_filled_when_present():
    samples = [_sample(40.0), _sample(40.0), _sample(40.0)]
    # range 40..42, target 3; 40 is full, 41 and 42 are empty
    bin_ = _get_most_underfilled_bin(samples, 1.0, 3, 40.0, 42.0)
    assert bin_ in (41.0, 42.0)


def test_least_filled_bin_returns_direction_imbalance_when_counts_met():
    # Two bins each with 2 samples - all rising - interior bin 41 should be
    # picked because it lacks a falling sample.
    samples = [
        _sample(40.0, direction="rising"),
        _sample(40.0, direction="rising"),
        _sample(41.0, direction="rising"),
        _sample(41.0, direction="rising"),
        _sample(42.0, direction="rising"),
        _sample(42.0, direction="rising"),
    ]
    bin_ = _get_most_underfilled_bin(samples, 1.0, 2, 40.0, 42.0)
    assert bin_ == 41.0


def test_least_filled_bin_none_when_fully_covered():
    samples = []
    for temp in (40.0, 41.0, 42.0):
        samples += [
            _sample(temp, direction="rising"),
            _sample(temp, direction="falling"),
        ]
    assert _get_most_underfilled_bin(samples, 1.0, 2, 40.0, 42.0) is None


def test_pick_direction_alternates():
    samples = [_sample(50.0, direction="rising")]
    assert _pick_direction(samples, 50.0, 1.0) == "falling"
    samples.append(_sample(50.0, direction="falling"))
    assert _pick_direction(samples, 50.0, 1.0) == "rising"


def test_invert_map_2d_picks_in_bin_match():
    points = [
        _LoadPoint(workers=1, cpu_load=0, temp=35.0),
        _LoadPoint(workers=2, cpu_load=50, temp=50.5),
        _LoadPoint(workers=4, cpu_load=100, temp=75.0),
    ]
    workers, load = _suggest_load_params(
        points, target_temp_bin=50.0, bin_width=1.0, nproc=4
    )
    assert (workers, load) == (2, 50)


def test_invert_map_2d_interpolates_when_no_in_bin_point():
    points = [
        _LoadPoint(workers=2, cpu_load=20, temp=40.0),
        _LoadPoint(workers=2, cpu_load=80, temp=70.0),
    ]
    workers, load = _suggest_load_params(
        points, target_temp_bin=55.0, bin_width=1.0, nproc=4
    )
    assert workers == 2
    assert 40 <= load <= 60


def test_invert_map_2d_falls_back_to_extremes():
    points = [_LoadPoint(workers=1, cpu_load=0, temp=35.0)]
    # No point at or above target - should aim for the upper extreme.
    workers, load = _suggest_load_params(
        points, target_temp_bin=60.0, bin_width=1.0, nproc=4
    )
    assert (workers, load) == (4, 100)


def test_invert_map_2d_picks_workers_when_loads_match():
    points = [
        _LoadPoint(workers=1, cpu_load=100, temp=45.0),
        _LoadPoint(workers=4, cpu_load=100, temp=80.0),
    ]
    # No in-bin point and no shared-workers below/above pair to bisect cpu_load.
    # cpu_load is already saturated on the "above" point, so step workers down
    # toward the cooler anchor rather than overshooting at (4, 100).
    workers, load = _suggest_load_params(
        points, target_temp_bin=70.0, bin_width=1.0, nproc=4
    )
    assert (workers, load) == (3, 100)


def test_default_workers_grid():
    assert _default_workers_grid(4, 3) == [1, 2, 4]
    assert _default_workers_grid(4, 2) == [1, 4]
    assert _default_workers_grid(4, 1) == [4]
    assert _default_workers_grid(8, 4) == [1, 2, 4, 8]
    assert _default_workers_grid(24, 4) == [1, 3, 8, 24]
    assert _default_workers_grid(1, 4) == [1]


# ---------------------------------------------------------------------------
# Plot
# ---------------------------------------------------------------------------


def test_plot_writes_png_for_combined_overlay(tmp_path):
    cache = Cache(path="", run_id="r", platform="p", fan_mode="rpm")
    silent = ProfileBlock(reachable_temp_range=[35.0, 70.0])
    perf = ProfileBlock(reachable_temp_range=[35.0, 75.0])
    for temp in range(35, 71, 2):
        silent.samples.append(_sample(temp, 500 + 30 * (temp - 35)))
        silent.samples.append(
            _sample(temp, 540 + 30 * (temp - 35), direction="falling")
        )
        perf.samples.append(_sample(temp, 800 + 40 * (temp - 35)))
    perf.samples.append(_sample(80, 3200, stable=False))
    cache.profiles = {"silent": silent, "performance": perf}
    out = plot(cache, None, str(tmp_path))
    assert os.path.exists(out)
    assert os.path.getsize(out) > 0


def test_plot_with_specific_profile(tmp_path):
    cache = Cache(path="", run_id="r", platform="p", fan_mode="rpm")
    block = ProfileBlock(reachable_temp_range=[40.0, 60.0])
    for temp in range(40, 61):
        block.samples.append(_sample(temp, 1000 + 20 * temp))
    cache.profiles["silent"] = block
    out = plot(cache, None, str(tmp_path), profile="silent")
    assert os.path.exists(out)
    assert out.endswith("_silent.png")
