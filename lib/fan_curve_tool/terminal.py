# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

from abc import ABC, abstractmethod


class Terminal(ABC):
    @abstractmethod
    def run(self, cmd: str, timeout: float = 30.0) -> str: ...


class RobotTerminal(Terminal):
    """Runs DUT commands by delegating to Robot's `Execute Command In Terminal`,
    which reuses whatever SSH/Telnet session the test suite has already opened."""

    def run(self, cmd: str, timeout: float = 30.0) -> str:
        from robot.libraries.BuiltIn import BuiltIn

        return BuiltIn().run_keyword(
            "Execute Command In Terminal", cmd, f"{int(timeout)}"
        )


class SSHTerminal(Terminal):
    """Plain paramiko terminal for the offline CLI (no Robot Framework)."""

    def __init__(
        self, host: str, user: str = "root", port: int = 22, password: str | None = None
    ):
        import paramiko

        self._client = paramiko.SSHClient()
        self._client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self._client.connect(
            hostname=host,
            username=user,
            port=port,
            password=password,
            allow_agent=False,
            look_for_keys=False,
        )

    def run(self, cmd: str, timeout: float = 30.0) -> str:
        _stdin, stdout, _stderr = self._client.exec_command(cmd, timeout=timeout)
        return stdout.read().decode("utf-8", errors="replace")

    def close(self) -> None:
        self._client.close()
