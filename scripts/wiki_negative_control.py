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

셋째는 **잡히지 않아야 하는 항**이며 `CASES` 의 일곱째 자리에 `"nocatch"` 를 둔 항이 그것이다.
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
from datetime import date as _date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_wiki          # noqa: E402  주입 대상을 검증기의 수집기로 고른다
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
    phase = f"charter-{max(int(p.rsplit('-', 1)[1]) for p in charter['phases']) + 1}"
    if phase in charter["phases"]:
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
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(
        "CF-9016", {"kind": "artifact", "ref": "docs/arcs.json"}))
    save(root, "deferred", doc)


def inj_43(root):
    """실재하지 않는 번호를 `extraction` 트리거의 `ref` 로 둔 항을 등재한다.

    그 항이 「발화할 수 없는 항」으로 세어져야 한다. 번호의 꼴을 만족하므로 검사 12 는 그것을
    형식으로 받으며, 그 번호의 기록이 실재하는지를 보는 자리가 검사 43 하나임이 이 주입으로
    선다. 추출 기록의 번호가 두 자리이고 현행 열이 49 까지이므로 97 을 고른다."""
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(
        "CF-9043", {"kind": "extraction", "ref": "E-97"}))
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
    led = check_wiki.Ledger(root)
    since, forms = check_wiki.heading_rules(led)
    inside = [] if since is None else [d for d in led.doc_decls() if d.no >= since]
    return inside, forms


def _append_para(root: Path, d, para: str) -> None:
    """그 선언의 docstring 말미에 문단 하나를 더한다.

    선언 줄보다 앞에 선 마지막 `/-- -/` 블록이 그 선언의 docstring 이라는 것은 검증기의
    수집기가 쓰는 규칙과 같다. 그 규칙을 전사하지 않으려고 같은 정규식을 불러 쓴다."""
    f = root / d.rel
    text = f.read_text(encoding="utf-8")
    cut = sum(len(x) for x in text.splitlines(keepends=True)[:d.line - 1])
    blocks = [m for m in check_wiki.DOC_BLOCK.finditer(text) if m.end() <= cut]
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
            head = check_wiki.para_heading(p)
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
    led = check_wiki.Ledger(root)
    forms = check_wiki.heading_rules(led)[1].get(check_wiki.EXCLUSIVITY_WORD, [])
    got = check_wiki.excl_registry(led)
    if got is None:
        raise SystemExit("등록 관계를 드는 선언이 없어 주입 대상이 없다")
    decl, parts, excl = got
    paras = []
    for p in decl.paras:
        head = check_wiki.para_heading(p)
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
    return check_wiki.para_heading(para)


