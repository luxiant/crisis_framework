/-
정의층 — 중앙은행 사이의 통화 교환 약정

규율: L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외), L-13(정의층 대상은 시점 인덱스를 갖는
      족으로 선다), L-12(통화 간 환산 금지), L-9(import 방향은 단방향), A-1(`axiom` 금지),
      A-3(witness 의무), C-1·C-2(`noncomputable` 과 `Classical` 금지),
      C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목),
      D-3(배제 사례는 실제 문면), D-5(식별자를 원문 저자 표기에서 가져오지 않는다),
      D-7(선행 등록), D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류),
      T-4(가정의 명시), T-6(존재 형태).

이 파일은 수를 시점 인덱스로만 쓰고 금액은 수 체계 매개변수 위의 항으로 받는다. 한도의 값이
그 항에 담기고 그 항의 수 체계를 아래 층이 정한다.

**이 파일이 세우는 것은 중앙은행 사이의 통화 교환이 어느 꼴의 엣지인가다.** 개별 거래는 청구권
셋과 담보 하나의 합성으로 이미 서므로 이 파일이 세우는 것은 그 거래들이 딛는 기본 약정의 층이며,
국제 기구의 지침이 그 두 층을 자기 문면으로 가른다.

**기간과 한도와 상호성의 세 축을 곱으로 둔다.** 한 발행자의 공시가 그 셋을 본문의 세 문단으로
각각 세워 독립을 자기 문면으로 받치므로 서지 않는 조합이 타입에 서는 비용을 받는다.

**도달 범위가 두 고리를 지나고 그 둘이 서로 다른 자리에서 나온다.** 첫째는 약정 자신의 수취자
필드에서 나오고 둘째는 재대출 적격성에서 나오므로 단계 수를 받는 재귀로 접으면 그 가름이 사라진다.

**정리의 증명은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채운다. 그 진술이
증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께
확인했으나, 쓴 전술은 싣지 않는다. 전술을 싣으면 집행이 그것을 옮겨 쓰게 되어 절단면을 넘으며,
사전 검사가 통과한 사실은 증거가 아니라 필터다.

**존재 정리의 증거를 익명 구조체 리터럴로 둔다.** 선례가 증거를 열거와 그 족 인스턴스로 최상위에
두었으나 그 둘이 실재하는 통화 셋을 담는 의미 있는 타입이어서이고, 이 파일의 증거는 축의 조합을
보이는 것뿐이어서 최상위 선언으로 두면 대응 비형식 개념을 들 자리가 없다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Finset.Basic
import CrisisFramework.Definition.Trigger

namespace CrisisFramework.Definition

/--
약정의 성립을 판단하는 자리.

**대응 비형식 개념:** 한 중앙은행이 상대를 고를 때 그 판단이 무엇에 붙는가의 갈래. 한 발행자의
공시가 결정 기준 넷을 열거하고 그 가운데 셋이 상대의 성질에 붙고 하나가 두 주체 사이의 관계에
붙는다.

**이 정의가 배제하는 사례:**
성립 조건을 수취자 하나에 붙는 성질로만 보는 읽기. 한 발행자의 공시가 넷째 기준으로 발행자가
상대의 통화를 받을 필요를 드는데 그것이 수취자의 성질이 아니라 두 주체 사이의 관계이므로, 자리를
하나로 두면 그 넷째가 담길 데가 없다.
조달처: E-60 §5-3 「그 조건을 수취자 하나에 붙는 술어로 세우면 넷째가 사라진다」

**기각한 대체 정의:**
성립 조건을 수취자 하나에 붙는 술어로 두고 자리의 열거를 세우지 않는 안. 칸이 하나여서 구조가
짧으나 그 넷째 기준이 사라진다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2975
inductive AdmissionLocus where
  /-- 수취자의 성질에 붙는 자리. -/
  | recipientAttribute
  /-- 두 주체 사이의 관계에 붙는 자리. -/
  | pairRelation
  deriving DecidableEq, Repr

