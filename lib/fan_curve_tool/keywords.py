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
from lib.fan_curve_tool.terminal import Terminal


@library(scope="GLOBAL", auto_keywords=False)
class FanCurveTool:
    """Robot Framework keywords for the fan curve measurement tool."""

    def __init__(self):
        self._logs_dir = ""
        self._sensors_cfg: SensorsConfig | None = None
        self._curve_cfg: CurveConfig | None = None
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

        self._cache = Cache.open(
            logs_dir=self._logs_dir,
            run_id=run_id,
            platform=os.environ.get("CONFIG", socket.gethostname()),
            fan_mode=self._fan_mode,
            resume=bool(resume),
        )
        with _open_terminal() as t:
            stop_stress(t)

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
        self._config.apply_overrides(
            verbose=verbose,
            quick=quick,
            max_runtime=max_runtime,
            target_per_bin=target_per_bin,
        )
        with _open_terminal() as t:
            prepare_sensors(t, self._sensors_cfg)
            block = gather(
                profile=profile,
                terminal=t,
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
        try:
            with _open_terminal() as t:
                stop_stress(t)
        except Exception:
            # Best-effort during teardown — a dead DUT here shouldn't mask
            # the real failure.
            pass

    @staticmethod
    def _auto_run_id() -> str:
        host = os.environ.get("CONFIG", "unknown-config")
        return f"{host}-{time.strftime('%Y%m%dT%H%M%S')}"


def _platform_configs_dir() -> str:
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.normpath(os.path.join(here, "..", "..", "platform-configs"))


def _open_terminal() -> Terminal:
    """Open a dedicated SSH session to the DUT.

    Reads the same Robot variables the rest of OSFV uses for SSH logins, so
    the test suite doesn't need to pass connection details through Robot
    arguments. The dedicated session keeps fan-curve traffic off the Robot
    console terminal — no `Execute Command In Terminal` noise in the log.
    """
    from robot.libraries.BuiltIn import BuiltIn

    bi = BuiltIn()
    host = bi.get_variable_value("${DEVICE_IP}")
    user = bi.get_variable_value("${DEVICE_OS_USERNAME}") or "root"
    password = bi.get_variable_value("${DEVICE_OS_PASSWORD}")
    assert host, "DEVICE_IP variable must be defined"
    return Terminal(host=host, user=user, password=password, sudo_password=password)
