"""형식층 갈래 검사의 음성 대조 주입.

`scripts/wiki_formal.py` 가 든 검사의 주입 함수와 그 사례 목록을 든다. 주입이 어느 단위에
사는지는 그 주입이 겨눈 검사가 사는 단위에서 유도한다.
"""

from __future__ import annotations

import re
from pathlib import Path
import wiki_common
import wiki_formal
from wiki_nc_common import _fixed_cq, edit, ko_word, load, pick, save


def id_no(cf) -> int:
    """`CF-<n>` 의 번호. 형식이 아니면 -1 이다.

    검사 10 이 지목한 항목과 폐기 레코드의 번호로 가르므로, 그 검사를 겨누는 주입이 같은 가름을
    쓰려면 여기서도 번호를 읽어야 한다."""
    m = re.match(r"CF-(\d+)$", str(cf or ""))
    return int(m.group(1)) if m else -1


def inj_10(root):
    """폐기된 id 를 폐기 뒤에 선 항목의 `related` 에 넣는다.

    **지목하는 항목을 박지 않고 유도한다.** 이 주입은 그 항목을 `CF-24` 로 박아 두었는데, 검사
    10 이 폐기 레코드보다 번호가 앞선 항목의 지목을 실패가 아니라 보고로 돌리므로 그 지목은
    구조적으로 실패가 될 수 없다. `collateral-5` 가 받은 판에서 이미 죽어 있었고, 그래서 검사
    10 이 음성 대조를 받지 않는 상태로 여러 회차를 지났다.

    그래서 번호가 가장 작은 폐기 레코드를 고르고, 그 번호보다 큰 살아 있는 결정 항목 가운데
    번호가 가장 큰 것이 그 폐기 대상을 들게 한다. 원장이 자라면 고르는 항목이 함께 뒤로 가므로
    유도가 스스로 유지된다. `related` 는 덮지 않고 덧붙인다. 덮으면 그 항목이 원래 들고 있던
    지목이 사라져 같은 사본에서 다른 검사가 함께 흔들린다."""
    rets = load(root, "retirements")["retirements"]
    first = min(rets, key=lambda q: id_no(q.get("id")))
    dead = first["target"]
    retired = {q["target"] for q in rets if q.get("target")}
    live = [e for e in load(root, "decisions")["decisions"]
            if id_no(e.get("id")) > id_no(first.get("id")) and e.get("id") not in retired]
    if not live:
        raise SystemExit("폐기 레코드보다 뒤에 선 살아 있는 결정 항목이 없어 주입 대상이 없다")
    tgt = max(live, key=lambda e: id_no(e.get("id")))
    related = list(tgt.get("related") or [])
    if dead in related or first.get("id") in related:
        raise SystemExit(f"{tgt['id']} 가 이미 {dead} 나 {first['id']} 를 들어 주입이 조건을 만들지 못한다")
    edit(root, "decisions", tgt["id"],
         lambda e: e.__setitem__("related", list(e.get("related") or []) + [dead]))
    return tgt["id"]


def inj_13(root):
    """없는 id 를 **줄 주석**에 적는다.

    검사 13 의 유니버스가 줄 주석으로 좁혀졌으므로 주입도 줄 주석이어야 걸린다. 블록 주석에
    같은 줄을 적으면 잡히지 않는 것이 좁힘의 뜻이다(SPEC §2.1)."""
    f = root / "CrisisFramework" / "Glossary" / "Core.lean"
    f.write_text(f.read_text(encoding="utf-8") + "\n-- DD:CF-9999\n", encoding="utf-8")


def inj_14(root):
    d = pick(root, "decisions", lambda e: e.get("layer") == "definition")
    f = root / "CrisisFramework" / "Accounting" / "Aggregation.lean"
    f.write_text(f.read_text(encoding="utf-8") + f"\n-- DD:{d['id']}\n", encoding="utf-8")


