#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""보조 논증의 판정 문단의 꼴을 재는 결정 세션의 설비.

**이 모듈은 검증 스크립트가 부르지 않는다.** 판정 문단을 앞으로 서는 선언에도 요구하는 상주 조항과 그 검사를
둘지가 아크의 마지막 페이즈의 몫으로 미뤄져 있으므로, 그때까지 이 설비가 그 꼴을 결정 세션의 조작으로 잰다.

판정 문단은 머리말이 값 정본의 머리말 블록이 예약 낱말 `보조 논증` 에 둔 형인 문단이다. 그 형을 이 모듈이
상수로 들지 않고 그 블록에서 꺼낸다. 문단은 「주장은」 으로 시작하는 산문과 목록의 항으로 서고, 한 선언이
주장을 둘 이상 들면 「주장은」 으로 시작하는 줄에서 산문과 항이 되풀이된다. 재는 것은 다음과 같다.

1. 산문이 「주장은」 으로 시작하고, 「그 자리는」 이 든 문장이 자리의 낱말 넷 가운데 하나만 들며, 「이 주장이
   거짓이려면」 이 서는가. 첫 묶음의 산문이 판정을 받는 원장 항목을 「이 판정을 원장의 CF-n 가 받는다」 꼴로
   들고 그 항목이 결정 레지스터에서 살아 있는가. 번호를 감싼 백틱은 있어도 없어도 받고, 조사는 번호를 읽는
   소리에 따라 「이」 와 「가」 를 함께 받는다.
2. 인자의 항이 `- 인자 <번호> · <등급> · <설명>` 이고 번호가 하나부터 이어지며 등급이 넷 가운데 하나인가.
   공표 실측과 제한 실측과 대리 추정은 추출 기록의 절을 하나 이상 지목하고 그 지목이 실재하는 기록의 실재하는
   절에 닿는가. 대리 추정은 「전제」 를 드는가. 측정 불가는 관측층의 판정 불가 까닭 열거의 생성자를 백틱으로
   드는가. 그 생성자의 목록은 이 모듈이 들지 않고 형식층 소스에서 뽑는다.
3. `- 결합 · <등급>` 이 하나 서고 인자의 가장 낮은 등급과 같은가. 결합이 측정 불가이면 측정 불가인 인자마다
   `- 우회 · <꼴> · 인자 <번호> · <설명>` 이나 `- 새 구멍 · CF-n · 인자 <번호> · <설명>` 이 서는가. 우회의
   꼴이 여섯 가운데 하나이고 그 인자가 측정 불가인가. 우회가 서면 `- 우회 뒤의 결합 · <등급>` 이 하나 서고
   우회하지 않은 인자의 가장 낮은 등급과 같은가. 결합이 측정 불가가 아니면 우회가 서지 않는가. 새 구멍의
   항목이 이연 레지스터에서 살아 있는가.

등급과 자리와 우회의 꼴의 낱말은 그것을 정한 원장 항목의 문면에 실재하는지를 단언하므로 박아 둔 값이 아니라
단언이 지키는 값이다. 원장이 수정되지 않으므로 그 항목의 문면은 구조적으로 바뀌지 않는다.

쓰는 꼴은 둘이다.

    python3 -I scripts/aux_judgment.py report [--root 리포]
    python3 -I scripts/aux_judgment.py selftest [--root 리포]

`report` 는 리포의 판정 문단마다 적발을 내고, 적발이 하나라도 있으면 종료 코드 1 로 끝난다. `selftest` 는
리포의 기록과 원장을 딛는 합성 문단으로 꼴에 맞는 문단의 적발이 영인지와, 어긋남을 하나씩 주입한 사본마다
적발이 서는지를 잰다. 합성 문단이 판정을 받는 결정과 새 구멍은 원장 번호로 박아 두지 않고 지금의 원장에서
결정 레지스터와 이연 레지스터의 마지막 살아 있는 항목을 꺼낸다. 박아 두면 그 항목이 폐기되는 회차마다 꼴에
맞는 문단에서 적발이 서서 자기 시험이 깨진다.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from wiki_common import EXTRACTION_POINTER, Ledger, extraction_record, heading_rules, para_heading  # noqa: E402
from wiki_formal import extraction_sections, fold  # noqa: E402

