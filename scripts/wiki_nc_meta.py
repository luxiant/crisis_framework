"""메타 갈래 검사의 음성 대조 주입.

`scripts/wiki_meta.py` 가 든 검사의 주입 함수와 그 사례 목록을 든다. 주입이 어느 단위에
사는지는 그 주입이 겨눈 검사가 사는 단위에서 유도한다.
"""

from __future__ import annotations

import re
import wiki_common
import wiki_meta
from wiki_nc_common import edit, ko_word, pick


def inj_40_count(root):
    """계수 자리 가운데 하나의 수를 하나 틀리게 적는다.

    명세의 가름을 함께 드는 자리가 든 전체 계수를 하나 올린다. 자리를 하나만 건드리는 주입이므로
    그 자리와 정본이 어긋나는 것이 잡혀야 하고, 자리마다 따로 돌리지 않는다. 판정 대상 하나에 한
    번만 돌린다는 요구가 그것을 든다.

    **자리를 그 검사의 꼴로 찾는다.** 그 검사가 유니버스를 열거에서 꼴 유도로 바꿨으므로 열거의
    첫 항을 집던 앞 판은 설 자리가 없어졌다. 꼴을 전사하면 그 검사가 꼴을 고칠 때 이 주입이
    조용히 공허해진다.
    """
    rel = wiki_common.COUNT_SPEC
    f = root / rel
    text = f.read_text(encoding="utf-8")
    m = wiki_meta.COUNT_GROUP_FORM.search(text)
    if m is None:
        raise SystemExit(f"{rel} 에서 가름을 함께 드는 자리를 찾지 못했다")
    said = wiki_meta.ko_count(m.group(1))
    if said is None:
        raise SystemExit(f"그 자리가 든 수사 `{m.group(1)}` 를 값으로 읽을 수 없다")
    wrong = ko_word(said + 1)
    at, end = m.span(1)
    f.write_text(text[:at] + wrong + text[end:], encoding="utf-8")
    return f"{rel} 의 전체 계수: {m.group(1)}→{wrong}"


# 검사 44 의 주입이 만지는 자리. 사례 목록을 소스의 문면으로 고치는 까닭은 그 검사가 사본의
# 소스를 읽기 때문이며, 돌고 있는 이 모듈의 값을 고쳐도 사본에는 닿지 않는다. **만질 파일을
# 박아 두지 않고 사본의 실물에서 고르는 까닭은** 사례 목록이 음성 대조 단위마다 서므로 한
# 파일을 문면에 박으면 그 파일의 사례가 비는 날에 그 주입이 조용히 공허해진다는 것이다.


NC_LIST_FORM = re.compile(r"^CASES = \[(.*?)^\]", re.M | re.S)


NC_ROW_FORM = re.compile(r'^[ \t]*\("([^"]+)",\s*"([^"]+)".*?\),[ \t]*$', re.M)


def _nc_rows(root):
    """사본의 사례 목록과 그 행. (파일, 전문, 행의 목록) 을 낸다.

    음성 대조 단위 가운데 사례 행이 실재하는 첫 파일을 고른다. 고르지 못하면 주입이 설
    자리가 없으므로 멈춘다.
    """
    for rel in wiki_common.WIKI_NC_UNITS:
        f = root / rel
        if not f.is_file():
            continue
        src = f.read_text(encoding="utf-8")
        m = NC_LIST_FORM.search(src)
        if m is None:
            continue
        rows = list(NC_ROW_FORM.finditer(src, m.start(1), m.end(1)))
        if rows:
            return f, src, rows
    raise SystemExit("사본의 음성 대조 단위에서 사례 행을 하나도 읽지 못했다")


def inj_44_drop(root):
    """한 검사의 주입 항을 사례 목록에서 지운다.

    사례가 하나뿐인 검사를 고른다. 둘 이상인 검사의 한 항만 지우면 다른 항이 남아 그 검사의
    번호가 여전히 목록에 서고 주입이 공허해진다.
    """
    f, src, rows = _nc_rows(root)
    nums = [m.group(1) for m in rows]
    victim = next((m for m in rows if nums.count(m.group(1)) == 1), None)
    if victim is None:
        raise SystemExit("사례가 하나뿐인 검사가 없어 지울 자리가 없다")
    f.write_text(src[:victim.start()] + src[victim.end() + 1:], encoding="utf-8")
    return victim.group(1)


