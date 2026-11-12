#!/usr/bin/env python3
"""원장 검증기.

`docs/decisions/SPEC.md` §2 의 검사 예순하나를 돈다. 실패시키는 것 마흔아홉과 보고만 하는 것 아홉과
아크 종료 시에만 도는 것 셋이다. 검사마다 단계 id 를 선언하고 그것을 출력에 낸다.

    python3 scripts/check_wiki.py [--root PATH] [--arc-close ARC] [--quiet]

`--root` 는 원장과 부속 파일을 읽을 뿌리를 바꾼다. 음성 대조가 사본에 위반을 주입한 뒤 그
사본을 뿌리로 지목하므로, 이 선택지가 없으면 주입이 원장을 건드리게 된다.

`--arc-close` 는 아크 종료 시에만 도는 검사 20 과 21 과 29 를 그 아크에 대해 돌린다. 그것을 주지
않으면 셋은 수행되지 않았음을 출력에 내고 판정에 들지 않는다.

**이 검증기를 고쳐 통과시키지 않는다.** 검사가 실패하면 그 실패가 산출물이다(SPEC §4).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import NamedTuple

from wiki_common import (
    Ledger,
    REGISTERS,
)

import wiki_ledger
import wiki_formal
import wiki_prose
import wiki_meta


EXTRACTION_NO = re.compile(r"^E-(\d+)$")


# --------------------------------------------------------------------------- 검사


# 이 러너가 거느리는 단위. 검사의 호출과 뿌리의 소스를 읽는 검사가 이 순서를
# 함께 쓴다. 경로의 정본은 공용 설비의 `WIKI_UNITS` 이고 여기는 모듈을 든다.
UNITS = (wiki_ledger, wiki_formal, wiki_prose, wiki_meta)


ORDER = ["1", "2", "3", "3-a", "4-a", "5", "6", "7", "8", "9", "10",
         "11", "12", "13", "14", "15", "23", "24", "25", "16", "17", "18", "19", "20", "21", "26", "27",
         "28", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41",
         "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54",
         "55", "56", "57", "58", "59", "60", "61", "29", "30"]


def run(root: Path, arc_close: str | None, quiet: bool) -> int:
    led = Ledger(root)
    # 검사의 호출을 손으로 열거하지 않고 단위가 선언한 목록을 이어 붙인다.
    # 아크 종료 시에만 도는 검사가 인자를 하나 더 받으므로 그 수를 선언에서
    # 유도하고 갈래를 손으로 적지 않는다.
    reports = [fn(led, arc_close) if fn.__code__.co_argcount == 2 else fn(led)
               for unit in UNITS for fn in unit.CHECKS]
    order = {n: i for i, n in enumerate(ORDER)}
    reports.sort(key=lambda r: order[r.number])

    print(f"원장 검증기 — 뿌리 {root}")
    counts = {name: len(led.reg[name]) for name in REGISTERS}
    print("레지스터 entry: " + " · ".join(f"{k} {v}" for k, v in counts.items())
          + f" · 총계 {sum(counts.values())}")
    print()
    for r in reports:
        r.emit(quiet)

    failed = [r for r in reports if r.failed]
    print()
    ran = sum(1 for r in reports if r.ran)
    print(f"검사 {len(reports)}개 가운데 {ran}개 수행, 실패 {len(failed)}개")
    if failed:
        print("실패한 검사: " + ", ".join(f"{r.number}({r.step})" for r in failed))
        print("\033[1;31m원장 검증 실패\033[0m")
        return 1
    print("\033[1;32m원장 검증 전량 통과\033[0m")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description="원장 검증기 (SPEC.md §2 의 검사 예순하나)")
    ap.add_argument("--root", default=None, help="원장을 읽을 뿌리. 음성 대조가 사본을 지목한다")
    ap.add_argument("--arc-close", default=None, metavar="ARC",
                    help="아크 종료 시에만 도는 검사 20·21·29 를 그 아크에 대해 돌린다")
    ap.add_argument("--quiet", action="store_true", help="보고 줄을 줄인다")
    args = ap.parse_args()
    root = Path(args.root).resolve() if args.root \
        else Path(__file__).resolve().parent.parent
    return run(root, args.arc_close, args.quiet)


if __name__ == "__main__":
    sys.exit(main())
