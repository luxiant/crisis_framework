#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""규율 문서의 전사 대조를 내는 결정 세션의 상주 설비.

**이 모듈은 검증 스크립트가 부르지 않는다.** 좌변이 리포 밖의 회의록에서 오고 대조의 상대가 리포
밖의 세션 지시와 그 부록이므로 리포 안의 검사로 설 수 없다. 결정 세션이 경로를 인자로 주어
부르고, 그 결과를 그 페이즈의 종료 문서가 적는다.

좌변은 회의록에서 거처가 세션 지시나 부록을 드는 살아 있는 낙착 전량이며 회의록을 읽는 설비가
그것을 유도한다. 우변은 낙착마다 손으로 고른 구절의 표다. 구절의 등장을 공백을 전량 지운 변에서
세고, 등장이 영이면 구절을 조각 둘로 갈라 다시 세며 조각이 둘 다 서면 옮겨 적기의 어긋남으로 낸다.
구절이 그 문서에서 유일하지 않으면 다른 조항의 문면에 걸려 선 것으로 세어지므로 그 자리도 낸다.

    python3 scripts/rulecross.py --si <세션 지시> --ap <부록> --phrases <구절 표> \\
        --minutes <회의록> [<회의록> ...] [--phase <페이즈>]

구절 표는 JSON 객체이며 열쇠가 `<페이즈>:낙착-N-(n)` 이고 값이 문서 이름에서 구절 목록으로 가는
객체다. 문서 이름은 `세션 지시` 와 `부록` 이다. `--phase` 를 주면 그 페이즈를 출처로 든 원장
항목 가운데 티어가 policy 이고 규율 ID 를 비운 것의 목록을 함께 내며, 그 목록은 사람이 읽어 그
항목이 결정 세션의 조작을 구속하는지를 가른다.

