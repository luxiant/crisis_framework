# -*- coding: utf-8 -*-
"""형태소 설비. 받침과 조사와 수사와 서수와 표시 폭 흘림을 한 자리에 둔다.
부록이 요구하는 꼴 전량을 받으며, 판정은 전부 이 모듈이 내고 다른 자리는 부른다."""
import ast, re, unicodedata

# ---- 받침 ----
# 읽히지 않는 기호를 떼고 본다
_MUTE = '`\'"()[]{}「」『』<>《》〈〉.,:;!?*_~/\\|-+= \t\n'
# 숫자의 한국어 읽기. 영(ㅇ)·일(ㄹ)·삼(ㅁ)·육(ㄱ)·칠(ㄹ)·팔(ㄹ) 이 받침을 갖는다
_DIGIT_JONG = {'0': True, '1': True, '2': False, '3': True, '4': False,
               '5': False, '6': True, '7': True, '8': True, '9': False}
_DIGIT_RIEUL = {'1', '7', '8'}
# 라틴 글자의 한국어 읽기에서 받침을 갖는 것. 엘·엠·엔
_LATIN_JONG = {'l', 'm', 'n'}
_LATIN_RIEUL = {'l'}

def _last_reading_char(s):
    for ch in reversed(s):
        if ch not in _MUTE:
            return ch
    return ''

def has_jong(s):
    """마지막으로 읽히는 글자의 받침 유무. 읽히지 않는 기호는 뗀다."""
    ch = _last_reading_char(str(s))
    if not ch:
        return False
    if '가' <= ch <= '힣':
        return (ord(ch) - 0xAC00) % 28 != 0
    if ch.isdigit():
        return _DIGIT_JONG[ch]
    low = ch.lower()
    if 'a' <= low <= 'z':
        return low in _LATIN_JONG
    return False

def is_rieul(s):
    ch = _last_reading_char(str(s))
    if not ch:
        return False
    if '가' <= ch <= '힣':
        return (ord(ch) - 0xAC00) % 28 == 8
    if ch.isdigit():
        return ch in _DIGIT_RIEUL
    return ch.lower() in _LATIN_RIEUL

# ---- 조사. 받침으로 꼴이 갈리는 것만 짝으로 든다 ----
PAIRS = {'은': ('은', '는'), '는': ('은', '는'), '이': ('이', '가'), '가': ('이', '가'),
         '을': ('을', '를'), '를': ('을', '를'), '과': ('과', '와'), '와': ('과', '와'),
         '으로': ('으로', '로'), '로': ('으로', '로'), '이나': ('이나', '나'),
         '나': ('이나', '나'), '이란': ('이란', '란'), '란': ('이란', '란')}
# 받침에 무관한 조사. 축의 유니버스 밖
FLAT = ('의', '에', '도', '만', '에서', '에게', '부터', '까지', '처럼', '보다', '마다')

def jo(word, particle):
    """받침으로 조사를 고른다. 「으로」는 ㄹ 받침이 받침 없는 꼴을 받는 예외."""
    w = str(word)
    if particle in FLAT:
        return particle
    if particle not in PAIRS:
        raise AssertionError('받침으로 갈리지 않는 조사: %r' % particle)
    yes, no = PAIRS[particle]
    if particle in ('으로', '로'):
        return no if (not has_jong(w) or is_rieul(w)) else yes
    return yes if has_jong(w) else no

def w(word, particle):
    """낱말과 조사를 함께 낸다. 조사를 리터럴로 적을 자리를 없앤다."""
    return '%s%s' % (word, jo(word, particle))

NUMW = ('열하나', '열둘', '열셋', '열넷', '스물', '서른', '마흔', '쉰', '예순', '일흔',
         '여든', '아흔', '하나', '둘', '셋', '넷', '다섯', '여섯', '일곱', '여덟', '아홉', '열')

CODE_READ = re.compile(r'^`(?:[0-9a-f]{6,}|[^`]*[0-9]|[^`]*\.(?:lean|md|json|py|sh|txt|html|csv|yml|yaml|toml))`$')

