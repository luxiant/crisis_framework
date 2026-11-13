"""빌드 도구가 더하거나 바꾼 환경 변수의 이름을 값 정본의 블록과 맞대어 판정 행을 낸다.

`scripts/verify.sh` 의 `step11-leanenv` 단계가 이 모듈을 부르고 그 산출을 받는다.
"""
import sys

def load(path):
    out = {}
    with open(path, "rb") as fh:
        for rec in fh.read().split(b"\0"):
            if b"=" in rec:
                k, v = rec.split(b"=", 1)
                out[k] = v
    return out

now, inner, doc = load(sys.argv[1]), load(sys.argv[2]), sys.argv[3]
# 셸이 마지막 인자를 담는 자리는 호출마다 달라지므로 그 집합의 안정을 깨뜨린다.
SHELL_SET = {b"_"}
touched = sorted(k.decode("utf-8", "replace") for k in inner
                 if k not in SHELL_SET and now.get(k) != inner[k])
want, inblock = [], False
for ln in open(doc, encoding="utf-8"):
    if "<!-- LEANENV:BEGIN -->" in ln:
        inblock = True
        continue
    if "<!-- LEANENV:END -->" in ln:
        inblock = False
        continue
    if inblock and ln.startswith("LEANENV_VAR="):
        want.append(ln.strip().split("=", 1)[1])
rows = []
if not want:
    rows.append("FAIL\t값 정본의 LEANENV 블록에서 변수 이름을 읽지 못했다")
else:
    extra = [n for n in touched if n not in want]
    missing = [n for n in want if n not in touched]
    rows.append("REPORT\t빌드 도구가 더하거나 바꾼 변수 %d · 블록이 든 이름 %d"
                % (len(touched), len(want)))
    if extra:
        rows.append("REPORT\t블록에 없는 변수 %d — %s" % (len(extra), " · ".join(extra)))
    if missing:
        rows.append("REPORT\t블록이 드는데 이 환경에 서지 않는 변수 %d — %s"
                    % (len(missing), " · ".join(missing)))
    if not extra and not missing:
        rows.append("OK\t더하거나 바꾼 변수의 이름이 블록과 같다 (%d)" % len(want))
sys.stdout.write("".join(r + "\n" for r in rows))
