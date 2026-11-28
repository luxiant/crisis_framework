#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""보조 논증의 후보를 좁히는 결정 세션의 설비.

**이 모듈은 검증 스크립트가 부르지 않는다.** 무리를 훑는 페이즈가 형식층의 선언과 그 문서화 문면을 하나씩 읽기
전에, 보조 논증이 설 수 있는 자리를 셋으로 뽑아 특징과 함께 낸다. 판정은 이 설비가 하지 않고 읽는 쪽이 한다.

1. 행태 전제의 자리. 정리의 진술 머리에 쓴 바인더 가운데 타입이 명제인 것과, 구조체의 명제 필드다. 바인더가
   명제인지는 Lean 이 가르고, 진술 머리에 쓴 바인더와 결론 안의 전칭을 가르는 일은 주석과 문자열을 덮은 소스의
   서명에서 이 모듈이 한다.
2. 이음과 넓힘과 정당화의 자리. 조달처 줄이 없는 문단이며, 선언의 문서화 문면과 파일 머리의 블록 주석을 함께
   유니버스에 넣는다. 파일 머리를 빼면 그 자리에 선 이음을 놓친다. 문단마다 머리말의 갈래와 조달처 줄의 유무와
   추출 기록 지목의 수와 저자와 연도를 든 괄호의 수와 길이를 특징으로 내고, 순서는 지목과 인용이 적은 것을 앞에
   둔다. 현실을 드는 어휘의 목록으로 거르는 길은 쓰지 않는다. 그 목록이 리포의 실물에서 유도되지 않는 상수가
   되기 때문이다.
3. 무리별 부피. 아크 값 정본의 페이즈 레코드가 드는 훑을 파일의 목록으로 위의 둘을 가른다.

쓰는 꼴은 둘이다.

    python3 -I scripts/aux_candidates.py report [--root 리포] [--arc 아크] [--json 산출] [--tsv 산출]
    python3 -I scripts/aux_candidates.py selftest [--root 리포]

`selftest` 는 Lean 쪽과 문단 쪽에 음성 대조를 둘씩 건다. Lean 쪽의 정방향은 명제 가정을 든 정리를 사본에
더해 그 바인더가 잡히는지이고, 역방향은 명제 가정이 없는 정리를 더해 아무것도 잡히지 않는지다. 문단 쪽의
정방향은 리포 밖 사본의 한 문서화 문면에 조달처 줄이 없는 문단을 더해 후보가 하나 느는지이고, 역방향은 같은
문단을 조달처 줄과 함께 더해 후보가 늘지 않는지다.
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import cq_reach  # noqa: E402
from vstep_common import mask  # noqa: E402
from wiki_common import EXTRACTION_POINTER, Ledger, heading_rules, para_heading  # noqa: E402
from wiki_formal import SOURCING_LINE, fold  # noqa: E402

ROOT = HERE.parent
REPORT_CMD = "\n#eval AuxProbe.candidateReport\n"

# 파일 머리의 블록 주석. 문서화 문면의 `/--` 와 모듈 문서의 `/-!` 는 머리가 아니다.
HEAD_BLOCK = re.compile(r"\A\s*/-(?![-!])(.*?)-/", re.S)
PARA_SPLIT = re.compile(r"\n\s*\n")
# 저자와 연도를 든 괄호. 글자 하나 이상과 네 자리 연도가 함께 서야 한다.
CITATION = re.compile(r"\([^()]*?[A-Za-z가-힣][^()]*?\b(?:1[89]|20)\d\d\b[^()]*\)")
THEOREM_HEAD = re.compile(r"^theorem\s+([^\s({\[:]+)", re.M)
OPEN = re.compile(r"^(namespace|section)\b[ \t]*(\S*)")
END = re.compile(r"^end\b")
GROUP_FILES = re.compile(r"훑는 파일은 CrisisFramework 아래에서 경로가 (.+?) 인 lean 파일이다")
OPENERS = {"(": ")", "{": "}", "[": "]", "⦃": "⦄"}

