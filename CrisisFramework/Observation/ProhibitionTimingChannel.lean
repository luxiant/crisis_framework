/-
관측층 — 금지의 시점이 어느 공표 꼴에서 읽히는가

규율: L-14(값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), A-3(witness), T-2(반증 조건), T-3(분류).

**값을 담지 않는다.** 이 파일은 시점의 물음마다 그 물음이 관측으로 답해지는지의 명세만 담고 수를
담지 않는다.

**명세를 발행 주체가 아니라 공표 꼴로 색인한다.** 같은 발행 주체가 내는 두 꼴 가운데 앞의 것에 시점
칸이 없고 뒤의 것에 사건마다 날짜가 필수로 서므로, 발행 주체 하나에 사상 하나를 두면 그 갈림이
사라진다. 발행 주체의 축은 그 색인의 원소가 어느 발행 주체의 것인가로 서고 구조가 그 귀속을 강제하지
않는다.

**물음을 칸으로 두고 사상으로 두지 않는다.** 칸을 물음의 열거에서 참거짓으로 가는 함수로 두면 그
함수의 본문이 열거 위의 분기로 서고, 이 층의 공리 기준선이 공리 없음인데 그 분기가 명제 외연성을
끌어온다. 앞 페이즈의 명세가 물음을 칸으로 둔 것이 선례이며, 그 꼴에서는 증명이 상수 위의 계산으로
닫힌다.

**조달된 기록이 묻지 않은 물음을 비운 칸으로 든다.** 꼴마다 답하는 물음이 다르므로 나머지에 판정을
채우면 재지 않은 값을 적는 것이 되고, 재지 않았음을 적는 것과 문면상 구별되지 않는다. 비운 칸과 측정
소스가 없다는 판정은 해소 경로가 다르다. 앞은 다른 문면을 읽어 풀리고 뒤는 자료의 조달로 풀리거나
끝까지 남는다.

**계약의 체결 시점에는 소스가 없다고 적는다.** 조달된 두 기록이 공표하는 것이 제재의 문면과 그
목록이고 어느 쪽도 사인 사이의 계약이 언제 맺어졌는지를 내지 않으므로, 그 물음은 그 기록이 묻지 않은
것이 아니라 그 경로가 답할 수 없는 것이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

/--
시점을 싣는 공표의 꼴.

**대응 비형식 개념:** 제재의 시점이 읽히는 공표물의 종류. 같은 발행 주체가 둘 이상의 꼴로 내고 꼴마다
싣는 칸이 달라, 어느 꼴을 읽었는가가 답을 가른다.

**이 정의가 배제하는 사례:**
공표를 발행 주체로 색인하는 읽기. 고정 길이와 쉼표 구분의 주 표에 시점 칸이 없고 같은 주체가 내는
진보된 스키마에는 사건마다 날짜가 필수로 서므로, 주체로 색인하면 한 주체에 두 답이 서서 그 가운데
하나가 버려진다.
조달처: E-69 §4-1 「같은 발행 주체 안에서 꼴마다 답이 갈린다」

**기각한 대체 정의:**
꼴을 자유 문자열로 받는 안. 그러면 꼴의 수가 바뀔 때 구조가 조용히 넓어지고 명세가 열거 위의 계산으로
닫히지 않는다. 꼴을 공표물의 파일 형식으로 가르는 안도 기각했다. 같은 형식이 다른 칸을 싣고 다른
형식이 같은 칸을 실을 수 있으므로 형식이 답을 가르는 축이 아니다.

**값을 담지 않는다.** 세 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4348
inductive TimingPublicationForm where
  /-- 고정 길이와 쉼표로 가른 목록의 주 표. -/
  | flatListing
  /-- 제재 항마다 사건과 조치와 기간을 요소로 두는 스키마. -/
  | structuredSchema
  /-- 금지를 세우는 조문이 딸린 부속서의 표. -/
  | statuteAnnexTable
  deriving DecidableEq, Repr

/--
시점의 물음마다의 관측 명세.

**대응 비형식 개념:** 금지가 언제부터 어디까지 누구에게 걸리는지를 판정하려면 읽는 쪽이 알아야 하는
값들이 그 공표 꼴에서 관측되는가. 발효와 종료와 눈금과 조치 갈래와 그 시점의 대상이 시점 판정의 다섯
입력이고, 계약의 체결 시점이 유예 판정의 입력이다.

**이 정의가 배제하는 사례:**
발효와 종료를 한 물음으로 접는 읽기. 그 스키마가 제재 항의 타입 아래에 조치 요소를 최소 하나로 두고
요소마다 기간을 필수 자식으로 들면서 그 기간의 시작과 끝을 선택 자식으로 두므로, 접으면 시작만 실린
항과 둘 다 실린 항이 한 값으로 나온다.
조달처: E-69 §3-2 「한 주체에 걸린 금지가 하나가 아니라 갈래마다 다른 기간으로 설 수」

**기각한 대체 정의:**
눈금의 물음을 빼고 발효의 물음에 접는 안. 그 공표 꼴이 연과 월과 일의 고정 여부를 기간 요소의 필수
속성으로 따로 두므로, 접으면 시점이 실렸다는 것과 그 시점이 하루까지 고정되었다는 것이 한 값이 된다.
계약의 체결 시점을 칸에서 빼는 안도 기각했다. 이 페이즈가 세운 정의층 대상마다 관측층에 대응하는
명세를 두라는 요구가 그 여섯을 함께 들게 하며, 빼면 그 결손이 어디에도 적히지 않는다.

