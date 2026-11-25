#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""뭉치의 압축과 뭉치 인벤토리의 파일 목록 블록을 맞대는 결정 세션의 상주 설비.

**이 모듈은 검증 스크립트가 부르지 않는다.** 압축이 리포 밖에 있으므로 그 대조가 리포 안의
검사로 설 수 없다. 뭉치가 바뀌는 회차의 결정 세션이 올라온 압축의 경로를 인자로 주어 이 모듈을
부르고, 그 결과를 그 회차의 종료 문서가 적는다.

**리포에 사는 사유는 승계다.** 압축과 인벤토리를 맞대는 대조가 회차마다 다시 짜이면 파일 이름과
구성원 행의 제목을 정규화해 맞대는 꼴이 되풀이되고, 인벤토리가 구성원을 한국어 제목이나 줄인
꼴로 들어 같은 편이 양쪽에서 다른 키로 서므로 그 대조가 닫히지 않았다. 해시를 키로 두면 그
거짓 양성이 서지 않는다.

맞대는 축은 셋이다. 압축의 파일과 블록의 줄을 해시와 경로로 양방향으로 맞대고, 블록의 무리가
인벤토리의 절 제목에서 괄호를 걷은 꼴로 서는지와 블록의 편이 그 절의 문면에 서는지를 재며,
표의 구성원 행 가운데 블록이 편으로 들지 않는 행을 보고한다. 앞의 둘이 닫히지 않으면 비영으로
끝나고, 셋째는 압축 밖에 두는 구성원이 있으므로 보고만 한다.

