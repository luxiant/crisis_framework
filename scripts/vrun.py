#!/usr/bin/env python3
"""재현 가능한 전량 검증의 오케스트레이터.

선언된 집합과 그 갈래를 이 모듈이 들고 `scripts/verify.sh` 는 이것을 부르는 진입점만 든다.
단계 본문은 단계마다 자기 모듈에 살고 이 모듈이 그 모듈을 들여 함수로 부른다.

  step1-duplicate  빌드 타깃 밖 중복 사본 탐지 (검증된 파일 ≠ 손에 든 파일 사고 방지)
  step2-build      프로젝트 olean 강제 삭제 후 lake build (디스크 내용 기준 재검증)
  step3-forbidden  금지 구문 정적 검사 (sorry / axiom / noncomputable / Classical / 층별 ℝ)
  step11-leanenv   모듈 탐색 환경을 한 번 들여 빌드 도구가 세우던 것과 대조
                   뒤의 네 자리가 Lean 을 직접 부르게 하고 그 환경이 같은지를 두 축으로 잰다
  step4-baseline   olean 기준 공리 의존 출력 + docs/baseline.md 기준선 차분
                   감사 대상 선언은 매 실행마다 훑어 잡아 임시 프로브 파일로 찍는다
                   공리 출력이 비어 있지 않은 선언의 목록과 계수를 층별로 보고에 낸다 (실패시키지 않는다)
  step8-layertype  층별 수 타입 정적 검사 (CLAUDE.md §2 의 층별 금지 표)
  step9-propfree   정의층 structure 필드와 inductive 생성자의 Prop 금지
  step5-mutation   변이 검사 — 최상위 theorem 과 example 의 결론 전체를 ¬ ( ) 로 감싸 반드시 실패함을 확인
                   대상은 CrisisFramework 아래 .lean 전량에서 훑어 잡는다
  step10-clausemut 논리 결합 변이 — 정의층과 관측층의 판정 반환 함수 본문에서 결합 하나를 뒤집은
                   사본이 통과하는 자리를 세어 docs/baseline.md 의 블록과 맞댄다 (늘면 실패)
  step6-ledger     원장 검증기 check_wiki.py 호출 (SPEC.md §2 의 검사 예순셋)
                   아크 종료 검사 셋은 첫 인자로 아크 이름을 주면 함께 돌고
                   주지 않으면 돌지 않는다 (`bash scripts/verify.sh <아크>`)
  step7-cqfin      CQ 고정 절 대조 check_cqfin.py 호출 (docs/baseline.md §6)

각 단계는 선언된 단계 id 를 [step:<id>] 로 출력에 낸다. 원장의 tier: invariant
항목이 그 id 를 check 필드로 들고 검사 7 이 둘을 대조한다. 그 선언이 이 모듈의 STEPS 에 서고
검사 7 이 이 모듈을 읽는다.

실행: bash scripts/verify.sh
"""

import hashlib
import os
import re
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# 층별 기대 기준선과 모듈 탐색 환경의 변수 이름 집합과 논리 결합 변이의 상한을
# docs/baseline.md 의 기계 판독 블록이 든다. 그 경로를 여러 단계가 함께 읽으므로 한 번 정한다.
BASELINE_DOC = "docs/baseline.md"

# Lean 사본을 병렬로 부르는 자리의 동시 호출 수. 변이 검사와 논리 결합 변이가 이 값을 함께 쓴다.
# 두 자리에 박으면 한쪽만 고쳐져 갈리므로 한 자리에 둔다. 값을 넷으로 두는 것은 받은 판의 논리
# 결합 변이가 그 값으로 돌아 러너에서 통과한 선례가 있기 때문이며, 사본 하나가 의존 묶음의 빌드
# 산출을 읽어 메모리를 쓰므로 코어 수에서 유도하지 않는다.
LEAN_JOBS = 4

