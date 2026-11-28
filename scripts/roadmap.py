"""항해도의 본편과 부록을 내는 생성기.

항해도는 사용자가 길을 잃지 않으려고 읽는 메모이며 리포에 넣지 않는다. 본편은 향하는 곳과 현 위치와
열려 있는 아크를 들고, 부록은 그 셋에 들지 않는 구멍의 재고와 설비의 대기와 수취인이 사용자인 과제를
받는다. 이 생성기는 두 문서의 값을 한 커밋을 풀어 놓은 사본에서 전량 유도하고, 리포 실물에서 유도될
상대가 없는 것만 입력으로 받아 그 출처를 문면으로 든다. 양식과 머리는 앞 판에서 그대로 떼어 쓰고
머리의 제목에서 판의 번호만 유도해 바꾸며, 앞 판이 든 절을 새 판이 빠뜨리지 않는지를 그 앞 판과 맞대어
잰다. 축 설비의 축 전량으로 두 산출을 재고 그 전량에서 적발이 영일 때에만 파일을 쓰며, 축마다 음성
대조를 돌린다.

리포를 읽는 자리를 한 커밋을 풀어 놓은 사본으로 가둔다. 그 커밋은 원격 추적 머리이거나 그 조상이어야
하고, 같은 커밋을 주면 커밋이 쌓인 뒤에 다시 돌려도 같은 산출이 선다. 리포 밖의 문서는 전부 인자로
받고 리포 밖의 경로를 상수로 들지 않는다.

쓰는 꼴:
  python3 scripts/roadmap.py --commit <커밋> --prev <앞 판 본편> --prev-appendix <앞 판 부록> \\
      --tasks <과제 입력 JSON> --rules <세션 지시> --rules <부록> \\
      --out <본편 경로> --out-appendix <부록 경로> [--dry]

과제 입력 JSON 은 {"tasks": [{"task", "what", "clause", "phrase"}], "facility": [{"what", "why"}]} 이다.
행마다 그 행이 딛는 조항의 구절을 phrase 로 들고, 이 생성기가 그 구절을 규율 문서에서 되찾는다.
"""
import argparse
import hashlib
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import bp_axes as A  # noqa: E402
import bp_measure as B  # noqa: E402
import check_cqfin as Q  # noqa: E402
import morph  # noqa: E402
import wiki_common as WC  # noqa: E402
import wiki_ledger as WL  # noqa: E402

REPO = HERE.parent

# 아크 이름의 읽기. 아크 이름 뒤의 조사를 이 읽기의 받침에서 고른다. 형태소 설비의 받침 판정이 라틴
# 글자를 글자 이름으로 읽으므로 그것으로 고르면 낱말의 읽기와 갈리는 자리가 선다. 아크 값 정본의 아크
# 전량이 이 사상에 드는지를 생성이 단언하므로 아크가 늘면 그 자리에서 터진다. 이름 끝의 숫자는 그
# 설비가 숫자를 읽는 꼴과 같이 한자어 수사로 읽어, 청사진과 항해도가 같은 이름 뒤에 다른 조사를 고르지
# 않게 한다
READING = {
    'primary': '프라이머리', 'charter': '차터', 'claim': '클레임', 'collateral': '콜래터럴',
    'hierarchy': '하이어라키', 'propagation': '프로퍼게이션', 'holder': '홀더',
    'currency': '커런시', 'harness': '하네스', 'orchestration': '오케스트레이션',
    'network': '네트워크', 'sanction': '생크션', 'funding': '펀딩',
    'housekeeper1': '하우스키퍼일', 'housekeeper2': '하우스키퍼이', 'bypass1': '바이패스일',
    'bypass2': '바이패스이',
}

# 앞 판이 들었으나 이 판이 걷는 절과 그 사유. 키는 절 제목의 비교 키다. 앞 판의 절을 빠뜨리지 않는지
# 재는 단언이 이 사상에 든 절만 빠짐으로 받으며, 그 사유를 지위 절이 문면으로 든다
DROPPED = {
    '아크별 재고': ('열린 아크와 예약된 아크가 없어 그 아크에 걸린 구멍을 드는 절이 설 자리가 없다'),
}


# ── 산출의 조각 ────────────────────────────────────────────────────────────

def esc(s):
    return str(s).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


def tick(s):
    """원장 문면의 코드 표기를 산출의 꼴로 옮긴다. 옮기지 않으면 백틱이 문자로 선다."""
    out, i = [], 0
    for m in re.finditer(r'`([^`]+)`', s):
        out.append(esc(s[i:m.start()]))
        out.append('<code>%s</code>' % esc(m.group(1)))
        i = m.end()
    out.append(esc(s[i:]))
    return ''.join(out)


def quote(s):
    """원장이나 대기열의 문면을 옮겨 싣는 칸. 이 문서가 쓴 문면이 아니라 인용임을 표지로 든다."""
    return '<span class="gist">%s</span>' % tick(s)


def code(s):
    return '<code>%s</code>' % esc(s)


def table(heads, rows):
    """표를 낸다. 머리 행을 틀에만 두고 값의 목록에 함께 두지 않는다."""
    assert rows, '값이 없는 표를 두지 않는다'
    n = len(heads)
    for r in rows:
        assert len(r) == n, '표의 칸이 머리와 갈린다: %d · %d' % (len(r), n)
    th = ''.join('<th class="%s">%s</th>' % (c, t) for t, c in heads)
    tr = ['<tr>' + ''.join('<td class="%s">%s</td>' % (c, v) for v, (_, c) in zip(r, heads))
          + '</tr>' for r in rows]
    return ('<div class="table-wrap">\n<table>\n<thead><tr>%s</tr></thead>\n<tbody>%s</tbody>\n'
            '</table>\n</div>' % (th, ''.join(tr)))


def section(title, *blocks):
    return '<section>\n  <h2>%s</h2>\n%s</section>' % (title, '\n'.join(b for b in blocks if b))


def p(s, cls=None):
    return '  <p%s>%s</p>' % ((' class="%s"' % cls) if cls else '', s)


def flag(*ps):
    return '  <div class="flag">\n%s\n  </div>' % '\n'.join('  ' + x for x in ps)


def ul(items):
    return '  <ul>\n%s\n  </ul>' % '\n'.join('    <li>%s</li>' % x for x in items)


def h3(s):
    return '  <h3>%s</h3>' % s


def arc_jo(name, particle):
    """아크 이름 뒤의 조사. 그 낱말의 읽기의 받침에서 고른다."""
    assert name in READING, '아크 %r 의 읽기가 사상에 없다' % name
    return morph.jo(READING[name], particle)


def arc_w(name, particle):
    """아크 이름의 코드 표기와 그 뒤의 조사. 띄어 쓰는 관례를 지킨다."""
    return '%s %s' % (code(name), arc_jo(name, particle))


def cw(x, particle):
    """아크 이름이 아닌 식별자의 코드 표기와 그 뒤의 조사. 조사를 그 표기의 읽기에서 고른다."""
    return '%s %s' % (code(x), morph.jo('`%s`' % x, particle))


def cws(xs, particle):
    """식별자 여럿을 가운뎃점으로 잇고 마지막 것의 읽기에서 조사를 고른다."""
    xs = list(xs)
    return '%s %s' % (dot(code(x) for x in xs), morph.jo('`%s`' % xs[-1], particle))


def arc_cop(name):
    """아크 이름의 코드 표기와 그 뒤의 종결 서술격. 그 낱말의 읽기의 받침에서 고른다."""
    assert name in READING, '아크 %r 의 읽기가 사상에 없다' % name
    return '%s %s' % (code(name), '이다' if morph.has_jong(READING[name]) else '다')


def arc_josa_bad(text):
    """아크 이름의 코드 표기 뒤에 선 조사가 그 읽기에서 고른 꼴과 같은지를 잰다.

    조사를 고르는 함수와 같은 사상을 읽어 둘이 갈릴 수 없게 한다.
    """
    v = re.sub(r'<code>([^<`]*)</code>', r'`\1`', text)
    v = re.sub(r'<[^>]+>', '', v)
    bad = []
    for m in re.finditer(r'`([a-z][a-z0-9]*)` (이|가|은|는|을|를|과|와|으로|로)(?![가-힣])', v):
        name, j = m.group(1), m.group(2)
        if name in READING and arc_jo(name, j) != j:
            bad.append(m.group(0))
    return bad


def nw(n):
    """계수를 낱말로 든다. 영은 「영」이고 백 이상은 숫자로 든다."""
    n = int(n)
    if n == 0:
        return '영'
    return morph.native(n) if n <= 99 else str(n)


def nwj(n, particle):
    return morph.w(nw(n), particle)


def ncop(n):
    """계수와 종결 서술격."""
    return morph.cop_end(nw(n))


def dot(xs):
    return ' · '.join(xs)


# 처분의 갈래와 재개 트리거의 갈래의 읽기. 그 뒤의 조사를 이 읽기의 받침에서 고른다
KIND_READ = {'cleared': '클리어드', 'hole': '홀'}


def kind_w(k, particle):
    assert k in KIND_READ, '처분의 갈래 %r 의 읽기가 사상에 없다' % k
    return '%s %s' % (k, morph.jo(KIND_READ[k], particle))


def kinds_txt(d):
    """재개 트리거의 갈래별 계수. 갈래가 없는 것은 트리거를 쓸 수 없는 것으로 부른다."""
    return dot('%s %s' % (code(k) if k != 'none' else '트리거를 쓸 수 없는 것', nw(len(v)))
               for k, v in sorted(d.items()))


def codes_cop(xs):
    """식별자 여럿을 가운뎃점으로 잇고 마지막 것의 읽기에서 종결 서술격을 고른다."""
    xs = list(xs)
    return '%s %s' % (dot(code(x) for x in xs), '이다' if morph.has_jong('`%s`' % xs[-1]) else '다')


def fn_name(fn):
    return '%s.%s' % (Path(sys.modules[fn.__module__].__file__).stem
                      if fn.__module__ != '__main__' else 'roadmap', fn.__name__)


# ── 받은 커밋을 풀어 놓은 사본 ─────────────────────────────────────────────

def _git(*args):
    return subprocess.run(['git', '-C', str(REPO)] + list(args),
                          capture_output=True, text=True, check=True).stdout.strip()


def export(commit):
    """그 커밋의 트리를 임시 자리에 풀고 그 뿌리를 돌려준다. 리포를 읽는 자리 전량이 이 뿌리를 쓴다.

    그 커밋이 원격 추적 머리이거나 그 조상인지를 단언한다. 떠 둔 클론이 원격보다 낡았으면 그 클론을
    원천으로 쓰지 않는다.
    """
    full = _git('rev-parse', '--verify', commit + '^{commit}')
    remote = _git('rev-parse', 'origin/main')
    r = subprocess.run(['git', '-C', str(REPO), 'merge-base', '--is-ancestor', full, remote])
    assert r.returncode == 0, '그 커밋이 원격 추적 머리의 조상이 아니다: %s' % full
    d = Path(tempfile.mkdtemp(prefix='roadmap-'))
    data = subprocess.run(['git', '-C', str(REPO), 'archive', '--format=tar', full,
                           'docs', 'scripts', 'CrisisFramework'],
                          capture_output=True, check=True).stdout
    with tarfile.open(fileobj=io.BytesIO(data)) as tf:
        tf.extractall(d, filter='data')
    short = _git('rev-parse', '--short', full)
    date = _git('show', '-s', '--format=%cd', '--date=format:%Y-%m-%d', full)
    return d, {'full': full, 'head': short, 'date': date, 'remote': remote[:len(short)]}


# ── 값을 내는 함수. 산출이 계수를 들면 그 값을 낸 함수의 이름을 그 자리에 적는다 ──────────

def live_holes(root):
    """살아 있는 구멍. 폐기 레코드의 target 이 가리키지 않는 이연이다."""
    return B.live_deferred(root)


