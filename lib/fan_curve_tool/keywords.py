# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import socket
import sys
import time

# Robot loads this file by path (Library ../lib/fan_curve_tool/keywords.py),
# not as a package, so absolute `lib.fan_curve_tool.*` imports need the repo
# root on sys.path.
_REPO_ROOT = os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
)
if _REPO_ROOT not in sys.path:
    sys.path.insert(0, _REPO_ROOT)

from robot.api.deco import keyword, library
from robot.libraries.BuiltIn import BuiltIn

from lib.fan_curve_tool import (
    Cache,
    CpuTempReader,
    CurveConfig,
    FanReader,
    MeasureConfig,
    SensorsConfig,
    Terminal,
    gather,
    pick_fan_mode,
    plot,
    plot_load_grid,
    prepare_sensors,
    stop_stress,
)

_HERE = os.path.dirname(os.path.abspath(__file__))
PLATFORM_CONFIGS_DIR = os.path.normpath(
    os.path.join(_HERE, "..", "..", "platform-configs")
)


@library(scope="GLOBAL", auto_keywords=False)
class FanCurveTool:
    """Robot Framework keywords for the fan curve measurement tool."""

    def __init__(self):
        self._logs_dir = ""
        self._sensors_config: SensorsConfig | None = None
        self._curve_config: CurveConfig | None = None
        self._temp_reader: CpuTempReader | None = None
        self._fan_reader: FanReader | None = None
        self._fan_mode = ""
        self._cache: Cache | None = None
        self._measure_config = MeasureConfig()

    @keyword("Fan Measure Init")
    def fan_measure_init(
        self,
        run_id: str,
        sensors_config_file: str,
        curve_config_file: str,
        logs_dir: str = "",
        resume: bool = False,
    ) -> None:
        platform = os.environ.get("CONFIG", socket.gethostname())
        run_id = run_id or f"{platform}-{time.strftime('%Y%m%dT%H%M%S')}"
        self._logs_dir = logs_dir or os.environ.get("LOGS_DIR", "logs")
        os.makedirs(self._logs_dir, exist_ok=True)

        self._sensors_config = SensorsConfig.load(
            os.path.join(PLATFORM_CONFIGS_DIR, sensors_config_file)
        )
        self._curve_config = CurveConfig.load(
            os.path.join(PLATFORM_CONFIGS_DIR, curve_config_file)
        )
        self._fan_mode, fan_spec = pick_fan_mode(self._sensors_config)
        self._temp_reader = CpuTempReader(self._sensors_config.cpu_temp)
        self._fan_reader = FanReader(fan_spec, self._fan_mode)

        self._cache = Cache.open(
            logs_dir=self._logs_dir,
            run_id=run_id,
            platform=platform,
            fan_mode=self._fan_mode,
            resume=bool(resume),
        )
        with _open_terminal() as terminal:
            stop_stress(terminal)

    @keyword("Fan Measure Gather")
    def fan_measure_gather(
        self,
        profile: str,
        verbose: bool = True,
        max_runtime: float | None = None,
        target_per_bin: int | None = None,
        quick: bool = False,
    ) -> dict:
        assert self._cache is not None, "Fan Measure Init must be called first"
        self._measure_config.apply_overrides(
            verbose=verbose,
            quick=quick,
            max_runtime=max_runtime,
            target_per_bin=target_per_bin,
        )
        with _open_terminal() as terminal:
            prepare_sensors(terminal, self._sensors_config)
            block = gather(
                profile=profile,
                terminal=terminal,
                temp_reader=self._temp_reader,
                fan_reader=self._fan_reader,
                fan_mode=self._fan_mode,
                cache=self._cache,
                config=self._measure_config,
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
        return plot(
            cache=self._cache,
            curve=self._curve_config,
            logs_dir=self._logs_dir,
            profile=profile or None,
            bin_width=self._measure_config.bin_width,
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
        # Best-effort during suite teardown: a dead DUT here must not mask
        # the real failure.
        try:
            with _open_terminal() as terminal:
                stop_stress(terminal)
        except Exception:
            pass


def _open_terminal() -> Terminal:
    """Open a fresh SSH session to the DUT using the standard OSFV variables.
    A new session is opened per keyword call so it survives the DUT reboots
    that happen between profile gathers."""
    built_in = BuiltIn()
    host = built_in.get_variable_value("${DEVICE_IP}")
    user = built_in.get_variable_value("${DEVICE_OS_USERNAME}") or "root"
    password = built_in.get_variable_value("${DEVICE_OS_PASSWORD}")
    assert host, "DEVICE_IP variable must be defined"
    return Terminal(host=host, user=user, password=password, sudo_password=password)
