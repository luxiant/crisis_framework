/-
관측층 — 의사결정 단위와 보유자 부문의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 수를 쓰지 않는다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-3(배제 사례의 조달처), D-8(witness 예외),
      T-2(반증 조건), T-4(가정의 명시).

**칸을 넷으로 가른다.** 주체가 어느 보유자 부문에 서는지와 수단마다 그 보유자 부문이 서는지와
그 주체의 결정 시계와 그 시계가 자산 만기를 덮는지가 전부 다른 공시에서 나오거나 어느 공시에서도
나오지 않으므로, 한 칸으로 두면 한쪽에 소스가 있는 것이 다른 쪽의 결손을 덮는다. **그 결손이 이
파일의 산출이다.**

**수단별 보유자의 소스 없음이 이 파일의 중심이다.** 보유자 부문을 색인하는 자료집합은 수단을
교섭가능성으로 넷으로만 가르고, 수단을 잘게 가르는 자료집합은 그 가운데 환매조건부와 채무증권
발행을 거래상대 배분에서 빼내므로, 두 구조가 상호 보완이 아니라 상호 배타다. **그래서 그 둘이
동시에 서는 경로가 없다는 것이 진술로 선다.**

**시계 적합의 소스 없음이 둘째 자리다.** 결정 시계의 측정 소스가 임원 보상 주기와 재임 기간이고
자산 만기의 측정 소스가 부채와 자산의 만기 구조인데, 그 둘을 한 주체에 대해 맞대는 공시가 없다.

**공시 경로는 비형식 개념에 대응하지 않는다.** 측정 사상을 담는 그릇이므로 형식화의 표현 수단이며
용어집의 선행 등록을 요구하지 않는다(D-7). 용어집에 서는 것은 그 경로가 측정하는 개념과 공시 자신
이고, 이 층의 구조는 그 둘을 잇는 명세다.

**주체의 타입을 매개변수로 받는다.** 금액을 드는 칸이 없으므로 이 파일에는 수 타입도 수치 리터럴도
없다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.DecisionUnit

open CrisisFramework.Definition

namespace CrisisFramework.Observation

/--
의사결정 단위와 보유자 부문의 공시 경로.

**대응 비형식 개념:** 어느 공시가 한 주체의 보유자 부문과 그 주체의 결정 시계를 내는가. 부문의
배정과 수단별 보유자와 결정 시계와 시계의 적합이 서로 다른 공시에서 나오므로 경로가 그 넷을 가르는
지를 칸으로 받는다.

**이 정의가 배제하는 사례:**
연결 기준 은행통계가 거래상대 배분을 요구하지 않는 항목을 드는 표. 그 표가 드는 항목에 환매조건부
채권과 역환매조건부채권과 단기 채무증권 발행과 장기 채무증권 발행이 들어 있어 그 넷에 전세계 연결
총계만 보고하게 하므로, 이 구조의 칸이 보는 것은 보유자 부문이어서 그 표로는 수단별 보유자의 칸이
채워지지 않는다.
조달처: E-55 §2-2 「그 표가 드는 항목에 환매조건부채권과 역환매조건부채권과 단기 채무증권 발행과 장기 채무증권」