# 자기 출력의 정규화가 지우는 넷. 판 사이에 달라지는 것만 지운다. 터미널 색 코드와 절대 경로와
# 소요 시간 표기와 빌드 진행 표시이며 그 밖은 한 글자도 바꾸지 않는다. 같은 환경의 두 판에서
# 실제로 움직이는 것은 뒤의 둘이고 앞의 둘은 환경이 다를 때 움직인다. 해시가 값을 내는 자리가
# 바로 그 자리이므로 넷을 다 지운다. 해시를 내는 줄 자신은 입력에서 빠지며, 그 줄이 출력에
# 더해지는 자리가 모으기가 끝난 뒤이므로 그 빠짐이 구조적으로 선다.
_ANSI = re.compile(r"\x1b\[[0-9;]*m")
_PROGRESS = re.compile(r"\[\d+/\d+\]")
_ELAPSED_PAREN = re.compile(r"\((\d+(?:\.\d+)?m?s)\)")


class Proc:
    """하위 프로세스 하나의 결과.

    받은 판의 셸이 `$(... 2>&1)` 와 `2>file` 의 두 꼴을 함께 썼으므로 이 자리가 그 둘을 함께
    든다. 바이트를 들고 글자는 그 위에서 푼다. 널 문자로 가른 환경 출력이 글자로 풀리지 않는
    바이트를 품을 수 있어 그 자리가 바이트를 요구하기 때문이다.
    """

    __slots__ = ("rc", "out_bytes", "err_bytes")

    def __init__(self, rc: int, out_bytes: bytes, err_bytes: bytes):
        self.rc = rc
        self.out_bytes = out_bytes
        self.err_bytes = err_bytes

    @property
    def out(self) -> str:
        return self.out_bytes.decode("utf-8", "replace")

    @property
    def err(self) -> str:
        return self.err_bytes.decode("utf-8", "replace")


