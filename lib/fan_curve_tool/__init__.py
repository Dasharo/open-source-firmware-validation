# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import argparse
import json
import math
import os
import shlex
import statistics
import sys
import time
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from typing import Any

import matplotlib.pyplot as plt
import numpy as np
import paramiko
import yaml

# ----------------------------------------------------------------------------
# SSH terminal
# ----------------------------------------------------------------------------


class Terminal:
    """SSH terminal used by both the Robot keyword library and the offline
    CLI. When sudo_password is set and the login user is not root, commands
    are wrapped in `sudo -S` with the password fed via stdin."""

    def __init__(
        self,
        host: str,
        user: str = "root",
        password: str | None = None,
        port: int = 22,
        sudo_password: str | None = None,
    ):
        self._user = user
        self._sudo_password = sudo_password
        self._client = paramiko.SSHClient()
        self._client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self._client.connect(
            hostname=host,
            username=user,
            port=port,
            password=password,
            allow_agent=False,
            look_for_keys=False,
        )

    def run(self, command: str, timeout: float = 300.0) -> str:
        print(command)
        if self._sudo_password is not None and self._user != "root":
            wrapped = f"sudo -S -p '' sh -c {shlex.quote(command)}"
            stdin, stdout, _ = self._client.exec_command(wrapped, timeout=timeout)
            stdin.write(f"{self._sudo_password}\n")
            stdin.flush()
        else:
            _, stdout, _ = self._client.exec_command(command, timeout=timeout)
        return stdout.read().decode("utf-8", errors="replace")

    def run_detached(self, command: str) -> None:
        detached = f"nohup sh -c {shlex.quote(command)} </dev/null >/dev/null 2>&1 &"
        if self._sudo_password is not None and self._user != "root":
            wrapped = f"sudo -S -p '' sh -c {shlex.quote(detached)}"
            stdin, stdout, _ = self._client.exec_command(wrapped, timeout=10)
            stdin.write(f"{self._sudo_password}\n")
            stdin.flush()
        else:
            _, stdout, _ = self._client.exec_command(detached, timeout=10)
        stdout.channel.recv_exit_status()

    def close(self) -> None:
        self._client.close()

    def __enter__(self) -> "Terminal":
        return self

    def __exit__(self, exc_type, exc, tb) -> None:
        self.close()


# ----------------------------------------------------------------------------
# Cache / data model
# ----------------------------------------------------------------------------


@dataclass
class Sample:
    timestamp: str
    temp: float
    fan: float
    fan_mode: str
    workers: int
    cpu_load: int
    direction: str
    settle_seconds: float
    stable: bool

    @classmethod
    def create(
        cls,
        temp: float,
        fan: float,
        fan_mode: str,
        workers: int,
        cpu_load: int,
        direction: str,
        settle_seconds: float,
        stable: bool,
    ) -> "Sample":
        return cls(
            timestamp=datetime.now(timezone.utc).isoformat(timespec="seconds"),
            temp=float(temp),
            fan=float(fan),
            fan_mode=fan_mode,
            workers=int(workers),
            cpu_load=int(cpu_load),
            direction=direction,
            settle_seconds=float(settle_seconds),
            stable=bool(stable),
        )


@dataclass
class ProfileBlock:
    started_at: str = ""
    finished_at: str = ""
    reachable_temp_range: list[float] = field(default_factory=lambda: [0.0, 0.0])
    target_per_bin: int = 0
    stop_reason: str = ""
    samples: list[Sample] = field(default_factory=list)

    @classmethod
    def from_dict(cls, raw: dict[str, Any]) -> "ProfileBlock":
        fields = {k: v for k, v in raw.items() if k in cls.__dataclass_fields__}
        fields["samples"] = [Sample(**sample) for sample in raw.get("samples", [])]
        return cls(**fields)


