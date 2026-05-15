# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

from lib.fan_curve_tool.cache import Sample
from lib.fan_curve_tool.measure import (
    _bin_counts,
    _bin_of,
    _default_workers_grid,
    _direction_counts,
    _invert_map_2d,
    _least_filled_bin,
    _LoadPoint,
    _pick_direction,
)


def _s(temp, direction="rising"):
    return Sample(
        ts="t",
        temp=temp,
        fan=1000.0,
        mode="rpm",
        workers=4,
        load=50,
        direction=direction,
        settle_dt=10.0,
        stable=True,
    )


def test_bin_of_floors_to_bin_width():
    assert _bin_of(42.7, 1.0) == 42.0
    assert _bin_of(42.7, 2.0) == 42.0
    assert _bin_of(43.0, 2.0) == 42.0


def test_bin_counts_groups_samples():
    samples = [_s(40.2), _s(40.9), _s(41.0), _s(60.5)]
    c = _bin_counts(samples, 1.0)
    assert c[40.0] == 2
    assert c[41.0] == 1
    assert c[60.0] == 1


def test_direction_counts_per_bin():
    samples = [_s(50.0, "rising"), _s(50.5, "falling"), _s(50.1, "rising")]
    r, f = _direction_counts(samples, 50.0, 1.0)
    assert r == 2
    assert f == 1


def test_least_filled_bin_returns_under_filled_when_present():
    samples = [_s(40.0), _s(40.0), _s(40.0)]
    # range 40..42, target 3; 40 is full, 41 and 42 are empty
    bin_ = _least_filled_bin(samples, 1.0, 3, 40.0, 42.0)
    assert bin_ in (41.0, 42.0)


def test_least_filled_bin_returns_direction_imbalance_when_counts_met():
    # Two bins each with 2 samples — all rising — interior bin 41 should be
    # picked because it lacks a falling sample.
    samples = [
        _s(40.0, "rising"),
        _s(40.0, "rising"),
        _s(41.0, "rising"),
        _s(41.0, "rising"),
        _s(42.0, "rising"),
        _s(42.0, "rising"),
    ]
    bin_ = _least_filled_bin(samples, 1.0, 2, 40.0, 42.0)
    assert bin_ == 41.0


def test_least_filled_bin_none_when_fully_covered():
    samples = []
    for t in (40.0, 41.0, 42.0):
        samples += [_s(t, "rising"), _s(t, "falling")]
    assert _least_filled_bin(samples, 1.0, 2, 40.0, 42.0) is None


def test_pick_direction_alternates():
    samples = [_s(50.0, "rising")]
    assert _pick_direction(samples, 50.0, 1.0) == "falling"
    samples.append(_s(50.0, "falling"))
    assert _pick_direction(samples, 50.0, 1.0) == "rising"


def test_invert_map_2d_picks_in_bin_match():
    points = [
        _LoadPoint(workers=1, cpu_load=0, temp=35.0),
        _LoadPoint(workers=2, cpu_load=50, temp=50.5),
        _LoadPoint(workers=4, cpu_load=100, temp=75.0),
    ]
    w, l = _invert_map_2d(points, target_bin=50.0, bin_width=1.0, nproc=4)
    assert (w, l) == (2, 50)


def test_invert_map_2d_interpolates_when_no_in_bin_point():
    points = [
        _LoadPoint(workers=2, cpu_load=20, temp=40.0),
        _LoadPoint(workers=2, cpu_load=80, temp=70.0),
    ]
    w, l = _invert_map_2d(points, target_bin=55.0, bin_width=1.0, nproc=4)
    assert w == 2
    assert 40 <= l <= 60


def test_invert_map_2d_falls_back_to_extremes():
    points = [_LoadPoint(workers=1, cpu_load=0, temp=35.0)]
    # No point at or above target — should aim for the upper extreme.
    w, l = _invert_map_2d(points, target_bin=60.0, bin_width=1.0, nproc=4)
    assert (w, l) == (4, 100)


def test_invert_map_2d_picks_workers_when_loads_match():
    points = [
        _LoadPoint(workers=1, cpu_load=100, temp=45.0),
        _LoadPoint(workers=4, cpu_load=100, temp=80.0),
    ]
    # No in-bin point and no shared-workers below/above pair to bisect cpu_load.
    # cpu_load is already saturated on the "above" point, so step workers down
    # toward the cooler anchor rather than overshooting at (4, 100).
    w, l = _invert_map_2d(points, target_bin=70.0, bin_width=1.0, nproc=4)
    assert (w, l) == (3, 100)


def test_default_workers_grid():
    assert _default_workers_grid(4, 3) == [1, 2, 4]
    assert _default_workers_grid(4, 2) == [1, 4]
    assert _default_workers_grid(4, 1) == [4]
    assert _default_workers_grid(8, 4) == [1, 2, 4, 8]
    assert _default_workers_grid(24, 4) == [1, 3, 8, 24]
    assert _default_workers_grid(1, 4) == [1]