# 표현의 선택을 드는 예약 머리말의 형. 보조 논증의 정의가 수 체계와 시간의 이산화와 판정의 계산 가능성 같은
# 표현의 선택을 대상에서 빼므로 그 형의 문단을 후보에서 뺀다. 형마다 값 정본의 머리말 블록에 실재하는지를
# 단언하므로 박아 둔 값이 아니라 단언이 지키는 값이다. 별표는 그 블록의 가변 구간과 같은 뜻이다.
REPRESENTATION_FORMS = (
    "T-3 분류:",
    "가정을 두지 않는다.",
    "수 체계를 매개변수로 받는다.",
    "수 체계를 받지 않는다.",
    "값을 담지 않는다.",
    "무엇을 증거하는가.",
    "인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.",
    "분할의 완전성은 *의 귀결이다(V-7).",
    "분할의 완전성을 주장하지 않는다(V-7).",
)
# 같은 축의 자유 머리말. 블록의 형을 벗어났으나 표현의 선택만 드는 머리말이 경계 밖에 서 있으므로, 예약 낱말이
# 그 축의 것이고 형이 블록에 없는 머리말을 그 축으로 함께 받는다. 그 낱말이 블록에 실재하는지를 단언한다.
REPRESENTATION_WORDS = ("T-3 분류", "수 체계", "값을 담지 않는다", "증거", "인덱스", "완전성")


def lean_props(root: Path, files: list[str], extra: str = "") -> dict:
    """Lean 이 가른 명제 가정과 명제 필드."""
    hyps: dict[str, list[tuple[str, str]]] = {}
    fields: dict[str, list[tuple[str, str]]] = {}
    for ln in cq_reach.run_meta(root, files, cq_reach.LEAN_SRC, REPORT_CMD, extra):
        if not ln:
            continue
        f = ln.split("\t")
        if f[0] == "HYP":
            hyps.setdefault(f[1], []).append((f[2], f[3]))
        elif f[0] == "PROPFIELD":
            fields.setdefault(f[1], []).append((f[2], f[3]))
        else:
            raise AssertionError("후보 보고의 줄 꼴이 다르다: %r" % ln)
    return {"hyps": hyps, "fields": fields}


def _match_close(t: str, i: int) -> int:
    """`t[i]` 의 여는 괄호에 맞는 닫는 자리. 종류가 다른 괄호도 깊이에 든다."""
    stack = [OPENERS[t[i]]]
    j = i + 1
    while j < len(t):
        c = t[j]
        if c in OPENERS:
            stack.append(OPENERS[c])
        elif stack and c == stack[-1]:
            stack.pop()
            if not stack:
                return j
        j += 1
    raise AssertionError("닫히지 않는 괄호가 있다")


def signature_binders(t: str) -> set[str]:
    """선언 이름 뒤의 문면에서 진술 머리에 쓴 바인더의 이름. 깊이 영의 쌍점에서 멈춘다."""
    names: set[str] = set()
    i = 0
    while i < len(t):
        c = t[i]
        if c in OPENERS:
            j = _match_close(t, i)
            inner = t[i + 1:j]
            depth, k = 0, None
            for q, ch in enumerate(inner):
                if ch in OPENERS:
                    depth += 1
                elif ch in OPENERS.values():
                    depth -= 1
                elif ch == ":" and depth == 0:
                    k = q
                    break
            if k is not None:
                names.update(inner[:k].split())
            i = j + 1
            continue
        if c == ":":
            break
        i += 1
    return names