def inj_24_missing(root):
    """상주 문서에 없는 규율 ID 를 적는다. 미실재는 선언으로 면제되지 않는다.

    토큰은 검사 23·24 의 계열에 들면서 어느 항목의 `names` 에도 없는 것이어야 한다. 계열 밖의
    글자를 쓰면 애초에 규율 ID 로 읽히지 않아 주입이 조건을 만들지 못한다."""
    f = root / "CLAUDE.md"
    f.write_text(f.read_text(encoding="utf-8")
                 + "\n음성 대조가 주입한 줄이며 Q-99 를 든다.\n", encoding="utf-8")


def inj_24_retired(root):
    """선언되지 않은 폐기 규율을 적는다. CLAUDE.md 는 폐기 지목 선언을 두지 않는다."""
    dead_id = load(root, "retirements")["retirements"][0]["target"]
    tok = None
    for reg in ("decisions", "deferred"):
        for e in load(root, reg)[reg]:
            if e["id"] == dead_id and e.get("names"):
                tok = e["names"][0]
    if not tok:
        raise SystemExit("폐기된 항목이 규율 ID 를 들지 않아 주입 대상이 없다")
    f = root / "CLAUDE.md"
    f.write_text(f.read_text(encoding="utf-8")
                 + f"\n음성 대조가 주입한 줄이며 {tok} 을 근거로 든다.\n", encoding="utf-8")
    return tok


def inj_25(root):
    """최상위 선언 하나의 표지를 지운다."""
    f = root / "CrisisFramework" / "Glossary" / "Core.lean"
    lines = f.read_text(encoding="utf-8").split("\n")
    for i, ln in enumerate(lines):
        if ln.strip().startswith("-- DD:"):
            del lines[i]
            break
    else:
        raise SystemExit("지울 표지가 없다")
    f.write_text("\n".join(lines), encoding="utf-8")


def _boundary_decls(root: Path):
    """경계 안 선언. **검증기의 수집기를 그대로 불러 쓰고 전사하지 않는다.**

    경계와 머리말 표를 여기서 다시 읽으면 한쪽을 고칠 때 다른 쪽이 조용히 낡고, 주입이
    경계 밖을 겨누게 되어도 그것을 어느 검사도 잡지 않는다."""
    led = wiki_common.Ledger(root)
    since, forms = wiki_common.heading_rules(led)
    inside = [] if since is None else [d for d in led.doc_decls() if d.no >= since]
    return inside, forms


def _append_para(root: Path, d, para: str) -> None:
    """그 선언의 docstring 말미에 문단 하나를 더한다.

    선언 줄보다 앞에 선 마지막 `/-- -/` 블록이 그 선언의 docstring 이라는 것은 검증기의
    수집기가 쓰는 규칙과 같다. 그 규칙을 전사하지 않으려고 같은 정규식을 불러 쓴다."""
    f = root / d.rel
    text = f.read_text(encoding="utf-8")
    cut = sum(len(x) for x in text.splitlines(keepends=True)[:d.line - 1])
    blocks = [m for m in wiki_common.DOC_BLOCK.finditer(text) if m.end() <= cut]
    if not blocks:
        raise SystemExit(f"{d.full} 의 docstring 블록을 찾지 못했다")
    end = blocks[-1].end() - 2            # 닫는 `-/` 앞
    f.write_text(text[:end] + f"\n{para}\n" + text[end:], encoding="utf-8")


def _inj_33_para(root, para: str) -> str:
    """경계 안 선언 가운데 그 낱말을 들지 않는 것 하나의 docstring 에 문단을 더한다.

    기각 레지스터가 그 선언을 `for_decl` 로 들지 않는 것이 주입의 조건이다. 이미 드는 선언을
    고르면 좌변에 들어도 미포착이 서지 않아 주입이 조건을 만들지 못한다."""
    inside, _forms = _boundary_decls(root)
    claimed = {str(e.get("for_decl")) for e in load(root, "rejected")["rejected"]
               if e.get("for_decl")}
    word = wiki_formal.REJECTION_WORD
    for d in inside:
        if d.full in claimed or any(word in p for p in d.paras):
            continue
        _append_para(root, d, para)
        return d.full
    raise SystemExit("경계 안에 주입할 선언이 없다")


