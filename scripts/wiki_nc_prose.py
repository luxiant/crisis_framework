"""산문층 갈래 검사의 음성 대조 주입.

`scripts/wiki_prose.py` 가 든 검사의 주입 함수와 그 사례 목록을 든다. 주입이 어느 단위에
사는지는 그 주입이 겨눈 검사가 사는 단위에서 유도한다.
"""

from __future__ import annotations

import re
from pathlib import Path
import wiki_common
import wiki_prose
from wiki_nc_common import deferred_stub, edit, load, pick, save


def inj_12(root):
    tgt = pick(root, "deferred",
               lambda e: isinstance(e.get("reopen_when"), dict)
               and e["reopen_when"].get("kind") == "arc_phase")
    edit(root, "deferred", tgt["id"],
         lambda e: e["reopen_when"].__setitem__("ref", "아크가 아닌 문자열"))


def inj_43(root):
    """실재하지 않는 번호를 `extraction` 트리거의 `ref` 로 둔 항을 등재한다.

    그 항이 「발화할 수 없는 항」으로 세어져야 한다. 번호의 꼴을 만족하므로 검사 12 는 그것을
    형식으로 받으며, 그 번호의 기록이 실재하는지를 보는 자리가 검사 43 하나임이 이 주입으로
    선다. 추출 기록의 번호가 두 자리이고 현행 열이 49 까지이므로 97 을 고른다."""
    eid = "CF-9043"
    doc = load(root, "deferred")
    doc["deferred"].append(deferred_stub(
        eid, {"kind": "extraction", "ref": "E-97"}))
    save(root, "deferred", doc)
    return eid


def inj_32(root):
    """어느 아크의 `phases` 에도 없는 페이즈 이름으로 종료 문서를 하나 둔다.

    좁힌 검사 32 는 블록을 읽지 않으므로 앞 판의 주입(블록의 값을 패치 계수와 다르게 적는
    것)은 더 이상 조건을 만들지 못한다. 선언된 아크의 이름을 쓰면 검사 35 의 형에는 맞으므로
    이 주입이 검사 32 만 겨눈다."""
    phase = "collateral-9999"
    f = root / "docs" / "phases" / f"{phase}-closure.md"
    f.parent.mkdir(parents=True, exist_ok=True)
    f.write_text("음성 대조가 주입한 종료 문서다.\n", encoding="utf-8")
    return phase


def _plant(root: Path, rel: str) -> str:
    """`docs/` 아래에 파일을 하나 심고 그 경로를 낸다. 검사 35 의 주입이 전부 이것을 쓴다."""
    p = root / "docs" / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text("음성 대조가 주입한 문서다.\n", encoding="utf-8")
    return f"docs/{rel}"


def inj_35_plan(root):
    """청사진을 `docs/` 에 둔다."""
    return _plant(root, "IMPLEMENTATION_PLAN_collateral_9.md")


def inj_35_patch(root):
    """패치 조각을 `docs/` 에 둔다."""
    return _plant(root, "patches-collateral-9.json")


def inj_35_annex(root):
    """별지를 `docs/` 에 둔다."""
    return _plant(root, "별지-collateral-9-명세.md")


def inj_35_phases_other(root):
    """종료 문서가 아닌 것을 `phases/` 에 둔다."""
    return _plant(root, "phases/collateral-9-notes.md")


def inj_35_phases_arc(root):
    """선언되지 않은 아크 이름으로 종료 문서를 둔다.

    `<ARC>` 가 `arcs.json` 의 아크 이름 전량의 택일로 바뀌므로, 선언된 아크의 이름을 쓰면
    번호가 무엇이든 통과한다. 그 값을 레지스터가 닫는다는 것이 이 주입이 재는 것이다."""
    return _plant(root, "phases/nosucharc-1-closure.md")


def inj_35_extraction(root):
    """추출 기록의 접두사를 어긴다."""
    return _plant(root, "extractions/extract-48-foo.md")


def inj_35_case(root):
    """파일 이름에 대문자와 밑줄을 쓴다."""
    return _plant(root, "extractions/extraction-48-Foo_Bar.md")


def inj_35_dir(root):
    """허용되지 않은 디렉터리를 만든다."""
    return _plant(root, "notes/collateral-9.md")


def inj_35_ledger(root):
    """원장 디렉터리에 새 파일을 둔다."""
    return _plant(root, "decisions/holes.json")


def inj_36_open(root):
    """사본의 무시 파일에서 `/*` 한 줄을 지운다. 닫힌 형이 깨진다."""
    f = root / wiki_prose.IGNORE_FILE
    lines = f.read_text(encoding="utf-8").splitlines(keepends=True)
    for i, ln in enumerate(lines):
        if ln.strip() == wiki_prose.IGNORE_ALL:
            del lines[i]
            break
    else:
        raise SystemExit(f"무시 파일에 `{wiki_prose.IGNORE_ALL}` 줄이 없다")
    f.write_text("".join(lines), encoding="utf-8")


