/-
회계층 — 자본 조정의 사상과 그 상의 양방향성

규율: L-4(회계층에 `ℝ` 가 들어오면 위반), L-10·L-15(회계층의 기본 수 체계는 `ℤ`),
      L-9(import 방향은 단방향), D-1·D-2(docstring 3항목), D-5(오염 어간에 한정어를 붙인다),
      C-9(전면 `simp` 금지), T-2(반증 조건), T-3(기여 분류), T-6(존재 형태).

이 파일은 `ℤ` 만 쓴다. 조정이 더하기와 빼기로 닫히고 나눗셈을 쓰지 않으므로 `ℚ` 가 강제되는
자리가 없다.

**이 파일이 세우는 것은 한 자본 개념에서 다른 자본 개념으로 가는 사상이다.** 용어집이 규제자본을
자본의 분기로 등재하면서 보통주 장부자본과 자기자본과 후순위 포함 장부자본이 이루는 중첩 사슬에
그것을 놓지 않는데, 그 사유가 공제와 가산을 거쳐 포함 관계가 아니라는 것이다. **이 파일은 그 사슬에
원소를 더하지 않고 두 자본을 잇는 사상을 세우며, 그 상이 어느 방향으로도 포함을 이루지 않음을
존재 진술 둘로 든다.**

**합을 유한집합 합으로 돌리지 않는다.** 그 합의 부등식 보조정리 가운데 핀된 판에서 선택공리를
끌어오는 것이 있어 한 번으로 공리 기준선의 초과가 서며, 그 목록의 정본은 `docs/baseline.md` 가
든다. 그래서 항목의 열거를 목록으로 들고 접기로 더한다.

**체제가 시점을 받는 자리를 이 파일이 쓰지 않는다.** 정의층이 체제의 족을 세우나 이 파일의 사상은
한 시점의 체제를 받으며, 시점을 달리하는 조정의 비교는 그 족을 받는 쪽의 몫이다. 값과 값의 결정이
다른 층에 산다는 가름이 그 자리에 걸린다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Int.Notation
import CrisisFramework.Definition.CapitalAdjustment

namespace CrisisFramework.Accounting

open CrisisFramework.Definition

/--
자본 조정 항목의 전량 목록.

**대응 비형식 개념:** 조정이 닿을 수 있는 자리의 전수. 감독 규범의 자본 조정 장이 공제 항목을 절
제목으로 열거하고 감독 지침의 원칙 다섯이 그 장에 없는 항목 넷을 더하므로, 그 둘의 합집합이 이
목록의 원소다.

**이 정의가 배제하는 사례:**
판이 올라가면서 공제 항목이 더해지거나 빠지는 자리. 감독 규범의 편입본이 자기 장을 판마다 고쳐
싣고 이 목록은 한 판의 열거를 고정하므로, 그 변화를 담지 못한다. 그 결손이 증권화 연쇄의 단계
열거에서 이미 구멍으로 서 있고 같은 축이다(바젤은행감독위원회).
조달처: E-56 §8-2 「그 열거가 절 제목으로 닫혀 있어 조문에서 전수로 뽑힌다」

**기각한 대체 정의:**
유한집합으로 두는 안. 그 꼴이 중복을 막고 순서를 지우므로 열거의 전수를 드는 데 더 맞으나, 그 합의
부등식 보조정리 가운데 핀된 판에서 선택공리를 끌어오는 것이 있어 그것을 쓰는 순간 공리 기준선의
초과가 선다. 목록으로 두고 접기로 더하면 그 유입이 서지 않으며, 중복과 순서가 이 파일의 총계에
영향을 주지 않는 것은 각 항목이 한 번만 등장하도록 이 목록을 세우기 때문이다.
-/
-- DD:CF-2571
def allAdjustmentItems : List CapitalAdjustmentItem :=
  [ .goodwillAndIntangibles, .deferredTaxAsset, .cashFlowHedgeReserve,
    .provisionShortfall, .securitisationGainOnSale, .definedBenefitPensionAsset,
    .ownShareInvestment, .reciprocalCrossHolding, .financialEntityInvestment,
    .thresholdDeduction, .hiddenLoss, .nonGoingConcernCapitalItem,
    .hiddenReserve, .minorityInterest ]

/--
그 체제가 공제로 거두는 금액의 총계.

**대응 비형식 개념:** 조정의 공제 쪽 합. 체제가 쓰는 항목 가운데 방향이 공제인 것의 금액을 더한
값이다.

