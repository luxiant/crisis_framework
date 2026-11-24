#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""규율 문서의 작업 파일을 치환으로 고치는 결정 세션의 상주 설비.

**이 모듈은 검증 스크립트가 부르지 않는다.** 그 작업 파일이 세션 지시와 그 부록이고 그 둘이 리포
밖에 살므로, 결정 세션이 경로를 인자로 주어 이 모듈을 부르거나 들여 쓴다. 리포 밖의 경로를 상수로
들지 않는다.

**치환마다 대상 문면의 등장 횟수를 하나로 단언하고 전후의 해시와 바이트를 기록에 남긴다.** 치환을
걸기 전에 그 파일의 해시가 그 기록이 마지막으로 남긴 판의 것인지를 단언하며, 기록이 비었으면 그
회차의 초입에 남긴 판의 해시가 그 자리다. 부피는 바이트로 재고 글자 수로 재지 않는다. 구조를 읽어
다시 쓰지 않고 문면을 치환한다.

들여 쓰는 꼴은 `Work(경로, 기록경로)` 를 세우고 `sub` 와 `resub` 와 `para` 와 `section` 과
`insert_before` 로 고친 뒤 `save` 로 쓰는 것이다. 명령으로 쓰는 꼴은 아래와 같다.

    python3 scripts/plant.py init <작업 파일> <기록>       회차 초입의 판을 기록에 남긴다
    python3 scripts/plant.py check <작업 파일> <기록>      작업 파일이 기록의 마지막 판인지 단언한다
    python3 scripts/plant.py deliver <작업 파일> <사본>    사본으로 옮기고 바이트의 같음을 단언한다

