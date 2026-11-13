"""주석을 지운 사본에서 선언을 훑어 감사 프로브와 선언 목록과 이름 없는 인스턴스의 목록을 세운다.

`scripts/verify.sh` 의 `step4-baseline` 단계가 이 모듈을 부르고 그 산출을 받는다.
"""
import os, re
def run(audit, stripped, files) -> None:
    """감사 대상 선언의 목록과 `#print axioms` 프로브 파일을 `audit` 아래에 세운다."""
    DECL = re.compile(r"^(inductive|structure|def|theorem|abbrev|instance)\s+([^\s({\[:]+)")
    ANON = re.compile(r"^instance\b(?!\s+[^\s({\[:]+)")
    OPEN = re.compile(r"^(namespace|section)\b[ \t]*(\S*)")
    END = re.compile(r"^end\b")
    rows, anon = [], []
    # 경로의 둘째 칸이 층이다. 다만 회계층 아래의 `Rat` 디렉터리는 유리수를 쓰는 파일의 자리이고 그
    # 기준선이 정수 기준선과 따로 서므로, 그 디렉터리의 선언을 회계층과 다른 자리로 낸다. 회계층으로
    # 들이면 유리수가 끌어오는 공리가 정수 기준선 위의 초과로 전량 잡힌다.
    def layer_of(f):
        if f.startswith("CrisisFramework/Accounting/Rat/"):
            return "Accounting/Rat"
        return f.split("/")[1]
    for f in files:
        stack = []
        code = open(os.path.join(stripped, f), encoding="utf-8").read()
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
                rows.append((layer_of(f), f"{ns}.{m.group(2)}" if ns else m.group(2)))
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
