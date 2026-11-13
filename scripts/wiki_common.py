#!/usr/bin/env python3
"""원장 검증기의 공용 설비.

`scripts/check_wiki.py` 의 검사 가운데 둘 이상이 쓰는 수집기와 보조와 상수를 든다. 한 검사만
쓰는 것은 그 검사 곁에 남으므로, 이 파일에 서는 것은 그 이름이 둘 이상의 검사에 걸린다는 뜻이다.
그 가름은 지목의 전이를 받으므로 이 파일은 자기 지목에 대해 닫혀 있고 검사 본문을 가리키지 않는다.

**이 파일을 고쳐 검사를 통과시키지 않는다.** 검사가 실패하면 그 실패가 산출물이다(SPEC §4).
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import NamedTuple

REGISTERS = ("decisions", "deferred", "retirements", "rejected")

# 검사 23 의 규율 ID 계열. SPEC §2.1 이 정본이며 `E` 는 추출 기록의 번호라 뺀다.
# `PH-R` 이 한 계열이고 맨 앞에 두어야 `PH-R2` 가 `R-2` 로 잘리지 않는다.
RULE_SERIES = ("PH-R", "P", "A", "C", "L", "D", "T", "R", "N", "V", "W", "Q", "B", "O",
               "G", "S", "F", "J", "K")
# `PH-R` 만 번호를 하이픈 없이 붙인다(`PH-R2`). 그 계열을 하이픈을 요구하는 꼴로 읽으면
# 토큰이 한 건도 잡히지 않으면서 검사가 통과하므로, 두 꼴을 갈라 받고 그 계열을 먼저 본다.
RULE_TOKEN = re.compile(
    r"(?<![0-9A-Za-z-])(?:PH-R(\d+)|("
    + "|".join(x for x in RULE_SERIES if x != "PH-R")
    + r")-(\d+))(?![0-9A-Za-z-])")

# 검사 24 의 유니버스. SPEC §2.1 이 상주 문서 다섯과 Lean 주석을 든다.
RESIDENT_DOCS = (
    "CLAUDE.md",
    "docs/baseline.md",
    "docs/decisions/SPEC.md",
    "docs/reading-queue-v0.md",
    "docs/bundle-inventory-v0.md",
)
# 기록하는 자리는 유니버스 밖이다. 그 문면은 그 시점의 앎을 담으므로 낡은 지목이 정당하다.
HISTORY_PATHS = ("BUILD_LOG.md", "docs/phases/", "docs/extractions/",
                 "docs/arcs.json 의 patches 배열")
# `arcs.json` 은 `patches` 배열만 빠지고 나머지는 유니버스에 든다. 그 파일의 `note` 가 규율을
# 지목하므로 파일 전체를 빼면 그 지목이 검사되지 않는다(SPEC §2.1).
ARCS_DOC = "docs/arcs.json"

ID_FORM = re.compile(r"^CF-(\d+)$")

DD_TOKEN = re.compile(r"--\s*DD:\s*(\S+)")
STEP_CALL = re.compile(r'^\s*Step\(\s*"([^"]+)"')

# 검사 25 의 유니버스. 최상위 선언만 보며 생성자와 필드는 자기를 담은 선언의 표지를 딛는다.
# abbrev 도 최상위 선언이다. 투영이 쓰이는 족을 abbrev 로 두므로(CF-641) 빼면 표지 누락이 그물 밖에
# 남는다(CF-669).
TOP_DECL = re.compile(r"^(def|theorem|inductive|structure|abbrev)\s+([^\s({\[:]+)")
# 검사 33·34 가 선언의 완전 이름을 세울 때 쓰는 이름공간. `end` 는 여는 쪽과 같은 점 이름을 든다.
NAMESPACE = re.compile(r"^namespace\s+(\S+)")
NAMESPACE_END = re.compile(r"^end\s+(\S+)")
# docstring 블록과 그 문단과 문단 머리말. 머리말은 문단 선두의 `**` 와 `**` 사이다(SPEC §2.1).
DOC_BLOCK = re.compile(r"/--(.*?)-/", re.S)
PARA_SPLIT = re.compile(r"\n\s*\n")
PARA_HEAD = re.compile(r"^\*\*(.+?)\*\*", re.S)


class DocDecl(NamedTuple):
    """최상위 선언 하나와 그 docstring 의 문단. 검사 33 과 34 가 이 하나를 함께 쓴다."""

    full: str              # 이름공간을 붙인 완전 이름
    rel: str               # 리포 뿌리를 기준으로 한 경로
    line: int              # 그 선언이 선 줄
    no: int                # `DD:` 표지가 가리키는 번호. `CF-<n>` 형식이 아니면 -1
    paras: list[str]       # docstring 을 빈 줄로 가른 문단


class Report:
    """검사 하나의 결과. `step` 이 선언된 단계 id 이고 출력의 머리에 그대로 난다."""

    def __init__(self, number: str, step: str, title: str, kind: str):
        self.number = number
        self.step = step
        self.title = title
        self.kind = kind          # fail · report · arc_close
        self.violations: list[str] = []
        self.notes: list[str] = []
        self.ran = True

    def bad(self, msg: str) -> None:
        self.violations.append(msg)

    def note(self, msg: str) -> None:
        self.notes.append(msg)

    @property
    def failed(self) -> bool:
        return self.kind != "report" and self.ran and bool(self.violations)

    def emit(self, quiet: bool) -> None:
        if not self.ran:
            verdict, colour = "SKIP", "\033[33m"
        elif self.kind == "report":
            verdict, colour = "REPORT", "\033[36m"
        elif self.violations:
            verdict, colour = "FAIL", "\033[31m"
        else:
            verdict, colour = "OK", "\033[32m"
        print(f"[check:{self.step}] {colour}{verdict}\033[0m  검사 {self.number} — {self.title}")
        for line in self.violations:
            print(f"    · {line}")
        if not quiet:
            for line in self.notes:
                print(f"    - {line}")


def _lean_comments(src: str) -> str:
    """Lean 소스에서 주석만 남기고 코드를 지운다. `/- -/` 는 중첩되고 `--` 는 줄 끝까지다."""
    out, i, depth, n = [], 0, 0, len(src)
    while i < n:
        if src.startswith("/-", i):
            depth += 1; i += 2; out.append("  "); continue
        if src.startswith("-/", i) and depth:
            depth -= 1; i += 2; out.append("  "); continue
        if depth:
            out.append(src[i]); i += 1; continue
        if src.startswith("--", i):
            j = src.find("\n", i)
            out.append(src[i:n if j < 0 else j]); i = n if j < 0 else j; continue
        out.append("\n" if src[i] == "\n" else " "); i += 1
    return "".join(out)


class Ledger:
    """원장과 그 부속 파일을 한 뿌리에서 읽는다."""

    def __init__(self, root: Path):
        self.root = root
        self.reg: dict[str, list[dict]] = {}
        self.container_keys: dict[str, list[str]] = {}
        for name in REGISTERS:
            path = root / "docs" / "decisions" / f"{name}.json"
            doc = json.loads(path.read_text(encoding="utf-8"))
            self.container_keys[name] = list(doc.keys())
            self.reg[name] = doc[name]

        self.entries: list[tuple[str, dict]] = [
            (name, e) for name in REGISTERS for e in self.reg[name]]
        self.by_id: dict = {}
        for _, e in self.entries:
            self.by_id.setdefault(e.get("id"), e)

        arcs_doc = json.loads((root / "docs" / "arcs.json").read_text(encoding="utf-8"))
        self.arcs = {a["name"]: a for a in arcs_doc.get("arcs", [])}
        self.patches = arcs_doc.get("patches", [])

        # 폐기된 id. 살아 있음은 저장하지 않고 유도한다(SPEC §0.2).
        self.dead = {e["target"] for e in self.reg["retirements"] if e.get("target")}
        # 폐기된 항목 → 그것을 폐기한 레코드의 id. 검사 23 의 승인 경로가 이것을 요구한다.
        self.retired_by: dict = {}
        for e in self.reg["retirements"]:
            if e.get("target"):
                self.retired_by.setdefault(e["target"], e.get("id"))
        # 폐기된 항목 → 그것을 폐기한 레코드가 선 날. 검사 23 의 날짜 면제가 이 값을 요구한다.
        self.retired_on: dict = {}
        for e in self.reg["retirements"]:
            if e.get("target"):
                self.retired_on.setdefault(
                    e["target"], (e.get("origin") or {}).get("date"))

        # 규율 ID → 그것을 드는 항목의 원장 id
        self.name_owner: dict = {}
        for _, e in self.entries:
            for n in e.get("names", []) or []:
                self.name_owner.setdefault(n, e["id"])

        self.verify_steps = self._read_verify_steps()
        self._doc_decls: list[DocDecl] | None = None
        self.lean_files = sorted((root / "CrisisFramework").rglob("*.lean")) \
            if (root / "CrisisFramework").is_dir() else []
        self.doc_files = sorted((root / "docs").rglob("*.md")) \
            if (root / "docs").is_dir() else []

    def _read_verify_steps(self) -> list[str]:
        """선언된 단계 id. `scripts/vrun.py` 의 `STEPS` 가 드는 각 항의 첫 인자다.

        그 모듈을 들여 선언을 묻지 않고 문면을 읽는 까닭은, 음성 대조가 사본을 뿌리로
        지목하므로 들이면 돌고 있는 트리의 모듈을 읽고 사본의 그 자리에 든 주입을 보지
        못한다는 것이다. 갈래별 단위의 경로를 뿌리의 소스에서 읽는 자리가 같은 사유를
        이미 든다.
        """
        path = self.root / "scripts" / "vrun.py"
        if not path.is_file():
            return []
        out = []
        for line in path.read_text(encoding="utf-8").splitlines():
            m = STEP_CALL.match(line)
            if m and m.group(1):
                out.append(m.group(1))
        return out

    def rule_scan_targets(self) -> list[tuple[str, str]]:
        """검사 24 가 훑을 (표시 경로, 훑을 텍스트) 목록.

        상주 문서는 전문을 훑고 Lean 파일은 주석만 훑는다. `arcs.json` 은 `patches` 배열을 뺀
        나머지를 훑는다. 식별자는 영어라 규율 ID 꼴이 코드에
        서지 않으나, SPEC 이 유니버스를 「Lean 주석」으로 들므로 그대로 좁힌다.
        """
        out = []
        for rel in RESIDENT_DOCS:
            f = self.root / rel
            if f.is_file():
                out.append((rel, f.read_text(encoding="utf-8")))
        f = self.root / ARCS_DOC
        if f.is_file():
            doc = json.loads(f.read_text(encoding="utf-8"))
            doc.pop("patches", None)
            out.append((ARCS_DOC, json.dumps(doc, ensure_ascii=False, indent=1)))
        for f in self.lean_files:
            out.append((str(f.relative_to(self.root)), _lean_comments(f.read_text(encoding="utf-8"))))
        return out

    def pointer_scan_targets(self) -> list[tuple[str, str]]:
        """검사 41 이 훑을 (표시 경로, 훑을 텍스트) 목록.

        리포에 영구히 남는 문면이 유니버스다. 집행 문면과 회차 기록과 `docs/` 아래의 마크다운과
        Lean 파일과 아크 값 정본의 산문 필드 둘이다. Lean 은 주석만 훑는다. 그 조항이 거는 자리가
        docstring 과 주석이고, 식별자는 영어라 금지 갈래의 꼴이 코드에 서지 않기 때문이다.

        **추출 기록을 건너뛰지 않는다.** 건너뛰던 근거는 그 디렉터리가 인용한 편 자신의 절
        번호를 구조적으로 많이 든다는 것이었는데, 기록의 번호가 앞에 오는 절 번호를 면제하는
        규칙이 그 사이에 섰으므로 그 근거가 소멸했다. 남는 적발은 리포 밖 문서의 절 번호를 든
        자리다.

        **아크 값 정본은 파일 전량을 훑지 않고 산문 필드 둘만 값으로 꺼내 훑는다.** 그 파일이
        마크다운이 아니어서 앞의 수집이 받지 않으며, 파일 전량을 텍스트로 훑으면 ID 와 경로가
        금지 갈래의 꼴에 걸려 거짓 양성이 선다. 필드마다 따로 한 문면으로 두므로 표시 경로가
        그 필드의 자리를 든다.

        **원장 네 파일은 파일로 훑지 않는다.** 그 산문 필드는 검사 41 의 R-11 갈래가 항목
        단위로 따로 받으며, 파일로도 훑으면 같은 자리가 두 번 세어진다(SPEC §2.1).
        """
        out = []
        for rel in ("CLAUDE.md", "BUILD_LOG.md"):
            f = self.root / rel
            if f.is_file():
                out.append((rel, f.read_text(encoding="utf-8")))
        for f in sorted((self.root / "docs").rglob("*.md")):
            out.append((str(f.relative_to(self.root)), f.read_text(encoding="utf-8")))
        f = self.root / ARCS_DOC
        if f.is_file():
            doc = json.loads(f.read_text(encoding="utf-8"))
            for array, key, field in POINTER_ARCS_FIELDS:
                for i, x in enumerate(doc.get(array) or [], 1):
                    if not isinstance(x, dict) or not isinstance(x.get(field), str):
                        continue
                    at = x.get(key) if key else i
                    out.append((f"{ARCS_DOC}{POINTER_ARCS_MARK}{array}/{at}/{field}", x[field]))
        for f in self.lean_files:
            out.append((str(f.relative_to(self.root)),
                        _lean_comments(f.read_text(encoding="utf-8"))))
        return out

    def doc_decls(self) -> list[DocDecl]:
        """최상위 선언마다 그 `DD:` 표지의 번호와 docstring 의 문단을 낸다.

        **검사 33 과 34 가 이 하나를 부른다.** 전사하면 한쪽을 고칠 때 다른 쪽이 조용히 낡고,
        둘이 다른 수를 내는 것을 어느 검사도 잡지 않는다. 검사 31 이 검사 16 과 발화 판정을
        나누어 쓴 것과 같은 형이다(SPEC §2.1).

        표지를 집는 규칙은 검사 25 와 같다. 앞 선언과 이 선언 사이에 선 표지가 이 선언의
        것이며, 그 구간의 마지막 `/-- -/` 블록이 이 선언의 docstring 이다. 블록이 둘 이상인
        것은 생성자와 필드가 자기 docstring 을 갖기 때문이고, 그것들은 선언 줄보다 뒤에 서므로
        구간에 들지 않는다.
        """
        if self._doc_decls is not None:
            return self._doc_decls
        marks = self.dd_markers()
        out: list[DocDecl] = []
        for f in self.lean_files:
            lines = f.read_text(encoding="utf-8").splitlines()
            mk = sorted((ln, tgt) for g, ln, tgt in marks if g == f)
            rel = str(f.relative_to(self.root))
            stack: list[str] = []
            prev = 0
            for i, line in enumerate(lines, 1):
                m = NAMESPACE.match(line)
                if m:
                    stack.append(m.group(1))
                    continue
                m = NAMESPACE_END.match(line)
                if m:
                    if stack and stack[-1] == m.group(1):
                        stack.pop()
                    continue
                d = TOP_DECL.match(line)
                if not d:
                    continue
                cand = [t for ln, t in mk if prev < ln < i]
                m = ID_FORM.match(cand[-1]) if cand else None
                blocks = DOC_BLOCK.findall("\n".join(lines[prev:i - 1]))
                paras = [p.strip() for p in PARA_SPLIT.split(blocks[-1].strip())
                         if p.strip()] if blocks else []
                out.append(DocDecl(".".join(stack + [d.group(2)]), rel, i,
                                   int(m.group(1)) if m else -1, paras))
                prev = i
        self._doc_decls = out
        return out

    def dd_markers(self) -> list[tuple[Path, int, str]]:
        """Lean **줄 주석**의 `-- DD:<id>` 표지 전량.

        R-6 의 문면이 `-- DD:<id>` 이므로 줄 주석이 규율에 박혀 있고, `/- -/` 블록 주석 안의
        문면은 표지가 아니다(SPEC §2.1). 블록 안을 읽으면 표지의 형태를 예시로 든 산문이 표지로
        잡히며 그 일이 실제로 났다. `CLAUDE.md` §5-5 가 근거로 든 형의 두 번째다.
        """
        out = []
        for f in self.lean_files:
            depth = 0
            for i, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
                at_top = (depth == 0)
                # 그 줄이 시작될 때 블록 주석 밖이었고 줄이 `--` 로 시작할 때만 표지로 읽는다.
                if at_top and line.lstrip().startswith("--"):
                    m = DD_TOKEN.search(line)
                    if m:
                        out.append((f, i, m.group(1)))
                # 다음 줄의 깊이를 센다. Lean 의 `/- -/` 는 중첩된다.
                j = 0
                while j < len(line):
                    if line.startswith("/-", j):
                        depth += 1; j += 2; continue
                    if line.startswith("-/", j) and depth:
                        depth -= 1; j += 2; continue
                    if depth == 0 and line.startswith("--", j):
                        break          # 줄 주석이므로 그 줄의 나머지는 세지 않는다
                    j += 1
        return out


def arc_phase_names(a: dict) -> list[str]:
    """아크 레코드가 선언한 페이즈의 이름. 순서는 그 배열의 것이다.

    페이즈 레코드가 객체이고 이름이 `name` 필드에 서므로, 배열의 원소를 이름으로 바로 쓰는
    자리는 객체와 문자열을 맞대어 한 건도 맞지 않게 된다. **그 배열을 읽는 자리가 넷이고 넷이
    같은 사상을 쓰므로 여기 하나를 나누어 쓴다.** 전사하면 한쪽을 고칠 때 다른 쪽이 조용히
    낡고, 둘이 다른 목록을 내는 것을 어느 검사도 잡지 못한다(SPEC §3.6).

    객체가 아닌 원소는 이름을 내지 않는다. 그 꼴은 스키마를 어긴 것이므로 이름을 지어내 받으면
    낡은 꼴이 조용히 서고, 내지 않으면 그 페이즈를 미선언으로 보는 검사가 소리 내어 걸린다.
    """
    return [str(p.get("name")) for p in (a.get("phases") or []) if isinstance(p, dict)]

# `extraction` 트리거의 `ref` 를 추출 기록의 번호로 읽는 사상. 검사 12 와 발화 판정과 검사 43 이
# 이 하나를 공유한다(SPEC §3.3). 전사하면 한쪽을 고칠 때 다른 쪽이 조용히 낡고, 둘이 다른 수를
# 내는 것을 어느 검사도 잡지 못한다.
EXTRACTION_REF_NO = re.compile(r"^(?:E-)?(\d{1,2})$")


def extraction_ref_number(ref: str) -> int | None:
    """`extraction` 트리거의 `ref` 를 추출 기록의 번호로 읽는다.

    번호로 읽히지 않으면 `None` 이다. 새 규약 앞에 선 항은 논문 지목이나 조달처의 서술을 들고
    있으므로 그 자리가 `None` 으로 나오며, 소급해 고치지 않는다(SPEC §3.3).
    """
    m = EXTRACTION_REF_NO.match(ref.strip())
    return int(m.group(1)) if m else None


def extraction_record(led: "Ledger", n: int) -> Path | None:
    """그 번호의 추출 기록 파일. 서 있지 않으면 `None` 이다."""
    d = led.root / "docs" / "extractions"
    hits = sorted(d.glob(f"extraction-{n:02d}-*.md")) if d.is_dir() else []
    return hits[0] if hits else None

def trigger_fired(led: Ledger, e: dict) -> tuple[bool, str, str]:
    """이연 항목의 `reopen_when` 이 충족됐는가와 그 종류와 사유를 낸다.

    검사 16 과 31 이 같은 판정을 쓴다. 판정을 두 자리에 전사하면 한쪽을 고칠 때 다른 쪽이
    조용히 낡고, 둘이 다른 수를 내는 것을 어느 검사도 잡지 못한다(SPEC §2.1).
    """
    rw = e.get("reopen_when")
    if not isinstance(rw, dict):
        return False, "", ""
    kind, ref = rw.get("kind"), str(rw.get("ref") or "")
    hit = False
    why = ""
    if kind == "artifact":
        p = led.root / ref
        hit = p.exists()
        why = f"경로 `{ref}` 가 실재한다"
    elif kind == "extraction":
        # 새 규약은 `ref` 가 추출 기록의 번호를 들므로 그 번호의 기록이 섰는가로 본다. 번호로
        # 읽히지 않는 항은 그 규약 앞에 선 것이므로 옛 판정을 그대로 쓴다(SPEC §3.3).
        n = extraction_ref_number(ref)
        if n is not None:
            f = extraction_record(led, n)
            if f is not None:
                hit, why = True, f"추출 기록 `{f.name}` 이 섰다"
        else:
            # 그 논문의 추출 기록이 섰는가를 파일명으로 본다. 본문으로 보면 다른 추출 기록이
            # 그 논문을 인용한 자리가 발화로 잡힌다.
            flat = re.sub(r"[^a-z0-9]", "", ref.lower())
            d = led.root / "docs" / "extractions"
            for f in (sorted(d.glob("*.md")) if d.is_dir() else []):
                if flat and flat in re.sub(r"[^a-z0-9]", "", f.stem.lower()):
                    hit, why = True, f"추출 기록 `{f.name}` 이 섰다"
                    break
    elif kind == "arc_phase":
        a = led.arcs.get(ref)
        hit = bool(a) and a.get("status") == "open"
        why = f"아크 `{ref}` 가 열려 있다"
    # `blocking` 은 여기서 보지 않는다. 아크가 열려 있다는 것으로는 누가 실제로 부딪힌 것과
    # 아크가 그냥 열려 있는 것이 갈리지 않아 늘 발화로 뜨고, 그러면 이 보고를 읽는 쪽이
    # 곧 넘기게 되어 검사 16 을 두는 사유가 무너진다. 그 몫은 검사 18 이 든다(SPEC §2.2).
    return hit, str(kind or ""), why

# 검사 28·29·30 이 읽는 CQ 고정 절. `docs/baseline.md` §5 의 `CQFIN` 블록이며 정본은 같은 파일의 §6 이다.
CQFIN_BLOCK = re.compile(r"<!-- CQFIN:BEGIN -->\n(.*?)<!-- CQFIN:END -->", re.S)
CQFIN_LINE = re.compile(r"^CQFIN=(\d+)\|")
CQ_REF = re.compile(r"^CQ-fin-(\d+)$")

def cq_fixed(led: Ledger) -> list[int]:
    """고정 절 블록이 드는 CQ 번호. 파일이나 블록이 없으면 빈 목록이다."""
    p = led.root / "docs" / "baseline.md"
    m = CQFIN_BLOCK.search(p.read_text(encoding="utf-8")) if p.is_file() else None
    if not m:
        return []
    return [int(x.group(1)) for x in map(CQFIN_LINE.match, m.group(1).splitlines()) if x]

# 검사 33·34 가 읽는 머리말 규약. `docs/baseline.md` §5 의 `HEADING` 블록이며 정본은 같은
# 파일의 §7 이다. 경계를 코드에 박지 않고 그 블록의 `HEADING_SINCE` 가 들게 한다.
HEADING_BLOCK = re.compile(r"<!-- HEADING:BEGIN -->\n(.*?)<!-- HEADING:END -->", re.S)
HEADING_SINCE_LINE = re.compile(r"^HEADING_SINCE=(\d+)$")
HEADING_LINE = re.compile(r"^HEADING=([^|]*)\|([^|]*)\|(.*)$")

# 아크 값 정본에서 훑는 산문 필드. (배열, 자리를 드는 키, 필드) 이며 키가 없는 배열은 차례로 자리를
# 든다. 아크마다의 서술 필드와 패치 레코드의 사유 필드 둘만 받고, 파일 전량을 훑지 않는 까닭은
# ID 와 경로가 금지 갈래의 꼴에 걸려 거짓 양성이 서는 것이다. 표시 경로는 파일 경로 뒤에 표지와
# 그 필드의 자리를 붙인 꼴이며, 표지가 쌍점이 아닌 까닭은 적발을 파일별로 셀 때 쌍점 앞을 경로로
# 읽기 때문이다(SPEC §2.1).
POINTER_ARCS_FIELDS = (("arcs", "name", "discriminator"), ("patches", None, "why"))
POINTER_ARCS_MARK = "#"

def _baseline_block(led: Ledger, pattern: re.Pattern) -> str:
    """`docs/baseline.md` 에서 그 블록의 본문. 파일이나 블록이 없으면 빈 문자열이다."""
    p = led.root / "docs" / "baseline.md"
    m = pattern.search(p.read_text(encoding="utf-8")) if p.is_file() else None
    return m.group(1) if m else ""


def heading_rules(led: Ledger) -> tuple[int | None, dict[str, list[str]]]:
    """`HEADING` 블록이 든 경계와 예약 낱말별 형의 목록."""
    since: int | None = None
    forms: dict[str, list[str]] = {}
    for line in _baseline_block(led, HEADING_BLOCK).splitlines():
        m = HEADING_SINCE_LINE.match(line)
        if m:
            since = int(m.group(1))
            continue
        m = HEADING_LINE.match(line)
        if m:
            forms.setdefault(m.group(1), []).append(m.group(3))
    return since, forms

def heading_matches(form: str, head: str) -> bool:
    """형과 머리말이 같은가.

    `*` 가 없으면 완전일치다. 있으면 그 앞뒤를 접두와 접미로 보고 가변 구간이 한 글자
    이상인지 본다(SPEC §2.1).
    """
    if "*" not in form:
        return form == head
    pre, suf = form.split("*", 1)
    return (head.startswith(pre) and head.endswith(suf)
            and len(head) > len(pre) + len(suf))


def para_heading(para: str) -> str | None:
    """문단의 머리말. 선두에 `**` 가 없으면 머리말이 없으며 판정의 대상이 아니다.

    머리말 안의 줄바꿈은 공백 하나로 접는다. 접지 않으면 두 줄에 걸친 머리말이 형과 결코
    같아지지 않아 그 자리가 전부 위반으로 잡힌다.
    """
    m = PARA_HEAD.match(para)
    return re.sub(r"\s+", " ", m.group(1)).strip() if m else None

def _lean_code(src: str) -> str:
    """Lean 소스에서 코드만 남기고 주석을 지운다. `_lean_comments` 의 거울이다.

    등록 관계를 드는 선언의 docstring 이 `partitions` 와 `excludes` 를 산문으로 들고 있어서,
    지우지 않으면 그 산문이 관계로 잡힌다. 주석 안의 문면이 코드로 오인되지 않게 하라는 요구가
    음성 대조의 근거에 이미 서 있다(CLAUDE.md §5-5).
    """
    out, i, depth, n = [], 0, 0, len(src)
    while i < n:
        if src.startswith("/-", i):
            depth += 1; i += 2; out.append("  "); continue
        if src.startswith("-/", i) and depth:
            depth -= 1; i += 2; out.append("  "); continue
        if depth:
            out.append("\n" if src[i] == "\n" else " "); i += 1; continue
        if src.startswith("--", i):
            j = src.find("\n", i)
            end = n if j < 0 else j
            out.append(" " * (end - i)); i = end; continue
        out.append(src[i]); i += 1
    return "".join(out)

COUNT_SPEC = "docs/decisions/SPEC.md"
COUNT_VERIFY = "scripts/vrun.py"
COUNT_WIKI = "scripts/check_wiki.py"

# 러너가 거느리는 단위의 경로. 검사의 선언과 기계 판독 블록을 읽는 자리가 이것을
# 유니버스로 쓴다. **뿌리의 소스에서 읽는 까닭은** 음성 대조가 사본을 뿌리로 지목하므로
# 돌고 있는 모듈을 세면 사본의 그 자리에 든 주입을 보지 못한다는 것이다. 러너는 검사의
# 선언을 들지 않으므로 그 유니버스에 러너를 두지 않는다.
WIKI_UNITS = (
    "scripts/wiki_ledger.py",
    "scripts/wiki_formal.py",
    "scripts/wiki_prose.py",
    "scripts/wiki_meta.py",
)

# 검사의 갈래별 단위마다 짝이 되는 음성 대조 단위의 경로. 사례 목록이 그 음성 대조 단위에
# 살고 그 목록을 읽는 검사가 이것을 유니버스로 쓰며, 음성 대조의 주입도 만질 파일을 이
# 목록에서 고른다. **생산 공용 설비에 두는 까닭은** 그 목록을 읽는 검사가 생산 단위에 살아
# 주입 전용 모듈을 들일 자리가 없다는 것이다. 경로의 목록은 보조가 아니므로 주입 전용
# 공용에 두지 않는다.
WIKI_NC_UNITS = (
    "scripts/wiki_nc_ledger.py",
    "scripts/wiki_nc_formal.py",
    "scripts/wiki_nc_prose.py",
    "scripts/wiki_nc_meta.py",
)

# 검증 스크립트의 단계가 부르는 모듈의 경로. 기계 판독 블록을 읽는 자리가 이것을
# 유니버스로 쓴다. **원장 검증기의 단위와 가르는 까닭은** 그 둘이 서로 다른 진입점에서
# 불리고 이 목록이 그 스크립트의 단계가 부르는 것만 든다는 것이다. 그 가운데 둘이 값
# 정본의 블록을 읽으며, 읽지 않는 것을 함께 두는 까닭은 그 목록이 단위의 전량을 들어야
# 블록을 읽는 자리가 하나 늘 때 이 목록이 낡지 않는다는 것이다.
VSTEP_UNITS = (
    "scripts/vstep_axiomdiff.py",
    "scripts/vstep_clausemut.py",
    "scripts/vstep_common.py",
    "scripts/vstep_declprobe.py",
    "scripts/vstep_forbidden.py",
    "scripts/vstep_layertype.py",
    "scripts/vstep_leanenv.py",
    "scripts/vstep_mutation.py",
    "scripts/vstep_propfree.py",
)

# 검증의 오케스트레이터가 들이는 단계 본문의 경로. 기계 판독 블록을 읽는 자리와 검사의 계수가
# 실리는 자리가 이것을 유니버스로 쓴다. **`VSTEP_UNITS` 와 가르는 까닭은** 그 목록이 단계가
# 부르는 모듈을 들고 이 목록이 단계 자신의 본문을 들어 둘의 역할이 다르다는 것이다. 그 가운데
# 하나가 값 정본의 블록을 읽으며, 읽지 않는 것을 함께 두는 까닭은 그 목록이 단위의 전량을
# 들어야 블록을 읽는 자리가 하나 늘 때 이 목록이 낡지 않는다는 것이다.
VRUN_UNITS = (
    "scripts/vrun_step1.py",
    "scripts/vrun_step10.py",
    "scripts/vrun_step11.py",
    "scripts/vrun_step2.py",
    "scripts/vrun_step3.py",
    "scripts/vrun_step4.py",
    "scripts/vrun_step5.py",
    "scripts/vrun_step6.py",
    "scripts/vrun_step7.py",
    "scripts/vrun_step8.py",
    "scripts/vrun_step9.py",
)

# 한글 수사를 값으로 읽는 표. 검사 36 의 `KO_NUMERAL` 을 쓰지 않는 까닭은 그 표가 스물까지의 닫힌
# 목록이고 표 밖의 수사를 실패로 내는 것이 그 검사의 처분이라는 데 있다. 검사의 계수가 이미 서른을
# 넘었으므로 이 자리는 열 자리와 한 자리를 조합해 읽는다.
COUNT_KO_UNIT = {"하나": 1, "둘": 2, "셋": 3, "넷": 4, "다섯": 5, "여섯": 6, "일곱": 7,
                 "여덟": 8, "아홉": 9}
COUNT_KO_TENS = {"열": 10, "스물": 20, "서른": 30, "마흔": 40, "쉰": 50, "예순": 60,
                 "일흔": 70, "여든": 80, "아흔": 90}

COUNT_SECTION_HEAD = re.compile(r"^### 2\.\d+ ")

REPORT_DECL = re.compile(r'Report\(\s*"([^"]+)",\s*"([^"]+)"')

# 검사 47 이 읽는 필드 표. **표를 머리에서 가른다.** 첫 칸이 `필드` 인 표가 그 부류이고 그 가운데
# 머리가 `검사` 열을 든 것이 유니버스다. 검사 칸의 자리를 열 번호로 박지 않는 까닭은 §3.6 의 표
# 둘이 형 칸을 들지 않아 열이 셋이고 나머지가 넷이라는 데 있으며, 박으면 그 가정이 틀린다.
# 절을 번호로 박지 않으므로 필드 표가 하나 더 서면 그 표가 저절로 유니버스에 든다.
SPEC_FIELD_HEAD = "필드"

SPEC_TABLE_RULE = re.compile(r"^:?-{2,}:?$")
# 칸을 가르는 꼴. 역슬래시로 막은 세로줄은 칸의 경계가 아니라 `invariant\|policy` 처럼 한 칸 안의
# 문면이므로 가르지 않는다. 가르면 형 칸이 둘로 쪼개져 검사 칸의 자리가 한 칸씩 밀린다.
SPEC_CELL_SPLIT = re.compile(r"(?<!\\)\|")

def md_cells(line: str) -> list[str] | None:
    """마크다운 표의 한 줄에서 칸을 뽑는다. 표의 줄이 아니면 `None` 이다."""
    t = line.strip()
    if not (t.startswith("|") and t.endswith("|")):
        return None
    return [c.strip() for c in SPEC_CELL_SPLIT.split(t[1:-1])]

# 추출 기록 지목의 꼴. 절 번호는 숫자와 그 사이의 붙임표이며 그 밖의 꼴은 유니버스 밖이다.
# 뒤를 막는 자리가 점으로 이은 꼴을 통째로 밀어낸다. 막지 않으면 그 앞자리만 잡혀 적지 않은
# 절을 지목한 것으로 읽힌다(SPEC §2.1).
EXTRACTION_POINTER = re.compile(
    r"(?<![0-9A-Za-z])E-(\d{1,2})\s*§\s*(\d+(?:-\d+)*)(?![0-9.-])")

EXTRACTION_FILE_NO = re.compile(r"^extraction-(\d+)-")

def doc_pointers(led: Ledger) -> list[tuple[str, int, int, str]]:
    """형식층 docstring 이 드는 추출 기록 지목 전량. (경로, 줄, 기록 번호, 절 번호) 다.

    **검사 48 과 49 가 이 하나를 부른다.** 전사하면 한쪽을 고칠 때 다른 쪽이 조용히 낡고, 둘이
    다른 목록을 내는 것을 어느 검사도 잡지 못한다. 검사 33 과 34 가 선언의 수집기를 나누어
    쓰는 것과 같은 형이다(SPEC §2.1).

    유니버스는 `/-- -/` 블록이며 생성자와 필드의 docstring 도 든다. 선언의 수집기를 쓰지 않는
    까닭은 그것이 선언마다 마지막 블록 하나만 들어 생성자의 docstring 이 그물 밖에 남는다는
    것이다. 파일 머리의 `/- -/` 주석은 docstring 이 아니라 들지 않는다.

    **착지의 몫에는 경계를 걸지 않는다.** 경계는 조달처 줄을 요구하는 몫의 유니버스를 가르며,
    지목이 실재하지 않는 절에 닿는 것은 그 docstring 의 뜻이 서지 않는 것이라 표지의 번호와
    무관하게 결함이다(SPEC §2.1).
    """
    out: list[tuple[str, int, int, str]] = []
    for f in led.lean_files:
        src = f.read_text(encoding="utf-8")
        rel = str(f.relative_to(led.root))
        for b in DOC_BLOCK.finditer(src):
            for m in EXTRACTION_POINTER.finditer(b.group(1)):
                at = b.start(1) + m.start()
                out.append((rel, src.count("\n", 0, at) + 1,
                            int(m.group(1)), m.group(2)))
    return out

# 검사 50 이 읽는 뭉치 인벤토리와 `MIRROR` 블록. `docs/baseline.md` §5 가 유령의 계수를 들며 값을
# 코드에 박지 않고 그 블록이 들게 한다. **그 값은 이 검사가 처음 설 때 이 검사 자신이 낸 것이다.**
# 그 계수가 아래 구성원 행의 꼴에 달려 있으므로 블록과 탐지기를 같은 코드에서 나오게 둔다(SPEC §2.1).
INVENTORY_DOC = "docs/bundle-inventory-v0.md"

# 구성원 행이 드는 기록 번호의 꼴. 앞을 막는 자리가 규율 ID 의 꼴에 섞인 `E` 를 거르고 뒤를 막는
# 자리가 더 긴 번호를 두 자리에서 자르지 않게 한다. 번호의 자릿수는 검사 48 의 지목 꼴과 같다.
INVENTORY_EXTRACTION_NO = re.compile(r"(?<![0-9A-Za-z-])E-(\d{1,2})(?![0-9A-Za-z])")

# 검사 53 과 54 가 읽는 `INVENTORYMARK` 블록. `docs/baseline.md` 가 집계 표의 마커와 비고 칸의 표지
# 낱말 둘을 든다. **블록이 비거나 키 하나가 빠지면 통과시키지 않는다.** 표지의 낱말을 코드에 박으면
# 그 낱말을 바꾸는 회차가 인벤토리와 블록만 고쳤을 때 이 검사가 옛 낱말을 찾아 조용히 낡는다.
INVENTORYMARK_BLOCK = re.compile(r"<!-- INVENTORYMARK:BEGIN -->\n(.*?)<!-- INVENTORYMARK:END -->", re.S)
INVENTORYMARK_LINE = re.compile(r"^(INVENTORYMARK_[A-Z]+)=(.*)$")
INVENTORYMARK_AGGREGATE = "INVENTORYMARK_AGGREGATE"
INVENTORYMARK_CITED = "INVENTORYMARK_CITED"
INVENTORYMARK_UNREAD = "INVENTORYMARK_UNREAD"
INVENTORYMARK_KEYS = (INVENTORYMARK_AGGREGATE, INVENTORYMARK_CITED, INVENTORYMARK_UNREAD)
# 검사 54 가 분포를 가르는 구간 이름. 읽기 대기열이 드는 `O-<n>` 꼴에서 유도하고 열거하지 않는다.
# 열거하면 대기열에 구간이 하나 서는 회차가 이 목록을 잊어 그 구간의 행이 구간 밖으로 세어진다.
READING_QUEUE_DOC = "docs/reading-queue-v0.md"

# 인벤토리의 무리는 `##` 절이며, 그 제목이 구간 이름과 공백으로 시작하면 그 구간의 무리다.
INVENTORY_SECTION = re.compile(r"^##\s+(.+?)\s*$")

def inventorymark_block(led: Ledger) -> dict[str, str]:
    """`INVENTORYMARK` 블록의 키와 값. 값이 빈 키는 들지 않는다."""
    out: dict[str, str] = {}
    for line in _baseline_block(led, INVENTORYMARK_BLOCK).splitlines():
        m = INVENTORYMARK_LINE.match(line)
        if m and m.group(2).strip():
            out[m.group(1)] = m.group(2).strip()
    return out


def inventory_member_rows(text: str, aggregate: str
                          ) -> tuple[list[tuple[int, list[str], str]], int, int]:
    """구성원 행 (줄 번호, 칸, 그 행이 선 `##` 절의 제목) 과 마커로 뺀 표의 수와 그 표의 행 수.

    **표를 마커로 가른다.** 표의 머리 줄 바로 앞 줄이 마커이면 그 표의 본문 행 전량을 유니버스에서
    뺀다. 머리 칼럼의 이름으로 가르지 않는 까닭은 표가 늘 때 그 열거가 낡고 그 낡음을 어느 검사도
    보지 않는다는 데 있다. 표의 행을 가르는 꼴은 검사 50 의 `inventory_members` 와 같다.
    """
    rows: list[tuple[int, list[str], str]] = []
    lines = text.splitlines()
    section = ""
    n_tables = n_rows = 0
    i = 0
    while i < len(lines):
        s = INVENTORY_SECTION.match(lines[i])
        if s:
            section = s.group(1)
        head = md_cells(lines[i])
        rule = md_cells(lines[i + 1]) if i + 1 < len(lines) else None
        if head and rule and all(SPEC_TABLE_RULE.match(c) for c in rule if c):
            marked = i > 0 and lines[i - 1].strip() == aggregate
            if marked:
                n_tables += 1
            j = i + 2
            while j < len(lines):
                body = md_cells(lines[j])
                if body is None:
                    break
                if marked:
                    n_rows += 1
                else:
                    rows.append((j + 1, body, section))
                j += 1
            i = j
            continue
        i += 1
    return rows, n_tables, n_rows


def _inventory_rows(led: Ledger, r: Report
                    ) -> tuple[list[tuple[int, list[str], str]], dict[str, str], int, int] | None:
    """검사 53 과 54 가 함께 쓰는 유니버스. 블록이나 인벤토리를 읽지 못하면 그 사실을 위반으로 남긴다."""
    marks = inventorymark_block(led)
    missing = [k for k in INVENTORYMARK_KEYS if k not in marks]
    if missing:
        r.bad("docs/baseline.md 의 INVENTORYMARK 블록에 " + " · ".join(missing) + " 가 없다")
        return None
    inv = led.root / INVENTORY_DOC
    if not inv.is_file():
        r.bad(f"{INVENTORY_DOC} 이 없다")
        return None
    rows, n_tables, n_rows = inventory_member_rows(inv.read_text(encoding="utf-8"),
                                                   marks[INVENTORYMARK_AGGREGATE])
    # 유니버스가 비면 어느 행도 걸리지 않아 0 으로 난다. 검사 50 이 같은 요구를 둔다.
    if not rows:
        r.bad(f"{INVENTORY_DOC} 에서 구성원 행을 하나도 읽지 못했다")
        return None
    return rows, marks, n_tables, n_rows

# 검사 55 · 56 이 읽는 페이즈 레코드의 칸. 아크 수준의 같은 이름의 칸은 검사 28 · 29 · 30 이 읽는다.
PHASE_CQ = "cq"


def phase_cq_records(led: Ledger) -> list[tuple[str, str, object]]:
    """`cq` 칸을 든 페이즈 레코드마다 (아크 이름, 페이즈 이름, 그 칸의 값).

    **검사 55 와 56 이 이 하나를 나누어 쓴다.** 전사하면 한쪽을 고칠 때 다른 쪽이 조용히 낡고, 두
    방향이 서로 다른 유니버스를 보는 것을 어느 검사도 잡지 않는다. 객체가 아닌 페이즈 원소는 검사
    45 가 그 문면으로 내므로 여기서는 건너뛴다.
    """
    out: list[tuple[str, str, object]] = []
    for name in sorted(led.arcs):
        for ph in led.arcs[name].get("phases") or []:
            if isinstance(ph, dict) and PHASE_CQ in ph:
                out.append((name, str(ph.get("name")), ph[PHASE_CQ]))
    return out
