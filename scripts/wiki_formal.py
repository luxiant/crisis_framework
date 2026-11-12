# -*- coding: utf-8 -*-
"""원장 검증기의 검사 가운데 형식층의 Lean 선언과 그 문서화 문면을 유니버스로 드는 검사.

이 단위가 자기 검사의 목록을 `CHECKS` 로 선언하고 러너가 그 목록을 이어 붙인다.
검사의 번호와 단계 id 는 그 선언이 들고 이 파일이 그 계수를 들지 않는다.
"""
from __future__ import annotations

import re
from pathlib import Path

from wiki_common import (
    COUNT_KO_TENS,
    COUNT_KO_UNIT,
    DocDecl,
    HISTORY_PATHS,
    ID_FORM,
    Ledger,
    NAMESPACE_END,
    RESIDENT_DOCS,
    RULE_TOKEN,
    Report,
    TOP_DECL,
    _baseline_block,
    _lean_code,
    doc_pointers,
    extraction_record,
    heading_matches,
    heading_rules,
    para_heading,
)

# 검사 14 의 대응표. SPEC §3.2 가 든다. `meta` 는 층에 갇히지 않으므로 건너뛴다.
LAYER_DIR = {
    "glossary": "CrisisFramework/Glossary",
    "definition": "CrisisFramework/Definition",
    "accounting": "CrisisFramework/Accounting",
    "dynamics": "CrisisFramework/Dynamics",
    "observation": "CrisisFramework/Observation",
}


# 폐기 지목의 면제 선언. 문서 머리에 이 형으로 한 줄을 두고 면제되는 ID 를 열거한다.
DECLARE_LINE = re.compile(r"^\s*\*\*폐기 지목:\*\*(.*)$")


CF_TOKEN = re.compile(r"(?<![0-9A-Za-z-])CF-(\d+)(?![0-9A-Za-z-])")


def check_10(led: Ledger) -> Report:
    r = Report("10", "wiki10-ghost-ref", "폐기된 id 를 살아 있는 것처럼 참조하는 자리가 있는가", "fail")
    dead = led.dead
    early: list[str] = []
    early_owners: list[str] = []

    def id_no(cf) -> int:
        """`CF-<n>` 의 번호. 형식이 아니면 -1 이라 가름에 쓰이지 않는다."""
        m = ID_FORM.match(str(cf or ""))
        return int(m.group(1)) if m else -1

    def judge(e: dict, ref: str, msg: str) -> None:
        """원장 안의 지목 하나를 가른다. 폐기 전이면 보고하고, 폐기 뒤면 승인하거나 실패시킨다."""
        retirer = led.retired_by.get(ref)
        if retirer is not None and id_no(e.get("id")) < id_no(retirer):
            early.append(msg)
            if e.get("id") not in early_owners:
                early_owners.append(e.get("id"))
            return
        if retirer is not None and retirer in (e.get("related") or []):
            return
        r.bad(msg)

    # 폐기 전에 쓰인 지목은 그 시점에 산 대상을 가리킨 역사이므로 실패가 아니라 보고다. ID 가 단조
    # 증가하므로 지목한 항목이 폐기 레코드보다 앞서는지로 가른다. 폐기 뒤에 쓰인 지목만 그 폐기
    # 레코드를 related 에 들 때 승인한다(SPEC §2.1, CF-661).
    # 원장 안. 폐기 레코드 자신의 target 과 original 은 제외한다(SPEC §2.1).
    for name, e in led.entries:
        # 그 자신이 폐기된 항목은 보지 않는다. 폐기된 항목의 지목을 고치는 길이 없고, 그 문면도
        # 폐기 시점의 앎을 담은 역사이기 때문이다.
        if e.get("id") in dead:
            continue
        for ref in e.get("related", []) or []:
            if ref in dead:
                judge(e, ref, f"{e.get('id')}: related 가 폐기된 {ref} 를 든다")
        rw = e.get("reopen_when")
        if isinstance(rw, dict) and rw.get("ref") in dead:
            judge(e, rw.get("ref"),
                  f"{e.get('id')}: reopen_when.ref 가 폐기된 {rw.get('ref')} 를 든다")
        if name == "retirements":
            continue
        for f in ("statement", "basis", "reason", "candidate", "for"):
            for m in CF_TOKEN.finditer(str(e.get(f) or "")):
                if m.group(0) in dead:
                    judge(e, m.group(0),
                          f"{e.get('id')}: {f} 가 폐기된 {m.group(0)} 를 든다")
    # Lean 의 DD: 표지. 이 자리는 고칠 수 있으므로 폐기와 함께 고치며 가름을 받지 않는다.
    for f, ln, ref in led.dd_markers():
        if ref in dead:
            r.bad(f"{f.relative_to(led.root)}:{ln}: DD: 표지가 폐기된 {ref} 를 가리킨다")
    # docs/ 산문. 역사 기록은 유니버스 밖이다. 그 문면은 그 시점의 앎을 담으므로 낡은 지목이
    # 정당하고 소급해 고치지 않는다. 검사 24 가 쓰는 `HISTORY_PATHS` 를 같이 쓴다(SPEC §2.1).
    for f in led.doc_files:
        rel = str(f.relative_to(led.root))
        if any(rel.startswith(h) for h in HISTORY_PATHS):
            continue
        for i, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
            for m in CF_TOKEN.finditer(line):
                if m.group(0) in dead:
                    r.bad(f"{f.relative_to(led.root)}:{i}: 산문이 폐기된 {m.group(0)} 를 든다")
    r.note(f"폐기된 id {len(dead)}건을 유니버스로 훑었다. 유니버스 밖: {list(HISTORY_PATHS)}")
    r.note(f"폐기 전에 쓰인 지목 {len(early)}건 · 그것을 든 항목 {len(early_owners)}개")
    # 보고 줄과 실패 줄을 줄 머리(`-` 와 `·`)로만 가르면 받는 쪽이 눈으로 가르게 된다. 각 줄이
    # 스스로 「폐기 전에 쓰인 지목」임을 들어 문면으로도 갈리게 한다(CF-683).
    for msg in early:
        r.note(f"폐기 전에 쓰인 지목 — {msg}")
    return r


def check_13(led: Ledger) -> Report:
    r = Report("13", "wiki13-dd-target",
               "Lean 줄 주석의 DD: 표지가 실재하고 폐기되지 않은 id 를 가리키는가", "fail")
    marks = led.dd_markers()
    r.note(f"DD: 표지 {len(marks)}개")
    for f, ln, ref in marks:
        if not ID_FORM.match(ref):
            r.bad(f"{f.relative_to(led.root)}:{ln}: 표지 `{ref}` 가 CF-<n> 형식이 아니다")
        elif ref not in led.by_id:
            r.bad(f"{f.relative_to(led.root)}:{ln}: 표지가 없는 항목 {ref} 를 가리킨다")
        elif ref in led.dead:
            r.bad(f"{f.relative_to(led.root)}:{ln}: 표지가 폐기된 {ref} 를 가리킨다")
    return r