def inj_44_ghost(root):
    """명세에 없는 번호로 사례를 더한다."""
    f, src, rows = _nc_rows(root)
    ghost = "9944"
    if any(m.group(1) == ghost for m in rows):
        raise SystemExit(f"번호 {ghost} 가 사례 목록에 이미 있어 없는 번호로 쓰지 못한다")
    stem = re.search(r",\s*(inj_[A-Za-z0-9_]+)\s*,", rows[0].group(0))
    if stem is None:
        raise SystemExit("고른 사례 행에서 주입 함수의 이름을 읽지 못했다")
    row = (f'    ("{ghost}", "wiki{ghost}-ghost", "음성 대조가 주입한 항이다", '
           f'{stem.group(1)}, None, None),\n')
    f.write_text(src[:rows[0].start()] + row + src[rows[0].start():], encoding="utf-8")
    return ghost


def inj_44_step(root):
    """사례 목록의 한 항이 전사한 단계 id 를 다른 값으로 바꾼다."""
    f, src, rows = _nc_rows(root)
    first = rows[0]
    bent = first.group(0).replace(f'"{first.group(2)}"', '"wiki-음성-대조가-바꾼-단계"', 1)
    f.write_text(src[:first.start()] + bent + src[first.end():], encoding="utf-8")
    return first.group(2)


# 검사 46 의 주입이 만지는 줄. 목록의 이름을 담은 문장이며 그 꼴의 정본은 검증기가 든다.
SPEC_IN_COPY = ("docs", "decisions", "SPEC.md")


def _spec_block_list(root):
    """사본의 기계 판독 블록 목록 문장. (파일, 전문, 그 범위) 를 낸다."""
    f = root.joinpath(*SPEC_IN_COPY)
    src = f.read_text(encoding="utf-8")
    m = wiki_meta.SPEC_BLOCK_SENTENCE.search(src)
    if m is None:
        raise SystemExit("사본에서 기계 판독 블록의 목록을 읽지 못했다")
    return f, src, m


def inj_46_drop(root):
    """목록에서 블록 이름 하나를 지운다."""
    f, src, m = _spec_block_list(root)
    names = wiki_meta.SPEC_BLOCK_NAME.findall(m.group(1))
    if not names:
        raise SystemExit("목록이 든 블록 이름이 없어 지울 자리가 없다")
    gone = names[0]
    bent = m.group(1).replace(f"`{gone}` 과 ", "", 1)
    if bent == m.group(1):
        raise SystemExit(f"목록에서 `{gone}` 를 지우는 꼴을 찾지 못했다")
    f.write_text(src[:m.start(1)] + bent + src[m.end(1):], encoding="utf-8")
    return gone


def inj_46_ghost(root):
    """어느 검사도 읽지 않는 이름을 목록에 더한다."""
    f, src, m = _spec_block_list(root)
    ghost = "NOSUCHBLOCK"
    if ghost in m.group(1):
        raise SystemExit(f"`{ghost}` 가 목록에 이미 있어 읽히지 않는 이름으로 쓰지 못한다")
    bent = m.group(1) + f" 그리고 `{ghost}` 가 그 목록에 더 선다"
    f.write_text(src[:m.start(1)] + bent + src[m.end(1):], encoding="utf-8")
    return ghost


