#!/usr/bin/env python3
"""`step2-build` 의 본문. 프로젝트의 빌드 산출을 지우고 전량 재빌드한다.

디스크의 문면을 기준으로 다시 검증하기 위해 프로젝트의 olean 을 먼저 지운다. 의존 묶음의
산출은 지우지 않는다.

성공 경로에서는 완료 요약 한 줄만 낸다. 뒤 다섯 줄은 병렬 작업의 완료 순서를 따라 바뀌어
OUTPUT_DIGEST 가 리포 상태의 함수가 아니게 된다(CF-674).
"""

import re
import shutil
from pathlib import Path

BUILD_LOG = Path("/tmp/verify_build.log")
LIB = ".lake/build/lib/lean"
_JOBS = re.compile(r"Build completed successfully \(([0-9]+) jobs\)")
_DIAG = re.compile(r"error|warning")


def run(ctx) -> None:
    lib = ctx.root / LIB
    shutil.rmtree(lib / "CrisisFramework", ignore_errors=True)
    for p in lib.glob("CrisisFramework.[oit]*"):
        if p.is_dir():
            shutil.rmtree(p, ignore_errors=True)
        else:
            p.unlink(missing_ok=True)

    p = ctx.run(["lake", "build"], merge=True)
    BUILD_LOG.write_text(p.out, encoding="utf-8")
    log = p.out.split("\n")
    if log and log[-1] == "":
        log.pop()

    if p.rc == 0:
        # 받은 판의 `grep -m1` 이 들여쓰기 없이 첫 줄만 내던 자리다.
        for ln in log:
            if "Build completed successfully" in ln:
                ctx.line(ln)
                break
        diag = [f"{i}:{ln}" for i, ln in enumerate(log, 1) if _DIAG.search(ln)]
        if diag:
            ctx.bad("빌드 로그에 error/warning 존재:")
            for d in diag:
                ctx.line(d)
        else:
            jobs = [m.group(1) for ln in log for m in [_JOBS.search(ln)] if m]
            ctx.ok(f"lake build 전량 통과, error/warning 0 ({jobs[0] if jobs else '?'} job)")
    else:
        for ln in log[-5:]:
            ctx.line(ln)
        ctx.bad("lake build 실패")
