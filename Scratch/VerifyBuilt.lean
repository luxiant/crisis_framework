/-
빌드 산출물(.olean) 기준 검증 — 스크래치

소스 파일 텍스트가 아니라 `lake build` 가 실제로 생성한 olean 을 import 해서
정리가 그 안에 존재하고 어떤 공리에 의존하는지 확인한다.
빌드 타깃 밖. 실행: `lake env lean Scratch/VerifyBuilt.lean`

회계층이 `ℚ` 에서 `ℤ` 로 이행함에 따라 적용 예시의 수 타입을 `ℤ` 로 맞췄다
(`ℚ` 로 두면 `aggregationError` 에 적용되지 않아 이 파일이 컴파일되지 않는다).
-/
import CrisisFramework.Accounting.Aggregation

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

#print axioms creditSupply
#print axioms aggregationError
#print axioms two_mul_aggregationError_eq_pairwise
#print axioms aggregationError_eq_zero_of_constant_cap
#print axioms aggregationError_eq_zero_of_constant_equity

-- 반례의 실제 값 (ℤ 는 계산 가능하므로 직접 확인한다)
#eval aggregationError (Finset.univ : Finset (Fin 2))
        (fun i => if i = 0 then 2 else 3) (fun i => if i = 0 then 1 else 2)
#eval aggregationError (Finset.univ : Finset (Fin 2))
        (fun _ => 2) (fun i => if i = 0 then 1 else 2)
#eval aggregationError (Finset.univ : Finset (Fin 2))
        (fun i => if i = 0 then 2 else 3) (fun _ => 1)