ROOT = HERE.parent
WORD = "보조 논증"
GRADES = ("공표 실측", "제한 실측", "대리 추정", "측정 불가")
GRADES_FROM = "CF-4961"
SITES = ("이음", "넓힘", "정당화", "행태 전제")
SITES_FROM = "CF-4960"
FORMS = ("특징짓기", "물음 밖", "외생 입력", "기존 규율의 흡수", "범위 밖", "쓰는 자리의 단언")
FORMS_FROM = "CF-4873"
REASON_FILE = "CrisisFramework/Observation/CompetencyQuestion.lean"
REASON_BLOCK = re.compile(r"inductive UndeterminedReason where\n(.*?)\n\s*deriving", re.S)
REASON_CTOR = re.compile(r"^\s*\|\s*(\w+)\s*$", re.M)
ITEM = re.compile(r"^- (인자 (\d+)|결합|우회 뒤의 결합|우회|새 구멍) · (.*)$", re.S)
RECEIVER = re.compile(r"이 판정을 원장의 `?(CF-\d+)`? (?:이|가) 받는다")
CF_ID = re.compile(r"\bCF-\d+\b")
BACKTICK = re.compile(r"`([^`]+)`")


class Ctx:
    """판정이 딛는 리포의 실물. 원장과 추출 기록과 까닭의 생성자와 머리말의 형이다."""

    def __init__(self, root: Path):
        self.led = Ledger(root)
        _since, forms = heading_rules(self.led)
        assert WORD in forms and len(forms[WORD]) == 1, "머리말 블록에 `%s` 의 형이 하나로 서지 않는다" % WORD
        self.form = forms[WORD][0]
        for words, src in ((GRADES, GRADES_FROM), (SITES, SITES_FROM), (FORMS, FORMS_FROM)):
            e = self.led.by_id.get(src)
            assert e is not None, "낱말을 정한 원장 항목 %s 가 없다" % src
            text = (e.get("statement") or "") + (e.get("basis") or "")
            missing = [w for w in words if w not in text]
            assert not missing, "원장 항목 %s 의 문면에 낱말이 없다: %r" % (src, missing)
        m = REASON_BLOCK.search((root / REASON_FILE).read_text(encoding="utf-8"))
        assert m, "판정 불가 까닭 열거를 찾지 못했다"
        self.reasons = set(REASON_CTOR.findall(m.group(1)))
        assert self.reasons, "판정 불가 까닭의 생성자가 영이다"
        self._secs: dict[int, dict[str, str]] = {}

    def lands(self, n: int, sec: str) -> bool:
        if n not in self._secs:
            f = extraction_record(self.led, n)
            self._secs[n] = extraction_sections(f) if f is not None else {}
        return sec in self._secs[n]

    def live(self, reg: str, cid: str) -> bool:
        return any(e.get("id") == cid for e in self.led.reg[reg]) and cid not in self.led.dead


def _blocks(body: str) -> list[tuple[str, list[tuple[str, str | None, str]]]]:
    """본문을 주장의 묶음으로 가른다. 묶음은 (산문, [(항의 갈래, 인자 번호, 설명)]) 이다."""
    blocks: list[list] = []
    cur_items: list[list] | None = None
    for raw in body.split("\n"):
        ln = raw.strip()
        if not ln:
            continue
        if ln.startswith("주장은") and (not blocks or cur_items):
            blocks.append([ln, []])
            cur_items = blocks[-1][1]
            continue
        if not blocks:
            blocks.append([ln, []])
            cur_items = blocks[-1][1]
            continue
        if ln.startswith("- "):
            m = ITEM.match(ln)
            if m:
                kind = "인자" if m.group(1).startswith("인자") else m.group(1)
                cur_items.append([kind, m.group(2), m.group(3)])
            else:
                cur_items.append(["?", None, ln])
            continue
        if cur_items:
            cur_items[-1][2] += " " + ln
        else:
            blocks[-1][0] += " " + ln
    return [(fold(p), [(k, n, fold(t)) for k, n, t in items]) for p, items in blocks]


