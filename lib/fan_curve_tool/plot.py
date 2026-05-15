# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import math
import os
import statistics

import matplotlib.pyplot as plt
import numpy as np

from .cache import Cache, Sample
from .curve_yaml import CurveConfig


def _profile_colors(profile_names: list[str]) -> dict[str, tuple]:
    cmap = plt.get_cmap("tab10")
    return {name: cmap(i % cmap.N) for i, name in enumerate(profile_names)}


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
    for prof_name, block in cache.profiles.items():
        if not block.samples:
            continue
        focus = profile is None or prof_name == profile
        color = colors[prof_name]
        _plot_profile(
            ax, prof_name, block.samples, cache.fan_mode, bin_width, color, focus
        )

    if curve is not None:
        for prof_name in cache.profiles:
            focus = profile is None or prof_name == profile
            color = colors[prof_name]
            temps, values = curve.reference_points(prof_name, cache.fan_mode)
            if temps:
                ax.plot(
                    temps,
                    values,
                    ":",
                    color=color,
                    alpha=0.6 if focus else 0.2,
                )

    ax.set_xlabel("CPU temperature [°C]")
    ax.set_ylabel("Fan PWM [%]" if cache.fan_mode == "pwm" else "Fan RPM")
    ax.set_title(f"Fan curve — {profile or 'all profiles'} — run_id={cache.run_id}")
    ax.legend(loc="best", fontsize="small")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(out_path, dpi=120)
    if show:
        plt.show()
    plt.close(fig)
    return out_path


def _plot_profile(ax, name, samples, fan_mode, bin_width, color, focus):
    points = list(zip(*[(s.temp, s.fan) for s in samples]))
    bins, medians, q1s, q3s = _bin_stats(samples, fan_mode, bin_width)
    line_alpha = 1.0 if focus else 0.35
    band_alpha = 0.25 if focus else 0.08
    if bins:
        ax.scatter(points[0], points[1], color=color, alpha=band_alpha / 2)
        ax.fill_between(bins, q1s, q3s, color=color, alpha=band_alpha)
        ax.plot(bins, medians, color=color, alpha=line_alpha, label=name)


def _fan_value(s: Sample, fan_mode: str) -> float:
    return s.fan / 2.55 if fan_mode == "pwm" else s.fan


def plot_load_grid(
    cache: Cache,
    logs_dir: str,
    profile: str | None = None,
    show: bool = False,
) -> str:
    """Crude 2D heatmap of (workers, cpu_load) -> mean stable temperature, one
    panel per profile. Cells without samples stay blank."""
    out_dir = os.path.join(logs_dir, "fan_measurements")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, f"{cache.run_id}_loadgrid_{profile or 'all'}.png")

    candidates = [profile] if profile else list(cache.profiles)
    profiles = [
        p for p in candidates if cache.profiles.get(p) and cache.profiles[p].samples
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
    fig.suptitle(f"Load-grid temperature map — run_id={cache.run_id}")
    fig.tight_layout()
    fig.savefig(out_path, dpi=120)
    if show:
        plt.show()
    plt.close(fig)
    return out_path


def _plot_one_load_grid(ax, profile_name: str, samples: list[Sample], fig) -> None:
    stable = [s for s in samples if s.stable]
    if not stable:
        ax.set_title(f"{profile_name} (no stable samples)")
        ax.set_axis_off()
        return

    workers_vals = sorted({s.workers for s in stable})
    load_vals = sorted({s.load for s in stable})
    cells: dict[tuple[int, int], list[float]] = {}
    for s in stable:
        cells.setdefault((s.workers, s.load), []).append(s.temp)

    grid = np.full((len(workers_vals), len(load_vals)), np.nan, dtype=float)
    for (w, l), temps in cells.items():
        grid[workers_vals.index(w), load_vals.index(l)] = statistics.mean(temps)

    # origin="lower" puts higher worker counts at the top (workers_vals is ascending).
    im = ax.imshow(
        grid, aspect="auto", cmap="inferno", interpolation="nearest", origin="lower"
    )
    ax.set_xticks(range(len(load_vals)), [f"{v}%" for v in load_vals])
    ax.set_yticks(range(len(workers_vals)), workers_vals)
    ax.set_xlabel("cpu_load")
    ax.set_ylabel("workers")
    ax.set_title(f"{profile_name} ({len(stable)} stable samples)")
    mean = np.nanmean(grid)
    for i in range(grid.shape[0]):
        for j in range(grid.shape[1]):
            v = grid[i, j]
            if not math.isnan(v):
                ax.text(
                    j,
                    i,
                    f"{v:.0f}",
                    ha="center",
                    va="center",
                    color="white" if v > mean else "black",
                    fontsize=8,
                )
    fig.colorbar(im, ax=ax, label="temp [°C]")


def _bin_stats(samples, fan_mode, bin_width):
    buckets: dict[float, list[float]] = {}
    for s in samples:
        b = math.floor(s.temp / bin_width) * bin_width
        buckets.setdefault(b, []).append(_fan_value(s, fan_mode))
    bins: list[float] = []
    medians: list[float] = []
    q1s: list[float] = []
    q3s: list[float] = []
    for b in sorted(buckets):
        vals = sorted(buckets[b])
        bins.append(b + bin_width / 2)
        medians.append(statistics.median(vals))
        if len(vals) >= 2:
            q1, _, q3 = statistics.quantiles(vals, n=4, method="inclusive")
        else:
            q1 = q3 = vals[0]
        q1s.append(q1)
        q3s.append(q3)
    return bins, medians, q1s, q3s
