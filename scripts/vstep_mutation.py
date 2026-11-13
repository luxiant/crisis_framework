"""최상위 정리와 예제의 결론을 부정한 사본을 임시 디렉터리에 세우고 그 목록을 낸다.

`scripts/verify.sh` 의 `step5-mutation` 단계가 이 모듈을 부르고 그 산출을 받는다.
"""

from vstep_common import mask
import pathlib, re

def run(tmp, files) -> str:
    """결론 전체를 ¬ ( ) 로 감싼 사본을 `tmp` 아래에 세우고 그 목록을 잇는다."""
    tmp = pathlib.Path(tmp)

    OPEN = {'(': ')', '[': ']', '{': '}', '⟨': '⟩', '⦃': '⦄'}
    CLOSE = {v: k for k, v in OPEN.items()}
    DECL = re.compile(r'^(theorem|example)(?=[\s:])', re.M)
    NAME = re.compile(r'[^\s(){}\[\]⟨⟩⦃⦄:]+')

    def skip_group(m: str, i: int):
        """여는 괄호 자리에서 짝의 다음 자리를 낸다. 짝이 없으면 None 이다."""
        stack, n = [OPEN[m[i]]], len(m)
        i += 1
        while i < n and stack:
            c = m[i]
            if c in OPEN:
                stack.append(OPEN[c])
            elif c == stack[-1]:
                stack.pop()
            i += 1
        return None if stack else i

    def conclusion(m: str, kw: str, i: int):
        """선언 머리 뒤에서 결론의 (시작, 끝) offset 을 낸다. 못 잡으면 None 이다."""
        n = len(m)
        if kw == 'theorem':
            while i < n and m[i].isspace():
                i += 1
            while i < n and not m[i].isspace() and m[i] not in OPEN and m[i] != ':':
                i += 1
        # 괄호 묶음을 차례로 건너뛰고 깊이 0 의 ':' 를 결론의 시작으로 잡는다. 결론 안의
        # `∃ m : T,` 같은 콜론을 시작으로 잡지 않기 위해서다.
        while i < n:
            c = m[i]
            if c.isspace():
                i += 1
                continue
            if c in OPEN:
                j = skip_group(m, i)
                if j is None:
                    return None
                i = j
                continue
            if c == ':':
                if m[i:i + 2] == ':=':
                    return None
                i += 1
                break
            i += 1
        else:
            return None
        start, depth = i, 0
        while i < n:
            c = m[i]
            if c in OPEN:
                depth += 1
            elif c in CLOSE:
                depth -= 1
            elif depth == 0 and m[i:i + 2] == ':=':
                return (start, i)
            i += 1
        return None

    def decl_name(m: str, kw: str, i: int) -> str:
        """선언 머리의 이름. `example` 은 이름을 갖지 않으므로 그 낱말을 그대로 낸다."""
        if kw == 'example':
            return 'example'
        g = NAME.search(m, i)
        return g.group(0) if g else '<이름을 읽지 못했다>'

    rows, serial = [], 0
    for f in files:
        src = pathlib.Path(f).read_text(encoding='utf-8')
        m = mask(src)
        for d in DECL.finditer(m):
            line = src[:d.start()].count('\n') + 1
            span = conclusion(m, d.group(1), d.end())
            if span is None:
                # 결론을 잡지 못한 선언을 조용히 건너뛰면 그 진술이 알림 없이 그물 밖에 남고 통과
                # 계수에도 들지 않아 밖에서 보이지 않는다 (CF-682). 이름과 파일을 알리고 실패로 센다.
                rows.append('NOCONCL\t%s\t%d\t-\t%s' % (f, line, decl_name(m, d.group(1), d.end())))
                continue
            a, b = span
            serial += 1
            box = tmp / ('m%03d' % serial)
            box.mkdir()
            copy = box / 'Mutant.lean'
            copy.write_text(src[:a] + '¬ (' + src[a:b] + ')' + src[b:], encoding='utf-8')
            brief = ' '.join(src[a:b].split())
            rows.append('MUT\t%s\t%d\t%s\t%s' % (f, line, copy, brief))

    return ''.join(r + '\n' for r in rows)