def inj_33_heading(root):
    """경계 안 선언의 문단에 **머리말로** 그 예약 낱말을 두고 기각 레지스터에 대응 항목을
    두지 않는다. 좌에서 우로가 실패해야 한다.

    머리말을 `HEADING` 블록의 형 그대로 두어 검사 34 가 함께 걸리지 않게 한다. 걸리면 어느
    검사가 주입을 잡았는지가 갈리지 않는다."""
    return _inj_33_para(root, f"**{wiki_formal.REJECTION_WORD}:** 음성 대조가 주입한 문단이다.")


def inj_33_body(root):
    """경계 안 선언의 문단에 **본문으로만** 그 낱말을 둔다. 잡히지 않아야 한다.

    그 방향을 재지 않으면 「머리말로 좁혔다」와 「여전히 본문을 본다」가 갈리지 않는다."""
    return _inj_33_para(
        root,
        f"**음성 대조가 주입한 문단이다.** 본문에서만 {wiki_formal.REJECTION_WORD} 를 든다.")


def inj_33_right(root):
    """`for_decl` 값을 없는 선언 이름으로 바꾼다. 우에서 좌로가 실패한다."""
    doc = load(root, "rejected")
    e = next((x for x in doc["rejected"] if x.get("for_decl")), None)
    if e is None:
        raise SystemExit("for_decl 을 든 기각 항목이 없어 주입 대상이 없다")
    e["for_decl"] = "CrisisFramework.Definition.NoSuchDeclaration"
    save(root, "rejected", doc)
    return e["for_decl"]


def inj_34_period(root):
    """경계 안 머리말의 마침표를 지운다. 그 머리말이 형과 달라져 실패한다.

    예약 낱말을 들고 마침표로 닫는 머리말만 고른다. 자유 머리말은 형에 걸리지 않으므로
    마침표를 지워도 통과하고, 그러면 주입이 조건을 만들지 못한다."""
    inside, forms = _boundary_decls(root)
    for d in inside:
        f = root / d.rel
        text = f.read_text(encoding="utf-8")
        for p in d.paras:
            head = wiki_common.para_heading(p)
            if not head or not head.endswith(".") or not any(w in head for w in forms):
                continue
            old = f"**{head}**"
            if old not in text:
                continue          # 두 줄에 걸친 머리말은 원문에 그 꼴로 서지 않는다
            f.write_text(text.replace(old, f"**{head[:-1]}**", 1), encoding="utf-8")
            return head
    raise SystemExit("마침표로 닫는 예약 머리말이 경계 안에 없다")


def inj_34_empty(root):
    """`HEADING` 블록을 비운다. 비어 있으면 통과가 아니라 실패다."""
    f = root / "docs" / "baseline.md"
    text = f.read_text(encoding="utf-8")
    new = re.sub(r"<!-- HEADING:BEGIN -->\n.*?<!-- HEADING:END -->",
                 "<!-- HEADING:BEGIN -->\n<!-- HEADING:END -->",
                 text, count=1, flags=re.S)
    if new == text:
        raise SystemExit("HEADING 블록을 찾지 못했다")
    f.write_text(new, encoding="utf-8")


def _excl_block(root: Path) -> list[str]:
    """사본의 `EXCL` 블록이 든 분할 이름. 주입 셋이 유니버스를 이것으로 읽는다."""
    text = (root / "docs" / "baseline.md").read_text(encoding="utf-8")
    m = wiki_formal.EXCL_BLOCK.search(text)
    if m is None:
        raise SystemExit("EXCL 블록을 찾지 못했다")
    return [x.group(1) for x in
            map(wiki_formal.EXCL_LINE.match, m.group(1).splitlines()) if x]


def _excl_paras(root: Path):
    """사본의 등록 관계 선언과 그 배타성 문단.

    문단마다 (문면, 모든 쌍이 배타적이라 적었는가) 를 든다. 그 판별을 검증기의 함수로 하므로
    주입과 판정이 같은 것을 읽는다. 전사하면 한쪽을 고칠 때 다른 쪽이 조용히 낡는다.
    """
    led = wiki_common.Ledger(root)
    forms = wiki_common.heading_rules(led)[1].get(wiki_formal.EXCLUSIVITY_WORD, [])
    got = wiki_formal.excl_registry(led)
    if got is None:
        raise SystemExit("등록 관계를 드는 선언이 없어 주입 대상이 없다")
    decl, parts, excl = got
    paras = []
    for p in decl.paras:
        head = wiki_common.para_heading(p)
        if head is None:
            continue
        for f in forms:
            if wiki_formal.heading_fill(f, head) is not None:
                paras.append((p, wiki_formal.EXCL_ALL_MARK in f))
                break
    return led, decl, parts, excl, paras


