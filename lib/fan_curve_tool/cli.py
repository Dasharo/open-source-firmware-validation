# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import argparse
import os
import sys

from .cache import Cache
from .curve_yaml import CurveConfig
from .measure import MeasureConfig, gather
from .plot import plot as plot_fn
from .plot import plot_load_grid
from .sensors import CpuTempReader, FanReader, pick_fan_mode, prepare_sensors
from .sensors_yaml import SensorsConfig
from .terminal import SSHTerminal


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(prog="python -m lib.fan_curve_tool")
    sub = p.add_subparsers(dest="cmd", required=True)

    g = sub.add_parser("gather")
    g.add_argument("--run-id", required=True)
    g.add_argument("--profile", required=True)
    g.add_argument("--sensors-config", required=True)
    g.add_argument("--curve-config", required=True)
    g.add_argument("--host", required=True)
    g.add_argument("--user", default="root")
    g.add_argument("--port", type=int, default=22)
    g.add_argument("--password", default=os.environ.get("DUT_PASSWORD"))
    g.add_argument("--logs-dir", default=os.environ.get("LOGS_DIR", "logs"))
    g.add_argument("--resume", action="store_true")
    g.add_argument("--platform", default="unknown")
    g.add_argument("-v", "--verbose", action="store_true")
    g.add_argument(
        "--max-runtime",
        type=float,
        help="Cap on gather wallclock seconds (default 3600). Lower for quick debug runs.",
    )
    g.add_argument(
        "--target-per-bin",
        type=int,
        help="Samples per temperature bin in Phase B (default 5). Set to 1 for a "
        "rough debug curve that still covers the full reachable range.",
    )
    g.add_argument(
        "--quick",
        action="store_true",
        help="Debug-grade run: short stabilization/staging/arrival timeouts, "
        "default target_per_bin=1, and skip the rising+falling direction "
        "coverage pass. Explicit overrides still win.",
    )

    pl = sub.add_parser("plot")
    pl.add_argument("--run-id", required=True)
    pl.add_argument("--logs-dir", default=os.environ.get("LOGS_DIR", "logs"))
    pl.add_argument("--curve-config")
    pl.add_argument("--profile")
    pl.add_argument(
        "--load-grid",
        action="store_true",
        help="Also emit a (workers x cpu_load) -> temperature heatmap.",
    )

    args = p.parse_args(argv)
    if args.cmd == "gather":
        return _gather(args)
    return _plot(args)


def _gather(args) -> int:
    sensors_cfg = SensorsConfig.load(args.sensors_config)
    fan_mode, spec = pick_fan_mode(sensors_cfg)
    terminal = SSHTerminal(
        host=args.host, user=args.user, port=args.port, password=args.password
    )
    try:
        prepare_sensors(terminal, sensors_cfg)
        cache = Cache.open(
            logs_dir=args.logs_dir,
            run_id=args.run_id,
            platform=args.platform,
            fan_mode=fan_mode,
            resume=args.resume,
        )
        mcfg = MeasureConfig()
        mcfg.apply_overrides(
            verbose=args.verbose,
            quick=args.quick,
            max_runtime=args.max_runtime,
            target_per_bin=args.target_per_bin,
        )
        gather(
            profile=args.profile,
            terminal=terminal,
            temp_reader=CpuTempReader(sensors_cfg.cpu_temp),
            fan_reader=FanReader(spec, fan_mode),
            fan_mode=fan_mode,
            cache=cache,
            config=mcfg,
        )
    finally:
        terminal.close()
    return 0


def _plot(args) -> int:
    path = os.path.join(args.logs_dir, "fan_measurements", f"{args.run_id}.json")
    cache = Cache.load_existing(path, run_id_fallback=args.run_id)
    curve = CurveConfig.load(args.curve_config) if args.curve_config else None
    print(plot_fn(cache, curve, args.logs_dir, profile=args.profile, show=True))
    if args.load_grid:
        print(plot_load_grid(cache, args.logs_dir, profile=args.profile, show=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
