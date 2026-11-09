# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Write the criteria by implementation matrix of DRTM runs.

Reads the results of one or more runs and the expectations of each run's
platform, firmware and kernel, and writes the matrix of the DRTM criteria
against the runs, as Markdown and HTML, with a drill-down to the checks of
each criterion. docs/drtm-report.md describes the report.

A run is a directory or an output.xml. The Source of a run is the one whose
loader reads its directory, for an output.xml the one whose suites have most
of its tests, or the one ,source=NAME sets. After the path, ,platform=NAME,
,firmware=NAME, ,kernel=NAME and ,label=TEXT set what the run does not say,
or override it. Only the runs given appear in the report.
"""

import argparse
import datetime
import html
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable

from robot.api import ExecutionResult

from . import expectations as exp

OVERRIDES = ("platform", "firmware", "kernel", "label", "source")
CRITERION_ROW = re.compile(r"^\|\s*(C\d\d)\s*\|\s*(.+?)\s*\|\s*(L\d)\s*\|", re.M)
# The worst verdict of a cell's tests is the cell's.
SEVERITY = ["expected", "improved", "unknown", "regression"]
MESSAGE_MAX = 400


class ReportError(Exception):
    """A run the report cannot read."""


@dataclass
class RunInfo:
    """What a Source's loader reads from a run: the result files and what
    the run records about itself. A value it leaves empty comes from the
    overrides or the Source's defaults."""

    outputs: list
    platform: str = ""
    firmware: str = ""
    kernel: str = ""
    evidence: str = ""
    date: str = ""
    revision: str = ""
    warnings: list = field(default_factory=list)


@dataclass
class Source:
    """One tree of DRTM suites.

    ``root`` is the tree, ``name`` how the report shows it.
    ``criteria_doc`` holds the criteria table and the Bindings table of the
    tree's evidence paths, ``suite_dirs`` the suites whose tags map tests to
    criteria, ``expectations_dir`` the expectation files and
    references.yaml. ``evidences`` are the evidence paths of its runs.
    ``load_dir(path, overrides)`` returns the RunInfo of a run directory, or
    None when the directory is not one of its runs; it raises ReportError for
    a run of its own it cannot read. ``defaults`` gives the platform,
    firmware or kernel of a run that does not record it, as
    defaults(key, info) returning a value or None.
    """

    name: str
    root: Path
    criteria_doc: Path
    suite_dirs: list
    expectations_dir: Path
    evidences: tuple
    load_dir: Callable
    defaults: Callable = lambda key, info: None
    _tests: dict = None

    @property
    def references(self):
        return self.expectations_dir / "references.yaml"

    def tests(self):
        """{test ID: set of tags} of the Source's suites, read once."""
        if self._tests is None:
            self._tests = exp.load_tests(self.suite_dirs)
        return self._tests

    def expectation_files(self):
        return sorted(
            p
            for p in self.expectations_dir.glob("*.yaml")
            if p.name != "references.yaml"
        )

    def rel(self, path):
        try:
            return str(Path(path).resolve().relative_to(self.root.resolve()))
        except ValueError:
            return str(path)

    def suites_text(self):
        return ", ".join(self.rel(d) + "/" for d in self.suite_dirs)


@dataclass
class Result:
    test_id: str
    name: str
    status: str
    message: str
    entry: dict | None
    verdict: str


@dataclass
class Run:
    source: Source
    path: Path
    outputs: list
    label: str
    platform: str
    firmware: str
    kernel: str
    evidence: str
    date: str
    revision: str
    expectation_file: Path | None
    meta: dict | None = None
    entries: dict = field(default_factory=dict)
    results: dict = field(default_factory=dict)
    warnings: list = field(default_factory=list)


@dataclass
class Cell:
    status: str | None
    source: str
    verdict: str | None
    refs: list
    results: list


def read_record(path):
    """Returns the "key: value" lines of a run record file, the first value of
    each key, or {} when the file does not exist."""
    record = {}
    if path.is_file():
        for line in path.read_text(errors="replace").splitlines():
            key, sep, value = line.partition(": ")
            if sep and key not in record:
                record[key] = value.strip()
    return record


