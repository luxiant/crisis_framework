#!/usr/bin/env python3
"""CQ 고정 절 대조기.

`docs/baseline.md` §5 의 `CQFIN` 블록과 관측층 파일의 `CQ-fin` 선언을 맞댄다. 고정 절의 정본은
`docs/baseline.md` §6 이 들고, 이 스크립트는 `verify.sh` 의 `step7-cqfin` 단계가 부른다.

    python3 scripts/check_cqfin.py [--root PATH]

`--root` 는 두 파일을 읽을 뿌리를 바꾼다. 음성 대조가 사본에 위반을 주입한 뒤 그 사본을 뿌리로
지목하므로, 이 선택지가 없으면 주입이 검증된 파일을 건드리게 된다.

추출 규칙은 아래로 고정한다. 규칙을 바꾸면 다이제스트가 달라져 고정 절과 맞지 않게 된다.

1. 관측층 파일에서 `namespace CQ` 뒤를 본다
2. 각 `structure` 선언마다, 바로 위의 `-- DD:` 표지보다 앞에 붙은 `/-- … -/` 블록이 그 선언의
   docstring 이다
3. docstring 의 본문에서 줄 끝 공백을 지우고 앞뒤의 빈 줄을 턴 뒤 `\\n` 으로 잇는다
4. 그 문자열의 sha256 을 16진수로 내고 앞 열두 자리를 쓴다
5. 답 함수의 타입은 `answer :` 뒤의 전부이며, 연속 공백을 한 칸으로 접고 앞뒤를 턴다
6. 한 줄을 `CQFIN=<번호>|<구조물 이름>|<답 함수의 타입>|<다이제스트>` 로 짓는다. 번호는 선언이
   파일에 나오는 순서다

대조는 집합이 아니라 순서까지 한다.

**이 대조기나 고정 절 블록을 고쳐 통과시키지 않는다.** 어긋남이 나면 그 어긋남이 산출물이다.
"""

from __future__ import annotations

import argparse
import hashlib
import re
import sys
from pathlib import Path

CQ_FILE = "CrisisFramework/Observation/CompetencyQuestion.lean"
BASELINE_DOC = "docs/baseline.md"
BLOCK = re.compile(r"<!-- CQFIN:BEGIN -->\n(.*?)<!-- CQFIN:END -->", re.S)


def extract(src: str) -> list[str]:
    """관측층 파일에서 고정 절의 줄을 규칙대로 짓는다."""
    lines = src.splitlines()
    try:
        start = next(i for i, l in enumerate(lines) if l.strip() == "namespace CQ")
    except StopIteration:
        raise SystemExit(f"{CQ_FILE}: `namespace CQ` 를 찾지 못했다")
    out = []
    for i in range(start + 1, len(lines)):
        m = re.match(r"structure\s+(\S+)", lines[i])
        if not m:
            continue
        name = m.group(1)
        # 규칙 2. 선언 바로 위가 `-- DD:` 표지이고, 그 위에 docstring 이 붙어 있어야 한다.
        j = i - 1
        if not lines[j].startswith("-- DD:"):
            raise SystemExit(f"{CQ_FILE}:{i + 1}: `{name}` 바로 위에 `-- DD:` 표지가 없다")
        j -= 1
        if lines[j].rstrip() != "-/":
            raise SystemExit(f"{CQ_FILE}:{i + 1}: `{name}` 의 표지 위에 docstring 이 붙어 있지 않다")
        k = j - 1
        while k > start and not lines[k].startswith("/--"):
            k -= 1
        if k <= start:
            raise SystemExit(f"{CQ_FILE}:{i + 1}: `{name}` 의 docstring 머리를 찾지 못했다")
        body = [lines[k][3:]] + lines[k + 1:j]
        # 규칙 3. 줄 끝 공백을 지우고 앞뒤 빈 줄을 턴다.
        body = [l.rstrip() for l in body]
        while body and not body[0]:
            body.pop(0)
        while body and not body[-1]:
            body.pop()
        digest = hashlib.sha256("\n".join(body).encode("utf-8")).hexdigest()[:12]
        # 규칙 5. `answer :` 뒤의 전부. 필드는 빈 줄까지 이어진다.
        a = i + 1
        while a < len(lines) and "answer :" not in lines[a]:
            if not lines[a].strip():
                raise SystemExit(f"{CQ_FILE}:{i + 1}: `{name}` 에 `answer` 필드가 없다")
            a += 1
        if a >= len(lines):
            raise SystemExit(f"{CQ_FILE}:{i + 1}: `{name}` 에 `answer` 필드가 없다")
        seg = [lines[a].split("answer :", 1)[1]]
        b = a + 1
        while b < len(lines) and lines[b].strip():
            seg.append(lines[b])
            b += 1
        ty = re.sub(r"\s+", " ", " ".join(seg)).strip()
        out.append(f"CQFIN={len(out) + 1}|{name}|{ty}|{digest}")
    return out


def fixed(doc: str) -> list[str]:
    """`docs/baseline.md` 의 `CQFIN` 블록을 줄로 낸다."""
    m = BLOCK.search(doc)
    if not m:
        raise SystemExit(f"{BASELINE_DOC}: `CQFIN` 블록을 찾지 못했다")
    return [l for l in m.group(1).splitlines() if l.strip()]


def main() -> int:
    ap = argparse.ArgumentParser(description="CQ 고정 절 대조기 (docs/baseline.md §6)")
    ap.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    root = Path(ap.parse_args().root)
    got = extract((root / CQ_FILE).read_text(encoding="utf-8"))
    want = fixed((root / BASELINE_DOC).read_text(encoding="utf-8"))
    print(f"관측층 선언에서 뽑은 줄 {len(got)} · 고정 절의 줄 {len(want)}")
    bad = 0
    for n in range(max(len(got), len(want))):
        g = got[n] if n < len(got) else None
        w = want[n] if n < len(want) else None
        if g == w:
            print(f"  OK   {g}")
            continue
        bad += 1
        print(f"  FAIL {n + 1}번째 줄이 어긋난다")
        print(f"       고정 절: {w}")
        print(f"       선언   : {g}")
    if bad:
        print(f"어긋난 줄 {bad}")
        return 1
    print("고정 절과 관측층 선언이 순서까지 일치한다")
    return 0


if __name__ == "__main__":
    sys.exit(main())
