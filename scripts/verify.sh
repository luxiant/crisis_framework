#!/usr/bin/env bash
# 재현 가능한 전량 검증 스크립트.
#
#   step1-duplicate  빌드 타깃 밖 중복 사본 탐지 (검증된 파일 ≠ 손에 든 파일 사고 방지)
#   step2-build      프로젝트 olean 강제 삭제 후 lake build (디스크 내용 기준 재검증)
#   step3-forbidden  금지 구문 정적 검사 (sorry / axiom / noncomputable / Classical / 층별 ℝ)
#   step11-leanenv   모듈 탐색 환경을 한 번 들여 빌드 도구가 세우던 것과 대조
#                    뒤의 네 자리가 Lean 을 직접 부르게 하고 그 환경이 같은지를 두 축으로 잰다
#   step4-baseline   olean 기준 공리 의존 출력 + docs/baseline.md 기준선 차분
#                    감사 대상 선언은 매 실행마다 훑어 잡아 임시 프로브 파일로 찍는다
#                    공리 출력이 비어 있지 않은 선언의 목록과 계수를 층별로 보고에 낸다 (실패시키지 않는다)
#   step8-layertype  층별 수 타입 정적 검사 (CLAUDE.md §2 의 층별 금지 표)
#   step9-propfree   정의층 structure 필드와 inductive 생성자의 Prop 금지
#   step5-mutation   변이 검사 — 최상위 theorem 과 example 의 결론 전체를 ¬ ( ) 로 감싸 반드시 실패함을 확인
#                    대상은 CrisisFramework 아래 .lean 전량에서 훑어 잡는다
#   step10-clausemut 논리 결합 변이 — 정의층과 관측층의 판정 반환 함수 본문에서 결합 하나를 뒤집은
#                    사본이 통과하는 자리를 세어 docs/baseline.md 의 블록과 맞댄다 (늘면 실패)
#   step6-ledger     원장 검증기 check_wiki.py 호출 (SPEC.md §2 의 검사 예순하나)
#                    아크 종료 검사 셋은 첫 인자로 아크 이름을 주면 함께 돌고
#                    주지 않으면 돌지 않는다 (`bash scripts/verify.sh <아크>`)
#   step7-cqfin      CQ 고정 절 대조 check_cqfin.py 호출 (docs/baseline.md §6)
#
# 각 단계는 선언된 단계 id 를 [step:<id>] 로 출력에 낸다. 원장의 tier: invariant
# 항목이 그 id 를 check 필드로 들고 검사 7 이 둘을 대조한다.
#
# 실행: bash scripts/verify.sh
set -uo pipefail

export PATH=/root/.elan/bin:$PATH
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# 자기 출력의 정규화 해시를 마지막 줄에 낸다. 갈음한 보고에서도 판 사이 대조가
# 기계로 서게 하는 앵커이며, 판정이 아니므로 종료 코드를 이 값으로 가르지 않는다.
# 검사 결과가 바뀌면 값이 달라지는 것이 당연하고 그것은 실패가 아니다.
#
# 정규화는 판 사이에 달라지는 것만 지운다. 지우는 것은 넷이며 터미널 색 코드와
# 절대 경로와 소요 시간 표기와 빌드 진행 표시다. 그 밖은 한 글자도 바꾸지 않는다.
# 같은 환경의 두 판에서 실제로 움직이는 것은 뒤의 둘이고, 앞의 둘은 환경이 다를 때
# 움직인다. 해시가 값을 내는 자리가 바로 그 자리이므로 넷을 다 지운다.
#
# 이 줄 자신은 해시의 입력에서 뺀다. 자기 해시를 입력에 넣으면 값이 정해지지 않는다.
if [ -z "${VERIFY_DIGEST_CHILD:-}" ]; then
  digest_log=$(mktemp)
  VERIFY_DIGEST_CHILD=1 bash "$0" "$@" 2>&1 | tee "$digest_log"
  digest_rc=${PIPESTATUS[0]}
  printf 'OUTPUT_DIGEST=%s\n' "$(
    python3 - "$digest_log" "$ROOT" "${HOME:-}" <<'NORMALIZE' | sha256sum | cut -c1-12
import re, sys

log, root, home = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(log, encoding='utf-8', errors='replace').read()

s = re.sub(r'\x1b\[[0-9;]*m', '', s)                       # 터미널 색 코드
s = s.replace(root, '<ROOT>')                              # 절대 경로
if home and home != '/':
    s = s.replace(home, '<HOME>')
s = re.sub(r'\[\d+/\d+\]', '[<progress>]', s)              # 빌드 진행 표시
s = re.sub(r'\((\d+(?:\.\d+)?m?s)\)', '(<time>)', s)        # 소요 시간 표기

sys.stdout.write(s)
NORMALIZE
  )"
  rm -f "$digest_log"
  exit "$digest_rc"
fi

# 검사 대상은 훑어서 잡는다. 박아 두면 새 파일이 금지 구문과 공리 감사와 변이 검사의 그물
# 밖에 남으며, `lakefile.toml` 의 glob 이 빌드는 하므로 그 사실이 빌드로 드러나지 않는다.
mapfile -t TARGETS < <(find CrisisFramework -name '*.lean' -type f | LC_ALL=C sort)