/--
성립 조건의 거처.

**대응 비형식 개념:** 어느 발행자가 어느 자리의 기준을 두는가. 기준의 값은 담지 않는다.

**이 정의가 배제하는 사례:**
성립 조건의 기준을 구조가 값으로 담는 읽기. 공공 기관 문면이 두 발행자의 기준을 각각 분석한 연구를
인용하면서 그 기준이 공시에서 유도되지 않고 추정으로 복원된다고 적으므로, 값을 담으면 그 원천이
공시가 아니라 추정이 된다.
조달처: E-62 §8-3 「그 기준의 측정 소스가 공시가 아니라 연구의 추정이다」

**기각한 대체 정의:**
성립 조건의 기준을 발행자별 술어로 담아 그 내용을 구조가 들게 하는 안. 어느 발행자의 넷을 담을지가
그 자리에서 다시 판단되고 담는 값의 원천이 추정이어서 기각했다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2975
structure AdmissionCriteria (Node : Type) where
  /-- 그 발행자가 그 자리의 기준을 두는가. -/
  usesLocus : Node → AdmissionLocus → Bool

/--
한 방향의 중앙은행 통화 교환 기본 약정.

**대응 비형식 개념:** 두 중앙은행이 맺은 통화 교환의 기본 약정 하나. 국제 기구의 지침이 그것을
개별 거래의 상위에 두고 미결제 원금 총액이 그 최대를 넘을 수 없다고 적는다.

**이 정의가 배제하는 사례:**
기본 약정과 개별 거래를 한 층으로 보는 읽기. 국제 기구의 지침이 약정의 기간과 개별 거래의 만기를
서로 다른 축으로 두고 뒤의 것이 앞의 것을 넘을 수 있다고 적으므로, 한 층으로 접으면 그 두 축이
한 값으로 선다.
조달처: E-63 §2-2 「그러므로 약정의 기간과 개별 거래의 만기가 서로 다른 축이고 뒤의 것이 앞의 것을 넘을 수 있다」

**기각한 대체 정의:**
기본 약정과 개별 거래를 한 타입으로 두고 활성화 여부를 필드로 받는 안. 발동되지 않은 잔량이
금융자산과 부채의 경계 밖이라 활성화 전에는 청구권이 서지 않으므로 색인이 비는 자리가 생긴다.

**수 체계를 매개변수로 받는다.**
-/
-- DD:CF-2975
structure CentralBankSwapLine (Node Currency Num Obs : Type) where
  /-- 자기 통화를 공급하는 중앙은행. -/
  supplier : Node
  /-- 그 통화를 받는 중앙은행. -/
  recipient : Node
  /-- 공급되는 통화. -/
  suppliedCurrency : Currency
  /-- 예정 종료일. 값이 없으면 상시이며 그 종료가 통지로만 선다. -/
  scheduledEnd : Option ℕ
  /-- 최대 차입 가능액. 값이 없으면 무제한이다. -/
  cap : Option (Term Num Obs)
  /-- 그 쌍의 약정이 상호인가. -/
  reciprocal : Bool
  /-- 되돌리는 거래의 환율이 처음과 같은가. 조항의 축이며 환위험 귀속이 이 자리에서 유도된다. -/
  reversalAtInitialRate : Bool

/--
상시 지위를 예정 종료일의 부재로 유도한다.

**대응 비형식 개념:** 한 약정이 추가 통지가 있을 때까지 유지되는가. 한 발행자의 보도자료가 상시의
뜻을 그렇게 풀어 적으므로 그 지위가 상태가 아니라 사건의 부재다.

