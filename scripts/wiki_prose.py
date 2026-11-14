# -*- coding: utf-8 -*-
"""원장 검증기의 검사 가운데 산문층의 상주 문서와 집행 문면과 루트의 무시 파일을 유니버스로 드는 검사.

이 단위가 자기 검사의 목록을 `CHECKS` 로 선언하고 러너가 그 목록을 이어 붙인다.
검사의 번호와 단계 id 는 그 선언이 들고 이 파일이 그 계수를 들지 않는다.
"""
from __future__ import annotations

import re
from pathlib import Path

from wiki_common import (
    ARCS_DOC,
    EXTRACTION_FILE_NO,
    INVENTORYMARK_AGGREGATE,
    INVENTORYMARK_BLOCK,
    INVENTORYMARK_CITED,
    INVENTORYMARK_UNREAD,
    INVENTORY_DOC,
    INVENTORY_EXTRACTION_NO,
    Ledger,
    POINTER_ARCS_MARK,
    READING_QUEUE_DOC,
    REGISTERS,
    RULE_TOKEN,
    Report,
    SPEC_TABLE_RULE,
    _baseline_block,
    _inventory_rows,
    arc_phase_names,
    doc_pointers,
    extraction_record,
    extraction_ref_number,
    inventory_member_rows,
    inventorymark_block,
    md_cells,
)

ARTIFACT_PATH = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._/-]*$")


def check_12(led: Ledger) -> Report:
    r = Report("12", "wiki12-reopen-ref", "reopen_when.ref 가 kind 별 형식을 만족하는가", "fail")
    queue = led.root / "docs" / "reading-queue-v0.md"
    qtext = queue.read_text(encoding="utf-8") if queue.is_file() else ""
    qflat = re.sub(r"\s+", "", qtext)
    for e in led.reg["deferred"]:
        rw = e.get("reopen_when")
        if not isinstance(rw, dict):
            continue
        kind, ref = rw.get("kind"), str(rw.get("ref") or "")
        if kind == "artifact":
            # 실재는 보지 않는다. 그 파일이 서는 것이 곧 재개 조건이기 때문이다(SPEC §3.3).
            if not ARTIFACT_PATH.match(ref) or ".." in ref:
                r.bad(f"{e.get('id')}: artifact 의 ref 가 리포 경로의 형식이 아니다 — {ref!r}")
        elif kind == "extraction":
            # 새 규약의 번호로 읽히면 형식을 만족한다. 그 번호의 기록이 섰는지는 이 검사가
            # 보지 않으며 검사 43 이 본다. 실재를 요구하면 발화 조건이 이미 충족된 트리거만
            # 등재할 수 있게 되어 발화 탐지와 정반대로 선다(SPEC §3.3).
            if extraction_ref_number(ref) is not None:
                continue
            # 번호를 강제하지 않는다. 그 규약 앞에 선 항은 논문 지목을 들며 소급해 고치지
            # 않으므로, 그 자리는 대기열에서 해소되는지만 본다(SPEC §3.3).
            if not qflat:
                r.bad(f"{e.get('id')}: reading-queue-v0.md 를 읽을 수 없어 extraction 을 해소하지 못한다")
            elif re.sub(r"\s+", "", ref) not in qflat:
                r.bad(f"{e.get('id')}: extraction 의 ref `{ref}` 가 reading-queue-v0.md 에서 해소되지 않는다")
        elif kind in ("arc_phase", "blocking"):
            if ref not in led.arcs:
                r.bad(f"{e.get('id')}: {kind} 의 ref `{ref}` 가 arcs.json 의 아크가 아니다")
    return r


def phases_closed_after(led: "Ledger", phase: str) -> int | None:
    """그 페이즈 뒤로 닫힌 페이즈의 수. 닫힘은 종료 문서의 실재로 본다.

    페이즈의 순서는 `arcs.json` 의 아크 순서와 아크마다의 `phases` 순서가 든다. 그 페이즈가
    그 목록에 없으면 셀 자리가 없으므로 `None` 이다.
    """
    order = [p for a in led.arcs.values() for p in arc_phase_names(a)]
    if phase not in order:
        return None
    d = led.root / "docs" / "phases"
    return sum(1 for p in order[order.index(phase) + 1:]
               if (d / f"{p}-closure.md").is_file())


def check_32(led: Ledger) -> Report:
    r = Report("32", "wiki32-closure-phase",
               "페이즈 종료 문서의 페이즈가 어느 아크의 phases 에 선언되어 있는가", "fail")
    declared = {p for a in led.arcs.values() for p in arc_phase_names(a)}
    d = led.root / "docs" / "phases"
    docs = sorted(d.glob("*-closure.md")) if d.is_dir() else []
    for f in docs:
        phase = f.name[:-len("-closure.md")]
        if phase not in declared:
            r.bad(f"{f.relative_to(led.root)}: 페이즈 `{phase}` 가 어느 아크의 "
                  f"phases 에도 없다")
    # 미전사분 블록의 대조를 걷었다. 그 문면이 청사진에만 살고 `patches` 가 계획 변경만 들게
    # 되어 맞댈 상대를 잃었기 때문이다. 블록을 든 앞 판의 종료 문서는 역사 기록이라 그대로
    # 두며, 이 검사가 블록을 읽지 않으므로 그것들이 걸리지 않는다(SPEC §2).
    r.note(f"종료 문서 {len(docs)}건")
    return r


# 검사 35 가 읽는 문서 양식. 한 줄은 `DOCFORM=<디렉터리>|<종류>|<값>` 이고 디렉터리는
# `docs/` 를 기준으로 한 상대 경로이며 루트는 `.` 으로 적는다.
DOCFORM_BLOCK = re.compile(r"<!-- DOCFORM:BEGIN -->\n(.*?)<!-- DOCFORM:END -->", re.S)


DOCFORM_LINE = re.compile(r"^DOCFORM=([^|]*)\|([^|]*)\|(.*)$")


# 검사 35 의 실패 문면. 적발한 뒤의 질의가 이 검사에 요구된 것이므로 이름을 맞추지 말라고
# 적되, 어떤 이름이면 통과하는지는 적지 않는다. 적으면 합의되지 않은 양식이 합의된 이름을
# 입고 들어온다(SPEC §2.1).
DOCFORM_HEAD = "합의되지 않은 형태의 문서 유입 시도"


DOCFORM_ASK = "그 이름을 맞추지 말고 결정 세션에 묻는다"


# 번호를 묶는 명명 그룹의 이름. 이 그룹을 든 패턴 줄에만 같은 디렉터리의 번호 중복과 결번을
# 본다. 그룹이 없는 줄에서는 아무것도 더하지 않으며, 종료 문서의 꼴이 그 경우다. 그 꼴은 번호가
# 같으면 이름도 같아 구조적으로 겹칠 수 없기 때문이다(SPEC §2.1).
DOCFORM_NUM_GROUP = "docnum"


# 검사 41 이 읽는 R-11 지목의 재기. `docs/baseline.md` §5 의 `R11` 블록이 거리와 면제 항목의
# 목록을 들며, 값을 코드에 박지 않고 그 블록이 들게 한다(SPEC §2.1).
R11_BLOCK = re.compile(r"<!-- R11:BEGIN -->\n(.*?)<!-- R11:END -->", re.S)


R11_DIST_LINE = re.compile(r"^R11_DIST=(\d+)$")


R11_EXEMPT_LINE = re.compile(r"^R11_EXEMPT=(\S+)$")


# 검사 41 의 유니버스. 네 레지스터의 산문 필드 여섯이다. 원장 ID 를 드는 필드와 분류를 드는
# 필드는 산문이 아니라 뺀다.
R11_FIELDS = ("statement", "basis", "reason", "candidate", "for", "original")


# 지목을 가리키는 낱말. 규율 ID 토큰 뒤 `R11_DIST` 자 안에 이것이 따르면 적발이다.
R11_WORD = "주석"


# 검사 41 이 읽는 갈래별 적발 계수. `docs/baseline.md` §5 의 `POINTER` 블록이며 **그 값은 이
# 검사가 처음 설 때 이 검사 자신이 낸 것이다.** 그 계수가 아래 패턴의 꼴에 달려 있으므로 블록과
# 탐지기를 같은 코드에서 나오게 두며, 그 꼴을 바꾸는 회차가 블록을 함께 고친다. 둘을 다른 코드로
# 두면 어느 쪽이 옳은지 맞댈 상대가 없어지고, 그 어긋남이 실제로 한 번 섰다(SPEC §2.1).
POINTER_BLOCK = re.compile(r"<!-- POINTER:BEGIN -->\n(.*?)<!-- POINTER:END -->", re.S)


POINTER_LINE = re.compile(r"^(POINTER_[A-Z]+)=(\d+)$")


POINTER_KEYS = ("POINTER_COMMENT", "POINTER_EPHEMERAL", "POINTER_SECTION")


# 유니버스에서 빼는 것은 원장 네 파일뿐이다. 그 산문 필드를 아래의 R-11 갈래가 따로 받으므로
# 파일로 훑지 않는다. **추출 기록은 이제 유니버스에 든다.** 그 디렉터리를 빼던 근거가 인용한 편
# 자신의 절 번호를 구조적으로 많이 든다는 것이었는데, 기록의 번호가 앞에 오는 절 번호를 면제하는
# 아래 규칙이 그 사이에 서서 그 근거가 소멸했다.
# 갈래 2 의 꼴. 소진 문서가 자기 안에서 쓰는 조작 표지와 그 문서의 파일 이름 접두사다. 그 둘은
# 페이즈가 끝나면 이관되어 도달 불가가 되므로 리포에 남는 문면이 그것을 지목하면 열 수 없다.
POINTER_TAG = re.compile(r"(?<![0-9A-Za-z])[A-Z]\d+-O\d+(?![0-9A-Za-z])")


