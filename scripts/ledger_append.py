#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""원장 레지스터에 항목을 덧붙이고 값 정본의 원장 고정점을 다시 심는 결정 세션의 상주 설비.

**이 모듈은 검증 스크립트가 부르지 않는다.** 원장 항목을 쓰는 것은 결정 세션의 조작이고, 검사 64 가
이 설비가 심은 고정점을 맞댄다. **고정점의 유일한 필자가 이 설비다.** 고정점을 손으로 고치면 검사의
입력 블록을 고치는 결정이 되며, 그 값이 앞 항목의 변경을 덮을 수 있다.

쓰는 꼴은 넷이다.

    python3 scripts/ledger_append.py append <레지스터> <항목 JSON 파일> [--root 뿌리]
    python3 scripts/ledger_append.py replant [--root 뿌리]
    python3 scripts/ledger_append.py init [--root 뿌리]
    python3 scripts/ledger_append.py selftest

`append` 는 덧붙이기 전에 네 레지스터의 고정점이 서는지와 대상 레지스터의 항목 수가 고정점의 수와
같은지와 그 파일이 들여쓰기 하나의 직렬화와 같은지를 단언한다. 항목 JSON 파일은 항목의 배열을 든다.
덧붙일 항목의 식별자는 네 레지스터를 통틀어 가장 큰 번호의 다음부터 차례로 이어져야 하고, 항목마다
키 순서가 같은 키 집합을 가진 그 레지스터의 가장 최근 항목과 같아야 한다. 덧붙임은 배열을 닫는 꼬리
앞에 문면으로 하며, 앞 바이트가 그대로이고 결과가 들여쓰기 하나의 직렬화와 같음을 다시 단언한 뒤에
그 레지스터의 고정점 줄을 등장 횟수가 하나임을 단언하는 치환으로 고친다.

`replant` 는 설비를 거치지 않은 덧붙임을 받아들일 때 쓴다. 고정점이 묶은 접두가 그대로임을 단언한
뒤에만 고정점을 지금의 항목 수로 옮기므로 앞 항목의 변경을 받아들이지 않는다. 그 모드를 쓰는 회차는
그 덧붙임을 받아들이는 사유를 결정으로 세운다.

`init` 은 값 정본에 빈 고정점 블록이 서 있을 때 지금의 네 파일에서 처음 값을 심는다. 블록이 이미
값을 들면 거부하므로 고정점을 처음부터 다시 심는 길로 쓰이지 않는다.

`selftest` 는 이 파일이 만드는 합성 원장으로 단언마다 어긋남을 주입해 거부되는지를 잰다.
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from wiki_common import (  # noqa: E402
    ID_FORM,
    LEDGER_TAIL,
    LEDGERFIX_BLOCK,
    REGISTERS,
    ledger_prefix_digest,
    ledgerfix_rows,
)

ROOT = HERE.parent
BASELINE = Path("docs") / "baseline.md"


class Refuse(Exception):
    """단언이 서지 않아 원장과 값 정본을 건드리지 않고 멈춘다."""


def register_path(root: Path, name: str) -> Path:
    return root / "docs" / "decisions" / f"{name}.json"


def canonical(doc: dict) -> bytes:
    """들여쓰기 하나의 직렬화. 원장 네 파일이 이 꼴로 서 있다."""
    return (json.dumps(doc, indent=1, ensure_ascii=False) + "\n").encode("utf-8")


def fix_line(name: str, row: tuple[int, int, str]) -> str:
    return f"LEDGERFIX={name}|{row[0]}|{row[1]}|{row[2]}"


def read_register(root: Path, name: str) -> tuple[bytes, dict]:
    raw = register_path(root, name).read_bytes()
    return raw, json.loads(raw.decode("utf-8"))


def load_block(root: Path) -> tuple[str, dict[str, tuple[int, int, str]]]:
    """값 정본의 본문과 그 블록의 레지스터별 고정점. 블록이 넷을 다 들지 않으면 거부한다."""
    text = (root / BASELINE).read_text(encoding="utf-8")
    m = LEDGERFIX_BLOCK.search(text)
    if m is None:
        raise Refuse("값 정본에 LEDGERFIX 블록이 없다")
    rows, bad = ledgerfix_rows(m.group(1))
    if bad:
        raise Refuse(f"LEDGERFIX 블록에 꼴에 맞지 않는 줄이 있다: {bad[0]}")
    missing = [n for n in REGISTERS if n not in rows]
    if missing:
        raise Refuse(f"LEDGERFIX 블록에 {', '.join(missing)} 의 줄이 없다")
    return text, rows