def josa_bad(text):
    """수사 뒤의 조사가 받침과 맞는지를 잰다. 유니버스를 수사 뒤로 좁힌다.
    조사가 겹치는 자리를 함께 재는 꼴은 동사 어미에서 거짓 양성을 대량 내므로 쓰지 않는다."""
    bad = []
    J = r'은|는|이|가|을|를|과|와|으로|로'
    for wd in NUMW:
        for m in re.finditer(re.escape(wd) + r'(%s)(?![가-힣])' % J, text):
            if jo(wd, m.group(1)) != m.group(1):
                bad.append(wd + m.group(1))
        # 조사를 고르는 함수가 이미 붙인 뒤에 포맷이 조사를 또 붙인 자리.
        # 격조사 뒤의 보조사(는·도·만)는 적법한 연쇄이므로 둘째 자리에서 뺀다
        J2 = r'은|이|가|을|를|과|와|으로|로'
        for m in re.finditer(re.escape(wd) + r'(?:%s)(?:%s|이다|이고|이며)(?![가-힣])'
                             % (J, J2), text):
            bad.append(m.group(0))
    # 서수의 관형형 「첫」은 조사를 받지 못한다. 묶는 함수가 관형형을 이으면 「첫과」가 서므로
    # 그 꼴을 수사의 유니버스에 함께 넣는다
    for m in re.finditer(r'(?<![가-힣])첫(%s|의)(?![가-힣])' % J, text):
        bad.append(m.group(0))
    # 숫자 뒤의 서술격. 조사의 유니버스에 서술격이 들지 않아 「조작 6다」가 그 밖으로 떨어졌다
    for m in re.finditer(r'(?<![0-9.\-`])([0-9]+)(이다|다)(?![가-힣])', text):
        if m.group(2) != ('이다' if has_jong(m.group(1)) else '다'):
            bad.append(m.group(0))
    # 코드 표기 뒤의 조사와 서술격. 그 표기의 읽기가 받침을 정하며, 띄어 쓰는 관례가 그
    # 판정을 바꾸지 않는다. 유니버스를 읽기가 글자 이름으로 정해지는 표기로 좁힌다. 해시와
    # 숫자로 끝나는 식별자와 확장자가 글자 이름으로 읽히는 파일 이름이 그 부류이고, 영어
    # 낱말은 낱말의 발음이 받침을 정하여 글자 이름과 갈리므로 거짓 양성이 선다. 공백을 끼운
    # 「이」는 지시 관형사와 꼴이 같아 갈리지 않으므로 뺀다
    for m in re.finditer(r'(`[^`\n]+`)( ?)(이다|다|%s)(?![가-힣])' % J, text):
        code, sp, j = m.group(1), m.group(2), m.group(3)
        if not CODE_READ.match(code) or (sp and j == '이'):
            continue
        want = ('이다' if has_jong(code) else '다') if j in ('이다', '다') else jo(code, j)
        if want != j:
            bad.append(m.group(0))
    # 아라비아 숫자 뒤의 조사. 유니버스를 한글 수사로만 닫으면 조작 번호와 계수가 그 밖으로
    # 떨어지고, 숫자의 한국어 읽기가 받침을 정하므로 같은 판정이 그대로 선다
    # 공백을 하나까지만 받는다. 둘 이상은 표의 칸 경계를 지운 자리여서 두 칸의 글자가
    # 붙은 것이고 한 문장 안의 조사가 아니다
    for m in re.finditer(r'(?<![0-9.\-])([0-9]+) ?(%s)(?![가-힣])' % J, text):
        n, j = m.group(1), m.group(2)
        if jo(n, j) != j:
            bad.append(m.group(0))
    return bad

def cop_end(word):
    """종결 서술격. 받침에 따라 갈린다."""
    return '%s이다' % word if has_jong(word) else '%s다' % word

def cop_conj(word, kind='이고'):
    """연결 서술격. 받침에 무관하게 「이」를 받으므로 받침을 보지 않는다."""
    assert kind in ('이고', '이며'), '연결 서술격이 아니다: %r' % kind
    return '%s%s' % (word, kind)

def join(words, particle='과'):
    """여러 원소를 묶는 조사도 앞 원소의 받침에서 고르고 한 꼴로 박지 않는다."""
    parts = [str(x) for x in words]
    if not parts:
        return ''
    acc = parts[0]
    for nxt in parts[1:]:
        acc = acc + jo(acc, particle) + ' ' + nxt
    return acc

def dot_join(words):
    """라틴 식별자의 열거는 가운뎃점으로 잇는다. 조사의 가름을 아예 없앤다."""
    return '·'.join(str(x) for x in words)

