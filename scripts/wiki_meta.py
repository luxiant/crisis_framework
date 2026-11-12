# -*- coding: utf-8 -*-
"""원장 검증기의 검사 가운데 검증 설비 자신과 원장 명세를 유니버스로 드는 검사.

이 단위가 자기 검사의 목록을 `CHECKS` 로 선언하고 러너가 그 목록을 이어 붙인다.
검사의 번호와 단계 id 는 그 선언이 들고 이 파일이 그 계수를 들지 않는다.
"""
from __future__ import annotations

import re

from wiki_common import (
    COUNT_KO_TENS,
    COUNT_KO_UNIT,
    COUNT_SECTION_HEAD,
    COUNT_SPEC,
    COUNT_VERIFY,
    COUNT_WIKI,
    Ledger,
    REGISTERS,
    REPORT_DECL,
    Report,
    SPEC_FIELD_HEAD,
    SPEC_TABLE_RULE,
    WIKI_UNITS,
    md_cells,
)

# 검사 40 이 읽는 계수 자리. SPEC §2 의 세 절이 그 자리를 들고 정렬 상수의 길이가 전체 계수의
# 정본이다(CF-1175). 나머지 여섯 자리는 그 값이나 그 가름을 산문으로 든다.
#
# **자리마다 어느 값을 드는지가 다르다.** 전체 계수와 실패시키는 것과 보고만 하는 것과 아크 종료
# 시에만 도는 것이 네 수로 갈려 서므로, 한 자리의 수를 전체 계수와 바로 맞대면 가름을 드는 자리가
# 전부 어긋난 것으로 선다. 그래서 자리마다 어느 값을 드는지를 함께 둔다(SPEC §2.1).
COUNT_TOTAL = "전체"


COUNT_FAIL = "실패시키는 것"


COUNT_REPORT = "보고만 하는 것"


COUNT_ARC = "아크 종료 시에만 도는 것"


# 정렬 상수의 목록. 돌고 있는 모듈의 `ORDER` 를 세지 않고 뿌리의 소스에서 읽는다. 음성 대조가
# 사본을 뿌리로 지목하므로 자기 모듈을 세면 사본의 그 자리에 든 주입을 보지 못하며, 나머지
# 자리도 전부 뿌리에서 읽어 그 자리 전량이 한 판을 본다.
COUNT_ORDER_LIST = re.compile(r"^ORDER = \[(.*?)\]", re.M | re.S)


COUNT_ORDER_ITEM = re.compile(r'"[^"]+"')


# 명세 §2 의 표의 행. 머리와 가름 줄은 첫 칸이 검사 번호가 아니라 세지 않는다.
COUNT_SPEC_ROW = re.compile(r"^\|\s*\*\*\S+\*\*\s*\|")


# 한글 수사의 꼴. 위 두 표에서 지어 쓰며 따로 적지 않는다. 전사하면 표에 수사를 더하는 회차가
# 이 꼴을 잊어 그 수사를 쓴 자리가 유니버스에서 조용히 빠진다. 긴 것을 앞에 두는 까닭은
# 「마흔여섯」이 「마흔」으로 잘려 값이 달라지는 것을 막는 것이다.
COUNT_KO_FORM = "(?:" + "|".join(sorted(
    [t + u for t in COUNT_KO_TENS for u in COUNT_KO_UNIT]
    + list(COUNT_KO_TENS) + list(COUNT_KO_UNIT), key=len, reverse=True)) + ")"


