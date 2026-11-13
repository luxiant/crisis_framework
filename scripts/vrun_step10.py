#!/usr/bin/env python3
"""`step10-clausemut` 의 본문. 판정 반환 함수의 증거가 덮는 범위를 잰다.

결론을 부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지
않는다. 두 인자가 함께 참인 증거와 함께 거짓인 증거만 두면 곱과 합의 값이 그 둘에서 같으므로
그 결합을 뒤집은 변이가 통과한다(A-8). 그래서 정의층과 관측층의 판정 반환 함수 본문에서 논리
결합을 하나씩 뒤집은 사본을 만들어 그 사본이 elaborate 에 성공하는 자리를 센다.

판정 반환 함수는 결과 타입이 `Bool` 인 최상위 def 다. 판정을 `Bool` 반환 계산 함수로 준다는
규율(C-10)이 그 부류를 정하므로, 구조체나 답할 항을 내는 def 는 그 안에 결합이 있어도 대상이
아니다. 뒤집는 것은 본문의 `&&` 와 `||` 를 서로 바꾸는 것과 `decide` 안의 `∧` 와 `∨` 를 서로
바꾸는 것이며, 한 사본에 한 자리만 바꾼다. 바꾼 문면은 그대로 다시 읽히므로 결합의 우선순위가
그 사본의 뜻을 정한다. 대상은 그 두 층의 파일 전량에서 훑어 잡고 계수를 박지 않는다.

사본은 그 파일 하나만 elaborate 하고 전량 빌드하지 않는다. 그 함수를 다른 파일의 정리가 쓰더라도
그 파일은 원본의 olean 을 읽으므로 그 정리는 이 단계의 증거가 아니다. 사본이 통과한 자리는
실패시키지 않고 보고하며, 그 계수를 docs/baseline.md 의 블록과 맞대어 늘었을 때만 실패시킨다.
뒤집은 함수 자신의 범위에서 오류가 나거나 구문 오류로 깨지면 그 사본은 결합을 재지 못한 것이므로
거부로 세지 않고 실패로 센다. 사본은 임시 디렉터리에 만들고 돈 뒤에 지운다.
"""

import re
import shutil
import tempfile
from pathlib import Path

import vstep_clausemut

_ERROR = re.compile(r"error")
_MUTANT_ERR = re.compile(r"Mutant\.lean:([0-9]+):[0-9]+: error")
_CAP = re.compile(r"^CLAUSEMUT_UNCOVERED=([0-9]+)$", re.M)
_BLOCK = re.compile(
    r"<!-- CLAUSEMUT:BEGIN -->(.*?)<!-- CLAUSEMUT:END -->", re.S)


def run(ctx) -> None:
    cm_dir = Path(tempfile.mkdtemp())
    cm_files = [t for t in ctx.targets
                if re.match(r"^CrisisFramework/(Definition|Observation)/", t)]
    rows = [r.split("\t") for r in vstep_clausemut.run(str(cm_dir), cm_files).split("\n")
            if r != ""]

    doc = (ctx.root / ctx.baseline_doc).read_text(encoding="utf-8")
    blk = _BLOCK.search(doc)
    cap_m = _CAP.search(blk.group(1)) if blk else None
    cap = int(cap_m.group(1)) if cap_m else None
    if cap is None:
        ctx.bad(f"{ctx.baseline_doc} 의 CLAUSEMUT 블록에서 CLAUSEMUT_UNCOVERED 를 읽지 못했다")

    if not rows:
        ctx.bad("변이 대상 0 — 정의층과 관측층에서 판정 반환 함수의 논리 결합을 하나도 잡지 못했다")
        shutil.rmtree(cm_dir, ignore_errors=True)
        return

    ctx.ok(f"변이 대상 {len(rows)} ({ctx.per_file(r[0] for r in rows)})")
    # 사본마다 elaborate 를 따로 돌린다. 판정은 아래에서 원래 순서대로 하므로 병렬이 출력을
    # 바꾸지 않는다.
    ctx.elaborate_all(r[7] for r in rows)

    uncovered = 0
    for row in rows:
        c_file, c_line, c_name, c_from, c_to, c_first, c_last, c_copy = (row + [""] * 8)[:8]
        where = f"{c_file}:{c_line} {c_name} 의 `{c_from}` → `{c_to}`"
        rc, out = ctx.elaborated(c_copy)
        head = ctx.MUT_SYNTAX.search(out)
        in_self = any(int(c_first) <= int(m.group(1)) <= int(c_last)
                      for m in _MUTANT_ERR.finditer(out))
        if rc == 0 and not _ERROR.search(out):
            uncovered += 1
            ctx.rep(f"{where} 변이가 통과함 — 그 결합을 가리는 증거가 그 파일에 없다")
        elif head:
            ctx.bad(f"{where} 사본이 구문 오류로 깨져 그 결합이 재어지지 않았다 ({head.group(0)})")
        elif in_self:
            ctx.bad(f"{where} 사본이 그 함수 자신에서 깨져 그 결합이 재어지지 않았다")
        else:
            n = sum(1 for ln in out.split("\n") if _ERROR.search(ln))
            ctx.ok(f"{where} 변이 거부됨 ({n} error) — 증거가 그 결합을 가린다")

    if cap is not None:
        if uncovered > cap:
            ctx.bad(f"통과한 변이 {uncovered} 가 CLAUSEMUT_UNCOVERED={cap} 보다 많다"
                    " — 증거 없이 결합이 새로 섰다")
        elif uncovered < cap:
            ctx.rep(f"통과한 변이 {uncovered} 가 CLAUSEMUT_UNCOVERED={cap} 보다"
                    f" {cap - uncovered} 적다 — 그 결합을 가리는 증거가 섰다")
        else:
            ctx.ok(f"통과한 변이 {uncovered} / {len(rows)}"
                   f" — CLAUSEMUT_UNCOVERED={cap} 과 같다")

    shutil.rmtree(cm_dir, ignore_errors=True)