def load_criteria(doc):
    """Returns [(ID, criterion, level)] from the criteria table of ``doc``."""
    criteria = CRITERION_ROW.findall(Path(doc).read_text())
    if not criteria:
        raise ReportError(f"no criteria table in {doc}")
    return criteria


def load_not_applicable(doc):
    """Returns {(ID, evidence path)} of the criteria the Bindings table of
    ``doc`` marks N/A on a path: a cell that starts with "N/A", in a column
    whose header is the path in backticks, such as `tpm`."""
    bindings = Path(doc).read_text().partition("\n## Bindings\n")[2]
    rows = [line for line in bindings.splitlines() if line.startswith("|")]
    if not rows:
        return set()
    header = [cell.strip() for cell in rows[0].strip("|").split("|")]
    paths = {
        i: m.group(1)
        for i, h in enumerate(header)
        if (m := re.fullmatch(r"`(\w+)`", h))
    }
    not_applicable = set()
    for row in rows[2:]:
        cells = [cell.strip() for cell in row.strip("|").split("|")]
        if not cells or not re.fullmatch(r"C\d\d", cells[0]):
            continue
        for i, path in paths.items():
            if i < len(cells) and cells[i].startswith("N/A"):
                not_applicable.add((cells[0], path))
    return not_applicable


def run_time(date):
    """2026_10_30_11_44_39 as 2026-10-30 11:44, and a run index _N as #N."""
    match = re.fullmatch(r"(\d{4})_(\d\d)_(\d\d)_(\d\d)_(\d\d)_\d\d(?:_(\d+))?", date)
    if not match:
        return date
    year, month, day, hour, minute, index = match.groups()
    return f"{year}-{month}-{day} {hour}:{minute}" + (f" #{index}" if index else "")


def parse_spec(spec):
    """Splits PATH,key=value,... into the path and the overrides."""
    path, *items = spec.split(",")
    overrides = {}
    for item in items:
        key, sep, value = item.partition("=")
        if not sep or key not in OVERRIDES:
            raise ReportError(
                f"{spec}: {item!r} is not one of {', '.join(k + '=' for k in OVERRIDES)}"
            )
        overrides[key] = value
    return Path(path), overrides


def test_ids(outputs):
    return [
        test.name.split()[0]
        for test in ExecutionResult(*map(str, outputs)).suite.all_tests
        if exp.TEST_ID.match(test.name.split()[0])
    ]


def find_source(path, overrides, sources):
    """Returns the Source of the run at ``path`` and its RunInfo."""
    if overrides.get("source"):
        sources = [s for s in sources if s.name == overrides["source"]]
        if not sources:
            raise ReportError(f"{path}: no source {overrides['source']!r}")
    if path.is_dir():
        # A loader can read a directory of another Source's runs, such as an
        # OSFV merged_<date>, so the run's tests decide.
        for source in sources:
            info = source.load_dir(path, overrides)
            if info is not None and set(test_ids(info.outputs)) & set(source.tests()):
                return source, info
        raise ReportError(
            f"{path}: not a run directory of {', '.join(s.name for s in sources)}"
        )
    if path.suffix == ".xml" and path.is_file():
        ids = set(test_ids([path]))
        source = max(sources, key=lambda s: len(ids & set(s.tests())))
        if not ids & set(source.tests()):
            raise ReportError(
                f"{path}: none of its tests is in the suites of {', '.join(s.name for s in sources)}"
            )
        return source, RunInfo(outputs=[path])
    raise ReportError(f"{path}: neither a run directory nor an output.xml")