# 계수를 드는 자리를 유도하는 꼴 셋. 규약의 정본은 SPEC §2 의 머리이며, 열거를 쓰지 않는 까닭은
# 검사를 하나 더하는 회차가 열거에서 한 자리를 잊으면 그대로 통과하고 그 낡음을 어느 검사도 보지
# 않는다는 것이다.
#
# **가름을 함께 드는 자리**는 전체 계수 뒤에 세 가름이 그 순서로 따른다. 사이에 끼는 문면의 길이를
# 묶는 까닭은 묶지 않으면 한 파일의 멀리 떨어진 두 문면이 한 자리로 붙어 잡히는 것이다.
#
# **전체만 드는 자리**는 명세의 그 절을 지목하고 이어 조사 없이 수사를 든다. 그 지목을 함께 요구하는
# 까닭은 「검사 셋의 판정」처럼 검사의 수를 세지 않는 산문이 그 지목 없이 같은 꼴로 서기 때문이며,
# 요구하지 않으면 그런 자리가 여섯 잡혀 이 검사가 제 유니버스를 잃는다.
#
# **절 제목**은 괄호의 수사가 그 절의 표의 행 수를 들고, 어느 가름을 드는지는 제목의 낱말에서
# 유도한다. 번호를 박지 않으므로 절이 하나 더 서면 그 자리가 저절로 유니버스에 든다.
COUNT_GROUP_FORM = re.compile(
    r"검사[는은]?\s*(" + COUNT_KO_FORM + r")(?:이다|을|를)"
    r"[^\n]{0,40}?실패시키는 것\s*(" + COUNT_KO_FORM + r")"
    r".{0,60}?보고만 하는 것\s*(" + COUNT_KO_FORM + r")"
    r".{0,60}?아크 종료 시에만 도는 것\s*(" + COUNT_KO_FORM + r")", re.S)


COUNT_TOTAL_FORM = re.compile(r"§2 의 검사\s(" + COUNT_KO_FORM + r")")


COUNT_HEADING_FORM = re.compile(r"^### 2\.\d+ (.+?) \((" + COUNT_KO_FORM + r")\)$")


COUNT_HEADING_KIND = {"실패시키는": COUNT_FAIL, "보고만 하는": COUNT_REPORT,
                      "아크 종료": COUNT_ARC}


def ko_count(word: str) -> int | None:
    """한글 수사를 값으로 읽는다. 「마흔둘」처럼 열 자리와 한 자리를 붙인 꼴까지 받는다."""
    if word in COUNT_KO_UNIT:
        return COUNT_KO_UNIT[word]
    for tens, base in COUNT_KO_TENS.items():
        if word == tens:
            return base
        if word.startswith(tens) and word[len(tens):] in COUNT_KO_UNIT:
            return base + COUNT_KO_UNIT[word[len(tens):]]
    return None


def count_spec_sections(text: str) -> tuple[list[tuple[str, str, int, int]], list[str]]:
    """§2 의 절 제목마다 (제목, 어느 가름인가, 제목이 든 수, 그 절의 표의 행 수) 와 결손의 목록.

    괄호에 수사를 들지 않는 절 제목과 낱말에서 가름이 유도되지 않는 절 제목을 결손으로 낸다.
    건너뛰면 그 절이 계수를 들지 않는 절로 읽혀 유니버스에서 조용히 빠지고, 그 빠짐을 어느
    검사도 보지 않는다.
    """
    out: list[tuple[str, str, int, int]] = []
    bad: list[str] = []
    lines = text.splitlines()
    for i, ln in enumerate(lines):
        if not COUNT_SECTION_HEAD.match(ln):
            continue
        m = COUNT_HEADING_FORM.match(ln)
        if m is None:
            bad.append(f"절 제목 `{ln.strip()}` 이 괄호에 수사를 들지 않아 계수 자리에서 빠진다")
            continue
        kind = next((k for w, k in COUNT_HEADING_KIND.items() if w in m.group(1)), None)
        if kind is None:
            bad.append(f"절 제목 `{ln.strip()}` 의 낱말에서 어느 가름인지 유도되지 않는다")
            continue
        rows = 0
        for x in lines[i + 1:]:
            if COUNT_SPEC_ROW.match(x):
                rows += 1
            elif rows and not x.startswith("|"):
                break
        out.append((ln.strip(), kind, ko_count(m.group(2)) or 0, rows))
    return out, bad


