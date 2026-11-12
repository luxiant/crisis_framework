#!/usr/bin/env python3
"""원장 검증기의 음성 대조.

`docs/decisions/SPEC.md` §2 의 주입 시험 칸이 든 검사마다 위반을 주입하고, 그 검사가 주입을
잡는지 본다. **주입은 사본에서 하고 원장을 건드리지 않는다.** 사본은 임시 디렉터리에
만들며 검사가 끝나면 지운다.

    python3 scripts/wiki_negative_control.py [--keep]

판정 기준이 셋으로 갈린다. 실패시키는 검사와 아크 종료 검사는 **주입한 사본에서 FAIL 이 나고
기준선에 없던 위반 줄이 새로 나야** 통과다. 기준선에서 이미 실패하는 검사가 있으므로 FAIL
여부만 보면 공허해지기 때문이다. 보고만 하는 검사는 실패시키지 않으므로 **보고 줄이 기준선과
달라지고 주입한 항목이 그 안에 잡혀야** 통과다.

**머리 문면이 계수를 들지 않는다.** 몇을 드는지의 정본은 `CASES` 이고 그 계수는 이 스크립트의
출력이 낸다. 머리 문면이 계수를 들면 검사가 늘 때마다 낡는데 그 낡음을 어느 검사도 보지 않으며,
`collateral-5` 가 받은 판에서 실제로 한 수가 어긋나 있었다.

셋째는 **잡히지 않아야 하는 항**이며 `CASES` 의 여섯째 자리에 `"nocatch"` 를 둔 항이 그것이다.
새 위반 줄이 나지 않아야 통과다. 검사 5 가 날짜로 가르므로 닫힌 날 이전 날짜의 항목은 잡히지
않아야 하고, 그 방향을 재지 않으면 「날짜를 보지 않고 여전히 전량을 잡는다」와 갈리지 않는다.
"""

from __future__ import annotations

import argparse
import json
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import types
from datetime import date as _date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_wiki          # noqa: E402  주입 대상을 검증기의 수집기로 고른다
import wiki_common         # noqa: E402  둘 이상의 검사가 쓰는 설비가 그 모듈에 산다
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


def id_no(cf) -> int:
    """`CF-<n>` 의 번호. 형식이 아니면 -1 이다.

    검사 10 이 지목한 항목과 폐기 레코드의 번호로 가르므로, 그 검사를 겨누는 주입이 같은 가름을
    쓰려면 여기서도 번호를 읽어야 한다."""
    m = re.match(r"CF-(\d+)$", str(cf or ""))
    return int(m.group(1)) if m else -1


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


def inj_03p(root):
    """권한을 준 패치를 지운다.

    검사 4 를 폐기하고 검사 3 하나로 두었으므로(SPEC §2.1) 이 검사가 잡아야 할 것이 둘이다.
    앞은 선언되지 않은 페이즈를 적는 것이고 뒤가 이것이다. 먼저 미선언 페이즈에 권한을 주는
    패치를 세워 정당한 상태를 만들고, 그 패치만 걷어 낸다.

    **미선언 페이즈의 이름을 박지 않고 유도한다.** 이 주입은 그 이름을 `charter-11` 로 박아
    두었는데, 그 뒤 `charter` 아크가 `charter-11` 을 선언하면서 조건이 서지 않게 되었다.
    `collateral-5` 가 받은 판에서 이미 죽어 있었고, 그래서 검사 3 의 이 갈래가 음성 대조를 받지
    않는 상태로 여러 회차를 지났다. 그 죽음은 「새 위반 줄 없음」으로만 보여 유도의 결함과 검사의
    결함이 그 문면에서 갈리지 않는다.

    **단언이 그 유도를 지킨다.** 선언된 페이즈의 뒤 번호 가운데 가장 큰 것에 1 을 더해 이름을
    짓고, 그 이름이 그 아크의 `phases` 에 없음을 주입 전에 단언한다. 아크가 페이즈를 더 선언해도
    이름이 함께 뒤로 가므로 유도가 스스로 유지된다."""
    a = arcs(root)
    charter = next(x for x in a["arcs"] if x["name"] == "charter")
    declared = wiki_common.arc_phase_names(charter)
    phase = f"charter-{max(int(p.rsplit('-', 1)[1]) for p in declared) + 1}"
    if phase in declared:
        raise SystemExit(f"유도한 페이즈 `{phase}` 가 이미 선언돼 있어 주입이 조건을 만들지 못한다")
    edit(root, "decisions", "CF-24", lambda e: e["origin"].__setitem__("phase", phase))
    doc = arcs(root)
    doc["patches"].append({
        "arc": "charter", "op": "add", "from": None, "phase": phase,
        "what": "", "why": "음성 대조가 세운 항이다.",
        "origin": {"arc": "charter", "phase": "charter-8",
                   "kind": "decision_session", "date": "2026-09-20"},
    })
    save_arcs(root, doc)
    # 여기까지가 정당한 상태다. 아래가 주입이며 권한을 준 패치를 지운다.
    doc = arcs(root)
    doc["patches"] = [q for q in doc["patches"] if q.get("phase") != phase]
    save_arcs(root, doc)
    return phase


def inj_04a(root):
    doc = arcs(root)
    doc["patches"][0]["from"] = "charter-99"
    save_arcs(root, doc)


def _closed_arc(root):
    """닫힌 아크 하나와 그 closed 날짜를 낸다."""
    for x in arcs(root)["arcs"]:
        if x.get("status") == "closed" and x.get("closed"):
            return x["name"], x["closed"]
    raise SystemExit("음성 대조: 닫힌 아크가 없어 검사 5 의 조건을 만들 수 없다")


def _shift(day: str, delta: int) -> str:
    y, m, d = (int(v) for v in day.split("-"))
    return (_date(y, m, d) + timedelta(days=delta)).isoformat()


def inj_05(root):
    """닫힌 날보다 **뒤**의 날짜로 항목을 쓴다. 잡혀야 한다.

    날짜를 함께 옮기지 않으면 조건이 서지 않는다. 검사 5 가 닫힌 아크를 가리키는
    항목을 전부 잡던 판에서는 아크와 페이즈만 옮겨도 걸렸으나, 날짜로 가르게 된
    뒤에는 같은 날의 항목이 빠져나가므로 그 주입이 공허해진다.
    """
    name, closed = _closed_arc(root)
    after = _shift(closed, 1)

    def f(e):
        e["origin"]["arc"] = name
        e["origin"]["phase"] = f"{name}-1"
        e["origin"]["date"] = after
    edit(root, "decisions", "CF-24", f)
    return after


def inj_05_before(root):
    """닫힌 날보다 **앞**의 날짜로 항목을 쓴다. 잡히지 않아야 한다.

    반대 방향이 없으면 「날짜를 보지 않고 여전히 전량을 잡는다」와 갈리지 않는다.
    """
    name, closed = _closed_arc(root)
    before = _shift(closed, -1)

    def f(e):
        e["origin"]["arc"] = name
        e["origin"]["phase"] = f"{name}-1"
        e["origin"]["date"] = before
    edit(root, "decisions", "CF-24", f)
    return before


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
    """폐기된 id 를 폐기 뒤에 선 항목의 `related` 에 넣는다.

    **지목하는 항목을 박지 않고 유도한다.** 이 주입은 그 항목을 `CF-24` 로 박아 두었는데, 검사
    10 이 폐기 레코드보다 번호가 앞선 항목의 지목을 실패가 아니라 보고로 돌리므로 그 지목은
    구조적으로 실패가 될 수 없다. `collateral-5` 가 받은 판에서 이미 죽어 있었고, 그래서 검사
    10 이 음성 대조를 받지 않는 상태로 여러 회차를 지났다.

    그래서 번호가 가장 작은 폐기 레코드를 고르고, 그 번호보다 큰 살아 있는 결정 항목 가운데
    번호가 가장 큰 것이 그 폐기 대상을 들게 한다. 원장이 자라면 고르는 항목이 함께 뒤로 가므로
    유도가 스스로 유지된다. `related` 는 덮지 않고 덧붙인다. 덮으면 그 항목이 원래 들고 있던
    지목이 사라져 같은 사본에서 다른 검사가 함께 흔들린다."""
    rets = load(root, "retirements")["retirements"]
    first = min(rets, key=lambda q: id_no(q.get("id")))
    dead = first["target"]
    retired = {q["target"] for q in rets if q.get("target")}
    live = [e for e in load(root, "decisions")["decisions"]
            if id_no(e.get("id")) > id_no(first.get("id")) and e.get("id") not in retired]
    if not live:
        raise SystemExit("폐기 레코드보다 뒤에 선 살아 있는 결정 항목이 없어 주입 대상이 없다")
    tgt = max(live, key=lambda e: id_no(e.get("id")))
    related = list(tgt.get("related") or [])
    if dead in related or first.get("id") in related:
        raise SystemExit(f"{tgt['id']} 가 이미 {dead} 나 {first['id']} 를 들어 주입이 조건을 만들지 못한다")
    edit(root, "decisions", tgt["id"],
         lambda e: e.__setitem__("related", list(e.get("related") or []) + [dead]))
    return tgt["id"]


def inj_11(root):
    tgt = pick(root, "deferred", lambda e: isinstance(e.get("reopen_when"), dict))
    edit(root, "deferred", tgt["id"], lambda e: e["reopen_when"].__setitem__("kind", ""))


def inj_12(root):
    tgt = pick(root, "deferred",
               lambda e: isinstance(e.get("reopen_when"), dict)
               and e["reopen_when"].get("kind") == "arc_phase")
    edit(root, "deferred", tgt["id"],
         lambda e: e["reopen_when"].__setitem__("ref", "아크가 아닌 문자열"))


def _out_of_scope_arc(root) -> str:
    """범위 밖인 아크 하나의 이름. **아크 레코드에서 고르고 박아 두지 않는다.**

    이름을 박으면 그 아크의 처분이 바뀔 때 주입이 조건을 만들지 못하면서 음성 대조가
    통과한다.

    **그 상태의 아크가 산 레코드에 없으면 사본의 아크 하나를 그 상태로 바꾼 뒤 조건을 짓는다.**
    이름을 박지 않는 것과 그 상태의 아크가 리포에 실재하기를 요구하는 것이 다르며, 아크의 처분은
    이 프로젝트가 계속 고치는 값이므로 실재를 전제로 두면 처분이 바뀌는 회차마다 음성 대조 전량이
    멈춘다. 고르는 규칙도 이름을 박지 않고 `reserved` 이며 답할 항을 들지 않는 아크 가운데 레코드의
    열거 순서로 첫째를 집는다. 그 상태가 아직 일하지 않은 아크를 뜻해 범위 밖과 가장 가까우므로
    사본에 생기는 딴 위반이 가장 적고, 답할 항이 없는 아크를 고르면 검사 28 의 주입이 그 번호를
    다른 아크에서 조달할 수 있다. **바꾼 사본이 그 주입의 유니버스이며 리포의 실물은 그대로다.**

    **지을 수 없는 전제가 남으면 그때는 그대로 멈춘다.** 조용히 통과하는 것보다 멈추는 것이 옳다는
    이 구성기의 설계는 그대로이고, 바뀐 것은 지을 수 있는 전제의 범위다.
    """
    doc = arcs(root)
    for x in doc["arcs"]:
        if x.get("status") == check_wiki.ARC_OUT_OF_SCOPE:
            return x["name"]
    for x in doc["arcs"]:
        if x.get("status") == "reserved" and not (x.get("cq") or []):
            x["status"] = check_wiki.ARC_OUT_OF_SCOPE
            save_arcs(root, doc)
            return x["name"]
    raise SystemExit("음성 대조: 범위 밖인 아크를 사본에서도 지을 수 없어 "
                     "검사 12·28 의 조건을 만들 수 없다")


def inj_28_out_of_scope(root):
    """범위 밖인 아크의 `cq` 에 고정 절의 번호를 적는다.

    현행 주입은 고정 절에 **없는** 번호를 적는 것이고 이것은 고정 절에 **있는** 번호를 범위
    밖 아크에 적는 것이다. 번호를 박지 않고 다른 아크가 이미 든 것을 고르므로, 고정 절이
    바뀌어도 주입이 조건을 만든다."""
    name = _out_of_scope_arc(root)
    doc = arcs(root)
    ref = next((c for x in doc["arcs"]
                if x.get("status") != check_wiki.ARC_OUT_OF_SCOPE
                for c in (x.get("cq") or [])), None)
    if ref is None:
        raise SystemExit("음성 대조: 고정 절의 번호를 든 아크가 없어 주입 대상이 없다")
    for x in doc["arcs"]:
        if x["name"] == name:
            x["cq"] = [ref]
    save_arcs(root, doc)
    return f"{name}/{ref}"


def inj_13(root):
    """없는 id 를 **줄 주석**에 적는다.

    검사 13 의 유니버스가 줄 주석으로 좁혀졌으므로 주입도 줄 주석이어야 걸린다. 블록 주석에
    같은 줄을 적으면 잡히지 않는 것이 좁힘의 뜻이다(SPEC §2.1)."""
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


def _retired_rule(root) -> tuple[str, str]:
    """폐기된 규율 ID 하나와 그것을 폐기한 레코드가 선 날을 낸다.

    검사 23 이 날짜로 좁혀졌으므로 주입의 날짜를 그 레코드의 날짜에서 유도해야 한다. 날짜를
    박아 두면 폐기 레코드가 늘 때 주입이 조건을 만들지 못하면서 음성 대조가 통과한다."""
    for rec in load(root, "retirements")["retirements"]:
        target, when = rec.get("target"), (rec.get("origin") or {}).get("date")
        if not target or not when:
            continue
        for reg in ("decisions", "deferred"):
            for e in load(root, reg)[reg]:
                if e["id"] == target and e.get("names"):
                    return e["names"][0], when
    raise SystemExit("폐기된 항목이 규율 ID 를 들지 않아 검사 23 의 주입 대상이 없다")


