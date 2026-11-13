"""공리 출력을 값 정본의 층별 기준선과 차분하고 그 판정 행과 보고 행을 낸다.

`scripts/verify.sh` 의 `step4-baseline` 단계가 이 모듈을 부르고 그 산출을 받는다.
"""
import re, sys
axfile, basedoc, declfile = sys.argv[1], sys.argv[2], sys.argv[3]
norm = re.sub(r"\s+", " ", open(axfile, encoding="utf-8").read())

# 디렉터리가 층을 결정한다. 층마다 docs/baseline.md 의 키와 실효 기준선을 내는 프로브가
# 짝을 이룬다. 이 표에 없는 디렉터리에 선언이 서면 차분할 기준선이 없으므로 실패시킨다.
# 회계층 아래의 `Rat` 디렉터리는 위의 생성부가 따로 내는 자리이며 유리수 기준선과 차분한다.
LAYERS = [
    ("Accounting",     "회계층",    "ACCOUNTING_INT", "baselineProbeSum"),
    ("Accounting/Rat", "회계층(ℚ)", "ACCOUNTING_RAT", "ratProbeSum"),
    ("Glossary",       "용어집",    "GLOSSARY",       "glossaryProbeList"),
    ("Definition",     "정의층",    "DEFINITION",     "definitionProbeFamily"),
    ("Observation",    "관측층",    "OBSERVATION",    "observationProbeProd"),
]

# 층별 기대 기준선은 docs/baseline.md 의 기계 판독 블록이 든다. 값을 스크립트에
# 전사하면 문서를 고쳐도 검사가 낡은 값으로 돌기 때문이다 (baseline.md 머리말).
doc = open(basedoc, encoding="utf-8").read()
m = re.search(r"<!-- BASELINE:BEGIN -->(.*?)<!-- BASELINE:END -->", doc, re.S)
base_of = {}
for ln in (m.group(1) if m else "").split("\n"):
    if "=" in ln:
        k, _, v = ln.partition("=")
        base_of[k.strip()] = v.strip()

def axioms_of(n):
    """이름 하나의 공리 목록을 낸다. 무의존이면 [] 를 내고 찾지 못하면 빈 문자열을 낸다."""
    g = re.search(r"'" + re.escape(n) + r"' depends on axioms: \[([^\]]*)\]", norm)
    if g:
        return "[" + g.group(1) + "]"
    if re.search(r"'" + re.escape(n) + r"' does not depend on any axioms", norm):
        return "[]"
    return ""

def parse(s):
    return set(t.strip() for t in s.strip().strip("[]").split(",") if t.strip())

rows = []
for ln in open(declfile, encoding="utf-8"):
    ln = ln.rstrip("\n")
    if ln:
        d, _, n = ln.partition("\t")
        rows.append((d, n))

out, audited, ne_total = [], 0, 0
detail, ne_detail, known = [], [], set()
for d, label, key, probe in LAYERS:
    known.add(d)
    base = base_of.get(key, "")
    if not base:
        out.append(f"BASE_MISS\t{key}")
        detail.append(f"{label} 0")
        continue
    out.append(f"BASE_OK\t{key}\t{base}")
    measured = axioms_of(probe)
    if not measured:
        out.append(f"PROBE_MISS\t{label}\t{probe}")
    elif measured == base:
        out.append(f"PROBE_OK\t{label}\t{measured}")
    else:
        out.append(f"PROBE_DIFF\t{label}\t{measured}\t{base}")
    n = ne = 0
    nonempty = []
    for c in [nm for dd, nm in rows if dd == d]:
        got = axioms_of(c)
        audited += 1
        n += 1
        if not got:
            out.append(f"DECL_MISS\t{c}")
            continue
        if got != "[]":
            ne += 1
            nonempty.append(f"{c}  {got}")
        # 기준선을 넘은 공리만 낸다. 부분집합 대조이므로 기준선 이하도 통과시킨다.
        ex = sorted(parse(got) - parse(base))
        if not ex:
            out.append(f"DECL_SAME\t{c}\t{got}" if got == base else f"DECL_UNDER\t{c}\t{got}")
        else:
            out.append(f"DECL_EXCESS\t{c}\t{got}\t{base}\t[{', '.join(ex)}]")
    detail.append(f"{label} {n}")
    out.append(f"NONEMPTY\t{label}\t{ne}\t{n}")
    out += [f"NONEMPTY_ITEM\t{x}" for x in nonempty]
    ne_total += ne
    ne_detail.append(f"{label} {ne}")
for d, n in rows:
    if d not in known:
        out.append(f"LAYER_UNKNOWN\t{d}\t{n}")
out.append(f"TOTAL\t{audited}\t" + " · ".join(detail))
out.append(f"NE_TOTAL\t{ne_total}\t" + " · ".join(ne_detail))
print("\n".join(out))