def trigger_split(root):
    """살아 있는 구멍을 재개 트리거의 갈래로 가른다. 갈래가 없는 것은 none 이다."""
    out = {}
    for e in live_holes(root):
        k = (e.get('reopen_when') or {}).get('kind') or 'none'
        out.setdefault(k, []).append(e['id'])
    return out


def layer_split(root, ids=None):
    """살아 있는 구멍을 층으로 가른다. ids 를 주면 그 집합으로 좁힌다."""
    out = {}
    for e in live_holes(root):
        if ids is not None and e['id'] not in ids:
            continue
        out[e.get('layer') or '—'] = out.get(e.get('layer') or '—', 0) + 1
    return out


def arc_pointing(root):
    """재개 트리거의 참조가 아크 값 정본의 아크 이름인 살아 있는 구멍."""
    names = {a['name'] for a in B.arcs(root)['arcs']}
    return [e['id'] for e in live_holes(root)
            if ((e.get('reopen_when') or {}).get('ref')) in names]


def ledger_checks(root):
    """원장 검증기의 보고 검사 둘을 불러 그 출력의 계수를 낸다. 셈법의 정본이 그 검사에 있다."""
    led = WC.Ledger(Path(root))
    n17 = re.match(r'reopen_when: null (\d+)건', WL.check_17(led).notes[0])
    n18 = re.match(r'아크를 가리키는 구멍 (\d+)건', WL.check_18(led).notes[0])
    assert n17 and n18, '원장 검증기의 보고 꼴이 바뀌었다'
    return {'null': int(n17.group(1)), 'arc': int(n18.group(1))}


def arc_states(root):
    """아크 값 정본의 상태별 계수."""
    out = {}
    for a in B.arcs(root)['arcs']:
        out[a.get('status')] = out.get(a.get('status'), 0) + 1
    return out


def last_closed(root):
    """가장 늦게 닫힌 아크. 종료 날짜가 같으면 아크 값 정본의 배열에서 뒤에 선 것이다."""
    recs = [(a.get('closed') or '', i, a['name']) for i, a in enumerate(B.arcs(root)['arcs'])
            if a.get('status') == 'closed']
    assert recs, '닫힌 아크가 없다'
    return max(recs)[2]


def arc_entries(root, arc):
    """그 아크를 출처로 든 원장 항목을 페이즈별로 센다. 네 레지스터 전량이 유니버스다."""
    out = {}
    for r in B.REG:
        for e in B.entries(root, r):
            o = e.get('origin') or {}
            if o.get('arc') == arc:
                out[o.get('phase')] = out.get(o.get('phase'), 0) + 1
    return out


def arc_hole_disposal(root, arc):
    """그 아크의 구멍 배열에서 폐기 레코드가 선 것과 서지 않은 것."""
    rec = [a for a in B.arcs(root)['arcs'] if a['name'] == arc][0]
    dead = {e.get('target') for e in B.entries(root, 'retirements')}
    hs = rec.get('holes') or []
    return {'all': hs, 'retired': [h for h in hs if h in dead],
            'alive': [h for h in hs if h not in dead]}


def arc_new_live(root, arc):
    """그 아크가 세우고 아직 살아 있는 이연을 재개 트리거의 갈래로 가른다."""
    out = {}
    for e in live_holes(root):
        if (e.get('origin') or {}).get('arc') == arc:
            k = (e.get('reopen_when') or {}).get('kind') or 'none'
            out.setdefault(k, []).append(e['id'])
    return out


def cq_items(root):
    """관측층의 물음 선언. 번호와 구조물 이름과 답 타입과 제목과 용도 문장을 낸다.

    고정 절 대조기의 추출을 직접 불러 쓰고 그 규칙을 옮겨 적지 않는다.
    """
    src = (Path(root) / Q.CQ_FILE).read_text(encoding='utf-8')
    lines = Q.extract(src)
    out = []
    for ln in lines:
        m = re.match(r'^CQFIN=(\d+)\|([^|]+)\|(.+)\|[0-9a-f]+$', ln)
        assert m, '고정 절의 줄 꼴이 다르다: %r' % ln
        n, name, typ = int(m.group(1)), m.group(2), m.group(3)
        dm = re.search(r'(?s)/--\s*\n`CQ-fin-%d`\s+([^\n]+?)\.\s*\n(.*?)-/\s*\n-- DD:[^\n]*\n'
                       r'structure %s\b' % (n, re.escape(name)), src)
        assert dm, '%s 의 문서화 문면을 찾지 못했다' % name
        out.append({'id': 'CQ-fin-%d' % n, 'name': name, 'type': typ, 'title': dm.group(1),
                    'doc': dm.group(2)})
    return out


def cq_reasons(root):
    """못 재는 까닭의 열거와 답 타입마다 그 열거를 받는 생성자가 서는지."""
    src = (Path(root) / Q.CQ_FILE).read_text(encoding='utf-8')
    rm = re.search(r'(?s)inductive UndeterminedReason where\n(.*?)\n(?:\n|deriving)', src)
    assert rm, '못 재는 까닭의 열거를 찾지 못했다'
    reasons = re.findall(r'^\s*\|\s*([A-Za-z]+)', rm.group(1), re.M)
    heads = set()
    for c in cq_items(root):
        tail = c['type'].split('→')[-1]
        for part in tail.split('×'):
            heads.add(part.strip().split()[0])
    carry = {}
    for h in sorted(heads):
        im = re.search(r'(?s)inductive %s\b[^\n]*where\n(.*?)\n(?:\n|deriving)' % re.escape(h), src)
        assert im, '답 타입 %s 의 선언을 찾지 못했다' % h
        carry[h] = bool(re.search(r'\|\s*undetermined\s*\(reason\s*:\s*UndeterminedReason\)',
                                  im.group(1)))
    return {'reasons': reasons, 'carry': carry}


def cq_dispositions(root):
    """내리는 항마다 살아 있는 처분. 폐기된 항목의 처분은 뺀다. 원장 번호가 큰 것이 현행이다."""
    dead = {e.get('target') for e in B.entries(root, 'retirements')}
    out = {}
    for r in B.REG:
        for e in B.entries(root, r):
            if e['id'] in dead:
                continue
            for d in e.get('cq_disposition') or []:
                out.setdefault(d['cq'], []).append((int(e['id'][3:]), e['id'], d['kind'],
                                                    (e.get('origin') or {}).get('arc')))
    return {k: sorted(v) for k, v in out.items()}


def lean_files(root):
    """형식층의 파일을 층별로 센다. 풀어 놓은 사본이 추적 파일만 들므로 그 트리를 센다."""
    out = {}
    for f in sorted((Path(root) / 'CrisisFramework').rglob('*.lean')):
        out[f.relative_to(Path(root) / 'CrisisFramework').parts[0]] = \
            out.get(f.relative_to(Path(root) / 'CrisisFramework').parts[0], 0) + 1
    return out


def closures(root):
    """페이즈 종료 문서의 수."""
    return len(list((Path(root) / 'docs' / 'phases').glob('*-closure.md')))


def extraction_count(root):
    """추출 기록의 수. 그 머리 뒤에 편 제목의 굵은 구간이 서는지를 추출 설비가 함께 단언한다."""
    return len(B.extractions(root))


def queue_rows(root):
    """읽기 대기열의 지목 참조 대기 표의 행. 굵은 제목과 괄호와 표지와 뭉치 밖의 표지를 낸다."""
    t = (Path(root) / 'docs' / 'reading-queue-v0.md').read_text(encoding='utf-8')
    m = re.search(r'(?ms)^## 1\. 지목 참조 대기.*?\n(.*?)(?=^## )', t)
    assert m, '읽기 대기열에서 지목 참조 대기 절을 찾지 못했다'
    rows = []
    for ln in m.group(1).split('\n'):
        if not ln.startswith('|') or re.match(r'^\|\s*-', ln):
            continue
        cells = [c.strip() for c in ln.strip().strip('|').split('|')]
        if cells[0] == '논문':
            continue
        tm = re.match(r'^\*\*(.+?)\*\*\s*(?:\((.+)\))?\s*$', cells[0])
        st = re.findall(r'\*\*(대기|조달|소진)\.?\*\*', ln)
        rows.append({'title': tm.group(1) if tm else None,
                     'paren': (tm.group(2) if tm and tm.group(2) else None),
                     'first': cells[0], 'status': st[0] if st else None,
                     # 뭉치 밖의 표지는 괄호에 서기도 하고 비고 칸에 서기도 하므로 행 전체에서 찾는다
                     'outside': '뭉치 밖' in ln,
                     'ids': set(re.findall(r'`(CF-\d+)`', ln))})
    assert rows, '지목 참조 대기 표에 행이 없다'
    return rows


def _norm(s):
    return re.sub(r'\s+', '', s or '')


def reading_split(root):
    """살아 있는 추출 갈래 이연을 대기열의 행에 잇는다.

    굵은 제목이 재개 트리거의 참조와 같은 행을 먼저 찾고, 없으면 그 번호를 드는 행을 찾는다. 뭉치 밖의
    표지와 대기 표지를 함께 든 행에 이어진 것이 조달 대기이고, 이어지지 않은 것은 따로 낸다.
    """
    rows = queue_rows(root)
    out = {'procure': [], 'inside': [], 'nomatch': []}
    for e in live_holes(root):
        rw = e.get('reopen_when') or {}
        if rw.get('kind') != 'extraction':
            continue
        ref = rw.get('ref') or ''
        hit = [r for r in rows if r['title'] and _norm(r['title']) == _norm(ref)]
        if not hit:
            hit = [r for r in rows if e['id'] in r['ids']]
        if not hit:
            out['nomatch'].append(e['id'])
            continue
        assert len(hit) == 1, '%s 이 대기열의 행 여럿에 이어진다' % e['id']
        r = hit[0]
        item = {'id': e['id'], 'ref': ref, 'row': r, 'layer': e.get('layer')}
        if r['outside'] and r['status'] == '대기':
            out['procure'].append(item)
        else:
            out['inside'].append(item)
    return out


# ── 앞 판 ─────────────────────────────────────────────────────────────────

def prev_parts(html, appendix):
    """앞 판에서 머리와 양식과 판의 번호와 절 제목을 떼고, 이 생성기가 이월하는 표를 읽는다."""
    hm = re.search(r'(?s)<head>\n(.*?)<style>\n(.*?)\n</style>\n</head>', html)
    assert hm, '앞 판에서 머리와 양식을 떼지 못했다'
    tm = re.search(r'<h1>항해도 v(\d+)( 부록)?</h1>', html)
    assert tm and bool(tm.group(2)) == appendix, '앞 판의 제목을 읽지 못했다'
    secs = {}
    for sm in re.finditer(r'(?s)<section>\n  <h2>(.*?)</h2>(.*?)</section>', html):
        secs[sm.group(1)] = sm.group(2)
    assert secs, '앞 판에서 절을 읽지 못했다'
    out = {'head': hm.group(1), 'style': hm.group(2), 'version': int(tm.group(1)),
           'sections': secs}
    if not appendix:
        body = secs.get('등뼈 — 어디까지 왔는가')
        assert body, '앞 판에 등뼈 절이 없다'
        anchors = []
        for rm in re.finditer(r'(?s)<tr>(.*?)</tr>', body.split('<tbody>')[1]):
            cells = re.findall(r'(?s)<td[^>]*>(.*?)</td>', rm.group(1))
            arc = re.search(r'<code>([a-z][a-z0-9]*)</code>', cells[3])
            assert arc, '등뼈 표의 상태 칸에서 아크를 읽지 못했다'
            anchors.append({'struct': re.sub(r'<[^>]+>', '', cells[0]).strip(),
                            'clause': re.sub(r'<[^>]+>', '', cells[1]).strip(),
                            'arc': arc.group(1)})
        out['anchors'] = anchors
    else:
        key = [t for t in secs if t.startswith('이 프로젝트 밖으로 넘어가는 과제')]
        assert len(key) == 1, '앞 판에 독자 연구 절이 하나가 아니다'
        out['outside_ids'] = re.findall(r'<tr><td[^>]*><code>(CF-\d+)</code>', secs[key[0]])
        out['tasks'] = _prev_rows(secs.get('수취인이 사용자인 과제', ''), 4,
                                  ('task', 'what', 'clause', 'phrase'))
        out['facility'] = _prev_rows(secs.get('집행 구간이 정해지지 않은 작업', ''), 2, ('what', 'why'))
    return out


