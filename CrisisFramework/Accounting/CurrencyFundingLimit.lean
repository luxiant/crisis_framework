/-
회계층 — 통화별 담보 여력과 그 통화의 상환 실패 판정

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(통화 간 환산을 금지한다), L-9(import 방향은 단방향),
      A-1(`axiom` 금지), A-6(기준선 차분), C-1·C-2(`noncomputable` 과 `Classical` 금지),
      C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시), T-6(존재 형태).

**수 체계: `ℤ`.** 몫과 기재값이 정수이고 몫이 스케일된 정수인 비율이므로, 곱이 금액에 배율이 걸린
값으로 서고 나눗셈이 들어가지 않는다.

**이 파일이 세우는 것은 제약이 조이는 자리의 담보 쪽에 통화 축을 세운 금액과, 그 축 위에서 조달형
불일치가 상환 실패 판정으로 들어가는 고리다.** 부채 측 한도와 부채 총계와 단기 부채 총계가 이미 통화를
받는데 담보 여력의 금액 판본은 통화를 받지 않아, 그 합이 서로 다른 통화로 기재된 자산의 기재값을 한
합에 더한다. 통화 간 환산이 금지되므로 그 통화의 조달을 환산 없이 떠받치는 담보는 그 통화로 기재된
자산의 몫뿐이다.

**다른 통화의 담보가 그 통화의 조달을 떠받치는 몫은 이 층이 세지 않는다.** 그 몫은 환율을 지나야
서므로 그 값의 결정이 동학층에 있고, 이 층의 판정은 환율을 지나지 않고 설 수 있는 한도를 잰다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.CurrencyMismatch
import CrisisFramework.Accounting.DebtCapacity

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
통화별 담보 여력의 금액 판본.

**대응 비형식 개념:** 그 주체가 담보로 내놓지 않고 들고 있는 몫 가운데 제약의 자산 측 적격성을
통과하고 그 기재값이 그 통화로 서는 것을 기재값으로 모은 값. 통화 간 환산이 금지되므로 그 통화의
조달을 환산 없이 떠받치는 담보가 이 값이며, 같은 층의 통화를 받지 않는 금액 판본이 서로 다른 통화의
기재값을 한 합에 더하는 자리를 그 통화로 좁힌다.

**이 정의가 배제하는 사례:**
담보의 통화가 대출의 통화와 다를 때 가산 할인율을 걸어 그 담보를 받는 중앙은행의 틀. 그 할인율 문서가
그 경우에 최소 6%p 를 더하고 몇 통화에 2%p 를 더 더하므로, 그 틀에서는 다른 통화의 담보도 그 통화의
조달을 떠받친다(영란은행 2026년 6월 18일 적격 증권 할인율 요약). 이 값은 그 몫을 세지 않으며, 그 몫은
환율과 그 가산을 지나야 서므로 그 값의 결정이 동학층에 있다.
조달처: E-49 §11-5 「담보의 통화가 대출의 통화와 다를 때 환율 변동을 감당하려고 최소 6%p 를 더하고」

**기각한 대체 정의:**
제약의 자산 측 적격성이 통화를 받게 하는 안. 그 적격성은 그 주체가 무엇을 보유할 수 있는가를 가르는데
여기서 갈리는 것은 그 자산의 기재값을 그 통화의 금액과 환산 없이 더할 수 있는가여서 축이 다르고, 정의층의
제약 구조체를 고치면 그것을 받는 선언 전량의 뜻이 함께 바뀐다. 기재값이 통화마다 값을 내게 하는 안도
기각했다. 한 자산의 기재값을 여러 통화로 내는 것이 곧 환산이고 그 값의 결정이 동학층에 있다. 다른 통화의
담보를 가산 할인율로 줄여 세는 안도 기각했다. 그 몫이 환율을 지나야 서고, 같은 층의 금액 판본이 할인율을
받는 쪽이 매길 값으로 두어 세지 않는다.