def load_run(spec, sources):
    """Reads one run, its results and its expectations."""
    path, overrides = parse_spec(spec)
    source, info = find_source(path, overrides, sources)
    values = {}
    for key in ("platform", "kernel", "firmware"):
        values[key] = (
            overrides.get(key) or getattr(info, key) or source.defaults(key, info)
        )
        if key == "platform":
            info.platform = values[key]
        if not values[key]:
            raise ReportError(
                f"{path}: the run does not record the {key}, add ,{key}=NAME"
            )
    platform, firmware, kernel = (
        values["platform"],
        values["firmware"],
        values["kernel"],
    )

    run = Run(
        source=source,
        path=path,
        outputs=info.outputs,
        label=overrides.get("label")
        or f"{platform} {firmware} {kernel} {run_time(info.date)}".strip(),
        platform=platform,
        firmware=firmware,
        kernel=kernel,
        evidence=info.evidence,
        date=info.date,
        revision=info.revision,
        expectation_file=None,
        warnings=list(info.warnings),
    )
    tests = source.tests()
    references = exp.load_references(source.references)
    expectation_file = source.expectations_dir / f"{platform}-{firmware}-{kernel}.yaml"
    if expectation_file.is_file():
        try:
            meta, entries = exp.load_expectations(
                expectation_file,
                references,
                tests,
                source.evidences,
                source.suites_text(),
            )
        except exp.ExpectationError as err:
            raise ReportError(str(err)) from err
        run.expectation_file = expectation_file
        run.meta, run.entries = meta, entries
        if run.evidence and run.evidence != meta["evidence"]:
            run.warnings.append(
                f"the run's evidence is {run.evidence}, {expectation_file.name} expects {meta['evidence']}"
            )
        run.evidence = run.evidence or meta["evidence"]
    else:
        run.warnings.append(
            f"no expectation file {source.rel(expectation_file)}, every result is unknown"
        )
        if not run.evidence and len(source.evidences) == 1:
            run.evidence = source.evidences[0]

    left_out = []
    for test in ExecutionResult(*map(str, info.outputs)).suite.all_tests:
        test_id = test.name.split()[0]
        if not exp.TEST_ID.match(test_id):
            continue
        # A run from before its runner left out the other evidence path has
        # the tests of that path, which a run of this path does not.
        if run.evidence and exp.other_paths(tests.get(test_id, ()), run.evidence):
            left_out.append(test_id)
            continue
        entry = expectation_of(run, test_id)
        run.results[test_id] = Result(
            test_id=test_id,
            name=test.name,
            status=test.status,
            message=test.message or "",
            entry=entry,
            verdict=exp.compare(entry, test.status),
        )
    if left_out:
        run.warnings.append(
            f"left out {len(left_out)} test(s) of another evidence path, which a {run.evidence} run does not run: {' '.join(left_out)}"
        )
    if not run.results:
        raise ReportError(
            f"{path}: no DRTM tests in {', '.join(map(str, info.outputs))}"
        )
    return run


def derived_status(results):
    """The status of a criterion from its checks alone: failed when one
    failed, passed when one passed, skipped otherwise."""
    statuses = {result.status for result in results}
    if "FAIL" in statuses:
        return "FAIL"
    if "PASS" in statuses:
        return "PASS"
    return "SKIP"


def worst(verdicts):
    verdicts = [v for v in verdicts if v]
    return max(verdicts, key=SEVERITY.index) if verdicts else None


def criterion_cell(run, criterion, not_applicable):
    """The cell of ``criterion`` for ``run``: the status the run's checks of
    the criterion give, the worst verdict of those checks, N/A when the run
    has none and the Bindings table of its Source marks the criterion N/A on
    the run's path, and not checked otherwise."""
    tag = f"criterion:{criterion}"
    tests = run.source.tests()
    checks = [
        run.results[t] for t in sorted(tests) if tag in tests[t] and t in run.results
    ]
    if not checks:
        if (criterion, run.evidence) in not_applicable[run.source.name]:
            return Cell("N/A", "binding", None, [], [])
        return Cell(None, "none", None, [], [])
    refs = []
    for check in checks:
        for ref in (check.entry or {}).get("refs") or []:
            if ref not in refs and check.status != "PASS":
                refs.append(ref)
    return Cell(
        derived_status(checks),
        "checks",
        worst([c.verdict for c in checks]),
        refs,
        checks,
    )


