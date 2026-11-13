#!/usr/bin/env python3
"""`step9-propfree` 의 본문. 발동조건 문법의 `Prop` 금지를 정의층에서 검사한다.

정의층의 structure 필드와 inductive 생성자는 타입 서명에 Prop 를 담지 않는다. 자료 구조에서
Prop 를 몰아내면 발동조건의 의미가 Bool 반환 계산 함수로 선다는 요구가 타입으로 선다.
최상위 def·abbrev·theorem 의 서명은 대상이 아니다. 구조에 들어가지 않는 보조 술어는
발동조건의 판정 경로에 있지 않기 때문이다. 필드와 생성자는 선언 머리의 where 뒤에 선다.

주석을 지운 사본을 읽는 마지막 단계이므로 이 자리가 그 사본을 지운다.
"""

import shutil

import vstep_propfree

INDENT = " " * 7


def run(ctx) -> None:
    def_targets = [t for t in ctx.targets if t.startswith("CrisisFramework/Definition/")]
    out = vstep_propfree.run(ctx.stripped, def_targets)
    if ctx.stripped:
        shutil.rmtree(ctx.stripped, ignore_errors=True)
        ctx.stripped = None

    rows = [ln.split("\t") for ln in out.split("\n") if ln != ""]
    pf_bad = 0
    for r in rows:
        if r[0] == "FAIL":
            _, a, b, c = (r + [""] * 4)[:4]
            pf_bad = 1
            ctx.bad(f"Prop 를 담은 {b}: {a}")
            ctx.write(INDENT + c + "\n")
    for r in rows:
        if r[0] == "SCAN" and pf_bad == 0:
            a, b, c = (r + [""] * 4)[1:4]
            ctx.ok(f"정의층 파일 {a} · structure {b} · inductive {c}"
                   " 의 필드와 생성자에 Prop 없음")