def unit_declarations(root) -> dict[str, str]:
    """단위 전량에서 검사의 선언을 읽어 번호와 단계 id 의 짝으로 낸다.

    러너가 검사를 들지 않으므로 그 유니버스가 단위 전량이다. 뿌리의 소스에서 읽는
    까닭은 음성 대조가 사본을 뿌리로 지목한다는 것이며, 돌고 있는 모듈을 세면 그
    사본에 든 주입을 보지 못한다.
    """
    out: dict[str, str] = {}
    for rel in WIKI_UNITS:
        f = root / rel
        if not f.is_file():
            continue
        out.update(dict(REPORT_DECL.findall(f.read_text(encoding="utf-8"))))
    return out


def check_40(led: Ledger) -> Report:
    r = Report("40", "wiki40-check-count-places",
               "검사의 계수가 실리는 자리가 ORDER 의 길이와 같은 값을 드는가", "fail")
    text: dict[str, str] = {}
    for rel in (COUNT_SPEC, COUNT_VERIFY, COUNT_WIKI):
        f = led.root / rel
        if not f.is_file():
            r.bad(f"{rel} 이 없다")
            return r
        text[rel] = f.read_text(encoding="utf-8")
    # ㉠ 정본. 정렬 상수의 길이가 전체 계수다. 목록을 읽을 수 없으면 맞댈 상대가 없으므로
    # 통과가 아니라 실패다. 검사 28 과 34 와 35 와 37 과 38 이 같은 요구를 둔다.
    m = COUNT_ORDER_LIST.search(text[COUNT_WIKI])
    if m is None:
        r.bad(f"{COUNT_WIKI} 에서 정렬 상수 `ORDER` 의 목록을 읽을 수 없다")
        return r
    order = len(COUNT_ORDER_ITEM.findall(m.group(1)))
    # 자리마다 (이름, 어느 값을 드는가, 그 수) 다. 한 자리가 네 값을 다 들면 넷이 선다.
    places: list[tuple[str, str, int]] = [
        ("check_wiki.py 의 정렬 상수", COUNT_TOTAL, order)]
    # ㉡ 산문의 자리를 꼴로 유도한다. **열거를 쓰지 않는 까닭은 검사를 하나 더하는 회차가
    # 열거에서 한 자리를 잊으면 그대로 통과하고 그 낡음을 어느 검사도 보지 않는다는 것이다.**
    # 가름을 함께 드는 자리가 그 전체 계수도 들므로, 그 자리에 겹치는 전체 자리를 다시 세지
    # 않는다. 세면 한 문면이 두 자리로 보고된다.
    for rel in (COUNT_SPEC, COUNT_VERIFY, COUNT_WIKI):
        spans: list[tuple[int, int]] = []
        for g in COUNT_GROUP_FORM.finditer(text[rel]):
            spans.append(g.span())
            for key, word in zip((COUNT_TOTAL, COUNT_FAIL, COUNT_REPORT, COUNT_ARC),
                                 g.groups()):
                places.append((f"{rel} 의 가름을 함께 드는 자리", key, ko_count(word) or 0))
        for t in COUNT_TOTAL_FORM.finditer(text[rel]):
            if any(a <= t.start(1) < b for a, b in spans):
                continue
            places.append((f"{rel} 의 전체 계수를 드는 자리", COUNT_TOTAL,
                           ko_count(t.group(1)) or 0))
    # ㉢ 절 제목이 든 수와 그 절의 표의 행 수. 둘을 따로 올려 그 둘이 갈리는 것도 이 자리에서
    # 선다. 절을 번호로 박지 않으므로 절이 하나 더 서면 그 자리가 저절로 유니버스에 든다.
    sections, head_bad = count_spec_sections(text[COUNT_SPEC])
    for line in head_bad:
        r.bad(line)
    if not sections:
        r.bad(f"{COUNT_SPEC} 에서 계수를 드는 절 제목을 하나도 찾지 못했다")
    for title, kind, said, rows in sections:
        places.append((f"{COUNT_SPEC} 의 절 제목 `{title}`", kind, said))
        places.append((f"{COUNT_SPEC} 의 `{title}` 의 표의 행", kind, rows))
    # ㉣ 전체 계수를 드는 자리는 정본과 바로 맞댄다.
    for name, key, value in places:
        if key == COUNT_TOTAL and value != order:
            r.bad(f"`{name}` 이 전체 계수를 {value} 로 드는데 정렬 상수의 길이가 {order} 이다")
    # ㉤ 가름을 드는 자리는 같은 종류끼리 맞댄다. 한 자리가 낡으면 그 종류의 수가 자리마다 갈린다.
    part: dict[str, int] = {}
    for key in (COUNT_FAIL, COUNT_REPORT, COUNT_ARC):
        got = [(n, v) for n, k, v in places if k == key]
        if not got:
            r.bad(f"`{key}` 의 계수를 드는 자리가 하나도 없다")
            continue
        if len({v for _, v in got}) != 1:
            r.bad(f"`{key}` 의 계수가 자리마다 갈린다: "
                  + " · ".join(f"{n} {v}" for n, v in got))
            continue
        part[key] = got[0][1]
    # ㉥ 가름의 합이 전체다. 이 단언이 없으면 가름의 세 수가 서로만 맞아도 통과해 그 셋이 정본과
    # 끊기고, 표의 행 수가 정본에 맺히는 자리도 이것뿐이다.
    if len(part) == 3 and sum(part.values()) != order:
        r.bad("가름의 합 " + " + ".join(f"{k} {v}" for k, v in part.items())
              + f" = {sum(part.values())} 가 정렬 상수의 길이 {order} 와 다르다")
    # 자리의 수는 이 검사가 세지 않고 보고에 낸다. 그 수의 정본은 명세의 산문이므로 이 검사가
    # 그것을 읽으면 자기 유니버스를 자기가 정하게 된다.
    r.note(f"정본은 정렬 상수의 길이 {order} 다. 계수를 드는 자리 "
           f"{len({n for n, _, _ in places})} · 그 자리가 든 수 {len(places)}")
    for name, key, value in places:
        r.note(f"{name} — {key} {value}")
    return r


