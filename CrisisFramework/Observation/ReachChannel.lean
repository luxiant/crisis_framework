/-
관측층 — 금지의 번짐과 주체의 식별이 읽히는 자리

규율: L-14(값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), A-3(witness), T-2(반증 조건), T-3(분류).

**값을 담지 않는다.** 이 파일은 번짐과 식별의 물음마다 그 물음이 관측으로 답해지는지의 명세만 담고
수를 담지 않는다.

**물음을 칸으로 두고 사상으로 두지 않는다.** 칸을 물음의 열거에서 참거짓으로 가는 함수로 두면 그 함수의
본문이 열거 위의 분기로 서고, 이 층의 공리 기준선이 공리 없음인데 그 분기가 명제 외연성을 끌어온다.
앞 페이즈의 경로 구조가 물음을 칸으로 둔 것이 선례이며, 그 꼴에서는 증명이 상수 위의 계산으로 닫힌다.

**조달된 기록이 묻지 않은 물음을 비운 칸으로 든다.** 그 기록이 세 물음에만 답하므로 나머지에 판정을
채우면 재지 않은 값을 적는 것이 되고, 재지 않았음을 적는 것과 문면상 구별되지 않는다. 비운 칸과 측정
소스가 없다는 판정은 해소 경로가 다르다. 앞은 다른 문면을 읽어 풀리고 뒤는 자료의 조달로 풀리거나 끝까지
남는다.

**판정 불가의 까닭을 세분하지 않고 이미 선 열거에서 고른다.** 대리와 지시의 관계는 재야 할 것이
정해졌으나 그것을 내는 자리가 없는 부류이고, 이름과 주소는 재야 할 것이 정해졌고 자료가 있어도 그 값이
하나로 정해지지 않는 부류이므로, 그 둘이 그 열거의 두 칸에 그대로 든다.

**관측자를 칸으로 두지 않는다.** 어느 관측자에게 없는가는 경로의 수신자 칸이 드는 것인데, 조달된 기록이
이 여섯 물음을 경로별로 가르지 않으므로 그 칸을 두면 그 값을 지어내게 된다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

/--
번짐과 식별의 물음마다의 관측 명세.

**대응 비형식 개념:** 금지의 번짐을 판정하려면 읽는 쪽이 알아야 하는 값들이 관측으로 답해지는가.
지분의 몫과 설립지와 대리의 관계가 번짐의 세 입력이고 이름과 주소가 주체를 집는 두 축이며, 간선의
열거가 간접 소유를 읽는 입력이다. 조달된 기록이 그 물음을 묻지 않았으면 그 칸이 빈다.

**이 정의가 배제하는 사례:**
물음을 하나로 접는 읽기. 조문이 소유의 조건과 설립지의 조건과 행위의 관계를 다른 항에 두고 그 가운데
행위의 관계만 소유 공시가 내지 않으므로, 접으면 어느 물음에 소스가 없는지가 그 값에서 사라진다.
조달처: E-68 §3-3 「행위로 재어지는 경로는 지분의 공시에서 나오지 않으므로」

**기각한 대체 정의:**
비운 칸을 두지 않고 판정 불가의 까닭에 묻지 않음을 더하는 안. 그 열거의 칸을 가른 근거가 해소 경로이고
묻지 않음은 다른 문면을 읽어 풀리는데 그 열거의 어느 칸도 그 경로를 들지 않으므로, 더하면 그 근거가
그 자리에서 무너진다. 묻지 않은 물음을 칸에서 빼는 안도 기각했다. 이 페이즈가 세운 정의층 대상마다
관측층에 대응하는 명세를 두라는 요구가 그 여섯을 함께 들게 하며, 빼면 그 결손이 어디에도 적히지 않는다.

**값을 담지 않는다.** 여섯 칸이 판정의 선택이며 수를 들지 않는다.
-/
-- DD:CF-4299
structure ReachSourceSpec where
  /-- 한 주체가 다른 주체에 둔 지분의 몫이 관측되는가. -/
  stakeShare : Option ObservedTruth
  /-- 그 주체가 어디에 설립되어 있는지가 관측되는가. -/
  establishment : Option ObservedTruth
  /-- 그 주체가 누구를 대신하여 또는 누구의 지시에 따라 행동하는지가 관측되는가. -/
  conduct : Option ObservedTruth
  /-- 그 주체의 다른 이름이 관측되는가. -/
  altName : Option ObservedTruth
  /-- 그 주체의 주소가 관측되는가. -/
  address : Option ObservedTruth
  /-- 간접 소유로 읽을 간선의 열이 관측되는가. -/
  chainEnumeration : Option ObservedTruth