def _cell_text(c):
    """표의 칸을 글자로 되돌린다. 산출이 가한 이스케이프를 되돌려 입력과 같은 꼴로 받는다."""
    c = re.sub(r'<[^>]+>', '', c)
    return c.replace('&lt;', '<').replace('&gt;', '>').replace('&amp;', '&').strip()


def _prev_rows(body, ncol, keys):
    """앞 판의 표에서 행을 이월한다. 칸의 수가 기대와 다르면 이월하지 않고 None 을 낸다."""
    if '<tbody>' not in body:
        return []
    rows = []
    for rm in re.finditer(r'(?s)<tr>(.*?)</tr>', body.split('<tbody>')[1]):
        cells = re.findall(r'(?s)<td[^>]*>(.*?)</td>', rm.group(1))
        if len(cells) != ncol:
            return None
        rows.append(dict(zip(keys, [_cell_text(c) for c in cells])))
    return rows


def title_key(t):
    """절 제목의 비교 키. 계수와 아크 이름이 판마다 바뀌는 제목은 그 자리를 걷는다."""
    for pat, key in ((r'^<code>[a-z][a-z0-9]*</code> [이가] 낸 것$', '아크가 낸 것'),
                     (r'^현 위치 — 내리는 항 \S+$', '현 위치'),
                     (r'^열려 있는 아크.*$', '열려 있는 아크'),
                     (r'^트리거를 쓸 수 없는 \S+$', '트리거를 쓸 수 없는 것'),
                     (r'^<code>[a-z][a-z0-9]*</code> — \S+$', '아크별 재고'),
                     (r'^조달 대기 — .*$', '조달 대기'),
                     (r'^이 프로젝트 밖으로 넘어가는 과제 — .*$', '독자 연구')):
        if re.match(pat, t):
            return key
    return t


STATUS_TITLES = ('이 문서의 지위', '이 부록의 지위와 왜 여기에만 적는가')
SYN_OP = '이 회차가 그 표의 칸을 손으로 고쳤다'
SYN_PREV = '<section>\n  <h2>이 문서의 지위</h2>\n  <p>%s.</p>\n</section>' % SYN_OP


def prev_op_phrases(prevs):
    """앞 판의 산문에서 조작을 주장하는 문장을 뽑는다. 이 판의 산문이 그 문장을 들면 적발로 낸다.

    유니버스는 산출이 자기 조작을 주장하는 자리인 지위 절의 문단과 각 절의 주석 문단이며, 표를 걷는다.
    그 가운데 주체가 회차나 생성기나 결정 세션이거나 앞 판에서 떼어 온 것을 드는 문장 가운데 과거
    시제로 끝나는 것을 뽑는다. 앞 판의 사본이 이 유니버스를 빠짐없이 들어야 한다.
    """
    out = []
    for html in prevs:
        texts = []
        for title, body in re.findall(r'(?s)<section>\n  <h2>(.*?)</h2>(.*?)</section>', html):
            body = re.sub(r'(?s)<table>.*?</table>', ' ', body)
            pat = r'(?s)<p[^>]*>(.*?)</p>' if title in STATUS_TITLES else r'(?s)<p class="note">(.*?)</p>'
            texts += re.findall(pat, body)
        v = re.sub(r'<[^>]+>', '', '\n'.join(texts))
        for s in re.split(r'(?<=다)\.\s*|\n+', v):
            s = re.sub(r'\s+', ' ', s).strip().rstrip('.')
            if len(s) < 12 or not re.search(r'(었|았|였|웠|뒀|쟀|냈|렸|했|겼|쳤|섰)다$', s):
                continue
            if re.search(r'회차가|생성기가|결정 세션이|이 판은|떼어|조사해', s):
                out.append(s)
    return sorted(set(out))


# ── 실측을 모은다 ─────────────────────────────────────────────────────────

class Measures:
    """계수를 낸 함수와 그 값을 함께 든다. 산출에 그 함수의 이름이 서는지와 다시 불러 같은 값이
    나오는지를 마지막에 잰다."""

    def __init__(self):
        self.vals = {}

    def take(self, fn, *args):
        v = fn(*args)
        self.vals[(fn.__name__, args)] = (fn, v)
        return v

    def names(self):
        return sorted({fn_name(fn) for fn, _ in self.vals.values()})

    def recheck(self, htmls):
        for (nm, args), (fn, v) in self.vals.items():
            assert fn(*args) == v, '%s 를 다시 불러 다른 값이 났다' % nm
        joined = '\n'.join(htmls)
        missing = [n for n in self.names() if n not in joined]
        assert not missing, '계수를 낸 함수의 이름이 산출에 서지 않는다: %r' % missing


def gather(a):
    root, hd = export(a.commit)
    M = Measures()
    g = {'root': root, 'head': hd, 'M': M, 'asserted': []}

    def ok(name):
        g['asserted'].append(name)

    arcs = B.arcs(root)['arcs']
    assert {x['name'] for x in arcs} <= set(READING), \
        '아크 값 정본의 아크가 읽기 사상에 없다: %r' % sorted({x['name'] for x in arcs} - set(READING))
    ok('아크 값 정본의 아크 전량이 아크 이름의 읽기 사상에 든다')
    g['arcs'] = arcs
    g['states'] = M.take(arc_states, root)
    g['last'] = M.take(last_closed, root)
    g['live'] = M.take(live_holes, root)
    g['split'] = M.take(trigger_split, root)
    g['layers'] = M.take(layer_split, root)
    g['arc_ptr'] = M.take(arc_pointing, root)
    g['wl'] = M.take(ledger_checks, root)
    nnull = len(g['split'].get('none', []))
    assert g['wl']['null'] == nnull, '트리거를 쓸 수 없는 이연의 두 셈이 갈린다: %d · %d' % (
        g['wl']['null'], nnull)
    assert g['wl']['arc'] == len([i for i in g['live'] if (i.get('reopen_when') or {}).get('kind')
                                  in WL.ARC_POINTING_KINDS]), '아크를 가리키는 구멍의 두 셈이 갈린다'
    ok('트리거를 쓸 수 없는 이연과 아크를 가리키는 구멍의 계수를 원장 검증기의 보고 검사와 맞댔다')
    g['notrig_layers'] = M.take(layer_split, root, frozenset(g['split'].get('none', [])))
    g['entries'] = M.take(arc_entries, root, g['last'])
    g['disposal'] = M.take(arc_hole_disposal, root, g['last'])
    g['newlive'] = M.take(arc_new_live, root, g['last'])
    g['cq'] = M.take(cq_items, root)
    g['reasons'] = M.take(cq_reasons, root)
    assert all(g['reasons']['carry'].values()), \
        '못 재는 까닭을 받는 생성자가 없는 답 타입: %r' % g['reasons']['carry']
    ok('답 타입마다 못 재는 까닭을 받는 생성자가 선다')
    g['purpose'] = [c['id'] for c in g['cq'] if '복무한다' in re.sub(r'\s+', '', c['doc'])]
    g['disp'] = M.take(cq_dispositions, root)
    cq_arcs = {}
    for x in arcs:
        for c in x.get('cq') or []:
            cq_arcs.setdefault(c, []).append(x['name'])
    assert set(cq_arcs) == {c['id'] for c in g['cq']}, '아크 값 정본의 물음과 관측층의 물음이 갈린다'
    ok('아크 값 정본이 드는 물음과 관측층의 물음 선언이 양방향으로 같다')
    g['cq_arcs'] = cq_arcs
    g['lean'] = M.take(lean_files, root)
    g['reg'] = M.take(B.registers, root)
    g['closures'] = M.take(closures, root)
    g['ex'] = M.take(extraction_count, root)
    g['reading'] = M.take(reading_split, root)
    g['patches'] = len(B.arcs(root).get('patches') or [])

    # 앞 판
    g['prev'] = prev_parts(io.open(a.prev, encoding='utf-8').read(), False)
    g['prev_app'] = prev_parts(io.open(a.prev_appendix, encoding='utf-8').read(), True)
    assert g['prev']['version'] == g['prev_app']['version'], '앞 판의 본편과 부록의 판이 갈린다'
    assert g['prev']['style'] == g['prev_app']['style'], '앞 판의 본편과 부록의 양식이 갈린다'
    ok('앞 판의 본편과 부록이 같은 판이고 양식이 바이트로 같다')
    g['version'] = g['prev']['version'] + 1
    anchors = g['prev']['anchors']
    want = {x['name'] for x in arcs if x.get('cq')}
    got = {x['arc'] for x in anchors}
    assert got == want, '등뼈 표의 앵커가 드는 아크와 물음을 든 아크가 갈린다: %r · %r' % (
        sorted(got - want), sorted(want - got))
    ok('앞 판의 등뼈 앵커가 드는 아크의 집합이 물음을 든 아크의 집합과 양방향으로 같다')

    # 독자 연구. 원장의 필드에서 유도되지 않으므로 앞 판에서 구멍 번호로 이월한다. 폐기됐으면 그
    # 대체를 따라가고, 살아 있는지를 단언한다
    repl = {e.get('target'): e.get('replaced_by') for e in B.entries(root, 'retirements')}
    live_ids = {e['id']: e for e in g['live']}
    carried = []
    for hid in g['prev_app']['outside_ids']:
        cur = hid
        while cur in repl and repl[cur]:
            cur = repl[cur]
        if cur in live_ids:
            carried.append(live_ids[cur])
    g['outside'] = carried
    ok('독자 연구 절이 이월한 구멍이 전량 살아 있다')

    # 과제와 설비의 대기. 리포에서 유도되지 않으므로 앞 판의 그 표에서 이월하고, 결정 세션이 그 행을
    # 바꿀 때에만 입력으로 넘긴다
    if a.tasks:
        tdoc = json.loads(io.open(a.tasks, encoding='utf-8').read())
        assert set(tdoc) == {'tasks', 'facility'}, '과제 입력의 꼴이 다르다'
        g['tasks_from'] = 'input'
    else:
        tdoc = {'tasks': g['prev_app']['tasks'], 'facility': g['prev_app']['facility']}
        assert tdoc['tasks'] is not None and tdoc['facility'] is not None, \
            '앞 판의 과제 표가 구절의 칸을 들지 않아 이월할 수 없다. 입력으로 넘겨라'
        assert tdoc['tasks'], '앞 판의 과제 표가 비었다'
        g['tasks_from'] = 'prev'
    rules = [io.open(x, encoding='utf-8').read() for x in a.rules]
    for t in tdoc['tasks']:
        assert set(t) == {'task', 'what', 'clause', 'phrase'}, '과제 행의 꼴이 다르다'
        hits = sum(_norm(r).count(_norm(t['phrase'])) for r in rules)
        assert hits >= 1, '과제 %r 의 구절을 규율 문서에서 되찾지 못했다' % t['task']
    ok('수취인이 사용자인 과제의 행마다 그 구절을 규율 문서의 작업 파일에서 되찾았다')
    g['tasks'] = tdoc['tasks']
    g['facility'] = tdoc['facility']
    g['ops'] = prev_op_phrases([io.open(a.prev, encoding='utf-8').read(),
                                io.open(a.prev_appendix, encoding='utf-8').read()])
    # 뽑는 꼴 자신을 합성 문장으로 잰다. 앞 판이 그 문장을 하나도 들지 않으면 그 축이 아무것도 재지
    # 않으므로, 그 축의 음성 대조는 이 합성 문장을 더한 목록으로 돈다
    assert prev_op_phrases([SYN_PREV]) == [SYN_OP], '조작을 주장하는 문장을 뽑는 꼴이 합성 문장을 놓쳤다'
    ok('앞 판의 조작을 주장하는 문장을 뽑는 꼴이 합성 문장을 뽑는다')
    return g