@dataclass
class Cache:
    path: str
    run_id: str
    platform: str
    fan_mode: str
    profiles: dict[str, ProfileBlock] = field(default_factory=dict)

    @classmethod
    def open(
        cls,
        logs_dir: str,
        run_id: str,
        platform: str,
        fan_mode: str,
        resume: bool = False,
    ) -> "Cache":
        os.makedirs(os.path.join(logs_dir, "fan_measurements"), exist_ok=True)
        path = os.path.join(logs_dir, "fan_measurements", f"{run_id}.json")
        profiles: dict[str, ProfileBlock] = {}
        if resume and os.path.exists(path):
            with open(path, "r") as file:
                raw = json.load(file)
            profiles = {
                name: ProfileBlock.from_dict(block)
                for name, block in raw.get("profiles", {}).items()
            }
        return cls(
            path=path,
            run_id=run_id,
            platform=platform,
            fan_mode=fan_mode,
            profiles=profiles,
        )

    @classmethod
    def load_existing(cls, path: str, run_id_fallback: str = "") -> "Cache":
        with open(path, "r") as file:
            raw = json.load(file)
        return cls(
            path=path,
            run_id=raw.get("run_id", run_id_fallback),
            platform=raw.get("platform", "unknown"),
            fan_mode=raw.get("fan_mode", "rpm"),
            profiles={
                name: ProfileBlock.from_dict(block)
                for name, block in raw.get("profiles", {}).items()
            },
        )

    def save(self) -> None:
        body = {
            "run_id": self.run_id,
            "platform": self.platform,
            "fan_mode": self.fan_mode,
            "profiles": {name: asdict(block) for name, block in self.profiles.items()},
        }
        with open(self.path, "w") as file:
            json.dump(body, file, indent=2)


# ----------------------------------------------------------------------------
# YAML configs (sensors + curve)
# ----------------------------------------------------------------------------


@dataclass
class Measurement:
    gather: str
    filter: str = ""
    process: str = ""

    @classmethod
    def from_dict(cls, raw: dict[str, Any]) -> "Measurement":
        return cls(
            gather=raw["gather"],
            filter=raw.get("filter") or "",
            process=raw.get("process") or "",
        )

    def pipe(self) -> str:
        # empty stage = passthrough; native shell pipe (byte-safe)
        stages = [self.gather, self.filter or "cat", self.process or "cat"]
        return " | ".join(stages)


@dataclass
class SensorsConfig:
    cpu_temp: Measurement | None
    fan_pwm: Measurement | None
    fan_rpm: Measurement | None
    requirements_commands: dict[str, list[str]] = field(default_factory=dict)
    prepare_commands: list[str] = field(default_factory=list)

    @classmethod
    def load(cls, path: str) -> "SensorsConfig":
        with open(path, "r") as file:
            raw = yaml.safe_load(file) or {}

        def measurement(key: str) -> Measurement | None:
            block = raw.get(key)
            return Measurement.from_dict(block) if block else None

        return cls(
            cpu_temp=measurement("cpu_temperature_measurement"),
            fan_pwm=measurement("fan_pwm_measurement"),
            fan_rpm=measurement("fan_rpm_measurement"),
            requirements_commands=raw.get("sensors_requirements_commands", {}) or {},
            prepare_commands=raw.get("sensors_prepare_commands", []) or [],
        )


PROFILE_KEY_PREFIX = "temperature_curve_"
SETTINGS_KEY = "temperature_curve_settings"


@dataclass
class CurveSegment:
    min_temp: float
    max_temp: float
    eval_pwm: tuple[float, float]
    eval_rpm: tuple[float, float]
    tolerance_pwm: float
    tolerance_rpm: float


@dataclass
class CurveConfig:
    settings: dict
    profiles: dict[str, list[CurveSegment]]

    @classmethod
    def load(cls, path: str) -> "CurveConfig":
        with open(path, "r") as file:
            raw = yaml.safe_load(file) or {}
        profiles: dict[str, list[CurveSegment]] = {}
        # Any top-level key matching `temperature_curve_<name>` is a profile,
        # with <name> as the profile id. `temperature_curve_settings` is
        # reserved for global settings.
        for key in raw:
            if not key.startswith(PROFILE_KEY_PREFIX) or key == SETTINGS_KEY:
                continue
            name = key[len(PROFILE_KEY_PREFIX) :]
            segments: list[CurveSegment] = []
            for entry in raw.get(key, []) or []:
                low, high = entry["range"]
                eval_pwm = tuple(entry.get("evaluation_pwm", (0, 0)))
                eval_rpm = tuple(entry.get("evaluation_rpm", (0, 0)))
                segments.append(
                    CurveSegment(
                        min_temp=float(low),
                        max_temp=float(high),
                        eval_pwm=(float(eval_pwm[0]), float(eval_pwm[1])),
                        eval_rpm=(float(eval_rpm[0]), float(eval_rpm[1])),
                        tolerance_pwm=float(entry.get("tolerance_pwm", 0)),
                        tolerance_rpm=float(entry.get("tolerance_rpm", 0)),
                    )
                )
            profiles[name] = segments
        return cls(settings=raw.get(SETTINGS_KEY, {}) or {}, profiles=profiles)

    def reference_points(self, profile: str, mode: str, step: float = 0.5):
        """Return (temps, values) for a smooth reference overlay."""
        segments = self.profiles.get(profile, [])
        temps: list[float] = []
        values: list[float] = []
        for segment in segments:
            point_count = max(2, int((segment.max_temp - segment.min_temp) / step) + 1)
            for i in range(point_count):
                temp = segment.min_temp + (segment.max_temp - segment.min_temp) * i / (
                    point_count - 1
                )
                evaluation = segment.eval_pwm if mode == "pwm" else segment.eval_rpm
                value = evaluation[0] + (evaluation[1] - evaluation[0]) * (
                    temp - segment.min_temp
                ) / (segment.max_temp - segment.min_temp)
                temps.append(temp)
                values.append(value)
        return temps, values