def inj_47_ghost(root):
    """어느 필드 표의 검사 칸에 실재하지 않는 번호를 적는다.

    **자리를 그 검사의 꼴로 찾는다.** 그 검사가 유니버스를 표의 머리에서 유도하므로 절이나 줄을
    집으면 표가 하나 더 설 때 이 주입이 다른 자리를 겨누게 되고, 꼴을 전사하면 그 검사가 꼴을
    고칠 때 이 주입이 조용히 공허해진다.

    번호를 선언된 검사에서 빼어 고른다. 실재하는 번호를 적으면 그 칸이 다른 검사를 가리키는
    꼴이 되어 이 주입이 아무것도 겨누지 않는다.
    """
    f = root / wiki_common.COUNT_SPEC
    text = f.read_text(encoding="utf-8")
    rows, _outside = wiki_meta.spec_field_rows(text)
    target = next((x for x in rows if x[3]), None)
    if target is None:
        raise SystemExit(f"{wiki_common.COUNT_SPEC} 에 검사 칸이 선 필드 표의 행이 없다")
    declared: set[str] = set()
    for _rel in wiki_common.WIKI_UNITS:
        declared |= set(dict(wiki_common.REPORT_DECL.findall(
            (root / _rel).read_text(encoding="utf-8"))))
    ghost = next((str(n) for n in range(90, 100) if str(n) not in declared), None)
    if ghost is None:
        raise SystemExit("선언되지 않은 번호를 고를 자리가 없어 주입이 서지 않는다")
    line, _sec, field, _cell, at = target
    lines = text.splitlines(keepends=True)
    raw = lines[line - 1]
    tail = "\n" if raw.endswith("\n") else ""
    inner = raw.rstrip("\n").strip()
    parts = wiki_common.SPEC_CELL_SPLIT.split(inner[1:-1])
    parts[at] = parts[at].rstrip() + wiki_meta.SPEC_CHECK_JOIN + ghost + " "
    lines[line - 1] = "|" + "|".join(parts) + "|" + tail
    f.write_text("".join(lines), encoding="utf-8")
    return f"{field}: {ghost}"


# ----------------------------------------------------- 검사 51 · 원장 entry 의 키 유니버스

def inj_51_key(root):
    """원장 entry 하나에 그 유니버스 밖의 키를 더한다.

    유니버스는 검증기의 함수로 사본의 명세에서 뽑는다. 전사하면 그 검사가 유니버스를 고칠 때
    고른 키가 유니버스 안으로 들어가 이 주입이 조용히 공허해진다. **값은 어느 검사도 읽지 않는
    문면으로 둔다.** 산문 필드를 읽는 검사가 그 값에 걸리면 이 주입이 다른 검사까지 실패시켜
    겨눈 자리가 흐려진다.
    """
    names, _seen, _odd = wiki_meta.ledger_key_universe(
        (root / wiki_common.COUNT_SPEC).read_text(encoding="utf-8"))
    universe = set().union(*names.values())
    if not universe:
        raise SystemExit("사본의 명세에서 키 유니버스를 읽지 못했다")
    key = "negative_control_probe"
    if key in universe:
        raise SystemExit(f"주입할 키 `{key}` 가 이미 유니버스 안에 있다")
    e = pick(root, "decisions", lambda x: True)
    edit(root, "decisions", e["id"], lambda x: x.__setitem__(key, "음성 대조가 주입한 키다."))
    return f"{e['id']} 가 유니버스 밖의 키 `{key}`"


# 이 단위가 거느리는 음성 대조의 사례. 하네스가 단위 순서로 이 목록을 이어
# 붙이며 사례의 손 열거를 들지 않는다. **선언으로 두는 까닭은** 이 목록을 읽는
# 검사가 뿌리의 소스를 텍스트로 읽으므로 모듈의 값을 모으는 꼴이면 그 검사가
# 읽을 문면이 없다는 것이다.
CASES = [
    ("40", "wiki40-check-count-places", "계수 자리 가운데 하나의 수를 하나 틀리게 적는다", inj_40_count, None),
    ("44", "wiki44-injection-mirror", "한 검사의 주입 항을 사례 목록에서 지운다", inj_44_drop, None),
    ("44", "wiki44-injection-mirror", "명세에 없는 번호로 사례를 더한다", inj_44_ghost, None),
    ("44", "wiki44-injection-mirror", "사례 목록의 한 항이 전사한 단계 id 를 다른 값으로 바꾼다", inj_44_step, None),
    ("46", "wiki46-block-list-mirror", "목록에서 블록 이름 하나를 지운다", inj_46_drop, None),
    ("46", "wiki46-block-list-mirror", "어느 검사도 읽지 않는 이름을 더한다", inj_46_ghost, None),
    ("47", "wiki47-spec-field-check-no", "어느 필드 표의 검사 칸에 실재하지 않는 번호를 적는다", inj_47_ghost, None),
    ("51", "wiki51-ledger-key-universe", "원장 entry 하나에 그 유니버스 밖의 키를 더한다", inj_51_key, None),
]