**이 정의가 배제하는 사례:**
상시 지위를 약정의 상태로 저장하는 읽기. 한 발행자의 보도자료가 임시에서 상시로 전환한다고 적으면서
그 지위가 영구가 아니라 종료 통지의 부재라고 자기 문면으로 풀므로, 상태로 저장하면 그 부재가 값으로
굳는다.
조달처: E-61 §8-3 「그 지위가 상태가 아니라 사건의 부재로 정의된다」

**기각한 대체 정의:**
상시 지위를 열거 필드로 저장하고 예정 종료일과 따로 두는 안. 같은 공시가 그 기간 축의 두 값이 표의
만료일 칸으로 나타난다고 적으므로 축을 따로 저장하면 그 둘이 갈릴 수 있다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2975
def CentralBankSwapLine.isStanding {Node Currency Num Obs : Type}
    (s : CentralBankSwapLine Node Currency Num Obs) : Bool :=
  s.scheduledEnd.isNone

/--
무제한 지위를 한도의 부재로 유도한다.

**대응 비형식 개념:** 한 약정이 최대 차입 가능액을 두지 않는가. 한 발행자의 정책 수단 면이 상시
상대방을 열거하면서 한도 칸을 두지 않는다.

**이 정의가 배제하는 사례:**
한도의 부재를 금액 영으로 담는 읽기. 한 발행자의 정책 수단 면이 금액도 무제한이라는 표현도 들지
않으므로 영으로 담으면 한도가 영인 약정과 무제한인 약정이 같은 값으로 선다.
조달처: E-61 §2-2 「금액도 무제한이라는 표현도 들지 않는다」

**기각한 대체 정의:**
한도의 부재를 금액 영으로 담고 선택 타입을 쓰지 않는 안. 금액 항이 상수와 신호와 곱과 합의 넷뿐이고
그 넷 가운데 어느 것도 한도의 부재를 뜻하지 않는다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2975
def CentralBankSwapLine.isUncapped {Node Currency Num Obs : Type}
    (s : CentralBankSwapLine Node Currency Num Obs) : Bool :=
  s.cap.isNone

/--
재대출 적격성.

**대응 비형식 개념:** 수취 중앙은행이 받은 외화를 자기 관할의 어느 기관에 다시 대출할 적격으로
두는가. 공급하는 쪽의 질의응답이 그 조건을 수취자가 스스로 정하고 어느 기관이 차입 적격인지가 그
조건에 든다고 적는다.

**이 정의가 배제하는 사례:**
재대출의 조건을 공급 중앙은행이 정한다고 보는 읽기. 공급하는 쪽의 질의응답이 공급의 층과 재대출의
층을 가르고 조건을 정하는 주체와 그 조건을 공표하는 주체가 둘 다 수취자라고 적는다.
조달처: E-61 §6 「그래서 공급의 층과 재대출의 층이 갈리고, 조건을 정하는 주체와 그 조건을 공표하는 주체가 둘 다 수취자다」

**기각한 대체 정의:**
재대출 적격성을 약정의 필드로 두고 별도 구조체를 세우지 않는 안. 한 수취자가 여러 발행자와 약정을
가지면 그 적격성이 약정마다 중복으로 서고 그 중복이 서로 다른 값을 가질 수 있다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2975
structure OnlendingEligibility (Node Currency : Type) where
  /-- 그 수취자가 그 통화를 그 기관에 다시 대출할 적격으로 두는가. -/
  eligible : Node → Currency → Node → Bool

/--
그 약정이 공급하는 외화가 구조적으로 닿는 범위. 고리가 둘이다.

**대응 비형식 개념:** 한 주체가 그 통화 교환이 공급하는 외화의 도달 범위 안에 있는가. 관측층의
답할 항이 그 물음을 들고 그 기각 문단이 구조적 도달 범위를 유한 그래프의 도달 가능성으로 둔다.

