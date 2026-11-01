/-
회계층 — 부채수용력 여지와 담보 여력의 금액 판본과 실효 조달 한도

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(색인을 갈라 두고 환산하지 않는다),
      C-9(전면 `simp` 금지), A-6(기준선 차분), T-2(반증 조건), T-4(가정의 명시),
      T-6(존재 형태).

**수 체계: `ℤ`.** 금액과 몫이 둘 다 정수이고 몫이 스케일된 정수인 비율이므로, 곱이 금액에 배율이
걸린 값으로 서고 나눗셈이 들어가지 않는다.

**이 파일이 초석 명제의 둘째 절과 넷째 절을 한 사슬에 올린다.** 그 명제가 전파되는 것을 손실이
아니라 담보 가용성과 그에 따른 부채수용력으로 드는데, 담보 여력의 금액 판본과 부채수용력 여지가
서로 다른 축에서 조달의 상한을 주고 둘 가운데 작은 쪽이 실제로 물리는 한도다. 담보 쪽이 물리는
자리에서 적격성이 넓어지면 그 한도가 늘어나므로, 담보 가용성의 변화가 부채수용력의 변화로
전달되는 사슬이 그 자리에서 닫힌다.

**기재값을 인자로 받는다.** 자산의 기재값이 기재된 정수이고 그 값의 결정이 동학층에 있으므로,
이 층은 그 값을 받아 쓰고 결정하지 않는다. 같은 층의 부채 총계가 정의층의 환경을 인자로 받아
청구권의 금액 항을 평가하는 것과 같은 관례이며, L-9 의 의존 방향이 보존된다.

**레버리지를 새로 세우지 않는다.** 같은 층의 신용공급이 상한과 자기자본의 곱으로 서 있고 그
상한이 레버리지의 자리이므로, 이 파일은 그 곱에서 부채 총계를 뺀 여지를 든다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Accounting.Hierarchy
import CrisisFramework.Accounting.Ownership

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
금액 단위의 물림 판정.

**대응 비형식 개념:** 그 주체의 부채 총계가 제약의 상한과 자기자본의 곱을 넘지 않는가. 제약이
상시 등식이 아니라 물렸을 때만 드러나는 부등식이며, 그 물림을 금액 단위에서 잰다. 같은 층의 몫
단위 물림 판정이 보유와 제공의 두 합으로 같은 일을 하고, 이 판정이 그 금액 쪽 짝이다.

**이 정의가 배제하는 사례:**
한국의 예대율 상한. 그 상한이 원화 대출을 원화 예금에 매고 분모에서 양도성예금증서를 빼며 대상이
대출이고 총자산이나 부외 익스포저가 아니므로, 이 판정이 재는 양과 분자와 분모가 둘 다 다르다. 이
판정이 재는 것은 자기자본에 매인 총자산의 상한이며 특정 자산 범주를 특정 부채 범주에 매는 상한이
아니다(Hahm · Mishkin · Shin · Shin 2012).
조달처: E-52 §2-1 「그 상한이 총자산을 자기자본에 매는 것」

