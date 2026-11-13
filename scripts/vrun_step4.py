#!/usr/bin/env python3
"""`step4-baseline` 의 본문. 공리 의존 출력을 값 정본의 기준선과 차분한다.

층별 기대 기준선은 docs/baseline.md 의 기계 판독 블록이 든다. 값을 이 자리에 전사하면
문서를 고쳐도 검사가 낡은 값으로 돌기 때문이다 (baseline.md 머리말). 화이트리스트가 아니라
차분이다. 실효 기준선 자체는 매 실행마다 Scratch/VerifyBuilt.lean 의 층별 프로브가 다시 찍는다.

Lean 을 빌드 도구를 거치지 않고 직접 부른다. 그 환경은 step11-leanenv 가 한 번 들였다.
"""

import shutil
import tempfile
from pathlib import Path

import vstep_axiomdiff
import vstep_declprobe

INDENT = " " * 7


def run(ctx) -> None:
    vb = ctx.run([ctx.lean_bin(), "Scratch/VerifyBuilt.lean"], merge=True)
    vb_out = vb.out.rstrip("\n")
    ctx.indent(vb_out)
    if vb.rc == 0:
        ctx.ok("VerifyBuilt 통과 (DecidableEq 없이 적용됨)")
    else:
        ctx.bad("VerifyBuilt 실패")

    # 감사 대상 선언은 목록을 박지 않고 매 실행마다 훑어 잡는다. 박아 두면 새 선언이 그물 밖에
    # 남고, `lakefile.toml` 의 glob 이 빌드는 하므로 그 사실이 빌드로 드러나지 않는다 (CF-595).
    # 주석을 지운 뒤 줄머리의 inductive·structure·def·theorem·abbrev·instance 뒤 이름을 뽑고
    # 그 자리에서 열려 있는 namespace 를 앞에 붙인다. example 은 이름이 없어 대상이 아니다.
    # 뽑은 이름마다 `#print axioms` 한 줄을 내는 프로브 파일을 임시 디렉터리에 만들어 돌린다.
    audit = Path(tempfile.mkdtemp())
    vstep_declprobe.run(str(audit), ctx.stripped, list(ctx.targets))

    pr = ctx.run([ctx.lean_bin(), str(audit / "Probe.lean")], merge=True)
    pr_out = pr.out.rstrip("\n")
    ctx.indent(pr_out)
    decls = (audit / "decls.tsv").read_text(encoding="utf-8")
    if pr.rc == 0:
        ctx.ok(f"선언 감사 프로브 통과 (임시 파일, 선언 {decls.count(chr(10))})")
    else:
        ctx.bad("선언 감사 프로브 실패")
    for a in (audit / "anon.txt").read_text(encoding="utf-8").split("\n"):
        if a != "":
            ctx.bad(f"이름 없는 instance 는 이름으로 감사할 수 없다: {a}")

    # 층별 판정을 한 호출에 모은다. 받은 판은 선언마다 공리 목록을 셸에서 뽑고 기준선 차분을
    # 파이썬으로 내므로 그 호출이 선언 수만큼 서며 그 수가 세 자리다. 공리 출력과 값 정본의
    # 블록과 선언 목록을 한 번에 넘기면 전량이 한 호출에서 판정되고 이 자리는 그 판정 행을 읽어
    # 찍는다. `#print axioms` 는 목록이 길면 줄바꿈해 출력하므로 공백을 접어서 대조하며 접는
    # 자리도 그 호출 안이다.
    #
    # 공리 출력이 비어 있지 않은 선언의 누계와 층별 내역을 함께 낸다. 기준선 초과가 없다는 것과
    # 공리 출력이 비어 있다는 것이 다른 사실인데 둘을 가르는 출력이 없었다. 차분은 그 층의
    # 기준선과 맞대므로 기준선이 비어 있지 않은 층에서는 비어 있지 않은 값이 전부 통과로 묻힌다.
    # 관측층의 기준선이 비어 있어 그 층의 선언이 아래 층 선언을 부르면 초과가 서는데, 그 초과가
    # 설 자리를 미리 드러내는 것이 이 보고의 몫이다. **실패시키지 않는다.** 지금 서 있는 호출이
    # 전부 막히고, 초과분이 도구 구현에서 오는 종류라 처리가 회피이며, 기준선을 올리면 추적
    # 의무가 그 층에서 무력해지기 때문이다. 보고로 두면 발원지를 깨끗하게 만드는 작업의 대상
    # 목록이 매 회차 갱신된다. 패턴의 모양으로 가르지 않고 공리를 직접 재는 까닭은, 와일드카드를
    # 든 선언을 세는 쪽이 유한집합과 몫 구성에서 오는 공리를 전부 놓치고 맨 끝 포괄 분기 하나뿐인
    # 선언도 공리를 내는 것이 실측됐기 때문이다.
    (audit / "axioms.txt").write_text(vb_out + "\n" + pr_out, encoding="utf-8")
    audit_out = vstep_axiomdiff.run(
        str(audit / "axioms.txt"), ctx.baseline_doc, str(audit / "decls.tsv"))

    audited = "0"
    audit_detail = ""
    nonempty = "0"
    ne_detail = ""
    for ln in audit_out.split("\n"):
        f = ln.split("\t")
        kind = f[0]
        a, b, c, d = (f[1:] + [""] * 4)[:4]
        if kind == "BASE_MISS":
            ctx.bad(f"{ctx.baseline_doc} 의 기계 판독 블록에서 {a} 를 읽지 못함 — 형식 확인 필요")
        elif kind == "BASE_OK":
            ctx.ok(f"기준선을 {ctx.baseline_doc} 에서 읽음: {a}={b}")
        elif kind == "PROBE_MISS":
            ctx.bad(f"{a} 기준선 프로브 출력을 찾지 못함 ({b})"
                    " — Scratch/VerifyBuilt.lean 확인 필요")
        elif kind == "PROBE_OK":
            ctx.ok(f"{a} 실효 기준선 실측 = {b} (기대값과 일치)")
        elif kind == "PROBE_DIFF":
            ctx.bad(f"{a} 실효 기준선이 기대값과 다름: 측정 {b} / 기대 {c}"
                    " — docs/baseline.md 의 갱신은 사람의 결정")
        elif kind == "DECL_MISS":
            ctx.bad(f"{a}: 공리 출력을 찾지 못함")
        elif kind == "DECL_SAME":
            ctx.ok(f"{a}: {b} (기준선과 동일)")
        elif kind == "DECL_UNDER":
            ctx.ok(f"{a}: {b} (기준선 이하)")
        elif kind == "DECL_EXCESS":
            ctx.bad(f"{a}: 기준선 초과 — {b} / 기준선 {c} / 초과분 {d}."
                    " 어느 보조정리에서 유입됐는지 추적할 것 (CLAUDE.md §5-2)")
        elif kind == "NONEMPTY":
            ctx.rep(f"{a} 공리 출력이 비어 있지 않은 선언 {b} / {c}")
        elif kind == "NONEMPTY_ITEM":
            ctx.write(INDENT + a + "\n")
        elif kind == "LAYER_UNKNOWN":
            ctx.bad(f"층 기준선이 정해지지 않은 자리의 선언: {a} 의 {b}")
        elif kind == "TOTAL":
            audited, audit_detail = a, b
        elif kind == "NE_TOTAL":
            nonempty, ne_detail = a, b

    shutil.rmtree(audit, ignore_errors=True)

    ctx.ok(f"공리 감사 대상 선언 {audited} ({audit_detail})")
    ctx.rep(f"공리 출력이 비어 있지 않은 선언 {nonempty} / {audited} ({ne_detail})."
            " 실패시키지 않는다")
