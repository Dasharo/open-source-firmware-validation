import json
import socket

from robot.api.deco import keyword, library


@library
class QemuMonitor:
    def __init__(self, socket_path):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.sock.connect(socket_path)
        greeting = self.sock.recv(4096)
        self.qmp_capabilities()

    def _send(self, command, **args):
        msg = {"execute": command, "arguments": args}
        self.sock.sendall(json.dumps(msg).encode())
        response = self.sock.recv(4096).decode()
        json_objects = [
            json.loads(line) for line in response.splitlines() if line.strip()
        ]
        if len(json_objects) > 1:
            return {"ack": json_objects[0], "event": json_objects[1]}
        else:
            return json_objects[0]

    @keyword
    def qmp_capabilities(self):
        return self._send("qmp_capabilities")

    @keyword
    def system_powerdown(self):
        return self._send("system_powerdown")

    @keyword
    def system_reset(self):
        return self._send("system_reset")

    @keyword
    def quit(self):
        return self._send("quit")
