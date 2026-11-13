#!/usr/bin/env python3
"""`step8-layertype` 의 본문. 층별 수 타입을 주석을 지운 코드에서 대조한다.

CLAUDE.md §2 의 층별 금지 표를 주석을 지운 코드에서 대조한다. 디렉터리가 층을 결정한다.
정의층의 ℕ·Nat 은 L-13 의 명시적 예외라 잡지 않는다. ℝ 기호는 네 층 전부에서
step3-forbidden 이 보므로 여기서 다시 세지 않는다. L-4 가 invariant 로 그 단계에 걸려 있기
때문이다. 다만 영문명 Real 은 step3 가 기호만 보므로 여기서 잡는다. 회계층의 ℚ·Rat 은
L-15 의 판정이 docstring 의 사유를 읽어야 서므로 실패가 아니라 보고로 낸다.
"""

import vstep_layertype

INDENT = " " * 7


def run(ctx) -> None:
    out = vstep_layertype.run(ctx.stripped, list(ctx.targets))
    rows = [ln.split("\t") for ln in out.split("\n") if ln != ""]

    lt_fail: dict[str, int] = {}
    lt_rep: dict[str, int] = {}
    for r in rows:
        kind = r[0]
        if kind == "FAIL":
            _, layer, where, what, line = (r + [""] * 5)[:5]
            ctx.bad(f"금지 수 타입·수치 리터럴 ({layer}): {where} ({what})")
            ctx.write(INDENT + line + "\n")
            lt_fail[layer] = lt_fail.get(layer, 0) + 1
        elif kind == "REPORT":
            _, layer, where, what, line = (r + [""] * 5)[:5]
            ctx.rep(f"ℚ·Rat 사용 ({layer}): {where} ({what})."
                    " L-15 의 사유가 docstring 에 적혀 있는지 사람이 확인한다")
            ctx.write(INDENT + line + "\n")
            lt_rep[layer] = lt_rep.get(layer, 0) + 1

    for r in rows:
        kind = r[0]
        if kind == "SCAN":
            layer, n = r[1], r[2]
            if layer == "회계층":
                ctx.ok(f"{layer}: 파일 {n} · ℚ·Rat 보고 {lt_rep.get(layer, 0)}줄")
            elif layer not in lt_fail:
                ctx.ok(f"{layer}: 파일 {n} · 금지 수 타입·수치 리터럴 없음")
        elif kind == "OTHER":
            # 받은 판이 이 줄의 둘째 칸을 계수로 읽어 그 자리에 넣는다.
            ctx.ok(f"대상 밖 파일 {r[1]} (동학층과 층 디렉터리 밖)")