# Lean 사본을 병렬로 부르는 자리의 동시 호출 수. 변이 검사와 논리 결합 변이가 이 값을 함께 쓴다.
# 두 자리에 박으면 한쪽만 고쳐져 갈리므로 한 자리에 둔다. 값을 넷으로 두는 것은 받은 판의 논리
# 결합 변이가 그 값으로 돌아 러너에서 통과한 선례가 있기 때문이며, 사본 하나가 의존 묶음의 빌드
# 산출을 읽어 메모리를 쓰므로 코어 수에서 유도하지 않는다.
LEAN_JOBS=4

fail=0
# 단계마다 경과를 찍어 아크의 기준점 맞댐이 단계별로 서게 한다. 한 단계의 끝은 다음
# 단계의 시작이므로 이 함수가 앞 단계의 경과를 먼저 찍으며, 마지막 단계는 그 뒤에
# 불리는 자리가 없어 말미의 판정 앞에서 한 번 더 찍는다. 둘을 가르지 않으면 마지막
# 단계의 경과가 전량 빠지고 그 빠짐이 출력에서 드러나지 않는다.
#
# 값을 괄호 안의 초로 둔다. 자기 출력의 정규화 해시가 소요 시간 표기를 지우는 축을
# 이미 들고 있어 그 꼴이면 해시가 판 사이에 안정적으로 서고, 괄호를 두지 않으면 그
# 값이 남아 해시가 매 실행마다 달라져 출력이 리포 상태의 함수가 아니게 된다
# (CF-674 와 같은 형). 소수 한 자리를 두는 것은 가장 가벼운 두 단계의 합이 초 단위로
# 접히면 영으로 서기 때문이다.
STEP_ID=
STEP_T0=
step_elapsed() {
  [ -n "$STEP_ID" ] || return 0
  printf '[elapsed:%s] (%ss)\n' "$STEP_ID" \
    "$(awk -v a="$STEP_T0" -v b="$(date +%s.%N)" 'BEGIN { printf "%.1f", b - a }')"
}
step() {
  step_elapsed
  STEP_ID=$1
  STEP_T0=$(date +%s.%N)
  printf '\n\033[1m== %s\033[0m\n' "$*"; printf '[step:%s]\n' "$1"
}
ok()   { printf '  \033[32mOK\033[0m   %s\n' "$*"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$*"; fail=1; }
rep()  { printf '  \033[36mREPORT\033[0m %s\n' "$*"; }

step step1-duplicate "빌드 타깃 밖 중복 사본 탐지"
# 저장소 전체를 훑는다. crisis-framework/ 안만 보면 상위 디렉터리에 놓인
# 낡은 초안 사본을 놓친다 (1차 검증 직후 실제로 발생한 사고).
#
# 탐색을 대상마다 돌리지 않고 한 번만 돌린다. 제외를 부정 경로로 거르는 꼴은 그 디렉터리
# 안을 전량 순회한 뒤 결과만 버리므로 빌드 산출에 받아 둔 의존 패키지 전량이 대상 파일마다
# 다시 순회되며, 가지치기로 바꾸면 그 디렉터리에 아예 들어가지 않는다. 빌드 타깃 판별도
# 대상 전량을 다시 훑지 않고 해소된 경로의 집합으로 한 번에 받는다. `-type f` 를 두지
# 않는 것은 받은 판의 동작을 그대로 두기 위한 것이다.
#
# 적발의 순서는 대상 경로로 정렬해 고정한다. 탐색이 낸 순서를 그대로 쓰면 디렉터리 순회
# 순서가 출력에 들어와 OUTPUT_DIGEST 가 리포 상태의 함수가 아니게 된다 (CF-674 와 같은 형).
SCAN="$(git rev-parse --show-toplevel 2>/dev/null || echo "$ROOT")"
dup=0
declare -A TARGET_ABS=() TARGET_OF=()
for t in "${TARGETS[@]}"; do
  TARGET_ABS["$(readlink -f "$ROOT/$t")"]=1
  # 한 파일명이 여러 층에 서므로 대상을 쌓는다. 받은 판이 대상마다 탐색을 돌려 같은
  # 사본을 대상마다 적발하므로 그 쌍의 수가 같아야 한다.
  TARGET_OF["$(basename "$t")"]+="$t"$'\n'
done
dup_rows=()
while IFS= read -r other; do
  base=$(basename "$other")
  [ -n "${TARGET_OF[$base]:-}" ] || continue
  other_abs=$(readlink -f "$other")
  # 다른 빌드 타깃은 사본이 아니다. `lakefile.toml` 의 glob 이 둘을 함께 세우고
  # `lake` 가 경로로 구별하므로 검증에서 빠지는 파일이 아니다. 이 검사가 잡으려는
  # 것은 빌드 타깃 **밖**의 낡은 초안이며 CF-83 의 사고가 그 형이었다.
  [ -n "${TARGET_ABS[$other_abs]:-}" ] && continue
  rel=${other#"$SCAN"/}
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    if diff -q "$other" "$ROOT/$t" >/dev/null 2>&1; then
      dup_rows+=("$t"$'\t'"중복 사본(내용 동일, 그래도 혼동 위험): $rel  ↔  $t")
    else
      dup_rows+=("$t"$'\t'"중복 사본(내용 다름 — 위험): $rel  ↔  $t")
    fi
  done <<< "${TARGET_OF[$base]}"
done < <(find "$SCAN" \( -name .lake -o -name .git \) -prune -o -name '*.lean' -print)
if [ "${#dup_rows[@]}" -gt 0 ]; then
  dup=1
  while IFS= read -r row; do bad "${row#*$'\t'}"; done < <(printf '%s\n' "${dup_rows[@]}" | LC_ALL=C sort)
fi
[ "$dup" -eq 0 ] && ok "저장소 전체에 빌드 타깃 파일명과 겹치는 사본 없음"

step step2-build "olean 삭제 후 전량 재빌드"
rm -rf .lake/build/lib/lean/CrisisFramework .lake/build/lib/lean/CrisisFramework.[oit]*
# 성공 경로에서는 완료 요약 한 줄만 낸다. 뒤 다섯 줄은 병렬 작업의 완료 순서를 따라 바뀌어
# OUTPUT_DIGEST 가 리포 상태의 함수가 아니게 된다(CF-674).
if lake build 2>&1 | tee /tmp/verify_build.log >/dev/null; then
  grep -m1 'Build completed successfully' /tmp/verify_build.log || true
  if grep -qE 'error|warning' /tmp/verify_build.log; then
    bad "빌드 로그에 error/warning 존재:"; grep -nE 'error|warning' /tmp/verify_build.log
  else
    jobs=$(grep -o 'Build completed successfully ([0-9]* jobs)' /tmp/verify_build.log | grep -o '[0-9]*')
    ok "lake build 전량 통과, error/warning 0 (${jobs:-?} job)"
  fi
else
  tail -5 /tmp/verify_build.log
  bad "lake build 실패"
fi

step step3-forbidden '금지 구문 정적 검사 (층별 `ℝ` 포함)'
# 주석·docstring 을 먼저 제거한다. 그러지 않으면 헤더에 적은
# "`sorry` 0" 같은 설명 문구가 스스로 걸린다 (실제로 발생했다).
# Lean 의 /- -/ 는 중첩 가능하므로 깊이를 세어 제거하고, -- 는 줄 끝까지 지운다.
#
# 사본을 한 벌만 만들고 뒤의 네 단계가 그것을 함께 읽는다. 단계마다 다시 만들면 같은
# 산출을 네 번 세우고 파일마다 파이썬을 새로 띄워 그 횟수가 대상 수의 네 배로 선다.
# 전량을 한 호출에서 처리하므로 기동 비용도 한 번으로 선다. 지우는 자리는 이 벌을
# 읽는 마지막 단계의 뒤다 (step9-propfree).
#
# 변이 검사와 논리 결합 변이는 이 벌을 쓰지 않는다. 그 둘은 자리 수를 보존해 공백으로
# 덮는 다른 꼴을 쓰고 원본의 자리 번호를 그대로 쓰기 때문이다.
STRIPPED=$(mktemp -d)
python3 scripts/vstep_forbidden.py "$STRIPPED" "${TARGETS[@]}"

check_absent() {  # 표시명, 정규식
  local name="$1" pat="$2" hits
  hits=$(cd "$STRIPPED" && grep -nE "$pat" "${TARGETS[@]}" 2>/dev/null)
  if [ -n "$hits" ]; then bad "코드에 금지 구문: $name"; printf '%s\n' "$hits" | sed 's/^/       /'
  else ok "코드에 없음: $name"; fi
}
check_absent 'sorry'          '\bsorry\b'
check_absent 'axiom 선언'      '^[[:space:]]*axiom[[:space:]]'
check_absent 'noncomputable'  '\bnoncomputable\b'
check_absent 'Classical'      '\bClassical\b'
check_absent 'admit/native_decide' '\b(admit|native_decide)\b'

# `ℝ` 금지는 층별로 갈린다. 동학층은 허용이고 나머지 넷은 금지다 (L-4).
# CLAUDE.md §2 의 표가 정본이며 디렉터리가 층을 결정한다.
real_hits=0
for t in "${TARGETS[@]}"; do
  case "$t" in
    CrisisFramework/Dynamics/*) continue ;;
  esac
  hits=$(cd "$STRIPPED" && grep -nE 'ℝ' "$t" 2>/dev/null)
  if [ -n "$hits" ]; then
    real_hits=1
    bad "층별 \`ℝ\` 금지 위반: $t"; printf '%s\n' "$hits" | sed 's/^/       /'
  fi
done
[ "$real_hits" -eq 0 ] && ok "\`ℝ\` 없음: 동학층 밖 대상 전량 (동학층은 검사 대상이 아니다)"

# 층별 기대 기준선과 모듈 탐색 환경의 변수 이름 집합을 docs/baseline.md 의 기계 판독
# 블록이 든다. 그 경로를 뒤의 두 단계가 함께 읽으므로 이 자리에서 한 번 정한다.
BASELINE_DOC=docs/baseline.md

step step11-leanenv '모듈 탐색 환경을 한 번 들여 빌드 도구가 세우던 것과 대조'
# 빌드 도구를 거쳐 Lean 을 부르면 그 호출마다 빌드 도구가 자기 명세를 다시 읽고 의존을 다시
# 해소하므로 그 고정비가 호출마다 선다. 뒤의 네 자리가 그 꼴로 Lean 을 불렀고 그 가운데 둘이
# 감사 대상의 수만큼 반복되므로, 그 환경을 이 자리에서 한 번 들여 뒤의 단계가 Lean 을 직접
# 부르게 한다. 전량 재빌드 단계의 호출은 빌드 산출을 낳는 자리여서 그대로 둔다.
#
# 들이는 것이 모듈 탐색 경로 하나가 아니라 그 환경 전량이다. 빌드 도구가 세우는 것이 그 경로
# 하나가 아니고 그 가운데 동적 라이브러리 경로와 소스 탐색 경로가 Lean 의 동작에 걸릴 수
# 있는데, 그 걸림은 빌드 산출이 선 판에서만 재어지므로 경로 하나만 세우는 길은 그 전제가
# 재어지지 않은 채 남는다. 환경 전량을 옮기면 빌드 도구가 세우던 것과 구조적으로 같다.
#
# 널 문자로 가른 꼴로 받는다. 줄 단위로 받으면 값에 줄바꿈이 든 변수가 그 자리에서 깨지고
# 그 깨짐이 조용히 지나간다. 이름이 식별자가 아닌 레코드는 들이지 않는다. 그 꼴이 러너의
# 환경에 서면 들이기가 실패하고 그 실패가 표준 오류로만 남는다.
le_now=$(mktemp); le_inner=$(mktemp)
env -0 > "$le_now"
if lake env printenv -0 > "$le_inner" 2>"$le_inner.err"; then
  :
else
  bad "빌드 도구의 환경 출력을 받지 못했다"; sed 's/^/       /' "$le_inner.err"
fi

# 축 첫째. 빌드 도구가 더하거나 바꾸는 변수의 이름 집합을 값 정본의 블록과 맞댄다. 그 집합이
# 늘면 Lean 의 동작에 걸리는 변수가 새로 섰을 수 있으므로 보고로 내고 실패시키지 않는다.
# 블록을 읽지 못한 것만 실패로 센다. 그 값은 이 검사가 처음 설 때 이 검사 자신이 낸 것으로
# 심으며, 그 집합이 빌드 도구의 판과 의존 묶음이 정하는 것이어서 환경마다 갈릴 수 있다.
while IFS=$'\t' read -r le_v le_m; do
  case "$le_v" in
    OK)     ok "$le_m" ;;
    FAIL)   bad "$le_m" ;;
    REPORT) rep "$le_m" ;;
  esac
done < <(python3 scripts/vstep_leanenv.py "$le_now" "$le_inner" "$BASELINE_DOC")

# 축 둘째. 같은 파일을 두 길로 돌려 종료 코드와 출력이 바이트로 같은지 잰다. 대상은 뒤의
# 단계가 이미 돌리는 층별 프로브이며, 이름의 집합만 보면 이름이 같은데 값의 뜻이 바뀐 자리를
# 놓치고 이 축만 보면 그 파일이 쓰지 않는 자리에 걸린 변수가 늘어도 재어지지 않는다.
#
# 받은 판의 꼴을 들이기 앞에서 잰다. 들인 환경 위에서 빌드 도구를 다시 부르면 그 도구가
# 자기 경로를 기존 값 앞에 다시 붙여 모듈 탐색 경로가 두 배로 서고, 그 중첩이 오류 메시지의
# 경로 목록을 늘려 두 길의 출력이 갈린다. 그 갈림은 환경이 다른 것이 아니라 한쪽이 중첩된
# 것이므로 이 순서가 아니면 이 축이 늘 실패한다.
le_a=$(lake env lean Scratch/VerifyBuilt.lean 2>&1); le_a_rc=$?

while IFS= read -r -d '' le_kv; do
  le_name=${le_kv%%=*}
  case "$le_name" in
    *[!A-Za-z0-9_]*|'') continue ;;
  esac
  export "$le_kv"
done < "$le_inner"
if [ -z "${LEAN:-}" ]; then
  bad "들인 환경이 Lean 바이너리의 경로를 들지 않는다"
  # 이 스크립트가 미정의 변수를 오류로 받으므로 뒤의 단계가 이 변수를 맨몸으로
  # 참조하면 셸이 그 자리에서 끝나고 그 끊김이 적발로 기록되지 않는다. 그래서 그
  # 참조마다 기본값을 두어 이 경로에서도 뒤의 단계가 돌아 실패를 남기게 한다.
else
  ok "Lean 을 직접 부를 경로를 들였다"
fi

le_c=$("${LEAN:-lean}" Scratch/VerifyBuilt.lean 2>&1); le_c_rc=$?
if [ "$le_a_rc" -eq "$le_c_rc" ] && [ "$le_a" = "$le_c" ]; then
  ok "두 길의 출력이 바이트로 같다 (종료 코드 $le_a_rc)"
else
  bad "두 길의 출력이 갈린다 — 들인 환경이 빌드 도구가 세우던 것과 다르다"
  diff <(printf '%s\n' "$le_a") <(printf '%s\n' "$le_c") | sed 's/^/       /' | head -20
fi
rm -f "$le_now" "$le_inner" "$le_inner.err"

step step4-baseline '공리 의존 + `docs/baseline.md` 기준선 차분'
# 층별 기대 기준선은 docs/baseline.md 의 기계 판독 블록이 든다. 값을 스크립트에
# 전사하면 문서를 고쳐도 검사가 낡은 값으로 돌기 때문이다 (baseline.md 머리말).
# 화이트리스트가 아니라 차분이다. 실효 기준선 자체는 매 실행마다
# Scratch/VerifyBuilt.lean 의 층별 프로브가 다시 찍는다.
#
# Lean 을 빌드 도구를 거치지 않고 직접 부른다. 그 환경은 step11-leanenv 가 한 번 들였다.
vb_out=$("${LEAN:-lean}" Scratch/VerifyBuilt.lean 2>&1); vb_rc=$?
printf '%s\n' "$vb_out" | sed 's/^/  /'
if [ "$vb_rc" -eq 0 ]; then ok "VerifyBuilt 통과 (DecidableEq 없이 적용됨)"
else bad "VerifyBuilt 실패"; fi

# 감사 대상 선언은 목록을 박지 않고 매 실행마다 훑어 잡는다. 박아 두면 새 선언이 그물 밖에
# 남고, `lakefile.toml` 의 glob 이 빌드는 하므로 그 사실이 빌드로 드러나지 않는다 (CF-595).
# 주석을 지운 뒤 줄머리의 inductive·structure·def·theorem·abbrev·instance 뒤 이름을 뽑고
# 그 자리에서 열려 있는 namespace 를 앞에 붙인다. example 은 이름이 없어 대상이 아니다.
# 뽑은 이름마다 `#print axioms` 한 줄을 내는 프로브 파일을 임시 디렉터리에 만들어 돌린다.
AUDIT=$(mktemp -d)
python3 scripts/vstep_declprobe.py "$AUDIT" "$STRIPPED" "${TARGETS[@]}"
pr_out=$("${LEAN:-lean}" "$AUDIT/Probe.lean" 2>&1); pr_rc=$?
printf '%s\n' "$pr_out" | sed 's/^/  /'
if [ "$pr_rc" -eq 0 ]; then ok "선언 감사 프로브 통과 (임시 파일, 선언 $(wc -l < "$AUDIT/decls.tsv"))"
else bad "선언 감사 프로브 실패"; fi
while IFS= read -r a; do
  [ -n "$a" ] && bad "이름 없는 instance 는 이름으로 감사할 수 없다: $a"
done < "$AUDIT/anon.txt"

# 층별 판정을 한 호출에 모은다. 받은 판은 선언마다 공리 목록을 셸에서 뽑고 기준선 차분을
# 파이썬으로 내므로 그 호출이 선언 수만큼 서며 그 수가 세 자리다. 공리 출력과 값 정본의
# 블록과 선언 목록을 한 번에 넘기면 전량이 한 호출에서 판정되고 셸은 그 판정 행을 읽어
# 찍는다. 그 꼴은 층별 수 타입 검사와 발동조건 문법 검사가 이미 쓰는 선례를 따른다.
# `#print axioms` 는 목록이 길면 줄바꿈해 출력하므로 공백을 접어서 대조하며 접는 자리도
# 그 호출 안이다.
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
printf '%s\n%s' "$vb_out" "$pr_out" > "$AUDIT/axioms.txt"
audit_out=$(python3 scripts/vstep_axiomdiff.py "$AUDIT/axioms.txt" "$BASELINE_DOC" "$AUDIT/decls.tsv")
AUDITED=0
AUDIT_DETAIL_S=
NONEMPTY=0
NE_DETAIL_S=
while IFS=$'\t' read -r kind a b c d; do
  case "$kind" in
    BASE_MISS)     bad "$BASELINE_DOC 의 기계 판독 블록에서 $a 를 읽지 못함 — 형식 확인 필요" ;;
    BASE_OK)       ok "기준선을 $BASELINE_DOC 에서 읽음: $a=$b" ;;
    PROBE_MISS)    bad "$a 기준선 프로브 출력을 찾지 못함 ($b) — Scratch/VerifyBuilt.lean 확인 필요" ;;
    PROBE_OK)      ok "$a 실효 기준선 실측 = $b (기대값과 일치)" ;;
    PROBE_DIFF)    bad "$a 실효 기준선이 기대값과 다름: 측정 $b / 기대 $c — docs/baseline.md 의 갱신은 사람의 결정" ;;
    DECL_MISS)     bad "$a: 공리 출력을 찾지 못함" ;;
    DECL_SAME)     ok "$a: $b (기준선과 동일)" ;;
    DECL_UNDER)    ok "$a: $b (기준선 이하)" ;;
    DECL_EXCESS)   bad "$a: 기준선 초과 — $b / 기준선 $c / 초과분 $d. 어느 보조정리에서 유입됐는지 추적할 것 (CLAUDE.md §5-2)" ;;
    NONEMPTY)      rep "$a 공리 출력이 비어 있지 않은 선언 $b / $c" ;;
    NONEMPTY_ITEM) printf '       %s\n' "$a" ;;
    LAYER_UNKNOWN) bad "층 기준선이 정해지지 않은 자리의 선언: $a 의 $b" ;;
    TOTAL)         AUDITED=$a; AUDIT_DETAIL_S=$b ;;
    NE_TOTAL)      NONEMPTY=$a; NE_DETAIL_S=$b ;;
  esac
done <<< "$audit_out"
rm -rf "$AUDIT"

ok "공리 감사 대상 선언 $AUDITED ($AUDIT_DETAIL_S)"
rep "공리 출력이 비어 있지 않은 선언 $NONEMPTY / $AUDITED ($NE_DETAIL_S). 실패시키지 않는다"

step step8-layertype '층별 수 타입 정적 검사 (L-10)'
# CLAUDE.md §2 의 층별 금지 표를 주석을 지운 코드에서 대조한다. 디렉터리가 층을 결정한다.
# 정의층의 ℕ·Nat 은 L-13 의 명시적 예외라 잡지 않는다. ℝ 기호는 네 층 전부에서 step3-forbidden
# 이 보므로 여기서 다시 세지 않는다. L-4 가 invariant 로 그 단계에 걸려 있기 때문이다. 다만 영문명
# Real 은 step3 가 기호만 보므로 여기서 잡는다. 회계층의 ℚ·Rat 은 L-15 의 판정이 docstring 의
# 사유를 읽어야 서므로 실패가 아니라 보고로 낸다.
lt_out=$(python3 scripts/vstep_layertype.py "$STRIPPED" "${TARGETS[@]}")
declare -A lt_fail=() lt_rep=()
while IFS=$'\t' read -r kind layer where what line; do
  case "$kind" in
    FAIL)   bad "금지 수 타입·수치 리터럴 ($layer): $where ($what)"; printf '       %s\n' "$line"
            lt_fail[$layer]=$(( ${lt_fail[$layer]:-0} + 1 )) ;;
    REPORT) rep "ℚ·Rat 사용 ($layer): $where ($what). L-15 의 사유가 docstring 에 적혀 있는지 사람이 확인한다"
            printf '       %s\n' "$line"
            lt_rep[$layer]=$(( ${lt_rep[$layer]:-0} + 1 )) ;;
  esac
done <<< "$lt_out"
while IFS=$'\t' read -r kind layer n; do
  case "$kind" in
    SCAN)
      if [ "$layer" = 회계층 ]; then ok "$layer: 파일 $n · ℚ·Rat 보고 ${lt_rep[$layer]:-0}줄"
      elif [ -z "${lt_fail[$layer]:-}" ]; then ok "$layer: 파일 $n · 금지 수 타입·수치 리터럴 없음"; fi ;;
    OTHER) ok "대상 밖 파일 $layer (동학층과 층 디렉터리 밖)" ;;
  esac
done <<< "$lt_out"

step step9-propfree '발동조건 문법의 `Prop` 금지 (C-10)'
# 정의층의 structure 필드와 inductive 생성자는 타입 서명에 Prop 를 담지 않는다. 자료 구조에서
# Prop 를 몰아내면 발동조건의 의미가 Bool 반환 계산 함수로 선다는 요구가 타입으로 선다.
# 최상위 def·abbrev·theorem 의 서명은 대상이 아니다. 구조에 들어가지 않는 보조 술어는
# 발동조건의 판정 경로에 있지 않기 때문이다. 필드와 생성자는 선언 머리의 where 뒤에 선다.
mapfile -t DEF_TARGETS < <(printf '%s\n' "${TARGETS[@]}" | grep '^CrisisFramework/Definition/')
pf_out=$(python3 scripts/vstep_propfree.py "$STRIPPED" "${DEF_TARGETS[@]}")
rm -rf "$STRIPPED"
pf_bad=0
while IFS=$'\t' read -r kind a b c; do
  case "$kind" in
    FAIL) pf_bad=1; bad "Prop 를 담은 $b: $a"; printf '       %s\n' "$c" ;;
    SCAN) [ "$pf_bad" -eq 0 ] && ok "정의층 파일 $a · structure $b · inductive $c 의 필드와 생성자에 Prop 없음" ;;
  esac
done <<< "$pf_out"

step step5-mutation "변이 검사"
# 대상은 CrisisFramework 아래 .lean 전량에서 훑어 잡는 최상위 theorem 과 example 이며 계수를 박지 않는다.
# 목록을 박아 두면 새 진술이 그물 밖에 남는다 (CF-595). 결론의 모양을 가리지 않고 결론 전체를 ¬ ( ) 로
# 감싼 사본을 만든다 (CF-675). 변이 사본은 파일별로 임시 디렉터리에 만들어 원본을 건드리지 않고 돌린 뒤 지운다.
mut_dir=$(mktemp -d)
mut_list="$mut_dir/targets.tsv"
python3 scripts/vstep_mutation.py "$mut_dir" "${TARGETS[@]}" > "$mut_list"
mapfile -t mut_rows < "$mut_list"
# 구문 오류의 머리 목록. 사본을 일부러 깨뜨려 Lean 이 내는 머리를 모은 것이다 (CF-681).
# 한 가지 머리로만 가르면 그 밖의 머리로 깨진 사본이 거부로 세어지고, 그 진술의 검사가
# 수행되지 않았는데도 통과로 보고된다. 거부가 아니라 실패로 세는 까닭이 그것이다.
mut_syntax_re='error: (unexpected|unterminated comment|unterminated string literal|expected token|Invalid `end`)'
if [ "${#mut_rows[@]}" -eq 0 ]; then
  ok "변이 대상 0 — CrisisFramework 아래에 최상위 theorem 과 example 이 없다"
else
  per_file=$(cut -f2 "$mut_list" | uniq -c | awk '{printf "%s%s %s", (NR>1?" · ":""), $2, $1}')
  ok "변이 대상 ${#mut_rows[@]} ($per_file)"
  rep "구문 오류로 세는 머리: unexpected · unterminated comment · unterminated string literal · expected token · Invalid \`end\`"
  # 사본마다 elaborate 를 따로 돌린다. 판정은 아래에서 원래 순서대로 하므로 병렬이 출력을 바꾸지 않는다.
  # 결론을 잡지 못한 행은 사본을 갖지 않고 그 자리에 자리표를 드므로 그 행을 걸러 넘긴다. 자리로만
  # 잘라 넘기면 그 자리표가 경로로 서서 호출이 돌고 그 실패가 어느 판정에도 들지 않는다.
  awk -F'\t' '$1 == "MUT" { print $4 }' "$mut_list" \
    | xargs -P "$LEAN_JOBS" -I{} sh -c '"${LEAN:-lean}" "$1" > "$1.out" 2>&1; echo $? > "$1.rc"' _ {}
  for row in "${mut_rows[@]}"; do
    IFS=$'\t' read -r m_kind m_file m_line m_copy m_concl <<< "$row"
    if [ "$m_kind" = NOCONCL ]; then
      bad "$m_file:$m_line $m_concl 의 결론을 잡지 못해 그 진술의 변이 검사가 수행되지 않았다"
      continue
    fi
    if [ "$(cat "$m_copy.rc")" = 0 ]; then
      bad "$m_file:$m_line 변이가 통과함 — 해당 진술은 공허한 검사다: $m_concl"
    elif grep -qE "$mut_syntax_re" "$m_copy.out"; then
      # 사본이 깨진 것을 거부로 세면 그 진술의 검사가 공허해지는데도 통과로 보고된다.
      m_head=$(grep -oE "$mut_syntax_re" "$m_copy.out" | head -1)
      bad "$m_file:$m_line 변이 사본이 구문 오류로 깨져 그 진술의 검사가 수행되지 않았다 ($m_head): $m_concl"
    else
      ok "$m_file:$m_line 변이 거부됨 ($(grep -cE 'error' "$m_copy.out") error) — 실검사 확인"
    fi
  done
fi
rm -rf "$mut_dir"

step step10-clausemut "논리 결합 변이 — 판정 반환 함수의 증거가 덮는 범위"
# 결론을 부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지
# 않는다. 두 인자가 함께 참인 증거와 함께 거짓인 증거만 두면 곱과 합의 값이 그 둘에서 같으므로
# 그 결합을 뒤집은 변이가 통과한다(A-8). 그래서 정의층과 관측층의 판정 반환 함수 본문에서 논리
# 결합을 하나씩 뒤집은 사본을 만들어 그 사본이 elaborate 에 성공하는 자리를 센다.
#
# 판정 반환 함수는 결과 타입이 `Bool` 인 최상위 def 다. 판정을 `Bool` 반환 계산 함수로 준다는
# 규율(C-10)이 그 부류를 정하므로, 구조체나 답할 항을 내는 def 는 그 안에 결합이 있어도 대상이
# 아니다. 뒤집는 것은 본문의 `&&` 와 `||` 를 서로 바꾸는 것과 `decide` 안의 `∧` 와 `∨` 를 서로
# 바꾸는 것이며, 한 사본에 한 자리만 바꾼다. 바꾼 문면은 그대로 다시 읽히므로 결합의 우선순위가
# 그 사본의 뜻을 정한다. 대상은 그 두 층의 파일 전량에서 훑어 잡고 계수를 박지 않는다.
#
# 사본은 그 파일 하나만 elaborate 하고 전량 빌드하지 않는다. 그 함수를 다른 파일의 정리가 쓰더라도
# 그 파일은 원본의 olean 을 읽으므로 그 정리는 이 단계의 증거가 아니다. 사본이 통과한 자리는
# 실패시키지 않고 보고하며, 그 계수를 docs/baseline.md 의 블록과 맞대어 늘었을 때만 실패시킨다.
# 뒤집은 함수 자신의 범위에서 오류가 나거나 구문 오류로 깨지면 그 사본은 결합을 재지 못한 것이므로
# 거부로 세지 않고 실패로 센다. 사본은 임시 디렉터리에 만들고 돈 뒤에 지운다.
cm_dir=$(mktemp -d)
cm_list="$cm_dir/targets.tsv"
mapfile -t CM_FILES < <(printf '%s\n' "${TARGETS[@]}" | grep -E '^CrisisFramework/(Definition|Observation)/')
python3 scripts/vstep_clausemut.py "$cm_dir" "${CM_FILES[@]}" > "$cm_list"
mapfile -t cm_rows < "$cm_list"
cm_cap=$(sed -n '/<!-- CLAUSEMUT:BEGIN -->/,/<!-- CLAUSEMUT:END -->/p' "$BASELINE_DOC" \
  | grep -oE '^CLAUSEMUT_UNCOVERED=[0-9]+$' | cut -d= -f2)
if [ -z "$cm_cap" ]; then
  bad "$BASELINE_DOC 의 CLAUSEMUT 블록에서 CLAUSEMUT_UNCOVERED 를 읽지 못했다"
fi
if [ "${#cm_rows[@]}" -eq 0 ]; then
  bad "변이 대상 0 — 정의층과 관측층에서 판정 반환 함수의 논리 결합을 하나도 잡지 못했다"
else
  per_file=$(cut -f1 "$cm_list" | uniq -c | awk '{printf "%s%s %s", (NR>1?" · ":""), $2, $1}')
  ok "변이 대상 ${#cm_rows[@]} ($per_file)"
  # 사본마다 elaborate 를 따로 돌린다. 판정은 아래에서 원래 순서대로 하므로 병렬이 출력을 바꾸지 않는다.
  cut -f8 "$cm_list" | xargs -P "$LEAN_JOBS" -I{} sh -c '"${LEAN:-lean}" "$1" > "$1.out" 2>&1; echo $? > "$1.rc"' _ {}
  cm_uncovered=0
  for row in "${cm_rows[@]}"; do
    IFS=$'\t' read -r c_file c_line c_name c_from c_to c_first c_last c_copy <<< "$row"
    c_where="$c_file:$c_line $c_name 의 \`$c_from\` → \`$c_to\`"
    if [ "$(cat "$c_copy.rc")" = 0 ] && ! grep -q 'error' "$c_copy.out"; then
      cm_uncovered=$((cm_uncovered + 1))
      rep "$c_where 변이가 통과함 — 그 결합을 가리는 증거가 그 파일에 없다"
    elif grep -qE "$mut_syntax_re" "$c_copy.out"; then
      bad "$c_where 사본이 구문 오류로 깨져 그 결합이 재어지지 않았다 ($(grep -oE "$mut_syntax_re" "$c_copy.out" | head -1))"
    elif grep -oE 'Mutant\.lean:[0-9]+:[0-9]+: error' "$c_copy.out" | cut -d: -f2 \
         | awk -v a="$c_first" -v b="$c_last" '$1 >= a && $1 <= b {f=1} END {exit !f}'; then
      bad "$c_where 사본이 그 함수 자신에서 깨져 그 결합이 재어지지 않았다"
    else
      ok "$c_where 변이 거부됨 ($(grep -cE 'error' "$c_copy.out") error) — 증거가 그 결합을 가린다"
    fi
  done
  if [ -n "$cm_cap" ]; then
    if [ "$cm_uncovered" -gt "$cm_cap" ]; then
      bad "통과한 변이 $cm_uncovered 가 CLAUSEMUT_UNCOVERED=$cm_cap 보다 많다 — 증거 없이 결합이 새로 섰다"
    elif [ "$cm_uncovered" -lt "$cm_cap" ]; then
      rep "통과한 변이 $cm_uncovered 가 CLAUSEMUT_UNCOVERED=$cm_cap 보다 $((cm_cap - cm_uncovered)) 적다 — 그 결합을 가리는 증거가 섰다"
    else
      ok "통과한 변이 $cm_uncovered / ${#cm_rows[@]} — CLAUSEMUT_UNCOVERED=$cm_cap 과 같다"
    fi
  fi
fi
rm -rf "$cm_dir"

# 첫 인자를 아크 이름으로 읽어 원장 검증기에 `--arc-close` 로 넘긴다. 주지 않으면 그 인자
# 없이 부르므로 호출이 글자대로 그대로다. 아크를 닫는 커밋이 한 아크에서 가장 무거운 커밋인데,
# 그것을 가르는 검사 셋의 판정이 이 출력 밖에서만 돌 수 있었다(W-3). 단계 id 는 바꾸지 않는다.
arc_close_args=()
[ -n "${1:-}" ] && arc_close_args=(--arc-close "$1")

step step6-ledger '`check_wiki.py` 호출'
if python3 scripts/check_wiki.py "${arc_close_args[@]}"; then
  ok "원장 검증 전량 통과"
else
  bad "원장 검증 실패 — 위 [check:*] 줄이 어느 검사인지 든다 (SPEC.md §2)"
fi

step step7-cqfin 'CQ 고정 절 대조'
if python3 scripts/check_cqfin.py; then
  ok "CQ 고정 절과 관측층 선언이 일치한다"
else
  bad "CQ 고정 절과 관측층 선언이 어긋난다 — docs/baseline.md §6"
fi

step_elapsed
printf '\n'
if [ "$fail" -eq 0 ]; then printf '\033[1;32m전량 통과\033[0m\n'; else printf '\033[1;31m검증 실패 항목 있음\033[0m\n'; fi
exit "$fail"
