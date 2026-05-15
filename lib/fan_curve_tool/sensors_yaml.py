# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

from dataclasses import dataclass, field
from typing import Any

import yaml


@dataclass
class MeasurementSpec:
    method: str
    hwmon_path: str | None = None
    lm_sensors_sensor_name: str | None = None

    @classmethod
    def from_dict(cls, d: dict[str, Any]) -> "MeasurementSpec":
        return cls(
            method=d.get("method", "none"),
            hwmon_path=_optional(d.get("hwmon_path")),
            lm_sensors_sensor_name=_optional(d.get("lm_sensors_sensor_name")),
        )


@dataclass
class KernelModule:
    module: str
    force_id: str | None = None


@dataclass
class SensorsConfig:
    cpu_temp: MeasurementSpec
    fan_pwm: MeasurementSpec
    fan_rpm: MeasurementSpec
    modules: list[KernelModule] = field(default_factory=list)

    @classmethod
    def load(cls, path: str) -> "SensorsConfig":
        with open(path, "r") as f:
            d = yaml.safe_load(f) or {}
        modules = []
        for m in d.get("sensors_kernel_modules", []) or []:
            name = m.get("module", "none")
            if name == "none":
                continue
            modules.append(
                KernelModule(module=name, force_id=_optional(m.get("force_id")))
            )
        return cls(
            cpu_temp=MeasurementSpec.from_dict(
                d.get("cpu_temperature_measurement", {})
            ),
            fan_pwm=MeasurementSpec.from_dict(d.get("fan_pwm_measurement", {})),
            fan_rpm=MeasurementSpec.from_dict(d.get("fan_rpm_measurement", {})),
            modules=modules,
        )


def _optional(v: Any) -> str | None:
    if v is None or (isinstance(v, str) and v.strip().lower() == "none"):
        return None
    return v
