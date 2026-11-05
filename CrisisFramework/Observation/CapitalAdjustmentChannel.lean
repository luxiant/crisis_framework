/-
관측층 — 자본 조정의 측정 사상

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원),
      L-9(import 방향은 단방향), A-3(witness 의무), D-1·D-2(docstring 3항목),
      D-5(오염 어간에 한정어를 붙인다), D-8(witness 의 서술), T-2(반증 조건),
      T-3(기여 분류), T-4(가정의 명시).

이 파일은 수를 한 번도 쓰지 않고 금액도 담지 않는다. 각 경로가 어느 칸을 내는가만 `Bool` 로 들며,
금액의 수 체계는 회계층이 정한다.

**이 파일이 세우는 것은 자본 조정이 공표 수치에서 어떻게 관측되는가 또는 관측되지 않는가다.**
회계층이 조정의 사상을 세우고 그 사상이 체제와 출발 자본과 항목별 금액 셋을 받는데, 그 셋을 외부
관측자가 어디에서 읽는지가 이 파일의 물음이다.

**세 경로가 전부 어느 칸도 내지 못하는 것이 이 파일의 산출이다.** 관측층에 등재되는 소스 없음이
프레임워크의 주요 산출물 가운데 하나이므로, 그 거짓이 결손의 기록이고 결함의 기록이 아니다.

**경로를 셋으로 가른 사유가 결손의 자리가 다르다는 것이다.** 감독 지침의 대조 요구는 그 대조가
서게 하면서 수취인을 감독 당국으로 두고, 감독 규범의 조정 장은 규칙을 정하면서 금액을 공시하게
하지 않으며, 발행자의 재무제표는 요건을 위험 요인의 산문으로만 적는다. 한 경로로 묶으면 한 결손이
다른 결손을 덮는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.CapitalAdjustment

namespace CrisisFramework.Observation

open CrisisFramework.Definition

/--
자본 조정을 읽는 공시 경로.

**대응 비형식 개념:** 어떤 공시가 자본 조정의 재료를 내는가. 조정의 사상이 체제와 출발 자본과
항목별 금액을 받으므로, 그 셋을 내는지가 경로마다 갈린다.

**이 정의가 배제하는 사례:**
한 공시가 어떤 항목은 내고 다른 항목은 내지 않는 자리. 감독 규범이 조정 항목을 열거하면서 항목마다
공시의 요구를 달리 두는데, 이 구조는 항목별 금액을 내는가를 한 칸으로 두므로 그 갈림을 담지
못한다. 항목을 정의역으로 받는 칸으로 두는 길이 열려 있으나 그 가름이 공시 서식을 열어야 서고 이
회차가 그 서식을 열지 않았다(바젤은행감독위원회).
조달처: E-56 §8-2 「그 장이 공제 항목을 절 제목으로 하나씩 들고 각 절이 그 금액을 정하는 규칙을 둔다」

**기각한 대체 정의:**
칸을 둘로 두고 체제의 선택을 금액의 칸에 흡수하는 안. 체제의 선택이 서지 않으면 같은 금액에서
다른 값이 나오므로 그 둘이 다른 물음이며, 조정의 사상이 재량을 받는다는 것이 이 아크의 산출이어서
그 칸을 지우면 그 산출이 관측층에서 사라진다. 그리고 대조의 칸을 지우고 금액과 체제 둘로 닫는
안도 기각했다. 감독 지침이 두 자본 사이의 대조를 따로 요구하므로 그 요구의 충족이 금액과 체제의
공시와 다른 사건이다.

**값을 담지 않는다.**
-/
-- DD:CF-2572
structure CapitalAdjustmentChannel (Entity : Type) where
  /-- 그 주체의 조정 항목별 금액을 이 경로가 내는가. -/
  resolvesItemAmount : Entity → Bool
  /-- 그 주체가 어느 조정 체제를 썼는지를 이 경로가 내는가. -/
  resolvesRegimeChoice : Entity → Bool
  /-- 두 자본 개념 사이의 대조를 이 경로가 외부 관측자에게 내는가. -/
  resolvesReconciliation : Bool

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `CapitalAdjustmentChannel` 이 비어 있지 않음을 보인다. 어느 주체도 보지
않고 세 칸을 하나도 내지 않는 경로다.
-/
-- DD:CF-2572
def CapitalAdjustmentChannel.noSource {Entity : Type} : CapitalAdjustmentChannel Entity where
  resolvesItemAmount := fun _ => false
  resolvesRegimeChoice := fun _ => false
  resolvesReconciliation := false

/--
감독 지침이 요구하는 두 자본의 대조를 경로로 읽은 것.

