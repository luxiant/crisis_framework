#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""역량 질문의 답 조립이 닿는 선언을 재는 결정 세션의 설비.

**이 모듈은 검증 스크립트가 부르지 않는다.** 보조 논증의 판정에서 물음 밖의 우회를 받치려고, 답을 조립하는
정의에서 이 프로젝트의 상수를 이행적으로 모아 그 닫힘이 어느 선언에 닿는지를 낸다.

쓰는 꼴은 둘이다.

    python3 -I scripts/cq_reach.py report [--root 리포] [--json 산출]
    python3 -I scripts/cq_reach.py selftest [--root 리포]

`report` 는 뿌리마다 닿은 선언과 그 합집합과 파일별과 층별 계수를 그 수를 낸 명령과 유니버스와 함께 낸다.
`selftest` 는 같은 측정을 세 번 돌린다. 받은 트리 그대로의 측정이 출발점이고, 정방향의 대조는 기존 뿌리 하나를
감싸면서 새 상수를 쓰는 뿌리를 사본에 더해 닿은 합집합이 그 새 뿌리와 새 상수만큼 늘어나는지를 재며, 역방향의
대조는 어느 뿌리도 쓰지 않는 선언만 사본에 더해 합집합이 그대로인지를 잰다. 사본은 리포의 파일을 고치지 않고
리포 밖의 임시 파일로 세운다.

**Lean 쪽은 `scripts/AuxProbe.lean` 의 닿음 보고가 든다.** 이 모듈이 그 파일의 머리에 형식층 모듈 전량의 수입을 붙이고
말미에 보고 명령을 붙인 사본을 리포 밖에 세워 `lake env lean` 으로 돌린다. 수입의 목록은 리포가 추적하는
형식층 파일에서 유도하고 상수로 들지 않는다.

**선언의 유니버스는 검증 스크립트의 감사 단계가 쓰는 것과 같다.** 주석과 문서화 문면을 걷어낸 사본에서
선언의 머리로 뽑으며, 그 뽑기를 이 모듈이 다시 쓰지 않고 그 단계의 모듈을 부른다. 자동으로 서는 보조 정의는
그 유니버스의 선언으로 접는다. 이름의 뒤 성분을 떼어 유니버스에 닿으면 그 선언이고, 닿지 않으면 그 타입이
쓰는 이 프로젝트의 상수를 앞에서부터 접어 처음 닿는 선언이다. 재귀자와 생성자와 사영과 매처와 증명 보조는
앞의 길로 접히고, 파생된 같음 판별과 그 인스턴스는 뒤의 길로 접힌다. 사본에 더한 선언은 그 자신으로 접는다.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import vstep_declprobe  # noqa: E402
from vstep_common import strip  # noqa: E402

ROOT = HERE.parent
LEAN_SRC = "scripts/AuxProbe.lean"
REPORT_CMD = "\n#eval AuxProbe.reachReport\n"
TEMP_MODULE = "<사본>"


def tracked_lean(root: Path) -> list[str]:
    """리포가 추적하는 형식층 파일. 경로는 리포 뿌리에서 본 상대 경로다."""
    out = subprocess.run(["git", "-C", str(root), "ls-files", "CrisisFramework"],
                         capture_output=True, text=True, check=True).stdout.split("\n")
    files = sorted(f for f in out if f.endswith(".lean"))
    assert files, "형식층 파일이 영이다"
    return files


def source_decls(root: Path, files: list[str]) -> dict[str, tuple[str, str]]:
    """선언의 완전 이름에서 (층, 파일) 로 가는 사상. 감사 단계의 모듈을 파일마다 불러 뽑는다."""
    out: dict[str, tuple[str, str]] = {}
    with tempfile.TemporaryDirectory() as d:
        stripped = Path(d) / "stripped"
        for f in files:
            p = stripped / f
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text(strip((root / f).read_text(encoding="utf-8")), encoding="utf-8")
        for f in files:
            audit = Path(d) / "audit"
            if audit.exists():
                shutil.rmtree(audit)
            audit.mkdir()
            vstep_declprobe.run(str(audit), str(stripped), [f])
            for line in (audit / "decls.tsv").read_text(encoding="utf-8").splitlines():
                if not line:
                    continue
                layer, name = line.split("\t")
                assert name not in out, "선언 이름이 둘 이상의 자리에 선다: %s" % name
                out[name] = (layer, f)
    assert out, "선언이 영이다"
    return out


def compose(root: Path, files: list[str], lean_src: str, report_cmd: str, extra: str) -> str:
    """수입과 메타프로그램과 덧붙일 선언과 보고 명령을 이은 사본의 문면."""
    imports = "".join("import %s\n" % f[:-len(".lean")].replace("/", ".") for f in files)
    body = (root / lean_src).read_text(encoding="utf-8")
    assert body.count("\nimport Lean\n") == 1, "메타프로그램의 수입 줄이 하나가 아니다"
    return imports + body + ("\n" + extra + "\n" if extra else "") + report_cmd