# 검사 44 가 읽는 자리 셋. 음성 대조의 사례 목록과 검사가 선언한 단계 id 와 명세의 주입 시험 칸이며,
# **셋을 전부 뿌리의 소스에서 읽는다.** 돌고 있는 모듈의 값을 세면 사본을 뿌리로 지목한 음성 대조가
# 그 사본에 든 주입을 보지 못해 그 주입이 공허해진다. 검사 40 의 정렬 상수가 같은 사유로 그렇게 선다.
COUNT_COMMON = "scripts/wiki_common.py"


NC_SOURCE = "scripts/wiki_negative_control.py"


NC_CASES_LIST = re.compile(r"^CASES = \[(.*?)^\]", re.M | re.S)


NC_CASE_ROW = re.compile(r'^\s*\("([^"]+)",\s*"([^"]+)"', re.M)


# 명세 §2 의 표의 행에서 번호와 칸을 뽑는 꼴. 주입 시험 칸이 마지막 열이다.
SPEC_ROW_CELLS = re.compile(r"^\|\s*\*\*(\S+?)\*\*\s*\|(.*)\|\s*$")


def spec_injection_cells(text: str) -> dict[str, str]:
    """§2 의 절마다 그 표의 행의 (검사 번호, 주입 시험 칸). 칸이 비면 빈 문자열이다."""
    out: dict[str, str] = {}
    inside = False
    for ln in text.splitlines():
        if COUNT_SECTION_HEAD.match(ln):
            inside = True
            continue
        if ln.startswith("## ") or (ln.startswith("### ") and not COUNT_SECTION_HEAD.match(ln)):
            inside = False
        if not inside:
            continue
        m = SPEC_ROW_CELLS.match(ln)
        if m:
            out[m.group(1)] = m.group(2).rsplit("|", 1)[-1].strip()
    return out


