#!/usr/bin/env bash
# 재현 가능한 전량 검증 스크립트.
#
#   step1-duplicate  빌드 타깃 밖 중복 사본 탐지 (검증된 파일 ≠ 손에 든 파일 사고 방지)
#   step2-build      프로젝트 olean 강제 삭제 후 lake build (디스크 내용 기준 재검증)
#   step3-forbidden  금지 구문 정적 검사 (sorry / axiom / noncomputable / Classical / 층별 ℝ)
#   step4-baseline   olean 기준 공리 의존 출력 + docs/baseline.md 기준선 차분
#                    감사 대상 선언은 매 실행마다 훑어 잡아 임시 프로브 파일로 찍는다
#   step8-layertype  층별 수 타입 정적 검사 (CLAUDE.md §2 의 층별 금지 표)
#   step9-propfree   정의층 structure 필드와 inductive 생성자의 Prop 금지
#   step5-mutation   변이 검사 — 결론이 `= 0`·`≠ 0` 인 진술을 하나씩 뒤집어 반드시 실패함을 확인
#                    대상은 CrisisFramework 아래 .lean 전량에서 훑어 잡는다
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

fail=0
step() { printf '\n\033[1m== %s\033[0m\n' "$*"; printf '[step:%s]\n' "$1"; }
ok()   { printf '  \033[32mOK\033[0m   %s\n' "$*"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$*"; fail=1; }
rep()  { printf '  \033[36mREPORT\033[0m %s\n' "$*"; }

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
# 층별 기대 기준선은 docs/baseline.md 의 기계 판독 블록이 든다. 값을 스크립트에
# 전사하면 문서를 고쳐도 검사가 낡은 값으로 돌기 때문이다 (baseline.md 머리말).
# 화이트리스트가 아니라 차분이다. 실효 기준선 자체는 매 실행마다
# Scratch/VerifyBuilt.lean 의 층별 프로브가 다시 찍는다.
BASELINE_DOC=docs/baseline.md

vb_out=$(lake env lean Scratch/VerifyBuilt.lean 2>&1); vb_rc=$?
printf '%s\n' "$vb_out" | sed 's/^/  /'
if [ "$vb_rc" -eq 0 ]; then ok "VerifyBuilt 통과 (DecidableEq 없이 적용됨)"
else bad "VerifyBuilt 실패"; fi

# 감사 대상 선언은 목록을 박지 않고 매 실행마다 훑어 잡는다. 박아 두면 새 선언이 그물 밖에
# 남고, `lakefile.toml` 의 glob 이 빌드는 하므로 그 사실이 빌드로 드러나지 않는다 (CF-595).
# 주석을 지운 뒤 줄머리의 inductive·structure·def·theorem·abbrev·instance 뒤 이름을 뽑고
# 그 자리에서 열려 있는 namespace 를 앞에 붙인다. example 은 이름이 없어 대상이 아니다.
# 뽑은 이름마다 `#print axioms` 한 줄을 내는 프로브 파일을 임시 디렉터리에 만들어 돌린다.
AUDIT=$(mktemp -d)
for t in "${TARGETS[@]}"; do
  mkdir -p "$AUDIT/code/$(dirname "$t")"
  strip_comments "$t" > "$AUDIT/code/$t"
done
python3 - "$AUDIT" "${TARGETS[@]}" <<'PYEOF'
import os, re, sys
audit, files = sys.argv[1], sys.argv[2:]
DECL = re.compile(r"^(inductive|structure|def|theorem|abbrev|instance)\s+([^\s({\[:]+)")
ANON = re.compile(r"^instance\b(?!\s+[^\s({\[:]+)")
OPEN = re.compile(r"^(namespace|section)\b[ \t]*(\S*)")
END = re.compile(r"^end\b")
rows, anon = [], []
for f in files:
    stack = []
    code = open(os.path.join(audit, "code", f), encoding="utf-8").read()
    for i, ln in enumerate(code.split("\n"), 1):
        m = OPEN.match(ln)
        if m:
            stack.append((m.group(1), m.group(2))); continue
        if END.match(ln):
            if stack: stack.pop()
            continue
        m = DECL.match(ln)
        if m:
            ns = ".".join(n for k, n in stack if k == "namespace" and n)
            rows.append((f.split("/")[1], f"{ns}.{m.group(2)}" if ns else m.group(2)))
        elif ANON.match(ln):
            anon.append(f"{f}:{i}")
with open(os.path.join(audit, "decls.tsv"), "w", encoding="utf-8") as out:
    for d, n in rows:
        out.write(f"{d}\t{n}\n")
with open(os.path.join(audit, "anon.txt"), "w", encoding="utf-8") as out:
    out.write("".join(a + "\n" for a in anon))
with open(os.path.join(audit, "Probe.lean"), "w", encoding="utf-8") as out:
    for f in files:
        out.write("import " + f[:-len(".lean")].replace("/", ".") + "\n")
    out.write("\n")
    for _, n in rows:
        out.write(f"#print axioms {n}\n")
PYEOF
pr_out=$(lake env lean "$AUDIT/Probe.lean" 2>&1); pr_rc=$?
printf '%s\n' "$pr_out" | sed 's/^/  /'
if [ "$pr_rc" -eq 0 ]; then ok "선언 감사 프로브 통과 (임시 파일, 선언 $(wc -l < "$AUDIT/decls.tsv"))"
else bad "선언 감사 프로브 실패"; fi
while IFS= read -r a; do
  [ -n "$a" ] && bad "이름 없는 instance 는 이름으로 감사할 수 없다: $a"
done < "$AUDIT/anon.txt"

# `#print axioms` 는 목록이 길면 줄바꿈해 출력하므로 공백을 접어서 대조한다.
norm=$(printf '%s\n%s' "$vb_out" "$pr_out" | python3 -c "import sys,re;print(re.sub(r'\s+',' ',sys.stdin.read()))")

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

AUDITED=0
AUDIT_DETAIL=()
audit_layer() {
  local label=$1 key=$2 probe=$3; shift 3
  local base measured c got ex n=0
  base=$(sed -n '/<!-- BASELINE:BEGIN -->/,/<!-- BASELINE:END -->/p' "$BASELINE_DOC" \
         | sed -n "s/^$key=//p")
  if [ -z "$base" ]; then
    bad "$BASELINE_DOC 의 기계 판독 블록에서 $key 를 읽지 못함 — 형식 확인 필요"
    AUDIT_DETAIL+=("$label 0")
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
  AUDIT_DETAIL+=("$label $n")
}

# 디렉터리가 층을 결정한다. 층마다 docs/baseline.md 의 키와 실효 기준선을 내는 프로브가
# 짝을 이룬다. 이 표에 없는 디렉터리에 선언이 서면 차분할 기준선이 없으므로 실패시킨다.
LAYERS=(
  "Accounting|회계층|ACCOUNTING_INT|baselineProbeSum"
  "Glossary|용어집|GLOSSARY|glossaryProbeList"
  "Definition|정의층|DEFINITION|definitionProbeFamily"
  "Observation|관측층|OBSERVATION|observationProbeProd"
)
known=""
for row in "${LAYERS[@]}"; do
  IFS='|' read -r dir label key probe <<< "$row"
  known="$known $dir"
  mapfile -t names < <(awk -F'\t' -v d="$dir" '$1 == d { print $2 }' "$AUDIT/decls.tsv")
  audit_layer "$label" "$key" "$probe" "${names[@]}"
done
while IFS=$'\t' read -r dir name; do
  case " $known " in *" $dir "*) ;; *) bad "층 기준선이 정해지지 않은 자리의 선언: $dir 의 $name" ;; esac
