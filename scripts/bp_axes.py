"""청사진의 산출을 재는 축 여덟과 축마다의 음성 대조.

축마다 유니버스를 가린다. 문법 표지를 재는 축이 양식 블록을 걷지 않으면 그
중괄호가 적발로 서고, 조사를 재는 축의 유니버스를 보간이 서는 자리로 좁히지
않으면 용언의 어미가 전량 적발로 선다.
"""
import re, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import morph

STYLE_BLOCK = re.compile(r'(?s)<style>.*?</style>')


def _nostyle(t):
    """양식 블록을 걷은 변. 문법 표지와 괄호 짝을 재는 축이 이 변을 쓴다."""
    return STYLE_BLOCK.sub('', t)


# ── 축 ────────────────────────────────────────────────────────────────────

def ax_cells(t):
    """표의 칸. 머리 행의 칸 수와 값 행의 칸 수가 표마다 같은지."""
    bad = []
    for i, m in enumerate(re.finditer(r'(?s)<table>(.*?)</table>', t), 1):
        body = m.group(1)
        hm = re.search(r'(?s)<thead>.*?</thead>', body)
        if not hm:
            bad.append(('표 %d' % i, '머리 행이 없다'))
            continue
        n = len(re.findall(r'<th\b', hm.group(0)))
        if n == 0:
            bad.append(('표 %d' % i, '머리의 칸이 영이다'))
        for j, rm in enumerate(re.finditer(r'<tr>(.*?)</tr>', body[hm.end():]), 1):
            k = len(re.findall(r'<td\b', rm.group(1)))
            if k != n:
                bad.append(('표 %d 행 %d' % (i, j), '칸 %d · 머리 %d' % (k, n)))
        if len(re.findall(r'(?s)<thead>', body)) > 1:
            bad.append(('표 %d' % i, '머리 행이 둘 이상이다'))
    return bad


def ax_bold(t):
    """굵은 표지의 짝. 여는 것과 닫는 것의 수가 같은지."""
    o = len(re.findall(r'<strong>', t))
    c = len(re.findall(r'</strong>', t))
    bad = [] if o == c else [('굵은 표지', '%d · %d' % (o, c))]
    # 회의록에서 옮긴 문면에 별표가 남았으면 그것도 적발
    for m in re.finditer(r'\*\*', _nostyle(t)):
        bad.append(('별표', t[max(0, m.start()-20):m.end()+20].replace('\n', ' ')))
    return bad


def ax_syntax(t):
    """생성 수단의 문법 표지. 양식 블록을 걷은 변에서 잰다."""
    v = _nostyle(t)
    bad = []
    for pat, nm in ((r'\{[a-z_]+\}', '중괄호 보간'), (r'%\([a-z_]+\)', '이름 보간'),
                    (r'\bNone\b', 'None'), (r"\['", '리스트 표기'),
                    (r'\bdict_|\bodict', '사전 표기')):
        for m in re.finditer(pat, v):
            bad.append((nm, v[max(0, m.start()-25):m.end()+25].replace('\n', ' ')))
    return bad


def ax_blank(t):
    """빈 보간. 자리표와 빈 칸과 빈 굵은 구간."""
    v = _nostyle(t)
    bad = []
    for pat, nm in ((r'<<[A-Z_]+>>', '자리표'), (r'<td[^>]*>\s*</td>', '빈 칸'),
                    (r'<strong>\s*</strong>', '빈 굵은 구간'),
                    (r'<code>\s*</code>', '빈 코드 표기'),
                    (r'<p[^>]*>\s*</p>', '빈 문단')):
        for m in re.finditer(pat, v):
            bad.append((nm, v[max(0, m.start()-25):m.end()+25].replace('\n', ' ')))
    return bad


