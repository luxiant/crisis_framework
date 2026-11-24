"""청사진을 내는 생성기.

청사진은 결정 세션이 아크를 여는 자리에서 쓰고 페이즈가 닫히는 자리마다 다시 세우는 사용자의
현황 메모이며 리포에 넣지 않는다. 이 생성기는 그 문서의 값을 이 리포의 받은 트리와 회의록의 작업
정본에서 전량 유도하고, 유도될 상대가 없는 것만 개막 결정에서 옮긴 목표 표로 인자로 받아 그 사실을
문면으로 든다. 양식과 머리는 앞 판의 청사진에서 그대로 떼어 쓰고, 앞 판이 든 절을 새 판이 빠뜨리지
않는지를 그 앞 판과 맞대어 잰다. 축 아홉으로 자기 산출을 재고 그 전량에서 적발이 영일 때에만 파일을
쓰며, 축마다 음성 대조를 돌린다.

받은 트리는 이 파일이 사는 리포이고, 그 머리가 원격 추적 머리와 같고 작업 트리가 깨끗해야 한다.
리포 밖의 문서는 전부 인자로 받고 리포 밖의 경로를 상수로 들지 않는다.

쓰는 꼴:
  python3 scripts/blueprint.py --minutes <회의록> --arc <아크> --phase <페이즈> \
      --goals <목표 표 JSON> --prev <앞 판 청사진> --out <산출 경로> [--dry]

목표 표 JSON 은 {"goals": [{"name", "axis", "question", "phases"}], "exit": [종료 조건]} 이다.
"""
import argparse
import hashlib
import io
import json
import os
import re
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import bp_axes as A  # noqa: E402
import bp_measure as B  # noqa: E402
import minutes as M  # noqa: E402
import morph  # noqa: E402

REPO = HERE.parent

# 앞 판이 들었으나 이 판이 걷는 절과 그 사유. 앞 판의 절을 빠뜨리지 않는지 재는 단언이 이 사상에
# 든 절만 빠짐으로 받으며, 그 사유를 지위 절이 문면으로 든다
DROPPED = {
    '수취 경계 밖의 부류': ('역할 통합으로 카드와 그 동결이 사라져 갈래가 「없음」인 낙착을 결정 세션이 그 '
                       '거처에 바로 싣으므로, 이 문서가 그 처분을 기다리며 들 것이 없다'),
}


# ── 산출의 조각 ────────────────────────────────────────────────────────────