done < "$AUDIT/decls.tsv"
rm -rf "$AUDIT"

detail=$(printf '%s · ' "${AUDIT_DETAIL[@]}"); detail=${detail% · }
ok "공리 감사 대상 선언 $AUDITED ($detail)"

step step8-layertype '층별 수 타입 정적 검사 (L-10)'
# CLAUDE.md §2 의 층별 금지 표를 주석을 지운 코드에서 대조한다. 디렉터리가 층을 결정한다.
# 정의층의 ℕ·Nat 은 L-13 의 명시적 예외라 잡지 않는다. 회계층의 ℝ 는 step3-forbidden 이
# 보므로 여기서 다시 세지 않는다. 회계층의 ℚ·Rat 은 L-15 의 판정이 docstring 의 사유를
# 읽어야 서므로 실패가 아니라 보고로 낸다.
LT=$(mktemp -d)
for t in "${TARGETS[@]}"; do
  mkdir -p "$LT/$(dirname "$t")"
  strip_comments "$t" > "$LT/$t"
done
lt_out=$(python3 - "$LT" "${TARGETS[@]}" <<'PYEOF'
import os, re, sys
root, files = sys.argv[1], sys.argv[2:]
# 디렉터리: (층, 금지 기호, 금지 영문명, 수치 리터럴 금지, 처분)
RULES = {
    "Glossary":    ("용어집", "ℚℤℝℕ", ("Rat", "Int", "Real", "Nat"), True,  "FAIL"),
    "Definition":  ("정의층", "ℚℤℝ",  ("Rat", "Int", "Real"),        False, "FAIL"),
    "Accounting":  ("회계층", "ℚ",    ("Rat",),                      False, "REPORT"),
    "Observation": ("관측층", "ℚℤℝℕ", ("Rat", "Int", "Real", "Nat"), True,  "FAIL"),
}
# 영문명은 토큰 경계를 요구하고 대소문자를 구별한다. `intermediation` 의 Int 나 `Rational` 의
# Rat 이 걸리지 않게 한다. 수치 리터럴은 식별자의 일부가 아닌 독립 정수·소수이며 첨자는 들지 않는다.
LIT = re.compile(r"(?<![\w'.])[0-9]+(?:\.[0-9]+)?(?![\w'])")
scanned = {d: 0 for d in RULES}
other = 0
for f in files:
    d = f.split("/")[1] if f.count("/") >= 2 else ""
    if d not in RULES:
        other += 1
        continue
    layer, syms, names, no_lit, verdict = RULES[d]
    scanned[d] += 1
    tok = re.compile("[" + syms + "]|(?<![\\w'.])(?:" + "|".join(names) + ")(?![\\w'])")
    for i, ln in enumerate(open(os.path.join(root, f), encoding="utf-8").read().split("\n"), 1):
        hits = [m.group(0) for m in tok.finditer(ln)]
        if no_lit:
            hits += [f"리터럴 {m.group(0)}" for m in LIT.finditer(ln)]
        if hits:
            print(f"{verdict}\t{layer}\t{f}:{i}\t{', '.join(hits)}\t{ln.strip()}")
for d, (layer, *_rest) in RULES.items():
    print(f"SCAN\t{layer}\t{scanned[d]}")
print(f"OTHER\t{other}")
PYEOF
)
rm -rf "$LT"
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
PF=$(mktemp -d)
mapfile -t DEF_TARGETS < <(printf '%s\n' "${TARGETS[@]}" | grep '^CrisisFramework/Definition/')
for t in "${DEF_TARGETS[@]}"; do
  mkdir -p "$PF/$(dirname "$t")"
  strip_comments "$t" > "$PF/$t"
