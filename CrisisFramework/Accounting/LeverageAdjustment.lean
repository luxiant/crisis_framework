/-
회계층 — 레버리지 조정 모드의 판정과 자본 체제로 잰 금액

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ` 이고 비율을 교차곱으로 쓴다), C-9(전면 `simp` 금지),
      A-6(기준선 차분), T-2(반증 조건), T-4(가정의 명시).

**수 체계: `ℤ`.** 세 성분과 자산 총액이 전부 최소 화폐단위의 정수배다.

**정의층의 두 열거를 받아 그 위에 수를 얹는다.** 조정 모드와 자본 체제가 수를 쓰지 않아 정의층에
서고, 어느 성분이 고정됐는지를 가리는 판정과 체제로 잰 금액이 두 시점의 성분을 수로 맞대므로 이 층에
선다.

**비율을 쓰지 않고 교차곱으로 쓴다.** 레버리지가 자산을 자본으로 나눈 값이므로 두 레버리지의 비교를
총자산과 두 자본의 곱으로 바꾸어 나눗셈을 없앤다. 원 문헌의 원시 조건이 이미 곱셈 부등식이므로 이것이
형식화 편의가 아니라 대상의 성질이다.

**모드 판정이 선택을 낸다.** 고정된 성분이 없거나 둘 이상이면 어느 모드도 아니므로 값을 갖지 않으며,
그것이 전제 밖의 두 자리를 구조가 거부하지 않고 담아 내는 방식이다. 그 두 자리가 형식층에 담기지
않는 것은 구멍으로 등재되어 있다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Int.Notation
import CrisisFramework.Definition.LeverageAdjustment

open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
두 시점의 세 성분으로 가린 장부 레버리지 조정 모드.

**대응 비형식 개념:** 자산과 부채와 자기자본 가운데 무엇이 두 시점 사이에 고정됐는가. 원전이 한
그림에서 세 모드를 가르고 그 셋이 항등식의 세 성분 가운데 하나를 고정하는 것이므로, 두 시점의 세
성분을 맞대면 어느 모드인지가 정해진다.

**이 정의가 배제하는 사례:**
상업은행의 레버리지 고정. 레버리지 대 자산의 기울기가 영에 가까워 수직선으로 서고 레버리지 자체를
고정하는 것이므로, 세 성분 가운데 무엇이 고정됐는가로는 그 행태가 가려지지 않는다. 같은 그림에서
가계와 비금융기업과 증권 브로커딜러가 세 모드에 대응하는 데 비해 상업은행만 대응물을 갖지
않는다(Adrian and Shin 2008). 이 판정은 그 자리에서 값을 갖지 않는다.
조달처: E-02 §2-1 「상업은행의 수직선(레버리지 고정)은 E-01의 3모드 분류에 대응물이 없는 네 번째 행태다」

**기각한 대체 정의:**
고정된 성분이 둘 이상일 때 그 가운데 하나를 고르는 안. 두 성분이 함께 고정되면 항등식으로 셋째도
고정되어 레버리지가 움직이지 않으므로 그것이 조정이 아니며, 하나를 고르면 조정이 아닌 자리에 모드가
붙는다. 세 성분을 받지 않고 자산과 자기자본만 받는 안도 기각했다. 부채 고정 모드가 그 둘만으로는
가려지지 않고 항등식으로 유도하면 부채의 변화가 영인지를 다시 재야 한다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 선택이고 그 안의 열거가 `DecidableEq` 를 가지므로
판정이 그 타입에서 나오고 인스턴스를 선언할 자리가 없다.
-/
-- DD:CF-1890
def leverageAdjustmentModeOf (asset₁ liability₁ equity₁ asset₂ liability₂ equity₂ : ℤ) :
    Option BookLeverageAdjustmentMode :=
  if asset₁ = asset₂ ∧ liability₁ ≠ liability₂ ∧ equity₁ ≠ equity₂ then
    some BookLeverageAdjustmentMode.assetFixed
  else if liability₁ = liability₂ ∧ asset₁ ≠ asset₂ ∧ equity₁ ≠ equity₂ then
    some BookLeverageAdjustmentMode.liabilityFixed
  else if equity₁ = equity₂ ∧ asset₁ ≠ asset₂ ∧ liability₁ ≠ liability₂ then
    some BookLeverageAdjustmentMode.equityFixed
  else
    none

/--
자본 체제로 잰 장부자본의 금액.

**대응 비형식 개념:** 레버리지의 분모인 자본을 그 체제가 정한 범위까지 센 금액. 보통주와 우선주와
후순위채 셋을 받아 체제가 고르는 만큼을 더한다.

**이 정의가 배제하는 사례:**
감독 규범의 기본자본 비율과 총자본 비율. 그 둘의 분모가 위험가중자산이어서 레버리지의 분모인
총자산과 다르고 회계 계열의 어느 자리에 놓이는지가 어느 원편에도 서지 않는다(Hahm · Mishkin ·
Shin · Shin 2010). 이 금액은 회계 계열만 담으며, 그 둘이 이 사슬에 드는지는 구멍으로 등재되어 있다.
조달처: E-52 §2-2 「원문의 표가 규제 계열의 자본 비율을 기본자본 비율과 총자본 비율 둘로 나란히 든다」

**기각한 대체 정의:**
체제마다 따로 선언을 두는 안. 셋이 중첩 사슬이어서 뒤의 것이 앞의 것에 항을 더한 값이므로, 따로
두면 그 중첩이 세 선언 사이의 관계가 되어 구조에서 사라진다. 자본을 한 값으로 받아 체제를 쓰지 않는
안도 기각했다. 체제의 선택이 두 시점 사이의 변화 방향을 뒤집는 것이 이 페이즈의 산출이므로 그 선택이
인자로 서야 한다.

**세 성분을 받고 합을 받지 않는다.** 합을 받으면 체제가 범위를 고를 재료가 사라지며, 세 성분이
공시의 다른 줄에서 읽히는 것이 그 재료가 실재하는 근거다.
-/
-- DD:CF-1894
def bookCapitalOf (common preferred subordinated : ℤ) : BookCapitalRegime → ℤ
  | BookCapitalRegime.commonShare => common
  | BookCapitalRegime.shareholder => common + preferred
  | BookCapitalRegime.subordinatedInclusive => common + preferred + subordinated

/--
자본 체제의 선택이 두 시점 사이의 레버리지 변화 방향을 뒤집는 배치가 존재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 어떤 배치에서도 주주자본으로 잰 레버리지가
오르면 후순위 포함 자본으로 잰 레버리지도 오르는 것. 그러려면 후순위채의 변화가 자본의 변화에 비례
해야 하는데, 구조가 세 성분을 독립한 인자로 두므로 그런 강제가 없다. 원전이 후순위채를 자본으로
세면 그 해에 레버리지가 내려가고 주주자본으로만 보면 같은 해에 계속 올랐다고 적는 것이 실제로
관측된 사례다(Shin 2009).

**가정과 그 배제 사례(T-4·T-5):** 가정을 두지 않는다. 존재 진술이므로 배치 하나를 세우면 서고,
그 배치가 현실에서 일어났다는 것은 위의 사례가 든다. 양의 자본은 가정이 아니라 존재 진술의 항으로
들어가며, 그래야 교차곱이 레버리지의 비교를 옳게 옮긴다.

**교차곱이 나눗셈을 없앤다.** 자산을 자본으로 나눈 값의 비교를 자산과 두 자본의 곱으로 바꾸므로
`ℤ` 안에서 닫히고 `ℚ` 가 강제되지 않는다. 두 자본이 양이라는 항이 그 변환을 받친다.

**이 진술이 측정 체제의 선택이 실물 판정을 바꾸는 자리다.** 그 선택의 주체가 은행이며, 어느 값이
공시에 서는지가 발행 시점이 아니라 자본 계열에 넣는 시점으로 정해진다는 것이 그 뜻이다.
-/
-- DD:CF-1894
theorem exists_bookCapitalRegime_reverses_leverageDirection :
    ∃ common₁ preferred₁ subordinated₁ asset₁
      common₂ preferred₂ subordinated₂ asset₂ : ℤ,
      0 < bookCapitalOf common₁ preferred₁ subordinated₁ BookCapitalRegime.shareholder
      ∧ 0 < bookCapitalOf common₂ preferred₂ subordinated₂ BookCapitalRegime.shareholder
      ∧ 0 < bookCapitalOf common₁ preferred₁ subordinated₁
              BookCapitalRegime.subordinatedInclusive
      ∧ 0 < bookCapitalOf common₂ preferred₂ subordinated₂
              BookCapitalRegime.subordinatedInclusive
      ∧ asset₁ * bookCapitalOf common₂ preferred₂ subordinated₂
                   BookCapitalRegime.shareholder
          < asset₂ * bookCapitalOf common₁ preferred₁ subordinated₁
                       BookCapitalRegime.shareholder
      ∧ asset₂ * bookCapitalOf common₁ preferred₁ subordinated₁
                   BookCapitalRegime.subordinatedInclusive
          < asset₁ * bookCapitalOf common₂ preferred₂ subordinated₂
                       BookCapitalRegime.subordinatedInclusive := by
  -- 주주자본이 두 시점에 같고 후순위채만 늘며 자산이 두 배가 되는 배치다. 주주자본으로 잰
  -- 레버리지는 오르고 후순위 포함 자본으로 잰 레버리지는 내린다. 여섯 부등식이 전부 정수 리터럴의
  -- 비교이므로 커널 평가로 닫고 전면 `simp` 를 쓰지 않는다.
  exact ⟨10, 0, 0, 100, 10, 0, 20, 200, by decide⟩

end CrisisFramework.Accounting