def expectation_of(run, test_id):
    """The expectation entry of ``test_id`` for ``run``, as compare() takes
    it: unknown when the run has no expectation file."""
    if run.meta is None:
        return {"result": "unknown", "refs": [], "basis": None, "note": None}
    return exp.expectation(run.meta, run.entries, test_id)


def short(message):
    message = " ".join(message.split())
    return message if len(message) <= MESSAGE_MAX else message[: MESSAGE_MAX - 1] + "…"


def expected_text(entry):
    if entry is None:
        return "pass"
    return entry["result"]


def revision_text(run):
    return f"{run.source.name} {run.revision or '?'}"


def intro(sources):
    """The paragraph under the title, as plain text."""
    where = "; ".join(
        f"{s.name}: {s.rel(s.criteria_doc)} and {s.rel(s.expectations_dir)}/"
        for s in sources
    )
    return (
        f"The criteria and their bindings, and the expectations, are those of {where}. "
        "A cell is the status the run's checks of the criterion give: failed when one "
        "failed, passed when one passed. N/A is a criterion the run's evidence path "
        "cannot meet, from the Bindings table of the run's criteria document."
    )


def used_references(runs, references):
    """[(ID, reference)] of every reference an expectation of the runs has."""
    used = {}
    for run in runs:
        for result in run.results.values():
            for ref in (result.entry or {}).get("refs") or []:
                used.setdefault(ref, references[run.source.name].get(ref, {}))
    return sorted(used.items())


# Markdown


def md_escape(text):
    return text.replace("|", "\\|").replace("\n", " ")


def md_cell(cell):
    if cell.status is None:
        return "not checked"
    text = cell.status
    if cell.verdict not in (None, "expected"):
        text += (
            f" **{cell.verdict.upper()}**"
            if cell.verdict == "regression"
            else f" {cell.verdict}"
        )
    if cell.refs:
        text += " " + ", ".join(f"[{ref}](#{ref})" for ref in cell.refs)
    return text


def write_markdown(path, report):
    runs, criteria, cells = report["runs"], report["criteria"], report["cells"]
    lines = [
        "# DRTM criteria report",
        "",
        f"Generated {report['generated']} from {len(runs)} run(s). {intro(report['sources'])}",
        "",
        "## Runs",
        "",
        "| Run | Platform | Firmware | Kernel | Evidence | Revision | Expectations | Results |",
        "| --- | -------- | -------- | ------ | -------- | -------- | ------------ | ------- |",
    ]
    for run in runs:
        exp_name = run.expectation_file.name if run.expectation_file else "none"
        lines.append(
            f"| {md_escape(run.label)} | {run.platform} | {run.firmware} | {run.kernel} | "
            f"{run.evidence or '?'} | {revision_text(run)} | {exp_name} | {', '.join(f'`{o}`' for o in run.outputs)} |"
        )
    for warning in report["warnings"]:
        lines.append(f"\nWarning: {md_escape(warning)}")
    for run in runs:
        for warning in run.warnings:
            lines.append(f"\nWarning, {md_escape(run.label)}: {md_escape(warning)}")
    lines += ["", "## Regressions", ""]
    if report["regressions"]:
        lines += [
            "| Run | Test | Result | Expected | Message |",
            "| --- | ---- | ------ | -------- | ------- |",
        ]
        for run, result in report["regressions"]:
            lines.append(
                f"| {md_escape(run.label)} | {result.test_id} | {result.status} | "
                f"{expected_text(result.entry)} | {md_escape(short(result.message))} |"
            )
    else:
        lines.append("None: every result is the expected one, improved or unknown.")
    lines += ["", "## Matrix", ""]
    lines.append(
        "| Criterion | Level | "
        + " | ".join(md_escape(run.label) for run in runs)
        + " |"
    )
    lines.append("| --------- | ----- | " + " | ".join("---" for _ in runs) + " |")
    for cid, text, level in criteria:
        row = [f"{cid} {md_escape(text)}", level]
        row += [md_cell(cells[cid][i]) for i in range(len(runs))]
        lines.append("| " + " | ".join(row) + " |")
    lines += ["", "## Drill-down", ""]
    for cid, text, level in criteria:
        lines += [f"### {cid}: {text}", ""]
        for i, run in enumerate(runs):
            cell = cells[cid][i]
            lines.append(f"{md_escape(run.label)}: {md_cell(cell)}")
            lines.append("")
            if cell.results:
                lines += md_results(cell.results)
                lines.append("")
    lines += ["## Checks without a criterion", ""]
    for i, run in enumerate(runs):
        if report["other"][i]:
            lines += (
                [f"{md_escape(run.label)}:", ""] + md_results(report["other"][i]) + [""]
            )
    lines += ["## Known deviations", ""]
    for ref, info in report["used"]:
        lines.append(f'<a id="{ref}"></a>')
        lines.append(f"- **{ref}**: {md_escape(info.get('title', '?'))}.")
        if info.get("requirement"):
            lines.append(f"  Requirement: {md_escape(info['requirement'])}.")
        if info.get("link"):
            lines.append(f"  <{info['link']}>")
    path.write_text("\n".join(lines) + "\n")