# ----------------------------------------------------------------------------
# DUT sensor readers
# ----------------------------------------------------------------------------


@dataclass
class Reader:
    spec: Measurement

    def read(self, terminal: Terminal) -> float:
        out = terminal.run(self.spec.pipe()).strip()
        return float(out)


def pick_fan_mode(config: SensorsConfig) -> tuple[str, Measurement]:
    if config.fan_pwm is not None:
        return "pwm", config.fan_pwm
    if config.fan_rpm is not None:
        return "rpm", config.fan_rpm
    raise ValueError("no fan measurement configured")


def prepare_sensors(terminal: Terminal, config: SensorsConfig, env_id: str) -> None:
    for cmd in config.requirements_commands.get(env_id, []):
        terminal.run(cmd)
    for cmd in config.prepare_commands:
        terminal.run(cmd)


# ----------------------------------------------------------------------------
# Measurement algorithm
# ----------------------------------------------------------------------------


@dataclass
class MeasureConfig:
    bin_width: float = 5.0
    target_per_bin: int = 15
    workers_grid: list[int] | None = None
    worker_grid_size: int = 4
    cpu_load_grid: list[int] = field(default_factory=lambda: [0, 25, 50, 75, 100])
    poll_interval_s: float = 1.0
    stddev_window: int = 20
    temp_std_thresh: float = 1.0
    fan_std_thresh_rpm: float = 100.0
    fan_std_thresh_pwm: float = 5.0
    stability_wait_s: int = 5
    stable_timeout_s: float = 30.0
    bin_arrival_timeout_s: float = 30.0
    hysteresis_timeout_s: float = 60.0
    no_progress_timeout_s: float = 60.0
    max_runtime_s: float = 60 * 60
    verbose: bool = False
    post_stable_samples: int = 10
    post_stable_interval_s: float = 1
    require_both_directions: bool = True

    def apply_overrides(
        self,
        *,
        verbose: bool = False,
        quick: bool = False,
        max_runtime: float | None = None,
        target_per_bin: int | None = None,
    ) -> None:
        self.verbose = bool(verbose)
        if quick:
            self.stable_timeout_s = 30.0
            self.hysteresis_timeout_s = 60.0
            self.bin_arrival_timeout_s = 60.0
            self.target_per_bin = 1
            self.require_both_directions = False
        if max_runtime is not None:
            self.max_runtime_s = float(max_runtime)
        if target_per_bin is not None:
            self.target_per_bin = int(target_per_bin)


@dataclass
class _LoadPoint:
    workers: int
    cpu_load: int
    temp: float