class Ctx:
    """단계가 주고받는 것.

    단계 본문이 단계마다 자기 모듈에 사므로 그 경계를 지나는 값을 이 객체가 든다. 모듈마다
    자기에게 필요한 것을 이 객체에서 꺼내고, 어느 모듈도 다른 모듈을 들이지 않는다.
    """

    # 구문 오류의 머리 목록. 사본을 일부러 깨뜨려 Lean 이 내는 머리를 모은 것이다 (CF-681).
    # 변이 검사와 논리 결합 변이가 이 값을 함께 쓰므로 한 자리에 둔다. 받은 판은 그 값을 변이
    # 검사의 본문에 두고 논리 결합 변이가 그 셸 변수를 읽었는데, 본문이 모듈로 갈리면 그 길이
    # 끊기므로 이 자리가 그것을 받는다. 정규식과 보고 문면을 둘 다 이 목록에서 유도해 그 둘이
    # 갈리지 않게 한다.
    MUT_SYNTAX_HEADS = (
        "unexpected",
        "unterminated comment",
        "unterminated string literal",
        "expected token",
        "Invalid `end`",
    )
    MUT_SYNTAX = re.compile("error: (" + "|".join(MUT_SYNTAX_HEADS) + ")")

    def __init__(self, root: Path, arc_close: list[str]):
        self.root = root
        self.arc_close = arc_close
        self.baseline_doc = BASELINE_DOC
        self.lean_jobs = LEAN_JOBS
        self.fail = 0

        # 검사 대상은 훑어서 잡는다. 박아 두면 새 파일이 금지 구문과 공리 감사와 변이 검사의 그물
        # 밖에 남으며, `lakefile.toml` 의 glob 이 빌드는 하므로 그 사실이 빌드로 드러나지 않는다.
        # 받은 판이 `LC_ALL=C sort` 로 세우던 순서를 바이트로 정렬해 그대로 세운다.
        base = root / "CrisisFramework"
        self.targets = sorted(
            (str(p.relative_to(root)) for p in base.rglob("*.lean") if p.is_file()),
            key=lambda s: s.encode("utf-8"),
        )

        # 빌드 도구가 세운 환경. step11-leanenv 가 한 번 들이고 뒤의 네 자리가 Lean 을 직접 부를 때
        # 이것을 쓴다. 받은 판은 셸의 `export` 로 그 자리를 세웠고 이 자리가 그것을 사전으로 든다.
        self.env: dict[str, str] = dict(os.environ)

        # 주석을 지운 사본. step3-forbidden 이 한 벌 만들고 뒤의 세 단계가 함께 읽으며
        # step9-propfree 가 지운다.
        self.stripped: str | None = None

        self._elab: dict[str, tuple[int, str]] = {}
        self._chunks: list[str] = []
        self._step_id = ""
        self._step_t0 = 0.0

    # ---- 출력 ----
    #
    # 흘려 보내며 모은다. 모았다 한 번에 내면 긴 단계에서 진행이 보이지 않고, 모으지 않으면
    # 자기 출력의 정규화 해시를 낼 입력이 없다.

    def write(self, s: str) -> None:
        self._chunks.append(s)
        sys.stdout.write(s)
        sys.stdout.flush()

    def line(self, s: str = "") -> None:
        self.write(s + "\n")

    def ok(self, msg: str) -> None:
        self.write(f"  \033[32mOK\033[0m   {msg}\n")

    def bad(self, msg: str) -> None:
        self.write(f"  \033[31mFAIL\033[0m {msg}\n")
        self.fail = 1

    def rep(self, msg: str) -> None:
        self.write(f"  \033[36mREPORT\033[0m {msg}\n")

    def indent(self, s: str, pad: str = "  ") -> None:
        """받은 판이 `sed 's/^/  /'` 로 들여쓰던 자리. 말미의 빈 줄을 더하지 않는다."""
        for ln in s.split("\n"):
            self.write(pad + ln + "\n")

    # ---- 단계의 경계 ----
    #
    # 단계마다 경과를 찍어 아크의 기준점 맞댐이 단계별로 서게 한다. 한 단계의 끝은 다음
    # 단계의 시작이므로 이 자리가 앞 단계의 경과를 먼저 찍으며, 마지막 단계는 그 뒤에
    # 불리는 자리가 없어 말미의 판정 앞에서 한 번 더 찍는다. 둘을 가르지 않으면 마지막
    # 단계의 경과가 전량 빠지고 그 빠짐이 출력에서 드러나지 않는다.
    #
    # 값을 괄호 안의 초로 둔다. 자기 출력의 정규화 해시가 소요 시간 표기를 지우는 축을
    # 이미 들고 있어 그 꼴이면 해시가 판 사이에 안정적으로 서고, 괄호를 두지 않으면 그
    # 값이 남아 해시가 매 실행마다 달라져 출력이 리포 상태의 함수가 아니게 된다
    # (CF-674 와 같은 형). 소수 한 자리를 두는 것은 가장 가벼운 두 단계의 합이 초 단위로
    # 접히면 영으로 서기 때문이다.

    def step_elapsed(self) -> None:
        if not self._step_id:
            return
        dt = time.time() - self._step_t0
        self.write(f"[elapsed:{self._step_id}] ({dt:.1f}s)\n")

    def step(self, step_id: str, title: str) -> None:
        self.step_elapsed()
        self._step_id = step_id
        self._step_t0 = time.time()
        self.write(f"\n\033[1m== {step_id} {title}\033[0m\n")
        self.write(f"[step:{step_id}]\n")

    # ---- 하위 프로세스 ----

    def run(self, cmd: list[str], env: dict[str, str] | None = None,
            merge: bool = False, binary: bool = False) -> Proc:
        """리포의 뿌리에서 명령을 돌린다. 받은 판의 셸이 뿌리로 옮겨 돌던 자리다.

        `merge` 는 받은 판의 `2>&1` 이고 `binary` 는 글자로 풀지 않고 받는 자리를 위한 표지다.

        바이너리가 없는 자리에서 터지지 않고 종료 코드 백스물일곱과 그 사유를 낸다. 받은 판의
        셸이 그 자리에서 터지지 않고 그 값을 내므로 판정이 그 꼴에 걸려 있으며, 터지면 그
        단계의 실패가 적발로 기록되지 않고 전량이 그 자리에서 끊긴다. 그 사유 문면은 셸이 내던
        것과 다르고 그 다름이 툴체인이 서지 않은 환경에만 선다.
        """
        try:
            p = subprocess.run(
                cmd, cwd=str(self.root),
                env=env if env is not None else self.env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT if merge else subprocess.PIPE,
                check=False,
            )
        except (FileNotFoundError, NotADirectoryError, PermissionError) as e:
            msg = f"{cmd[0]}: command not found\n".encode("utf-8")
            if isinstance(e, PermissionError):
                msg = f"{cmd[0]}: Permission denied\n".encode("utf-8")
            return Proc(127, msg if merge else b"", b"" if merge else msg)
        return Proc(p.returncode, p.stdout or b"", p.stderr or b"")

    def lean_bin(self) -> str:
        """Lean 바이너리의 경로. 받은 판의 `${LEAN:-lean}` 과 같은 꼴이다."""
        return self.env.get("LEAN") or "lean"

    def elaborate_all(self, copies) -> None:
        """변이 사본마다 elaborate 를 따로 돌린다.

        받은 판이 `xargs -P` 로 돌리고 사본 옆의 파일에 종료 코드와 출력을 적었고, 판정은 그
        뒤에 원래 순서대로 했다. 이 자리가 그 값을 사전에 담아 같은 꼴로 세운다. 파일을 두지
        않는 것은 그 파일이 판정 밖의 어느 자리도 읽지 않고 사본의 임시 디렉터리와 함께
        지워지기 때문이다.
        """
        lean = self.lean_bin()
        paths = [c for c in copies]
        with ThreadPoolExecutor(max_workers=self.lean_jobs) as ex:
            for c, p in zip(paths, ex.map(
                    lambda x: self.run([lean, x], merge=True), paths)):
                self._elab[c] = (p.rc, p.out)

    def elaborated(self, copy: str) -> tuple[int, str]:
        """`elaborate_all` 이 담은 종료 코드와 출력. 돌지 않은 자리는 빈 값을 낸다."""
        return self._elab.get(copy, (-1, ""))

    # ---- 보조 ----

    @staticmethod
    def per_file(names) -> str:
        """받은 판의 `uniq -c` 가 내던 파일별 계수. 잇닿은 같은 값만 묶는다."""
        out: list[str] = []
        prev = None
        n = 0
        for x in names:
            if x == prev:
                n += 1
                continue
            if prev is not None:
                out.append(f"{prev} {n}")
            prev, n = x, 1
        if prev is not None:
            out.append(f"{prev} {n}")
        return " · ".join(out)

    # ---- 자기 출력의 정규화 해시 ----

    def digest(self) -> str:
        s = "".join(self._chunks)
        s = _ANSI.sub("", s)
        s = s.replace(str(self.root), "<ROOT>")
        home = os.environ.get("HOME", "")
        if home and home != "/":
            s = s.replace(home, "<HOME>")
        s = _PROGRESS.sub("[<progress>]", s)
        s = _ELAPSED_PAREN.sub("(<time>)", s)
        return hashlib.sha256(s.encode("utf-8")).hexdigest()[:12]