def md_results(results):
    lines = [
        "| Test | Result | Expected | Verdict | Message |",
        "| ---- | ------ | -------- | ------- | ------- |",
    ]
    for result in results:
        lines.append(
            f"| {md_escape(result.name)} | {result.status} | {expected_text(result.entry)} | "
            f"{result.verdict} | {md_escape(short(result.message))} |"
        )
    return lines


# HTML

CSS = """
:root { --bg: #ffffff; --fg: #1d1d1f; --muted: #6e6e73; --line: #d2d2d7;
  --pass: #1a7f37; --fail: #cf222e; --skip: #9a6700; --none: #6e6e73;
  --reg-bg: #ffebe9; --head: #f6f8fa; }
@media (prefers-color-scheme: dark) {
  :root { --bg: #0d1117; --fg: #e6edf3; --muted: #8b949e; --line: #30363d;
    --pass: #3fb950; --fail: #f85149; --skip: #d29922; --none: #8b949e;
    --reg-bg: #3d1214; --head: #161b22; } }
body { background: var(--bg); color: var(--fg); margin: 0 16px 32px;
  font: 14px/1.45 system-ui, sans-serif; }
h1, h2, h3 { margin: 1.2em 0 0.4em; }
table { border-collapse: collapse; margin: 0.4em 0 1em; }
.wrap { overflow-x: auto; }
th, td { border: 1px solid var(--line); padding: 4px 8px; vertical-align: top;
  text-align: left; }
th { background: var(--head); }
.PASS { color: var(--pass); font-weight: 600; }
.FAIL { color: var(--fail); font-weight: 600; }
.SKIP { color: var(--skip); font-weight: 600; }
.none { color: var(--none); }
.regression { background: var(--reg-bg); }
.verdict { font-size: 12px; color: var(--muted); }
.regression .verdict { color: var(--fail); font-weight: 700; }
.msg { font-size: 12px; max-width: 60ch; word-break: break-word; }
summary { cursor: pointer; margin: 0.3em 0; }
code { font-size: 12px; }
"""


def e(text):
    return html.escape(str(text))


def html_cell(cell):
    if cell.status is None:
        return '<td class="none">not checked</td>'
    if cell.status == "N/A":
        return '<td class="none">N/A</td>'
    cls = "regression" if cell.verdict == "regression" else ""
    parts = [f'<span class="{cell.status}">{cell.status}</span>']
    if cell.verdict != "expected":
        parts.append(f'<span class="verdict">{e(cell.verdict)}</span>')
    if cell.refs:
        parts.append(
            '<span class="verdict">'
            + ", ".join(f'<a href="#{e(ref)}">{e(ref)}</a>' for ref in cell.refs)
            + "</span>"
        )
    return f'<td class="{cls}">' + " ".join(parts) + "</td>"