def _inj_23_dated(root, delta: int) -> str:
    """폐기한 날에서 `delta` 만큼 옮긴 날짜로 폐기된 규율 ID 를 근거로 드는 항을 세운다.

    첫 적재(`charter-6`)는 `related` 요건을 면하므로 주입은 그 뒤의 페이즈로 선 항목이어야
    한다. 그래서 `charter-7` 로 선 항목을 새로 세워 거기에 지목을 넣는다."""
    tok, when = _retired_rule(root)
    doc = load(root, "decisions")
    doc["decisions"].append({
        "id": "CF-9023",
        "origin": {"arc": "charter", "phase": "charter-7",
                   "kind": "decision_session", "date": _shift(when, delta)},
        "names": ["Z-9023"],
        "statement": "음성 대조가 주입한 항이다.",
        "basis": f"음성 대조가 주입한 항이며 {tok} 을 근거로 든다.",
        "tier": "finding",
        "layer": "meta",
        "related": [],
    })
    save(root, "decisions", doc)
    return tok


def inj_23_after(root):
    """폐기한 날보다 **뒤**의 날짜로 폐기된 규율 ID 를 근거로 적는다. 잡혀야 한다.

    그 검사가 처음부터 잡으려던 행위이며, 작성 시점에 이미 폐기된 것을 근거로 드는 것이다."""
    return _inj_23_dated(root, 1)


def inj_23_before(root):
    """폐기한 날보다 **앞**의 날짜로 적는다. 잡히지 않아야 한다.

    좁힘이 실제로 받는 쪽이다. 이 방향을 재지 않으면 「날짜를 보지 않고 여전히 전량을
    잡는다」와 갈리지 않는다."""
    return _inj_23_dated(root, -1)


def inj_23_same(root):
    """폐기한 날과 **같은** 날짜로 적는다. 잡혀야 한다.

    엄격 부등호가 실제로 엄격한지를 이 주입만 잰다. 없으면 느슨하게 써도 음성 대조가
    통과하고, 같은 카드에서 폐기되는 규율을 새 항목이 이름으로 들지 못하게 한 금지가
    조용히 풀린다."""
    return _inj_23_dated(root, 0)


def inj_24_missing(root):
    """상주 문서에 없는 규율 ID 를 적는다. 미실재는 선언으로 면제되지 않는다.

    토큰은 검사 23·24 의 계열에 들면서 어느 항목의 `names` 에도 없는 것이어야 한다. 계열 밖의
    글자를 쓰면 애초에 규율 ID 로 읽히지 않아 주입이 조건을 만들지 못한다."""
    f = root / "CLAUDE.md"
    f.write_text(f.read_text(encoding="utf-8")
                 + "\n음성 대조가 주입한 줄이며 Q-99 를 든다.\n", encoding="utf-8")


def inj_24_retired(root):
    """선언되지 않은 폐기 규율을 적는다. CLAUDE.md 는 폐기 지목 선언을 두지 않는다."""
    dead_id = load(root, "retirements")["retirements"][0]["target"]
    tok = None
    for reg in ("decisions", "deferred"):
        for e in load(root, reg)[reg]:
            if e["id"] == dead_id and e.get("names"):
                tok = e["names"][0]
    if not tok:
        raise SystemExit("폐기된 항목이 규율 ID 를 들지 않아 주입 대상이 없다")
    f = root / "CLAUDE.md"
    f.write_text(f.read_text(encoding="utf-8")
                 + f"\n음성 대조가 주입한 줄이며 {tok} 을 근거로 든다.\n", encoding="utf-8")
    return tok


def inj_25(root):
    """최상위 선언 하나의 표지를 지운다."""
    f = root / "CrisisFramework" / "Glossary" / "Core.lean"
    lines = f.read_text(encoding="utf-8").split("\n")
    for i, ln in enumerate(lines):
        if ln.strip().startswith("-- DD:"):
            del lines[i]
            break
    else:
        raise SystemExit("지울 표지가 없다")
    f.write_text("\n".join(lines), encoding="utf-8")


def inj_16(root):
    eid = "CF-9016"
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(
        eid, {"kind": "artifact", "ref": "docs/arcs.json"}))
    save(root, "deferred", doc)
    return eid


def inj_43(root):
    """실재하지 않는 번호를 `extraction` 트리거의 `ref` 로 둔 항을 등재한다.

    그 항이 「발화할 수 없는 항」으로 세어져야 한다. 번호의 꼴을 만족하므로 검사 12 는 그것을
    형식으로 받으며, 그 번호의 기록이 실재하는지를 보는 자리가 검사 43 하나임이 이 주입으로
    선다. 추출 기록의 번호가 두 자리이고 현행 열이 49 까지이므로 97 을 고른다."""
    eid = "CF-9043"
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(
        eid, {"kind": "extraction", "ref": "E-97"}))
    save(root, "deferred", doc)
    return eid


def inj_17(root):
    eid = "CF-9017"
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(eid, None))
    save(root, "deferred", doc)
    return eid


def inj_18(root):
    eid = "CF-9018"
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(
        eid, {"kind": "blocking", "ref": "network"}))
    save(root, "deferred", doc)
    return eid


def inj_19(root):
    eid = "CF-100"
    doc = load(root, "decisions")
    doc["decisions"] = [e for e in doc["decisions"] if e["id"] != eid]
    save(root, "decisions", doc)
    return eid


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


def inj_31(root):
    """열린 아크의 페이즈로 발화하는 이연 항을 쓰고 어느 아크의 `holes` 에도 넣지 않는다.

    기존 뼈대는 `origin.phase` 를 `charter-6` 으로 두는데 검사 31 이 첫 적재를 면제하므로
    그대로 쓰면 주입이 조건을 만들지 못한다. 그 자리만 열린 아크의 선언된 페이즈로 바꾸고
    나머지는 같게 둔다."""
    doc = load(root, "deferred")
    e = deferred_stub("CF-9031", {"kind": "artifact", "ref": "docs/arcs.json"})
    e["origin"]["arc"] = "collateral"
    e["origin"]["phase"] = "collateral-5"
    doc["deferred"].append(e)
    save(root, "deferred", doc)
    return "CF-9031"


def inj_32(root):
    """어느 아크의 `phases` 에도 없는 페이즈 이름으로 종료 문서를 하나 둔다.

    좁힌 검사 32 는 블록을 읽지 않으므로 앞 판의 주입(블록의 값을 패치 계수와 다르게 적는
    것)은 더 이상 조건을 만들지 못한다. 선언된 아크의 이름을 쓰면 검사 35 의 형에는 맞으므로
    이 주입이 검사 32 만 겨눈다."""
    phase = "collateral-9999"
    f = root / "docs" / "phases" / f"{phase}-closure.md"
    f.parent.mkdir(parents=True, exist_ok=True)
    f.write_text("음성 대조가 주입한 종료 문서다.\n", encoding="utf-8")
    return phase


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


def _boundary_decls(root: Path):
    """경계 안 선언. **검증기의 수집기를 그대로 불러 쓰고 전사하지 않는다.**

    경계와 머리말 표를 여기서 다시 읽으면 한쪽을 고칠 때 다른 쪽이 조용히 낡고, 주입이
    경계 밖을 겨누게 되어도 그것을 어느 검사도 잡지 않는다."""
    led = wiki_common.Ledger(root)
    since, forms = wiki_common.heading_rules(led)
    inside = [] if since is None else [d for d in led.doc_decls() if d.no >= since]
    return inside, forms


def _append_para(root: Path, d, para: str) -> None:
    """그 선언의 docstring 말미에 문단 하나를 더한다.

    선언 줄보다 앞에 선 마지막 `/-- -/` 블록이 그 선언의 docstring 이라는 것은 검증기의
    수집기가 쓰는 규칙과 같다. 그 규칙을 전사하지 않으려고 같은 정규식을 불러 쓴다."""
    f = root / d.rel
    text = f.read_text(encoding="utf-8")
    cut = sum(len(x) for x in text.splitlines(keepends=True)[:d.line - 1])
    blocks = [m for m in wiki_common.DOC_BLOCK.finditer(text) if m.end() <= cut]
    if not blocks:
        raise SystemExit(f"{d.full} 의 docstring 블록을 찾지 못했다")
    end = blocks[-1].end() - 2            # 닫는 `-/` 앞
    f.write_text(text[:end] + f"\n{para}\n" + text[end:], encoding="utf-8")


def _inj_33_para(root, para: str) -> str:
    """경계 안 선언 가운데 그 낱말을 들지 않는 것 하나의 docstring 에 문단을 더한다.

    기각 레지스터가 그 선언을 `for_decl` 로 들지 않는 것이 주입의 조건이다. 이미 드는 선언을
    고르면 좌변에 들어도 미포착이 서지 않아 주입이 조건을 만들지 못한다."""
    inside, _forms = _boundary_decls(root)
    claimed = {str(e.get("for_decl")) for e in load(root, "rejected")["rejected"]
               if e.get("for_decl")}
    word = check_wiki.REJECTION_WORD
    for d in inside:
        if d.full in claimed or any(word in p for p in d.paras):
            continue
        _append_para(root, d, para)
        return d.full
    raise SystemExit("경계 안에 주입할 선언이 없다")


def inj_33_heading(root):
    """경계 안 선언의 문단에 **머리말로** 그 예약 낱말을 두고 기각 레지스터에 대응 항목을
    두지 않는다. 좌에서 우로가 실패해야 한다.

    머리말을 `HEADING` 블록의 형 그대로 두어 검사 34 가 함께 걸리지 않게 한다. 걸리면 어느
    검사가 주입을 잡았는지가 갈리지 않는다."""
    return _inj_33_para(root, f"**{check_wiki.REJECTION_WORD}:** 음성 대조가 주입한 문단이다.")


def inj_33_body(root):
    """경계 안 선언의 문단에 **본문으로만** 그 낱말을 둔다. 잡히지 않아야 한다.

    그 방향을 재지 않으면 「머리말로 좁혔다」와 「여전히 본문을 본다」가 갈리지 않는다."""
    return _inj_33_para(
        root,
        f"**음성 대조가 주입한 문단이다.** 본문에서만 {check_wiki.REJECTION_WORD} 를 든다.")


def inj_33_right(root):
    """`for_decl` 값을 없는 선언 이름으로 바꾼다. 우에서 좌로가 실패한다."""
    doc = load(root, "rejected")
    e = next((x for x in doc["rejected"] if x.get("for_decl")), None)
    if e is None:
        raise SystemExit("for_decl 을 든 기각 항목이 없어 주입 대상이 없다")
    e["for_decl"] = "CrisisFramework.Definition.NoSuchDeclaration"
    save(root, "rejected", doc)
    return e["for_decl"]


def inj_34_period(root):
    """경계 안 머리말의 마침표를 지운다. 그 머리말이 형과 달라져 실패한다.

    예약 낱말을 들고 마침표로 닫는 머리말만 고른다. 자유 머리말은 형에 걸리지 않으므로
    마침표를 지워도 통과하고, 그러면 주입이 조건을 만들지 못한다."""
    inside, forms = _boundary_decls(root)
    for d in inside:
        f = root / d.rel
        text = f.read_text(encoding="utf-8")
        for p in d.paras:
            head = wiki_common.para_heading(p)
            if not head or not head.endswith(".") or not any(w in head for w in forms):
                continue
            old = f"**{head}**"
            if old not in text:
                continue          # 두 줄에 걸친 머리말은 원문에 그 꼴로 서지 않는다
            f.write_text(text.replace(old, f"**{head[:-1]}**", 1), encoding="utf-8")
            return head
    raise SystemExit("마침표로 닫는 예약 머리말이 경계 안에 없다")


def inj_34_empty(root):
    """`HEADING` 블록을 비운다. 비어 있으면 통과가 아니라 실패다."""
    f = root / "docs" / "baseline.md"
    text = f.read_text(encoding="utf-8")
    new = re.sub(r"<!-- HEADING:BEGIN -->\n.*?<!-- HEADING:END -->",
                 "<!-- HEADING:BEGIN -->\n<!-- HEADING:END -->",
                 text, count=1, flags=re.S)
    if new == text:
        raise SystemExit("HEADING 블록을 찾지 못했다")
    f.write_text(new, encoding="utf-8")


def _plant(root: Path, rel: str) -> str:
    """`docs/` 아래에 파일을 하나 심고 그 경로를 낸다. 검사 35 의 주입이 전부 이것을 쓴다."""
    p = root / "docs" / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text("음성 대조가 주입한 문서다.\n", encoding="utf-8")
    return f"docs/{rel}"


def inj_35_plan(root):
    """청사진을 `docs/` 에 둔다."""
    return _plant(root, "IMPLEMENTATION_PLAN_collateral_9.md")


def inj_35_patch(root):
    """패치 조각을 `docs/` 에 둔다."""
    return _plant(root, "patches-collateral-9.json")


def inj_35_annex(root):
    """별지를 `docs/` 에 둔다."""
    return _plant(root, "별지-collateral-9-명세.md")


def inj_35_phases_other(root):
    """종료 문서가 아닌 것을 `phases/` 에 둔다."""
    return _plant(root, "phases/collateral-9-notes.md")


def inj_35_phases_arc(root):
    """선언되지 않은 아크 이름으로 종료 문서를 둔다.

    `<ARC>` 가 `arcs.json` 의 아크 이름 전량의 택일로 바뀌므로, 선언된 아크의 이름을 쓰면
    번호가 무엇이든 통과한다. 그 값을 레지스터가 닫는다는 것이 이 주입이 재는 것이다."""
    return _plant(root, "phases/nosucharc-1-closure.md")


def inj_35_extraction(root):
    """추출 기록의 접두사를 어긴다."""
    return _plant(root, "extractions/extract-48-foo.md")


def inj_35_case(root):
    """파일 이름에 대문자와 밑줄을 쓴다."""
    return _plant(root, "extractions/extraction-48-Foo_Bar.md")


def inj_35_dir(root):
    """허용되지 않은 디렉터리를 만든다."""
    return _plant(root, "notes/collateral-9.md")


def inj_35_ledger(root):
    """원장 디렉터리에 새 파일을 둔다."""
    return _plant(root, "decisions/holes.json")

def inj_36_open(root):
    """사본의 무시 파일에서 `/*` 한 줄을 지운다. 닫힌 형이 깨진다."""
    f = root / check_wiki.IGNORE_FILE
    lines = f.read_text(encoding="utf-8").splitlines(keepends=True)
    for i, ln in enumerate(lines):
        if ln.strip() == check_wiki.IGNORE_ALL:
            del lines[i]
            break
    else:
        raise SystemExit(f"무시 파일에 `{check_wiki.IGNORE_ALL}` 줄이 없다")
    f.write_text("".join(lines), encoding="utf-8")