**기각한 대체 정의:**
비율로 두는 안. 비율로 두면 분모가 양변에 서서 나눗셈이 들어오고 L-15 가 비율 제약을 분모를 양변에
곱해 정수 부등식으로 쓰게 하므로 그 요구와 부딪힌다. 부채 총계 대신 단기 부채 총계를 받는 안도
기각했다. 제약의 상한이 총자산을 자기자본에 매는 것이어서 유효기일을 가르지 않으므로, 분자와 분모의
색인이 어긋난다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Bool` 이므로 판정이 그 타입의 `DecidableEq` 에서
나오고 인스턴스를 선언할 자리가 없다.

**수 체계를 받지 않는다.** 세 인자가 `ℤ` 이며 회계층의 기본 수 체계다.
-/
-- DD:CF-1995
def meetsLiabilityCapAmount (liabilityTotal cap equity : ℤ) : Bool :=
  decide (liabilityTotal ≤ creditSupply cap equity)

/--
부채수용력 여지.

**대응 비형식 개념:** 그 주체가 제약에 물리기까지 더 질 수 있는 부채의 금액. 제약의 상한과
자기자본의 곱에서 부채 총계를 뺀 값이며, 음이면 이미 물린 자리를 넘었다는 뜻이다. 초석 명제가
전파의 매개로 드는 둘 가운데 부채수용력 쪽이 이 값이다.

**이 정의가 배제하는 사례:**
자기자본을 손실에 대한 완충으로 보는 접근에서 재는 잔량. 그 접근에서는 손실을 흡수한 뒤에 남는
자기자본이 재어지고 이 값에서는 자기자본에 매인 총자산의 상한이 재어지므로, 같은 자기자본에서 두
값이 서로 다른 양을 센다. 레버리지 상한의 근거가 완충이 아니라 제약이라고 원문이 적는 것이 그
가름이다(Hahm · Mishkin · Shin · Shin 2012).
조달처: E-52 §2-1 「제약으로 쓰면 자기자본에 매인 총자산의 상한이 재어진다」

**기각한 대체 정의:**
비율의 여유로 두는 안. 비율로 두면 나눗셈이 들어오고 L-15 의 교차곱 요구와 부딪힌다. 음수를 영으로
자르는 안도 기각했다. 그 자름이 제약이 이미 물린 자리와 아직 여유가 있는 자리를 같은 값으로 접으므로
물림의 판정이 그 값에서 복원되지 않으며, 담보 계약의 두 양식이 신용보전금액을 음수가 되면 영으로
본다고 적어 그 자름이 실물에 선례를 갖되 이 자리의 목적이 물림을 재는 것이어서 그 선례를 따르면
목적이 사라진다.

**수 체계를 받지 않는다.** 세 인자가 `ℤ` 이며 회계층의 기본 수 체계다.
-/
-- DD:CF-1995
def debtCapacityHeadroom (liabilityTotal cap equity : ℤ) : ℤ :=
  creditSupply cap equity - liabilityTotal

/--
담보 여력의 금액 판본.

**대응 비형식 개념:** 그 주체가 담보로 내놓지 않고 들고 있는 몫 가운데 제약의 자산 측 적격성을
통과하는 것을 그 자산의 기재값으로 환산해 모은 값. 같은 층의 몫 판본이 같은 집합을 몫 단위로 모으고,
이 값이 그 금액 쪽 짝이어서 부채 쪽과 한 부등식에 들어간다.

**이 정의가 배제하는 사례:**
중앙은행 담보 틀의 할인율 격자. 영란은행의 틀이 범주와 금리 유형의 격자로 할인율 행 스물여덟을 내고
잔존만기 구간 여덟을 열로 두어 할인율이 0.5% 에서 42% 까지 벌어지므로, 기재값에 그 할인율을 걸어
받는 담보 가치는 이 값과 다르다. 이 값이 재는 것은 기재된 금액의 합이며 받는 쪽이 매길 값이 아니다.
조달처: E-49 §2-11 「할인율이 0.5% 에서 42% 까지 벌어지며 국채의 단기 구간이 최저이고」

**기각한 대체 정의:**
몫 쪽 선언 안에서 평가율을 곱하는 안. 그 안은 몫 쪽 선언의 기각 문단이 이미 기각했고 그 사유가 합이
자산마다 다른 비율을 품어 공통분모가 필요해진다는 것이다. 이 선언은 그 자리를 비켜 기재값을 인자로
받으므로 그 기각과 부딪히지 않는다. 적격 자산의 유한집합을 따로 받는 안도 기각했다. 몫 집합의 색인이
그 자리를 이미 대신하므로 색인이 둘이 되고 그 둘이 갈릴 수 있다.

**수 체계를 매개변수로 받는다.** 몫 집합이 수 체계를 받고 이 선언이 그 자리에 `ℤ` 를 넣으며, 기재값
사상이 자산을 받아 금액 항을 내므로 시점은 그 사상을 주는 쪽이 든다.
-/
-- DD:CF-2014
def collateralCapacityAmountOf {SIdx Asset Party PIdx Currency : Type} [DecidableEq Party]
    (H : ShareSet SIdx Asset Party PIdx ℤ)
    (k : Constraint ℤ Currency Asset) (carrying : Asset → ℤ) (p : Party) : ℤ :=
  ∑ i ∈ H.index,
    (if (H.assign i).holder = p ∧ (H.assign i).kind = ShareKind.held
          ∧ k.assetEligible (H.assign i).asset = true
     then (H.assign i).share * carrying (H.assign i).asset else 0)

/--
실효 조달 한도.

**대응 비형식 개념:** 두 상한 가운데 실제로 물리는 쪽. 부채수용력 여지가 부채 측 한도에서 오고
담보 여력의 금액 판본이 자산 측 적격성에서 오므로 둘이 서로 다른 축에 서며, 조달이 둘을 다 넘을 수
없어 작은 쪽이 한도다.

**이 정의가 배제하는 사례:**
적격성이 시점에 따라 바뀌는 자리. 영란은행의 틀에서 2026년 10월 31일부터 적격 회사채가 Level B 로만
분류되고 Level B 와 Level C 의 분할이 폐지되므로, 같은 자산을 들고 있어도 담보 쪽 상한이 그 시점을
지나며 달라진다. 이 값은 한 시점의 두 상한을 맞대며 그 시점 사이의 변화를 담지 않는다.
조달처: E-49 §2-12 「적격 회사채가 Level B 로만 분류되고」

**기각한 대체 정의:**
두 값의 합으로 두는 안. 합으로 두면 한쪽이 물려도 다른 쪽의 여유가 그것을 메우는 것으로 읽히는데,
두 상한이 서로 다른 축에서 오므로 한쪽의 여유가 다른 쪽의 물림을 풀지 못한다. 두 값을 따로 두고
맞대지 않는 안도 기각했다. 어느 쪽이 실제로 물리는지가 구조에 서지 않아 담보 가용성의 변화가
부채수용력으로 전달되는 사슬이 닫히지 않는다.

**최소를 조건식으로 직접 쓴다.** 순서 구조의 최소 연산이 끌어오는 인스턴스가 A-6 의 기준선을
넘기는 것이 같은 층에서 실측됐으므로, 판정을 조건식으로 두어 그 경로를 끊는다.

**수 체계를 받지 않는다.** 두 인자가 `ℤ` 이며 회계층의 기본 수 체계다.
-/
-- DD:CF-2015
def effectiveFundingLimit (headroom collateralAmount : ℤ) : ℤ :=
  if headroom ≤ collateralAmount then headroom else collateralAmount

/--
실효 한도는 부채수용력 여지를 넘지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 두 상한을 받아 낸 실효 한도가 그 가운데 여지보다
큰 배치. 조건식이 두 인자 가운데 하나를 그대로 내므로 그런 배치가 설 수 없고, 반증은 그 조건식이
세 번째 값을 내는 구현에서만 온다.

**가정을 두지 않는다.** 두 인자가 정수이고 결론이 조건식의 두 분기에서 각각 따라 나온다.

**T-3 분류:** 정의를 전개하고 두 분기를 가르면 닫히므로 보조 보정이며 기여 목록에서 뺀다. 실효
한도가 두 상한의 작은 쪽이라는 것을 쓰는 자리마다 이 부등식이 필요하므로 선언으로 둔다.
-/
-- DD:CF-2015
theorem effectiveFundingLimit_le_headroom (headroom collateralAmount : ℤ) :
    effectiveFundingLimit headroom collateralAmount ≤ headroom := by
  -- 조건식의 두 분기를 `by_cases` 로 가르고 각 분기에서 정수 부등식으로 닫는다. 전면 `simp` 와
  -- `linarith` 를 쓰지 않으며 마무리는 `omega` 다.
  show (if headroom ≤ collateralAmount then headroom else collateralAmount) ≤ headroom
  by_cases h : headroom ≤ collateralAmount
  · rw [if_pos h]
  · rw [if_neg h]
    omega

/--
실효 한도는 담보 여력의 금액 판본을 넘지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 두 상한을 받아 낸 실효 한도가 그 가운데 담보 쪽
금액보다 큰 배치. 앞 정리와 같은 사유로 설 수 없으며, 둘을 따로 두는 것은 조건식의 두 분기에서
작용하는 가정이 서로 다르기 때문이다.

**가정을 두지 않는다.** 두 인자가 정수이고 결론이 조건식의 두 분기에서 각각 따라 나온다.

**T-3 분류:** 정의를 전개하고 두 분기를 가르면 닫히므로 보조 보정이며 기여 목록에서 뺀다.
-/
-- DD:CF-2015
theorem effectiveFundingLimit_le_collateralAmount (headroom collateralAmount : ℤ) :
    effectiveFundingLimit headroom collateralAmount ≤ collateralAmount := by
  -- 앞 정리와 같은 꼴이며 분기의 방향만 바뀐다.
  show (if headroom ≤ collateralAmount then headroom else collateralAmount) ≤ collateralAmount
  by_cases h : headroom ≤ collateralAmount
  · rw [if_pos h]
    omega
  · rw [if_neg h]

/--
담보 쪽이 먼저 물리는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 담보 여력의 금액 판본이 부채수용력 여지보다
작은 두 정수를 어떻게 골라도 실효 한도가 담보 쪽 값과 같아지지 않는 것이 관측되어야 한다. 그러면
조건식이 작은 쪽을 내지 않는 것이므로 실효 한도의 정의가 두 상한의 최소가 아니다.

**존재 형태로 진술하는 까닭(T-6):** 담보 쪽이 물리는지 여지 쪽이 물리는지는 두 값의 크기가 정하고
그 크기가 구조에서 유도되지 않으므로, 전칭으로 세우면 거짓이다. 어느 조건에서 담보 쪽이 물리는지는
기재값과 적격성과 제약의 상한이 함께 정하며 그 사상이 형식층에 서지 않는다.

**이 존재가 초석 명제의 둘째 절을 형식층에 드는 첫 자리다.** 그 절이 전파되는 것을 손실이 아니라
담보 가용성과 그에 따른 부채수용력으로 드는데, 담보 쪽이 물리는 배치에서 적격성이 넓어지면 같은
파일의 단조 정리로 그 한도가 늘어나므로 담보 가용성의 변화가 부채수용력의 변화로 전달된다.
-/
-- DD:CF-2015
theorem exists_effectiveFundingLimit_eq_collateralAmount :
    ∃ headroom collateralAmount : ℤ,
      collateralAmount < headroom ∧
        effectiveFundingLimit headroom collateralAmount = collateralAmount := by
  -- 구체 정수 둘을 들어 증거한다. 조건식의 분기 판정이 계산으로 나오므로 `decide` 로 닫힌다.
  exact ⟨1, 0, by decide⟩

/--
상한이 오르면 같은 부채 총계와 자기자본에서 여지가 반드시 는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 자기자본이 양이고 부채 총계가 같은데 상한이
올랐음에도 여지가 늘지 않은 배치. 여지가 곱에서 부채 총계를 뺀 값이고 자기자본이 양이면 곱이
단조이므로 그런 배치가 설 수 없으며, 반증은 자기자본이 영 이하인 자리에서 온다.

**가정과 그 배제 사례(T-4·T-5):** 자기자본이 양이라는 가정과 상한이 올랐다는 가정을 진술에
명시한다. 자기자본이 양이라는 가정이 배제하는 자리는 자기자본이 음이 된 배치이고, 그 자리에서는
상한이 올라도 곱이 내려가므로 여지가 줄어든다. 같은 층의 앞선 전칭이 같은 가정을 같은 사유로 든다.

**증명이 정수 산술로 닫힌다.** 여지가 곱과 차로 서고 비교가 정수 위의 부등식이므로 유한집합의 합
보조정리가 쓰이지 않으며, 같은 층의 선례가 곱의 단조를 정수 곱셈 보조정리로 받고 마무리를 정수
산술 전술로 둔 길을 그대로 쓴다.
-/
-- DD:CF-1995
theorem debtCapacityHeadroom_lt_of_liabilityCap_lt
    (liabilityTotal cap₁ cap₂ equity : ℤ)
    (hEquity : 0 < equity) (hCap : cap₁ < cap₂) :
    debtCapacityHeadroom liabilityTotal cap₁ equity
      < debtCapacityHeadroom liabilityTotal cap₂ equity := by
  -- 두 여지를 펼치면 같은 부채 총계를 뺀 두 곱의 비교로 접히고, 자기자본이 양이므로 곱이 오른다.
  -- `Int.mul_lt_mul_of_pos_right` 로 곱의 단조를 받고 마무리를 `omega` 로 둔다. 전면 `simp` 와
  -- `linarith` 와 합의 부등식 보조정리를 쓰지 않는다.
  have hMul : creditSupply cap₁ equity < creditSupply cap₂ equity :=
    Int.mul_lt_mul_of_pos_right hCap hEquity
  show creditSupply cap₁ equity - liabilityTotal < creditSupply cap₂ equity - liabilityTotal
  omega

/--
적격성이 넓어지면 담보 여력의 금액 판본이 줄지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 한 제약의 적격성 판정이 참으로 내는 자산을 다른
제약이 전부 참으로 내는데, 그 다른 제약으로 잰 금액 판본이 더 작은 배치. 적격성이 넓어지면 더해지는
항이 늘어날 뿐이므로 각 항이 음수가 아닌 동안은 그런 배치가 설 수 없고, 반증은 음의 항을 지닌
배치에서 온다.

**가정과 그 배제 사례(T-4·T-5):** 몫과 기재값의 곱이 음수가 아니라는 가정을 진술에 명시한다. 같은
층의 자산별 보유 총계가 공매도를 음의 몫으로 받는다고 자기 docstring 에 적으므로 몫이 음수가 되는
자리가 실재하고, 기재값이 음수가 되는 자리는 충당금이 장부금액을 넘긴 배치다. 가정은 그 둘을 함께
배제한다. 몫 쪽 단조 정리가 몫의 비음수만 가정한 데 비해 이 가정이 곱의 비음수를 요구하는 것은
기재값이 인자로 들어왔기 때문이다.

**유한집합의 합 보조정리를 쓰지 않는다.** 핀된 판의 그 보조정리들이 선택공리를 끌어오는 것이
실측됐으므로 색인의 귀납으로 세운다. 같은 형의 선례가 이 층에 이미 있다.
-/
-- DD:CF-2014
theorem collateralCapacityAmountOf_le_of_assetEligible_imp
    {SIdx Asset Party PIdx Currency : Type} [DecidableEq Party]
    (H : ShareSet SIdx Asset Party PIdx ℤ)
    (k₁ k₂ : Constraint ℤ Currency Asset) (carrying : Asset → ℤ) (p : Party)
    (hNonneg : ∀ i ∈ H.index, 0 ≤ (H.assign i).share * carrying (H.assign i).asset)
    (hImp : ∀ a : Asset, k₁.assetEligible a = true → k₂.assetEligible a = true) :
    collateralCapacityAmountOf H k₁ carrying p
      ≤ collateralCapacityAmountOf H k₂ carrying p := by
  -- 두 합이 같은 색인 위에 서고 적격성이 넓어지면 항의 조건이 약해질 뿐이므로, 색인의 항마다
  -- 부등식을 세워 부분합으로 올린다. 부분합 부등식을 `Finset.cons_induction` 으로 직접 세우고
  -- `Finset.sum_le_sum` 과 `linarith` 를 쓰지 않는다. 같은 층의 몫 쪽 단조 정리가 같은 길을 갔다.
  simp only [collateralCapacityAmountOf]
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
  -- 좁은 쪽의 조건이 서면 넓은 쪽의 조건도 서서 양변이 같은 항이고, 넓은 쪽만 서면 왼쪽이 영이어서
  -- 비음수 가정이 받는다. 판정 명제를 `by_cases` 로 가르므로 배중률을 쓰지 않는다.
  by_cases h₁ : (H.assign i).holder = p ∧ (H.assign i).kind = ShareKind.held
      ∧ k₁.assetEligible (H.assign i).asset = true
  · rw [if_pos h₁, if_pos (And.intro h₁.1 (And.intro h₁.2.1 (hImp _ h₁.2.2)))]
  · rw [if_neg h₁]
    by_cases h₂ : (H.assign i).holder = p ∧ (H.assign i).kind = ShareKind.held
        ∧ k₂.assetEligible (H.assign i).asset = true
    · rw [if_pos h₂]
      exact hNonneg i hi
    · rw [if_neg h₂]

/--
위계에서 위에 있는 자리의 제약을 받으면 실효 조달 한도가 작지 않다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 위계에서 엄격히 위에 있는 주체의 제약이 부채 측
한도와 자산 측 적격성 양쪽에서 넓고 그 주체의 자기자본이 음이 아닌데, 그 제약으로 잰 실효 조달 한도가
아래 자리의 제약으로 잰 것보다 작은 배치. 두 상한이 각각 작지 않으면 그 최소도 작지 않으므로 그런
배치가 설 수 없고, 반증은 그 셋 가운데 하나가 깨진 자리에서 온다.

**가정과 그 배제 사례(T-4·T-5):** 가정을 전부 진술에 명시한다. 위계에서 엄격히 위에 있다는 것과
위계 위치가 부채 측 한도를 가른다는 것과 위계 위치가 자산 측 적격성을 가른다는 것과 몫과 기재값의
곱이 음수가 아니라는 것과 자기자본이 음이 아니라는 것이다. **두 고리와 자기자본의 부호가 구조에서
나오지 않는다.** 긴급 조달의 단계가 위계 위치에서 유도되지 않고 그 단계에서 제약의 두 필드로 가는
사상이 형식층에 없으므로 그 고리가 둘 다 가정으로 서고 그 결손이 구멍으로 등재되어 있다. 자기자본의
부호를 정하는 것이 그 주체의 지급능력인데 지급능력 축의 제약이 형식층에 서 있지 않으므로 그 부호도
가정으로 서며, 그 결손도 같은 부류다. 고리의 가정이 배제하는 자리는 단계가 높아도 한도가 작거나
적격성이 좁은 배치이며, 중앙은행이 특정 담보 범주를 받지 않기로 한 자리가 그 부류다. 자기자본의
가정이 배제하는 자리는 자기자본이 음인 주체가 위계 상단의 제약을 받아도 조달의 한도가 늘지 않는
배치이며, 중앙은행이 자본을 갖지 않아 손실 흡수가 재정 주체로 넘어가는 자리가 그 부류다.

**이 부호 조건은 반례가 세운 것이다.** 그것을 떼면 이 진술이 거짓이다. 여지가 상한과 자기자본의
곱에서 부채 총계를 뺀 값이므로 자기자본이 음이면 상한이 오를수록 여지가 줄어들어 곱의 단조가 뒤집히며,
주체를 두 값으로 두고 위를 상단에 두고 상한을 하나와 영으로 두고 모든 자산을 적격으로 두고 몫 집합을
비우고 부채 총계를 영으로 두고 자기자본을 음의 하나로 둔 배치에서 다른 가정이 전부 서고 결론이
거짓으로 계산된다. **등호를 허용하는 꼴로 두는 까닭은 자기자본이 영이면 두 여지가 같아 결론의 등호가
서기 때문이다.** 같은 파일의 짝이 되는 단조 정리가 자기자본의 양수를 요구해 엄격한 부등식을 내는
것과 갈리는 자리다.

**이것이 초석 명제의 넷째 절이 다시 서는 자리다.** 그 절이 상단의 노드는 디폴트하지 않고 조정한다고
드는데, 상단의 제약을 받는 자리에서 조달의 한도가 작지 않다는 것이 그 절의 형식층 판본이다. 앞 아크가
그 절을 전칭으로 세워 거짓으로 판정한 것은 전제가 의무액과 지급액을 묶지 않아 결론이 전제와 독립인
것이었고, 이 꼴은 두 상한을 묶어 그 독립을 깬다. **가정을 들되 그것이 결론을 직접 말하지 않는 것이
이 꼴의 요지다.**
-/
-- DD:CF-1997
theorem effectiveFundingLimit_le_of_hierarchy_above
    {SIdx Asset Party PIdx Currency : Type} [DecidableEq Party]
    (M : MoneyAsset Party)
    (H : ShareSet SIdx Asset Party PIdx ℤ)
    (k : Party → Constraint ℤ Currency Asset) (carrying : Asset → ℤ)
    (p m n : Party) (c : Currency) (liabilityTotal equity : ℤ)
    (hEquity : 0 ≤ equity)
    (hNonneg : ∀ i ∈ H.index, 0 ≤ (H.assign i).share * carrying (H.assign i).asset)
    (hAbove : M.aboveOrEqual m n = true) (hStrict : M.aboveOrEqual n m = false)
    (hCapLink : ∀ x y : Party, M.aboveOrEqual x y = true → M.aboveOrEqual y x = false →
                  (k y).liabilityCap c ≤ (k x).liabilityCap c)
    (hEligLink : ∀ x y : Party, M.aboveOrEqual x y = true → M.aboveOrEqual y x = false →
                   ∀ a : Asset, (k y).assetEligible a = true → (k x).assetEligible a = true) :
    effectiveFundingLimit
        (debtCapacityHeadroom liabilityTotal ((k n).liabilityCap c) equity)
        (collateralCapacityAmountOf H (k n) carrying p)
      ≤ effectiveFundingLimit
        (debtCapacityHeadroom liabilityTotal ((k m).liabilityCap c) equity)
        (collateralCapacityAmountOf H (k m) carrying p) := by
  -- 위계 가정을 두 고리 가정에 먹여 한도 부등식과 적격성 함의를 받는다. 한도 부등식에 자기자본의
  -- 부호 가정을 먹이면 곱의 단조가 비음수 꼴로 서서 여지의 부등식이 나온다. 적격성 함의에서는 금액
  -- 판본의 부등식이 같은 파일의 단조 정리로 선다. 아래 자리의 최소는 같은 파일의 두 상계 정리로 두
  -- 인자 아래에 묶고, 위 자리의 조건식을 두 분기로 갈라 최소의 부등식을 낸다. 전면 `simp` 와
  -- `linarith` 를 쓰지 않으며 마무리는 `omega` 다.
  have hMul : creditSupply ((k n).liabilityCap c) equity
      ≤ creditSupply ((k m).liabilityCap c) equity :=
    Int.mul_le_mul_of_nonneg_right (hCapLink m n hAbove hStrict) hEquity
  have hHead : debtCapacityHeadroom liabilityTotal ((k n).liabilityCap c) equity
      ≤ debtCapacityHeadroom liabilityTotal ((k m).liabilityCap c) equity := by
    show creditSupply ((k n).liabilityCap c) equity - liabilityTotal
      ≤ creditSupply ((k m).liabilityCap c) equity - liabilityTotal
    omega
  have hColl := collateralCapacityAmountOf_le_of_assetEligible_imp H (k n) (k m) carrying p
    hNonneg (hEligLink m n hAbove hStrict)
  have h₁ := effectiveFundingLimit_le_headroom
    (debtCapacityHeadroom liabilityTotal ((k n).liabilityCap c) equity)
    (collateralCapacityAmountOf H (k n) carrying p)
  have h₂ := effectiveFundingLimit_le_collateralAmount
    (debtCapacityHeadroom liabilityTotal ((k n).liabilityCap c) equity)
    (collateralCapacityAmountOf H (k n) carrying p)
  -- 아래 자리의 최소를 한 원자로 접어 두 상계만 남긴다.
  generalize effectiveFundingLimit
      (debtCapacityHeadroom liabilityTotal ((k n).liabilityCap c) equity)
      (collateralCapacityAmountOf H (k n) carrying p) = lo at h₁ h₂ ⊢
  show lo ≤ (if debtCapacityHeadroom liabilityTotal ((k m).liabilityCap c) equity
                ≤ collateralCapacityAmountOf H (k m) carrying p
             then debtCapacityHeadroom liabilityTotal ((k m).liabilityCap c) equity
             else collateralCapacityAmountOf H (k m) carrying p)
  by_cases h : debtCapacityHeadroom liabilityTotal ((k m).liabilityCap c) equity
      ≤ collateralCapacityAmountOf H (k m) carrying p
  · rw [if_pos h]
    omega
  · rw [if_neg h]
    omega

/--
실효 조달 한도가 단기 부채 총계를 덮으면 상환 실패 판정이 거짓이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 지급 의무가 선 액수를 실효 조달 한도가 덮는데도
상환 실패 판정이 참을 내는 배치. 그 판정이 두 수의 비교이므로 그런 배치가 설 수 없고, 반증은 그
판정의 본문이 비교 밖의 값을 쓰는 구현에서만 온다.

**가정과 그 배제 사례(T-4·T-5):** 단기 부채 총계가 실효 조달 한도를 넘지 않는다는 가정을 진술에
명시한다. 그 가정이 배제하는 자리는 두 상한이 둘 다 작아 조달이 의무를 덮지 못하는 배치이며, 그
자리에서 상환 실패가 실제로 선다.

**이 진술이 상환 실패 판정의 두 인자에 값을 내는 자리를 형식층에 드는 첫 자리다.** 그 판정의 두
인자가 이 진술에 서기 전까지 그 이름이 선언과 본문에만 등장했으므로, 앞 아크가 넷째 절의 전칭을
거짓으로 판정한 사유인 전제와 결론의 독립이 그 두 인자에 값을 내는 자리가 없다는 것이었다. 의무액이
단기 부채 총계이고 지급액이 실효 조달 한도일 때 그 비교가 다른 전제에서 유도되므로 그 독립이 깨진다.

**T-3 분류:** 증명이 정의 전개로 닫히나 기여로 센다. 그 사유가 이 진술이 두 축을 처음 잇는다는
것이고 증명의 길이가 아니며, 같은 판정이 이 아크의 앞선 페이즈에 섰다.
-/
-- DD:CF-1997
theorem failsRepayment_eq_false_of_shortTerm_le_effectiveFundingLimit
    {Idx SIdx Asset Party PIdx Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (H : ShareSet SIdx Asset Party PIdx ℤ)
    (k : Constraint ℤ Currency Asset) (carrying : Asset → ℤ)
    (p : Party) (c : Currency) (t horizon : ℕ) (equity : ℤ)
    (hCover : shortTermLiabilityOf e S p c t horizon
                ≤ effectiveFundingLimit
                    (debtCapacityHeadroom (liabilityTotalOf e S p c) (k.liabilityCap c) equity)
                    (collateralCapacityAmountOf H k carrying p)) :
    failsRepayment (shortTermLiabilityOf e S p c t horizon)
        (effectiveFundingLimit
          (debtCapacityHeadroom (liabilityTotalOf e S p c) (k.liabilityCap c) equity)
          (collateralCapacityAmountOf H k carrying p)) = false := by
  -- 판정을 펼치면 두 수의 비교이고 가정이 그 비교의 반대 방향을 주므로 `decide` 가 거짓을 낸다.
  -- 전면 `simp` 를 쓰지 않고 `simp only` 로 판정의 정의만 펼친다.
  simp only [failsRepayment]
  exact decide_eq_false (Int.not_lt.mpr hCover)

end CrisisFramework.Accounting