**이 정의가 배제하는 사례:**
도달 범위를 수취 중앙은행 하나로 닫는 읽기. 공급하는 쪽의 질의응답이 그 귀결로 한 엣지가 두 층을
품고 층마다 다른 주체가 조건을 정한다고 적으므로, 수취자로 닫으면 그 관할의 기관이 범위 밖으로
떨어진다.
조달처: E-61 §6 「그 귀결로 한 엣지가 두 층을 품고 층마다 다른 주체가 조건을 정한다」

**기각한 대체 정의:**
도달 범위를 단계 수를 받는 재귀로 두고 담보 사슬의 선례를 그대로 옮기는 안. 그 고리 둘이 서로 다른
자리에서 나오므로 재귀로 접으면 그 가름이 사라지고, 단계 수를 받으면 구조적 도달 범위가 그 수에
달려 있게 된다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2975
def CentralBankSwapLine.reaches {Node Currency Num Obs : Type} [DecidableEq Node]
    (s : CentralBankSwapLine Node Currency Num Obs)
    (E : OnlendingEligibility Node Currency) (n : Node) : Bool :=
  decide (n = s.recipient) || E.eligible s.recipient s.suppliedCurrency n

/--
한 시점의 약정 집합.

**대응 비형식 개념:** 한 시점에 서 있는 통화 교환 약정의 전량. 한 발행자의 질의응답이 상대방
집합이 시점에 따라 변하고 그 변화가 양방향이라고 적는다.

**이 정의가 배제하는 사례:**
약정 집합을 시점에 무관한 것으로 보는 읽기. 한 발행자의 질의응답이 앞선 위기에 세워진 임시 약정들이
그 위기가 가라앉은 뒤 만료되도록 두어졌다고 적으면서 그래서 상대방 집합이 시점에 따라 변하고 그
변화가 양방향이라고 적는다.
조달처: E-61 §4-3 「그래서 상대방 집합이 시점에 따라 변하고 그 변화가 양방향이다」

**기각한 대체 정의:**
약정 하나에 족 축약을 붙이고 집합의 구조체를 세우지 않는 안. 관측층의 답할 항이 받는 타입이 약정
하나이므로 개체에 족을 붙이면 그 서명이 받을 것이 약정의 시점열이 된다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2975
structure SwapLineNetwork (ι Node Currency Num Obs : Type) where
  /-- 약정의 색인. -/
  index : Finset ι
  /-- 색인에서 약정으로의 배정. -/
  assign : ι → CentralBankSwapLine Node Currency Num Obs

/--
시점마다의 약정 집합.

**대응 비형식 개념:** 약정의 집합이 시점에 따라 달라진다는 사실. 통지로 끝난 약정이 그 시점의
집합에서 빠지는 것으로 그 종료가 담긴다.

**이 정의가 배제하는 사례:**
집합을 시점과 무관한 상수로 두는 읽기. 한 발행자의 질의응답이 그 위기가 가라앉은 뒤 그 라인들이
만료되도록 두어졌다고 적으므로 상수로 두면 그 만료가 사라진다.
조달처: E-61 §4-3 「그 위기가 가라앉은 뒤 그 라인들이 만료되도록 두어졌다」

**기각한 대체 정의:**
시점 인덱스를 약정의 필드로 두고 족 축약을 세우지 않는 안. L-13 이 정의층 대상에 시점 인덱스를
요구하는 것이 타입에 걸리고 그 위의 술어에는 걸리지 않으며, 필드로 두면 한 약정이 자기 시점을 들어
집합이 시점마다 변하는 것을 담지 못한다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-2975
abbrev SwapLineNetworkFamily (ι Node Currency Num Obs : Type) :=
  ℕ → SwapLineNetwork ι Node Currency Num Obs

/-- witness (A-3). **무엇을 증거하는가.** 성립 조건의 거처 구조체가 비어 있지 않다. 어느 자리의
기준도 두지 않는 발행자 하나를 든다. -/
-- DD:CF-2975
def AdmissionCriteria.trivial : AdmissionCriteria Unit where
  usesLocus := fun _ _ => false