def ax_paren(t):
    """양식의 괄호 짝. 양식 블록 안에서만 재며 중괄호의 짝을 본다."""
    m = STYLE_BLOCK.search(t)
    if not m:
        return [('양식', '양식 블록이 없다')]
    css = m.group(0)
    o, c = css.count('{'), css.count('}')
    return [] if o == c else [('양식의 중괄호', '%d · %d' % (o, c))]


# 블록을 가르는 태그. 이것을 빈 문자열로 지우면 두 칸의 글자가 붙어 조사의 꼴을 이루므로
# 거짓 양성이 선다
BLOCK_TAG = re.compile(r'</?(?:td|th|tr|table|p|div|li|ul|ol|h[1-6]|br|section)\b[^>]*>')

def ax_josa(t):
    """보간 뒤의 조사. 유니버스를 수사가 서는 자리로 좁히고 블록 경계를 공백으로 바꾼다."""
    v = BLOCK_TAG.sub('\n', _nostyle(t))
    # 코드 표기를 백틱으로 되돌려 코드 표기 뒤의 조사를 재는 축이 그 자리를 받게 한다. 태그를
    # 그대로 지우면 그 표기의 경계가 사라져 식별자 뒤의 조사가 그 축의 밖으로 떨어진다
    v = re.sub(r'<code>([^<`]*)</code>', r'`\1`', v)
    v = re.sub(r'<[^>]+>', '', v)
    return [('조사', x) for x in morph.josa_bad(v)]


def ax_prev(t, verbs):
    """산문이 앞 판의 조작을 주장하는 문면을 들지 않는지.

    그 구절의 목록을 조작의 갈래에서 유도해 받는다.
    """
    # 회의록의 요지를 옮겨 실은 칸은 그 낙착이 쓴 문면이고 이 문서가 조작을 주장하는 자리가
    # 아니므로 걷는다. 걷지 않으면 요지가 그 동사를 드는 회차마다 거짓 양성이 선다
    v = re.sub(r'(?s)<span class="gist">.*?</span>', '', _nostyle(t))
    v = re.sub(r'<[^>]+>', '', v)
    bad = []
    for w in verbs:
        for m in re.finditer(re.escape(w), v):
            bad.append((w, v[max(0, m.start()-30):m.end()+20].replace('\n', ' ')))
    return bad


def ax_pointer(t):
    """산문이 표를 방향으로 지목하지 않고 절의 이름으로 지목하는지."""
    v = re.sub(r'<[^>]+>', '', _nostyle(t))
    bad = []
    for m in re.finditer(r'(위|아래|앞|뒤)의? ?(표|절)(?:[이가은는을를의로와과도만에]|(?![가-힣]))', v):
        seg = v[max(0, m.start()-40):m.end()+30].replace('\n', ' ')
        # 「아래의 두 절」처럼 수사를 끼운 지목과 「이 표」는 방향이 아니다
        bad.append((m.group(0), seg))
    return bad


# 조작의 갈래가 가리키는 산문 구절. 갈래가 늘면 이 사상에 그 갈래의 구절이 서야 한다
KIND_VERB = {
    'merge': ['병합했다', '병합한 뒤', '원장에 실었다'],
    'create': ['세웠다', '파일을 세웠다'],
    'doc': ['문서를 세웠다', '종료 문서를 세웠다'],
    'replace': ['치환했다', '그 칸을 고쳤다', '행을 고쳤다'],
    'delete': ['지웠다', '카드를 지웠다'],
    'append_exec': ['덧붙였다'],
    'incr': ['증명을 채웠다'],
    'readonly': [],
}


def prev_verbs(kinds=None):
    """조작의 갈래에서 그 구절의 목록을 유도한다. 갈래를 주지 않으면 사상의 갈래 전량을 쓴다.

    역할 통합 뒤에는 대장이 서지 않으므로 생성기가 갈래 전량을 넘겨 그 구절 전량을 금지한다.
    """
    out = []
    for k in sorted(set(KIND_VERB if kinds is None else kinds)):
        assert k in KIND_VERB, '조작의 갈래 %r 에 구절이 서지 않았다' % k
        out += KIND_VERB[k]
    return out


