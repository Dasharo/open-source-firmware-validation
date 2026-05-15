# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import os
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from typing import Any


@dataclass
class Sample:
    ts: str
    temp: float
    fan: float
    mode: str
    workers: int
    load: int
    direction: str
    settle_dt: float
    stable: bool

    @classmethod
    def create(
        cls,
        temp: float,
        fan: float,
        mode: str,
        workers: int,
        cpu_load: int,
        direction: str,
        settle_dt: float,
        stable: bool,
    ) -> "Sample":
        return cls(
            ts=datetime.now(timezone.utc).isoformat(timespec="seconds"),
            temp=float(temp),
            fan=float(fan),
            mode=mode,
            workers=int(workers),
            load=int(cpu_load),
            direction=direction,
            settle_dt=float(settle_dt),
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
    def from_dict(cls, d: dict[str, Any]) -> "ProfileBlock":
        fields = {k: v for k, v in d.items() if k in cls.__dataclass_fields__}
        fields["samples"] = [Sample(**s) for s in d.get("samples", [])]
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
            profiles = _load_profiles(path)
        return cls(
            path=path,
            run_id=run_id,
            platform=platform,
            fan_mode=fan_mode,
            profiles=profiles,
        )

    @classmethod
    def load_existing(cls, path: str, run_id_fallback: str = "") -> "Cache":
        with open(path, "r") as f:
            raw = json.load(f)
        return cls(
            path=path,
            run_id=raw.get("run_id", run_id_fallback),
            platform=raw.get("platform", "unknown"),
            fan_mode=raw.get("fan_mode", "rpm"),
            profiles={
                k: ProfileBlock.from_dict(v) for k, v in raw.get("profiles", {}).items()
            },
        )

    def save(self) -> None:
        body = {
            "run_id": self.run_id,
            "platform": self.platform,
            "fan_mode": self.fan_mode,
            "profiles": {k: asdict(v) for k, v in self.profiles.items()},
        }
        with open(self.path, "w") as f:
            json.dump(body, f, indent=2)


def _load_profiles(path: str) -> dict[str, ProfileBlock]:
    with open(path, "r") as f:
        raw = json.load(f)
    return {k: ProfileBlock.from_dict(v) for k, v in raw.get("profiles", {}).items()}