POINTER_EPHEMERAL_FILE = re.compile(r"IMPLEMENTATION_PLAN|ENTRY_CARD")


# 갈래 3 의 꼴과 그 면제 둘. 출처 표지가 앞에 오는 자리는 규율 조항의 역추적을 붙인 자리이고,
# 리포 안 문서의 이름이 앞에 오면 그 절이 그 경로로 열린다. 자기 문서의 절 제목에 선 번호는
# 그 문서가 자기 절을 가리키는 것이므로 적발로 세지 않으며, 그 제목은 머리 기호로 시작하는
# 줄과 굵은 표지로 시작하는 줄에서 모은다.
POINTER_SECTION_NO = re.compile(r"§\s*(\d+(?:[.-]\d+)*)")


POINTER_OWN_HEADING = re.compile(r"^(?:#+|\*\*)\s*(\d+(?:[.-]\d+)*)")


POINTER_SOURCE_MARK = "←"


POINTER_DOC_NAME = re.compile(
    r"SPEC\.md|baseline\.md|CLAUDE\.md|BUILD_LOG\.md|arcs\.json"
    r"|reading-queue|bundle-inventory|docs/|scripts/")


# 갈래 3 의 면제 하나가 더 선다. 추출 기록의 번호가 앞에 오면 그 절 번호는 리포 안의 기록
# 파일에 일대일로 대응하여 리포 안에서 열리므로 애초에 금지의 대상이 아니다. 면제하지 않으면
# 그 꼴을 쓰는 자리가 전부 적발로 서서 블록의 값이 금지된 지목이 아니라 정상 지목의 계수를
# 든다(SPEC §2.1).
POINTER_EXTRACTION_NO = re.compile(r"(?<![0-9A-Za-z])E-\d{1,2}(?![0-9A-Za-z])")


# 갈래 3 의 면제가 하나 더 선다. 추출 기록의 파일 이름이 앞에 오면 그 절 번호는 그 이름이 가리키는
# 기록 파일로 리포 안에서 열리므로, 앞의 번호 꼴과 같은 사유로 애초에 금지의 대상이 아니다. 꼴은
# 그 파일 이름의 머리인 `extraction-` 과 두 자리 번호까지이며, 그 뒤에 이어지는 이름의 나머지와
# 확장자는 묻지 않는다. 그래서 번호까지만 줄여 드는 꼴과 이름 전체를 드는 꼴이 함께 면제된다.
# 번호의 자릿수는 `docs/baseline.md` 의 `DOCFORM` 블록이 추출 기록의 이름에 거는 형과 같다.
POINTER_EXTRACTION_FILE = re.compile(r"(?<![0-9A-Za-z])extraction-[0-9]{2}(?![0-9])")


def pointer_block(led: Ledger) -> dict[str, int]:
    """`POINTER` 블록이 든 갈래별 적발 계수."""
    got: dict[str, int] = {}
    for line in _baseline_block(led, POINTER_BLOCK).splitlines():
        m = POINTER_LINE.match(line)
        if m:
            got[m.group(1)] = int(m.group(2))
    return got


def pointer_hits(targets: list[tuple[str, str]], dist: int) -> dict[str, list[str]]:
    """갈래별 적발의 자리. 키는 `POINTER_KEYS` 이고 값은 `<경로>:<줄> <적발한 꼴>` 이다.

    **블록을 심는 쪽과 그것을 맞대는 쪽이 이 하나를 함께 쓴다.** 두 자리에 전사하면 한쪽을
    고칠 때 다른 쪽이 조용히 낡고, 그 둘이 다른 수를 내는 것을 어느 검사도 잡지 못한다.

    유니버스를 인자로 받는 까닭은 그 수집기가 파일 전량을 읽으므로 부르는 쪽이 그 수를 함께
    쓸 때 두 번 읽게 되는 것이다.
    """
    out: dict[str, list[str]] = {k: [] for k in POINTER_KEYS}
    for rel, text in targets:
        lines = text.splitlines()
        # 그 문서 자신의 절 제목에 선 번호. 자기 절을 가리키는 것은 적발이 아니다.
        own = {m.group(1) for ln in lines
               for m in [POINTER_OWN_HEADING.match(ln)] if m}
        for i, ln in enumerate(lines, 1):
            for m in RULE_TOKEN.finditer(ln):
                if R11_WORD in ln[m.end():m.end() + dist]:
                    out["POINTER_COMMENT"].append(f"{rel}:{i} `{m.group(0)}`")
            for m in POINTER_TAG.finditer(ln):
                out["POINTER_EPHEMERAL"].append(f"{rel}:{i} `{m.group(0)}`")
            for m in POINTER_EPHEMERAL_FILE.finditer(ln):
                out["POINTER_EPHEMERAL"].append(f"{rel}:{i} `{m.group(0)}`")
            for m in POINTER_SECTION_NO.finditer(ln):
                head = ln[:m.start()]
                if (POINTER_SOURCE_MARK in head or POINTER_DOC_NAME.search(head)
                        or POINTER_EXTRACTION_NO.search(head)
                        or POINTER_EXTRACTION_FILE.search(head)):
                    continue
                if m.group(1) in own:
                    continue
                out["POINTER_SECTION"].append(f"{rel}:{i} `{m.group(0)}`")
    return out


def r11_rules(led: Ledger) -> tuple[int | None, set[str]]:
    """`R11` 블록이 든 거리와 면제 항목의 id."""
    dist: int | None = None
    exempt: set[str] = set()
    for line in _baseline_block(led, R11_BLOCK).splitlines():
        m = R11_DIST_LINE.match(line)
        if m:
            dist = int(m.group(1))
            continue
        m = R11_EXEMPT_LINE.match(line)
        if m:
            exempt.add(m.group(1))
    return dist, exempt


def check_35(led: Ledger) -> Report:
    r = Report("35", "wiki35-doc-form",
               "docs/ 아래의 파일과 디렉터리가 DOCFORM 블록이 든 형에 드는가", "fail")
    rows: dict[str, list[tuple[str, str]]] = {}
    for line in _baseline_block(led, DOCFORM_BLOCK).splitlines():
        m = DOCFORM_LINE.match(line)
        if m:
            rows.setdefault(m.group(1), []).append((m.group(2), m.group(3)))
    # 블록이 비어 있으면 통과가 아니라 실패다. 검사 28 과 34 가 같은 요구를 둔다.
    if not rows:
        r.bad("docs/baseline.md 의 DOCFORM 블록이 없거나 비어 있다")
        return r

    # `<ARC>` 를 아크 이름 전량의 택일로 바꾼다. 아크 이름을 블록에 적지 않는 것은 그 값을
    # 레지스터가 닫기 때문이다(SPEC §2.1).
    arc_alt = "|".join(re.escape(a) for a in sorted(led.arcs)) or r"(?!)"
    forms: dict[str, list[tuple[str, str, re.Pattern | None]]] = {}
    for d in sorted(rows):
        for kind, val in rows[d]:
            if kind == "name":
                forms.setdefault(d, []).append((kind, val, None))
            elif kind == "pattern":
                try:
                    rx = re.compile(val.replace("<ARC>", f"(?:{arc_alt})"))
                except re.error as exc:
                    r.bad(f"DOCFORM 블록의 패턴 `{val}` 이 정규식으로 컴파일되지 않는다: {exc}")
                    continue
                forms.setdefault(d, []).append((kind, val, rx))
            else:
                r.bad(f"DOCFORM 블록의 종류 `{kind}` 가 name 도 pattern 도 아니다")
    if r.violations:
        return r

    base = led.root / "docs"
    if not base.is_dir():
        r.bad("docs/ 디렉터리가 없다")
        return r
    # 파일시스템을 훑고 `git ls-files` 를 쓰지 않는다. 추적되지 않은 채 그 자리에 놓인
    # 문서도 유입이고, 추적 여부로 가르면 `.gitignore` 가 가린 것이 함께 가려진다.
    dirs = sorted(p for p in base.rglob("*") if p.is_dir())
    files = sorted(p for p in base.rglob("*") if p.is_file())
    for p in dirs:
        rel = p.relative_to(base).as_posix()
        if rel not in rows:
            r.bad(f"{DOCFORM_HEAD} — docs/{rel}/ 가 허용된 디렉터리가 아니다. {DOCFORM_ASK}")
    per: dict[str, int] = {}
    for p in files:
        rel = p.relative_to(base)
        d = rel.parent.as_posix()
        per[d] = per.get(d, 0) + 1
        items = forms.get(d)
        if items is None:
            continue          # 그 디렉터리가 허용 밖인 것은 위에서 이미 들었다
        # 한 디렉터리에 행이 여럿이면 하나라도 맞으면 통과한다.
        if any(val == rel.name if rx is None else rx.fullmatch(rel.name)
               for _kind, val, rx in items):
            continue
        r.bad(f"{DOCFORM_HEAD} — docs/{rel.as_posix()} 가 그 디렉터리에 허용된 어느 형에도 "
              f"맞지 않는다. {DOCFORM_ASK}")
    # 번호를 묶는 명명 그룹을 든 패턴 줄에만 같은 디렉터리의 번호 중복과 결번을 더해 본다.
    # 번호 중복은 그 이름이 무엇을 가리키는지를 되돌릴 수 없게 하므로 실패이고, 결번은 어긋남이
    # 아니라 보고다. 원장이 수정 불가여서 그 번호를 지목한 항목이 이미 실려 있으면 중복을 고칠
    # 수단이 없고, 번호를 배정하다 쓰지 않은 자리가 남는 것은 정상이며 다음 번호를 고를 때 그
    # 자리가 보이는 것이 값이다(SPEC §2.1).
    for d in sorted(forms):
        for _kind, val, rx in forms[d]:
            if rx is None or DOCFORM_NUM_GROUP not in rx.groupindex:
                continue
            seen: dict[str, list[str]] = {}
            for p in files:
                rel = p.relative_to(base)
                if rel.parent.as_posix() != d:
                    continue
                m = rx.fullmatch(rel.name)
                if m:
                    seen.setdefault(m.group(DOCFORM_NUM_GROUP), []).append(rel.name)
            for k in sorted(k for k, v in seen.items() if len(v) > 1):
                r.bad(f"docs/{d}/ 에서 번호 `{k}` 를 가진 파일이 {len(seen[k])} 개다: "
                      + ", ".join(sorted(seen[k])))
            nums = sorted(int(k) for k in seen)
            missing = [n for n in range(nums[0], nums[-1] + 1) if n not in set(nums)] \
                if nums else []
            w = max((len(k) for k in seen), default=0)
            r.note(f"docs/{d}/ 의 `{val}` — 그 꼴에 든 파일 "
                   f"{sum(len(v) for v in seen.values())} · 서로 다른 번호 {len(seen)} "
                   f"· 결번 {len(missing)}"
                   + (" (" + ", ".join(f"{n:0{w}d}" for n in missing) + ")"
                      if missing else ""))
    r.note(f"docs/ 의 파일 {len(files)} · 디렉터리 {len(dirs)} · 허용 디렉터리 {len(rows)}")
    r.note("디렉터리별 파일: "
           + " · ".join(f"{k} {per[k]}" for k in sorted(per)))
    return r