def run_meta(root: Path, files: list[str], lean_src: str, report_cmd: str,
             extra: str = "") -> list[str]:
    """메타프로그램의 사본을 돌려 그 보고 파일의 줄을 낸다. `aux_candidates.py` 도 이 함수를 부른다."""
    lake = shutil.which("lake")
    assert lake, "lake 가 경로에 없다"
    with tempfile.TemporaryDirectory() as d:
        src = Path(d) / "MetaRun.lean"
        out = Path(d) / "report.tsv"
        src.write_text(compose(root, files, lean_src, report_cmd, extra), encoding="utf-8")
        env = dict(os.environ, CQREACH_OUT=str(out))
        p = subprocess.run([lake, "-d", str(root), "env", "lean", str(src)],
                           capture_output=True, text=True, env=env)
        errors = [ln for ln in (p.stdout + p.stderr).splitlines() if ": error" in ln]
        assert p.returncode == 0 and not errors, "사본이 서지 않았다:\n" + (p.stdout + p.stderr)[-4000:]
        assert out.is_file(), "보고 파일이 서지 않았다"
        return out.read_text(encoding="utf-8").splitlines()


def run_lean(root: Path, files: list[str], extra: str = "") -> dict:
    """사본을 돌려 뿌리와 닿은 상수와 상수의 정보를 읽는다."""
    lines = run_meta(root, files, LEAN_SRC, REPORT_CMD, extra)
    roots, reach, info, structs = [], {}, {}, []
    for ln in lines:
        if not ln:
            continue
        f = ln.split("\t")
        if f[0] == "CQSTRUCT":
            structs.append(f[1])
        elif f[0] == "ROOT":
            roots.append(f[1]); reach[f[1]] = []
        elif f[0] == "REACH":
            reach[f[1]].append(f[2])
        elif f[0] == "INFO":
            info[f[1]] = {"module": f[2], "kind": f[3],
                          "type_consts": [x for x in f[4].split(",") if x] if len(f) > 4 else []}
        else:
            raise AssertionError("보고의 줄 꼴이 다르다: %r" % ln)
    assert roots, "뿌리가 영이다"
    assert structs, "역량 질문 구조가 영이다"
    return {"roots": roots, "reach": reach, "info": info, "structs": structs}


def make_fold(decls: dict[str, tuple[str, str]], info: dict):
    """닿은 상수를 선언으로 접는 함수. 접히지 않으면 `None` 이다."""
    memo: dict[str, str | None] = {}

    def fold(n: str, guard: frozenset = frozenset()) -> str | None:
        if n in memo:
            return memo[n]
        if n in decls:
            return n
        meta = info.get(n) or {}
        if meta.get("module") == TEMP_MODULE:
            memo[n] = n
            return n
        parts = n.split(".")
        for k in range(len(parts) - 1, 0, -1):
            p = ".".join(parts[:k])
            if p in decls:
                memo[n] = p
                return p
        for c in meta.get("type_consts") or []:
            if c == n or c in guard:
                continue
            got = fold(c, guard | {n})
            if got is not None:
                memo[n] = got
                return got
        memo[n] = None
        return None
    return fold


def measure(root: Path, extra: str = "") -> dict:
    """한 번의 측정. 원천 값과 접은 값을 함께 낸다."""
    files = tracked_lean(root)
    decls = source_decls(root, files)
    raw = run_lean(root, files, extra)
    fold = make_fold(decls, raw["info"])
    per_root: dict[str, list[str]] = {}
    unfolded: set[str] = set()
    for r in raw["roots"]:
        got = set()
        for n in raw["reach"][r]:
            f = fold(n)
            if f is None:
                unfolded.add(n)
            else:
                got.add(f)
        per_root[r] = sorted(got)
    union = sorted({x for v in per_root.values() for x in v})
    raw_union = sorted({x for v in raw["reach"].values() for x in v})
    by_file: dict[str, int] = {}
    by_layer: dict[str, int] = {}
    for n in union:
        layer, f = decls.get(n, (TEMP_MODULE, TEMP_MODULE))
        by_file[f] = by_file.get(f, 0) + 1
        by_layer[layer] = by_layer.get(layer, 0) + 1
    heads = {r: next((c for c in raw["info"][r]["type_consts"] if c in raw["structs"]), None)
             for r in raw["roots"]}
    rootless = sorted(s for s in raw["structs"] if s not in set(heads.values()))
    return {"files": len(files), "decls": len(decls), "roots": raw["roots"],
            "structs": raw["structs"], "root_head": heads, "rootless": rootless,
            "per_root": per_root, "union": union, "raw_union": raw_union,
            "unfolded": sorted(unfolded), "by_file": by_file, "by_layer": by_layer,
            "layers_total": _layer_totals(decls), "files_by_layer": _file_totals(decls)}


def _layer_totals(decls):
    out: dict[str, int] = {}
    for layer, _f in decls.values():
        out[layer] = out.get(layer, 0) + 1
    return out


def _file_totals(decls):
    out: dict[str, set] = {}
    for layer, f in decls.values():
        out.setdefault(layer, set()).add(f)
    return {k: len(v) for k, v in out.items()}