def check_44(led: Ledger) -> Report:
    r = Report("44", "wiki44-injection-mirror",
               "주입 시험 칸이 든 검사마다 음성 대조에 사례가 있고 그 역도 서며, "
               "사례가 전사한 단계 id 가 그 검사의 선언과 같은가", "fail")
    spec = led.root / COUNT_SPEC
    nc = led.root / NC_SOURCE
    for f in (spec, nc, *(led.root / rel for rel in WIKI_UNITS)):
        if not f.is_file():
            r.bad(f"{f.name} 이 없다")
            return r
    cells = spec_injection_cells(spec.read_text(encoding="utf-8"))
    # 좌변이 비면 우변이 무엇이든 한쪽 방향의 어긋남이 0 으로 난다. 검사 28 과 34 와 35 와 37 과
    # 38 과 40 과 42 가 같은 요구를 둔다.
    if not cells:
        r.bad(f"{COUNT_SPEC} 의 §2 에서 표의 행을 하나도 읽지 못했다")
        return r
    m = NC_CASES_LIST.search(nc.read_text(encoding="utf-8"))
    if m is None:
        r.bad(f"{NC_SOURCE} 에서 사례 목록 `CASES` 를 읽을 수 없다")
        return r
    cases = NC_CASE_ROW.findall(m.group(1))
    if not cases:
        r.bad(f"{NC_SOURCE} 의 사례 목록이 비어 있다")
        return r
    declared = unit_declarations(led.root)
    want = {num for num, cell in cells.items() if cell}
    got = {num for num, _step in cases}
    for num in sorted(want - got):
        r.bad(f"검사 {num} 의 주입 시험 칸이 섰는데 음성 대조의 사례 목록에 그 항이 없다")
    for num in sorted(got - want):
        r.bad(f"음성 대조가 검사 {num} 의 사례를 드는데 §2 의 그 행에 주입 시험 칸이 없다")
    # 사례 이름이 전사한 단계 id 를 그 검사의 선언과 맞댄다. 이름을 맞대지 않으면 그 전사가 낡아도
    # 걸리지 않고, 그 낡음은 사례 이름이 실재하지 않는 단계를 가리키는 꼴로만 남는다.
    for num, step in cases:
        if num not in declared:
            r.bad(f"음성 대조의 사례가 드는 검사 {num} 를 단위 전량의 어느 검사도 "
                  f"선언하지 않는다: " + " · ".join(WIKI_UNITS))
        elif declared[num] != step:
            r.bad(f"검사 {num} 의 사례가 전사한 단계 id `{step}` 가 그 검사의 선언 "
                  f"`{declared[num]}` 와 다르다")
    r.note(f"주입 시험 칸이 든 검사 {len(want)} · 사례 목록의 검사 {len(got)} · 사례 항 {len(cases)}")
    r.note(f"좌에서 우로 미포착 {len(want - got)} · 우에서 좌로 유령 {len(got - want)}")
    return r


# 검사 46 이 읽는 블록 목록과 그 블록을 읽는 쪽. **읽는 쪽이 여럿이고 그 정본이 `BLOCK_READERS`
# 다.** 공리 기준선의 블록을 읽는 쪽이 검증 스크립트이므로 유니버스를 검증기로만 두면 그 하나가
# 유령으로 나고, 검사가 갈래별 단위로 옮겨 간 뒤에는 단위를 빼면 거기서 읽히는 블록이 전량 유령으로
# 난다. **그 수를 이 산문이 들지 않는 까닭은** 읽는 쪽이 늘 때 그 수가 낡고 그 낡음을 어느 검사도
# 보지 않는다는 것이다. 이름을 대문자로 묶는 까닭은 같은 줄에 선 경로의 홑따옴표를 블록 이름으로 읽지 않는 것이다.
SPEC_BLOCK_SENTENCE = re.compile(r"지금 그런 블록은(.*?)이다")


SPEC_BLOCK_NAME = re.compile(r"`([A-Z][A-Z0-9]*)`")


BLOCK_READ_FORM = re.compile(r"<!--\s*([A-Z][A-Z0-9]*):BEGIN|([A-Z][A-Z0-9]*):BEGIN")


BLOCK_READERS = (COUNT_WIKI, COUNT_COMMON, COUNT_VERIFY) + WIKI_UNITS