def inj_38_pair(root):
    """모든 쌍이 배타적이라 적은 분할의 배타 관계 한 쌍을 지운다.

    문단은 그대로 두고 관계만 지운다. 그 방향을 재지 않으면 「문단과 관계를 함께 본다」와
    「문단만 본다」가 갈리지 않는다.
    """
    led, decl, parts, _excl, paras = _excl_paras(root)
    labels = check_wiki.concept_labels(led, decl.rel)
    forms = check_wiki.heading_rules(led)[1][check_wiki.EXCLUSIVITY_WORD]
    all_form = next(f for f in forms if check_wiki.EXCL_ALL_MARK in f)
    target = None
    for name in _excl_block(root):
        label = labels.get(name)
        cells = parts.get(name) or []
        if not label or len(cells) < 2:
            continue
        for para, is_all in paras:
            fill = check_wiki.heading_fill(all_form, check_wiki.para_heading(para) or "")
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
    led = check_wiki.Ledger(root)
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
    unit = {v: w for w, v in check_wiki.COUNT_KO_UNIT.items()}
    for tens, base in sorted(check_wiki.COUNT_KO_TENS.items(),
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
    """계수 자리 일곱 가운데 하나의 수를 하나 틀리게 적는다.

    명세의 머리 계수가 든 전체 계수를 하나 올린다. 자리를 하나만 건드리는 주입이므로 그 자리와
    정본이 어긋나는 것이 잡혀야 하고, 일곱 자리마다 따로 돌리지 않는다. 판정 대상 하나에 한 번만
    돌린다는 요구가 그것을 든다.
    """
    name, rel, pat, _keys = check_wiki.COUNT_PLACES[0]
    f = root / rel
    text = f.read_text(encoding="utf-8")
    m = pat.search(text)
    if m is None:
        raise SystemExit(f"`{name}` 의 자리를 찾지 못했다")
    said = check_wiki.ko_count(m.group(1))
    if said is None:
        raise SystemExit(f"`{name}` 이 든 수사 `{m.group(1)}` 를 값으로 읽을 수 없다")
    wrong = ko_word(said + 1)
    at, end = m.span(1)
    f.write_text(text[:at] + wrong + text[end:], encoding="utf-8")
    return f"{name}: {m.group(1)}→{wrong}"


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
    led = check_wiki.Ledger(root)
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
    led = check_wiki.Ledger(root)
    series, clauses = check_wiki.sessionclause_rules(led)
    dead = sorted(n for n, owner in led.name_owner.items()
                  if n not in clauses and owner in led.dead
                  and (lambda m: m is not None and (m.group(2) or "PH-R") in series)(
                      check_wiki.RULE_TOKEN.fullmatch(n)))
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
    led = check_wiki.Ledger(root)
    series, _clauses = check_wiki.sessionclause_rules(led)
    ser = sorted(series)[0]
    used = [int(m.group(3)) for m in
            (check_wiki.RULE_TOKEN.fullmatch(n) for n in led.name_owner)
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
    led = check_wiki.Ledger(root)
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
    led = check_wiki.Ledger(root)
    if ghost in led.by_id:
        raise SystemExit(f"{ghost} 가 원장에 이미 있어 없는 id 로 쓰지 못한다")
    edit(root, "decisions", tail["id"], lambda e: e.__setitem__("clarifies", ghost))
    return ghost


def inj_27(root):
    """꼬리의 `resolves` 의 `phrase` 를 대상 항목의 산문에 없는 값으로 바꾼다.

    `clarifies` 는 그대로 두어 검사 26 이 걸리지 않게 한다. 대상이 살아 있는 꼬리를 고르는
    까닭은 검사 27 이 폐기된 대상을 건너뛰어 주입이 조건을 만들지 못하는 것이다.
    """
    led = check_wiki.Ledger(root)
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
    led = check_wiki.Ledger(root)
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
    led = check_wiki.Ledger(root)
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
                 check_wiki.Ledger(root).pointer_scan_targets(), dist).items()}
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


