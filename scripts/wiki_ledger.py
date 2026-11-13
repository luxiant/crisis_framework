# -*- coding: utf-8 -*-
"""원장 검증기의 검사 가운데 원장 entry 와 아크 값 정본을 유니버스로 드는 검사.

이 단위가 자기 검사의 목록을 `CHECKS` 로 선언하고 러너가 그 목록을 이어 붙인다.
검사의 번호와 단계 id 는 그 선언이 들고 이 파일이 그 계수를 들지 않는다.
"""
from __future__ import annotations

import re

from wiki_common import (
    CQ_REF,
    ID_FORM,
    Ledger,
    RULE_SERIES,
    RULE_TOKEN,
    Report,
    _baseline_block,
    arc_phase_names,
    cq_fixed,
    phase_cq_records,
    trigger_fired,
)

TIERS = ("invariant", "policy", "finding")


REOPEN_KINDS = ("artifact", "extraction", "arc_phase", "blocking")


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
        if phase not in arc_phase_names(a):
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
        if p.get("from") not in arc_phase_names(a):
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
               "tier: invariant 인 항목의 check 가 vrun.py 의 선언된 단계에 실재하는가", "fail")
    steps = led.verify_steps
    r.note(f"vrun.py 가 선언한 단계 id: {steps}")
    for e in led.reg["decisions"]:
        if e.get("tier") != "invariant":
            continue
        val = e.get("check")
        if not val:
            r.bad(f"{e.get('id')}: tier 가 invariant 인데 check 가 비었다")
        elif val not in steps:
            r.bad(f"{e.get('id')}: check `{val}` 가 vrun.py 의 선언된 단계에 없다")
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
# 읽는다. 어휘의 정본은 SPEC §3.6 의 아크 레코드 필드 표다.
ARC_OUT_OF_SCOPE = "out_of_scope"


def arc_out_of_scope(led: Ledger, name: str) -> bool:
    """그 아크가 범위 밖인가.

    **검사 28 이 이 판정을 부른다.** 재개 트리거 쪽에 같은 판정을 거는 것은 이 판에 서지
    않으며, 범위 밖이 된 시점을 드는 필드가 아크 레코드에 없어서 이미 등재된 트리거를 가를
    자리가 없기 때문이다. 그 자리가 서면 이 함수를 두 검사가 함께 부른다.
    """
    a = led.arcs.get(name)
    return bool(a) and a.get("status") == ARC_OUT_OF_SCOPE


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
    nulls: list[dict] = []
    dropped: list[str] = []
    for e in led.reg["deferred"]:
        if e.get("reopen_when") is not None:
            continue
        # 폐기된 이연 항목은 살아 있는 구멍이 아니다. 함께 세면 트리거를 쓸 수 없는 항의 수를
        # 밖에서 셀 수 없다(CF-684). 뺀 건수와 그 ID 는 같은 줄에 남긴다.
        if e.get("id") in led.dead:
            dropped.append(str(e.get("id")))
            continue
        nulls.append(e)
    r.note(f"reopen_when: null {len(nulls)}건"
           + (f" · 폐기된 이연 항목 {len(dropped)}건을 뺐다({', '.join(dropped)})"
              if dropped else " · 뺀 폐기분 0건"))
    for e in nulls:
        r.note(f"{e.get('id')} — names {e.get('names')}")
    return r


# 검사 18 의 유니버스. `ref` 가 아크의 이름을 드는 트리거의 종류이며, 그 둘만 아크를 가리킨다.
# `artifact` 는 경로를 들고 `extraction` 은 추출 기록의 번호를 들므로 아크로 묶을 수 없다.
# 이 유니버스를 `blocking` 하나로 좁히면 아크를 가리키는 다른 종류의 구멍이 처분됐는지 자고
# 있는지가 어느 보고에도 나지 않는다(SPEC §2.2).
ARC_POINTING_KINDS = ("arc_phase", "blocking")


