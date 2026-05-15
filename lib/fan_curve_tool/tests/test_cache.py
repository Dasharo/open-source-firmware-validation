# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import os

from lib.fan_curve_tool.cache import Cache, ProfileBlock, Sample


def _sample(temp=50.0, fan=1000.0):
    return Sample(
        ts="2026-05-15T12:00:00+00:00",
        temp=temp,
        fan=fan,
        mode="rpm",
        workers=4,
        load=50,
        direction="rising",
        settle_dt=20.0,
        stable=True,
    )


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