def check_46(led: Ledger) -> Report:
    r = Report("46", "wiki46-block-list-mirror",
               "§5 가 드는 기계 판독 블록의 목록이 실제로 읽히는 블록과 양방향으로 맞는가", "fail")
    f = led.root / COUNT_SPEC
    if not f.is_file():
        r.bad(f"{COUNT_SPEC} 이 없다")
        return r
    m = SPEC_BLOCK_SENTENCE.search(f.read_text(encoding="utf-8"))
    if m is None:
        r.bad(f"{COUNT_SPEC} 에서 기계 판독 블록의 목록을 읽을 수 없다")
        return r
    listed = set(SPEC_BLOCK_NAME.findall(m.group(1)))
    if not listed:
        r.bad(f"{COUNT_SPEC} 의 기계 판독 블록 목록이 비어 있다")
        return r
    read: dict[str, list[str]] = {}
    for rel in BLOCK_READERS:
        g = led.root / rel
        if not g.is_file():
            r.bad(f"{rel} 이 없다")
            return r
        for x in BLOCK_READ_FORM.finditer(g.read_text(encoding="utf-8")):
            read.setdefault(x.group(1) or x.group(2), []).append(rel)
    for name in sorted(listed - set(read)):
        r.bad(f"목록이 드는 블록 `{name}` 를 읽는 자리가 "
              + " · ".join(BLOCK_READERS) + " 어디에도 없다")
    for name in sorted(set(read) - listed):
        r.bad(f"블록 `{name}` 를 {' · '.join(sorted(set(read[name])))} 가 읽는데 "
              f"§5 의 목록이 그것을 들지 않는다")
    r.note(f"목록이 든 블록 {len(listed)} · 읽히는 블록 {len(read)}")
    for name in sorted(read):
        r.note(f"{name} — {' · '.join(sorted(set(read[name])))}")
    return r


SPEC_FIELD_CHECK = "검사"


# 검사 번호의 꼴. 숫자와 그 뒤에 붙는 알파벳 한 자이며 가운뎃점으로 여럿을 잇는다.
SPEC_CHECK_NO = re.compile(r"^\d+(?:-[a-z])?$")


SPEC_CHECK_JOIN = "·"


def spec_field_rows(text: str) -> tuple[list[tuple[int, str, str, str, int]], list[str]]:
    """필드 표의 행마다 (줄 번호, 절 제목, 필드 칸, 검사 칸, 검사 열의 자리) 와 유니버스 밖의 표.

    검사 열을 들지 않는 필드 표는 유니버스 밖이며 그 사실을 보고에 낸다. 건너뛰면 그 표가
    유니버스에 든 것인지 검사 칸이 비어 있는 것인지가 보고에서 갈리지 않는다.
    """
    rows: list[tuple[int, str, str, str, int]] = []
    outside: list[str] = []
    lines = text.splitlines()
    sec = ""
    i = 0
    while i < len(lines):
        if lines[i].startswith("#"):
            sec = lines[i].strip()
        head = md_cells(lines[i])
        rule = md_cells(lines[i + 1]) if i + 1 < len(lines) else None
        if head and rule and all(SPEC_TABLE_RULE.match(c) for c in rule if c):
            if head[:1] == [SPEC_FIELD_HEAD]:
                if SPEC_FIELD_CHECK in head:
                    at = head.index(SPEC_FIELD_CHECK)
                    for j in range(i + 2, len(lines)):
                        body = md_cells(lines[j])
                        if body is None:
                            break
                        if at < len(body):
                            rows.append((j + 1, sec, body[0], body[at], at))
                else:
                    outside.append(f"{sec} 의 {lines[i].strip()}")
            i += 2
            continue
        i += 1
    return rows, outside


