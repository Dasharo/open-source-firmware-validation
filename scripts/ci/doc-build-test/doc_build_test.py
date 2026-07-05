#!/usr/bin/env python

# SPDX-FileCopyrightText: 2026 Amey Pawar <ameyap007aaa@gmail.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Command-line front end for the Dasharo documentation build test.

Turns a MkDocs building manual into concrete, single-path build recipes and
verifies a locally built binary against a published release.  See the module
docstring in ``mkdocs_build_extractor`` and the directory ``README.md`` for the
design rationale.

Subcommands
-----------
list     Enumerate every build target (leaf path) a document describes.
extract  Print the resolved commands, artifacts and caveats for one selection.
script   Emit a standalone, fail-fast shell script for one selection.
verify   Compare a built binary against a published release (sha256 + romscope).
"""

import argparse
import subprocess
import sys

import mkdocs_build_extractor as ext


def _read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as handle:
        return handle.read()


def _cmd_list(args: argparse.Namespace) -> int:
    targets = ext.list_targets(_read(args.doc))
    if not targets:
        print("no build targets found", file=sys.stderr)
        return 1
    for target in targets:
        print(" / ".join(target.selections) or "(single path)")
        if target.artifacts:
            print("    artifacts: " + ", ".join(target.artifacts))
    print(f"\n{len(targets)} target(s)")
    return 0


def _resolve(args: argparse.Namespace) -> ext.Recipe:
    return ext.resolve(
        _read(args.doc),
        select=args.select or [],
        version=args.version,
        revision=args.revision,
    )


def _cmd_extract(args: argparse.Namespace) -> int:
    try:
        recipe = _resolve(args)
    except ext.AmbiguousSelection as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    print("# selection: " + " / ".join(recipe.selections))
    if recipe.caveats:
        print("# caveats: " + ", ".join(recipe.caveats))
    if recipe.artifacts:
        print("# artifacts: " + ", ".join(recipe.artifacts))
    print()
    for command in recipe.commands:
        print(command)
    return 0


def _cmd_script(args: argparse.Namespace) -> int:
    try:
        recipe = _resolve(args)
    except ext.AmbiguousSelection as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    script = ext.to_script(recipe)
    if args.output:
        with open(args.output, "w", encoding="utf-8") as handle:
            handle.write(script)
    else:
        sys.stdout.write(script)
    return 0


def _cmd_verify(args: argparse.Namespace) -> int:
    runner = None
    if args.romscope:

        def runner(published: str, built: str) -> str:
            result = subprocess.run(
                [args.romscope, "compare", published, built],
                capture_output=True,
                text=True,
                check=False,
            )
            return result.stdout + result.stderr

    verdict = ext.verify(args.built, args.published, romscope_runner=runner)
    print(verdict)
    return 0 if verdict != ext.DIFFERS else 1


def _cmd_diagnose(args: argparse.Namespace) -> int:
    diagnostics = ext.diagnose(_read(args.doc))
    if not diagnostics:
        print("no documentation issues detected")
        return 0
    for diagnostic in diagnostics:
        print(f"{diagnostic.kind}: {diagnostic.detail}")
    print(f"\n{len(diagnostics)} issue(s)")
    return 1


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="doc_build_test", description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    p_list = sub.add_parser("list", help="enumerate build targets")
    p_list.add_argument("doc", help="path to a building-manual.md")
    p_list.set_defaults(func=_cmd_list)

    def add_select(p: argparse.ArgumentParser) -> None:
        p.add_argument("doc", help="path to a building-manual.md")
        p.add_argument(
            "--select",
            action="append",
            metavar="LABEL",
            help="tab label to choose (repeatable)",
        )
        p.add_argument("--version", help="value for X.Y.Z / VERSION placeholders")
        p.add_argument("--revision", help="value for the REVISION placeholder")

    p_extract = sub.add_parser("extract", help="print a resolved recipe")
    add_select(p_extract)
    p_extract.set_defaults(func=_cmd_extract)

    p_script = sub.add_parser("script", help="emit a runnable build script")
    add_select(p_script)
    p_script.add_argument("-o", "--output", help="write script to this file")
    p_script.set_defaults(func=_cmd_script)

    p_verify = sub.add_parser("verify", help="compare built vs published binary")
    p_verify.add_argument("--built", required=True, help="locally built .rom")
    p_verify.add_argument("--published", required=True, help="published .rom")
    p_verify.add_argument(
        "--romscope",
        help="path to a romscope binary for signature-aware comparison",
    )
    p_verify.set_defaults(func=_cmd_verify)

    p_diagnose = sub.add_parser(
        "diagnose", help="report documentation issues that block automated testing"
    )
    p_diagnose.add_argument("doc", help="path to a building-manual.md")
    p_diagnose.set_defaults(func=_cmd_diagnose)
    return parser


def main(argv=None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
