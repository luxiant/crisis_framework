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

**면제마다 끈 사본을 함께 잰다.** 원장 검증기는 값 정본에 등록된 이름으로만 면제하고 환경 변수가 그
이름을 끄면 그 면제가 서지 않는다. 순회가 끝나면 기준선의 사본에서 면제를 하나씩 꺼 기준선에 없던
위반 줄과 보고 줄을 세어 표로 낸다. 그 표는 계측이고 판정에 들지 않는다.

**주입 자리가 없는 항은 건너뛴다.** 주입 함수가 `SystemExit` 로 그 사실을 알리면 그 항을 재지 않고
다음 항으로 간다. 그 항은 기대대로인 것으로도 어긋난 것으로도 세지 않으며, 그 이름과 사유를 별도의
표가 들고 그 계수를 요약 줄이 든다. 원장이 바뀌어 주입 대상이 사라지는 일이 실재하므로, 그 자리에서
순회 전체가 멈추면 뒤의 항이 재어지지 않은 채로 남고 그 사실이 출력에 드러나지 않는다.
"""


from __future__ import annotations

import argparse
import os
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
import wiki_prose       # noqa: E402
import wiki_common      # noqa: E402
CHECKER = ROOT / "scripts" / "check_wiki.py"
ANSI = re.compile(r"\x1b\[[0-9;]*m")


# 음성 대조의 사본에 주는 커밋 메시지. 사본은 깃 메타 없이 복사되므로 검사 41 의 커밋 메시지 몫이
# 출처를 갖도록 하네스가 사본 밖에 깨끗한 메시지 파일을 두고 그 경로를 환경 변수로 넘긴다. **사본
# 안에 아래 이름의 파일이나 디렉터리가 서면 그것을 대신 넘기고, 사본 안에 깃 메타가 서면 환경 변수를
# 넘기지 않아 머리 커밋의 메시지가 재어진다.** 메시지 몫을 찌르는 주입이 이 셋으로 출처를 고른다.
# 그 이름의 정본은 그 주입이 사는 단위이며 여기서 다시 적지 않는다.
NC_MESSAGE_FILE = wiki_nc_prose.INJ_MESSAGE_FILE


CLEAN_MESSAGE = "음성 대조의 사본에 주는 커밋 메시지다. 금지된 지목을 들지 않는다.\n"


# 하네스가 자식 프로세스에 물려주지 않는 환경 변수. 결정 세션이 커밋 앞의 검증에 준 메시지가 사본에
# 새면 주입이 고른 출처가 가려지고, 면제를 끄는 변수가 새면 기준선과 주입한 사본이 다른 면제로
# 재어진다. 면제를 끄는 변수는 역방향 몫이 사본마다 따로 준다.
NC_STRIP_ENV = (wiki_prose.COMMIT_MESSAGE_ENV, wiki_common.EXEMPT_OFF_ENV)


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


def checker_env(root: Path, clean_message: Path | None,
                exempt_off: str | None = None) -> dict[str, str]:
    """사본에 검증기를 돌릴 환경. 커밋 메시지의 출처를 사본의 상태에서 고른다."""
    env = {k: v for k, v in os.environ.items() if k not in NC_STRIP_ENV}
    if exempt_off:
        env[wiki_common.EXEMPT_OFF_ENV] = exempt_off
    if (root / ".git").exists():
        return env
    if (root / NC_MESSAGE_FILE).exists():
        env[wiki_prose.COMMIT_MESSAGE_ENV] = str(root / NC_MESSAGE_FILE)
    elif clean_message is not None:
        env[wiki_prose.COMMIT_MESSAGE_ENV] = str(clean_message)
    return env


def run_checker(root: Path, arc_close: str | None = None,
                clean_message: Path | None = None, exempt_off: str | None = None) -> dict:
    """검증기를 사본에 돌리고 검사별 판정과 줄을 뽑는다."""
    cmd = [sys.executable, str(CHECKER), "--root", str(root)]
    if arc_close:
        cmd += ["--arc-close", arc_close]
    p = subprocess.run(cmd, capture_output=True, text=True,
                       env=checker_env(root, clean_message, exempt_off))
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


def reverse_measure(base_root: Path, base: dict, clean: Path) -> list[tuple[str, int, str, int]]:
    """면제를 이름마다 하나씩 끈 사본에서 기준선에 없던 줄을 센다.

    **판정이 아니라 계측이다.** 받는 자리가 없는 면제는 끄더라도 적발이 늘지 않으므로 늘지 않은 것을
    어긋남으로 세지 않는다. 그 표가 면제마다 지금 받는 양을 보여 주며, 면제를 이름으로 끄는 몫이
    끄는 쪽으로만 움직이므로 검사를 느슨하게 만들 수 없다. 이름은 사본의 값 정본에서 읽는다.
    """
    m = wiki_common.EXEMPT_BLOCK.search(
        (base_root / "docs" / "baseline.md").read_text(encoding="utf-8"))
    rows, _reasons, _bad = wiki_common.exempt_rows(m.group(1) if m else "")
    out = []
    for name in sorted(rows):
        got = run_checker(base_root, clean_message=clean, exempt_off=name)
        n_v = n_n = 0
        where = []
        for num, g in got["checks"].items():
            b = base["checks"].get(num, {"verdict": "?", "violations": [], "notes": []})
            new_v = [v for v in g["violations"] if v not in b["violations"]]
            if new_v:
                n_v += len(new_v)
                where.append(f"{num} {len(new_v)}")
            if b["verdict"] == "REPORT":
                n_n += len([x for x in g["notes"] if x not in b["notes"]])
        out.append((name, n_v, " · ".join(where), n_n))
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description="원장 검증기의 음성 대조")
    ap.add_argument("--keep", action="store_true", help="사본을 지우지 않는다")
    args = ap.parse_args()

    tmp = Path(tempfile.mkdtemp(prefix="wiki-nc-"))
    clean = tmp / "clean-commit-message.txt"
    clean.write_text(CLEAN_MESSAGE, encoding="utf-8")
    rows = []
    skipped = []
    # 항의 이름은 `<단계 id>#<차례>` 다. 검사 번호에 접미를 붙이면 실재하는 검사 3-a·4-a 와
    # 같은 꼴이 되어 항인지 검사인지 갈리지 않는다. 단계 id 는 네임스페이스가 다르다.
    seen_step: dict = {}
    case_id = []
    for _num, _step, *_ in CASES:
        seen_step[_step] = seen_step.get(_step, 0) + 1
        case_id.append(f"{_step}#{seen_step[_step]}")
    try:
        base_plain = run_checker(make_copy(tmp / "base"), clean_message=clean)
        base_arc = run_checker(make_copy(tmp / "base-arc"), arc_close="charter",
                               clean_message=clean)

        for case, cid in zip(CASES, case_id):
            num, step, desc, fn, arc = case[:5]
            # 기대 방향이다. 기본은 잡히는 것이고 "nocatch" 는 잡히지 않아야 하는 항이다.
            expect = case[5] if len(case) > 5 else "catch"
            work = make_copy(tmp / f"case-{num.replace('-', '')}")
            # **표지가 주입 자신에게서 나온다.** 사례 목록이 그것을 상수로 들면 주입이 심는 값을
            # 고치는 회차가 그 상수를 잊어도 어느 검사도 걸리지 않으며, 그 낡음은 보고 부류의
            # 판정이 제 표지를 잃고 「새 보고 줄이 있다」로 떨어지는 꼴로만 남는다.
            try:
                marker = fn(work)
            except SystemExit as exc:
                # 주입 자리가 없음을 알린 항이다. 사본을 지우고 다음 항으로 가며, 사유는
                # 그 예외가 든 문면을 그대로 옮긴다.
                why = "" if exc.code is None else str(exc.code)
                skipped.append((cid, num, desc, why))
                shutil.rmtree(work)
                continue
            got = run_checker(work, arc_close=arc, clean_message=clean)
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
        reverse = reverse_measure(tmp / "base", base_plain, clean)
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
    if skipped:
        print()
        print("| 건너뛴 항 | 검사 | 주입하려던 위반 | 주입 자리가 없는 사유 |")
        print("|---|---|---|---|")
        for cid, num, desc, why in skipped:
            print(f"| `{cid}` | {num} | {desc} | {why} |")
    print()
    print("| 끈 면제 | 끈 사본에서 새로 선 위반 줄 | 그 줄이 선 검사 | 보고 검사에서 새로 선 줄 |")
    print("|---|---|---|---|")
    for name, n_v, where, n_n in reverse:
        print(f"| {name} | {n_v} | {where or '없음'} | {n_n} |")
    bad = [r for r in rows if not r[5]]
    print()
    print(f"주입 항 {len(rows) + len(skipped)}개 가운데 기대대로인 것 {len(rows)-len(bad)}개, "
          f"어긋난 것 {len(bad)}개, 건너뛴 것 {len(skipped)}개")
    if skipped:
        print("건너뛴 항: " + ", ".join(r[0] for r in skipped))
    if bad:
        print("어긋난 항: " + ", ".join(r[0] for r in bad))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
