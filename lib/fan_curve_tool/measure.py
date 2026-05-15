# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import math
import statistics
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone

from .cache import Cache, ProfileBlock, Sample
from .sensors import CpuTempReader, FanReader
from .terminal import Terminal


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
    stability_window: int = 5
    stable_timeout_s: float = 30.0
    bin_arrival_timeout_s: float = 30.0
    staging_timeout_s: float = 60.0
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
            self.staging_timeout_s = 60.0
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


def gather(
    profile: str,
    terminal: Terminal,
    temp_reader: CpuTempReader,
    fan_reader: FanReader,
    fan_mode: str,
    cache: Cache,
    config: MeasureConfig | None = None,
    nproc: int | None = None,
) -> ProfileBlock:
    cfg = config or MeasureConfig()
    _require_stress_ng(terminal)
    if nproc is None:
        nproc = max(1, int(terminal.run("nproc").strip()))
    workers_grid = cfg.workers_grid or _default_workers_grid(
        nproc, cfg.worker_grid_size
    )
    fan_std = cfg.fan_std_thresh_pwm if fan_mode == "pwm" else cfg.fan_std_thresh_rpm

    block = ProfileBlock(target_per_bin=cfg.target_per_bin, started_at=_iso_now())
    cache.profiles[profile] = block
    load_temp_map: list[_LoadPoint] = []
    run_start = time.time()

    def log(msg: str) -> None:
        if cfg.verbose:
            print(f"[fan-curve {time.strftime('%H:%M:%S')}] {msg}", flush=True)

    def collect(workers: int, cpu_load: int, direction: str):
        stable, temp, fan, settle = _wait_stable(
            terminal, temp_reader, fan_reader, cfg, fan_std
        )
        readings = _burst_readings(terminal, temp_reader, fan_reader, cfg, temp, fan)
        for t, f in readings:
            block.samples.append(
                Sample.create(
                    t, f, fan_mode, workers, cpu_load, direction, settle, stable
                )
            )
        mean_temp = sum(t for t, _ in readings) / len(readings)
        load_temp_map.append(_LoadPoint(workers, cpu_load, mean_temp))
        cache.save()
        return stable, readings, settle, mean_temp

    log(
        f"start profile={profile} nproc={nproc} workers_grid={workers_grid} "
        f"max_runtime={int(cfg.max_runtime_s)}s target_per_bin={cfg.target_per_bin}"
    )

    # Phase A: small (workers, cpu_load) grid to learn load -> temp.
    for workers in workers_grid:
        for cpu_load in cfg.cpu_load_grid:
            if cpu_load == 0 and any(p.cpu_load == 0 for p in load_temp_map):
                continue
            _set_stress(terminal, workers, cpu_load, cfg.stable_timeout_s)
            stable, readings, settle, mean_temp = collect(workers, cpu_load, "phase_a")
            log(
                f"phase_a workers={workers} load={cpu_load} -> "
                f"temp={mean_temp:.1f}C fan={readings[-1][1]:.0f} stable={stable} "
                f"settle={settle:.0f}s burst={len(readings)} n={len(block.samples)}"
            )
            if time.time() - run_start > cfg.max_runtime_s:
                break
        if time.time() - run_start > cfg.max_runtime_s:
            break

    reachable_min = min(p.temp for p in load_temp_map)
    reachable_max = max(p.temp for p in load_temp_map)
    log(f"phase_b reachable=[{reachable_min:.1f}..{reachable_max:.1f}]C")

    # Phase B: target under-filled bins, alternating approach direction.
    last_progress = time.time()
    last_total = len(block.samples)
    stop_reason = "all_bins_filled"
    while True:
        if time.time() - run_start > cfg.max_runtime_s:
            stop_reason = "max_runtime"
            break
        target_bin = _least_filled_bin(
            block.samples,
            cfg.bin_width,
            cfg.target_per_bin,
            reachable_min,
            reachable_max,
            require_both_directions=cfg.require_both_directions,
        )
        if target_bin is None:
            break
        if time.time() - last_progress > cfg.no_progress_timeout_s:
            stop_reason = "no_progress"
            break

        direction = _pick_direction(block.samples, target_bin, cfg.bin_width)
        workers, cpu_load = _invert_map_2d(
            load_temp_map, target_bin, cfg.bin_width, nproc
        )
        _move_to_staging(direction, target_bin, cfg, terminal, temp_reader, nproc)
        _set_stress(
            terminal,
            workers,
            cpu_load,
            cfg.bin_arrival_timeout_s + cfg.stable_timeout_s,
        )
        _wait_until_in_bin(
            target_bin,
            cfg.bin_width,
            cfg.bin_arrival_timeout_s,
            terminal,
            temp_reader,
            cfg,
        )
        stable, readings, settle, mean_temp = collect(workers, cpu_load, direction)
        reachable_min = min(reachable_min, min(t for t, _ in readings))
        reachable_max = max(reachable_max, max(t for t, _ in readings))
        log(
            f"phase_b bin={target_bin:.1f}C dir={direction} workers={workers} "
            f"load={cpu_load} -> temp={mean_temp:.1f}C fan={readings[-1][1]:.0f} "
            f"stable={stable} burst={len(readings)} n={len(block.samples)}"
        )

        if len(block.samples) > last_total:
            last_total = len(block.samples)
            last_progress = time.time()

    block.reachable_temp_range = [reachable_min, reachable_max]
    block.stop_reason = stop_reason
    block.finished_at = _iso_now()
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
    temp_reader: CpuTempReader,
    fan_reader: FanReader,
    cfg: MeasureConfig,
    first_temp: float,
    first_fan: float,
) -> list[tuple[float, float]]:
    """Collect post-stable readings. On a stabilization timeout the resulting
    spread widens the IQR, which is the desired signal — each Sample carries
    its own `stable` flag for downstream filtering."""
    readings = [(float(first_temp), float(first_fan))]
    for _ in range(max(0, cfg.post_stable_samples - 1)):
        time.sleep(cfg.post_stable_interval_s)
        readings.append(
            (float(temp_reader.read(terminal)), float(fan_reader.read(terminal)))
        )
    return readings


