#!/usr/bin/env python3
"""`step5-mutation` 의 본문. 결론을 부정한 사본이 컴파일에 실패하는지 잰다.

대상은 CrisisFramework 아래 .lean 전량에서 훑어 잡는 최상위 theorem 과 example 이며 계수를
박지 않는다. 목록을 박아 두면 새 진술이 그물 밖에 남는다 (CF-595). 결론의 모양을 가리지 않고
결론 전체를 ¬ ( ) 로 감싼 사본을 만든다 (CF-675). 변이 사본은 파일별로 임시 디렉터리에 만들어
원본을 건드리지 않고 돌린 뒤 지운다.
"""

import re
import shutil
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import vstep_mutation

_ERROR = re.compile(r"error")


def run(ctx) -> None:
    mut_dir = Path(tempfile.mkdtemp())
    rows = [r.split("\t") for r in vstep_mutation.run(str(mut_dir), list(ctx.targets)).split("\n")
            if r != ""]

    if not rows:
        ctx.ok("변이 대상 0 — CrisisFramework 아래에 최상위 theorem 과 example 이 없다")
        shutil.rmtree(mut_dir, ignore_errors=True)
        return

    ctx.ok(f"변이 대상 {len(rows)} ({ctx.per_file(r[1] for r in rows)})")
    # 구문 오류의 머리 목록. 사본을 일부러 깨뜨려 Lean 이 내는 머리를 모은 것이다 (CF-681).
    # 한 가지 머리로만 가르면 그 밖의 머리로 깨진 사본이 거부로 세어지고, 그 진술의 검사가
    # 수행되지 않았는데도 통과로 보고된다. 거부가 아니라 실패로 세는 까닭이 그것이다.
    # 그 목록을 오케스트레이터가 들고 논리 결합 변이가 같은 값을 함께 쓴다. 이 보고의 문면도
    # 그 목록에서 유도하므로 목록과 문면이 갈리지 않는다.
    ctx.rep("구문 오류로 세는 머리: " + " · ".join(ctx.MUT_SYNTAX_HEADS))

    # 사본마다 elaborate 를 따로 돌린다. 판정은 아래에서 원래 순서대로 하므로 병렬이 출력을
    # 바꾸지 않는다. 결론을 잡지 못한 행은 사본을 갖지 않고 그 자리에 자리표를 드므로 그 행을
    # 걸러 넘긴다. 자리로만 잘라 넘기면 그 자리표가 경로로 서서 호출이 돌고 그 실패가 어느
    # 판정에도 들지 않는다.
    ctx.elaborate_all(r[3] for r in rows if r[0] == "MUT")

    for row in rows:
        kind, m_file, m_line, m_copy, m_concl = (row + [""] * 5)[:5]
        if kind == "NOCONCL":
            ctx.bad(f"{m_file}:{m_line} {m_concl} 의 결론을 잡지 못해"
                    " 그 진술의 변이 검사가 수행되지 않았다")
            continue
        rc, out = ctx.elaborated(m_copy)
        head = ctx.MUT_SYNTAX.search(out)
        if rc == 0:
            ctx.bad(f"{m_file}:{m_line} 변이가 통과함 — 해당 진술은 공허한 검사다: {m_concl}")
        elif head:
            # 사본이 깨진 것을 거부로 세면 그 진술의 검사가 공허해지는데도 통과로 보고된다.
            ctx.bad(f"{m_file}:{m_line} 변이 사본이 구문 오류로 깨져"
                    f" 그 진술의 검사가 수행되지 않았다 ({head.group(0)}): {m_concl}")
        else:
            n = sum(1 for ln in out.split("\n") if _ERROR.search(ln))
            ctx.ok(f"{m_file}:{m_line} 변이 거부됨 ({n} error) — 실검사 확인")

    shutil.rmtree(mut_dir, ignore_errors=True)