def gather_measurements(
    profile: str,
    terminal: Terminal,
    temp_reader: Reader,
    fan_reader: Reader,
    fan_mode: str,
    cache: Cache,
    config: MeasureConfig | None = None,
    nproc: int | None = None,
) -> ProfileBlock:
    config = config or MeasureConfig()
    _require_stress_ng(terminal)
    if nproc is None:
        nproc = max(1, int(terminal.run("nproc").strip()))
    workers_grid = config.workers_grid or _default_workers_grid(
        nproc, config.worker_grid_size
    )
    fan_std_thresh = (
        config.fan_std_thresh_pwm if fan_mode == "pwm" else config.fan_std_thresh_rpm
    )

    block = ProfileBlock(
        target_per_bin=config.target_per_bin,
        started_at=datetime.now(timezone.utc).isoformat(timespec="seconds"),
    )
    cache.profiles[profile] = block
    load_temp_map: list[_LoadPoint] = []
    run_start = time.time()

    def log(message: str) -> None:
        if config.verbose:
            print(f"[fan-curve {time.strftime('%H:%M:%S')}] {message}", flush=True)

    def collect_samples(workers: int, cpu_load: int, direction: str):
        stable, temp, fan, settle = _wait_stable(
            terminal, temp_reader, fan_reader, config, fan_std_thresh
        )
        readings = _burst_readings(terminal, temp_reader, fan_reader, config, temp, fan)
        for reading_temp, reading_fan in readings:
            block.samples.append(
                Sample.create(
                    reading_temp,
                    reading_fan,
                    fan_mode,
                    workers,
                    cpu_load,
                    direction,
                    settle,
                    stable,
                )
            )
        mean_temp = sum(reading_temp for reading_temp, _ in readings) / len(readings)
        load_temp_map.append(_LoadPoint(workers, cpu_load, mean_temp))
        cache.save()
        return stable, readings, settle, mean_temp

    log(
        f"start profile={profile} nproc={nproc} workers_grid={workers_grid} "
        f"max_runtime={int(config.max_runtime_s)}s "
        f"target_per_bin={config.target_per_bin}"
    )

    # Phase A: small (workers, cpu_load) grid to learn how load corresponds
    # to temperature
    for workers in workers_grid:
        for cpu_load in config.cpu_load_grid:
            if cpu_load == 0 and any(p.cpu_load == 0 for p in load_temp_map):
                continue
            _set_stress(terminal, workers, cpu_load, config.stable_timeout_s)
            stable, readings, settle, mean_temp = collect_samples(
                workers, cpu_load, "phase_a"
            )
            log(
                f"phase_a workers={workers} load={cpu_load} -> "
                f"temp={mean_temp:.1f}C fan={readings[-1][1]:.0f} stable={stable} "
                f"settle={settle:.0f}s burst={len(readings)} n={len(block.samples)}"
            )
            if time.time() - run_start > config.max_runtime_s:
                break
        if time.time() - run_start > config.max_runtime_s:
            break

    reachable_min = min(p.temp for p in load_temp_map)
    reachable_max = max(p.temp for p in load_temp_map)
    log(f"phase_b reachable=[{reachable_min:.1f}..{reachable_max:.1f}]C")

    # Phase B: target temperature ranges which are not covered enough
    last_progress = time.time()
    last_total = len(block.samples)
    stop_reason = "all_bins_filled"
    while True:
        if time.time() - run_start > config.max_runtime_s:
            stop_reason = "max_runtime"
            break
        target_temp_bin = _get_most_underfilled_bin(
            block.samples,
            config.bin_width,
            config.target_per_bin,
            reachable_min,
            reachable_max,
            require_both_directions=config.require_both_directions,
        )
        if target_temp_bin is None:
            break
        if time.time() - last_progress > config.no_progress_timeout_s:
            stop_reason = "no_progress"
            break

        direction = _pick_direction(block.samples, target_temp_bin, config.bin_width)
        workers, cpu_load = _suggest_load_params(
            load_temp_map, target_temp_bin, config.bin_width, nproc
        )
        _prepare_hysteresis_temp_change(
            direction, target_temp_bin, config, terminal, temp_reader, nproc
        )
        _set_stress(
            terminal,
            workers,
            cpu_load,
            config.bin_arrival_timeout_s + config.stable_timeout_s,
        )
        _wait_until_in_bin(
            target_temp_bin,
            config.bin_width,
            config.bin_arrival_timeout_s,
            terminal,
            temp_reader,
            config,
        )
        stable, readings, settle, mean_temp = collect_samples(
            workers, cpu_load, direction
        )
        reachable_min = min(reachable_min, min(t for t, _ in readings))
        reachable_max = max(reachable_max, max(t for t, _ in readings))
        log(
            f"phase_b bin={target_temp_bin:.1f}C dir={direction} workers={workers} "
            f"load={cpu_load} -> temp={mean_temp:.1f}C fan={readings[-1][1]:.0f} "
            f"stable={stable} burst={len(readings)} n={len(block.samples)}"
        )

        if len(block.samples) > last_total:
            last_total = len(block.samples)
            last_progress = time.time()

    block.reachable_temp_range = [reachable_min, reachable_max]
    block.stop_reason = stop_reason
    block.finished_at = datetime.now(timezone.utc).isoformat(timespec="seconds")
    cache.save()
    log(
        f"done profile={profile} stop_reason={stop_reason} "
        f"samples={len(block.samples)} elapsed={int(time.time() - run_start)}s"
    )
    return block


def stop_stress(terminal: Terminal) -> None:
    terminal.run("pkill stress-ng 2>/dev/null; true")


def _burst_readings(
    terminal: Terminal,
    temp_reader: Reader,
    fan_reader: Reader,
    config: MeasureConfig,
    first_temp: float,
    first_fan: float,
) -> list[tuple[float, float]]:
    """Collect post stabilization readings."""
    readings = [(float(first_temp), float(first_fan))]
    for _ in range(max(0, config.post_stable_samples - 1)):
        time.sleep(config.post_stable_interval_s)
        readings.append(
            (float(temp_reader.read(terminal)), float(fan_reader.read(terminal)))
        )
    return readings