def inj_36_ghost(root):
    """사본의 무시 파일에 루트에 없는 이름으로 되살림 줄을 더한다. 목록이 유령을 든다.

    산문의 계수를 어기는 주입을 따로 두지 않는다. 이 주입이 목록을 늘리면 계수도 함께
    어긋나므로 한 주입이 두 축을 함께 잡고, 같은 것을 두 번 세면 검사의 계수가 부풀고 음성
    대조가 그 자리에서 공허해진다."""
    f = root / check_wiki.IGNORE_FILE
    lines = f.read_text(encoding="utf-8").splitlines()
    ghost = "!/NO_SUCH_ROOT_ENTRY.md"
    at = [i for i, ln in enumerate(lines) if check_wiki.IGNORE_REVIVE.match(ln.strip())]
    if not at:
        raise SystemExit("무시 파일에 되살림 줄이 없다")
    lines.insert(at[-1] + 1, ghost)
    f.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return ghost


def inj_37_count(root):
    """사본의 원장 계수 표에서 한 행의 수를 하나 틀리게 적는다."""
    f = root / check_wiki.LEDGER_COUNT_DOC
    lines = f.read_text(encoding="utf-8").splitlines()
    head = [i for i, ln in enumerate(lines)
            if ln.strip() == check_wiki.LEDGER_COUNT_HEAD]
    if len(head) != 1:
        raise SystemExit("원장 계수 표의 머리를 찾지 못했다")
    for i in range(head[0] + 2, len(lines)):
        m = check_wiki.LEDGER_COUNT_ROW.match(lines[i].strip())
        if not m:
            break
        lines[i] = f"| {m.group(1)} | {int(m.group(2)) + 1} |"
        f.write_text("\n".join(lines) + "\n", encoding="utf-8")
        return f"{m.group(1)} {m.group(2)}→{int(m.group(2)) + 1}"
    raise SystemExit("원장 계수 표의 행을 찾지 못했다")


def _excl_block(root: Path) -> list[str]:
    """사본의 `EXCL` 블록이 든 분할 이름. 주입 셋이 유니버스를 이것으로 읽는다."""
    text = (root / "docs" / "baseline.md").read_text(encoding="utf-8")
    m = check_wiki.EXCL_BLOCK.search(text)
    if m is None:
        raise SystemExit("EXCL 블록을 찾지 못했다")
    return [x.group(1) for x in
            map(check_wiki.EXCL_LINE.match, m.group(1).splitlines()) if x]


def _excl_paras(root: Path):
    """사본의 등록 관계 선언과 그 배타성 문단.

    문단마다 (문면, 모든 쌍이 배타적이라 적었는가) 를 든다. 그 판별을 검증기의 함수로 하므로
    주입과 판정이 같은 것을 읽는다. 전사하면 한쪽을 고칠 때 다른 쪽이 조용히 낡는다.
    """
    led = wiki_common.Ledger(root)
    forms = wiki_common.heading_rules(led)[1].get(check_wiki.EXCLUSIVITY_WORD, [])
    got = check_wiki.excl_registry(led)
    if got is None:
        raise SystemExit("등록 관계를 드는 선언이 없어 주입 대상이 없다")
    decl, parts, excl = got
    paras = []
    for p in decl.paras:
        head = wiki_common.para_heading(p)
        if head is None:
            continue
        for f in forms:
            if check_wiki.heading_fill(f, head) is not None:
                paras.append((p, check_wiki.EXCL_ALL_MARK in f))
                break
    return led, decl, parts, excl, paras


def inj_38_para(root):
    """`EXCL` 블록의 분할에서 배타성 문단을 지운다. 그 분할의 문단이 없으면 실패해야 한다."""
    _led, decl, _parts, _excl, paras = _excl_paras(root)
    if not paras:
        raise SystemExit("배타성 문단이 없어 주입 대상이 없다")
    para = paras[0][0]
    f = root / decl.rel
    text = f.read_text(encoding="utf-8")
    if text.count(para + "\n\n") != 1:
        raise SystemExit("배타성 문단의 문면을 파일에서 한 번으로 찾지 못했다")
    f.write_text(text.replace(para + "\n\n", "", 1), encoding="utf-8")
    return wiki_common.para_heading(para)


def inj_38_pair(root):
    """모든 쌍이 배타적이라 적은 분할의 배타 관계 한 쌍을 지운다.

    문단은 그대로 두고 관계만 지운다. 그 방향을 재지 않으면 「문단과 관계를 함께 본다」와
    「문단만 본다」가 갈리지 않는다.
    """
    led, decl, parts, _excl, paras = _excl_paras(root)
    labels = check_wiki.concept_labels(led, decl.rel)
    forms = wiki_common.heading_rules(led)[1][check_wiki.EXCLUSIVITY_WORD]
    all_form = next(f for f in forms if check_wiki.EXCL_ALL_MARK in f)
    target = None
    for name in _excl_block(root):
        label = labels.get(name)
        cells = parts.get(name) or []
        if not label or len(cells) < 2:
            continue
        for para, is_all in paras:
            fill = check_wiki.heading_fill(all_form, wiki_common.para_heading(para) or "")
            if is_all and fill is not None and fill.startswith(label):
                target = (name, cells[0], cells[1])
                break
        if target:
            break
    if target is None:
        raise SystemExit("모든 쌍이 배타적이라 적은 분할이 없어 주입 대상이 없다")
    name, a, b = target
    f = root / decl.rel
    lines = f.read_text(encoding="utf-8").splitlines()
    want = {frozenset((a, b))}
    for i, ln in enumerate(lines):
        m = check_wiki.EXCLUDES_ROW.search(ln)
        if m and frozenset(m.groups()) in want:
            del lines[i]
            f.write_text("\n".join(lines) + "\n", encoding="utf-8")
            return f"{name}: {a} 와 {b}"
    raise SystemExit(f"`{a}` 와 `{b}` 의 배타 관계 줄을 찾지 못했다")


def inj_38_empty(root):
    """`EXCL` 블록을 비운다. 비어 있으면 통과가 아니라 실패다.

    이 항이 없으면 블록이 비었을 때 통과시키는 구현이 음성 대조를 통과한다. 검사 34 의 같은
    항이 그 사유로 이미 서 있다.
    """
    f = root / "docs" / "baseline.md"
    text = f.read_text(encoding="utf-8")
    new = re.sub(r"<!-- EXCL:BEGIN -->\n.*?<!-- EXCL:END -->",
                 "<!-- EXCL:BEGIN -->\n<!-- EXCL:END -->",
                 text, count=1, flags=re.S)
    if new == text:
        raise SystemExit("EXCL 블록을 찾지 못했다")
    f.write_text(new, encoding="utf-8")


def inj_39_ghost(root):
    """어느 아크의 `holes` 에 이연 레지스터에 없는 id 를 적는다."""
    doc = arcs(root)
    if not doc.get("arcs"):
        raise SystemExit("arcs.json 에 아크가 없어 주입 대상이 없다")
    live = {e.get("id") for e in load(root, "deferred")["deferred"]}
    ghost = "CF-9039"
    if ghost in live:
        raise SystemExit(f"{ghost} 가 이연 레지스터에 이미 있어 주입이 서지 않는다")
    doc["arcs"][0].setdefault("holes", []).append(ghost)
    save_arcs(root, doc)
    return f"{doc['arcs'][0].get('name')}: {ghost}"


def inj_41_pointer(root):
    """면제 목록에 없는 항목의 산문에 살아 있는 조항의 주석을 지목하는 꼴을 적는다.

    면제 목록을 값 정본에서 읽어 주입과 판정이 같은 목록을 쓰게 한다. 전사하면 한쪽을 고칠 때
    다른 쪽이 조용히 낡는다. 폐기되지 않은 조항을 고르는 까닭은 폐기된 것을 고르면 규율 ID
    토큰을 보는 검사 23 이 먼저 잡아 이 주입이 그 뒤에 가려지는 것이다.
    """
    led = wiki_common.Ledger(root)
    _dist, exempt = check_wiki.r11_rules(led)
    if not exempt:
        raise SystemExit("R11 블록의 면제 목록이 비어 주입과 판정이 같은 목록을 쓰지 못한다")
    live = sorted(tok for tok, owner in led.name_owner.items()
                  if owner not in led.dead)
    if not live:
        raise SystemExit("폐기되지 않은 규율 조항이 없어 주입이 서지 않는다")
    tok = live[0]
    doc = load(root, "decisions")
    target = next((e for e in doc["decisions"] if e.get("id") not in exempt), None)
    if target is None:
        raise SystemExit("면제 목록 밖의 항목이 없어 주입 대상이 없다")
    target["statement"] = (str(target.get("statement") or "")
                           + f" {tok} 에 붙은 주석을 지목한다.")
    save(root, "decisions", doc)
    return f"{target.get('id')}: {tok} 에 붙은 주석"


def ko_word(value: int) -> str:
    """값을 한글 수사로 적는다. 검증기의 `ko_count` 가 읽는 꼴의 역이다.

    주입이 수를 하나 틀리게 적는 자리에서 쓴다. 조합의 두 표를 검증기에서 가져오므로 주입과
    판정이 같은 어휘를 쓰고, 전사하면 한쪽을 고칠 때 다른 쪽이 조용히 낡는다.
    """
    unit = {v: w for w, v in wiki_common.COUNT_KO_UNIT.items()}
    for tens, base in sorted(wiki_common.COUNT_KO_TENS.items(),
                             key=lambda x: -x[1]):
        if value >= base:
            rest = value - base
            if rest and rest not in unit:
                raise SystemExit(f"{value} 를 한글 수사로 적을 수 없다")
            return tens + (unit[rest] if rest else "")
    if value not in unit:
        raise SystemExit(f"{value} 를 한글 수사로 적을 수 없다")
    return unit[value]


def inj_40_count(root):
    """계수 자리 가운데 하나의 수를 하나 틀리게 적는다.

    명세의 가름을 함께 드는 자리가 든 전체 계수를 하나 올린다. 자리를 하나만 건드리는 주입이므로
    그 자리와 정본이 어긋나는 것이 잡혀야 하고, 자리마다 따로 돌리지 않는다. 판정 대상 하나에 한
    번만 돌린다는 요구가 그것을 든다.

    **자리를 그 검사의 꼴로 찾는다.** 그 검사가 유니버스를 열거에서 꼴 유도로 바꿨으므로 열거의
    첫 항을 집던 앞 판은 설 자리가 없어졌다. 꼴을 전사하면 그 검사가 꼴을 고칠 때 이 주입이
    조용히 공허해진다.
    """
    rel = wiki_common.COUNT_SPEC
    f = root / rel
    text = f.read_text(encoding="utf-8")
    m = check_wiki.COUNT_GROUP_FORM.search(text)
    if m is None:
        raise SystemExit(f"{rel} 에서 가름을 함께 드는 자리를 찾지 못했다")
    said = check_wiki.ko_count(m.group(1))
    if said is None:
        raise SystemExit(f"그 자리가 든 수사 `{m.group(1)}` 를 값으로 읽을 수 없다")
    wrong = ko_word(said + 1)
    at, end = m.span(1)
    f.write_text(text[:at] + wrong + text[end:], encoding="utf-8")
    return f"{rel} 의 전체 계수: {m.group(1)}→{wrong}"


# ----------------------------------------------------- 검사 42 · 조항 목록의 거울

def _clause_block(root: Path) -> tuple[pathlib.Path, str]:
    """값 정본의 경로와 그 본문. 블록이 없으면 주입이 설 자리가 없으므로 멈춘다."""
    f = root / "docs" / "baseline.md"
    s = f.read_text(encoding="utf-8")
    if check_wiki.SESSIONCLAUSE_BLOCK.search(s) is None:
        raise SystemExit("값 정본에 SESSIONCLAUSE 블록이 없어 주입이 서지 않는다")
    return f, s


def inj_42_drop(root):
    """블록에서 살아 있는 조항 하나를 지운다.

    지울 조항을 블록과 원장에서 함께 고른다. 블록의 줄만 보고 고르면 그것이 폐기된 조항일 때
    주입이 다른 갈래를 재게 된다. 판정과 같은 읽기를 쓰는 까닭은 전사하면 한쪽을 고칠 때 다른
    쪽이 조용히 낡는 것이다.
    """
    led = wiki_common.Ledger(root)
    _series, clauses = check_wiki.sessionclause_rules(led)
    live = sorted(c for c in clauses
                  if any(i not in led.dead
                         for i in [o for n, o in led.name_owner.items() if n == c]))
    if not live:
        raise SystemExit("블록에 살아 있는 조항이 없어 주입이 서지 않는다")
    tok = live[0]
    f, s = _clause_block(root)
    line = f"SESSIONCLAUSE={tok}\n"
    if s.count(line) != 1:
        raise SystemExit(f"블록에서 `{tok}` 의 줄을 한 번으로 집지 못했다")
    f.write_text(s.replace(line, ""), encoding="utf-8")
    return tok


def inj_42_retired(root):
    """블록에 폐기된 조항 하나를 더한다. 실패 문면이 「전부 폐기됐다」를 들어야 한다."""
    led = wiki_common.Ledger(root)
    series, clauses = check_wiki.sessionclause_rules(led)
    dead = sorted(n for n, owner in led.name_owner.items()
                  if n not in clauses and owner in led.dead
                  and (lambda m: m is not None and (m.group(2) or "PH-R") in series)(
                      wiki_common.RULE_TOKEN.fullmatch(n)))
    if not dead:
        raise SystemExit("블록 밖의 폐기된 조항이 없어 주입이 서지 않는다")
    tok = dead[0]
    f, s = _clause_block(root)
    f.write_text(s.replace("<!-- SESSIONCLAUSE:END -->",
                           f"SESSIONCLAUSE={tok}\n<!-- SESSIONCLAUSE:END -->"),
                 encoding="utf-8")
    return tok