def check_18(led: Ledger) -> Report:
    r = Report("18", "wiki18-arc-hole-disposition", "아크별 구멍의 처분 내역", "report")
    rows: dict = {}
    dropped: list[str] = []
    for e in led.reg["deferred"]:
        rw = e.get("reopen_when")
        if isinstance(rw, dict) and rw.get("kind") in ARC_POINTING_KINDS:
            # 폐기된 구멍은 처분이 끝난 것이므로 목록에서 뺀다. 뺀 건수는 출력에 남긴다(CF-684).
            if e.get("id") in led.dead:
                dropped.append(str(e.get("id")))
                continue
            rows.setdefault(str(rw.get("ref")), []).append(
                (str(e.get("id")), str(rw.get("kind"))))
    kinds: dict = {}
    for holes in rows.values():
        for _id, kind in holes:
            kinds[kind] = kinds.get(kind, 0) + 1
    r.note(f"아크를 가리키는 구멍 {sum(len(v) for v in rows.values())}건, 아크 {len(rows)}개"
           + (" · 종류별 " + " · ".join(f"{k} {n}" for k, n in sorted(kinds.items()))
              if kinds else " · 종류별 없음")
           + (f" · 폐기된 이연 항목 {len(dropped)}건을 뺐다({', '.join(dropped)})"
              if dropped else " · 뺀 폐기분 0건"))
    # 아크마다 상태와 구멍의 종류를 함께 싣는다. 상태만 실으면 범위 밖인 아크를 가리키는 구멍이
    # 처분된 것과 자고 있는 것이 그 줄에서 갈리지 않고, 종류만 실으면 그 아크가 열렸는지가
    # 갈리지 않는다. 둘이 함께 서야 그 가름이 보고 줄 하나에서 선다(`CF-1491`).
    for arc, holes in sorted(rows.items()):
        a = led.arcs.get(arc) or {}
        # 번호 순으로 낸다. 문자열로 정렬하면 `CF-834` 가 `CF-1405` 뒤에 서서 읽는 쪽이 그 줄을
        # 번호로 훑을 수 없다. 번호로 읽히지 않는 id 는 맨 뒤에 모아 문자열 순으로 둔다.
        def by_number(pair: tuple[str, str]) -> tuple[int, str]:
            m = ID_FORM.match(pair[0])
            return (int(m.group(1)) if m else 1 << 30, pair[0])
        r.note(f"{arc} (status {a.get('status')}) — "
               + ", ".join(f"{i} ({k})" for i, k in sorted(holes, key=by_number)))
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


# 검사 29 가 읽는 `cq_disposition` 의 `kind` 레지스터. S-6 의 종료 조건 둘이다(SPEC §3.2).
CQ_DISPOSITION_KINDS = ("cleared", "hole")


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
    # 면제가 영구적이므로 그 계수를 값 정본과 맞댄다. 맞대지 않으면 새로 발화하는 첫 적재 항이
    # 그 면제 안으로 조용히 들어오고, 이 검사가 그것을 배정 없음으로 잡을 자리를 잃는다.
    # 값은 줄어들 수 있고 늘어날 수 없다. 줄어드는 것은 그 항이 처분된 것이다(SPEC §2.1).
    want = fired_exempt_count(led)
    if want is None:
        r.bad("docs/baseline.md 의 FIRED 블록에 FIRED_FIRSTLOAD_EXEMPT 가 없다")
    elif exempt != want:
        r.bad(f"첫 적재 면제가 {exempt}건인데 FIRED 블록의 값은 {want} 이다. "
              f"늘어난 쪽을 값으로 맞추면 면제가 조용히 넓어지므로 고쳐 맞추지 않는다")
    r.note(f"발화 {n_fired}건 · 그 가운데 배정된 것 {n_assigned}건 "
           f"· 첫 적재(charter-6) 면제 {exempt}건 (FIRED 블록의 값 {want})"
           + (f" · 폐기된 이연 항목 {len(dropped)}건을 뺐다({', '.join(dropped)})"
              if dropped else " · 뺀 폐기분 0건"))
    return r


# 검사 42 가 읽는 세션 지시의 조항 목록. `docs/baseline.md` 의 `SESSIONCLAUSE` 블록이 계열과
# 조항을 든다. 계열을 열거하는 까닭은 구멍과 미결의 ID 가 규율 조항과 같은 꼴을 쓰는데 세션
# 지시가 그 둘의 전량을 들지 않아 유니버스에서 빠지기 때문이다. **세션 지시 자체는 검사의
# 대상이 아니다.** 그 문서가 리포에 없으므로 이 검사가 재는 것은 블록과 원장이며, 블록이 그
# 문서의 거울이 되는 것은 사람이 지킨다(SPEC §2.1).
SESSIONCLAUSE_BLOCK = re.compile(
    r"<!-- SESSIONCLAUSE:BEGIN -->\n(.*?)<!-- SESSIONCLAUSE:END -->", re.S)