def inj_38_para(root):
    """`EXCL` 블록의 분할에서 배타성 문단을 지운다. 그 분할의 문단이 없으면 실패해야 한다."""
    _led, decl, _parts, _excl, paras = _excl_paras(root)
    if not paras:
        raise SystemExit("배타성 문단이 없어 주입 대상이 없다")
    para = paras[0][0]
    f = root / decl.rel
    text = f.read_text(encoding="utf-8")
    if text.count(para + "\n\n") != 1:
        raise SystemExit("배타성 문단의 문면을 파일에서 한 번으로 찾지 못했다")
    f.write_text(text.replace(para + "\n\n", "", 1), encoding="utf-8")
    return wiki_common.para_heading(para)


def inj_38_pair(root):
    """모든 쌍이 배타적이라 적은 분할의 배타 관계 한 쌍을 지운다.

    문단은 그대로 두고 관계만 지운다. 그 방향을 재지 않으면 「문단과 관계를 함께 본다」와
    「문단만 본다」가 갈리지 않는다.
    """
    led, decl, parts, _excl, paras = _excl_paras(root)
    labels = wiki_formal.concept_labels(led, decl.rel)
    forms = wiki_common.heading_rules(led)[1][wiki_formal.EXCLUSIVITY_WORD]
    all_form = next(f for f in forms if wiki_formal.EXCL_ALL_MARK in f)
    target = None
    for name in _excl_block(root):
        label = labels.get(name)
        cells = parts.get(name) or []
        if not label or len(cells) < 2:
            continue
        for para, is_all in paras:
            fill = wiki_formal.heading_fill(all_form, wiki_common.para_heading(para) or "")
            if is_all and fill is not None and fill.startswith(label):
                target = (name, cells[0], cells[1])
                break
        if target:
            break
    if target is None:
        raise SystemExit("모든 쌍이 배타적이라 적은 분할이 없어 주입 대상이 없다")
    name, a, b = target
    f = root / decl.rel
    lines = f.read_text(encoding="utf-8").splitlines()
    want = {frozenset((a, b))}
    for i, ln in enumerate(lines):
        m = wiki_formal.EXCLUDES_ROW.search(ln)
        if m and frozenset(m.groups()) in want:
            del lines[i]
            f.write_text("\n".join(lines) + "\n", encoding="utf-8")
            return f"{name}: {a} 와 {b}"
    raise SystemExit(f"`{a}` 와 `{b}` 의 배타 관계 줄을 찾지 못했다")


def inj_38_empty(root):
    """`EXCL` 블록을 비운다. 비어 있으면 통과가 아니라 실패다.

    이 항이 없으면 블록이 비었을 때 통과시키는 구현이 음성 대조를 통과한다. 검사 34 의 같은
    항이 그 사유로 이미 서 있다.
    """
    f = root / "docs" / "baseline.md"
    text = f.read_text(encoding="utf-8")
    new = re.sub(r"<!-- EXCL:BEGIN -->\n.*?<!-- EXCL:END -->",
                 "<!-- EXCL:BEGIN -->\n<!-- EXCL:END -->",
                 text, count=1, flags=re.S)
    if new == text:
        raise SystemExit("EXCL 블록을 찾지 못했다")
    f.write_text(new, encoding="utf-8")


# 검사 48 의 주입이 세우는 사본의 파일. **주입이 제 대상을 세운다.** 경계 안 표지를 가진 선언이
# 받은 판에 아직 없으므로 기존 선언을 굽히는 꼴로는 이 주입이 서지 않으며, 경계가 뒤 회차에
# 올라가도 같은 사유로 공허해지지 않는다. 자리를 정의층에 두는 까닭은 그 검사의 유니버스가
# 형식층 docstring 이라는 것이다.
NC48_FILE = ("CrisisFramework", "Definition", "NcSourcingProbe.lean")