def _require_stress_ng(terminal: Terminal) -> None:
    if not terminal.run("command -v stress-ng 2>/dev/null").strip():
        raise RuntimeError(
            "stress-ng is not installed on the DUT. Install it before running "
            "fan curve measurement (e.g. `apt-get install -y stress-ng`)."
        )


def _set_stress(
    terminal: Terminal, workers: int, cpu_load: int, duration_s: float
) -> None:
    stop_stress(terminal=terminal)
    if cpu_load <= 0 or workers <= 0:
        return
    terminal.run_detached(
        f"(stress-ng --cpu {workers} --cpu-load {cpu_load} "
        f"--timeout {int(duration_s) + 30} -q &> /dev/null & disown) 2>/dev/null"
    )


def _wait_stable(
    terminal: Terminal,
    temp_reader: Reader,
    fan_reader: Reader,
    config: MeasureConfig,
    fan_std_thresh: float,
) -> tuple[bool, float, float, float]:
    """Wait until temp and fan rolling stddev are both small. Returns the most
    recent reading even on timeout, with stable=False."""
    start = time.time()
    window_size = max(2, int(config.stddev_window / config.poll_interval_s))
    consecutive_needed = max(1, int(config.stability_wait_s / config.poll_interval_s))
    temp_history: list[float] = []
    fan_history: list[float] = []
    consecutive_stable = 0
    temp = fan = 0.0
    while True:
        temp = float(temp_reader.read(terminal))
        fan = float(fan_reader.read(terminal))
        temp_history.append(temp)
        fan_history.append(fan)
        if len(temp_history) > window_size:
            temp_history.pop(0)
            fan_history.pop(0)
        if len(temp_history) >= window_size:
            if (
                statistics.pstdev(temp_history) < config.temp_std_thresh
                and statistics.pstdev(fan_history) < fan_std_thresh
            ):
                consecutive_stable += 1
            else:
                consecutive_stable = 0
            if consecutive_stable >= consecutive_needed:
                return True, temp, fan, time.time() - start
        if time.time() - start > config.stable_timeout_s:
            return False, temp, fan, time.time() - start
        time.sleep(config.poll_interval_s)


def _wait_until_in_bin(
    target_temp_bin: float,
    bin_width: float,
    timeout: float,
    terminal: Terminal,
    temp_reader: Reader,
    config: MeasureConfig,
) -> bool:
    start = time.time()
    while True:
        temp = float(temp_reader.read(terminal))
        if target_temp_bin <= temp < target_temp_bin + bin_width:
            return True
        if time.time() - start > timeout:
            return False
        time.sleep(config.poll_interval_s)


def _prepare_hysteresis_temp_change(
    direction: str,
    target_temp_bin: float,
    config: MeasureConfig,
    terminal: Terminal,
    temp_reader: Reader,
    nproc: int,
) -> None:
    """Drive temperature below (rising) or above (falling) the target bin so
    the next gather sample enters the bin from the chosen direction."""
    if direction == "rising":
        stop_stress(terminal)
        # cool to at least one bin below
        is_done = lambda temp: temp < target_temp_bin - config.bin_width
    else:
        _set_stress(terminal, nproc, 100, config.hysteresis_timeout_s)
        # heat to at least one bin above (2x because target_temp_bin is the bins lowest temp)
        is_done = lambda temp: temp > target_temp_bin + 2 * config.bin_width
    start = time.time()
    while time.time() - start < config.hysteresis_timeout_s:
        if is_done(float(temp_reader.read(terminal))):
            return
        time.sleep(config.poll_interval_s)


def _bin_of(temp: float, bin_width: float) -> float:
    return math.floor(temp / bin_width) * bin_width


def _bin_counts(samples: list[Sample], bin_width: float) -> dict[float, int]:
    counts: dict[float, int] = {}
    for sample in samples:
        bin_floor = _bin_of(sample.temp, bin_width)
        counts[bin_floor] = counts.get(bin_floor, 0) + 1
    return counts


def _direction_counts(
    samples: list[Sample], target_temp_bin: float, bin_width: float
) -> tuple[int, int]:
    rising = falling = 0
    for sample in samples:
        if _bin_of(sample.temp, bin_width) != target_temp_bin:
            continue
        if sample.direction == "rising":
            rising += 1
        elif sample.direction == "falling":
            falling += 1
    return rising, falling