def check_14(led: Ledger) -> Report:
    r = Report("14", "wiki14-dd-layer", "DD: 항목의 layer 가 그 파일이 사는 층과 같은가", "fail")
    n = 0
    for f, ln, ref in led.dd_markers():
        e = led.by_id.get(ref)
        if e is None:
            continue
        layer = e.get("layer")
        if layer == "meta":
            continue          # 층에 갇히지 않으므로 건너뛴다(SPEC §3.2)
        n += 1
        want = LAYER_DIR.get(layer)
        rel = str(f.relative_to(led.root))
        if want is None:
            r.bad(f"{rel}:{ln}: {ref} 의 layer `{layer}` 가 대응표에 없다")
        elif not rel.startswith(want + "/"):
            r.bad(f"{rel}:{ln}: {ref} 의 layer 가 `{layer}` 인데 파일이 그 층에 없다")
    r.note(f"meta 가 아닌 표지 {n}개를 봤다")
    return r


def check_24(led: Ledger) -> Report:
    r = Report("24", "wiki24-doc-rule-ghost",
               "상주 문서와 Lean 주석의 규율 ID 토큰이 실재하고, 폐기됐으면 그 문서가 선언했는가",
               "fail")
    total = missing = retired = declared = 0
    for rel, text in led.rule_scan_targets():
        # 문서 머리의 선언 줄을 읽어 거기 열거된 ID 의 폐기 지목을 면제한다.
        allow: set = set()
        for line in text.splitlines():
            m = DECLARE_LINE.match(line)
            if m:
                allow |= {x.group(0) for x in RULE_TOKEN.finditer(m.group(1))}
        for i, line in enumerate(text.splitlines(), 1):
            if DECLARE_LINE.match(line):
                continue                      # 선언 줄 자신은 면제의 근거이지 지목이 아니다
            for m in RULE_TOKEN.finditer(line):
                tok = m.group(0)
                total += 1
                owner = led.name_owner.get(tok)
                if owner is None:
                    missing += 1
                    r.bad(f"{rel}:{i}: `{tok}` 이 어느 항목의 names 에도 없다")
                elif owner in led.dead:
                    if tok in allow:
                        declared += 1
                    else:
                        retired += 1
                        r.bad(f"{rel}:{i}: 폐기된 규율 `{tok}`({owner}) 를 드는데 "
                              f"문서 머리의 폐기 지목 선언에 없다")
    r.note(f"규율 ID 토큰 {total}건. 미실재 {missing} · 선언 없는 폐기 지목 {retired} · "
           f"선언으로 면제된 폐기 지목 {declared}")
    r.note(f"유니버스: 상주 문서 {len(RESIDENT_DOCS) + 1} · Lean {len(led.lean_files)}. "
           f"유니버스 밖: {list(HISTORY_PATHS)}")
    return r


def check_25(led: Ledger) -> Report:
    r = Report("25", "wiki25-marker-missing",
               "Lean 의 최상위 def·theorem·inductive·structure·abbrev 선언마다 DD: 표지가 붙었는가",
               "fail")
    marks = led.dd_markers()
    n_decl = n_mark = missing = 0
    for f in led.lean_files:
        lines = f.read_text(encoding="utf-8").splitlines()
        decls = [(i, m.group(1), m.group(2))
                 for i, ln in enumerate(lines, 1)
                 for m in [TOP_DECL.match(ln)] if m]
        # 그 파일의 표지가 선 줄. 검사 13 과 같은 유니버스라 블록 주석은 들지 않는다.
        mark_lines = sorted(ln for g, ln, _ in marks if g == f)
        n_decl += len(decls)
        n_mark += len(mark_lines)
        prev = 0
        for line_no, kind, name in decls:
            # 앞 선언과 이 선언 사이에 선 표지가 이 선언의 것이다.
            if any(prev < m < line_no for m in mark_lines):
                pass
            else:
                missing += 1
                r.bad(f"{f.relative_to(led.root)}:{line_no}: 최상위 {kind} `{name}` 에 "
                      f"DD: 표지가 없다")
            prev = line_no
    r.note(f"최상위 선언 {n_decl} · 표지 {n_mark} · 누락 {missing}")
    r.note("example 은 정의도 정리도 아니므로 대상이 아니다(SPEC §2.1)")
    return r


# 기각 문단을 가리키는 **예약 낱말**. 검사 33 의 좌변이 이것으로 선다.
#
# 본문의 부분 문자열을 재던 상수를 예약 낱말로 갈음했다. 그 낱말은 기각을 가리키는 머리말에만
# 서는 것이 아니라 산문 안에서도 서므로, 본문을 재면 기각 문단이 아닌 자리에 기각 레지스터의
# 등재가 요구된다. 상수를 지우지 않고 남기는 것은 `HEADING` 블록에서 이 낱말을 골라낼 다른
# 열이 없기 때문이며, 그 항의 규율 ID 를 드는 항이 셋이라 ID 로는 골라지지 않는다. 그래서
# 상수가 남되 **단언이 지키는 부류로 옮겨 간다**(SPEC §2.1).
REJECTION_WORD = "기각한 대체 정의"