def assert_fixpoint(name: str, raw: bytes, row: tuple[int, int, str]) -> None:
    _n, length, digest = row
    if (len(raw) < length or raw[length - 1:length] != b"}"
            or ledger_prefix_digest(raw, length) != digest):
        raise Refuse(f"{name}: 고정점이 묶은 앞 {length} 바이트가 블록의 해시 {digest} 와 맞지 않는다. "
                     f"앞 항목이 바뀌었다")


def assert_canonical(name: str, raw: bytes, doc: dict) -> None:
    if not doc.get(name):
        raise Refuse(f"{name}: 항목이 없는 레지스터에는 덧붙이지 않는다")
    if raw != canonical(doc):
        raise Refuse(f"{name}: 파일이 들여쓰기 하나의 직렬화와 다르다")
    if not raw.endswith(b"\n  }" + LEDGER_TAIL):
        raise Refuse(f"{name}: 파일의 꼬리가 마지막 항목과 배열과 객체를 닫는 꼴이 아니다")


def fix_of(raw: bytes, count: int) -> tuple[int, int, str]:
    """지금 파일의 고정점. 접두는 꼬리 앞까지이며 마지막 항목의 닫는 괄호로 끝난다."""
    length = len(raw) - len(LEDGER_TAIL)
    return count, length, ledger_prefix_digest(raw, length)


def replace_line(text: str, old: str, new: str) -> str:
    n = text.count(old + "\n")
    if n != 1:
        raise Refuse(f"값 정본에서 고정점 줄 `{old}` 의 등장이 {n} 이다")
    return text.replace(old + "\n", new + "\n", 1)


def top_id(docs: dict[str, dict]) -> int:
    top = 0
    for name, doc in docs.items():
        for e in doc.get(name) or []:
            m = ID_FORM.match(str(e.get("id", "")))
            if m:
                top = max(top, int(m.group(1)))
    return top


def assert_key_order(name: str, seen: list[dict], e: dict) -> None:
    keys = list(e.keys())
    for prev in reversed(seen):
        if set(prev.keys()) == set(keys):
            if list(prev.keys()) != keys:
                raise Refuse(f"{e.get('id')}: 키 순서가 같은 키 집합을 가진 가장 최근 항목 "
                             f"{prev.get('id')} 와 다르다: {keys} / {list(prev.keys())}")
            return
    raise Refuse(f"{e.get('id')}: 같은 키 집합을 가진 항목이 {name} 에 없다. 키 집합이 새로 서는 것은 "
                 f"스키마를 고치는 결정이다")


def append(root: Path, name: str, entries: list) -> tuple[list[str], tuple, tuple]:
    if name not in REGISTERS:
        raise Refuse(f"`{name}` 는 레지스터가 아니다")
    if not isinstance(entries, list) or not entries:
        raise Refuse("덧붙일 항목의 배열이 비었다")
    text, rows = load_block(root)
    raws: dict[str, bytes] = {}
    docs: dict[str, dict] = {}
    for r in REGISTERS:
        raws[r], docs[r] = read_register(root, r)
        assert_fixpoint(r, raws[r], rows[r])
    raw, doc = raws[name], docs[name]
    assert_canonical(name, raw, doc)
    have, want = len(doc[name]), rows[name][0]
    if have != want:
        raise Refuse(f"{name}: 항목이 {have} 인데 고정점의 수는 {want} 이다. 설비를 거치지 않은 덧붙임을 "
                     f"받아들이려면 그 결정을 세우고 replant 를 먼저 돌린다")
    top = top_id(docs)
    seen = list(doc[name])
    for k, e in enumerate(entries, 1):
        if not isinstance(e, dict):
            raise Refuse(f"{k}번째 항목이 객체가 아니다")
        if e.get("id") != f"CF-{top + k}":
            raise Refuse(f"{k}번째 항목의 식별자가 {e.get('id')} 인데 CF-{top + k} 여야 한다")
        assert_key_order(name, seen, e)
        seen.append(e)
    body = raw[:-len(LEDGER_TAIL)]
    parts = ["\n".join("  " + line for line in json.dumps(e, indent=1, ensure_ascii=False).split("\n"))
             for e in entries]
    new_raw = body + b",\n" + ",\n".join(parts).encode("utf-8") + LEDGER_TAIL
    new_doc = json.loads(new_raw.decode("utf-8"))
    if new_raw[:len(body)] != body or new_doc[name][:have] != doc[name]:
        raise Refuse(f"{name}: 덧붙인 결과에서 앞 항목이 그대로가 아니다")
    if new_raw != canonical(new_doc):
        raise Refuse(f"{name}: 덧붙인 결과가 들여쓰기 하나의 직렬화와 다르다")
    new_row = fix_of(new_raw, have + len(entries))
    new_text = replace_line(text, fix_line(name, rows[name]), fix_line(name, new_row))
    register_path(root, name).write_bytes(new_raw)
    (root / BASELINE).write_text(new_text, encoding="utf-8")
    return [str(e["id"]) for e in entries], rows[name], new_row