NC48_DECL = "ncSourcingProbe"


# 실재하지 않는 절 번호. 추출 기록의 절이 두 자리를 넘지 않으므로 이 꼴이 어느 기록에도 없다.
NC48_GHOST_SECTION = "99-99"


def _nc48_material(root):
    """사본에서 조달처 줄이 설 재료를 고른다.

    (기록 번호, 절 번호, 그 절에 있는 구절, 그 기록의 다른 절에 있는 구절) 을 낸다. **재료를
    검증기의 수집기로 고른다.** 꼴을 전사하면 그 검사가 꼴을 고칠 때 이 주입이 조용히
    공허해지고, 번호를 박으면 기록이 늘거나 절이 덧붙을 때 다른 자리를 겨누게 된다.
    """
    led = wiki_common.Ledger(root)
    _since, minlen = wiki_formal.sourcing_rules(led)
    if minlen is None:
        raise SystemExit("사본의 SOURCING 블록에서 구절의 최소 길이를 읽지 못했다")
    want = minlen + 8          # 짧게 줄이는 주입이 하한 아래로 내려갈 여유를 둔다
    d = root / "docs" / "extractions"
    for f in sorted(d.glob("extraction-*.md")):
        m = wiki_common.EXTRACTION_FILE_NO.match(f.name)
        if m is None:
            continue
        secs = wiki_formal.extraction_sections(f)
        picked = []
        for no in sorted(secs):
            body = wiki_formal.fold(secs[no])
            # 낫표와 Lean 의 주석 표지를 담은 구절은 쓰지 않는다. 앞은 조달처 줄의 울타리를
            # 닫아 버리고 뒤는 docstring 을 닫아 버린다.
            if any(x in body for x in ("「", "」", "-/", "/-")):
                continue
            if len(body) >= want:
                picked.append((no, body[:want]))
            if len(picked) == 2:
                break
        if len(picked) < 2:
            continue
        (no_a, phrase), (_no_b, other) = picked
        if other in wiki_formal.fold(secs[no_a]):
            continue           # 다른 절의 구절이 그 절에도 있으면 그 주입이 공허해진다
        return int(m.group(1)), no_a, phrase, other
    raise SystemExit("조달처 줄의 재료가 될 절 둘을 가진 추출 기록이 없다")


def _nc48_plant(root, bend):
    """경계 안 표지를 가진 선언을 사본에 세우고 그 조달처 줄을 굽힌다.

    굽히지 않은 꼴은 그 검사를 통과하므로, 굽힌 자리 하나만이 새 위반 줄을 낸다.
    """
    led = wiki_common.Ledger(root)
    since, minlen = wiki_formal.sourcing_rules(led)
    if since is None:
        raise SystemExit("사본의 SOURCING 블록에서 경계를 읽지 못했다")
    rec, sec, phrase, other = _nc48_material(root)
    if bend == "phrase":
        src = f"조달처: E-{rec:02d} §{sec} 「{other}」"
    elif bend == "section":
        src = f"조달처: E-{rec:02d} §{NC48_GHOST_SECTION} 「{phrase}」"
    elif bend == "short":
        src = f"조달처: E-{rec:02d} §{sec} 「{phrase[:minlen - 1]}」"
    elif bend == "drop":
        src = ""
    else:
        raise SystemExit(f"굽히는 꼴을 알 수 없다: {bend!r}")
    para = ["**이 정의가 배제하는 사례:**",
            "음성 대조가 세운 사본 안의 사례이며 리포의 어느 판에도 들어가지 않는다."]
    if src:
        para.append(src)
    f = root.joinpath(*NC48_FILE)
    f.write_text(
        "/-\n정의층 — 음성 대조의 조달처 프로브\n\n"
        "이 파일은 음성 대조가 사본에만 세우는 것이며 리포의 어느 판에도 들어가지 않는다.\n-/\n\n"
        "namespace CrisisFramework.Definition\n\n"
        "/--\n음성 대조가 세운 선언.\n\n"
        "**대응 비형식 개념:** 없다.\n\n"
        + "\n".join(para) + "\n\n"
        "**기각한 대체 정의:**\n기각한 것이 없다.\n\n"
        "**수 체계를 받지 않는다.**\n-/\n"
        f"-- DD:CF-{since}\n"
        f"def {NC48_DECL} : Bool := true\n\n"
        "end CrisisFramework.Definition\n", encoding="utf-8")
    return f"CrisisFramework.Definition.{NC48_DECL}: E-{rec:02d} §{sec}"


