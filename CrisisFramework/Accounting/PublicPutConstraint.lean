/-
회계층 — 공적 유동성 풋 접근이 넓히는 제약

규율: L-4(회계층에 `ℝ` 금지), L-10·L-15(회계층의 기본 수 체계는 `ℤ`), L-12(통화 간 환산 금지),
      C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례의 조달처),
      T-2(반증 조건), T-4(가정의 명시), T-3(기여와 보조 보정의 분류).

**이 파일이 위계 위치에서 제약의 두 필드로 가는 고리를 세운다.** 공적 풋 접근이 부채 측 한도를
최댓값으로 넓히고 자산 측 적격성을 논리합으로 넓히므로, 기저가 그 결합보다 크지 않은 것이 두 연산의
성질에서 나와 넓힘의 값에 아무 조건도 걸리지 않는다.

**기저 제약을 비교하는 두 주체가 공유한다.** 주체마다 기저를 따로 받으면 그 비교가 기저의 단조에
걸려 위계 위치의 몫이 보이지 않는다.

**수 체계: `ℤ`.** 나눗셈을 쓰지 않으므로 교차곱으로 옮길 부등식이 없다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Int.Notation
import CrisisFramework.Definition.Constraint
import CrisisFramework.Definition.PublicPutAccess

open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
공적 유동성 풋 접근으로 기저 제약을 넓히는 사상.

**대응 비형식 개념:** 한 주체가 공적 유동성 풋에 닿는 것이 그 주체의 대차대조표 제약을
어떻게 바꾸는가. 최후대출자 접근이 부채 측 한도를 올리는 것만이 아니라 중앙은행이 받아 주는 담보의
범위를 넓히는 것이기도 하므로, 그 넓힘이 제약의 두 필드에 각각 선다.

**이 정의가 배제하는 사례:**
한 중앙은행이 어느 개별 증권에든 언제든 추가 할인율을 적용할 권리를 유보하고 이미 인도된 거래의
담보에도 그렇게 한다고 적는 것. 그 유보가 넓힘의 값을 열어 두므로 이 사상은 그 값을 매개변수로 받고
자기가 정하지 않으며, 그래서 얼마나 넓어지는지를 담지 않는다. 담는 것은 넓어지는 방향 하나다.
조달처: E-49 §2-13 「어느 개별 증권에든 언제든 추가 할인율을 적용할 권리를 유보하며」

**기각한 대체 정의:**
비교하는 주체마다 기저 제약을 따로 받는 안. 그 꼴이 일반적으로 보이나 두 주체의 제약을 맞댈 때 그
비교가 기저의 단조에 걸리므로, 위계 위치가 무엇을 가르는지가 기저에 가려 보이지 않는다. 넓힘을
기저에 더하는 꼴로 두는 안도 기각했다. 더하기로 두면 그 값이 음이 아님을 가정으로 받아야 하고 그
가정이 자기자본의 부호를 가정으로 받는 자리와 같은 결손을 새로 세우는데, 최댓값과 논리합으로 두면
기저가 그 결합보다 크지 않은 것이 두 연산의 성질에서 나와 어떤 값에도 조건이 걸리지 않는다.
-/
-- DD:CF-3079
def constraintWithPublicPut {Entity Currency Asset : Type}
    (A : EmergencyFundingAccess Entity) (P : PublicPutAccess Entity Currency)
    (base : Constraint ℤ Currency Asset)
    (pubCap : Entity → Currency → ℤ) (pubElig : Entity → Asset → Bool)
    (n : Entity) : Constraint ℤ Currency Asset where
  liabilityCap := fun c =>
    if P.reachesIn n c then max (base.liabilityCap c) (pubCap n c) else base.liabilityCap c
  assetEligible := fun a =>
    if A.reachesPublicPut n then base.assetEligible a || pubElig n a else base.assetEligible a

/--
공적 풋에 닿지 않는 주체의 부채 측 한도가 다른 주체의 한도보다 크지 않다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공적 풋에 닿지 않는 주체의 한도가 같은 기저를 공유하는 다른 주체의 한도보다 커야 한다. 닿지 않는
자리의 한도가 기저의 값이고 닿는 자리의 한도가 기저와 공적 한도의 최댓값이므로, 이 명제가 거짓이면
그 최댓값이 자기 인자보다 작은 자리가 있다는 뜻이다.