def _get_most_underfilled_bin(
    samples: list[Sample],
    bin_width: float,
    target_per_bin: int,
    reachable_min: float,
    reachable_max: float,
    require_both_directions: bool = True,
) -> float | None:
    counts = _bin_counts(samples, bin_width)
    lower_bin = _bin_of(reachable_min, bin_width)
    upper_bin = _bin_of(reachable_max, bin_width)
    least: float | None = None
    least_count = target_per_bin
    current_bin = lower_bin
    while current_bin <= upper_bin + 1e-9:
        if counts.get(current_bin, 0) < least_count:
            least = current_bin
            least_count = counts.get(current_bin, 0)
        current_bin += bin_width
    if least is not None:
        return least
    if not require_both_directions:
        return None
    # All bins meet the count, but also check for missing rising/falling samples
    # on all but the first and last bin
    current_bin = lower_bin + bin_width
    while current_bin < upper_bin - 1e-9:
        rising, falling = _direction_counts(samples, current_bin, bin_width)
        if rising == 0 or falling == 0:
            return current_bin
        current_bin += bin_width
    return None


def _pick_direction(
    samples: list[Sample], target_temp_bin: float, bin_width: float
) -> str:
    rising, falling = _direction_counts(samples, target_temp_bin, bin_width)
    return "rising" if rising <= falling else "falling"


def _suggest_load_params(
    load_temp_map: list[_LoadPoint],
    target_temp_bin: float,
    bin_width: float,
    nproc: int,
) -> tuple[int, int]:
    temps_by_setting: dict[tuple[int, int], list[float]] = {}
    for point in load_temp_map:
        temps_by_setting.setdefault((point.workers, point.cpu_load), []).append(
            point.temp
        )
    points = [
        _LoadPoint(workers, load, sum(temps) / len(temps))
        for (workers, load), temps in temps_by_setting.items()
    ]

    center = target_temp_bin + bin_width / 2
    in_bin = [
        p for p in points if target_temp_bin <= p.temp < target_temp_bin + bin_width
    ]
    if in_bin:
        best = min(in_bin, key=lambda p: abs(p.temp - center))
        return best.workers, best.cpu_load
    below = [p for p in points if p.temp < target_temp_bin]
    above = [p for p in points if p.temp >= target_temp_bin + bin_width]
    if not above:
        return nproc, 100
    if not below:
        return 1, 0

    tried = set(temps_by_setting)
    candidates: list[tuple[float, int, int]] = []
    for cooler in below:
        for hotter in above:
            fraction = (center - cooler.temp) / max(hotter.temp - cooler.temp, 1e-3)
            workers_lerp = cooler.workers + (hotter.workers - cooler.workers) * fraction
            load_lerp = cooler.cpu_load + (hotter.cpu_load - cooler.cpu_load) * fraction
            workers = max(1, min(nproc, round(workers_lerp)))
            load = max(0, min(100, round(load_lerp)))
            if (workers, load) in tried:
                continue
            candidates.append((hotter.temp - cooler.temp, workers, load))
    if candidates:
        candidates.sort()
        return candidates[0][1], candidates[0][2]

    # If every interpolation was tried and we're still not getting good results,
    # try to move the load params an orthogonal direction
    coolest_above = min(above, key=lambda p: p.temp)
    for worker_delta, load_delta in [(-1, 0), (0, -10), (-1, -10), (1, -10)]:
        workers = max(1, min(nproc, coolest_above.workers + worker_delta))
        load = max(0, min(100, coolest_above.cpu_load + load_delta))
        if (workers, load) not in tried:
            return workers, load
    return coolest_above.workers, max(0, coolest_above.cpu_load - 1)


def _default_workers_grid(nproc: int, grid_size: int) -> list[int]:
    if grid_size <= 1:
        return [nproc]
    factor = nproc ** (1 / (grid_size - 1))
    return sorted({max(1, int(round(factor**step))) for step in range(grid_size)})


# ----------------------------------------------------------------------------
# Plotting
# ----------------------------------------------------------------------------


def plot(
    cache: Cache,
    curve: CurveConfig | None,
    logs_dir: str,
    profile: str | None = None,
    bin_width: float = 1.0,
    show: bool = False,
) -> str:
    out_dir = os.path.join(logs_dir, "fan_measurements")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, f"{cache.run_id}_{profile or 'all'}.png")

    colors = _profile_colors(list(cache.profiles.keys()))

    fig, ax = plt.subplots(figsize=(10, 6))
    for profile_name, block in cache.profiles.items():
        if not block.samples:
            continue
        focus = profile is None or profile_name == profile
        _plot_profile(
            ax,
            profile_name,
            block.samples,
            bin_width,
            colors[profile_name],
            focus,
        )

    if curve is not None:
        for profile_name in cache.profiles:
            focus = profile is None or profile_name == profile
            temps, values = curve.reference_points(profile_name, cache.fan_mode)
            if temps:
                ax.plot(
                    temps,
                    values,
                    ":",
                    color=colors[profile_name],
                    alpha=0.6 if focus else 0.2,
                )

    ax.set_xlabel("CPU temperature [C]")
    ax.set_ylabel("Fan PWM [%]" if cache.fan_mode == "pwm" else "Fan RPM")
    ax.set_title(f"Fan curve, {profile or 'all profiles'}, run_id={cache.run_id}")
    ax.legend(loc="best", fontsize="small")
    ax.grid(True, alpha=0.3)
    ranges = [
        block.reachable_temp_range for block in cache.profiles.values() if block.samples
    ]
    if ranges:
        ax.set_xlim(min(r[0] for r in ranges) - 3.0, max(r[1] for r in ranges) + 3.0)
    fig.tight_layout()
    fig.savefig(out_path, dpi=120)
    if show:
        plt.show()
    plt.close(fig)
    return out_path


