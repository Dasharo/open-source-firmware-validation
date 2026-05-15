# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# Sensor parsing now happens on the DUT via shell pipelines (mirroring
# lib/sensors/sensors.robot), so there is no Python-side parsing to unit
# test. The shell pipelines are exercised end-to-end on real hardware.
