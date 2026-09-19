#!/usr/bin/env python3
"""원장 검증기의 음성 대조.

`docs/decisions/SPEC.md` §2 의 주입 시험 칸대로 검사 스물넷 각각에 위반을 주입하고, 그 검사가
주입을 잡는지 본다. **주입은 사본에서 하고 원장을 건드리지 않는다.** 사본은 임시 디렉터리에
만들며 검사가 끝나면 지운다.

    python3 Scratch/wiki_negative_control.py [--keep]

판정 기준이 둘로 갈린다. 실패시키는 검사(열여덟과 아크 종료 둘)는 **주입한 사본에서 FAIL 이
나고 기준선에 없던 위반 줄이 새로 나야** 통과다. 기준선에서 이미 실패하는 검사가 있으므로
FAIL 여부만 보면 공허해지기 때문이다. 보고만 하는 검사 넷은 실패시키지 않으므로 **보고 줄이
기준선과 달라지고 주입한 항목이 그 안에 잡혀야** 통과다.
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CHECKER = ROOT / "scripts" / "check_wiki.py"
ANSI = re.compile(r"\x1b\[[0-9;]*m")


# ------------------------------------------------------------------ 사본과 실행

def make_copy(dst: Path) -> Path:
    """빌드 산출과 git 메타를 뺀 리포 사본을 만든다."""
    shutil.copytree(
        ROOT, dst,
        ignore=shutil.ignore_patterns(".lake", ".git", "__pycache__"))
    return dst


def run_checker(root: Path, arc_close: str | None = None) -> dict:
    """검증기를 사본에 돌리고 검사별 판정과 줄을 뽑는다."""
    cmd = [sys.executable, str(CHECKER), "--root", str(root)]
    if arc_close:
        cmd += ["--arc-close", arc_close]
    p = subprocess.run(cmd, capture_output=True, text=True)
    out = ANSI.sub("", p.stdout)
    res: dict = {"rc": p.returncode, "raw": out, "checks": {}}
    cur = None
    for line in out.splitlines():
        m = re.match(r"\[check:(\S+)\] (OK|FAIL|REPORT|SKIP)\s+검사 (\S+) — (.*)", line)
        if m:
            cur = m.group(3)
            res["checks"][cur] = {"step": m.group(1), "verdict": m.group(2),
                                  "violations": [], "notes": []}
            continue
        if cur and line.startswith("    · "):
            res["checks"][cur]["violations"].append(line[6:])
        elif cur and line.startswith("    - "):
            res["checks"][cur]["notes"].append(line[6:])
    return res


# ------------------------------------------------------------------ 주입 도구

def load(root: Path, reg: str) -> dict:
    return json.loads((root / "docs" / "decisions" / f"{reg}.json").read_text(encoding="utf-8"))


def save(root: Path, reg: str, doc: dict) -> None:
    (root / "docs" / "decisions" / f"{reg}.json").write_text(
        json.dumps(doc, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")


def arcs(root: Path) -> dict:
    return json.loads((root / "docs" / "arcs.json").read_text(encoding="utf-8"))


def save_arcs(root: Path, doc: dict) -> None:
    (root / "docs" / "arcs.json").write_text(
        json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def pick(root: Path, reg: str, pred) -> dict:
    for e in load(root, reg)[reg]:
        if pred(e):
            return e
    raise SystemExit(f"주입 대상을 찾지 못했다: {reg}")


def edit(root: Path, reg: str, eid: str, fn) -> None:
    doc = load(root, reg)
    for e in doc[reg]:
        if e["id"] == eid:
            fn(e)
            break
    else:
        raise SystemExit(f"{eid} 가 {reg} 에 없다")
    save(root, reg, doc)


def deferred_stub(eid: str, reopen) -> dict:
    return {
        "id": eid,
        "origin": {"arc": "charter", "phase": "charter-6",
                   "kind": "decision_session", "date": "2026-09-19"},
        "names": [f"Z-{eid.split('-')[1]}"],
        "statement": "음성 대조가 주입한 항이다.",
        "basis": "음성 대조가 주입한 항이다.",
        "layer": "meta",
        "reopen_when": reopen,
        "related": [],
    }


# ------------------------------------------------------------------ 주입 정의

def inj_01(root):
    doc = load(root, "rejected")
    first = load(root, "decisions")["decisions"][0]
    doc["rejected"].append({"id": first["id"], "origin": first["origin"],
                            "candidate": "주입", "reason": "주입", "for": "주입",
                            "statement": "주입", "basis": "주입", "related": []})
    save(root, "rejected", doc)


def inj_02(root):
    edit(root, "decisions", "CF-24", lambda e: e["origin"].__setitem__("arc", "nosucharc"))


def inj_03(root):
    edit(root, "decisions", "CF-24", lambda e: e["origin"].__setitem__("phase", "charter-99"))


def inj_03a(root):
    edit(root, "decisions", "CF-24", lambda e: e["origin"].__setitem__("phase", "primary-1"))


def inj_04(root):
    edit(root, "decisions", "CF-24", lambda e: e["origin"].__setitem__("phase", "charter-9"))


def inj_04a(root):
    doc = arcs(root)
    doc["patches"][0]["from"] = "charter-99"
    save_arcs(root, doc)


def inj_05(root):
    def f(e):
        e["origin"]["arc"] = "primary"
        e["origin"]["phase"] = "primary-1"
    edit(root, "decisions", "CF-24", f)


def inj_06(root):
    edit(root, "decisions", "CF-24", lambda e: e.__setitem__("tier", "tactical"))


def inj_07(root):
    inv = pick(root, "decisions", lambda e: e.get("tier") == "invariant")
    edit(root, "decisions", inv["id"], lambda e: e.__setitem__("check", "step9-nonexistent"))


def inj_08(root):
    doc = load(root, "retirements")
    first = dict(doc["retirements"][0])
    first["id"] = "CF-9008"
    doc["retirements"].append(first)
    save(root, "retirements", doc)


def inj_09(root):
    doc = load(root, "retirements")
    doc["retirements"][0]["reason"] = ""
    save(root, "retirements", doc)


def inj_10(root):
    dead = load(root, "retirements")["retirements"][0]["target"]
    edit(root, "decisions", "CF-24", lambda e: e.__setitem__("related", [dead]))


def inj_11(root):
    tgt = pick(root, "deferred", lambda e: isinstance(e.get("reopen_when"), dict))
    edit(root, "deferred", tgt["id"], lambda e: e["reopen_when"].__setitem__("kind", ""))


def inj_12(root):
    tgt = pick(root, "deferred",
               lambda e: isinstance(e.get("reopen_when"), dict)
               and e["reopen_when"].get("kind") == "arc_phase")
    edit(root, "deferred", tgt["id"],
         lambda e: e["reopen_when"].__setitem__("ref", "아크가 아닌 문자열"))


def inj_13(root):
    f = root / "CrisisFramework" / "Glossary" / "Core.lean"
    f.write_text(f.read_text(encoding="utf-8") + "\n-- DD:CF-9999\n", encoding="utf-8")


def inj_14(root):
    d = pick(root, "decisions", lambda e: e.get("layer") == "definition")
    f = root / "CrisisFramework" / "Accounting" / "Aggregation.lean"
    f.write_text(f.read_text(encoding="utf-8") + f"\n-- DD:{d['id']}\n", encoding="utf-8")


def inj_15(root):
    doc = load(root, "decisions")
    src = next(e for e in doc["decisions"] if e.get("names"))
    tgt = next(e for e in doc["decisions"] if e["id"] != src["id"] and e.get("names"))
    tgt["names"] = list(src["names"])
    save(root, "decisions", doc)


def inj_23(root):
    """폐기된 규율 ID 를 근거로 적는다. related 에 적지 않으므로 유령이다.

    첫 적재(`charter-6`)는 `related` 요건을 면하므로 주입은 그 뒤의 페이즈로 선 항목이어야
    한다. 그래서 `charter-7` 로 선 항목을 새로 세워 거기에 지목을 넣는다."""
    dead_id = load(root, "retirements")["retirements"][0]["target"]
    dead_names = None
    for reg in ("decisions", "deferred"):
        for e in load(root, reg)[reg]:
            if e["id"] == dead_id:
                dead_names = e.get("names")
    if not dead_names:
        raise SystemExit("폐기된 항목이 규율 ID 를 들지 않아 검사 23 의 주입 대상이 없다")
    tok = dead_names[0]
    doc = load(root, "decisions")
    doc["decisions"].append({
        "id": "CF-9023",
        "origin": {"arc": "charter", "phase": "charter-7",
                   "kind": "decision_session", "date": "2026-09-19"},
        "names": ["Z-9023"],
        "statement": "음성 대조가 주입한 항이다.",
        "basis": f"음성 대조가 주입한 항이며 {tok} 을 근거로 든다.",
        "tier": "finding",
        "layer": "meta",
        "related": [],
    })
    save(root, "decisions", doc)
    return tok


def inj_16(root):
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(
        "CF-9016", {"kind": "artifact", "ref": "docs/arcs.json"}))
    save(root, "deferred", doc)


def inj_17(root):
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub("CF-9017", None))
    save(root, "deferred", doc)


def inj_18(root):
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(
        "CF-9018", {"kind": "blocking", "ref": "network"}))
    save(root, "deferred", doc)


def inj_19(root):
    doc = load(root, "decisions")
    doc["decisions"] = [e for e in doc["decisions"] if e["id"] != "CF-100"]
    save(root, "decisions", doc)


def inj_20(root):
    """해소도 이관도 되지 않은 구멍을 든 채 아크를 닫는다.

    폐기된 항은 해소된 것이라 대상이 되지 못하므로 살아 있는 항을 고른다."""
    dead = {r["target"] for r in load(root, "retirements")["retirements"]}
    hole = pick(root, "deferred",
                lambda e: e.get("reopen_when") is None and e["id"] not in dead)
    doc = arcs(root)
    for a in doc["arcs"]:
        if a["name"] == "charter":
            a["holes"] = [hole["id"]]
    save_arcs(root, doc)


def inj_21(root):
    """발화도 해소도 이월도 되지 않은 blocking 구멍을 든 채 아크를 닫는다."""
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(
        "CF-9021", {"kind": "blocking", "ref": "charter"}))
    save(root, "deferred", doc)
    a = arcs(root)
    for x in a["arcs"]:
        if x["name"] == "charter":
            x["holes"] = ["CF-9021"]
    save_arcs(root, a)


CASES = [
    ("1",   "wiki1-id-unique",             "같은 id 를 두 파일에 넣는다",                  inj_01,  None, None),
    ("2",   "wiki2-origin-arc",            "없는 아크명을 적는다",                        inj_02,  None, None),
    ("3",   "wiki3-origin-phase",          "선언되지 않은 페이즈를 적는다",                inj_03,  None, None),
    ("3-a", "wiki3a-phase-form",           "다른 아크의 페이즈명을 적는다",                inj_03a, None, None),
    ("4",   "wiki4-patch-grant",           "패치 없이 페이즈를 늘린다",                    inj_04,  None, None),
    ("4-a", "wiki4a-patch-from",           "없는 페이즈를 from 에 적는다",                 inj_04a, None, None),
    ("5",   "wiki5-closed-arc",            "닫힌 아크로 항목을 쓴다",                      inj_05,  None, None),
    ("6",   "wiki6-tier-vocab",            "tactical 을 적는다",                           inj_06,  None, None),
    ("7",   "wiki7-invariant-check",       "없는 단계명을 적는다",                         inj_07,  None, None),
    ("8",   "wiki8-retire-target",         "같은 대상을 두 번 폐기한다",                   inj_08,  None, None),
    ("9",   "wiki9-retire-reason",         "reason 을 비운다",                             inj_09,  None, None),
    ("10",  "wiki10-ghost-ref",            "폐기된 id 를 related 에 넣는다",               inj_10,  None, None),
    ("11",  "wiki11-reopen-kind",          "kind 를 비운다",                               inj_11,  None, None),
    ("12",  "wiki12-reopen-ref",           "아크가 아닌 문자열을 arc_phase 에 적는다",     inj_12,  None, None),
    ("13",  "wiki13-dd-target",            "없는 id 를 주석에 적는다",                     inj_13,  None, None),
    ("14",  "wiki14-dd-layer",             "회계층 파일에서 정의층 항목을 지목한다",       inj_14,  None, None),
    ("15",  "wiki15-names-unique",         "같은 규율 ID 를 두 항목에 적는다",             inj_15,  None, None),
    ("23",  "wiki23-rule-ghost",           "폐기된 규율 ID 를 근거로 적는다",              inj_23,  None, None),
    ("16",  "wiki16-trigger-fired",        "충족된 트리거를 등재한다",                     inj_16,  "CF-9016", None),
    ("17",  "wiki17-reopen-null",          "reopen_when 을 null 로 둔 항을 늘린다",        inj_17,  "CF-9017", None),
    ("18",  "wiki18-blocking-disposition", "blocking 구멍을 등재한다",                     inj_18,  "CF-9018", None),
    ("19",  "wiki19-id-gap",               "항목을 지워 결번을 만든다",                    inj_19,  "CF-100",  None),
    ("20",  "wiki20-arc-holes",            "해소도 이관도 안 된 구멍을 든 채 닫는다",      inj_20,  None, "charter"),
    ("21",  "wiki21-arc-blocking",         "발화도 해소도 이월도 안 된 blocking 을 든다",  inj_21,  None, "charter"),
]


def main() -> int:
    ap = argparse.ArgumentParser(description="원장 검증기의 음성 대조")
    ap.add_argument("--keep", action="store_true", help="사본을 지우지 않는다")
    args = ap.parse_args()

    tmp = Path(tempfile.mkdtemp(prefix="wiki-nc-"))
    rows = []
    try:
        base_plain = run_checker(make_copy(tmp / "base"))
        base_arc = run_checker(make_copy(tmp / "base-arc"), arc_close="charter")

        for num, step, desc, fn, marker, arc in CASES:
            work = make_copy(tmp / f"case-{num.replace('-', '')}")
            extra = fn(work)
            got = run_checker(work, arc_close=arc)
            base = base_arc if arc else base_plain
            b = base["checks"].get(num, {"verdict": "?", "violations": [], "notes": []})
            g = got["checks"].get(num, {"verdict": "?", "violations": [], "notes": []})

            if num in ("16", "17", "18", "19"):
                new_notes = [n for n in g["notes"] if n not in b["notes"]]
                hit = any((marker or "") in n for n in new_notes)
                ok = bool(new_notes) and hit
                detail = new_notes[0] if new_notes else "보고 줄에 변화 없음"
            else:
                new_v = [v for v in g["violations"] if v not in b["violations"]]
                ok = g["verdict"] == "FAIL" and bool(new_v)
                detail = new_v[0] if new_v else "새 위반 줄 없음"
                if extra:
                    detail = detail.replace(str(extra), str(extra))
            rows.append((num, step, desc, b["verdict"], g["verdict"], ok, detail))
            shutil.rmtree(work)
    finally:
        if not args.keep:
            shutil.rmtree(tmp, ignore_errors=True)
        else:
            print(f"사본을 남겼다: {tmp}")

    print()
    print("| 검사 | 단계 id | 주입한 위반 | 기준선 | 주입 후 | 잡았는가 |")
    print("|---|---|---|---|---|---|")
    for num, step, desc, bv, gv, ok, _ in rows:
        print(f"| {num} | `{step}` | {desc} | {bv} | {gv} | {'예' if ok else '**아니오**'} |")
    print()
    for num, step, desc, bv, gv, ok, detail in rows:
        print(f"검사 {num}: {detail}")
    bad = [r for r in rows if not r[5]]
    print()
    print(f"검사 {len(rows)}개 가운데 주입을 잡은 것 {len(rows)-len(bad)}개, 놓친 것 {len(bad)}개")
    if bad:
        print("놓친 검사: " + ", ".join(r[0] for r in bad))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