def inj_36_ghost(root):
    """사본의 무시 파일에 루트에 없는 이름으로 되살림 줄을 더한다. 목록이 유령을 든다.

    산문의 계수를 어기는 주입을 따로 두지 않는다. 이 주입이 목록을 늘리면 계수도 함께
    어긋나므로 한 주입이 두 축을 함께 잡고, 같은 것을 두 번 세면 검사의 계수가 부풀고 음성
    대조가 그 자리에서 공허해진다."""
    f = root / wiki_prose.IGNORE_FILE
    lines = f.read_text(encoding="utf-8").splitlines()
    ghost = "!/NO_SUCH_ROOT_ENTRY.md"
    at = [i for i, ln in enumerate(lines) if wiki_prose.IGNORE_REVIVE.match(ln.strip())]
    if not at:
        raise SystemExit("무시 파일에 되살림 줄이 없다")
    lines.insert(at[-1] + 1, ghost)
    f.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return ghost


def inj_37_count(root):
    """사본의 원장 계수 표에서 한 행의 수를 하나 틀리게 적는다."""
    f = root / wiki_prose.LEDGER_COUNT_DOC
    lines = f.read_text(encoding="utf-8").splitlines()
    head = [i for i, ln in enumerate(lines)
            if ln.strip() == wiki_prose.LEDGER_COUNT_HEAD]
    if len(head) != 1:
        raise SystemExit("원장 계수 표의 머리를 찾지 못했다")
    for i in range(head[0] + 2, len(lines)):
        m = wiki_prose.LEDGER_COUNT_ROW.match(lines[i].strip())
        if not m:
            break
        lines[i] = f"| {m.group(1)} | {int(m.group(2)) + 1} |"
        f.write_text("\n".join(lines) + "\n", encoding="utf-8")
        return f"{m.group(1)} {m.group(2)}→{int(m.group(2)) + 1}"
    raise SystemExit("원장 계수 표의 행을 찾지 못했다")


def inj_41_pointer(root):
    """면제 목록에 없는 항목의 산문에 살아 있는 조항의 주석을 지목하는 꼴을 적는다.

    면제 목록을 값 정본에서 읽어 주입과 판정이 같은 목록을 쓰게 한다. 전사하면 한쪽을 고칠 때
    다른 쪽이 조용히 낡는다. 폐기되지 않은 조항을 고르는 까닭은 폐기된 것을 고르면 규율 ID
    토큰을 보는 검사 23 이 먼저 잡아 이 주입이 그 뒤에 가려지는 것이다.
    """
    led = wiki_common.Ledger(root)
    _dist, exempt = wiki_prose.r11_rules(led)
    if not exempt:
        raise SystemExit("R11 블록의 면제 목록이 비어 주입과 판정이 같은 목록을 쓰지 못한다")
    live = sorted(tok for tok, owner in led.name_owner.items()
                  if owner not in led.dead)
    if not live:
        raise SystemExit("폐기되지 않은 규율 조항이 없어 주입이 서지 않는다")
    tok = live[0]
    doc = load(root, "decisions")
    target = next((e for e in doc["decisions"] if e.get("id") not in exempt), None)
    if target is None:
        raise SystemExit("면제 목록 밖의 항목이 없어 주입 대상이 없다")
    target["statement"] = (str(target.get("statement") or "")
                           + f" {tok} 에 붙은 주석을 지목한다.")
    save(root, "decisions", doc)
    return f"{target.get('id')}: {tok} 에 붙은 주석"


# ------------------------------------------------- 검사 35 · 추출 기록 번호의 축

def _extraction_pattern(root: Path):
    """추출 기록의 꼴과 그 디렉터리의 번호별 파일 목록. 번호 그룹이 없으면 멈춘다."""
    led = wiki_common.Ledger(root)
    s = (root / "docs" / "baseline.md").read_text(encoding="utf-8")
    m = wiki_prose.DOCFORM_BLOCK.search(s)
    if m is None:
        raise SystemExit("값 정본에 DOCFORM 블록이 없어 주입이 서지 않는다")
    for line in m.group(1).splitlines():
        g = wiki_prose.DOCFORM_LINE.match(line)
        if g is None or g.group(2) != "pattern":
            continue
        rx = re.compile(g.group(3).replace(
            "<ARC>", "(?:" + "|".join(re.escape(a) for a in sorted(led.arcs)) + ")"))
        if wiki_prose.DOCFORM_NUM_GROUP not in rx.groupindex:
            continue
        d = root / "docs" / g.group(1)
        seen: dict = {}
        for f in sorted(d.glob("*")) if d.is_dir() else []:
            hit = rx.fullmatch(f.name)
            if hit:
                seen.setdefault(hit.group(wiki_prose.DOCFORM_NUM_GROUP), []).append(f)
        return g.group(1), seen
    raise SystemExit("번호 그룹을 든 DOCFORM 패턴 줄이 없어 주입이 서지 않는다")