**수 체계를 매개변수로 받는다.** 몫 집합이 수 체계를 받고 이 선언이 그 자리에 `ℤ` 를 넣으며, 기재값과
그 기재값이 서는 통화를 사상으로 받으므로 시점은 그 사상을 주는 쪽이 든다.
-/
-- DD:CF-4640
def collateralCapacityAmountIn {SIdx Asset Party PIdx Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (H : ShareSet SIdx Asset Party PIdx ℤ)
    (k : Constraint ℤ Currency Asset) (carryingCurrency : Asset → Currency)
    (carrying : Asset → ℤ) (p : Party) (c : Currency) : ℤ :=
  ∑ i ∈ H.index,
    (if (H.assign i).holder = p ∧ (H.assign i).kind = ShareKind.held
          ∧ k.assetEligible (H.assign i).asset = true
          ∧ carryingCurrency (H.assign i).asset = c
     then (H.assign i).share * carrying (H.assign i).asset else 0)

/--
통화 축을 세우면 담보 여력이 늘지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 몫과 기재값의 곱이 음수가 아닌 배치에서 한 통화의
담보 여력이 통화를 받지 않는 금액 판본보다 큰 것. 통화의 가름이 더해지는 항을 거를 뿐이므로 그런 배치가
설 수 없고, 반증은 그 가름이 항을 새로 더하는 구현에서만 온다.

**가정과 그 배제 사례(T-4·T-5):** 몫과 기재값의 곱이 음수가 아니라는 가정을 진술에 명시한다. 같은 층의
적격성 단조 정리가 같은 가정을 같은 사유로 들며, 공매도를 음의 몫으로 받는 자리와 충당금이 장부금액을
넘긴 자리를 함께 배제한다. 그 자리에서는 다른 통화의 음의 항이 빠지면서 그 통화의 값이 오히려 커질 수
있다.

**T-3 분류:** 기여다. 제약이 조이는 자리에 통화 축을 세우는 것이 한도를 넓히지 않고 조이기만 한다는 것을
구조 안의 명제로 드는 유일한 자리이며, 이것이 없으면 그 방향이 문서화 문면에만 선다.

**유한집합의 합 보조정리를 쓰지 않는다.** 핀된 판의 그 보조정리들이 선택공리를 끌어오는 것이
실측됐으므로 색인의 귀납으로 세우며, 같은 층의 적격성 단조 정리가 같은 길을 갔다.
-/
-- DD:CF-4640
theorem collateralCapacityAmountIn_le_collateralCapacityAmountOf
    {SIdx Asset Party PIdx Currency : Type} [DecidableEq Party] [DecidableEq Currency]
    (H : ShareSet SIdx Asset Party PIdx ℤ)
    (k : Constraint ℤ Currency Asset) (carryingCurrency : Asset → Currency)
    (carrying : Asset → ℤ) (p : Party) (c : Currency)
    (hNonneg : ∀ i ∈ H.index, 0 ≤ (H.assign i).share * carrying (H.assign i).asset) :
    collateralCapacityAmountIn H k carryingCurrency carrying p c
      ≤ collateralCapacityAmountOf H k carrying p := by
  -- 두 합이 같은 색인 위에 서고 통화의 가름이 항의 조건을 강하게 할 뿐이므로, 색인의 항마다
  -- 부등식을 세워 부분합으로 올린다. 부분합 부등식을 `Finset.cons_induction` 으로 직접 세우고
  -- `Finset.sum_le_sum` 과 `linarith` 를 쓰지 않는다.
  unfold collateralCapacityAmountIn collateralCapacityAmountOf
  have key : ∀ (s : Finset SIdx) (F G : SIdx → ℤ),
      (∀ i ∈ s, F i ≤ G i) → ∑ i ∈ s, F i ≤ ∑ i ∈ s, G i := by
    intro s F G h
    induction s using Finset.cons_induction with
    | empty => rw [Finset.sum_empty, Finset.sum_empty]
    | cons a t ha ih =>
        rw [Finset.sum_cons, Finset.sum_cons]
        exact add_le_add (h a (Finset.mem_cons_self a t))
          (ih fun i hi => h i (Finset.mem_cons_of_mem hi))
  refine key _ _ _ fun i hi => ?_
  -- 통화의 가름까지 서면 넓은 쪽의 조건도 서서 양변이 같은 항이고, 넓은 쪽만 서면 왼쪽이 영이어서
  -- 비음수 가정이 받는다. 판정 명제를 `by_cases` 로 가르므로 배중률을 쓰지 않는다.
  by_cases h₁ : (H.assign i).holder = p ∧ (H.assign i).kind = ShareKind.held
      ∧ k.assetEligible (H.assign i).asset = true
      ∧ carryingCurrency (H.assign i).asset = c
  · rw [if_pos h₁, if_pos (And.intro h₁.1 (And.intro h₁.2.1 h₁.2.2.1))]
  · rw [if_neg h₁]
    by_cases h₂ : (H.assign i).holder = p ∧ (H.assign i).kind = ShareKind.held
        ∧ k.assetEligible (H.assign i).asset = true
    · rw [if_pos h₂]
      exact hNonneg i hi
    · rw [if_neg h₂]

/--
보유한 적격 담보가 전부 다른 통화로 기재된 주체는 그 통화의 담보 여력이 영이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 주체가 들고 있는 적격 몫의 기재값이 어느 것도 그
통화로 서지 않는데 그 통화의 담보 여력이 영이 아닌 배치. 그 합의 항마다 통화의 가름이 거짓이어서 영이므로
그런 배치가 설 수 없다.

**가정과 그 배제 사례(T-4·T-5):** 그 주체가 들고 있는 적격 몫이 전부 그 통화와 다른 통화로 기재되었다는
가정을 진술에 명시한다. 그 가정이 배제하는 자리는 그 통화로 기재된 적격 몫이 하나라도 있는 배치이며, 그
자리에서는 그 몫이 그 통화의 담보 여력에 선다.

**T-3 분류:** 보조 보정이다. 정의를 전개하고 항마다 가름을 거짓으로 접으면 닫히므로 기여 목록에서 뺀다.
뒤의 상환 실패 정리가 이것을 받으므로 선언으로 둔다.
-/
-- DD:CF-4640
theorem collateralCapacityAmountIn_eq_zero_of_carryingCurrency_ne
    {SIdx Asset Party PIdx Currency : Type} [DecidableEq Party] [DecidableEq Currency]
    (H : ShareSet SIdx Asset Party PIdx ℤ)
    (k : Constraint ℤ Currency Asset) (carryingCurrency : Asset → Currency)
    (carrying : Asset → ℤ) (p : Party) (c : Currency)
    (hElsewhere : ∀ i ∈ H.index, (H.assign i).holder = p → (H.assign i).kind = ShareKind.held
        → k.assetEligible (H.assign i).asset = true → carryingCurrency (H.assign i).asset ≠ c) :
    collateralCapacityAmountIn H k carryingCurrency carrying p c = 0 := by
  -- 항마다 가름이 거짓이어서 영이므로 합이 영이다. 합이 영이라는 것을 색인의 귀납으로 세우고
  -- `Finset.sum_eq_zero` 를 쓰지 않는다.
  unfold collateralCapacityAmountIn
  have zero : ∀ (s : Finset SIdx) (F : SIdx → ℤ), (∀ i ∈ s, F i = 0) → ∑ i ∈ s, F i = 0 := by
    intro s F h
    induction s using Finset.cons_induction with
    | empty => rw [Finset.sum_empty]
    | cons a t ha ih =>
        rw [Finset.sum_cons, h a (Finset.mem_cons_self a t),
          ih fun i hi => h i (Finset.mem_cons_of_mem hi)]
        rfl
  refine zero _ _ fun i hi => ?_
  have hn : ¬((H.assign i).holder = p ∧ (H.assign i).kind = ShareKind.held
      ∧ k.assetEligible (H.assign i).asset = true
      ∧ carryingCurrency (H.assign i).asset = c) :=
    fun h => hElsewhere i hi h.1 h.2.1 h.2.2.1 h.2.2.2
  rw [if_neg hn]

/--
적격 담보가 전부 다른 통화로 기재된 주체는 그 통화의 단기 부채가 양이면 그 통화의 상환 실패 판정이 참이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 들고 있는 적격 몫이 전부 다른 통화로 기재된 주체가 그
통화로 진 단기 부채가 양인데 그 통화의 실효 조달 한도로 잰 상환 실패 판정이 거짓인 배치. 그 한도가 담보
쪽에서 영으로 막히므로 그런 배치가 설 수 없고, 반증은 그 한도가 두 상한의 작은 쪽이 아닌 구현에서만 온다.

**가정과 그 배제 사례(T-4·T-5):** 가정이 둘이다. 들고 있는 적격 몫이 전부 다른 통화로 기재되었다는 가정이
그 통화로 기재된 담보를 하나라도 가진 주체를 배제하고, 그 통화의 단기 부채 총계가 양이라는 가정이 그
통화로 갚을 것이 지평 안에 없는 주체를 배제한다. 앞의 가정을 빼면 그 통화의 담보가 한도를 세우므로 결론이
그 크기에 매이고, 뒤의 가정을 빼면 영과 영을 맞대어 판정이 거짓이 된다.

**T-3 분류:** 기여다. 부채의 통화와 그 부채가 조달한 자산의 통화가 갈린 주체에서 그 자산이 부채 통화의
한도를 세우지 못해 상환 실패 판정이 참이 되는 고리를 드는 유일한 자리이며, 통화 불일치의 전달이 상환 실패
가능성을 높인다는 정의층의 엣지가 이 판정의 두 인자에 닿는 자리다.

**이 판정이 환율을 지나지 않는 한도를 잰다.** 그 주체가 다른 통화의 자산을 팔아 그 통화를 사면 한도가
서지만 그 길이 환율을 지나므로 그 값의 결정이 동학층에 있고, 이 진술은 그 길이 막힌 자리에서 무엇이
남는가를 든다. 같은 층의 실효 조달 한도가 두 상한의 작은 쪽을 내므로 이 결론이 서며, 무담보 조달이
그 담보 쪽 상한 밖에 서는 구조라면 이 결론이 약해진다.

**통화마다 한도를 맞대는 제약이 규범에 실재한다.** 한 관할권의 은행 감독자가 유동성 요건을 은행의 두 통화
포지션에 각각 적용했고, 지목 참조로 연 편이 그 사례를 위기 때의 조달 압박에 대한 대응으로 든다. 이 진술의
판정이 그 통화의 의무와 그 통화의 한도를 맞대는 것이 그 요건과 같은 축이다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-9 「한 관할권의 은행 감독자가 유동성 요건을 은행의 두 통화 포지션에 각각 적용했다」
-/
-- DD:CF-4640
theorem failsRepayment_eq_true_of_carryingCurrency_ne
    {Idx SIdx Asset Party PIdx Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (H : ShareSet SIdx Asset Party PIdx ℤ)
    (k : Constraint ℤ Currency Asset) (carryingCurrency : Asset → Currency)
    (carrying : Asset → ℤ) (p : Party) (c : Currency) (t horizon : ℕ) (equity : ℤ)
    (hElsewhere : ∀ i ∈ H.index, (H.assign i).holder = p → (H.assign i).kind = ShareKind.held
        → k.assetEligible (H.assign i).asset = true → carryingCurrency (H.assign i).asset ≠ c)
    (hDue : 0 < shortTermLiabilityOf e S p c t horizon) :
    failsRepayment (shortTermLiabilityOf e S p c t horizon)
        (effectiveFundingLimit
          (debtCapacityHeadroom (liabilityTotalOf e S p c) (k.liabilityCap c) equity)
          (collateralCapacityAmountIn H k carryingCurrency carrying p c)) = true := by
  -- 담보 쪽 상한이 영으로 접히고 실효 한도가 그것을 넘지 못하므로, 판정의 비교가 양의 단기 부채와
  -- 영 이하의 한도를 맞댄다. 한도를 한 원자로 접어 정수 산술로 닫고 전면 `simp` 를 쓰지 않는다.
  rw [collateralCapacityAmountIn_eq_zero_of_carryingCurrency_ne H k carryingCurrency carrying p c
    hElsewhere]
  have hLe := effectiveFundingLimit_le_collateralAmount
    (debtCapacityHeadroom (liabilityTotalOf e S p c) (k.liabilityCap c) equity) 0
  generalize effectiveFundingLimit
      (debtCapacityHeadroom (liabilityTotalOf e S p c) (k.liabilityCap c) equity) 0 = lim at hLe ⊢
  generalize shortTermLiabilityOf e S p c t horizon = due at hDue ⊢
  simp only [failsRepayment]
  exact decide_eq_true (by omega)

/--
통화를 받지 않는 한도가 단기 부채를 덮는데 그 통화의 한도로 잰 상환 실패 판정이 참인 조달형 불일치의
배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 한 통화로 진 부채가 다른 통화의 자산을 조달한 주체에서
통화를 받지 않는 담보 여력으로 잰 판정과 그 부채 통화의 담보 여력으로 잰 판정이 늘 같은 값을 내는 것.
그러면 통화 축을 세운 것이 판정을 바꾸지 않으므로, 조달형 불일치가 그 한도를 줄이는 경로가 구조에 서지
않는다.

**존재 형태로 진술하는 까닭(T-6):** 두 판정이 갈리는지는 그 주체의 담보가 어느 통화로 기재되었는지와 두
상한의 크기가 정하고 그 배치가 구조에서 유도되지 않으므로, 전칭으로 세우면 거짓이다. 그 통화로 기재된
담보가 단기 부채를 덮는 주체에서는 두 판정이 같다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 통화를 받지 않는 금액 판본이 상환 실패를 놓치는 자리가 조달형 불일치에서 실제로
선다는 것을 드는 유일한 자리이며, 증거의 주체가 정의층의 조달 연결 불일치 판정에서 참을 낸다.

**정의층의 조달 연결 인스턴스를 그대로 쓴다.** 그 인스턴스가 부채 쪽 통화로 진 부채가 자산 쪽 통화의 자산을
조달한 주체를 드는 자리이므로, 담보의 기재 통화를 자산 쪽 통화로 두면 그 불일치가 이 배치의 담보에 선다.
-/
-- DD:CF-4640
theorem exists_failsRepayment_in_currency_while_blind_covers :
    ∃ (H : ShareSet Unit Unit Unit Unit ℤ) (k : Constraint ℤ MismatchWitnessCurrency Unit)
      (carryingCurrency : Unit → MismatchWitnessCurrency) (carrying : Unit → ℤ)
      (headroom due : ℤ),
      linkedFundingWitness.mismatched () MismatchWitnessCurrency.debtSide
          (carryingCurrency ()) = true ∧
      failsRepayment due
          (effectiveFundingLimit headroom (collateralCapacityAmountOf H k carrying ())) = false ∧
      failsRepayment due
          (effectiveFundingLimit headroom
            (collateralCapacityAmountIn H k carryingCurrency carrying ()
              MismatchWitnessCurrency.debtSide)) = true := by
  -- 보유 몫 하나를 두고 그 자산의 기재 통화를 자산 쪽 통화로 둔다. 통화를 받지 않는 담보 여력이
  -- 하나이고 부채 쪽 통화의 담보 여력이 영이며, 여지와 단기 부채를 하나로 두면 앞 판정이 거짓이고
  -- 뒤 판정이 참이다. 구체 값이 계산되므로 `decide` 로 닫는다.
  exact ⟨⟨{()}, fun _ => ⟨(), (), 1, ShareKind.held, none⟩⟩, ⟨fun _ => 0, fun _ => true⟩,
    fun _ => MismatchWitnessCurrency.assetSide, fun _ => 1, 1, 1, by decide, by decide, by decide⟩

end CrisisFramework.Accounting
