#!/usr/bin/env python3
"""원장 검증기의 음성 대조.

`docs/decisions/SPEC.md` §2 의 주입 시험 칸이 든 검사마다 위반을 주입하고, 그 검사가 주입을
잡는지 본다. **주입은 사본에서 하고 원장을 건드리지 않는다.** 사본은 임시 디렉터리에
만들며 검사가 끝나면 지운다.

    python3 scripts/wiki_negative_control.py [--keep]

판정 기준이 셋으로 갈린다. 실패시키는 검사와 아크 종료 검사는 **주입한 사본에서 FAIL 이 나고
기준선에 없던 위반 줄이 새로 나야** 통과다. 기준선에서 이미 실패하는 검사가 있으므로 FAIL
여부만 보면 공허해지기 때문이다. 보고만 하는 검사는 실패시키지 않으므로 **보고 줄이 기준선과
달라지고 주입한 항목이 그 안에 잡혀야** 통과다.

**머리 문면이 계수를 들지 않는다.** 몇을 드는지의 정본은 `CASES` 이고 그 계수는 이 스크립트의
출력이 낸다. 머리 문면이 계수를 들면 검사가 늘 때마다 낡는데 그 낡음을 어느 검사도 보지 않으며,
`collateral-5` 가 받은 판에서 실제로 한 수가 어긋나 있었다.

셋째는 **잡히지 않아야 하는 항**이며 `CASES` 의 여섯째 자리에 `"nocatch"` 를 둔 항이 그것이다.
새 위반 줄이 나지 않아야 통과다. 검사 5 가 날짜로 가르므로 닫힌 날 이전 날짜의 항목은 잡히지
않아야 하고, 그 방향을 재지 않으면 「날짜를 보지 않고 여전히 전량을 잡는다」와 갈리지 않는다.
"""


from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
# 갈래별 음성 대조 단위를 들인다. 주입 함수와 사례 목록이 그 단위에 살고 이
# 자리는 사본을 뜨고 검증기를 돌려 순회를 도는 몫만 든다. **모듈 찾는 경로를
# 삽입하는 파일을 하나로 두는 까닭은** 단위가 그 경로를 이 진입점을 거쳐 받으면
# 그 삽입이 단위마다 번지지 않는다는 것이다.
import wiki_nc_ledger   # noqa: E402
import wiki_nc_formal   # noqa: E402
import wiki_nc_prose    # noqa: E402
import wiki_nc_meta     # noqa: E402
CHECKER = ROOT / "scripts" / "check_wiki.py"
ANSI = re.compile(r"\x1b\[[0-9;]*m")


# 이 하네스가 거느리는 음성 대조 단위. 사례의 손 열거를 들지 않고 단위가 선언한
# 목록을 단위 순서로 이어 붙인다. 러너가 검사의 호출을 그 꼴로 거느리는 선례를
# 그대로 쓰며, 그 사유는 유도의 원천이 문면이어서 뿌리의 소스를 읽는 검사도 같은
# 자리를 볼 수 있다는 것이다.
NC_UNITS = (wiki_nc_ledger, wiki_nc_formal, wiki_nc_prose, wiki_nc_meta)


# ------------------------------------------------------------------ 사본과 실행

def make_copy(dst: Path) -> Path:
    """빌드 산출과 git 메타를 뺀 리포 사본을 만든다."""
    shutil.copytree(
        ROOT, dst,
        ignore=shutil.ignore_patterns(".lake", ".git", "__pycache__"))
    return dst


def run_checker(root: Path, arc_close: str | None = None) -> dict:
    """검증기를 사본에 돌리고 검사별 판정과 줄을 뽑는다."""
    cmd = [sys.executable, str(CHECKER), "--root", str(root)]
    if arc_close:
        cmd += ["--arc-close", arc_close]
    p = subprocess.run(cmd, capture_output=True, text=True)
    out = ANSI.sub("", p.stdout)
    res: dict = {"rc": p.returncode, "raw": out, "checks": {}}
    cur = None
    for line in out.splitlines():
        m = re.match(r"\[check:(\S+)\] (OK|FAIL|REPORT|SKIP)\s+검사 (\S+) — (.*)", line)
        if m:
            cur = m.group(3)
            res["checks"][cur] = {"step": m.group(1), "verdict": m.group(2),
                                  "violations": [], "notes": []}
            continue
        if cur and line.startswith("    · "):
            res["checks"][cur]["violations"].append(line[6:])
        elif cur and line.startswith("    - "):
            res["checks"][cur]["notes"].append(line[6:])
    return res


CASES = [case for unit in NC_UNITS for case in unit.CASES]