`selftest` 를 인자로 주면 임시 파일에 등장이 둘인 대상과 기록 밖의 판을 주입하는 음성 대조를 돈다.
"""
import hashlib
import json
import re
import shutil
import sys
import unicodedata
from pathlib import Path


def h12(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()[:12]


def dispw(s: str) -> int:
    """표시 폭. 동아시아 넓은 글자를 둘로 센다."""
    return sum(2 if unicodedata.east_asian_width(c) in ("W", "F") else 1 for c in s)


def wrap_para(p: str, width: int = 100) -> str:
    """한 문단을 표시 폭으로 접는다. 표와 제목과 목록과 이미 접힌 문단은 그대로 둔다."""
    if "\n" in p or p.startswith(("|", "#", "- ", "```")) or re.match(r"^\d+\. ", p):
        return p
    lines, cur = [], ""
    for w in p.split(" "):
        cand = w if not cur else cur + " " + w
        if dispw(cand) > width and cur:
            lines.append(cur)
            cur = w
        else:
            cur = cand
    if cur:
        lines.append(cur)
    return "\n".join(lines)


def wrap_block(block: str) -> str:
    return "\n\n".join(wrap_para(p) for p in block.strip("\n").split("\n\n"))


def words_re(s: str) -> str:
    """낱말 열을 공백에 무관하게 찾는 패턴. 줄바꿈이 구절의 가운데에 들어간 자리를 함께 받는다."""
    return r"\s+".join(re.escape(t) for t in s.split())


def _log(path: Path) -> list:
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else []


class Work:
    """작업 파일 하나. 세울 때 기록의 마지막 판과 디스크의 판이 같은지를 단언한다."""

    def __init__(self, path: str, log: str):
        self.path, self.logp = Path(path), Path(log)
        raw = self.path.read_bytes()
        rows = _log(self.logp)
        if not rows:
            raise AssertionError("기록이 비었다. 회차 초입의 판을 init 으로 먼저 남긴다")
        if h12(raw) != rows[-1]["after"]:
            raise AssertionError(f"작업 파일이 기록의 마지막 판이 아니다: {h12(raw)} / {rows[-1]['after']}")
        self.t = raw.decode("utf-8")
        self.pending: list[dict] = []

    def _rec(self, label: str, before: str, n: int) -> None:
        self.pending.append({"op": label, "count": n, "before": h12(before.encode()),
                             "after": h12(self.t.encode()),
                             "bytes_before": len(before.encode()), "bytes_after": len(self.t.encode())})

    def sub(self, label: str, old: str, new: str, expect: int = 1) -> None:
        n = self.t.count(old)
        if n != expect:
            raise AssertionError(f"{label}: 등장 {n} (기대 {expect})")
        b = self.t
        self.t = self.t.replace(old, new)
        self._rec(label, b, n)

    def resub(self, label: str, old_words: str, new: str, expect: int = 1) -> None:
        pat = re.compile(words_re(old_words))
        n = len(pat.findall(self.t))
        if n != expect:
            raise AssertionError(f"{label}: 등장 {n} (기대 {expect})")
        b = self.t
        self.t = pat.sub(lambda m: new, self.t)
        self._rec(label, b, n)

    def para(self, label: str, anchor_words: str, new: str) -> None:
        """앵커를 품은 문단 하나를 통째로 바꾼다. new 가 빈 문자열이면 그 문단을 지운다."""
        pat = re.compile(words_re(anchor_words))
        parts = re.split(r"(\n\s*\n)", self.t)
        idx = [i for i in range(0, len(parts), 2) if pat.search(parts[i])]
        if len(idx) != 1 or len(pat.findall(self.t)) != 1:
            raise AssertionError(f"{label}: 문단 {len(idx)}")
        b, i = self.t, idx[0]
        if new == "":
            del parts[i]
            if i - 1 >= 0:
                del parts[i - 1]
        else:
            parts[i] = wrap_block(new)
        self.t = "".join(parts)
        self._rec(label, b, 1)

    def section(self, label: str, header: str, new: str) -> None:
        """제목 줄부터 같거나 높은 수준의 다음 제목 줄 앞까지를 바꾼다. new 가 비면 지운다."""
        lines = self.t.split("\n")
        hits = [i for i, ln in enumerate(lines) if ln == header]
        if len(hits) != 1:
            raise AssertionError(f"{label}: 제목 {len(hits)}")
        level = len(header) - len(header.lstrip("#"))
        s = hits[0]
        e = next((j for j in range(s + 1, len(lines))
                  if re.match(r"^#{1,%d} " % level, lines[j])), len(lines))
        b = self.t
        lines[s:e] = [] if new == "" else wrap_block(new).split("\n") + [""]
        self.t = "\n".join(lines)
        self._rec(label, b, 1)

    def insert_before(self, label: str, anchor_line: str, new: str) -> None:
        lines = self.t.split("\n")
        hits = [i for i, ln in enumerate(lines) if ln == anchor_line]
        if len(hits) != 1:
            raise AssertionError(f"{label}: 앵커 줄 {len(hits)}")
        b = self.t
        lines[hits[0]:hits[0]] = wrap_block(new).split("\n") + [""]
        self.t = "\n".join(lines)
        self._rec(label, b, 1)

    def save(self) -> str:
        data = self.t.encode("utf-8")
        self.path.write_bytes(data)
        rows = _log(self.logp) + self.pending
        self.logp.write_text(json.dumps(rows, ensure_ascii=False, indent=1), encoding="utf-8")
        self.pending = []
        return h12(data)


def init(path: str, log: str) -> str:
    raw = Path(path).read_bytes()
    rows = _log(Path(log))
    rows.append({"op": "init", "count": 0, "before": h12(raw), "after": h12(raw),
                 "bytes_before": len(raw), "bytes_after": len(raw)})
    Path(log).write_text(json.dumps(rows, ensure_ascii=False, indent=1), encoding="utf-8")
    return h12(raw)


def deliver(src: str, dst: str) -> tuple[int, str]:
    shutil.copyfile(src, dst)
    a, b = Path(src).read_bytes(), Path(dst).read_bytes()
    if a != b:
        raise AssertionError(f"사본이 작업 파일과 갈린다: {dst}")
    return len(a), h12(a)


def selftest() -> int:
    """음성 대조. 임시 파일에 축마다 어긋남을 주입해 단언이 터지는지를 본다."""
    import tempfile
    ok = True
    with tempfile.TemporaryDirectory() as d:
        f, log = Path(d) / "w.md", Path(d) / "log.json"
        f.write_text("# 제목\n\n가 문장. 가 문장.\n\n나 문단이다.\n", encoding="utf-8")
        init(str(f), str(log))
        w = Work(str(f), str(log))
        w.sub("하나", "나 문단이다.", "나 문단이 섰다.")
        w.save()
        cases = []
        try:                                   # 등장이 둘인 대상
            Work(str(f), str(log)).sub("둘", "가 문장.", "다")
            cases.append(("등장 둘", False))
        except AssertionError:
            cases.append(("등장 둘", True))
        f.write_text(f.read_text(encoding="utf-8") + "밖에서 고친 줄\n", encoding="utf-8")
        try:                                   # 기록의 마지막 판이 아닌 작업 파일
            Work(str(f), str(log))
            cases.append(("기록 밖의 판", False))
        except AssertionError:
            cases.append(("기록 밖의 판", True))
    for name, fired in cases:
        print(f"  {name:10s} {'발화' if fired else '미발화'}")
        ok = ok and fired
    return 0 if ok else 1


def main(argv: list[str]) -> int:
    if len(argv) == 2 and argv[1] == "selftest":
        return selftest()
    if len(argv) == 4 and argv[1] == "init":
        print(init(argv[2], argv[3]))
        return 0
    if len(argv) == 4 and argv[1] == "check":
        Work(argv[2], argv[3])
        print("같다")
        return 0
    if len(argv) == 4 and argv[1] == "deliver":
        n, h = deliver(argv[2], argv[3])
        print(f"{n} 바이트 {h}")
        return 0
    print(__doc__.split("명령으로 쓰는 꼴은 아래와 같다.")[1], file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
