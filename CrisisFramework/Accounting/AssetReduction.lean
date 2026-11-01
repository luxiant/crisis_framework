/-
회계층 — 자산 감소의 까닭을 재는 판정

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), C-9(전면 `simp` 금지), A-6(기준선 차분),
      T-2(반증 조건), T-4(가정의 명시).

**수 체계: `ℤ`.** 두 시점의 자산 총액과 부채 총액을 정수로 받아 맞댄다.

**판정이 선택을 낸다.** 자산이 줄지 않은 배치에서는 까닭이 서지 않으므로 값을 갖지 않으며, 같은
층의 조정 모드 판정이 고정된 성분이 없거나 둘 이상일 때 값을 갖지 않게 둔 것과 같은 꼴이다.

**이 판정이 관측 경로의 한 칸이 묻는 것을 구조로 받는다.** 상환 경로의 그 칸이 자산이 줄어든 까닭을
가르는가를 묻고 그 축이 서지 않았다고 자기 docstring 에 적는데, 이 판정이 그 축이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Int.Notation
import CrisisFramework.Definition.AssetReduction

namespace CrisisFramework.Accounting

open CrisisFramework.Definition

/--
자산 감소의 까닭을 두 시점의 두 총계로 재는 판정.

**대응 비형식 개념:** 두 시점 사이에 자산 총액이 줄었을 때 부채 총액이 함께 줄었는지로 그 까닭을
가른다. 함께 줄었으면 상환에 따른 소멸이고 줄지 않았으면 매각이며, 자산 총액이 줄지 않은 배치에서는
까닭이 서지 않아 값을 갖지 않는다.

**이 정의가 배제하는 사례:**
롤오버 게임의 손상 함수. 그 함수가 인출량을 받아 대차대조표에 입히는 비용을 내고 그 미분이 자산
단위를 팔 때의 가격 할인이므로, 매각이 일어나는 자리에서 자산 총액의 감소가 매각한 양과 같지 않고
할인만큼 더 줄어든다. 이 판정은 두 총계의 차이만 받으며 그 차이가 매각량인지 할인을 포함한 값인지를
가르지 않는다(Morris · Shin 2016).
조달처: E-17 §2-5 「인출량 `Z` 가 대차대조표에 입히는 비용을 담는다」

**기각한 대체 정의:**
두 총액의 변화만으로 판정하고 경로의 칸을 읽지 않는 안. 그 안은 조정 판정의 기각 문단이 이미
기각했고 그 사유가 상환으로 부채가 소멸하면 자산도 함께 주는데 그것이 의무의 이행이고 조정이
아니라는 것이다. 이 판정은 그 둘을 가르는 것이 목적이어서 그 기각이 막은 자리와 다르다. 자산이
줄지 않은 배치에서 값을 내는 안도 기각했다. 까닭이 서지 않는 자리에서 값을 내면 그 값이 무엇을
가리키는지가 서지 않으며, 같은 층의 조정 모드 판정이 같은 꼴을 따른다.

**수 체계를 받지 않는다.** 네 인자가 `ℤ` 이며 회계층의 기본 수 체계다.
-/
-- DD:CF-2006
def assetReductionCauseOf (assetBefore assetAfter liabilityBefore liabilityAfter : ℤ) :
    Option AssetReductionCause :=
  if assetAfter < assetBefore then
    (if liabilityAfter < liabilityBefore then some AssetReductionCause.repaymentExtinction
     else some AssetReductionCause.assetSale)
  else none

/--
자산 총액이 줄지 않으면 까닭이 서지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 자산 총액이 줄지 않았는데 이 판정이 까닭을 내는
배치. 조건식의 첫 분기가 그 자리를 받으므로 그런 배치가 설 수 없고, 반증은 그 분기가 뒤집힌
구현에서만 온다.

**가정과 그 배제 사례(T-4·T-5):** 자산 총액이 줄지 않았다는 가정을 진술에 명시한다. 그 가정이
배제하는 자리는 자산이 줄어든 배치이며 거기서 이 판정이 까닭을 낸다. 자산 총액이 불변인 채 자산의
구성만 바뀌는 조정이 이 가정 안에 들어오고 그 구성을 가르는 구조가 형식층에 없으므로, 그 결손이
구멍으로 등재되어 있다.

