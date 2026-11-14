#!/usr/bin/env python3
"""규율 문서를 재는 결정 세션의 상주 측정 설비.

**이 모듈은 검증 스크립트가 부르지 않는다.** 그 유니버스가 세션 지시와 그
부록이고 그 둘이 프로젝트 디렉터리에 살아 리포에 들어가지 않으므로, 검증
설비가 이 값을 쓸 수 없다. 결정 세션이 그 두 파일의 경로를 인자로 주어 이
모듈을 직접 부르고, 그 결과를 그 회차의 종료 문서가 적는다.

**리포에 사는 사유는 승계다.** 이 측정기가 결정 세션의 컨테이너에만 살던
동안에는 회차마다 다시 짜였고, 그 두 판의 경계가 갈려 한쪽이 다른 것을 재는
일이 되풀이됐다. 산문으로 꼴을 적어 두는 것이 그 갈림을 막지 못한다는 것이
실측으로 섰으므로 소스를 리포에 둔다.

쓰는 꼴은 인자 둘을 받는 것이며, 첫 인자가 세션 지시의 경로이고 둘째 인자가
부록의 경로다. 네 대조와 팽창 지표를 내며, 대조가 하나라도 닫히지 않으면
비영으로 끝난다.
"""

import ast
import inspect
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASELINE = ROOT / "docs" / "baseline.md"


# ============================================================ 변의 가름
#
# 표기의 고정을 재는 자리는 접은 변을 쓰고 구절의 실재를 재는 자리는 공백을
# 전량 지운 변을 쓴다. 낫표와 조사가 붙어 공백을 품지 않는 구절은 줄바꿈이
# 그 가운데에 들면 접은 변에서 공백이 끼어 깨지므로, 가르지 않으면 서 있는
# 조항이 서지 않은 것으로 나오는 거짓 음성이 서고 그것이 앞 회차의 결손이라는
# 판정으로 옮겨진다.

def fold(text: str) -> str:
    """표기의 고정을 재는 변. 줄바꿈과 잇단 공백을 공백 하나로 접는다."""
    return re.sub(r"\s+", " ", text)


def strip_ws(text: str) -> str:
    """구절의 실재를 재는 변. 공백을 전량 지운다."""
    return re.sub(r"\s+", "", text)


def occurrences(haystack: str, needle: str) -> int:
    """구절의 등장을 세는 유일한 자리. 공백을 전량 지운 변에서 센다."""
    h, n = strip_ws(haystack), strip_ws(needle)
    if not n:
        raise ValueError("빈 구절은 셀 수 없다")
    return h.count(n)


def assert_narrowing() -> bool:
    """가름이 자기 소스에 섰음을 단언하고 동작으로도 잰다."""
    tree = ast.parse(inspect.getsource(occurrences))
    names = {n.id for n in ast.walk(tree) if isinstance(n, ast.Name)}
    if "strip_ws" not in names:
        raise AssertionError("구절의 실재를 재는 자리가 공백 지움을 거치지 않는다")
    if "fold" in names:
        raise AssertionError("구절의 실재를 재는 자리에 접기가 걸렸다")
    broken, needle = "거처는 「세션\n지시」다", "「세션지시」"
    if occurrences(broken, needle) != 1:
        raise AssertionError("줄바꿈이 낀 구절을 지움 변이 받지 못한다")
    if fold(broken).count(needle) != 0:
        raise AssertionError("접은 변이 공백을 품지 않는 구절을 깨뜨리지 않는다")
    if fold(broken) != "거처는 「세션 지시」다":
        raise AssertionError("접기가 줄바꿈을 공백 하나로 바꾸지 않는다")
    return True


# ====================================================== 값 정본의 블록

def _block(name: str, text: str | None = None) -> str:
    src = BASELINE.read_text(encoding="utf-8") if text is None else text
    m = re.search(rf"<!-- {name}:BEGIN -->\n(.*?)<!-- {name}:END -->", src, re.S)
    if m is None:
        raise AssertionError(f"값 정본에 `{name}` 블록이 없다")
    return m.group(1)


# ======================================= 조항을 작업 파일에서 뽑는 자리
#
# 조항 선언이 취하는 꼴을 전수로 든다. 목록 항의 머리에 굵게 선 것과 머리에
# 이름이 이어 붙은 것과 작업 흐름 절의 제목이 드는 것과 확정 결정의 제목이
# 드는 것이 그 넷이다. 줄 머리를 보는 측정이므로 접기를 걸지 않는다.

