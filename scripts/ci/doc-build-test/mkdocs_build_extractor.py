# SPDX-FileCopyrightText: 2026 Amey Pawar <ameyap007aaa@gmail.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Tab-aware extractor for Dasharo MkDocs "building manual" pages.

The Dasharo build documentation (``docs.dasharo.com``) is written for MkDocs
Material.  A ``building-manual.md`` page is not a linear script - it is a
*decision tree* built out of ``pymdownx.tabbed`` content tabs, admonitions and
fenced code blocks.  A single page typically encodes several mutually exclusive
branches at once, for example::

    === "Dasharo (UEFI)"
        ...
        === "PRO Z690-A (WIFI) DDR4"
            ./build.sh z690a_ddr4
        === "PRO Z690-A (WIFI)"
            ./build.sh z690a_ddr5
    === "Dasharo (coreboot + Heads)"
        ...

Off-the-shelf "runnable docs" tools (``codedown``, ``doc-detective``,
``tuttest``) extract *every* fenced block on the page and run them in order.
On a page like the one above that concatenates incompatible branches -
``./build.sh z690a_ddr4`` and ``./build.sh z690a_ddr5`` and the Heads build -
into a single script.  (Branch concatenation is one failure mode.  A separate
and equally important one, capturing the exact host dependencies a build needs
from a fresh OS, is out of scope for this module; see the README.)

This module instead resolves a *single path* through the tree.  Given a
selection of tab labels (firmware type, device, package manager, ...) it emits
the ordered shell commands for that one build, the artifact(s) the prose says
will be produced, and any admonition caveats attached to the chosen path.  Tab
resolution mirrors MkDocs' own ``content.tabs.link`` semantics: tabs that share
a title are the *same* choice, so selecting a device once applies it to every
tab group that offers it.