CASES = [
    ("1",   "wiki1-id-unique",             "같은 id 를 두 파일에 넣는다",                  inj_01,  None, None),
    ("2",   "wiki2-origin-arc",            "없는 아크명을 적는다",                        inj_02,  None, None),
    ("3",   "wiki3-origin-phase",          "선언되지 않은 페이즈를 적는다",                inj_03,  None, None),
    ("3-a", "wiki3a-phase-form",           "다른 아크의 페이즈명을 적는다",                inj_03a, None, None),
    ("3",   "wiki3-origin-phase",          "권한을 준 패치를 지운다",                      inj_03p, None, None),
    ("4-a", "wiki4a-patch-from",           "없는 페이즈를 from 에 적는다",                 inj_04a, None, None),
    ("5",   "wiki5-closed-arc",            "닫힌 날 뒤의 날짜로 항목을 쓴다",              inj_05,  None, None),
    ("5",   "wiki5-closed-arc",            "닫힌 날 앞의 날짜로 항목을 쓴다",              inj_05_before, None, None, "nocatch"),
    ("6",   "wiki6-tier-vocab",            "tactical 을 적는다",                           inj_06,  None, None),
    ("7",   "wiki7-invariant-check",       "없는 단계명을 적는다",                         inj_07,  None, None),
    ("8",   "wiki8-retire-target",         "같은 대상을 두 번 폐기한다",                   inj_08,  None, None),
    ("9",   "wiki9-retire-reason",         "reason 을 비운다",                             inj_09,  None, None),
    ("10",  "wiki10-ghost-ref",            "폐기된 id 를 related 에 넣는다",               inj_10,  None, None),
    ("11",  "wiki11-reopen-kind",          "kind 를 비운다",                               inj_11,  None, None),
    ("12",  "wiki12-reopen-ref",           "아크가 아닌 문자열을 arc_phase 에 적는다",     inj_12,  None, None),
    ("13",  "wiki13-dd-target",            "없는 id 를 줄 주석에 적는다",                  inj_13,  None, None),
    ("14",  "wiki14-dd-layer",             "회계층 파일에서 정의층 항목을 지목한다",       inj_14,  None, None),
    ("15",  "wiki15-names-unique",         "같은 규율 ID 를 두 항목에 적는다",             inj_15,  None, None),
    ("23",  "wiki23-rule-ghost",           "폐기한 날 뒤의 날짜로 폐기된 규율 ID 를 적는다",  inj_23_after,  None, None),
    ("23",  "wiki23-rule-ghost",           "폐기한 날 앞의 날짜로 폐기된 규율 ID 를 적는다",  inj_23_before, None, None, "nocatch"),
    ("23",  "wiki23-rule-ghost",           "폐기한 날과 같은 날짜로 폐기된 규율 ID 를 적는다", inj_23_same,   None, None),
    ("24",  "wiki24-doc-rule-ghost",       "상주 문서에 없는 규율 ID 를 적는다",           inj_24_missing,  None, None),
    ("24",  "wiki24-doc-rule-ghost",       "선언되지 않은 폐기 규율을 적는다",             inj_24_retired,  None, None),
    ("25",  "wiki25-marker-missing",       "최상위 선언 하나의 표지를 지운다",             inj_25,          None, None),
    ("16",  "wiki16-trigger-fired",        "충족된 트리거를 등재한다",                     inj_16,  "CF-9016", None),
    ("17",  "wiki17-reopen-null",          "reopen_when 을 null 로 둔 항을 늘린다",        inj_17,  "CF-9017", None),
    ("43",  "wiki43-extraction-trigger-age", "실재하지 않는 번호를 extraction 의 ref 로 둔다",  inj_43,  "CF-9043", None),
    ("18",  "wiki18-arc-hole-disposition", "blocking 구멍을 등재한다",                      inj_18,  "CF-9018", None),
    ("19",  "wiki19-id-gap",               "항목을 지워 결번을 만든다",                    inj_19,  "CF-100",  None),
    ("20",  "wiki20-arc-holes",            "해소도 이관도 안 된 구멍을 든 채 닫는다",      inj_20,  None, "charter"),
    ("21",  "wiki21-arc-blocking",         "발화도 해소도 이월도 안 된 blocking 을 든다",  inj_21,  None, "charter"),
    ("28",  "wiki28-cq-exists",            "범위 밖인 아크의 cq 에 고정 절의 번호를 적는다", inj_28_out_of_scope, None, None),
    ("31",  "wiki31-hole-unassigned",      "열린 아크의 페이즈로 발화하는 이연 항을 쓴다",  inj_31,  None, None),
    ("32",  "wiki32-closure-phase",         "선언되지 않은 페이즈 이름으로 종료 문서를 둔다",  inj_32, None, None),
    ("33",  "wiki33-rejection-registered",  "경계 안 문단의 머리말에 그 예약 낱말을 둔다",    inj_33_heading, None, None),
    ("33",  "wiki33-rejection-registered",  "경계 안 문단의 본문에만 그 낱말을 둔다",         inj_33_body,  None, None, "nocatch"),
    ("33",  "wiki33-rejection-registered",  "for_decl 값을 없는 선언 이름으로 바꾼다",       inj_33_right, None, None),
    ("34",  "wiki34-heading-form",          "경계 안 머리말의 마침표를 지운다",              inj_34_period, None, None),
    ("34",  "wiki34-heading-form",          "HEADING 블록을 비운다",                        inj_34_empty,  None, None),
    ("35",  "wiki35-doc-form",              "청사진을 docs/ 에 둔다",                       inj_35_plan,         None, None),
    ("35",  "wiki35-doc-form",              "패치 조각을 docs/ 에 둔다",                    inj_35_patch,        None, None),
    ("35",  "wiki35-doc-form",              "별지를 docs/ 에 둔다",                         inj_35_annex,        None, None),
    ("35",  "wiki35-doc-form",              "종료 문서가 아닌 것을 phases/ 에 둔다",         inj_35_phases_other, None, None),
    ("35",  "wiki35-doc-form",              "선언되지 않은 아크 이름으로 종료 문서를 둔다",   inj_35_phases_arc,   None, None),
    ("35",  "wiki35-doc-form",              "추출 기록의 접두사를 어긴다",                   inj_35_extraction,   None, None),
    ("35",  "wiki35-doc-form",              "파일 이름에 대문자와 밑줄을 쓴다",              inj_35_case,         None, None),
    ("35",  "wiki35-doc-form",              "허용되지 않은 디렉터리를 만든다",               inj_35_dir,          None, None),
    ("35",  "wiki35-doc-form",              "원장 디렉터리에 새 파일을 둔다",                inj_35_ledger,       None, None),
    ("36",  "wiki36-root-surface",          "무시 파일에서 /* 줄을 지운다",                  inj_36_open,         None, None),
    ("36",  "wiki36-root-surface",          "없는 이름으로 되살림 줄을 더한다",              inj_36_ghost,        None, None),
    ("37",  "wiki37-claude-ledger-count",   "원장 계수 표의 한 행의 수를 하나 틀리게 적는다",  inj_37_count,        None, None),
    ("38",  "wiki38-partition-exclusivity",  "EXCL 블록의 분할에서 배타성 문단을 지운다",      inj_38_para,         None, None),
    ("38",  "wiki38-partition-exclusivity",  "모든 쌍이 배타적이라 적은 분할의 배타 관계 한 쌍을 지운다", inj_38_pair, None, None),
    ("38",  "wiki38-partition-exclusivity",  "EXCL 블록을 비운다",                            inj_38_empty,        None, None),
    ("39",  "wiki39-arc-holes-exist",       "어느 아크의 holes 에 이연 레지스터에 없는 id 를 적는다", inj_39_ghost, None, None),
    ("40",  "wiki40-check-count-places",    "계수 자리 일곱 가운데 하나의 수를 하나 틀리게 적는다", inj_40_count, None, None),
    ("41",  "wiki41-rule-comment-pointer",  "면제 목록에 없는 항목의 산문에 살아 있는 조항의 주석을 지목하는 꼴을 적는다", inj_41_pointer, None, None),
    ("42",  "wiki42-session-clause-mirror", "블록에서 살아 있는 조항 하나를 지운다",        inj_42_drop,    None, None),
    ("42",  "wiki42-session-clause-mirror", "블록에 폐기된 조항 하나를 더한다",             inj_42_retired, None, None),
    ("42",  "wiki42-session-clause-mirror", "블록에 원장에 없는 이름을 더한다",             inj_42_ghost,   None, None),
    ("42",  "wiki42-session-clause-mirror", "블록을 비운다",                               inj_42_empty,   None, None),
    ("35",  "wiki35-doc-form",              "같은 번호를 가진 추출 기록을 둔다",            inj_35_dupnum,  None, None),
    ("35",  "wiki35-doc-form",              "중간 번호의 추출 기록을 옮겨 결번을 만든다",   inj_35_gapnum,  None, None, "nocatch"),
    ("26",  "wiki26-clarify-target",        "clarifies 를 없는 id 로 바꾼다",               inj_26,         None, None),
    ("27",  "wiki27-clarify-resolves",      "phrase 를 대상의 산문에 없는 값으로 바꾼다",   inj_27,         None, None),
    ("30",  "wiki30-cq-unclaimed",          "어느 아크의 cq 에서 번호를 지워 미배정으로 만든다", inj_30,    "CQ-fin-", None),
    ("29",  "wiki29-arc-cq",                "닫힌 아크의 한 처분 항목의 답할 항 값을 다른 번호로 바꾼다", inj_29, None, INJ_29_ARC),
    ("41",  "wiki41-rule-comment-pointer",  "규율 ID 뒤 그 거리 안에 그 낱말이 따르는 자리를 하나 더한다", inj_41_comment,   None, None),
    ("41",  "wiki41-rule-comment-pointer",  "소진 문서의 식별자 꼴을 하나 더한다",          inj_41_ephemeral, None, None),
    ("41",  "wiki41-rule-comment-pointer",  "앞에 출처 표지도 문서 이름도 오지 않는 절 번호를 하나 더한다", inj_41_section, None, None),
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
            num, step, desc, fn, marker, arc = case[:6]
            # 기대 방향이다. 기본은 잡히는 것이고 "nocatch" 는 잡히지 않아야 하는 항이다.
            expect = case[6] if len(case) > 6 else "catch"
            work = make_copy(tmp / f"case-{num.replace('-', '')}")
            extra = fn(work)
            got = run_checker(work, arc_close=arc)
            base = base_arc if arc else base_plain
            b = base["checks"].get(num, {"verdict": "?", "violations": [], "notes": []})
            g = got["checks"].get(num, {"verdict": "?", "violations": [], "notes": []})

            # 보고 부류인지를 **기준선의 판정에서 유도한다.** 번호를 박으면 새로 선 보고 검사가
            # 실패 부류로 갈려 「새 위반 줄 없음」으로 어긋남이 나며, 그 문면에서 검사의 결함과
            # 가름의 결함이 갈리지 않는다. 검사 43 이 그 자리였다. 보고만 하는 검사는 위반 줄을
            # 내지 않으므로 기준선의 판정이 `REPORT` 인 것이 그 부류의 정의와 같다.
            if b["verdict"] == "REPORT":
                new_notes = [n for n in g["notes"] if n not in b["notes"]]
                hit = any((marker or "") in n for n in new_notes)
                ok = bool(new_notes) and hit
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
                if extra:
                    detail = detail.replace(str(extra), str(extra))
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
