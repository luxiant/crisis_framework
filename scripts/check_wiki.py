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

ID_FORM = re.compile(r"^CF-(\d+)$")
CF_TOKEN = re.compile(r"(?<![0-9A-Za-z-])CF-(\d+)(?![0-9A-Za-z-])")
DD_TOKEN = re.compile(r"--\s*DD:\s*(\S+)")
STEP_CALL = re.compile(r"^\s*step\s+\"([^\"]*)\"")
EXTRACTION_NO = re.compile(r"^E-(\d+)$")
ARTIFACT_PATH = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._/-]*$")


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
        """`verify.sh` 가 선언한 단계 id. `step "<id> …"` 호출의 첫 토큰이다."""
        path = self.root / "scripts" / "verify.sh"
        if not path.is_file():
            return []
        out = []
        for line in path.read_text(encoding="utf-8").splitlines():
            m = STEP_CALL.match(line)
            if m:
                arg = m.group(1).strip()
                if arg:
                    out.append(arg.split()[0])
        return out

    def dd_markers(self) -> list[tuple[Path, int, str]]:
        """Lean 파일의 `-- DD:<id>` 표지 전량."""
        out = []
        for f in self.lean_files:
            for i, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
                m = DD_TOKEN.search(line)
                if m:
                    out.append((f, i, m.group(1)))
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
    r = Report("3", "wiki3-origin-phase", "origin.phase 가 그 아크의 phases 에 있는가", "fail")
    for e, arc, phase in _undeclared(led):
        if _granting_patch(led, arc, phase) is None:
            r.bad(f"{e.get('id')}: 페이즈 `{phase}` 가 아크 `{arc}` 에 선언되지 않았고 패치도 없다")
        else:
            r.note(f"{e.get('id')}: 페이즈 `{phase}` 가 미선언이나 패치가 권한을 준다")
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


def check_04(led: Ledger) -> Report:
    r = Report("4", "wiki4-patch-grant",
               "3 이 실패할 때 arcs.json 의 patches 가 그 페이즈에 권한을 주는가", "fail")
    und = _undeclared(led)
    if not und:
        r.note("검사 3 이 잡은 미선언 페이즈가 없어 이 검사의 대상이 비었다")
    for e, arc, phase in und:
        if _granting_patch(led, arc, phase) is None:
            r.bad(f"{e.get('id')}: 페이즈 `{phase}` 를 늘리는 패치가 arcs.json 에 없다")
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
               "Lean 의 DD: 표지가 실재하고 폐기되지 않은 id 를 가리키는가", "fail")
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
               "statement·basis 의 규율 ID 토큰이 어느 항목의 names 에 실재하고 폐기되지 않았는가",
               "fail")
    total = 0
    for _, e in led.entries:
        related = set(e.get("related", []) or [])
        for f in ("statement", "basis"):
            for m in RULE_TOKEN.finditer(str(e.get(f) or "")):
                tok = m.group(0)
                total += 1
                owner = led.name_owner.get(tok)
                if owner is None:
                    r.bad(f"{e.get('id')}: {f} 의 `{tok}` 이 어느 항목의 names 에도 없다")
                elif owner in led.dead and owner not in related:
                    r.bad(f"{e.get('id')}: {f} 가 폐기된 규율 `{tok}`({owner}) 를 "
                          f"related 에 적지 않고 든다")
    r.note(f"규율 ID 토큰 {total}건을 봤다. 계열은 {list(RULE_SERIES)}")
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


ORDER = ["1", "2", "3", "3-a", "4", "4-a", "5", "6", "7", "8", "9", "10",
         "11", "12", "13", "14", "15", "23", "16", "17", "18", "19", "20", "21"]


def run(root: Path, arc_close: str | None, quiet: bool) -> int:
    led = Ledger(root)
    reports = [
        check_01(led), check_02(led), check_03(led), check_03a(led), check_04(led),
        check_04a(led), check_05(led), check_06(led), check_07(led), check_08(led),
        check_09(led), check_10(led), check_11(led), check_12(led), check_13(led),
        check_14(led), check_15(led), check_23(led),
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