SESSIONCLAUSE_SERIES_LINE = re.compile(r"^SESSIONCLAUSE_SERIES=(.*)$")


SESSIONCLAUSE_LINE = re.compile(r"^SESSIONCLAUSE=(\S+)$")


# 검사 31 이 읽는 첫 적재 면제의 계수. `docs/baseline.md` §5 의 `FIRED` 블록이 든다.
FIRED_BLOCK = re.compile(r"<!-- FIRED:BEGIN -->\n(.*?)<!-- FIRED:END -->", re.S)


FIRED_EXEMPT_LINE = re.compile(r"^FIRED_FIRSTLOAD_EXEMPT=(\d+)$")


def fired_exempt_count(led: Ledger) -> int | None:
    """`FIRED` 블록이 든 첫 적재 면제의 계수."""
    for line in _baseline_block(led, FIRED_BLOCK).splitlines():
        m = FIRED_EXEMPT_LINE.match(line)
        if m:
            return int(m.group(1))
    return None


def check_39(led: Ledger) -> Report:
    r = Report("39", "wiki39-arc-holes-exist",
               "arcs.json 의 모든 아크의 holes 가 든 id 가 이연 레지스터에 실재하는가", "fail")
    # 유니버스는 이연 레지스터 하나다. 구멍은 정의 구멍과 탐구 미결이므로 그 거처가 그 파일이며,
    # 원장 전체에서 찾으면 결정이나 기각에 선 id 를 구멍으로 든 것이 통과한다(SPEC §1).
    live = {e.get("id") for e in led.reg["deferred"]}
    n = dead = 0
    for name in sorted(led.arcs):
        for h in led.arcs[name].get("holes") or []:
            n += 1
            if h not in live:
                r.bad(f"{h}: 아크 `{name}` 의 holes 가 든 id 가 이연 레지스터에 없다")
                continue
            if h in led.dead:
                dead += 1
    # 폐기 여부는 보지 않는다. 범위 밖 아크를 가리키는 구멍의 처분이 그 구멍을 배열에 그대로
    # 두게 하므로 폐기된 구멍이 남는 것이 정상이고, 그것을 실패로 보면 그 처분이 세운 형과
    # 정면으로 부딪힌다. 실재를 보는 축과 처분을 보는 축이 달라서 그 배열의 처분을 재는 검사
    # 20 과 21 은 아크 종료 커밋에서만 돌고 실재를 재는 이 검사는 상시로 돈다(SPEC §2.1).
    r.note(f"아크 {len(led.arcs)} · 구멍 지목 {n} · 그 가운데 폐기된 것 {dead}")
    r.note("폐기 여부는 보지 않는다. 처분을 보는 축은 아크 종료 시에만 도는 검사 20 과 21 이 "
           "든다(SPEC §2.1)")
    return r


def sessionclause_rules(led: Ledger) -> tuple[set[str], set[str]]:
    """`SESSIONCLAUSE` 블록이 든 계열과 조항."""
    series: set[str] = set()
    clauses: set[str] = set()
    for line in _baseline_block(led, SESSIONCLAUSE_BLOCK).splitlines():
        m = SESSIONCLAUSE_SERIES_LINE.match(line)
        if m:
            series.update(m.group(1).split())
            continue
        m = SESSIONCLAUSE_LINE.match(line)
        if m:
            clauses.add(m.group(1))
    return series, clauses


