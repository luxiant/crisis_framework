#!/usr/bin/env python3
"""`step1-duplicate` 의 본문. 빌드 타깃 밖의 중복 사본을 탐지한다.

저장소 전체를 훑는다. crisis-framework/ 안만 보면 상위 디렉터리에 놓인 낡은 초안 사본을
놓친다 (1차 검증 직후 실제로 발생한 사고).

탐색을 대상마다 돌리지 않고 한 번만 돌린다. 제외를 부정 경로로 거르는 꼴은 그 디렉터리
안을 전량 순회한 뒤 결과만 버리므로 빌드 산출에 받아 둔 의존 패키지 전량이 대상 파일마다
다시 순회되며, 가지치기로 바꾸면 그 디렉터리에 아예 들어가지 않는다. 빌드 타깃 판별도
대상 전량을 다시 훑지 않고 해소된 경로의 집합으로 한 번에 받는다.

적발의 순서는 대상 경로로 정렬해 고정한다. 탐색이 낸 순서를 그대로 쓰면 디렉터리 순회
순서가 출력에 들어와 OUTPUT_DIGEST 가 리포 상태의 함수가 아니게 된다 (CF-674 와 같은 형).
"""

import os
from pathlib import Path

PRUNE = {".lake", ".git"}


def _scan_root(ctx) -> Path:
    """훑을 뿌리. 버전 관리의 최상위를 묻고 답이 없으면 리포의 뿌리를 쓴다."""
    p = ctx.run(["git", "rev-parse", "--show-toplevel"])
    if p.rc == 0 and p.out.strip():
        return Path(p.out.strip())
    return ctx.root


def run(ctx) -> None:
    scan = _scan_root(ctx)

    target_abs = set()
    target_of: dict[str, list[str]] = {}
    for t in ctx.targets:
        target_abs.add(os.path.realpath(ctx.root / t))
        # 한 파일명이 여러 층에 서므로 대상을 쌓는다. 받은 판이 대상마다 탐색을 돌려 같은
        # 사본을 대상마다 적발하므로 그 쌍의 수가 같아야 한다.
        target_of.setdefault(os.path.basename(t), []).append(t)

    rows: list[tuple[bytes, str]] = []
    for dirpath, dirnames, filenames in os.walk(scan):
        dirnames[:] = [d for d in dirnames if d not in PRUNE]
        for fn in filenames:
            if not fn.endswith(".lean"):
                continue
            other = os.path.join(dirpath, fn)
            same_name = target_of.get(fn)
            if not same_name:
                continue
            # 다른 빌드 타깃은 사본이 아니다. `lakefile.toml` 의 glob 이 둘을 함께 세우고
            # `lake` 가 경로로 구별하므로 검증에서 빠지는 파일이 아니다. 이 검사가 잡으려는
            # 것은 빌드 타깃 **밖**의 낡은 초안이며 CF-83 의 사고가 그 형이었다.
            if os.path.realpath(other) in target_abs:
                continue
            prefix = str(scan) + os.sep
            rel = other[len(prefix):] if other.startswith(prefix) else other
            for t in same_name:
                try:
                    a = Path(other).read_bytes()
                    b = (ctx.root / t).read_bytes()
                    same = a == b
                except OSError:
                    same = False
                if same:
                    msg = f"중복 사본(내용 동일, 그래도 혼동 위험): {rel}  ↔  {t}"
                else:
                    msg = f"중복 사본(내용 다름 — 위험): {rel}  ↔  {t}"
                rows.append((f"{t}\t{msg}".encode("utf-8"), msg))

    if rows:
        # 받은 판이 `LC_ALL=C sort` 로 줄 전량을 바이트 순으로 세웠으므로 같은 꼴로 정렬한다.
        for _key, msg in sorted(rows, key=lambda r: r[0]):
            ctx.bad(msg)
    else:
        ctx.ok("저장소 전체에 빌드 타깃 파일명과 겹치는 사본 없음")