def check_33(led: Ledger) -> Report:
    r = Report("33", "wiki33-rejection-registered",
               "경계 안 선언의 docstring 기각 문단마다 기각 레지스터에 for_decl 로 그 선언을 "
               "드는 항목이 있고, for_decl 을 든 항목 전량에 대해 그 선언이 실재하고 그 "
               "docstring 이 기각 문단을 드는가", "fail")
    since, forms = heading_rules(led)
    if since is None:
        r.bad("docs/baseline.md 의 HEADING 블록에 HEADING_SINCE 가 없다")
        return r
    # 상수가 그 블록에 실재하는지 단언한다. 블록에서 빠지면 좌변이 조용히 비므로, 박아 둔
    # 값이 아니라 단언이 지키는 값이 된다.
    if REJECTION_WORD not in forms:
        r.bad(f"docs/baseline.md 의 HEADING 블록에 예약 낱말 `{REJECTION_WORD}` 이 없다")
        return r
    decls = led.doc_decls()
    inside = [d for d in decls if d.no >= since]

    def has_rejection(d: DocDecl) -> bool:
        """머리말이 그 예약 낱말을 드는 문단을 하나라도 갖는가.

        본문이 아니라 머리말을 본다. 머리말의 뜻과 낱말을 드는지의 판정은 검사 34 가 쓰는
        것과 같은 것을 쓴다(SPEC §2.1).
        """
        return any(h is not None and REJECTION_WORD in h
                   for h in (para_heading(p) for p in d.paras))

    # 좌변. 기각 문단을 하나라도 든 경계 안 선언의 완전 이름.
    left = {d.full: d for d in inside if has_rejection(d)}
    # 우변. `for_decl` 을 든 기각 항목이 가리키는 완전 이름과 그것을 든 항목의 id.
    right: dict[str, list[str]] = {}
    for e in led.reg["rejected"]:
        if e.get("for_decl"):
            right.setdefault(str(e["for_decl"]), []).append(str(e.get("id")))

    missed = ghost = 0
    for full, d in sorted(left.items()):
        if full not in right:
            missed += 1
            r.bad(f"{d.rel}:{d.line}: `{full}` 의 docstring 이 기각 문단을 드는데 기각 "
                  f"레지스터에 그것을 for_decl 로 드는 항목이 없다")
    by_full = {d.full: d for d in decls}
    for full in sorted(right):
        d = by_full.get(full)
        ids = ", ".join(right[full])
        if d is None:
            # 깨진 참조는 경계와 무관하다. 기각 레지스터가 없는 선언을 가리키는 것은 경계
            # 안이든 밖이든 결함이다.
            ghost += 1
            r.bad(f"기각 항목 {ids} 의 for_decl `{full}` 에 해당하는 선언이 리포 소스에 없다")
        elif not has_rejection(d):
            ghost += 1
            r.bad(f"기각 항목 {ids} 의 for_decl `{full}` 의 docstring 이 기각 문단을 "
                  f"들지 않는다")
            # 이 판정에 경계를 걸지 않는다. 경계를 선언의 표지에 걸면 표지가 경계보다 앞인
            # 선언이 좌변과 우변에서 함께 빠지는데, `for_decl` 이 소급되지 않은 선택 필드라
            # 그것을 든 항목은 전부 경계 뒤에 쓰였다. 그래서 경계를 항목 쪽으로 옮긴 것이
            # 소급이 아니다. 좌변은 그대로 경계 안으로 좁혀 둔다(SPEC §2.1).
    # 계수를 맞대지 않는다. 한 선언에 원장 항목이 둘 이상인 것과 기각 문단이 둘 이상인 것이
    # 있어 양쪽 계수가 갈리므로 존재 검사로 둔다(SPEC §2.1).
    outside = sum(1 for d in decls if d.no < since and has_rejection(d))
    r.note(f"유니버스 선언 {len(inside)} · 좌변 {len(left)} · 우변 {len(right)} "
           f"· 좌→우 미포착 {missed} · 우→좌 유령 {ghost} · 경계 HEADING_SINCE={since}")
    r.note(f"경계 밖에서 기각 문단을 든 선언 {outside} "
           f"(소급하지 않기로 한 미등재분의 크기이며 실패가 아니라 보고다)")
    return r


def check_34(led: Ledger) -> Report:
    r = Report("34", "wiki34-heading-form",
               "경계 안 선언의 docstring 문단 머리말이 예약 낱말을 들면 HEADING 블록이 그 "
               "낱말에 둔 형과 같은가", "fail")
    since, forms = heading_rules(led)
    # 블록이 비어 있으면 통과가 아니라 실패다. 가리킬 대상이 없는데 통과시키면 이 검사가
    # 공허해지고, 머리말이 검사 33 의 좌변 앵커이므로 그 탐지도 함께 조용히 빈다.
    if not forms:
        r.bad("docs/baseline.md 의 HEADING 블록이 없거나 비어 있다")
        return r
    if since is None:
        r.bad("docs/baseline.md 의 HEADING 블록에 HEADING_SINCE 가 없다")
        return r
    for word in sorted(forms):
        for form in forms[word]:
            if form.count("*") > 1:
                r.bad(f"HEADING 블록의 형 `{form}` 에 `*` 가 둘 이상이다")
    if r.violations:
        return r

    n_para = n_res = n_free = outside = 0
    for d in led.doc_decls():
        inside = d.no >= since
        for p in d.paras:
            head = para_heading(p)
            if head is None:
                continue
            hit = sorted(w for w in forms if w in head)
            if inside:
                n_para += 1
                if hit:
                    n_res += 1
                else:
                    n_free += 1
            if not hit:
                continue
            # 한 머리말이 예약 낱말 둘을 들면 그 둘의 형을 합집합으로 받는다.
            if any(heading_matches(f, head) for w in hit for f in forms[w]):
                continue
            if inside:
                r.bad(f"{d.rel}:{d.line}: `{d.full}` 의 머리말 `{head}` 가 예약 낱말 "
                      f"{' · '.join(hit)} 에 걸린 형과 다르다")
            else:
                outside += 1
    r.note(f"유니버스 문단 {n_para} · 예약 낱말을 드는 머리말 {n_res} · 자유 {n_free} "
           f"· 예약 낱말 {len(forms)} · 형 {sum(len(v) for v in forms.values())} "
           f"· 경계 HEADING_SINCE={since}")
    r.note(f"경계 밖에서 형을 어기는 머리말 {outside} "
           f"(소급하지 않기로 한 미정리분의 크기이며 실패가 아니라 보고다)")
    return r


# 검사 38 이 읽는 V-8 의 대상 분할. `docs/baseline.md` §5 의 `EXCL` 블록이며 정본은 같은 파일의
# §7-2-1 이다. 등록 관계를 드는 선언이 하나라 표지도 하나이고 그 번호가 머리말의 경계보다 앞서서
# 경계를 번호로는 가를 수 없으므로, 분할의 이름을 레지스터로 닫는다(SPEC §2.1).
EXCL_BLOCK = re.compile(r"<!-- EXCL:BEGIN -->\n(.*?)<!-- EXCL:END -->", re.S)


EXCL_LINE = re.compile(r"^EXCL=(\S+)$")


# 배타성 문단을 가리키는 **예약 낱말**. 검사 38 이 이것으로 `HEADING` 블록에서 두 형을 꺼내고
# 머리말이 이것을 드는 문단을 고르며, 그 낱말이 블록에 실재하는지를 단언이 지킨다. 검사 33 의
# `REJECTION_WORD` 와 같은 형이다. **두 형의 문면에 실제로 서는 낱말이어야 고르는 자리가 비지
# 않으므로 「배타성」이 아니라 「배타적」이다.** 「배타」만 쓰면 두 형이 함께 걸린다.
EXCLUSIVITY_WORD = "배타적"