def replant(root: Path) -> list[tuple[str, tuple, tuple]]:
    text, rows = load_block(root)
    changed = []
    new_text = text
    for r in REGISTERS:
        raw, doc = read_register(root, r)
        assert_fixpoint(r, raw, rows[r])
        assert_canonical(r, raw, doc)
        have = len(doc[r])
        if have < rows[r][0]:
            raise Refuse(f"{r}: 항목이 {have} 인데 고정점의 수는 {rows[r][0]} 이다")
        new_row = fix_of(raw, have)
        if new_row != rows[r]:
            new_text = replace_line(new_text, fix_line(r, rows[r]), fix_line(r, new_row))
            changed.append((r, rows[r], new_row))
    if changed:
        (root / BASELINE).write_text(new_text, encoding="utf-8")
    return changed


def init(root: Path) -> list[str]:
    text = (root / BASELINE).read_text(encoding="utf-8")
    m = LEDGERFIX_BLOCK.search(text)
    if m is None:
        raise Refuse("값 정본에 LEDGERFIX 블록이 없다")
    if m.group(1).strip():
        raise Refuse("LEDGERFIX 블록이 이미 값을 든다. 처음 심기는 빈 블록에만 한다")
    lines = []
    for r in REGISTERS:
        raw, doc = read_register(root, r)
        assert_canonical(r, raw, doc)
        lines.append(fix_line(r, fix_of(raw, len(doc[r]))))
    new_text = text[:m.start(1)] + "".join(line + "\n" for line in lines) + text[m.end(1):]
    (root / BASELINE).write_text(new_text, encoding="utf-8")
    return lines


# ------------------------------------------------------------------ 음성 대조

SELFTEST_ENTRIES = {
    "decisions": [{"id": "CF-1", "tier": "policy", "statement": "가"},
                  {"id": "CF-2", "tier": "finding", "statement": "나"}],
    "deferred": [{"id": "CF-3", "statement": "다", "reopen_when": None}],
    "retirements": [{"id": "CF-4", "target": "CF-2", "reason": "라"}],
    "rejected": [{"id": "CF-5", "statement": "마"}],
}


def _synthetic(root: Path) -> None:
    (root / "docs" / "decisions").mkdir(parents=True)
    for name, entries in SELFTEST_ENTRIES.items():
        register_path(root, name).write_bytes(canonical({"spec": "합성", name: entries}))
    (root / BASELINE).write_text("# 합성\n\n<!-- LEDGERFIX:BEGIN -->\n<!-- LEDGERFIX:END -->\n",
                                 encoding="utf-8")


def _tamper(root: Path, name: str, old: str, new: str) -> None:
    p = register_path(root, name)
    s = p.read_text(encoding="utf-8")
    assert s.count(old) == 1, (name, old)
    p.write_text(s.replace(old, new, 1), encoding="utf-8")


def _hand_append(root: Path, name: str, entry: dict) -> None:
    raw = register_path(root, name).read_bytes()
    text = "\n".join("  " + x for x in json.dumps(entry, indent=1, ensure_ascii=False).split("\n"))
    register_path(root, name).write_bytes(raw[:-len(LEDGER_TAIL)] + b",\n" + text.encode() + LEDGER_TAIL)