미포착과 유령과 유일하지 않은 구절이 하나라도 서면 비영으로 끝난다. `selftest` 를 인자로 주면 합성
회의록과 문서에 축마다 어긋남을 주입하는 음성 대조를 돈다.
"""
import argparse
import json
import re
import sys
from pathlib import Path

import minutes as M

DOCS = ("세션 지시", "부록")


def left_side(paths: list[str]) -> dict[str, set[str]]:
    """거처가 세션 지시나 부록을 드는 살아 있는 낙착과 그 문서 이름."""
    out: dict[str, set[str]] = {}
    for p in paths:
        text = Path(p).read_text(encoding="utf-8")
        m = M.PHASE_HEAD.search(text)
        if m is None:
            raise AssertionError(f"회의록 머리에서 페이즈를 읽지 못했다: {p}")
        _, g, _, _, _ = M.read(text)
        for k, v in sorted(g.items()):
            docs = {h for h in v["homes"] if h in DOCS}
            if v.get("retired") or not docs:
                continue
            out[f"{m.group(1)}:낙착-{k[0]}-({k[1]})"] = docs
    if not out:
        raise AssertionError("전사 대조의 좌변이 비었다")
    return out


def count(phrase: str, sq_text: str) -> int:
    return sq_text.count(M.squeeze(phrase))


def cross(left: dict[str, set[str]], table: dict, texts: dict[str, str]) -> dict:
    sq = {d: M.squeeze(t) for d, t in texts.items()}
    rows, missing, ghost, multi = [], [], [], []
    for key, docs in sorted(left.items()):
        got = table.get(key, {})
        for d in sorted(docs):
            phrases = got.get(d) or []
            if not phrases:
                missing.append(f"{key} · {d} · 구절 없음")
                continue
            for ph in phrases:
                n = count(ph, sq[d])
                frags = []
                if n == 0:
                    parts = [x for x in re.split(r"\s+", ph) if x]
                    if len(parts) < 2:
                        raise AssertionError(f"조각으로 가를 수 없는 구절이다: {ph!r}")
                    mid = len(parts) // 2
                    frags = [count(" ".join(parts[:mid]), sq[d]), count(" ".join(parts[mid:]), sq[d])]
                verdict = ("섰다" if n == 1 else "유일하지 않다" if n > 1
                           else "옮겨 적기의 어긋남" if frags and all(frags) else "미포착")
                rows.append({"key": key, "doc": d, "phrase": ph, "hits": n, "frags": frags,
                             "verdict": verdict})
                if verdict == "미포착":
                    missing.append(f"{key} · {d} · {ph}")
                if verdict == "유일하지 않다":
                    multi.append(f"{key} · {d} · {ph} · {n}")
    for key, got in sorted(table.items()):
        for d in sorted(got):
            if key not in left or d not in left[key]:
                ghost.append(f"{key} · {d}")
    return {"rows": rows, "missing": missing, "ghost": ghost, "not_unique": multi,
            "left": len(left), "phrases": len(rows)}


def policy_unnamed(phase: str) -> list[dict]:
    doc = json.loads((M.LEDGER_DIR / "decisions.json").read_text(encoding="utf-8"))
    return [{"id": e["id"], "statement": e.get("statement", "")}
            for e in doc["decisions"]
            if (e.get("origin") or {}).get("phase") == phase
            and e.get("tier") == "policy" and not e.get("names")]


def selftest() -> int:
    """음성 대조. 합성 회의록과 문서에 축마다 어긋남을 주입해 적발이 서는지를 본다."""
    mins = ("# 회의록 — `test-1`\n\n## `화두-1` 시험\n\n"
            "**`낙착-1-(1)` 조항을 세운다.** 몸통이다.\n**갈래는 `decisions` 다. 거처는 세션 지시와 결정 레지스터다.**\n\n"
            "**`낙착-1-(2)` 설비를 고친다.** 몸통이다.\n**갈래는 「없음」이다. 거처는 부록이다.**\n")
    import tempfile
    with tempfile.TemporaryDirectory() as d:
        tmp = Path(d) / "m.md"
        tmp.write_text(mins, encoding="utf-8")
        left = left_side([str(tmp)])
    texts = {"세션 지시": "가 조항은\n여기에 선다. 나 문장. 다 문장.", "부록": "라 설비는 여기에 선다."}
    good = {"test-1:낙착-1-(1)": {"세션 지시": ["조항은 여기에 선다"]},
            "test-1:낙착-1-(2)": {"부록": ["설비는 여기에 선다"]}}
    r0 = cross(left, good, texts)
    ok0 = not (r0["missing"] or r0["ghost"] or r0["not_unique"])
    cases = [
        ("구절 없음", {**good, "test-1:낙착-1-(2)": {"부록": []}}, "missing"),
        ("구절 미포착", {**good, "test-1:낙착-1-(2)": {"부록": ["없는 구절이다"]}}, "missing"),
        ("유령", {**good, "test-1:낙착-1-(9)": {"부록": ["설비는"]}}, "ghost"),
        ("유일하지 않음", {**good, "test-1:낙착-1-(1)": {"세션 지시": ["문장"]}}, "not_unique"),
    ]
    ok = ok0
    for name, tbl, axis in cases:
        fired = bool(cross(left, tbl, texts)[axis])
        print(f"  {name:12s} {axis:12s} {'발화' if fired else '미발화'}")
        ok = ok and fired
    # 옮겨 적기의 어긋남은 미포착으로 세지 않는다
    r1 = cross(left, {**good, "test-1:낙착-1-(1)": {"세션 지시": ["조항은 문장"]}}, texts)
    shifted = [x["verdict"] for x in r1["rows"] if x["key"] == "test-1:낙착-1-(1)"]
    print(f"  옮겨 적기의 어긋남 판정: {shifted}")
    ok = ok and shifted == ["옮겨 적기의 어긋남"]
    print(f"  밑판 무적발: {ok0} · 전량 발화: {ok}")
    return 0 if ok else 1


def main(argv: list[str]) -> int:
    if len(argv) == 2 and argv[1] == "selftest":
        return selftest()
    ap = argparse.ArgumentParser()
    ap.add_argument("--si", required=True)
    ap.add_argument("--ap", required=True)
    ap.add_argument("--phrases", required=True)
    ap.add_argument("--minutes", nargs="+", required=True)
    ap.add_argument("--phase")
    a = ap.parse_args(argv[1:])
    texts = {"세션 지시": Path(a.si).read_text(encoding="utf-8"),
             "부록": Path(a.ap).read_text(encoding="utf-8")}
    table = json.loads(Path(a.phrases).read_text(encoding="utf-8"))
    res = cross(left_side(a.minutes), table, texts)
    if a.phase:
        res["policy_unnamed"] = policy_unnamed(a.phase)
    print(json.dumps(res, ensure_ascii=False, indent=1))
    print(f"[전사 대조] 좌 {res['left']} · 구절 {res['phrases']} · 미포착 {len(res['missing'])} · "
          f"유령 {len(res['ghost'])} · 유일하지 않음 {len(res['not_unique'])}", file=sys.stderr)
    return 1 if (res["missing"] or res["ghost"] or res["not_unique"]) else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