# 배타성 문단의 두 꼴을 가르는 조각. 블록의 한 줄이 예약 낱말과 조항과 형만 들고 꼴을 가를 열을
# 두지 않으므로 형의 문면으로 가르며, 그 조각이 두 형 가운데 한쪽에만 서는 것을 단언이 지킨다.
EXCL_ALL_MARK = "모든 쌍이 배타적"


# 검사 38 이 읽는 등록 관계의 선언. 분할과 배타 관계가 전부 그 하나에 서므로 자리를 상수로 둔다.
# 선언이 둘로 갈리면 이 상수가 가리키는 자리가 비어 그 사실이 실패로 드러난다.
EXCL_DECL = "CrisisFramework.Glossary.registry"


# 등록 관계의 본문에서 분할과 배타 관계를 뽑는 꼴. 칸의 목록이 두 줄에 걸친 자리가 이미 있으므로
# 줄 단위로 읽지 않고 본문을 통째로 훑는다.
PARTITIONS_ROW = re.compile(r"\.partitions\s+\.(\w+)\s*\[([^\]]*)\]", re.S)


EXCLUDES_ROW = re.compile(r"\.excludes\s+\.(\w+)\s+\.(\w+)")


PART_ITEM = re.compile(r"\.(\w+)")


# 생성자와 그 docstring. 첫 마디가 그 개념의 한국어 이름이고 배타성 문단의 머리말이 그 이름으로
# 분할을 드므로, 식별자로 선 `EXCL` 블록과 한국어로 선 머리말을 맺는 자리가 이것이다.
CTOR_DOC = re.compile(r"/--\s*(.*?)\s*-/\s*\n\s*\|\s*(\w+)", re.S)


def heading_fill(form: str, head: str) -> str | None:
    """형의 가변 구간에 든 문면. 형과 머리말이 맞지 않으면 None 이다.

    맞는지의 판정은 `heading_matches` 를 그대로 부르고 이 함수는 그 자리의 문면만 꺼낸다. 두
    구현이 갈리면 같은 머리말이 한쪽에서 맞고 다른 쪽에서 비므로 판정을 나누어 쓰지 않는다.
    가변 구간이 하나인 형만 받으며, 그것을 검사 38 이 부르기 전에 단언한다.
    """
    if not heading_matches(form, head):
        return None
    pre, suf = form.split("*", 1)
    return head[len(pre):len(head) - len(suf)]


def excl_registry(led: Ledger) -> tuple[DocDecl, dict[str, list[str]], set[frozenset]] | None:
    """등록 관계를 드는 선언과 그 본문이 든 분할과 배타 관계. 선언이 없으면 None 이다.

    본문은 그 선언이 선 줄부터 다음 최상위 선언이나 이름공간의 끝까지다. 분할은 이름마다 칸의
    목록이고 배타 관계는 순서를 묻지 않는 쌍의 집합이다. V-2 가 그 관계를 대칭으로 두므로
    등록된 순서를 판정에 쓰지 않는다.
    """
    d = next((x for x in led.doc_decls() if x.full == EXCL_DECL), None)
    if d is None:
        return None
    lines = (led.root / d.rel).read_text(encoding="utf-8").splitlines()
    end = len(lines)
    for i in range(d.line, len(lines)):
        if TOP_DECL.match(lines[i]) or NAMESPACE_END.match(lines[i]):
            end = i
            break
    body = _lean_code("\n".join(lines[d.line - 1:end]))
    parts = {m.group(1): PART_ITEM.findall(m.group(2))
             for m in PARTITIONS_ROW.finditer(body)}
    excl = {frozenset(m.groups()) for m in EXCLUDES_ROW.finditer(body)}
    return d, parts, excl


def concept_labels(led: Ledger, rel: str) -> dict[str, str]:
    """생성자 이름과 그 docstring 의 첫 마디. 그 마디가 그 개념의 한국어 이름이다.

    `EXCL` 블록은 분할을 식별자로 들고 배타성 문단의 머리말은 한국어 이름으로 드므로 둘을 맺는
    자리가 있어야 한다. 그 이름을 블록에 다시 적지 않는 까닭은 같은 이름이 두 자리에 살면
    한쪽을 고칠 때 다른 쪽이 조용히 낡기 때문이고, 생성자 docstring 의 첫 마디가 그 이름의
    정본으로 이미 서 있다(SPEC §0.2).
    """
    out: dict[str, str] = {}
    for m in CTOR_DOC.finditer((led.root / rel).read_text(encoding="utf-8")):
        doc = re.sub(r"\s+", " ", m.group(1)).strip()
        out.setdefault(m.group(2), doc.split(".")[0].strip())
    return out