class Step:
    """선언된 집합의 한 항. 식별자와 갈래와 제목과 본문을 든다."""

    __slots__ = ("id", "kind", "title", "run")

    def __init__(self, step_id: str, kind: str, title: str, run):
        self.id = step_id
        self.kind = kind
        self.title = title
        self.run = run


def _bodies():
    """단계 본문의 모듈을 들인다.

    파이썬이 직접 불린 스크립트의 디렉터리를 모듈 찾는 경로의 앞에 두므로 같은 디렉터리의
    모듈을 이름으로 들일 수 있고, 원장 검증기의 진입점이 그 선례를 이미 쓴다. 들이는 자리를
    함수 안에 두는 것은 선언 전량이 모듈 수준에서 서야 하는데 그 들이기가 뿌리 경로를
    요구하지 않기 때문이다.
    """
    import vrun_step1, vrun_step2, vrun_step3, vrun_step4, vrun_step5
    import vrun_step6, vrun_step7, vrun_step8, vrun_step9, vrun_step10, vrun_step11
    return (vrun_step1, vrun_step2, vrun_step3, vrun_step4, vrun_step5,
            vrun_step6, vrun_step7, vrun_step8, vrun_step9, vrun_step10, vrun_step11)


(_s1, _s2, _s3, _s4, _s5, _s6, _s7, _s8, _s9, _s10, _s11) = _bodies()

