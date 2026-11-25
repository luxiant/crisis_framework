/-
변이 검사와 논리 결합 변이의 사본을 한 프로세스에서 차례로 elaborate 하는 일괄 처리기다.

검증 스크립트의 두 변이 단계가 사본마다 `lean` 을 따로 부르면 사본마다 수입이 처음부터 다시 서고,
그 수입이 사본 하나를 재는 시간의 대부분을 차지한다. 이 처리기는 수입을 한 번 세우고 그 상태에서 원본과
사본의 명령을 처리하며, 사본은 원본과 처음 갈리는 자리 앞의 명령을 원본의 처리에서 재사용한다. 그
재사용은 언어 서버가 편집마다 쓰는 증분 처리와 같은 경로이고, 갈린 자리부터 파일 끝까지는 사본마다
다시 elaborate 한다. 그래서 갈린 자리 뒤의 명령이 내는 오류가 사본의 판정에 그대로 든다.

인자는 툴체인의 뿌리 하나이고, 표준 입력의 한 줄이 원본 하나와 그 사본들을 탭으로 가른 묶음이다. 한
프로세스가 받는 묶음은 수입이 같아야 한다. 수입은 첫 묶음의 원본에서 한 번 세우며, 한 프로세스에서
수입을 두 번 세우는 길을 Lean 이 막으므로 수입이 다른 묶음은 다른 프로세스가 받는다. 머리의 수입이 첫
원본과 다른 입력은 처리하지 않고 건너뛴 표지를 내며, 원본이 건너뛰어지면 그 사본도 함께 건너뛴다.

입력마다 시작 표지와 그 입력의 메시지와 끝 표지를 표준 출력에 내고, 끝 표지가 오류의 유무를 든다.
메시지는 명령줄의 `lean` 이 쓰는 보고 함수로 내므로 그 꼴이 같다. 원본은 대조군이며, 원본에서 오류가
서면 부르는 쪽이 그 묶음의 결과를 쓰지 않는다. 건너뛴 입력과 쓰지 않은 결과는 부르는 쪽이 명령줄의
`lean` 으로 다시 잰다.
-/
import Lean
open Lean Elab

/-- 명령줄의 `lean` 이 파일의 머리를 처리할 때 넘기는 것과 같은 값으로 수입을 세운다. -/
def setupImports (opts : Options) (stx : HeaderSyntax) :
    Language.ProcessingT IO
      (Except Language.Lean.HeaderProcessedSnapshot Language.Lean.SetupImportsResult) :=
  return .ok { imports := stx.imports, isModule := stx.isModule, mainModuleName := `_stdin,
               opts, trustLevel := 1024 }

/-- 수입이 끝난 상태에서 입력 하나의 명령을 처리하고 그 메시지를 보고하며, 오류가 섰는지를 함께 낸다. -/
def elabCommands (opts : Options) (cmdState : Command.State)
    (old? : Option (Parser.InputContext × Language.Lean.CommandParsedSnapshot))
    (ictx : Parser.InputContext) (ps : Parser.ModuleParserState) :
    IO (Language.Lean.CommandParsedSnapshot × Bool) := do
  let t ← Language.Lean.processCommands ictx ps cmdState old?
  let snap ← IO.wait t
  let hasErrors ← (Language.toSnapshotTree snap).runAndReport opts
  return (snap, hasErrors)

unsafe def main (args : List String) : IO UInt32 := do
  let [sysroot] := args
    | IO.eprintln "쓰는 꼴: <실행 파일> <툴체인 뿌리> (표준 입력의 줄마다 원본과 사본을 탭으로 가른다)"
      return 2
  Lean.initSearchPath sysroot
  enableInitializersExecution
  -- 명령줄의 `lean` 과 같이 비동기 elaborate 를 켠다. 그 판이 켜는 최소 스냅숏은 끈다. 최소
  -- 스냅숏은 명령의 구문을 버리므로 그 처리를 사본이 재사용할 수 없다
  let opts := Elab.async.setIfNotSet ({} : Options) true
  let opts := Lean.internal.cmdlineSnapshots.set opts false
  let stdin ← IO.getStdin
  let mut groups : Array (Array String) := #[]
  repeat
    let ln ← stdin.getLine
    if ln.isEmpty then break
    let ln := ln.trimAsciiEnd.toString
    unless ln.isEmpty do
      groups := groups.push (ln.splitOn "\t").toArray
  let some first := groups[0]? | return 0
  let orig0 := first[0]!
  let src0 ← IO.FS.readFile orig0
  let (hdr0, ps0, _) ← Parser.parseHeader (Parser.mkInputContext src0 orig0)
  -- 첫 원본의 머리만 담은 문면을 처리해 수입을 세운다. 그 처리가 낸 상태를 모든 입력이 출발점으로 쓴다
  let hdrText := String.Pos.Raw.extract src0 0 ps0.pos
  let init ← (Language.Lean.process (setupImports opts) none).run
    { Parser.mkInputContext hdrText orig0 with }
  let some parsed := init.result?
    | IO.eprintln s!"머리를 읽지 못했다: {orig0}"
      return 3
  let some processed := parsed.processedSnap.get.result?
    | IO.eprintln s!"수입을 세우지 못했다: {orig0}"
      return 3
  let cmdState0 := processed.cmdState
  let sameHeader (h : HeaderSyntax) : Bool :=
    HeaderSyntax.imports h == HeaderSyntax.imports hdr0 &&
      HeaderSyntax.isModule h == HeaderSyntax.isModule hdr0
  for g in groups do
    let orig := g[0]!
    let src ← IO.FS.readFile orig
    let ictx := Parser.mkInputContext src orig
    let (hdr, ps, msgs) ← Parser.parseHeader ictx
    if msgs.hasErrors || !sameHeader hdr then
      IO.println "@@mutation-batch:skip"
      continue
    IO.println "@@mutation-batch:begin"
    let (snap, e) ← elabCommands opts cmdState0 none ictx ps
    IO.println s!"@@mutation-batch:end {if e then 1 else 0}"
    for c in g[1:] do
      let s ← IO.FS.readFile c
      let ictx' := Parser.mkInputContext s c
      let (hdr', ps', msgs') ← Parser.parseHeader ictx'
      if msgs'.hasErrors || !sameHeader hdr' then
        IO.println "@@mutation-batch:skip"
        continue
      IO.println "@@mutation-batch:begin"
      let (_, e') ← elabCommands opts cmdState0 (some (ictx, snap)) ictx' ps'
      IO.println s!"@@mutation-batch:end {if e' then 1 else 0}"
  return 0