def check_45(led: Ledger) -> Report:
    r = Report("45", "wiki45-phase-hole-assignment",
               "열려 있는 아크의 페이즈 레코드가 구멍을 나누어 들고 그 합집합이 아크의 구멍과 "
               "양방향으로 맞으며, 아크 전량에서 페이즈 배열의 원소가 객체인가", "fail")
    n_obj = n_open = 0
    # ㉠ 원소의 형을 아크 전량에서 본다. 이름을 뽑는 사상이 객체가 아닌 원소를 건너뛰므로, 이
    # 자리가 없으면 그 페이즈가 미선언으로 보여 검사 3 과 4-a 와 32 가 원인과 다른 문면으로 걸린다.
    for name in sorted(led.arcs):
        for i, ph in enumerate(led.arcs[name].get("phases") or [], 1):
            n_obj += 1
            if not isinstance(ph, dict):
                r.bad(f"아크 `{name}` 의 페이즈 배열의 {i} 번째 원소가 객체가 아니다: `{ph}`")
    # ㉡ 열려 있는 아크에서만 `builds` 와 `holes` 를 요구한다. 그 강제가 아크를 열 때 걸리므로
    # 이미 닫힌 아크는 그 자리가 없고, 소급해 채우면 그 페이즈가 섰던 시점의 전제가 왜곡된다.
    for name in sorted(led.arcs):
        a = led.arcs[name]
        if a.get("status") != "open":
            continue
        n_open += 1
        union: dict[str, list[str]] = {}
        for ph in a.get("phases") or []:
            if not isinstance(ph, dict):
                continue
            pname = str(ph.get("name"))
            for field in ("builds", "holes"):
                if field not in ph:
                    r.bad(f"열려 있는 아크 `{name}` 의 페이즈 `{pname}` 가 `{field}` 를 들지 않는다")
            for h in (ph.get("holes") or []):
                union.setdefault(str(h), []).append(pname)
        for h, owners in sorted(union.items()):
            if len(owners) > 1:
                r.bad(f"아크 `{name}` 의 구멍 `{h}` 를 페이즈 {len(owners)} 개가 함께 든다: "
                      + " · ".join(owners))
        arc_holes = {str(x) for x in (a.get("holes") or [])}
        for h in sorted(arc_holes - set(union)):
            r.bad(f"아크 `{name}` 의 구멍 `{h}` 가 어느 페이즈에도 배정되지 않았다")
        for h in sorted(set(union) - arc_holes):
            r.bad(f"아크 `{name}` 의 페이즈가 그 아크의 구멍 배열에 없는 `{h}` 를 든다")
        r.note(f"아크 `{name}` — 구멍 {len(arc_holes)} · 페이즈 합집합 {len(union)}")
    r.note(f"페이즈 레코드 {n_obj} · 열려 있는 아크 {n_open}")
    return r


def check_42(led: Ledger) -> Report:
    r = Report("42", "wiki42-session-clause-mirror",
               "세션 지시가 드는 조항 목록이 원장에서 유도되는 살아 있는 규율 조항과 "
               "양방향으로 맞는가", "fail")
    series, left = sessionclause_rules(led)
    # 블록이 없거나 비어 있으면 통과가 아니라 실패다. 좌변이 비면 우변이 무엇이든 한쪽 방향의
    # 어긋남이 0 으로 나온다. 검사 28 과 34 와 35 와 37 과 38 과 40 이 같은 요구를 둔다.
    if not series:
        r.bad("docs/baseline.md 의 SESSIONCLAUSE 블록에 SESSIONCLAUSE_SERIES 가 없다")
        return r
    if not left:
        r.bad("docs/baseline.md 의 SESSIONCLAUSE 블록에 SESSIONCLAUSE 줄이 하나도 없다")
        return r
    # 규율 ID 의 꼴은 검사 23·24 가 쓰는 것을 그대로 쓴다. 꼴을 다시 짜면 한쪽을 고칠 때 다른
    # 쪽이 조용히 낡는다. `PH-R` 만 번호를 하이픈 없이 붙이므로 그 계열의 이름을 따로 집는다.
    def series_of(n: str) -> str | None:
        m = RULE_TOKEN.fullmatch(n)
        return None if m is None else (m.group(2) or "PH-R")

    owners: dict[str, list[str]] = {}
    for _name, e in led.entries:
        for n in e.get("names", []) or []:
            owners.setdefault(n, []).append(str(e.get("id")))
    # 우변은 그 계열에 들고 **살아 있는** 것이다. 살아 있음은 저장하지 않고 유도한다. 그 ID 를
    # `names` 로 드는 항목이 전부 폐기 레코드의 대상이면 죽은 것이고, 하나라도 살아 있으면
    # 살아 있는 것이다(SPEC §0.2).
    right = {n for n, ids in owners.items()
             if series_of(n) in series and any(i not in led.dead for i in ids)}
    # ㉠ 좌변에 없고 우변에 있는 것. 세션 지시가 들지 않는 살아 있는 조항이다.
    for n in sorted(right - left):
        r.bad(f"살아 있는 조항 `{n}` 이 SESSIONCLAUSE 블록에 없다. 원장에서 그것을 "
              f"`names` 로 드는 항목: {', '.join(sorted(owners[n]))}")
    # ㉡ 좌변에 있고 우변에 없는 것. **두 경우를 문면이 가른다.** 원장에 그 이름이 아예 없는
    #    것과, 있으나 그것을 드는 항목이 전부 폐기된 것이다. 한 방향만 재면 빠진 조항과 죽은
    #    조항이 갈리지 않으며, 그 어긋남이 실측된 자리가 둘이고 방향이 서로 달랐다.
    for n in sorted(left - right):
        if series_of(n) not in series:
            r.bad(f"SESSIONCLAUSE 블록의 `{n}` 이 SESSIONCLAUSE_SERIES 가 든 계열 밖이다")
        elif n not in owners:
            r.bad(f"SESSIONCLAUSE 블록의 `{n}` 을 `names` 로 드는 항목이 원장에 없다")
        else:
            r.bad(f"SESSIONCLAUSE 블록의 `{n}` 을 드는 항목이 전부 폐기됐다: "
                  + ", ".join(sorted(owners[n])))
    r.note(f"좌변 {len(left)} · 우변 {len(right)} · 계열 {len(series)}")
    return r