/-- witness (A-3). **무엇을 증거하는가.** 약정 구조체가 비어 있지 않다. 상시이면서 무제한이고
상호가 아닌 약정 하나를 든다. -/
-- DD:CF-2975
def CentralBankSwapLine.trivial : CentralBankSwapLine Unit Unit Unit Unit where
  supplier := ()
  recipient := ()
  suppliedCurrency := ()
  scheduledEnd := none
  cap := none
  reciprocal := false
  reversalAtInitialRate := false

/-- witness (A-3). **무엇을 증거하는가.** 재대출 적격성 구조체가 비어 있지 않다. 어느 기관도
적격으로 두지 않는 수취자 하나를 든다. -/
-- DD:CF-2975
def OnlendingEligibility.trivial : OnlendingEligibility Unit Unit where
  eligible := fun _ _ _ => false

/-- witness (A-3). **무엇을 증거하는가.** 약정 집합 구조체가 비어 있지 않다. 색인이 빈 집합인
망 하나를 든다. -/
-- DD:CF-2975
def SwapLineNetwork.trivial : SwapLineNetwork Unit Unit Unit Unit Unit where
  index := ∅
  assign := fun _ => CentralBankSwapLine.trivial

/-- 한 집합을 모든 시점에 두는 족. 선례가 같은 꼴을 둔다. -/
-- DD:CF-2975
def SwapLineNetworkFamily.constant {ι Node Currency Num Obs : Type}
    (N : SwapLineNetwork ι Node Currency Num Obs) :
    SwapLineNetworkFamily ι Node Currency Num Obs := fun _ => N

/--
수취 중앙은행은 늘 도달 범위 안이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
수취 중앙은행이 자기 약정의 도달 범위 밖에 있어야 한다. 범위가 수취자 등식의 판정과 재대출
적격성의 논리합으로 서므로 그 거짓은 그 논리합의 왼쪽이 참일 때도 전체가 거짓이라는 뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 정의를 전개하면 수취자 등식의 판정과 논리합의 왼쪽 항등식으로
닫히므로 기여 목록에서 제외한다.

**증명은 집행 증분이다.** 길은 범위의 정의를 전개하고 수취자 등식의 판정이 참임을 먹인 뒤 논리합의
왼쪽 항등식으로 닫는 것이다. 이 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을
부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2975
theorem CentralBankSwapLine.reaches_recipient {Node Currency Num Obs : Type}
    [DecidableEq Node] (s : CentralBankSwapLine Node Currency Num Obs)
    (E : OnlendingEligibility Node Currency) :
    s.reaches E s.recipient = true := by
  unfold CentralBankSwapLine.reaches
  rw [decide_eq_true (rfl : s.recipient = s.recipient)]
  rfl

/--
재대출 적격이 비면 도달 범위가 수취자 하나로 닫힌다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
재대출 적격으로 둔 기관이 하나도 없는 수취자의 약정인데 그 범위가 수취자 하나보다 넓어야 한다. 그
반례는 범위의 둘째 고리가 적격성이 아닌 다른 자리에서도 온다는 뜻이며, 그러면 그 고리를 비운 자리가
범위를 닫지 못한다.

**가정과 그 배제 사례(T-4·T-5):** 그 수취자가 그 통화를 어느 기관에도 적격으로 두지 않는다는
가정을 진술문에 둔다. 그 가정을 빼면 임의의 적격성에 대한 전칭 진술이 되어 거짓이며, 그 가정이
배제하는 것은 받은 외화를 자기 관할의 기관에 다시 대출하는 수취자다.

**T-3 분류:** 기여다. 범위의 두 고리가 서로 독립임을 그 둘 가운데 하나를 비운 자리에서 보이므로
기여 목록에 든다.

