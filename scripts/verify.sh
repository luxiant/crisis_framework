#!/usr/bin/env bash
# 재현 가능한 전량 검증 스크립트.
#
#   step1-duplicate  빌드 타깃 밖 중복 사본 탐지 (검증된 파일 ≠ 손에 든 파일 사고 방지)
#   step2-build      프로젝트 olean 강제 삭제 후 lake build (디스크 내용 기준 재검증)
#   step3-forbidden  금지 구문 정적 검사 (sorry / axiom / noncomputable / Classical / 층별 ℝ)
#   step4-baseline   olean 기준 공리 의존 출력 + docs/baseline.md 기준선 차분
#   step5-mutation   변이 검사 — 정리·example 5개 진술을 하나씩 뒤집어 반드시 실패함을 확인
#   step6-ledger     원장 검증기 check_wiki.py 호출 (SPEC.md §2 의 검사 서른)
#                    아크 종료 검사 셋은 `--arc-close` 를 주지 않으므로 여기서 돌지 않는다
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
AGG=CrisisFramework/Accounting/Aggregation.lean

fail=0
step() { printf '\n\033[1m== %s\033[0m\n' "$*"; printf '[step:%s]\n' "$1"; }
ok()   { printf '  \033[32mOK\033[0m   %s\n' "$*"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$*"; fail=1; }

step step1-duplicate "빌드 타깃 밖 중복 사본 탐지"
# 저장소 전체를 훑는다. crisis-framework/ 안만 보면 상위 디렉터리에 놓인
# 낡은 초안 사본을 놓친다 (1차 검증 직후 실제로 발생한 사고).
SCAN="$(git rev-parse --show-toplevel 2>/dev/null || echo "$ROOT")"
dup=0
for t in "${TARGETS[@]}"; do
  base=$(basename "$t")
  abs="$ROOT/$t"
  while IFS= read -r other; do
    [ "$(readlink -f "$other")" = "$(readlink -f "$abs")" ] && continue
    dup=1
    rel=${other#"$SCAN"/}
    if diff -q "$other" "$abs" >/dev/null 2>&1; then
      bad "중복 사본(내용 동일, 그래도 혼동 위험): $rel  ↔  $t"
    else
      bad "중복 사본(내용 다름 — 위험): $rel  ↔  $t"
    fi
  done < <(find "$SCAN" -name "$base" -not -path '*/.lake/*' -not -path '*/.git/*')
done
[ "$dup" -eq 0 ] && ok "저장소 전체에 빌드 타깃 파일명과 겹치는 사본 없음"

step step2-build "olean 삭제 후 전량 재빌드"
rm -rf .lake/build/lib/lean/CrisisFramework .lake/build/lib/lean/CrisisFramework.[oit]*
if lake build 2>&1 | tee /tmp/verify_build.log | tail -5; then
  if grep -qE 'error|warning' /tmp/verify_build.log; then
    bad "빌드 로그에 error/warning 존재:"; grep -nE 'error|warning' /tmp/verify_build.log
  else
    jobs=$(grep -o 'Build completed successfully ([0-9]* jobs)' /tmp/verify_build.log | grep -o '[0-9]*')
    ok "lake build 전량 통과, error/warning 0 (${jobs:-?} job)"
  fi
else
  bad "lake build 실패"
fi

step step3-forbidden '금지 구문 정적 검사 (층별 `ℝ` 포함)'
# 주석·docstring 을 먼저 제거한다. 그러지 않으면 헤더에 적은
# "`sorry` 0" 같은 설명 문구가 스스로 걸린다 (실제로 발생했다).
# Lean 의 /- -/ 는 중첩 가능하므로 깊이를 세어 제거하고, -- 는 줄 끝까지 지운다.
strip_comments() {
  python3 - "$1" <<'PYEOF'
import sys
src = open(sys.argv[1], encoding='utf-8').read()
out, i, depth, n = [], 0, 0, len(src)
while i < n:
    if src.startswith('/-', i):
        depth += 1; i += 2; continue
    if src.startswith('-/', i) and depth:
        depth -= 1; i += 2; continue
    if depth:
        out.append('\n' if src[i] == '\n' else ' '); i += 1; continue
    if src.startswith('--', i):
        j = src.find('\n', i); i = n if j < 0 else j; continue
    out.append(src[i]); i += 1
sys.stdout.write(''.join(out))
PYEOF
}

CODE=$(mktemp -d)
for t in "${TARGETS[@]}"; do
  mkdir -p "$CODE/$(dirname "$t")"
  strip_comments "$t" > "$CODE/$t"
done

check_absent() {  # 표시명, 정규식
  local name="$1" pat="$2" hits
  hits=$(cd "$CODE" && grep -nE "$pat" "${TARGETS[@]}" 2>/dev/null)
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
  hits=$(cd "$CODE" && grep -nE 'ℝ' "$t" 2>/dev/null)
  if [ -n "$hits" ]; then
    real_hits=1
    bad "층별 \`ℝ\` 금지 위반: $t"; printf '%s\n' "$hits" | sed 's/^/       /'
  fi
done
[ "$real_hits" -eq 0 ] && ok "\`ℝ\` 없음: 동학층 밖 대상 전량 (동학층은 검사 대상이 아니다)"
rm -rf "$CODE"

step step4-baseline '공리 의존 + `docs/baseline.md` 기준선 차분'
# 회계층 기대 기준선은 docs/baseline.md 의 기계 판독 블록이 든다. 값을 스크립트에
# 전사하면 문서를 고쳐도 검사가 낡은 값으로 돌기 때문이다 (baseline.md 머리말).
# 화이트리스트가 아니라 차분이다. 기준선 자체는 매 실행마다
# Scratch/VerifyBuilt.lean 의 baselineProbe / baselineProbeSum 이 다시 찍는다.
# Finset 합을 쓰는 baselineProbeSum 쪽이 실효 기준선이다.
BASELINE_DOC=docs/baseline.md
BASELINE=$(sed -n '/<!-- BASELINE:BEGIN -->/,/<!-- BASELINE:END -->/p' "$BASELINE_DOC" \
           | sed -n 's/^ACCOUNTING_INT=//p')
if [ -z "$BASELINE" ]; then
  bad "$BASELINE_DOC 의 기계 판독 블록에서 ACCOUNTING_INT 를 읽지 못함 — 형식 확인 필요"
  BASELINE='(읽지 못함)'
else
  ok "기준선을 $BASELINE_DOC 에서 읽음: ACCOUNTING_INT=$BASELINE"
fi

vb_out=$(lake env lean Scratch/VerifyBuilt.lean 2>&1); vb_rc=$?
printf '%s\n' "$vb_out" | sed 's/^/  /'
if [ "$vb_rc" -eq 0 ]; then ok "VerifyBuilt 통과 (DecidableEq 없이 적용됨)"
else bad "VerifyBuilt 실패"; fi

# `#print axioms` 는 목록이 길면 줄바꿈해 출력하므로 공백을 접어서 대조한다.
norm=$(printf '%s' "$vb_out" | python3 -c "import sys,re;print(re.sub(r'\s+',' ',sys.stdin.read()))")

measured=$(printf '%s' "$norm" | grep -o "'baselineProbeSum' depends on axioms: \[[^]]*\]" | sed "s/.*axioms: //")
if [ -z "$measured" ]; then
  bad "기준선 프로브 출력을 찾지 못함 — Scratch/VerifyBuilt.lean 확인 필요"
elif [ "$measured" = "$BASELINE" ]; then
  ok "실효 기준선 실측 = $measured (기대값과 일치)"
else
  bad "실효 기준선이 기대값과 다름: 측정 $measured / 기대 $BASELINE — docs/baseline.md 의 갱신은 사람의 결정"
fi

for c in creditSupply aggregationError two_mul_aggregationError_eq_pairwise \
         aggregationError_eq_zero_of_constant_cap aggregationError_eq_zero_of_constant_equity; do
  got=$(printf '%s' "$norm" | grep -o "'CrisisFramework.Accounting.$c' depends on axioms: \[[^]]*\]" | sed "s/.*axioms: //")
  if [ -z "$got" ]; then
    if printf '%s' "$norm" | grep -q "'CrisisFramework.Accounting.$c' does not depend on any axioms"; then
      ok "$c: 무의존 (기준선 이하)"
    else
      bad "$c: 공리 출력을 찾지 못함"
    fi
  elif [ "$got" = "$BASELINE" ]; then
    ok "$c: $got (기준선과 동일)"
  else
    bad "$c: 기준선 초과 — $got / 기준선 $BASELINE. 어느 보조정리에서 유입됐는지 추적할 것 (CLAUDE.md §5-2)"
  fi
done
AUDITED=5
AUDIT_DETAIL="회계층 5"

# 용어집 넷과 정의층 여섯을 각 층의 실효 기준선과 차분한다 (A-6). 회계층만 보던
# 그물을 선언 열다섯 전량으로 넓힌 자리다. 각 층의 기준선은 docs/baseline.md 의
# 기계 판독 블록이 들고, 실효 기준선 자체는 그 층의 프로브가 매 실행마다 다시 찍는다.

# 이름 하나의 공리 목록을 낸다. 무의존이면 [] 를 내고 찾지 못하면 빈 문자열을 낸다.
axioms_of() {
  local n=$1 g
  g=$(printf '%s' "$norm" | grep -o "'$n' depends on axioms: \[[^]]*\]" | sed "s/.*axioms: //")
  if [ -n "$g" ]; then printf '%s' "$g"; return; fi
  if printf '%s' "$norm" | grep -q "'$n' does not depend on any axioms"; then printf '[]'; return; fi
  printf ''
}

# 기준선을 넘은 공리만 낸다. 부분집합 대조이므로 기준선 이하도 통과시킨다.
excess_of() {
  python3 -c "
import sys
def p(s): return set(t.strip() for t in s.strip().strip('[]').split(',') if t.strip())
ex=sorted(p(sys.argv[1])-p(sys.argv[2]))
print('['+', '.join(ex)+']' if ex else '[]')
" "$1" "$2"
}

audit_layer() {
  local label=$1 key=$2 probe=$3; shift 3
  local base measured c got ex n=0
  base=$(sed -n '/<!-- BASELINE:BEGIN -->/,/<!-- BASELINE:END -->/p' "$BASELINE_DOC" \
         | sed -n "s/^$key=//p")
  if [ -z "$base" ]; then
    bad "$BASELINE_DOC 의 기계 판독 블록에서 $key 를 읽지 못함 — 형식 확인 필요"
    AUDIT_DETAIL="$AUDIT_DETAIL · $label 0"
    return
  fi
  ok "기준선을 $BASELINE_DOC 에서 읽음: $key=$base"
  measured=$(axioms_of "$probe")
  if [ -z "$measured" ]; then
    bad "$label 기준선 프로브 출력을 찾지 못함 ($probe) — Scratch/VerifyBuilt.lean 확인 필요"
  elif [ "$measured" = "$base" ]; then
    ok "$label 실효 기준선 실측 = $measured (기대값과 일치)"
  else
    bad "$label 실효 기준선이 기대값과 다름: 측정 $measured / 기대 $base — docs/baseline.md 의 갱신은 사람의 결정"
  fi
  for c in "$@"; do
    got=$(axioms_of "$c")
    AUDITED=$((AUDITED + 1)); n=$((n + 1))
    if [ -z "$got" ]; then
      bad "$c: 공리 출력을 찾지 못함"
      continue
    fi
    ex=$(excess_of "$got" "$base")
    if [ "$ex" = "[]" ]; then
      if [ "$got" = "$base" ]; then ok "$c: $got (기준선과 동일)"
      else ok "$c: $got (기준선 이하)"; fi
    else
      bad "$c: 기준선 초과 — $got / 기준선 $base / 초과분 $ex. 어느 보조정리에서 유입됐는지 추적할 것 (CLAUDE.md §5-2)"
    fi
  done
  AUDIT_DETAIL="$AUDIT_DETAIL · $label $n"
}

audit_layer 용어집 GLOSSARY glossaryProbeList \
  CrisisFramework.Glossary.Concept \
  CrisisFramework.Glossary.SourceTag \
  CrisisFramework.Glossary.ConceptRel \
  CrisisFramework.Glossary.registry

audit_layer 정의층 DEFINITION definitionProbeFamily \
  CrisisFramework.Definition.Constraint \
  CrisisFramework.Definition.Constraint.trivial \
  CrisisFramework.Definition.NodeState \
  CrisisFramework.Definition.NodeState.trivial \
  CrisisFramework.Definition.NodeFamily \
  CrisisFramework.Definition.NodeFamily.empty

audit_layer 관측층 OBSERVATION observationProbeProd \
  CrisisFramework.Observation.UndeterminedReason \
  CrisisFramework.Observation.ObservedTruth \
  CrisisFramework.Observation.ObservedValue \
  CrisisFramework.Observation.PaymentMethodShareChange \
  CrisisFramework.Observation.RepaymentOutcome \
  CrisisFramework.Observation.CQ.TradePaymentComposition \
  CrisisFramework.Observation.CQ.TradePaymentComposition.trivial \
  CrisisFramework.Observation.CQ.TradeFinanceCurrency \
  CrisisFramework.Observation.CQ.TradeFinanceCurrency.trivial \
  CrisisFramework.Observation.CQ.SanctionTextCut \
  CrisisFramework.Observation.CQ.SanctionTextCut.trivial \
  CrisisFramework.Observation.CQ.DebtCapacityCollateralDependence \
  CrisisFramework.Observation.CQ.DebtCapacityCollateralDependence.trivial \
  CrisisFramework.Observation.CQ.ClaimsByHolderConstraintKind \
  CrisisFramework.Observation.CQ.ClaimsByHolderConstraintKind.trivial \
  CrisisFramework.Observation.CQ.SwapLineReach \
  CrisisFramework.Observation.CQ.SwapLineReach.trivial \
  CrisisFramework.Observation.CQ.ClaimsByDecisionUnit \
  CrisisFramework.Observation.CQ.ClaimsByDecisionUnit.trivial \
  CrisisFramework.Observation.CQ.MonetaryHierarchyOrder \
  CrisisFramework.Observation.CQ.MonetaryHierarchyOrder.trivial \
  CrisisFramework.Observation.CQ.RepaymentAndAdjustment \
  CrisisFramework.Observation.CQ.RepaymentAndAdjustment.trivial \
  CrisisFramework.Observation.CQ.PledgedClaimsAndStock \
  CrisisFramework.Observation.CQ.PledgedClaimsAndStock.trivial \
  CrisisFramework.Observation.CQ.ClaimsOnMismatchedDebtors \
  CrisisFramework.Observation.CQ.ClaimsOnMismatchedDebtors.trivial

ok "공리 감사 대상 선언 $AUDITED ($AUDIT_DETAIL)"

step step5-mutation "변이 검사"
mapfile -t anchors < <(grep -nE '(≠|=) 0 := by' "$AGG" | cut -d: -f1)
if [ "${#anchors[@]}" -ne 5 ]; then
  bad "변이 대상 5개를 기대했으나 ${#anchors[@]}개 발견 — 스크립트 갱신 필요"
else
  tmp=$(mktemp -d)
  for ln in "${anchors[@]}"; do
    src=$(sed -n "${ln}p" "$AGG")
    if printf '%s' "$src" | grep -q '≠ 0 := by'; then
      mut=$(printf '%s' "$src" | sed 's/≠ 0 := by/= 0 := by/')
    else
      mut=$(printf '%s' "$src" | sed 's/= 0 := by/≠ 0 := by/')
    fi
    awk -v n="$ln" -v r="$mut" 'NR==n{print r; next}{print}' "$AGG" > "$tmp/Mutant.lean"
    if lake env lean "$tmp/Mutant.lean" >"$tmp/out.$ln" 2>&1; then
      bad "L${ln} 변이가 통과함 — 해당 진술은 공허한 검사다: ${src## }"
    else
      ok "L${ln} 변이 거부됨 ($(grep -cE 'error' "$tmp/out.$ln") error) — 실검사 확인"
    fi
  done
  rm -rf "$tmp"
fi

step step6-ledger '`check_wiki.py` 호출'
if python3 scripts/check_wiki.py; then
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

printf '\n'
if [ "$fail" -eq 0 ]; then printf '\033[1;32m전량 통과\033[0m\n'; else printf '\033[1;31m검증 실패 항목 있음\033[0m\n'; fi
exit "$fail"