**T-3 분류:** 정의를 전개하고 분기를 가르면 닫히므로 보조 보정이며 기여 목록에서 뺀다. 판정이
선택을 내는 자리가 구조에 서 있다는 것을 쓰는 데 이 정리가 필요하므로 선언으로 둔다.
-/
-- DD:CF-2006
theorem assetReductionCauseOf_eq_none_of_not_lt
    (assetBefore assetAfter liabilityBefore liabilityAfter : ℤ)
    (h : ¬ assetAfter < assetBefore) :
    assetReductionCauseOf assetBefore assetAfter liabilityBefore liabilityAfter = none := by
  -- 조건식의 첫 분기를 가정으로 닫는다. `simp only` 로 판정의 정의만 펼치고 전면 `simp` 를
  -- 쓰지 않는다.
  simp only [assetReductionCauseOf]
  rw [if_neg h]

/--
자산과 부채가 함께 줄면 까닭이 상환에 따른 소멸이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 자산 총액과 부채 총액이 둘 다 줄었는데 이 판정이
매각을 내거나 값을 내지 않는 배치. 조건식의 두 분기가 그 자리를 받으므로 그런 배치가 설 수 없다.

**가정과 그 배제 사례(T-4·T-5):** 자산 총액이 줄었다는 가정과 부채 총액이 줄었다는 가정을 진술에
명시한다. 그 둘이 배제하는 자리는 자산만 줄어든 배치이며 거기서 이 판정이 매각을 낸다.

**T-3 분류:** 정의를 전개하고 두 분기를 가르면 닫히므로 보조 보정이며 기여 목록에서 뺀다.
-/
-- DD:CF-2006
theorem assetReductionCauseOf_eq_repaymentExtinction
    (assetBefore assetAfter liabilityBefore liabilityAfter : ℤ)
    (hAsset : assetAfter < assetBefore) (hLiab : liabilityAfter < liabilityBefore) :
    assetReductionCauseOf assetBefore assetAfter liabilityBefore liabilityAfter
      = some AssetReductionCause.repaymentExtinction := by
  -- 두 분기를 두 가정으로 각각 닫는다. `simp only` 로 판정의 정의만 펼친다.
  simp only [assetReductionCauseOf]
  rw [if_pos hAsset, if_pos hLiab]

/--
자산만 줄면 까닭이 매각이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 자산 총액이 줄고 부채 총액이 줄지 않았는데 이
판정이 상환에 따른 소멸을 내거나 값을 내지 않는 배치. 조건식의 두 분기가 그 자리를 받으므로 그런
배치가 설 수 없다.

**가정과 그 배제 사례(T-4·T-5):** 자산 총액이 줄었다는 가정과 부채 총액이 줄지 않았다는 가정을
진술에 명시한다. 그 둘이 배제하는 자리는 둘이 함께 줄어든 배치이며 거기서 이 판정이 상환에 따른
소멸을 낸다. **이 정리와 앞 정리가 함께 분할의 완전성을 형식층에서 드러낸다.** 자산이 줄었다는
조건 아래에서 부채가 줄었는가의 참과 거짓이 두 부분을 각각 내므로, 용어집이 그 완전성을 여집합의
귀결로 적은 것이 이 두 정리로 확인된다.

**T-3 분류:** 정의를 전개하고 두 분기를 가르면 닫히므로 보조 보정이며 기여 목록에서 뺀다.
-/
-- DD:CF-2006
theorem assetReductionCauseOf_eq_assetSale
    (assetBefore assetAfter liabilityBefore liabilityAfter : ℤ)
    (hAsset : assetAfter < assetBefore) (hLiab : ¬ liabilityAfter < liabilityBefore) :
    assetReductionCauseOf assetBefore assetAfter liabilityBefore liabilityAfter
      = some AssetReductionCause.assetSale := by
  -- 앞 정리와 같은 꼴이며 둘째 분기의 방향만 바뀐다.
  simp only [assetReductionCauseOf]
  rw [if_pos hAsset, if_neg hLiab]

end CrisisFramework.Accounting
