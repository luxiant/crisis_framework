/-
회계층 — 집행자가 고리의 정의역 밖인 자리

규율: L-4(회계층에 `ℝ` 금지), L-10·L-15(회계층의 기본 수 체계는 `ℤ`), L-12(통화 간 환산 금지),
      C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례의 조달처),
      T-2(반증 조건), T-3(기여와 보조 보정의 분류), T-4(가정의 명시), T-6(존재 형태).

**이 파일이 세우는 것은 고리가 집행자에게 무엇을 하는가의 진술이다.** 공적 풋 접근이 제약의 두 필드를
넓히는 고리가 서 있고 그 접근이 긴급 조달 단계에서 나오는데, 풋의 위계를 집행하는 주체는 접근자의
위계에 들지 않아 단계를 갖지 않는다. 그 귀결로 그 고리가 집행자에게 넓힘을 주지 않고, 확정 결정이 그
주체를 유동성 축에서 무제약으로 두므로 구조와 결정이 반대 방향을 가리킨다.

**그 어긋남을 고치지 않고 진술로 세운다.** 분기에 집행자의 자리를 넣는 일은 위계 위치가 제약의 계수로
들어가는 축이나, 어느 역량 질문의 답 조립도 그 분기와 집행자의 판정을 쓰지 않으므로 그 분기를 고치지
않는다. 그 대신 그 분기가 집행자에게 하는 일을 두 진술이 든다. 좁음이 실재하는 배치를 존재 진술이 들고,
집행자의 자산 측 적격성이 언제나 기저와 같다는 것을 전칭 진술이 든다.

**수 체계: `ℤ`.** 나눗셈을 쓰지 않으므로 교차곱으로 옮길 부등식이 없다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Accounting.PublicPutConstraint

open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
그 주체가 풋의 위계를 집행하는 쪽인가.

**대응 비형식 개념:** 접근자가 아니라 집행자인 주체. 보유 유도 순서의 최상단에 서면서 긴급 조달 단계를
갖지 않는 자리이며, 원 문헌이 중앙은행을 그 자리로 든다.

**이 정의가 배제하는 사례:**
최상단을 접근자의 위계에 넣어 단계를 주는 읽기. 중앙은행의 담보 정책을 읽은 기록이 중앙은행만 상관관계를
판별 기준에서 뺀다고 적고 그 사유를 자기 위에 아무도 없다는 데 두므로, 단계를 주면 그 주체가 자기에게
접근하는 꼴이 된다(BCBS·영란은행).
조달처: E-49 §3-6 「자기 위에 아무도 없는 주체만 그 축을 뺄 수 있다」

