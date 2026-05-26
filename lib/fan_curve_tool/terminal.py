# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import shlex

import paramiko


class Terminal:
    """Plain SSH terminal. Opens its own paramiko connection and runs each
    command in a fresh exec channel — the keyword library and the offline CLI
    both go through this class, and neither relies on Robot Framework state.

    When `sudo_password` is set and the login user is not root, every command
    is wrapped in ``sudo -S sh -c '<cmd>'`` and the password is fed to sudo
    via stdin.
    """

    def __init__(
        self,
        host: str,
        user: str = "root",
        password: str | None = None,
        port: int = 22,
        sudo_password: str | None = None,
    ):
        self._user = user
        self._sudo_password = sudo_password
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
        if self._sudo_password is not None and self._user != "root":
            wrapped = f"sudo -S -p '' sh -c {shlex.quote(cmd)}"
            stdin, stdout, _stderr = self._client.exec_command(wrapped, timeout=timeout)
            stdin.write(f"{self._sudo_password}\n")
            stdin.flush()
        else:
            _stdin, stdout, _stderr = self._client.exec_command(cmd, timeout=timeout)
        return stdout.read().decode("utf-8", errors="replace")

    def close(self) -> None:
        self._client.close()

    def __enter__(self) -> "Terminal":
        return self

    def __exit__(self, exc_type, exc, tb) -> None:
        self.close()
