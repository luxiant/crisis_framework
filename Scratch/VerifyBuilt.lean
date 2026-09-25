/-
빌드 산출물(.olean) 기준 검증 — 스크래치

소스 파일 텍스트가 아니라 `lake build` 가 실제로 생성한 olean 을 import 해서
정리가 그 안에 존재하고 어떤 공리에 의존하는지 확인한다.
빌드 타깃 밖. 실행: `lake env lean Scratch/VerifyBuilt.lean`

회계층이 `ℚ` 에서 `ℤ` 로 이행함에 따라 적용 예시의 수 타입을 `ℤ` 로 맞췄다
(`ℚ` 로 두면 `aggregationError` 에 적용되지 않아 이 파일이 컴파일되지 않는다).
-/
import CrisisFramework.Accounting.Aggregation
-- 관측층은 L-9 에서 회계층 위에 있으므로 `Aggregation` 이 끌어오지 않는다. 이 파일은 빌드
-- 타깃 밖이라 import 방향 검사의 대상이 아니다.
import CrisisFramework.Observation.CompetencyQuestion

open CrisisFramework.Accounting

/-! ### 회계층 기준선 실측 (ℤ)

기준선은 그 층이 쓰는 최소 수 체계만 언급하는 자명한 정의의 출력이다.
`Finset` 을 쓰는 쪽이 실효 기준선이다.
-/

def baselineProbe (a b : Int) : Int := a * b
#print axioms baselineProbe

def baselineProbeSum {ι : Type} (S : Finset ι) (f : ι → Int) : Int := ∑ i ∈ S, f i
#print axioms baselineProbeSum

/-! ### 산출물 검사 -/

-- DecidableEq 없이 적용되는지 (작업 A 가 산출물에 반영되었는가)
example (S : Finset ℕ) (cap equity : ℕ → ℤ) :
    2 * aggregationError S cap equity
      = ∑ i ∈ S, ∑ j ∈ S, (cap i - cap j) * (equity i - equity j) :=
  two_mul_aggregationError_eq_pairwise S cap equity

-- 반례의 실제 값 (ℤ 는 계산 가능하므로 직접 확인한다)
#eval aggregationError (Finset.univ : Finset (Fin 2))
        (fun i => if i = 0 then 2 else 3) (fun i => if i = 0 then 1 else 2)
#eval aggregationError (Finset.univ : Finset (Fin 2))
        (fun _ => 2) (fun i => if i = 0 then 1 else 2)
#eval aggregationError (Finset.univ : Finset (Fin 2))
        (fun i => if i = 0 then 2 else 3) (fun _ => 1)

/-! ### 용어집 층 기준선 실측 (수 체계 없음)

용어집은 수를 쓰지 않으므로 기준선은 열거형만 언급하는 자명한 정의의 출력이다.
`registry` 가 `List ConceptRel` 이므로 `List` 를 포함한 쪽이 실효 기준선이다.
-/

def glossaryProbe (c : CrisisFramework.Glossary.Concept) :
    CrisisFramework.Glossary.Concept := c
#print axioms glossaryProbe

def glossaryProbeList (c : CrisisFramework.Glossary.Concept) :
    List CrisisFramework.Glossary.Concept := [c]
#print axioms glossaryProbeList

/-! ### 정의층 기준선 실측 (무차원 + 시점 인덱스 `ℕ`)

정의층은 구체 수 타입을 쓰지 않고 시점 인덱스 `ℕ` 만 예외로 허용한다.
`NodeFamily` 가 `ℕ → Finset Node` 이므로 `Finset` 을 포함한 쪽이 실효 기준선이다.
-/

def definitionProbe (t : ℕ) : ℕ := t
#print axioms definitionProbe

def definitionProbeFamily (Node : Type) : ℕ → Finset Node := fun _ => ∅
#print axioms definitionProbeFamily

/-! ### 층별 선언 감사

층별 선언을 찍는 `#print axioms` 는 이 파일에 두지 않는다. 목록을 박아 두면 새 선언이 그물
밖에 남고, `lakefile.toml` 의 glob 이 빌드는 하므로 그 사실이 빌드로 드러나지 않는다.

그 목록은 `scripts/verify.sh` 의 `step4-baseline` 이 `CrisisFramework` 아래 최상위 선언을
훑어 임시 프로브 파일로 생성한다. 이 파일에 남는 것은 층별 기준선을 내는 프로브 여덟과
산출물 검사 하나다.
-/

-- 관측층. 무차원이며 용기는 `Prod` 하나다. 뒤가 실효 기준선을 낸다.
def observationProbe : Unit := ()
#print axioms observationProbe

def observationProbeProd : Unit × Unit := ((), ())
#print axioms observationProbeProd