/-- witness (A-3). **무엇을 증거하는가.** `ReachSourceSpec` 이 비어 있지 않다. 어느 물음에도 판정이
서지 않은 명세 하나를 든다. -/
-- DD:CF-31
def ReachSourceSpec.unasked : ReachSourceSpec where
  stakeShare := none
  establishment := none
  conduct := none
  altName := none
  address := none
  chainEnumeration := none

/-- **무엇을 증거하는가.** 조달된 기록에서 유도한 명세다. 대리와 지시의 관계를 측정 소스가 없는 것으로
들고 이름과 주소를 귀속이 유일하지 않은 것으로 들며, 나머지 세 물음은 그 기록이 묻지 않으므로 비운다. -/
-- DD:CF-4300
def sanctionReachSpec : ReachSourceSpec where
  stakeShare := none
  establishment := none
  conduct := some (.undetermined .noMeasurementSource)
  altName := some (.undetermined .attributionNotUnique)
  address := some (.undetermined .attributionNotUnique)
  chainEnumeration := none

/--
대리와 지시의 관계에 측정 소스가 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 관계의 값을 내는 공표 경로가 있어야 한다. 그 관측은 행위로 재어지는 경로가 공시에서 나온다는 뜻이며,
그러면 번짐의 셋째 갈래가 읽는 쪽의 계산으로 닫히고 이 파일의 산출이 사라진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 조문이 셋째 갈래로 든 관계에 측정 소스가 없다는 것을 구조 안의 명제로 드는
유일한 자리이고, 그 결손이 이 페이즈의 산출이다.
-/
-- DD:CF-4300
theorem conduct_has_no_measurement_source :
    sanctionReachSpec.conduct = some (.undetermined .noMeasurementSource) := by
  -- 명세가 상수이므로 그 칸이 전개만으로 나와 `rfl` 로 닫힌다.
  rfl

/--
식별의 두 축은 자료가 있어도 귀속이 유일하지 않다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 축 가운데 하나라도 그 값이 한 주체에 하나로 정해져야 한다. 그 관측은 식별이 공표에서 단일하게
집힌다는 뜻이며, 그러면 정의층이 식별을 색인된 집합으로 둔 꼴이 쓰이지 않은 채 남는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 소스가 있으면서 귀속이 유일하지 않은 자리를 드는 유일한 자리이고, 그 자리가
소스가 없는 자리와 다른 부류라는 것이 이 파일이 까닭을 가려 든 까닭이다.
-/
-- DD:CF-4300
theorem identity_axes_attribution_not_unique :
    sanctionReachSpec.altName = some (.undetermined .attributionNotUnique) ∧
      sanctionReachSpec.address = some (.undetermined .attributionNotUnique) := by
  -- 명세가 상수이므로 두 칸이 전개만으로 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl⟩

/--
세 물음은 조달된 기록이 묻지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 기록이 지분의 몫이나 설립지나 간선의 열거가 관측되는지를 답해야 한다. 그 관측은 이 명세의 비운 칸이
실제로는 채워진다는 뜻이며, 그러면 그 세 물음이 다음 읽기가 찾아야 할 목록에서 빠진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 기록이 묻지 않은 물음을 전수로 드는 유일한 자리이고, 그 목록이 다음 읽기가
무엇을 찾아야 하는지를 정한다.
-/
-- DD:CF-4300
theorem three_questions_unasked :
    sanctionReachSpec.stakeShare = none ∧
      sanctionReachSpec.establishment = none ∧
      sanctionReachSpec.chainEnumeration = none := by
  -- 명세가 상수이므로 세 칸이 전개만으로 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl⟩

/--
묻지 않은 칸과 소스가 없다는 판정이 같은 값이 아니다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
비운 칸과 측정 소스가 없다는 판정이 같은 값이어야 한다. 그 관측은 두 결손의 해소 경로가 하나라는
뜻이며, 그러면 칸을 선택으로 둔 꼴이 까닭의 열거에 칸을 더하는 것과 같아진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 묻지 않은 칸과 측정 소스가 없다는 판정이 같은 값이 아니라는 것을 구조 안의
명제로 드는 유일한 자리이고, 그 다름이 없으면 칸을 선택으로 둔 꼴이 까닭의 열거에 칸을 더하는 것과
같아진다. 전개만으로 증명이 닫히는 것이 그 분류를 가르지 않으며, 이 진술이 정의의 전개를 넘어
드는 몫이 그 다름을 구조 안의 명제로 세우는 것이다.
-/
-- DD:CF-4299
theorem unasked_differs_from_no_source :
    sanctionReachSpec.stakeShare ≠ sanctionReachSpec.conduct := by
  -- 앞 칸이 `none` 이고 뒤 칸이 `some` 이어서 두 생성자가 다르므로, 같다는 가정을 생성자로
  -- 가르면 맞는 경우가 하나도 남지 않는다.
  intro h
  cases h

end CrisisFramework.Observation