# 검사 52 의 유니버스는 재개 트리거의 `ref` 가 열려 있는 아크의 이름인 살아 있는 이연 항목이다.
# **트리거의 종류로 거르지 않는다.** 명세가 그 유니버스를 `ref` 가 가리키는 아크의 상태로만 닫으므로,
# 종류로 좁히면 아크의 이름을 `ref` 로 드는 다른 종류의 항이 조용히 빠진다. 닫힌 아크와 예약 아크와
# 범위 밖 아크를 가리키는 항은 그 밖이며, 그 셋을 넣으면 페이즈 배열이 빈 예약 아크의 정상이 실패로
# 선다(SPEC §2.1).
#
# **방향은 하나다.** 유니버스의 항이 아크와 페이즈의 `holes` 에 드는가만 보고, `holes` 가 든 ID 가
# 살아 있는가는 보지 않는다. 폐기된 구멍이 아크의 배열에 남는 것은 처분의 기록이며, 아크의 배열과
# 페이즈 배열의 합집합이 맞는가는 검사 45 가 본다.
def check_52(led: Ledger) -> Report:
    r = Report("52", "wiki52-open-arc-deferred-assignment",
               "재개 트리거의 `ref` 가 열려 있는 아크를 가리키는 살아 있는 이연 항목마다 그 아크의 "
               "`holes` 와 그 아크의 어느 페이즈의 `holes` 에 그 ID 가 함께 드는가", "fail")
    open_arcs = {n: a for n, a in led.arcs.items() if a.get("status") == "open"}
    universe: dict[str, list[str]] = {}
    dropped: list[str] = []
    for e in led.reg["deferred"]:
        rw = e.get("reopen_when")
        if not isinstance(rw, dict) or not rw:
            continue
        ref = rw.get("ref")
        if not isinstance(ref, str) or ref not in open_arcs:
            continue
        # 폐기된 이연 항목은 살아 있는 구멍이 아니다. 뺀 건수와 그 ID 는 보고 줄에 남긴다(CF-684).
        if e.get("id") in led.dead:
            dropped.append(str(e.get("id")))
            continue
        universe.setdefault(ref, []).append(str(e.get("id")))

    def by_number(i: str) -> tuple[int, str]:
        m = ID_FORM.match(i)
        return (int(m.group(1)) if m else 1 << 30, i)

    total = hits_total = 0
    for name in sorted(open_arcs):
        a = open_arcs[name]
        arc_holes = {str(x) for x in (a.get("holes") or [])}
        phase_holes: set[str] = set()
        for ph in a.get("phases") or []:
            if isinstance(ph, dict):
                phase_holes |= {str(x) for x in (ph.get("holes") or [])}
        ids = sorted(universe.get(name, []), key=by_number)
        hits = 0
        for i in ids:
            # 어느 쪽이 빠졌는지를 줄에 적는다. 둘을 한 문면으로 접으면 패치가 아크 쪽만 세웠는지
            # 페이즈 쪽만 세웠는지가 그 줄에서 갈리지 않는다.
            miss = [side for side, held in (("아크의 `holes`", arc_holes),
                                            ("어느 페이즈의 `holes`", phase_holes))
                    if i not in held]
            if miss:
                hits += 1
                r.bad(f"{i}: 아크 `{name}` 를 가리키는 살아 있는 이연 항목인데 "
                      + " 와 ".join(miss) + " 에 들지 않는다")
        total += len(ids)
        hits_total += hits
        r.note(f"아크 `{name}` — 유니버스 {len(ids)}건 · 적발 {hits}건"
               + (f" ({', '.join(ids)})" if ids else ""))
    r.note(f"유니버스는 열려 있는 아크 {len(open_arcs)}개를 가리키는 살아 있는 이연 항목 {total}건"
           + f" · 적발 {hits_total}건"
           + (f" · 폐기된 이연 항목 {len(dropped)}건을 뺐다({', '.join(dropped)})"
              if dropped else " · 뺀 폐기분 0건"))
    return r