**기각한 대체 정의:**
칸을 둘만 두어 부문과 시계를 각각 하나로 받는 안. 부문의 배정과 수단별 보유자가 소스가 다르고 그
가운데 배정만 부분적으로 읽히므로, 한 칸으로 두면 읽히는 몫이 읽히지 않는 쪽의 결손을 덮는다.
보유자 위임의 공시 경로가 위임의 배정과 가중과 보유분을 세 칸으로 가른 사유가 이 자리에 그대로
걸린다. 칸을 주체마다 받지 않고 경로 전체에 하나씩 두는 안도 기각했다. 부문의 배정이 주체에 따라
읽히는 정도가 다르고 거래상대로는 색인되면서 보고 주체로는 들지 않는 주체가 있으므로, 경로 전체에
하나로 두면 그 비대칭이 구조에서 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-2293
structure DecisionUnitChannel (Entity : Type) where
  /-- 그 주체가 어느 보유자 부문에 서는지를 이 경로가 보는가. -/
  coversSectorAssignment : Entity → Bool
  /-- 이 경로가 수단마다 그 수단의 보유자 부문을 내는가. 수단을 넷으로만 가른 분해는 이 칸을
      채우지 않는다. -/
  resolvesInstrumentHolder : Bool
  /-- 그 주체의 결정 시계를 이 경로가 보는가. -/
  coversDecisionHorizon : Entity → Bool
  /-- 이 경로가 결정 시계와 자산 만기를 맞대어 그 적합을 내는가. -/
  resolvesHorizonFit : Bool
  /-- 그 주체를 노드로 묶는 입도를 이 경로가 내는가. 법인과 지점을 가르는 분해가 이 칸을
      채운다. -/
  coversNodeGranularity : Entity → Bool
  /-- 이 경로가 그 입도를 결정의 경계로 내는가. 회계 단위의 경계를 내는 것으로는 이 칸이
      채워지지 않는다. -/
  resolvesDecisionBoundary : Bool

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `DecisionUnitChannel` 이 비어 있지 않음을 증거한다. 어느 주체도 보지 않고
여섯 칸을 하나도 내지 않는 경로다.
-/
-- DD:CF-2293
def DecisionUnitChannel.noSource {Entity : Type} : DecisionUnitChannel Entity where
  coversSectorAssignment := fun _ => false
  resolvesInstrumentHolder := false
  coversDecisionHorizon := fun _ => false
  resolvesHorizonFit := false
  coversNodeGranularity := fun _ => false
  resolvesDecisionBoundary := false

/--
소재지 기준 은행통계를 보유자 부문의 경로로 읽은 것.

**대응 비형식 개념:** 국제 기준의 보고 지침이 소재지 기준으로 걷는 통계가 금융자산과 부채를
거래상대 부문으로 배분하게 하는 것. 부채 쪽의 거래상대가 곧 보유자이므로 그 배분이 보유자 부문을
색인하며, 그 색인이 수단의 분해와 교차된다.

**이 정의가 배제하는 사례:**
비은행 금융기관의 하위 입도. 그 지침이 그 부문의 정의에서 금융중개에 부수하는 서비스와 활동을 주로
제공하는 은행 이외의 사적 또는 공적 금융기관으로 두고 특수목적기구와 헤지펀드와 증권중개업자와
머니마켓펀드 등 열 종류를 열거하면서도 그 전량에 코드 하나만 주며, 같은 지침의 다른 절이 국제수지
기준에서 그 부문이 일곱 하위부문으로 짜인다는 것과 자기 분해가 덜 잘다는 것을 함께 적는다. 그래서
이 경로는 그 부문 안의 쪼갬을 내지 못한다.
조달처: E-55 §2-1 「금융중개에 부수하는 서비스와 활동을 주로 제공하는 은행 이외의 사적 또는 공적 금융기관으로 두고」

**기각한 대체 정의:**
이 경로가 수단별 보유자를 낸다고 두는 안. 그 통계의 교차표가 수단을 대출과 예금과 채무증권과 파생
상품과 기타 수단 넷으로만 가르고 환매조건부와 자산유동화증권을 각각 대출과 예금의 예시와 채무증권의
예시로 두므로, 그 넷의 입도에서는 수단별 보유자가 서지 않는다. 이 경로가 결정 시계를 본다고 두는
안도 기각했다. 그 지침이 거래상대의 부문과 국가와 통화를 색인하고 보고 주체의 지배구조를 색인하지
않으므로 시계의 재료가 그 통계에 없다.

**값을 담지 않는다.**
-/
-- DD:CF-2294
def locationalBankingStatisticsChannel {Entity : Type} : DecisionUnitChannel Entity where
  coversSectorAssignment := fun _ => true
  resolvesInstrumentHolder := false
  coversDecisionHorizon := fun _ => false
  resolvesHorizonFit := false
  coversNodeGranularity := fun _ => true
  resolvesDecisionBoundary := false

/--
연결 기준 은행통계를 보유자 부문의 경로로 읽은 것.

**대응 비형식 개념:** 같은 보고 지침이 본국 기준으로 연결해 걷는 통계가 청구권을 거래상대 부문으로
배분하게 하는 것. 수단을 소재지 기준보다 잘게 가르되 그 가운데 여럿을 거래상대 배분에서 빼내므로
입도와 색인이 서로를 상쇄한다.