**증명은 집행 증분이다.** 길은 범위의 정의를 전개하고 가정을 공급 통화와 그 주체에 적용한 뒤 논리합의
오른쪽 항등식으로 닫는 것이다. 이 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을
부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2975
theorem CentralBankSwapLine.reaches_eq_of_no_onlending {Node Currency Num Obs : Type}
    [DecidableEq Node] (s : CentralBankSwapLine Node Currency Num Obs)
    (E : OnlendingEligibility Node Currency)
    (hE : ∀ m, E.eligible s.recipient s.suppliedCurrency m = false) (n : Node) :
    s.reaches E n = decide (n = s.recipient) := by
  unfold CentralBankSwapLine.reaches
  rw [hE n, Bool.or_false]

/--
상시이면서 한도 지위가 갈리는 약정 둘이 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
상시인 약정이 전부 같은 한도 지위를 가져야 한다. 그 반례는 기간과 한도의 두 축이 타입에서 묶여
있다는 뜻이며, 그러면 한 발행자의 공시가 그 둘을 따로 세운 것이 담기지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
기간과 한도의 독립은 그 조합이 실제로 서는 약정 둘을 들어야 보이고, 임의의 상시 약정에 대한 전칭으로는
그 독립이 진술되지 않는다. 시스템 수준의 기간 지위가 개별 약정의 한도 지위를 결정하지 않는 자리다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 타입이 두 축을 곱으로 둔 설계가 실제로 두 값을 함께 받는다는 것을 보이므로
기여 목록에 든다.

**증명은 집행 증분이다.** 길은 한도가 선 약정과 한도가 없는 약정을 증거로 들고 네 등식을 계산으로
닫는 것이다. 증거는 익명 구조체 리터럴로 두어 최상위 선언을 늘리지 않는다. 이 진술이 증명 가능함을
결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴
전술은 싣지 않는다.
-/
-- DD:CF-2975
theorem exists_standing_differing_on_cap :
    ∃ a b : CentralBankSwapLine Unit Unit Unit Unit,
      a.isStanding = true ∧ b.isStanding = true
        ∧ a.isUncapped = false ∧ b.isUncapped = true := by
  exact ⟨{ supplier := (), recipient := (), suppliedCurrency := (), scheduledEnd := none,
            cap := some (Term.const ()), reciprocal := false, reversalAtInitialRate := false },
          { supplier := (), recipient := (), suppliedCurrency := (), scheduledEnd := none,
            cap := none, reciprocal := false, reversalAtInitialRate := false },
          rfl, rfl, rfl, rfl⟩

/--
두 자리의 기준을 함께 두는 발행자가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 발행자도 두 자리의 기준을 함께 두지 않아야 한다. 그 반례는 자리의 열거가 배타적 분류라는
뜻이며, 그러면 한 발행자가 상대의 성질과 두 주체 사이의 관계를 함께 보는 것이 담기지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
자리 둘이 배타적이지 않음은 둘을 함께 두는 발행자를 들어야 보이고, 임의의 발행자에 대한 전칭으로는
그 비배타성이 진술되지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 자리의 열거가 분할이 아니라 독립된 두 축임을 보이므로 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 두 자리에 모두 참을 내는 발행자를 증거로 들고 두 등식을 계산으로
닫는 것이다. 증거는 익명 구조체 리터럴로 둔다. 이 진술이 증명 가능함을 결정 세션의 사전 검사가
확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2975
theorem exists_issuer_using_both_loci :
    ∃ A : AdmissionCriteria Unit,
      A.usesLocus () AdmissionLocus.recipientAttribute = true
        ∧ A.usesLocus () AdmissionLocus.pairRelation = true := by
  exact ⟨{ usesLocus := fun _ _ => true }, rfl, rfl⟩

/--
환위험을 지는 주체.

**대응 비형식 개념:** 그 약정의 조항이 환율 변동의 부담을 어느 주체의 장부에 두는가. 값이 없으면
그 조항이 그것을 정하지 않는다는 뜻이며 아무도 지지 않는다는 뜻이 아니다.