_CLAUSE_LIST_BOLD = re.compile(r"^\s*[-*]\s+\*\*([A-Z]{1,2}-\d+)\b")
_CLAUSE_SECTION = re.compile(r"^#{2,4}\s+[\d.]*\s*([A-Z]{1,2}-\d+)\b")
_CLAUSE_SECTION_TAIL = re.compile(r"^#{2,4}\s+[\d.]+\s+([A-Z]{1,2}-\d+)\s")
_W_SECTION = re.compile(r"^###\s+2\.\d+\s+(W-\d+)\s", re.M)


def clauses(si_text: str, series: set[str]) -> set[str]:
    out = set()
    for line in si_text.split("\n"):
        for pat in (_CLAUSE_LIST_BOLD, _CLAUSE_SECTION, _CLAUSE_SECTION_TAIL):
            m = pat.match(line)
            if m and m.group(1).split("-")[0] in series:
                out.add(m.group(1))
    return out


def w_clauses(si_text: str) -> set[str]:
    return set(_W_SECTION.findall(si_text))


def logic_section(si_text: str) -> str:
    """§3.1 부터 §3.10 앞까지. 위반 탐지 표의 대조가 좌변을 이 범위로 닫는다."""
    lines = si_text.split("\n")
    lo = hi = None
    for i, line in enumerate(lines):
        if lo is None and re.match(r"^###\s+3\.1\s", line):
            lo = i
        if re.match(r"^###\s+3\.10\s", line):
            hi = i
            break
    if lo is None or hi is None:
        raise AssertionError("논리 전개 규율의 절 범위를 잡지 못했다")
    return "\n".join(lines[lo:hi])


# ====================================== 부록 지목과 부록의 절 제목

_APPENDIX_REF = re.compile(r"부록의\s+(.{1,40}?절)\s*이\s*든다")
_APPENDIX_HEAD = re.compile(r"^##\s+(.+?)\s*$")


def appendix_refs(si_text: str) -> set[str]:
    """「부록의 ○○ 절이 든다」로 든 이름 전량. 자리표는 좌변의 유니버스 밖이다.

    한 지목이 절 둘을 「과」로 이어 들 수 있으므로 양쪽이 다 「절」로 닫히면
    갈라 받아 우변의 절 제목과 같은 단위로 맞춘다.
    """
    out = set()
    for m in _APPENDIX_REF.finditer(fold(si_text)):
        name = m.group(1).strip()
        if "○" in name:
            continue
        parts = re.split(r"절(?:과|와)\s+", name)
        if len(parts) > 1:
            for p in parts[:-1]:
                out.add(p.strip() + " 절")
            out.add(parts[-1].strip())
        else:
            out.add(name)
    return out


def appendix_heads(ap_text: str) -> set[str]:
    out = set()
    for line in ap_text.split("\n"):
        m = _APPENDIX_HEAD.match(line)
        if m:
            out.add(m.group(1).strip())
    return out


# ============================================ 위반 탐지 표와 그 설계 묶음

_RANGE = re.compile(r"([A-Z]{1,2})-(\d+)\s*~\s*(?:[A-Z]{1,2}-)?(\d+)")
_ID = re.compile(r"\b([A-Z]{1,2}-\d+)\b")
_NODETECT = re.compile(r"탐지의 대상이 아닌 \S+은\s+(.+?)\s*다\.")


def detection_table(si_text: str) -> set[str]:
    """§3.10 위반 탐지 표의 첫 칼럼. 범위 표기를 펼치고, 행을 세우지 않는
    사유를 드는 표는 그 머리로 가려 우변에서 뺀다. 가리지 않으면 미포착이
    설계가 드는 수보다 작게 나와 행을 세우지 않기로 한 조항이 행을 가진
    것으로 서고 그 어긋남이 통과에 가려진다."""
    out, in_table, excluded = set(), False, False
    for line in si_text.split("\n"):
        s = line.strip()
        if s.startswith("|") and "---" in s:
            continue
        if s.startswith("| 조항 |") and "사유" in s:
            excluded, in_table = True, True
            continue
        if s.startswith("| 규율 |") and "탐지" in s:
            excluded, in_table = False, True
            continue
        if not s.startswith("|"):
            in_table = False
            continue
        if not in_table or excluded:
            continue
        cell = s.split("|")[1].replace("*", "").strip() if s.count("|") >= 2 else ""
        for m in _RANGE.finditer(cell):
            ser, lo, hi = m.group(1), int(m.group(2)), int(m.group(3))
            out.update(f"{ser}-{i}" for i in range(lo, hi + 1))
        out.update(_ID.findall(_RANGE.sub(" ", cell)))
    return out