# ── 본편의 절 ─────────────────────────────────────────────────────────────

def cq_summary(g):
    n = len(g['cq'])
    k = len([c for c in g['cq'] if g['disp'].get(c['id'])])
    if k == n:
        return '내리는 항 %s 전량 처분을 받았다' % nwj(n, '이')
    return '내리는 항 %s 가운데 %s 처분을 받았고 %s 아직 받지 않았다' % (
        nw(n), nwj(k, '이'), nwj(n - k, '이'))


def arc_summary(g):
    st = g['states']
    n = sum(st.values())
    c, o, r = st.get('closed', 0), st.get('open', 0), st.get('reserved', 0)
    parts = ['아크 %s 가운데 닫힌 것이 %s' % (nw(n), morph.cop_conj(nw(c), '이고'))]
    if o == 0 and r == 0:
        parts.append('열린 것과 예약된 것이 없다')
    else:
        parts.append('열린 것이 %s 예약된 것이 %s' % (
            morph.cop_conj(nw(o), '이고'), ncop(r)))
    return ' '.join(parts)


def header(g, appendix):
    hd = g['head']
    title = '항해도 v%d%s' % (g['version'], ' 부록' if appendix else '')
    if not appendix:
        asof = ' · '.join([
            '머리 커밋 %s 기준' % code(hd['head']), hd['date'], arc_summary(g),
            '<strong>%s 닫혔다</strong>' % arc_w(g['last'], '이'), cq_summary(g)])
    else:
        n = len(g['live'])
        na = len(g['arc_ptr'])
        nz = len(g['split'].get('none', []))
        asof = ' · '.join([
            '머리 커밋 %s 기준' % code(hd['head']), hd['date'],
            '<strong>수취인이 없는 살아 있는 구멍의 재고</strong>',
            '살아 있는 구멍 %s 가운데 트리거가 아크를 가리키는 것이 %s 트리거를 쓸 수 없는 것이 %s'
            % (nw(n), ('없고' if na == 0 else morph.cop_conj(nw(na), '이고')), ncop(nz))])
    return ('<header>\n  <h1>%s</h1>\n  <p class="asof">%s</p>\n</header>' % (title, asof))


def sec_status_main(g, dropped):
    blocks = [
        flag(p('<strong>이 문서는 사용자가 길을 잃지 않으려고 읽는 메모이며 정본이 아니다.</strong> '
               '아크와 페이즈의 값은 아크 값 정본과 원장이 들고, 규율은 세션 지시가 들며, 이 문서가 '
               '그것들과 어긋나면 정본이 이긴다. 미전사분의 거처도 아니다. 그 자리는 청사진이 들고 '
               '이 문서는 그것을 전사하지 않는다.')),
    ]
    st = g['states']
    prev_empty = '열려 있는 아크가 없다 — 다음을 고르는 자리' in g['prev']['sections']
    if st.get('open', 0) == 0:
        tail = ('<strong>마지막 것이 이 판에서%s 비었다.</strong> 열려 있는 아크가 없으므로 다음 아크를 '
                '고르는 자리를 드는 절이 그 자리를 대신한다.' % ('도' if prev_empty else ''))
    else:
        tail = '열려 있는 아크가 무엇을 묻는지는 그 이름의 절이 든다.'
    blocks.append(p('이 문서가 드는 것은 셋이다. <strong>무엇을 향해 가는가</strong>와 '
                    '<strong>지금 어디에 있는가</strong>와 <strong>열려 있는 아크가 무엇을 묻는가'
                    '</strong>이다. ' + tail))
    blocks.append(p('<strong>이 판의 머리 커밋에서 가장 늦게 닫힌 아크는 %s. 이 판은 리포의 '
                    '생성기(%s)가 낸다.</strong> 아크가 닫히는 '
                    '자리마다 본문을 실측에서 다시 세우라는 요구가 걸리고 그 다시 세움이 재생성이므로, '
                    '그 생성기가 리포에 서야 다음 판도 같은 꼴로 선다. <strong>양식과 머리는 앞 판에서 '
                    '그대로 떼어 쓰고 머리의 제목에서 판의 번호만 유도해 바꾼다.</strong> 양식이 '
                    '계수도 식별자도 아니어서 실측에서 유도될 상대가 없기 때문이다.'
                    % (arc_cop(g['last']), code('scripts/roadmap.py'))))
    if dropped:
        blocks.append(p('<strong>앞 판이 든 절 가운데 이 판이 걷은 것이 %s.</strong> %s. 앞 판의 절을 '
                        '빠뜨리지 않는지 재는 단언이 걷은 절의 사상에 든 것만 빠짐으로 받는다.'
                        % (ncop(len(dropped)),
                           ' '.join('「%s」의 갈래에 드는 절은 %s' % (k, DROPPED[k]) for k in dropped))))
    blocks.append(p('값은 머리 커밋을 풀어 놓은 사본에서 실측한 것이고 정본은 리포다. 이 문서는 리포 밖에 '
                    '있어 그 유니버스에 들지 않는다. 생성기가 리포를 읽는 자리 전량을 그 사본 하나로 '
                    '가두므로 같은 커밋을 주면 커밋이 쌓인 뒤에도 같은 산출이 선다. 생성기가 받은 확인의 '
                    '목록은 「이 산출이 받은 확인」 절이 든다.', 'note'))
    return section('이 문서의 지위', *blocks)


def sec_arc_output(g):
    arc = g['last']
    rec = [x for x in g['arcs'] if x['name'] == arc][0]
    phases = rec.get('phases') or []
    drops = [q for q in B.arcs(g['root']).get('patches') or []
             if q.get('arc') == arc and q.get('op') == 'drop']
    lastp = phases[-1]
    blocks = [p('<strong>판별선은 「%s」였고 선언된 페이즈가 %s</strong>%s 마지막 페이즈 %s 의 세울 것은 '
                '「%s」였다.'
                % (esc(rec.get('discriminator') or ''), ncop(len(phases)) + '.',
                   (' 패치 레코드가 걷은 페이즈가 %s' % ncop(len(drops)) + '.') if drops else '',
                   code(lastp['name']), esc(lastp.get('builds') or '')))]
    lines = []
    for c in rec.get('cq') or []:
        ds = [d for d in g['disp'].get(c, []) if d[3] == arc]
        if ds:
            lines.append('%s %s %s 처분했다' % (cw(c, '을'), cw(ds[-1][1], '이'),
                                              kind_w(ds[-1][2], '으로')))
        else:
            lines.append('%s 이 아크의 처분을 받지 않았다' % cw(c, '은'))
    # 답할 항을 들지 않는 아크는 처분할 항이 없으므로 빈 목록을 문단에 넣지 않고 그 사실을 적는다. 빈
    # 목록을 넣으면 굵은 표지 뒤에 마침표만 남은 문단이 서며, 그 꼴을 빈 보간의 축이 잡는다
    if lines:
        blocks.append(flag(p('<strong>이 아크가 내리려던 항의 처분.</strong> %s. 그 처분은 원장의 처분 '
                             '필드에서 유도했고 폐기된 항목의 처분은 뺐다.' % ' · '.join(lines))))
    else:
        blocks.append(p('<strong>이 아크가 내리려던 항이 없다.</strong> 아크 값 정본의 그 레코드가 답할 항의 '
                        '배열을 비워 두었으므로 처분할 항이 없고, 그 사유는 개막 결정이 든다.'))
    dsp = g['disposal']
    na, nr = len(dsp['all']), len(dsp['retired'])
    if nr == na:
        hole_txt = ('<strong>이 아크에 걸린 구멍 %s 전량 폐기 레코드로 해소됐다.</strong> 그래서 이 아크를 '
                    '닫는 관문 가운데 구멍의 처분이 섰다.' % nwj(na, '이'))
    else:
        hole_txt = ('이 아크에 걸린 구멍이 %s 그 가운데 %s 폐기 레코드로 해소됐고 %s 살아 있다.'
                    % (morph.cop_conj(nw(na), '이고'), nwj(nr, '이'), nwj(na - nr, '이')))
    nl = g['newlive']
    if nl:
        new_txt = (' 이 아크가 세우고 아직 살아 있는 이연이 %s 재개 트리거의 갈래로 가르면 %s.'
                   % (morph.cop_conj(nw(sum(len(v) for v in nl.values())), '이고'),
                      morph.cop_end(kinds_txt(nl))))
    else:
        new_txt = ' 이 아크가 세운 이연 가운데 살아 있는 것이 없다.'
    blocks.append(p(hole_txt + new_txt))
    ent = g['entries']
    order = [q['name'] for q in phases]
    tot = sum(ent.values())
    blocks.append(h3('이 아크가 낸 원장 항목'))
    blocks.append(p('이 아크가 낸 원장 항목이 %s 개다. 페이즈마다의 분포는 이 절의 표가 든다.' % tot))
    blocks.append(table([('페이즈', ''), ('원장 항목', '')],
                        [(code(q), str(ent.get(q, 0))) for q in order]))
    blocks.append(p('이 절이 드는 아크(%s)는 아크 값 정본의 종료 날짜에서 가장 늦게 닫힌 것이다. 항목의 '
                    '수(%s)는 네 레지스터에서 출처가 이 아크를 드는 항목을 센 것이다. 구멍의 처분(%s)은 '
                    '이 아크 레코드의 구멍 배열과 폐기 레코드를 맞대어 낸 것이고, 살아 있는 이연(%s)은 '
                    '출처가 이 아크인 이연에서 폐기된 것을 뺀 것이다. 항목의 내용은 원장이 들고 이 문서는 '
                    '그것을 전사하지 않는다.'
                    % (code(fn_name(last_closed)), code(fn_name(arc_entries)),
                       code(fn_name(arc_hole_disposal)), code(fn_name(arc_new_live))), 'note'))
    return section('%s 낸 것' % arc_w(arc, '이'), *blocks)


def sec_destination(g):
    n = len(g['cq'])
    k = len([c for c in g['cq'] if g['disp'].get(c['id'])])
    if k == n:
        end_txt = ('<strong>%s 전량 처분을 받아 그 조건이 이 판에서 닫혔다.</strong> 새 항을 더하는 길이 '
                   '열려 있으므로 그 수가 늘면 이 조건이 다시 열린다.' % nwj(n, '이'))
    else:
        end_txt = '<strong>%s 가운데 %s 처분을 받았고 %s 아직 받지 않았다.</strong>' % (
            nw(n), nwj(k, '이'), nwj(n - k, '이'))
    rs = g['reasons']['reasons']
    return section('목적지',
        p('<strong>알고자 하는 것은 위기가 어디서 올 수 있고 그것이 깨지기 전에 보이는가, 그리고 보이지 '
          '않는 자리가 어디인가이다.</strong> 거시 상태가 어디로 갈지를 예측하는 것이 아니다.'),
        p('리포는 그 목적지를 두 자리에서 잰다.'),
        ul(['<strong>프로젝트의 종료 조건.</strong> 내리는 항 전량이 정의 공백을 벗어나거나 구멍으로 '
            '기록되면 프로젝트가 끝난다. ' + end_txt,
            '<strong>소스 없음 등재.</strong> 관측층에 측정 소스가 없음을 드는 선언이 서 있는 자리들이 '
            '그것이다. 그 등재를 주요 산출물로 드는 조항이 서 있으며, 보이지 않는 자리가 어디인지가 '
            '그것으로 남는다.']),
        p('이 목적지가 리포의 실물과 맞는다는 근거가 둘이다. %s 그리고 답 타입이 값만 들지 않고 '
          '<strong>못 재는 까닭</strong>을 열거로 들며, 그 열거의 원소가 %s. 예측하려고 만든 장치는 그 '
          '까닭을 일급 생성자로 두지 않는다.' % (purpose_txt(g), ncop(len(rs)))),
        p('용도 문장(%s)은 관측층의 물음 선언에서 뽑았고, 못 재는 까닭(%s)은 그 열거를 읽은 것이며 답 '
          '타입마다 그 열거를 받는 생성자가 서는지를 함께 단언했다. 물음 선언을 뽑는 규칙은 고정 절 대조기의 '
          '추출을 직접 불러 썼다.' % (code(fn_name(cq_items)), code(fn_name(cq_reasons))), 'note'))