def check_38(led: Ledger) -> Report:
    r = Report("38", "wiki38-partition-exclusivity",
               "EXCL 블록이 든 분할마다 배타성 문단이 하나 있고, 모든 쌍이 배타적이라 적은 "
               "분할은 그 쌍마다 배타 관계가 등록되어 있으며, 배타적이지 않은 쌍이 있다고 적은 "
               "분할은 등록되지 않은 쌍을 갖는가", "fail")
    # 유니버스. 블록이 비어 있으면 통과가 아니라 실패다. 가리킬 대상이 없는데 통과시키면 이
    # 검사가 공허해진다. 검사 28 과 34 와 35 와 37 이 같은 요구를 둔다.
    names = [m.group(1) for m in
             map(EXCL_LINE.match, _baseline_block(led, EXCL_BLOCK).splitlines()) if m]
    if not names:
        r.bad("docs/baseline.md 의 EXCL 블록이 없거나 비어 있다")
        return r
    _, forms = heading_rules(led)
    # 예약 낱말과 두 꼴을 가르는 조각이 그 블록에 실재하는지 단언한다. 블록에서 빠지면 좌변이
    # 조용히 비므로, 박아 둔 값이 아니라 단언이 지키는 값이 된다(검사 33 과 같은 형).
    if EXCLUSIVITY_WORD not in forms:
        r.bad(f"docs/baseline.md 의 HEADING 블록에 예약 낱말 `{EXCLUSIVITY_WORD}` 이 없다")
        return r
    all_forms = [f for f in forms[EXCLUSIVITY_WORD] if EXCL_ALL_MARK in f]
    some_forms = [f for f in forms[EXCLUSIVITY_WORD] if EXCL_ALL_MARK not in f]
    if len(all_forms) != 1 or len(some_forms) != 1:
        r.bad(f"docs/baseline.md 의 HEADING 블록에서 예약 낱말 `{EXCLUSIVITY_WORD}` 의 형이 "
              f"`{EXCL_ALL_MARK}` 를 든 것 {len(all_forms)} 과 들지 않은 것 "
              f"{len(some_forms)} 으로 갈리지 않는다")
        return r
    # 가변 구간이 하나인 것을 단언한다. `heading_fill` 이 그 형만 받고, 검사 34 도 둘 이상인
    # 형을 위반으로 내므로 그 제한이 두 검사에 같이 걸린다.
    for f in forms[EXCLUSIVITY_WORD]:
        if f.count("*") != 1:
            r.bad(f"HEADING 블록의 형 `{f}` 가 가변 구간을 하나 두지 않는다")
    if r.violations:
        return r

    got = excl_registry(led)
    if got is None:
        r.bad(f"등록 관계를 드는 선언 `{EXCL_DECL}` 이 리포 소스에 없다")
        return r
    decl, parts, excl = got
    labels = concept_labels(led, decl.rel)

    # 배타성 문단. 머리말이 예약 낱말을 드는 것을 먼저 고르고 그 뒤에 두 형과 맞대어, 가변
    # 구간의 문면과 두 꼴 가운데 어느 것인지를 함께 얻는다. 고르는 자리를 검사 34 와 같은 꼴로
    # 두므로 낱말을 드는데 어느 형과도 맞지 않는 머리말이 그 검사에서와 같이 위반으로 선다.
    paras: list[tuple[str, bool]] = []
    for p in decl.paras:
        head = para_heading(p)
        if head is None or EXCLUSIVITY_WORD not in head:
            continue
        fill = heading_fill(all_forms[0], head)
        if fill is not None:
            paras.append((fill, True))
            continue
        fill = heading_fill(some_forms[0], head)
        if fill is not None:
            paras.append((fill, False))
            continue
        r.bad(f"{decl.rel}:{decl.line}: `{decl.full}` 의 머리말 `{head}` 가 예약 낱말 "
              f"`{EXCLUSIVITY_WORD}` 을 드는데 그 낱말의 두 형 가운데 어느 것과도 맞지 않는다")

    n_all = n_pair = 0
    for name in names:
        # ㉠ 블록의 이름이 그 선언에서 분할로 실재하는가. 유령 이름을 막는다.
        if name not in parts:
            r.bad(f"EXCL 블록의 `{name}` 을 분할로 드는 partitions 행이 `{EXCL_DECL}` 에 없다")
            continue
        label = labels.get(name)
        if not label:
            r.bad(f"EXCL 블록의 `{name}` 의 한국어 이름을 그 생성자의 docstring 에서 "
                  f"읽을 수 없다")
            continue
        # ㉡ 그 분할의 배타성 문단이 하나인가. 머리말의 가변 구간이 그 한국어 이름으로 시작하는
        # 것을 그 분할의 문단으로 본다. 그 이름에 한정어가 붙어 선 자리가 있어 완전일치로는
        # 맺히지 않는다.
        hit = [x for x in paras if x[0].startswith(label)]
        if len(hit) != 1:
            r.bad(f"{decl.rel}:{decl.line}: EXCL 블록의 `{name}`(`{label}`) 에 걸린 배타성 "
                  f"문단이 {len(hit)} 개다. 하나여야 한다")
            continue
        _, is_all = hit[0]
        cells = parts[name]
        pairs = [frozenset((a, b)) for i, a in enumerate(cells) for b in cells[i + 1:]]
        n_pair += len(pairs)
        missing = [tuple(sorted(x)) for x in pairs if x not in excl]
        if is_all:
            n_all += 1
            # ㉢ 모든 쌍이 배타적이라 적었으면 그 쌍마다 배타 관계가 서야 한다.
            if missing:
                r.bad(f"`{name}` 의 배타성 문단이 모든 쌍이 배타적이라 적는데 배타 관계가 없는 "
                      f"쌍이 있다: " + " · ".join(f"{a} 와 {b}" for a, b in missing))
        elif not missing:
            # ㉣ 배타적이지 않은 쌍이 있다고 적었으면 등록되지 않은 쌍이 하나 이상 있어야 한다.
            # **어느 쌍인지를 본문에서 파싱하지 않는다.** 머리말이 꼴만 가르고 쌍의 판정은 배타
            # 관계의 실물이 내므로, 본문을 읽으면 검사 33 의 좌변을 머리말로 좁힌 결정이 든
            # 오탐의 위험이 이 자리에 다시 선다(SPEC §2.1).
            r.bad(f"`{name}` 의 배타성 문단이 배타적이지 않은 쌍이 있다고 적는데 그 칸의 모든 "
                  f"쌍에 배타 관계가 등록되어 있다")
    outside = sum(1 for p in parts if p not in names)
    r.note(f"EXCL 블록의 분할 {len(names)} · 모든 쌍이 배타적인 것 {n_all} · 쌍의 전량 "
           f"{n_pair} · 블록에 들지 않은 분할 {outside}")
    r.note("블록에 들지 않은 분할은 소급되지 않고 미정리분의 크기만 보고된다(SPEC §2.1)")
    return r


# 검사 48·49 가 읽는 `SOURCING` 블록. `docs/baseline.md` §5 가 경계와 구절의 최소 길이를 들며,
# 값을 코드에 박지 않고 그 블록이 들게 한다(SPEC §2.1).
SOURCING_BLOCK = re.compile(r"<!-- SOURCING:BEGIN -->\n(.*?)<!-- SOURCING:END -->", re.S)


SOURCING_SINCE_LINE = re.compile(r"^SOURCING_SINCE=(\d+)$")


SOURCING_MINLEN_LINE = re.compile(r"^SOURCING_MINLEN=(\d+)$")


# 배제 사례 문단을 가리키는 **예약 낱말**. 검사 48 의 둘째 몫이 이 낱말로 그 문단을 고르며,
# 검사 33 이 기각 문단을 고르는 것과 같은 형이다. 그 낱말이 `HEADING` 블록에 실재하는지를
# 단언하므로 박아 둔 값이 아니라 **단언이 지키는 값**이다(SPEC §2.1).
EXCLUSION_WORD = "배제하는 사례"


# 조달처 줄의 꼴. 배제 사례 문단의 말미에 서고 기록 번호와 절 번호와 낫표로 감싼 구절을 든다.
# 문단의 공백을 접은 뒤에 맞대므로 줄을 걸쳐 쓴 구절도 한 꼴로 읽힌다.
SOURCING_LINE = re.compile(
    r"조달처:\s*E-(\d{1,2})\s*§\s*(\d+(?:-\d+)*)\s*「([^」]+)」[.\s]*$")


# 추출 기록의 절 제목과 그 파일 이름의 번호. 절 제목은 머리 기호 둘 이상에 번호와 마침표가
# 따르는 줄이며 번호가 그 절의 이름이다.
EXTRACTION_HEADING = re.compile(r"^#{2,}\s*(\d+(?:-\d+)*)\.\s")