def _require_stress_ng(terminal: Terminal) -> None:
    if not terminal.run("command -v stress-ng 2>/dev/null").strip():
        raise RuntimeError(
            "stress-ng is not installed on the DUT. Install it before running "
            "fan curve measurement (e.g. `apt-get install -y stress-ng`, "
            "`dnf install -y stress-ng`, or the equivalent for the DUT's distro)."
        )


def _set_stress(
    terminal: Terminal, workers: int, cpu_load: int, duration_s: float
) -> None:
    stop_stress(terminal=terminal)
    if cpu_load <= 0 or workers <= 0:
        return
    terminal.run(
        f"(stress-ng --cpu {workers} --cpu-load {cpu_load} --timeout {int(duration_s) + 30} -q"
        f" &> /dev/null & disown) 2>/dev/null"
    )


def _wait_stable(
    terminal: Terminal,
    temp_reader: CpuTempReader,
    fan_reader: FanReader,
    cfg: MeasureConfig,
    fan_std_thresh: float,
) -> tuple[bool, float, float, float]:
    """Wait until both temp and fan rolling stddev are small. Always returns
    the most recent reading even on timeout, with stable=False."""
    start = time.time()
    window_n = max(2, int(cfg.stddev_window / cfg.poll_interval_s))
    consec_needed = max(1, int(cfg.stability_window / cfg.poll_interval_s))
    temp_hist: list[float] = []
    fan_hist: list[float] = []
    consec_ok = 0
    temp = fan = 0.0
    while True:
        temp = float(temp_reader.read(terminal))
        fan = float(fan_reader.read(terminal))
        temp_hist.append(temp)
        fan_hist.append(fan)
        if len(temp_hist) > window_n:
            temp_hist.pop(0)
            fan_hist.pop(0)
        if len(temp_hist) >= window_n:
            if (
                statistics.pstdev(temp_hist) < cfg.temp_std_thresh
                and statistics.pstdev(fan_hist) < fan_std_thresh
            ):
                consec_ok += 1
            else:
                consec_ok = 0
            if consec_ok >= consec_needed:
                return True, temp, fan, time.time() - start
        if time.time() - start > cfg.stable_timeout_s:
            return False, temp, fan, time.time() - start
        time.sleep(cfg.poll_interval_s)


def _wait_until_in_bin(
    target_bin: float,
    bin_width: float,
    timeout: float,
    terminal: Terminal,
    temp_reader: CpuTempReader,
    cfg: MeasureConfig,
) -> bool:
    start = time.time()
    while True:
        temp = float(temp_reader.read(terminal))
        if target_bin <= temp < target_bin + bin_width:
            return True
        if time.time() - start > timeout:
            return False
        time.sleep(cfg.poll_interval_s)


def _move_to_staging(
    direction: str,
    target_bin: float,
    cfg: MeasureConfig,
    terminal: Terminal,
    temp_reader: CpuTempReader,
    nproc: int,
) -> None:
    """Drive temperature below (rising) or above (falling) the target bin so
    that the next gather sample enters the bin from the chosen direction."""
    if direction == "rising":
        _set_stress(terminal, 1, 0, cfg.staging_timeout_s)
        done = lambda t: t < target_bin - cfg.bin_width
    else:
        _set_stress(terminal, nproc, 100, cfg.staging_timeout_s)
        done = lambda t: t > target_bin + 2 * cfg.bin_width
    start = time.time()
    while time.time() - start < cfg.staging_timeout_s:
        if done(float(temp_reader.read(terminal))):
            return
        time.sleep(cfg.poll_interval_s)


