# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

from dataclasses import dataclass

import yaml

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
        with open(path, "r") as f:
            d = yaml.safe_load(f) or {}
        profiles = {}
        # Any top-level key matching `temperature_curve_<name>` is treated
        # as a profile and <name> becomes the profile id. The
        # temperature_curve_settings key is reserved for global settings.
        for key in d:
            if not key.startswith(PROFILE_KEY_PREFIX) or key == SETTINGS_KEY:
                continue
            name = key[len(PROFILE_KEY_PREFIX) :]
            segs = []
            for s in d.get(key, []) or []:
                lo, hi = s["range"]
                ep = tuple(s.get("evaluation_pwm", (0, 0)))
                er = tuple(s.get("evaluation_rpm", (0, 0)))
                segs.append(
                    CurveSegment(
                        min_temp=float(lo),
                        max_temp=float(hi),
                        eval_pwm=(float(ep[0]), float(ep[1])),
                        eval_rpm=(float(er[0]), float(er[1])),
                        tolerance_pwm=float(s.get("tolerance_pwm", 0)),
                        tolerance_rpm=float(s.get("tolerance_rpm", 0)),
                    )
                )
            profiles[name] = segs
        return cls(settings=d.get(SETTINGS_KEY, {}) or {}, profiles=profiles)

    def reference_points(self, profile: str, mode: str, step: float = 0.5):
        """Return (temps, values) for a smooth reference overlay."""
        segs = self.profiles.get(profile, [])
        temps: list[float] = []
        values: list[float] = []
        for seg in segs:
            n = max(2, int((seg.max_temp - seg.min_temp) / step) + 1)
            for i in range(n):
                t = seg.min_temp + (seg.max_temp - seg.min_temp) * i / (n - 1)
                ev = seg.eval_pwm if mode == "pwm" else seg.eval_rpm
                v = ev[0] + (ev[1] - ev[0]) * (t - seg.min_temp) / (
                    seg.max_temp - seg.min_temp
                )
                temps.append(t)
                values.append(v)
        return temps, values
