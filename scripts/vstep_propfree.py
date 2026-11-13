"""정의층의 구조체 필드와 귀납 생성자가 명제를 받는 자리를 찾아 판정 행을 낸다.

`scripts/verify.sh` 의 `step9-propfree` 단계가 이 모듈을 부르고 그 산출을 받는다.
"""
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