**이 정의가 배제하는 사례:**
문턱 공제의 되먹임. 감독 규범이 문턱 공제를 두고 그 앞의 절들이 보통주 자본의 10%를 넘는 금액에
걸리는 규칙을 두므로 한 항목의 공제액이 다른 항목의 금액과 자본 자신의 금액에 함께 걸리는데, 이
함수는 항목별 금액을 주어진 것으로 받아 더하므로 그 되먹임을 담지 못한다. 그 금액을 내는 규칙이
체제의 재량에 남는다(바젤은행감독위원회).
조달처: E-56 §8-5 「항목마다 금액을 받아 더하는 꼴로는 그 문턱이 표현되지 않으므로」

**기각한 대체 정의:**
항목별 금액을 구조의 필드로 받는 안. 항목이 열넷이어서 필드도 열넷이 되고 판이 올라가 항목이 늘면
그 구조가 함께 바뀌는데, 함수로 받으면 열거가 바뀔 때 그 함수의 정의역만 넓어진다. 그리고 필드로
두면 체제가 쓰지 않는 항목의 금액도 자리를 차지하므로 쓰임과 금액이 한 자리에 섞인다.
-/
-- DD:CF-2571
def CapitalAdjustmentRegime.deductionTotal
    (r : CapitalAdjustmentRegime) (amountOf : CapitalAdjustmentItem → ℤ) : ℤ :=
  allAdjustmentItems.foldl
    (fun acc i =>
      if r.applied i then
        match r.direction i with
        | .deduction => acc + amountOf i
        | .addition => acc
      else acc) 0

/--
그 체제가 가산으로 거두는 금액의 총계.

**대응 비형식 개념:** 조정의 가산 쪽 합. 체제가 쓰는 항목 가운데 방향이 가산인 것의 금액을 더한
값이다.

**이 정의가 배제하는 사례:**
숨은 적립금을 넣을 때 위험 노출을 함께 늘리라는 요구. 감독 지침이 기관이 숨은 적립금을 넣기로
정하면 그것이 조심스럽고 보수적으로 이루어질 것을 기대하며 그때 위험 노출을 그 포함에 맞추어 늘릴
것을 기대한다고 적는데, 이 함수는 가산의 총계만 내고 그 짝이 되는 노출의 증가를 담지 못한다. 그
짝은 위험 측정의 몫이고 이 아크에 그 축을 받는 구조물이 서지 않는다(유럽중앙은행).
조달처: E-58 §4 「그때 위험 노출을 그 포함에 맞추어 늘릴 것을 기대한다고 적는다」

**기각한 대체 정의:**
공제와 가산을 한 함수로 두고 가산을 음의 공제로 표현하는 안. 그러면 총계 하나로 닫혀 사상이
간결해지나, 조정의 방향이 체제의 선택이라는 사실이 그 총계에서 사라진다. 두 총계를 따로 두면 어느
방향이 그 값을 냈는지가 사상의 서명에 남고, 그것이 포함 관계가 서지 않는 사유를 드는 진술의 재료가
된다.
-/
-- DD:CF-2571
def CapitalAdjustmentRegime.additionTotal
    (r : CapitalAdjustmentRegime) (amountOf : CapitalAdjustmentItem → ℤ) : ℤ :=
  allAdjustmentItems.foldl
    (fun acc i =>
      if r.applied i then
        match r.direction i with
        | .addition => acc + amountOf i
        | .deduction => acc
      else acc) 0

/--
출발 자본에 조정을 걸어 낸 자본.

**대응 비형식 개념:** 한 자본 개념에서 다른 자본 개념으로 간 값. 감독 규범의 조정이 장부자본에서
규제 자기자본으로 가고 감독 지침의 조정이 규제 자기자본에서 내부 자본으로 가는데, 두 축이 같은 꼴의
사상이므로 이 함수가 둘을 받는다.

**이 정의가 배제하는 사례:**
평가 방법과 가정의 차이가 낳는 갈림. 감독 지침이 자산과 부채와 거래의 평가 방법과 가정이 달라
경제적 관점의 가용 내부 자본이 규범적 관점의 자기자본과 크게 다를 수 있음을 기관이 인식하도록
요구하는데, 이 함수는 출발 자본과 항목별 금액을 주어진 것으로 받으므로 그 평가의 갈림이 금액에
이미 들어온 뒤의 자리에 선다. 그래서 같은 대차대조표에서 두 기관이 다른 출발 자본을 적는 자리를
담지 못한다(유럽중앙은행).
조달처: E-58 §2 「경제적 관점 아래의 가용 내부 자본이 규범적 관점 아래의 자기자본과 크게 다를 수 있음」