**이 정의가 배제하는 사례:**
보고 은행이 발행한 교섭가능 부채의 보유자. 그 지침이 보고 은행이 자기가 발행한 채무증권과 그 밖의
교섭가능 부채의 보유자를 식별하는 데 어려움을 겪을 수 있다고 적고 미배분 부문의 정의가 은행은 자기가
청구권을 갖는 거래상대를 알지만 자기 부채의 거래상대를 늘 알지는 못한다고 적으므로, 이 경로가 내는
부문은 청구권 쪽에 치우친다.
조달처: E-55 §2-2 「보고 은행이 자기가 발행한 채무증권과 그 밖의 교섭가능 부채의 보유자를 식별하는 데 어려움을」

**기각한 대체 정의:**
이 경로가 수단별 보유자를 낸다고 두는 안. 수단을 자산 일곱과 부채 여섯으로 가르는 것이 소재지
기준보다 잘되 환매조건부와 역환매조건부와 단기와 장기 채무증권 발행이 거래상대 배분을 받지 않는
항목에 들어 있으므로, 잘게 가른 바로 그 항목에서 보유자가 사라진다. 이 경로를 세우지 않고 소재지
기준 하나로 갈음하는 안도 기각했다. 두 자료집합이 중앙은행의 부문 배정을 서로 다르게 두고 그
어긋남을 지침이 자기 절로 명시하므로, 하나로 갈음하면 그 어긋남이 구조에서 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-2295
def consolidatedBankingStatisticsChannel {Entity : Type} : DecisionUnitChannel Entity where
  coversSectorAssignment := fun _ => true
  resolvesInstrumentHolder := false
  coversDecisionHorizon := fun _ => false
  resolvesHorizonFit := false
  coversNodeGranularity := fun _ => true
  resolvesDecisionBoundary := false

/--
규제 공시의 임원 보상 항목을 결정 시계의 경로로 읽은 것.

**대응 비형식 개념:** 결정 시계의 측정 소스로 든 임원 보상 주기와 재임 기간이 규제 공시에 서는
것. 그 축을 세운 편이 경영자의 시계가 자산 만기보다 짧다는 것을 모형의 전제로 두고 그 측정 소스를
그 둘로 들므로, 그 공시가 시계의 재료를 내는 경로가 된다.

**이 정의가 배제하는 사례:**
소득 수취자와 가구의 관계. 국제 기준의 편람이 소득은 개인이 벌고 소비는 가구가 하므로 소득 수취자로
서의 개인과 그가 속한 가구 사이에 자연스러운 관계가 없다고 적는데, 임원 보상 공시가 개인에게 지급된
보상의 주기를 들고 그 개인이 속한 결정 단위를 들지 않으므로 이 경로가 그 둘을 잇지 못한다.
조달처: E-54 §2-3 「소득 수취자로서의 개인과 그가 속한 가구 사이에 자연스러운 관계가 없다고 적는다」

**기각한 대체 정의:**
이 경로가 시계의 적합을 낸다고 두는 안. 적합은 시계와 자산 만기를 맞댄 결과이고 자산 만기의 측정
소스가 만기 구조의 보고이므로, 한 공시가 그 둘을 함께 내지 않는 한 적합이 서지 않는다. 이 경로가
보유자 부문을 본다고 두는 안도 기각했다. 임원 보상 공시가 보고 주체의 지배구조를 색인하고 그 주체가
드는 청구권의 보유자 부문을 색인하지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-2296
def executiveCompensationFilingChannel {Entity : Type} : DecisionUnitChannel Entity where
  coversSectorAssignment := fun _ => false
  resolvesInstrumentHolder := false
  coversDecisionHorizon := fun _ => true
  resolvesHorizonFit := false
  coversNodeGranularity := fun _ => false
  resolvesDecisionBoundary := false