def html_results(results):
    rows = [
        "<table><tr><th>Test</th><th>Result</th><th>Expected</th><th>Verdict</th><th>Message</th></tr>"
    ]
    for r in results:
        cls = ' class="regression"' if r.verdict == "regression" else ""
        rows.append(
            f'<tr{cls}><td>{e(r.name)}</td><td class="{r.status}">{r.status}</td>'
            f"<td>{e(expected_text(r.entry))}</td><td>{e(r.verdict)}</td>"
            f'<td class="msg">{e(short(r.message))}</td></tr>'
        )
    rows.append("</table>")
    return "\n".join(rows)


def write_html(path, report):
    runs, criteria, cells = report["runs"], report["criteria"], report["cells"]
    out = [
        "<!doctype html>",
        '<html lang="en"><head><meta charset="utf-8">',
        '<meta name="viewport" content="width=device-width, initial-scale=1">',
        "<title>DRTM criteria report</title>",
        f"<style>{CSS}</style></head><body>",
        "<h1>DRTM criteria report</h1>",
        f"<p>Generated {e(report['generated'])} from {len(runs)} run(s). {e(intro(report['sources']))}</p>",
        "<h2>Runs</h2>",
        '<div class="wrap"><table><tr><th>Run</th><th>Platform</th><th>Firmware</th><th>Kernel</th>'
        "<th>Evidence</th><th>Revision</th><th>Expectations</th><th>Results</th></tr>",
    ]
    for run in runs:
        exp_name = run.expectation_file.name if run.expectation_file else "none"
        out.append(
            f"<tr><td>{e(run.label)}</td><td>{e(run.platform)}</td><td>{e(run.firmware)}</td>"
            f"<td>{e(run.kernel)}</td><td>{e(run.evidence or '?')}</td><td>{e(revision_text(run))}</td>"
            f"<td>{e(exp_name)}</td><td>{'<br>'.join(f'<code>{e(o)}</code>' for o in run.outputs)}</td></tr>"
        )
    out.append("</table></div>")
    for warning in report["warnings"]:
        out.append(f"<p><strong>Warning</strong>: {e(warning)}</p>")
    for run in runs:
        for warning in run.warnings:
            out.append(f"<p><strong>Warning</strong>, {e(run.label)}: {e(warning)}</p>")
    out.append("<h2>Regressions</h2>")
    if report["regressions"]:
        out.append(
            '<div class="wrap"><table><tr><th>Run</th><th>Test</th><th>Result</th><th>Expected</th>'
            "<th>Message</th></tr>"
        )
        for run, r in report["regressions"]:
            out.append(
                f'<tr class="regression"><td>{e(run.label)}</td><td>{e(r.test_id)}</td>'
                f'<td class="{r.status}">{r.status}</td><td>{e(expected_text(r.entry))}</td>'
                f'<td class="msg">{e(short(r.message))}</td></tr>'
            )
        out.append("</table></div>")
    else:
        out.append(
            "<p>None: every result is the expected one, improved or unknown.</p>"
        )
    out.append("<h2>Matrix</h2>")
    out.append(
        '<div class="wrap"><table><tr><th>Criterion</th><th>Level</th>'
        + "".join(f"<th>{e(run.label)}</th>" for run in runs)
        + "</tr>"
    )
    for cid, text, level in criteria:
        out.append(
            f'<tr><td><a href="#{cid}">{cid}</a> {e(text)}</td><td>{level}</td>'
            + "".join(html_cell(cells[cid][i]) for i in range(len(runs)))
            + "</tr>"
        )
    out.append("</table></div>")
    out.append("<h2>Drill-down</h2>")
    for cid, text, level in criteria:
        out.append(f'<h3 id="{cid}">{cid}: {e(text)}</h3>')
        for i, run in enumerate(runs):
            cell = cells[cid][i]
            label = re.sub(r"<[^>]+>", "", html_cell(cell))
            if not cell.results:
                out.append(f"<p>{e(run.label)}: {e(label)}</p>")
                continue
            out.append(f"<details><summary>{e(run.label)}: {e(label)}</summary>")
            out.append(
                '<div class="wrap">' + html_results(cell.results) + "</div></details>"
            )
    out.append("<h2>Checks without a criterion</h2>")
    for i, run in enumerate(runs):
        if report["other"][i]:
            out.append(f"<details><summary>{e(run.label)}</summary>")
            out.append(
                '<div class="wrap">'
                + html_results(report["other"][i])
                + "</div></details>"
            )
    out.append("<h2>Known deviations</h2><ul>")
    for ref, info in report["used"]:
        link = info.get("link")
        out.append(
            f'<li id="{e(ref)}"><strong>{e(ref)}</strong>: {e(info.get("title", "?"))}.'
            + (
                f" Requirement: {e(info['requirement'])}."
                if info.get("requirement")
                else ""
            )
            + (
                f' <a href="{e(link)}">{e(link)}</a>'
                if link and "://" in link
                else (f" <code>{e(link)}</code>" if link else "")
            )
            + "</li>"
        )
    out.append("</ul></body></html>")
    path.write_text("\n".join(out) + "\n")