# 선언된 집합. 돌리는 순서가 이 순서다. 갈래는 그 단계가 무엇에 매여 있는지를 들며,
# 정적 검사는 디스크의 문면만 읽고 빌드는 빌드 산출을 낳으며 Lean 은 그 산출을 읽는다.
STEPS = (
    Step("step1-duplicate", "static", "빌드 타깃 밖 중복 사본 탐지", _s1.run),
    Step("step2-build", "build", "olean 삭제 후 전량 재빌드", _s2.run),
    Step("step3-forbidden", "static", "금지 구문 정적 검사 (층별 `ℝ` 포함)", _s3.run),
    Step("step11-leanenv", "leanenv", "모듈 탐색 환경을 한 번 들여 빌드 도구가 세우던 것과 대조", _s11.run),
    Step("step4-baseline", "lean", "공리 의존 + `docs/baseline.md` 기준선 차분", _s4.run),
    Step("step8-layertype", "static", "층별 수 타입 정적 검사 (L-10)", _s8.run),
    Step("step9-propfree", "static", "발동조건 문법의 `Prop` 금지 (C-10)", _s9.run),
    Step("step5-mutation", "lean", "변이 검사", _s5.run),
    Step("step10-clausemut", "lean", "논리 결합 변이 — 판정 반환 함수의 증거가 덮는 범위", _s10.run),
    Step("step6-ledger", "ledger", "`check_wiki.py` 호출", _s6.run),
    Step("step7-cqfin", "ledger", "CQ 고정 절 대조", _s7.run),
)


def declared_steps() -> list[str]:
    """선언된 단계 id. 검사 7 이 티어의 `check` 필드를 이 값과 맞댄다."""
    return [s.id for s in STEPS]


def main(argv: list[str]) -> int:
    # 첫 인자를 아크 이름으로 읽어 원장 검증기에 `--arc-close` 로 넘긴다. 주지 않으면 그 인자
    # 없이 부르므로 호출이 글자대로 그대로다. 아크를 닫는 커밋이 한 아크에서 가장 무거운 커밋인데,
    # 그것을 가르는 검사 셋의 판정이 이 출력 밖에서만 돌 수 있었다(W-3). 단계 id 는 바꾸지 않는다.
    arc_close = ["--arc-close", argv[0]] if argv and argv[0] else []
    ctx = Ctx(ROOT, arc_close)

    for s in STEPS:
        ctx.step(s.id, s.title)
        s.run(ctx)

    ctx.step_elapsed()
    ctx.line()
    if ctx.fail == 0:
        ctx.write("\033[1;32m전량 통과\033[0m\n")
    else:
        ctx.write("\033[1;31m검증 실패 항목 있음\033[0m\n")

    # 자기 출력의 정규화 해시를 마지막 줄에 낸다. 갈음한 보고에서도 판 사이 대조가
    # 기계로 서게 하는 앵커이며, 판정이 아니므로 종료 코드를 이 값으로 가르지 않는다.
    # 검사 결과가 바뀌면 값이 달라지는 것이 당연하고 그것은 실패가 아니다.
    sys.stdout.write(f"OUTPUT_DIGEST={ctx.digest()}\n")
    sys.stdout.flush()
    return ctx.fail


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