def main() -> int:
    ap = argparse.ArgumentParser(description="원장 검증기의 음성 대조")
    ap.add_argument("--keep", action="store_true", help="사본을 지우지 않는다")
    args = ap.parse_args()

    tmp = Path(tempfile.mkdtemp(prefix="wiki-nc-"))
    rows = []
    # 항의 이름은 `<단계 id>#<차례>` 다. 검사 번호에 접미를 붙이면 실재하는 검사 3-a·4-a 와
    # 같은 꼴이 되어 항인지 검사인지 갈리지 않는다. 단계 id 는 네임스페이스가 다르다.
    seen_step: dict = {}
    case_id = []
    for _num, _step, *_ in CASES:
        seen_step[_step] = seen_step.get(_step, 0) + 1
        case_id.append(f"{_step}#{seen_step[_step]}")
    try:
        base_plain = run_checker(make_copy(tmp / "base"))
        base_arc = run_checker(make_copy(tmp / "base-arc"), arc_close="charter")

        for case, cid in zip(CASES, case_id):
            num, step, desc, fn, arc = case[:5]
            # 기대 방향이다. 기본은 잡히는 것이고 "nocatch" 는 잡히지 않아야 하는 항이다.
            expect = case[5] if len(case) > 5 else "catch"
            work = make_copy(tmp / f"case-{num.replace('-', '')}")
            # **표지가 주입 자신에게서 나온다.** 사례 목록이 그것을 상수로 들면 주입이 심는 값을
            # 고치는 회차가 그 상수를 잊어도 어느 검사도 걸리지 않으며, 그 낡음은 보고 부류의
            # 판정이 제 표지를 잃고 「새 보고 줄이 있다」로 떨어지는 꼴로만 남는다.
            marker = fn(work)
            got = run_checker(work, arc_close=arc)
            base = base_arc if arc else base_plain
            b = base["checks"].get(num, {"verdict": "?", "violations": [], "notes": []})
            g = got["checks"].get(num, {"verdict": "?", "violations": [], "notes": []})

            # 보고 부류인지를 **기준선의 판정에서 유도한다.** 번호를 박으면 새로 선 보고 검사가
            # 실패 부류로 갈려 「새 위반 줄 없음」으로 어긋남이 나며, 그 문면에서 검사의 결함과
            # 가름의 결함이 갈리지 않는다. 검사 43 이 그 자리였다. 보고만 하는 검사는 위반 줄을
            # 내지 않으므로 기준선의 판정이 `REPORT` 인 것이 그 부류의 정의와 같다.
            if b["verdict"] == "REPORT":
                # 판정은 기준선 차분으로 그대로 두고 표지의 거처만 옮긴다. 주입이 새로 만든
                # 자리의 줄은 같은 꼴의 줄이 뒤 회차의 기준선에 서더라도 여전히 새 줄이다.
                #
                # **표지가 비면 통과시키지 않는다.** 빈 표지는 어느 줄에나 들어 있는 것으로
                # 읽혀 판정이 「새 보고 줄이 있다」로 떨어지고, 그러면 주입이 겨눈 자리가
                # 보고에 잡혔는지를 재지 않는다.
                new_notes = [n for n in g["notes"] if n not in b["notes"]]
                if not marker:
                    ok = False
                    detail = "보고 부류인데 주입이 표지를 돌려주지 않았다"
                else:
                    ok = bool(new_notes) and any(str(marker) in n for n in new_notes)
                    detail = new_notes[0] if new_notes else "보고 줄에 변화 없음"
            elif expect == "nocatch":
                new_v = [v for v in g["violations"] if v not in b["violations"]]
                ok = not new_v
                detail = ("잡히지 않았다 (기대대로)" if ok
                          else "잡히지 않아야 하는데 잡혔다 — " + new_v[0])
            else:
                new_v = [v for v in g["violations"] if v not in b["violations"]]
                ok = g["verdict"] == "FAIL" and bool(new_v)
                detail = new_v[0] if new_v else "새 위반 줄 없음"
            rows.append((cid, num, desc, b["verdict"], g["verdict"], ok, detail))
            shutil.rmtree(work)
    finally:
        if not args.keep:
            shutil.rmtree(tmp, ignore_errors=True)
        else:
            print(f"사본을 남겼다: {tmp}")

    print()
    print("| 주입 항 | 검사 | 주입한 위반 | 기준선 | 주입 후 | 기대대로인가 |")
    print("|---|---|---|---|---|---|")
    for cid, num, desc, bv, gv, ok, _ in rows:
        print(f"| `{cid}` | {num} | {desc} | {bv} | {gv} | {'예' if ok else '**아니오**'} |")
    print()
    for cid, num, desc, bv, gv, ok, detail in rows:
        print(f"{cid}: {detail}")
    bad = [r for r in rows if not r[5]]
    print()
    print(f"주입 항 {len(rows)}개 가운데 기대대로인 것 {len(rows)-len(bad)}개, "
          f"어긋난 것 {len(bad)}개")
    if bad:
        print("어긋난 항: " + ", ".join(r[0] for r in bad))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
