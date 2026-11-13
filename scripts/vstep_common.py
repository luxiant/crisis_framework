"""검증 스크립트의 단계가 부르는 모듈이 함께 쓰는 보조.

둘 이상의 단위가 드는 보조만 이 자리에 둔다. 한 단위에만 걸리는 것은 그 단위가 들며,
원장 검증기의 공용 설비에 두지 않는 까닭은 셸 단계가 부르는 모듈이 그 검증기의 설비를
들이면 두 갈래 사이에 방향이 생긴다는 것이다.
"""

def mask(src: str) -> str:
    """주석과 문자열 리터럴을 공백으로 덮은 사본. 자리 수가 같아 원본의 offset 이 그대로 쓰인다.

    리터럴을 함께 덮는 까닭은 그 안의 `--` 와 `/-` 가 주석 제거를 어긋나게 하고 그 안의 괄호가
    괄호 묶음 건너뛰기를 어긋나게 하기 때문이다 (CF-680). 여는 따옴표와 닫는 따옴표는 남기고
    안쪽만 덮으며, 따옴표는 괄호가 아니므로 깊이 셈에 들지 않는다.
    """
    out, i, n, depth = list(src), 0, len(src), 0
    while i < n:
        if depth == 0 and src[i] == '"':
            j = i + 1
            while j < n and src[j] != '"':
                if src[j] == '\\' and j + 1 < n:
                    out[j] = ' '
                    j += 1                 # 이스케이프된 글자는 리터럴을 닫지 않는다
                if src[j] != '\n':
                    out[j] = ' '
                j += 1
            i = j + 1 if j < n else n
            continue
        if depth == 0 and src.startswith('--', i):
            j = src.find('\n', i)
            j = n if j < 0 else j
            for k in range(i, j):
                out[k] = ' '
            i = j
            continue
        if src.startswith('/-', i):
            depth += 1
            out[i] = out[i + 1] = ' '
            i += 2
            continue
        if depth > 0 and src.startswith('-/', i):
            depth -= 1
            out[i] = out[i + 1] = ' '
            i += 2
            continue
        if depth > 0 and src[i] != '\n':
            out[i] = ' '
        i += 1
    return ''.join(out)

def strip(src):
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
    return ''.join(out)
