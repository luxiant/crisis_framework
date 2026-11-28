"""청사진이 드는 값을 원격 `main` 의 머리를 담은 받은 트리에서 전량 유도한다.

손으로 적는 자리를 두지 않는다. 값마다 그것을 내는 명령과 유니버스를 함께 내어
산출의 표가 그 둘을 같은 자리에 둘 수 있게 한다.
"""
import json, re, subprocess
from pathlib import Path

REG = ('decisions', 'deferred', 'rejected', 'retirements')


def _git(repo, *args):
    return subprocess.run(['git', '-C', str(repo)] + list(args),
                          capture_output=True, text=True, check=True).stdout.strip()


def head(repo):
    """받은 트리의 머리와 원격의 머리와 작업 트리의 상태."""
    h = _git(repo, 'rev-parse', '--short', 'HEAD')
    try:
        o = _git(repo, 'rev-parse', '--short', 'origin/main')
    except subprocess.CalledProcessError:
        o = None
    dirty = len([l for l in _git(repo, 'status', '--porcelain').split('\n') if l])
    assert h == o, '받은 머리가 원격의 머리와 갈린다: %r · %r' % (h, o)
    assert dirty == 0, '작업 트리가 깨끗하지 않다: %d 줄' % dirty
    date = _git(repo, 'show', '-s', '--format=%cd', '--date=format-local:%Y-%m-%d', 'HEAD')
    return {'head': h, 'remote': o, 'dirty': dirty, 'date': date}


def registers(repo):
    """네 레지스터의 배열 길이."""
    out = {}
    for r in REG:
        d = json.loads((Path(repo) / 'docs/decisions' / (r + '.json')).read_text())
        assert isinstance(d, dict) and r in d, '%s 의 꼴이 다르다' % r
        out[r] = len(d[r])
    out['total'] = sum(out[r] for r in REG)
    return out


def entries(repo, reg):
    d = json.loads((Path(repo) / 'docs/decisions' / (reg + '.json')).read_text())
    return d[reg]


def live_deferred(repo):
    """폐기 레코드가 가리키지 않는 이연."""
    tgt = {e.get('target') for e in entries(repo, 'retirements')}
    rows = [e for e in entries(repo, 'deferred') if e['id'] not in tgt]
    return rows


def arcs(repo):
    return json.loads((Path(repo) / 'docs/arcs.json').read_text())


def arc_stats(repo, arc):
    a = arcs(repo)
    recs = a['arcs']
    me = [r for r in recs if r.get('name') == arc]
    assert len(me) == 1, '아크 %r 의 레코드가 하나가 아니다: %d' % (arc, len(me))
    me = me[0]
    by = {}
    for r in recs:
        by[r.get('status', '?')] = by.get(r.get('status', '?'), 0) + 1
    return {'arcs': len(recs), 'by_status': by, 'rec': me,
            'phases': me.get('phases') or [], 'holes': me.get('holes') or [],
            'cq': me.get('cq') or [], 'patches': len(a.get('patches') or [])}


def closed_phases(repo, arc):
    """그 아크의 종료 문서가 그 트리에 서는 페이즈."""
    d = Path(repo) / 'docs/phases'
    out = []
    for p in sorted(d.glob('%s-*-closure.md' % arc)):
        m = re.match(r'^%s-(\d+)-closure\.md$' % re.escape(arc), p.name)
        if m:
            out.append('%s-%s' % (arc, m.group(1)))
    return out


def lean_files(repo):
    """형식층의 추적 파일을 층별로 센다."""
    root = Path(repo) / 'CrisisFramework'
    tracked = set(_git(repo, 'ls-files', 'CrisisFramework').split('\n'))
    out = {}
    for rel in sorted(tracked):
        if not rel.endswith('.lean'):
            continue
        parts = rel.split('/')
        if len(parts) < 2:
            continue
        out[parts[1]] = out.get(parts[1], 0) + 1
    assert out, '형식층 파일이 영이다'
    return out


def _first_named_commit(repo, arc):
    """그 아크의 이름이 아크 값 정본에 처음 선 커밋. 찾지 못하면 그 자리에서 터뜨린다."""
    shas = _git(repo, 'log', '--reverse', '--format=%H', '-S', '"name": "%s"' % arc,
                '--', 'docs/arcs.json').split('\n')
    assert shas and shas[0], '아크 %r 가 처음 선 커밋을 찾지 못했다' % arc
    return shas[0]


def _arc_record_at(repo, sha, arc):
    """그 커밋의 아크 값 정본에서 그 아크의 레코드. 없으면 `None` 이고 둘 이상이면 터뜨린다."""
    a = json.loads(_git(repo, 'show', '%s:docs/arcs.json' % sha))
    rec = [x for x in a.get('arcs', []) if x.get('name') == arc]
    assert len(rec) <= 1, '아크 %r 가 커밋 %s 의 아크 값 정본에 둘 이상 선다' % (arc, sha[:7])
    return rec[0] if rec else None