def _grade_min(gs: list[str]) -> str | None:
    return max(gs, key=GRADES.index) if gs else None


def check_paragraph(text: str, ctx: Ctx) -> list[str]:
    """판정 문단 하나의 적발."""
    out: list[str] = []
    head = para_heading(text)
    if head != ctx.form:
        return ["머리말이 형 `%s` 와 다르다: %r" % (ctx.form, head)]
    body = text.split("**", 2)[2] if text.count("**") >= 2 else ""
    blocks = _blocks(body)
    if not blocks:
        return ["본문이 없다"]
    for bi, (prose, items) in enumerate(blocks, 1):
        tag = "주장 %d" % bi
        if not prose.startswith("주장은"):
            out.append("%s: 산문이 「주장은」 으로 시작하지 않는다" % tag)
        sents = [s for s in re.split(r"(?<=다)\.\s*", prose) if "그 자리는" in s]
        if len(sents) != 1:
            out.append("%s: 「그 자리는」 이 든 문장이 하나가 아니다" % tag)
        else:
            hit = [w for w in SITES if w in sents[0]]
            if len(hit) != 1:
                out.append("%s: 그 자리의 낱말이 하나가 아니다: %r" % (tag, hit))
        if "이 주장이 거짓이려면" not in prose:
            out.append("%s: 「이 주장이 거짓이려면」 이 없다" % tag)
        if bi == 1:
            m = RECEIVER.search(prose)
            if not m:
                out.append("%s: 판정을 받는 원장 항목이 없다" % tag)
            elif not ctx.live("decisions", m.group(1)):
                out.append("%s: 판정을 받는 %s 가 결정 레지스터에 살아 있지 않다" % (tag, m.group(1)))
        factors: dict[int, str] = {}
        order: list[int] = []
        combined, after, bypassed = [], [], {}
        for kind, num, desc in items:
            parts = [x.strip() for x in desc.split(" · ")]
            if kind == "인자":
                n = int(num)
                order.append(n)
                g = parts[0]
                if g not in GRADES:
                    out.append("%s 인자 %d: 등급 %r 이 넷 가운데 하나가 아니다" % (tag, n, g))
                    continue
                factors[n] = g
                rest = desc[len(g):]
                if g != "측정 불가":
                    ptrs = EXTRACTION_POINTER.findall(rest)
                    if not ptrs:
                        out.append("%s 인자 %d: 추출 기록의 지목이 없다" % (tag, n))
                    for rn, sec in ptrs:
                        if not ctx.lands(int(rn), sec):
                            out.append("%s 인자 %d: 지목 E-%s §%s 이 닿지 않는다" % (tag, n, rn, sec))
                    if g == "대리 추정" and "전제" not in rest:
                        out.append("%s 인자 %d: 대리 추정이 전제를 들지 않는다" % (tag, n))
                else:
                    ctors = [c for c in BACKTICK.findall(rest) if c in ctx.reasons]
                    if len(ctors) != 1:
                        out.append("%s 인자 %d: 판정 불가 까닭의 생성자가 하나가 아니다: %r" % (
                            tag, n, BACKTICK.findall(rest)))
            elif kind == "결합":
                combined.append(parts[0])
            elif kind == "우회 뒤의 결합":
                after.append(parts[0])
            elif kind in ("우회", "새 구멍"):
                if len(parts) < 3 or not re.fullmatch(r"인자 \d+", parts[1]):
                    out.append("%s %s: 꼴이 `<꼴이나 원장 번호> · 인자 <번호> · <설명>` 이 아니다" % (tag, kind))
                    continue
                n = int(parts[1].split()[1])
                if kind == "우회":
                    if parts[0] not in FORMS:
                        out.append("%s 우회: 꼴 %r 이 여섯 가운데 하나가 아니다" % (tag, parts[0]))
                    bypassed.setdefault(n, []).append("우회")
                else:
                    cid = parts[0].strip("`")
                    if not CF_ID.fullmatch(cid) or not ctx.live("deferred", cid):
                        out.append("%s 새 구멍: %r 가 이연 레지스터에 살아 있지 않다" % (tag, parts[0]))
                    bypassed.setdefault(n, []).append("새 구멍")
            else:
                out.append("%s: 꼴을 알 수 없는 항: %r" % (tag, desc[:60]))
        if not order:
            out.append("%s: 인자의 항이 없다" % tag)
        elif order != list(range(1, len(order) + 1)):
            out.append("%s: 인자의 번호가 하나부터 이어지지 않는다: %r" % (tag, order))
        want = _grade_min(list(factors.values()))
        if len(combined) != 1:
            out.append("%s: 결합의 항이 하나가 아니다" % tag)
        elif want is not None and combined[0] != want:
            out.append("%s: 결합 %r 이 인자의 가장 낮은 등급 %r 과 다르다" % (tag, combined[0], want))
        for n in bypassed:
            if n not in factors:
                out.append("%s: 우회나 새 구멍이 없는 인자 %d 을 가리킨다" % (tag, n))
        detour = {n for n, ks in bypassed.items() if "우회" in ks}
        for n in detour:
            if factors.get(n) not in (None, "측정 불가"):
                out.append("%s: 측정 불가가 아닌 인자 %d 에 우회를 걸었다" % (tag, n))
        if want == "측정 불가":
            for n, g in factors.items():
                if g == "측정 불가" and n not in bypassed:
                    out.append("%s: 측정 불가인 인자 %d 에 우회도 새 구멍도 없다" % (tag, n))
        elif detour:
            out.append("%s: 결합이 측정 불가가 아닌데 우회가 섰다" % tag)
        if detour:
            rest = _grade_min([g for n, g in factors.items() if n not in detour])
            if len(after) != 1:
                out.append("%s: 우회 뒤의 결합의 항이 하나가 아니다" % tag)
            elif rest is None or after[0] != rest:
                out.append("%s: 우회 뒤의 결합 %r 이 남은 인자의 가장 낮은 등급 %r 과 다르다" % (tag, after[0], rest))
        elif after:
            out.append("%s: 우회가 없는데 우회 뒤의 결합이 섰다" % tag)
    return out


