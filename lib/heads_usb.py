# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Host-side test data for Heads in QEMU: USB stick images and GPG keys.

USB images are MBR disks with a single FAT partition at 1 MiB, which Heads'
mount-usb.sh picks automatically.  Everything runs without root: the
partition is formatted and filled as a separate file (mkfs.vfat, mtools) and
copied into the disk image.  Requires sfdisk, mkfs.vfat, mtools and gpg.
"""

import os
import re
import shutil
import subprocess
import tempfile

from robot.api import logger
from robot.api.deco import keyword, library

PART_OFFSET = 1024 * 1024


def _run(*cmd, **kwargs):
    logger.debug(" ".join(cmd))
    return subprocess.run(cmd, check=True, capture_output=True, text=True, **kwargs)


@library
class heads_usb:
    @keyword("Create Heads USB Image")
    def create_usb_image(self, path, *files, size_mb=64, label="HEADSTEST"):
        """Create USB disk image ``path`` with one FAT partition holding
        ``files`` (host paths, copied to the root directory)."""
        size = int(size_mb) * 1024 * 1024
        os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
        with open(path, "wb") as f:
            f.truncate(size)
        _run("sfdisk", "-q", path, input=f"start={PART_OFFSET // 512}, type=c\n")
        with tempfile.TemporaryDirectory() as tmp:
            part = os.path.join(tmp, "part.img")
            with open(part, "wb") as f:
                f.truncate(size - PART_OFFSET)
            _run("mkfs.vfat", "-n", label, part)
            for src in files:
                _run("mcopy", "-i", part, src, "::" + os.path.basename(src))
            with open(part, "rb") as src, open(path, "r+b") as dst:
                dst.seek(PART_OFFSET)
                shutil.copyfileobj(src, dst)

    def _with_partition(self, path, func):
        with tempfile.TemporaryDirectory() as tmp:
            part = os.path.join(tmp, "part.img")
            with open(path, "rb") as src, open(part, "wb") as dst:
                src.seek(PART_OFFSET)
                shutil.copyfileobj(src, dst)
            return func(part, tmp)

    @keyword("Get Heads USB Image File List")
    def list_usb_image(self, path):
        """Return the names of the files in the root of the image's partition."""

        def ls(part, _):
            out = _run("mdir", "-b", "-i", part, "::").stdout
            return [os.path.basename(l.strip()) for l in out.splitlines() if l.strip()]

        return self._with_partition(path, ls)

    @keyword("Get File From Heads USB Image")
    def get_usb_image_file(self, path, name, dest):
        """Copy ``name`` from the root of the image's partition to ``dest``."""
        self._with_partition(path, lambda part, _: _run("mcopy", "-n", "-i", part, "::" + name, dest))
        return dest

    @keyword("Get GPG Key Fingerprints From File")
    def gpg_file_fingerprints(self, path):
        """Return the fingerprints of the (primary) keys in a key file."""
        out = _run("gpg", "--batch", "--with-colons", "--show-keys", path).stdout
        fprs, primary = [], False
        for line in out.splitlines():
            fields = line.split(":")
            if fields[0] == "pub":
                primary = True
            elif fields[0] == "fpr" and primary:
                fprs.append(fields[9])
                primary = False
        return fprs

    @keyword("Generate GPG Test Key")
    def generate_gpg_key(self, workdir, uid="OSFV Heads Test <osfv-heads@example.com>"):
        """Generate a passphrase-less GPG key in ``workdir``/gnupg and export
        its public key to ``workdir``/public-key.asc.  Returns the public key
        path and the key fingerprint."""
        home = os.path.join(workdir, "gnupg")
        shutil.rmtree(home, ignore_errors=True)
        os.makedirs(home, mode=0o700)
        gpg = ("gpg", "--homedir", home, "--batch", "--pinentry-mode", "loopback", "--passphrase", "")
        _run(*gpg, "--quick-gen-key", uid, "ed25519", "sign", "never")
        out = _run(*gpg, "--with-colons", "--fingerprint", uid).stdout
        fpr = re.search(r"^fpr:+([0-9A-F]{40}):", out, re.M).group(1)
        pubkey = os.path.join(workdir, "public-key.asc")
        _run(*gpg, "--armor", "--output", pubkey, "--yes", "--export", fpr)
        return pubkey, fpr