def fold(s: str) -> str:
    """공백을 하나로 접고 앞뒤를 떼어 낸다.

    줄을 걸쳐 쓴 문면을 한 꼴로 맞대는 수단이다. 접지 않으면 두 줄에 걸친 조달처 줄과 그
    구절이 지목한 절의 문면과 결코 같아지지 않아 그 자리가 전부 위반으로 잡힌다. 머리말의
    줄바꿈을 접는 `para_heading` 이 같은 사유로 같은 일을 한다.
    """
    return re.sub(r"\s+", " ", s).strip()


def sourcing_rules(led: Ledger) -> tuple[int | None, int | None]:
    """`SOURCING` 블록이 든 경계와 구절의 최소 길이."""
    since: int | None = None
    minlen: int | None = None
    for line in _baseline_block(led, SOURCING_BLOCK).splitlines():
        m = SOURCING_SINCE_LINE.match(line)
        if m:
            since = int(m.group(1))
            continue
        m = SOURCING_MINLEN_LINE.match(line)
        if m:
            minlen = int(m.group(1))
    return since, minlen


def extraction_sections(path: Path) -> dict[str, str]:
    """추출 기록의 절 번호별 본문. 하위 절의 문면은 그 상위 절의 본문에도 든다.

    하위를 품게 두는 까닭은 `§8` 을 지목한 구절이 `§8-3` 에 서 있는 것이 그 절 **안**에 있는
    것이라는 데 있다. 품지 않으면 상위 절을 지목한 자리가 전부 미착지로 잡힌다.

    같은 번호의 절이 둘이면 두 본문을 잇는다. 뒤의 것으로 덮으면 앞 절에 선 구절이 조용히
    사라지고, 그 꼴은 그 기록 자신의 결함이므로 이 사상이 가리지 않는다.
    """
    lines = path.read_text(encoding="utf-8").splitlines()
    heads = [(i, m.group(1)) for i, ln in enumerate(lines)
             for m in [EXTRACTION_HEADING.match(ln)] if m]
    out: dict[str, str] = {}
    for k, (i, no) in enumerate(heads):
        end = len(lines)
        for j, nxt in heads[k + 1:]:
            if not nxt.startswith(no + "-"):
                end = j
                break
        body = "\n".join(lines[i + 1:end])
        out[no] = out[no] + "\n" + body if no in out else body
    return out


def check_48(led: Ledger) -> Report:
    r = Report("48", "wiki48-extraction-sourcing",
               "형식층 docstring 의 추출 기록 지목이 실재하는 기록의 실재하는 절에 닿고, "
               "경계 안 선언의 배제 사례 문단이 조달처 줄을 들며 그 구절이 지목한 그 절 안에 "
               "있는가", "fail")
    since, minlen = sourcing_rules(led)
    # 블록을 읽지 못하면 통과가 아니라 실패다. 경계가 없으면 둘째 몫의 유니버스가 서지 않고
    # 최소 길이가 없으면 구절의 하한이 서지 않는다. 검사 33 과 34 와 41 이 같은 요구를 둔다.
    if since is None:
        r.bad("docs/baseline.md 의 SOURCING 블록에 SOURCING_SINCE 가 없다")
        return r
    if minlen is None:
        r.bad("docs/baseline.md 의 SOURCING 블록에 SOURCING_MINLEN 이 없다")
        return r
    _since, forms = heading_rules(led)
    # 예약 낱말이 그 블록에 실재하는지 단언한다. 블록에서 빠지면 둘째 몫의 좌변이 조용히
    # 비므로, 박아 둔 값이 아니라 단언이 지키는 값이 된다. 검사 33 이 같은 자리를 둔다.
    if EXCLUSION_WORD not in forms:
        r.bad(f"docs/baseline.md 의 HEADING 블록에 예약 낱말 `{EXCLUSION_WORD}` 이 없다")
        return r

    cache: dict[int, dict[str, str]] = {}

    def secs(n: int) -> dict[str, str]:
        """그 번호의 기록의 절 모음. 기록마다 한 번만 읽는다."""
        if n not in cache:
            f = extraction_record(led, n)
            cache[n] = extraction_sections(f) if f is not None else {}
        return cache[n]

    # ㉠ 착지. 지목이 실재하는 기록의 실재하는 절에 닿는가.
    ptrs = doc_pointers(led)
    landed = 0
    for rel, line, n, sec in ptrs:
        f = extraction_record(led, n)
        if f is None:
            r.bad(f"{rel}:{line}: 지목 `E-{n:02d} §{sec}` 의 번호에 해당하는 추출 기록이 없다")
            continue
        if sec not in secs(n):
            r.bad(f"{rel}:{line}: 지목 `E-{n:02d} §{sec}` 의 절이 `{f.name}` 에 없다")
            continue
        landed += 1
    # ㉡ 조달처. 경계 안 선언의 배제 사례 문단마다 말미의 조달처 줄과 그 구절을 본다.
    n_in = n_out = 0
    for d in led.doc_decls():
        for p in d.paras:
            head = para_heading(p)
            if head is None or EXCLUSION_WORD not in head:
                continue
            m = SOURCING_LINE.search(fold(p))
            if d.no < since:
                # 경계 밖은 소급하지 않는다. 그 문면이 영구 문면이고 D-2 가 요구하는 세
                # 항목이 경계 이전에도 서 있으므로, 조달처만 뒤에 걸린 것이다.
                if m is None:
                    n_out += 1
                continue
            n_in += 1
            if m is None:
                r.bad(f"{d.rel}:{d.line}: `{d.full}` 의 배제 사례 문단이 말미에 조달처 "
                      f"줄을 들지 않는다")
                continue
            n, sec, phrase = int(m.group(1)), m.group(2), fold(m.group(3))
            if sec not in secs(n):
                continue          # 착지의 몫이 그 자리를 이미 냈다
            if len(phrase) < minlen:
                r.bad(f"{d.rel}:{d.line}: `{d.full}` 의 조달처 구절의 길이 {len(phrase)} 가 "
                      f"최소 길이 {minlen} 보다 짧다")
                continue
            if phrase not in fold(secs(n)[sec]):
                r.bad(f"{d.rel}:{d.line}: `{d.full}` 의 조달처 구절이 지목한 "
                      f"`E-{n:02d} §{sec}` 안에 없다")
    r.note(f"형식층 docstring 의 지목 {len(ptrs)} · 그 가운데 착지한 것 {landed} "
           f"· 지목이 가리킨 기록 {len({n for _r, _l, n, _s in ptrs})}")
    r.note(f"경계 안 선언의 배제 사례 문단 {n_in} · 경계 SOURCING_SINCE={since} "
           f"· 구절의 최소 길이 SOURCING_MINLEN={minlen}")
    r.note(f"경계 밖에서 조달처 줄을 들지 않는 배제 사례 문단 {n_out} "
           f"(소급하지 않기로 한 미조달분의 크기이며 실패가 아니라 보고다)")
    return r