def check_55(led: Ledger) -> Report:
    r = Report("55", "wiki55-phase-cq-in-arc",
               "아크 값 정본의 페이즈 레코드가 든 cq 가 그 아크의 cq 에 전부 드는가", "fail")
    recs = phase_cq_records(led)
    n_items = 0
    for arc, phase, val in recs:
        # 배열이 아니면 원소를 읽을 수 없다. 건너뛰면 그 칸이 빈 것과 같아 보여, 아크가 내리지 않는
        # 항을 든 꼴이 그 자리에서 가려진다.
        if not isinstance(val, list):
            r.bad(f"아크 `{arc}` 의 페이즈 `{phase}` 의 cq 가 배열이 아니다: `{val}`")
            continue
        arc_cq = {str(x) for x in (led.arcs[arc].get("cq") or [])}
        for ref in val:
            n_items += 1
            if str(ref) not in arc_cq:
                r.bad(f"아크 `{arc}` 의 페이즈 `{phase}` 가 그 아크의 cq 에 없는 `{ref}` 를 든다")
    # 유니버스가 비어도 실패가 아니다. 그 칸은 선택이며 보충의 몫이어서, 아직 적지 않은 아크가 있는
    # 것이 정상이다(SPEC §2.1). 비었는지는 이 줄의 계수가 든다.
    r.note(f"cq 칸을 든 페이즈 레코드 {len(recs)} · 그 칸이 든 항 {n_items}")
    return r


def check_56(led: Ledger) -> Report:
    r = Report("56", "wiki56-arc-cq-phase-assignment",
               "그 아크의 cq 마다 그것을 드는 페이즈 레코드가 있는가", "report")
    held: dict[str, set[str]] = {}
    for arc, _phase, val in phase_cq_records(led):
        if isinstance(val, list):
            held.setdefault(arc, set()).update(str(x) for x in val)
    # **열려 있는 아크만 본다.** 페이즈 레코드에 이 칸이 서기 전에 닫힌 아크는 그 배정을 적을 자리가
    # 없었고, 소급해 채우면 그 페이즈가 섰던 시점의 전제가 왜곡된다. 검사 45 가 페이즈의 구멍 배정을
    # 열려 있는 아크에만 요구하는 것과 같은 가름이며, 보지 않은 아크의 수를 아래 줄이 함께 든다.
    missing: list[tuple[str, str]] = []
    n_open = n_cq = n_skip = 0
    for name in sorted(led.arcs):
        a = led.arcs[name]
        if a.get("status") != "open":
            n_skip += 1 if a.get("cq") else 0
            continue
        n_open += 1
        for ref in a.get("cq") or []:
            n_cq += 1
            if str(ref) not in held.get(name, set()):
                missing.append((name, str(ref)))
    r.note(f"열려 있는 아크 {n_open} · 그 아크의 cq {n_cq} · 그것을 드는 페이즈 레코드가 없는 항 "
           f"{len(missing)} · 열려 있지 않아 보지 않은 아크 가운데 cq 를 든 것 {n_skip}")
    # 항마다 한 줄을 낸다. 음성 대조가 지운 번호를 그 줄로 찾으며, 계수만 내면 그 주입이 어느 항을
    # 겨눴는지가 보고에 남지 않는다. 검사 54 가 같은 형이다.
    for name, ref in missing:
        r.note(f"아크 `{name}` — {ref}")
    return r


# 이 단위가 드는 검사. 러너가 이 목록을 이어 붙여 손 열거를 걷는다.
CHECKS = (
    check_01,
    check_02,
    check_03,
    check_03a,
    check_04a,
    check_05,
    check_06,
    check_07,
    check_08,
    check_09,
    check_11,
    check_15,
    check_16,
    check_17,
    check_18,
    check_19,
    check_20,
    check_21,
    check_23,
    check_26,
    check_27,
    check_28,
    check_29,
    check_30,
    check_31,
    check_39,
    check_42,
    check_45,
    check_52,
    check_55,
    check_56,
)