def opening_commit(repo, arc):
    """그 아크의 상태가 예약이 아닌 첫 커밋.

    그 아크의 이름이 아크 값 정본에 처음 선 커밋부터 아크 값 정본을 고친 커밋을 차례로 읽는다. 예약 없이
    선 아크에서는 그 커밋이 이름이 처음 선 커밋과 같고, 예약 뒤에 연 아크에서는 예약 커밋을 지나 개막
    커밋에 닿는다. 그 커밋을 찾지 못하면 그 자리에서 터뜨린다.
    """
    first = _first_named_commit(repo, arc)
    shas = _git(repo, 'log', '--reverse', '--format=%H', '--', 'docs/arcs.json').split('\n')
    assert first in shas, '아크 %r 가 처음 선 커밋이 아크 값 정본의 이력에 없다' % arc
    for sha in shas[shas.index(first):]:
        rec = _arc_record_at(repo, sha, arc)
        if rec is not None and rec.get('status') != 'reserved':
            return sha
    raise AssertionError('아크 %r 의 상태가 예약이 아닌 커밋을 찾지 못했다' % arc)


def opening_holes(repo, arc):
    """그 아크의 상태가 예약이 아닌 첫 커밋의 아크 값 정본이 든 그 아크의 구멍 배열.

    패치 레코드가 구멍의 식별자를 필드로 들지 않으므로, 개막이 넣은 구멍을 개막 커밋에서 읽고 그 뒤에
    아크의 구멍 배열에 든 것을 패치로 든 것으로 센다. 예약 커밋의 구멍 배열을 읽으면 예약 뒤에 연
    아크에서 개막이 재개 트리거로 기계로 뽑아 넣은 구멍이 전부 패치로 든 것으로 세어진다.
    """
    rec = _arc_record_at(repo, opening_commit(repo, arc), arc)
    return set(rec.get('holes') or [])


def opening_holes_by_first_name(repo, arc):
    """그 아크의 이름이 처음 선 커밋의 구멍 배열. 고치기 전의 유도이며 음성 대조가 맞대는 상대다."""
    rec = _arc_record_at(repo, _first_named_commit(repo, arc), arc)
    assert rec is not None, '아크 %r 가 처음 선 커밋의 아크 값 정본에 서지 않는다' % arc
    return set(rec.get('holes') or [])


def hole_rows(repo, arc):
    """그 아크의 구멍 배열을 이연과 폐기에서 유도한 뷰로 낸다."""
    st = arc_stats(repo, arc)
    opening = opening_holes(repo, arc)
    defd = {e['id']: e for e in entries(repo, 'deferred')}
    tgt = {}
    for e in entries(repo, 'retirements'):
        tgt.setdefault(e.get('target'), []).append(e)
    phase_of = {}
    for p in st['phases']:
        for h in (p.get('holes') or []):
            phase_of.setdefault(h, []).append(p.get('name'))
    rows = []
    for hid in st['holes']:
        e = defd.get(hid)
        assert e, '구멍 %r 이 이연 레지스터에 없다' % hid
        rows.append({
            'id': hid,
            'layer': (e.get('origin') or {}).get('layer') or e.get('layer') or '—',
            'trigger': ((e.get('reopen_when') or {}).get('kind')
                        if e.get('reopen_when') else None),
            # 조달의 경로를 가르는 재료. 그 이연이 이 아크에서 섰으면 이 아크가 발행한 것이고, 개막이
            # 넣지 않았으면 패치로 든 것이며, 개막이 넣은 것 가운데 트리거가 이 아크를 지목하면 기계로
            # 뽑힌 것이고 나머지가 판별선으로 가려 넣은 것이다
            'ref': (e.get('reopen_when') or {}).get('ref') if e.get('reopen_when') else None,
            'origin_arc': (e.get('origin') or {}).get('arc'),
            'opening': hid in opening,
            'what': e.get('statement') or '',
            'phases': phase_of.get(hid) or [],
            'retired': bool(tgt.get(hid)),
        })
    return rows


def extractions(repo):
    """추출 기록의 파일과 그 머리가 드는 편 제목."""
    d = Path(repo) / 'docs/extractions'
    out = {}
    for p in sorted(d.glob('extraction-*.md')):
        t = p.read_text(encoding='utf-8')
        # 머리 뒤의 첫 굵은 구간이 편 제목이다. 꼴이 둘이고 (발행 주체에 굵은
        # 기울임이 붙는 것과 저자와 연도에 붙는 것) 둘 다 이 구간에 선다
        m = re.search(r'(?ms)^#\s+.+?\n+\*\*(.+?)\*\*', t)
        assert m, '%s 의 머리 뒤에 굵은 구간이 없다' % p.name
        out[p.name] = re.sub(r'\s+', ' ', m.group(1)).strip()
    return out