def _bin_of(temp: float, bin_width: float) -> float:
    return math.floor(temp / bin_width) * bin_width


def _bin_counts(samples: list[Sample], bin_width: float) -> dict[float, int]:
    counts: dict[float, int] = {}
    for s in samples:
        b = _bin_of(s.temp, bin_width)
        counts[b] = counts.get(b, 0) + 1
    return counts


def _direction_counts(
    samples: list[Sample], target_bin: float, bin_width: float
) -> tuple[int, int]:
    rising = falling = 0
    for s in samples:
        if _bin_of(s.temp, bin_width) != target_bin:
            continue
        if s.direction == "rising":
            rising += 1
        elif s.direction == "falling":
            falling += 1
    return rising, falling


def _least_filled_bin(
    samples: list[Sample],
    bin_width: float,
    target_per_bin: int,
    reachable_min: float,
    reachable_max: float,
    require_both_directions: bool = True,
) -> float | None:
    counts = _bin_counts(samples, bin_width)
    lo = _bin_of(reachable_min, bin_width)
    hi = _bin_of(reachable_max, bin_width)
    least: float | None = None
    least_count = target_per_bin
    b = lo
    while b <= hi + 1e-9:
        if counts.get(b, 0) < least_count:
            least = b
            least_count = counts.get(b, 0)
        b += bin_width
    if least is not None:
        return least
    if not require_both_directions:
        return None
    # All bins meet the count; check for missing rising/falling samples in
    # interior bins (edges may be one-direction-only on this DUT).
    b = lo + bin_width
    while b < hi - 1e-9:
        rising, falling = _direction_counts(samples, b, bin_width)
        if rising == 0 or falling == 0:
            return b
        b += bin_width
    return None


def _pick_direction(samples: list[Sample], target_bin: float, bin_width: float) -> str:
    rising, falling = _direction_counts(samples, target_bin, bin_width)
    return "rising" if rising <= falling else "falling"


def _invert_map_2d(
    load_temp_map: list[_LoadPoint],
    target_bin: float,
    bin_width: float,
    nproc: int,
) -> tuple[int, int]:
    """Pick (workers, cpu_load) whose learned mean temp lands in the target
    bin. Repeat visits to the same setting are averaged. Then linearly
    interpolate between every (below, above) pair across both axes; the pair
    whose interpolated setting is untried and has the tightest temp gap wins.
    A cliff on one axis (e.g. stress-ng's jump at cpu_load=100) is escaped
    automatically because the cliff pair's interpolation rounds to a setting
    we've already tried and is filtered out."""
    by_setting: dict[tuple[int, int], list[float]] = {}
    for p in load_temp_map:
        by_setting.setdefault((p.workers, p.cpu_load), []).append(p.temp)
    points = [_LoadPoint(w, l, sum(ts) / len(ts)) for (w, l), ts in by_setting.items()]

    center = target_bin + bin_width / 2
    in_bin = [p for p in points if target_bin <= p.temp < target_bin + bin_width]
    if in_bin:
        best = min(in_bin, key=lambda p: abs(p.temp - center))
        return best.workers, best.cpu_load
    below = [p for p in points if p.temp < target_bin]
    above = [p for p in points if p.temp >= target_bin + bin_width]
    if not above:
        return nproc, 100
    if not below:
        return 1, 0

    tried = set(by_setting)
    candidates: list[tuple[float, int, int]] = []
    for b in below:
        for a in above:
            frac = (center - b.temp) / max(a.temp - b.temp, 1e-3)
            w = max(1, min(nproc, round(b.workers + (a.workers - b.workers) * frac)))
            l = max(0, min(100, round(b.cpu_load + (a.cpu_load - b.cpu_load) * frac)))
            if (w, l) in tried:
                continue
            candidates.append((a.temp - b.temp, w, l))
    if candidates:
        candidates.sort()
        return candidates[0][1], candidates[0][2]

    # Every interpolation lands on a tried setting. Nudge from the coolest
    # "above" point along an untried direction.
    a = min(above, key=lambda p: p.temp)
    for dw, dl in [(-1, 0), (0, -10), (-1, -10), (1, -10), (-2, 0)]:
        w = max(1, min(nproc, a.workers + dw))
        l = max(0, min(100, a.cpu_load + dl))
        if (w, l) not in tried:
            return w, l
    return a.workers, max(0, a.cpu_load - 1)


def _default_workers_grid(nproc: int, grid_size: int) -> list[int]:
    if grid_size <= 1:
        return [nproc]
    factor = nproc ** (1 / (grid_size - 1))
    return sorted({max(1, int(round(factor**step))) for step in range(grid_size)})


def _iso_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")
