/-
관측층 — 자국통화 술어의 측정 사상

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원),
      L-9(import 방향은 단방향), A-3(witness 의무), D-1·D-2(docstring 3항목),
      D-3(배제 사례는 실제 문면), D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류),
      T-4(가정의 명시).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 칸을 내는가만 `Bool` 로 든다.

**이 파일이 세우는 것은 자국통화 여부가 공표 수치에서 어떻게 관측되는가 또는 관측되지 않는가다.**
정의층의 술어가 관할권 기준을 함께 받으므로 그 기준마다 공시가 서는지를 칸으로 가른다.

**두 기준 가운데 하나만 재어진다는 사실이 두 칸으로 갈려 서는 것이 이 파일의 산출이다.** 한 칸으로
묶으면 한 기준의 결손이 다른 기준의 가능을 덮는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.DomesticCurrency

namespace CrisisFramework.Observation

open CrisisFramework.Definition

/--
자국통화 여부를 읽는 공시 경로.

**대응 비형식 개념:** 어떤 공시가 어떤 노드에게 어떤 통화가 자국통화인지를 내는가. 정의층의 술어가
관할권 기준을 함께 받으므로 그 기준마다 공시가 서는지가 갈린다.

**이 정의가 배제하는 사례:**
두 기준의 가름을 한 칸으로 묶는 자리. 원 문헌이 연결 통계 안에서 국제 청구권이 현지 통화 곧
호스트국 통화로 된 현지 청구권을 제외한다고 적어 소재지 쪽 가름이 공시에 서는데, 한 칸으로 묶으면
국적 쪽 결손이 그 가능에 덮인다(Shin 2012).
조달처: E-12 §9-2 「연결 통계 안에서 국제 청구권이 현지 통화 곧 호스트국 통화로 된 현지 청구권을 제외한다고 적는다」

**기각한 대체 정의:**
기준을 정의역으로 받는 칸 하나로 두는 안. 기준이 늘어도 구조를 고치지 않아도 되므로 확장이 쉬우나,
기준이 둘로 고정되어 있고 그 둘의 결손이 다른 자리에 서므로 정의역으로 접으면 어느 기준이
재어지는지가 인스턴스의 값에서만 읽히고 구조에서 읽히지 않는다. 그리고 노드를 보는 칸을 두지 않고
기준 칸만 두는 안도 기각했다. 어느 노드를 보는지가 경로마다 다르고 그 범위가 결손의 한 축이어서
빼면 전수 공시와 일부 공시가 같아 보인다.

**값을 담지 않는다.**
-/
-- DD:CF-2678
structure DomesticCurrencyChannel (Node : Type) where
  /-- 그 노드를 이 경로가 보는가. -/
  coversNode : Node → Bool
  /-- 소재지 기준 아래의 자국통화 가름을 이 경로가 내는가. -/
  resolvesResidenceBasis : Bool
  /-- 국적 기준 아래의 자국통화 가름을 이 경로가 내는가. -/
  resolvesNationalityBasis : Bool

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `DomesticCurrencyChannel` 이 비어 있지 않음을 보인다. 어느 노드도 보지
않고 두 기준의 가름을 하나도 내지 않는 경로다.
-/
-- DD:CF-2678
def DomesticCurrencyChannel.noSource {Node : Type} : DomesticCurrencyChannel Node where
  coversNode := fun _ => false
  resolvesResidenceBasis := false
  resolvesNationalityBasis := false

/--
그 경로가 한 노드의 자국통화 여부를 두 기준 모두에서 내는가.

**대응 비형식 개념:** 자국통화 술어가 기준을 함께 받으므로 그 술어를 공시에서 읽으려면 두 기준의
가름이 모두 서야 한다는 요구.

**이 정의가 배제하는 사례:**
한 기준의 가름만 읽히면 술어가 선다는 읽기. 원 문헌이 같은 청구권이 어느 기준으로 세느냐에 따라
다른 나라에 귀속된다고 적으므로 한 기준의 값에서 다른 기준의 값이 유도되지 않으며, 하나만 요구하면
그 유도되지 않음이 판정에서 사라진다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §3-3 「같은 청구권이 어느 기준으로 세느냐에 따라 다른 나라에 귀속된다」