done
pf_out=$(python3 - "$PF" "${DEF_TARGETS[@]}" <<'PYEOF'
import os, re, sys
root, files = sys.argv[1], sys.argv[2:]
HEAD = re.compile(r"^(structure|inductive)\s+([^\s({\[:]+)")
TOP = re.compile(r"^\S")
WHERE = re.compile(r"\bwhere\b")
PROP = re.compile(r"(?<![\w'.])Prop(?![\w'])")
n = {"structure": 0, "inductive": 0}
for f in files:
    lines = open(os.path.join(root, f), encoding="utf-8").read().split("\n")
    for i, ln in enumerate(lines):
        m = HEAD.match(ln)
        if not m:
            continue
        kind, name = m.groups()
        n[kind] += 1
        body = False
        j = i
        while j < len(lines) and (j == i or not TOP.match(lines[j])):
            seg = lines[j]
            if not body:
                w = WHERE.search(seg)
                if w:
                    body, seg = True, seg[w.end():]
                elif kind == "inductive" and seg.lstrip().startswith("|"):
                    body = True
                else:
                    j += 1
                    continue
            if not seg.strip().startswith("deriving") and PROP.search(seg):
                part = "필드" if kind == "structure" else "생성자"
                print(f"FAIL\t{f}:{j + 1}\t{kind} {name} 의 {part}\t{lines[j].strip()}")
            j += 1
print(f"SCAN\t{len(files)}\t{n['structure']}\t{n['inductive']}")
PYEOF
)
rm -rf "$PF"
pf_bad=0
while IFS=$'\t' read -r kind a b c; do
  case "$kind" in
    FAIL) pf_bad=1; bad "Prop 를 담은 $b: $a"; printf '       %s\n' "$c" ;;
    SCAN) [ "$pf_bad" -eq 0 ] && ok "정의층 파일 $a · structure $b · inductive $c 의 필드와 생성자에 Prop 없음" ;;
  esac