def selftest() -> int:
    rows = []

    def case(desc: str, expect_ok: bool, fn) -> None:
        try:
            fn()
            ok, why = True, ""
        except Refuse as exc:
            ok, why = False, str(exc)
        rows.append((desc, expect_ok, ok, why))

    tmp = Path(tempfile.mkdtemp(prefix="ledger-append-"))
    try:
        root = tmp / "r"
        _synthetic(root)
        case("빈 블록에 처음 값을 심는다", True, lambda: init(root))
        case("값을 든 블록에 처음 심기를 다시 한다", False, lambda: init(root))
        good = {"id": "CF-6", "tier": "policy", "statement": "바"}
        case("이어지는 식별자로 결정 하나를 덧붙인다", True, lambda: append(root, "decisions", [good]))
        before = register_path(root, "decisions").read_bytes()
        case("식별자를 건너뛴다", False, lambda: append(
            root, "decisions", [{"id": "CF-8", "tier": "policy", "statement": "사"}]))
        case("키 순서를 뒤집는다", False, lambda: append(
            root, "decisions", [{"statement": "사", "tier": "policy", "id": "CF-7"}]))
        case("같은 키 집합이 없는 항목을 든다", False, lambda: append(
            root, "decisions", [{"id": "CF-7", "tier": "policy", "statement": "사", "new": 1}]))
        case("거부된 덧붙임이 파일을 건드리지 않았다", True, lambda: (
            None if register_path(root, "decisions").read_bytes() == before
            else (_ for _ in ()).throw(Refuse("파일이 바뀌었다"))))
        _tamper(root, "decisions", '"statement": "가"', '"statement": "가가"')
        case("앞 항목을 고친 뒤에 덧붙인다", False, lambda: append(
            root, "decisions", [{"id": "CF-7", "tier": "policy", "statement": "사"}]))
        case("앞 항목을 고친 뒤에 다시 심는다", False, lambda: replant(root))
        _tamper(root, "decisions", '"statement": "가가"', '"statement": "가"')
        _hand_append(root, "deferred", {"id": "CF-7", "statement": "사", "reopen_when": None})
        case("설비를 거치지 않은 덧붙임 뒤에 그 레지스터에 덧붙인다", False, lambda: append(
            root, "deferred", [{"id": "CF-8", "statement": "아", "reopen_when": None}]))
        case("설비를 거치지 않은 덧붙임을 다시 심기로 받아들인다", True, lambda: replant(root))
        case("다시 심은 뒤에 그 레지스터에 덧붙인다", True, lambda: append(
            root, "deferred", [{"id": "CF-8", "statement": "아", "reopen_when": None}]))
        p = register_path(root, "rejected")
        p.write_bytes(p.read_bytes()[:-len(LEDGER_TAIL)] + b" " + LEDGER_TAIL)
        case("꼬리 앞에 공백이 낀 파일에 덧붙인다", False, lambda: append(
            root, "rejected", [{"id": "CF-9", "statement": "자"}]))
        _, final_rows = load_block(root)
        for r in REGISTERS:
            raw, _doc = read_register(root, r)
            case(f"마지막 상태에서 {r} 의 고정점이 선다", True,
                 lambda raw=raw, r=r: assert_fixpoint(r, raw, final_rows[r]))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    print("| 항 | 기대 | 결과 | 맞는가 |")
    print("|---|---|---|---|")
    for desc, expect_ok, ok, why in rows:
        print(f"| {desc} | {'통과' if expect_ok else '거부'} | {'통과' if ok else '거부'} | "
              f"{'예' if ok == expect_ok else '**아니오**'} |")
    bad = [r for r in rows if r[1] != r[2]]
    for desc, _e, ok, why in rows:
        if why:
            print(f"{desc}: {why}")
    print(f"항 {len(rows)}개 가운데 맞는 것 {len(rows) - len(bad)}개, 어긋난 것 {len(bad)}개")
    return 1 if bad else 0


def main() -> int:
    ap = argparse.ArgumentParser(description="원장 항목을 덧붙이고 원장 고정점을 다시 심는다")
    ap.add_argument("mode", choices=("append", "replant", "init", "selftest"))
    ap.add_argument("register", nargs="?")
    ap.add_argument("entries", nargs="?", help="덧붙일 항목의 배열을 든 JSON 파일")
    ap.add_argument("--root", default=None, help="리포 뿌리. 주지 않으면 이 파일의 리포다")
    args = ap.parse_args()
    if args.mode == "selftest":
        return selftest()
    root = Path(args.root).resolve() if args.root else ROOT
    try:
        if args.mode == "append":
            if not args.register or not args.entries:
                ap.error("append 는 레지스터와 항목 JSON 파일을 받는다")
            entries = json.loads(Path(args.entries).read_text(encoding="utf-8"))
            ids, old, new = append(root, args.register, entries)
            print(f"{args.register} 에 {', '.join(ids)} 를 덧붙였다")
            print(f"고정점 {fix_line(args.register, old)} -> {fix_line(args.register, new)}")
        elif args.mode == "replant":
            changed = replant(root)
            for r, old, new in changed:
                print(f"고정점 {fix_line(r, old)} -> {fix_line(r, new)}")
            if not changed:
                print("다시 심을 고정점이 없다")
        else:
            for line in init(root):
                print(f"심었다: {line}")
    except Refuse as exc:
        print(f"거부: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
