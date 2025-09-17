#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import sys

from robot.running.builder import ResourceFileBuilder

C_RESET = "\033[0m"
C_YELLOW = "\033[93m"
C_CYAN = "\033[96m"
C_GREEN = "\033[92m"
C_BLUE = "\033[94m"
C_RED = "\033[91m"

DEFAULT_FILE = os.path.abspath("platform-configs/include/default.robot")


def get_all_vars_with_resources(entry_file, skip_file=None):
    """Return {var_name: var_value} from file and its resources recursively."""
    visited = set()

    def visit(path):
        abs_path = os.path.abspath(path)
        if abs_path in visited or not os.path.exists(abs_path):
            return {}
        if skip_file and os.path.abspath(skip_file) == abs_path:
            return {}

        visited.add(abs_path)
        resource = ResourceFileBuilder().build(abs_path)
        vars_dict = {var.name: var.value for var in getattr(resource, "variables", [])}

        base_dir = os.path.dirname(abs_path)
        for imp in getattr(resource, "imports", []):
            imp_type = (
                getattr(imp, "type", None) or getattr(imp, "type_name", None) or ""
            ).lower()
            if imp_type == "resource":
                target = (
                    getattr(imp, "name", None)
                    or getattr(imp, "path", None)
                    or (getattr(imp, "args", None) or [None])[0]
                )
                if not target:
                    continue
                target = target.replace("${CURDIR}", base_dir)
                if not os.path.isabs(target):
                    target = os.path.normpath(os.path.join(base_dir, target))
                vars_dict.update(visit(target))

        return vars_dict

    return visit(entry_file)


def format_value(val):
    if isinstance(val, dict):
        lines = ["{"]
        for k, v in val.items():
            lines.append(f"  {k}: {v}")
        lines.append("}")
        return "\n".join(lines)
    return str(val)


def pretty_print(title, items):
    if not items:
        return
    print(f"\n{C_YELLOW}{'=' * 80}\n{title}\n{'=' * 80}{C_RESET}")
    for name, def_val, curr_val in items:
        status = "MISSING" if curr_val == "<missing>" else "UNCHANGED"
        color_status = C_RED if status == "MISSING" else C_BLUE
        print(f"\n{C_CYAN}--- {name} {color_status}({status}){C_RESET}")
        print(f"{C_GREEN}Default value:{C_RESET}")
        print(format_value(def_val))
    print(f"{C_YELLOW}{'=' * 80}{C_RESET}\n")


if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <target.robot>")
    sys.exit(1)

target_file = sys.argv[1]

# Load vars
default_vars = get_all_vars_with_resources(DEFAULT_FILE)
target_vars = get_all_vars_with_resources(target_file, skip_file=DEFAULT_FILE)

# Find missing/unchanged
unchanged_or_missing = []
for name, default_value in default_vars.items():
    if name not in target_vars:
        unchanged_or_missing.append((name, default_value, "<missing>"))
    elif target_vars[name] == default_value:
        unchanged_or_missing.append((name, default_value, target_vars[name]))

if unchanged_or_missing:
    pretty_print(
        "Variables still at default value (missing or unchanged)", unchanged_or_missing
    )
    sys.exit(1)
else:
    print(f"{C_GREEN}All variables are overridden with non-default values.{C_RESET}")
    sys.exit(0)