def inj_48_phrase(root):
    """조달처 줄의 구절을 그 기록의 다른 절에 있는 구절로 바꾼다."""
    return _nc48_plant(root, "phrase")


def inj_48_drop(root):
    """경계 안 선언의 조달처 줄을 지운다."""
    return _nc48_plant(root, "drop")


def inj_48_section(root):
    """지목의 절 번호를 실재하지 않는 것으로 바꾼다."""
    return _nc48_plant(root, "section")


def inj_48_short(root):
    """구절을 최소 길이 아래로 줄인다."""
    return _nc48_plant(root, "short")


def inj_57_numeral(root):
    """그 머리 블록에 항의 수를 수사로 적는다.

    수는 고정 절의 줄 수에서 얻고 관형형으로 적는다. 관형형을 받는 꼴이 이 검사의 고유한 자리이므로,
    기수형으로만 주입하면 그 꼴이 빠져도 이 주입이 통과한다. 수사의 두 표는 검증기에서 가져온다.
    """
    f = root / wiki_formal.CQ_FIXED_FILE
    text = f.read_text(encoding="utf-8")
    m = wiki_formal.CQ_HEAD_BLOCK.match(text)
    if m is None:
        raise SystemExit(f"{wiki_formal.CQ_FIXED_FILE} 의 머리 블록을 찾지 못해 주입할 자리가 없다")
    word = ko_word(len(_fixed_cq(root)))
    for card, attr in wiki_formal.CQ_KO_ATTRIBUTIVE.items():
        if word.endswith(card):
            word = word[:-len(card)] + attr
            break
    sentence = f"이 파일은 {word} 물음을 든다."
    f.write_text(text[:m.end(1)] + sentence + "\n" + text[m.end(1):], encoding="utf-8")
    return sentence


def _inj_60_target(root):
    """회계층 파일 가운데 이름공간을 닫는 줄이 한 번 서는 첫 파일과 그 줄."""
    anchor = "\nend CrisisFramework.Accounting\n"
    for f in sorted((root / wiki_formal.CURRENCY_GUARD_DIR).glob("*.lean")):
        src = f.read_text(encoding="utf-8")
        if src.count(anchor) == 1:
            return f, src, anchor
    raise SystemExit("이름공간을 닫는 줄이 한 번 서는 회계층 파일이 없어 주입할 자리가 없다")


def _inj_60_put(root, name, binders, args):
    f, src, anchor = _inj_60_target(root)
    decl = (f"\ndef {name} {{ι Party Obs Ext Lvl Currency : Type}}{binders}\n"
            f"    (e : Env ℤ Obs Ext Lvl){args} (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) : ℤ :=\n"
            f"  ∑ i ∈ S.index, evalTerm e (S.assign i).amount\n")
    # 주입한 합의 항이 금액을 평가하고 표시 통화 판정을 들지 않음을 넣기 전에 단언한다. 그 둘이
    # 서지 않으면 이 주입이 겨눈 자리가 서지 않는다.
    terms = [t for t in wiki_formal.sum_terms(decl) if wiki_formal.CURRENCY_GUARD_AMOUNT.search(t)]
    if len(terms) != 1 or wiki_formal.CURRENCY_GUARD_CUR.search(terms[0]):
        raise SystemExit("주입할 선언의 합의 항이 겨눈 꼴이 아니다")
    f.write_text(src.replace(anchor, decl + anchor), encoding="utf-8")
    return name


def inj_60_unguarded(root):
    """가드 없는 합을 하나 더한다. 통화를 받지 않고 금액을 그대로 더하는 선언이다."""
    return _inj_60_put(root, "injectedUnguardedTotal", "", "")


