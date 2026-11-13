"""판정 반환 함수의 논리 결합 하나를 뒤집은 사본을 임시 디렉터리에 세우고 그 목록을 낸다.

`scripts/verify.sh` 의 `step10-clausemut` 단계가 이 모듈을 부르고 그 산출을 받는다.
"""

from vstep_common import mask
import pathlib, re, sys

tmp, files = pathlib.Path(sys.argv[1]), sys.argv[2:]

# 판정 반환 함수의 머리. 주석을 덮은 뒤 줄머리에 선 def 이며 속성과 가시성 수식을 앞에 둘 수 있다.
DEF = re.compile(r'^(?:@\[[^\]\n]*\]\s*)?(?:private\s+|protected\s+)?def\s+([^\s(){}\[\]⟨⟩⦃⦄:]+)', re.M)
# 선언의 끝. 본문과 match 갈래는 들여 쓰므로 줄머리에 글자가 선 다음 줄이 다음 항목이다.
NEXT = re.compile(r'^\S', re.M)
# 머리와 본문의 경계. `:=` 이거나 줄머리를 들여 쓴 match 갈래의 `|` 다.
SPLIT = re.compile(r':=|\n[ \t]*\|')
OPS = re.compile(r'&&|\|\||∧|∨')
SWAP = {'&&': '||', '||': '&&', '∧': '∨', '∨': '∧'}

def line_of(src: str, k: int) -> int:
    """offset 의 줄 번호. 칸 번호는 그 줄 머리에서 센 글자 수이며 바이트가 아니다."""
    return src.count('\n', 0, k) + 1

rows, serial = [], 0
for f in files:
    src = pathlib.Path(f).read_text(encoding='utf-8')
    m = mask(src)
    for d in DEF.finditer(m):
        nl = m.find('\n', d.end())
        nx = NEXT.search(m, nl + 1) if nl >= 0 else None
        end = nx.start() if nx else len(m)
        cut = SPLIT.search(m, d.end(), end)
        if cut is None:
            continue
        if not m[d.end():cut.start()].rstrip().endswith('Bool'):
            continue
        first, last = line_of(src, d.start()), line_of(src, end - 1)
        for o in OPS.finditer(m, cut.start(), end):
            serial += 1
            box = tmp / ('c%03d' % serial)
            box.mkdir()
            copy = box / 'Mutant.lean'
            a, b = o.span()
            copy.write_text(src[:a] + SWAP[o.group(0)] + src[b:], encoding='utf-8')
            col = a - (src.rfind('\n', 0, a) + 1) + 1
            rows.append('\t'.join([f, '%d:%d' % (line_of(src, a), col), d.group(1), o.group(0),
                                   SWAP[o.group(0)], str(first), str(last), str(copy)]))

sys.stdout.write(''.join(r + '\n' for r in rows))