**값을 담지 않는다.** 여섯 칸이 판정의 선택이며 수를 들지 않는다.
-/
-- DD:CF-4348
structure ProhibitionTimingSourceSpec where
  /-- 그 금지가 언제부터 걸리는지가 관측되는가. -/
  effectiveTiming : Option ObservedTruth
  /-- 그 금지가 언제 풀리는지가 관측되는가. -/
  terminationTiming : Option ObservedTruth
  /-- 그 시점이 어느 눈금까지 고정되는지가 관측되는가. -/
  timeGranularity : Option ObservedTruth
  /-- 그 시점이 어느 조치 갈래의 것인지가 관측되는가. -/
  measureKind : Option ObservedTruth
  /-- 그 시점에 어느 대상이 걸리는지가 관측되는가. -/
  scopeAtTime : Option ObservedTruth
  /-- 그 거래가 딛는 계약이 언제 맺어졌는지가 관측되는가. -/
  contractConclusion : Option ObservedTruth

/-- witness (A-3). **무엇을 증거하는가.** `ProhibitionTimingSourceSpec` 이 비어 있지 않다. 어느
물음에도 판정이 서지 않은 명세 하나를 든다. -/
-- DD:CF-31
def ProhibitionTimingSourceSpec.unasked : ProhibitionTimingSourceSpec where
  effectiveTiming := none
  terminationTiming := none
  timeGranularity := none
  measureKind := none
  scopeAtTime := none
  contractConclusion := none

/-- **무엇을 증거하는가.** 조달된 기록에서 유도한 명세다. 목록의 주 표에는 발효 시점을 드는 칸이
없으므로 그 물음을 측정 소스 없음으로 든다. 사건과 조치와 기간을 요소로 두는 스키마의 공표 실물에서는 항의
생성 사건이 날짜를 일까지 들고 조치마다 갈래가 서므로 발효와 눈금과 조치 갈래를 선 것으로 들고, 사건
갈래가 생성 하나뿐이고 조치의 기간이 비어 있어 해제가 한 판에서 관측되지 않으므로 종료를 측정 소스
없음으로 든다(E-84). 조문의 부속서 표에는 발효 시점의 칸과 두 날에 걸리는 대상이 서므로 그 둘을 선 것으로
든다. 어느 꼴도 묻지 않는 물음은 비우고, 계약의 체결 시점은 모든 꼴에서 측정 소스 없음으로 든다. -/
-- DD:CF-4348
def prohibitionTimingSpec : TimingPublicationForm → ProhibitionTimingSourceSpec
  | .flatListing =>
      { effectiveTiming := some (.undetermined .noMeasurementSource),
        terminationTiming := none,
        timeGranularity := none,
        measureKind := none,
        scopeAtTime := none,
        contractConclusion := some (.undetermined .noMeasurementSource) }
  | .structuredSchema =>
      { effectiveTiming := some .holds,
        terminationTiming := some (.undetermined .noMeasurementSource),
        timeGranularity := some .holds,
        measureKind := some .holds,
        scopeAtTime := none,
        contractConclusion := some (.undetermined .noMeasurementSource) }
  | .statuteAnnexTable =>
      { effectiveTiming := some .holds,
        terminationTiming := none,
        timeGranularity := none,
        measureKind := none,
        scopeAtTime := some .holds,
        contractConclusion := some (.undetermined .noMeasurementSource) }

/--
같은 발효의 물음에 꼴마다 다른 답이 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
같은 발행 주체가 내는 두 꼴이 발효의 물음에 같은 답을 내야 한다. 그 관측은 명세를 발행 주체로 색인해도
잃는 것이 없다는 뜻이며, 그러면 이 파일이 색인을 공표 꼴로 둔 까닭이 사라지고 한 주체에 사상 하나를
두는 꼴로 돌아간다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 명세의 색인이 발행 주체가 아니라 공표 꼴이어야 한다는 것을 구조 안의 명제로
드는 유일한 자리이고, 그 명제가 없으면 색인을 꼴로 둔 것이 이름만 다른 둘이 된다.
-/
-- DD:CF-4348
theorem forms_split_effective_timing :
    (prohibitionTimingSpec .flatListing).effectiveTiming
        = some (.undetermined .noMeasurementSource) ∧
      (prohibitionTimingSpec .structuredSchema).effectiveTiming = some .holds := by
  -- 명세가 상수이므로 두 칸이 전개만으로 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl⟩

/--
계약의 체결 시점에는 어느 꼴에도 측정 소스가 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
세 꼴 가운데 하나라도 그 거래가 딛는 계약이 언제 맺어졌는지를 내야 한다. 그 관측은 제재를 공표하는
경로가 사인 사이의 계약을 함께 낸다는 뜻이며, 그러면 유예의 판정이 그 경로 하나로 닫히고 이 파일의
산출이 사라진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 유예의 판정이 받는 두 축 가운데 하나에 측정 소스가 없다는 것을 구조 안의
명제로 드는 유일한 자리이고, 그 결손이 이 페이즈의 산출이다.
-/
-- DD:CF-4348
theorem contract_conclusion_has_no_measurement_source :
    (prohibitionTimingSpec .flatListing).contractConclusion
        = some (.undetermined .noMeasurementSource) ∧
      (prohibitionTimingSpec .structuredSchema).contractConclusion
        = some (.undetermined .noMeasurementSource) ∧
      (prohibitionTimingSpec .statuteAnnexTable).contractConclusion
        = some (.undetermined .noMeasurementSource) := by
  -- 명세가 상수이므로 세 칸이 전개만으로 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl⟩

end CrisisFramework.Observation