**기각한 대체 정의:**
두 기준 가운데 하나만 요구하는 안. 소재지 기준의 가름이 공시에 서므로 그 하나로 두면 이 판정이
참을 내고 술어가 관측된 것으로 기록되나, 정의층의 구조체가 기준을 필드로 들어 두 기준이 다른
인스턴스를 낳으므로 하나만 재면 다른 인스턴스의 관측이 어디에서도 기록되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-2678
def DomesticCurrencyChannel.answersDomestic {Node : Type}
    (C : DomesticCurrencyChannel Node) (n : Node) : Bool :=
  C.coversNode n && C.resolvesResidenceBasis && C.resolvesNationalityBasis

/--
연결 국제은행 통계와 국적별 소재지 통계를 자국통화의 경로로 읽은 것.

**대응 비형식 개념:** 모은행 국적으로 통합한 공시와 국적을 함께 보고하는 공시를 자국통화의 재료를
읽는 경로로 세운 것. 앞의 공시가 현지 통화로 된 현지 청구권을 국제 청구권에서 제외하므로 소재지
기준의 가름이 거기서 읽힌다.

**두 칸 가운데 하나만 참인 것이 이 선언의 산출이다.** 소스 없음을 경로에 등재하는 자리이며, 두
기준 가운데 하나만 재어진다는 사실이 두 칸으로 갈려 선다.

**이 정의가 배제하는 사례:**
그 공시들이 국적 기준의 자국통화 가름을 낸다는 읽기. 원 문헌이 그 데이터가 대출 은행의 소재지와
그 국적과 차입자의 소재지 셋을 함께 보고한다고 적으면서 통화를 그 셋과 함께 들지 않으므로, 같은
청구권을 국적 기준으로 세면서 그 표시 통화가 모은행 국적국의 통화인지를 가르는 칸이 어느 공시에도
없다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-5 「그 데이터가 대출 은행의 소재지와 그 국적과 차입자의 소재지 셋을 함께 보고한다고 적는다」

**기각한 대체 정의:**
국적 칸을 참으로 두는 안. 국적별 보고가 서 있으므로 국적 기준의 분류가 가능한 것으로 보이나,
국적으로 분류하는 것과 그 분류 아래에서 표시 통화가 자국통화인지를 가르는 것이 다른 사실이고 그
공시가 통화를 국적과 함께 들지 않는다. 그 간격을 참으로 덮으면 관측층이 받을 소스 없음이 국적
분류의 존재로 해소된 것으로 읽힌다.

**값을 담지 않는다.**
-/
-- DD:CF-2678
def bisConsolidatedDomesticChannel {Node : Type} : DomesticCurrencyChannel Node where
  coversNode := fun _ => true
  resolvesResidenceBasis := true
  resolvesNationalityBasis := false

/--
그 공시들은 소재지 기준의 가름을 내면서 국적 기준의 가름을 내지 못하므로 자국통화 여부를
두 기준 모두에서 내지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
국적별로 분류한 청구권에 표시 통화의 색인이 함께 붙어야 한다. 그러면 같은 청구권을 모은행 국적으로
세면서 그 통화가 국적국의 통화인지를 가를 수 있고 자국통화 술어가 두 기준에서 모두 관측된다.

**가정을 두지 않는다.**

**이 진술이 기준을 구조체의 필드로 둔 사유를 받친다.** 두 기준이 서로 유도되지 않는다는 것이 정의층
쪽 설계의 근거이고, 그 둘 가운데 하나만 관측된다는 것이 관측층 쪽 결손이다. 앞은 구조의 요구이고
뒤는 측정의 결손이며 둘이 서로 다른 사실이다.

**T-3 분류:** 보조 보정이 아니다. 기준을 구조에 둔 설계가 관측에서 절반만 받쳐진다는 것을 이 명제가
들며, 그 절반이 어느 쪽인지가 뒤 페이즈가 답할 항을 조립할 때 그 답의 입도를 정한다.
-/
-- DD:CF-2678
theorem bisConsolidatedDomesticChannel_nationality_unresolved {Node : Type} :
    (bisConsolidatedDomesticChannel (Node := Node)).resolvesResidenceBasis = true
    ∧ (bisConsolidatedDomesticChannel (Node := Node)).resolvesNationalityBasis = false
    ∧ (∀ n : Node,
        (bisConsolidatedDomesticChannel (Node := Node)).answersDomestic n = false) := by
  exact ⟨rfl, rfl, fun _ => rfl⟩
end CrisisFramework.Observation
