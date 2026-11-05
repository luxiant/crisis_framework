/-
관측층 — 자금조달 통화 등급의 측정 사상

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원),
      L-9(import 방향은 단방향), A-3(witness 의무), D-1·D-2(docstring 3항목),
      D-3(배제 사례는 실제 문면), D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류),
      T-4(가정의 명시).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 칸을 내는가만 `Bool` 로 든다.

**이 파일이 세우는 것은 통화의 등급이 공표 수치에서 어떻게 관측되는가 또는 관측되지 않는가다.**
정의층이 등급을 역할별 도달 범위로 세우는데 그 범위를 외부 관측자가 어디에서 읽는지가 이 파일의
물음이다.

**으뜸 단계를 가르는 칸이 거짓인 것이 이 파일의 산출이다.** 관측층에 등재되는 소스 없음이
프레임워크의 주요 산출물 가운데 하나이므로 그 거짓이 결손의 기록이고 결함의 기록이 아니다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.CurrencyStanding

namespace CrisisFramework.Observation

open CrisisFramework.Definition

/--
자금조달 통화 등급을 읽는 공시 경로.

**대응 비형식 개념:** 어떤 공시가 통화의 역할별 도달 범위를 내는가. 등급이 통화와 역할을 받아
단계를 내므로 그 단계를 내는지가 경로마다 갈린다.

**이 정의가 배제하는 사례:**
한 공시가 어떤 역할의 범위는 내고 다른 역할의 범위는 내지 않는 자리. 원 문헌이 달러와 유로를
글로벌 통화로 인정하는 것이 공적 준비통화나 교역 표시통화의 역할을 넘지 않는 일이 흔하다고 적어
역할마다 읽히는 공시가 다름을 밝히는데, 이 구조는 역할을 정의역으로 받는 칸 하나로 그 갈림을
담으므로 역할마다 다른 경로가 서는 자리는 인스턴스를 둘로 나누어야 한다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-1 「그 인정이 공적 준비통화의 역할이나 교역 표시통화의 역할을 넘지 않는 일이 흔하다고 적는다」

**기각한 대체 정의:**
칸을 하나로 두고 등급 전량을 내는가만 묻는 안. 판정이 단순해지나 역할별 범위가 읽히면서 으뜸
단계만 읽히지 않는 자리가 사라지고, 그 자리가 이 파일의 산출이므로 결손이 구조에서 보이지 않게
된다. 그리고 으뜸 칸을 두지 않고 역할별 칸만 두는 안도 기각했다. 으뜸 단계가 역할별 범위의 가름과
다른 축이어서 전자는 통화가 발행국 밖에서 쓰이는지로 서고 후자는 규모의 비교로 서는데, 그 둘을
한 칸으로 묶으면 규모의 임계가 없다는 결손이 범위의 가름이 선다는 사실에 덮인다.

**값을 담지 않는다.**
-/
-- DD:CF-2677
structure CurrencyStandingChannel (Currency : Type) where
  /-- 그 통화를 이 경로가 보는가. -/
  coversCurrency : Currency → Bool
  /-- 그 역할에서 통화가 발행 영역을 넘어 쓰이는지를 이 경로가 내는가. -/
  resolvesRoleReach : CurrencyRole → Bool
  /-- 어느 통화가 그 역할에서 으뜸인지를 이 경로가 내는가. -/
  resolvesPreEminence : Bool

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `CurrencyStandingChannel` 이 비어 있지 않음을 보인다. 어느 통화도 보지
않고 세 칸을 하나도 내지 않는 경로다.
-/
-- DD:CF-2677
def CurrencyStandingChannel.noSource {Currency : Type} : CurrencyStandingChannel Currency where
  coversCurrency := fun _ => false
  resolvesRoleReach := fun _ => false
  resolvesPreEminence := false

/--
그 경로가 한 통화의 등급을 전부 내는가.

**대응 비형식 개념:** 등급을 읽으려면 그 통화를 보는 공시가 역할 셋의 범위를 전부 내고 으뜸 단계도
가려야 한다는 요구. 그 전량의 곱이 참일 때만 등급이 공시에서 유도된다.

**이 정의가 배제하는 사례:**
역할 둘의 범위만 읽히면 등급이 선다는 읽기. 원 문헌이 국제통화를 자국 관할권보다 넓은 영역을 갖는
것으로 세우므로 범위의 가름이 역할마다 따로 서야 하며, 셋 가운데 하나가 비면 그 역할의 단계가
공시에서 유도되지 않는다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-3 「국제통화가 자국 관할권보다 넓은 영역을 갖는다고 적는다」

