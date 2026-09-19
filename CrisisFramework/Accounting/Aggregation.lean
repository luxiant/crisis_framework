/-
회계층 — 집계 정리

J-9의 첫 형식화 대상.

규율: L-4(`ℝ` 금지), L-10(회계층은 `ℤ`/`ℚ`), T-1(조립 가능한 최소 단위),
      T-2(반증 조건), T-3(자명한 명제 분류), A-3(witness), A-6(기준선 차분).

**수 체계: `ℤ`.** 최소 화폐단위의 정수배로 금액을 표현한다.
집계 항등식은 `cap` 과 `equity` 에 대해 동차이므로 양변이 같은 배율로 스케일된다.
따라서 고정소수 표현으로 이행해도 반올림이 발생하지 않는다.

`ℚ` 판본에서 이행한 사유: Lean core의 `Rat` 은 표현에 기약성 증명을 품으며
그 증명이 `Classical.choice` 에 닿는다. `ℤ` 는 증명 필드가 없어 기준선이
`[propext, Quot.sound]` 로 떨어진다. 이행 비용은 0으로 측정되었다
(`Scratch/IntBaseline.lean`).

**검증 상태: 검증됨 (2026-09-12).**
`leanprover/lean4:v4.32.2` + Mathlib `v4.32.2`
(`905b95818eb32af7874a58b427f50c1711a5e96c`) 에서
`bash scripts/verify.sh` 전량 통과 — 프로젝트 olean 삭제 후 재빌드 error 0 / warning 0,
`sorry` 0, `axiom` 선언 0, 진술 5개 변이 전량 거부, 반례 값 1 / 0 / 0.

측정된 회계층 공리 기준선: `[propext, Quot.sound]`
(`Finset` 합을 포함한 자명한 `ℤ` 정의 기준. `Scratch/VerifyBuilt.lean`).
이 파일의 정의·정리 전부가 그 기준선과 같다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import CrisisFramework.Definition.Constraint

open Finset

namespace CrisisFramework.Accounting

variable {ι : Type}

/--
노드의 신용공급.

**대응 비형식 개념:** 제약 상한과 자기자본이 주어졌을 때 그 노드가 공여할 수 있는 신용의 양.

**이 정의가 배제하는 사례:**
제약이 물리지 않은 상태. 이 정의는 상한이 항상 구속한다고 가정한다.
실증에서 레버리지-위험 회귀계수가 예측값 −1에 미치지 못하고 위기 국면에서만 근접한다는
사실은, 제약이 상시 등식이 아니라 물렸을 때만 드러나는 부등식임을 시사한다.

**기각한 대체 정의:**
신용공급을 부등식 `credit ≤ cap * equity` 로 두는 안. 부등식이 실증에 더 충실하나,
집계 정리는 상한 자체의 집계를 다루므로 등식 형태로 충분하다.
부등식 판본은 제약의 물림 여부를 다룰 때 별도로 도입한다.

**수 체계 주의:** `cap` 은 무차원 비율이므로 스케일된 정수로 표현한다.
`equity` 는 최소 화폐단위의 정수배다. 따라서 곱의 배율은 두 배율의 곱이며,
집계 항등식이 동차이므로 양변에서 상쇄된다.
-/
-- DD:CF-130
def creditSupply (cap equity : ℤ) : ℤ := cap * equity

/--
집계 오차.

집계 노드의 신용공급을 개별 노드 신용공급의 합과 비교한 차이.
분모를 피하기 위해 노드 수를 곱한 형태로 둔다.

`card * Σ(capᵢ · equityᵢ) − (Σcapᵢ) · (Σequityᵢ)`

두 번째 항이 "평균 제약 × 총 자기자본"에 노드 수를 곱한 것이다.

**분모를 피한 것이 `ℤ` 이행의 전제다.** 평균을 직접 쓰면 나눗셈이 필요해
정수 표현이 깨진다.
-/
-- DD:CF-130
def aggregationError (S : Finset ι) (cap equity : ι → ℤ) : ℤ :=
  (S.card : ℤ) * (∑ i ∈ S, cap i * equity i)
    - (∑ i ∈ S, cap i) * (∑ i ∈ S, equity i)

/--
**주 정리.** 집계 오차는 노드 쌍마다 (제약 차이 × 규모 차이)를 더한 것의 절반이다.

**대응 비형식 개념:**
"제약이 동일한 노드 집합은 하나의 노드로 취급해도 결과가 같다"는 집계 주장의 정밀화.
원 진술은 충분조건만 말하는데, 이 항등식은 오차의 정확한 크기를 준다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가 (T-2):**
제약이 서로 다르고 자기자본도 서로 다른 두 노드로 이루어진 집합에서,
집계 신용공급이 개별 신용공급의 합과 일치하는 경우. 위 항등식은 그런 경우가
`(cap₁ − cap₂)(equity₁ − equity₂) = 0` 일 때만 발생한다고 말하므로,
두 차이가 모두 0이 아닌데 오차가 0인 사례가 관측되면 거짓이다.

