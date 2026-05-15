# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import socket
import sys
import time

_REPO_ROOT = os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
)
if _REPO_ROOT not in sys.path:
    sys.path.insert(0, _REPO_ROOT)

from robot.api.deco import keyword, library

from lib.fan_curve_tool.cache import Cache
from lib.fan_curve_tool.curve_yaml import CurveConfig
from lib.fan_curve_tool.measure import MeasureConfig, gather, stop_stress
from lib.fan_curve_tool.plot import plot as plot_fn
from lib.fan_curve_tool.plot import plot_load_grid
from lib.fan_curve_tool.sensors import (
    CpuTempReader,
    FanReader,
    pick_fan_mode,
    prepare_sensors,
)
from lib.fan_curve_tool.sensors_yaml import SensorsConfig
from lib.fan_curve_tool.terminal import RobotTerminal


@library(scope="GLOBAL", auto_keywords=False)
class FanCurveTool:
    """Robot Framework keywords for the fan curve measurement tool."""

    def __init__(self):
        self._logs_dir = ""
        self._sensors_cfg: SensorsConfig | None = None
        self._curve_cfg: CurveConfig | None = None
        self._console_connection: RobotTerminal | None = None
        self._temp_reader: CpuTempReader | None = None
        self._fan_reader: FanReader | None = None
        self._fan_mode = ""
        self._cache: Cache | None = None
        self._config = MeasureConfig()

    @keyword("Fan Measure Init")
    def fan_measure_init(
        self,
        run_id: str,
        sensors_config_file: str,
        curve_config_file: str,
        logs_dir: str = "",
        resume: bool = False,
    ) -> None:
        run_id = run_id or self._auto_run_id()
        self._logs_dir = logs_dir or os.environ.get("LOGS_DIR", "logs")
        os.makedirs(self._logs_dir, exist_ok=True)

        platform_cfg_dir = _platform_configs_dir()
        self._sensors_cfg = SensorsConfig.load(
            os.path.join(platform_cfg_dir, sensors_config_file)
        )
        self._curve_cfg = CurveConfig.load(
            os.path.join(platform_cfg_dir, curve_config_file)
        )
        self._fan_mode, spec = pick_fan_mode(self._sensors_cfg)
        self._temp_reader = CpuTempReader(self._sensors_cfg.cpu_temp)
        self._fan_reader = FanReader(spec, self._fan_mode)
        self._console_connection = RobotTerminal()

        self._cache = Cache.open(
            logs_dir=self._logs_dir,
            run_id=run_id,
            platform=os.environ.get("CONFIG", socket.gethostname()),
            fan_mode=self._fan_mode,
            resume=bool(resume),
        )
        stop_stress(self._console_connection)

    @keyword("Fan Measure Gather")
    def fan_measure_gather(
        self,
        profile: str,
        verbose: bool = False,
        max_runtime: float | None = None,
        target_per_bin: int | None = None,
        quick: bool = False,
    ) -> dict:
        assert self._cache is not None, "Fan Measure Init must be called first"
        prepare_sensors(self._console_connection, self._sensors_cfg)
        self._config.apply_overrides(
            verbose=verbose,
            quick=quick,
            max_runtime=max_runtime,
            target_per_bin=target_per_bin,
        )
        block = gather(
            profile=profile,
            terminal=self._console_connection,
            temp_reader=self._temp_reader,
            fan_reader=self._fan_reader,
            fan_mode=self._fan_mode,
            cache=self._cache,
            config=self._config,
        )
        return {
            "samples_n": len(block.samples),
            "reachable_min": block.reachable_temp_range[0],
            "reachable_max": block.reachable_temp_range[1],
            "stop_reason": block.stop_reason,
            "json_path": self._cache.path,
        }

    @keyword("Fan Measure Show Graphs")
    def fan_measure_show_graphs(self, profile: str = "") -> str:
        assert self._cache is not None, "Fan Measure Init must be called first"
        return plot_fn(
            cache=self._cache,
            curve=self._curve_cfg,
            logs_dir=self._logs_dir,
            profile=profile or None,
            bin_width=self._config.bin_width,
        )

    @keyword("Fan Measure Show Load Grid")
    def fan_measure_show_load_grid(self, profile: str = "") -> str:
        assert self._cache is not None, "Fan Measure Init must be called first"
        return plot_load_grid(
            cache=self._cache,
            logs_dir=self._logs_dir,
            profile=profile or None,
        )

    @keyword("Fan Measure Stop Stress")
    def fan_measure_stop_stress(self) -> None:
        if self._console_connection is None:
            return
        try:
            stop_stress(self._console_connection)
        except Exception:
            # Best-effort during teardown — a dead session here shouldn't
            # mask the real failure.
            pass

    @staticmethod
    def _auto_run_id() -> str:
        host = os.environ.get("CONFIG", "unknown-config")
        return f"{host}-{time.strftime('%Y%m%dT%H%M%S')}"


def _platform_configs_dir() -> str:
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.normpath(os.path.join(here, "..", "..", "platform-configs"))