def purpose_txt(g):
    """용도 문장의 근거. 그 문장이 서지 않은 물음이 있으면 그 항을 이름으로 든다."""
    n, k = len(g['cq']), len(g['purpose'])
    if k == n:
        return ('내리는 항마다 문서화 문면이 그 물음이 무엇을 정하는 데 복무하는지를 용도 문장으로 '
                '든다.')
    miss = [c['id'] for c in g['cq'] if c['id'] not in g['purpose']]
    return ('내리는 항 %s 가운데 %s 문서화 문면에 그 물음이 무엇을 정하는 데 복무하는지를 용도 문장으로 '
            '들고, %s 그 문장을 들지 않는다.' % (nw(n), nwj(k, '이'), cws(miss, '은')))


def sec_backbone(g):
    anchors = {x['arc']: x for x in g['prev']['anchors']}
    recs = sorted([x for x in g['arcs'] if x.get('cq')],
                  key=lambda x: (x.get('opened') or '', x['name']))
    rows = []
    for x in recs:
        an = anchors[x['name']]
        cs = x.get('cq') or []
        k = len([c for c in cs if g['disp'].get(c)])
        st = x.get('status')
        if st == 'closed':
            state = '%s 에서 닫혔다 · 그 항 %s 가운데 %s 처분을 받았다' % (
                code(x['name']), nw(len(cs)), nw(k))
        elif st == 'open':
            state = '%s 열려 있다 · 그 항 %s 가운데 %s 처분을 받았다' % (
                arc_w(x['name'], '이'), nw(len(cs)), nw(k))
        else:
            state = '%s 예약되어 있다' % arc_w(x['name'], '이')
        done = st == 'closed'
        wrap = (lambda s: '<span class="done">%s</span>' % s) if done else (lambda s: s)
        rows.append((wrap(esc(an['struct'])), wrap(esc(an['clause'])),
                     wrap(dot(code(c) for c in cs)), wrap(state)))
    infra = sorted([x['name'] for x in g['arcs'] if not x.get('cq')])
    left = [an['struct'] for x in recs for an in [anchors[x['name']]] if x.get('status') != 'closed']
    order = dot(anchors[x['name']]['struct'] for x in recs)
    left_txt = ('<strong>남은 것이 없다.</strong>' if not left
                else '<strong>남은 것이 %s.</strong>' % morph.cop_end(dot(left)))
    infra_txt = '%s %s' % (dot(code(x) for x in infra), arc_jo(infra[-1], '은'))
    return section('등뼈 — 어디까지 왔는가',
        p('초석 명제가 절 넷으로 위기의 경로를 들고 있으므로, 구조물과 내리는 항을 그 절 위에 놓으면 '
          '어디까지 왔는지가 경로로 읽힌다.'),
        p('<strong>방향은 보이는 표면에서 안쪽으로다.</strong> 아크를 연 순서로 놓으면 %s. %s %s 이 '
          '표에 들지 않는다. 내리는 항을 들지 않는 아크여서 등뼈의 어느 절도 받지 않는다.'
          % (morph.cop_end(order), left_txt, infra_txt)),
        table([('구조물', ''), ('등뼈의 절', 'wrap'), ('묻는 항', 'wrap'), ('상태', 'wrap')], rows),
        p('상태 칸과 묻는 항은 아크 값 정본의 국면과 그 아크의 답할 항 배열과 원장의 처분 필드에서 '
          '유도했고, 순서는 그 아크의 개막 날짜에서 유도했다. 구조물과 등뼈의 절은 생성기가 앞 판의 등뼈 '
          '표에서 아크 이름으로 읽어 이월한다. <strong>그 앵커가 드는 아크의 집합이 물음을 든 아크의 '
          '집합과 양방향으로 닫히는 것을 생성기가 단언한다.</strong> 처분의 계수(%s)는 원장 네 파일의 처분 '
          '필드에서 낸다.' % code(fn_name(cq_dispositions)), 'note'))


def sec_position(g):
    rows = []
    open_left = []
    for c in g['cq']:
        ds = g['disp'].get(c['id'], [])
        arcs = g['cq_arcs'].get(c['id'], [])
        if ds:
            kinds = sorted({d[2] for d in ds})
            cell = '%s (%s)' % (dot(kinds), dot(code(d[1]) for d in ds))
            rows.append(('<span class="done">%s</span>' % code(c['id']),
                         '<span class="done">%s</span>' % dot(code(x) for x in arcs),
                         '<span class="done">%s</span>' % cell))
        else:
            open_left.append(c['id'])
            rows.append((code(c['id']), dot(code(x) for x in arcs), '처분 없음'))
    n = len(g['cq'])
    cur = {}
    for c in g['cq']:
        ds = g['disp'].get(c['id'], [])
        if ds:
            cur[ds[-1][2]] = cur.get(ds[-1][2], 0) + 1
    cur_txt = dot('%s %s' % (k, nw(v)) for k, v in sorted(cur.items()))
    if not open_left:
        lead = ('<strong>전량이 처분을 받았다.</strong> 항마다 가장 큰 원장 번호의 처분을 현행으로 두고 '
                '갈래로 가르면 %s. %s 처분된 항은 그 정의 공백이 구멍으로 기록된 것이며, 그것도 산출물로 '
                '세므로 종료 조건을 닫는다.' % (morph.cop_end(cur_txt), kind_w('hole', '으로')))
    else:
        lead = '<strong>남은 항이 %s.</strong> 현행 처분을 갈래로 가르면 %s.' % (
            codes_cop(open_left), morph.cop_end(cur_txt))
    return section('현 위치 — 내리는 항 %s' % nw(n),
        table([('항', ''), ('아크', ''), ('처분', 'wrap')], rows),
        p(lead),
        p('항과 아크는 아크 값 정본의 그 필드에서 유도했고 처분(%s)은 원장 네 파일의 처분 필드에서 '
          '유도했다. 폐기된 항목의 처분은 뺐다. 항의 유니버스는 관측층의 물음 선언이고 그 목록(%s)은 고정 '
          '절 대조기의 추출로 뽑았다.' % (code(fn_name(cq_dispositions)), code(fn_name(cq_items))),
          'note'))


def layer_txt(d):
    """층별 계수와 그 뒤의 「으로 갈린다」. 조사를 마지막 수의 읽기에서 고른다."""
    items = sorted(d.items(), key=lambda x: (-x[1], x[0]))
    return '%s %s 갈린다' % (dot('%s %d' % kv for kv in items), morph.jo(str(items[-1][1]), '으로'))


def disc_txt(rec):
    """판별선을 드는 자리의 문면. 판별선이 아직 서지 않은 예약 아크는 그 사실을 든다."""
    d = rec.get('discriminator')
    return esc(d) if d else '아직 서지 않았다'


def sec_holes(g):
    n = len(g['live'])
    sp = g['split']
    na = len(g['arc_ptr'])
    blocks = [p('살아 있는 구멍이 <strong>%s</strong> 층으로 가르면 %s.'
                % (ncop(n) + '.', layer_txt(g['layers'])))]
    if na == 0:
        blocks.append(p('<strong>재개 트리거가 아크를 가리키는 구멍이 없다.</strong> 그래서 아크별 '
                        '계수를 드는 표가 이 판에 서지 않는다.'))
    else:
        by = {}
        for e in g['live']:
            r = (e.get('reopen_when') or {}).get('ref')
            if e['id'] in g['arc_ptr']:
                by.setdefault(r, []).append(e)
        rows = []
        for arc, es in sorted(by.items()):
            nb = len([e for e in es if (e.get('reopen_when') or {}).get('kind') == 'blocking'])
            rec = [x for x in g['arcs'] if x['name'] == arc][0]
            rows.append((code(arc), nw(nb), '<strong>%s</strong>' % nw(len(es)),
                         disc_txt(rec)))
        blocks.append(table([('갈래', ''), ('차단', ''), ('합', ''), ('판별선', 'wrap')], rows))
    nn = n - na
    blocks.append(p('아크를 가리키지 않는 것이 %s 용어집과 관측층을 가리키는 %s 갈래가 %s 읽기를 가리키는 %s '
                    '갈래가 %s 트리거가 없는 것이 %s'
                    % (ncop(nn) + '.', code('artifact'), morph.cop_conj(nw(len(sp.get('artifact', []))),
                                                                        '이고'),
                       code('extraction'), morph.cop_conj(nw(len(sp.get('extraction', []))), '이며'),
                       ncop(len(sp.get('none', []))) + '.')))
    nz = len(sp.get('none', []))
    assigned = set()
    for x in g['arcs']:
        if x.get('status') in ('open', 'reserved'):
            assigned |= set(x.get('holes') or [])
    na_z = len(set(sp.get('none', [])) & assigned)
    if nz == 0:
        blocks.append(flag(p('<strong>트리거를 쓸 수 없는 살아 있는 이연이 이 판에 없다.</strong> 그 갈래가 '
                             '다시 서면 기계로 뽑히지 않으므로 아크를 여는 결정이 판별선으로 가려 그 아크의 '
                             '구멍 배열에 넣는 길밖에 없고, 이관의 길이 없어 폐기 레코드가 유일한 처분이다.')))
    else:
        blocks.append(flag(p('<strong>트리거를 쓸 수 없는 %s %s.</strong> 그 항은 기계로 뽑히지 않으므로 '
                             '아크를 여는 결정이 판별선으로 가려 그 아크의 구멍 배열에 넣는 길밖에 없고, '
                             '이관의 길이 없어 폐기 레코드가 유일한 처분이다.'
                             % (nwj(nz, '이'),
                                '전량 어느 열린 아크나 예약된 아크에도 배정되지 않았다' if na_z == 0
                                else '가운데 %s 열린 아크나 예약된 아크에 배정되었다' % nwj(na_z, '이')))))
    blocks.append(p('살아 있는 구멍(%s)은 자기를 가리키는 폐기 레코드가 없는 이연이다. 갈래(%s)는 재개 '
                    '트리거의 종류로 갈랐고 층(%s)은 그 항의 층 필드로 갈랐다. 아크를 가리키는 구멍(%s)은 '
                    '그 트리거의 참조가 아크 값 정본의 아크 이름인 것만 센다. <strong>트리거를 쓸 수 없는 '
                    '것과 아크를 가리키는 것의 계수는 셈법의 정본이 원장 검증기의 보고 검사이므로 그 두 '
                    '계수를 그 검사의 출력(%s)과 맞댔다.</strong>'
                    % (code(fn_name(live_holes)), code(fn_name(trigger_split)),
                       code(fn_name(layer_split)), code(fn_name(arc_pointing)),
                       code(fn_name(ledger_checks))), 'note'))
    return section('구멍의 분포', *blocks)