def judged(ctx: Ctx) -> list[tuple[str, str, str]]:
    """리포의 판정 문단. (파일, 선언, 문단) 이다."""
    out = []
    for d in ctx.led.doc_decls():
        for p in d.paras:
            h = para_heading(p)
            if h is not None and WORD in h:
                out.append((d.rel, d.full, p))
    return out


SAMPLE = """**보조 논증 판정:** 주장은 합성 문단의 주장이며, 그 자리는 이음이다. 이 주장이 거짓이려면
합성 문단이 그리는 관측이 서야 한다. 이 판정을 원장의 `@RECV@` 이 받는다.
- 인자 1 · 공표 실측 · 할인율의 격자(E-49 §2-11)
- 인자 2 · 제한 실측 · 감독 지표(E-56 §2-7)
- 인자 3 · 측정 불가 · 반사실 미평가(`counterfactualUnevaluated`). 얻지 않은 조달의 액수를 요구한다
- 결합 · 측정 불가
- 우회 · 특징짓기 · 인자 3 · 주장을 상한으로 약하게 한다
- 우회 뒤의 결합 · 제한 실측
- 새 구멍 · `@HOLE@` · 인자 3 · 합성 문단의 남는 독해"""

MUTANTS = (
    ("결합이 가장 낮은 등급과 다르다", "- 결합 · 측정 불가", "- 결합 · 제한 실측"),
    ("측정 불가가 아닌 인자에 우회를 걸었다", "- 우회 · 특징짓기 · 인자 3", "- 우회 · 특징짓기 · 인자 2"),
    ("지목이 없다", "감독 지표(E-56 §2-7)", "감독 지표"),
    ("지목이 닿지 않는다", "(E-49 §2-11)", "(E-49 §99-1)"),
    ("까닭의 생성자가 열거에 없다", "`counterfactualUnevaluated`", "`counterfactualMissing`"),
    ("인자의 번호가 이어지지 않는다", "- 인자 2 ·", "- 인자 4 ·"),
    ("반증의 문장이 없다", "이 주장이 거짓이려면", "이 주장이 틀리려면"),
    ("자리의 낱말이 없다", "그 자리는 이음이다", "그 자리는 연결이다"),
    ("우회 뒤의 결합이 다르다", "- 우회 뒤의 결합 · 제한 실측", "- 우회 뒤의 결합 · 공표 실측"),
    ("우회의 꼴이 여섯에 없다", "- 우회 · 특징짓기", "- 우회 · 약화"),
    ("받는 항목이 결정 레지스터에 없다", "`@RECV@` 이 받는다", "`@HOLE@` 이 받는다"),
    ("새 구멍이 이연 레지스터에 없다", "- 새 구멍 · `@HOLE@`", "- 새 구멍 · `@RECV@`"),
    ("측정 불가에 우회가 없다", "- 우회 · 특징짓기 · 인자 3 · 주장을 상한으로 약하게 한다\n", ""),
)