The module is pure standard library so it runs in CI with no extra
dependencies and never touches the network.
"""

from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass, field
from typing import Callable, Iterator, Optional

# Fenced-code languages we treat as executable build steps.
SHELL_LANGS = {"bash", "sh", "shell", "console"}

# Placeholders the docs use for the release version / revision.
VERSION_PLACEHOLDERS = ("X.Y.Z", "VERSION")
REVISION_PLACEHOLDER = "REVISION"

# Inline-code spans ending in .rom that prose points at as the build output.
_ROM_RE = re.compile(r"`([^`]*?\.rom)`")
_ARTIFACT_CUES = (
    "resulting",
    "placed",
    "produce",
    "produced",
    "will be",
    "binary",
    "image",
    "output",
)

_TAB_RE = re.compile(r'^===\s+(?:"([^"]*)"|\'([^\']*)\')\s*$')
_ADMONITION_RE = re.compile(
    r"^(?P<marker>!!!|\?\?\?\+?|\?\?\?)\s+(?P<kind>[\w-]+)"
    r'(?:\s+"(?P<title>[^"]*)")?\s*$'
)
_FENCE_RE = re.compile(r"^(?P<ticks>`{3,}|~{3,})(?P<info>.*)$")


# --------------------------------------------------------------------------- #
# Block tree
# --------------------------------------------------------------------------- #
@dataclass
class CodeBlock:
    lang: str
    code: str
    line: int


@dataclass
class Prose:
    text: str
    line: int


@dataclass
class Admonition:
    kind: str
    title: str
    children: list = field(default_factory=list)


@dataclass
class Tab:
    title: str
    children: list = field(default_factory=list)
    line: int = 0


@dataclass
class TabGroup:
    tabs: list = field(default_factory=list)

    @property
    def titles(self) -> list:
        return [t.title for t in self.tabs]

    @property
    def title_key(self) -> tuple:
        """Identity of the choice this group offers (order-independent).

        MkDocs links tabs that share a title, so two groups presenting the
        same set of titles represent the same decision.
        """
        return tuple(sorted(t.title for t in self.tabs))


def _indent(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def _is_blank(line: str) -> bool:
    return line.strip() == ""


def _parse_lang(info: str) -> str:
    """Extract the language from a fence info string.

    Handles plain (```` ```bash ````), title (```` ```bash title="x" ````) and
    MkDocs attribute-list (```` ```{.bash .no-copy} ````) forms.
    """
    info = info.strip()
    if not info:
        return ""
    if info.startswith("{"):
        m = re.search(r"\.([\w-]+)", info)
        return m.group(1).lower() if m else ""
    return info.split()[0].lower()


class _Parser:
    """Indentation-aware recursive-descent parser for MkDocs Material blocks."""

    def __init__(self, text: str) -> None:
        self.lines = text.expandtabs(4).splitlines()
        self.i = 0

    def parse(self) -> list:
        return self._sequence(0)

    def _sequence(self, min_indent: int) -> list:
        nodes: list = []
        prose: list = []
        prose_line = 0

        def flush_prose() -> None:
            nonlocal prose, prose_line
            if prose:
                nodes.append(Prose("\n".join(prose), prose_line))
                prose = []

        while self.i < len(self.lines):
            line = self.lines[self.i]
            if _is_blank(line):
                self.i += 1
                continue
            indent = _indent(line)
            if indent < min_indent:
                break
            stripped = line.strip()

            fence = _FENCE_RE.match(stripped)
            if fence:
                flush_prose()
                nodes.append(self._code_block(indent, fence))
                continue

            tab = _TAB_RE.match(stripped)
            if tab:
                flush_prose()
                nodes.append(self._tab_group(indent))
                continue

            adm = _ADMONITION_RE.match(stripped)
            if adm:
                flush_prose()
                nodes.append(self._admonition(indent, adm))
                continue

            if not prose:
                prose_line = self.i + 1
            prose.append(stripped)
            self.i += 1

        flush_prose()
        return nodes

    def _code_block(self, indent: int, fence) -> CodeBlock:
        ticks = fence.group("ticks")
        lang = _parse_lang(fence.group("info"))
        start = self.i + 1
        body: list = []
        self.i += 1
        close = "`" if ticks[0] == "`" else "~"
        while self.i < len(self.lines):
            line = self.lines[self.i]
            s = line.strip()
            if s.startswith(close * len(ticks)) and set(s) <= {close}:
                self.i += 1
                break
            # Dedent by the fence indent; keep deeper indentation intact.
            body.append(line[indent:] if len(line) >= indent else line.lstrip(" "))
            self.i += 1
        return CodeBlock(lang=lang, code="\n".join(body), line=start)

    def _tab_group(self, indent: int) -> TabGroup:
        group = TabGroup()
        while self.i < len(self.lines):
            # Skip blanks between sibling tabs.
            while self.i < len(self.lines) and _is_blank(self.lines[self.i]):
                self.i += 1
            if self.i >= len(self.lines):
                break
            line = self.lines[self.i]
            if _indent(line) != indent:
                break
            m = _TAB_RE.match(line.strip())
            if not m:
                break
            title = m.group(1) if m.group(1) is not None else m.group(2)
            tab_line = self.i + 1
            self.i += 1
            children = self._sequence(indent + 1)
            group.tabs.append(Tab(title=title, children=children, line=tab_line))
        return group

    def _admonition(self, indent: int, adm) -> Admonition:
        self.i += 1
        children = self._sequence(indent + 1)
        return Admonition(
            kind=adm.group("kind"),
            title=adm.group("title") or "",
            children=children,
        )


def parse(text: str) -> list:
    """Parse MkDocs Material markdown into a block tree."""
    return _Parser(text).parse()


# --------------------------------------------------------------------------- #
# Path resolution
# --------------------------------------------------------------------------- #
class AmbiguousSelection(Exception):
    """Raised when a tab group cannot be resolved from the given selection."""

    def __init__(self, options: list) -> None:
        self.options = options
        super().__init__(
            "ambiguous build path; unresolved choice between: "
            + ", ".join(repr(o) for o in options)
        )


@dataclass
class Recipe:
    """One fully resolved single-path build."""

    selections: list = field(default_factory=list)
    commands: list = field(default_factory=list)
    artifacts: list = field(default_factory=list)
    caveats: list = field(default_factory=list)


def _norm(label: str) -> str:
    return " ".join(label.lower().split())


def _label_matches(title: str, wanted) -> bool:
    nt = _norm(title)
    return any(_norm(w) == nt for w in wanted)


def _collect_artifacts(text: str) -> list:
    lowered = text.lower()
    if not any(cue in lowered for cue in _ARTIFACT_CUES):
        return []
    return _ROM_RE.findall(text)


def _walk(
    nodes: list,
    idx: int,
    chosen: dict,
    select: Optional[list],
    state: Recipe,
) -> Iterator[Recipe]:
    if idx >= len(nodes):
        yield state
        return

    node = nodes[idx]

    if isinstance(node, TabGroup):
        key = node.title_key
        picked = _pick_tabs(node, chosen, select)
        for tab in picked:
            branch_chosen = chosen
            branch_state = state
            if key not in chosen:
                branch_chosen = dict(chosen)
                branch_chosen[key] = tab.title
                branch_state = _clone(state)
                branch_state.selections = state.selections + [tab.title]
            for sub in _walk(tab.children, 0, branch_chosen, select, branch_state):
                yield from _walk(nodes, idx + 1, branch_chosen, select, sub)
        return

    next_state = _absorb(node, state)
    yield from _walk(nodes, idx + 1, chosen, select, next_state)


def _pick_tabs(group: TabGroup, chosen: dict, select: Optional[list]) -> list:
    key = group.title_key
    # A linked group already decided earlier on this path follows that choice.
    if key in chosen:
        return [t for t in group.tabs if t.title == chosen[key]]
    if select is None:
        # Enumeration mode: branch over every tab.
        return list(group.tabs)
    matches = [t for t in group.tabs if _label_matches(t.title, select)]
    if len(matches) >= 1:
        return matches[:1]
    if len(group.tabs) == 1:
        return list(group.tabs)
    raise AmbiguousSelection(group.titles)


def _absorb(node, state: Recipe) -> Recipe:
    if isinstance(node, CodeBlock):
        # Only fences explicitly tagged with a shell language are build steps.
        # Unlabeled fences are sample output / file listings, not commands.
        if node.lang in SHELL_LANGS:
            new = _clone(state)
            for cmd in _split_commands(node.code):
                new.commands.append(cmd)
            return new
        return state
    if isinstance(node, Prose):
        arts = _collect_artifacts(node.text)
        if arts:
            new = _clone(state)
            new.artifacts = state.artifacts + arts
            return new
        return state
    if isinstance(node, Admonition):
        new = _clone(state)
        label = node.title or node.kind
        new.caveats = state.caveats + [label]
        # Admonition bodies can carry code and artifacts on the path too.
        for child in node.children:
            new = _absorb(child, new)
        return new
    return state


def _split_commands(code: str) -> list:
    """Split a fenced block into individual commands.

    Blank lines and comment-only lines are dropped; continuation lines ending
    in a backslash are joined so multi-line ``docker run`` invocations stay a
    single command.
    """
    commands: list = []
    buffer: list = []
    for raw in code.splitlines():
        line = raw.rstrip()
        if not line.strip():
            continue
        if line.lstrip().startswith("#"):
            continue
        buffer.append(line)
        if line.endswith("\\"):
            continue
        commands.append("\n".join(buffer))
        buffer = []
    if buffer:
        commands.append("\n".join(buffer))
    return commands


def _clone(state: Recipe) -> Recipe:
    return Recipe(
        selections=list(state.selections),
        commands=list(state.commands),
        artifacts=list(state.artifacts),
        caveats=list(state.caveats),
    )


def iter_recipes(nodes: list, select: Optional[list] = None) -> Iterator[Recipe]:
    """Yield resolved build recipes.

    With ``select=None`` every leaf path in the tree is yielded (enumeration).
    With a list of tab labels, a single deterministic path is resolved; an
    :class:`AmbiguousSelection` is raised if a required choice is missing.
    """
    yield from _walk(nodes, 0, {}, select, Recipe())


def _leftover_placeholders(commands: list) -> set:
    joined = "\n".join(commands)
    return {t for t in (*VERSION_PLACEHOLDERS, REVISION_PLACEHOLDER) if t in joined}


def resolve(
    text: str,
    select: list,
    version: Optional[str] = None,
    revision: Optional[str] = None,
) -> Recipe:
    """Resolve exactly one build recipe for a selection, with substitutions.

    Raises :class:`AmbiguousSelection` if the selection does not pin a single
    path, and ``ValueError`` if a version/revision placeholder is left
    unresolved after substitution (e.g. ``--version`` given without the
    ``--revision`` a ``git clone -b REVISION`` step needs).
    """
    nodes = parse(text)
    recipes = list(iter_recipes(nodes, select=select))
    if not recipes:
        raise ValueError("no build path found in document")
    if len(recipes) > 1:
        raise AmbiguousSelection(sorted({" / ".join(r.selections) for r in recipes}))
    recipe = recipes[0]
    if version is not None or revision is not None:
        recipe.commands = [substitute(c, version, revision) for c in recipe.commands]
        recipe.artifacts = [substitute(a, version, revision) for a in recipe.artifacts]
        leftover = _leftover_placeholders(recipe.commands)
        if leftover:
            raise ValueError(
                "unresolved placeholder(s) after substitution: "
                + ", ".join(sorted(leftover))
                + " (pass --version and/or --revision)"
            )
    return recipe


def list_targets(text: str) -> list:
    """Enumerate every build target (leaf path) described by the document."""
    return list(iter_recipes(parse(text), select=None))


def substitute(value: str, version: Optional[str], revision: Optional[str]) -> str:
    """Replace version / revision placeholders in a command or artifact."""
    out = value
    if revision is not None:
        out = out.replace(REVISION_PLACEHOLDER, revision)
    if version is not None:
        for token in VERSION_PLACEHOLDERS:
            out = out.replace(token, version)
    return out


# --------------------------------------------------------------------------- #
# Runnable script + reproducibility verdict
# --------------------------------------------------------------------------- #
def to_script(recipe: Recipe) -> str:
    """Render a recipe as a standalone, fail-fast shell script."""
    header = [
        "#!/usr/bin/env bash",
        "# Generated from Dasharo build documentation by doc_build_test.",
        "# Selection: " + " / ".join(recipe.selections),
        "set -euo pipefail",
        "",
    ]
    if recipe.artifacts:
        header.append("# Expected artifact(s): " + ", ".join(recipe.artifacts))
        header.append("")
    return "\n".join(header + recipe.commands) + "\n"


# Verdicts returned by :func:`verify`.
IDENTICAL = "IDENTICAL"
DIFFERS = "DIFFERS"


@dataclass
class VerifyResult:
    """Outcome of comparing a built binary to a published release."""

    verdict: str  # IDENTICAL | DIFFERS
    romscope_report: str = ""


def sha256_file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def verify(
    built: str,
    published: str,
    romscope_runner: Optional[Callable[[str, str], str]] = None,
) -> VerifyResult:
    """Compare a locally built binary against a published release.

    ``sha256`` equality yields ``IDENTICAL``.  Any other result is ``DIFFERS``,
    which does *not* by itself mean the build is wrong: a legitimately
    reproducible Dasharo build is not byte-identical to the release (the release
    is Vboot-signed, and both carry version strings and build metadata a local
    build will not match).  Deciding whether a ``DIFFERS`` result is
    *functionally* reproducible needs ``romscope compare`` and human reading of
    its report (see romscope's "Interpreting results": string / compression /
    program-data differences).  This function therefore surfaces romscope's raw
    output rather than inventing a pass/fail verdict from it.
    """
    if sha256_file(built) == sha256_file(published):
        return VerifyResult(IDENTICAL)
    report = ""
    if romscope_runner is not None:
        report = romscope_runner(published, built)
    return VerifyResult(DIFFERS, report)


# --------------------------------------------------------------------------- #
# Documentation diagnostics
# --------------------------------------------------------------------------- #
_VERSION_CONDITION_RE = re.compile(
    r"\bfor\s+v?\d+(?:\.\d+)*\s+and\s+(?:older|newer)\b", re.IGNORECASE
)
_BUILD_INVOCATION_RE = re.compile(r"(?:^|\s)\./build\.sh\b")


@dataclass
class Diagnostic:
    """A machine-detected weakness that makes a manual hard to test."""

    kind: str
    detail: str


def _iter_prose(nodes: list) -> Iterator[Prose]:
    for node in nodes:
        if isinstance(node, Prose):
            yield node
        elif isinstance(node, Admonition):
            yield from _iter_prose(node.children)
        elif isinstance(node, TabGroup):
            for tab in node.tabs:
                yield from _iter_prose(tab.children)


def _diagnose_labels(nodes: list, found: list, seen: set) -> None:
    """Flag device labels that differ between build steps at the same level.

    Two tab groups in the same scope with different title sets, where one
    title is a prefix of another, cannot be linked by MkDocs - a reader has to
    guess which checkout tab pairs with which build tab.
    """
    groups = [n for n in nodes if isinstance(n, TabGroup)]
    for i, group_a in enumerate(groups):
        for group_b in groups[i + 1 :]:
            if group_a.title_key == group_b.title_key:
                continue
            for title_a in group_a.titles:
                for title_b in group_b.titles:
                    norm_a, norm_b = _norm(title_a), _norm(title_b)
                    if norm_a == norm_b:
                        continue
                    short, long = sorted((norm_a, norm_b), key=len)
                    if len(short) >= 6 and long.startswith(short + " "):
                        pair = (short, long)
                        if pair not in seen:
                            seen.add(pair)
                            found.append(
                                Diagnostic(
                                    "inconsistent-tab-labels",
                                    f"'{title_a}' vs '{title_b}'",
                                )
                            )
    for node in nodes:
        if isinstance(node, TabGroup):
            for tab in node.tabs:
                _diagnose_labels(tab.children, found, seen)
        elif isinstance(node, Admonition):
            _diagnose_labels(node.children, found, seen)


def diagnose(text: str) -> list:
    """Report machine-detectable weaknesses in a build manual.

    The checks are deliberately conservative so that a report is actionable:

    * ``version-conditional-prose`` - a build step branches on the release
      version in prose ("For v1.1.1 and older") instead of a tab, so no single
      command can be selected mechanically for a given version.
    * ``multiple-build-commands`` - one resolved path contains more than one
      *distinct* ``./build.sh`` invocation: mutually exclusive builds, or
      several board variants, that were not split into separate tabs.
    * ``inconsistent-tab-labels`` - two build steps label the same device
      differently, so the tabs cannot be linked across steps.
    """
    nodes = parse(text)
    found: list = []

    for prose in _iter_prose(nodes):
        for line in prose.text.splitlines():
            if _VERSION_CONDITION_RE.search(line):
                found.append(Diagnostic("version-conditional-prose", line.strip()))

    for recipe in iter_recipes(nodes):
        builds = [c for c in recipe.commands if _BUILD_INVOCATION_RE.search(c)]
        distinct = list(dict.fromkeys(builds))  # order-preserving dedupe
        if len(distinct) > 1:
            found.append(
                Diagnostic(
                    "multiple-build-commands",
                    " / ".join(recipe.selections) + ": " + ", ".join(distinct),
                )
            )

    _diagnose_labels(nodes, found, set())
    return found
