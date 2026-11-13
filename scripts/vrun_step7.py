#!/usr/bin/env python3
"""`step7-cqfin` 의 본문. CQ 고정 절과 관측층 선언을 대조하는 검사기를 부른다.

그 검사기도 자기 진입점을 가진 스크립트이므로 하위 프로세스로 부르는 꼴을 그대로 둔다.
"""


def run(ctx) -> None:
    p = ctx.run(["python3", "scripts/check_cqfin.py"], merge=True)
    if p.out:
        ctx.write(p.out)
    if p.rc == 0:
        ctx.ok("CQ 고정 절과 관측층 선언이 일치한다")
    else:
        ctx.bad("CQ 고정 절과 관측층 선언이 어긋난다 — docs/baseline.md §6")