def sec_next(g):
    st = g['states']
    reserved = [x for x in g['arcs'] if x.get('status') == 'reserved']
    nz = len(g['split'].get('none', []))
    prev_empty = '열려 있는 아크가 없다 — 다음을 고르는 자리' in g['prev']['sections']
    if st.get('open', 0):
        title = '열려 있는 아크 — 무엇을 묻는가'
        opened = [x for x in g['arcs'] if x.get('status') == 'open']
        rows = [(code(x['name']), esc(x.get('discriminator') or ''),
                 dot(code(c) for c in x.get('cq') or []) or '없음') for x in opened]
        return section(title, table([('아크', ''), ('판별선', 'wrap'), ('내리는 항', '')], rows),
                       p('열린 아크의 페이즈와 걸린 구멍은 그 아크의 청사진이 든다.', 'note'))
    blocks = [flag(p('<strong>이 판에서%s 열려 있는 아크가 없다.</strong> %s'
                     % ('도' if prev_empty else '',
                        ('예약된 아크도 없어 아크 값 정본의 아크 전량이 닫혔다. 다음 아크는 그것을 여는 '
                         '결정이 판별선과 페이즈 분할과 걸린 구멍과 내리려는 항과 종료 조건을 함께 세워야 '
                         '선다.' if not reserved else
                         '예약된 아크가 %s 다음 아크를 여는 결정이 그것을 열고 그 아크를 가리키는 살아 '
                         '있는 구멍을 전수로 찾아 구멍 배열에 넣는다.' % (ncop(len(reserved)) + '.')))))]
    if reserved:
        rows = [(code(x['name']), dot(code(c) for c in x.get('cq') or []) or '없음',
                 disc_txt(x)) for x in reserved]
        blocks.append(table([('예약 아크', ''), ('내리는 항', ''), ('판별선', 'wrap')], rows))
    blocks.append(p('<strong>고르는 일을 이 문서가 하지 않는다.</strong> 아크를 여는 것 자체가 결정이므로 '
                    '그 판별선과 페이즈 분할과 걸린 구멍과 내리려는 항과 종료 조건을 원장의 결정 항목이 '
                    '담고 아크 값 정본이 그 값을 든다. 이 절이 드는 것은 그 결정이 받을 대상의 무게다.'))
    tail_z = ('<strong>트리거를 쓸 수 없는 살아 있는 이연이 이 판에 없어 개막 결정이 판별선으로 가려야 할 '
              '목록이 비었다.</strong> 그 목록이 다시 서면 이 문서의 부록이 든다.' if nz == 0 else
              '<strong>트리거를 쓸 수 없는 %s 어느 아크를 열어도 그 개막 결정이 판별선으로 가려야 할 '
              '목록이다.</strong> 그 목록은 이 문서의 부록이 든다.' % nwj(nz, '이'))
    blocks.append(p('살아 있는 차단 구멍이 영이면 아크 종료의 관문에 미리 걸리는 항이 없으므로, 분할의 '
                    '크기를 정하는 것이 판별선으로 가린 몫과 그 아크가 세울 구조물이다. ' + tail_z, 'note'))
    return section('열려 있는 아크가 없다 — 다음을 고르는 자리', *blocks)


def sec_scale(g):
    U = lambda f, u: '%s · 유니버스는 %s' % (code(fn_name(f)), u)  # noqa: E731
    reg = g['reg']
    st = g['states']
    rows = [
        ('형식층 파일', '%d (%s)' % (sum(g['lean'].values()),
                                 dot('%s %d' % kv for kv in sorted(g['lean'].items()))),
         U(lean_files, '풀어 놓은 사본의 형식층 디렉터리에서 확장자가 lean 인 파일')),
        ('원장 전체', '%d (결정 %d · 이연 %d · 기각 %d · 폐기 %d)' % (
            reg['total'], reg['decisions'], reg['deferred'], reg['rejected'], reg['retirements']),
         '%s · 유니버스는 네 레지스터 파일의 배열' % code('bp_measure.registers')),
        ('살아 있는 구멍', str(len(g['live'])), U(live_holes, '이연 레지스터의 entry 전량')),
        ('추출 기록', str(g['ex']), U(extraction_count, '추출 기록 디렉터리의 그 접두를 든 파일')),
        ('페이즈 종료 문서', str(g['closures']), U(closures, '페이즈 디렉터리의 종료 문서')),
        ('패치 레코드', str(g['patches']), '아크 값 정본의 patches 배열의 길이'),
        ('아크', '%d (닫힘 %d · 예약 %d · 열림 %d)' % (
            sum(st.values()), st.get('closed', 0), st.get('reserved', 0), st.get('open', 0)),
         U(arc_states, '아크 값 정본의 arcs 배열')),
        ('머리', code(g['head']['head']), '풀어 놓은 커밋의 짧은 번호'),
    ]
    return section('리포의 현 규모',
        table([('재는 것', ''), ('값', 'wrap'), ('그 값을 내는 함수와 유니버스', 'wrap')],
              [(x, y, z) for x, y, z in rows]),
        p('값은 머리 커밋을 풀어 놓은 사본에서 실측한 것이고 정본은 리포다. 살아 있음은 자기를 가리키는 '
          '폐기 레코드가 없는 것으로 유도했다. <strong>최상위 선언의 수는 Lean 툴체인으로 빌드해야 '
          '재어지고 이 생성기가 빌드를 돌리지 않으므로 이 표가 그 행을 들지 않는다.</strong> 앞 판이나 '
          '검증 출력의 값을 옮겨 적으면 그것이 이 커밋의 실측이 아니다.', 'note'))


def sec_checks(g, axes):
    lis = ['%s' % esc(x) for x in axes]
    asr = ['%s' % esc(x) for x in g['asserted']]
    return section('이 산출이 받은 확인',
        p('<strong>이 산출을 내는 생성기가 축 %s 본편과 부록을 함께 재고 그 전량에서 적발이 영일 때에만 '
          '파일을 쓴다.</strong> 그 목록을 산문이 손으로 적지 않고 축 설비의 축 목록에서 유도하므로, 축이 '
          '하나 늘면 이 목록이 함께 는다.' % morph.num(len(axes), '으로')),
        ul(lis),
        p('<strong>생성기가 실측을 모으며 단언한 것이 %s.</strong> 이 목록도 그 단언이 통과한 자리에서 '
          '쌓인 것을 옮긴 것이다.' % ncop(len(asr))),
        ul(asr),
        p('띄워 보아야 서는 축은 머리 없는 브라우저로 두 문서를 띄워 계산된 양식과 표와 행을 재고 '
          '렌더링된 본문에서 빈 보간을 찾은 것이고, 나머지는 문면을 읽어 잰 것이다. <strong>축마다 음성 '
          '대조를 세워 주입이 전량 한 번씩 터지는 것을 함께 쟀다.</strong> 앞 판이 든 절을 이 판이 '
          '빠뜨리지 않는지와 같은 커밋에서 다시 돌린 산출이 바이트로 같은지와 계수를 낸 함수를 다시 불러 '
          '같은 값이 나오는지도 쟀다.', 'note'))


# ── 부록의 절 ─────────────────────────────────────────────────────────────

def sec_status_app(g, dropped):
    rows = [
        ('원장의 결정 항목', '<strong>계수가 바뀐다.</strong> 구멍이 하나 서거나 폐기될 때마다 이 재고의 '
         '수가 달라지는데, 작업이 진행되면서 바뀔 값은 항목의 진술에 싣지 않고 그 값의 거처를 역할 '
         '이름으로 부르라는 요구가 서 있다'),
        ('아크 값 정본의 구멍 배열', '<strong>개막 결정이 채우는 자리다.</strong> 아크를 여는 결정이 그 '
         '아크를 가리키는 살아 있는 구멍을 전수로 찾아 넣으라는 요구가 서 있고, 트리거를 쓸 수 없는 '
         '항은 그 결정이 판별선으로 가려 넣는다'),
        ('청사진', '<strong>아크가 닫히면 보관하거나 지운다.</strong> 이 재고는 어느 아크가 열릴 때 그 '
         '개막 결정이 다시 뽑을 목록이어서 어느 청사진보다 오래 산다'),
        ('Lean 파일의 주석', '<strong>전사가 되고 재고를 한 번에 세는 자리가 서지 않는다.</strong> 구멍의 '
         '정본은 원장의 이연 레지스터이고 그 문면을 주석에 다시 적으면 값을 전사하지 말라는 요구를 '
         '어긴다'),
    ]
    blocks = [
        flag(p('<strong>이 부록은 항해도의 부록이며 정본이 아니다.</strong> 아크와 페이즈의 값은 아크 값 '
               '정본과 원장이 들고 규율은 세션 지시가 들며, 이 문서가 그것들과 어긋나면 정본이 이긴다. '
               '<strong>미전사분의 거처도 아니다.</strong> 그 자리는 청사진이 든다.')),
        p('이 부록이 드는 재고를 리포 안에 적을 자리가 없다. 사유가 %s.' % ncop(len(rows))),
        table([('적을 수 있어 보이는 자리', ''), ('왜 적을 수 없는가', 'wrap')], rows),
        p('<strong>항해도가 아크를 건너 사는 리포 밖의 사용자 메모이므로 이 부록이 그 자리를 받는다.'
          '</strong> 리포 밖에만 사는 재료를 두지 말라는 요구와 부딪히는 것처럼 보이나, 이 재고의 구멍 '
          '목록은 원장에서 다시 뽑히는 것이어서 그 원천이 리포 안에 있다. 리포에서 유도되지 않는 행은 그 '
          '행을 드는 절이 그 출처를 문면으로 든다.'),
    ]
    if dropped:
        blocks.append(p('<strong>앞 판이 든 절 가운데 이 판이 걷은 것이 %s.</strong> %s.'
                        % (ncop(len(dropped)),
                           ' '.join('「%s」의 갈래에 드는 절은 %s' % (k, DROPPED[k]) for k in dropped))))
    blocks.append(p('값은 머리 커밋을 풀어 놓은 사본에서 실측한 것이고, 생성기가 받은 확인의 목록은 '
                    '「이 산출이 받은 확인」 절이 든다. 이 부록과 본편은 같은 생성기가 같은 사본에서 '
                    '낸다.', 'note'))
    return section('이 부록의 지위와 왜 여기에만 적는가', *blocks)


def sec_split(g):
    sp = g['split']
    na = len(g['arc_ptr'])
    nd = len(sp.get('artifact', [])) + len(sp.get('extraction', []))
    nz = len(sp.get('none', []))
    rows = [('트리거가 아크를 든다', nw(na), '재개 트리거의 참조가 아크 이름이므로 원장에서 기계로 뽑힌다'),
            ('트리거가 자료나 파일을 든다', nw(nd),
             '용어집과 관측층을 가리키는 갈래가 %s 읽기를 가리키는 갈래가 %s 그 조달이나 읽기가 서면 '
             '풀린다' % (morph.cop_conj(nw(len(sp.get('artifact', []))), '이고'),
                       morph.cop_conj(nw(len(sp.get('extraction', []))), '이며'))),
            ('트리거를 쓸 수 없다', nw(nz),
             '<strong>기계로 뽑히지 않는다.</strong> 아크를 여는 결정이 판별선으로 가려 그 아크의 '
             '구멍 배열에 넣는 길밖에 없고 이관의 길이 없다')]
    blocks = [p('<strong>가름은 트리거를 쓸 수 있는가다.</strong> 앞의 갈래는 재개 트리거가 아크 이름을 '
                '들어 원장에서 기계로 뽑히고, 뒤의 갈래는 트리거를 쓸 수 없어 기계로 뽑히지 않는다. 그 '
                '사이에 자료와 파일을 가리키는 갈래가 서며, 그것은 아크가 아니라 조달이 풀어 준다.'),
              table([('갈래', ''), ('계수', ''), ('어떻게 뽑히는가', 'wrap')], rows)]
    if na == 0:
        live_arc = [x for x in g['arcs'] if x.get('status') in ('open', 'reserved')]
        blocks.append(p('<strong>이 판에서 아크를 가리키는 것이 없다.</strong> %s살아 있는 이연 가운데 재개 '
                        '트리거가 아크 이름을 드는 것이 없기 때문이다.'
                        % ('' if live_arc else '열린 아크와 예약된 아크가 없고 ')))
    blocks.append(p('계수(%s)는 재개 트리거의 종류로 가른 것이고, 아크를 드는 계수와 트리거를 쓸 수 없는 '
                    '계수는 원장 검증기의 보고 검사의 출력(%s)과 맞댔다.'
                    % (code(fn_name(trigger_split)), code(fn_name(ledger_checks))), 'note'))
    return section('재고가 세 갈래로 갈린다', *blocks)