**이 정의가 배제하는 사례:**
환위험 귀속을 참거짓으로 두는 읽기. 공급하는 쪽의 질의응답이 되돌리는 거래의 환율이 처음과 같으므로
자기가 환율 변동에 노출되지 않는다고 적고 공공 기관 문면이 차입하는 중앙은행이 환위험을 전부 진다고
적는데, 참거짓으로 두면 그 조항이 귀속을 정하지 않는 자리와 아무도 지지 않는 자리가 한 값으로 선다.
조달처: E-62 §6 「그 둘이 같은 거래의 두 면이어서 어느 쪽도 틀리지 않으나 그 둘을 한 문장으로 합치면 환위험이 어느 주체의 장부에 서는지가 사라진다」

**기각한 대체 정의:**
귀속을 공급자와 수취자의 열거로 두고 선택 타입을 쓰지 않는 안. 두 문면이 같은 거래의 두 면이어서
어느 쪽도 틀리지 않는데 열거로 두면 조항이 정하지 않는 자리에 둘 가운데 하나를 넣게 되고, 그 넣음이
B-7 이 금지한 봉합이다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3103
def CentralBankSwapLine.fxRiskBearer {Node Currency Num Obs : Type}
    (s : CentralBankSwapLine Node Currency Num Obs) : Option Node :=
  if s.reversalAtInitialRate then some s.recipient else none

/--
되돌림이 처음 환율이면 귀속이 수취자다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
되돌리는 거래의 환율이 처음과 같은 약정인데 그 귀속이 수취자가 아니어야 한다. 그 관측은 조항의
축과 귀속이 다른 자리에서 나온다는 뜻이며, 그러면 귀속이 조항에서 유도되지 않고 따로 저장되어야 한다.

**가정과 그 배제 사례(T-4·T-5):** 되돌림이 처음 환율이라는 가정을 진술문에 둔다. 그 가정을 빼면
임의의 약정에 대한 전칭이 되어 거짓이며, 그 가정이 배제하는 것은 되돌림 환율을 미리 정하지 않는
약정이다.

**T-3 분류:** 보조 보정이다. 정의를 전개하고 조건 분기의 참 갈래로 닫히므로 기여 목록에서 제외한다.
-/
-- DD:CF-3103
theorem CentralBankSwapLine.fxRiskBearer_eq_recipient {Node Currency Num Obs : Type}
    (s : CentralBankSwapLine Node Currency Num Obs)
    (h : s.reversalAtInitialRate = true) : s.fxRiskBearer = some s.recipient := by
  unfold CentralBankSwapLine.fxRiskBearer
  rw [if_pos h]

/--
되돌림이 처음 환율이 아니면 귀속이 비어 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
되돌림 환율을 미리 정하지 않는 약정인데 그 귀속이 비어 있지 않아야 한다. 그 관측은 그 조항 밖의
자리가 귀속을 정한다는 뜻이며, 그러면 그 자리를 타입이 받아야 한다.

**가정과 그 배제 사례(T-4·T-5):** 되돌림이 처음 환율이 아니라는 가정을 진술문에 둔다. 그 가정을
빼면 앞 명제와 부딪히며, 그 가정이 배제하는 것은 되돌림 환율이 처음과 같은 약정이다.

**T-3 분류:** 보조 보정이다. 앞 명제와 같은 사유다.
-/
-- DD:CF-3103
theorem CentralBankSwapLine.fxRiskBearer_eq_none {Node Currency Num Obs : Type}
    (s : CentralBankSwapLine Node Currency Num Obs)
    (h : s.reversalAtInitialRate = false) : s.fxRiskBearer = none := by
  unfold CentralBankSwapLine.fxRiskBearer
  rw [h, if_neg Bool.false_ne_true]