def inj_42_ghost(root):
    """블록에 원장에 없는 이름을 더한다. 실패 문면이 「원장에 없다」를 들어야 한다.

    계열은 블록이 든 것에서 고르고 번호는 그 계열의 현행 최대보다 크게 잡는다. 계열 밖의 이름을
    쓰면 검사가 다른 갈래로 가른다.
    """
    led = wiki_common.Ledger(root)
    series, _clauses = check_wiki.sessionclause_rules(led)
    ser = sorted(series)[0]
    used = [int(m.group(3)) for m in
            (wiki_common.RULE_TOKEN.fullmatch(n) for n in led.name_owner)
            if m is not None and m.group(2) == ser]
    tok = f"{ser}-{max(used, default=0) + 90}"
    f, s = _clause_block(root)
    f.write_text(s.replace("<!-- SESSIONCLAUSE:END -->",
                           f"SESSIONCLAUSE={tok}\n<!-- SESSIONCLAUSE:END -->"),
                 encoding="utf-8")
    return tok


def inj_42_empty(root):
    """블록을 비운다. 통과가 아니라 실패여야 한다."""
    f, s = _clause_block(root)
    f.write_text(check_wiki.SESSIONCLAUSE_BLOCK.sub(
        "<!-- SESSIONCLAUSE:BEGIN -->\n<!-- SESSIONCLAUSE:END -->", s), encoding="utf-8")
    return "SESSIONCLAUSE"


# ------------------------------------------------- 검사 35 · 추출 기록 번호의 축

def _extraction_pattern(root: Path):
    """추출 기록의 꼴과 그 디렉터리의 번호별 파일 목록. 번호 그룹이 없으면 멈춘다."""
    led = wiki_common.Ledger(root)
    s = (root / "docs" / "baseline.md").read_text(encoding="utf-8")
    m = check_wiki.DOCFORM_BLOCK.search(s)
    if m is None:
        raise SystemExit("값 정본에 DOCFORM 블록이 없어 주입이 서지 않는다")
    for line in m.group(1).splitlines():
        g = check_wiki.DOCFORM_LINE.match(line)
        if g is None or g.group(2) != "pattern":
            continue
        rx = re.compile(g.group(3).replace(
            "<ARC>", "(?:" + "|".join(re.escape(a) for a in sorted(led.arcs)) + ")"))
        if check_wiki.DOCFORM_NUM_GROUP not in rx.groupindex:
            continue
        d = root / "docs" / g.group(1)
        seen: dict = {}
        for f in sorted(d.glob("*")) if d.is_dir() else []:
            hit = rx.fullmatch(f.name)
            if hit:
                seen.setdefault(hit.group(check_wiki.DOCFORM_NUM_GROUP), []).append(f)
        return g.group(1), seen
    raise SystemExit("번호 그룹을 든 DOCFORM 패턴 줄이 없어 주입이 서지 않는다")


def inj_35_dupnum(root):
    """같은 번호를 가진 추출 기록을 둔다. 번호 중복은 실패다."""
    d, seen = _extraction_pattern(root)
    if not seen:
        raise SystemExit("그 꼴에 든 파일이 없어 주입이 서지 않는다")
        # 번호를 실물에서 읽는다. 박아 두면 그 번호의 파일이 사라질 때 주입이 조용히 빈다.
    num = sorted(seen)[0]
    return _plant(root, f"{d}/extraction-{num}-duplicate-probe.md")