**기각한 대체 정의:**
단계가 없는 것만으로 집행자라고 보는 안. 단계 배정이 서지 않은 주체가 전부 집행자가 되므로 배정이
비어 있는 관측의 결손과 집행자의 자리가 한 값으로 접힌다. 최상단인 것만으로 집행자라고 보는 안도
기각했다. 최상단이면서 단계를 갖는 주체가 배치에 따라 설 수 있고, 그 주체는 접근자다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Bool` 이고 그 판정이 목록의 접기에서 나온다.

**주체의 열거를 목록으로 받는다.** 원 문헌의 매트릭스가 주체를 열거로 들고 그 열거가 문헌마다 다르므로,
타입의 유한성으로 받으면 그 열거가 타입에 숨고 다른 매트릭스를 받는 자리가 사라진다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3877
def isEnforcerOver {Entity : Type}
    (A : EmergencyFundingAccess Entity) (M : MoneyAsset Entity)
    (ns : List Entity) (n : Entity) : Bool :=
  (A.tierOf n).isNone && ns.all (fun m => M.aboveOrEqual n m)

/--
집행자가 접근자보다 좁은 자산 측 적격성을 받는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
집행자의 자산 측 적격성이 어느 배치에서도 접근자의 것보다 좁지 않아야 한다. 그 넓힘이 공적 풋 도달에
걸리고 집행자가 단계를 갖지 않아 그 도달이 거짓이므로, 이 명제가 거짓이면 그 고리가 단계 아닌 다른
자리에서 넓힘을 주고 있다는 뜻이다.

**존재 형태로 진술하는 까닭(T-6):**
좁음은 두 주체의 값이 갈리는 배치를 들어야 보인다. 기저와 공적 확장의 값에 따라 둘이 같아지는 배치가
있으므로 전칭으로는 서지 않으며, 갈리는 배치가 실재함이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 확정 결정이 그 주체를 유동성 축에서 무제약으로 두는데 구조가 그 반대를 주는
자리가 이 진술로 서며, 받은 구멍이 적은 결손이 구조 안의 진술이 되는 자리이므로 기여 목록에 든다.

**이 진술이 고리를 고치지 않는다.** 분기에 집행자의 자리를 넣는 몫은 어느 역량 질문의 답도 쓰지 않아
세우지 않으며, 그 분기가 집행자에게 언제나 기저를 준다는 것을 아래의 전칭 진술이 든다.
-/
-- DD:CF-3877
theorem exists_enforcer_assetEligible_narrower_than_accessor :
    ∃ (P : PublicPutAccess MoneyMatrixEntity Unit)
      (base : Constraint ℤ Unit Bool)
      (pubCap : MoneyMatrixEntity → Unit → ℤ)
      (pubElig : MoneyMatrixEntity → Bool → Bool) (a : Bool),
      isEnforcerOver (moneyMatrixTierAccess 0) (moneyMatrixAssetFamily 0)
          [.centralBank, .bank, .governmentDesk, .governmentOnlyFund, .primeFund]
          MoneyMatrixEntity.centralBank = true
        ∧ (constraintWithPublicPut (moneyMatrixTierAccess 0) P base pubCap pubElig
            MoneyMatrixEntity.bank).assetEligible a = true
        ∧ (constraintWithPublicPut (moneyMatrixTierAccess 0) P base pubCap pubElig
            MoneyMatrixEntity.centralBank).assetEligible a = false := by
  exact ⟨⟨fun _ _ => false⟩, ⟨fun _ => 0, fun _ => false⟩, fun _ _ => 0, fun _ _ => true, true,
    rfl, rfl, rfl⟩

/--
집행자에게는 공적 풋 접근으로 넓힌 제약의 자산 측 적격성이 기저의 적격성과 같다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
풋의 위계를 집행하는 주체가 공적 풋 접근으로 기저보다 넓은 자산을 적격으로 받는 것이 관측되어야 한다.
그 넓힘이 긴급 조달 단계의 공적 풋 도달에 걸리고 집행자는 단계를 갖지 않으므로, 이 명제가 거짓이면 그
고리가 단계 아닌 다른 자리에서 넓힘을 주고 있다는 뜻이다.

**가정과 그 배제 사례(T-4·T-5):**
그 주체가 주어진 열거 위에서 집행자라는 것을 가정한다. 그 가정 없이는 명제가 거짓이며, 단계를 가진
접근자에게 공적 확장이 기저에 더해지는 배치가 그 배제 사례다.

**T-3 분류:** 기여다. 그 고리가 집행자에게 무엇을 하는지를 모든 배치에서 드는 유일한 자리이고, 위의
존재 진술은 좁음이 실재하는 배치를 들 뿐 그 자리가 언제나 기저라는 것을 들지 않는다.
-/
-- DD:CF-4923
theorem assetEligible_eq_base_of_isEnforcerOver {Entity Currency Asset : Type}
    (A : EmergencyFundingAccess Entity) (M : MoneyAsset Entity) (ns : List Entity)
    (P : PublicPutAccess Entity Currency) (base : Constraint ℤ Currency Asset)
    (pubCap : Entity → Currency → ℤ) (pubElig : Entity → Asset → Bool) (n : Entity)
    (h : isEnforcerOver A M ns n = true) :
    (constraintWithPublicPut A P base pubCap pubElig n).assetEligible = base.assetEligible := by
  -- 집행자의 판정이 단계가 없음과 최상단임의 곱이므로, 앞 인자가 거짓이면 그 곱이 거짓이 되어
  -- 가정과 부딪힌다. 그래서 단계가 비어 있고, 단계 없는 주체의 도달 정리가 공적 풋 도달을 거짓으로
  -- 둔다. 넓힌 제약의 자산 측 칸을 펼쳐 그 도달을 거짓으로 바꾸면 기저의 칸이 남는다.
  unfold isEnforcerOver at h
  have hnone : (A.tierOf n).isNone = true := by
    cases hx : (A.tierOf n).isNone with
    | false =>
      rw [hx, Bool.false_and] at h
      exact absurd h Bool.false_ne_true
    | true => rfl
  have htier : A.tierOf n = none := Option.isNone_iff_eq_none.mp hnone
  have hput := EmergencyFundingAccess.reachesPublicPut_eq_false_of_tierOf_none A n htier
  funext a
  unfold constraintWithPublicPut
  rw [hput]
  rfl

end CrisisFramework.Accounting