def criteria_warnings(sources, criteria):
    """Warnings for a Source whose criteria table differs from the first
    Source's, which the report uses."""
    warnings = []
    ids = [(cid, level) for cid, _, level in criteria]
    for source in sources[1:]:
        other = [(cid, level) for cid, _, level in load_criteria(source.criteria_doc)]
        if other != ids:
            warnings.append(
                f"the criteria of {source.name} ({source.rel(source.criteria_doc)}) differ in their IDs "
                f"or levels from those of {sources[0].name}, which the report shows"
            )
    return warnings


def main(argv, sources, default_out):
    """Writes the report of the runs in ``argv`` of ``sources``. The first
    Source's criteria table gives the rows."""
    parser = argparse.ArgumentParser(
        description=__doc__.split("\n\n")[0],
        epilog=__doc__.split("\n\n", 1)[1]
        + "\nSources: "
        + ", ".join(f"{s.name} ({s.suites_text()})" for s in sources),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("runs", nargs="+", metavar="RUN[,key=value...]")
    parser.add_argument(
        "--out",
        type=Path,
        default=default_out,
        help=f"directory for report.md and report.html (default: {default_out})",
    )
    args = parser.parse_args(argv)

    try:
        criteria = load_criteria(sources[0].criteria_doc)
        warnings = criteria_warnings(sources, criteria)
        not_applicable = {s.name: load_not_applicable(s.criteria_doc) for s in sources}
        references = {s.name: exp.load_references(s.references) for s in sources}
        runs = [load_run(spec, sources) for spec in args.runs]
    except (ReportError, exp.ExpectationError, OSError) as err:
        print(f"Error: {err}", file=sys.stderr)
        return 2

    cells = {
        cid: [criterion_cell(run, cid, not_applicable) for run in runs]
        for cid, _, _ in criteria
    }
    other = []
    for run in runs:
        tests = run.source.tests()
        other.append(
            [
                r
                for t, r in sorted(run.results.items())
                if not any(tag.startswith("criterion:") for tag in tests.get(t, ()))
            ]
        )
    regressions = [
        (run, r)
        for run in runs
        for r in run.results.values()
        if r.verdict == "regression"
    ]
    report = {
        "sources": sorted(
            {run.source.name: run.source for run in runs}.values(), key=sources.index
        )
        or sources[:1],
        "runs": runs,
        "criteria": criteria,
        "cells": cells,
        "other": other,
        "regressions": regressions,
        "used": used_references(runs, references),
        "warnings": warnings,
        "generated": datetime.datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %Z"),
    }
    args.out.mkdir(parents=True, exist_ok=True)
    md_path, html_path = args.out / "report.md", args.out / "report.html"
    write_markdown(md_path, report)
    write_html(html_path, report)

    for warning in warnings:
        print(f"Warning: {warning}", file=sys.stderr)
    for run in runs:
        for warning in run.warnings:
            print(f"Warning, {run.label}: {warning}", file=sys.stderr)
    print(f"{len(regressions)} regression(s) in {len(runs)} run(s)")
    for run, r in regressions:
        print(
            f"  {run.label}: {r.test_id} {r.status}, expected {expected_text(r.entry)}"
        )
    print(f"Wrote {md_path} and {html_path}")
    return 0