def no_detection(si_text: str) -> set[str]:
    """탐지의 대상이 아니라고 그 문단의 머리가 열거한 조항."""
    m = _NODETECT.search(fold(si_text))
    if m is None:
        raise AssertionError("탐지의 대상이 아닌 조항을 드는 문단을 잡지 못했다")
    return set(_ID.findall(m.group(1)))


def no_row(si_text: str) -> set[str]:
    """행을 세우지 않기로 한 조항. 그 사유를 드는 표의 첫 칼럼에서 받으며,
    사유 안의 범위 표기는 펼치지 않는다."""
    out, in_table = set(), False
    for line in si_text.split("\n"):
        s = line.strip()
        if s.startswith("| 조항 |") and "사유" in s:
            in_table = True
            continue
        if not s.startswith("|"):
            in_table = False
            continue
        if not in_table or "---" in s:
            continue
        cell = s.split("|")[1].replace("*", "").strip() if s.count("|") >= 2 else ""
        out.update(_ID.findall(cell))
    return out


# ================================================== 팽창 지표의 측정기
#
# 상한은 한 요구를 다루는 문단이 셋을 넘거나 그 바이트가 삼천을 넘는 것이고,
# 지표는 요구 단위의 계수가 아니라 상한을 넘는 단위의 바이트다. 요구의 단위를
# 세우는 조작이 단위의 수를 늘리므로 계수로 재면 그 조작이 적발된다.

_OVER_PARAS = 3
_OVER_BYTES = 3000

_SECTION = re.compile(r"^#{2,3}\s+")
_LIST_ID = re.compile(r"^\s*[-*]\s+\*\*?[A-Z]{1,2}-\d+\b")


# 표의 행이 식별자를 머리로 두는 꼴. 한 행이 한 조항의 탐지를 드는 표가 열거이고 합칠
# 상대가 없는데, 항을 목록의 꼴로만 받으면 그 절이 한 단위로 서서 상한을 넘고 행을 더하는
# 조작이 전부 적발된다.
_ROW_ID = re.compile(r"^\s*\|\s*\*{0,2}[A-Z]{1,2}-\d+\b")
_HEAD_BOLD = re.compile(r"^\*\*")
_HEAD_NUM = re.compile(r"^\(\d+\)|^\d+\.\s")
_HEAD_ID = re.compile(r"^\s*[-*]\s+\*\*[A-Z]{1,2}-\d+\b")

_RE_REINFORCE = re.compile(
    r"^\*\*(그|이|저)\s*\S*\s*(요구|조항|금지|탐지|단언|축|유니버스|가름|제거|처방)")
_RE_REASON = re.compile(r"(비용|까닭|근거)(은|는|이|가)")
_RE_IMPL = re.compile(r"(재는 꼴|집행의 꼴|재는 자리|패턴|유니버스를 뽑)")


def _sections(text: str):
    """절은 제목 수준 둘과 셋이 가른다."""
    name, cur = "(머리)", []
    for line in text.split("\n"):
        if _SECTION.match(line):
            yield name, "\n".join(cur)
            name, cur = line.strip(), []
        else:
            cur.append(line)
    yield name, "\n".join(cur)


def _is_enumeration(body: str) -> bool:
    """열거를 드는 절은 유니버스 밖이다. 그 가름을 절의 항 가운데 식별자를
    머리로 둔 것이 절반을 넘는지로 유도하고 손으로 열거하지 않는다.

    표의 행도 항으로 받는다. 한 행이 한 조항의 탐지를 드는 표가 열거이고 합칠
    상대가 없는데, 목록의 꼴만 받으면 그 절 전량이 한 단위로 서서 상한을 넘고
    그 표에 행을 더하는 조작이 전부 적발되며 그 적발이 처방을 갖지 않는다."""
    items = [l for l in body.split("\n") if re.match(r"^\s*[-*]\s+", l)]
    rows = [l for l in body.split("\n")
            if l.lstrip().startswith("|") and not re.match(r"^\s*\|\s*-", l)]
    total = len(items) + len(rows)
    if not total:
        return False
    ident = (len([l for l in items if _LIST_ID.match(l)])
             + len([l for l in rows if _ROW_ID.match(l)]))
    return ident * 2 > total


def _units(body: str):
    """요구의 단위. 머리는 굵게 시작하는 문단과 번호 항과 조항 식별자 항
    셋이며 머리부터 다음 머리까지가 한 단위다. 머리가 없으면 절 전량이 한
    단위로 선다."""
    units, cur = [], []
    for p in [p for p in re.split(r"\n\s*\n", body) if p.strip()]:
        head = p.lstrip()
        if (_HEAD_BOLD.match(head) or _HEAD_NUM.match(head)
                or _HEAD_ID.match(p)) and cur:
            units.append(cur)
            cur = [p]
        else:
            cur.append(p)
    if cur:
        units.append(cur)
    return units