def check_47(led: Ledger) -> Report:
    r = Report("47", "wiki47-spec-field-check-no",
               "이 명세의 필드 표가 검사 칸에 든 번호가 실재하는 검사인가", "fail")
    spec = led.root / COUNT_SPEC
    for f in (spec, *(led.root / rel for rel in WIKI_UNITS)):
        if not f.is_file():
            r.bad(f"{f.name} 이 없다")
            return r
    rows, outside = spec_field_rows(spec.read_text(encoding="utf-8"))
    # 좌변이 비면 우변이 무엇이든 어긋남이 0 으로 난다. 검사 40 과 44 와 46 이 같은 요구를 둔다.
    if not rows:
        r.bad(f"{COUNT_SPEC} 에서 필드 표의 행을 하나도 읽지 못했다")
        return r
    # 실재의 정본은 선언이다. 뿌리의 소스에서 읽는 까닭은 음성 대조가 사본을 뿌리로 지목하므로
    # 돌고 있는 모듈을 세면 사본의 그 자리에 든 주입을 보지 못한다는 것이다. 검사 44 가 같은
    # 자리를 같은 꼴로 읽는다.
    declared = set(unit_declarations(led.root))
    if not declared:
        r.bad("단위 전량에서 검사의 선언을 하나도 읽지 못했다: "
              + " · ".join(WIKI_UNITS))
        return r
    cited: set[str] = set()
    filled = 0
    for line, _sec, field, cell, _at in rows:
        if not cell:
            continue
        filled += 1
        for tok in (x.strip() for x in cell.split(SPEC_CHECK_JOIN)):
            if not SPEC_CHECK_NO.match(tok):
                r.bad(f"{COUNT_SPEC}:{line} 의 {field} 의 검사 칸이 번호의 꼴이 아닌 "
                      f"`{tok}` 를 든다")
                continue
            cited.add(tok)
            if tok not in declared:
                r.bad(f"{COUNT_SPEC}:{line} 의 {field} 가 검사 {tok} 를 드는데 "
                      f"단위 전량의 어느 검사도 그 번호를 선언하지 않는다")
    r.note(f"필드 표의 행 {len(rows)} · 검사 칸이 선 행 {filled} · 그 칸이 든 번호 {len(cited)}")
    r.note(f"단위 전량이 선언한 검사 {len(declared)} · "
           f"유니버스 밖의 필드 표 {len(outside)}")
    for x in outside:
        r.note(f"유니버스 밖 — {x}")
    return r


# 검사 51 이 읽는 유니버스. 명세 §3 의 공통 필드 절과 레지스터 넷의 절이 그 자리이며, 엔트리 카드
# 절과 아크 값 정본 절은 원장 entry 의 키를 들지 않으므로 그 밖이다(SPEC §2.1).
#
# **절을 번호로 고르고 표는 머리의 첫 칸으로 고른다.** 그 절들에는 필드 표 말고도 `layer` 의 값과
# 재개 트리거의 `kind` 를 드는 표가 함께 서는데, 그 표의 첫 칼럼은 키가 아니라 값이다. 그것을
# 유니버스에 넣으면 값의 이름이 키로 들어와도 걸리지 않는다. 검사 칸을 요구하지 않는 까닭은
# 기각 레지스터의 필드 표가 그 칸을 들지 않는다는 것이며, 요구하면 그 레지스터의 키가 전부
# 유니버스 밖으로 읽힌다. 검사 47 이 같은 머리를 쓰되 그 칸을 요구하는 것과 여기서 갈린다.
LEDGER_KEY_SECTIONS = ("3.1", "3.2", "3.3", "3.4", "3.5")


LEDGER_KEY_SECTION_HEAD = re.compile(r"^(#+)\s+(\d+(?:\.\d+)*)\s")


# 필드 표의 첫 칼럼이 드는 이름의 꼴. 백틱으로 감싼 소문자와 밑줄이다.
LEDGER_KEY_NAME = re.compile(r"^`([a-z_]+)`$")