def hole_rows(g, ids, with_ref=False):
    es = [e for e in g['live'] if e['id'] in ids]
    es.sort(key=lambda e: int(e['id'][3:]))
    rows = []
    for e in es:
        o = e.get('origin') or {}
        if with_ref:
            rows.append((code(e['id']), esc(e.get('layer') or '—'),
                         quote((e.get('reopen_when') or {}).get('ref') or ''),
                         quote(e.get('statement') or '')))
        else:
            rows.append((code(e['id']), esc(e.get('layer') or '—'), code(o.get('phase') or '—'),
                         quote(e.get('statement') or '')))
    return rows


def sec_notrig(g):
    ids = set(g['split'].get('none', []))
    nz = len(ids)
    if nz == 0:
        return section('트리거를 쓸 수 없는 %s' % nw(nz),
            flag(p('<strong>트리거를 쓸 수 없는 살아 있는 이연이 이 판에 없다.</strong> 그래서 층의 가름과 '
                   '목록이 이 절에 서지 않는다. 그 갈래가 다시 서면 기계로 뽑히지 않으므로 이 절의 목록이 그 '
                   '가름의 유일한 출발점이 된다.')),
            p('그 갈래의 계수(%s)는 재개 트리거의 종류로 가른 것이다.' % code(fn_name(trigger_split)),
              'note'))
    assigned = set()
    for x in g['arcs']:
        if x.get('status') in ('open', 'reserved'):
            assigned |= set(x.get('holes') or [])
    na_z = len(ids & assigned)
    head = ('<strong>이 %s 전량 어느 열린 아크나 예약된 아크에도 배정되지 않았다.</strong>'
            % nwj(nz, '이')) if na_z == 0 else (
            '<strong>이 가운데 %s 열린 아크나 예약된 아크에 배정되었다.</strong>' % nwj(na_z, '이'))
    return section('트리거를 쓸 수 없는 %s' % nw(nz),
        flag(p(head + ' 아크의 개막이 그 가운데 일부를 판별선으로 가려 그 구멍 배열에 받고 그 아크가 닫히면서 '
               '처분하는데, 그 뒤에 선 것이 다시 쌓인다. <strong>기계로 뽑히지 않으므로 이 목록이 그 '
               '가름의 유일한 출발점이다.</strong>')),
        p('<strong>층으로 가르면 %s.</strong> 판별선이 구조물의 이름으로 서므로 설비의 결손이 '
          '그 가름 밖으로 떨어지기 쉽다.' % layer_txt(g['notrig_layers'])),
        table([('구멍', ''), ('층', ''), ('섰다', ''), ('무엇', 'wrap')], hole_rows(g, ids)),
        p('<strong>무엇 칸은 이연 레지스터의 진술을 그대로 옮긴 인용이다.</strong> 층의 분포(%s)는 그 '
          '집합으로 좁혀 낸 것이고, 섰다 칸은 그 항의 출처가 드는 페이즈다.' % code(fn_name(layer_split)),
          'note'))


def sec_arc_invs(g):
    """열린 아크와 예약된 아크마다 그 아크에 걸린 살아 있는 구멍. 그런 아크가 없으면 절이 서지 않는다."""
    live_ids = {e['id'] for e in g['live']}
    out = []
    for x in g['arcs']:
        if x.get('status') not in ('open', 'reserved'):
            continue
        ids = {h for h in (x.get('holes') or []) if h in live_ids}
        ids |= {e['id'] for e in g['live'] if (e.get('reopen_when') or {}).get('ref') == x['name']}
        cq = x.get('cq') or []
        lead = ('<strong>판별선은 「%s」이다.</strong>' % esc(x['discriminator'])
                if x.get('discriminator') else
                '<strong>판별선이 아직 서지 않았다.</strong> 그 아크를 여는 결정이 판별선을 세운다.')
        blocks = [p('%s %s'
                    % (lead,
                       ('내리는 항 %s 걸린다.' % cws(cq, '이')) if cq else '내리는 항이 걸리지 않는다.'))]
        if ids:
            blocks.append(table([('구멍', ''), ('층', ''), ('섰다', ''), ('무엇', 'wrap')],
                                hole_rows(g, ids)))
        else:
            blocks.append(p('<strong>이 아크에 걸린 살아 있는 구멍이 없다.</strong> 비우는 것과 아직 유도하지 '
                            '않은 것이 갈리므로 그 사실을 이 자리가 적는다.'))
        blocks.append(p('이 절의 구멍은 그 아크의 구멍 배열에 든 것과 재개 트리거가 그 아크를 가리키는 것의 '
                        '합집합에서 살아 있는 것이다.', 'note'))
        out.append(section('%s — %s' % (code(x['name']), nw(len(ids))), *blocks))
    return out


def sec_other(g):
    sp = g['split']
    blocks = [p('<strong>이 둘은 재개 조건이 아크가 아니라 산출물과 읽기를 가리킨다.</strong> 앞은 '
                '용어집이나 관측층에 어떤 선언이 서면 깨고, 뒤는 어떤 편을 읽으면 깬다. 그래서 아크를 '
                '여는 결정의 전수 조달에 들지 않고, 그 조건이 충족되는 자리에서 깬다.')]
    for k in ('extraction', 'artifact'):
        ids = set(sp.get(k, []))
        blocks.append(h3('%s %s' % (code(k), nw(len(ids)))))
        if ids:
            blocks.append(table([('구멍', ''), ('층', ''), ('가리키는 것', 'wrap'), ('무엇', 'wrap')],
                                hole_rows(g, ids, with_ref=True)))
        else:
            blocks.append(p('이 갈래가 비었다.'))
    blocks.append(p('가리키는 것 칸은 재개 트리거의 참조를 그대로 옮긴 인용이고, 무엇 칸은 이연 '
                    '레지스터의 진술을 그대로 옮긴 인용이다.', 'note'))
    return section('아크를 가리키지 않으면서 트리거가 서는 것', *blocks)


def sec_procure(g):
    rd = g['reading']
    items = sorted(rd['procure'], key=lambda x: int(x['id'][3:]))
    blocks = [flag(p('<strong>결정 세션은 뭉치 안의 편만 열 수 있고 그 편이 어디에 있는지까지는 조사로 낼 수 '
                     '있으나 그것을 뭉치에 넣는 것은 할 수 없다.</strong> 그래서 이 절의 수취인이 아크가 '
                     '아니라 사용자다.'))]
    if items:
        rows = [(code(x['id']), quote(x['row']['title'] or x['ref']),
                 quote(x['row']['paren'] or '대기열의 행이 괄호를 들지 않는다')) for x in items]
        blocks.append(table([('구멍', ''), ('대기열의 행이 드는 편', 'wrap'), ('대기열의 괄호', 'wrap')],
                            rows))
    else:
        blocks.append(p('<strong>이 판에서 조달 대기가 비었다.</strong>'))
    ni, nm = len(rd['inside']), len(rd['nomatch'])
    blocks.append(p('<strong>이 절의 행(%s)은 읽기 대기열의 지목 참조 대기 표에서 유도했다.</strong> '
                    '살아 있는 추출 갈래 이연마다 굵은 제목이 재개 트리거의 참조와 같은 행을 먼저 찾고 '
                    '없으면 그 번호를 드는 행을 찾으며, 그 행이 뭉치 밖이라는 표지와 대기 표지를 함께 들면 '
                    '이 절에 든다. 두 칸은 그 행의 굵은 제목과 괄호를 그대로 옮긴 인용이다. 그 표지를 '
                    '함께 들지 않은 행에 이어진 읽기 갈래가 %s 그 편이 뭉치에 있는지가 그 행에서 서지 '
                    '않았거나 뭉치 안의 편이므로 이 절에 들지 않으며, 대기열에 행이 없는 읽기 갈래가 %s'
                    % (code(fn_name(reading_split)), morph.cop_conj(nw(ni), '이고'), ncop(nm) + '.')))
    blocks.append(p('<strong>앞 판의 이 절이 든 조사 결론을 이월하지 않는다.</strong> 그 결론 가운데 읽기 '
                    '대기열이 뒤에 고친 문면과 갈리는 것이 있어, 이월하면 알려진 결손이 이 문서에 그대로 '
                    '선다. 조달이 서면 그 편을 읽은 회차가 추출 기록을 세우고 그 기록이 조달처의 정본이 '
                    '된다.', 'note'))
    return section('조달 대기 — 수취인이 사용자인 읽기 %s' % nw(len(items)), *blocks)


def sec_facility(g):
    fac = g['facility']
    prev_empty = '<table>' not in g['prev_app']['sections'].get('집행 구간이 정해지지 않은 작업', '')
    blocks = [flag(p('<strong>이 절은 구멍의 재고를 드는 절들과 지위가 다르다.</strong> 그 절들이 드는 것은 '
                     '구멍이고 아크가 열릴 때 개막 결정이 전수로 받는데, <strong>이것은 구멍이 아니다.'
                     '</strong> 구멍이라는 말을 '
                     '정의의 결손에만 쓰라는 술어 규약이 서 있고 이것은 설비의 대기이므로, 구멍으로 '
                     '발행하면 그 규약을 어기고 구멍 계수를 부풀린다.'))]
    if fac:
        rows = [(esc(x['what']), esc(x['why'])) for x in fac]
        blocks.append(table([('작업', 'wrap'), ('왜 대기인가', 'wrap')], rows))
    else:
        blocks.append(p('<strong>이 판에서%s 그 자리가 비었다.</strong> 계수가 영인 자리를 넘기는 것으로 '
                        '적지 않는다.' % ('도' if prev_empty else '')))
    blocks.append(p('이 절의 항은 원장이 받지 않으므로 리포에서 유도되지 않으며, %s. 그 항이 %s'
                    % ('결정 세션이 이 회차에 생성기에 넘긴 입력이 그 원천이다' if g['tasks_from'] == 'input'
                       else '앞 판의 이 절의 표에서 생성기가 이월한다', ncop(len(fac)) + '.'), 'note'))
    return section('집행 구간이 정해지지 않은 작업', *blocks)


def sec_outside(g):
    es = g['outside']
    blocks = [flag(p('<strong>이 절은 재고의 절들과 「집행 구간이 정해지지 않은 작업」 절과 또 다른 지위를 '
                     '갖는다.</strong> 재고의 절들이 드는 것은 이 프로젝트가 풀 구멍이고 그 절이 드는 것은 '
                     '구멍으로 발행하지 않은 설비의 대기인데, <strong>이 절이 드는 것은 구멍으로 발행됐으나 '
                     '이 프로젝트가 푸는 범위 '
                     '밖인 것이다.</strong> 차단의 축 가운데 이 프로젝트가 푸는 것은 정의 공백 하나인데 이 '
                     '과제는 데이터 공백에 든다.'))]
    if es:
        rows = [(code(e['id']), esc(e.get('layer') or '—'), code((e.get('origin') or {}).get('phase')),
                 quote(e.get('statement') or '')) for e in es]
        blocks.append(table([('구멍', ''), ('층', ''), ('섰다', ''), ('무엇', 'wrap')], rows))
    else:
        blocks.append(p('이 판에서 그 자리가 비었다.'))
    blocks.append(p('<strong>그래서 수취인이 아크가 아니라 사용자다.</strong> 어느 아크를 열어도 그 개막 '
                    '결정이 이것을 자기 몫으로 받지 않으며, 독자 연구의 산출이 서면 그 값이 외생 매개변수로 '
                    '형식층에 들어온다.'))
    blocks.append(p('이 절의 행은 앞 판의 이 절에서 구멍 번호로 이월했다. 그 가름이 원장의 필드에서 '
                    '유도되지 않기 때문이며, 그 구멍이 폐기됐으면 그 대체를 따라가고 그 끝이 아직 살아 '
                    '있는지를 생성기가 단언한다.', 'note'))
    return section('이 프로젝트 밖으로 넘어가는 과제 — 독자 연구 %s' % nw(len(es)), *blocks)