def source_theorems(root: Path, files: list[str]) -> dict[str, tuple[str, set[str]]]:
    """정리의 완전 이름에서 (파일, 진술 머리의 바인더 이름) 으로 가는 사상."""
    out: dict[str, tuple[str, set[str]]] = {}
    for f in files:
        code = mask((root / f).read_text(encoding="utf-8"))
        lines = code.split("\n")
        offs = [0]
        for ln in lines:
            offs.append(offs[-1] + len(ln) + 1)
        stack: list[tuple[str, str]] = []
        for no, ln in enumerate(lines):
            m = OPEN.match(ln)
            if m:
                stack.append((m.group(1), m.group(2)))
                continue
            if END.match(ln):
                if stack:
                    stack.pop()
                continue
            m = THEOREM_HEAD.match(ln)
            if not m:
                continue
            ns = ".".join(n for k, n in stack if k == "namespace" and n)
            full = "%s.%s" % (ns, m.group(1)) if ns else m.group(1)
            start = offs[no] + m.end()
            stop = code.find(":=", start)
            assert stop > 0, "%s 의 정리 %s 에 `:=` 가 없다" % (f, full)
            out[full] = (f, signature_binders(code[start:stop]))
    return out


def group_of(root: Path, arc: str) -> dict[str, str]:
    """파일에서 그 파일을 훑는 페이즈로 가는 사상. 아크 값 정본의 페이즈 레코드에서 유도한다."""
    a = json.loads((root / "docs" / "arcs.json").read_text(encoding="utf-8"))
    rec = [r for r in a["arcs"] if r.get("name") == arc]
    assert len(rec) == 1, "아크 %r 의 레코드가 하나가 아니다" % arc
    out: dict[str, str] = {}
    for p in rec[0].get("phases") or []:
        m = GROUP_FILES.search(p.get("builds") or "")
        if not m:
            continue
        for x in m.group(1).split(" · "):
            f = "CrisisFramework/%s.lean" % x.strip()
            assert f not in out, "파일 %s 이 두 페이즈에 배정됐다" % f
            out[f] = p["name"]
    return out


def paragraphs(root: Path, files: list[str]) -> list[dict]:
    """문서화 문면과 파일 머리의 문단마다 특징을 낸다."""
    led = Ledger(root)
    _since, forms = heading_rules(led)
    words = sorted(forms)
    out: list[dict] = []

    def feat(where: str, owner: str, f: str, idx: int, p: str) -> dict:
        head = para_heading(p)
        hit = [w for w in words if head and w in head]
        flat = fold(p)
        return {"where": where, "owner": owner, "file": f, "index": idx,
                "heading": head or "", "reserved": hit,
                "kind": ("summary" if idx == 0 else
                         "reserved" if hit else "free" if head else "plain"),
                "sourcing": bool(SOURCING_LINE.search(flat)),
                "pointers": len(EXTRACTION_POINTER.findall(p)),
                "citations": len(CITATION.findall(flat)),
                "chars": len(flat), "text": flat}

    for f in files:
        src = (root / f).read_text(encoding="utf-8")
        m = HEAD_BLOCK.match(src)
        if m:
            paras = [x.strip() for x in PARA_SPLIT.split(m.group(1).strip()) if x.strip()]
            for i, p in enumerate(paras):
                out.append(feat("header", f, f, i, p))
    for d in led.doc_decls():
        for i, p in enumerate(d.paras):
            out.append(feat("doc", d.full, d.rel, i, p))
    return out


def is_candidate(p: dict) -> bool:
    """조달처 줄이 없는 주장 문단인가. 한 줄 서술과 판정 문단과 표현의 선택만 드는 문단은 대상이 아니다."""
    if p["sourcing"] or p["kind"] == "summary":
        return False
    if "보조 논증 판정" in p["heading"]:
        return False
    return not is_representation(p)


def is_representation(p: dict) -> bool:
    """표현의 선택을 드는 예약 머리말의 문단인가."""
    if p["kind"] != "reserved":
        return False
    head = p["heading"]
    if any(_form_match(f, head) for f in REPRESENTATION_FORMS):
        return True
    return bool(p["reserved"]) and all(w in REPRESENTATION_WORDS for w in p["reserved"])


