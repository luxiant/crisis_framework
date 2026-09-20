#!/usr/bin/env python3
"""원장 검증기.

`docs/decisions/SPEC.md` §2 의 검사 스물넷을 돈다. 실패시키는 것 열여덟과 보고만 하는 것 넷과
아크 종료 시에만 도는 것 둘이다. 검사마다 단계 id 를 선언하고 그것을 출력에 낸다.

    python3 scripts/check_wiki.py [--root PATH] [--arc-close ARC] [--quiet]

`--root` 는 원장과 부속 파일을 읽을 뿌리를 바꾼다. 음성 대조가 사본에 위반을 주입한 뒤 그
사본을 뿌리로 지목하므로, 이 선택지가 없으면 주입이 원장을 건드리게 된다.

`--arc-close` 는 아크 종료 시에만 도는 검사 20 과 21 을 그 아크에 대해 돌린다. 그것을 주지
않으면 둘은 수행되지 않았음을 출력에 내고 판정에 들지 않는다.

**이 검증기를 고쳐 통과시키지 않는다.** 검사가 실패하면 그 실패가 산출물이다(SPEC §4).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

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
RULE_TOKEN = re.compile(
    r"(?<![0-9A-Za-z-])(" + "|".join(RULE_SERIES) + r")-(\d+)(?![0-9A-Za-z-])")

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
TOP_DECL = re.compile(r"^(def|theorem|inductive|structure)\s+([^\s({\[:]+)")


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

        # 규율 ID → 그것을 드는 항목의 원장 id
        self.name_owner: dict = {}
        for _, e in self.entries:
            for n in e.get("names", []) or []:
                self.name_owner.setdefault(n, e["id"])

        self.verify_steps = self._read_verify_steps()
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
    r = Report("5", "wiki5-closed-arc", "status: closed 인 아크에 항목이 드는가", "fail")
    for _, e in led.entries:
        arc = (e.get("origin") or {}).get("arc")
        a = led.arcs.get(arc)
        if a is not None and a.get("status") == "closed":
            r.bad(f"{e.get('id')}: 닫힌 아크 `{arc}` 로 항목이 쓰였다")
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
    # 원장 안. 폐기 레코드 자신의 target 과 original 은 제외한다(SPEC §2.1).
    for name, e in led.entries:
        for ref in e.get("related", []) or []:
            if ref in dead:
                r.bad(f"{e.get('id')}: related 가 폐기된 {ref} 를 든다")
        rw = e.get("reopen_when")
        if isinstance(rw, dict) and rw.get("ref") in dead:
            r.bad(f"{e.get('id')}: reopen_when.ref 가 폐기된 {rw.get('ref')} 를 든다")
        if name == "retirements":
            continue
        for f in ("statement", "basis", "reason", "candidate", "for"):
            for m in CF_TOKEN.finditer(str(e.get(f) or "")):
                if m.group(0) in dead:
                    r.bad(f"{e.get('id')}: {f} 가 폐기된 {m.group(0)} 를 든다")
    # Lean 의 DD: 표지
    for f, ln, ref in led.dd_markers():
        if ref in dead:
            r.bad(f"{f.relative_to(led.root)}:{ln}: DD: 표지가 폐기된 {ref} 를 가리킨다")
    # docs/ 산문
    for f in led.doc_files:
        for i, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
            for m in CF_TOKEN.finditer(line):
                if m.group(0) in dead:
                    r.bad(f"{f.relative_to(led.root)}:{i}: 산문이 폐기된 {m.group(0)} 를 든다")
    r.note(f"폐기된 id {len(dead)}건을 유니버스로 훑었다")
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
               "폐기됐으면 그 폐기 레코드를 related 가 드는가",
               "fail")
    total = 0
    exempt = 0
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
                    if retirer in related:
                        pass
                    elif first_load:
                        exempt += 1
                    else:
                        r.bad(f"{e.get('id')}: {f} 가 폐기된 규율 `{tok}`({owner}) 를 "
                              f"그것을 폐기한 레코드 {retirer} 를 related 에 적지 않고 든다")
    r.note(f"규율 ID 토큰 {total}건을 봤다. 계열은 {list(RULE_SERIES)}")
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
               "Lean 의 최상위 def·theorem·inductive·structure 선언마다 DD: 표지가 붙었는가",
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


def check_16(led: Ledger) -> Report:
    r = Report("16", "wiki16-trigger-fired", "reopen_when 이 충족된 이연 항목", "report")
    fired = []
    for e in led.reg["deferred"]:
        rw = e.get("reopen_when")
        if not isinstance(rw, dict):
            continue
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
        elif kind in ("arc_phase", "blocking"):
            a = led.arcs.get(ref)
            hit = bool(a) and a.get("status") == "open"
            why = f"아크 `{ref}` 가 열려 있다"
        if hit:
            fired.append(f"{e.get('id')} ({kind}) — {why}")
    r.note(f"발화한 트리거 {len(fired)}건")
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
    for e in led.reg["deferred"]:
        rw = e.get("reopen_when")
        if isinstance(rw, dict) and rw.get("kind") == "blocking":
            rows.setdefault(str(rw.get("ref")), []).append(e.get("id"))
    r.note(f"blocking 구멍 {sum(len(v) for v in rows.values())}건, 아크 {len(rows)}개")
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
               "그 아크에 걸린 blocking 구멍마다 발화했거나 해소됐거나 이월됐는가", "arc_close")
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
        r.bad(f"{e.get('id')}: 아크 `{arc}` 의 blocking 구멍이 발화도 해소도 이월도 되지 않았다")
    r.note(f"아크 `{arc}` 의 blocking 구멍 {n}건")
    return r


ORDER = ["1", "2", "3", "3-a", "4-a", "5", "6", "7", "8", "9", "10",
         "11", "12", "13", "14", "15", "23", "24", "25", "16", "17", "18", "19", "20", "21"]


def run(root: Path, arc_close: str | None, quiet: bool) -> int:
    led = Ledger(root)
    reports = [
        check_01(led), check_02(led), check_03(led), check_03a(led),
        check_04a(led), check_05(led), check_06(led), check_07(led), check_08(led),
        check_09(led), check_10(led), check_11(led), check_12(led), check_13(led),
        check_14(led), check_15(led), check_23(led), check_24(led), check_25(led),
        check_16(led), check_17(led), check_18(led), check_19(led),
        check_20(led, arc_close), check_21(led, arc_close),
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
    ap = argparse.ArgumentParser(description="원장 검증기 (SPEC.md §2 의 검사 스물넷)")
    ap.add_argument("--root", default=None, help="원장을 읽을 뿌리. 음성 대조가 사본을 지목한다")
    ap.add_argument("--arc-close", default=None, metavar="ARC",
                    help="아크 종료 시에만 도는 검사 20·21 을 그 아크에 대해 돌린다")
    ap.add_argument("--quiet", action="store_true", help="보고 줄을 줄인다")
    args = ap.parse_args()
    root = Path(args.root).resolve() if args.root \
        else Path(__file__).resolve().parent.parent
    return run(root, args.arc_close, args.quiet)


if __name__ == "__main__":
    sys.exit(main())