# 검사 36 이 읽는 무시 파일. 루트의 추적 대상 목록이 그 파일에 이미 실물로 서 있으므로 값
# 정본에 블록을 두지 않고 이 검사가 그 파일을 직접 읽는다. 블록을 두면 같은 목록이 두 자리에
# 살고 한쪽을 고칠 때 나머지가 조용히 낡는다(SPEC §0.2).
IGNORE_FILE = ".gitignore"


IGNORE_ALL = "/*"


IGNORE_REVIVE = re.compile(r"^!/(\S+)$")


# 산문이 든 계수를 읽는 꼴과 한글 수사의 표. 그 대조가 숫자 비교가 아니므로 수사를 값으로
# 읽어야 한다. 표 밖의 수사는 실패로 내며 표를 늘릴지는 사람이 정한다.
IGNORE_PROSE = re.compile(r"([가-힣]+) 파일과 ([가-힣]+) 디렉터리")


KO_NUMERAL = {"하나": 1, "둘": 2, "셋": 3, "넷": 4, "다섯": 5, "여섯": 6, "일곱": 7,
              "여덟": 8, "아홉": 9, "열": 10, "열하나": 11, "열둘": 12, "열셋": 13,
              "열넷": 14, "열다섯": 15, "열여섯": 16, "열일곱": 17, "열여덟": 18,
              "열아홉": 19, "스물": 20}


def check_36(led: Ledger) -> Report:
    r = Report("36", "wiki36-root-surface",
               "무시 파일의 루트 되살림 목록이 /* 뒤에 서고, 그 항마다 루트에 실물이 있으며 "
               "산문이 든 계수와 목록의 계수가 같은가", "fail")
    path = led.root / IGNORE_FILE
    if not path.is_file():
        r.bad(f"{IGNORE_FILE} 이 없다")
        return r
    lines = path.read_text(encoding="utf-8").splitlines()
    revive = [(i, m.group(1)) for i, ln in enumerate(lines, 1)
              for m in [IGNORE_REVIVE.match(ln.strip())] if m]
    # ㉠ 닫힌 형. 그 줄이 사라지면 되살림 줄이 전부 무의미해지고 루트가 조용히 열린다.
    # **이 판정이 이 검사가 사는 자리다.** 양식을 새로 지어내도 자동으로 무시된다는 것이 그
    # 형에 걸려 있으므로, 형이 깨지면 그 보호가 함께 사라진다.
    at = next((i for i, ln in enumerate(lines, 1) if ln.strip() == IGNORE_ALL), None)
    if at is None:
        r.bad(f"{IGNORE_FILE} 에 `{IGNORE_ALL}` 줄이 없다. 루트가 통째로 열려 있다")
    elif revive and at > revive[0][0]:
        r.bad(f"{IGNORE_FILE}:{at}: `{IGNORE_ALL}` 줄이 되살림 목록보다 뒤에 선다")
    if not revive:
        r.bad(f"{IGNORE_FILE} 에 루트 되살림 줄이 없다")
        return r
    # ㉡ 목록의 위생. 파일을 지우거나 이름을 바꾸면 목록이 유령을 든다.
    n_file = n_dir = 0
    for i, item in revive:
        want_dir = item.endswith("/")
        target = led.root / item.rstrip("/")
        if not target.exists():
            r.bad(f"{IGNORE_FILE}:{i}: 되살림 항 `{item}` 의 실물이 루트에 없다")
            continue
        if want_dir and not target.is_dir():
            r.bad(f"{IGNORE_FILE}:{i}: 되살림 항 `{item}` 이 디렉터리 꼴인데 실물이 파일이다")
        elif not want_dir and not target.is_file():
            r.bad(f"{IGNORE_FILE}:{i}: 되살림 항 `{item}` 이 파일 꼴인데 실물이 디렉터리다")
        if want_dir:
            n_dir += 1
        else:
            n_file += 1
    # ㉢ 산문의 계수. 항을 더하면서 산문을 고치지 않는 것을 잡는다.
    comment = " ".join(ln.lstrip("#").strip() for ln in lines
                       if ln.lstrip().startswith("#"))
    m = IGNORE_PROSE.search(comment)
    if m is None:
        r.bad(f"{IGNORE_FILE} 의 주석이 되살림 목록의 계수를 "
              f"「<수사> 파일과 <수사> 디렉터리」 꼴로 들지 않는다")
    else:
        for word, counted, what in ((m.group(1), n_file, "파일"),
                                    (m.group(2), n_dir, "디렉터리")):
            said = KO_NUMERAL.get(word)
            if said is None:
                r.bad(f"{IGNORE_FILE} 의 주석이 든 수사 `{word}` 를 값으로 읽을 수 없다")
            elif said != counted:
                r.bad(f"{IGNORE_FILE} 의 주석이 {what}을 `{word}`({said}) 로 드는데 "
                      f"목록이 든 것은 {counted} 이다")
    r.note(f"되살림 항 {len(revive)} (파일 {n_file} · 디렉터리 {n_dir}) · "
           f"`{IGNORE_ALL}` 줄 {at if at else '없다'}")
    r.note("우변에서 좌변으로 훑지 않는다. 루트에 추적되지 않는 것이 있는 것은 정상이며 "
           "지시서와 엔트리 카드가 그 부류다(SPEC §2.1)")
    return r


# 검사 37 이 읽는 집행 문면의 원장 계수 표. 좌변이 그 표의 행이고 우변이 레지스터 배열의
# 길이다. 그 문면이 「계수는 손으로 세지 않고 검증기의 출력에서 읽는다」를 관례로만 들고
# 있어서, 병합하는 회차가 그 표를 고치지 않아도 아무것도 걸리지 않았다(SPEC §2.1).
LEDGER_COUNT_DOC = "CLAUDE.md"


LEDGER_COUNT_HEAD = "| 레지스터 | entry |"


LEDGER_COUNT_ROW = re.compile(r"^\|\s*(\w+)\s*\|\s*(\d+)\s*\|$")


def check_37(led: Ledger) -> Report:
    r = Report("37", "wiki37-claude-ledger-count",
               "집행 문면의 원장 계수 표가 레지스터 넷을 전부 들고 행마다 적힌 수가 그 "
               "레지스터의 배열 길이와 같은가", "fail")
    path = led.root / LEDGER_COUNT_DOC
    if not path.is_file():
        r.bad(f"{LEDGER_COUNT_DOC} 이 없다")
        return r
    lines = path.read_text(encoding="utf-8").splitlines()
    head = [i for i, ln in enumerate(lines) if ln.strip() == LEDGER_COUNT_HEAD]
    # 표가 없으면 통과가 아니라 실패다. 검사 28 과 34 와 35 가 같은 요구를 둔다.
    if len(head) != 1:
        r.bad(f"{LEDGER_COUNT_DOC} 에 원장 계수 표의 머리 `{LEDGER_COUNT_HEAD}` 가 "
              f"{len(head)}개다")
        return r
    said: dict[str, int] = {}
    for ln in lines[head[0] + 2:]:
        m = LEDGER_COUNT_ROW.match(ln.strip())
        if not m:
            break
        said[m.group(1)] = int(m.group(2))
    # 우변을 새로 세지 않고 검증기의 수집기를 부른다. 출력의 머리가 싣는 계수와 같은 자리다.
    real = {name: len(led.reg[name]) for name in REGISTERS}
    for name in sorted(set(said) | set(real)):
        if name not in said:
            r.bad(f"{LEDGER_COUNT_DOC} 의 원장 계수 표가 레지스터 `{name}` 의 행을 들지 않는다")
        elif name not in real:
            r.bad(f"{LEDGER_COUNT_DOC} 의 원장 계수 표가 레지스터가 아닌 `{name}` 의 행을 든다")
        elif said[name] != real[name]:
            r.bad(f"{LEDGER_COUNT_DOC} 의 원장 계수 표가 `{name}` 을 {said[name]} 로 드는데 "
                  f"그 배열의 길이가 {real[name]} 이다")
    r.note("표의 행 " + (" · ".join(f"{k} {said[k]}" for k in sorted(said)) or "없다"))
    r.note("배열의 길이 " + " · ".join(f"{k} {real[k]}" for k in sorted(real)))
    return r