done <<< "$pf_out"

step step5-mutation "변이 검사"
# 대상은 CrisisFramework 아래 .lean 전량에서 훑어 잡으며 계수를 박지 않는다. 목록을 박아 두면
# 새 진술이 그물 밖에 남는다 (CF-595). 뽑는 패턴은 결론이 `= 0`·`≠ 0` 인 진술이다.
# 변이 사본은 파일별로 임시 디렉터리에 만들어 원본을 건드리지 않고 돌린 뒤 지운다.
mut_targets=()
for t in "${TARGETS[@]}"; do
  while IFS= read -r ln; do
    [ -n "$ln" ] && mut_targets+=("$t:$ln")
  done < <(grep -nE '(≠|=) 0 := by' "$t" | cut -d: -f1)
done
if [ "${#mut_targets[@]}" -eq 0 ]; then
  ok "변이 대상 0 — 결론이 \`= 0\`·\`≠ 0\` 인 진술이 CrisisFramework 아래에 없다"
else
  per_file=$(printf '%s\n' "${mut_targets[@]}" | cut -d: -f1 | uniq -c | awk '{printf "%s%s %s", (NR>1?" · ":""), $2, $1}')
  ok "변이 대상 ${#mut_targets[@]} ($per_file)"
  tmp=$(mktemp -d)
  for tl in "${mut_targets[@]}"; do
    t=${tl%:*}; ln=${tl##*:}
    src=$(sed -n "${ln}p" "$t")
    if printf '%s' "$src" | grep -q '≠ 0 := by'; then
      mut=$(printf '%s' "$src" | sed 's/≠ 0 := by/= 0 := by/')
    else
      mut=$(printf '%s' "$src" | sed 's/= 0 := by/≠ 0 := by/')
    fi
    awk -v n="$ln" -v r="$mut" 'NR==n{print r; next}{print}' "$t" > "$tmp/Mutant.lean"
    if lake env lean "$tmp/Mutant.lean" >"$tmp/out" 2>&1; then
      bad "$t:$ln 변이가 통과함 — 해당 진술은 공허한 검사다: ${src## }"
    else
      ok "$t:$ln 변이 거부됨 ($(grep -cE 'error' "$tmp/out") error) — 실검사 확인"
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