def inj_60_binder_only(root):
    """타입클래스 바인더와 통화 인자만 더하고 합의 항은 그대로 둔 선언을 주입한다.

    가드를 선언 본문 전량에서 찾는 꼴이면 바인더의 결정 가능 등식이나 통화 인자를 가드로 읽어 이
    주입을 놓친다. 그 거짓 음성을 재는 항이며, 바인더와 인자가 주입한 문면에 실제로 서는지를 넣기
    전에 단언한다.
    """
    binders = " [DecidableEq Currency]"
    args = " (c : Currency)"
    name = _inj_60_put(root, "injectedBinderOnlyTotal", binders, args)
    f, src, _anchor = _inj_60_target(root)
    if binders.strip() not in src or args.strip() not in src:
        raise SystemExit("주입한 선언에 바인더와 통화 인자가 서지 않는다")
    return name


# 이 단위가 거느리는 음성 대조의 사례. 하네스가 단위 순서로 이 목록을 이어
# 붙이며 사례의 손 열거를 들지 않는다. **선언으로 두는 까닭은** 이 목록을 읽는
# 검사가 뿌리의 소스를 텍스트로 읽으므로 모듈의 값을 모으는 꼴이면 그 검사가
# 읽을 문면이 없다는 것이다.
CASES = [
    ("10", "wiki10-ghost-ref", "폐기된 id 를 related 에 넣는다", inj_10, None),
    ("13", "wiki13-dd-target", "없는 id 를 줄 주석에 적는다", inj_13, None),
    ("14", "wiki14-dd-layer", "회계층 파일에서 정의층 항목을 지목한다", inj_14, None),
    ("24", "wiki24-doc-rule-ghost", "상주 문서에 없는 규율 ID 를 적는다", inj_24_missing, None),
    ("24", "wiki24-doc-rule-ghost", "선언되지 않은 폐기 규율을 적는다", inj_24_retired, None),
    ("25", "wiki25-marker-missing", "최상위 선언 하나의 표지를 지운다", inj_25, None),
    ("33", "wiki33-rejection-registered", "경계 안 문단의 머리말에 그 예약 낱말을 둔다", inj_33_heading, None),
    ("33", "wiki33-rejection-registered", "경계 안 문단의 본문에만 그 낱말을 둔다", inj_33_body, None, "nocatch"),
    ("33", "wiki33-rejection-registered", "for_decl 값을 없는 선언 이름으로 바꾼다", inj_33_right, None),
    ("34", "wiki34-heading-form", "경계 안 머리말의 마침표를 지운다", inj_34_period, None),
    ("34", "wiki34-heading-form", "HEADING 블록을 비운다", inj_34_empty, None),
    ("38", "wiki38-partition-exclusivity", "EXCL 블록의 분할에서 배타성 문단을 지운다", inj_38_para, None),
    ("38", "wiki38-partition-exclusivity", "모든 쌍이 배타적이라 적은 분할의 배타 관계 한 쌍을 지운다", inj_38_pair, None),
    ("38", "wiki38-partition-exclusivity", "EXCL 블록을 비운다", inj_38_empty, None),
    ("48", "wiki48-extraction-sourcing", "조달처 줄의 구절을 그 기록의 다른 절에 있는 구절로 바꾼다", inj_48_phrase, None),
    ("48", "wiki48-extraction-sourcing", "경계 안 선언의 조달처 줄을 지운다", inj_48_drop, None),
    ("48", "wiki48-extraction-sourcing", "지목의 절 번호를 실재하지 않는 것으로 바꾼다", inj_48_section, None),
    ("48", "wiki48-extraction-sourcing", "구절을 최소 길이 아래로 줄인다", inj_48_short, None),
    ("57", "wiki57-cq-count-numeral", "그 머리 블록에 항의 수를 수사로 적는다", inj_57_numeral, None),
    ("60", "wiki60-currency-guard", "가드 없는 합을 하나 더한다", inj_60_unguarded, None),
    ("60", "wiki60-currency-guard", "타입클래스 바인더와 통화 인자만 더한 선언을 주입한다", inj_60_binder_only, None),
]