def check_41(led: Ledger) -> Report:
    r = Report("41", "wiki41-pointer-scope",
               "리포의 영구 문면이 리포 밖에서만 뜻을 갖는 식별자를 지목하는가", "fail")
    dist, exempt = r11_rules(led)
    # 블록을 읽지 못하면 통과가 아니라 실패다. 거리가 없으면 재기가 서지 않고 면제가 비면
    # 이미 실린 열여덟이 전부 적발로 나므로, 둘 다 맞댈 상대가 없는 것이다(SPEC §2.1).
    if dist is None:
        r.bad("docs/baseline.md 의 R11 블록에 R11_DIST 가 없다")
        return r
    if not exempt:
        r.bad("docs/baseline.md 의 R11 블록에 R11_EXEMPT 가 하나도 없다")
        return r
    # 면제 항이 원장에 없으면 그 항이 조용히 비어 목록만 넓어진 것을 알 수 없다. 검사 33 이
    # 예약 낱말의 실재를 단언하는 것과 같은 형이다(SPEC §2.1).
    for eid in sorted(exempt):
        if eid not in led.by_id:
            r.bad(f"R11 블록의 면제 항 `{eid}` 이 원장에 없다")
    hit = 0
    waived: set[str] = set()
    for _name, e in led.entries:
        eid = str(e.get("id"))
        for f in R11_FIELDS:
            s = str(e.get(f) or "")
            # 규율 ID 의 꼴은 검사 23·24 가 쓰는 것을 그대로 쓴다. 꼴을 다시 짜면 한쪽을
            # 고칠 때 다른 쪽이 조용히 낡는다. 원장 ID 의 접두사 `CF` 는 그 계열에 없고
            # 토큰의 앞을 막는 자리가 `CF-1070` 의 `F` 를 걸러 유니버스에서 저절로 빠진다.
            for m in RULE_TOKEN.finditer(s):
                if R11_WORD not in s[m.end():m.end() + dist]:
                    continue
                if eid in exempt:
                    waived.add(eid)
                    continue
                hit += 1
                r.bad(f"{eid}: {f} 의 `{m.group(0)}` 뒤 {dist} 자 안에 "
                      f"`{R11_WORD}` 이 따른다")
    r.note(f"R-11 갈래의 유니버스는 네 레지스터의 산문 필드 {len(R11_FIELDS)} "
           f"· 거리 R11_DIST={dist} · 면제 항 {len(exempt)}")
    r.note(f"R-11 갈래의 적발 {hit} · 면제 목록으로 넘긴 항목 {len(waived)}")

    # 두 번째 몫. 리포의 영구 문면이 리포 밖에서만 뜻을 갖는 식별자를 지목하는가를 갈래 셋으로
    # 나누어 세고 값 정본의 블록과 맞댄다. **늘면 실패시키고 줄면 통과시킨다.** 그 조항이
    # 소급하지 않으므로 이미 쓰인 문면이 전량 적발로 나오며, 계수를 고정해 앞으로 쓰는 문면이
    # 그 수를 늘리는 자리를 막는 것이 이 몫의 처분이다.
    #
    # **갈래마다 따로 맞대는 까닭은 합으로 맞대면 한 갈래를 고치고 다른 갈래를 더해도 통과한다는
    # 것이다.** 앞의 R-11 갈래를 이 계수에 섞지 않는 까닭도 같다. 그 갈래는 적발 하나로 바로
    # 실패해야 하는데 계수로 맞대면 다른 자리가 줄어든 회차에 그것이 가려진다.
    want = pointer_block(led)
    if not want:
        r.bad("docs/baseline.md 의 POINTER 블록을 읽을 수 없다")
        return r
    missing = [k for k in POINTER_KEYS if k not in want]
    if missing:
        r.bad("POINTER 블록에 " + " · ".join(missing) + " 이 없다")
        return r
    targets = led.pointer_scan_targets()
    hits = pointer_hits(targets, dist)
    fields = sum(1 for rel, _ in targets if rel.startswith(ARCS_DOC + POINTER_ARCS_MARK))
    r.note(f"지목 범위 갈래의 유니버스는 영구 문면 {len(targets)} 개"
           f" · 그 가운데 아크 값 정본의 산문 필드 {fields} · 유니버스 밖: 원장 네 파일")
    for key in POINTER_KEYS:
        got = len(hits[key])
        if got > want[key]:
            r.bad(f"{key} 의 적발이 {got} 인데 값 정본의 블록이 {want[key]} 를 든다. "
                  f"{got - want[key]} 만큼 늘었다")
            # 어느 파일에서 늘었는지를 파일별 계수로 낸다. 적발의 자리를 전량 열거하면 역사
            # 기록의 몫이 수백 줄로 나서 새로 선 자리가 그 안에 묻히는데, 파일별 계수는 앞
            # 회차의 기록과 맞대어 그 자리를 좁힐 수 있다.
            per: dict[str, int] = {}
            for place in hits[key]:
                per[place.split(":")[0]] = per.get(place.split(":")[0], 0) + 1
            for rel, n in sorted(per.items(), key=lambda x: (-x[1], x[0])):
                r.note(f"{key} — {rel} {n}")
        elif got < want[key]:
            r.note(f"{key} 의 적발 {got} 가 블록의 {want[key]} 보다 "
                   f"{want[key] - got} 적다. 그 자리가 정리된 것이므로 통과시키며, 블록의 그 "
                   f"키를 같은 회차에 함께 내리는 것은 결정 세션의 조작이다")
        else:
            r.note(f"{key} 의 적발 {got} 가 블록의 값과 같다")
    return r


def check_43(led: Ledger) -> Report:
    r = Report("43", "wiki43-extraction-trigger-age",
               "살아 있는 extraction 트리거 가운데 발화할 수 없는 것과 "
               "발화할 수 있는데 깨우지 않은 항의 나이", "report")
    live = [e for e in led.reg["deferred"]
            if isinstance(e.get("reopen_when"), dict)
            and e["reopen_when"].get("kind") == "extraction"
            and e.get("id") not in led.dead]
    cannot: list[str] = []
    stale: list[str] = []
    for e in live:
        eid = str(e.get("id"))
        ref = str(e["reopen_when"].get("ref") or "")
        n = extraction_ref_number(ref)
        if n is None:
            cannot.append(f"{eid} — `ref` 가 번호로 읽히지 않는다: {ref!r}")
            continue
        f = extraction_record(led, n)
        if f is None:
            cannot.append(f"{eid} — 번호 {n:02d} 의 추출 기록이 아직 없다")
            continue
        origin = e.get("origin") or {}
        phase = str(origin.get("phase") or "")
        closed = phases_closed_after(led, phase)
        age = "셀 자리가 없다" if closed is None else f"{closed}"
        stale.append(f"{eid} — 선 날 {origin.get('date')} · 그 뒤로 닫힌 페이즈 {age} · "
                     f"`{f.name}` 이 섰다")
    # 둘을 한 검사로 묶는 까닭은 같은 유니버스를 재기 때문이다. 따로 세우면 한쪽을 고칠 때 다른
    # 쪽이 조용히 낡고, 둘이 다른 수를 내는 것을 어느 검사도 잡지 못한다(SPEC §2.2).
    r.note(f"유니버스는 살아 있는 extraction 트리거 {len(live)}건")
    r.note(f"발화할 수 없는 항 {len(cannot)}건")
    for line in cannot:
        r.note(line)
    r.note(f"발화할 수 있는데 깨우지 않은 항 {len(stale)}건")
    for line in stale:
        r.note(line)
    return r


def check_49(led: Ledger) -> Report:
    r = Report("49", "wiki49-extraction-unpointed",
               "어느 형식층 docstring 도 지목하지 않는 추출 기록의 계수와 번호", "report")
    d = led.root / "docs" / "extractions"
    files = sorted(d.glob("extraction-*.md")) if d.is_dir() else []
    # 지목의 수집기를 검사 48 과 나누어 쓴다. 꼴을 다시 짜면 한쪽을 고칠 때 다른 쪽이 조용히
    # 낡고, 그 낡음은 이 보고의 계수가 그 검사의 유니버스와 갈리는 꼴로만 남는다.
    ptrs = doc_pointers(led)
    pointed = {n for _rel, _line, n, _sec in ptrs}
    rows: list[tuple[int, str]] = []
    for f in files:
        m = EXTRACTION_FILE_NO.match(f.name)
        if m is None:
            continue          # 이름의 꼴은 검사 35 가 받는다
        n = int(m.group(1))
        if n not in pointed:
            rows.append((n, f.name))
    r.note(f"유니버스는 추출 기록 {len(files)} · 형식층 docstring 의 지목 {len(ptrs)} "
           f"· 그 지목이 가리킨 기록 {len(pointed)}")
    r.note(f"어느 형식층 docstring 도 지목하지 않는 기록 {len(rows)}건")
    for n, name in sorted(rows):
        r.note(f"E-{n:02d} — {name}")
    return r


