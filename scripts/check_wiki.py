#!/usr/bin/env python3
"""원장 검증기.

`docs/decisions/SPEC.md` §2 의 검사 서른일곱을 돈다. 실패시키는 것 스물아홉과 보고만 하는 것 다섯과
아크 종료 시에만 도는 것 셋이다. 검사마다 단계 id 를 선언하고 그것을 출력에 낸다.

    python3 scripts/check_wiki.py [--root PATH] [--arc-close ARC] [--quiet]

`--root` 는 원장과 부속 파일을 읽을 뿌리를 바꾼다. 음성 대조가 사본에 위반을 주입한 뒤 그
사본을 뿌리로 지목하므로, 이 선택지가 없으면 주입이 원장을 건드리게 된다.

`--arc-close` 는 아크 종료 시에만 도는 검사 20 과 21 과 29 를 그 아크에 대해 돌린다. 그것을 주지
않으면 셋은 수행되지 않았음을 출력에 내고 판정에 들지 않는다.

**이 검증기를 고쳐 통과시키지 않는다.** 검사가 실패하면 그 실패가 산출물이다(SPEC §4).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import NamedTuple

REGISTERS = ("decisions", "deferred", "retirements", "rejected")

# 검사 14 의 대응표. SPEC §3.2 가 든다. `meta` 는 층에 갇히지 않으므로 건너뛴다.
LAYER_DIR = {
    "glossary": "CrisisFramework/Glossary",
    "definition": "CrisisFramework/Definition",
    "accounting": "CrisisFramework/Accounting",
    "dynamics": "CrisisFramework/Dynamics",
    "observation": "CrisisFramework/Observation",
}

TIERS = ("invariant", "policy", "finding")
REOPEN_KINDS = ("artifact", "extraction", "arc_phase", "blocking")

# 검사 23 의 규율 ID 계열. SPEC §2.1 이 정본이며 `E` 는 추출 기록의 번호라 뺀다.
# `PH-R` 이 한 계열이고 맨 앞에 두어야 `PH-R2` 가 `R-2` 로 잘리지 않는다.
RULE_SERIES = ("PH-R", "P", "A", "C", "L", "D", "T", "R", "N", "V", "W", "Q", "B", "O",
               "G", "S", "F", "J", "K")
# `PH-R` 만 번호를 하이픈 없이 붙인다(`PH-R2`). 그 계열을 하이픈을 요구하는 꼴로 읽으면
# 토큰이 한 건도 잡히지 않으면서 검사가 통과하므로, 두 꼴을 갈라 받고 그 계열을 먼저 본다.
RULE_TOKEN = re.compile(
    r"(?<![0-9A-Za-z-])(?:PH-R(\d+)|("
    + "|".join(x for x in RULE_SERIES if x != "PH-R")
    + r")-(\d+))(?![0-9A-Za-z-])")

# 검사 24 의 유니버스. SPEC §2.1 이 상주 문서 다섯과 Lean 주석을 든다.
RESIDENT_DOCS = (
    "CLAUDE.md",
    "docs/baseline.md",
    "docs/decisions/SPEC.md",
    "docs/reading-queue-v0.md",
    "docs/bundle-inventory-v0.md",
)
# 기록하는 자리는 유니버스 밖이다. 그 문면은 그 시점의 앎을 담으므로 낡은 지목이 정당하다.
HISTORY_PATHS = ("BUILD_LOG.md", "docs/phases/", "docs/extractions/",
                 "docs/arcs.json 의 patches 배열")
# `arcs.json` 은 `patches` 배열만 빠지고 나머지는 유니버스에 든다. 그 파일의 `note` 가 규율을
# 지목하므로 파일 전체를 빼면 그 지목이 검사되지 않는다(SPEC §2.1).
ARCS_DOC = "docs/arcs.json"
# 폐기 지목의 면제 선언. 문서 머리에 이 형으로 한 줄을 두고 면제되는 ID 를 열거한다.
DECLARE_LINE = re.compile(r"^\s*\*\*폐기 지목:\*\*(.*)$")

ID_FORM = re.compile(r"^CF-(\d+)$")
CF_TOKEN = re.compile(r"(?<![0-9A-Za-z-])CF-(\d+)(?![0-9A-Za-z-])")
DD_TOKEN = re.compile(r"--\s*DD:\s*(\S+)")
STEP_CALL = re.compile(r"^\s*step\s+['\"]?([^\s'\"]+)")
EXTRACTION_NO = re.compile(r"^E-(\d+)$")
ARTIFACT_PATH = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._/-]*$")
# 검사 25 의 유니버스. 최상위 선언만 보며 생성자와 필드는 자기를 담은 선언의 표지를 딛는다.
# abbrev 도 최상위 선언이다. 투영이 쓰이는 족을 abbrev 로 두므로(CF-641) 빼면 표지 누락이 그물 밖에
# 남는다(CF-669).
TOP_DECL = re.compile(r"^(def|theorem|inductive|structure|abbrev)\s+([^\s({\[:]+)")
# 검사 33·34 가 선언의 완전 이름을 세울 때 쓰는 이름공간. `end` 는 여는 쪽과 같은 점 이름을 든다.
NAMESPACE = re.compile(r"^namespace\s+(\S+)")
NAMESPACE_END = re.compile(r"^end\s+(\S+)")
# docstring 블록과 그 문단과 문단 머리말. 머리말은 문단 선두의 `**` 와 `**` 사이다(SPEC §2.1).
DOC_BLOCK = re.compile(r"/--(.*?)-/", re.S)
PARA_SPLIT = re.compile(r"\n\s*\n")
PARA_HEAD = re.compile(r"^\*\*(.+?)\*\*", re.S)


class DocDecl(NamedTuple):
    """최상위 선언 하나와 그 docstring 의 문단. 검사 33 과 34 가 이 하나를 함께 쓴다."""

    full: str              # 이름공간을 붙인 완전 이름
    rel: str               # 리포 뿌리를 기준으로 한 경로
    line: int              # 그 선언이 선 줄
    no: int                # `DD:` 표지가 가리키는 번호. `CF-<n>` 형식이 아니면 -1
    paras: list[str]       # docstring 을 빈 줄로 가른 문단


class Report:
    """검사 하나의 결과. `step` 이 선언된 단계 id 이고 출력의 머리에 그대로 난다."""

    def __init__(self, number: str, step: str, title: str, kind: str):
        self.number = number
        self.step = step
        self.title = title
        self.kind = kind          # fail · report · arc_close
        self.violations: list[str] = []
        self.notes: list[str] = []
        self.ran = True

    def bad(self, msg: str) -> None:
        self.violations.append(msg)

    def note(self, msg: str) -> None:
        self.notes.append(msg)

    @property
    def failed(self) -> bool:
        return self.kind != "report" and self.ran and bool(self.violations)

    def emit(self, quiet: bool) -> None:
        if not self.ran:
            verdict, colour = "SKIP", "\033[33m"
        elif self.kind == "report":
            verdict, colour = "REPORT", "\033[36m"
        elif self.violations:
            verdict, colour = "FAIL", "\033[31m"
        else:
            verdict, colour = "OK", "\033[32m"
        print(f"[check:{self.step}] {colour}{verdict}\033[0m  검사 {self.number} — {self.title}")
        for line in self.violations:
            print(f"    · {line}")
        if not quiet:
            for line in self.notes:
                print(f"    - {line}")


def _lean_comments(src: str) -> str:
    """Lean 소스에서 주석만 남기고 코드를 지운다. `/- -/` 는 중첩되고 `--` 는 줄 끝까지다."""
    out, i, depth, n = [], 0, 0, len(src)
    while i < n:
        if src.startswith("/-", i):
            depth += 1; i += 2; out.append("  "); continue
        if src.startswith("-/", i) and depth:
            depth -= 1; i += 2; out.append("  "); continue
        if depth:
            out.append(src[i]); i += 1; continue
        if src.startswith("--", i):
            j = src.find("\n", i)
            out.append(src[i:n if j < 0 else j]); i = n if j < 0 else j; continue
        out.append("\n" if src[i] == "\n" else " "); i += 1
    return "".join(out)


class Ledger:
    """원장과 그 부속 파일을 한 뿌리에서 읽는다."""

    def __init__(self, root: Path):
        self.root = root
        self.reg: dict[str, list[dict]] = {}
        self.container_keys: dict[str, list[str]] = {}
        for name in REGISTERS:
            path = root / "docs" / "decisions" / f"{name}.json"
            doc = json.loads(path.read_text(encoding="utf-8"))
            self.container_keys[name] = list(doc.keys())
            self.reg[name] = doc[name]

        self.entries: list[tuple[str, dict]] = [
            (name, e) for name in REGISTERS for e in self.reg[name]]
        self.by_id: dict = {}
        for _, e in self.entries:
            self.by_id.setdefault(e.get("id"), e)

        arcs_doc = json.loads((root / "docs" / "arcs.json").read_text(encoding="utf-8"))
        self.arcs = {a["name"]: a for a in arcs_doc.get("arcs", [])}
        self.patches = arcs_doc.get("patches", [])

        # 폐기된 id. 살아 있음은 저장하지 않고 유도한다(SPEC §0.2).
        self.dead = {e["target"] for e in self.reg["retirements"] if e.get("target")}
        # 폐기된 항목 → 그것을 폐기한 레코드의 id. 검사 23 의 승인 경로가 이것을 요구한다.
        self.retired_by: dict = {}
        for e in self.reg["retirements"]:
            if e.get("target"):
                self.retired_by.setdefault(e["target"], e.get("id"))
        # 폐기된 항목 → 그것을 폐기한 레코드가 선 날. 검사 23 의 날짜 면제가 이 값을 요구한다.
        self.retired_on: dict = {}
        for e in self.reg["retirements"]:
            if e.get("target"):
                self.retired_on.setdefault(
                    e["target"], (e.get("origin") or {}).get("date"))

        # 규율 ID → 그것을 드는 항목의 원장 id
        self.name_owner: dict = {}
        for _, e in self.entries:
            for n in e.get("names", []) or []:
                self.name_owner.setdefault(n, e["id"])

        self.verify_steps = self._read_verify_steps()
        self._doc_decls: list[DocDecl] | None = None
        self.lean_files = sorted((root / "CrisisFramework").rglob("*.lean")) \
            if (root / "CrisisFramework").is_dir() else []
        self.doc_files = sorted((root / "docs").rglob("*.md")) \
            if (root / "docs").is_dir() else []

    def _read_verify_steps(self) -> list[str]:
        """`verify.sh` 가 선언한 단계 id. `step <id> "<제목>"` 호출의 첫 인자다."""
        path = self.root / "scripts" / "verify.sh"
        if not path.is_file():
            return []
        out = []
        for line in path.read_text(encoding="utf-8").splitlines():
            m = STEP_CALL.match(line)
            if m and m.group(1):
                out.append(m.group(1))
        return out

    def rule_scan_targets(self) -> list[tuple[str, str]]:
        """검사 24 가 훑을 (표시 경로, 훑을 텍스트) 목록.

        상주 문서는 전문을 훑고 Lean 파일은 주석만 훑는다. `arcs.json` 은 `patches` 배열을 뺀
        나머지를 훑는다. 식별자는 영어라 규율 ID 꼴이 코드에
        서지 않으나, SPEC 이 유니버스를 「Lean 주석」으로 들므로 그대로 좁힌다.
        """
        out = []
        for rel in RESIDENT_DOCS:
            f = self.root / rel
            if f.is_file():
                out.append((rel, f.read_text(encoding="utf-8")))
        f = self.root / ARCS_DOC
        if f.is_file():
            doc = json.loads(f.read_text(encoding="utf-8"))
            doc.pop("patches", None)
            out.append((ARCS_DOC, json.dumps(doc, ensure_ascii=False, indent=1)))
        for f in self.lean_files:
            out.append((str(f.relative_to(self.root)), _lean_comments(f.read_text(encoding="utf-8"))))
        return out

    def doc_decls(self) -> list[DocDecl]:
        """최상위 선언마다 그 `DD:` 표지의 번호와 docstring 의 문단을 낸다.

        **검사 33 과 34 가 이 하나를 부른다.** 전사하면 한쪽을 고칠 때 다른 쪽이 조용히 낡고,
        둘이 다른 수를 내는 것을 어느 검사도 잡지 않는다. 검사 31 이 검사 16 과 발화 판정을
        나누어 쓴 것과 같은 형이다(SPEC §2.1).

        표지를 집는 규칙은 검사 25 와 같다. 앞 선언과 이 선언 사이에 선 표지가 이 선언의
        것이며, 그 구간의 마지막 `/-- -/` 블록이 이 선언의 docstring 이다. 블록이 둘 이상인
        것은 생성자와 필드가 자기 docstring 을 갖기 때문이고, 그것들은 선언 줄보다 뒤에 서므로
        구간에 들지 않는다.
        """
        if self._doc_decls is not None:
            return self._doc_decls
        marks = self.dd_markers()
        out: list[DocDecl] = []
        for f in self.lean_files:
            lines = f.read_text(encoding="utf-8").splitlines()
            mk = sorted((ln, tgt) for g, ln, tgt in marks if g == f)
            rel = str(f.relative_to(self.root))
            stack: list[str] = []
            prev = 0
            for i, line in enumerate(lines, 1):
                m = NAMESPACE.match(line)
                if m:
                    stack.append(m.group(1))
                    continue
                m = NAMESPACE_END.match(line)
                if m:
                    if stack and stack[-1] == m.group(1):
                        stack.pop()
                    continue
                d = TOP_DECL.match(line)
                if not d:
                    continue
                cand = [t for ln, t in mk if prev < ln < i]
                m = ID_FORM.match(cand[-1]) if cand else None
                blocks = DOC_BLOCK.findall("\n".join(lines[prev:i - 1]))
                paras = [p.strip() for p in PARA_SPLIT.split(blocks[-1].strip())
                         if p.strip()] if blocks else []
                out.append(DocDecl(".".join(stack + [d.group(2)]), rel, i,
                                   int(m.group(1)) if m else -1, paras))
                prev = i
        self._doc_decls = out
        return out

    def dd_markers(self) -> list[tuple[Path, int, str]]:
        """Lean **줄 주석**의 `-- DD:<id>` 표지 전량.

        R-6 의 문면이 `-- DD:<id>` 이므로 줄 주석이 규율에 박혀 있고, `/- -/` 블록 주석 안의
        문면은 표지가 아니다(SPEC §2.1). 블록 안을 읽으면 표지의 형태를 예시로 든 산문이 표지로
        잡히며 그 일이 실제로 났다. `CLAUDE.md` §5-5 가 근거로 든 형의 두 번째다.
        """
        out = []
        for f in self.lean_files:
            depth = 0
            for i, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
                at_top = (depth == 0)
                # 그 줄이 시작될 때 블록 주석 밖이었고 줄이 `--` 로 시작할 때만 표지로 읽는다.
                if at_top and line.lstrip().startswith("--"):
                    m = DD_TOKEN.search(line)
                    if m:
                        out.append((f, i, m.group(1)))
                # 다음 줄의 깊이를 센다. Lean 의 `/- -/` 는 중첩된다.
                j = 0
                while j < len(line):
                    if line.startswith("/-", j):
                        depth += 1; j += 2; continue
                    if line.startswith("-/", j) and depth:
                        depth -= 1; j += 2; continue
                    if depth == 0 and line.startswith("--", j):
                        break          # 줄 주석이므로 그 줄의 나머지는 세지 않는다
                    j += 1
        return out


# --------------------------------------------------------------------------- 검사

def check_01(led: Ledger) -> Report:
    r = Report("1", "wiki1-id-unique", "id 가 CF-<n> 형식이고 전 파일에서 유일한가", "fail")
    seen: dict = {}
    for name, e in led.entries:
        eid = e.get("id")
        if not isinstance(eid, str) or not ID_FORM.match(eid):
            r.bad(f"{name}: id 가 `CF-<n>` 형식이 아니다 — {eid!r}")
            continue
        if eid in seen:
            r.bad(f"id 중복 — {eid} 가 {seen[eid]} 와 {name} 양쪽에 있다")
        else:
            seen[eid] = name
    r.note(f"id {len(seen)}건")
    return r


def check_02(led: Ledger) -> Report:
    r = Report("2", "wiki2-origin-arc", "origin.arc 가 arcs.json 의 아크 이름에 실재하는가", "fail")
    for _, e in led.entries:
        arc = (e.get("origin") or {}).get("arc")
        if arc not in led.arcs:
            r.bad(f"{e.get('id')}: 아크 `{arc}` 가 arcs.json 에 없다")
    return r


def _granting_patch(led: Ledger, arc: str, phase: str) -> dict | None:
    for p in led.patches:
        if p.get("arc") == arc and p.get("phase") == phase:
            return p
    return None


def _undeclared(led: Ledger) -> list[tuple[dict, str, str]]:
    """origin.phase 가 그 아크의 phases 에 없는 항목."""
    out = []
    for _, e in led.entries:
        o = e.get("origin") or {}
        arc, phase = o.get("arc"), o.get("phase")
        a = led.arcs.get(arc)
        if a is None:
            continue
        if phase not in (a.get("phases") or []):
            out.append((e, arc, phase))
    return out


def check_03(led: Ledger) -> Report:
    r = Report("3", "wiki3-origin-phase",
               "origin.phase 가 그 아크의 phases 에 있거나, 없으면 patches 가 권한을 주는가", "fail")
    granted = 0
    for e, arc, phase in _undeclared(led):
        if _granting_patch(led, arc, phase) is None:
            r.bad(f"{e.get('id')}: 페이즈 `{phase}` 가 아크 `{arc}` 에 선언되지 않았고 패치도 없다")
        else:
            granted += 1
            r.note(f"{e.get('id')}: 페이즈 `{phase}` 가 미선언이나 패치가 권한을 준다")
    # 검사 4 를 폐기하고 이 검사 하나로 두었으므로 권한이 쓰인 건수를 여기서 낸다(SPEC §2.1).
    r.note(f"패치가 권한을 준 항목 {granted}건")
    return r


def check_03a(led: Ledger) -> Report:
    r = Report("3-a", "wiki3a-phase-form", "origin.phase 가 origin.arc + \"-\" + <n> 형태인가", "fail")
    for _, e in led.entries:
        o = e.get("origin") or {}
        arc, phase = o.get("arc"), o.get("phase")
        if not isinstance(arc, str) or not isinstance(phase, str):
            r.bad(f"{e.get('id')}: origin 의 arc 또는 phase 가 문자열이 아니다")
            continue
        if not re.fullmatch(re.escape(arc) + r"-\d+", phase):
            r.bad(f"{e.get('id')}: 페이즈 `{phase}` 가 아크 `{arc}` 의 형태가 아니다")
    return r


def check_04a(led: Ledger) -> Report:
    r = Report("4-a", "wiki4a-patch-from",
               "op 가 move·split 인 패치의 from 이 그 아크의 phases 에 있는가", "fail")
    n = 0
    for p in led.patches:
        if p.get("op") not in ("move", "split"):
            continue
        n += 1
        arc = p.get("arc")
        a = led.arcs.get(arc)
        if a is None:
            r.bad(f"패치의 아크 `{arc}` 가 arcs.json 에 없다")
            continue
        if p.get("from") not in (a.get("phases") or []):
            r.bad(f"아크 `{arc}` 의 패치가 없는 페이즈 `{p.get('from')}` 에서 옮겼다고 적는다")
    r.note(f"move·split 패치 {n}건")
    return r


def check_05(led: Ledger) -> Report:
    r = Report("5", "wiki5-closed-arc", "status: closed 인 아크에 새 항목이 드는가", "fail")
    # 「새 항목」을 날짜로 가른다. 닫힌 아크의 항목 가운데 origin.date 가 그 아크의
    # closed 보다 뒤인 것만 잡는다. 닫힌 아크에 새 페이즈가 생기는 것은 검사 3 이 이미
    # 보므로, 이 검사의 고유한 몫은 선언된 페이즈 안에서 닫힌 뒤에 쓰인 항목뿐이고
    # 날짜가 유일한 신호다. 같은 날의 항목은 빠져나가며 스키마의 입도가 날짜이므로
    # 그 한계는 그대로 남는다. `← SPEC.md §2.1`
    n = 0
    for _, e in led.entries:
        origin = e.get("origin") or {}
        arc = origin.get("arc")
        a = led.arcs.get(arc)
        if a is None or a.get("status") != "closed":
            continue
        n += 1
        closed = a.get("closed")
        if not closed:
            r.bad(f"{e.get('id')}: 아크 `{arc}` 가 닫혔는데 closed 가 비어 있어 가를 수 없다")
            continue
        date = origin.get("date")
        if not date:
            r.bad(f"{e.get('id')}: 닫힌 아크 `{arc}` 의 항목인데 origin.date 가 없어 가를 수 없다")
            continue
        if date > closed:
            r.bad(f"{e.get('id')}: 닫힌 아크 `{arc}` 에 닫힌 날({closed}) 뒤의 항목이 쓰였다 — {date}")
    r.note(f"닫힌 아크를 가리키는 항목 {n}건")
    return r


def check_06(led: Ledger) -> Report:
    r = Report("6", "wiki6-tier-vocab", "tier 가 invariant·policy·finding 중 하나인가", "fail")
    for e in led.reg["decisions"]:
        if e.get("tier") not in TIERS:
            r.bad(f"{e.get('id')}: tier 가 어휘 밖이다 — {e.get('tier')!r}")
    return r


def check_07(led: Ledger) -> Report:
    r = Report("7", "wiki7-invariant-check",
               "tier: invariant 인 항목의 check 가 verify.sh 의 선언된 단계에 실재하는가", "fail")
    steps = led.verify_steps
    r.note(f"verify.sh 가 선언한 단계 id: {steps}")
    for e in led.reg["decisions"]:
        if e.get("tier") != "invariant":
            continue
        val = e.get("check")
        if not val:
            r.bad(f"{e.get('id')}: tier 가 invariant 인데 check 가 비었다")
        elif val not in steps:
            r.bad(f"{e.get('id')}: check `{val}` 가 verify.sh 의 선언된 단계에 없다")
    return r


def check_08(led: Ledger) -> Report:
    r = Report("8", "wiki8-retire-target",
               "폐기 레코드의 target 이 실재하고 한 대상에 폐기가 둘 이상이 아닌가", "fail")
    seen: dict = {}
    for e in led.reg["retirements"]:
        t = e.get("target")
        if t not in led.by_id:
            r.bad(f"{e.get('id')}: target `{t}` 가 원장에 없다")
        if t in seen:
            r.bad(f"{t} 에 폐기가 둘이다 — {seen[t]} 와 {e.get('id')}")
        else:
            seen[t] = e.get("id")
        rb = e.get("replaced_by")
        if rb is not None and rb not in led.by_id:
            r.bad(f"{e.get('id')}: replaced_by `{rb}` 가 원장에 없다")
    return r


def check_09(led: Ledger) -> Report:
    r = Report("9", "wiki9-retire-reason", "폐기 레코드에 original 과 reason 이 비어 있지 않은가", "fail")
    for e in led.reg["retirements"]:
        for f in ("original", "reason"):
            v = e.get(f)
            if not isinstance(v, str) or not v.strip():
                r.bad(f"{e.get('id')}: {f} 가 비었다")
    return r


def check_10(led: Ledger) -> Report:
    r = Report("10", "wiki10-ghost-ref", "폐기된 id 를 살아 있는 것처럼 참조하는 자리가 있는가", "fail")
    dead = led.dead
    early: list[str] = []
    early_owners: list[str] = []

    def id_no(cf) -> int:
        """`CF-<n>` 의 번호. 형식이 아니면 -1 이라 가름에 쓰이지 않는다."""
        m = ID_FORM.match(str(cf or ""))
        return int(m.group(1)) if m else -1

    def judge(e: dict, ref: str, msg: str) -> None:
        """원장 안의 지목 하나를 가른다. 폐기 전이면 보고하고, 폐기 뒤면 승인하거나 실패시킨다."""
        retirer = led.retired_by.get(ref)
        if retirer is not None and id_no(e.get("id")) < id_no(retirer):
            early.append(msg)
            if e.get("id") not in early_owners:
                early_owners.append(e.get("id"))
            return
        if retirer is not None and retirer in (e.get("related") or []):
            return
        r.bad(msg)

    # 폐기 전에 쓰인 지목은 그 시점에 산 대상을 가리킨 역사이므로 실패가 아니라 보고다. ID 가 단조
    # 증가하므로 지목한 항목이 폐기 레코드보다 앞서는지로 가른다. 폐기 뒤에 쓰인 지목만 그 폐기
    # 레코드를 related 에 들 때 승인한다(SPEC §2.1, CF-661).
    # 원장 안. 폐기 레코드 자신의 target 과 original 은 제외한다(SPEC §2.1).
    for name, e in led.entries:
        # 그 자신이 폐기된 항목은 보지 않는다. 폐기된 항목의 지목을 고치는 길이 없고, 그 문면도
        # 폐기 시점의 앎을 담은 역사이기 때문이다.
        if e.get("id") in dead:
            continue
        for ref in e.get("related", []) or []:
            if ref in dead:
                judge(e, ref, f"{e.get('id')}: related 가 폐기된 {ref} 를 든다")
        rw = e.get("reopen_when")
        if isinstance(rw, dict) and rw.get("ref") in dead:
            judge(e, rw.get("ref"),
                  f"{e.get('id')}: reopen_when.ref 가 폐기된 {rw.get('ref')} 를 든다")
        if name == "retirements":
            continue
        for f in ("statement", "basis", "reason", "candidate", "for"):
            for m in CF_TOKEN.finditer(str(e.get(f) or "")):
                if m.group(0) in dead:
                    judge(e, m.group(0),
                          f"{e.get('id')}: {f} 가 폐기된 {m.group(0)} 를 든다")
    # Lean 의 DD: 표지. 이 자리는 고칠 수 있으므로 폐기와 함께 고치며 가름을 받지 않는다.
    for f, ln, ref in led.dd_markers():
        if ref in dead:
            r.bad(f"{f.relative_to(led.root)}:{ln}: DD: 표지가 폐기된 {ref} 를 가리킨다")
    # docs/ 산문. 역사 기록은 유니버스 밖이다. 그 문면은 그 시점의 앎을 담으므로 낡은 지목이
    # 정당하고 소급해 고치지 않는다. 검사 24 가 쓰는 `HISTORY_PATHS` 를 같이 쓴다(SPEC §2.1).
    for f in led.doc_files:
        rel = str(f.relative_to(led.root))
        if any(rel.startswith(h) for h in HISTORY_PATHS):
            continue
        for i, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
            for m in CF_TOKEN.finditer(line):
                if m.group(0) in dead:
                    r.bad(f"{f.relative_to(led.root)}:{i}: 산문이 폐기된 {m.group(0)} 를 든다")
    r.note(f"폐기된 id {len(dead)}건을 유니버스로 훑었다. 유니버스 밖: {list(HISTORY_PATHS)}")
    r.note(f"폐기 전에 쓰인 지목 {len(early)}건 · 그것을 든 항목 {len(early_owners)}개")
    # 보고 줄과 실패 줄을 줄 머리(`-` 와 `·`)로만 가르면 받는 쪽이 눈으로 가르게 된다. 각 줄이
    # 스스로 「폐기 전에 쓰인 지목」임을 들어 문면으로도 갈리게 한다(CF-683).
    for msg in early:
        r.note(f"폐기 전에 쓰인 지목 — {msg}")
    return r


def check_11(led: Ledger) -> Report:
    r = Report("11", "wiki11-reopen-kind",
               "deferred 항목에 reopen_when 이 있고 kind 가 넷 중 하나인가", "fail")
    for e in led.reg["deferred"]:
        if "reopen_when" not in e:
            r.bad(f"{e.get('id')}: reopen_when 필드가 없다")
            continue
        rw = e["reopen_when"]
        if rw is None:
            continue
        if not isinstance(rw, dict):
            r.bad(f"{e.get('id')}: reopen_when 이 객체도 null 도 아니다")
            continue
        if rw.get("kind") not in REOPEN_KINDS:
            r.bad(f"{e.get('id')}: kind 가 넷 밖이다 — {rw.get('kind')!r}")
        if not str(rw.get("ref") or "").strip():
            r.bad(f"{e.get('id')}: ref 가 비었다")
    return r


# 범위 밖인 아크의 상태 값. 아크가 영영 열리지 않는다는 처분이며 검사 12 와 28 이 그 값을
# 읽는다. 어휘의 정본은 SPEC §3.2 의 아크 레코드 필드 표다.
ARC_OUT_OF_SCOPE = "out_of_scope"


def arc_out_of_scope(led: Ledger, name: str) -> bool:
    """그 아크가 범위 밖인가.

    **검사 28 이 이 판정을 부른다.** 재개 트리거 쪽에 같은 판정을 거는 것은 이 판에 서지
    않으며, 범위 밖이 된 시점을 드는 필드가 아크 레코드에 없어서 이미 등재된 트리거를 가를
    자리가 없기 때문이다. 그 자리가 서면 이 함수를 두 검사가 함께 부른다.
    """
    a = led.arcs.get(name)
    return bool(a) and a.get("status") == ARC_OUT_OF_SCOPE


def check_12(led: Ledger) -> Report:
    r = Report("12", "wiki12-reopen-ref", "reopen_when.ref 가 kind 별 형식을 만족하는가", "fail")
    queue = led.root / "docs" / "reading-queue-v0.md"
    qtext = queue.read_text(encoding="utf-8") if queue.is_file() else ""
    qflat = re.sub(r"\s+", "", qtext)
    for e in led.reg["deferred"]:
        rw = e.get("reopen_when")
        if not isinstance(rw, dict):
            continue
        kind, ref = rw.get("kind"), str(rw.get("ref") or "")
        if kind == "artifact":
            # 실재는 보지 않는다. 그 파일이 서는 것이 곧 재개 조건이기 때문이다(SPEC §3.3).
            if not ARTIFACT_PATH.match(ref) or ".." in ref:
                r.bad(f"{e.get('id')}: artifact 의 ref 가 리포 경로의 형식이 아니다 — {ref!r}")
        elif kind == "extraction":
            # 번호를 강제하지 않는다. S-5 가 지목 참조한 편에 E-nn 이 배정될 자리를
            # 두지 않으므로 형식을 요구하면 등재가 막힌다(SPEC §3.3).
            if not qflat:
                r.bad(f"{e.get('id')}: reading-queue-v0.md 를 읽을 수 없어 extraction 을 해소하지 못한다")
            elif re.sub(r"\s+", "", ref) not in qflat:
                r.bad(f"{e.get('id')}: extraction 의 ref `{ref}` 가 reading-queue-v0.md 에서 해소되지 않는다")
        elif kind in ("arc_phase", "blocking"):
            if ref not in led.arcs:
                r.bad(f"{e.get('id')}: {kind} 의 ref `{ref}` 가 arcs.json 의 아크가 아니다")
    return r


def check_13(led: Ledger) -> Report:
    r = Report("13", "wiki13-dd-target",
               "Lean 줄 주석의 DD: 표지가 실재하고 폐기되지 않은 id 를 가리키는가", "fail")
    marks = led.dd_markers()
    r.note(f"DD: 표지 {len(marks)}개")
    for f, ln, ref in marks:
        if not ID_FORM.match(ref):
            r.bad(f"{f.relative_to(led.root)}:{ln}: 표지 `{ref}` 가 CF-<n> 형식이 아니다")
        elif ref not in led.by_id:
            r.bad(f"{f.relative_to(led.root)}:{ln}: 표지가 없는 항목 {ref} 를 가리킨다")
        elif ref in led.dead:
            r.bad(f"{f.relative_to(led.root)}:{ln}: 표지가 폐기된 {ref} 를 가리킨다")
    return r


def check_14(led: Ledger) -> Report:
    r = Report("14", "wiki14-dd-layer", "DD: 항목의 layer 가 그 파일이 사는 층과 같은가", "fail")
    n = 0
    for f, ln, ref in led.dd_markers():
        e = led.by_id.get(ref)
        if e is None:
            continue
        layer = e.get("layer")
        if layer == "meta":
            continue          # 층에 갇히지 않으므로 건너뛴다(SPEC §3.2)
        n += 1
        want = LAYER_DIR.get(layer)
        rel = str(f.relative_to(led.root))
        if want is None:
            r.bad(f"{rel}:{ln}: {ref} 의 layer `{layer}` 가 대응표에 없다")
        elif not rel.startswith(want + "/"):
            r.bad(f"{rel}:{ln}: {ref} 의 layer 가 `{layer}` 인데 파일이 그 층에 없다")
    r.note(f"meta 가 아닌 표지 {n}개를 봤다")
    return r


def check_15(led: Ledger) -> Report:
    r = Report("15", "wiki15-names-unique", "names 의 규율 ID 가 원장 전체에서 유일한가", "fail")
    seen: dict = {}
    for _, e in led.entries:
        for n in e.get("names", []) or []:
            if n in seen:
                r.bad(f"규율 ID `{n}` 이 {seen[n]} 와 {e.get('id')} 양쪽에 붙었다")
            else:
                seen[n] = e.get("id")
    r.note(f"규율 ID {len(seen)}건")
    return r


def check_23(led: Ledger) -> Report:
    r = Report("23", "wiki23-rule-ghost",
               "statement·basis 의 규율 ID 토큰이 어느 항목의 names 에 실재하고, "
               "폐기됐으면 그 폐기 레코드를 related 가 들거나 그 항목이 폐기보다 앞서 쓰였는가",
               "fail")
    total = 0
    exempt = 0
    by_date = 0
    overlap = 0
    for name, e in led.entries:
        # 폐기 레코드는 통째로 유니버스 밖이다. statement 가 「D-6 을 폐기한다」 꼴이라
        # 형태상 반드시 폐기되는 규율의 ID 를 들기 때문이다(SPEC §2.1).
        if name == "retirements":
            continue
        related = set(e.get("related", []) or [])
        # 첫 적재는 related 를 전량 빈 배열로 두었고 원장이 수정 불가라 채울 길이 없다.
        # 예외를 charter-6 으로 못 박으므로 그 뒤의 항목은 요건을 그대로 받는다(SPEC §2.1).
        first_load = (e.get("origin") or {}).get("phase") == "charter-6"
        for f in ("statement", "basis"):
            for m in RULE_TOKEN.finditer(str(e.get(f) or "")):
                tok = m.group(0)
                total += 1
                owner = led.name_owner.get(tok)
                if owner is None:
                    r.bad(f"{e.get('id')}: {f} 의 `{tok}` 이 어느 항목의 names 에도 없다")
                elif owner in led.dead:
                    # 승인 경로는 폐기 레코드 지목이다. 폐기된 항목의 id 가 아니라 그것을
                    # 폐기한 레코드의 id 를 related 에서 찾는다. 앞을 요구하면 검사 10 이
                    # 그 id 를 산 참조로 잡아 두 검사가 정면으로 부딪힌다(SPEC §2.1).
                    retirer = led.retired_by.get(owner)
                    # 날짜 면제가 첫 적재 면제보다 앞에 선다. 앞은 애초에 이 검사의 대상이
                    # 아니라는 범위의 문제이고 뒤는 그때 related 를 채울 길이 없었다는 구조적
                    # 사정이므로, 범위가 먼저 서야 뒤의 계수가 소급 불가능분의 크기를 바르게
                    # 센다. 부등호는 엄격하다. 같은 날을 면제하면 같은 카드에서 폐기되는 규율을
                    # 새 항목이 이름으로 들지 못하게 한 금지가 조용히 풀린다(SPEC §2.1).
                    wrote = (e.get("origin") or {}).get("date")
                    killed = led.retired_on.get(owner)
                    early = bool(wrote) and bool(killed) and str(wrote) < str(killed)
                    if retirer in related:
                        pass
                    elif early:
                        by_date += 1
                        if first_load:
                            overlap += 1
                    elif first_load:
                        exempt += 1
                    else:
                        r.bad(f"{e.get('id')}: {f} 가 폐기된 규율 `{tok}`({owner}) 를 "
                              f"그것을 폐기한 레코드 {retirer} 를 related 에 적지 않고 든다")
    r.note(f"규율 ID 토큰 {total}건을 봤다. 계열은 {list(RULE_SERIES)}")
    r.note(f"폐기보다 앞서 쓰인 항목의 날짜 면제 {by_date}건 "
           f"(그 가운데 첫 적재와 겹치는 것 {overlap}건)")
    r.note(f"폐기 레코드는 유니버스 밖이다. 첫 적재(charter-6)의 related 면제 {exempt}건")
    return r


def check_24(led: Ledger) -> Report:
    r = Report("24", "wiki24-doc-rule-ghost",
               "상주 문서와 Lean 주석의 규율 ID 토큰이 실재하고, 폐기됐으면 그 문서가 선언했는가",
               "fail")
    total = missing = retired = declared = 0
    for rel, text in led.rule_scan_targets():
        # 문서 머리의 선언 줄을 읽어 거기 열거된 ID 의 폐기 지목을 면제한다.
        allow: set = set()
        for line in text.splitlines():
            m = DECLARE_LINE.match(line)
            if m:
                allow |= {x.group(0) for x in RULE_TOKEN.finditer(m.group(1))}
        for i, line in enumerate(text.splitlines(), 1):
            if DECLARE_LINE.match(line):
                continue                      # 선언 줄 자신은 면제의 근거이지 지목이 아니다
            for m in RULE_TOKEN.finditer(line):
                tok = m.group(0)
                total += 1
                owner = led.name_owner.get(tok)
                if owner is None:
                    missing += 1
                    r.bad(f"{rel}:{i}: `{tok}` 이 어느 항목의 names 에도 없다")
                elif owner in led.dead:
                    if tok in allow:
                        declared += 1
                    else:
                        retired += 1
                        r.bad(f"{rel}:{i}: 폐기된 규율 `{tok}`({owner}) 를 드는데 "
                              f"문서 머리의 폐기 지목 선언에 없다")
    r.note(f"규율 ID 토큰 {total}건. 미실재 {missing} · 선언 없는 폐기 지목 {retired} · "
           f"선언으로 면제된 폐기 지목 {declared}")
    r.note(f"유니버스: 상주 문서 {len(RESIDENT_DOCS) + 1} · Lean {len(led.lean_files)}. "
           f"유니버스 밖: {list(HISTORY_PATHS)}")
    return r


def check_25(led: Ledger) -> Report:
    r = Report("25", "wiki25-marker-missing",
               "Lean 의 최상위 def·theorem·inductive·structure·abbrev 선언마다 DD: 표지가 붙었는가",
               "fail")
    marks = led.dd_markers()
    n_decl = n_mark = missing = 0
    for f in led.lean_files:
        lines = f.read_text(encoding="utf-8").splitlines()
        decls = [(i, m.group(1), m.group(2))
                 for i, ln in enumerate(lines, 1)
                 for m in [TOP_DECL.match(ln)] if m]
        # 그 파일의 표지가 선 줄. 검사 13 과 같은 유니버스라 블록 주석은 들지 않는다.
        mark_lines = sorted(ln for g, ln, _ in marks if g == f)
        n_decl += len(decls)
        n_mark += len(mark_lines)
        prev = 0
        for line_no, kind, name in decls:
            # 앞 선언과 이 선언 사이에 선 표지가 이 선언의 것이다.
            if any(prev < m < line_no for m in mark_lines):
                pass
            else:
                missing += 1
                r.bad(f"{f.relative_to(led.root)}:{line_no}: 최상위 {kind} `{name}` 에 "
                      f"DD: 표지가 없다")
            prev = line_no
    r.note(f"최상위 선언 {n_decl} · 표지 {n_mark} · 누락 {missing}")
    r.note("example 은 정의도 정리도 아니므로 대상이 아니다(SPEC §2.1)")
    return r


def trigger_fired(led: Ledger, e: dict) -> tuple[bool, str, str]:
    """이연 항목의 `reopen_when` 이 충족됐는가와 그 종류와 사유를 낸다.

    검사 16 과 31 이 같은 판정을 쓴다. 판정을 두 자리에 전사하면 한쪽을 고칠 때 다른 쪽이
    조용히 낡고, 둘이 다른 수를 내는 것을 어느 검사도 잡지 못한다(SPEC §2.1).
    """
    rw = e.get("reopen_when")
    if not isinstance(rw, dict):
        return False, "", ""
    kind, ref = rw.get("kind"), str(rw.get("ref") or "")
    hit = False
    why = ""
    if kind == "artifact":
        p = led.root / ref
        hit = p.exists()
        why = f"경로 `{ref}` 가 실재한다"
    elif kind == "extraction":
        # 그 논문의 추출 기록이 섰는가를 파일명으로 본다. 본문으로 보면 다른 추출 기록이
        # 그 논문을 인용한 자리가 발화로 잡힌다.
        flat = re.sub(r"[^a-z0-9]", "", ref.lower())
        d = led.root / "docs" / "extractions"
        for f in (sorted(d.glob("*.md")) if d.is_dir() else []):
            if flat and flat in re.sub(r"[^a-z0-9]", "", f.stem.lower()):
                hit, why = True, f"추출 기록 `{f.name}` 이 섰다"
                break
    elif kind == "arc_phase":
        a = led.arcs.get(ref)
        hit = bool(a) and a.get("status") == "open"
        why = f"아크 `{ref}` 가 열려 있다"
    # `blocking` 은 여기서 보지 않는다. 아크가 열려 있다는 것으로는 누가 실제로 부딪힌 것과
    # 아크가 그냥 열려 있는 것이 갈리지 않아 늘 발화로 뜨고, 그러면 이 보고를 읽는 쪽이
    # 곧 넘기게 되어 검사 16 을 두는 사유가 무너진다. 그 몫은 검사 18 이 든다(SPEC §2.2).
    return hit, str(kind or ""), why


def check_16(led: Ledger) -> Report:
    r = Report("16", "wiki16-trigger-fired", "reopen_when 이 충족된 이연 항목", "report")
    fired: list[str] = []
    dropped: list[str] = []
    for e in led.reg["deferred"]:
        hit, kind, why = trigger_fired(led, e)
        if hit:
            # 폐기된 이연 항목은 살아 있는 구멍이 아니다. 함께 실으면 살아 있는 구멍의 수를
            # 밖에서 셀 수 없다(CF-684). 뺀 건수는 출력에 남긴다.
            if e.get("id") in led.dead:
                dropped.append(str(e.get("id")))
                continue
            fired.append(f"{e.get('id')} ({kind}) — {why}")
    r.note(f"발화한 트리거 {len(fired)}건"
           + (f" · 폐기된 이연 항목 {len(dropped)}건을 뺐다({', '.join(dropped)})"
              if dropped else " · 뺀 폐기분 0건"))
    for line in fired:
        r.note(line)
    return r


def check_17(led: Ledger) -> Report:
    r = Report("17", "wiki17-reopen-null", "reopen_when: null 인 항의 계수", "report")
    nulls = [e for e in led.reg["deferred"] if e.get("reopen_when") is None]
    r.note(f"reopen_when: null {len(nulls)}건")
    for e in nulls:
        r.note(f"{e.get('id')} — names {e.get('names')}")
    return r


def check_18(led: Ledger) -> Report:
    r = Report("18", "wiki18-blocking-disposition", "아크별 blocking 구멍의 처분 내역", "report")
    rows: dict = {}
    dropped: list[str] = []
    for e in led.reg["deferred"]:
        rw = e.get("reopen_when")
        if isinstance(rw, dict) and rw.get("kind") == "blocking":
            # 폐기된 구멍은 처분이 끝난 것이므로 목록에서 뺀다. 뺀 건수는 출력에 남긴다(CF-684).
            if e.get("id") in led.dead:
                dropped.append(str(e.get("id")))
                continue
            rows.setdefault(str(rw.get("ref")), []).append(e.get("id"))
    r.note(f"blocking 구멍 {sum(len(v) for v in rows.values())}건, 아크 {len(rows)}개"
           + (f" · 폐기된 이연 항목 {len(dropped)}건을 뺐다({', '.join(dropped)})"
              if dropped else " · 뺀 폐기분 0건"))
    for arc, ids in sorted(rows.items()):
        a = led.arcs.get(arc) or {}
        r.note(f"{arc} (status {a.get('status')}) — {', '.join(ids)}")
    return r


def check_19(led: Ledger) -> Report:
    r = Report("19", "wiki19-id-gap", "CF-<n> 번호의 결번", "report")
    nums = sorted(int(m.group(1)) for e in led.by_id
                  for m in [ID_FORM.match(e)] if m)
    if not nums:
        r.note("id 가 없다")
        return r
    gaps = [n for n in range(1, nums[-1] + 1) if n not in set(nums)]
    r.note(f"CF-{nums[0]}~CF-{nums[-1]}, 계수 {len(nums)}, 결번 {len(gaps)}건")
    if gaps:
        r.note("결번: " + ", ".join(f"CF-{n}" for n in gaps))
    return r


def check_20(led: Ledger, arc: str | None) -> Report:
    r = Report("20", "wiki20-arc-holes", "그 아크에 걸린 구멍마다 해소됐거나 이관됐는가", "arc_close")
    if arc is None:
        r.ran = False
        r.note("아크 종료 커밋이 아니므로 수행하지 않는다")
        return r
    a = led.arcs.get(arc)
    if a is None:
        r.bad(f"아크 `{arc}` 가 arcs.json 에 없다")
        return r
    holes = a.get("holes") or []
    r.note(f"아크 `{arc}` 의 구멍 {len(holes)}건")
    for h in holes:
        e = led.by_id.get(h)
        if e is None:
            r.bad(f"{h}: 아크 `{arc}` 가 든 구멍이 원장에 없다")
            continue
        if h in led.dead:
            continue                                   # 해소
        rw = e.get("reopen_when")
        if isinstance(rw, dict) and rw.get("kind") in ("arc_phase", "blocking") \
                and rw.get("ref") != arc:
            continue                                   # 이관
        r.bad(f"{h}: 해소도 이관도 되지 않은 채 아크 `{arc}` 가 닫힌다")
    return r


def check_21(led: Ledger, arc: str | None) -> Report:
    r = Report("21", "wiki21-arc-blocking",
               "그 아크에 걸린 blocking 구멍마다 해소됐거나 이월됐는가", "arc_close")
    if arc is None:
        r.ran = False
        r.note("아크 종료 커밋이 아니므로 수행하지 않는다")
        return r
    a = led.arcs.get(arc)
    if a is None:
        r.bad(f"아크 `{arc}` 가 arcs.json 에 없다")
        return r
    holes = set(a.get("holes") or [])
    n = 0
    for e in led.reg["deferred"]:
        rw = e.get("reopen_when")
        if not (isinstance(rw, dict) and rw.get("kind") == "blocking"):
            continue
        if rw.get("ref") != arc and e.get("id") not in holes:
            continue
        n += 1
        if e.get("id") in led.dead:
            continue                                   # 해소
        if rw.get("ref") != arc:
            continue                                   # 이월
        r.bad(f"{e.get('id')}: 아크 `{arc}` 의 blocking 구멍이 해소도 이월도 되지 않았다")
    r.note(f"아크 `{arc}` 의 blocking 구멍 {n}건")
    return r


ORDER = ["1", "2", "3", "3-a", "4-a", "5", "6", "7", "8", "9", "10",
         "11", "12", "13", "14", "15", "23", "24", "25", "16", "17", "18", "19", "20", "21", "26", "27",
         "28", "31", "32", "33", "34", "35", "36", "37", "29", "30"]


def check_26(led: Ledger) -> Report:
    r = Report("26", "wiki26-clarify-target",
               "꼬리의 clarifies 가 실재하고 폐기되지 않은 항목을 가리키는가",
               "fail")
    n = 0
    for name, e in led.entries:
        tgt = e.get("clarifies")
        if tgt is None:
            continue
        n += 1
        if tgt not in led.by_id:
            r.bad(f"{e.get('id')}: clarifies 의 `{tgt}` 이 원장에 없다")
        elif tgt in led.dead:
            r.bad(f"{e.get('id')}: clarifies 의 `{tgt}` 이 폐기된 항목이다")
    r.note(f"꼬리 {n}건")
    return r


def check_27(led: Ledger) -> Report:
    r = Report("27", "wiki27-clarify-resolves",
               "꼬리의 resolves 가 phrase 와 absolute 를 갖고 그 phrase 가 "
               "대상 항목의 산문 필드에 실제로 있는가",
               "fail")
    n = 0
    pairs = 0
    for name, e in led.entries:
        if "clarifies" not in e:
            continue
        n += 1
        res = e.get("resolves")
        if not isinstance(res, list) or not res:
            r.bad(f"{e.get('id')}: resolves 가 비어 있거나 배열이 아니다")
            continue
        # 대상의 실재와 비폐기는 검사 26 의 몫이다. 여기서 또 잡으면 한 주입이 두 검사를
        # 실패시켜 어느 검사가 무엇을 잡는지가 갈리지 않는다(§3.10-1).
        if e.get("clarifies") not in led.by_id or e.get("clarifies") in led.dead:
            continue
        tgt = led.by_id[e["clarifies"]]
        prose = str(tgt.get("statement") or "") + str(tgt.get("basis") or "")
        for item in res:
            pairs += 1
            if not isinstance(item, dict) or set(item) != {"phrase", "absolute"}:
                r.bad(f"{e.get('id')}: resolves 의 항이 phrase·absolute 만 갖지 않는다")
                continue
            if item["phrase"] not in prose:
                r.bad(f"{e.get('id')}: `{item['phrase']}` 가 "
                      f"{e.get('clarifies')} 의 산문에 없다")
    r.note(f"꼬리 {n}건 · 지목 {pairs}건")
    return r


# 검사 28·29·30 이 읽는 CQ 고정 절. `docs/baseline.md` §5 의 `CQFIN` 블록이며 정본은 같은 파일의 §6 이다.
CQFIN_BLOCK = re.compile(r"<!-- CQFIN:BEGIN -->\n(.*?)<!-- CQFIN:END -->", re.S)
CQFIN_LINE = re.compile(r"^CQFIN=(\d+)\|")
CQ_REF = re.compile(r"^CQ-fin-(\d+)$")
# 검사 29 가 읽는 `cq_disposition` 의 `kind` 레지스터. S-6 의 종료 조건 둘이다(SPEC §3.2).
CQ_DISPOSITION_KINDS = ("cleared", "hole")


def cq_fixed(led: Ledger) -> list[int]:
    """고정 절 블록이 드는 CQ 번호. 파일이나 블록이 없으면 빈 목록이다."""
    p = led.root / "docs" / "baseline.md"
    m = CQFIN_BLOCK.search(p.read_text(encoding="utf-8")) if p.is_file() else None
    if not m:
        return []
    return [int(x.group(1)) for x in map(CQFIN_LINE.match, m.group(1).splitlines()) if x]


def check_28(led: Ledger) -> Report:
    r = Report("28", "wiki28-cq-exists",
               "arcs.json 의 cq 값이 CQ 고정 절에 실재하는 번호를 가리키고, 범위 밖인 "
               "아크가 cq 를 들지 않는가", "fail")
    fixed = set(cq_fixed(led))
    # 블록이 비어 있으면 통과가 아니라 실패다. 가리킬 대상이 없는데 통과시키면 이 검사가 공허해진다.
    if not fixed:
        r.bad("docs/baseline.md 의 CQFIN 블록이 없거나 비어 있다")
    n = out = 0
    for name, a in led.arcs.items():
        cq = a.get("cq") or []
        # 범위 밖인 아크가 CQ 를 받으면 그 종료 조건이 그 항 위에서 영영 재어지지 않는다.
        # 받는 아크가 없는 것을 피하려고 만든 배정이 같은 결함의 다른 모양이 된다(SPEC §2.1).
        if cq and arc_out_of_scope(led, name):
            out += 1
            r.bad(f"아크 `{name}` 이 범위 밖인데 cq 를 든다 — {', '.join(map(str, cq))}")
        for ref in cq:
            n += 1
            m = CQ_REF.match(str(ref))
            if not m:
                r.bad(f"아크 `{name}` 의 cq `{ref}` 가 CQ-fin-<n> 형식이 아니다")
            elif int(m.group(1)) not in fixed:
                r.bad(f"아크 `{name}` 의 cq `{ref}` 가 고정 절에 없다")
    r.note(f"고정 절의 CQ {len(fixed)}건 · 아크가 든 cq {n}건 · "
           f"범위 밖인데 cq 를 든 아크 {out}건")
    return r


def check_29(led: Ledger, arc: str | None) -> Report:
    r = Report("29", "wiki29-arc-cq",
               "그 아크의 cq 마다 그 아크에서 나온 원장 항목이 cq_disposition 으로 그 CQ 를 드는가",
               "arc_close")
    if arc is None:
        r.ran = False
        r.note("아크 종료 커밋이 아니므로 수행하지 않는다")
        return r
    a = led.arcs.get(arc)
    if a is None:
        r.bad(f"아크 `{arc}` 가 arcs.json 에 없다")
        return r
    # 처분이 정의 공백을 벗어났는지는 기계가 판정하지 못한다. 결정 세션의 판정이 원장에
    # 기록됐는지만 본다. 검사 21 과 같은 형이다(SPEC §2.3).
    # 판정은 산문이 아니라 필드를 읽는다. 아크의 개막 결정이 자기 CQ 를 이름으로 적으므로
    # 산문 대조로는 처분이 없어도 통과한다(CF-597).
    own = [e for _, e in led.entries
           if isinstance(e.get("origin"), dict) and e["origin"].get("arc") == arc]
    fixed = set(cq_fixed(led))
    disposed: set[str] = set()
    n_with = 0
    for e in own:
        items = e.get("cq_disposition")
        if items is None:
            continue
        n_with += 1
        if not isinstance(items, list):
            r.bad(f"{e.get('id')}: cq_disposition 이 배열이 아니다")
            continue
        for item in items:
            if not isinstance(item, dict):
                r.bad(f"{e.get('id')}: cq_disposition 의 원소가 {{cq, kind}} 가 아니다")
                continue
            ref, kind = item.get("cq"), item.get("kind")
            m = CQ_REF.match(str(ref))
            ok_ref = bool(m) and int(m.group(1)) in fixed
            if not m:
                r.bad(f"{e.get('id')}: cq_disposition 의 cq `{ref}` 가 CQ-fin-<n> 형식이 아니다")
            elif not ok_ref:
                r.bad(f"{e.get('id')}: cq_disposition 의 cq `{ref}` 가 고정 절에 없다")
            if kind not in CQ_DISPOSITION_KINDS:
                r.bad(f"{e.get('id')}: cq_disposition 의 kind `{kind}` 가 레지스터 "
                      f"{list(CQ_DISPOSITION_KINDS)} 밖이다")
            elif ok_ref:
                disposed.add(str(ref))
    cqs = a.get("cq") or []
    for ref in cqs:
        if str(ref) not in disposed:
            r.bad(f"{ref}: 아크 `{arc}` 에서 나온 원장 항목 가운데 cq_disposition 으로 그 처분을 드는 것이 없다")
    r.note(f"아크 `{arc}` 의 cq {len(cqs)}건 · 그 아크에서 나온 항목 가운데 cq_disposition 을 든 것 {n_with}건")
    return r


def check_30(led: Ledger) -> Report:
    r = Report("30", "wiki30-cq-unclaimed", "어느 아크의 cq 에도 들지 않은 CQ 의 계수와 번호", "report")
    claimed = set()
    for a in led.arcs.values():
        for ref in a.get("cq") or []:
            m = CQ_REF.match(str(ref))
            if m:
                claimed.add(int(m.group(1)))
    rest = [n for n in cq_fixed(led) if n not in claimed]
    r.note(f"아크에 걸리지 않은 CQ {len(rest)}건")
    if rest:
        r.note(", ".join(f"CQ-fin-{n}" for n in rest))
    return r


def check_31(led: Ledger) -> Report:
    r = Report("31", "wiki31-hole-unassigned",
               "발화한 이연 항목이 어느 아크의 holes 에도 들지 않는가", "fail")
    assigned = {h for a in led.arcs.values() for h in (a.get("holes") or [])}
    dropped: list[str] = []
    n_fired = n_assigned = exempt = 0
    for e in led.reg["deferred"]:
        hit, kind, _ = trigger_fired(led, e)
        if not hit:
            continue
        # 폐기된 항목은 살아 있는 구멍이 아니므로 유니버스 밖이다. 검사 16 과 같은 형이며,
        # 발화를 먼저 보고 거르므로 뺀 건수와 그 id 가 출력에 남는다(CF-684).
        if e.get("id") in led.dead:
            dropped.append(str(e.get("id")))
            continue
        n_fired += 1
        if e.get("id") in assigned:
            n_assigned += 1
            continue
        # 첫 적재는 아크 개념 이전에 섰고 `arcs.json` 에 배정될 자리가 없었다. 예외를
        # charter-6 으로 못 박으므로 그 뒤의 항목은 요건을 그대로 받는다(SPEC §2.1).
        if (e.get("origin") or {}).get("phase") == "charter-6":
            exempt += 1
            continue
        r.bad(f"{e.get('id')}: 발화한({kind}) 이연 항목이 어느 아크의 holes 에도 없다")
    r.note(f"발화 {n_fired}건 · 그 가운데 배정된 것 {n_assigned}건 "
           f"· 첫 적재(charter-6) 면제 {exempt}건"
           + (f" · 폐기된 이연 항목 {len(dropped)}건을 뺐다({', '.join(dropped)})"
              if dropped else " · 뺀 폐기분 0건"))
    return r


def check_32(led: Ledger) -> Report:
    r = Report("32", "wiki32-closure-phase",
               "페이즈 종료 문서의 페이즈가 어느 아크의 phases 에 선언되어 있는가", "fail")
    declared = {p for a in led.arcs.values() for p in (a.get("phases") or [])}
    d = led.root / "docs" / "phases"
    docs = sorted(d.glob("*-closure.md")) if d.is_dir() else []
    for f in docs:
        phase = f.name[:-len("-closure.md")]
        if phase not in declared:
            r.bad(f"{f.relative_to(led.root)}: 페이즈 `{phase}` 가 어느 아크의 "
                  f"phases 에도 없다")
    # 미전사분 블록의 대조를 걷었다. 그 문면이 청사진에만 살고 `patches` 가 계획 변경만 들게
    # 되어 맞댈 상대를 잃었기 때문이다. 블록을 든 앞 판의 종료 문서는 역사 기록이라 그대로
    # 두며, 이 검사가 블록을 읽지 않으므로 그것들이 걸리지 않는다(SPEC §2).
    r.note(f"종료 문서 {len(docs)}건")
    return r


# 검사 33·34 가 읽는 머리말 규약. `docs/baseline.md` §5 의 `HEADING` 블록이며 정본은 같은
# 파일의 §7 이다. 경계를 코드에 박지 않고 그 블록의 `HEADING_SINCE` 가 들게 한다.
HEADING_BLOCK = re.compile(r"<!-- HEADING:BEGIN -->\n(.*?)<!-- HEADING:END -->", re.S)
HEADING_SINCE_LINE = re.compile(r"^HEADING_SINCE=(\d+)$")
HEADING_LINE = re.compile(r"^HEADING=([^|]*)\|([^|]*)\|(.*)$")
# 검사 35 가 읽는 문서 양식. 한 줄은 `DOCFORM=<디렉터리>|<종류>|<값>` 이고 디렉터리는
# `docs/` 를 기준으로 한 상대 경로이며 루트는 `.` 으로 적는다.
DOCFORM_BLOCK = re.compile(r"<!-- DOCFORM:BEGIN -->\n(.*?)<!-- DOCFORM:END -->", re.S)
DOCFORM_LINE = re.compile(r"^DOCFORM=([^|]*)\|([^|]*)\|(.*)$")
# 검사 35 의 실패 문면. 적발한 뒤의 질의가 이 검사에 요구된 것이므로 이름을 맞추지 말라고
# 적되, 어떤 이름이면 통과하는지는 적지 않는다. 적으면 합의되지 않은 양식이 합의된 이름을
# 입고 들어온다(SPEC §2.1).
DOCFORM_HEAD = "합의되지 않은 형태의 문서 유입 시도"
DOCFORM_ASK = "그 이름을 맞추지 말고 결정 세션에 묻는다"
# 기각 문단을 가리키는 **예약 낱말**. 검사 33 의 좌변이 이것으로 선다.
#
# 본문의 부분 문자열을 재던 상수를 예약 낱말로 갈음했다. 그 낱말은 기각을 가리키는 머리말에만
# 서는 것이 아니라 산문 안에서도 서므로, 본문을 재면 기각 문단이 아닌 자리에 기각 레지스터의
# 등재가 요구된다. 상수를 지우지 않고 남기는 것은 `HEADING` 블록에서 이 낱말을 골라낼 다른
# 열이 없기 때문이며, 그 항의 규율 ID 를 드는 항이 셋이라 ID 로는 골라지지 않는다. 그래서
# 상수가 남되 **단언이 지키는 부류로 옮겨 간다**(SPEC §2.1).
REJECTION_WORD = "기각한 대체 정의"


def _baseline_block(led: Ledger, pattern: re.Pattern) -> str:
    """`docs/baseline.md` 에서 그 블록의 본문. 파일이나 블록이 없으면 빈 문자열이다."""
    p = led.root / "docs" / "baseline.md"
    m = pattern.search(p.read_text(encoding="utf-8")) if p.is_file() else None
    return m.group(1) if m else ""


def heading_rules(led: Ledger) -> tuple[int | None, dict[str, list[str]]]:
    """`HEADING` 블록이 든 경계와 예약 낱말별 형의 목록."""
    since: int | None = None
    forms: dict[str, list[str]] = {}
    for line in _baseline_block(led, HEADING_BLOCK).splitlines():
        m = HEADING_SINCE_LINE.match(line)
        if m:
            since = int(m.group(1))
            continue
        m = HEADING_LINE.match(line)
        if m:
            forms.setdefault(m.group(1), []).append(m.group(3))
    return since, forms


def heading_matches(form: str, head: str) -> bool:
    """형과 머리말이 같은가.

    `*` 가 없으면 완전일치다. 있으면 그 앞뒤를 접두와 접미로 보고 가변 구간이 한 글자
    이상인지 본다(SPEC §2.1).
    """
    if "*" not in form:
        return form == head
    pre, suf = form.split("*", 1)
    return (head.startswith(pre) and head.endswith(suf)
            and len(head) > len(pre) + len(suf))


def para_heading(para: str) -> str | None:
    """문단의 머리말. 선두에 `**` 가 없으면 머리말이 없으며 판정의 대상이 아니다.

    머리말 안의 줄바꿈은 공백 하나로 접는다. 접지 않으면 두 줄에 걸친 머리말이 형과 결코
    같아지지 않아 그 자리가 전부 위반으로 잡힌다.
    """
    m = PARA_HEAD.match(para)
    return re.sub(r"\s+", " ", m.group(1)).strip() if m else None


def check_33(led: Ledger) -> Report:
    r = Report("33", "wiki33-rejection-registered",
               "경계 안 선언의 docstring 기각 문단마다 기각 레지스터에 for_decl 로 그 선언을 "
               "드는 항목이 있고 그 역도 서는가", "fail")
    since, forms = heading_rules(led)
    if since is None:
        r.bad("docs/baseline.md 의 HEADING 블록에 HEADING_SINCE 가 없다")
        return r
    # 상수가 그 블록에 실재하는지 단언한다. 블록에서 빠지면 좌변이 조용히 비므로, 박아 둔
    # 값이 아니라 단언이 지키는 값이 된다.
    if REJECTION_WORD not in forms:
        r.bad(f"docs/baseline.md 의 HEADING 블록에 예약 낱말 `{REJECTION_WORD}` 이 없다")
        return r
    decls = led.doc_decls()
    inside = [d for d in decls if d.no >= since]

    def has_rejection(d: DocDecl) -> bool:
        """머리말이 그 예약 낱말을 드는 문단을 하나라도 갖는가.

        본문이 아니라 머리말을 본다. 머리말의 뜻과 낱말을 드는지의 판정은 검사 34 가 쓰는
        것과 같은 것을 쓴다(SPEC §2.1).
        """
        return any(h is not None and REJECTION_WORD in h
                   for h in (para_heading(p) for p in d.paras))

    # 좌변. 기각 문단을 하나라도 든 경계 안 선언의 완전 이름.
    left = {d.full: d for d in inside if has_rejection(d)}
    # 우변. `for_decl` 을 든 기각 항목이 가리키는 완전 이름과 그것을 든 항목의 id.
    right: dict[str, list[str]] = {}
    for e in led.reg["rejected"]:
        if e.get("for_decl"):
            right.setdefault(str(e["for_decl"]), []).append(str(e.get("id")))

    missed = ghost = 0
    for full, d in sorted(left.items()):
        if full not in right:
            missed += 1
            r.bad(f"{d.rel}:{d.line}: `{full}` 의 docstring 이 기각 문단을 드는데 기각 "
                  f"레지스터에 그것을 for_decl 로 드는 항목이 없다")
    by_full = {d.full: d for d in decls}
    for full in sorted(right):
        d = by_full.get(full)
        ids = ", ".join(right[full])
        if d is None:
            # 깨진 참조는 경계와 무관하다. 기각 레지스터가 없는 선언을 가리키는 것은 경계
            # 안이든 밖이든 결함이다.
            ghost += 1
            r.bad(f"기각 항목 {ids} 의 for_decl `{full}` 에 해당하는 선언이 리포 소스에 없다")
        elif d.no >= since and not has_rejection(d):
            ghost += 1
            r.bad(f"기각 항목 {ids} 의 for_decl `{full}` 의 docstring 이 기각 문단을 "
                  f"들지 않는다")
            # 이 판정에 좌변과 같은 경계를 건다. 검사의 제목이 「경계 안 선언의 … 그 역도
            # 서는가」이므로 그 역도 그 범위의 역인데, 구현의 좌변만 경계로 좁혀져 있고
            # 우변은 선언 전량을 훑고 있었다. 좌변을 머리말로 좁히기 전에는 본문까지 보았으므로
            # 경계 밖 선언이 우연히 통과했고, 좁히는 순간 그 비대칭이 드러났다(SPEC §2.1).
    # 계수를 맞대지 않는다. 한 선언에 원장 항목이 둘 이상인 것과 기각 문단이 둘 이상인 것이
    # 있어 양쪽 계수가 갈리므로 존재 검사로 둔다(SPEC §2.1).
    outside = sum(1 for d in decls if d.no < since and has_rejection(d))
    r.note(f"유니버스 선언 {len(inside)} · 좌변 {len(left)} · 우변 {len(right)} "
           f"· 좌→우 미포착 {missed} · 우→좌 유령 {ghost} · 경계 HEADING_SINCE={since}")
    r.note(f"경계 밖에서 기각 문단을 든 선언 {outside} "
           f"(소급하지 않기로 한 미등재분의 크기이며 실패가 아니라 보고다)")
    return r


def check_34(led: Ledger) -> Report:
    r = Report("34", "wiki34-heading-form",
               "경계 안 선언의 docstring 문단 머리말이 예약 낱말을 들면 HEADING 블록이 그 "
               "낱말에 둔 형과 같은가", "fail")
    since, forms = heading_rules(led)
    # 블록이 비어 있으면 통과가 아니라 실패다. 가리킬 대상이 없는데 통과시키면 이 검사가
    # 공허해지고, 머리말이 검사 33 의 좌변 앵커이므로 그 탐지도 함께 조용히 빈다.
    if not forms:
        r.bad("docs/baseline.md 의 HEADING 블록이 없거나 비어 있다")
        return r
    if since is None:
        r.bad("docs/baseline.md 의 HEADING 블록에 HEADING_SINCE 가 없다")
        return r
    for word in sorted(forms):
        for form in forms[word]:
            if form.count("*") > 1:
                r.bad(f"HEADING 블록의 형 `{form}` 에 `*` 가 둘 이상이다")
    if r.violations:
        return r

    n_para = n_res = n_free = outside = 0
    for d in led.doc_decls():
        inside = d.no >= since
        for p in d.paras:
            head = para_heading(p)
            if head is None:
                continue
            hit = sorted(w for w in forms if w in head)
            if inside:
                n_para += 1
                if hit:
                    n_res += 1
                else:
                    n_free += 1
            if not hit:
                continue
            # 한 머리말이 예약 낱말 둘을 들면 그 둘의 형을 합집합으로 받는다.
            if any(heading_matches(f, head) for w in hit for f in forms[w]):
                continue
            if inside:
                r.bad(f"{d.rel}:{d.line}: `{d.full}` 의 머리말 `{head}` 가 예약 낱말 "
                      f"{' · '.join(hit)} 에 걸린 형과 다르다")
            else:
                outside += 1
    r.note(f"유니버스 문단 {n_para} · 예약 낱말을 드는 머리말 {n_res} · 자유 {n_free} "
           f"· 예약 낱말 {len(forms)} · 형 {sum(len(v) for v in forms.values())} "
           f"· 경계 HEADING_SINCE={since}")
    r.note(f"경계 밖에서 형을 어기는 머리말 {outside} "
           f"(소급하지 않기로 한 미정리분의 크기이며 실패가 아니라 보고다)")
    return r


def check_35(led: Ledger) -> Report:
    r = Report("35", "wiki35-doc-form",
               "docs/ 아래의 파일과 디렉터리가 DOCFORM 블록이 든 형에 드는가", "fail")
    rows: dict[str, list[tuple[str, str]]] = {}
    for line in _baseline_block(led, DOCFORM_BLOCK).splitlines():
        m = DOCFORM_LINE.match(line)
        if m:
            rows.setdefault(m.group(1), []).append((m.group(2), m.group(3)))
    # 블록이 비어 있으면 통과가 아니라 실패다. 검사 28 과 34 가 같은 요구를 둔다.
    if not rows:
        r.bad("docs/baseline.md 의 DOCFORM 블록이 없거나 비어 있다")
        return r

    # `<ARC>` 를 아크 이름 전량의 택일로 바꾼다. 아크 이름을 블록에 적지 않는 것은 그 값을
    # 레지스터가 닫기 때문이다(SPEC §2.1).
    arc_alt = "|".join(re.escape(a) for a in sorted(led.arcs)) or r"(?!)"
    forms: dict[str, list[tuple[str, str, re.Pattern | None]]] = {}
    for d in sorted(rows):
        for kind, val in rows[d]:
            if kind == "name":
                forms.setdefault(d, []).append((kind, val, None))
            elif kind == "pattern":
                try:
                    rx = re.compile(val.replace("<ARC>", f"(?:{arc_alt})"))
                except re.error as exc:
                    r.bad(f"DOCFORM 블록의 패턴 `{val}` 이 정규식으로 컴파일되지 않는다: {exc}")
                    continue
                forms.setdefault(d, []).append((kind, val, rx))
            else:
                r.bad(f"DOCFORM 블록의 종류 `{kind}` 가 name 도 pattern 도 아니다")
    if r.violations:
        return r

    base = led.root / "docs"
    if not base.is_dir():
        r.bad("docs/ 디렉터리가 없다")
        return r
    # 파일시스템을 훑고 `git ls-files` 를 쓰지 않는다. 추적되지 않은 채 그 자리에 놓인
    # 문서도 유입이고, 추적 여부로 가르면 `.gitignore` 가 가린 것이 함께 가려진다.
    dirs = sorted(p for p in base.rglob("*") if p.is_dir())
    files = sorted(p for p in base.rglob("*") if p.is_file())
    for p in dirs:
        rel = p.relative_to(base).as_posix()
        if rel not in rows:
            r.bad(f"{DOCFORM_HEAD} — docs/{rel}/ 가 허용된 디렉터리가 아니다. {DOCFORM_ASK}")
    per: dict[str, int] = {}
    for p in files:
        rel = p.relative_to(base)
        d = rel.parent.as_posix()
        per[d] = per.get(d, 0) + 1
        items = forms.get(d)
        if items is None:
            continue          # 그 디렉터리가 허용 밖인 것은 위에서 이미 들었다
        # 한 디렉터리에 행이 여럿이면 하나라도 맞으면 통과한다.
        if any(val == rel.name if rx is None else rx.fullmatch(rel.name)
               for _kind, val, rx in items):
            continue
        r.bad(f"{DOCFORM_HEAD} — docs/{rel.as_posix()} 가 그 디렉터리에 허용된 어느 형에도 "
              f"맞지 않는다. {DOCFORM_ASK}")
    r.note(f"docs/ 의 파일 {len(files)} · 디렉터리 {len(dirs)} · 허용 디렉터리 {len(rows)}")
    r.note("디렉터리별 파일: "
           + " · ".join(f"{k} {per[k]}" for k in sorted(per)))
    return r

# 검사 36 이 읽는 무시 파일. 루트의 추적 대상 목록이 그 파일에 이미 실물로 서 있으므로 값
# 정본에 블록을 두지 않고 이 검사가 그 파일을 직접 읽는다. 블록을 두면 같은 목록이 두 자리에
# 살고 한쪽을 고칠 때 나머지가 조용히 낡는다(SPEC §0.2).
IGNORE_FILE = ".gitignore"
IGNORE_ALL = "/*"
IGNORE_REVIVE = re.compile(r"^!/(\S+)$")
# 산문이 든 계수를 읽는 꼴과 한글 수사의 표. 그 대조가 숫자 비교가 아니므로 수사를 값으로
# 읽어야 한다. 표 밖의 수사는 실패로 내며 표를 늘릴지는 사람이 정한다.
IGNORE_PROSE = re.compile(r"([가-힣]+) 파일과 ([가-힣]+) 디렉터리")
KO_NUMERAL = {"하나": 1, "둘": 2, "셋": 3, "넷": 4, "다섯": 5, "여섯": 6, "일곱": 7,
              "여덟": 8, "아홉": 9, "열": 10, "열하나": 11, "열둘": 12, "열셋": 13,
              "열넷": 14, "열다섯": 15, "열여섯": 16, "열일곱": 17, "열여덟": 18,
              "열아홉": 19, "스물": 20}


def check_36(led: Ledger) -> Report:
    r = Report("36", "wiki36-root-surface",
               "무시 파일의 루트 되살림 목록이 /* 뒤에 서고, 그 항마다 루트에 실물이 있으며 "
               "산문이 든 계수와 목록의 계수가 같은가", "fail")
    path = led.root / IGNORE_FILE
    if not path.is_file():
        r.bad(f"{IGNORE_FILE} 이 없다")
        return r
    lines = path.read_text(encoding="utf-8").splitlines()
    revive = [(i, m.group(1)) for i, ln in enumerate(lines, 1)
              for m in [IGNORE_REVIVE.match(ln.strip())] if m]
    # ㉠ 닫힌 형. 그 줄이 사라지면 되살림 줄이 전부 무의미해지고 루트가 조용히 열린다.
    # **이 판정이 이 검사가 사는 자리다.** 양식을 새로 지어내도 자동으로 무시된다는 것이 그
    # 형에 걸려 있으므로, 형이 깨지면 그 보호가 함께 사라진다.
    at = next((i for i, ln in enumerate(lines, 1) if ln.strip() == IGNORE_ALL), None)
    if at is None:
        r.bad(f"{IGNORE_FILE} 에 `{IGNORE_ALL}` 줄이 없다. 루트가 통째로 열려 있다")
    elif revive and at > revive[0][0]:
        r.bad(f"{IGNORE_FILE}:{at}: `{IGNORE_ALL}` 줄이 되살림 목록보다 뒤에 선다")
    if not revive:
        r.bad(f"{IGNORE_FILE} 에 루트 되살림 줄이 없다")
        return r
    # ㉡ 목록의 위생. 파일을 지우거나 이름을 바꾸면 목록이 유령을 든다.
    n_file = n_dir = 0
    for i, item in revive:
        want_dir = item.endswith("/")
        target = led.root / item.rstrip("/")
        if not target.exists():
            r.bad(f"{IGNORE_FILE}:{i}: 되살림 항 `{item}` 의 실물이 루트에 없다")
            continue
        if want_dir and not target.is_dir():
            r.bad(f"{IGNORE_FILE}:{i}: 되살림 항 `{item}` 이 디렉터리 꼴인데 실물이 파일이다")
        elif not want_dir and not target.is_file():
            r.bad(f"{IGNORE_FILE}:{i}: 되살림 항 `{item}` 이 파일 꼴인데 실물이 디렉터리다")
        if want_dir:
            n_dir += 1
        else:
            n_file += 1
    # ㉢ 산문의 계수. 항을 더하면서 산문을 고치지 않는 것을 잡는다.
    comment = " ".join(ln.lstrip("#").strip() for ln in lines
                       if ln.lstrip().startswith("#"))
    m = IGNORE_PROSE.search(comment)
    if m is None:
        r.bad(f"{IGNORE_FILE} 의 주석이 되살림 목록의 계수를 "
              f"「<수사> 파일과 <수사> 디렉터리」 꼴로 들지 않는다")
    else:
        for word, counted, what in ((m.group(1), n_file, "파일"),
                                    (m.group(2), n_dir, "디렉터리")):
            said = KO_NUMERAL.get(word)
            if said is None:
                r.bad(f"{IGNORE_FILE} 의 주석이 든 수사 `{word}` 를 값으로 읽을 수 없다")
            elif said != counted:
                r.bad(f"{IGNORE_FILE} 의 주석이 {what}을 `{word}`({said}) 로 드는데 "
                      f"목록이 든 것은 {counted} 이다")
    r.note(f"되살림 항 {len(revive)} (파일 {n_file} · 디렉터리 {n_dir}) · "
           f"`{IGNORE_ALL}` 줄 {at if at else '없다'}")
    r.note("우변에서 좌변으로 훑지 않는다. 루트에 추적되지 않는 것이 있는 것은 정상이며 "
           "지시서와 엔트리 카드가 그 부류다(SPEC §2.1)")
    return r


# 검사 37 이 읽는 집행 문면의 원장 계수 표. 좌변이 그 표의 행이고 우변이 레지스터 배열의
# 길이다. 그 문면이 「계수는 손으로 세지 않고 검증기의 출력에서 읽는다」를 관례로만 들고
# 있어서, 병합하는 회차가 그 표를 고치지 않아도 아무것도 걸리지 않았다(SPEC §2.1).
LEDGER_COUNT_DOC = "CLAUDE.md"
LEDGER_COUNT_HEAD = "| 레지스터 | entry |"
LEDGER_COUNT_ROW = re.compile(r"^\|\s*(\w+)\s*\|\s*(\d+)\s*\|$")


def check_37(led: Ledger) -> Report:
    r = Report("37", "wiki37-claude-ledger-count",
               "집행 문면의 원장 계수 표가 레지스터 넷을 전부 들고 행마다 적힌 수가 그 "
               "레지스터의 배열 길이와 같은가", "fail")
    path = led.root / LEDGER_COUNT_DOC
    if not path.is_file():
        r.bad(f"{LEDGER_COUNT_DOC} 이 없다")
        return r
    lines = path.read_text(encoding="utf-8").splitlines()
    head = [i for i, ln in enumerate(lines) if ln.strip() == LEDGER_COUNT_HEAD]
    # 표가 없으면 통과가 아니라 실패다. 검사 28 과 34 와 35 가 같은 요구를 둔다.
    if len(head) != 1:
        r.bad(f"{LEDGER_COUNT_DOC} 에 원장 계수 표의 머리 `{LEDGER_COUNT_HEAD}` 가 "
              f"{len(head)}개다")
        return r
    said: dict[str, int] = {}
    for ln in lines[head[0] + 2:]:
        m = LEDGER_COUNT_ROW.match(ln.strip())
        if not m:
            break
        said[m.group(1)] = int(m.group(2))
    # 우변을 새로 세지 않고 검증기의 수집기를 부른다. 출력의 머리가 싣는 계수와 같은 자리다.
    real = {name: len(led.reg[name]) for name in REGISTERS}
    for name in sorted(set(said) | set(real)):
        if name not in said:
            r.bad(f"{LEDGER_COUNT_DOC} 의 원장 계수 표가 레지스터 `{name}` 의 행을 들지 않는다")
        elif name not in real:
            r.bad(f"{LEDGER_COUNT_DOC} 의 원장 계수 표가 레지스터가 아닌 `{name}` 의 행을 든다")
        elif said[name] != real[name]:
            r.bad(f"{LEDGER_COUNT_DOC} 의 원장 계수 표가 `{name}` 을 {said[name]} 로 드는데 "
                  f"그 배열의 길이가 {real[name]} 이다")
    r.note("표의 행 " + (" · ".join(f"{k} {said[k]}" for k in sorted(said)) or "없다"))
    r.note("배열의 길이 " + " · ".join(f"{k} {real[k]}" for k in sorted(real)))
    return r


def run(root: Path, arc_close: str | None, quiet: bool) -> int:
    led = Ledger(root)
    reports = [
        check_01(led), check_02(led), check_03(led), check_03a(led),
        check_04a(led), check_05(led), check_06(led), check_07(led), check_08(led),
        check_09(led), check_10(led), check_11(led), check_12(led), check_13(led),
        check_14(led), check_15(led), check_23(led), check_24(led), check_25(led),
        check_16(led), check_17(led), check_18(led), check_19(led),
        check_20(led, arc_close), check_21(led, arc_close),
        check_26(led), check_27(led),
        check_28(led), check_31(led), check_32(led),
        check_33(led), check_34(led), check_35(led),
        check_36(led), check_37(led),
        check_29(led, arc_close), check_30(led),
    ]
    order = {n: i for i, n in enumerate(ORDER)}
    reports.sort(key=lambda r: order[r.number])

    print(f"원장 검증기 — 뿌리 {root}")
    counts = {name: len(led.reg[name]) for name in REGISTERS}
    print("레지스터 entry: " + " · ".join(f"{k} {v}" for k, v in counts.items())
          + f" · 총계 {sum(counts.values())}")
    print()
    for r in reports:
        r.emit(quiet)

    failed = [r for r in reports if r.failed]
    print()
    ran = sum(1 for r in reports if r.ran)
    print(f"검사 {len(reports)}개 가운데 {ran}개 수행, 실패 {len(failed)}개")
    if failed:
        print("실패한 검사: " + ", ".join(f"{r.number}({r.step})" for r in failed))
        print("\033[1;31m원장 검증 실패\033[0m")
        return 1
    print("\033[1;32m원장 검증 전량 통과\033[0m")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description="원장 검증기 (SPEC.md §2 의 검사 서른일곱)")
    ap.add_argument("--root", default=None, help="원장을 읽을 뿌리. 음성 대조가 사본을 지목한다")
    ap.add_argument("--arc-close", default=None, metavar="ARC",
                    help="아크 종료 시에만 도는 검사 20·21·29 를 그 아크에 대해 돌린다")
    ap.add_argument("--quiet", action="store_true", help="보고 줄을 줄인다")
    args = ap.parse_args()
    root = Path(args.root).resolve() if args.root \
        else Path(__file__).resolve().parent.parent
    return run(root, args.arc_close, args.quiet)


if __name__ == "__main__":
    sys.exit(main())