def _form_match(form: str, head: str) -> bool:
    if "*" not in form:
        return form == head
    pre, suf = form.split("*", 1)
    return head.startswith(pre) and head.endswith(suf) and len(head) > len(pre) + len(suf)


def tier(p: dict) -> int:
    """읽는 순서의 층. 자유 문단과 파일 머리가 앞이고 예약 머리말의 문단이 뒤다."""
    return 0 if p["kind"] in ("free", "plain") else 1


def assert_forms(root: Path) -> None:
    """표현의 선택을 드는 형과 낱말이 값 정본의 머리말 블록에 실재하는지 단언한다."""
    _since, forms = heading_rules(Ledger(root))
    all_forms = {f for v in forms.values() for f in v}
    missing = [f for f in REPRESENTATION_FORMS if f not in all_forms]
    assert not missing, "표현의 선택을 드는 형이 머리말 블록에 없다: %r" % missing
    missing = [w for w in REPRESENTATION_WORDS if w not in forms]
    assert not missing, "표현의 선택을 드는 낱말이 머리말 블록에 없다: %r" % missing


def measure(root: Path, arc: str, extra: str = "") -> dict:
    files = cq_reach.tracked_lean(root)
    decls = cq_reach.source_decls(root, files)
    thms = source_theorems(root, files)
    lp = lean_props(root, files, extra)
    lean_thms = set(lp["hyps"])
    # 소스의 정리 머리 스캔과 감사 단계의 선언 목록을 맞댄다. 이 모듈이 정리의 머리를 다시 뽑으므로, 그 뽑기가
    # 감사 단계와 갈리면 서명의 바인더가 엉뚱한 정리에 붙는다.
    ghost = [n for n in thms if n not in decls]
    assert not ghost, "소스 스캔의 정리가 선언 목록에 없다: %r" % ghost[:3]
    hyp_rows, field_rows = [], []
    for n in sorted(lean_thms):
        if n not in thms:
            continue
        f, sig = thms[n]
        for b, t in lp["hyps"][n]:
            if b in sig:
                hyp_rows.append({"theorem": n, "file": f, "binder": b, "type": t})
    for s in sorted(lp["fields"]):
        if s not in decls:
            continue
        for fld, t in lp["fields"][s]:
            field_rows.append({"structure": s, "file": decls[s][1], "field": fld, "type": t})
    assert_forms(root)
    paras = paragraphs(root, files)
    cands = [p for p in paras if is_candidate(p)]
    for p in cands:
        p["tier"] = tier(p)
    cands.sort(key=lambda p: (p["tier"], p["pointers"] + p["citations"], p["file"], p["owner"], p["index"]))
    excluded = sum(1 for p in paras if is_representation(p) and not p["sourcing"])
    groups = group_of(root, arc)
    by_group: dict[str, dict[str, int]] = {}
    for kind, rows in (("hyp", hyp_rows), ("field", field_rows), ("para", cands)):
        for r in rows:
            g = groups.get(r["file"], "배정 없음")
            by_group.setdefault(g, {"hyp": 0, "field": 0, "para": 0, "para_front": 0})
            by_group[g][kind] += 1
            if kind == "para" and r["tier"] == 0:
                by_group[g]["para_front"] += 1
    kinds: dict[str, int] = {}
    for p in cands:
        kinds[p["kind"] + ":" + p["where"]] = kinds.get(p["kind"] + ":" + p["where"], 0) + 1
    return {"files": len(files), "theorems": len(thms), "paragraphs": len(paras),
            "representation_excluded": excluded,
            "hyp_rows": hyp_rows, "field_rows": field_rows, "candidates": cands,
            "candidate_kinds": kinds, "by_group": by_group,
            "lean_hyp_theorems": sorted(lean_thms), "raw_hyps": lp["hyps"]}