**따름 — J-1 분해 기준의 정밀화:**
노드를 쪼개야 하는 조건은 "제약이 다르다"가 아니다.
**제약이 다르고 규모도 다를 때**다. 두 노드의 제약이 같거나 규모가 같으면
그 쌍은 오차에 기여하지 않는다.
-/
-- DD:CF-130
theorem two_mul_aggregationError_eq_pairwise
    (S : Finset ι) (cap equity : ι → ℤ) :
    2 * aggregationError S cap equity
      = ∑ i ∈ S, ∑ j ∈ S, (cap i - cap j) * (equity i - equity j) := by
  unfold aggregationError
  have inner : ∀ i ∈ S,
      (∑ j ∈ S, (cap i - cap j) * (equity i - equity j))
        = (S.card : ℤ) * (cap i * equity i)
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

/--
**따름정리.** 제약이 모두 같으면 집계 오차가 0이다.

**T-3 분류:** 이 명제는 주 정리의 전개만으로 따라온다.
`cap i = cap j` 이면 각 쌍의 곱이 0이 되므로 총합이 0이다.
기여 목록에서 제외하며 보조 보정으로 둔다.

원 문헌의 집계 주장이 바로 이것이다. 즉 **원 주장은 정리가 아니라 따름정리다.**

**전술 주의 — 기준선을 지키려면 아래 둘이 함께 필요하다.**

1. `simp` 를 전면 호출하지 않고 `simp only [sub_self, zero_mul,
   Finset.sum_const_zero]` 로 제한한다. 전면 `simp` 는 여기서 `mul_eq_zero` 까지
   끌어와 `2 * x = 0` 을 `x = 0` 으로 접는데, 그 보조정리가 요구하는 `ℤ` 의
   `NoZeroDivisors` 인스턴스가 `Classical.choice` 에 닿는다. 보조정리 자체는
   깨끗하다(`mul_eq_zero` 는 무의존) — 유입원은 인스턴스 쪽이다.
2. 마무리는 `linarith` 가 아니라 `omega` 다. `linarith` 는 `ℤ` 위의 자명한
   목표에서도 `Classical.choice` 를 끌어온다(`Scratch/TacticProbe.lean`).

제한된 `simp only` 가 남기는 `h : 2 * aggregationError ... = 0` 을 `omega` 가
정수 선형 추론으로 닫는다. 둘 중 어느 쪽이든 되돌리면 기준선이
`[propext, Classical.choice, Quot.sound]` 로 돌아간다 (2×2 대조 측정: `BUILD_LOG.md` §11).
수학적 내용이 아니라 전술·인스턴스 구현의 의존이다.
-/
-- DD:CF-59
theorem aggregationError_eq_zero_of_constant_cap
    (S : Finset ι) (c : ℤ) (equity : ι → ℤ) :
    aggregationError S (fun _ => c) equity = 0 := by
  have h := two_mul_aggregationError_eq_pairwise S (fun _ => c) equity
  simp only [sub_self, zero_mul, Finset.sum_const_zero] at h
  omega

/--
**따름정리.** 자기자본이 모두 같아도 집계 오차가 0이다.

**이것은 원 문헌에 없다.** 제약이 서로 달라도 규모가 같으면 집계가 정확하다.
동질성은 집계의 필요조건이 아니다.

**전술 주의:** 위와 동일 — 제한된 `simp only` + `omega`.
차가 오른쪽 인자에 있으므로 `zero_mul` 자리에 `mul_zero` 를 쓴다.
-/
-- DD:CF-59
theorem aggregationError_eq_zero_of_constant_equity
    (S : Finset ι) (cap : ι → ℤ) (e : ℤ) :
    aggregationError S cap (fun _ => e) = 0 := by
  have h := two_mul_aggregationError_eq_pairwise S cap (fun _ => e)
  simp only [sub_self, mul_zero, Finset.sum_const_zero] at h
  omega

section Witness

/-!
### 반례 (A-3)

제약과 규모가 **함께** 다를 때만 집계가 깨진다는 것을 세 사례로 확인한다.
`ℤ` 는 계산 가능하므로 값을 직접 확인할 수 있다 — 각각 1, 0, 0.
-/

/-- 제약과 규모가 모두 다르면 오차가 0이 아니다. -/
example :
    aggregationError (Finset.univ : Finset (Fin 2))
      (fun i => if i = 0 then 2 else 3)
      (fun i => if i = 0 then 1 else 2) ≠ 0 := by
  unfold aggregationError
  norm_num [Fin.sum_univ_two]

/-- 제약이 같으면 규모가 달라도 오차가 0이다. -/
example :
    aggregationError (Finset.univ : Finset (Fin 2))
      (fun _ => 2)
      (fun i => if i = 0 then 1 else 2) = 0 := by
  unfold aggregationError
  norm_num [Fin.sum_univ_two]

/-- 규모가 같으면 제약이 달라도 오차가 0이다. -/
example :
    aggregationError (Finset.univ : Finset (Fin 2))
      (fun i => if i = 0 then 2 else 3)
      (fun _ => 1) = 0 := by
  unfold aggregationError
  norm_num [Fin.sum_univ_two]

end Witness

end CrisisFramework.Accounting