def _last_live(ctx: Ctx, reg: str) -> str:
    """그 레지스터의 마지막 살아 있는 항목의 번호. 합성 문단이 박아 둔 번호에 매이지 않게 한다."""
    for e in reversed(ctx.led.reg[reg]):
        cid = e.get("id")
        if cid and cid not in ctx.led.dead:
            return cid
    raise AssertionError("%s 레지스터에 살아 있는 항목이 없다" % reg)


def selftest(root: Path) -> list[str]:
    ctx = Ctx(root)
    recv, hole = _last_live(ctx, "decisions"), _last_live(ctx, "deferred")

    def fill(s: str) -> str:
        return s.replace("@RECV@", recv).replace("@HOLE@", hole)

    sample = fill(SAMPLE)
    base = check_paragraph(sample, ctx)
    assert not base, "꼴에 맞는 합성 문단에서 적발이 섰다: %r" % base
    out = ["꼴에 맞는 합성 문단의 적발이 영이다 (받는 결정 %s · 새 구멍 %s)" % (recv, hole)]
    for name, a, b in MUTANTS:
        a, b = fill(a), fill(b)
        assert sample.count(a) == 1, "주입 자리가 하나가 아니다: %s" % name
        got = check_paragraph(sample.replace(a, b, 1), ctx)
        assert got, "주입이 잡히지 않았다: %s" % name
        out.append("주입 %s: 적발 %d" % (name, len(got)))
    free = sample.replace("**보조 논증 판정:**", "**합성 문단.**", 1)
    assert para_heading(free) != ctx.form, "자유 머리말 대조의 머리말이 형과 같다"
    out.append("판정 문단이 아닌 문단은 대상에 들지 않는다")
    return out


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["report", "selftest"])
    ap.add_argument("--root", default=str(ROOT))
    a = ap.parse_args(argv)
    root = Path(a.root).resolve()
    if a.mode == "selftest":
        for line in selftest(root):
            print("OK", line)
        return 0
    ctx = Ctx(root)
    rows = judged(ctx)
    bad = 0
    print("명령: python3 -I scripts/aux_judgment.py report --root %s" % root)
    print("유니버스: 선언의 문서화 문면에서 머리말이 예약 낱말 `%s` 을 든 문단" % WORD)
    print("판정 문단 %d · 그 문단이 선 선언 %d" % (len(rows), len({d for _f, d, _p in rows})))
    for f, d, p in rows:
        got = check_paragraph(p, ctx)
        bad += len(got)
        print("%s %s: 적발 %d" % (f, d, len(got)))
        for g in got:
            print("  " + g)
    print("적발 합계 %d" % bad)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