def inj_35_dupnum(root):
    """같은 번호를 가진 추출 기록을 둔다. 번호 중복은 실패다."""
    d, seen = _extraction_pattern(root)
    if not seen:
        raise SystemExit("그 꼴에 든 파일이 없어 주입이 서지 않는다")
        # 번호를 실물에서 읽는다. 박아 두면 그 번호의 파일이 사라질 때 주입이 조용히 빈다.
    num = sorted(seen)[0]
    return _plant(root, f"{d}/extraction-{num}-duplicate-probe.md")


def inj_35_gapnum(root):
    """중간 번호의 추출 기록을 옮겨 결번을 만든다.

    **잡히지 않아야 하는 항이다.** 결번은 어긋남이 아니라 보고이므로 새 위반 줄이 나지 않아야
    한다. 보고 줄에 결번이 들었는지는 이 하네스가 보지 않는다.
    """
    _d, seen = _extraction_pattern(root)
    nums = sorted(seen)
    if len(nums) < 3:
        raise SystemExit("번호가 셋 미만이라 중간 번호를 고를 수 없다")
    num = nums[len(nums) // 2]
    for f in seen[num]:
        f.unlink()
    return num


# 지목 범위 세 갈래의 주입이 쓰는 문면. 갈래마다 그 갈래가 적발하는 꼴을 하나 담고 다른 갈래의
# 꼴은 담지 않는다. `{tok}` 은 주입이 살아 있는 규율 조항으로 채운다.
#
# 표지와 절 번호는 실재하지 않는 값을 쓴다. 이 문면의 몫이 적발되는 것이므로 실재하는 조작이나
# 절을 쓰면 그것을 지목한 자리로 읽히는데, 주입은 무엇도 지목하지 않는다. `Z` 로 여는 것이
# 이 파일이 주입한 이름에 쓰는 접두사다.
INJ_POINTER_LINE = {
    "POINTER_COMMENT": "\n음성 대조가 주입한 문면이다. {tok} 의 주석이 그 자리를 든다.\n",
    "POINTER_EPHEMERAL": "\n음성 대조가 주입한 문면이다. 조작 표지 Z9-O9 를 지목한다.\n",
    "POINTER_SECTION": "\n음성 대조가 주입한 문면이다. 그 요구는 §99.7 이 든다.\n",
}


# 주입을 받는 영구 문면. 집행 문면이 그 검사의 유니버스에 들고 덧붙이는 자리가 말미라 다른
# 검사의 앵커를 밀지 않는다.
INJ_POINTER_DOC = "CLAUDE.md"


def _inject_pointer(root, key):
    """지목 범위의 한 갈래만 하나 늘린다.

    **늘린 갈래와 그 수를 주입 안에서 단언한다.** 그 검사가 갈래마다 따로 맞대므로 다른 갈래가
    함께 움직이면 어느 갈래의 탐지를 재는지가 갈리지 않으며, 늘지 않으면 주입이 공허해진다.
    적발을 세는 쪽은 검증기에 선 함수를 그대로 부른다. 전사하면 한쪽을 고칠 때 다른 쪽이
    조용히 낡는다.
    """
    led = wiki_common.Ledger(root)
    dist, _exempt = wiki_prose.r11_rules(led)
    if dist is None:
        raise SystemExit("R11 블록에 거리가 없어 주입과 판정이 같은 값을 쓰지 못한다")
    before = {k: len(v) for k, v in
              wiki_prose.pointer_hits(led.pointer_scan_targets(), dist).items()}
    # 폐기된 조항을 고르면 규율 ID 토큰을 보는 검사 24 가 먼저 잡아 이 주입이 그 뒤에 가려진다.
    live = sorted(tok for tok, owner in led.name_owner.items() if owner not in led.dead)
    if not live:
        raise SystemExit("폐기되지 않은 규율 조항이 없어 주입이 서지 않는다")
    f = root / INJ_POINTER_DOC
    f.write_text(f.read_text(encoding="utf-8")
                 + INJ_POINTER_LINE[key].format(tok=live[0]), encoding="utf-8")
    after = {k: len(v) for k, v in
             wiki_prose.pointer_hits(
                 wiki_common.Ledger(root).pointer_scan_targets(), dist).items()}
    for k in before:
        want = before[k] + 1 if k == key else before[k]
        if after[k] != want:
            raise SystemExit(f"주입이 {k} 를 {before[k]} 에서 {after[k]} 로 바꿨다. "
                             f"{want} 여야 한다")
    return key


def inj_41_comment(root):
    """규율 ID 뒤 그 거리 안에 그 낱말이 따르는 자리를 하나 더한다."""
    return _inject_pointer(root, "POINTER_COMMENT")


def inj_41_ephemeral(root):
    """소진 문서의 식별자 꼴을 하나 더한다."""
    return _inject_pointer(root, "POINTER_EPHEMERAL")


def inj_41_section(root):
    """앞에 출처 표지도 문서 이름도 오지 않는 절 번호를 하나 더한다."""
    return _inject_pointer(root, "POINTER_SECTION")


def inj_49_unpointed(root):
    """어느 docstring 도 지목하지 않는 추출 기록을 하나 더한다.

    번호를 기존 최대의 다음으로 고른다. 중간 번호를 쓰면 결번이나 번호 중복이 서서 문서
    양식을 보는 검사가 함께 걸리는데, 그것은 이 주입이 겨눈 자리가 아니다.
    """
    d = root / "docs" / "extractions"
    nums = [int(m.group(1)) for f in d.glob("extraction-*.md")
            for m in [wiki_common.EXTRACTION_FILE_NO.match(f.name)] if m]
    if not nums:
        raise SystemExit("사본에 추출 기록이 없어 번호를 고를 자리가 없다")
    n = max(nums) + 1
    name = f"extraction-{n:02d}-negative-control-probe.md"
    (d / name).write_text(
        f"# 추출 기록 E-{n:02d}\n\n## 0. 이 기록의 지위\n\n"
        "음성 대조가 사본에만 세우는 기록이며 리포의 어느 판에도 들어가지 않는다.\n",
        encoding="utf-8")
    return name


# ----------------------------------------------------- 검사 50 · 뭉치 인벤토리의 거울

def _nc50_inventory(root):
    """사본의 뭉치 인벤토리 경로와 그 문면과 구성원 행의 번호. 구성원 행을 고르는 쪽은 검증기의
    함수를 그대로 부른다. 전사하면 그 검사가 꼴을 고칠 때 이 주입이 조용히 공허해진다."""
    f = root / wiki_common.INVENTORY_DOC
    text = f.read_text(encoding="utf-8")
    left, _rows, _lists = wiki_prose.inventory_members(text)
    if not left:
        raise SystemExit("사본의 인벤토리에서 구성원 행의 기록 번호를 하나도 읽지 못했다")
    return f, text, left


def inj_50_missing(root):
    """인벤토리의 구성원 행 하나에 실재하지 않는 기록 번호를 적는다.

    번호를 기존 기록 최대의 다음으로 고른다. 그 번호의 기록 파일이 없으므로 미포착이 서야
    하며, 그 행이 원래 든 번호를 지우지 않으므로 유령의 계수는 움직이지 않는다.
    """
    f, text, left = _nc50_inventory(root)
    d = root / "docs" / "extractions"
    nums = [int(m.group(1)) for g in d.glob("extraction-*.md")
            for m in [wiki_common.EXTRACTION_FILE_NO.match(g.name)] if m]
    if not nums:
        raise SystemExit("사본에 추출 기록이 없어 번호를 고를 자리가 없다")
    n = max(nums) + 1
    if n > 99:
        raise SystemExit("기록 번호가 두 자리를 넘어 검사의 꼴이 그 번호를 읽지 못한다")
    lines = text.split("\n")
    at = left[min(left)][0] - 1
    m = wiki_common.INVENTORY_EXTRACTION_NO.search(lines[at])
    if m is None:
        raise SystemExit("고른 구성원 행에서 기록 번호를 다시 찾지 못했다")
    lines[at] = lines[at][:m.end()] + f" · E-{n:02d}" + lines[at][m.end():]
    f.write_text("\n".join(lines), encoding="utf-8")
    return f"{wiki_common.INVENTORY_DOC}:{at + 1} 에 E-{n:02d}"


def inj_50_ghost(root):
    """추출 기록 하나의 번호를 드는 구성원 행을 인벤토리에서 지운다.

    **그 번호를 한 줄에서만 들고 그 줄이 다른 번호를 들지 않는 기록을 고른다.** 다른 줄에도
    서면 한 줄을 지워도 유령이 서지 않고, 그 줄이 다른 번호를 들면 유령이 둘 이상 늘어 이 주입이
    겨눈 자리가 흐려진다. 유령이 하나 늘었는지를 주입 안에서 단언한다.
    """
    f, text, left = _nc50_inventory(root)
    before = len(set(left))
    lines = text.split("\n")
    for n in sorted(left):
        where = sorted(set(left[n]))
        if len(where) != 1:
            continue
        at = where[0] - 1
        others = {int(x.group(1))
                  for x in wiki_common.INVENTORY_EXTRACTION_NO.finditer(lines[at])}
        if others != {n}:
            continue
        del lines[at]
        f.write_text("\n".join(lines), encoding="utf-8")
        after, _rows, _lists = wiki_prose.inventory_members(f.read_text(encoding="utf-8"))
        if len(set(after)) != before - 1 or n in after:
            raise SystemExit(f"구성원 행을 지웠는데 좌변이 {before} 에서 {len(set(after))} 로 "
                             f"바뀌었다. 하나만 줄어야 한다")
        return f"E-{n:02d}"
    raise SystemExit("한 줄에서만 서고 그 줄이 다른 번호를 들지 않는 기록이 없어 주입이 서지 않는다")


def _nc50_unread_row(root):
    """사본의 인벤토리와 미추출 표지를 든 구성원 행 하나와 편 제목 하나. 행과 제목을 고르는 쪽은
    검증기의 함수를 그대로 부른다. 전사하면 그 축이 꼴을 고칠 때 이 주입이 조용히 공허해진다."""
    f, lines, rows, unread = _nc53_rows(root)
    d = root / "docs" / "extractions"
    title = None
    for g in sorted(d.glob("extraction-*.md")):
        if wiki_common.EXTRACTION_FILE_NO.match(g.name):
            got = wiki_prose.extraction_titles(g.read_text(encoding="utf-8"))
            if got:
                title = got[0]
                break
    if title is None:
        raise SystemExit("사본의 추출 기록에서 편 제목을 하나도 읽지 못해 주입할 자리가 없다")
    for line, cells, _sec in rows:
        if unread in cells[-1] and len(cells) > 1:
            return f, lines, line, cells, title
    raise SystemExit("미추출 표지를 든 구성원 행이 없어 주입할 자리가 없다")


def _nc50_insert(f, lines, line, cells, cell):
    """고른 행 바로 뒤에 그 행의 칸을 옮긴 행을 더하되 비고 칸 앞의 마지막 칸을 바꾼다."""
    row = list(cells)
    row[-2] = cell
    lines.insert(line, "| " + " | ".join(row) + " |")
    f.write_text("\n".join(lines), encoding="utf-8")
    return f"{wiki_common.INVENTORY_DOC}:{line + 1}"


def inj_50_unread(root):
    """미추출 표지를 든 구성원 행 하나를 더하고 그 칸 하나가 추출 기록의 편 제목을 들게 한다.

    추출된 편을 미추출로 적은 낡은 표지가 서야 하며, 번호를 들지 않으므로 번호 대조의 두 방향은
    움직이지 않는다.
    """
    f, lines, line, cells, title = _nc50_unread_row(root)
    return _nc50_insert(f, lines, line, cells, title)


def inj_50_unread_below(root):
    """같은 행을 더하되 그 칸이 편 제목을 품고 그 뒤에 글자를 덧붙여 비가 문턱 아래로 가게 한다.

    짧은 제목이 같은 계열의 긴 제목에 들어가는 자리이며 잡히지 않아야 한다. 비가 문턱 아래인지와
    포함이 서는지를 주입 안에서 단언한다. 그 단언이 없으면 이 항이 문턱을 재지 않고 통과할 수 있다.
    """
    f, lines, line, cells, title = _nc50_unread_row(root)
    cell = title
    while True:
        ratio = wiki_prose.title_ratio(wiki_prose.title_key(cell), wiki_prose.title_key(title))
        if ratio is None:
            raise SystemExit("덧붙인 칸이 편 제목을 품지 않는다")
        if ratio < wiki_prose.INVENTORY_TITLE_RATIO / 2:
            break
        cell += " and its companion series"
    return _nc50_insert(f, lines, line, cells, cell)


# ----------------------------------------------------- 검사 53 · 54 · 뭉치 인벤토리의 구성원 행 표지

def _nc53_rows(root):
    """사본의 인벤토리 경로와 줄과 구성원 행과 표지 낱말. 구성원 행을 고르는 쪽은 검증기의 함수를
    그대로 부른다. 전사하면 그 검사가 꼴을 고칠 때 이 주입이 조용히 공허해진다."""
    led = wiki_common.Ledger(root)
    marks = wiki_common.inventorymark_block(led)
    f = root / wiki_common.INVENTORY_DOC
    text = f.read_text(encoding="utf-8")
    rows, _t, _r = wiki_common.inventory_member_rows(
        text, marks[wiki_common.INVENTORYMARK_AGGREGATE])
    if not rows:
        raise SystemExit("사본의 인벤토리에서 구성원 행을 하나도 읽지 못했다")
    return f, text.split("\n"), rows, marks[wiki_common.INVENTORYMARK_UNREAD]


def inj_53_drop(root):
    """구성원 행 하나에서 표지를 지운다.

    **번호를 들지 않고 미추출 표지 하나만 든 행을 고른다.** 번호를 든 행에서 표지를 지우면 그 행이
    번호로 통과해 이 주입이 겨눈 자리가 서지 않는다.
    """
    f, lines, rows, unread = _nc53_rows(root)
    for line, cells, _sec in rows:
        if unread in cells[-1] and not any(
                wiki_common.INVENTORY_EXTRACTION_NO.search(c) for c in cells):
            at = line - 1
            k = lines[at].rfind(" " + unread)
            if k < 0:
                raise SystemExit("고른 구성원 행에서 표지를 다시 찾지 못했다")
            lines[at] = lines[at][:k] + lines[at][k + len(unread) + 1:]
            f.write_text("\n".join(lines), encoding="utf-8")
            return f"{wiki_common.INVENTORY_DOC}:{line}"
    raise SystemExit("번호 없이 미추출 표지만 든 구성원 행이 없어 주입할 자리가 없다")


def inj_54_add(root):
    """미추출 표지를 든 행을 하나 늘린다. 표지를 들지 않은 구성원 행 하나의 비고 칸 말미에 더한다."""
    f, lines, rows, unread = _nc53_rows(root)
    for line, cells, _sec in rows:
        if unread not in cells[-1]:
            at = line - 1
            k = lines[at].rstrip().rfind("|")
            if k <= 0:
                raise SystemExit("고른 구성원 행의 마지막 칸을 찾지 못했다")
            lines[at] = lines[at][:k].rstrip() + " " + unread + " " + lines[at][k:]
            f.write_text("\n".join(lines), encoding="utf-8")
            return f"{wiki_common.INVENTORY_DOC}:{line}"
    raise SystemExit("미추출 표지를 들지 않은 구성원 행이 없어 주입할 자리가 없다")


def inj_58_unmarked(root):
    """표지를 들지 않는 행을 넣는다.

    지목 참조 대기 표의 마지막 행 뒤에 칸 셋의 행을 하나 더한다. 그 행의 칸이 블록의 어느 낱말도 품지
    않음을 넣기 전에 단언한다. 품으면 그 행이 표지를 든 행으로 읽혀 이 주입이 겨눈 자리가 서지 않는다.
    """
    led = wiki_common.Ledger(root)
    marks = wiki_prose.queuemark_block(led)
    words = [v for _k, v in wiki_prose.queuemark_words(marks)]
    f = root / wiki_common.READING_QUEUE_DOC
    lines = f.read_text(encoding="utf-8").split("\n")
    _at, rows = wiki_prose.queue_section_rows("\n".join(lines),
                                              marks[wiki_prose.QUEUEMARK_SECTION])
    if not rows:
        raise SystemExit("지목 참조 대기 표의 행이 없어 주입할 자리가 없다")
    row = "| 주입한 편 | 주입한 구멍 | 주입한 재료 |"
    if any(w in row for w in words):
        raise SystemExit("주입할 행이 표지의 낱말을 품는다")
    last = rows[-1][0]
    lines.insert(last, row)
    f.write_text("\n".join(lines), encoding="utf-8")
    return f"{wiki_common.READING_QUEUE_DOC}:{last + 1}"


# 검사 63 의 주입이 `ref` 에 심는 값. 그 표의 어느 행에도 닿지 않고 추출 기록의 번호로도 읽히지 않는
# 것을 넣기 전에 단언한다.
NC63_REF = "음성 대조가 주입한 지목"


def _nc63(root):
    """사본의 원장과 소진 낱말과 지목 참조 대기 표의 행. 검증기의 수집기를 그대로 써서 주입과 판정이
    같은 행을 본다."""
    led = wiki_common.Ledger(root)
    marks = wiki_prose.queuemark_block(led)
    if wiki_prose.QUEUEMARK_SPENT not in marks:
        raise SystemExit("QUEUEMARK 블록에 소진 낱말이 없어 주입 대상을 고를 수 없다")
    _at, rows = wiki_prose.queue_section_rows(
        (root / wiki_common.READING_QUEUE_DOC).read_text(encoding="utf-8"),
        marks[wiki_prose.QUEUEMARK_SECTION])
    if not rows:
        raise SystemExit("지목 참조 대기 표의 행이 없어 주입 대상이 없다")
    return led, marks[wiki_prose.QUEUEMARK_SPENT], rows


def _nc63_extraction(e) -> str | None:
    """재개 트리거가 추출 갈래이면 그 `ref`, 아니면 None 이다."""
    rw = e.get("reopen_when")
    if isinstance(rw, dict) and rw.get("kind") == "extraction":
        return str(rw.get("ref") or "")
    return None


def inj_63_retired(root):
    """소진 표지를 든 행이 가리키는 이연의 폐기 레코드를 지운다.

    그 이연이 살아나 소진 표지를 든 행에 닿으므로 적발에 들어야 한다. 이연을 박지 않고 사본의
    원장과 표에서 고르며, 고른 이연의 id 를 표지로 돌려준다.
    """
    led, spent, rows = _nc63(root)
    cell = wiki_prose.QUEUEMARK_CELL
    for e in led.reg["deferred"]:
        ref = _nc63_extraction(e)
        if ref is None or e.get("id") not in led.dead:
            continue
        hit = wiki_prose.queue_ref_rows(rows, ref)
        if any(len(c) > cell and spent in c[cell] for _line, c in hit):
            doc = load(root, "retirements")
            doc["retirements"] = [q for q in doc["retirements"] if q.get("target") != e["id"]]
            save(root, "retirements", doc)
            return e["id"]
    raise SystemExit("소진 표지를 든 행에 닿는 폐기된 이연이 없어 주입 대상이 없다")


def inj_63_ref(root):
    """살아 있는 이연 하나의 `ref` 를 그 표의 어느 행에도 닿지 않는 값으로 바꾼다.

    그 이연이 닿는 항에서 빠져 어느 행에도 닿지 않는 항으로 세어져야 한다. 고른 이연의 id 를
    표지로 돌려준다.
    """
    led, _spent, rows = _nc63(root)
    if wiki_prose.queue_ref_rows(rows, NC63_REF) or wiki_common.extraction_ref_number(NC63_REF) is not None:
        raise SystemExit("주입할 `ref` 가 표의 행에 닿거나 추출 기록의 번호로 읽힌다")
    for e in led.reg["deferred"]:
        ref = _nc63_extraction(e)
        if ref is None or e.get("id") in led.dead or not wiki_prose.queue_ref_rows(rows, ref):
            continue
        edit(root, "deferred", e["id"],
             lambda x: x["reopen_when"].__setitem__("ref", NC63_REF))
        return e["id"]
    raise SystemExit("표의 행에 닿는 살아 있는 이연이 없어 주입 대상이 없다")


def inj_59_dup(root):
    """같은 줄기의 파일을 하나 더 둔다. 번호는 실재하는 기록과 겹치지 않는 두 자리로 고른다."""
    d = root / "docs" / "extractions"
    files = [f for f in sorted(d.glob("extraction-*.md")) if wiki_common.EXTRACTION_FILE_NO.match(f.name)]
    if not files:
        raise SystemExit("번호를 든 추출 기록이 없어 주입할 자리가 없다")
    used = {int(wiki_common.EXTRACTION_FILE_NO.match(f.name).group(1)) for f in files}
    n = next(k for k in range(99, 9, -1) if k not in used)
    src = files[-1]
    stem = src.name[wiki_common.EXTRACTION_FILE_NO.match(src.name).end():]
    dst = d / f"extraction-{n:02d}-{stem}"
    dst.write_text(src.read_text(encoding="utf-8"), encoding="utf-8")
    return dst.name


def inj_61_sum(root):
    """무리 행 하나의 편수를 하나 늘린다. 합계 행은 그대로 둔다.

    표를 고르는 쪽은 검증기의 함수를 그대로 부른다. 전사하면 그 검사가 표를 읽는 꼴을 고칠 때 이
    주입이 조용히 공허해진다.
    """
    led = wiki_common.Ledger(root)
    marker = wiki_common.inventorymark_block(led)[wiki_common.INVENTORYMARK_AGGREGATE]
    f = root / wiki_common.INVENTORY_DOC
    lines = f.read_text(encoding="utf-8").split("\n")
    rows = wiki_prose.inventory_aggregate_rows("\n".join(lines), marker)
    hit = [(n, c) for n, c in rows if not c[0].startswith("**") and c[1].isdigit()]
    if not hit:
        raise SystemExit("집계 표에서 편수가 수인 무리 행을 찾지 못해 주입할 자리가 없다")
    n, cells = hit[0]
    lines[n - 1] = lines[n - 1].replace(f"| {cells[1]} |", f"| {int(cells[1]) + 1} |", 1)
    f.write_text("\n".join(lines), encoding="utf-8")
    return f"{wiki_common.INVENTORY_DOC}:{n}"


# 이 단위가 거느리는 음성 대조의 사례. 하네스가 단위 순서로 이 목록을 이어
# 붙이며 사례의 손 열거를 들지 않는다. **선언으로 두는 까닭은** 이 목록을 읽는
# 검사가 뿌리의 소스를 텍스트로 읽으므로 모듈의 값을 모으는 꼴이면 그 검사가
# 읽을 문면이 없다는 것이다.
CASES = [
    ("12", "wiki12-reopen-ref", "아크가 아닌 문자열을 arc_phase 에 적는다", inj_12, None),
    ("43", "wiki43-extraction-trigger-age", "실재하지 않는 번호를 extraction 의 ref 로 둔다", inj_43, None),
    ("32", "wiki32-closure-phase", "선언되지 않은 페이즈 이름으로 종료 문서를 둔다", inj_32, None),
    ("35", "wiki35-doc-form", "청사진을 docs/ 에 둔다", inj_35_plan, None),
    ("35", "wiki35-doc-form", "패치 조각을 docs/ 에 둔다", inj_35_patch, None),
    ("35", "wiki35-doc-form", "별지를 docs/ 에 둔다", inj_35_annex, None),
    ("35", "wiki35-doc-form", "종료 문서가 아닌 것을 phases/ 에 둔다", inj_35_phases_other, None),
    ("35", "wiki35-doc-form", "선언되지 않은 아크 이름으로 종료 문서를 둔다", inj_35_phases_arc, None),
    ("35", "wiki35-doc-form", "추출 기록의 접두사를 어긴다", inj_35_extraction, None),
    ("35", "wiki35-doc-form", "파일 이름에 대문자와 밑줄을 쓴다", inj_35_case, None),
    ("35", "wiki35-doc-form", "허용되지 않은 디렉터리를 만든다", inj_35_dir, None),
    ("35", "wiki35-doc-form", "원장 디렉터리에 새 파일을 둔다", inj_35_ledger, None),
    ("36", "wiki36-root-surface", "무시 파일에서 /* 줄을 지운다", inj_36_open, None),
    ("36", "wiki36-root-surface", "없는 이름으로 되살림 줄을 더한다", inj_36_ghost, None),
    ("37", "wiki37-claude-ledger-count", "원장 계수 표의 한 행의 수를 하나 틀리게 적는다", inj_37_count, None),
    ("41", "wiki41-pointer-scope", "면제 목록에 없는 항목의 산문에 살아 있는 조항의 주석을 지목하는 꼴을 적는다", inj_41_pointer, None),
    ("35", "wiki35-doc-form", "같은 번호를 가진 추출 기록을 둔다", inj_35_dupnum, None),
    ("35", "wiki35-doc-form", "중간 번호의 추출 기록을 옮겨 결번을 만든다", inj_35_gapnum, None, "nocatch"),
    ("41", "wiki41-pointer-scope", "규율 ID 뒤 그 거리 안에 그 낱말이 따르는 자리를 하나 더한다", inj_41_comment, None),
    ("41", "wiki41-pointer-scope", "소진 문서의 식별자 꼴을 하나 더한다", inj_41_ephemeral, None),
    ("41", "wiki41-pointer-scope", "앞에 출처 표지도 문서 이름도 오지 않는 절 번호를 하나 더한다", inj_41_section, None),
    ("49", "wiki49-extraction-unpointed", "어느 docstring 도 지목하지 않는 기록을 하나 더한다", inj_49_unpointed, None),
    ("50", "wiki50-inventory-extraction-mirror", "인벤토리의 구성원 행 하나에 실재하지 않는 기록 번호를 적는다", inj_50_missing, None),
    ("50", "wiki50-inventory-extraction-mirror", "추출 기록 하나의 번호를 드는 구성원 행을 인벤토리에서 지운다", inj_50_ghost, None),
    ("50", "wiki50-inventory-extraction-mirror", "미추출 표지를 든 구성원 행의 칸이 추출 기록의 편 제목을 든다", inj_50_unread, None),
    ("50", "wiki50-inventory-extraction-mirror", "그 칸이 편 제목을 품되 비가 문턱 아래다", inj_50_unread_below, None, "nocatch"),
    ("53", "wiki53-inventory-member-marker", "구성원 행 하나에서 표지를 지운다", inj_53_drop, None),
    ("54", "wiki54-inventory-unread-count", "미추출 표지를 든 행을 하나 늘린다", inj_54_add, None),
    ("58", "wiki58-queue-marker", "표지를 들지 않는 행을 넣는다", inj_58_unmarked, None),
    ("59", "wiki59-extraction-stem-unique", "같은 줄기의 파일을 하나 더 둔다", inj_59_dup, None),
    ("61", "wiki61-inventory-aggregate-sum", "무리 행 하나의 편수를 하나 늘린다", inj_61_sum, None),
    ("63", "wiki63-queue-spent-alive", "소진 표지를 든 행이 가리키는 이연의 폐기 레코드를 지운다", inj_63_retired, None),
    ("63", "wiki63-queue-spent-alive", "한 이연의 ref 를 그 표의 어느 행에도 닿지 않는 값으로 바꾼다", inj_63_ref, None),
]