def artifact_rows(repo):
    """추출 갈래의 살아 있는 이연마다 자료가 조달되었는지와 처분이 섰는지를 가른다.

    유니버스는 그 갈래를 가진 살아 있는 이연 전량이고 한 아크로 좁히지 않는다.
    조달과 처분이 다른 사실이므로 칸을 둘로 가른다.
    """
    tgt = {e.get('target') for e in entries(repo, 'retirements')}
    rows = []
    for e in entries(repo, 'deferred'):
        rw = e.get('reopen_when') or {}
        if rw.get('kind') != 'extraction':
            continue
        if e['id'] in tgt:
            continue
        rows.append({'id': e['id'], 'ref': rw.get('ref') or '',
                     'what': rw.get('what') or '', 'retired': False})
    return rows


def norm(s):
    """공백과 대소문자와 구두점을 지운 변."""
    return re.sub(r'[\s·,.\'"“”‘’`()\[\]—–\-/:;]', '', s).lower()


def compare_opening(repo):
    """아크 전량에서 개막 구멍의 두 유도를 맞댄다. 갈리는 아크와 그 상태를 낸다.

    유니버스는 받은 트리의 아크 값 정본이 드는 아크 가운데 예약이 아닌 것이다. 예약 상태의 아크는
    개막 커밋이 없으므로 고친 유도가 터뜨리고, 그것은 유도의 결함이 아니라 아직 열리지 않았다는 뜻이다.
    """
    out = []
    for rec in arcs(repo)['arcs']:
        name = rec.get('name')
        if rec.get('status') == 'reserved':
            continue
        old = opening_holes_by_first_name(repo, name)
        new = opening_holes(repo, name)
        out.append({'arc': name, 'status': rec.get('status'), 'old': sorted(old),
                    'new': sorted(new), 'differs': old != new})
    return out


def selftest():
    """합성 리포로 개막 구멍의 유도를 잰다. 단언이 서지 않으면 그 자리에서 터진다.

    정방향의 대조는 예약 뒤에 연 아크에서 고치기 전의 유도가 예약 커밋의 빈 배열을 내고 고친 유도가
    개막 커밋의 배열을 내는 것이다. 역방향의 대조는 예약 없이 선 아크에서 두 유도가 같은 값을 내는
    것이다. 그 위에 개막 뒤의 패치로 든 구멍이 개막 구멍으로 세어지지 않는 것과, 예약만 된 아크에서
    고친 유도가 터지는 것을 잰다.
    """
    import tempfile
    with tempfile.TemporaryDirectory() as d:
        root = Path(d)
        (root / 'docs').mkdir()

        def commit(recs, msg):
            (root / 'docs' / 'arcs.json').write_text(
                json.dumps({'arcs': recs, 'patches': []}, ensure_ascii=False, indent=1) + '\n')
            _git(root, 'add', 'docs/arcs.json')
            _git(root, '-c', 'user.name=selftest', '-c', 'user.email=selftest@example.invalid',
                 'commit', '-q', '-m', msg)

        _git(root, 'init', '-q')
        commit([{'name': 'alpha', 'status': 'reserved', 'holes': []}], 'reserve alpha')
        commit([{'name': 'alpha', 'status': 'open', 'holes': ['CF-1']},
                {'name': 'beta', 'status': 'open', 'holes': ['CF-2']},
                {'name': 'gamma', 'status': 'reserved', 'holes': []}], 'open alpha, beta')
        commit([{'name': 'alpha', 'status': 'open', 'holes': ['CF-1', 'CF-3']},
                {'name': 'beta', 'status': 'closed', 'holes': ['CF-2', 'CF-4']},
                {'name': 'gamma', 'status': 'reserved', 'holes': []}], 'patch alpha, beta')
        assert opening_holes_by_first_name(root, 'alpha') == set(), '정방향 대조의 출발점이 서지 않는다'
        assert opening_holes(root, 'alpha') == {'CF-1'}, '예약 뒤에 연 아크의 개막 구멍이 다르다'
        assert opening_holes_by_first_name(root, 'beta') == opening_holes(root, 'beta') == {'CF-2'}, \
            '예약 없이 선 아크에서 두 유도가 갈린다'
        try:
            opening_holes(root, 'gamma')
        except AssertionError:
            pass
        else:
            raise AssertionError('예약만 된 아크에서 고친 유도가 터지지 않았다')
    return ['정방향: 예약 뒤에 연 아크에서 빈 배열이 개막 배열로 바뀐다',
            '역방향: 예약 없이 선 아크에서 두 유도가 같다',
            '개막 뒤의 패치가 개막 구멍으로 세어지지 않는다',
            '예약만 된 아크에서 고친 유도가 터진다']


if __name__ == '__main__':
    import sys
    if sys.argv[1:] == ['selftest']:
        for line in selftest():
            print('OK', line)
    elif sys.argv[1:2] == ['compare'] and len(sys.argv) == 3:
        for row in compare_opening(sys.argv[2]):
            print('%s\t%s\t%s\t%s\t%s' % (row['arc'], row['status'], 'differs' if row['differs'] else 'same',
                                          ','.join(row['old']) or '-', ','.join(row['new']) or '-'))
    else:
        sys.exit('쓰는 꼴: python3 scripts/bp_measure.py selftest | compare <리포>')
