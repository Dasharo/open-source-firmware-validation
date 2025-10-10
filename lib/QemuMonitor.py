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
        logger.trace(response)
        self._close()
        if "error" in response:
            logger.error(f"Command '{command}' failed with error: {response['error']}")
            raise RuntimeError(
                f"QEMU monitor error response: {response['error']['desc']}"
            )
        return response

    def _send(self, command, **args):
        msg = {"execute": command, "arguments": args}
        logger.trace(f"QemuMonitor command: {msg}")
        self.sock.sendall(json.dumps(msg).encode())
        response = self.sock.recv(8192).decode()
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
    def blockdev_add(self, img_path, name="unnamed"):
        self.hdd_del(name)

        blockdev_add_params = {
            "node-name": self._hdd_nodename(name),
            "driver": "raw",
            "file": {
                "driver": "file",
                "filename": img_path,
            },
            "read-only": True,
        }
        logger.trace(self._send_cmd("blockdev-add", **blockdev_add_params))

        device_add_params = {
            "driver": "scsi-hd",
            "drive": self._hdd_nodename(name),
            "id": self._hdd_devid(name),
            "bus": "scsi.0",
        }
        return self._send_cmd("device_add", **device_add_params)

    @keyword("Remove Drive From Qemu")
    def hdd_del(self, name="unnamed"):
        contains_node = self._check_if_block_node_exists(self._hdd_nodename(name))
        logger.trace(f"contains_{self._hdd_nodename(name)}: {contains_node}")

        if contains_node:
            try:
                self._send_cmd("device_del", **{"id": self._hdd_devid(name)})
            except:
                pass
            time.sleep(2)
            try:
                self._send_cmd(
                    "blockdev-del", **{"node-name": self._hdd_nodename(name)}
                )
            except:
                pass

    @keyword("Add USB To Qemu")
    def usb_add(self, img_path, name="unnamed", read_only=True, removable=False):
        self.usb_del(name)

        blockdev_params = {
            "node-name": self._usb_file_nodename(name),  # "file_iso"
            "driver": "file",
            "filename": img_path,
            "auto-read-only": read_only,
            "discard": "unmap",
        }
        self._send_cmd("blockdev-add", **blockdev_params)

        drive_params = {
            "driver": "raw",
            "file": self._usb_file_nodename(name),
            "node-name": self._usb_nodename(name),  # "drive-iso",
            "read-only": read_only,
            "discard": "unmap",
        }
        self._send_cmd("blockdev-add", **drive_params)

        usb_storage_params = {
            "driver": "usb-storage",
            "id": self._usb_devid(name),  # "usbdisk",
            "drive": self._usb_nodename(name),
            "removable": removable,
        }
        self._send_cmd("device_add", **usb_storage_params)

        contains_file_node = self._check_if_block_node_exists(
            self._usb_file_nodename(name)
        )
        logger.trace(f"contains file node: {contains_file_node}")

    @keyword("Remove USB from Qemu")
    def usb_del(self, name="unnamed"):
        contains_file_node = self._check_if_block_node_exists(
            self._usb_file_nodename(name)
        )
        logger.trace(f"contains file node: {contains_file_node}")

        if contains_file_node:
            try:
                self._send_cmd("device_del", id=self._usb_devid(name))
            except Exception:
                pass
            time.sleep(2)

            blockdev_del_params = {
                "node-name": self._usb_nodename(name),
            }
            try:
                self._send_cmd("blockdev-del", **blockdev_del_params)
            except Exception:
                pass
            time.sleep(2)

            blockdev_del_params = {
                "node-name": self._usb_file_nodename(name),
            }
            self._send_cmd("blockdev-del", **blockdev_del_params)
            time.sleep(2)

    def _usb_file_nodename(self, name):
        return "usb_file_node_" + name

    def _usb_nodename(self, name):
        return "usb_node_" + name

    def _usb_devid(self, name):
        return "usb_devid_" + name

    def _hdd_nodename(self, name):
        return "hdd_node_" + name

    def _hdd_devid(self, name):
        return "hdd_devid_" + name

    def __del__(self):
        self._close()