**대응 비형식 개념:** 규범적 관점의 자기자본과 경제적 관점의 가용 내부 자본 사이의 대조를 기관이
가능하게 하라는 요구를 관측의 경로로 세운 것. 그 대조가 조정의 재료를 전부 담는 것으로 보이나 그
수취인이 감독 당국이다.

**세 칸이 모두 거짓인 것이 이 선언의 산출이다.** 소스 없음을 경로마다 등재하는 자리이며, 아무
주체도 보지 않는 경로가 비어 있지 않음을 보이는 witness 와 값이 같아도 드는 것이 다르다. 앞은
구조가 비어 있지 않음을 보이고 이것은 실재하는 요구가 외부 관측자에게 그 칸을 내지 못함을 보인다.

**이 정의가 배제하는 사례:**
그 대조가 아예 서지 않는다는 읽기. 감독 지침이 그 대조를 가능한 범위에서 가능하게 하라고 적으므로
그 대조 자체는 서며, 이 선언이 드는 결손은 그 대조가 없다는 것이 아니라 그 결과가 일반 관측자에게
열리는지를 그 편이 적지 않는다는 것이다(유럽중앙은행).
조달처: E-58 §5 「그 대조가 감독 당국을 수취인으로 둔다」

**기각한 대체 정의:**
대조의 칸을 참으로 두는 안. 그 요구가 조문으로 서 있어 대조가 수행되는 것으로 보이나, 감독 절차의
문서가 감독 당국에 제출되는 것이므로 그 수행이 외부 관측자의 읽기로 이어지지 않는다. 그 간격을
참으로 덮으면 관측층이 받을 소스 없음이 조문의 존재로 해소된 것으로 읽힌다.

**값을 담지 않는다.**
-/
-- DD:CF-2572
def supervisoryReconciliationChannel {Entity : Type} : CapitalAdjustmentChannel Entity where
  resolvesItemAmount := fun _ => false
  resolvesRegimeChoice := fun _ => false
  resolvesReconciliation := false

/--
감독 규범의 자본 조정 장을 경로로 읽은 것.

**대응 비형식 개념:** 규제자본에 적용되어야 하는 조정을 규정하는 장을 관측의 경로로 세운 것. 그
장이 조정 항목을 절 제목으로 열거하므로 항목의 전수는 거기서 읽히나 금액은 읽히지 않는다.

**세 칸이 모두 거짓인 것이 이 선언의 산출이다.** 앞의 경로와 값이 같아도 드는 것이 다르다. 앞은
대조가 서면서 수취인이 감독 당국인 자리이고 이것은 규칙이 서면서 금액이 공시되지 않는 자리이며,
두 결손이 서로를 덮지 않게 경로를 둘로 둔다.

**이 정의가 배제하는 사례:**
그 장이 항목의 열거를 내지 못한다는 읽기. 그 장이 공제 항목을 절 제목으로 열 개 들고 감독 지침이
넷을 더하므로 항목의 전수는 그 둘에서 읽히며, 이 선언이 드는 결손은 열거가 없다는 것이 아니라 그
항목마다의 금액이 그 장에서 나오지 않는다는 것이다(바젤은행감독위원회).
조달처: E-56 §8-1 「그래서 이 장의 조정이 장부자본에서 규제 자기자본으로 가는 사상이고」

**기각한 대체 정의:**
금액의 칸을 참으로 두는 안. 그 장이 금액을 정하는 규칙을 절마다 두므로 금액의 재료가 있는 것으로
보이나, 규칙이 금액을 정하는 것과 그 금액이 공시되는 것이 다른 사실이고 이 장은 공시의 장이 아니다.
그 둘을 섞으면 규범의 존재가 관측의 소스로 세어진다.

**값을 담지 않는다.**
-/
-- DD:CF-2572
def capitalAdjustmentRuleChannel {Entity : Type} : CapitalAdjustmentChannel Entity where
  resolvesItemAmount := fun _ => false
  resolvesRegimeChoice := fun _ => false
  resolvesReconciliation := false

/--
발행자의 재무제표를 자본 조정의 경로로 읽은 것.

**대응 비형식 개념:** 감독 요건의 적용을 받는 발행 주체의 연차보고서를 자본 조정의 재료를 읽는
경로로 세운 것. 그 보고서가 자본 쪽 행을 여럿 드므로 조정의 결과가 거기 서는 것으로 보이나 요건
자체를 위험 요인의 산문으로만 적는다.

