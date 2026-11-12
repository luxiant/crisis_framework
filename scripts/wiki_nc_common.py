"""원장 검증기 음성 대조의 전용 공용 설비.

갈래별 음성 대조 단위 가운데 둘 이상이 쓰는 보조를 든다. 한 단위만 쓰는 보조는 그 단위가
들고 여기 두지 않는다. **생산 공용 설비에 두지 않는 까닭은** 이 보조가 전량 주입 전용이고
원장과 아크 값 정본을 고치는 것이어서 검사를 돌리는 경로가 그것을 들일 자리가 없다는 것이다.
"""

from __future__ import annotations

import json
import types
from pathlib import Path
import wiki_common


# ------------------------------------------------------------------ 주입 도구

def load(root: Path, reg: str) -> dict:
    return json.loads((root / "docs" / "decisions" / f"{reg}.json").read_text(encoding="utf-8"))


def save(root: Path, reg: str, doc: dict) -> None:
    (root / "docs" / "decisions" / f"{reg}.json").write_text(
        json.dumps(doc, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")


def pick(root: Path, reg: str, pred) -> dict:
    for e in load(root, reg)[reg]:
        if pred(e):
            return e
    raise SystemExit(f"주입 대상을 찾지 못했다: {reg}")


def edit(root: Path, reg: str, eid: str, fn) -> None:
    doc = load(root, reg)
    for e in doc[reg]:
        if e["id"] == eid:
            fn(e)
            break
    else:
        raise SystemExit(f"{eid} 가 {reg} 에 없다")
    save(root, reg, doc)


def deferred_stub(eid: str, reopen) -> dict:
    return {
        "id": eid,
        "origin": {"arc": "charter", "phase": "charter-6",
                   "kind": "decision_session", "date": "2026-09-19"},
        "names": [f"Z-{eid.split('-')[1]}"],
        "statement": "음성 대조가 주입한 항이다.",
        "basis": "음성 대조가 주입한 항이다.",
        "layer": "meta",
        "reopen_when": reopen,
        "related": [],
    }


def ko_word(value: int) -> str:
    """값을 한글 수사로 적는다. 검증기의 `ko_count` 가 읽는 꼴의 역이다.

    주입이 수를 하나 틀리게 적는 자리에서 쓴다. 조합의 두 표를 검증기에서 가져오므로 주입과
    판정이 같은 어휘를 쓰고, 전사하면 한쪽을 고칠 때 다른 쪽이 조용히 낡는다.
    """
    unit = {v: w for w, v in wiki_common.COUNT_KO_UNIT.items()}
    for tens, base in sorted(wiki_common.COUNT_KO_TENS.items(),
                             key=lambda x: -x[1]):
        if value >= base:
            rest = value - base
            if rest and rest not in unit:
                raise SystemExit(f"{value} 를 한글 수사로 적을 수 없다")
            return tens + (unit[rest] if rest else "")
    if value not in unit:
        raise SystemExit(f"{value} 를 한글 수사로 적을 수 없다")
    return unit[value]


# ----------------------------------------------------- 검사 55 · 56 · 57 · 페이즈의 답할 항과 그 계수

def _fixed_cq(root: Path) -> list[int]:
    """고정 절 블록이 드는 CQ 번호. 검증기의 수집기를 그대로 써서 주입과 판정이 같은 목록을 본다."""
    return wiki_common.cq_fixed(types.SimpleNamespace(root=root))