# ── 축의 목록과 그 이름 ──────────────────────────────────────────────────

# 축의 이름과 그것을 재는 함수. 확인 절이 이 목록에서 이름을 유도하고 run 이 같은
# 목록에서 함수를 부르므로 둘이 갈릴 수 없다. 앞의 여덟은 문면을 읽어 재고
# 마지막 하나는 머리 없는 브라우저로 띄워야 선다
AXES = [
    ('표의 칸', lambda t, kinds, path: ax_cells(t)),
    ('굵은 표지의 짝', lambda t, kinds, path: ax_bold(t)),
    ('생성 수단의 문법 표지', lambda t, kinds, path: ax_syntax(t)),
    ('빈 보간', lambda t, kinds, path: ax_blank(t)),
    ('양식의 괄호 짝', lambda t, kinds, path: ax_paren(t)),
    ('보간 뒤의 조사', lambda t, kinds, path: ax_josa(t)),
    ('앞 판의 조작을 주장하는 문면',
     lambda t, kinds, path: ax_prev(t, prev_verbs(kinds))),
    ('표를 방향으로 지목하는 문면', lambda t, kinds, path: ax_pointer(t)),
    ('렌더링의 양식과 표와 행과 빈 보간', lambda t, kinds, path: ax_render(t, path)),
]
RENDER_AXIS = AXES[-1][0]


def names():
    """확인 절이 드는 축의 이름. 그 목록을 손으로 적지 않고 이 사상에서 유도한다."""
    return [n for n, _ in AXES]


def run(t, kinds, render=True, path=None):
    """축 전량을 돌려 (이름, 적발) 의 목록을 낸다."""
    out = []
    for nm, fn in AXES:
        if nm == RENDER_AXIS and not render:
            continue
        out.append((nm, fn(t, kinds, path)))
    return out


def ax_render(t, path=None):
    """머리 없는 브라우저로 띄워 계산된 양식과 표와 행을 재고 빈 보간을 찾는다.

    문턱을 상수로 두지 않고 이 산출에서 유도한 값을 기대로 받는다.
    """
    import tempfile, os, json
    want_tables = len(re.findall(r'<table>', t))
    want_rows = len(re.findall(r'<tr>', t))
    want_secs = len(re.findall(r'<section>', t))
    d = tempfile.mkdtemp()
    f = path or os.path.join(d, 'bp.html')
    if not path:
        open(f, 'w', encoding='utf-8').write(t)
    try:
        from playwright.sync_api import sync_playwright
    except Exception as e:
        return [('렌더링', '브라우저를 띄울 수 없다: %s' % e)]
    bad = []
    with sync_playwright() as pw:
        br = pw.chromium.launch(args=['--no-sandbox'])
        pg = br.new_page(viewport={'width': 1280, 'height': 900})
        pg.goto('file://' + os.path.abspath(f))
        pg.wait_for_load_state('load')
        got = pg.evaluate('''() => {
          const cs = getComputedStyle(document.querySelector('.sheet'));
          const body = getComputedStyle(document.body);
          return {
            tables: document.querySelectorAll('table').length,
            rows: document.querySelectorAll('tr').length,
            secs: document.querySelectorAll('section').length,
            borderLeft: cs.borderLeftWidth,
            borderStyle: cs.borderLeftStyle,
            maxw: cs.maxWidth,
            bg: body.backgroundColor,
            wordBreak: body.wordBreak,
            collapse: getComputedStyle(document.querySelector('table')).borderCollapse,
            text: document.body.innerText,
          };
        }''')
        br.close()
    if got['tables'] != want_tables:
        bad.append(('표', '%d · %d' % (got['tables'], want_tables)))
    if got['rows'] != want_rows:
        bad.append(('행', '%d · %d' % (got['rows'], want_rows)))
    if got['secs'] != want_secs:
        bad.append(('절', '%d · %d' % (got['secs'], want_secs)))
    # 양식이 먹었는지. 테두리와 폭과 표의 합침이 그 축이다
    if got['borderStyle'] != 'double' or got['borderLeft'] == '0px':
        bad.append(('종이의 테두리', '%s · %s' % (got['borderStyle'], got['borderLeft'])))
    if got['collapse'] != 'collapse':
        bad.append(('표의 합침', got['collapse']))
    if got['wordBreak'] != 'keep-all':
        bad.append(('낱말의 끊김', got['wordBreak']))
    if not got['maxw'].endswith('px'):
        bad.append(('종이의 폭', got['maxw']))
    # 렌더링된 본문의 빈 보간
    for pat, nm in ((r'<<[A-Z_]+>>', '자리표'), (r'\{[a-z_]+\}', '중괄호 보간'),
                    (r'\*\*', '별표'), (r'`', '백틱')):
        for m in re.finditer(pat, got['text']):
            bad.append((nm, got['text'][max(0, m.start()-25):m.end()+25]))
    return bad