def esc(s):
    return (str(s).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;'))


def tick(s):
    """회의록의 코드 표기를 산출의 꼴로 옮긴다. 옮기지 않으면 백틱이 문자로 선다."""
    out, i = [], 0
    for m in re.finditer(r'`([^`]+)`', s):
        out.append(esc(s[i:m.start()]))
        out.append('<code>%s</code>' % esc(m.group(1)))
        i = m.end()
    out.append(esc(s[i:]))
    return ''.join(out)


def bold(s):
    """회의록의 굵은 표지를 산출의 꼴로 옮긴다."""
    parts = s.split('**')
    out = []
    for i, part in enumerate(parts):
        out.append(('<strong>%s</strong>' % tick(part)) if i % 2 else tick(part))
    return ''.join(out)


def gist(s):
    """회의록의 요지를 옮겨 싣는 칸. 이 문서가 쓴 문면이 아니라 인용임을 표지로 든다."""
    return '<span class="gist">%s</span>' % bold(s)


def code(s):
    return '<code>%s</code>' % esc(s)


def table(heads, rows):
    """표를 낸다. 머리 행을 틀에만 두고 값의 목록에 함께 두지 않는다."""
    assert rows, '값이 없는 표를 두지 않는다'
    n = len(heads)
    for r in rows:
        assert len(r) == n, '표의 칸이 머리와 갈린다: %d · %d' % (len(r), n)
    th = ''.join('<th class="%s">%s</th>' % (c, t) for t, c in heads)
    tr = []
    for r in rows:
        tr.append('<tr>' + ''.join('<td class="%s">%s</td>' % (c, v)
                                   for v, (_, c) in zip(r, heads)) + '</tr>')
    return ('<div class="table-wrap">\n<table>\n<thead><tr>%s</tr></thead>\n<tbody>\n%s\n'
            '</tbody>\n</table>\n</div>' % (th, '\n'.join(tr)))


def section(title, *blocks):
    return '<section>\n  <h2>%s</h2>\n%s\n</section>' % (
        title, '\n'.join(b for b in blocks if b))


def p(s, cls=None):
    return '  <p%s>%s</p>' % ((' class="%s"' % cls) if cls else '', s)


def flag(*ps):
    return '  <div class="flag">\n%s\n  </div>' % '\n'.join('  ' + x for x in ps)


U = lambda s: '<br><span class="note">유니버스 · %s</span>' % s  # noqa: E731


# ── 앞 판 ─────────────────────────────────────────────────────────────────

def prev_parts(html):
    """앞 판에서 머리와 양식과 절 제목과 절마다의 값 행 수와 그 판의 페이즈를 뗀다."""
    hm = re.search(r'(?s)<head>\n(.*?)<style>\n(.*?)\n</style>\n</head>', html)
    assert hm, '앞 판에서 머리와 양식을 떼지 못했다'
    secs = {}
    for sm in re.finditer(r'(?s)<section>\n  <h2>(.*?)</h2>(.*?)</section>', html):
        body = sm.group(2)
        rows = len(re.findall(r'<tr>', body)) - len(re.findall(r'<thead><tr>', body))
        secs[sm.group(1)] = rows
    am = re.search(r'<p class="asof"><code>([a-z]+-\d+)</code>', html)
    assert am, '앞 판의 머리에서 페이즈를 읽지 못했다'
    return {'head': hm.group(1), 'style': hm.group(2), 'sections': secs, 'phase': am.group(1)}


def title_key(t):
    """절 제목의 비교 키. 페이즈 수를 드는 제목은 수사가 판마다 바뀌므로 그 수사를 걷는다."""
    return re.sub(r'^페이즈 \S+$', '페이즈 *', t)


# ── 실측을 모은다 ─────────────────────────────────────────────────────────

def gather(a, prev):
    hd = B.head(REPO)
    reg = B.registers(REPO)
    st = B.arc_stats(REPO, a.arc)
    live = B.live_deferred(REPO)
    no_trig = [e for e in live if not e.get('reopen_when')]
    this_arc = [e for e in live if (e.get('reopen_when') or {}).get('ref') == a.arc]
    closed = B.closed_phases(REPO, a.arc)
    phase_closed = (REPO / 'docs' / 'phases' / ('%s-closure.md' % a.phase)).is_file()
    assert (a.phase in closed) == phase_closed, '종료 문서의 유무와 닫힌 페이즈의 목록이 갈린다'

    mtext = io.open(a.minutes, encoding='utf-8').read()
    hm = M.PHASE_HEAD.search(mtext)
    assert hm and hm.group(1) == a.phase, '회의록의 머리가 이 페이즈를 들지 않는다'
    topics, gg, decls, applied, ghosts = M.read(mtext)
    assert not ghosts, '회의록의 선언이 유령을 남긴다: %r' % (ghosts,)
    # 폐기된 줄은 회의록에서 유도되는 목록 전량의 유니버스 밖이다
    retired = sorted(k for k, v in gg.items() if v.get('retired'))
    allcount = len(gg)
    live_g = {k: v for k, v in gg.items() if not v.get('retired')}
    assert len(live_g) + len(retired) == allcount, '살아 있는 것과 폐기된 것이 전량을 덮지 않는다'
    # 폐기를 세는 둘째 경로. 회의록의 원문에서 폐기 선언을 직접 세어 첫째 경로와 맞댄다
    rdecl = sorted({tuple(d['target']) for d in decls if d['kind'] == 'retire'})
    assert rdecl == retired, '폐기를 세는 두 경로가 갈린다: %r · %r' % (rdecl, retired)

    # 원장에 진술이 서지 않은 레지스터 갈래의 낙착. 기각 갈래는 진술이 요지에서 유도되지
    # 않으므로 이 페이즈가 기각 레지스터에 항을 하나라도 실었는지로 가른다
    led = M.to_ledger(live_g, M.ledger_live())
    rej_this = [e for e in B.entries(REPO, 'rejected')
                if (e.get('origin') or {}).get('phase') == a.phase]
    rej_pending = [] if rej_this else list(led['manual'])
    pending = [x['id'] for x in led['pending']] + rej_pending
    return {
        'a': a, 'prev': prev, 'head': hd, 'reg': reg, 'arc': st, 'live': live,
        'no_trig': no_trig, 'this_arc': this_arc, 'closed': closed,
        'phase_closed': phase_closed, 'lean': B.lean_files(REPO),
        'holes': B.hole_rows(REPO, a.arc), 'art': B.artifact_rows(REPO),
        'ex': B.extractions(REPO), 'topics': topics, 'gg': live_g, 'retired': retired,
        'led': led, 'rej_this': len(rej_this), 'pending': pending,
    }


# ── 절 ────────────────────────────────────────────────────────────────────

def sec_status(g):
    """이 문서의 지위."""
    dropped = [(t, r) for t, r in DROPPED.items() if t in g['prev']['sections']]
    blocks = [
      flag(p('<strong>이 문서는 사용자가 현황을 읽는 메모이고 정본이 아니다.</strong> 아크와 '
             '페이즈의 값에 대해 정본은 아크 값 정본과 원장이며 어긋나면 정본이 이긴다. 리포에 '
             '넣지 않고 프로젝트 디렉터리에만 둔다. <strong>다만 「미전사분」 절만은 메모가 '
             '아니다.</strong> 그 문면이 그 뒤에 원장에 항목을 싣는 첫 회차의 선별이 처분하기 '
             '전까지 여기에만 살므로 그 자리를 지우지 않는다.')),
      p('이 판이 드는 값의 출처가 셋이다. <strong>리포 실물에서 유도한 것</strong>과 '
        '<strong>회의록의 작업 정본에서 유도한 것</strong>과 <strong>개막 결정에서 옮겨 유도될 '
        '상대가 없는 것</strong>이며, 값마다 그것을 내는 명령과 그 명령이 매긴 유니버스를 같은 '
        '자리에 둔다. 셋째 부류는 목표 표의 축 열과 그 목표를 받는 페이즈 열과 종료 조건뿐이고 '
        '그 논증은 개막 결정이 든다. 페이즈의 세울 것 열과 받는 구멍 열은 아크 값 정본에서 '
        '유도한다. 이 문서는 리포 밖에 있어 리포 검사의 유니버스에 들지 않는다.'),
      p('양식과 머리는 앞 판에서 그대로 떼어 썼다. 그것이 계수도 식별자도 아니어서 실측에서 '
        '유도될 상대가 없기 때문이며, 그 옮김을 생성기가 하므로 결정 세션의 옮겨 적기를 '
        '지나지 않는다.', 'note'),
    ]
    if dropped:
        blocks.append(p('<strong>앞 판이 든 절 가운데 이 판이 걷은 것이 %s.</strong> %s. 앞 판의 '
                        '절을 빠뜨리지 않는지 재는 단언이 걷은 절의 사상에 든 것만 빠짐으로 '
                        '받는다.'
                        % (morph.cop_end(morph.native(len(dropped))),
                           ' '.join('「%s」 절은 %s' % (t, r) for t, r in dropped))))
    return section('이 문서의 지위', *blocks)


def sec_asks(g):
    """이 아크가 무엇을 묻는가."""
    goals = g['a'].goals_doc['goals']
    exits = g['a'].goals_doc['exit']
    disc = g['arc']['rec'].get('discriminator') or ''
    rows = [(esc(x['name']), '<b>%s</b>' % esc(x['axis']), esc(x['question']),
             ' · '.join(code(y) for y in x['phases'])) for x in goals]
    heads = [('목표', ''), ('무엇을 묻는가', 'nw'), ('그 물음이 묻는 것', 'wrap'),
             ('그 목표를 받는 페이즈', 'wrap')]
    cq = g['arc']['cq']
    return section('이 아크가 무엇을 묻는가',
      p('<strong>판별선은 「%s」 하나다.</strong> 이 값은 아크 값 정본에서 읽었다.' % esc(disc)),
      '  <h3>세부 목표 %s</h3>' % morph.native(len(goals)),
      p('초석 명제가 위기의 경로를 절로 들고 그 등뼈의 조달 절이 불일치가 조달에서 서는 자리로 '
        '서므로, 그 경로를 축으로 목표를 갈랐다. <strong>내리는 항의 서명을 축으로 쓰는 안은 그 '
        '서명이 조달이 끊기는 자리를 받지 않아 기각했다.</strong>'),
      table(heads, rows),
      '  <h3>내리는 항</h3>',
      p('이 아크가 내리려는 항은 %s 이다. 그 항의 문면과 답 타입의 정본은 관측층의 선언이고 이 '
        '문서가 그것을 옮겨 적지 않는다.' % ' · '.join(code(x) for x in cq)),
      '  <h3>종료 조건 %s</h3>' % morph.native(len(exits)),
      '  <ul>%s</ul>' % ''.join('<li>%s</li>' % esc(x) for x in exits))


def sec_phases(g):
    """페이즈 표. 세울 것과 받는 구멍을 아크 값 정본에서 유도한다."""
    ph = g['arc']['phases']
    closed = set(g['closed'])
    goal_of = {}
    for x in g['a'].goals_doc['goals']:
        for y in x['phases']:
            goal_of[y] = x['name']
    rows = []
    for rec in ph:
        nm = rec.get('name')
        state = ('<span class="done">닫혔다</span>' if nm in closed
                 else '진행 중' if nm == g['a'].phase
                 else '<span class="done">서지 않았다</span>')
        hs = rec.get('holes') or []
        rows.append((code(nm), state, esc(goal_of.get(nm, '—')),
                     esc(rec.get('builds') or ''),
                     ' · '.join(code(x) for x in hs) if hs else '없음'))
    heads = [('페이즈', ''), ('국면', 'nw'), ('목표', 'nw'),
             ('세울 것', 'wrap'), ('받는 구멍', 'wrap')]
    nc, nt = len(closed), len(ph)
    return section('페이즈 %s' % morph.native(nt),
      p('<strong>분할은 개막 시에 전량 정해지고 그 뒤의 이동은 패치가 받는다.</strong> 국면 열을 '
        '각 페이즈의 종료 문서가 이 판의 트리에 서는지에서 유도했고 %s 섰으므로, 닫힌 것은 %s '
        '이고 나머지 %s 아직 닫히지 않았다. <strong>걷힌 페이즈는 아크 값 정본의 페이즈 배열에서 '
        '빠지므로 이 표에도 서지 않고, 그 걷음은 패치 레코드가 든다.</strong>'
        % (morph.digits(nc, '이'), ' · '.join(code(x) for x in sorted(closed)),
           morph.digits(nt - nc, '은'))),
      table(heads, rows),
      p('받는 구멍 열이 아크 값 정본의 그 페이즈 레코드에서 유도된다. <strong>그 배정이 비어 '
        '있으면 그 사실이 그 칸에 서고, 이 회차가 발행한 구멍의 배정도 그 자리가 든다.</strong>',
        'note'))


def sec_holes(g):
    """이 아크에 걸린 구멍."""
    rows = []
    for r in g['holes']:
        state = ('<span class="done">폐기됐다</span>' if r['retired'] else '살아 있다')
        rows.append((code(r['id']), esc(r['layer']),
                     code(r['trigger']) if r['trigger'] else '판별선',
                     esc(r['what']),
                     ' · '.join(code(x) for x in r['phases']) if r['phases'] else '없음',
                     state))
    heads = [('구멍', ''), ('층', 'nw'), ('트리거', 'nw'), ('무엇', 'wrap'),
             ('푸는 페이즈', 'nw'), ('국면', 'nw')]
    n = len(g['holes'])
    nret = len([r for r in g['holes'] if r['retired']])
    return section('이 아크에 걸린 구멍',
      p('이 아크가 받는 구멍이 %s 이 절의 표가 드는 살아 있음을 폐기 레코드가 그 번호를 '
        '가리키는지에서 유도했으며 그 가운데 %s 폐기되고 %s 살아 있다. <strong>전수 조달의 '
        '유니버스를 트리거가 닫고 그것으로 뽑히지 않는 항을 개막이 판별선으로 가려 그 위에 '
        '더했으며, 이 아크의 읽기가 낸 구멍이 그 위에 다시 더해졌다.</strong>'
        % (morph.cop_conj(morph.digits(n), '이고'), morph.digits(nret, '이'),
           morph.digits(n - nret, '이'))),
      table(heads, rows),
      p('<strong>무엇 칸은 이연 레지스터의 산문을 그대로 옮긴 인용이다.</strong> 이 배정은 아크의 '
        '구멍 배열과 각 페이즈의 구멍 배열에 함께 실려야 하며, 한쪽에만 실으면 그 구멍이 어느 '
        '자리에서도 처분을 요구받지 않는다. <strong>푸는 페이즈 칸이 그 페이즈의 구멍 배열에서 '
        '유도되므로 그 배정이 비어 있으면 그 사실이 그 칸에 선다.</strong>', 'note'))


def sec_measure(g):
    """이 판의 실측."""
    reg, st = g['reg'], g['arc']
    by = st['by_status']
    lean = g['lean']
    rows = [
      ('원장 전체', reg['total'], '네 레지스터의 배열 길이의 합' + U('원장 entry 전량')),
      ('결정 레지스터', reg['decisions'], '그 레지스터 파일의 배열 길이' + U('그 레지스터의 entry 전량')),
      ('이연 레지스터', reg['deferred'], '그 레지스터 파일의 배열 길이' + U('그 레지스터의 entry 전량')),
      ('기각 레지스터', reg['rejected'], '그 레지스터 파일의 배열 길이' + U('그 레지스터의 entry 전량')),
      ('폐기 레지스터', reg['retirements'], '그 레지스터 파일의 배열 길이' + U('그 레지스터의 entry 전량')),
      ('살아 있는 이연', len(g['live']),
       '폐기 레코드의 target 이 가리키지 않는 이연을 센다' + U('이연 레지스터의 entry 전량')),
      ('그 가운데 트리거를 비운 것', len(g['no_trig']),
       '그 살아 있는 항 가운데 reopen_when 이 null 인 것을 센다' + U('살아 있는 이연 전량')),
      ('트리거가 이 아크를 드는 것', len(g['this_arc']),
       '재개 트리거의 참조가 이 아크의 이름인 살아 있는 이연을 센다' + U('살아 있는 이연 전량')),
      ('아크 값 정본의 아크', st['arcs'], '그 파일의 arcs 배열 길이' + U('아크 전량')),
    ]
    for k in ('closed', 'open', 'reserved'):
        rows.append(('그 가운데 %s' % {'closed': '닫힌 것', 'open': '열린 것',
                                     'reserved': '예약된 것'}[k],
                     by.get(k, 0),
                     '그 배열에서 status 가 %s 인 것을 센다' % k + U('아크 전량')))
    rows += [
      ('이 아크의 선언된 페이즈', len(st['phases']),
       '이 아크 레코드의 phases 배열 길이' + U('이 아크의 페이즈 전량')),
      ('패치 레코드', st['patches'], '그 파일의 patches 배열 길이' + U('패치 레코드 전량')),
      ('이 아크의 닫힌 페이즈', len(g['closed']),
       '이 아크의 종료 문서가 그 트리에 서는 것을 센다' + U('이 아크의 페이즈 전량')),
      ('추출 기록', len(g['ex']),
       '그 디렉터리의 추적 파일 가운데 이름이 그 접두를 드는 것을 센다' + U('추출 기록 전량')),
    ]
    rows.append(('형식층 파일',
                 ' · '.join('%s %d' % (k, v) for k, v in sorted(lean.items())),
                 '그 디렉터리의 추적 파일 가운데 확장자가 lean 인 것을 센다'
                 + U('형식층의 추적 파일 전량')))
    heads = [('재는 것', 'wrap'), ('값', 'nw'), ('그 값을 내는 명령', 'wrap')]
    return section('이 판의 실측 · 원장과 아크',
      p('이 절의 값을 원격 추적 머리 %s 에서 유도했다. <strong>원천을 이 페이즈의 받은 커밋으로 '
        '두면 그 뒤에 선 커밋이 바꾼 값을 이 표가 들지 못한다.</strong>'
        % code(g['head']['head']), 'note'),
      table(heads, [(x, esc(y), z) for x, y, z in rows]))


def sec_artifact(g):
    """자료의 조달과 이연의 처분을 가른 칸.

    유니버스는 추출 갈래를 가진 살아 있는 이연 전량이고 한 아크로 좁히지 않는다.
    """
    heads = [('재는 것', 'wrap'), ('값', 'nw'), ('그 값을 내는 명령', 'wrap')]
    rows = [
      ('추출 갈래의 살아 있는 이연', len(g['art']),
       '재개 트리거의 갈래가 extraction 인 이연 가운데 폐기 레코드가 가리키지 않는 것을 센다'
       + U('이연 레지스터의 entry 전량')),
      ('그 가운데 처분이 선 것', 0,
       '그 항을 가리키는 폐기 레코드를 센다' + U('추출 갈래의 살아 있는 이연 전량')),
    ]
    return section('자료의 조달과 이연의 처분',
      flag(p('<strong>이 두 사실을 한 칸이 들지 않는다.</strong> 자료가 조달되어 추출 기록이 '
             '섰다는 사실과 그 항이 처분됐다는 사실이 다르므로, 한 칸이 둘을 함께 들면 살아 있는 '
             '항목이 해소된 것으로 적힌다. <strong>조달은 이 표가 재지 않으며 그 사유를 이 절의 '
             '끝 문단이 든다.</strong>')),
      table(heads, [(x, esc(y), z) for x, y, z in rows]),
      p('<strong>조달이 섰는지를 이 표가 재지 않는다.</strong> 그 재개 트리거가 드는 참조가 찾는 '
        '자료의 서술이고 편의 제목이 아니므로 추출 기록의 머리가 드는 제목과 맞대어지지 않으며, '
        '그 맞댐을 억지로 세우면 전량이 미포착으로 서서 그 대조가 아무것도 재지 못한다. '
        '<strong>재지 않은 것과 영이 갈리므로 그 사실을 이 자리가 적는다.</strong> 처분은 재어지며 '
        '살아 있는 항의 정의가 폐기 레코드가 가리키지 않는 것이므로 그 값이 구조적으로 영이다.',
        'note'))


def sec_outside(g):
    """리포 밖의 재료."""
    gg = g['gg']
    regs = set(M.KINDS)
    kind_reg = [k for k, v in gg.items() if (v.get('kind') or '') in regs]
    kind_none = [k for k, v in gg.items() if (v.get('kind') or '') == '없음']
    kind_abs = [k for k, v in gg.items() if (v.get('kind') or '').startswith('흡수')]
    no_home = [k for k, v in gg.items() if not v.get('homes')]
    by_topic = {}
    for k in gg:
        by_topic[k[0]] = by_topic.get(k[0], 0) + 1
    empty = [t for t in g['topics'] if by_topic.get(t['num'], 0) == 0]
    E = ' · 결정 세션의 컨테이너'
    rows = [
      ('이 페이즈의 회의록이 든 화두', len(g['topics']),
       '줄 머리의 화두 제목을 센다' + U('회의록 작업 정본' + E)),
      ('그 회의록의 살아 있는 낙착', len(gg),
       '낙착을 번호로 묶어 세고 폐기된 줄을 뺀다' + U('회의록 작업 정본' + E)),
      ('그 회의록의 폐기된 낙착', len(g['retired']),
       '폐기 선언이 가리키는 낙착을 세고 낙착의 폐기 표지와 맞댄다' + U('회의록 작업 정본' + E)),
      ('그 가운데 갈래가 원장 레지스터를 드는 것', len(kind_reg),
       '갈래 자리가 네 레지스터의 이름 가운데 하나를 드는 낙착을 센다' + U('살아 있는 낙착 전량')),
      ('그 가운데 갈래가 「없음」인 것', len(kind_none),
       '갈래 자리가 고정된 「없음」의 꼴을 드는 낙착을 센다' + U('살아 있는 낙착 전량')),
      ('그 가운데 다른 entry 에 흡수되는 것', len(kind_abs),
       '갈래 자리가 고정된 흡수의 꼴을 드는 낙착을 센다' + U('살아 있는 낙착 전량')),
      ('거처를 하나도 들지 않는 낙착', len(no_home),
       '굵은 구간에서 거처의 이름을 뽑아 비는 낙착을 센다' + U('살아 있는 낙착 전량')),
      ('낙착이 영인 화두', len(empty),
       '화두마다 그 아래의 낙착을 세어 영인 것을 센다' + U('화두 전량')),
    ]
    heads = [('재는 것', 'wrap'), ('값', 'nw'), ('그 값을 내는 명령', 'wrap')]
    close_txt = ('낙착 전량의 거처가 닫힌다' if not no_home
                 else '그 낙착의 거처가 서기 전까지 이 페이즈가 닫히지 않는다')
    return section('리포 밖의 재료',
      p('이 절의 값은 리포에 들어가지 않는 재료에 걸려 있으므로 그것을 잰 환경의 지문을 함께 든다. '
        '결정 세션의 컨테이너에 뜬 회의록의 작업 정본이 그 재료이며, 그 재료가 리포 밖에 있어 '
        '리포 안의 어느 검사도 이 값을 다시 재지 못한다.', 'note'),
      table(heads, [(x, esc(y), z) for x, y, z in rows]),
      p('거처를 하나도 들지 않는 낙착이 %s %s. 이것이 그 페이즈를 닫는 관문 가운데 뒤의 것이며, '
        '앞의 것은 낙착이 영인 화두가 영인지이고 사람이 읽어 잰다.'
        % (morph.native(len(no_home)) + '이므로', close_txt), 'note'))


def sec_inherited(g):
    """앞 페이즈에서 받아 남는 항. 이 페이즈가 남기는 몫과 다른 절로 가른다.

    앞 판의 문면을 복제하지 않고 앞 판의 절에서 행을 센다. 앞 판의 미전사분 행이 있으면 그
    처분의 사상을 인자로 받아야 하며, 받지 않으면 그 자리에서 터뜨린다.
    """
    pv = g['prev']
    pp = pv['phase']
    nun = pv['sections'].get('미전사분', 0)
    nout = pv['sections'].get('수취 경계 밖의 부류', 0)
    if nun:
        disp = g['a'].prior_doc
        assert disp and len(disp) == nun, \
            '앞 판의 미전사분 행 %d 의 처분 사상을 인자로 받지 않았다' % nun
        rows = [(code(x['id']) if x.get('id') else '—', esc(x['disposition']), gist(x['gist']))
                for x in disp]
        head = flag(p('<strong>%s 에서 받은 미전사분 항이 %s.</strong> 그 처분을 이 회차의 '
                      '선별이 냈고 이 표가 그 사상을 그대로 든다.'
                      % (code(pp), morph.cop_end(morph.native(nun)))))
    else:
        rows = []
        head = flag(p('<strong>%s 에서 받아 원장에 넣을 몫이 없다.</strong> 앞 판의 미전사분 '
                      '절에 항이 서지 않았다.' % code(pp)))
    body = [head]
    if rows:
        body.append(table([('원장 항', ''), ('처분', 'nw'), ('요지', 'wrap')], rows))
    if nun or nout:
        closing = ('그 계수를 이 페이즈의 종료 문서가 함께 든다' if g['phase_closed']
                   else '그 계수를 이 페이즈를 닫는 커밋의 종료 문서가 받는다')
        body.append(p('<strong>이 판을 다시 세우며 앞 판이 든 미전사분 항 %s 수취 경계 밖의 부류 '
                      '%s 이 문서에서 걷었다.</strong> 뒤의 것은 %s 의 카드가 동결된 뒤에 선 '
                      '낙착 가운데 갈래가 「없음」인 것이어서 그 처분이 이미 선 것이다. 그 계수는 '
                      '앞 판의 이 문서에서 쟀고, %s.'
                      % (morph.w(morph.native(nun), '과'), morph.w(morph.native(nout), '을'),
                         code(pp), closing)))
    body.append(p('<strong>이 절과 「미전사분」 절을 한 목록이 함께 들지 않는다.</strong> 앞에서 '
                  '받아 원장에 넣을 몫과 이 페이즈가 남기는 몫이 수명이 다르고, 뒤의 것은 그 뒤에 '
                  '원장에 항목을 싣는 첫 회차가 받는다.', 'note'))
    return section('앞 페이즈에서 받아 남는 항', *body)


SELFNUM = re.compile(r'^`낙착-\d+-\(\d+\)`\s*')


def gist_of(v):
    """요지에서 자기 낙착 번호를 걷는다. 표의 첫 칸이 이미 그것을 들므로 되풀이하지 않는다."""
    return SELFNUM.sub('', (v.get('gist') or '').strip())


def sec_untrans(g):
    """미전사분. 원장에 진술이 아직 서지 않은 레지스터 갈래의 낙착을 회의록과 원장에서 유도한다.

    페이즈의 마지막 push 앞에서는 그 낙착이 그 페이즈가 실을 몫이고 미전사분이 아니므로
    국면으로 계수와 산문을 함께 가른다.
    """
    led = g['led']
    nrec = len(led['recorded'])
    nman = len(led['manual'])
    pend = g['pending']
    nreg = nrec + len(led['pending']) + nman
    head = p('이 회의록에서 갈래가 원장 레지스터를 드는 살아 있는 낙착이 %s 그 가운데 진술이 '
             '원장에 이미 선 것이 %s. 기각 갈래의 낙착 %s 진술이 요지에서 유도되지 않으므로 이 '
             '페이즈가 기각 레지스터에 항을 하나라도 실었는지로 갈랐고, 선언마다의 대응은 기각 '
             '문단과 기각 항을 맞대는 검사가 받는다. 이 페이즈가 실은 기각 항이 %s.'
             % (morph.cop_conj(morph.native(nreg), '이고'),
                morph.cop_end(morph.native(nrec)), morph.w(morph.native(nman), '은'),
                morph.cop_end(morph.digits(g['rej_this']))))
    if not pend:
        body = [flag(p('<strong>이 판에서 원장으로 갈 항이 영이다.</strong>'), head),
                p('<strong>이 부류가 비어 있다.</strong> 비어 있는 것과 아직 재지 않은 것이 '
                  '갈리므로 그 사실을 이 자리가 적는다.')]
        return section('미전사분', *body)
    byid = {'낙착-%d-(%d)' % k: v for k, v in g['gg'].items()}
    tr = [(code(i), code(byid[i].get('kind') or ''), esc(' · '.join(byid[i].get('homes') or [])),
           gist(gist_of(byid[i]))) for i in pend]
    if g['phase_closed']:
        lead = ('<strong>이 판에서 원장으로 갈 항이 %s.</strong> 이 페이즈를 닫는 커밋 뒤에 선 '
                '낙착이어서 그 페이즈의 커밋이 싣지 못했다.' % morph.cop_end(morph.native(len(pend))))
        tail = p('이 항의 수취인은 그 뒤에 원장에 항목을 싣는 첫 회차다. 페이즈의 이름으로 적지 않는 '
                 '까닭은 이름으로 적으면 페이즈가 하나 더 서거나 아크가 바뀌는 순간 낡는다는 데 '
                 '있다.', 'note')
    else:
        lead = ('<strong>이 판에서 원장에 아직 서지 않은 레지스터 갈래의 낙착이 %s.</strong> 이 '
                '페이즈가 아직 닫히지 않았으므로 그 항은 이 페이즈의 커밋이 실을 몫이고 미전사분이 '
                '아니다.' % morph.cop_end(morph.native(len(pend))))
        tail = None
    nums = sorted(int(i.split('-')[1]) for i in pend)
    body = [flag(p(lead), head,
                 p('<strong>이 표의 번호는 회의록의 낙착 번호이고 자리 번호가 아니다.</strong> 그 '
                   '번호의 기준점은 %s 의 회의록이고 경계는 그 목록에 든 가장 작은 번호 %s 이며, '
                   '둘을 이 목록의 원천에서 유도했다.' % (code(g['a'].phase), code('낙착-%d' % nums[0])))),
            table([('낙착', ''), ('갈래', 'nw'), ('거처', 'wrap'), ('요지', 'wrap')], tr)]
    if tail:
        body.append(tail)
    return section('미전사분', *body)


def sec_checks(g, axes):
    """이 산출이 받은 확인. 목록을 단언의 축에서 유도하고 손으로 적지 않는다."""
    lis = '\n'.join('<li>%s</li>' % esc(x) for x in axes)
    return section('이 산출이 받은 확인',
      p('<strong>이 산출을 내는 생성기가 축 %s 자기 산출을 재고 그 전량에서 적발이 영일 때에만 '
        '파일을 쓴다.</strong> 그 목록을 산문이 손으로 적지 않고 그 단언의 축에서 유도하므로, 축이 '
        '하나 늘면 이 목록이 함께 늘고 축이 서지 않으면 이 절이 그것을 들지 않는다.'
        % morph.num(len(axes), '으로')),
      '  <ul>%s</ul>' % lis,
      p('띄워 보아야 서는 축은 머리 없는 브라우저로 이 문서를 띄워 계산된 양식과 표와 행을 재고 '
        '렌더링된 본문에서 빈 보간을 찾은 것이고, 나머지는 문면을 읽어 잰 것이다. <strong>축마다 '
        '음성 대조를 세워 주입이 전량 한 번씩 터지는 것을 함께 쟀다.</strong> 앞 판이 든 절을 이 '
        '판이 빠뜨리지 않는지도 앞 판의 절 제목과 맞대어 쟀다.', 'note'))


def header(g):
    hd = g['head']
    ph = g['a'].phase
    state = ('<code>%s</code> %s 닫힌 판' if g['phase_closed']
             else '<code>%s</code> %s 진행 중인 판') % (ph, morph.jo(ph, '이'))
    return ('<header>\n  <h1>청사진 · <code>%s</code></h1>\n'
            '  <p class="asof">%s · 밑판 <code>%s</code> · 이 아크의 닫힌 페이즈 %d · %s</p>\n%s\n</header>'
            % (g['a'].arc, state, hd['head'], len(g['closed']), hd['date'],
               p('밑판은 이 리포의 받은 트리의 머리이고, 그 머리가 원격 추적 머리와 같고 작업 트리가 '
                 '깨끗함을 이 산출을 내는 자리가 단언했다. <strong>이 절과 「이 판의 실측 · 원장과 '
                 '아크」 절의 표가 그 밑판에서 유도된다.</strong> 국면은 이 페이즈의 종료 문서가 그 '
                 '트리에 서는지에서 유도했다.', 'note')))


SECTIONS = [sec_status, sec_asks, sec_phases, sec_holes, sec_measure, sec_artifact,
            sec_outside, sec_inherited, sec_untrans]


def build(g, axes):
    secs = [f(g) for f in SECTIONS] + [sec_checks(g, axes)]
    html = ('<!doctype html>\n<html lang="ko">\n<head>\n%s<style>\n%s\n</style>\n'
            '</head>\n\n<body>\n<div class="sheet">\n\n%s\n%s\n\n</div>\n</body>\n</html>\n'
            % (g['prev']['head'], g['prev']['style'], header(g), '\n'.join(secs)))
    # 앞 판이 든 절을 빠뜨리지 않는다. 걷은 절은 그 사상에 든 것만 받는다
    new = {title_key(t) for t in re.findall(r'<section>\n  <h2>(.*?)</h2>', html)}
    old = {title_key(t) for t in g['prev']['sections']}
    lost = old - new - {title_key(t) for t in DROPPED}
    assert not lost, '앞 판의 절을 빠뜨렸다: %r' % sorted(lost)
    return html


def main(argv=None):
    ap = argparse.ArgumentParser(description='청사진을 낸다')
    ap.add_argument('--minutes', required=True)
    ap.add_argument('--arc', required=True)
    ap.add_argument('--phase', required=True)
    ap.add_argument('--goals', required=True)
    ap.add_argument('--prev', required=True)
    ap.add_argument('--prior', default=None, help='앞 판의 미전사분 처분 사상 JSON')
    ap.add_argument('--out', required=True)
    ap.add_argument('--dry', action='store_true')
    a = ap.parse_args(argv)
    a.goals_doc = json.loads(io.open(a.goals, encoding='utf-8').read())
    assert set(a.goals_doc) == {'goals', 'exit'}, '목표 표의 꼴이 다르다'
    a.prior_doc = json.loads(io.open(a.prior, encoding='utf-8').read()) if a.prior else None
    prev = prev_parts(io.open(a.prev, encoding='utf-8').read())

    g = gather(a, prev)
    html = build(g, A.names())
    d = tempfile.mkdtemp()
    tmp = os.path.join(d, 'bp.html')
    io.open(tmp, 'w', encoding='utf-8').write(html)
    kinds = None
    det = A.run(html, kinds, path=tmp)
    bad = [(nm, r[:2]) for nm, r in det if r]
    assert not bad, '청사진의 적발이 영이 아니다: %r' % bad

    def path_of(nm, inj):
        q = os.path.join(d, 'inj.html')
        io.open(q, 'w', encoding='utf-8').write(inj)
        return q
    neg = A.negative(html, kinds, path_of)

    # 재생성이 같은 바이트를 내는지. 판정은 기억이 아니라 재생성이 한다
    again = build(gather(a, prev), A.names())
    assert again == html, '재생성이 다른 바이트를 냈다: %d · %d' % (
        len(again.encode()), len(html.encode()))
    h = hashlib.sha256(html.encode()).hexdigest()[:12]
    if not a.dry:
        assert not os.path.exists(a.out), '이미 선 파일을 덮어쓰지 않는다. 먼저 치워라: %s' % a.out
        io.open(a.out, 'w', encoding='utf-8').write(html)
    print('청사진 · %d B · %s · 축 %d · 적발 %d'
          % (len(html.encode()), h, len(A.names()), sum(len(r) for _, r in det)))
    print('음성 대조:', [(n, c) for n, c in neg])
    print('경로:', None if a.dry else a.out)
    return 0


if __name__ == '__main__':
    sys.exit(main())