**기각한 대체 정의:**
사상을 자본의 분기 사이의 함수로 타입 지어 두는 안. 그러면 출발과 도착이 어느 분기인지가 타입에
서나 용어집의 분기가 열거이고 그 열거의 원소마다 수 체계가 같으므로 그 타입이 값을 가르지 않으며,
분기를 타입으로 올리면 조정의 사상이 분기 쌍마다 따로 서야 한다. 조정의 꼴이 분기와 무관하게 같다는
것이 이 파일의 산출이므로 그 꼴을 한 함수로 둔다.
-/
-- DD:CF-2571
def adjustedCapitalOf
    (r : CapitalAdjustmentRegime) (base : ℤ)
    (amountOf : CapitalAdjustmentItem → ℤ) : ℤ :=
  base - CapitalAdjustmentRegime.deductionTotal r amountOf
    + CapitalAdjustmentRegime.additionTotal r amountOf

/--
조정 결과가 출발 자본보다 큰 자리가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 조정이 공제만으로 닫혀 어느 체제도 가산을 걸
수 없어야 한다. 그러면 감독 지침이 숨은 적립금을 넣는 길을 두고 감독 규범이 현금흐름 헤지 적립금의
음수를 다시 더해야 한다고 적은 두 문면이 거짓이 된다.

**존재 형태로 진술하는 까닭(T-6):** 조정의 결과가 출발 자본보다 큰지는 체제와 금액에 함께 걸리므로
전칭으로 세우면 거짓이다. 어느 체제에서도 그 부등식이 서지 않는다는 것이 이 명제가 막는 것이며,
존재 하나로 그것이 선다.

**T-3 분류:** 보조 보정이 아니다. 다음 명제와 짝을 이루어 조정의 상이 어느 방향으로도 포함을
이루지 않음을 들며, 규제자본이 자본 계열의 중첩 사슬에 들지 못하는 사유가 그 짝에서 선다.
-/
-- DD:CF-2571
theorem exists_adjusted_above_base :
    ∃ (r : CapitalAdjustmentRegime) (base : ℤ) (amountOf : CapitalAdjustmentItem → ℤ),
      base < adjustedCapitalOf r base amountOf := by
  exact ⟨CapitalAdjustmentRegime.allAdded, 0, fun _ => 1, by decide⟩

/--
조정 결과가 출발 자본보다 작은 자리가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 조정이 가산만으로 닫혀 어느 체제도 공제를 걸
수 없어야 한다. 그러면 감독 규범의 자본 조정 장이 공제 항목을 절 제목으로 열거한 것이 거짓이 된다.

**존재 형태로 진술하는 까닭(T-6):** 앞의 명제와 같은 사유다. 부등식의 방향이 체제와 금액에 함께
걸리므로 전칭이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 앞의 명제와 짝을 이루어 어느 방향의 포함도 성립하지 않음을
들므로, 이 둘이 함께 서는 것이 이 파일의 산출이다.
-/
-- DD:CF-2571
theorem exists_adjusted_below_base :
    ∃ (r : CapitalAdjustmentRegime) (base : ℤ) (amountOf : CapitalAdjustmentItem → ℤ),
      adjustedCapitalOf r base amountOf < base := by
  exact ⟨CapitalAdjustmentRegime.allDeducted, 0, fun _ => 1, by decide⟩

/--
같은 출발 자본과 같은 항목별 금액에 두 체제가 다른 값을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 조정의 결과가 출발 자본과 항목별 금액만으로
정해져 체제의 선택이 그 값을 바꾸지 못해야 한다. 그러면 감독 지침이 내부 자본의 정의와 방법론을
기관의 책임으로 두고 어느 정의도 규정하지도 제한하지도 않는다고 적은 문면이 거짓이 된다.

**존재 형태로 진술하는 까닭(T-6):** 두 체제가 다른 값을 내는 것은 그 둘이 어느 항목에서 갈리는지와
그 항목의 금액이 영인지에 함께 걸리므로 전칭으로 세우면 거짓이다. 금액이 전부 영이면 어느 두 체제도
같은 값을 낸다.

**T-3 분류:** 보조 보정이 아니다. 조정의 사상이 기관의 재량을 받는다는 것을 이 명제가 들며, 그
재량이 「규범의 판마다 다르다」보다 한 단계 넓은 결손이어서 그것을 형식층에 남기는 유일한 자리다.
-/
-- DD:CF-2571
theorem exists_regimes_differing_on_adjusted :
    ∃ (r s : CapitalAdjustmentRegime) (base : ℤ) (amountOf : CapitalAdjustmentItem → ℤ),
      adjustedCapitalOf r base amountOf ≠ adjustedCapitalOf s base amountOf := by
  exact ⟨CapitalAdjustmentRegime.allDeducted, CapitalAdjustmentRegime.allAdded, 0,
    fun _ => 1, by decide⟩

end CrisisFramework.Accounting