def plot_load_grid(
    cache: Cache,
    logs_dir: str,
    profile: str | None = None,
    show: bool = False,
) -> str:
    """2D heatmap showing how temperature depends on number of workers and cpu_load"""
    out_dir = os.path.join(logs_dir, "fan_measurements")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, f"{cache.run_id}_loadgrid_{profile or 'all'}.png")

    candidates = [profile] if profile else list(cache.profiles)
    profiles = [
        name
        for name in candidates
        if cache.profiles.get(name) and cache.profiles[name].samples
    ]
    if not profiles:
        fig, ax = plt.subplots(figsize=(6, 3))
        ax.text(0.5, 0.5, "no samples", ha="center", va="center")
        ax.set_axis_off()
        fig.savefig(out_path, dpi=120)
        plt.close(fig)
        return out_path

    fig, axes = plt.subplots(
        1, len(profiles), figsize=(5 * len(profiles), 5), squeeze=False
    )
    for ax, name in zip(axes[0], profiles):
        _plot_one_load_grid(ax, name, cache.profiles[name].samples, fig)
    fig.suptitle(f"Load-grid temperature map - run_id={cache.run_id}")
    fig.tight_layout()
    fig.savefig(out_path, dpi=120)
    if show:
        plt.show()
    plt.close(fig)
    return out_path


def _profile_colors(profile_names: list[str]) -> dict[str, tuple]:
    cmap = plt.get_cmap("tab10")
    return {name: cmap(i % cmap.N) for i, name in enumerate(profile_names)}


def _plot_profile(ax, name, samples, bin_width, color, focus):
    temps = [s.temp for s in samples]
    fan_values = [s.fan for s in samples]
    bins, medians, lower_quartiles, upper_quartiles = _bin_stats(samples, bin_width)
    line_alpha = 1.0 if focus else 0.35
    band_alpha = 0.25 if focus else 0.08
    if bins:
        ax.scatter(temps, fan_values, color=color, alpha=band_alpha / 2)
        ax.fill_between(
            bins, lower_quartiles, upper_quartiles, color=color, alpha=band_alpha
        )
        ax.plot(bins, medians, color=color, alpha=line_alpha, label=name)


def _plot_one_load_grid(ax, profile_name: str, samples: list[Sample], fig) -> None:
    stable = [s for s in samples if s.stable]
    if not stable:
        ax.set_title(f"{profile_name} (no stable samples)")
        ax.set_axis_off()
        return

    workers_values = sorted({s.workers for s in stable})
    load_values = sorted({s.cpu_load for s in stable})
    cells: dict[tuple[int, int], list[float]] = {}
    for sample in stable:
        cells.setdefault((sample.workers, sample.cpu_load), []).append(sample.temp)

    grid = np.full((len(workers_values), len(load_values)), np.nan, dtype=float)
    for (workers, load), temps in cells.items():
        grid[workers_values.index(workers), load_values.index(load)] = statistics.mean(
            temps
        )

    image = ax.imshow(
        grid, aspect="auto", cmap="inferno", interpolation="nearest", origin="lower"
    )
    ax.set_xticks(range(len(load_values)), [f"{v}%" for v in load_values])
    ax.set_yticks(range(len(workers_values)), workers_values)
    ax.set_xlabel("cpu_load")
    ax.set_ylabel("workers")
    ax.set_title(f"{profile_name} ({len(stable)} stable samples)")
    mean = np.nanmean(grid)
    for row in range(grid.shape[0]):
        for col in range(grid.shape[1]):
            value = grid[row, col]
            if not math.isnan(value):
                ax.text(
                    col,
                    row,
                    f"{value:.0f}",
                    ha="center",
                    va="center",
                    color="white" if value > mean else "black",
                    fontsize=8,
                )
    fig.colorbar(image, ax=ax, label="temp [C]")