MIRROR_BLOCK = re.compile(r"<!-- MIRROR:BEGIN -->\n(.*?)<!-- MIRROR:END -->", re.S)


MIRROR_GHOST_LINE = re.compile(r"^MIRROR_GHOST=(\d+)$")


# 나열 줄의 구성원 꼴. 보조 묶음의 절이 편을 표의 행이 아니라 「제목 (연도, 번호)」 로 들며, 괄호
# 안의 첫 자리가 네 자리 연도이고 마지막 자리가 기록 번호다. 연도를 요구하는 까닭은 산문 줄이
# 괄호 안에 기록 번호만 드는 꼴(「기록 하나(E-44)」)을 구성원으로 읽지 않는 것이다.
INVENTORY_LIST_MEMBER = re.compile(r"\(\s*\d{4}[^()]*?,\s*E-(\d{1,2})\s*\)")


# 검사 50 의 미추출 축이 읽는 편 제목의 꼴. 추출 기록의 머리 곧 첫 `#` 제목 뒤에 처음 서는 문단에서
# 찾으며, 제목이 줄을 넘어 이어지므로 그 문단의 줄을 공백 하나로 이어 붙인 뒤 찾는다. 꼴은 둘이다.
# 발행 주체에 붙는 굵은 기울임 꼴(`**발행 주체, *제목***`)과 저자와 연도에 붙는 인용부호 꼴
# (`**저자 (연도), "제목"`)이며, 한 꼴만 받으면 우변의 기록 대부분이 그 밖으로 떨어진다(SPEC §2.1).
#
# **굵은 글씨의 여는 표지를 공백이나 문단 머리 뒤로 묶고, 그 표지 뒤의 칸이 인용부호와 별표를 품지
# 않게 한다.** 인용부호 꼴의 머리가 닫는 표지 뒤의 괄호 안에 게재지를 기울임으로 드는 자리가 있는데,
# 그 닫는 표지를 여는 표지로 읽으면 게재지의 이름이 편 제목으로 들어온다. 목적 칸이 앞선 기록을
# 인용부호로 드는 자리도 같은 묶음이 거른다.
EXTRACTION_TITLE_QUOTED = re.compile(r'(?<!\S)\*\*(?=\S)[^*"]+?,\s*"([^"]+)"')


EXTRACTION_TITLE_ITALIC = re.compile(r'(?<!\S)\*\*(?=\S)[^*"]+?,\s*\*([^*]+?)\*')


# 두 정규화 문면의 짧은 쪽을 긴 쪽으로 나눈 값의 문턱이며, 그 값이 문턱 아래이면 포함을 받지
# 않는다(SPEC §2.1). 짧은 편 제목이 같은 계열의 긴 제목에 들어가는 자리가 거짓 양성이고, 인벤토리가
# 제목 앞에 발행자를 붙여 드는 자리가 받아야 할 쪽이므로 문턱이 그 둘 사이에 선다. 이 축이 처음 선
# 판에서 앞쪽 비의 최댓값이 0.342 이고 뒤쪽 비가 0.835 였으므로, 그 사이에서 절반을 고른다.
INVENTORY_TITLE_RATIO = 0.5


def extraction_titles(text: str) -> list[str]:
    """추출 기록의 머리가 드는 편 제목. 머리는 첫 `#` 제목 뒤에 처음 서는 문단이다."""
    para: list[str] = []
    started = False
    for ln in text.splitlines():
        if not started:
            started = ln.startswith("# ")
            continue
        if not ln.strip():
            if para:
                break
            continue
        para.append(ln.strip())
    head = " ".join(para)
    found = EXTRACTION_TITLE_QUOTED.findall(head) + EXTRACTION_TITLE_ITALIC.findall(head)
    return [x.strip() for x in found if x.strip()]


def title_key(s: str) -> str:
    """공백과 대소문자와 구두점을 지운 꼴. 글자와 숫자만 남기며 한글도 글자로 남는다."""
    return "".join(ch for ch in s.casefold() if ch.isalnum())


def title_ratio(a: str, b: str) -> float | None:
    """정규화한 두 문면이 어느 방향으로든 포함되면 짧은 쪽을 긴 쪽으로 나눈 값을 내고, 아니면 None."""
    if not a or not b or not (a in b or b in a):
        return None
    return min(len(a), len(b)) / max(len(a), len(b))


def inventory_members(text: str) -> tuple[dict[int, list[int]], int, int]:
    """구성원 행이 드는 기록 번호와 그 번호가 선 줄. (번호 → 줄 번호 목록, 표의 행 수, 나열 줄 수).

    **구성원 행은 표의 행과 나열 줄 둘이다.** 표의 행은 머리와 구분 줄을 뺀 본문 행이며 그 칸
    전량에서 번호를 모은다. 나열 줄은 표의 행이 아닌 줄 가운데 「제목 (연도, 번호)」 의 꼴을 든
    줄이고 그 꼴 안의 번호만 모은다. 산문 줄은 그 꼴을 들지 않으므로 좌변에 들지 않는다.
    """
    out: dict[int, list[int]] = {}
    lines = text.splitlines()
    n_rows = n_lists = 0
    i = 0
    while i < len(lines):
        head = md_cells(lines[i])
        rule = md_cells(lines[i + 1]) if i + 1 < len(lines) else None
        if head and rule and all(SPEC_TABLE_RULE.match(c) for c in rule if c):
            j = i + 2
            while j < len(lines):
                body = md_cells(lines[j])
                if body is None:
                    break
                n_rows += 1
                for c in body:
                    for m in INVENTORY_EXTRACTION_NO.finditer(c):
                        out.setdefault(int(m.group(1)), []).append(j + 1)
                j += 1
            i = j
            continue
        found = INVENTORY_LIST_MEMBER.findall(lines[i])
        if found:
            n_lists += 1
            for x in found:
                out.setdefault(int(x), []).append(i + 1)
        i += 1
    return out, n_rows, n_lists


def _check_50_unread(led: Ledger, r: Report, files: dict[int, Path]) -> None:
    """검사 50 의 미추출 축. 미추출 표지를 든 구성원 행이 이미 추출된 편을 가리키는지 본다.

    좌변은 그 표지를 든 구성원 행의 비고 칸을 뺀 칸 전량이고 우변은 추출 기록의 머리가 드는 편
    제목이다. **번호 대조와 축을 가른다.** 번호를 들지 않는 구성원 행을 번호 대조의 좌변에서 빼는
    요구가 그대로 서 있으므로, 이 축은 번호가 아니라 제목으로 그 행이 가리키는 편을 찾는다.
    구성원 행과 표지 낱말은 검사 53 과 54 가 쓰는 함수와 블록을 그대로 부른다. 전사하면 그 둘이
    꼴을 고칠 때 이 축이 조용히 낡는다. **적발은 0 을 요구한다**(SPEC §2.1).
    """
    marks = inventorymark_block(led)
    missing = [k for k in (INVENTORYMARK_AGGREGATE, INVENTORYMARK_UNREAD) if k not in marks]
    if missing:
        r.bad("docs/baseline.md 의 INVENTORYMARK 블록에 " + " · ".join(missing) + " 가 없다")
        return
    rows, _n_tables, _n_rows = inventory_member_rows(
        (led.root / INVENTORY_DOC).read_text(encoding="utf-8"), marks[INVENTORYMARK_AGGREGATE])
    unread = [(line, cells) for line, cells, _sec in rows
              if marks[INVENTORYMARK_UNREAD] in cells[-1]]
    titles: list[tuple[int, str, str]] = []
    untitled: list[int] = []
    for n in sorted(files):
        got = extraction_titles(files[n].read_text(encoding="utf-8"))
        if not got:
            untitled.append(n)
        titles += [(n, x, title_key(x)) for x in got]
    # 우변이 비면 어느 행도 걸리지 않아 0 으로 난다. 머리의 꼴이 바뀌어 제목을 하나도 읽지 못한
    # 것과 맞는 편이 없는 것이 갈리지 않으므로 통과시키지 않는다.
    if not titles:
        r.bad("docs/extractions/ 의 머리에서 편 제목을 하나도 읽지 못했다")
        return
    hits = below = 0
    for line, cells in unread:
        for c in cells[:-1]:
            k = title_key(c)
            for n, x, xk in titles:
                ratio = title_ratio(k, xk)
                if ratio is None:
                    continue
                if ratio < INVENTORY_TITLE_RATIO:
                    below += 1
                    r.note(f"문턱 아래의 포함 {INVENTORY_DOC}:{line} `{c}` 와 E-{n:02d} `{x}` "
                           f"(비 {ratio:.3f})")
                    continue
                hits += 1
                r.bad(f"{INVENTORY_DOC}:{line} 의 구성원 행이 미추출 표지를 드는데 그 칸 `{c}` 가 "
                      f"E-{n:02d} 의 편 제목 `{x}` 와 맞는다 (비 {ratio:.3f})")
    r.note(f"미추출 축의 좌변은 미추출 표지를 든 구성원 행 {len(unread)} · 우변은 기록 "
           f"{len(files) - len(untitled)} 의 편 제목 {len(titles)} · 적발 {hits} · 문턱 "
           f"{INVENTORY_TITLE_RATIO} 아래로 받지 않은 포함 {below}")
    if untitled:
        r.note("머리에서 편 제목을 읽지 못한 기록 " + " · ".join(f"E-{n:02d}" for n in untitled))


