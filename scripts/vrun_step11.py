#!/usr/bin/env python3
"""`step11-leanenv` 의 본문. 모듈 탐색 환경을 한 번 들여 빌드 도구가 세우던 것과 대조한다.

빌드 도구를 거쳐 Lean 을 부르면 그 호출마다 빌드 도구가 자기 명세를 다시 읽고 의존을 다시
해소하므로 그 고정비가 호출마다 선다. 뒤의 네 자리가 그 꼴로 Lean 을 불렀고 그 가운데 둘이
감사 대상의 수만큼 반복되므로, 그 환경을 이 자리에서 한 번 들여 뒤의 단계가 Lean 을 직접
부르게 한다. 전량 재빌드 단계의 호출은 빌드 산출을 낳는 자리여서 그대로 둔다.

들이는 것이 모듈 탐색 경로 하나가 아니라 그 환경 전량이다. 빌드 도구가 세우는 것이 그 경로
하나가 아니고 그 가운데 동적 라이브러리 경로와 소스 탐색 경로가 Lean 의 동작에 걸릴 수
있는데, 그 걸림은 빌드 산출이 선 판에서만 재어지므로 경로 하나만 세우는 길은 그 전제가
재어지지 않은 채 남는다. 환경 전량을 옮기면 빌드 도구가 세우던 것과 구조적으로 같다.

널 문자로 가른 꼴로 받는다. 줄 단위로 받으면 값에 줄바꿈이 든 변수가 그 자리에서 깨지고
그 깨짐이 조용히 지나간다. 이름이 식별자가 아닌 레코드는 들이지 않는다. 그 꼴이 러너의
환경에 서면 들이기가 실패하고 그 실패가 표준 오류로만 남는다.

받은 판은 지금 도는 환경을 `env -0` 으로 받았고 이 자리가 그 호출을 없애고 자기 환경을 그
꼴로 바로 적는다. 그 둘이 같은 것을 내는 까닭은 그 명령이 내는 것이 내보내진 환경이고 이
과정의 환경이 바로 그것이라는 데 있다. 바이트로 적어 꼴을 보존한다.
"""

import difflib
import os
import re
import tempfile
from pathlib import Path

import vstep_leanenv

INDENT = " " * 7
_IDENT = re.compile(r"\A[A-Za-z0-9_]+\Z")


def _nul(env: dict[bytes, bytes]) -> bytes:
    return b"".join(k + b"=" + v + b"\0" for k, v in env.items())


