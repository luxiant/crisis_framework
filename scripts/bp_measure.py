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


def hole_rows(repo, arc):
    """그 아크의 구멍 배열을 이연과 폐기에서 유도한 뷰로 낸다."""
    st = arc_stats(repo, arc)
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
