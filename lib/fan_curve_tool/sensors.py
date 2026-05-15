# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import re
from dataclasses import dataclass

from .sensors_yaml import MeasurementSpec, SensorsConfig
from .terminal import Terminal

_TEMP_RE = re.compile(r"Package id 0:.*?\+(\d+(?:\.\d+)?)")
_FAN_RPM_RE = re.compile(r"^\s*CPU \d+\s*:\s*(\d+) RPM", re.MULTILINE)
_FAN_PWM_RE = re.compile(r"^\s*pwm\d+\s*:\s*(\d+)", re.MULTILINE)
_S76_FAN_RE = re.compile(r"CPU fan\s*:?\s*(\d+)")


@dataclass
class CpuTempReader:
    spec: MeasurementSpec

    def read(self, t: Terminal) -> float:
        if self.spec.method == "lm-sensors":
            out = t.run("sensors 2>/dev/null")
            m = _TEMP_RE.search(out)
            if not m:
                raise ValueError(
                    f"no `Package id 0:` line in sensors output:\n{out[:600]!r}"
                )
            return float(m.group(1))
        if self.spec.method == "hwmon":
            out = t.run(f"cat {self.spec.hwmon_path}").strip()
            return int(out) / 1000.0
        raise ValueError(f"unsupported cpu temp method: {self.spec.method!r}")


@dataclass
class FanReader:
    spec: MeasurementSpec
    mode: str

    def read(self, t: Terminal) -> float:
        if self.spec.method == "hwmon":
            return float(t.run(f"cat {self.spec.hwmon_path}").strip())
        if self.spec.method == "lm-sensors":
            chip = self.spec.lm_sensors_sensor_name or ""
            out = t.run(f"sensors {chip} 2>/dev/null")
            regex = _FAN_PWM_RE if self.mode == "pwm" else _FAN_RPM_RE
            m = regex.search(out)
            if not m:
                raise ValueError(
                    f"no fan {self.mode} line in sensors {chip!r} output:\n{out[:600]!r}"
                )
            return float(m.group(1))
        if self.spec.method == "system76-acpi":
            out = t.run("sensors 2>/dev/null")
            m = _S76_FAN_RE.search(out)
            if not m:
                raise ValueError(f"no `CPU fan` line in sensors output:\n{out[:600]!r}")
            return float(m.group(1))
        raise ValueError(f"unsupported fan method: {self.spec.method!r}")


def pick_fan_mode(cfg: SensorsConfig) -> tuple[str, MeasurementSpec]:
    if cfg.fan_pwm.method != "none":
        return "pwm", cfg.fan_pwm
    if cfg.fan_rpm.method != "none":
        return "rpm", cfg.fan_rpm
    raise ValueError("no fan measurement method configured")


def prepare_sensors(t: Terminal, cfg: SensorsConfig) -> None:
    for mod in cfg.modules:
        force = f" force_id={mod.force_id}" if mod.force_id else ""
        t.run(f"modprobe {mod.module}{force}")
    if any(s.method == "lm-sensors" for s in (cfg.cpu_temp, cfg.fan_pwm, cfg.fan_rpm)):
        t.run("sensors-detect --auto")