def check_50(led: Ledger) -> Report:
    r = Report("50", "wiki50-inventory-extraction-mirror",
               "뭉치 인벤토리의 구성원 행이 든 추출 기록 번호가 실재하는 기록을 가리키고, 추출 기록마다 "
               "그 번호를 드는 구성원 행이 인벤토리에 있는가", "fail")
    # 블록을 읽지 못하면 통과가 아니라 실패다. 값이 없으면 유령의 계수를 맞댈 상대가 없고, 그때
    # 통과시키면 새로 선 기록이 인벤토리의 행을 얻지 못한 채 조용히 들어온다(SPEC §2.1).
    ghost_cap: int | None = None
    for line in _baseline_block(led, MIRROR_BLOCK).splitlines():
        m = MIRROR_GHOST_LINE.match(line)
        if m:
            ghost_cap = int(m.group(1))
    if ghost_cap is None:
        r.bad("docs/baseline.md 의 MIRROR 블록에 MIRROR_GHOST 가 없다")
        return r
    inv = led.root / INVENTORY_DOC
    if not inv.is_file():
        r.bad(f"{INVENTORY_DOC} 이 없다")
        return r
    left, n_rows, n_lists = inventory_members(inv.read_text(encoding="utf-8"))
    d = led.root / "docs" / "extractions"
    right: dict[int, str] = {}
    for f in (sorted(d.glob("extraction-*.md")) if d.is_dir() else []):
        m = EXTRACTION_FILE_NO.match(f.name)
        if m:
            right[int(m.group(1))] = f.name      # 이름의 꼴은 검사 35 가 받는다
    # 좌변이나 우변이 비면 어느 방향의 어긋남이든 0 으로 난다. 검사 40 과 44 와 46 이 같은 요구를
    # 둔다.
    if not left:
        r.bad(f"{INVENTORY_DOC} 의 구성원 행에서 추출 기록 번호를 하나도 읽지 못했다")
        return r
    if not right:
        r.bad("docs/extractions/ 에서 추출 기록을 하나도 읽지 못했다")
        return r
    # 좌에서 우로 미포착. 영을 요구한다.
    for n in sorted(set(left) - set(right)):
        r.bad(f"{INVENTORY_DOC}:{left[n][0]} 의 구성원 행이 든 E-{n:02d} 의 기록 파일이 없다")
    # 우에서 좌로 유령. 영을 요구하지 않고 블록의 값과 맞댄다. **늘면 실패시키고 줄면 통과시킨다.**
    # 여러 출처를 한 기록에 묶은 자리가 있어 대응하는 단일 구성원이 서지 않으므로 유령이 구조적으로
    # 영이 될 수 없고, 배정 문면을 면제의 축으로 쓰면 표 행을 가진 쪽이 재어지지 않으므로 면제를
    # 두지 않고 계수로 가둔다.
    ghosts = sorted(set(right) - set(left))
    if len(ghosts) > ghost_cap:
        r.bad(f"유령이 {len(ghosts)} 인데 값 정본의 블록이 {ghost_cap} 를 든다. "
              f"{len(ghosts) - ghost_cap} 만큼 늘었다")
    elif len(ghosts) < ghost_cap:
        r.note(f"유령 {len(ghosts)} 가 블록의 {ghost_cap} 보다 {ghost_cap - len(ghosts)} 적다. "
               f"그 기록이 구성원 행을 얻은 것이므로 통과시키며, 블록의 값을 같은 회차에 함께 "
               f"내리는 것은 결정 세션의 조작이다")
    else:
        r.note(f"유령 {len(ghosts)} 가 블록의 값과 같다")
    r.note(f"좌변은 구성원 행이 든 기록 번호 {len(left)} · 표의 본문 행 {n_rows} · "
           f"나열 줄 {n_lists} · 우변은 추출 기록 {len(right)}")
    r.note(f"좌에서 우로 미포착 {len(set(left) - set(right))} · 우에서 좌로 유령 {len(ghosts)}")
    for n in ghosts:
        r.note(f"유령 E-{n:02d} — {right[n]}")
    _check_50_unread(led, r, {n: d / name for n, name in right.items()})
    return r


QUEUE_SEGMENT = re.compile(r"(?<![0-9A-Za-z-])O-\d+(?![0-9A-Za-z-])")


INVENTORY_REQUIRED_MARK = "★"


INVENTORY_OUT_OF_SEGMENT = "구간 밖"


def check_53(led: Ledger) -> Report:
    r = Report("53", "wiki53-inventory-member-marker",
               "뭉치 인벤토리의 구성원 행마다 추출 기록 번호나 지목 참조 표지나 미추출 표지 가운데 "
               "하나를 드는가", "fail")
    got = _inventory_rows(led, r)
    if got is None:
        return r
    rows, marks, n_tables, n_rows = got
    cited, unread = marks[INVENTORYMARK_CITED], marks[INVENTORYMARK_UNREAD]
    n_num = n_cited = n_unread = 0
    for line, cells, _section in rows:
        # 번호는 칸 전량에서 찾고 그 꼴은 검사 50 과 같다. 표지는 비고 칸 곧 마지막 칸에서만 찾는다.
        has_num = any(INVENTORY_EXTRACTION_NO.search(c) for c in cells)
        has_cited = cited in cells[-1]
        has_unread = unread in cells[-1]
        n_num += has_num
        n_cited += has_cited
        n_unread += has_unread
        if not (has_num or has_cited or has_unread):
            r.bad(f"{INVENTORY_DOC}:{line} 의 구성원 행이 번호도 표지도 들지 않는다: "
                  f"| {' | '.join(cells)} |")
    r.note(f"구성원 행 {len(rows)} · 번호를 든 행 {n_num} · 지목 참조 표지를 든 행 {n_cited} · "
           f"미추출 표지를 든 행 {n_unread}")
    r.note(f"마커로 뺀 표 {n_tables} · 그 표의 행 {n_rows}")
    if n_tables == 0:
        r.note("마커가 선 표가 없다. 집계 표가 있으면 그 행이 구성원 행으로 세어진다")
    return r


def check_54(led: Ledger) -> Report:
    r = Report("54", "wiki54-inventory-unread-count",
               "미추출 표지를 든 구성원 행의 계수와 그 구간별 분포", "report")
    got = _inventory_rows(led, r)
    if got is None:
        return r
    rows, marks, _n_tables, _n_rows = got
    q = led.root / READING_QUEUE_DOC
    if not q.is_file():
        r.bad(f"{READING_QUEUE_DOC} 이 없다")
        return r
    segments = sorted(set(QUEUE_SEGMENT.findall(q.read_text(encoding="utf-8"))),
                      key=lambda s: int(s[2:]))
    if not segments:
        r.bad(f"{READING_QUEUE_DOC} 에서 구간 이름을 하나도 읽지 못했다")
        return r
    unread = marks[INVENTORYMARK_UNREAD]
    hits: list[tuple[int, str, str]] = []
    for line, cells, section in rows:
        if unread not in cells[-1]:
            continue
        seg = next((s for s in segments if section.startswith(s + " ")), None)
        if seg is None:
            label = INVENTORY_OUT_OF_SEGMENT
        else:
            star = (INVENTORY_REQUIRED_MARK if INVENTORY_REQUIRED_MARK in cells[0]
                    else "비" + INVENTORY_REQUIRED_MARK)
            label = f"{seg} {star}"
        hits.append((line, label, cells[1] if len(cells) > 1 else ""))
    dist: dict[str, int] = {}
    for _line, label, _title in hits:
        dist[label] = dist.get(label, 0) + 1
    keys = sorted((k for k in dist if k != INVENTORY_OUT_OF_SEGMENT),
                  key=lambda k: (int(k.split()[0][2:]), k))
    if INVENTORY_OUT_OF_SEGMENT in dist:
        keys.append(INVENTORY_OUT_OF_SEGMENT)
    r.note(f"미추출 표지를 든 구성원 행 {len(hits)} · 구성원 행 {len(rows)}")
    r.note("구간별 분포 " + (" · ".join(f"{k} {dist[k]}" for k in keys) if keys else "없음")
           + f" (구간 이름은 {READING_QUEUE_DOC} 의 " + " · ".join(segments) + ")")
    # 행마다 한 줄을 낸다. 음성 대조가 늘린 행을 그 줄로 찾으며, 계수만 내면 그 주입이 어느 행을
    # 겨눴는지가 보고에 남지 않는다.
    for line, label, title in hits:
        r.note(f"{INVENTORY_DOC}:{line} — {label} — {title}")
    return r