UNIVERSE = ("명제 가정은 소스의 정리 가운데 진술 머리에 쓴 바인더의 타입이 명제인 것이다. 명제 필드는 소스의 "
            "구조체의 필드 가운데 타입이 명제인 것이다. 문단 후보는 선언의 문서화 문면과 파일 머리의 블록 주석을 "
            "빈 줄로 가른 문단 가운데 조달처 줄이 없고 첫 문단이 아니며 판정 문단이 아니고 표현의 선택을 드는 "
            "예약 머리말의 문단이 아닌 것이다. 앞 층은 자유 머리말과 머리말 없는 문단이고 뒤 층은 예약 머리말의 "
            "문단이다.")


def render(m: dict, root: Path, arc: str) -> str:
    cmd = "python3 -I scripts/aux_candidates.py report --root %s --arc %s" % (root, arc)
    bare = sum(1 for p in m["candidates"] if p["pointers"] + p["citations"] == 0)
    front = sum(1 for p in m["candidates"] if p["tier"] == 0)
    lines = ["명령: " + cmd, "유니버스: " + UNIVERSE,
             "형식층 파일 %d · 정리 %d · 문단 %d · 표현의 선택으로 뺀 문단 %d" % (
                 m["files"], m["theorems"], m["paragraphs"], m["representation_excluded"]),
             "명제 가정 %d (정리 %d) · 명제 필드 %d (구조체 %d)" % (
                 len(m["hyp_rows"]), len({r["theorem"] for r in m["hyp_rows"]}),
                 len(m["field_rows"]), len({r["structure"] for r in m["field_rows"]})),
             "문단 후보 %d · 앞 층 %d · 지목과 인용이 없는 것 %d" % (len(m["candidates"]), front, bare)]
    for k in sorted(m["candidate_kinds"]):
        lines.append("  갈래 %s: %d" % (k, m["candidate_kinds"][k]))
    for g in sorted(m["by_group"], key=lambda x: (len(x), x)):
        v = m["by_group"][g]
        lines.append("  %s: 명제 가정 %d · 명제 필드 %d · 문단 후보 %d · 앞 층 %d" % (
            g, v["hyp"], v["field"], v["para"], v["para_front"]))
    return "\n".join(lines)


def write_tsv(m: dict, path: Path) -> None:
    rows = ["갈래\t파일\t주인\t자리\t층\t머리말\t조달처\t지목\t인용\t길이\t문면"]
    for r in m["hyp_rows"]:
        rows.append("명제 가정\t%s\t%s\t%s\t\t\t\t\t\t\t%s" % (r["file"], r["theorem"], r["binder"], r["type"]))
    for r in m["field_rows"]:
        rows.append("명제 필드\t%s\t%s\t%s\t\t\t\t\t\t\t%s" % (r["file"], r["structure"], r["field"], r["type"]))
    for p in m["candidates"]:
        rows.append("문단\t%s\t%s\t%s:%d\t%d\t%s\t%s\t%d\t%d\t%d\t%s" % (
            p["file"], p["owner"], p["where"], p["index"], p["tier"], p["heading"], "있음" if p["sourcing"] else "없음",
            p["pointers"], p["citations"], p["chars"], p["text"].replace("\t", " ")))
    path.write_text("\n".join(rows) + "\n", encoding="utf-8")


def _copy_root(root: Path, dest: Path) -> None:
    """문단 쪽 대조에 쓸 리포 밖 사본. 형식층과 원장과 값 정본만 옮긴다."""
    shutil.copytree(root / "CrisisFramework", dest / "CrisisFramework")
    shutil.copytree(root / "docs", dest / "docs")