def sec_use(g):
    na = len(g['arc_ptr'])
    nz = len(g['split'].get('none', []))
    first = ('<strong>트리거가 아크를 가리키는 것이 이 판에 없다.</strong>' if na == 0 else
             '<strong>트리거가 아크를 가리키는 것이 %s</strong>' % (ncop(na) + '.'))
    return section('이 재고가 쓰이는 자리',
        p(first + ' 어느 아크가 열릴 때 그 개막 결정이 전수 조달을 수행하며, 그때 원장에서 기계로 다시 '
          '뽑으므로 이 부록의 목록이 그 조달의 정본이 아니다. 이 부록이 하는 일은 둘이다.'),
        ul(['<strong>무게를 미리 알려 준다.</strong> 아크의 페이즈 분할을 개막 시에 전량 정할 때 차단 '
            '트리거의 수가 그 분할의 크기를 정한다.',
            '<strong>조달을 빠뜨렸을 때의 대조 상대가 된다.</strong> 개막 결정이 뽑은 목록과 이 부록을 '
            '맞대면 빠진 것이 그 자리에서 드러난다. 검사가 그것을 잡는 시점은 아크를 열어 페이즈를 '
            '선언한 뒤이므로 늦다.']),
        p(('<strong>트리거를 쓸 수 없는 것이 이 판에 없다.</strong> 그 갈래가 다시 서면 기계로 뽑히지 '
           '않으므로 그 목록이 <strong>대조 상대가 아니라 출발점</strong>이며, 어느 아크를 열 때든 그 '
           '개막 결정이 그 목록 전량을 읽어 판별선으로 가려야 한다.') if nz == 0 else
          ('<strong>트리거를 쓸 수 없는 %s 쓰임이 다르다.</strong> 기계로 뽑히지 않으므로 이 목록이 '
           '<strong>대조 상대가 아니라 출발점</strong>이며, 어느 아크를 열 때든 그 개막 결정이 이 목록 '
           '전량을 읽어 판별선으로 가려야 한다.' % nwj(nz, '은'))),
        p('<strong>조달 대기와 독자 연구의 쓰임은 또 다르다.</strong> 그 항은 어느 개막 결정도 자기 몫으로 '
          '받지 않으므로 조달의 대상이 아니고, 사용자가 그 편을 뭉치에 넣을지와 그 연구를 할지를 정하는 '
          '자리다. 그래서 그 두 절은 프로젝트의 경계가 어디인지를 드는 자리다.'),
        p('<strong>이 부록은 머리에 커밋을 들고 그 시점의 실측임을 밝힌다.</strong> 뒤에 구멍이 늘거나 '
          '폐기되면 이 목록이 그 시점보다 뒤의 상태와 갈리므로, 아크가 닫히는 자리마다 실측으로 다시 '
          '세운다.'))


def sec_tasks(g):
    rows = [(esc(t['task']), esc(t['what']), esc(t['clause']), quote(t['phrase'])) for t in g['tasks']]
    src = ('결정 세션이 이 회차에 규율 문서의 조항에서 뽑아 생성기에 넘긴 입력이다'
           if g['tasks_from'] == 'input' else '앞 판의 이 절의 표에서 생성기가 이월한 것이다')
    return section('수취인이 사용자인 과제',
        p('리포 안의 조작으로 풀리지 않고 사용자의 손을 요구하는 자리다. <strong>그 전량이 리포 밖에 '
          '있으므로 어느 검사도 그것을 재지 않는다.</strong> 조달 대기와 독자 연구를 드는 두 절과 지위가 '
          '다르다. 그것들은 구멍으로 발행된 결손이고 이것은 작업 절차가 요구하는 손이다.'),
        table([('과제', ''), ('무엇', 'wrap'), ('딛는 조항', ''), ('딛는 구절', 'wrap')], rows),
        p('<strong>이 표의 행은 리포 실물에서 유도될 상대가 없어 %s.</strong> 생성기가 행마다 딛는 구절을 '
          '규율 문서의 작업 파일에서 공백을 전량 지운 변으로 되찾아 단언했으며, 다음 판은 이 표를 이월하고 '
          '그 구절을 다시 되찾는다. 딛는 구절 칸은 규율 문서의 문면을 그대로 옮긴 인용이다.' % src,
          'note'))


# ── 조립과 축 ─────────────────────────────────────────────────────────────

def assemble(g, head, style_head, title, secs):
    return ('<!doctype html>\n<html lang="ko">\n<head>\n%s<style>\n%s\n</style>\n</head>\n\n<body>\n'
            '<div class="sheet">\n\n%s\n%s\n\n</div>\n</body>\n</html>\n'
            % (style_head, g['prev']['style'], head, '\n'.join(secs)))


def head_with_title(prev_head, title):
    assert prev_head.count('<title>') == 1, '앞 판의 머리에 제목이 하나가 아니다'
    return re.sub(r'<title>[^<]*</title>', '<title>%s</title>' % title, prev_head)


MAIN = [sec_arc_output, sec_destination, sec_backbone, sec_position, sec_holes, sec_next, sec_scale]
APP = [sec_split, sec_notrig, sec_arc_invs, sec_other, sec_procure, sec_facility, sec_outside,
       sec_use, sec_tasks]


def build(g, axes):
    # 걷은 절을 먼저 가린다. 지위 절이 그 사유를 들어야 하므로 본문을 한 번 세운 뒤에 그 제목을 맞댄다
    body_main = [f(g) for f in MAIN]
    body_app = []
    for f in APP:
        r = f(g)
        body_app += r if isinstance(r, list) else [r]
    draft = '\n'.join(body_main + body_app)
    titles = {title_key(t) for t in re.findall(r'<section>\n  <h2>(.*?)</h2>', draft)}
    titles |= {'이 문서의 지위', '이 부록의 지위와 왜 여기에만 적는가', '이 산출이 받은 확인'}
    old = {title_key(t) for t in g['prev']['sections']} | \
          {title_key(t) for t in g['prev_app']['sections']}
    lost = sorted(old - titles)
    bad = [k for k in lost if k not in DROPPED]
    assert not bad, '앞 판의 절을 빠뜨렸다: %r' % bad
    tm = '항해도 v%d' % g['version']
    main = assemble(g, header(g, False), head_with_title(g['prev']['head'], tm), tm,
                    [sec_status_main(g, lost)] + body_main + [sec_checks(g, axes)])
    ta = '항해도 v%d 부록' % g['version']
    app = assemble(g, header(g, True), head_with_title(g['prev_app']['head'], ta), ta,
                   [sec_status_app(g, lost)] + body_app + [sec_checks(g, axes)])
    return main, app


def axes_for(ops):
    """축 설비의 축에서 이 문서의 축을 세운다. 앞 판의 조작을 재는 축은 앞 판에서 뽑은 문장을 받고,
    조사를 재는 축은 아크 이름의 읽기를 함께 잰다."""
    out = []
    for nm, fn in A.AXES:
        if nm == '앞 판의 조작을 주장하는 문면':
            fn = (lambda o: (lambda t, kinds, path: A.ax_prev(t, o)))(ops)
        elif nm == '보간 뒤의 조사':
            fn = (lambda t, kinds, path: A.ax_josa(t) + [('아크 이름 뒤의 조사', x)
                                                       for x in arc_josa_bad(A._nostyle(t))])
        out.append((nm, fn))
    assert [n for n, _ in out] == A.names(), '축의 목록이 축 설비와 갈린다'
    return out


def run_axes(axes, t, path):
    return [(nm, fn(t, None, path)) for nm, fn in axes]


def negative(axes, ops, t, d):
    """축마다 주입을 세워 전량이 한 번씩 터지는지 잰다. 축 설비의 주입을 쓰고 앞 판의 조작을 재는 축만
    앞 판에서 뽑은 문장을 주입하며, 아크 이름 뒤의 조사를 따로 한 번 더 주입한다."""
    inj = dict(A.INJECT)
    inj['앞 판의 조작을 주장하는 문면'] = lambda x: ('</div>\n</body>', '<p>%s.</p></div>\n</body>'
                                                % SYN_OP)
    plan = [(nm, inj[nm]) for nm, _ in axes]
    plan.append(('보간 뒤의 조사', lambda x: ('</div>\n</body>',
                                          '<p><code>funding</code> 가 닫혔다</p></div>\n</body>')))
    # 한 축에 둘째 주입을 둔 자리는 축 설비의 덧붙인 주입 목록이 든다. 사전으로 읽으면 같은 이름의
    # 주입이 하나로 접히므로 그 목록을 따로 이어 붙인다
    plan += list(A.INJECT_EXTRA)
    fns = dict(axes)
    # 앞 판의 조작을 재는 축은 그 목록에 합성 문장을 더한 판으로 잰다. 앞 판이 그 문장을 하나도 들지
    # 않아도 그 축의 꼴이 동작하는지가 그 자리에서 선다
    fns['앞 판의 조작을 주장하는 문면'] = dict(axes_for(ops + [SYN_OP]))['앞 판의 조작을 주장하는 문면']
    out = []
    for nm, mk in plan:
        if nm == A.RENDER_AXIS:
            tt = t.replace('<style>', '<style>/*', 1).replace('</style>', '*/</style>', 1)
        else:
            lhs, rhs = mk(t)
            assert t.count(lhs) >= 1, '%s 의 주입 좌변이 서지 않는다' % nm
            tt = t.replace(lhs, rhs, 1)
        assert tt != t, '%s 의 주입이 문면을 바꾸지 않았다' % nm
        q = os.path.join(d, 'inj.html')
        io.open(q, 'w', encoding='utf-8').write(tt)
        out.append((nm, len(fns[nm](tt, None, q))))
    silent = [nm for nm, n in out if n == 0]
    assert not silent, '음성 대조가 발화하지 않은 축: %r' % silent
    return out


def main(argv=None):
    ap = argparse.ArgumentParser(description='항해도의 본편과 부록을 낸다')
    ap.add_argument('--commit', default='origin/main')
    ap.add_argument('--prev', required=True)
    ap.add_argument('--prev-appendix', required=True)
    ap.add_argument('--tasks', default=None, help='과제와 설비의 대기를 바꿀 때만 넘긴다')
    ap.add_argument('--rules', action='append', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--out-appendix', required=True)
    ap.add_argument('--dry', action='store_true')
    a = ap.parse_args(argv)

    g = gather(a)
    axes = axes_for(g['ops'])
    names = [n for n, _ in axes]
    main_html, app_html = build(g, names)
    g['M'].recheck([main_html, app_html])
    d = tempfile.mkdtemp()
    dets = []
    for nm, html in (('본편', main_html), ('부록', app_html)):
        f = os.path.join(d, nm + '.html')
        io.open(f, 'w', encoding='utf-8').write(html)
        det = run_axes(axes, html, f)
        bad = [(x, r[:2]) for x, r in det if r]
        assert not bad, '%s 의 적발이 영이 아니다: %r' % (nm, bad)
        dets.append((nm, det))
    negs = [(nm, negative(axes, g['ops'], html, d))
            for nm, html in (('본편', main_html), ('부록', app_html))]

    # 같은 커밋에서 다시 돌린 산출이 바이트로 같은지. 판정은 기억이 아니라 재생성이 한다
    g2 = gather(a)
    m2, a2 = build(g2, [n for n, _ in axes_for(g2['ops'])])
    assert (m2, a2) == (main_html, app_html), '재생성이 다른 바이트를 냈다'
    shutil.rmtree(g['root'], ignore_errors=True)
    shutil.rmtree(g2['root'], ignore_errors=True)

    for path, html in ((a.out, main_html), (a.out_appendix, app_html)):
        h = hashlib.sha256(html.encode()).hexdigest()[:12]
        if not a.dry:
            assert not os.path.exists(path), '이미 선 파일을 덮어쓰지 않는다. 먼저 치워라: %s' % path
            io.open(path, 'w', encoding='utf-8').write(html)
        print('%s · %d 바이트 · %s · 축 %d' % (path, len(html.encode()), h, len(names)))
    for nm, neg in negs:
        print('음성 대조 %s:' % nm, neg)
    print('앞 판의 조작을 주장하는 문장 %d · 머리 %s · 판 v%d'
          % (len(g['ops']), g['head']['head'], g['version']))
    return 0


if __name__ == '__main__':
    sys.exit(main())
