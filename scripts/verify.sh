#!/usr/bin/env bash
# 재현 가능한 전량 검증 스크립트.
#
#   1. 빌드 타깃 밖 중복 사본 탐지 (검증된 파일 ≠ 손에 든 파일 사고 방지)
#   2. 프로젝트 olean 강제 삭제 후 lake build (디스크 내용 기준 재검증)
#   3. 금지 구문 정적 검사 (sorry / axiom / noncomputable / Classical / ℝ)
#   4. olean 기준 공리 의존 출력 + 회계층 기준선 차분 (기대값 대조)
#   5. 변이 검사 — 정리·example 5개 진술을 하나씩 뒤집어 반드시 실패함을 확인
#
# 실행: bash scripts/verify.sh
set -uo pipefail

export PATH=/root/.elan/bin:$PATH
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

TARGETS=(
  CrisisFramework/Glossary/Core.lean
  CrisisFramework/Definition/Constraint.lean
  CrisisFramework/Accounting/Aggregation.lean
)
AGG=CrisisFramework/Accounting/Aggregation.lean

fail=0
step() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok()   { printf '  \033[32mOK\033[0m   %s\n' "$*"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$*"; fail=1; }

step "1. 빌드 타깃 밖 중복 사본 탐지"
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

step "2. 프로젝트 olean 삭제 후 전량 재빌드"
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

step "3. 금지 구문 정적 검사 (주석 제외)"
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
check_absent 'ℝ (L-4)'        'ℝ'
check_absent 'admit/native_decide' '\b(admit|native_decide)\b'
rm -rf "$CODE"

step "4. olean 기준 공리 의존 + 회계층 기준선 차분"
# 회계층 기대 기준선 — 2026-09-12 `ℚ → ℤ` 이행 시점에 실측한 값.
#   갱신 전 (ℚ 회계층): [propext, Classical.choice, Quot.sound]
#   갱신 후 (ℤ 회계층): [propext, Quot.sound]
# 화이트리스트가 아니라 차분이다. 기준선 자체는 매 실행마다
# Scratch/VerifyBuilt.lean 의 baselineProbe / baselineProbeSum 이 다시 찍는다.
# Finset 합을 쓰는 baselineProbeSum 쪽이 실효 기준선이다.
BASELINE='[propext, Quot.sound]'

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
  bad "실효 기준선이 기대값과 다름: 측정 $measured / 기대 $BASELINE — 스크립트의 BASELINE 갱신은 사람의 결정"
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

step "5. 변이 검사 (진술 5개, 각각 뒤집으면 실패해야 함)"
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

printf '\n'
if [ "$fail" -eq 0 ]; then printf '\033[1;32m전량 통과\033[0m\n'; else printf '\033[1;31m검증 실패 항목 있음\033[0m\n'; fi
exit "$fail"
