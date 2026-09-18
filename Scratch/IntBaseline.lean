/-
ℤ 기준선 검사 — 스크래치

목적: 회계층을 `ℚ` 대신 `ℤ` 로 두었을 때 공리 기준선이 깨끗해지는지 확인.
이 파일은 빌드 타깃(`CrisisFramework.+`) 밖에 있으며, 검사 전용이다.
기존 검증 파일은 건드리지 않는다.

실행: `lake env lean Scratch/IntBaseline.lean`

증명 스크립트는 `CrisisFramework/Accounting/Aggregation.lean` 의 것을 그대로 가져오고
`ℚ` 만 `Int` 로 바꾼다. 전략은 새로 짜지 않는다.
-/

import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

open Finset

namespace Scratch.IntBaseline

/-! ### B-1. 수 표현 기준선 비교 -/

def ratMul (a b : Rat) : Rat := a * b
def intMul (a b : Int) : Int := a * b

#print axioms ratMul
#print axioms intMul

/-! ### B-2. Finset 합에서도 유지되는가 -/

def ratSum {ι : Type} (S : Finset ι) (f : ι → Rat) : Rat := ∑ i ∈ S, f i
def intSum {ι : Type} (S : Finset ι) (f : ι → Int) : Int := ∑ i ∈ S, f i

#print axioms ratSum
#print axioms intSum

/-! ### B-3. 집계 정리의 ℤ 판본 -/

variable {ι : Type}

/-- `aggregationError` 의 ℤ 판본. -/
def aggErrZ (S : Finset ι) (cap equity : ι → Int) : Int :=
  (S.card : Int) * (∑ i ∈ S, cap i * equity i)
    - (∑ i ∈ S, cap i) * (∑ i ∈ S, equity i)

/-- `two_mul_aggregationError_eq_pairwise` 의 ℤ 판본. 증명 스크립트 동일. -/
theorem two_mul_aggErrZ_eq_pairwise
    (S : Finset ι) (cap equity : ι → Int) :
    2 * aggErrZ S cap equity
      = ∑ i ∈ S, ∑ j ∈ S, (cap i - cap j) * (equity i - equity j) := by
  unfold aggErrZ
  have inner : ∀ i ∈ S,
      (∑ j ∈ S, (cap i - cap j) * (equity i - equity j))
        = (S.card : Int) * (cap i * equity i)
          - cap i * (∑ j ∈ S, equity j)
          - (∑ j ∈ S, cap j) * equity i
          + ∑ j ∈ S, cap j * equity j := by
    intro i _
    simp only [sub_mul, mul_sub, Finset.sum_sub_distrib,
               Finset.mul_sum, Finset.sum_mul, Finset.sum_const, nsmul_eq_mul]
    ring
  rw [Finset.sum_congr rfl inner]
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const,
             nsmul_eq_mul, ← Finset.mul_sum, ← Finset.sum_mul]
  ring

/-- 따름정리 1의 ℤ 판본. -/
theorem aggErrZ_eq_zero_of_constant_cap
    (S : Finset ι) (c : Int) (equity : ι → Int) :
    aggErrZ S (fun _ => c) equity = 0 := by
  have h := two_mul_aggErrZ_eq_pairwise S (fun _ => c) equity
  simp at h
  linarith [h]

/-- 따름정리 2의 ℤ 판본. -/
theorem aggErrZ_eq_zero_of_constant_equity
    (S : Finset ι) (cap : ι → Int) (e : Int) :
    aggErrZ S cap (fun _ => e) = 0 := by
  have h := two_mul_aggErrZ_eq_pairwise S cap (fun _ => e)
  simp at h
  linarith [h]

#print axioms two_mul_aggErrZ_eq_pairwise
#print axioms aggErrZ_eq_zero_of_constant_cap
#print axioms aggErrZ_eq_zero_of_constant_equity

section Witness

/-- 반례 1: 제약과 규모가 모두 다르면 오차가 0이 아니다. -/
example :
    aggErrZ (Finset.univ : Finset (Fin 2))
      (fun i => if i = 0 then 2 else 3)
      (fun i => if i = 0 then 1 else 2) ≠ 0 := by
  unfold aggErrZ
  norm_num [Fin.sum_univ_two]

/-- 반례 2: 제약이 같으면 규모가 달라도 오차가 0이다. -/
example :
    aggErrZ (Finset.univ : Finset (Fin 2))
      (fun _ => 2)
      (fun i => if i = 0 then 1 else 2) = 0 := by
  unfold aggErrZ
  norm_num [Fin.sum_univ_two]

/-- 반례 3: 규모가 같으면 제약이 달라도 오차가 0이다. -/
example :
    aggErrZ (Finset.univ : Finset (Fin 2))
      (fun i => if i = 0 then 2 else 3)
      (fun _ => 1) = 0 := by
  unfold aggErrZ
  norm_num [Fin.sum_univ_two]

-- 반례의 실제 값 (ℤ 는 계산 가능하므로 직접 확인한다)
#eval aggErrZ (Finset.univ : Finset (Fin 2))
        (fun i => if i = 0 then 2 else 3) (fun i => if i = 0 then 1 else 2)
#eval aggErrZ (Finset.univ : Finset (Fin 2))
        (fun _ => 2) (fun i => if i = 0 then 1 else 2)
#eval aggErrZ (Finset.univ : Finset (Fin 2))
        (fun i => if i = 0 then 2 else 3) (fun _ => 1)

end Witness

end Scratch.IntBaseline

/-!
### 검사 기록 (해석 없음, 관측값만)

실행: `lake env lean Scratch/IntBaseline.lean` — 오류 없음, `sorry` 없음.

```
ratMul                            [propext, Classical.choice, Quot.sound]
intMul                            (무의존)
ratSum                            [propext, Classical.choice, Quot.sound]
intSum                            [propext, Quot.sound]
aggErrZ                           [propext, Quot.sound]
two_mul_aggErrZ_eq_pairwise       [propext, Quot.sound]
aggErrZ_eq_zero_of_constant_cap   [propext, Classical.choice, Quot.sound]
aggErrZ_eq_zero_of_constant_equity[propext, Classical.choice, Quot.sound]
반례 값                            1, 0, 0
```

이식에 필요했던 수정: 없음. `ℚ → Int` 치환 외에 보조정리 이름·승격·전술을
바꾸지 않았다. `(S.card : Int)` 승격, `nsmul_eq_mul`, `linarith`, `ring`,
`norm_num [Fin.sum_univ_two]` 모두 그대로 통했다.

따름정리 둘의 `Classical.choice` 출처는 `Scratch/TacticProbe.lean` 참조:
`linarith` 전술 자체가 ℤ 위의 자명한 목표에서도 `Classical.choice` 를 끌어온다
(`omega` 는 끌어오지 않는다). 대체 여부는 판단하지 않는다.
-/