def inj_35_gapnum(root):
    """중간 번호의 추출 기록을 옮겨 결번을 만든다.

    **잡히지 않아야 하는 항이다.** 결번은 어긋남이 아니라 보고이므로 새 위반 줄이 나지 않아야
    한다. 보고 줄에 결번이 들었는지는 이 하네스가 보지 않는다.
    """
    _d, seen = _extraction_pattern(root)
    nums = sorted(seen)
    if len(nums) < 3:
        raise SystemExit("번호가 셋 미만이라 중간 번호를 고를 수 없다")
    num = nums[len(nums) // 2]
    for f in seen[num]:
        f.unlink()
    return num



def inj_26(root):
    """꼬리의 `clarifies` 를 원장에 없는 id 로 바꾼다.

    검사 27 이 대상의 실재와 비폐기를 검사 26 의 몫으로 두고 건너뛰므로 이 주입이 검사 26
    하나만 겨눈다. 꼬리를 든 항목을 원장에서 골라 그 필드만 바꾸고 `resolves` 는 그대로 둔다.
    """
    tail = pick(root, "decisions", lambda e: e.get("clarifies") is not None)
    ghost = "CF-99026"
    led = wiki_common.Ledger(root)
    if ghost in led.by_id:
        raise SystemExit(f"{ghost} 가 원장에 이미 있어 없는 id 로 쓰지 못한다")
    edit(root, "decisions", tail["id"], lambda e: e.__setitem__("clarifies", ghost))
    return ghost


def inj_27(root):
    """꼬리의 `resolves` 의 `phrase` 를 대상 항목의 산문에 없는 값으로 바꾼다.

    `clarifies` 는 그대로 두어 검사 26 이 걸리지 않게 한다. 대상이 살아 있는 꼬리를 고르는
    까닭은 검사 27 이 폐기된 대상을 건너뛰어 주입이 조건을 만들지 못하는 것이다.
    """
    led = wiki_common.Ledger(root)
    tail = pick(root, "decisions",
                lambda e: (e.get("clarifies") in led.by_id
                           and e.get("clarifies") not in led.dead
                           and isinstance(e.get("resolves"), list)
                           and e.get("resolves")))
    tgt = led.by_id[tail["clarifies"]]
    prose = str(tgt.get("statement") or "") + str(tgt.get("basis") or "")
    phrase = "음성 대조가 주입한 지목 문구다"
    if phrase in prose:
        raise SystemExit("주입할 문구가 대상의 산문에 이미 있어 조건을 만들지 못한다")

    def bend(e):
        e["resolves"][0]["phrase"] = phrase

    edit(root, "decisions", tail["id"], bend)
    return phrase


# 검사 29 의 주입이 쓰는 아크. **답할 항과 그 처분이 일대일인 닫힌 아크여야 한다.** 일대일이
# 아닌 아크를 쓰면 한 처분을 바꿔도 다른 처분이 남아 그 검사가 통과하여 주입이 공허해진다.
# 그 조건을 주입 안에서 단언하므로, 원장이 달라져 조건이 깨지면 조용히 통과하지 않고 선다.
INJ_29_ARC = "claim"


def inj_29(root):
    """닫힌 아크의 한 처분 항목이 드는 답할 항의 값을 그 아크의 다른 답할 항으로 바꾼다.

    바꾼 뒤에도 그 값이 고정 절에 있으므로 「고정 절에 없다」가 아니라 「그 처분을 드는 것이
    없다」 하나만 새로 선다. 고정 절 밖의 번호로 바꾸면 한 주입이 두 위반을 내어 어느 쪽이
    이 검사의 몫인지가 갈리지 않는다.
    """
    led = wiki_common.Ledger(root)
    a = led.arcs.get(INJ_29_ARC)
    if a is None or a.get("status") != "closed":
        raise SystemExit(f"아크 `{INJ_29_ARC}` 가 없거나 닫혀 있지 않다")
    cqs = [str(x) for x in (a.get("cq") or [])]
    if len(cqs) < 2:
        raise SystemExit(f"아크 `{INJ_29_ARC}` 의 답할 항이 둘 미만이라 다른 번호로 바꾸지 못한다")
    holder: dict = {}
    for _n, e in led.entries:
        if not (isinstance(e.get("origin"), dict)
                and e["origin"].get("arc") == INJ_29_ARC):
            continue
        for item in (e.get("cq_disposition") or []):
            if isinstance(item, dict):
                holder.setdefault(str(item.get("cq")), []).append(e["id"])
    if any(len(holder.get(c, [])) != 1 for c in cqs):
        raise SystemExit(f"아크 `{INJ_29_ARC}` 의 답할 항과 처분이 일대일이 아니라 주입이 공허해진다")
    victim, other = cqs[0], cqs[1]
    eid = holder[victim][0]

    def bend(e):
        for item in e["cq_disposition"]:
            if isinstance(item, dict) and str(item.get("cq")) == victim:
                item["cq"] = other

    for reg in ("decisions", "deferred", "retirements", "rejected"):
        if any(x["id"] == eid for x in load(root, reg)[reg]):
            edit(root, reg, eid, bend)
            break
    else:
        raise SystemExit(f"{eid} 를 어느 레지스터에서도 찾지 못했다")
    return victim


def inj_30(root):
    """어느 아크의 `cq` 에서 번호를 지워 어느 아크에도 걸리지 않은 답할 항을 만든다.

    고를 자리를 이름 순으로 정해 판마다 같은 주입이 서게 한다. 아크 종료 검사는 이 항에서
    돌지 않으므로 닫힌 아크를 골라도 그 검사가 함께 걸리지 않는다.
    """
    doc = arcs(root)
    for a in sorted(doc["arcs"], key=lambda x: x["name"]):
        if a.get("cq"):
            gone = str(a["cq"].pop())
            save_arcs(root, doc)
            return gone
    raise SystemExit("답할 항을 든 아크가 없어 지울 자리가 없다")


# 지목 범위 세 갈래의 주입이 쓰는 문면. 갈래마다 그 갈래가 적발하는 꼴을 하나 담고 다른 갈래의
# 꼴은 담지 않는다. `{tok}` 은 주입이 살아 있는 규율 조항으로 채운다.
#
# 표지와 절 번호는 실재하지 않는 값을 쓴다. 이 문면의 몫이 적발되는 것이므로 실재하는 조작이나
# 절을 쓰면 그것을 지목한 자리로 읽히는데, 주입은 무엇도 지목하지 않는다. `Z` 로 여는 것이
# 이 파일이 주입한 이름에 쓰는 접두사다.
INJ_POINTER_LINE = {
    "POINTER_COMMENT": "\n음성 대조가 주입한 문면이다. {tok} 의 주석이 그 자리를 든다.\n",
    "POINTER_EPHEMERAL": "\n음성 대조가 주입한 문면이다. 조작 표지 Z9-O9 를 지목한다.\n",
    "POINTER_SECTION": "\n음성 대조가 주입한 문면이다. 그 요구는 §99.7 이 든다.\n",
}
# 주입을 받는 영구 문면. 집행 문면이 그 검사의 유니버스에 들고 덧붙이는 자리가 말미라 다른
# 검사의 앵커를 밀지 않는다.
INJ_POINTER_DOC = "CLAUDE.md"


def _inject_pointer(root, key):
    """지목 범위의 한 갈래만 하나 늘린다.

    **늘린 갈래와 그 수를 주입 안에서 단언한다.** 그 검사가 갈래마다 따로 맞대므로 다른 갈래가
    함께 움직이면 어느 갈래의 탐지를 재는지가 갈리지 않으며, 늘지 않으면 주입이 공허해진다.
    적발을 세는 쪽은 검증기에 선 함수를 그대로 부른다. 전사하면 한쪽을 고칠 때 다른 쪽이
    조용히 낡는다.
    """
    led = wiki_common.Ledger(root)
    dist, _exempt = check_wiki.r11_rules(led)
    if dist is None:
        raise SystemExit("R11 블록에 거리가 없어 주입과 판정이 같은 값을 쓰지 못한다")
    before = {k: len(v) for k, v in
              check_wiki.pointer_hits(led.pointer_scan_targets(), dist).items()}
    # 폐기된 조항을 고르면 규율 ID 토큰을 보는 검사 24 가 먼저 잡아 이 주입이 그 뒤에 가려진다.
    live = sorted(tok for tok, owner in led.name_owner.items() if owner not in led.dead)
    if not live:
        raise SystemExit("폐기되지 않은 규율 조항이 없어 주입이 서지 않는다")
    f = root / INJ_POINTER_DOC
    f.write_text(f.read_text(encoding="utf-8")
                 + INJ_POINTER_LINE[key].format(tok=live[0]), encoding="utf-8")
    after = {k: len(v) for k, v in
             check_wiki.pointer_hits(
                 wiki_common.Ledger(root).pointer_scan_targets(), dist).items()}
    for k in before:
        want = before[k] + 1 if k == key else before[k]
        if after[k] != want:
            raise SystemExit(f"주입이 {k} 를 {before[k]} 에서 {after[k]} 로 바꿨다. "
                             f"{want} 여야 한다")
    return key


def inj_41_comment(root):
    """규율 ID 뒤 그 거리 안에 그 낱말이 따르는 자리를 하나 더한다."""
    return _inject_pointer(root, "POINTER_COMMENT")


def inj_41_ephemeral(root):
    """소진 문서의 식별자 꼴을 하나 더한다."""
    return _inject_pointer(root, "POINTER_EPHEMERAL")


def inj_41_section(root):
    """앞에 출처 표지도 문서 이름도 오지 않는 절 번호를 하나 더한다."""
    return _inject_pointer(root, "POINTER_SECTION")


# 검사 44 의 주입이 만지는 자리. 사례 목록을 소스의 문면으로 고치는 까닭은 그 검사가 사본의
# 소스를 읽기 때문이며, 돌고 있는 이 모듈의 값을 고쳐도 사본에는 닿지 않는다.
NC_IN_COPY = ("scripts", "wiki_negative_control.py")
NC_LIST_FORM = re.compile(r"^CASES = \[(.*?)^\]", re.M | re.S)
NC_ROW_FORM = re.compile(r'^[ \t]*\("([^"]+)",\s*"([^"]+)".*?\),[ \t]*$', re.M)


def _nc_rows(root):
    """사본의 사례 목록과 그 행. (파일, 전문, 목록의 범위, 행의 목록) 을 낸다."""
    f = root.joinpath(*NC_IN_COPY)
    src = f.read_text(encoding="utf-8")
    m = NC_LIST_FORM.search(src)
    if m is None:
        raise SystemExit("사본의 사례 목록을 읽지 못했다")
    rows = list(NC_ROW_FORM.finditer(src, m.start(1), m.end(1)))
    if not rows:
        raise SystemExit("사본의 사례 목록에서 행을 하나도 읽지 못했다")
    return f, src, rows


def inj_44_drop(root):
    """한 검사의 주입 항을 사례 목록에서 지운다.

    사례가 하나뿐인 검사를 고른다. 둘 이상인 검사의 한 항만 지우면 다른 항이 남아 그 검사의
    번호가 여전히 목록에 서고 주입이 공허해진다.
    """
    f, src, rows = _nc_rows(root)
    nums = [m.group(1) for m in rows]
    victim = next((m for m in rows if nums.count(m.group(1)) == 1), None)
    if victim is None:
        raise SystemExit("사례가 하나뿐인 검사가 없어 지울 자리가 없다")
    f.write_text(src[:victim.start()] + src[victim.end() + 1:], encoding="utf-8")
    return victim.group(1)


def inj_44_ghost(root):
    """명세에 없는 번호로 사례를 더한다."""
    f, src, rows = _nc_rows(root)
    ghost = "9944"
    if any(m.group(1) == ghost for m in rows):
        raise SystemExit(f"번호 {ghost} 가 사례 목록에 이미 있어 없는 번호로 쓰지 못한다")
    row = f'    ("{ghost}", "wiki{ghost}-ghost", "음성 대조가 주입한 항이다", inj_01, None, None),\n'
    f.write_text(src[:rows[0].start()] + row + src[rows[0].start():], encoding="utf-8")
    return ghost


def inj_44_step(root):
    """사례 목록의 한 항이 전사한 단계 id 를 다른 값으로 바꾼다."""
    f, src, rows = _nc_rows(root)
    first = rows[0]
    bent = first.group(0).replace(f'"{first.group(2)}"', '"wiki-음성-대조가-바꾼-단계"', 1)
    f.write_text(src[:first.start()] + bent + src[first.end():], encoding="utf-8")
    return first.group(2)


def _open_arc(root):
    """열려 있는 아크의 레코드. 그 아크가 없으면 주입이 조건을 만들지 못한다."""
    doc = arcs(root)
    a = next((x for x in doc["arcs"] if x.get("status") == "open"), None)
    if a is None:
        raise SystemExit("열려 있는 아크가 없어 주입이 조건을 만들지 못한다")
    return doc, a


def inj_45_hole_drop(root):
    """한 페이즈의 `holes` 에서 구멍 하나를 지운다."""
    doc, a = _open_arc(root)
    ph = next((x for x in a["phases"] if x.get("holes")), None)
    if ph is None:
        raise SystemExit("구멍을 든 페이즈가 없어 지울 자리가 없다")
    gone = str(ph["holes"].pop())
    save_arcs(root, doc)
    return gone


def inj_45_hole_dup(root):
    """두 페이즈가 같은 구멍을 들게 한다."""
    doc, a = _open_arc(root)
    src = next((x for x in a["phases"] if x.get("holes")), None)
    dst = next((x for x in a["phases"]
                if x is not src and isinstance(x.get("holes"), list)), None)
    if src is None or dst is None:
        raise SystemExit("구멍을 옮겨 담을 페이즈 둘을 찾지 못했다")
    dst["holes"].append(src["holes"][0])
    save_arcs(root, doc)
    return src["holes"][0]


def inj_45_builds_drop(root):
    """열려 있는 아크의 페이즈 객체에서 `builds` 를 지운다."""
    doc, a = _open_arc(root)
    ph = next((x for x in a["phases"] if "builds" in x), None)
    if ph is None:
        raise SystemExit("`builds` 를 든 페이즈가 없어 지울 자리가 없다")
    ph.pop("builds")
    save_arcs(root, doc)
    return ph["name"]


def inj_45_string(root):
    """닫힌 아크의 페이즈 원소를 문자열로 되돌린다.

    어디서도 지목되지 않는 페이즈를 고른다. 원장의 `origin.phase` 나 종료 문서나 패치가 그
    이름을 들면 그 페이즈가 미선언으로 보여 검사 셋이 함께 걸리고, 그러면 한 주입이 겨눈 검사와
    다른 검사를 함께 실패시킨다.
    """
    doc = arcs(root)
    led = wiki_common.Ledger(root)
    used = {(e.get("origin") or {}).get("phase") for _n, e in led.entries}
    used |= {p.get("from") for p in led.patches} | {p.get("phase") for p in led.patches}
    used |= {f.name[:-len("-closure.md")]
             for f in (root / "docs" / "phases").glob("*-closure.md")}
    for a in doc["arcs"]:
        if a.get("status") == "open":
            continue
        for i, ph in enumerate(a.get("phases") or []):
            if isinstance(ph, dict) and ph.get("name") not in used:
                a["phases"][i] = ph["name"]
                save_arcs(root, doc)
                return ph["name"]
    raise SystemExit("어디서도 지목되지 않는 닫힌 아크의 페이즈가 없어 되돌릴 자리가 없다")


# 검사 46 의 주입이 만지는 줄. 목록의 이름을 담은 문장이며 그 꼴의 정본은 검증기가 든다.
SPEC_IN_COPY = ("docs", "decisions", "SPEC.md")


def _spec_block_list(root):
    """사본의 기계 판독 블록 목록 문장. (파일, 전문, 그 범위) 를 낸다."""
    f = root.joinpath(*SPEC_IN_COPY)
    src = f.read_text(encoding="utf-8")
    m = check_wiki.SPEC_BLOCK_SENTENCE.search(src)
    if m is None:
        raise SystemExit("사본에서 기계 판독 블록의 목록을 읽지 못했다")
    return f, src, m


def inj_46_drop(root):
    """목록에서 블록 이름 하나를 지운다."""
    f, src, m = _spec_block_list(root)
    names = check_wiki.SPEC_BLOCK_NAME.findall(m.group(1))
    if not names:
        raise SystemExit("목록이 든 블록 이름이 없어 지울 자리가 없다")
    gone = names[0]
    bent = m.group(1).replace(f"`{gone}` 과 ", "", 1)
    if bent == m.group(1):
        raise SystemExit(f"목록에서 `{gone}` 를 지우는 꼴을 찾지 못했다")
    f.write_text(src[:m.start(1)] + bent + src[m.end(1):], encoding="utf-8")
    return gone


def inj_46_ghost(root):
    """어느 검사도 읽지 않는 이름을 목록에 더한다."""
    f, src, m = _spec_block_list(root)
    ghost = "NOSUCHBLOCK"
    if ghost in m.group(1):
        raise SystemExit(f"`{ghost}` 가 목록에 이미 있어 읽히지 않는 이름으로 쓰지 못한다")
    bent = m.group(1) + f" 그리고 `{ghost}` 가 그 목록에 더 선다"
    f.write_text(src[:m.start(1)] + bent + src[m.end(1):], encoding="utf-8")
    return ghost


def inj_47_ghost(root):
    """어느 필드 표의 검사 칸에 실재하지 않는 번호를 적는다.

    **자리를 그 검사의 꼴로 찾는다.** 그 검사가 유니버스를 표의 머리에서 유도하므로 절이나 줄을
    집으면 표가 하나 더 설 때 이 주입이 다른 자리를 겨누게 되고, 꼴을 전사하면 그 검사가 꼴을
    고칠 때 이 주입이 조용히 공허해진다.

    번호를 선언된 검사에서 빼어 고른다. 실재하는 번호를 적으면 그 칸이 다른 검사를 가리키는
    꼴이 되어 이 주입이 아무것도 겨누지 않는다.
    """
    f = root / wiki_common.COUNT_SPEC
    text = f.read_text(encoding="utf-8")
    rows, _outside = check_wiki.spec_field_rows(text)
    target = next((x for x in rows if x[3]), None)
    if target is None:
        raise SystemExit(f"{wiki_common.COUNT_SPEC} 에 검사 칸이 선 필드 표의 행이 없다")
    declared = set(dict(wiki_common.REPORT_DECL.findall(
        (root / wiki_common.COUNT_WIKI).read_text(encoding="utf-8"))))
    ghost = next((str(n) for n in range(90, 100) if str(n) not in declared), None)
    if ghost is None:
        raise SystemExit("선언되지 않은 번호를 고를 자리가 없어 주입이 서지 않는다")
    line, _sec, field, _cell, at = target
    lines = text.splitlines(keepends=True)
    raw = lines[line - 1]
    tail = "\n" if raw.endswith("\n") else ""
    inner = raw.rstrip("\n").strip()
    parts = wiki_common.SPEC_CELL_SPLIT.split(inner[1:-1])
    parts[at] = parts[at].rstrip() + check_wiki.SPEC_CHECK_JOIN + ghost + " "
    lines[line - 1] = "|" + "|".join(parts) + "|" + tail
    f.write_text("".join(lines), encoding="utf-8")
    return f"{field}: {ghost}"


# 검사 48 의 주입이 세우는 사본의 파일. **주입이 제 대상을 세운다.** 경계 안 표지를 가진 선언이
# 받은 판에 아직 없으므로 기존 선언을 굽히는 꼴로는 이 주입이 서지 않으며, 경계가 뒤 회차에
# 올라가도 같은 사유로 공허해지지 않는다. 자리를 정의층에 두는 까닭은 그 검사의 유니버스가
# 형식층 docstring 이라는 것이다.
NC48_FILE = ("CrisisFramework", "Definition", "NcSourcingProbe.lean")
NC48_DECL = "ncSourcingProbe"
# 실재하지 않는 절 번호. 추출 기록의 절이 두 자리를 넘지 않으므로 이 꼴이 어느 기록에도 없다.
NC48_GHOST_SECTION = "99-99"


def _nc48_material(root):
    """사본에서 조달처 줄이 설 재료를 고른다.

    (기록 번호, 절 번호, 그 절에 있는 구절, 그 기록의 다른 절에 있는 구절) 을 낸다. **재료를
    검증기의 수집기로 고른다.** 꼴을 전사하면 그 검사가 꼴을 고칠 때 이 주입이 조용히
    공허해지고, 번호를 박으면 기록이 늘거나 절이 덧붙을 때 다른 자리를 겨누게 된다.
    """
    led = wiki_common.Ledger(root)
    _since, minlen = check_wiki.sourcing_rules(led)
    if minlen is None:
        raise SystemExit("사본의 SOURCING 블록에서 구절의 최소 길이를 읽지 못했다")
    want = minlen + 8          # 짧게 줄이는 주입이 하한 아래로 내려갈 여유를 둔다
    d = root / "docs" / "extractions"
    for f in sorted(d.glob("extraction-*.md")):
        m = wiki_common.EXTRACTION_FILE_NO.match(f.name)
        if m is None:
            continue
        secs = check_wiki.extraction_sections(f)
        picked = []
        for no in sorted(secs):
            body = check_wiki.fold(secs[no])
            # 낫표와 Lean 의 주석 표지를 담은 구절은 쓰지 않는다. 앞은 조달처 줄의 울타리를
            # 닫아 버리고 뒤는 docstring 을 닫아 버린다.
            if any(x in body for x in ("「", "」", "-/", "/-")):
                continue
            if len(body) >= want:
                picked.append((no, body[:want]))
            if len(picked) == 2:
                break
        if len(picked) < 2:
            continue
        (no_a, phrase), (_no_b, other) = picked
        if other in check_wiki.fold(secs[no_a]):
            continue           # 다른 절의 구절이 그 절에도 있으면 그 주입이 공허해진다
        return int(m.group(1)), no_a, phrase, other
    raise SystemExit("조달처 줄의 재료가 될 절 둘을 가진 추출 기록이 없다")


def _nc48_plant(root, bend):
    """경계 안 표지를 가진 선언을 사본에 세우고 그 조달처 줄을 굽힌다.

    굽히지 않은 꼴은 그 검사를 통과하므로, 굽힌 자리 하나만이 새 위반 줄을 낸다.
    """
    led = wiki_common.Ledger(root)
    since, minlen = check_wiki.sourcing_rules(led)
    if since is None:
        raise SystemExit("사본의 SOURCING 블록에서 경계를 읽지 못했다")
    rec, sec, phrase, other = _nc48_material(root)
    if bend == "phrase":
        src = f"조달처: E-{rec:02d} §{sec} 「{other}」"
    elif bend == "section":
        src = f"조달처: E-{rec:02d} §{NC48_GHOST_SECTION} 「{phrase}」"
    elif bend == "short":
        src = f"조달처: E-{rec:02d} §{sec} 「{phrase[:minlen - 1]}」"
    elif bend == "drop":
        src = ""
    else:
        raise SystemExit(f"굽히는 꼴을 알 수 없다: {bend!r}")
    para = ["**이 정의가 배제하는 사례:**",
            "음성 대조가 세운 사본 안의 사례이며 리포의 어느 판에도 들어가지 않는다."]
    if src:
        para.append(src)
    f = root.joinpath(*NC48_FILE)
    f.write_text(
        "/-\n정의층 — 음성 대조의 조달처 프로브\n\n"
        "이 파일은 음성 대조가 사본에만 세우는 것이며 리포의 어느 판에도 들어가지 않는다.\n-/\n\n"
        "namespace CrisisFramework.Definition\n\n"
        "/--\n음성 대조가 세운 선언.\n\n"
        "**대응 비형식 개념:** 없다.\n\n"
        + "\n".join(para) + "\n\n"
        "**기각한 대체 정의:**\n기각한 것이 없다.\n\n"
        "**수 체계를 받지 않는다.**\n-/\n"
        f"-- DD:CF-{since}\n"
        f"def {NC48_DECL} : Bool := true\n\n"
        "end CrisisFramework.Definition\n", encoding="utf-8")
    return f"CrisisFramework.Definition.{NC48_DECL}: E-{rec:02d} §{sec}"


def inj_48_phrase(root):
    """조달처 줄의 구절을 그 기록의 다른 절에 있는 구절로 바꾼다."""
    return _nc48_plant(root, "phrase")


def inj_48_drop(root):
    """경계 안 선언의 조달처 줄을 지운다."""
    return _nc48_plant(root, "drop")


def inj_48_section(root):
    """지목의 절 번호를 실재하지 않는 것으로 바꾼다."""
    return _nc48_plant(root, "section")


def inj_48_short(root):
    """구절을 최소 길이 아래로 줄인다."""
    return _nc48_plant(root, "short")


def inj_49_unpointed(root):
    """어느 docstring 도 지목하지 않는 추출 기록을 하나 더한다.

    번호를 기존 최대의 다음으로 고른다. 중간 번호를 쓰면 결번이나 번호 중복이 서서 문서
    양식을 보는 검사가 함께 걸리는데, 그것은 이 주입이 겨눈 자리가 아니다.
    """
    d = root / "docs" / "extractions"
    nums = [int(m.group(1)) for f in d.glob("extraction-*.md")
            for m in [wiki_common.EXTRACTION_FILE_NO.match(f.name)] if m]
    if not nums:
        raise SystemExit("사본에 추출 기록이 없어 번호를 고를 자리가 없다")
    n = max(nums) + 1
    name = f"extraction-{n:02d}-negative-control-probe.md"
    (d / name).write_text(
        f"# 추출 기록 E-{n:02d}\n\n## 0. 이 기록의 지위\n\n"
        "음성 대조가 사본에만 세우는 기록이며 리포의 어느 판에도 들어가지 않는다.\n",
        encoding="utf-8")
    return name


# ----------------------------------------------------- 검사 50 · 뭉치 인벤토리의 거울

def _nc50_inventory(root):
    """사본의 뭉치 인벤토리 경로와 그 문면과 구성원 행의 번호. 구성원 행을 고르는 쪽은 검증기의
    함수를 그대로 부른다. 전사하면 그 검사가 꼴을 고칠 때 이 주입이 조용히 공허해진다."""
    f = root / wiki_common.INVENTORY_DOC
    text = f.read_text(encoding="utf-8")
    left, _rows, _lists = check_wiki.inventory_members(text)
    if not left:
        raise SystemExit("사본의 인벤토리에서 구성원 행의 기록 번호를 하나도 읽지 못했다")
    return f, text, left


def inj_50_missing(root):
    """인벤토리의 구성원 행 하나에 실재하지 않는 기록 번호를 적는다.

    번호를 기존 기록 최대의 다음으로 고른다. 그 번호의 기록 파일이 없으므로 미포착이 서야
    하며, 그 행이 원래 든 번호를 지우지 않으므로 유령의 계수는 움직이지 않는다.
    """
    f, text, left = _nc50_inventory(root)
    d = root / "docs" / "extractions"
    nums = [int(m.group(1)) for g in d.glob("extraction-*.md")
            for m in [wiki_common.EXTRACTION_FILE_NO.match(g.name)] if m]
    if not nums:
        raise SystemExit("사본에 추출 기록이 없어 번호를 고를 자리가 없다")
    n = max(nums) + 1
    if n > 99:
        raise SystemExit("기록 번호가 두 자리를 넘어 검사의 꼴이 그 번호를 읽지 못한다")
    lines = text.split("\n")
    at = left[min(left)][0] - 1
    m = wiki_common.INVENTORY_EXTRACTION_NO.search(lines[at])
    if m is None:
        raise SystemExit("고른 구성원 행에서 기록 번호를 다시 찾지 못했다")
    lines[at] = lines[at][:m.end()] + f" · E-{n:02d}" + lines[at][m.end():]
    f.write_text("\n".join(lines), encoding="utf-8")
    return f"{wiki_common.INVENTORY_DOC}:{at + 1} 에 E-{n:02d}"


def inj_50_ghost(root):
    """추출 기록 하나의 번호를 드는 구성원 행을 인벤토리에서 지운다.

    **그 번호를 한 줄에서만 들고 그 줄이 다른 번호를 들지 않는 기록을 고른다.** 다른 줄에도
    서면 한 줄을 지워도 유령이 서지 않고, 그 줄이 다른 번호를 들면 유령이 둘 이상 늘어 이 주입이
    겨눈 자리가 흐려진다. 유령이 하나 늘었는지를 주입 안에서 단언한다.
    """
    f, text, left = _nc50_inventory(root)
    before = len(set(left))
    lines = text.split("\n")
    for n in sorted(left):
        where = sorted(set(left[n]))
        if len(where) != 1:
            continue
        at = where[0] - 1
        others = {int(x.group(1))
                  for x in wiki_common.INVENTORY_EXTRACTION_NO.finditer(lines[at])}
        if others != {n}:
            continue
        del lines[at]
        f.write_text("\n".join(lines), encoding="utf-8")
        after, _rows, _lists = check_wiki.inventory_members(f.read_text(encoding="utf-8"))
        if len(set(after)) != before - 1 or n in after:
            raise SystemExit(f"구성원 행을 지웠는데 좌변이 {before} 에서 {len(set(after))} 로 "
                             f"바뀌었다. 하나만 줄어야 한다")
        return f"E-{n:02d}"
    raise SystemExit("한 줄에서만 서고 그 줄이 다른 번호를 들지 않는 기록이 없어 주입이 서지 않는다")


def _nc50_unread_row(root):
    """사본의 인벤토리와 미추출 표지를 든 구성원 행 하나와 편 제목 하나. 행과 제목을 고르는 쪽은
    검증기의 함수를 그대로 부른다. 전사하면 그 축이 꼴을 고칠 때 이 주입이 조용히 공허해진다."""
    f, lines, rows, unread = _nc53_rows(root)
    d = root / "docs" / "extractions"
    title = None
    for g in sorted(d.glob("extraction-*.md")):
        if wiki_common.EXTRACTION_FILE_NO.match(g.name):
            got = check_wiki.extraction_titles(g.read_text(encoding="utf-8"))
            if got:
                title = got[0]
                break
    if title is None:
        raise SystemExit("사본의 추출 기록에서 편 제목을 하나도 읽지 못해 주입할 자리가 없다")
    for line, cells, _sec in rows:
        if unread in cells[-1] and len(cells) > 1:
            return f, lines, line, cells, title
    raise SystemExit("미추출 표지를 든 구성원 행이 없어 주입할 자리가 없다")


def _nc50_insert(f, lines, line, cells, cell):
    """고른 행 바로 뒤에 그 행의 칸을 옮긴 행을 더하되 비고 칸 앞의 마지막 칸을 바꾼다."""
    row = list(cells)
    row[-2] = cell
    lines.insert(line, "| " + " | ".join(row) + " |")
    f.write_text("\n".join(lines), encoding="utf-8")
    return f"{wiki_common.INVENTORY_DOC}:{line + 1}"


def inj_50_unread(root):
    """미추출 표지를 든 구성원 행 하나를 더하고 그 칸 하나가 추출 기록의 편 제목을 들게 한다.

    추출된 편을 미추출로 적은 낡은 표지가 서야 하며, 번호를 들지 않으므로 번호 대조의 두 방향은
    움직이지 않는다.
    """
    f, lines, line, cells, title = _nc50_unread_row(root)
    return _nc50_insert(f, lines, line, cells, title)


def inj_50_unread_below(root):
    """같은 행을 더하되 그 칸이 편 제목을 품고 그 뒤에 글자를 덧붙여 비가 문턱 아래로 가게 한다.

    짧은 제목이 같은 계열의 긴 제목에 들어가는 자리이며 잡히지 않아야 한다. 비가 문턱 아래인지와
    포함이 서는지를 주입 안에서 단언한다. 그 단언이 없으면 이 항이 문턱을 재지 않고 통과할 수 있다.
    """
    f, lines, line, cells, title = _nc50_unread_row(root)
    cell = title
    while True:
        ratio = check_wiki.title_ratio(check_wiki.title_key(cell), check_wiki.title_key(title))
        if ratio is None:
            raise SystemExit("덧붙인 칸이 편 제목을 품지 않는다")
        if ratio < check_wiki.INVENTORY_TITLE_RATIO / 2:
            break
        cell += " and its companion series"
    return _nc50_insert(f, lines, line, cells, cell)


# ----------------------------------------------------- 검사 51 · 원장 entry 의 키 유니버스

def inj_51_key(root):
    """원장 entry 하나에 그 유니버스 밖의 키를 더한다.

    유니버스는 검증기의 함수로 사본의 명세에서 뽑는다. 전사하면 그 검사가 유니버스를 고칠 때
    고른 키가 유니버스 안으로 들어가 이 주입이 조용히 공허해진다. **값은 어느 검사도 읽지 않는
    문면으로 둔다.** 산문 필드를 읽는 검사가 그 값에 걸리면 이 주입이 다른 검사까지 실패시켜
    겨눈 자리가 흐려진다.
    """
    names, _seen, _odd = check_wiki.ledger_key_universe(
        (root / wiki_common.COUNT_SPEC).read_text(encoding="utf-8"))
    universe = set().union(*names.values())
    if not universe:
        raise SystemExit("사본의 명세에서 키 유니버스를 읽지 못했다")
    key = "negative_control_probe"
    if key in universe:
        raise SystemExit(f"주입할 키 `{key}` 가 이미 유니버스 안에 있다")
    e = pick(root, "decisions", lambda x: True)
    edit(root, "decisions", e["id"], lambda x: x.__setitem__(key, "음성 대조가 주입한 키다."))
    return f"{e['id']} 가 유니버스 밖의 키 `{key}`"

# ----------------------------------------------------- 검사 52 · 열려 있는 아크의 구멍 배정

def _hole_52(root):
    """열려 있는 아크를 `ref` 로 드는 살아 있는 차단 구멍 가운데 아크와 페이즈에 함께 든 것 하나.

    둘에 함께 든 것을 고르는 까닭은 주입이 한쪽만 지워 그쪽의 미포착을 세워야 하기 때문이다. 이미
    한쪽이 빠진 항을 고르면 그 주입이 만든 줄과 기준선의 줄이 갈리지 않는다."""
    doc, a = _open_arc(root)
    dead = {e.get("target") for e in load(root, "retirements")["retirements"]}
    phase = {str(h) for ph in a["phases"] if isinstance(ph, dict) for h in (ph.get("holes") or [])}
    arc_holes = {str(h) for h in (a.get("holes") or [])}
    for e in load(root, "deferred")["deferred"]:
        rw = e.get("reopen_when") or {}
        if (rw.get("kind") == "blocking" and rw.get("ref") == a["name"]
                and e["id"] not in dead and e["id"] in arc_holes and e["id"] in phase):
            return doc, a, e["id"]
    raise SystemExit("열려 있는 아크를 가리키는 살아 있는 차단 구멍이 아크와 페이즈에 함께 들지 않아 "
                     "주입 대상이 없다")


def inj_52_arc(root):
    """열려 있는 아크를 `ref` 로 드는 차단 구멍 하나를 그 아크의 `holes` 에서 지운다."""
    doc, a, hid = _hole_52(root)
    a["holes"] = [h for h in a["holes"] if str(h) != hid]
    save_arcs(root, doc)
    return hid


def inj_52_phase(root):
    """그 구멍을 아크의 `holes` 에는 두고 모든 페이즈의 `holes` 에서 지운다."""
    doc, a, hid = _hole_52(root)
    for ph in a["phases"]:
        if isinstance(ph, dict) and isinstance(ph.get("holes"), list):
            ph["holes"] = [h for h in ph["holes"] if str(h) != hid]
    save_arcs(root, doc)
    return hid


# ----------------------------------------------------- 검사 53 · 54 · 뭉치 인벤토리의 구성원 행 표지

def _nc53_rows(root):
    """사본의 인벤토리 경로와 줄과 구성원 행과 표지 낱말. 구성원 행을 고르는 쪽은 검증기의 함수를
    그대로 부른다. 전사하면 그 검사가 꼴을 고칠 때 이 주입이 조용히 공허해진다."""
    led = wiki_common.Ledger(root)
    marks = wiki_common.inventorymark_block(led)
    f = root / wiki_common.INVENTORY_DOC
    text = f.read_text(encoding="utf-8")
    rows, _t, _r = wiki_common.inventory_member_rows(
        text, marks[wiki_common.INVENTORYMARK_AGGREGATE])
    if not rows:
        raise SystemExit("사본의 인벤토리에서 구성원 행을 하나도 읽지 못했다")
    return f, text.split("\n"), rows, marks[wiki_common.INVENTORYMARK_UNREAD]


def inj_53_drop(root):
    """구성원 행 하나에서 표지를 지운다.

    **번호를 들지 않고 미추출 표지 하나만 든 행을 고른다.** 번호를 든 행에서 표지를 지우면 그 행이
    번호로 통과해 이 주입이 겨눈 자리가 서지 않는다.
    """
    f, lines, rows, unread = _nc53_rows(root)
    for line, cells, _sec in rows:
        if unread in cells[-1] and not any(
                wiki_common.INVENTORY_EXTRACTION_NO.search(c) for c in cells):
            at = line - 1
            k = lines[at].rfind(" " + unread)
            if k < 0:
                raise SystemExit("고른 구성원 행에서 표지를 다시 찾지 못했다")
            lines[at] = lines[at][:k] + lines[at][k + len(unread) + 1:]
            f.write_text("\n".join(lines), encoding="utf-8")
            return f"{wiki_common.INVENTORY_DOC}:{line}"
    raise SystemExit("번호 없이 미추출 표지만 든 구성원 행이 없어 주입할 자리가 없다")


def inj_54_add(root):
    """미추출 표지를 든 행을 하나 늘린다. 표지를 들지 않은 구성원 행 하나의 비고 칸 말미에 더한다."""
    f, lines, rows, unread = _nc53_rows(root)
    for line, cells, _sec in rows:
        if unread not in cells[-1]:
            at = line - 1
            k = lines[at].rstrip().rfind("|")
            if k <= 0:
                raise SystemExit("고른 구성원 행의 마지막 칸을 찾지 못했다")
            lines[at] = lines[at][:k].rstrip() + " " + unread + " " + lines[at][k:]
            f.write_text("\n".join(lines), encoding="utf-8")
            return f"{wiki_common.INVENTORY_DOC}:{line}"
    raise SystemExit("미추출 표지를 들지 않은 구성원 행이 없어 주입할 자리가 없다")



# ----------------------------------------------------- 검사 55 · 56 · 57 · 페이즈의 답할 항과 그 계수

def _fixed_cq(root: Path) -> list[int]:
    """고정 절 블록이 드는 CQ 번호. 검증기의 수집기를 그대로 써서 주입과 판정이 같은 목록을 본다."""
    return wiki_common.cq_fixed(types.SimpleNamespace(root=root))


def inj_55_foreign(root):
    """페이즈 레코드에 그 아크의 `cq` 에 없는 번호를 넣는다.

    **고정 절에 실재하는 번호를 고른다.** 고정 절에 없는 번호를 넣으면 형식의 결손과 배정의 결손이
    한 주입에 겹쳐, 이 검사가 잡았는지 다른 검사가 함께 걸렸는지가 그 줄에서 갈리지 않는다.
    """
    doc, a = _open_arc(root)
    ph = next((x for x in a.get("phases") or [] if isinstance(x, dict)), None)
    if ph is None:
        raise SystemExit("열려 있는 아크에 페이즈 객체가 없어 주입할 자리가 없다")
    own = {str(x) for x in a.get("cq") or []}
    ref = next((f"CQ-fin-{n}" for n in _fixed_cq(root) if f"CQ-fin-{n}" not in own), None)
    if ref is None:
        raise SystemExit("그 아크의 cq 밖에 있는 고정 절의 번호가 없어 주입할 자리가 없다")
    ph.setdefault("cq", []).append(ref)
    save_arcs(root, doc)
    return f"{a['name']}/{ph.get('name')}: {ref}"


def inj_56_drop(root):
    """페이즈 레코드에서 그 번호를 지운다.

    그 번호를 드는 페이즈가 하나뿐인 항을 고른다. 둘이 들면 하나를 지워도 배정이 남아 보고 줄이
    서지 않으므로, 그 주입은 검사가 아니라 고른 자리를 재게 된다.
    """
    doc, a = _open_arc(root)
    holders: dict[str, list[dict]] = {}
    for ph in a.get("phases") or []:
        if isinstance(ph, dict) and isinstance(ph.get("cq"), list):
            for ref in ph["cq"]:
                holders.setdefault(str(ref), []).append(ph)
    ref = next((x for x in sorted(holders) if len(holders[x]) == 1), None)
    if ref is None:
        raise SystemExit("한 페이즈만 드는 답할 항이 없어 지울 자리가 없다")
    ph = holders[ref][0]
    ph["cq"] = [x for x in ph["cq"] if str(x) != ref]
    save_arcs(root, doc)
    return ref


def inj_57_numeral(root):
    """그 머리 블록에 항의 수를 수사로 적는다.

    수는 고정 절의 줄 수에서 얻고 관형형으로 적는다. 관형형을 받는 꼴이 이 검사의 고유한 자리이므로,
    기수형으로만 주입하면 그 꼴이 빠져도 이 주입이 통과한다. 수사의 두 표는 검증기에서 가져온다.
    """
    f = root / check_wiki.CQ_FIXED_FILE
    text = f.read_text(encoding="utf-8")
    m = check_wiki.CQ_HEAD_BLOCK.match(text)
    if m is None:
        raise SystemExit(f"{check_wiki.CQ_FIXED_FILE} 의 머리 블록을 찾지 못해 주입할 자리가 없다")
    word = ko_word(len(_fixed_cq(root)))
    for card, attr in check_wiki.CQ_KO_ATTRIBUTIVE.items():
        if word.endswith(card):
            word = word[:-len(card)] + attr
            break
    sentence = f"이 파일은 {word} 물음을 든다."
    f.write_text(text[:m.end(1)] + sentence + "\n" + text[m.end(1):], encoding="utf-8")
    return sentence


def inj_58_unmarked(root):
    """표지를 들지 않는 행을 넣는다.

    지목 참조 대기 표의 마지막 행 뒤에 칸 셋의 행을 하나 더한다. 그 행의 칸이 블록의 어느 낱말도 품지
    않음을 넣기 전에 단언한다. 품으면 그 행이 표지를 든 행으로 읽혀 이 주입이 겨눈 자리가 서지 않는다.
    """
    led = wiki_common.Ledger(root)
    marks = check_wiki.queuemark_block(led)
    words = [v for _k, v in check_wiki.queuemark_words(marks)]
    f = root / wiki_common.READING_QUEUE_DOC
    lines = f.read_text(encoding="utf-8").split("\n")
    _at, rows = check_wiki.queue_section_rows("\n".join(lines),
                                              marks[check_wiki.QUEUEMARK_SECTION])
    if not rows:
        raise SystemExit("지목 참조 대기 표의 행이 없어 주입할 자리가 없다")
    row = "| 주입한 편 | 주입한 구멍 | 주입한 재료 |"
    if any(w in row for w in words):
        raise SystemExit("주입할 행이 표지의 낱말을 품는다")
    last = rows[-1][0]
    lines.insert(last, row)
    f.write_text("\n".join(lines), encoding="utf-8")
    return f"{wiki_common.READING_QUEUE_DOC}:{last + 1}"


def inj_59_dup(root):
    """같은 줄기의 파일을 하나 더 둔다. 번호는 실재하는 기록과 겹치지 않는 두 자리로 고른다."""
    d = root / "docs" / "extractions"
    files = [f for f in sorted(d.glob("extraction-*.md")) if wiki_common.EXTRACTION_FILE_NO.match(f.name)]
    if not files:
        raise SystemExit("번호를 든 추출 기록이 없어 주입할 자리가 없다")
    used = {int(wiki_common.EXTRACTION_FILE_NO.match(f.name).group(1)) for f in files}
    n = next(k for k in range(99, 9, -1) if k not in used)
    src = files[-1]
    stem = src.name[wiki_common.EXTRACTION_FILE_NO.match(src.name).end():]
    dst = d / f"extraction-{n:02d}-{stem}"
    dst.write_text(src.read_text(encoding="utf-8"), encoding="utf-8")
    return dst.name


def _inj_60_target(root):
    """회계층 파일 가운데 이름공간을 닫는 줄이 한 번 서는 첫 파일과 그 줄."""
    anchor = "\nend CrisisFramework.Accounting\n"
    for f in sorted((root / check_wiki.CURRENCY_GUARD_DIR).glob("*.lean")):
        src = f.read_text(encoding="utf-8")
        if src.count(anchor) == 1:
            return f, src, anchor
    raise SystemExit("이름공간을 닫는 줄이 한 번 서는 회계층 파일이 없어 주입할 자리가 없다")


def _inj_60_put(root, name, binders, args):
    f, src, anchor = _inj_60_target(root)
    decl = (f"\ndef {name} {{ι Party Obs Ext Lvl Currency : Type}}{binders}\n"
            f"    (e : Env ℤ Obs Ext Lvl){args} (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) : ℤ :=\n"
            f"  ∑ i ∈ S.index, evalTerm e (S.assign i).amount\n")
    # 주입한 합의 항이 금액을 평가하고 표시 통화 판정을 들지 않음을 넣기 전에 단언한다. 그 둘이
    # 서지 않으면 이 주입이 겨눈 자리가 서지 않는다.
    terms = [t for t in check_wiki.sum_terms(decl) if check_wiki.CURRENCY_GUARD_AMOUNT.search(t)]
    if len(terms) != 1 or check_wiki.CURRENCY_GUARD_CUR.search(terms[0]):
        raise SystemExit("주입할 선언의 합의 항이 겨눈 꼴이 아니다")
    f.write_text(src.replace(anchor, decl + anchor), encoding="utf-8")
    return name


def inj_60_unguarded(root):
    """가드 없는 합을 하나 더한다. 통화를 받지 않고 금액을 그대로 더하는 선언이다."""
    return _inj_60_put(root, "injectedUnguardedTotal", "", "")


def inj_60_binder_only(root):
    """타입클래스 바인더와 통화 인자만 더하고 합의 항은 그대로 둔 선언을 주입한다.

    가드를 선언 본문 전량에서 찾는 꼴이면 바인더의 결정 가능 등식이나 통화 인자를 가드로 읽어 이
    주입을 놓친다. 그 거짓 음성을 재는 항이며, 바인더와 인자가 주입한 문면에 실제로 서는지를 넣기
    전에 단언한다.
    """
    binders = " [DecidableEq Currency]"
    args = " (c : Currency)"
    name = _inj_60_put(root, "injectedBinderOnlyTotal", binders, args)
    f, src, _anchor = _inj_60_target(root)
    if binders.strip() not in src or args.strip() not in src:
        raise SystemExit("주입한 선언에 바인더와 통화 인자가 서지 않는다")
    return name


def inj_61_sum(root):
    """무리 행 하나의 편수를 하나 늘린다. 합계 행은 그대로 둔다.

    표를 고르는 쪽은 검증기의 함수를 그대로 부른다. 전사하면 그 검사가 표를 읽는 꼴을 고칠 때 이
    주입이 조용히 공허해진다.
    """
    led = wiki_common.Ledger(root)
    marker = wiki_common.inventorymark_block(led)[wiki_common.INVENTORYMARK_AGGREGATE]
    f = root / wiki_common.INVENTORY_DOC
    lines = f.read_text(encoding="utf-8").split("\n")
    rows = check_wiki.inventory_aggregate_rows("\n".join(lines), marker)
    hit = [(n, c) for n, c in rows if not c[0].startswith("**") and c[1].isdigit()]
    if not hit:
        raise SystemExit("집계 표에서 편수가 수인 무리 행을 찾지 못해 주입할 자리가 없다")
    n, cells = hit[0]
    lines[n - 1] = lines[n - 1].replace(f"| {cells[1]} |", f"| {int(cells[1]) + 1} |", 1)
    f.write_text("\n".join(lines), encoding="utf-8")
    return f"{wiki_common.INVENTORY_DOC}:{n}"


CASES = [
    ("1",   "wiki1-id-unique",             "같은 id 를 두 파일에 넣는다",                  inj_01, None),
    ("2",   "wiki2-origin-arc",            "없는 아크명을 적는다",                        inj_02, None),
    ("3",   "wiki3-origin-phase",          "선언되지 않은 페이즈를 적는다",                inj_03, None),
    ("3-a", "wiki3a-phase-form",           "다른 아크의 페이즈명을 적는다",                inj_03a, None),
    ("3",   "wiki3-origin-phase",          "권한을 준 패치를 지운다",                      inj_03p, None),
    ("4-a", "wiki4a-patch-from",           "없는 페이즈를 from 에 적는다",                 inj_04a, None),
    ("5",   "wiki5-closed-arc",            "닫힌 날 뒤의 날짜로 항목을 쓴다",              inj_05, None),
    ("5",   "wiki5-closed-arc",            "닫힌 날 앞의 날짜로 항목을 쓴다",              inj_05_before, None, "nocatch"),
    ("6",   "wiki6-tier-vocab",            "tactical 을 적는다",                           inj_06, None),
    ("7",   "wiki7-invariant-check",       "없는 단계명을 적는다",                         inj_07, None),
    ("8",   "wiki8-retire-target",         "같은 대상을 두 번 폐기한다",                   inj_08, None),
    ("9",   "wiki9-retire-reason",         "reason 을 비운다",                             inj_09, None),
    ("10",  "wiki10-ghost-ref",            "폐기된 id 를 related 에 넣는다",               inj_10, None),
    ("11",  "wiki11-reopen-kind",          "kind 를 비운다",                               inj_11, None),
    ("12",  "wiki12-reopen-ref",           "아크가 아닌 문자열을 arc_phase 에 적는다",     inj_12, None),
    ("13",  "wiki13-dd-target",            "없는 id 를 줄 주석에 적는다",                  inj_13, None),
    ("14",  "wiki14-dd-layer",             "회계층 파일에서 정의층 항목을 지목한다",       inj_14, None),
    ("15",  "wiki15-names-unique",         "같은 규율 ID 를 두 항목에 적는다",             inj_15, None),
    ("23",  "wiki23-rule-ghost",           "폐기한 날 뒤의 날짜로 폐기된 규율 ID 를 적는다",  inj_23_after, None),
    ("23",  "wiki23-rule-ghost",           "폐기한 날 앞의 날짜로 폐기된 규율 ID 를 적는다",  inj_23_before, None, "nocatch"),
    ("23",  "wiki23-rule-ghost",           "폐기한 날과 같은 날짜로 폐기된 규율 ID 를 적는다", inj_23_same, None),
    ("24",  "wiki24-doc-rule-ghost",       "상주 문서에 없는 규율 ID 를 적는다",           inj_24_missing, None),
    ("24",  "wiki24-doc-rule-ghost",       "선언되지 않은 폐기 규율을 적는다",             inj_24_retired, None),
    ("25",  "wiki25-marker-missing",       "최상위 선언 하나의 표지를 지운다",             inj_25, None),
    ("16",  "wiki16-trigger-fired",        "충족된 트리거를 등재한다",                     inj_16, None),
    ("17",  "wiki17-reopen-null",          "reopen_when 을 null 로 둔 항을 늘린다",        inj_17, None),
    ("43",  "wiki43-extraction-trigger-age", "실재하지 않는 번호를 extraction 의 ref 로 둔다",  inj_43, None),
    ("18",  "wiki18-arc-hole-disposition", "blocking 구멍을 등재한다",                      inj_18, None),
    ("19",  "wiki19-id-gap",               "항목을 지워 결번을 만든다",                    inj_19, None),
    ("20",  "wiki20-arc-holes",            "해소도 이관도 안 된 구멍을 든 채 닫는다",      inj_20, "charter"),
    ("21",  "wiki21-arc-blocking",         "발화도 해소도 이월도 안 된 blocking 을 든다",  inj_21, "charter"),
    ("28",  "wiki28-cq-exists",            "범위 밖인 아크의 cq 에 고정 절의 번호를 적는다", inj_28_out_of_scope, None),
    ("31",  "wiki31-hole-unassigned",      "열린 아크의 페이즈로 발화하는 이연 항을 쓴다",  inj_31, None),
    ("32",  "wiki32-closure-phase",         "선언되지 않은 페이즈 이름으로 종료 문서를 둔다",  inj_32, None),
    ("33",  "wiki33-rejection-registered",  "경계 안 문단의 머리말에 그 예약 낱말을 둔다",    inj_33_heading, None),
    ("33",  "wiki33-rejection-registered",  "경계 안 문단의 본문에만 그 낱말을 둔다",         inj_33_body, None, "nocatch"),
    ("33",  "wiki33-rejection-registered",  "for_decl 값을 없는 선언 이름으로 바꾼다",       inj_33_right, None),
    ("34",  "wiki34-heading-form",          "경계 안 머리말의 마침표를 지운다",              inj_34_period, None),
    ("34",  "wiki34-heading-form",          "HEADING 블록을 비운다",                        inj_34_empty, None),
    ("35",  "wiki35-doc-form",              "청사진을 docs/ 에 둔다",                       inj_35_plan, None),
    ("35",  "wiki35-doc-form",              "패치 조각을 docs/ 에 둔다",                    inj_35_patch, None),
    ("35",  "wiki35-doc-form",              "별지를 docs/ 에 둔다",                         inj_35_annex, None),
    ("35",  "wiki35-doc-form",              "종료 문서가 아닌 것을 phases/ 에 둔다",         inj_35_phases_other, None),
    ("35",  "wiki35-doc-form",              "선언되지 않은 아크 이름으로 종료 문서를 둔다",   inj_35_phases_arc, None),
    ("35",  "wiki35-doc-form",              "추출 기록의 접두사를 어긴다",                   inj_35_extraction, None),
    ("35",  "wiki35-doc-form",              "파일 이름에 대문자와 밑줄을 쓴다",              inj_35_case, None),
    ("35",  "wiki35-doc-form",              "허용되지 않은 디렉터리를 만든다",               inj_35_dir, None),
    ("35",  "wiki35-doc-form",              "원장 디렉터리에 새 파일을 둔다",                inj_35_ledger, None),
    ("36",  "wiki36-root-surface",          "무시 파일에서 /* 줄을 지운다",                  inj_36_open, None),
    ("36",  "wiki36-root-surface",          "없는 이름으로 되살림 줄을 더한다",              inj_36_ghost, None),
    ("37",  "wiki37-claude-ledger-count",   "원장 계수 표의 한 행의 수를 하나 틀리게 적는다",  inj_37_count, None),
    ("38",  "wiki38-partition-exclusivity",  "EXCL 블록의 분할에서 배타성 문단을 지운다",      inj_38_para, None),
    ("38",  "wiki38-partition-exclusivity",  "모든 쌍이 배타적이라 적은 분할의 배타 관계 한 쌍을 지운다", inj_38_pair, None),
    ("38",  "wiki38-partition-exclusivity",  "EXCL 블록을 비운다",                            inj_38_empty, None),
    ("39",  "wiki39-arc-holes-exist",       "어느 아크의 holes 에 이연 레지스터에 없는 id 를 적는다", inj_39_ghost, None),
    ("40",  "wiki40-check-count-places",    "계수 자리 가운데 하나의 수를 하나 틀리게 적는다", inj_40_count, None),
    ("41",  "wiki41-pointer-scope",  "면제 목록에 없는 항목의 산문에 살아 있는 조항의 주석을 지목하는 꼴을 적는다", inj_41_pointer, None),
    ("42",  "wiki42-session-clause-mirror", "블록에서 살아 있는 조항 하나를 지운다",        inj_42_drop, None),
    ("42",  "wiki42-session-clause-mirror", "블록에 폐기된 조항 하나를 더한다",             inj_42_retired, None),
    ("42",  "wiki42-session-clause-mirror", "블록에 원장에 없는 이름을 더한다",             inj_42_ghost, None),
    ("42",  "wiki42-session-clause-mirror", "블록을 비운다",                               inj_42_empty, None),
    ("35",  "wiki35-doc-form",              "같은 번호를 가진 추출 기록을 둔다",            inj_35_dupnum, None),
    ("35",  "wiki35-doc-form",              "중간 번호의 추출 기록을 옮겨 결번을 만든다",   inj_35_gapnum, None, "nocatch"),
    ("26",  "wiki26-clarify-target",        "clarifies 를 없는 id 로 바꾼다",               inj_26, None),
    ("27",  "wiki27-clarify-resolves",      "phrase 를 대상의 산문에 없는 값으로 바꾼다",   inj_27, None),
    ("30",  "wiki30-cq-unclaimed",          "어느 아크의 cq 에서 번호를 지워 미배정으로 만든다", inj_30, None),
    ("29",  "wiki29-arc-cq",                "닫힌 아크의 한 처분 항목의 답할 항 값을 다른 번호로 바꾼다", inj_29, INJ_29_ARC),
    ("41",  "wiki41-pointer-scope",  "규율 ID 뒤 그 거리 안에 그 낱말이 따르는 자리를 하나 더한다", inj_41_comment, None),
    ("41",  "wiki41-pointer-scope",  "소진 문서의 식별자 꼴을 하나 더한다",          inj_41_ephemeral, None),
    ("41",  "wiki41-pointer-scope",  "앞에 출처 표지도 문서 이름도 오지 않는 절 번호를 하나 더한다", inj_41_section, None),
    ("44",  "wiki44-injection-mirror",      "한 검사의 주입 항을 사례 목록에서 지운다",     inj_44_drop, None),
    ("44",  "wiki44-injection-mirror",      "명세에 없는 번호로 사례를 더한다",             inj_44_ghost, None),
    ("44",  "wiki44-injection-mirror",      "사례 목록의 한 항이 전사한 단계 id 를 다른 값으로 바꾼다", inj_44_step, None),
    ("45",  "wiki45-phase-hole-assignment", "한 페이즈의 holes 에서 구멍 하나를 지운다",    inj_45_hole_drop, None),
    ("45",  "wiki45-phase-hole-assignment", "두 페이즈가 같은 구멍을 들게 한다",            inj_45_hole_dup, None),
    ("45",  "wiki45-phase-hole-assignment", "열려 있는 아크의 페이즈 객체에서 builds 를 지운다", inj_45_builds_drop, None),
    ("45",  "wiki45-phase-hole-assignment", "닫힌 아크의 페이즈 원소를 문자열로 되돌린다",  inj_45_string, None),
    ("46",  "wiki46-block-list-mirror",     "목록에서 블록 이름 하나를 지운다",             inj_46_drop, None),
    ("46",  "wiki46-block-list-mirror",     "어느 검사도 읽지 않는 이름을 더한다",          inj_46_ghost, None),
    ("47",  "wiki47-spec-field-check-no",   "어느 필드 표의 검사 칸에 실재하지 않는 번호를 적는다", inj_47_ghost, None),
    ("48",  "wiki48-extraction-sourcing",   "조달처 줄의 구절을 그 기록의 다른 절에 있는 구절로 바꾼다", inj_48_phrase, None),
    ("48",  "wiki48-extraction-sourcing",   "경계 안 선언의 조달처 줄을 지운다",            inj_48_drop, None),
    ("48",  "wiki48-extraction-sourcing",   "지목의 절 번호를 실재하지 않는 것으로 바꾼다",  inj_48_section, None),
    ("48",  "wiki48-extraction-sourcing",   "구절을 최소 길이 아래로 줄인다",               inj_48_short, None),
    ("49",  "wiki49-extraction-unpointed",  "어느 docstring 도 지목하지 않는 기록을 하나 더한다", inj_49_unpointed, None),
    ("50",  "wiki50-inventory-extraction-mirror", "인벤토리의 구성원 행 하나에 실재하지 않는 기록 번호를 적는다", inj_50_missing, None),
    ("50",  "wiki50-inventory-extraction-mirror", "추출 기록 하나의 번호를 드는 구성원 행을 인벤토리에서 지운다", inj_50_ghost, None),
    ("50",  "wiki50-inventory-extraction-mirror", "미추출 표지를 든 구성원 행의 칸이 추출 기록의 편 제목을 든다", inj_50_unread, None),
    ("50",  "wiki50-inventory-extraction-mirror", "그 칸이 편 제목을 품되 비가 문턱 아래다", inj_50_unread_below, None, "nocatch"),
    ("51",  "wiki51-ledger-key-universe",  "원장 entry 하나에 그 유니버스 밖의 키를 더한다", inj_51_key, None),
    ("52",  "wiki52-open-arc-deferred-assignment", "열려 있는 아크를 ref 로 드는 차단 구멍 하나를 그 아크의 holes 에서 지운다", inj_52_arc, None),
    ("52",  "wiki52-open-arc-deferred-assignment", "그 구멍을 아크의 holes 에는 두고 모든 페이즈의 holes 에서 지운다", inj_52_phase, None),
    ("53",  "wiki53-inventory-member-marker", "구성원 행 하나에서 표지를 지운다", inj_53_drop, None),
    ("54",  "wiki54-inventory-unread-count", "미추출 표지를 든 행을 하나 늘린다", inj_54_add, None),
    ("55",  "wiki55-phase-cq-in-arc",        "페이즈 레코드에 그 아크의 cq 에 없는 번호를 넣는다", inj_55_foreign, None),
    ("56",  "wiki56-arc-cq-phase-assignment", "페이즈 레코드에서 그 번호를 지운다", inj_56_drop, None),
    ("57",  "wiki57-cq-count-numeral",       "그 머리 블록에 항의 수를 수사로 적는다", inj_57_numeral, None),
    ("58",  "wiki58-queue-marker",           "표지를 들지 않는 행을 넣는다", inj_58_unmarked, None),
    ("59",  "wiki59-extraction-stem-unique", "같은 줄기의 파일을 하나 더 둔다", inj_59_dup, None),
    ("60",  "wiki60-currency-guard",         "가드 없는 합을 하나 더한다", inj_60_unguarded, None),
    ("60",  "wiki60-currency-guard",         "타입클래스 바인더와 통화 인자만 더한 선언을 주입한다", inj_60_binder_only, None),
    ("61",  "wiki61-inventory-aggregate-sum", "무리 행 하나의 편수를 하나 늘린다", inj_61_sum, None),
]


def main() -> int:
    ap = argparse.ArgumentParser(description="원장 검증기의 음성 대조")
    ap.add_argument("--keep", action="store_true", help="사본을 지우지 않는다")
    args = ap.parse_args()

    tmp = Path(tempfile.mkdtemp(prefix="wiki-nc-"))
    rows = []
    # 항의 이름은 `<단계 id>#<차례>` 다. 검사 번호에 접미를 붙이면 실재하는 검사 3-a·4-a 와
    # 같은 꼴이 되어 항인지 검사인지 갈리지 않는다. 단계 id 는 네임스페이스가 다르다.
    seen_step: dict = {}
    case_id = []
    for _num, _step, *_ in CASES:
        seen_step[_step] = seen_step.get(_step, 0) + 1
        case_id.append(f"{_step}#{seen_step[_step]}")
    try:
        base_plain = run_checker(make_copy(tmp / "base"))
        base_arc = run_checker(make_copy(tmp / "base-arc"), arc_close="charter")

        for case, cid in zip(CASES, case_id):
            num, step, desc, fn, arc = case[:5]
            # 기대 방향이다. 기본은 잡히는 것이고 "nocatch" 는 잡히지 않아야 하는 항이다.
            expect = case[5] if len(case) > 5 else "catch"
            work = make_copy(tmp / f"case-{num.replace('-', '')}")
            # **표지가 주입 자신에게서 나온다.** 사례 목록이 그것을 상수로 들면 주입이 심는 값을
            # 고치는 회차가 그 상수를 잊어도 어느 검사도 걸리지 않으며, 그 낡음은 보고 부류의
            # 판정이 제 표지를 잃고 「새 보고 줄이 있다」로 떨어지는 꼴로만 남는다.
            marker = fn(work)
            got = run_checker(work, arc_close=arc)
            base = base_arc if arc else base_plain
            b = base["checks"].get(num, {"verdict": "?", "violations": [], "notes": []})
            g = got["checks"].get(num, {"verdict": "?", "violations": [], "notes": []})

            # 보고 부류인지를 **기준선의 판정에서 유도한다.** 번호를 박으면 새로 선 보고 검사가
            # 실패 부류로 갈려 「새 위반 줄 없음」으로 어긋남이 나며, 그 문면에서 검사의 결함과
            # 가름의 결함이 갈리지 않는다. 검사 43 이 그 자리였다. 보고만 하는 검사는 위반 줄을
            # 내지 않으므로 기준선의 판정이 `REPORT` 인 것이 그 부류의 정의와 같다.
            if b["verdict"] == "REPORT":
                # 판정은 기준선 차분으로 그대로 두고 표지의 거처만 옮긴다. 주입이 새로 만든
                # 자리의 줄은 같은 꼴의 줄이 뒤 회차의 기준선에 서더라도 여전히 새 줄이다.
                #
                # **표지가 비면 통과시키지 않는다.** 빈 표지는 어느 줄에나 들어 있는 것으로
                # 읽혀 판정이 「새 보고 줄이 있다」로 떨어지고, 그러면 주입이 겨눈 자리가
                # 보고에 잡혔는지를 재지 않는다.
                new_notes = [n for n in g["notes"] if n not in b["notes"]]
                if not marker:
                    ok = False
                    detail = "보고 부류인데 주입이 표지를 돌려주지 않았다"
                else:
                    ok = bool(new_notes) and any(str(marker) in n for n in new_notes)
                    detail = new_notes[0] if new_notes else "보고 줄에 변화 없음"
            elif expect == "nocatch":
                new_v = [v for v in g["violations"] if v not in b["violations"]]
                ok = not new_v
                detail = ("잡히지 않았다 (기대대로)" if ok
                          else "잡히지 않아야 하는데 잡혔다 — " + new_v[0])
            else:
                new_v = [v for v in g["violations"] if v not in b["violations"]]
                ok = g["verdict"] == "FAIL" and bool(new_v)
                detail = new_v[0] if new_v else "새 위반 줄 없음"
            rows.append((cid, num, desc, b["verdict"], g["verdict"], ok, detail))
            shutil.rmtree(work)
    finally:
        if not args.keep:
            shutil.rmtree(tmp, ignore_errors=True)
        else:
            print(f"사본을 남겼다: {tmp}")

    print()
    print("| 주입 항 | 검사 | 주입한 위반 | 기준선 | 주입 후 | 기대대로인가 |")
    print("|---|---|---|---|---|---|")
    for cid, num, desc, bv, gv, ok, _ in rows:
        print(f"| `{cid}` | {num} | {desc} | {bv} | {gv} | {'예' if ok else '**아니오**'} |")
    print()
    for cid, num, desc, bv, gv, ok, detail in rows:
        print(f"{cid}: {detail}")
    bad = [r for r in rows if not r[5]]
    print()
    print(f"주입 항 {len(rows)}개 가운데 기대대로인 것 {len(rows)-len(bad)}개, "
          f"어긋난 것 {len(bad)}개")
    if bad:
        print("어긋난 항: " + ", ".join(r[0] for r in bad))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