쓰는 꼴은 `python3 scripts/bundle.py <압축 경로> [인벤토리 경로]` 다.
"""

import hashlib
import re
import sys
import unicodedata
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
INVENTORY = ROOT / "docs" / "bundle-inventory-v0.md"
BLOCK = re.compile(r"<!-- BUNDLEFILES:BEGIN -->\n```text\n(.*?)```\n<!-- BUNDLEFILES:END -->", re.S)
LINE = re.compile(r"^BUNDLEFILE=([^|]+)\|(\d+)\|([0-9a-f]{12})\|([^|]+)\|([^|]+)$")
HEADING = re.compile(r"^## (.+?)\s*$", re.M)
# 경로가 규율 ID 의 꼴을 이루는 붙임표를 블록이 U+2011 로 적는다. 맞댈 때 붙임표로 되돌린다.
NB_HYPHEN = "‑"


def group_of(heading: str) -> str:
    """절 제목에서 괄호를 걷은 꼴. 편수가 바뀌어도 무리의 이름이 낡지 않게 한다."""
    return re.sub(r"\s*\([^)]*\)", "", heading).strip()


def sections(text: str) -> dict[str, str]:
    """무리 이름에서 그 절의 문면으로 가는 사전."""
    heads = list(HEADING.finditer(text))
    out: dict[str, str] = {}
    for i, h in enumerate(heads):
        end = heads[i + 1].start() if i + 1 < len(heads) else len(text)
        out[group_of(h.group(1))] = text[h.end():end]
    return out


def read_block(text: str) -> list[tuple[str, int, str, str, str]]:
    m = BLOCK.search(text)
    if not m:
        raise SystemExit("인벤토리에 파일 목록 블록이 없다")
    out = []
    for n, line in enumerate(m.group(1).splitlines(), 1):
        g = LINE.match(line)
        if not g:
            raise SystemExit(f"블록의 {n} 번째 줄이 꼴에 맞지 않는다: {line[:80]}")
        path, size, sha, grp, title = g.groups()
        out.append((path.replace(NB_HYPHEN, "-"), int(size), sha, grp, title))
    return out


def archive_files(path: str) -> list[tuple[str, int, str]]:
    out = []
    with zipfile.ZipFile(path) as z:
        for i in z.infolist():
            if i.is_dir():
                continue
            name = i.filename
            if not (i.flag_bits & 0x800):
                try:
                    name = name.encode("cp437").decode("utf-8")
                except UnicodeError:
                    pass
            name = unicodedata.normalize("NFC", name)
            out.append((name, i.file_size, hashlib.sha256(z.read(i)).hexdigest()[:12]))
    return out


def member_titles(text: str) -> list[tuple[str, str]]:
    """표의 구성원 행이 드는 (무리, 편). 행을 고르는 쪽은 검증기의 파서를 그대로 부른다."""
    sys.path.insert(0, str(ROOT / "scripts"))
    import wiki_common as W
    rows, _, _ = W.inventory_member_rows(text, "<!-- INVENTORY-AGGREGATE -->")
    out = []
    for _, cells, sec in rows:
        t = cells[1] if cells[0] in ("★", "") and len(cells) >= 4 else cells[0]
        out.append((group_of(sec), re.sub(r"\s*\(파일명 `[^`]*`\)", "", t).strip()))
    return out


def main(argv: list[str]) -> int:
    if not argv:
        print(__doc__)
        return 2
    inv = Path(argv[1]) if len(argv) > 1 else INVENTORY
    text = inv.read_text(encoding="utf-8")
    block = read_block(text)
    secs = sections(text)
    bad = 0
    # 블록의 무리와 편이 인벤토리에 서는가. 편은 표의 행 제목과 같거나, 나열 문단에서 쉼표나
    # 줄머리나 줄표 뒤에 서고 괄호나 쉼표나 줄끝 앞에서 끝나야 한다. 부분 문자열로 재면 제목의
    # 앞머리만 맞는 줄이 통과한다.
    rows = member_titles(text)
    def listed(scope: str, title: str) -> bool:
        pat = r"(?:^|, |— )" + re.escape(title) + r"(?= \(|,|$)"
        return re.search(pat, scope, re.M) is not None
    for path, _, _, grp, title in block:
        if grp not in secs:
            print(f"무리 없음: {grp} ({path})")
            bad += 1
        elif grp != "중복" and (grp, title) not in rows and not listed(secs[grp], title):
            print(f"편 없음: {grp} · {title} ({path})")
            bad += 1
        elif grp == "중복" and title not in {t for _, t in rows} and not listed(text, title):
            print(f"중복의 짝 편 없음: {title} ({path})")
            bad += 1
    # 압축과 블록을 해시와 경로로 양방향으로 맞댄다
    arc = archive_files(argv[0])
    by_path = {p: (s, h) for p, s, h, _, _ in block}
    arc_path = {p: (s, h) for p, s, h in arc}
    only_arc = sorted(set(arc_path) - set(by_path))
    only_block = sorted(set(by_path) - set(arc_path))
    changed = sorted(p for p in set(arc_path) & set(by_path) if arc_path[p] != by_path[p])
    block_hash = {h: p for p, (s, h) in by_path.items()}
    for p in only_arc:
        moved = block_hash.get(arc_path[p][1])
        print(f"압축에만 있는 파일: {p}" + (f" (해시가 블록의 {moved} 와 같다)" if moved else ""))
    for p in only_block:
        print(f"블록에만 있는 파일: {p}")
    for p in changed:
        print(f"바이트가 달라진 파일: {p}")
    bad += len(only_arc) + len(only_block) + len(changed)
    # 표의 구성원 행 가운데 블록이 편으로 들지 않는 행을 보고한다
    used = {(g, t) for _, _, _, g, t in block}
    loose = [m for m in rows if m not in used]
    for g, t in loose:
        print(f"보고: 파일이 없는 구성원 행: {g} · {t}")
    print(f"압축 {len(arc)} · 블록 {len(block)} · 압축에만 {len(only_arc)} · 블록에만 {len(only_block)}"
          f" · 달라짐 {len(changed)} · 파일이 없는 구성원 행 {len(loose)} · 위반 {bad}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
