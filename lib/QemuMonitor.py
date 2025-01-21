# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import os
import socket
import time

from robot.api import logger
from robot.api.deco import keyword, library


@library
class QemuMonitor:
    def __init__(self, socket_path):
        self.sock = None
        logger.info(f"QemuMonitor init")
        self.socket_path = socket_path
        if not os.path.exists(socket_path):
            raise ValueError(f"Socket path does not exist: {socket_path}")

    def _open(self):
        logger.info(f"QemuMonitor open")
        try:
            self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            self.sock.connect(self.socket_path)
            greeting = self.sock.recv(4096)
            logger.trace(f"QemuMonitor greeting: {greeting}")
        except Exception as e:
            self._close()
            raise e

    def _close(self):
        logger.info(f"QemuMonitor close")
        if self.sock:
            self.sock.close()
            self.sock = None

    def _send_cmd(self, command, **args):
        self._open()
        logger.trace(self._send("qmp_capabilities"))
        response = self._send(command, **args)
        self._close()
        if "error" in response:
            logger.error(f"Command '{command}' failed with error: {response['error']}")
            raise RuntimeError(f"QEMU monitor error response: {response['error']['desc']}")
        return response

    def _send(self, command, **args):
        msg = {"execute": command, "arguments": args}
        logger.trace(f"QemuMonitor command: {msg}")
        self.sock.sendall(json.dumps(msg).encode())
        response = self.sock.recv(4096).decode()
        logger.trace(f"QemuMonitor response: {response}")
        json_objects = [
            json.loads(line) for line in response.splitlines() if line.strip()
        ]
        if len(json_objects) > 1:
            return {"ack": json_objects[0], "event": json_objects[1]}
        else:
            return json_objects[0]

    def _check_if_block_node_exists(self, block_node):
        block_nodes = self._send_cmd("query-named-block-nodes")

        contains_node = any(
            block.get("node-name") == block_node
            for block in block_nodes.get("return", [])
        )
        return contains_node

    @keyword
    def qmp_capabilities(self):
        return self._send_cmd("qmp_capabilities")

    @keyword
    def system_powerdown(self):
        return self._send_cmd("system_powerdown")

    @keyword
    def system_reset(self):
        return self._send_cmd("system_reset")

    @keyword
    def quit(self):
        return self._send_cmd("quit")

    @keyword("Add HDD To Qemu")
    def blockdev_add(self, img_name):
        contains_mydisk = self._check_if_block_node_exists("mydisk")
        logger.trace(f"contains_mydisk: {contains_mydisk}")

        if contains_mydisk:
            blockdev_del_params = {
                "node-name": "mydisk"
            } 
            self._send_cmd("blockdev-del", **blockdev_del_params)

        blockdev_add_params = {
            "node-name": "mydisk",
            "driver": "file",
            "filename": img_name,
            "aio": "threads",
            "cache": {"direct": True, "no-flush": False},
            "read-only": True
        }
        logger.trace(self._send_cmd("blockdev-add", **blockdev_add_params))

        device_add_params = {
            "driver": "scsi-hd",
            "drive": "mydisk",
            "bus": "scsi.0",
            "id": "myhdd",
        }
        return self._send_cmd("device_add", **device_add_params)

    @keyword("Remove Drive From Qemu")
    def device_del(self):
        contains_mydisk = self._check_if_block_node_exists("file_iso")
        logger.trace(f"contains_mydisk: {contains_mydisk}")

        if contains_mydisk:
            blockdev_del_params = {
                "node-name": "mydisk"
            } 
            return self._send_cmd("blockdev-del", **blockdev_del_params)

    @keyword("Add USB To Qemu")
    def usb_add(self, img_name):
        contains_file_iso = self._check_if_block_node_exists("file_iso")
        logger.trace(f"contains_file_iso: {contains_file_iso}")

        if contains_file_iso:
            try:
                logger.trace(self._send_cmd("device_del", id="usbdisk"))
            except Exception:
                pass
            time.sleep(2)

            blockdev__del_params = {
                "node-name": "drive-iso",
            }
            try:
                logger.trace(self._send_cmd("blockdev-del", **blockdev_del_params))
            except Exception:
                pass
            time.sleep(2)

            blockdev_del_params = {
                "node-name": "file_iso",
            }
            logger.trace(self._send_cmd("blockdev-del", **blockdev_del_params))
            time.sleep(2)

        blockdev_params = {
            "node-name": "file_iso",
            "driver": "file",
            "filename": img_name,
            "auto-read-only": True,
            "discard": "unmap",
        }
        logger.trace(self._send_cmd("blockdev-add", **blockdev_params))

        drive_params = {
            "driver": "raw",
            "file": "file_iso",
            "node-name": "drive-iso",
            "read-only": True,
            "discard": "unmap",
        }
        logger.trace(self._send_cmd("blockdev-add", **drive_params))

        usb_storage_params = {
            "driver": "usb-storage",
            "id": "usbdisk",
            "drive": "drive-iso",
        }
        logger.trace(self._send_cmd("device_add", **usb_storage_params))

    def __del__(self):
        self._close()