def _kind(unit):
    """갈래 셋이 겹치면 보강을 먼저 보고 사유를 보고 구현을 본다. 표지는
    문단의 첫머리에서 찾고 아무 자리에서나 찾지 않는다."""
    head = unit[0].lstrip()
    bare = re.sub(r"^(\*\*|\s*[-*]\s+\*\*|\(\d+\)\s*\**)", "", head)
    if _RE_REINFORCE.match(head):
        return "reinforce"
    if _RE_REASON.search(bare[:60]):
        return "reason"
    if head.startswith("**"):
        return None
    if _RE_IMPL.search(bare[:80]):
        return "impl"
    return None


def bloat(text: str) -> dict[str, int]:
    """상한 초과 바이트와 갈래별 바이트."""
    got = {"over": 0, "impl": 0, "reason": 0, "reinforce": 0}
    for _name, body in _sections(text):
        if _is_enumeration(body):
            continue
        for unit in _units(body):
            nb = len("\n\n".join(unit).encode("utf-8"))
            if len(unit) > _OVER_PARAS or nb > _OVER_BYTES:
                got["over"] += nb
            k = _kind(unit)
            if k:
                got[k] += nb
    return got


# ================================================================ 진입점

def run(si_path: str, ap_path: str) -> int:
    assert_narrowing()
    si = Path(si_path).read_text(encoding="utf-8")
    ap = Path(ap_path).read_text(encoding="utf-8")
    blk = _block("SESSIONCLAUSE")
    series = set(re.search(r"^SESSIONCLAUSE_SERIES=(.+)$", blk, re.M).group(1).split())
    bad = 0

    left = clauses(si, series)
    right = set(re.findall(r"^SESSIONCLAUSE=(\S+)$", blk, re.M))
    bad += _report("조항 목록", left, right)

    bad += _report("부록 지목", appendix_refs(si), appendix_heads(ap))

    lhs = clauses(logic_section(si), series) | w_clauses(si)
    tbl = detection_table(si)
    design = no_detection(si) | no_row(si)
    miss, ghost = lhs - tbl, tbl - lhs
    ok = (miss == design) and not ghost
    print(f"[위반 탐지 표] 좌 {len(lhs)} · 우 {len(tbl)} · "
          f"미포착 {len(miss)} · 유령 {len(ghost)} · "
          f"설계가 드는 두 묶음 {len(design)} · 집합으로 같은가 {ok}")
    if not ok:
        for x in sorted(miss - design):
            print(f"    설계 밖의 미포착 {x}")
        for x in sorted(design - miss):
            print(f"    설계가 들었으나 표에 선 {x}")
        for x in sorted(ghost):
            print(f"    유령 {x}")
        bad += 1

    print("[팽창 지표]")
    got = {}
    for tag, txt in (("SI", si), ("APPENDIX", ap)):
        b = bloat(txt)
        got[f"RULEDOC_OVER_BYTES_{tag}"] = b["over"]
        got[f"RULEDOC_IMPL_BYTES_{tag}"] = b["impl"]
        got[f"RULEDOC_REASON_BYTES_{tag}"] = b["reason"]
        got[f"RULEDOC_REINFORCE_BYTES_{tag}"] = b["reinforce"]
    want = {}
    for line in _block("RULEDOC").splitlines():
        m = re.match(r"^(RULEDOC_\S+)=(\d+)$", line.strip())
        if m:
            want[m.group(1)] = int(m.group(2))
    for k in sorted(got):
        w = want.get(k)
        mark = "같다" if w == got[k] else f"받은 판 {w}"
        print(f"    {k}={got[k]}  ({mark})")
    return 1 if bad else 0


def _report(name: str, left: set, right: set) -> int:
    miss, ghost = left - right, right - left
    print(f"[{name}] 좌 {len(left)} · 우 {len(right)} · "
          f"미포착 {len(miss)} · 유령 {len(ghost)}")
    for x in sorted(miss):
        print(f"    미포착 {x}")
    for x in sorted(ghost):
        print(f"    유령 {x}")
    return 1 if (miss or ghost) else 0


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print("쓰는 꼴: python3 scripts/ruledoc.py 세션지시경로 부록경로",
              file=sys.stderr)
        return 2
    return run(argv[1], argv[2])


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