def selftest(root: Path, arc: str) -> list[str]:
    files = cq_reach.tracked_lean(root)
    base = lean_props(root, files)
    fwd = lean_props(root, files, "theorem auxNegFwd (n : Nat) (hPos : 0 < n) : 0 < n + 1 := by omega\n")
    assert fwd["hyps"].get("auxNegFwd") == [("hPos", "0 < n")], "Lean 정방향: 명제 가정이 잡히지 않았다: %r" % (
        fwd["hyps"].get("auxNegFwd"),)
    assert {k: v for k, v in fwd["hyps"].items() if k != "auxNegFwd"} == base["hyps"], "Lean 정방향: 다른 정리가 달라졌다"
    rev = lean_props(root, files, "theorem auxNegRev (n : Nat) : n ≤ n + 1 := by omega\n")
    assert "auxNegRev" not in rev["hyps"] and rev["hyps"] == base["hyps"], "Lean 역방향: 명제 가정이 아닌 것이 잡혔다"
    sfx = lean_props(root, files, "structure AuxNegS where\n  n : Nat\n  pos : 0 < n\n  flag : Bool\n")
    assert [f for f, _t in sfx["fields"].get("AuxNegS", [])] == ["pos"], "필드 대조: 명제 필드만 잡히지 않았다: %r" % (
        sfx["fields"].get("AuxNegS"),)
    assert signature_binders(" (a : Nat) (h : 0 < a) : ∀ x, x < a → x < a + 1") == {"a", "h"}, \
        "서명: 결론 안의 전칭이 진술 머리의 바인더로 잡혔다"
    led = Ledger(root)
    target = next(d for d in led.doc_decls() if d.paras and d.rel.startswith("CrisisFramework/Accounting/"))
    with tempfile.TemporaryDirectory() as dd:
        results = []
        for tail in ("", "\n조달처: E-04 §2-2 「각 투자자의 부채 상한은 보유 자산에」"):
            work = Path(dd) / ("w%d" % len(results))
            _copy_root(root, work)
            path = work / target.rel
            src = path.read_text(encoding="utf-8")
            anchor = target.paras[-1]
            assert src.count(anchor) == 1, "대조의 문단이 그 파일에 하나로 서지 않는다"
            para = "**음성 대조의 문단.** 이 문단은 조달처 줄이 없는 주장을 든다." + tail
            path.write_text(src.replace(anchor, anchor + "\n\n" + para, 1), encoding="utf-8")
            results.append(sum(1 for p in paragraphs(work, files) if is_candidate(p)))
        n0 = sum(1 for p in paragraphs(root, files) if is_candidate(p))
    assert results[0] == n0 + 1, "문단 정방향: 조달처 줄이 없는 문단이 후보로 잡히지 않았다 (%d → %d)" % (n0, results[0])
    assert results[1] == n0, "문단 역방향: 조달처 줄을 든 문단이 후보로 잡혔다 (%d → %d)" % (n0, results[1])
    return ["Lean 정방향: 명제 가정을 든 정리의 바인더가 잡힌다",
            "Lean 역방향: 명제 가정이 없는 정리가 잡히지 않는다",
            "필드 대조: 구조체의 명제 필드만 잡히고 수와 판정의 필드는 잡히지 않는다",
            "서명: 결론 안의 전칭이 진술 머리의 바인더로 잡히지 않는다",
            "문단 정방향: 조달처 줄이 없는 문단 하나가 후보를 하나 늘린다 (%d → %d)" % (n0, results[0]),
            "문단 역방향: 조달처 줄을 든 같은 문단은 후보를 늘리지 않는다"]


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["report", "selftest"])
    ap.add_argument("--root", default=str(ROOT))
    ap.add_argument("--arc", default="bypass2")
    ap.add_argument("--json")
    ap.add_argument("--tsv")
    a = ap.parse_args(argv)
    root = Path(a.root).resolve()
    if a.mode == "selftest":
        for line in selftest(root, a.arc):
            print("OK", line)
        return 0
    m = measure(root, a.arc)
    print(render(m, root, a.arc))
    if a.json:
        Path(a.json).write_text(json.dumps(m, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    if a.tsv:
        write_tsv(m, Path(a.tsv))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
