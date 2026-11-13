"""층마다 허용된 수 타입 밖의 토큰을 찾아 판정 행을 낸다.

`scripts/verify.sh` 의 `step8-layertype` 단계가 이 모듈을 부르고 그 산출을 받는다.
"""
import os, re, sys
root, files = sys.argv[1], sys.argv[2:]
# 디렉터리: (층, 금지 기호, 금지 영문명, 수치 리터럴 금지, 처분)
RULES = {
    "Glossary":    ("용어집", "ℚℤℕ", ("Rat", "Int", "Real", "Nat"), True,  "FAIL"),
    "Definition":  ("정의층", "ℚℤ",  ("Rat", "Int", "Real"),        False, "FAIL"),
    "Accounting":  ("회계층", "ℚ",   ("Rat",),                      False, "REPORT"),
    "Observation": ("관측층", "ℚℤℕ", ("Rat", "Int", "Real", "Nat"), True,  "FAIL"),
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