**기각한 대체 정의:**
으뜸 칸을 뺀 곱으로 두고 으뜸 단계는 따로 묻는 안. 그러면 역할별 범위가 읽히는 경로가 이 판정을
통과하여 등급이 공시에서 선다고 읽히나, 등급의 공역이 세 단계이고 으뜸이 그 하나이므로 그 단계를
가르지 못하면 등급이 유도되지 않는다. 판정을 느슨하게 두면 소스 없음이 통과로 기록된다.

**값을 담지 않는다.**
-/
-- DD:CF-2677
def CurrencyStandingChannel.answersStanding {Currency : Type}
    (C : CurrencyStandingChannel Currency) (c : Currency) : Bool :=
  C.coversCurrency c
    && C.resolvesRoleReach CurrencyRole.officialReserve
    && C.resolvesRoleReach CurrencyRole.tradeInvoicing
    && C.resolvesRoleReach CurrencyRole.debtDenomination
    && C.resolvesPreEminence

/--
소재지 기준 국제은행 통계를 등급의 경로로 읽은 것.

**대응 비형식 개념:** 통화별 국경 간 청구권을 드는 공시를 등급의 재료를 읽는 경로로 세운 것. 그
통계가 통화를 색인으로 들므로 통화가 발행국 밖에서 쓰이는지는 거기서 읽힌다.

**으뜸 단계의 칸이 거짓인 것이 이 선언의 산출이다.** 소스 없음을 경로에 등재하는 자리이며, 어느
통화도 보지 않는 경로가 비어 있지 않음을 보이는 witness 와 값이 달라 드는 것도 다르다. 앞은 구조가
비어 있지 않음을 보이고 이것은 실재하는 공시가 외부 관측자에게 그 칸을 내지 못함을 보인다.

**이 정의가 배제하는 사례:**
그 통계가 등급의 재료를 아예 내지 못한다는 읽기. 원 문헌이 달러가 국제 은행 체계에서 으뜸의 역할을
하며 미국 밖의 은행이 달러로 빌리고 빌려준다고 적어 그 사실이 그 통계에서 읽히므로 범위의 가름은
서며, 이 선언이 드는 결손은 재료가 없다는 것이 아니라 으뜸을 가르는 임계가 그 공시에 없다는
것이다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-2 「달러가 국제 은행 체계에서 으뜸의 역할을 한다고 적는다」

**기각한 대체 정의:**
으뜸 칸을 참으로 두는 안. 그 통계가 통화별 잔액을 내므로 규모의 비교가 가능한 것으로 보이나, 으뜸
단계는 정도를 단계로 접는 임계를 요구하고 그 임계가 공시에 없으므로 참으로 두면 임계를 지어내게
된다. 실증 수치를 추출하지 않는다는 요구와 관측층이 값을 담지 않는다는 요구가 그 지어냄을 함께
막는다.

**값을 담지 않는다.**
-/
-- DD:CF-2677
def bisLocationalStandingChannel {Currency : Type} : CurrencyStandingChannel Currency where
  coversCurrency := fun _ => true
  resolvesRoleReach := fun _ => true
  resolvesPreEminence := false

/--
소재지 기준 통계는 역할별 범위를 내면서 으뜸 단계를 내지 못하므로 등급을 내지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 통계가 어느 통화가 어느 역할에서 으뜸인지를 가르는 임계를 공시해야 한다. 그러면 규모의 비교가
단계로 접히는 자리가 공시에 서고 등급이 외부 관측자에게 열린다.

**가정을 두지 않는다.**

**이 진술이 등급을 정의층에 둔 사유를 받친다.** 등급이 외생으로 들어오는 것이 형식화의 편의가 아니라
이 결손의 귀결이며, 범위의 가름이 공시에 서는 것과 그 단계가 공시에 서는 것이 서로 다른 사실이다.

**T-3 분류:** 보조 보정이 아니다. 경로가 두 칸을 내면서 한 칸을 내지 못해 등급이 닫히지 않음을 이
명제가 들며, 그 결손이 통화 쪽 축의 측정이 어디에서 끊기는지를 가른다.
-/
-- DD:CF-2677
theorem bisLocationalStandingChannel_preEminence_unresolved {Currency : Type} :
    (∀ r : CurrencyRole,
      (bisLocationalStandingChannel (Currency := Currency)).resolvesRoleReach r = true)
    ∧ (bisLocationalStandingChannel (Currency := Currency)).resolvesPreEminence = false
    ∧ (∀ c : Currency,
        (bisLocationalStandingChannel (Currency := Currency)).answersStanding c = false) := by
  exact ⟨fun _ => rfl, rfl, fun _ => rfl⟩
end CrisisFramework.Observation