/--
귀속이 비어 있음과 되돌림 환율이 정해지지 않음이 서로 동치다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
귀속이 비어 있는데 되돌림 환율이 처음과 같거나, 되돌림 환율이 처음과 다른데 귀속이 선 약정이
있어야 한다. 그 관측은 귀속이 그 조항 하나에서 유도되지 않는다는 뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 귀속의 결손이 조항의 결손과 같은 것임을 양방향으로 보이므로, 소스 없음이
어느 축에서 오는지를 관측층이 그 조항 하나로 환원할 수 있게 된다.
-/
-- DD:CF-3103
theorem CentralBankSwapLine.fxRiskBearer_eq_none_iff_not_reversalAtInitialRate
    {Node Currency Num Obs : Type} (s : CentralBankSwapLine Node Currency Num Obs) :
    s.fxRiskBearer = none ↔ s.reversalAtInitialRate = false := by
  constructor
  · intro hn
    cases hr : s.reversalAtInitialRate with
    | false => rfl
    | true =>
      rw [CentralBankSwapLine.fxRiskBearer_eq_recipient s hr] at hn
      cases hn
  · exact CentralBankSwapLine.fxRiskBearer_eq_none s

/--
공급자와 수취자가 다르면 귀속이 공급자가 아니다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공급자와 수취자가 다른 약정인데 그 귀속이 공급자여야 한다. 그 관측은 공급하는 쪽의 질의응답이
자기가 환율 변동에 노출되지 않는다고 적은 것과 부딪히며, 그러면 그 두 문면 가운데 하나가 틀린다.

**가정과 그 배제 사례(T-4·T-5):** 공급자와 수취자가 다르다는 가정을 진술문에 둔다. 그 가정을
빼면 두 주체가 같은 약정에서 거짓이며, 그 가정이 배제하는 것은 한 중앙은행이 자기와 맺은 약정이다.

**T-3 분류:** 기여다. 두 문면 가운데 공급자 쪽의 서술이 타입에서 따라 나옴을 보이므로, B-7 이
금지한 봉합을 쓰지 않고 두 서술을 함께 담았음이 이 자리에서 선다.
-/
-- DD:CF-3103
theorem CentralBankSwapLine.fxRiskBearer_ne_supplier {Node Currency Num Obs : Type}
    (s : CentralBankSwapLine Node Currency Num Obs) (hne : s.supplier ≠ s.recipient) :
    s.fxRiskBearer ≠ some s.supplier := by
  intro heq
  cases hr : s.reversalAtInitialRate with
  | false =>
    rw [CentralBankSwapLine.fxRiskBearer_eq_none s hr] at heq
    cases heq
  | true =>
    rw [CentralBankSwapLine.fxRiskBearer_eq_recipient s hr] at heq
    exact hne (Option.some.inj heq).symm

/--
귀속이 선 약정과 비어 있는 약정이 둘 다 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
약정이 전부 같은 귀속 지위를 가져야 한다. 그 반례는 조항의 축이 타입에서 다른 축에 묶여 있다는
뜻이며, 그러면 두 문면이 같은 거래의 두 면이라는 사실이 담기지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
귀속의 결손이 실재함은 그 결손이 선 약정 하나를 들어야 보이고, 임의의 약정에 대한 전칭으로는
그 결손이 진술되지 않는다. 시스템 수준의 조항 관례가 개별 약정의 귀속을 결정하지 않는 자리다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 선택 타입을 쓴 설계가 실제로 두 값을 함께 받는다는 것을 보이므로 기여
목록에 든다.
-/
-- DD:CF-3103
theorem exists_mismatch_on_bearer_not_supplier :
    ∃ a b : CentralBankSwapLine Unit Unit Unit Unit,
      a.fxRiskBearer = some a.recipient ∧ b.fxRiskBearer = none := by
  exact ⟨{ CentralBankSwapLine.trivial with reversalAtInitialRate := true },
    CentralBankSwapLine.trivial, rfl, rfl⟩

end CrisisFramework.Definition