# 검사 57 의 유니버스. CQ 고정 파일의 머리 블록과 값 정본의 CQ 고정 절 둘로 닫는다. 영구 문면 전량으로
# 열면 다른 것을 세는 수사가 거짓 양성으로 서고 그 가운데 참인 것이 묻힌다(SPEC §2.1).
CQ_FIXED_FILE = "CrisisFramework/Observation/CompetencyQuestion.lean"


CQ_FIXED_SECTION_DOC = "docs/baseline.md"


# 머리 블록은 파일 맨 앞의 `/- -/` 다. docstring 의 `/--` 는 머리가 아니므로 받지 않는다.
CQ_HEAD_BLOCK = re.compile(r"\A\s*/-(?!-)(.*?)-/", re.S)


CQ_FIXED_SECTION_HEAD = re.compile(r"^## \d+\. CQ 고정 절")


CQ_NEXT_SECTION = re.compile(r"^## ", re.M)


# 걷어내는 것 둘. 기계 판독 블록은 값을 줄로 들어 번호가 수사처럼 읽히고, 식별자는 `CQ-fin-12`
# 처럼 번호를 품어 `CQ-fin` 뒤에 수가 오는 꼴로 읽힌다. 블록 이름을 대문자 꼴로만 받아 이 꼴이
# 검사 46 의 유니버스에 들지 않게 한다.
MACHINE_BLOCK = re.compile(r"<!--\s*[A-Z][A-Z0-9]*:BEGIN\s*-->.*?<!--\s*[A-Z][A-Z0-9]*:END\s*-->", re.S)


IDENTIFIER_WITH_NO = re.compile(r"(?<![0-9A-Za-z-])[A-Za-z]+(?:-[A-Za-z]+)*-[0-9]+(?![0-9A-Za-z-])")


# 수사의 꼴. 검사 40 의 두 표에서 지어 쓰고, 관형형을 더한다. 관형형이 없으면 「열한 물음」 처럼
# 명사를 꾸미는 자리가 그물 밖에 남으며 이 검사가 찾는 것이 바로 그 자리다. 아라비아 숫자도 받는다.
CQ_KO_ATTRIBUTIVE = {"하나": "한", "둘": "두", "셋": "세", "넷": "네", "스물": "스무"}


_CQ_UNITS = [w for u in COUNT_KO_UNIT for w in {u, CQ_KO_ATTRIBUTIVE.get(u, u)}]


_CQ_TENS = [w for t in COUNT_KO_TENS for w in {t, CQ_KO_ATTRIBUTIVE.get(t, t)}]


CQ_NUMERAL = "(?:" + "|".join(sorted(
    set(_CQ_UNITS + _CQ_TENS + [t + u for t in COUNT_KO_TENS for u in _CQ_UNITS]),
    key=len, reverse=True)) + r"|[0-9]+)"


# 꼴 둘. ㉠ 수사가 「물음」·「항」·「선언」을 바로 꾸미는 자리이며 수량 단위 「개」와 조사 「의」가
# 사이에 끼는 것을 받는다. 「항목」 은 다른 낱말이라 뺀다. 서수 「째」 는 수사 뒤에 붙어 명사와
# 떨어지므로 이 꼴에 들지 않는다. ㉡ `CQ-fin` 뒤에 수사가 바로 오는 자리이며, 수사 뒤에는 조사
# 하나까지만 받아 「세운다」 같은 낱말의 머리가 수사로 읽히지 않게 한다.
CQ_COUNT_MODIFIER = re.compile(
    r"(?<![0-9A-Za-z가-힣])(" + CQ_NUMERAL + r")\s*(?:개\s*)?(?:의\s*)?(물음|항(?!목)|선언)")


CQ_COUNT_AFTER_ID = re.compile(
    r"`?CQ-fin`?\s*(" + CQ_NUMERAL + r")(?!째)"
    r"(?=[^가-힣]|$|(?:의|이|가|은|는|을|를|과|와|에|도|만|이다|이며|이고|으로|로)(?![가-힣]))")


def cq_count_universe(led: Ledger, r: Report) -> list[tuple[str, str]]:
    """검사 57 의 (표시 이름, 걷어낸 뒤의 문면). 자리를 찾지 못하면 그 사실을 실패로 낸다."""
    out: list[tuple[str, str]] = []
    f = led.root / CQ_FIXED_FILE
    if not f.is_file():
        r.bad(f"{CQ_FIXED_FILE} 이 없다")
    else:
        m = CQ_HEAD_BLOCK.match(f.read_text(encoding="utf-8"))
        if m is None:
            r.bad(f"{CQ_FIXED_FILE} 의 머리 블록을 찾지 못했다")
        else:
            out.append((f"{CQ_FIXED_FILE} 의 머리 블록", m.group(1)))
    g = led.root / CQ_FIXED_SECTION_DOC
    if not g.is_file():
        r.bad(f"{CQ_FIXED_SECTION_DOC} 이 없다")
    else:
        lines = g.read_text(encoding="utf-8").splitlines(keepends=True)
        at = next((i for i, ln in enumerate(lines) if CQ_FIXED_SECTION_HEAD.match(ln)), None)
        if at is None:
            r.bad(f"{CQ_FIXED_SECTION_DOC} 에서 CQ 고정 절의 제목을 찾지 못했다")
        else:
            body = "".join(lines[at:])
            nxt = CQ_NEXT_SECTION.search(body, len(lines[at]))
            out.append((f"{CQ_FIXED_SECTION_DOC} 의 CQ 고정 절",
                        body[:nxt.start()] if nxt else body))
    return [(name, IDENTIFIER_WITH_NO.sub(" ", MACHINE_BLOCK.sub(" ", text)))
            for name, text in out]


def check_57(led: Ledger) -> Report:
    r = Report("57", "wiki57-cq-count-numeral",
               "CQ 고정 파일의 머리 블록과 값 정본의 고정 절이 그 항의 계수를 수사로 들지 않는가",
               "fail")
    places = cq_count_universe(led, r)
    hits = 0
    for name, text in places:
        found = ([m.group(0) for m in CQ_COUNT_MODIFIER.finditer(text)]
                 + [m.group(0) for m in CQ_COUNT_AFTER_ID.finditer(text)])
        hits += len(found)
        for h in found:
            r.bad(f"{name} 에 CQ 항의 계수를 드는 수사가 선다: 「{h}」")
        r.note(f"{name} — 걷어낸 뒤 {len(text)} 글자")
    r.note(f"유니버스 {len(places)} 자리 · 적발 {hits}")
    return r