UNIVERSE = ("뿌리는 결과 타입의 머리가 역량 질문 이름 공간의 구조인 정의에서 그 구조의 trivial witness 를 "
            "뺀 것이다. 닫힘은 뿌리의 타입과 값이 쓰는 상수를 이 프로젝트의 상수만 따라 이행적으로 모은 것이고, "
            "선언은 주석과 문서화 문면을 걷어낸 사본에서 감사 단계의 모듈이 머리로 뽑은 것이며, 닿은 상수는 "
            "그 선언으로 접는다.")


def render(m: dict, root: Path) -> str:
    cmd = "python3 -I scripts/cq_reach.py report --root %s" % root
    lines = ["명령: " + cmd, "유니버스: " + UNIVERSE,
             "형식층 파일 %d · 선언 %d · 뿌리 %d · 닿은 선언의 합집합 %d · 접히지 않은 상수 %d" % (
                 m["files"], m["decls"], len(m["roots"]), len(m["union"]), len(m["unfolded"])),
             "닿은 선언이 사는 파일 %d" % len(m["by_file"])]
    for layer in sorted(m["by_layer"]):
        lines.append("  층 %s: 닿은 선언 %d / 선언 %d" % (layer, m["by_layer"][layer],
                                                   m["layers_total"].get(layer, 0)))
    for f in sorted(m["by_file"]):
        lines.append("  파일 %s: %d" % (f, m["by_file"][f]))
    lines.append("역량 질문 구조 %d · 뿌리가 없는 구조 %d" % (len(m["structs"]), len(m["rootless"])))
    for s in m["rootless"]:
        lines.append("  뿌리가 없는 구조 %s" % s)
    for r in m["roots"]:
        lines.append("뿌리 %s: 닿은 선언 %d" % (r, len(m["per_root"][r])))
    for n in m["unfolded"]:
        lines.append("접히지 않음 %s" % n)
    return "\n".join(lines)


def selftest(root: Path) -> list[str]:
    """정방향과 역방향의 음성 대조. 단언이 서지 않으면 그 자리에서 터진다.

    정방향의 새 뿌리를 계산 불가로 표시한다. 수입한 모듈의 생성자를 사본 안에서 다시 컴파일하려 하면 코드
    생성이 그 생성자의 서명을 찾지 못해 사본이 서지 않으며, 그 표시가 저장되는 값을 바꾸지 않으므로 닫힘에는
    영향이 없다. 그 표시를 금지하는 조항은 리포의 형식층에 걸리고 리포 밖의 사본에는 걸리지 않는다.
    """
    base = measure(root)
    r0 = base["roots"][0]
    fwd = measure(root, "def cqReachNegConst : Nat := 7\n"
                        "noncomputable def cqReachNegRoot := let _x := cqReachNegConst; @%s\n" % r0)
    grew = set(fwd["union"]) - set(base["union"])
    assert grew == {"cqReachNegConst", "cqReachNegRoot"}, "정방향: 합집합이 늘어난 몫이 다르다: %r" % grew
    assert set(base["union"]) <= set(fwd["union"]), "정방향: 합집합이 줄었다"
    assert set(fwd["per_root"]["cqReachNegRoot"]) - set(base["per_root"][r0]) == grew, \
        "정방향: 새 뿌리의 닿은 집합이 감싼 뿌리의 것에 새 상수 둘을 더한 것이 아니다"
    assert set(fwd["roots"]) - set(base["roots"]) == {"cqReachNegRoot"}, "정방향: 뿌리의 증분이 다르다"
    rev = measure(root, "def cqReachNegUnused : Nat := 11\n")
    assert rev["union"] == base["union"] and rev["roots"] == base["roots"], \
        "역방향: 쓰이지 않는 선언을 더한 사본에서 합집합이나 뿌리가 달라졌다"
    assert not base["unfolded"], "받은 트리에서 접히지 않은 상수가 있다: %r" % base["unfolded"][:5]
    internal = [r for r in base["roots"] if any(c.startswith("_") for c in r.split("."))]
    assert not internal, "내부 성분을 든 이름이 뿌리로 섰다: %r" % internal[:3]
    return ["출발점: 뿌리 %d · 합집합 %d · 접히지 않은 상수 0" % (len(base["roots"]), len(base["union"])),
            "정방향: 새 뿌리가 감싼 뿌리는 %s 이고, 합집합이 새 뿌리와 새 상수만큼 늘어난다" % r0,
            "역방향: 쓰이지 않는 선언을 더해도 합집합과 뿌리가 그대로다"]


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["report", "selftest"])
    ap.add_argument("--root", default=str(ROOT))
    ap.add_argument("--json")
    a = ap.parse_args(argv)
    root = Path(a.root).resolve()
    if a.mode == "selftest":
        for line in selftest(root):
            print("OK", line)
        return 0
    m = measure(root)
    print(render(m, root))
    if a.json:
        Path(a.json).write_text(json.dumps(m, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