/--
세 공시 경로 가운데 어느 것도 수단별 보유자와 시계의 적합을 내지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
보유자 부문을 색인하면서 수단을 교섭가능성보다 잘게 가르는 자료집합이 있어야 하거나, 결정 시계와
자산 만기를 한 주체에 대해 함께 내는 공시가 있어야 한다. 보유자 부문을 드는 자료집합이 수단을 넷으로
가르고 수단을 잘게 가르는 자료집합이 그 항목의 거래상대를 빼내며 임원 보상 공시가 자산 만기를 들지
않으므로, 이 명제가 거짓이면 그 세 자료 가운데 하나를 잘못 읽은 것이거나 넷째 자료가 있는 것이다.

**가정을 두지 않는다.**
-/
-- DD:CF-2297
theorem channels_resolve_neither_instrument_holder_nor_horizon_fit {Entity : Type} :
    (locationalBankingStatisticsChannel (Entity := Entity)).resolvesInstrumentHolder = false ∧
    (consolidatedBankingStatisticsChannel (Entity := Entity)).resolvesInstrumentHolder = false ∧
    (executiveCompensationFilingChannel (Entity := Entity)).resolvesInstrumentHolder = false ∧
    (locationalBankingStatisticsChannel (Entity := Entity)).resolvesHorizonFit = false ∧
    (consolidatedBankingStatisticsChannel (Entity := Entity)).resolvesHorizonFit = false ∧
    (executiveCompensationFilingChannel (Entity := Entity)).resolvesHorizonFit = false := by
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
부문을 보는 경로와 시계를 보는 경로가 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
한 공시가 보유자 부문과 결정 시계를 함께 내야 한다. 은행통계가 거래상대의 부문과 국가와 통화를
색인하고 보고 주체의 지배구조를 색인하지 않으며 임원 보상 공시가 그 역이므로, 이 명제가 거짓이면
그 두 공시 가운데 하나가 다른 쪽의 색인을 함께 든 것이다.

**가정을 두지 않는다.**
-/
-- DD:CF-2297
theorem sector_and_horizon_channels_are_disjoint {Entity : Type} (e : Entity) :
    (locationalBankingStatisticsChannel (Entity := Entity)).coversSectorAssignment e = true ∧
    (locationalBankingStatisticsChannel (Entity := Entity)).coversDecisionHorizon e = false ∧
    (executiveCompensationFilingChannel (Entity := Entity)).coversSectorAssignment e = false ∧
    (executiveCompensationFilingChannel (Entity := Entity)).coversDecisionHorizon e = true := by
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
세 공시 경로 가운데 어느 것도 주체를 노드로 묶는 입도를 결정의 경계로 내지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
결정이 하나로 내려지는 단위를 공시에서 읽어 내는 자료집합이 있어야 한다. 두 은행통계가 법인과
지점을 가르는 입도를 내되 그 가름이 소재지와 본국이라는 회계 단위의 경계에서 오고, 같은 청구권이
어느 기준으로 세느냐에 따라 다른 나라에 귀속된다는 것이 그 두 경로가 서로 다른 답을 낸다는 뜻이므로,
이 명제가 거짓이면 그 두 자료 가운데 하나가 결정의 경계를 따로 드는 항목을 가진 것이다.

**이 자리가 소스 없음의 등재다(L-14).** 주체를 노드로 묶는 입도가 정의층에 서 있고 그 입도를
결정의 경계로 재는 경로가 관측층에 서지 않는다는 것이 이 진술로 기록된다.

**T-3 분류:** 기여다. 두 칸의 값이 어느 경로에서 갈리는지를 고정하는 자리이고, 입도를 내는 것과
결정의 경계를 내는 것이 다르다는 가름이 정의를 전개하기만 해서는 서지 않으므로 기여 목록에 든다.

**가정을 두지 않는다.**
-/
-- DD:CF-3700
theorem no_channel_resolves_decision_boundary {Entity : Type} (e : Entity) :
    (locationalBankingStatisticsChannel (Entity := Entity)).coversNodeGranularity e = true ∧
    (consolidatedBankingStatisticsChannel (Entity := Entity)).coversNodeGranularity e = true ∧
    (locationalBankingStatisticsChannel (Entity := Entity)).resolvesDecisionBoundary = false ∧
    (consolidatedBankingStatisticsChannel (Entity := Entity)).resolvesDecisionBoundary = false ∧
    (executiveCompensationFilingChannel (Entity := Entity)).resolvesDecisionBoundary = false := by
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Observation
