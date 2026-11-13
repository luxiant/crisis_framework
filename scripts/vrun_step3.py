#!/usr/bin/env python3
"""`step3-forbidden` 의 본문. 금지 구문을 주석을 지운 사본에서 정적으로 검사한다.

주석과 docstring 을 먼저 제거한다. 그러지 않으면 헤더에 적은 "`sorry` 0" 같은 설명 문구가
스스로 걸린다 (실제로 발생했다). Lean 의 /- -/ 는 중첩 가능하므로 깊이를 세어 제거하고,
-- 는 줄 끝까지 지운다.

사본을 한 벌만 만들고 뒤의 네 단계가 그것을 함께 읽는다. 단계마다 다시 만들면 같은 산출을
네 번 세우고 파일마다 파이썬을 새로 띄워 그 횟수가 대상 수의 네 배로 선다. 전량을 한 호출에서
처리하므로 기동 비용도 한 번으로 선다. 지우는 자리는 이 벌을 읽는 마지막 단계의 뒤다
(step9-propfree).

변이 검사와 논리 결합 변이는 이 벌을 쓰지 않는다. 그 둘은 자리 수를 보존해 공백으로
덮는 다른 꼴을 쓰고 원본의 자리 번호를 그대로 쓰기 때문이다.
"""

import re
import tempfile
from pathlib import Path

import vstep_forbidden

# 받은 판의 `grep -nE` 가 쓰던 정규식을 그대로 옮긴다. POSIX 의 `[[:space:]]` 를 파이썬의
# 글자 모음으로 풀며 줄 단위로 재므로 줄바꿈이 그 모음에 들어도 걸리지 않는다.
_SPACE = r"[ \t\v\f\r]"
CHECKS = (
    ("sorry", r"\bsorry\b"),
    ("axiom 선언", rf"^{_SPACE}*axiom{_SPACE}"),
    ("noncomputable", r"\bnoncomputable\b"),
    ("Classical", r"\bClassical\b"),
    ("admit/native_decide", r"\b(admit|native_decide)\b"),
)

INDENT = " " * 7


def _grep(base: Path, rel: str, pat: re.Pattern, with_name: bool) -> list[str]:
    """`grep -nE` 한 자리. 파일이 여럿이면 이름을 앞에 붙이고 하나면 붙이지 않는다."""
    p = base / rel
    try:
        text = p.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return []
    out = []
    for n, line in enumerate(text.split("\n"), 1):
        if pat.search(line):
            out.append(f"{rel}:{n}:{line}" if with_name else f"{n}:{line}")
    return out


def run(ctx) -> None:
    ctx.stripped = tempfile.mkdtemp()
    vstep_forbidden.run(ctx.stripped, list(ctx.targets))
    base = Path(ctx.stripped)

    many = len(ctx.targets) > 1
    for name, pat in CHECKS:
        rx = re.compile(pat)
        hits: list[str] = []
        for t in ctx.targets:
            hits.extend(_grep(base, t, rx, many))
        if hits:
            ctx.bad(f"코드에 금지 구문: {name}")
            for h in hits:
                ctx.write(INDENT + h + "\n")
        else:
            ctx.ok(f"코드에 없음: {name}")

    # `ℝ` 금지는 층별로 갈린다. 동학층은 허용이고 나머지 넷은 금지다 (L-4).
    # CLAUDE.md §2 의 표가 정본이며 디렉터리가 층을 결정한다.
    real_rx = re.compile("ℝ")
    real_hits = 0
    for t in ctx.targets:
        if t.startswith("CrisisFramework/Dynamics/"):
            continue
        hits = _grep(base, t, real_rx, False)
        if hits:
            real_hits = 1
            ctx.bad(f"층별 `ℝ` 금지 위반: {t}")
            for h in hits:
                ctx.write(INDENT + h + "\n")
    if real_hits == 0:
        ctx.ok("`ℝ` 없음: 동학층 밖 대상 전량 (동학층은 검사 대상이 아니다)")
