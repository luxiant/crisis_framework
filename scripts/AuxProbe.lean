/-
보조 논증의 판정을 받치는 두 설비가 함께 쓰는 메타프로그램이다. `scripts/cq_reach.py` 와
`scripts/aux_candidates.py` 가 이 파일의 머리에 형식층 모듈 전량의 수입을 붙이고 말미에 보고 명령 하나를
붙인 사본을 리포 밖에 세워 `lean` 으로 돌린다. 이 파일 자신은 `Lean` 만 수입하므로 그대로 돌리면 정의만
서고 아무것도 재지 않는다.

보고는 둘이다. `reachReport` 는 역량 질문의 답 조립이 닿는 상수를 내고, `candidateReport` 는 정리의 가정
바인더 가운데 타입이 명제인 것과 구조체의 명제 필드를 낸다. 이 프로젝트의 상수는 이름 머리가
`CrisisFramework` 인 모듈에 선 것과 수입되지 않고 사본 자신에 선 것이며, 뒤의 것은 음성 대조가 더하는
선언을 받는 자리다. 내부 성분을 든 이름과 매크로 범위를 든 이름은 컴파일러와 파생이 세운 보조 정의이므로
뿌리와 후보에서 뺀다.

닿음의 뿌리는 결과 타입의 머리가 역량 질문 이름 공간의 구조인 정의이며, 그 구조의 witness 인 `trivial`
정의는 답을 조립하지 않으므로 뺀다. 닫힘은 뿌리의 타입과 값이 쓰는 상수를 이행적으로 모으되 이 프로젝트의
상수만 따라간다. 자동으로 서는 보조 정의를 선언으로 접는 일은 이 파일이 하지 않고 부르는 쪽이 한다. 접을
자리가 선언의 머리로 뽑은 소스의 선언 목록이므로 그 목록을 가진 쪽이 접는 것이 전사를 피하는 길이다.

보고는 환경 변수 `CQREACH_OUT` 이 가리키는 파일에 줄 단위로 쓴다. 메시지로 내면 `lean` 이 그 앞에
위치 표지를 붙이는지가 판에 따라 갈리므로 파일로 쓴다. 닿음 보고의 줄 꼴은 넷이다.

  CQSTRUCT<탭><역량 질문 구조>
  ROOT<탭><뿌리>
  REACH<탭><뿌리><탭><닿은 상수>
  INFO<탭><상수><탭><모듈><탭><종류><탭><타입이 쓰는 이 프로젝트의 상수를 쉼표로 이은 것>

후보 보고의 줄 꼴은 둘이다. 정리의 가정은 타입의 전칭을 연 바인더 가운데 그 타입이 명제인 것이며, 진술의
머리에 쓴 바인더와 결론 안의 전칭을 가르는 일은 소스를 가진 부르는 쪽이 한다.

  HYP<탭><정리><탭><바인더 이름><탭><바인더의 타입>
  PROPFIELD<탭><구조><탭><필드><탭><필드의 타입>
-/
import Lean
open Lean Meta

namespace AuxProbe

/-- 역량 질문 구조가 서는 이름 공간. -/
def cqNamespace : Name := `CrisisFramework.Observation.CQ

/-- 이 프로젝트의 상수인가. 수입되지 않은 상수는 사본 자신에 선 것이다. -/
def isProject (env : Environment) (n : Name) : Bool :=
  match env.getModuleIdxFor? n with
  | some idx =>
    match env.header.moduleNames[idx.toNat]? with
    | some m => m.getRoot == `CrisisFramework
    | none => false
  | none => env.contains n

/-- 상수가 선 모듈의 이름. 사본 자신에 선 것은 그 사실을 든다. -/
def moduleOf (env : Environment) (n : Name) : String :=
  match env.getModuleIdxFor? n with
  | some idx => (env.header.moduleNames[idx.toNat]?.map toString).getD "?"
  | none => "<사본>"

/-- 전칭의 바인더를 벗긴 결론의 머리 상수. -/
partial def resultHead : Expr → Option Name
  | .forallE _ _ b _ => resultHead b
  | .mdata _ e => resultHead e
  | e => e.getAppFn.constName?

/-- 상수의 종류를 짧은 낱말로 낸다. -/
def kindOf : ConstantInfo → String
  | .defnInfo _ => "def"
  | .thmInfo _ => "thm"
  | .axiomInfo _ => "axiom"
  | .opaqueInfo _ => "opaque"
  | .quotInfo _ => "quot"
  | .inductInfo _ => "induct"
  | .ctorInfo _ => "ctor"
  | .recInfo _ => "rec"

/-- 그 상수가 딛는 상수. 타입과 값이 쓰는 것이고, 귀납 타입은 생성자를, 생성자와 재귀자는 그 타입을 든다. -/
def deps (ci : ConstantInfo) : Array Name :=
  let t := ci.type.getUsedConstants
  match ci with
  | .defnInfo v => t ++ v.value.getUsedConstants
  | .thmInfo v => t ++ v.value.getUsedConstants
  | .opaqueInfo v => t ++ v.value.getUsedConstants
  | .inductInfo v => t ++ v.ctors.toArray
  | .ctorInfo v => t.push v.induct
  | .recInfo _ => t.push ci.name.getPrefix
  | _ => t

