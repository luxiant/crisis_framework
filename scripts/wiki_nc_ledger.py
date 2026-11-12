"""원장 갈래 검사의 음성 대조 주입.

`scripts/wiki_ledger.py` 가 든 검사의 주입 함수와 그 사례 목록을 든다. 주입이 어느 단위에
사는지는 그 주입이 겨눈 검사가 사는 단위에서 유도한다.
"""

from __future__ import annotations

import json
import pathlib
from datetime import date as _date, timedelta
from pathlib import Path
import wiki_common
import wiki_ledger
from wiki_nc_common import _fixed_cq, deferred_stub, edit, load, pick, save


def arcs(root: Path) -> dict:
    return json.loads((root / "docs" / "arcs.json").read_text(encoding="utf-8"))


def save_arcs(root: Path, doc: dict) -> None:
    (root / "docs" / "arcs.json").write_text(
        json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


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


def inj_11(root):
    tgt = pick(root, "deferred", lambda e: isinstance(e.get("reopen_when"), dict))
    edit(root, "deferred", tgt["id"], lambda e: e["reopen_when"].__setitem__("kind", ""))


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
        if x.get("status") == wiki_ledger.ARC_OUT_OF_SCOPE:
            return x["name"]
    for x in doc["arcs"]:
        if x.get("status") == "reserved" and not (x.get("cq") or []):
            x["status"] = wiki_ledger.ARC_OUT_OF_SCOPE
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
                if x.get("status") != wiki_ledger.ARC_OUT_OF_SCOPE
                for c in (x.get("cq") or [])), None)
    if ref is None:
        raise SystemExit("음성 대조: 고정 절의 번호를 든 아크가 없어 주입 대상이 없다")
    for x in doc["arcs"]:
        if x["name"] == name:
            x["cq"] = [ref]
    save_arcs(root, doc)
    return f"{name}/{ref}"


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


def inj_16(root):
    eid = "CF-9016"
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(
        eid, {"kind": "artifact", "ref": "docs/arcs.json"}))
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


# ----------------------------------------------------- 검사 42 · 조항 목록의 거울

def _clause_block(root: Path) -> tuple[pathlib.Path, str]:
    """값 정본의 경로와 그 본문. 블록이 없으면 주입이 설 자리가 없으므로 멈춘다."""
    f = root / "docs" / "baseline.md"
    s = f.read_text(encoding="utf-8")
    if wiki_ledger.SESSIONCLAUSE_BLOCK.search(s) is None:
        raise SystemExit("값 정본에 SESSIONCLAUSE 블록이 없어 주입이 서지 않는다")
    return f, s


def inj_42_drop(root):
    """블록에서 살아 있는 조항 하나를 지운다.

    지울 조항을 블록과 원장에서 함께 고른다. 블록의 줄만 보고 고르면 그것이 폐기된 조항일 때
    주입이 다른 갈래를 재게 된다. 판정과 같은 읽기를 쓰는 까닭은 전사하면 한쪽을 고칠 때 다른
    쪽이 조용히 낡는 것이다.
    """
    led = wiki_common.Ledger(root)
    _series, clauses = wiki_ledger.sessionclause_rules(led)
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
    series, clauses = wiki_ledger.sessionclause_rules(led)
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
    series, _clauses = wiki_ledger.sessionclause_rules(led)
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
    f.write_text(wiki_ledger.SESSIONCLAUSE_BLOCK.sub(
        "<!-- SESSIONCLAUSE:BEGIN -->\n<!-- SESSIONCLAUSE:END -->", s), encoding="utf-8")
    return "SESSIONCLAUSE"


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


