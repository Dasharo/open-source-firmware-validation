# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import base64
import io

from PIL import Image
from robot.api import logger
from robot.api.deco import keyword


@keyword
def log_image(path, max_width=640):
    img = Image.open(path)
    if img.width > int(max_width):
        ratio = int(max_width) / img.width
        img = img.resize((int(max_width), int(img.height * ratio)), Image.LANCZOS)
    buf = io.BytesIO()
    img.save(buf, format="PNG", optimize=True)
    b64 = base64.b64encode(buf.getvalue()).decode("ascii")
    logger.info(f'<img src="data:image/png;base64,{b64}">', html=True)