**세 칸이 모두 거짓인 것이 이 선언의 산출이다.** 앞의 두 경로와 값이 같아도 드는 것이 다르다. 두
규범 쪽 경로가 규칙과 요구를 드는 자리인 데 비해 이것은 그 요건의 적용을 받는 주체의 공시가 드는
자리이며, 세 결손이 규범과 주체 양쪽에 서는 것이 이 파일의 산출이다.

**이 정의가 배제하는 사례:**
그 보고서가 자본의 값을 내지 못한다는 읽기. 그 표가 보통주주 귀속 자기자본과 비지배지분을 더한
자기자본을 행 둘로 들고 상환전환우선주를 별도 구획으로 두므로 자본의 값은 거기서 읽히며, 이 선언이
드는 결손은 값이 없다는 것이 아니라 **그 값이 조정의 결과인지 출발인지가 그 서식에서 갈리지
않는다**는 것이다(스테이블코인 발행자 연차보고서).
조달처: E-57 §3-1 「충족할 만큼의 규제자본을 양과 종류에서 담고 있지 않을 수 있다고 적고」

**기각한 대체 정의:**
체제의 칸을 참으로 두는 안. 그 보고서가 자기 자본의 경계를 세 구획으로 드므로 어느 경계를 쓰는지가
읽히는 것으로 보이나, 경계를 드는 것과 조정의 체제를 드는 것이 다른 사실이고 그 서식은 어느 항목에
어느 방향의 조정을 걸었는지를 적지 않는다. 그리고 이 경로를 세우지 않고 두 규범 경로로 갈음하는
안도 기각했다. 규범의 결손과 주체의 결손이 다른 자리에 서므로 갈음하면 뒤가 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-2572
def issuerFinancialStatementChannel {Entity : Type} : CapitalAdjustmentChannel Entity where
  resolvesItemAmount := fun _ => false
  resolvesRegimeChoice := fun _ => false
  resolvesReconciliation := false

/--
세 경로는 자본 조정의 어느 칸도 내지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
감독 지침의 대조 결과가 외부 관측자에게 열리거나, 감독 규범의 조정 장이 항목마다의 금액을 공시하게
하거나, 발행자의 재무제표가 어느 항목에 어느 방향의 조정을 걸었는지를 적어야 한다. 그 셋이 각각
감독 당국을 수취인으로 두고 규칙만 정하며 산문으로만 적으므로, 이 명제가 거짓이면 그 공시들이 지금
드는 것보다 가는 색인을 든다는 뜻이다.

**가정을 두지 않는다.**

**이 진술이 회계층의 체제 매개변수를 받친다.** 조정의 체제가 외생으로 들어오는 것이 형식화의 편의가
아니라 이 결손의 귀결이며, 감독 지침이 그 선택을 기관의 책임으로 둔 것과 그 선택이 관측되지 않는
것이 서로 다른 사실이다. 앞은 규범의 내용이고 뒤는 관측의 결손이다.

**T-3 분류:** 보조 보정이 아니다. 조정의 사상이 섰는데 그 사상의 인자가 어디에서도 읽히지 않음을
이 명제가 들며, 그 결손이 이 아크가 내릴 항의 답이 소스 없음으로 접히는 사유의 한 자리다.
-/
-- DD:CF-2572
theorem capitalAdjustmentChannels_resolve_nothing {Entity : Type} :
    (∀ e : Entity,
      (supervisoryReconciliationChannel (Entity := Entity)).resolvesItemAmount e = false)
    ∧ (∀ e : Entity,
        (supervisoryReconciliationChannel (Entity := Entity)).resolvesRegimeChoice e = false)
    ∧ (supervisoryReconciliationChannel (Entity := Entity)).resolvesReconciliation = false
    ∧ (∀ e : Entity,
        (capitalAdjustmentRuleChannel (Entity := Entity)).resolvesItemAmount e = false)
    ∧ (∀ e : Entity,
        (capitalAdjustmentRuleChannel (Entity := Entity)).resolvesRegimeChoice e = false)
    ∧ (capitalAdjustmentRuleChannel (Entity := Entity)).resolvesReconciliation = false
    ∧ (∀ e : Entity,
        (issuerFinancialStatementChannel (Entity := Entity)).resolvesItemAmount e = false)
    ∧ (∀ e : Entity,
        (issuerFinancialStatementChannel (Entity := Entity)).resolvesRegimeChoice e = false)
    ∧ (issuerFinancialStatementChannel (Entity := Entity)).resolvesReconciliation = false := by
  exact ⟨fun _ => rfl, fun _ => rfl, rfl, fun _ => rfl, fun _ => rfl, rfl,
    fun _ => rfl, fun _ => rfl, rfl⟩

end CrisisFramework.Observation