# 이 단위가 거느리는 음성 대조의 사례. 하네스가 단위 순서로 이 목록을 이어
# 붙이며 사례의 손 열거를 들지 않는다. **선언으로 두는 까닭은** 이 목록을 읽는
# 검사가 뿌리의 소스를 텍스트로 읽으므로 모듈의 값을 모으는 꼴이면 그 검사가
# 읽을 문면이 없다는 것이다.
CASES = [
    ("1", "wiki1-id-unique", "같은 id 를 두 파일에 넣는다", inj_01, None),
    ("2", "wiki2-origin-arc", "없는 아크명을 적는다", inj_02, None),
    ("3", "wiki3-origin-phase", "선언되지 않은 페이즈를 적는다", inj_03, None),
    ("3-a", "wiki3a-phase-form", "다른 아크의 페이즈명을 적는다", inj_03a, None),
    ("3", "wiki3-origin-phase", "권한을 준 패치를 지운다", inj_03p, None),
    ("4-a", "wiki4a-patch-from", "없는 페이즈를 from 에 적는다", inj_04a, None),
    ("5", "wiki5-closed-arc", "닫힌 날 뒤의 날짜로 항목을 쓴다", inj_05, None),
    ("5", "wiki5-closed-arc", "닫힌 날 앞의 날짜로 항목을 쓴다", inj_05_before, None, "nocatch"),
    ("6", "wiki6-tier-vocab", "tactical 을 적는다", inj_06, None),
    ("7", "wiki7-invariant-check", "없는 단계명을 적는다", inj_07, None),
    ("8", "wiki8-retire-target", "같은 대상을 두 번 폐기한다", inj_08, None),
    ("9", "wiki9-retire-reason", "reason 을 비운다", inj_09, None),
    ("11", "wiki11-reopen-kind", "kind 를 비운다", inj_11, None),
    ("15", "wiki15-names-unique", "같은 규율 ID 를 두 항목에 적는다", inj_15, None),
    ("23", "wiki23-rule-ghost", "폐기한 날 뒤의 날짜로 폐기된 규율 ID 를 적는다", inj_23_after, None),
    ("23", "wiki23-rule-ghost", "폐기한 날 앞의 날짜로 폐기된 규율 ID 를 적는다", inj_23_before, None, "nocatch"),
    ("23", "wiki23-rule-ghost", "폐기한 날과 같은 날짜로 폐기된 규율 ID 를 적는다", inj_23_same, None),
    ("16", "wiki16-trigger-fired", "충족된 트리거를 등재한다", inj_16, None),
    ("17", "wiki17-reopen-null", "reopen_when 을 null 로 둔 항을 늘린다", inj_17, None),
    ("18", "wiki18-arc-hole-disposition", "blocking 구멍을 등재한다", inj_18, None),
    ("19", "wiki19-id-gap", "항목을 지워 결번을 만든다", inj_19, None),
    ("20", "wiki20-arc-holes", "해소도 이관도 안 된 구멍을 든 채 닫는다", inj_20, "charter"),
    ("21", "wiki21-arc-blocking", "발화도 해소도 이월도 안 된 blocking 을 든다", inj_21, "charter"),
    ("28", "wiki28-cq-exists", "범위 밖인 아크의 cq 에 고정 절의 번호를 적는다", inj_28_out_of_scope, None),
    ("31", "wiki31-hole-unassigned", "열린 아크의 페이즈로 발화하는 이연 항을 쓴다", inj_31, None),
    ("39", "wiki39-arc-holes-exist", "어느 아크의 holes 에 이연 레지스터에 없는 id 를 적는다", inj_39_ghost, None),
    ("42", "wiki42-session-clause-mirror", "블록에서 살아 있는 조항 하나를 지운다", inj_42_drop, None),
    ("42", "wiki42-session-clause-mirror", "블록에 폐기된 조항 하나를 더한다", inj_42_retired, None),
    ("42", "wiki42-session-clause-mirror", "블록에 원장에 없는 이름을 더한다", inj_42_ghost, None),
    ("42", "wiki42-session-clause-mirror", "블록을 비운다", inj_42_empty, None),
    ("26", "wiki26-clarify-target", "clarifies 를 없는 id 로 바꾼다", inj_26, None),
    ("27", "wiki27-clarify-resolves", "phrase 를 대상의 산문에 없는 값으로 바꾼다", inj_27, None),
    ("30", "wiki30-cq-unclaimed", "어느 아크의 cq 에서 번호를 지워 미배정으로 만든다", inj_30, None),
    ("29", "wiki29-arc-cq", "닫힌 아크의 한 처분 항목의 답할 항 값을 다른 번호로 바꾼다", inj_29, INJ_29_ARC),
    ("45", "wiki45-phase-hole-assignment", "한 페이즈의 holes 에서 구멍 하나를 지운다", inj_45_hole_drop, None),
    ("45", "wiki45-phase-hole-assignment", "두 페이즈가 같은 구멍을 들게 한다", inj_45_hole_dup, None),
    ("45", "wiki45-phase-hole-assignment", "열려 있는 아크의 페이즈 객체에서 builds 를 지운다", inj_45_builds_drop, None),
    ("45", "wiki45-phase-hole-assignment", "닫힌 아크의 페이즈 원소를 문자열로 되돌린다", inj_45_string, None),
    ("52", "wiki52-open-arc-deferred-assignment", "열려 있는 아크를 ref 로 드는 차단 구멍 하나를 그 아크의 holes 에서 지운다", inj_52_arc, None),
    ("52", "wiki52-open-arc-deferred-assignment", "그 구멍을 아크의 holes 에는 두고 모든 페이즈의 holes 에서 지운다", inj_52_phase, None),
    ("55", "wiki55-phase-cq-in-arc", "페이즈 레코드에 그 아크의 cq 에 없는 번호를 넣는다", inj_55_foreign, None),
    ("56", "wiki56-arc-cq-phase-assignment", "페이즈 레코드에서 그 번호를 지운다", inj_56_drop, None),
]