# 검사 60 이 읽는 자리와 꼴. 유니버스는 회계층 파일 전량이고 `Rat/` 도 든다. 층을 정하는 것이
# 디렉터리이므로 그 아래를 전부 훑는다.
CURRENCY_GUARD_DIR = "CrisisFramework/Accounting"


# 최상위 선언의 머리. 주석과 문서화 문면을 걷어낸 뒤에 읽으므로 머리말 줄이 끼지 않는다.
CURRENCY_GUARD_DECL = re.compile(
    r"^(?:@\[[^\]\n]*\]\s*)?(?:(?:private|protected|noncomputable|partial|unsafe)\s+)*"
    r"(def|theorem|lemma|abbrev|instance|example|structure|inductive|class|opaque)\b"
    r"[ \t]*([^\s:({\[]*)", re.M)


# 선언이 아닌 최상위 명령. 마지막 선언의 몸이 그 뒤 명령까지 번지지 않게 끊는다.
CURRENCY_GUARD_STOP = re.compile(
    r"^(?:end|namespace|section|open|variable|universe|set_option|attribute|#\w+)\b", re.M)


# 청구권의 금액 항을 평가하는 문면. 색인이 다른 색인의 투영을 거쳐도 받는다.
CURRENCY_GUARD_AMOUNT = re.compile(
    r"evalTerm\s+[\w.']+\s+\(\s*[\w.']+\.assign\s+(?:[\w.']+|\([^()]*\)(?:\.[\w']+)*)\s*\)\.amount")


# 청구권의 표시 통화를 비교하는 문면. 좌변이든 우변이든 받는다.
CURRENCY_GUARD_CUR = re.compile(r"\.currency\s*=|=\s*\((?:[^()]|\([^()]*\))*\)\.currency\b")


CURRENCY_GUARD_OPEN = "([{⟨"


CURRENCY_GUARD_CLOSE = ")]}⟩"


def sum_terms(code: str) -> list[str]:
    """코드 문면의 합 기호마다 그 합의 항.

    바인더 뒤 첫 쉼표에서 시작해 괄호 균형을 따라가고, 같은 깊이의 비교 연산자나 정의 기호나
    전술 진입에서 멈춘다. 그 합을 감싼 괄호가 닫혀도 멈춘다. 항을 선언 본문 전량으로 잡으면
    타입클래스 바인더의 결정 가능 등식이 그 안에 들어 가드로 읽히므로 항으로 좁힌다.
    """
    out: list[str] = []
    n = len(code)
    for m in re.finditer("∑", code):
        # 바인더의 쉼표. 바인더 안의 괄호는 건너뛴다.
        k, depth = m.end(), 0
        while k < n:
            ch = code[k]
            if ch in CURRENCY_GUARD_OPEN:
                depth += 1
            elif ch in CURRENCY_GUARD_CLOSE:
                depth -= 1
            elif ch == "," and depth == 0:
                break
            k += 1
        if k >= n:
            continue
        start = k = k + 1
        depth = 0
        while k < n:
            ch = code[k]
            if ch in CURRENCY_GUARD_OPEN:
                depth += 1
            elif ch in CURRENCY_GUARD_CLOSE:
                if depth == 0:
                    break
                depth -= 1
            elif depth == 0:
                if code.startswith(":=", k):
                    break
                if ch in "≤≥≠":
                    break
                if ch == "=" and not code.startswith("=>", k):
                    break
                if ch in "<>" and not code.startswith(("<;>", "<|", "<-", "<$>"), k) \
                        and not (ch == ">" and k > 0 and code[k - 1] in "=-<|"):
                    break
                if code.startswith("by", k) and (k == 0 or not (code[k - 1].isalnum()
                                                                  or code[k - 1] in "_.'")) \
                        and (k + 2 >= n or not (code[k + 2].isalnum() or code[k + 2] in "_'")):
                    break
            k += 1
        out.append(code[start:k])
    return out


def currency_guard_decls(root: Path) -> list[tuple[str, str, int, int]]:
    """유니버스의 선언마다 (파일, 이름, 그 선언의 금액 합의 수, 그 가운데 표시 통화 판정이 든 수)."""
    res: list[tuple[str, str, int, int]] = []
    d = root / CURRENCY_GUARD_DIR
    for f in sorted(d.rglob("*.lean")):
        code = _lean_code(f.read_text(encoding="utf-8"))
        heads = list(CURRENCY_GUARD_DECL.finditer(code))
        for i, h in enumerate(heads):
            end = heads[i + 1].start() if i + 1 < len(heads) else len(code)
            stop = CURRENCY_GUARD_STOP.search(code, h.end(), end)
            body = code[h.start():stop.start() if stop else end]
            terms = [t for t in sum_terms(body) if CURRENCY_GUARD_AMOUNT.search(t)]
            if not terms:
                continue
            guarded = sum(1 for t in terms if CURRENCY_GUARD_CUR.search(t))
            res.append((str(f.relative_to(root)), h.group(2) or h.group(1), len(terms), guarded))
    return res


def check_60(led: Ledger) -> Report:
    r = Report("60", "wiki60-currency-guard",
               "회계층에서 합의 피가수가 청구권의 금액 항을 평가하는 선언마다 그 합의 항에 "
               "표시 통화 판정이 드는가", "fail")
    if not (led.root / CURRENCY_GUARD_DIR).is_dir():
        r.bad(f"{CURRENCY_GUARD_DIR}/ 가 없다")
        return r
    decls = currency_guard_decls(led.root)
    # 유니버스가 비면 어느 선언도 적발되지 않아 0 으로 난다. 검사 58 과 59 가 같은 요구를 둔다.
    if not decls:
        r.bad(f"{CURRENCY_GUARD_DIR}/ 에서 합의 항이 청구권의 금액 항을 평가하는 선언을 하나도 "
              "찾지 못했다")
        return r
    hit = [(f, n, t, g) for f, n, t, g in decls if g < t]
    for f, n, t, g in hit:
        r.bad(f"{f} 의 `{n}` 이 청구권의 금액을 더하는 합 {t} 가운데 {t - g} 의 항에 표시 통화 "
              "판정을 두지 않는다")
    r.note(f"유니버스의 선언 {len(decls)} · 모든 합의 항에 표시 통화 판정이 든 것 "
           f"{len(decls) - len(hit)} · 들지 않은 것 {len(hit)}")
    if hit:
        r.note("적발된 선언: " + " · ".join(f"`{n}`" for _f, n, _t, _g in hit))
    return r


# 이 단위가 드는 검사. 러너가 이 목록을 이어 붙여 손 열거를 걷는다.
CHECKS = (
    check_10,
    check_13,
    check_14,
    check_24,
    check_25,
    check_33,
    check_34,
    check_38,
    check_48,
    check_57,
    check_60,
)