def run(ctx) -> None:
    le_now = Path(tempfile.mkstemp()[1])
    le_inner = Path(tempfile.mkstemp()[1])
    le_now.write_bytes(_nul(os.environb))

    p = ctx.run(["lake", "env", "printenv", "-0"], binary=True)
    if p.rc == 0:
        le_inner.write_bytes(p.out_bytes)
    else:
        le_inner.write_bytes(b"")
        ctx.bad("빌드 도구의 환경 출력을 받지 못했다")
        ctx.indent(p.err.rstrip("\n"), INDENT)

    # 축 첫째. 빌드 도구가 더하거나 바꾸는 변수의 이름 집합을 값 정본의 블록과 맞댄다. 그 집합이
    # 늘면 Lean 의 동작에 걸리는 변수가 새로 섰을 수 있으므로 보고로 내고 실패시키지 않는다.
    # 블록을 읽지 못한 것만 실패로 센다. 그 값은 이 검사가 처음 설 때 이 검사 자신이 낸 것으로
    # 심으며, 그 집합이 빌드 도구의 판과 의존 묶음이 정하는 것이어서 환경마다 갈릴 수 있다.
    for ln in vstep_leanenv.run(str(le_now), str(le_inner), ctx.baseline_doc).split("\n"):
        if ln == "":
            continue
        kind, _, msg = ln.partition("\t")
        if kind == "OK":
            ctx.ok(msg)
        elif kind == "FAIL":
            ctx.bad(msg)
        elif kind == "REPORT":
            ctx.rep(msg)

    # 축 둘째. 같은 파일을 두 길로 돌려 종료 코드와 출력이 바이트로 같은지 잰다. 대상은 뒤의
    # 단계가 이미 돌리는 층별 프로브이며, 이름의 집합만 보면 이름이 같은데 값의 뜻이 바뀐 자리를
    # 놓치고 이 축만 보면 그 파일이 쓰지 않는 자리에 걸린 변수가 늘어도 재어지지 않는다.
    #
    # 받은 판의 꼴을 들이기 앞에서 잰다. 들인 환경 위에서 빌드 도구를 다시 부르면 그 도구가
    # 자기 경로를 기존 값 앞에 다시 붙여 모듈 탐색 경로가 두 배로 서고, 그 중첩이 오류 메시지의
    # 경로 목록을 늘려 두 길의 출력이 갈린다. 그 갈림은 환경이 다른 것이 아니라 한쪽이 중첩된
    # 것이므로 이 순서가 아니면 이 축이 늘 실패한다.
    a = ctx.run(["lake", "env", "lean", "Scratch/VerifyBuilt.lean"], merge=True)
    a_out = a.out.rstrip("\n")

    for rec in le_inner.read_bytes().split(b"\0"):
        if rec == b"":
            continue
        name = rec.split(b"=", 1)[0].decode("utf-8", "replace")
        if not _IDENT.match(name):
            continue
        k, _, v = rec.partition(b"=")
        ctx.env[k.decode("utf-8", "replace")] = v.decode("utf-8", "replace")

    if not ctx.env.get("LEAN"):
        ctx.bad("들인 환경이 Lean 바이너리의 경로를 들지 않는다")
        # 받은 판의 셸이 미정의 변수를 오류로 받으므로 뒤의 단계가 이 변수를 맨몸으로
        # 참조하면 그 자리에서 끝나고 그 끊김이 적발로 기록되지 않았다. 그 자리를
        # `Ctx.lean_bin` 이 받아 이 경로에서도 뒤의 단계가 돌아 실패를 남긴다.
    else:
        ctx.ok("Lean 을 직접 부를 경로를 들였다")

    c = ctx.run([ctx.lean_bin(), "Scratch/VerifyBuilt.lean"], merge=True)
    c_out = c.out.rstrip("\n")
    if a.rc == c.rc and a_out == c_out:
        ctx.ok(f"두 길의 출력이 바이트로 같다 (종료 코드 {a.rc})")
    else:
        ctx.bad("두 길의 출력이 갈린다 — 들인 환경이 빌드 도구가 세우던 것과 다르다")
        d = _diff(a_out, c_out)
        for ln in d[:20]:
            ctx.write(INDENT + ln + "\n")

    for p2 in (le_now, le_inner):
        p2.unlink(missing_ok=True)


def _diff(a: str, b: str) -> list[str]:
    """받은 판의 `diff` 가 내던 꼴. 바뀐 자리만 `NcM` 머리와 함께 든다."""
    left = a.split("\n")
    right = b.split("\n")
    out: list[str] = []
    sm = difflib.SequenceMatcher(a=left, b=right, autojunk=False)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            continue
        lo, ro = _span(i1, i2), _span(j1, j2)
        if tag == "replace":
            out.append(f"{lo}c{ro}")
            out += [f"< {x}" for x in left[i1:i2]]
            out.append("---")
            out += [f"> {x}" for x in right[j1:j2]]
        elif tag == "delete":
            out.append(f"{lo}d{j1}")
            out += [f"< {x}" for x in left[i1:i2]]
        else:
            out.append(f"{i1}a{ro}")
            out += [f"> {x}" for x in right[j1:j2]]
    return out


def _span(i1: int, i2: int) -> str:
    return str(i1 + 1) if i2 - i1 <= 1 else f"{i1 + 1},{i2}"
