#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""회의록을 읽는 결정 세션의 상주 설비.

**이 모듈은 검증 스크립트가 부르지 않는다.** 회의록이 리포 밖의 프로젝트 문서로 살고 리포에
들어가지 않으므로, 결정 세션이 그 경로를 인자로 주어 이 모듈을 직접 부른다. 리포 밖의 경로를
상수로 들지 않으며, 원장은 이 모듈이 선 리포의 것을 읽는다.

**리포에 사는 사유는 승계다.** 이 설비가 결정 세션의 컨테이너에만 살던 동안에는 회차마다 다시
짜였고, 그 두 판의 경계가 갈려 한쪽이 다른 것을 재는 일이 되풀이됐다. 회의록의 꼴은 W-12 가
들고 이 코드가 그 꼴을 집행한다.

쓰는 꼴은 둘이다.

    python3 scripts/minutes.py report <회의록> [<회의록> ...]
    python3 scripts/minutes.py selftest

`report` 는 회의록마다 화두와 낙착과 선언을 뽑아 관문 둘의 좌변과 거처별 목록과 적발과 원장에
실을 몫을 JSON 으로 낸다. 적발 가운데 영을 요구하는 것이 하나라도 서거나 거처가 빈 낙착이 있으면
비영으로 끝난다. 낙착이 영인 화두는 관문 첫째의 후보로 내며, 다른 화두의 줄이 그 화두를 답한다고
밝혔는지는 자유 서술이라 사람이 읽는다. `selftest` 는 이 파일이 든 합성 회의록에 축마다 어긋남을
주입해 적발이 서는지와 꼴에 맞는 문면에서 서지 않는지를 본다.
"""
import ast, json, re, sys, unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LEDGER_DIR = ROOT / "docs" / "decisions"

# ---- 변의 가름. 표기의 고정은 접은 변, 구절의 실재는 공백을 전량 지운 변 ----
def fold(s):            # 공백을 하나로 접는다
    return re.sub(r'\s+', ' ', s).strip()
def squeeze(s):         # 공백을 전량 지운다
    return re.sub(r'\s+', '', s)

def assert_edge_shape(path=None):
    """두 변의 가름을 측정기가 자기 소스에서 단언한다."""
    src = open(path or __file__, encoding='utf-8').read()
    tree = ast.parse(src)
    fns = {n.name for n in ast.walk(tree) if isinstance(n, ast.FunctionDef)}
    assert 'fold' in fns and 'squeeze' in fns, '두 변의 함수가 함께 서지 않는다'
    assert fold(' a\n b ') == 'a b', '접기가 줄바꿈을 공백 하나로 바꾸지 않는다'
    assert squeeze('「가」 를') == '「가」를', '지우기가 공백을 전량 지우지 않는다'
    # 구절의 실재를 재는 자리가 squeeze 를 쓰는지
    for n in ast.walk(tree):
        if isinstance(n, ast.FunctionDef) and n.name == 'phrase_present':
            names = {x.id for x in ast.walk(n) if isinstance(x, ast.Name)}
            assert 'squeeze' in names, '구절의 실재를 재는 자리가 접은 변을 쓴다'
            assert 'fold' not in names, '구절의 실재를 재는 자리가 접은 변을 쓴다'
            break
    else:
        raise AssertionError('구절의 실재를 재는 함수가 없다')
    return True

def phrase_present(phrase, haystack):
    return squeeze(phrase) in squeeze(haystack)

# ---- 선언의 네 꼴. 어간에 활용 어미를 붙인 집합 ----
NUM = r'`낙착-(\d+)-\((\d+)\)`'
DECL_PATTERNS = {
    'amend_gist':  re.compile(NUM + r'\s*의 요지를 「([^」]+)」\s*로 고(?:친다|치고|쳐|치며|침)'),
    'amend_kind':  re.compile(NUM + r'\s*의 갈래를 「([^」]+)」\s*로 고(?:친다|치고|쳐|치며|침)'),
    'strip_home':  re.compile(NUM + r'\s*의 거처에서 「([^」]+)」\s*를 걷(?:는다|고|어|으며|기)'),
    'retire':      re.compile(NUM + r'\s*[을를]\s*폐기(?:한다|하고|하며|하여|해|함)'),
    'reinforce':   re.compile(NUM + r'\s*을 보강(?:한다|하고|하며|하여|해|함)'),
}
# 꼴에 가까우나 어긋난 줄을 잡는 그물. 어간 + 활용 어미
_EOM = r'(?:한다|하고|하며|하여|해|함|시킨다|시키고|시키며|시켜|시킴|해준다|해주고|해줘)'
DECL_VERB = re.compile(r'(?:고(?:친다|치고|쳐|치며|침|쳐준다|쳐주고|쳐줘)'
                       r'|걷(?:는다|고|어|으며|기|어치운다|어치우고)'
                       r'|폐기' + _EOM + r'|보강' + _EOM + r')')
AXIS_AFTER = re.compile(NUM + r'\s*의 (?:요지|갈래|거처)')   # 축을 드는 자리

HEAD = re.compile(r'^\*\*' + NUM, re.M)
TOPIC = re.compile(r'^#{2,3} \`(화두-(\d+))\`(.*)$', re.M)   # 제목의 두 수준
HR = re.compile(r'^---\s*$', re.M)
BOLD = re.compile(r'\*\*(.+?)\*\*', re.S)
TICK = re.compile(r'`[^`]*`')

KINDS = ('decisions', 'deferred', 'rejected', 'retirements')
HOMES = [
    '결정 레지스터','이연 레지스터','기각 레지스터','폐기 레지스터',
    '세션 지시','부록','CLAUDE.md','docs/baseline.md','docs/arcs.json',
    '뭉치 인벤토리','읽기 대기열','추출 기록','페이즈 closure','청사진의 미전사분',
    'docs/decisions/SPEC.md','형식층의 선언','검증 스크립트','설비 코드','지속적 통합 워크플로',
    '항해도 본편','항해도 부록','어디에도 가지 않음',
]
# 긴 이름을 먼저 보아 항해도 부록이 부록으로도 세어지지 않게 한다. 거처를 더하는 회차는
# 이 목록과 아래의 리포 안 목록을 함께 본다
HOMES_ORDERED = sorted(HOMES, key=len, reverse=True)
IN_REPO = {'결정 레지스터','이연 레지스터','기각 레지스터','폐기 레지스터','CLAUDE.md',
           'docs/baseline.md','docs/arcs.json','뭉치 인벤토리','읽기 대기열','추출 기록',
           'docs/decisions/SPEC.md','형식층의 선언','검증 스크립트','지속적 통합 워크플로'}

def _split_paragraphs(text):
    return re.split(r'\n\s*\n', text)

def parse(text):
    """화두와 낙착과 선언을 뽑는다. 선언 문단은 낙착의 몸통으로 받지 않는다."""
    topics = [{'num': int(m.group(2)), 'name': m.group(1), 'title': m.group(3).strip(),
               'pos': m.start()} for m in TOPIC.finditer(text)]
    # 경계: 낙착 머리 · 화두 머리 · 가로줄 · 파일 끝
    bounds = sorted({m.start() for m in HEAD.finditer(text)}
                    | {m.start() for m in TOPIC.finditer(text)}
                    | {m.start() for m in HR.finditer(text)}
                    | {len(text)})
    rows, decls, near = [], [], []
    for m in HEAD.finditer(text):
        s = m.start()
        e = min([b for b in bounds if b > s])
        chunk = text[s:e]
        first_para = _split_paragraphs(chunk)[0]
        key = (int(m.group(1)), int(m.group(2)))
        # 선언 문단인가. 첫 굵은 구간이 그 번호 뒤에 고정된 축을 바로 드는가
        fb = fold(BOLD.search(first_para).group(1)) if BOLD.search(first_para) else ''
        hit = None
        for name, pat in DECL_PATTERNS.items():
            if name == 'retire':
                continue
            mm = pat.search(fb)
            if mm and fb.startswith('`낙착-%d-(%d)`' % (int(mm.group(1)), int(mm.group(2)))):
                hit = (name, (int(mm.group(1)), int(mm.group(2))), mm.group(3))
                break
        if hit:
            decls.append({'kind': hit[0], 'target': hit[1], 'arg': hit[2],
                          'pos': s, 'text': fb})
            continue
        rows.append({'key': key, 'head': fold(first_para), 'body': chunk, 'pos': s})
    # 폐기 선언: 굵은 구간에서 낙착 번호 바로 뒤에 목적격 조사와 「폐기한다」가 오는 고정된 꼴이다.
    # 번호와 그 낱말 사이에 다른 글자를 허용하면 요지가 그 낱말을 통상의 뜻으로 쓴 낙착이 자기를
    # 폐기한 것으로 읽히고, 다른 낙착을 폐기하는 줄도 가장 왼쪽의 번호를 대상으로 낸다.
    for mb in BOLD.finditer(text):
        fb = fold(mb.group(1))
        mm = DECL_PATTERNS['retire'].search(fb)
        if mm:
            decls.append({'kind': 'retire', 'target': (int(mm.group(1)), int(mm.group(2))),
                          'arg': None, 'pos': mb.start(), 'text': fb})
    # 보강 선언
    for mb in BOLD.finditer(text):
        fb = fold(mb.group(1))
        mm = DECL_PATTERNS['reinforce'].search(fb)
        if mm:
            decls.append({'kind': 'reinforce', 'target': (int(mm.group(1)), int(mm.group(2))),
                          'arg': None, 'pos': mb.start(), 'text': fb})
    return topics, rows, decls

def group(rows):
    """번호가 같은 여러 줄을 합집합으로 묶는다. 덮지 않는다."""
    g = {}
    for r in rows:
        k = r['key']
        if k not in g:
            g[k] = {'key': k, 'heads': [], 'bodies': [], 'pos': r['pos']}
        g[k]['heads'].append(r['head']); g[k]['bodies'].append(r['body'])
    return g

def _bold_segments(body):
    """굵은 구간을 문장으로 갈라 낸다."""
    out = []
    for mb in BOLD.finditer(body):
        for sent in re.split(r'(?<=다)\.\s*', fold(mb.group(1))):
            if sent.strip():
                out.append(sent.strip())
    return out

def read_kind_home(g):
    """갈래와 거처를 뽑는다. 낙착 번호로 시작하는 굵은 구간은 유니버스 밖."""
    for k, v in g.items():
        kinds, homes, unread = [], [], []
        for body in v['bodies']:
            for mb in BOLD.finditer(body):
                fb = fold(mb.group(1))
                if re.match(r'^`낙착-\d+-\(\d+\)`', fb):
                    continue
                for sent in re.split(r'(?<=다)\.\s*', fb):
                    sq = squeeze(sent)
                    if '갈래는' in sq:
                        if '없음.원장표지묶음의entry가받는다' in sq:
                            kinds.append('흡수:원장표지묶음')
                        elif '없음.아크개막entry가받는다' in sq:
                            kinds.append('흡수:아크개막')
                        elif re.search(r'없음\.`낙착-\d+(?:-\(\d+\))?`의entry가받는다', sq):
                            # 흡수의 꼴과 낙착을 지목하는 고정 꼴이 이 자리에서 부딪히므로 둘을 함께 받는다
                            kinds.append('흡수:낙착')
                        elif '갈래는「없음」' in sq:
                            kinds.append('없음')
                        else:
                            hit = [kd for kd in KINDS if '`%s`' % kd in sent]
                            kinds.extend(hit)
                            if not hit:
                                unread.append(sent)
                    if '거처는' in sq:
                        for h in HOMES_ORDERED:
                            if squeeze(h) in sq and not any(squeeze(h) in squeeze(x) and h != x
                                                            for x in homes):
                                homes.append(h)
        v['kind'] = kinds[0] if kinds else None
        v['kinds'] = kinds
        v['kind_unread'] = unread
        v['homes'] = homes
        mb = BOLD.search(v['bodies'][0])
        v['gist'] = fold(mb.group(1)) if mb else v['heads'][0]   # 요지 하나. 근거는 밖
    return g

def apply_decls(g, decls):
    """뽑기 뒤에 적용한다. 걷어서 거처가 비면 터뜨린다."""
    applied, ghosts = [], []
    for d in sorted(decls, key=lambda x: x['pos']):
        t = d['target']
        if d['kind'] in ('retire', 'reinforce'):
            if t not in g:
                ghosts.append(d); continue
            if d['kind'] == 'retire':
                g[t]['retired'] = True
            applied.append(d); continue
        if t not in g:
            ghosts.append(d); continue
        if d['kind'] == 'amend_kind':
            arg = d['arg']
            if squeeze(arg) == squeeze('없음. 원장 표지 묶음의 entry 가 받는다'):
                g[t]['kind'] = '흡수:원장표지묶음'
            elif squeeze(arg) == squeeze('없음. 아크 개막 entry 가 받는다'):
                g[t]['kind'] = '흡수:아크개막'
            elif squeeze(arg) == '없음':
                g[t]['kind'] = '없음'
            else:
                g[t]['kind'] = arg
        elif d['kind'] == 'amend_gist':
            g[t]['gist'] = d['arg']
        elif d['kind'] == 'strip_home':
            before = list(g[t]['homes'])
            g[t]['homes'] = [h for h in before if squeeze(h) != squeeze(d['arg'])]
            if not g[t]['homes']:
                raise AssertionError('걷어서 거처가 비었다: %s' % (t,))
        applied.append(d)
    return g, applied, ghosts

# ---- 적발 ----
ONE_CHAR_NUM = None  # 한 글자 수사는 유니버스 밖. len(w)==1 로 유도한다
NUMERALS = ['하나','둘','셋','넷','다섯','여섯','일곱','여덟','아홉','열','열하나','열둘','열셋',
            '열넷','열다섯','열여섯','열일곱','열여덟','열아홉','스물','스물하나','서른','마흔',
            '쉰','예순','일흔','여든','아흔','백']
DET = ['한','두','세','네','다섯','여섯','일곱','여덟','아홉','열']   # 수관형사
UNITS = ['바이트','줄','개','건','칸','행','번','차례']   # 측정 단위만. 관용은 밖
NEG_IDIOM = re.compile(r'(?:하나도|한 번도|한 자리도|하나 없|한 글자도)')
# 「이·그·저」는 지시 관형사로도 서고 뒤에 공백이 오는 꼴이 둘을 가르지 못하므로 유니버스 밖
PARTICLE_START = re.compile(r'^(?:은|는|가|을|를|의|에|도|만|와|과|로|으로|에서|에게|부터|까지)\s')

def detect(g, decls, text, ghosts=()):
    """적발 전량. 영을 요구하는 것과 전수로 읽는 것을 가른다."""
    out = {k: [] for k in ('near_decl','gist_count','kind_none_in_repo','reinforce_in_first',
                           'reinforce_gist_refs','gist_particle','decisions_only','ghost_decl',
                           'kind_unread')}
    # 폐기된 줄과 꼴에 맞는 선언이 든 짝은 유니버스 밖
    ok_pairs = {(d['target'], d['kind']) for d in decls}
    retired = {k for k, v in g.items() if v.get('retired')}
    # (1) 꼴에 가까우나 어긋난 줄. 굵은 구간을 문장으로 갈라 잰다
    heads = {fold(h) for v in g.values() for h in v['heads']}
    for mb in BOLD.finditer(text):
        fb = fold(mb.group(1))
        for sent in re.split(r'(?<=다)\.\s*', fb):
            sent = sent.strip()
            if not sent or not DECL_VERB.search(sent):
                continue
            nums = re.findall(NUM, sent)
            if not nums:
                continue
            # 유니버스는 축을 드는 자리와 선언의 낱말을 쓴 자리의 합집합이고
            # 거기서 낙착의 머리를 뺀다. 머리는 자기 번호 뒤에 바로 요지가 오고
            # 남은 구간에 다른 낙착의 번호가 서지 않는 것이다.
            if not AXIS_AFTER.search(sent):
                selfnum = re.match(r'^`낙착-(\d+)-\((\d+)\)`', sent)
                if selfnum and not re.search(NUM, sent[selfnum.end():]):
                    continue
            if any(p.search(sent) for p in DECL_PATTERNS.values()):
                continue
            # 대상은 선언이 고치거나 걷거나 폐기하거나 보강하는 낙착이다. 보강의 꼴은 그 선언을 쓴
            # 낙착이 먼저 서고 대상이 보강의 낱말 바로 앞에 서므로 그 자리의 번호를 대상으로 읽는다.
            # 첫 번호로 읽으면 꼴에 맞게 다시 쓴 보강 선언이 어긋난 줄을 걸러 내지 못한다.
            rf = re.search(NUM + r'\s*[을를]?\s*보강', sent)
            tn = rf.groups() if rf else nums[0]
            tgt = (int(tn[0]), int(tn[1]))
            if tgt in retired or any(tgt == t for t, _ in ok_pairs):
                continue
            out['near_decl'].append(sent)
    # (2) 요지가 계수를 든 자리. 백틱 구간을 걷고 한 글자 수사를 뺀다
    for k, v in sorted(g.items()):
        gist = TICK.sub(' ', v['gist'])
        hits = []
        for w in NUMERALS:
            if len(w) == 1:          # 한 글자 수사를 뺀다
                continue
            if re.search(w + r'(?![가-힣])', gist) or re.search(w + r'(?=[으로은는이가을를])', gist):
                hits.append(w)
        for d in DET:
            for u in UNITS:
                for mm in re.finditer(d + r'\s*' + u + r'(?:[은는이가을를의로와과도만]|\s|$|\.)', gist):
                    if NEG_IDIOM.search(gist[max(0, mm.start()-4):mm.end()+4]):
                        continue       # 부정의 관용은 유니버스 밖
                    hits.append(d + ' ' + u)
        if re.search(r'\d', gist):
            hits.append('아라비아 숫자')
        if hits:
            out['gist_count'].append((k, sorted(set(hits)), gist[:120]))
    # (3) 갈래가 「없음」인데 거처가 리포 안. closure 와 회차 기록은 밖
    for k, v in sorted(g.items()):
        if v['kind'] in ('없음',) or (v['kind'] or '').startswith('흡수'):
            bad = [h for h in v['homes'] if h in IN_REPO]
            if bad and v['kind'] == '없음':
                out['kind_none_in_repo'].append((k, bad))
    # (4) 보강·흡수 선언이 첫 굵은 문장에 선 것
    for k, v in sorted(g.items()):
        mb0 = BOLD.search(v['bodies'][0])
        fb0 = fold(mb0.group(1)) if mb0 else ''
        if (DECL_PATTERNS['reinforce'].search(fb0)
                or '원장 표지 묶음의 entry 가 받는다' in fb0
                or '아크 개막 entry 가 받는다' in fb0
                or re.search(r'`낙착-\d+`의entry가받는다', squeeze(fb0))):
            out['reinforce_in_first'].append((k, fb0[:140]))
        # 보강 선언을 든 낙착. 그 선언이 그 낙착의 몸통에 서는 쪽이다
        own = [d for d in decls
               if d['kind'] == 'reinforce'
               and any(d['text'] in fold(b) for b in v['bodies'])]
        if own:
            rest = re.sub(r'^`낙착-\d+-\(\d+\)`\s*', '', v['gist'])
            if re.search(NUM, rest) or DECL_PATTERNS['reinforce'].search(rest):
                out['reinforce_gist_refs'].append((k, rest[:140]))
    # (4-a) 갈래를 드는 문장인데 고정된 꼴의 어느 것으로도 읽히지 않은 자리
    for k, v in sorted(g.items()):
        for sent in v.get('kind_unread', ()):
            if k in retired:
                continue
            out['kind_unread'].append((k, sent[:70]))
    # (5) 요지가 조사로 시작
    for k, v in sorted(g.items()):
        body = re.sub(r'^`낙착-\d+-\(\d+\)`\s*', '', v['gist'])
        if PARTICLE_START.match(body):
            out['gist_particle'].append((k, body[:60]))
    # (6) 갈래가 레지스터인데 거처가 결정 레지스터 하나뿐
    for k, v in sorted(g.items()):
        if v['kind'] in KINDS and v['homes'] == ['결정 레지스터']:
            out['decisions_only'].append((k, v['gist'][:100]))
    for d in ghosts:
        out['ghost_decl'].append((d['target'], d['text'][:100]))
    return out

# ---- 회의록 하나를 읽는다 ----
# 아크 이름은 영문 소문자로 시작하고 그 뒤에 숫자를 들 수 있다. 같은 성격의 아크를 이름 끝의
# 숫자로 잇는 꼴이 서 있으므로 소문자만 받으면 그 아크의 회의록 머리가 읽히지 않는다
PHASE_HEAD = re.compile(r'^# 회의록 — `([a-z][a-z0-9]*-\d+)`', re.M)
SELFNUM = re.compile(r'^`낙착-\d+-\(\d+\)`\s*')
# 영을 요구하는 적발. 요지의 계수와 결정 레지스터 하나뿐인 거처는 사람이 읽는 목록이다
ZERO_AXES = ('near_decl', 'kind_none_in_repo', 'reinforce_in_first', 'reinforce_gist_refs',
             'gist_particle', 'ghost_decl', 'kind_unread')


def topic_numbers(topics):
    """화두 제목의 번호가 유일하고 단조 증가하는지. 낙착 번호의 둘째 자리는 보강이 되쓰므로 밖이다."""
    nums = [t['num'] for t in topics]
    dup = sorted({n for n in nums if nums.count(n) > 1})
    desc = [(a, b) for a, b in zip(nums, nums[1:]) if b <= a]
    return {'count': len(nums), 'duplicate': dup, 'not_increasing': desc}


def read(text):
    """뽑기와 묶기와 선언의 적용을 그 순서로 돈다. 선언은 묶은 뒤에 적용한다."""
    topics, rows, decls = parse(text)
    g = group(rows)
    g = read_kind_home(g)
    g, applied, ghosts = apply_decls(g, decls)
    return topics, g, decls, applied, ghosts


def gates(topics, g):
    """관문 둘의 좌변. 폐기된 낙착은 거처 대조의 유니버스 밖이다."""
    live = {k: v for k, v in g.items() if not v.get('retired')}
    with_decision = {k[0] for k in live}
    open_candidates = [t['name'] for t in topics if t['num'] not in with_decision]
    no_home = ['낙착-%d-(%d)' % k for k, v in sorted(live.items()) if not v['homes']]
    by_home = {}
    for k, v in sorted(live.items()):
        for h in v['homes']:
            by_home.setdefault(h, []).append('낙착-%d-(%d)' % k)
    return {'open_candidates': open_candidates, 'no_home': no_home,
            'by_home': {h: by_home[h] for h in HOMES if h in by_home},
            'live': len(live), 'retired': len(g) - len(live)}


# ---- 원장 ----
def ledger_live():
    """레지스터마다 살아 있는 항목의 진술 → 식별자. 폐기 레코드의 대상이 죽은 항목이다."""
    regs = {}
    for name in KINDS:
        doc = json.loads((LEDGER_DIR / ('%s.json' % name)).read_text(encoding='utf-8'))
        regs[name] = doc[name]
    dead = {str(e.get('target')) for e in regs['retirements']}
    out = {}
    for name, entries in regs.items():
        out[name] = {fold(str(e.get('statement') or '')): str(e['id'])
                     for e in entries if str(e['id']) not in dead and e.get('statement')}
    return out


def statement_of(gist):
    """요지에서 원장의 진술을 유도한다. 자기 낙착 번호를 걷고 말미의 마침표를 뗀다."""
    body = SELFNUM.sub('', gist or '').strip()
    if not body:
        raise AssertionError('요지가 비었다')
    if PARTICLE_START.match(body):
        raise AssertionError('요지가 조사로 시작한다: %r' % body[:40])
    if not re.search(r'(?:다|까|라)\.?$', body):
        raise AssertionError('요지가 종결어미로 끝나지 않는다: %r' % body[-40:])
    return body.rstrip('.')


def to_ledger(g, live):
    """갈래가 레지스터인 살아 있는 낙착마다 그 진술이 원장에 이미 섰는지를 가른다."""
    recorded, pending, manual = [], [], []
    for k, v in sorted(g.items()):
        if v.get('retired') or v.get('kind') not in KINDS:
            continue
        tag = '낙착-%d-(%d)' % k
        if v['kind'] == 'rejected':
            manual.append(tag)          # 기각 레지스터의 진술은 요지에서 유도되지 않는다
            continue
        st = statement_of(v['gist'])
        hit = live[v['kind']].get(fold(st))
        (recorded if hit else pending).append({'id': tag, 'kind': v['kind'], 'entry': hit,
                                                'statement': st})
    return {'recorded': recorded, 'pending': pending, 'manual': manual}


def report(paths):
    live = ledger_live()
    out, bad = [], 0
    for p in paths:
        text = Path(p).read_text(encoding='utf-8')
        m = PHASE_HEAD.search(text)
        topics, g, decls, applied, ghosts = read(text)
        found = detect(g, decls, text, ghosts)
        nums = topic_numbers(topics)
        gt = gates(topics, g)
        led = to_ledger(g, live)
        zero = {a: found[a] for a in ZERO_AXES if found[a]}
        bad += len(zero) + len(gt['no_home']) + len(nums['duplicate']) + len(nums['not_increasing'])
        out.append({
            'file': Path(p).name, 'phase': m.group(1) if m else None,
            'topics': nums, 'decisions': len(g), 'declarations_applied': len(applied),
            'gates': gt, 'to_ledger': led,
            'findings_zero_required': {a: len(found[a]) for a in ZERO_AXES},
            'findings_to_read': {'gist_count': found['gist_count'],
                                 'decisions_only': found['decisions_only']},
            'violations': zero,
            'decisions_detail': [{'id': '낙착-%d-(%d)' % k, 'kind': v.get('kind'),
                                  'homes': v['homes'], 'retired': bool(v.get('retired')),
                                  'gist': SELFNUM.sub('', v['gist'])}
                                 for k, v in sorted(g.items())]})
    print(json.dumps(out, ensure_ascii=False, indent=1))
    return 1 if bad else 0


# ---- 음성 대조 ----
SELFTEST_BASE = '''# 회의록 — `test-1`

---

## `화두-1` 시험 화두

**`낙착-1-(1)` 조달형 불일치의 크기에 전순서가 서지 않는다는 구멍을 폐기하고 범위 경계의 판정을
결정으로 세운다.** 몸통 문장이다.
**갈래는 `retirements` 다. 거처는 폐기 레지스터다.**

**`낙착-1-(2)` 답 함수를 경로 목록과 잔액 함수를 받아 조립하는 꼴로 세운다.** 몸통 문장이다.
**갈래는 `decisions` 다. 거처는 형식층의 선언이고 관측층이다.**

**`낙착-1-(3)` 조작의 목록을 대장이 든다.** 몸통 문장이다.
**갈래는 「없음」이다. 거처는 페이즈 closure 다.**

**`낙착-1-(4)` 구간을 둘로 가른다.** 몸통 문장이다. **`낙착-1-(4)` 가 `낙착-1-(3)` 을 보강한다.**
**갈래는 「없음」이다. 거처는 페이즈 closure 다.**

**`낙착-1-(5)` 집행 증분이 증명을 채운다.** 몸통 문장이다.
**갈래는 「없음」이다. 거처는 「어디에도 가지 않음」이다.**

**`낙착-1-(6)` 시험으로 세운 낙착이다.** 몸통 문장이다.
**갈래는 「없음」이다. 거처는 페이즈 closure 다.**

**`낙착-1-(7)` 설비의 꼴을 고친다.** 몸통 문장이다.
**갈래는 「없음」이다. 거처는 부록과 설비 코드다.**

**`낙착-1-(8)` 아크를 여는 결정이 받는 낙착이다.** 몸통 문장이다.
**갈래는 「없음. 아크 개막 entry 가 받는다」이다. 거처는 결정 레지스터다.**

---

## 선언

**`낙착-1-(2)` 의 갈래를 「없음. 원장 표지 묶음의 entry 가 받는다」 로 고친다.**

**`낙착-1-(6)` 을 폐기한다.**
'''


def _run(text):
    topics, g, decls, applied, ghosts = read(text)
    return detect(g, decls, text, ghosts), g


def _retired(text):
    _, g = _run(text)
    return {k for k, v in g.items() if v.get('retired')}


def selftest():
    assert assert_edge_shape(__file__)
    base = SELFTEST_BASE
    d0, g0 = _run(base)
    # 밑판의 적발은 영이어야 대조가 선다
    assert all(not v for k, v in d0.items() if k not in ('decisions_only', 'gist_count')), d0
    # 설비 코드를 든 낙착이 그 낱말을 거처로 받고, 갈래가 「없음」이어도 적발이 서지 않는다
    assert '설비 코드' in g0[(1, 7)]['homes'] and '부록' in g0[(1, 7)]['homes'], g0[(1, 7)]['homes']
    # 아크를 여는 결정 entry 가 받는 흡수의 꼴을 갈래 자리에서 읽고, 같은 꼴을 고침 선언으로도 받는다
    assert g0[(1, 8)]['kind'] == '흡수:아크개막', g0[(1, 8)]['kind']
    _, g8 = _run(base.replace('**`낙착-1-(6)` 을 폐기한다.**',
                              '**`낙착-1-(6)` 을 폐기한다.**\n\n'
                              '**`낙착-1-(7)` 의 갈래를 「없음. 아크 개막 entry 가 받는다」 로 고친다.**'))
    assert g8[(1, 7)]['kind'] == '흡수:아크개막', g8[(1, 7)]['kind']
    axes = [
        ('고침 선언의 꼴', lambda t: t.replace(
            '`낙착-1-(2)` 의 갈래를 「없음. 원장 표지 묶음의 entry 가 받는다」 로 고친다.',
            '`낙착-1-(2)` 의 갈래를 「없음. 원장 표지 묶음의 entry 가 받는다」 으로 고쳐준다.'),
         'near_decl'),
        ('걷기 선언의 꼴', lambda t: t.replace(
            '**`낙착-1-(4)` 가 `낙착-1-(3)` 을 보강한다.**',
            '**`낙착-1-(4)` 가 `낙착-1-(3)` 의 거처에서 「페이즈 closure」 걷어치운다.**'),
         'near_decl'),
        ('폐기 선언의 꼴', lambda t: t.replace(
            '**`낙착-1-(4)` 가 `낙착-1-(3)` 을 보강한다.**',
            '**`낙착-1-(4)` 가 `낙착-1-(3)` 을 폐기시킨다.**'),
         'near_decl'),
        ('보강 선언의 꼴', lambda t: t.replace(
            '**`낙착-1-(4)` 가 `낙착-1-(3)` 을 보강한다.**',
            '**`낙착-1-(4)` 가 `낙착-1-(3)` 를 보강시킨다.**'),
         'near_decl'),
        ('보강을 첫 굵은 구간에', lambda t: t.replace(
            '`낙착-1-(5)` 집행 증분이 증명을',
            '`낙착-1-(5)` `낙착-1-(3)` 을 보강한다. 집행 증분이 증명을'),
         'reinforce_in_first'),
        ('요지가 조사로 시작', lambda t: t.replace(
            '`낙착-1-(3)` 조작의 목록을', '`낙착-1-(3)` 를 조작의 목록을'),
         'gist_particle'),
        ('갈래 없음인데 거처가 리포 안', lambda t: t.replace(
            '**갈래는 「없음」이다. 거처는 「어디에도 가지 않음」이다.**',
            '**갈래는 「없음」이다. 거처는 `docs/arcs.json` 이다.**', 1),
         'kind_none_in_repo'),
        ('없는 낙착을 드는 선언', lambda t: t.replace(
            '**`낙착-1-(2)` 의 갈래를', '**`낙착-99-(1)` 의 갈래를', 1),
         'ghost_decl'),
        ('요지가 실물의 계수를', lambda t: t.replace(
            '`낙착-1-(3)` 조작의 목록을', '`낙착-1-(3)` 선언 열여섯이 드는 조작의 목록을'),
         'gist_count'),
        ('아크 개막 흡수의 꼴', lambda t: t.replace(
            '「없음. 아크 개막 entry 가 받는다」이다', '「없음. 아크 개막의 entry 가 받는다」이다'),
         'kind_unread'),
        ('아크 개막 흡수를 첫 굵은 구간에', lambda t: t.replace(
            '`낙착-1-(5)` 집행 증분이 증명을',
            '`낙착-1-(5)` 아크 개막 entry 가 받는다. 집행 증분이 증명을'),
         'reinforce_in_first'),
    ]
    rows, ok = [], True
    for name, mut, axis in axes:
        t = mut(base)
        assert t != base, '주입이 문면을 바꾸지 않았다: %s' % name
        try:
            n1 = len(_run(t)[0][axis])
        except AssertionError:
            n1 = -1                     # 터뜨리는 것도 발화다
        n0 = len(d0[axis])
        fired = n1 > n0 or n1 == -1
        rows.append((name, axis, n0, n1, '발화' if fired else '미발화'))
        ok = ok and fired
    # 폐기 선언을 읽는 축. 요지가 그 낱말을 통상의 뜻으로 쓴 낙착이 자기를 폐기한 것으로 읽히지 않는다
    r0 = _retired(base)
    ret_ok = r0 == {(1, 6)}
    r1 = _retired(base.replace('**`낙착-1-(6)` 을 폐기한다.**',
                               '**`낙착-1-(5)` 가 `낙착-1-(6)` 을 폐기한다.**'))
    ret_ok = ret_ok and r1 == {(1, 6)}
    saved = DECL_PATTERNS['retire']
    DECL_PATTERNS['retire'] = re.compile(NUM + r'[^*]{0,80}?폐기(?:한다|하고|하며|하여|해|함)')
    try:
        r2 = _retired(base)
    finally:
        DECL_PATTERNS['retire'] = saved
    ret_fired = r2 != {(1, 6)}
    rows.append(('폐기 대상의 읽기', 'retired', len(r0), len(r2), '발화' if ret_fired else '미발화'))
    ok = ok and ret_ok and ret_fired
    # 꼴을 벗어난 보강 선언 아래에 꼴에 맞는 선언을 다시 쓴 판은 적발이 서지 않고, 다시 쓰지 않은
    # 판은 선다. 보강의 대상을 첫 번호로 읽던 판은 앞의 판에서도 적발을 냈다
    one = '**`낙착-1-(4)` 가 `낙착-1-(3)` 을 보강한다.**'
    bad = '**`낙착-1-(4)` 가 `낙착-1-(3)` 를 보강한다.**'
    n_fix = len(_run(base.replace(one, bad + ' 꼴에 맞게 다시 쓴다. ' + one))[0]['near_decl'])
    n_bad = len(_run(base.replace(one, bad))[0]['near_decl'])
    fix_ok = n_fix == len(d0['near_decl']) and n_bad > len(d0['near_decl'])
    rows.append(('보강 선언을 다시 쓴 판', 'near_decl', n_bad, n_fix, '발화' if fix_ok else '미발화'))
    ok = ok and fix_ok
    # 화두 번호의 겹침
    tp = parse(base.replace('## `화두-1` 시험 화두', '## `화두-1` 시험 화두\n\n## `화두-1` 겹친 화두'))[0]
    dup_fired = bool(topic_numbers(tp)['duplicate'])
    rows.append(('화두 번호의 겹침', 'topics', 0, 1 if dup_fired else 0, '발화' if dup_fired else '미발화'))
    ok = ok and dup_fired
    # 회의록의 머리. 이름 끝에 숫자를 든 아크의 머리를 읽고 대문자로 시작하는 이름은 받지 않으며,
    # 소문자만 받던 패턴은 그 머리를 읽지 못한다
    hd = '# 회의록 — `housekeeper1-1`\n'
    old_head = re.compile(r'^# 회의록 — `([a-z]+-\d+)`', re.M)
    mh = PHASE_HEAD.search(hd)
    ph_ok = (mh is not None and mh.group(1) == 'housekeeper1-1' and old_head.search(hd) is None
             and PHASE_HEAD.search('# 회의록 — `Funding-1`\n') is None)
    rows.append(('머리의 아크 이름', 'phase_head', 0, 1 if ph_ok else 0, '발화' if ph_ok else '미발화'))
    ok = ok and ph_ok
    # 역방향: 가드를 뜻하지 않는 문면만 더했을 때 적발이 줄지 않는다
    pad = base + '\n\n보강과 고침과 걷기와 폐기를 논의한 산문이다. 조달처와 거처와 갈래를 든다.\n'
    d2, _ = _run(pad)
    neg_ok = all(len(d2[k]) == len(d0[k]) for k in d0) and _retired(pad) == r0
    for r in rows:
        print('  %-24s %-20s 원판 %2d → 주입 %2d  %s' % r)
    print('  정방향 전량 발화:', ok)
    print('  역방향 미발화(산문만 더함, 적발 불변):', neg_ok)
    return 0 if (ok and neg_ok) else 1


def main(argv):
    if len(argv) >= 3 and argv[1] == 'report':
        return report(argv[2:])
    if len(argv) == 2 and argv[1] == 'selftest':
        return selftest()
    print('쓰는 꼴: python3 scripts/minutes.py report <회의록> [...] | selftest', file=sys.stderr)
    return 2


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