def ledger_key_universe(text: str) -> tuple[dict[str, set[str]], set[str], list[str]]:
    """명세 §3.1 부터 §3.5 까지의 필드 표에서 첫 칼럼의 이름을 절마다 뽑는다.

    (절 번호 → 이름 집합, 실재한 절 번호, 첫 칸이 이름의 꼴이 아닌 행) 을 돌려준다. 울타리 안의
    줄은 읽지 않는다. 공통 필드 절이 `origin` 의 내부를 울타리로 들므로 그 안을 표로 읽으면
    내부 키가 entry 의 키로 섞인다. 셋째 수준보다 깊은 제목은 절을 바꾸지 않는다.
    """
    names: dict[str, set[str]] = {s: set() for s in LEDGER_KEY_SECTIONS}
    seen: set[str] = set()
    odd: list[str] = []
    lines = text.splitlines()
    sec: str | None = None
    fenced = False
    i = 0
    while i < len(lines):
        ln = lines[i]
        if ln.startswith("```"):
            fenced = not fenced
            i += 1
            continue
        if fenced:
            i += 1
            continue
        h = re.match(r"^(#+)\s", ln)
        if h:
            if len(h.group(1)) <= 3:
                m = LEDGER_KEY_SECTION_HEAD.match(ln)
                sec = m.group(2) if m and len(m.group(1)) == 3 and m.group(2) in names else None
                if sec:
                    seen.add(sec)
            i += 1
            continue
        head = md_cells(ln) if sec else None
        rule = md_cells(lines[i + 1]) if head and i + 1 < len(lines) else None
        if head and rule and all(SPEC_TABLE_RULE.match(c) for c in rule if c) \
                and head[:1] == [SPEC_FIELD_HEAD]:
            j = i + 2
            while j < len(lines):
                body = md_cells(lines[j])
                if body is None:
                    break
                m = LEDGER_KEY_NAME.match(body[0]) if body else None
                if m:
                    names[sec].add(m.group(1))
                else:
                    odd.append(f"§{sec} 의 {j + 1} 행 첫 칸 `{body[0] if body else ''}`")
                j += 1
            i = j
            continue
        i += 1
    return names, seen, odd


def check_51(led: Ledger) -> Report:
    r = Report("51", "wiki51-ledger-key-universe",
               "원장 네 레지스터의 entry 가 드는 키가 이 명세의 §3.1 부터 §3.5 까지가 든 필드 표의 "
               "첫 칼럼에 전부 드는가", "fail")
    spec = led.root / COUNT_SPEC
    if not spec.is_file():
        r.bad(f"{COUNT_SPEC} 이 없다")
        return r
    names, seen, odd = ledger_key_universe(spec.read_text(encoding="utf-8"))
    # 유니버스를 읽지 못하면 통과가 아니라 실패다. 절 하나가 빠지면 그 레지스터의 키가 전부
    # 밖으로 읽히거나, 이름이 바뀐 절을 놓쳐 유니버스가 조용히 줄어든다. 검사 40 과 44 와 46 이
    # 같은 요구를 둔다.
    for s in LEDGER_KEY_SECTIONS:
        if s not in seen:
            r.bad(f"{COUNT_SPEC} 에 §{s} 의 절 제목이 없다")
        elif not names[s]:
            r.bad(f"{COUNT_SPEC} 의 §{s} 에서 필드 표의 이름을 하나도 읽지 못했다")
    universe: set[str] = set().union(*names.values())
    if not universe:
        return r
    # 좌변이 비면 적발이 0 으로 난다. 검사 47 이 같은 요구를 둔다.
    if not led.entries:
        r.bad("원장 네 레지스터에서 entry 를 하나도 읽지 못했다")
        return r
    keys: set[str] = set()
    hits = 0
    for reg in REGISTERS:
        for e in led.reg[reg]:
            for k in e:
                keys.add(k)
                if k not in universe:
                    hits += 1
                    r.bad(f"{reg} 의 {e.get('id')} 가 유니버스 밖의 키 `{k}` 를 든다")
    r.note("유니버스 " + " · ".join(f"§{s} {len(names[s])}" for s in LEDGER_KEY_SECTIONS)
           + f" · 합집합 {len(universe)}")
    r.note(f"원장 entry {len(led.entries)} · 그 entry 가 든 키 {len(keys)} · 유니버스 밖의 키 적발 {hits}")
    for x in odd:
        r.note(f"첫 칸이 이름의 꼴이 아니어서 유니버스에 넣지 않은 행 — {x}")
    return r


# 이 단위가 드는 검사. 러너가 이 목록을 이어 붙여 손 열거를 걷는다.
CHECKS = (
    check_40,
    check_44,
    check_46,
    check_47,
    check_51,
)