# ── 음성 대조 ────────────────────────────────────────────────────────────

# 축마다 그 축이 잡아야 할 결손을 주입한다. 주입은 (축의 이름, 치환 좌변, 우변) 이고
# 좌변의 등장이 하나임을 단언한 뒤에 바꾼다
INJECT = [
    ('표의 칸', lambda t: (re.search(r'<tr><td', t).group(0),
                        '<tr><td class="x">군더더기</td><td')),
    ('굵은 표지의 짝', lambda t: ('<strong>', '<strong><strong>')),
    ('생성 수단의 문법 표지', lambda t: ('</div>\n</body>', '{gist}</div>\n</body>')),
    ('빈 보간', lambda t: ('</div>\n</body>', '<p><strong></strong></p></div>\n</body>')),
    ('양식의 괄호 짝', lambda t: ('</style>', '.x { color: red;\n</style>')),
    ('보간 뒤의 조사', lambda t: ('</div>\n</body>', '<p>축 열하나을 재었다</p></div>\n</body>')),
    ('앞 판의 조작을 주장하는 문면',
     lambda t: ('</div>\n</body>', '<p>그 조작을 이 자리가 병합했다</p></div>\n</body>')),
    ('표를 방향으로 지목하는 문면',
     lambda t: ('</div>\n</body>', '<p>아래의 표가 그 값을 든다</p></div>\n</body>')),
    ('렌더링의 양식과 표와 행과 빈 보간',
     lambda t: ('<style>', '<style>/*')),   # 양식을 통째로 주석으로 감싼다
]


def negative(t, kinds, path_of):
    """축마다 주입을 세워 전량이 한 번씩 터지는지 잰다.

    통과만 보고 그 축이 동작한다고 판단하지 않는다. 주입한 판에서 그 축만
    적발을 내고 다른 축이 함께 터지는 것은 받는다.
    """
    out = []
    for nm, mk in INJECT:
        pair = mk(t)
        if nm == '렌더링의 양식과 표와 행과 빈 보간':
            inj = t.replace('<style>', '<style>/*', 1).replace('</style>', '*/</style>', 1)
        else:
            lhs, rhs = pair
            assert t.count(lhs) >= 1, '%s 의 주입 좌변이 서지 않는다: %r' % (nm, lhs)
            inj = t.replace(lhs, rhs, 1)
        assert inj != t, '%s 의 주입이 문면을 바꾸지 않았다' % nm
        fn = dict(AXES)[nm]
        got = fn(inj, kinds, path_of(nm, inj) if path_of else None)
        out.append((nm, len(got)))
    bad = [nm for nm, n in out if n == 0]
    assert not bad, '음성 대조가 발화하지 않은 축: %r' % bad
    return out