# 검사 58 이 읽는 `QUEUEMARK` 블록. `docs/baseline.md` 가 읽기 대기열의 지목 참조 대기 표의 절 제목과
# 그 표의 표지 낱말을 든다. **블록이 비거나 절 제목이나 낱말이 하나도 없으면 통과시키지 않는다.** 제목과
# 낱말을 코드에 박으면 그것을 바꾸는 회차가 대기열과 블록만 고쳤을 때 이 검사가 옛 값을 찾아 조용히
# 낡는다. 검사 53 의 `INVENTORYMARK` 와 같은 형이다.
#
# **낱말의 수를 코드에 박지 않는다.** 절 제목의 키를 뺀 나머지 키 전량이 표지의 낱말이며, 블록이 드는
# 것을 그대로 센다. 박아 두면 표지를 더하는 회차가 블록과 대기열만 고쳤을 때 새 낱말을 든 행이 표지 없는
# 행으로 걸리고, 낱말을 빼는 회차에서는 옛 낱말을 든 행이 표지를 든 것으로 조용히 통과한다.
QUEUEMARK_BLOCK = re.compile(r"<!-- QUEUEMARK:BEGIN -->\n(.*?)<!-- QUEUEMARK:END -->", re.S)


QUEUEMARK_LINE = re.compile(r"^(QUEUEMARK_[A-Z]+)=(.*)$")


QUEUEMARK_SECTION = "QUEUEMARK_SECTION"


# 표지가 서는 칸의 자리. 첫 칸이 편의 이름이고 표지는 그 다음 칸 곧 대상 구멍의 칸에 선다. 그 표에
# 칸을 둘만 드는 행이 있고 그 행도 이 자리에 표지를 들므로 마지막 칸으로 두지 않는다. 마지막 칸으로
# 두면 칸을 셋 드는 행에서 기대 재료의 산문을 읽게 되어 표지를 든 행이 표지 없는 행으로 걸린다.
QUEUEMARK_CELL = 1


def queuemark_block(led: Ledger) -> dict[str, str]:
    """`QUEUEMARK` 블록의 키와 값. 값이 빈 키는 들지 않으며 블록의 줄 순서를 지킨다."""
    out: dict[str, str] = {}
    for line in _baseline_block(led, QUEUEMARK_BLOCK).splitlines():
        m = QUEUEMARK_LINE.match(line)
        if m and m.group(2).strip():
            out[m.group(1)] = m.group(2).strip()
    return out


def queuemark_words(marks: dict[str, str]) -> list[tuple[str, str]]:
    """블록이 드는 표지의 (키, 낱말). 절 제목의 키를 뺀 나머지 전량이며 블록의 줄 순서를 지킨다."""
    return [(k, v) for k, v in marks.items() if k != QUEUEMARK_SECTION]


def queue_section_rows(text: str, heading: str) -> tuple[int | None, list[tuple[int, list[str]]]]:
    """그 제목의 절이 선 줄 번호와 그 절 안의 표의 본문 행 (줄 번호, 칸).

    절은 그 제목으로 시작하는 줄부터 다음 `## ` 절 앞까지다. 제목 뒤에 공백과 부제가 붙는 꼴을 받으며,
    제목이 다른 제목의 앞부분으로만 맞는 꼴(`## 1. 지목` 이 `## 1. 지목 참조` 에 맞는 꼴)은 받지 않는다.
    표의 행을 가르는 꼴은 검사 53 의 `inventory_member_rows` 와 같다.
    """
    lines = text.splitlines()
    start = next((i for i, ln in enumerate(lines)
                  if ln == heading or ln.startswith(heading + " ")), None)
    if start is None:
        return None, []
    rows: list[tuple[int, list[str]]] = []
    i = start + 1
    while i < len(lines) and not lines[i].startswith("## "):
        head = md_cells(lines[i])
        rule = md_cells(lines[i + 1]) if i + 1 < len(lines) else None
        if head and rule and all(SPEC_TABLE_RULE.match(c) for c in rule if c):
            j = i + 2
            while j < len(lines):
                body = md_cells(lines[j])
                if body is None:
                    break
                rows.append((j + 1, body))
                j += 1
            i = j
            continue
        i += 1
    return start + 1, rows


def check_58(led: Ledger) -> Report:
    r = Report("58", "wiki58-queue-marker",
               "읽기 대기열의 지목 참조 대기 표의 행마다 대기 표지와 조달 표지와 소진 표지 가운데 하나를 드는가",
               "fail")
    marks = queuemark_block(led)
    words = queuemark_words(marks)
    if QUEUEMARK_SECTION not in marks:
        r.bad(f"docs/baseline.md 의 QUEUEMARK 블록에 {QUEUEMARK_SECTION} 가 없다")
        return r
    if not words:
        r.bad("docs/baseline.md 의 QUEUEMARK 블록이 표지의 낱말을 하나도 들지 않는다")
        return r
    q = led.root / READING_QUEUE_DOC
    if not q.is_file():
        r.bad(f"{READING_QUEUE_DOC} 이 없다")
        return r
    heading = marks[QUEUEMARK_SECTION]
    at, rows = queue_section_rows(q.read_text(encoding="utf-8"), heading)
    if at is None:
        r.bad(f"{READING_QUEUE_DOC} 에서 절 제목 `{heading}` 을 찾지 못했다")
        return r
    # 유니버스가 비면 어느 행도 걸리지 않아 0 으로 난다. 검사 50 과 53 이 같은 요구를 둔다.
    if not rows:
        r.bad(f"{READING_QUEUE_DOC}:{at} 의 절에서 표의 행을 하나도 읽지 못했다")
        return r
    count = {v: 0 for _k, v in words}
    for line, cells in rows:
        cell = cells[QUEUEMARK_CELL] if len(cells) > QUEUEMARK_CELL else ""
        hit = [v for _k, v in words if v in cell]
        # 둘 이상을 든 행도 걸린다. 이 검사가 잡으려는 것이 소진된 행이 대기 표지를 든 채 남는 것이므로
        # 하나를 요구하는 문면을 여럿을 드는 것으로 채우면 그 탐지가 빈다.
        if len(hit) > 1:
            r.bad(f"{READING_QUEUE_DOC}:{line} 의 행이 표지 {len(hit)} 개를 함께 든다 "
                  f"({' · '.join(hit)}): {cells[0]}")
        elif not hit:
            r.bad(f"{READING_QUEUE_DOC}:{line} 의 행이 어느 표지도 들지 않는다: {cells[0]}")
        else:
            count[hit[0]] += 1
    r.note(f"절 `{heading}` ({READING_QUEUE_DOC}:{at}) 의 표의 행 {len(rows)} · "
           + " · ".join(f"`{v}` 표지를 든 행 {n}" for v, n in count.items()))
    r.note(f"표지의 낱말 {len(words)} (" + " · ".join(f"{k}={v}" for k, v in words) + ") · "
           f"표지를 찾는 칸은 {QUEUEMARK_CELL + 1} 번째 칸")
    return r


# 검사 63 이 소진 표지로 읽는 `QUEUEMARK` 블록의 키. 낱말을 코드에 박지 않고 이 키로 블록에서 꺼내며,
# 그 키가 블록에 실재하는지를 단언이 지킨다. 검사 58 은 표지의 낱말을 키로 고르지 않으나, 이 검사는
# 표지 셋 가운데 소진 하나를 골라야 하므로 그 키 하나를 든다.
QUEUEMARK_SPENT = "QUEUEMARK_SPENT"


# 검사 63 이 지목을 맞대는 칸. 첫 칸이 편의 이름이고 이연의 `ref` 가 그 이름을 든다. 행 전체로 맞대면
# 다른 행의 기대 재료 칸이 든 번호나 구절에 닿아 닿지 않아야 할 항이 닿은 것으로 세어진다.
QUEUE_REF_CELL = 0


def queue_ref_key(s: str) -> str:
    """지목을 맞대는 변. 공백을 전량 지운다.

    접지 않으면 저자 이름의 가운뎃점 둘레에 선 공백 때문에 닿는 행이 닿지 않는 것으로 세어지고, 그
    거짓 음성이 적발을 작게 낸다(SPEC §2.2).
    """
    return re.sub(r"\s+", "", s)


def queue_ref_rows(rows: list[tuple[int, list[str]]], ref: str) -> list[tuple[int, list[str]]]:
    """그 지목이 닿는 표의 행. 공백을 지운 지목이 공백을 지운 편의 이름 칸 안에 서면 닿는다."""
    key = queue_ref_key(ref)
    if not key:
        return []
    return [(line, cells) for line, cells in rows
            if len(cells) > QUEUE_REF_CELL and key in queue_ref_key(cells[QUEUE_REF_CELL])]