/-- 역량 질문 이름 공간의 구조인가. -/
def isCqStructure (env : Environment) (n : Name) : Bool :=
  n.getPrefix == cqNamespace && isStructure env n

/-- 그 구조의 witness 인가. 이름이 구조 아래의 `trivial` 이다. -/
def isWitness (env : Environment) : Name → Bool
  | .str p "trivial" => isCqStructure env p
  | _ => false

/-- 답을 조립하는 뿌리인가. 내부 성분을 든 이름은 컴파일러가 세운 보조 정의이므로 뺀다. 생성자를 펼친
보조 정의가 결과 타입으로 그 구조를 들어, 빼지 않으면 구조마다 뿌리가 하나씩 더 선다. -/
def isRoot (env : Environment) (n : Name) (ci : ConstantInfo) : Bool :=
  match ci with
  | .defnInfo _ =>
    isProject env n && !n.isInternal && !n.hasMacroScopes && !isWitness env n &&
      (match resultHead ci.type with
       | some h => isCqStructure env h
       | none => false)
  | _ => false

/-- 뿌리에서 이 프로젝트의 상수만 따라가 닿는 상수 전량. 뿌리 자신을 든다. -/
def closure (env : Environment) (root : Name) : Array Name := Id.run do
  let mut seen : Std.HashSet Name := {}
  let mut out : Array Name := #[]
  let mut stack : Array Name := #[root]
  while !stack.isEmpty do
    let n := stack.back!
    stack := stack.pop
    if seen.contains n then
      continue
    seen := seen.insert n
    out := out.push n
    if let some ci := env.find? n then
      for d in deps ci do
        if isProject env d && !seen.contains d then
          stack := stack.push d
  return out

/-- 이름의 정렬 열쇠. 판에 매이지 않게 문자열로 가른다. -/
def key (n : Name) : String := toString n

/-- 닿음 보고를 `CQREACH_OUT` 이 가리키는 파일에 쓴다. -/
def reachReport : CoreM Unit := do
  let env ← getEnv
  let some path ← IO.getEnv "CQREACH_OUT" | throwError "환경 변수 CQREACH_OUT 이 없다"
  let roots := (env.constants.fold (init := #[]) fun acc n ci =>
    if isRoot env n ci then acc.push n else acc).qsort (fun a b => key a < key b)
  let mut lines : Array String := #[]
  let mut infos : Std.HashSet Name := {}
  let structs := (env.constants.fold (init := #[]) fun acc n _ =>
    if isProject env n && isCqStructure env n then acc.push n else acc).qsort (fun a b => key a < key b)
  for s in structs do
    lines := lines.push s!"CQSTRUCT\t{s}"
  for r in roots do
    lines := lines.push s!"ROOT\t{r}"
    let reached := (closure env r).qsort (fun a b => key a < key b)
    for n in reached do
      lines := lines.push s!"REACH\t{r}\t{n}"
      infos := infos.insert n
  for n in infos.toArray.qsort (fun a b => key a < key b) do
    if let some ci := env.find? n then
      let mut tc : Array Name := #[]
      for c in ci.type.getUsedConstants do
        if isProject env c && !tc.contains c then
          tc := tc.push c
      let tcs := ",".intercalate (tc.toList.map toString)
      lines := lines.push s!"INFO\t{n}\t{moduleOf env n}\t{kindOf ci}\t{tcs}"
  IO.FS.writeFile path ("\n".intercalate lines.toList ++ "\n")

/-- 타입을 한 줄의 문면으로 낸다. 탭과 줄바꿈을 공백으로 접고 길이를 자른다. -/
def oneLine (e : Expr) : MetaM String := do
  let s := toString (← ppExpr e)
  let s := String.map (fun c => if c == '\t' || c == '\n' then ' ' else c) s
  return if s.length > 240 then String.ofList (s.toList.take 240) ++ "…" else s

/-- 후보 보고를 `CQREACH_OUT` 이 가리키는 파일에 쓴다. -/
def candidateReport : MetaM Unit := do
  let env ← getEnv
  let some path ← IO.getEnv "CQREACH_OUT" | throwError "환경 변수 CQREACH_OUT 이 없다"
  let names := (env.constants.fold (init := #[]) fun acc n ci =>
    if isProject env n && !n.isInternal && !n.hasMacroScopes then acc.push (n, ci) else acc).qsort
      (fun a b => key a.1 < key b.1)
  let mut lines : Array String := #[]
  for (n, ci) in names do
    match ci with
    | .thmInfo _ =>
      let hs ← forallTelescope ci.type fun xs _ => do
        let mut acc : Array String := #[]
        for x in xs do
          let d ← x.fvarId!.getDecl
          if ← Meta.isProp d.type then
            acc := acc.push s!"{d.userName}\t{← oneLine d.type}"
        return acc
      for h in hs do
        lines := lines.push s!"HYP\t{n}\t{h}"
    | .inductInfo _ =>
      if isStructure env n then
        for f in getStructureFields env n do
          if let some pci := env.find? (n ++ f) then
            let r ← forallTelescope pci.type fun _ body => do
              if ← Meta.isProp body then
                return some (← oneLine body)
              else
                return none
            if let some t := r then
              lines := lines.push s!"PROPFIELD\t{n}\t{f}\t{t}"
    | _ => pure ()
  IO.FS.writeFile path ("\n".intercalate lines.toList ++ "\n")

end AuxProbe