**가정과 그 배제 사례(T-4·T-5):** 아래의 주체가 그 통화에서 공적 풋에 닿지 않는다는 가정을 둔다.
그 가정이 배제하는 것은 둘 다 닿는 자리이며, 거기서는 두 한도가 각각 기저와 서로 다른 공적 한도의
최댓값이어서 그 비교가 공적 한도의 비교에 걸린다.

**T-3 분류:** 기여다. 위계 위치가 제약의 부채 측 한도를 가르는 고리가 이 진술로 서며, 그 고리를
가정으로 받던 정리의 첫째 가정이 여기서 나온다.
-/
-- DD:CF-3079
theorem liabilityCap_le_of_not_reachesIn {Entity Currency Asset : Type}
    (A : EmergencyFundingAccess Entity) (P : PublicPutAccess Entity Currency)
    (base : Constraint ℤ Currency Asset)
    (pubCap : Entity → Currency → ℤ) (pubElig : Entity → Asset → Bool)
    (x y : Entity) (c : Currency) (hy : P.reachesIn y c = false) :
    (constraintWithPublicPut A P base pubCap pubElig y).liabilityCap c
      ≤ (constraintWithPublicPut A P base pubCap pubElig x).liabilityCap c := by
  show (if P.reachesIn y c then max (base.liabilityCap c) (pubCap y c) else base.liabilityCap c)
      ≤ (if P.reachesIn x c then max (base.liabilityCap c) (pubCap x c) else base.liabilityCap c)
  rw [hy, if_neg Bool.false_ne_true]
  cases P.reachesIn x c with
  | false => exact Int.le_refl _
  | true => exact Int.le_max_left _ _

/--
공적 풋에 닿지 않는 주체에게 적격인 자산은 다른 주체에게도 적격이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공적 풋에 닿지 않는 주체에게 적격인 자산이 같은 기저를 공유하는 다른 주체에게 적격이 아니어야 한다.
닿지 않는 자리의 적격성이 기저의 판정이고 닿는 자리가 기저와 공적 확장의 논리합이므로, 이 명제가
거짓이면 그 논리합이 자기 인자보다 좁은 자리가 있다는 뜻이다.

**가정과 그 배제 사례(T-4·T-5):** 아래의 주체가 공적 풋에 닿지 않는다는 가정을 둔다. 그 가정이
배제하는 것은 둘 다 닿는 자리이며, 거기서는 두 적격성이 각각 기저와 서로 다른 공적 확장의 논리합이어서
그 함의가 공적 확장의 포함에 걸린다.

**T-3 분류:** 기여다. 위계 위치가 제약의 자산 측 적격성을 가르는 고리가 이 진술로 서며, 그 고리를
가정으로 받던 정리의 둘째 가정이 여기서 나온다. 그리고 이 가정이 통화를 받지 않아 부채 측과 비대칭인
것이 이 아크의 판별선이 묻는 자리다.
-/
-- DD:CF-3079
theorem assetEligible_imp_of_not_reachesPublicPut {Entity Currency Asset : Type}
    (A : EmergencyFundingAccess Entity) (P : PublicPutAccess Entity Currency)
    (base : Constraint ℤ Currency Asset)
    (pubCap : Entity → Currency → ℤ) (pubElig : Entity → Asset → Bool)
    (x y : Entity) (a : Asset) (hy : A.reachesPublicPut y = false)
    (h : (constraintWithPublicPut A P base pubCap pubElig y).assetEligible a = true) :
    (constraintWithPublicPut A P base pubCap pubElig x).assetEligible a = true := by
  have hb : base.assetEligible a = true := by
    have h' : (if A.reachesPublicPut y then base.assetEligible a || pubElig y a
        else base.assetEligible a) = true := h
    rw [hy, if_neg Bool.false_ne_true] at h'
    exact h'
  show (if A.reachesPublicPut x then base.assetEligible a || pubElig x a
      else base.assetEligible a) = true
  cases A.reachesPublicPut x with
  | false => exact hb
  | true => rw [hb]; rfl

end CrisisFramework.Accounting