def _bin_stats(samples, bin_width):
    buckets: dict[float, list[float]] = {}
    for sample in samples:
        bin_floor = math.floor(sample.temp / bin_width) * bin_width
        buckets.setdefault(bin_floor, []).append(sample.fan)
    bins: list[float] = []
    medians: list[float] = []
    lower_quartiles: list[float] = []
    upper_quartiles: list[float] = []
    for bin_floor in sorted(buckets):
        values = sorted(buckets[bin_floor])
        bins.append(bin_floor + bin_width / 2)
        medians.append(statistics.median(values))
        if len(values) >= 2:
            q1, _, q3 = statistics.quantiles(values, n=4, method="inclusive")
        else:
            q1 = q3 = values[0]
        lower_quartiles.append(q1)
        upper_quartiles.append(q3)
    return bins, medians, lower_quartiles, upper_quartiles


# ----------------------------------------------------------------------------
# Offline CLI (entry point used by __main__.py)
# ----------------------------------------------------------------------------


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="python -m lib.fan_curve_tool")
    subparsers = parser.add_subparsers(dest="cmd", required=True)

    gather_parser = subparsers.add_parser("gather")
    gather_parser.add_argument("--run-id", required=True)
    gather_parser.add_argument("--profile", required=True)
    gather_parser.add_argument("--sensors-config", required=True)
    gather_parser.add_argument("--curve-config", required=True)
    gather_parser.add_argument("--host", required=True)
    gather_parser.add_argument("--user", default="root")
    gather_parser.add_argument("--port", type=int, default=22)
    gather_parser.add_argument("--password", default=os.environ.get("DUT_PASSWORD"))
    gather_parser.add_argument("--logs-dir", default=os.environ.get("LOGS_DIR", "logs"))
    gather_parser.add_argument("--resume", action="store_true")
    gather_parser.add_argument("--platform", default="unknown")
    gather_parser.add_argument("-v", "--verbose", action="store_true")
    gather_parser.add_argument(
        "--max-runtime",
        type=float,
        help="Cap on gather wallclock seconds (default 3600). "
        "Lower for quick debug runs.",
    )
    gather_parser.add_argument(
        "--target-per-bin",
        type=int,
        help="Samples per temperature bin in Phase B (default 5). "
        "Set to 1 for a rough debug curve that still covers the full reachable range.",
    )
    gather_parser.add_argument(
        "--quick",
        action="store_true",
        help="Debug-grade run: short stabilization/staging/arrival timeouts, "
        "default target_per_bin=1, and skip the rising+falling direction "
        "coverage pass. Explicit overrides still win.",
    )

    plot_parser = subparsers.add_parser("plot")
    plot_parser.add_argument("--run-id", required=True)
    plot_parser.add_argument("--logs-dir", default=os.environ.get("LOGS_DIR", "logs"))
    plot_parser.add_argument("--curve-config")
    plot_parser.add_argument("--profile")
    plot_parser.add_argument(
        "--load-grid",
        action="store_true",
        help="Also emit a (workers x cpu_load) -> temperature heatmap.",
    )
    gather_parser.add_argument("--env-id", required=True)

    args = parser.parse_args(argv)
    if args.cmd == "gather":
        return _cli_gather(args)
    return _cli_plot(args)


def _cli_gather(args) -> int:
    sensors_config = SensorsConfig.load(args.sensors_config)
    fan_mode, fan_spec = pick_fan_mode(sensors_config)
    with Terminal(
        host=args.host, user=args.user, port=args.port, password=args.password
    ) as terminal:
        prepare_sensors(terminal, sensors_config, args.env_id)
        cache = Cache.open(
            logs_dir=args.logs_dir,
            run_id=args.run_id,
            platform=args.platform,
            fan_mode=fan_mode,
            resume=args.resume,
        )
        measure_config = MeasureConfig()
        measure_config.apply_overrides(
            verbose=args.verbose,
            quick=args.quick,
            max_runtime=args.max_runtime,
            target_per_bin=args.target_per_bin,
        )
        gather_measurements(
            profile=args.profile,
            terminal=terminal,
            temp_reader=Reader(sensors_config.cpu_temp),
            fan_reader=Reader(fan_spec),
            fan_mode=fan_mode,
            cache=cache,
            config=measure_config,
        )
    return 0


def _cli_plot(args) -> int:
    path = os.path.join(args.logs_dir, "fan_measurements", f"{args.run_id}.json")
    cache = Cache.load_existing(path, run_id_fallback=args.run_id)
    curve = CurveConfig.load(args.curve_config) if args.curve_config else None
    print(plot(cache, curve, args.logs_dir, profile=args.profile, show=True))
    if args.load_grid:
        print(plot_load_grid(cache, args.logs_dir, profile=args.profile, show=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