def check_63(led: Ledger) -> Report:
    r = Report("63", "wiki63-queue-spent-alive",
               "재개 트리거가 추출 갈래인 살아 있는 이연 가운데 읽기 대기열의 지목 참조 대기 표에서 "
               "소진 표지를 든 행에 닿는 것과 그 표의 어느 행에도 닿지 않는 것의 계수와 번호", "report")
    marks = queuemark_block(led)
    for key in (QUEUEMARK_SECTION, QUEUEMARK_SPENT):
        if key not in marks:
            r.bad(f"docs/baseline.md 의 QUEUEMARK 블록에 {key} 가 없다")
            return r
    spent = marks[QUEUEMARK_SPENT]
    q = led.root / READING_QUEUE_DOC
    if not q.is_file():
        r.bad(f"{READING_QUEUE_DOC} 이 없다")
        return r
    heading = marks[QUEUEMARK_SECTION]
    at, rows = queue_section_rows(q.read_text(encoding="utf-8"), heading)
    if at is None:
        r.bad(f"{READING_QUEUE_DOC} 에서 절 제목 `{heading}` 을 찾지 못했다")
        return r
    # 행이 비면 어느 항도 닿지 않아 적발이 0 으로 난다. 검사 58 이 같은 요구를 둔다.
    if not rows:
        r.bad(f"{READING_QUEUE_DOC}:{at} 의 절에서 표의 행을 하나도 읽지 못했다")
        return r
    # 유니버스. 검사 43 과 같은 이연을 본다. 그 검사는 추출 기록의 실재를 보고 이 검사는 읽기
    # 대기열의 표지를 본다.
    live = [e for e in led.reg["deferred"]
            if isinstance(e.get("reopen_when"), dict)
            and e["reopen_when"].get("kind") == "extraction"
            and e.get("id") not in led.dead]
    caught: list[str] = []
    multi: list[str] = []
    numbered: list[str] = []
    loose: list[str] = []
    n_hit = 0
    for e in live:
        eid = str(e.get("id"))
        ref = str(e["reopen_when"].get("ref") or "")
        hit = queue_ref_rows(rows, ref)
        if not hit:
            # 닿지 않는 항은 적발의 유니버스 밖이다. 추출 기록의 번호를 드는 항은 해소되는 자리가
            # 그 표가 아니므로 별도 계수로 내고, 번호도 들지 않는 항은 그 지목이 어느 자리에도
            # 맺히지 않은 것이므로 따로 낸다.
            n = extraction_ref_number(ref)
            if n is not None:
                numbered.append(f"{eid} — E-{n:02d}")
            else:
                loose.append(f"{eid} — `ref` {ref!r}")
            continue
        n_hit += 1
        if len(hit) > 1:
            multi.append(f"{eid} — " + " · ".join(f"{READING_QUEUE_DOC}:{line}" for line, _ in hit))
        for line, cells in hit:
            cell = cells[QUEUEMARK_CELL] if len(cells) > QUEUEMARK_CELL else ""
            if spent in cell:
                caught.append(f"{eid} — {READING_QUEUE_DOC}:{line} — {cells[QUEUE_REF_CELL]}")
    r.note(f"유니버스는 재개 트리거가 추출 갈래인 살아 있는 이연 {len(live)}건 · 절 `{heading}` "
           f"({READING_QUEUE_DOC}:{at}) 의 표의 행 {len(rows)}")
    r.note(f"표의 행에 닿은 항 {n_hit}건 · 그 가운데 둘 이상의 행에 닿은 항 {len(multi)}건")
    for line in multi:
        r.note(line)
    r.note(f"`{spent}` 표지를 든 행에 닿은 항 {len(caught)}건")
    for line in caught:
        r.note(line)
    r.note(f"어느 행에도 닿지 않고 추출 기록의 번호를 드는 항 {len(numbered)}건")
    for line in numbered:
        r.note(line)
    r.note(f"어느 행에도 닿지 않고 추출 기록의 번호도 들지 않는 항 {len(loose)}건")
    for line in loose:
        r.note(line)
    return r


def check_59(led: Ledger) -> Report:
    r = Report("59", "wiki59-extraction-stem-unique",
               "추출 기록 디렉터리의 파일 이름에서 번호를 뗀 줄기가 전량 유일한가", "fail")
    d = led.root / "docs" / "extractions"
    if not d.is_dir():
        r.bad("docs/extractions/ 가 없다")
        return r
    stems: dict[str, list[str]] = {}
    skipped = 0
    for f in sorted(d.iterdir()):
        if not f.is_file():
            continue
        # 번호의 꼴은 검사 49 와 50 이 쓰는 `EXTRACTION_FILE_NO` 와 같다. 그 꼴 밖의 이름은 검사 35 가
        # 받으므로 여기서는 세기만 하고 건너뛴다.
        m = EXTRACTION_FILE_NO.match(f.name)
        if m is None:
            skipped += 1
            continue
        stem = f.name[m.end():]
        if stem.endswith(".md"):
            stem = stem[:-len(".md")]
        stems.setdefault(stem, []).append(f.name)
    # 유니버스가 비면 어느 줄기도 겹치지 않아 0 으로 난다. 검사 58 과 같은 요구를 둔다.
    if not stems:
        r.bad("docs/extractions/ 에서 번호를 든 파일을 하나도 읽지 못했다")
        return r
    dup = 0
    for stem, names in sorted(stems.items()):
        if len(names) > 1:
            dup += 1
            r.bad(f"줄기 `{stem}` 을 파일 {len(names)} 개가 함께 든다: " + " · ".join(names))
    r.note(f"번호를 든 파일 {sum(len(v) for v in stems.values())} · 서로 다른 줄기 {len(stems)} · "
           f"겹친 줄기 {dup} · 번호의 꼴 밖이라 건너뛴 파일 {skipped}")
    return r


def inventory_aggregate_rows(text: str, marker: str) -> list[tuple[int, list[str]]]:
    """집계 마커가 선 표의 본문 행 (줄 번호, 칸).

    마커 바로 뒤의 줄이 표의 머리이고 그 다음 줄이 구분 줄이어야 그 표로 읽는다. 마커가 없거나
    그 뒤가 표가 아니면 빈 목록을 내며, 그것을 받는 검사가 빈 유니버스를 통과시키지 않는다.
    """
    lines = text.splitlines()
    for i, ln in enumerate(lines):
        if ln.strip() != marker:
            continue
        k = i + 1
        if k + 1 >= len(lines) or not lines[k].startswith("|") \
                or not lines[k + 1].startswith("|---"):
            return []
        out: list[tuple[int, list[str]]] = []
        k += 2
        while k < len(lines) and lines[k].startswith("|"):
            out.append((k + 1, [c.strip() for c in lines[k].strip().strip("|").split("|")]))
            k += 1
        return out
    return []


def _aggregate_value(cell: str) -> int | None:
    """집계 표의 칸이 든 수. 굵은 표기를 걷고 줄표는 영으로 읽으며, 수로 읽히지 않으면 None 이다."""
    c = cell.replace("*", "").strip()
    if c in ("—", "-", ""):
        return 0
    return int(c) if c.isdigit() else None


def check_61(led: Ledger) -> Report:
    r = Report("61", "wiki61-inventory-aggregate-sum",
               "뭉치 인벤토리의 집계 표에서 무리 행의 편수와 zip 밖 칸을 더한 값이 합계 행과 같은가",
               "fail")
    # 표를 찾는 마커는 값 정본의 블록에서 읽는다. 구성원 행의 유니버스에서 그 표를 빼는 검사 53 이
    # 이미 그 블록을 읽으므로, 여기서 전사하면 한쪽을 고칠 때 다른 쪽이 조용히 낡는다.
    marks = inventorymark_block(led)
    if INVENTORYMARK_AGGREGATE not in marks:
        r.bad(f"`{INVENTORYMARK_BLOCK}` 블록이 `{INVENTORYMARK_AGGREGATE}` 를 들지 않는다")
        return r
    rows = inventory_aggregate_rows((led.root / INVENTORY_DOC).read_text(encoding="utf-8"),
                                    marks[INVENTORYMARK_AGGREGATE])
    # 첫 칸이 굵은 표기로 시작하는 행이 합계 행이다. 그 행이 하나가 아니거나 무리 행이 없으면 맞댈
    # 상대가 없으므로 통과가 아니라 실패다. 검사 58 과 59 가 같은 요구를 둔다.
    groups = [(n, c) for n, c in rows if not c[0].startswith("**")]
    totals = [(n, c) for n, c in rows if c[0].startswith("**")]
    if not groups or len(totals) != 1:
        r.bad(f"{INVENTORY_DOC} 의 집계 표에서 무리 행 {len(groups)} · 합계 행 {len(totals)} 을 "
              "읽었다. 무리 행이 하나 이상이고 합계 행이 하나여야 맞댈 수 있다")
        return r
    line, total = totals[0]
    # 절 제목이 드는 편수와 맞대는 축은 세우지 않는다. 그 꼴이 무리마다 달라 한 패턴으로 닫히지
    # 않으므로, 인벤토리의 집계 절이 그 사실을 문면으로 든다.
    for col, name in ((1, "편수"), (2, "zip 밖")):
        vals = [_aggregate_value(c[col]) if len(c) > col else None for _n, c in groups]
        tot = _aggregate_value(total[col]) if len(total) > col else None
        if None in vals or tot is None:
            r.bad(f"{INVENTORY_DOC} 의 집계 표의 `{name}` 칸에 수로 읽히지 않는 값이 있다")
            continue
        if sum(vals) != tot:
            r.bad(f"{INVENTORY_DOC}:{line} 의 합계 행이 `{name}` 을 {tot} 로 드는데 무리 행의 합이 "
                  f"{sum(vals)} 다")
        r.note(f"`{name}` — 무리 행 {len(vals)} 의 합 {sum(vals)} · 합계 행 {tot}")
    return r


# 이 단위가 드는 검사. 러너가 이 목록을 이어 붙여 손 열거를 걷는다.
CHECKS = (
    check_12,
    check_32,
    check_35,
    check_36,
    check_37,
    check_41,
    check_43,
    check_49,
    check_50,
    check_53,
    check_54,
    check_58,
    check_59,
    check_61,
    check_63,
)