# ---- 수사. 자릿수에서 유도한다 ----
_N1 = ['', '하나', '둘', '셋', '넷', '다섯', '여섯', '일곱', '여덟', '아홉']
_N10 = ['', '열', '스물', '서른', '마흔', '쉰', '예순', '일흔', '여든', '아흔']
_D1 = ['', '한', '두', '세', '네', '다섯', '여섯', '일곱', '여덟', '아홉']
_SINO1 = ['영', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구']
_SINO10 = ['', '십', '이십', '삼십', '사십', '오십', '육십', '칠십', '팔십', '구십']

def native(n):
    """고유수사. 한 자리와 열 자리에서 유도한다. 1부터 99까지."""
    n = int(n)
    if n == 0:
        return '영'
    assert 1 <= n <= 99, '고유수사의 범위를 넘는다: %d' % n
    return (_N10[n // 10] + _N1[n % 10]) or _N10[n // 10]

def det(n):
    """관형형. 「열한」·「열두」처럼 한 자리가 바뀐다."""
    n = int(n)
    assert 1 <= n <= 99, '관형형의 범위를 넘는다: %d' % n
    return (_N10[n // 10] + _D1[n % 10]) or _N10[n // 10]

def sino(n):
    """한자수사. 두 자리까지 유도하고 그 위는 자릿수로 잇는다."""
    n = int(n)
    if n < 10:
        return _SINO1[n]
    if n < 100:
        return _SINO10[n // 10] + (_SINO1[n % 10] if n % 10 else '')
    return ''.join(_SINO1[int(c)] for c in str(n))

_ORD_EXC = {1: '첫째', 2: '둘째', 20: '스무째'}
def ordinal(n):
    """서수. 영구 문면이 서수 자리에 수사를 쓰지 않게 한다.
    홀로 선 둘은 「둘째」이고 열 자리와 함께 서면 관형형을 받아 「열두째」가 된다."""
    n = int(n)
    assert 1 <= n <= 99, '서수의 범위를 넘는다: %d' % n
    if n in _ORD_EXC:
        return _ORD_EXC[n]
    tens, ones = divmod(n, 10)
    if ones == 0:
        return _N10[tens] + '째'
    if tens == 0:
        return _N1[ones] + '째'
    stem = _D1[ones] if ones in (1, 2) else _N1[ones]
    return _N10[tens] + stem + '째'

_ORD_DET_EXC = {1: '첫'}
def ord_det(n):
    """서수의 관형형. 「첫 구간」처럼 명사를 바로 꾸미는 자리가 쓴다."""
    n = int(n)
    return _ORD_DET_EXC.get(n, ordinal(n))

def ord_join(ns):
    """여러 구간의 서수를 묶는다. 하나이면 관형형으로 명사를 바로 꾸미고 둘 이상이면 서수의
    명사형을 조사로 잇는다. 관형형 「첫」은 조사를 받지 못하므로 묶는 자리에 서면 「첫과」가 된다."""
    ns = [int(n) for n in ns]
    assert ns, '묶을 서수가 없다'
    if len(ns) == 1:
        return ord_det(ns[0])
    return join([ordinal(n) for n in ns])

def code_w(code, particle):
    """코드 표기와 그 뒤의 조사. 띄어 쓰는 관례를 지키고 조사를 그 표기의 읽기에서 고른다."""
    c = '`%s`' % code
    return '%s %s' % (c, jo(c, particle))

def code_cop(code):
    """코드 표기와 그 뒤의 종결 서술격. 띄어 쓰는 관례를 지키고 받침으로 고른다."""
    c = '`%s`' % code
    return '%s %s' % (c, '이다' if has_jong(c) else '다')

def count(n, unit, particle=None):
    """단위를 수사 앞에 두고 뒤따르는 조사를 받침으로 고른다.
    단위를 수사 뒤에 붙이면 단위가 두 번 서는 문면이 나온다."""
    n = int(n)
    body = '%s %s' % (unit, native(n)) if n <= 99 else '%s %d' % (unit, n)
    return w(body, particle) if particle else body

def num(n, particle=None):
    """수사 하나와 그 조사. 보간 뒤에 조사를 리터럴로 둘 자리를 없앤다."""
    body = native(int(n)) if 1 <= int(n) <= 99 else str(int(n))
    return w(body, particle) if particle else body

def digits(n, particle=None):
    """계수를 숫자로 든다. 판정별 계수를 드는 자리의 관례."""
    body = str(int(n))
    return w(body, particle) if particle else body

# ---- 표시 폭 ----
def disp_width(s):
    return sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1 for c in str(s))

_FENCE = re.compile(r'^\s*(?:```|~~~)')
def flow(text, width=96, indent=''):
    """산문 단락만 표시 폭으로 흘린다. 표와 제목과 울타리는 건드리지 않는다.
    울타리 상태를 갱신으로 두지 않고 블록마다 다시 본다."""
    out = []
    blocks = re.split(r'\n\s*\n', text)
    for blk in blocks:
        lines = blk.split('\n')
        if (any(_FENCE.match(l) for l in lines) or any(l.lstrip().startswith('|') for l in lines)
                or any(l.lstrip().startswith('#') for l in lines)
                or any(re.match(r'(?:[-*>]\s|---|\*\*\*|___)', l.lstrip()) for l in lines)):
            out.append(blk); continue
        words = ' '.join(lines).split()
        if not words:
            out.append(blk); continue
        cur, acc = indent + words[0], []
        for tok in words[1:]:
            if disp_width(cur) + 1 + disp_width(tok) > width:
                acc.append(cur); cur = indent + tok
            else:
                cur += ' ' + tok
        acc.append(cur)
        res = '\n'.join(acc)
        assert res.startswith(indent), '흘림이 첫 줄의 들여쓰기를 떨어뜨렸다'
        out.append(res)
    return '\n\n'.join(out)

# ---- 자기 꼴 단언 ----
def assert_self_shape(path=None):
    src = open(path or __file__, encoding='utf-8').read()
    tree = ast.parse(src)
    fns = {n.name for n in ast.walk(tree) if isinstance(n, ast.FunctionDef)}
    for need in ('has_jong', 'is_rieul', 'jo', 'w', 'cop_end', 'cop_conj',
                 'native', 'det', 'sino', 'ordinal', 'ord_join', 'count', 'num', 'flow'):
        assert need in fns, '형태소 설비에 %s 가 없다' % need
    # 연결 서술격을 받침으로 고르는 자리가 남았는지
    for n in ast.walk(tree):
        if isinstance(n, ast.FunctionDef) and n.name == 'cop_conj':
            names = {x.id for x in ast.walk(n) if isinstance(x, ast.Name)}
            assert 'has_jong' not in names, '연결 서술격을 받침으로 고르고 있다'
    # 겹치는 범위에서 두 사상이 같은지
    for i in range(1, 10):
        assert native(i) == _N1[i] and det(i) == _D1[i]
    # 받침과 조사
    assert jo('페이즈', '은') == '는' and jo('낙착', '은') == '은'
    assert jo('서울', '으로') == '로' and jo('부산', '으로') == '으로'
    assert jo('하나', '이') == '가' and jo('열', '이') == '이'
    assert jo('`CF-4503`', '이') == '이', '읽히지 않는 기호를 떼지 않았다'
    assert jo('funding-2', '은') == '는' and jo('funding-1', '은') == '은'
    assert cop_end('열셋') == '열셋이다' and cop_end('둘') == '둘이다'
    assert cop_end('둘째') == '둘째다' and cop_end('넷') == '넷이다'
    assert join(['정의층', '회계층', '관측층']) == '정의층과 회계층과 관측층'
    assert join(['하나', '둘'], '와') == '하나와 둘'
    assert cop_conj('하나') == '하나이고' and cop_conj('열', '이며') == '열이며'
    assert ord_join([1]) == '첫' and ord_join([1, 2]) == '첫째와 둘째'
    assert josa_bad('첫과 둘째 구간') == ['첫과'] and josa_bad('첫째와 둘째 구간') == []
    assert josa_bad('조작이 넷이이다') == ['넷이이다']
    assert josa_bad('조작은 조작 6다.') == ['6다'] and josa_bad('조작은 조작 4다.') == []
    assert josa_bad('파일이 `A.lean` 다.') == ['`A.lean` 다'] and josa_bad('파일이 `A.md` 다.') == []
    assert josa_bad('`Finset` 으로 갈린다') == [] and josa_bad('`a.zip` 은 그대로다') == []
    assert josa_bad('`CF-2610` 가 받는다') == ['`CF-2610` 가'] and josa_bad('`CF-12` 이 구간') == []
    assert code_cop('A.lean') == '`A.lean` 이다' and code_w('A.lean', '으로') == '`A.lean` 으로'
    assert ordinal(1) == '첫째' and ordinal(2) == '둘째' and ordinal(3) == '셋째'
    assert ordinal(4) == '넷째' and ordinal(10) == '열째' and ordinal(11) == '열한째'
    assert ordinal(12) == '열두째' and ordinal(13) == '열셋째' and ordinal(20) == '스무째'
    assert native(55) == '쉰다섯' and det(12) == '열두' and sino(2026) == '이영이육'
    assert count(3, '조작') == '조작 셋' and count(3, '조작', '은') == '조작 셋은'
    assert disp_width('가a') == 3
    return True

if __name__ == '__main__':
    print('형태소 설비 자기 꼴:', assert_self_shape())
