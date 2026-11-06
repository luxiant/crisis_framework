/-
관측층 — 통화 불일치의 측정 사상

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원),
      L-9(import 방향은 단방향), A-3(witness 의무), C-3(판정 술어는 `Decidable`),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-8(witness 의 서술),
      T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 축을 내는가만 `Bool` 로 들고 입도는 열거다.

**이 파일이 세우는 것은 통화 불일치가 공표 수치에서 어떻게 관측되는가 또는 관측되지 않는가다.**
정의층이 그 개념을 두 가지로 가르므로 그 둘이 각각 어디서 읽히는지를 축으로 갈라 받는다.

**축을 다섯으로 가르고 입도와 수신자를 함께 받는 것이 이 파일의 설계다.** 한 칸으로 접으면 네 축이
참인 것이 다섯째의 거짓을 덮으며, 그 거짓이 이 파일의 산출이다. 조달 연결 축이 어느 경로에서도
서지 않는 것을 이 파일의 정리 둘이 받친다.

**정리의 증명은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채운다. 그 진술이
증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께
확인했으나, 쓴 전술은 싣지 않는다. 전술을 싣으면 집행이 그것을 옮겨 쓰게 되어 절단면을 넘으며,
사전 검사가 통과한 사실은 증거가 아니라 필터다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.CurrencyMismatch
import CrisisFramework.Observation.AssetCompositionChannel

namespace CrisisFramework.Observation

open CrisisFramework.Definition


/--
통화 불일치를 읽는 경로가 어느 입도로 값을 내는가.

**대응 비형식 개념:** 결손이 축에만 걸리지 않고 축과 입도와 관측자의 조합에 걸리므로 그 입도를
담는 공역이 이 열거다.

**이 정의가 배제하는 사례:**
교역 금융의 입도 셋을 그대로 옮기는 자리. 콜롬비아의 감독 자료를 든 기록이 그 자료의 대응이 기업과
분기에서 멈추고 거래 단위와 나라 단위 사이에 그 칸이 선다고 적으므로 입도의 선례가 셋이다. 그러나
청구권이 표시 통화를 필드 하나로 받아 한 청구권은 불일치를 가질 수 없으므로 거래 입도에서는
불일치가 구조적으로 서지 않으며, 이 열거는 그 입도를 담지 않는다.
조달처: E-40 §3-1 「통화는 붙되 외화 대 자국통화의 둘이고, 대응은 기업 단위에서 멈춘다」

**기각한 대체 정의:**
입도를 거래 단위까지 넓혀 셋으로 두는 안. 교역 금융의 입도 선례가 거래와 기업과 나라 셋을 들므로
그 축을 그대로 옮길 수 있어 보이나, 청구권이 표시 통화를 필드 하나로 받아 한 청구권은 불일치를
가질 수 없으므로 거래 입도에서는 불일치가 구조적으로 서지 않고 그 생성자가 어느 경로에서도 쓰이지
않는다. 입도를 받지 않고 경로마다 산문으로 적는 안도 기각했다. 결손이 축과 입도와 관측자의 조합에
걸리므로 입도를 칸으로 두어야 그 조합이 인스턴스로 서고 경로 여럿을 목록으로 모아 전량을 잴 수
있다.

**값을 담지 않는다.**
-/
-- DD:CF-2753
inductive MismatchGranularity where
  /-- 한 주체를 단위로 값을 내는 입도. -/
  | nodeLevel
  /-- 한 관할권을 단위로 값을 내는 입도. -/
  | jurisdictionLevel
  deriving DecidableEq, Repr

/--
통화 불일치의 축마다 그 값을 내는 공시 경로.

**대응 비형식 개념:** 관측층은 각 아크에서 병행하므로 정의층 대상을 세울 때 그 측정 사상 명세를
함께 쓰는 자리가 이 구조체다.

**이 정의가 배제하는 사례:**
한 경로가 모든 축을 같은 정도로 가른다고 보는 자리. 지목 참조로 연 편이 현금과 단기투자의 표시
통화를 알 수 없고 그 자료가 공개되지 않는다고 적으면서 달러채 발행의 이력은 그 자료에서 읽으므로,
같은 공시가 부채의 통화를 내고 자산의 통화를 내지 못한다. 이 구조체는 축마다 칸을 두어 그 갈림을
받으며, 한 칸으로 접으면 참인 축이 거짓인 축을 덮는다.
조달처: E-64 §2-3 「그래서 불일치를 직접 재지 않고 그 귀결을 재는 설계로 간다」

**기각한 대체 정의:**
축 다섯을 한 칸으로 접어 불일치를 읽는가만 받는 안. 칸이 하나여서 인스턴스가 짧으나 만기 불일치의
공시 경로가 앞의 셋을 한 칸으로 접으면 셋이 다 참이라는 것이 넷째의 거짓을 덮으며 그 거짓이
산출이라고 적으므로, 접으면 어느 축이 서고 어느 축이 서지 않는지가 사라지고 이 파일의 산출이 비어
버린다. 축마다 칸을 두되 입도와 수신자를 빼는 안도 기각했다. 지목 참조로 연 세 자리에서 같은 축이
감독 당국의 자료에서 서고 공개 공시에서 서지 않으므로 그 갈림이 축에 걸리지 않고 관측자와 입도에
걸리며, 빼면 두 경로가 같은 축을 두고 어긋나는 것이 모순으로 읽힌다.

**값을 담지 않는다.**
-/
-- DD:CF-2753
structure CurrencyMismatchChannel (Node : Type) where
  /-- 그 노드를 이 경로가 보는가. -/
  coversNode : Node → Bool
  /-- 부채의 표시 통화를 이 경로가 내는가. -/
  readsDebtCurrency : Bool
  /-- 자산의 표시 통화를 이 경로가 내는가. -/
  readsAssetCurrency : Bool
  /-- 수익의 표시 통화를 이 경로가 내는가. -/
  readsRevenueCurrency : Bool
  /-- 파생으로 맺은 헤지를 이 경로가 내는가. -/
  readsDerivativeHedge : Bool
  /-- 어느 부채가 어느 통화의 자산을 조달했는지를 이 경로가 내는가. -/
  readsFundingLink : Bool
  /-- 이 경로가 값을 내는 입도. 어느 입도로도 내지 않으면 없음이다. -/
  granularity : Option MismatchGranularity
  /-- 이 경로의 공시가 누구에게 가는가. -/
  recipient : DisclosureRecipient

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `CurrencyMismatchChannel` 이 비어 있지 않음을 보인다. 어느 노드도 보지 않고
축 다섯의 어느 값도 내지 않으며 입도를 갖지 않는 경로다.
-/
-- DD:CF-2753
def CurrencyMismatchChannel.noSource {Node : Type} : CurrencyMismatchChannel Node where
  coversNode := fun _ => false
  readsDebtCurrency := false
  readsAssetCurrency := false
  readsRevenueCurrency := false
  readsDerivativeHedge := false
  readsFundingLink := false
  granularity := none
  recipient := DisclosureRecipient.publicReader

/--
그 경로가 한 주체의 불일치를 축 다섯 모두에서 내는가.

**대응 비형식 개념:** 다섯을 모두 내는 경로가 하나도 없다는 것을 한 명제로 세우려면 그 합성 술어가
서야 한다.

**이 정의가 배제하는 사례:**
축 가운데 하나가 서면 불일치가 관측된 것으로 보는 자리. 콜롬비아의 감독 자료를 든 기록이
외화부채를 진 기업 가운데 세 부류에서 효과가 나타나지 않는다고 적어 부채 축만으로는 그 셋이
가려지지 않음을 보이므로, 한 축의 값에서 다른 축의 값이 유도되지 않는다. 이 판정은 다섯을 모두
요구하며, 하나만 요구하면 그 유도되지 않음이 판정에서 사라진다.
조달처: E-40 §2-4 「자산과 수익과 파생이 함께 들어가야 한다」

**기각한 대체 정의:**
축마다 따로 판정을 내고 합성하지 않는 안. 어느 축이 서는지를 각각 읽으므로 세밀하나 다섯을 모두
내는 경로가 하나도 없다는 것을 한 명제로 세울 자리가 없고, 자국통화의 공시 경로가 두 기준의 합성
술어를 두고 그것이 전량 거짓임을 정리로 보인 선례가 그 자리를 합성 술어에 둔다. 다섯 가운데 넷만
요구하고 조달 연결을 빼는 안도 기각했다. 그 축이 어느 입도에서도 서지 않는 것이 이 파일의 산출인데
빼면 그 판정이 참이 되는 경로가 생겨 결손이 가려진다.

**값을 담지 않는다.**
-/
-- DD:CF-2753
def CurrencyMismatchChannel.answersAllAxes {Node : Type}
    (C : CurrencyMismatchChannel Node) (n : Node) : Bool :=
  C.coversNode n && C.readsDebtCurrency && C.readsAssetCurrency
    && C.readsRevenueCurrency && C.readsDerivativeHedge && C.readsFundingLink

/--
감독 당국의 신용등록부와 통계청 자료와 대차대조표를 기업 식별자로 병합한 경로.

**대응 비형식 개념:** 지목 참조로 연 기록이 그 자료로 축 넷을 갈랐으므로 실재하는 경로가 어디까지
내는지를 드는 자리가 이 선언이다.

**이 정의가 배제하는 사례:**
감독 당국에 가는 보고를 공개 공시로 읽는 자리. 콜롬비아의 감독 자료를 든 기록이 그 자료가
감독당국의 신용등록부에서 왔다고 적고 은행과 금융기관이 분기마다 보고한다고 적으므로 그 수신자가
감독 당국이다. 이 경로는 수신자를 그 당국으로 들며, 공개로 두면 밖에서 보는 관측자가 닿지 못하는
자료를 닿는 것으로 적게 된다.
조달처: E-40 §2-1 「감독당국의 신용등록부에서 온 자료다」

**기각한 대체 정의:**
그 경로가 조달 연결을 낸다고 두는 안. 그 자료가 기업 식별자로 대출과 교역과 대차대조표를 잇고
통화를 외화와 자국통화로 가르므로 연결이 읽히는 것처럼 보이나, 그 기록이 어느 대출이 어느 선적을
금융했는지는 자료에 없다고 적고 끊기는 까닭을 자료의 부족이 아니라 돈이 대체 가능하다는 것으로
적는다. 그 경로의 수신자를 일반 관측자로 두는 안도 기각했다. 그 자료가 감독 당국의 신용등록부에서
오고 연구자가 그것을 쓰는 것과 그 자료가 공개 공시로 서는 것이 다른 사실이며, 같은 가름을 만기
불일치의 공시 경로가 자료가 실재하는데 그 수신자가 감독 당국이어서 밖에서 보는 관측자가 닿지
못한다는 문면으로 이미 들었다.

**값을 담지 않는다.**
-/
-- DD:CF-2753
def supervisoryCreditRegistryChannel {Node : Type} : CurrencyMismatchChannel Node where
  coversNode := fun _ => true
  readsDebtCurrency := true
  readsAssetCurrency := true
  readsRevenueCurrency := true
  readsDerivativeHedge := true
  readsFundingLink := false
  granularity := some MismatchGranularity.nodeLevel
  recipient := DisclosureRecipient.supervisor

/--
다국 상장기업의 공개 공시를 통화 불일치의 경로로 읽은 것.

**대응 비형식 개념:** 같은 축이 공개 공시에서 서지 않는다는 것이 이 파일의 산출이므로 그 경로를
따로 세운다.

**이 정의가 배제하는 사례:**
상장기업의 공시가 자산의 표시 통화를 낸다고 보는 자리. 지목 참조로 연 편이 현금과 단기투자의 표시
통화를 알 수 없고 그 자료가 공개되지 않는다고 명시하고 한 체제의 상장기업에 대해서만 그 자료를
따로 얻었다고 적으므로, 다국의 공개 공시에서 그 축이 서지 않는다. 이 경로는 그 칸을 거짓으로 들며,
한 체제의 자료를 합치면 그 체제 밖에서 거짓인 주장이 선다.
조달처: E-64 §2-3 「한 체제의 상장기업에 대해서만 표시 통화 자료를 따로 얻었다」

**기각한 대체 정의:**
그 경로가 자산의 표시 통화를 낸다고 두는 안. 현금과 단기투자의 금액이 공시에 서므로 통화도 읽히는
것처럼 보이나, 지목 참조로 연 편이 그 표시 통화를 알 수 없고 그 자료가 공개되지 않는다고 명시하며
그 대신 현금 축적의 증분과 환율의 변화율과 발행 이력을 결합해 불일치를 직접 재지 않고 그 귀결을
재는 설계로 간다. 한 체제의 상장기업 자료를 그 경로에 합쳐 자산 축을 참으로 두는 안도 기각했다. 그
자료가 한 체제에만 있고 이 경로가 다국을 보는 것이어서, 합치면 그 경로가 어느 노드에서나 자산의
통화를 낸다고 주장하게 되고 그 주장이 그 체제 밖에서 거짓이다.

**값을 담지 않는다.**
-/
-- DD:CF-2753
def listedFirmDisclosureChannel {Node : Type} : CurrencyMismatchChannel Node where
  coversNode := fun _ => true
  readsDebtCurrency := true
  readsAssetCurrency := false
  readsRevenueCurrency := false
  readsDerivativeHedge := false
  readsFundingLink := false
  granularity := some MismatchGranularity.nodeLevel
  recipient := DisclosureRecipient.publicReader

/--
국제투자대조표의 통화 구성을 통화 불일치의 경로로 읽은 것.

**대응 비형식 개념:** 나라 입도의 경로가 두 축을 내면서 수익과 파생을 내지 못하는 것이 입도의
가름을 받치므로 그 자리가 이 선언이다.

**이 정의가 배제하는 사례:**
경로가 값을 내면 그 값이 실측이라고 보는 자리. 나라 수준 통화 구성 자료를 든 기록이 당국이 보고한
실측을 쓰고 없는 자리는 합성 가중치로 메운 뒤 그 둘을 이어 붙인다고 적으면서 그 합성의 편향이
신흥국의 자국통화 발행 비중을 과소추정하는 방향임을 적으므로, 그 계열의 한 칸이 실측도 추정도
아니다. 이 경로는 그 칸을 내는가만 받으므로 그 혼합을 담지 않으며, 그 결손은 구멍으로 등재되어
있다.
조달처: E-41 §2-2 「신흥국의 자국통화 발행 비중이 과소추정된다」

**기각한 대체 정의:**
그 경로가 노드 입도로 값을 낸다고 두는 안. 그 자료가 자산과 부채를 통화별로 가르므로 불일치의 두
축이 읽히나 지목 참조로 연 기록이 그 단위를 나라와 연도로 적고 부문의 가름이 없다고 명시하므로,
노드 입도로 두면 입도를 두 칸 올리는 일이 된다. 그 경로가 내는 값을 실측으로 두는 안도 기각했다.
그 기록이 당국이 보고한 실측과 합성 가중치로 메운 값이 한 계열에 이어 붙는다고 적고 그 편향의
방향까지 들므로, 실측으로 두면 그 혼합이 판정에서 사라지고 그 결손은 이미 구멍으로 올라 있다.

**값을 담지 않는다.**
-/
-- DD:CF-2753
def externalPositionStatisticsChannel {Node : Type} : CurrencyMismatchChannel Node where
  coversNode := fun _ => false
  readsDebtCurrency := true
  readsAssetCurrency := true
  readsRevenueCurrency := false
  readsDerivativeHedge := false
  readsFundingLink := false
  granularity := some MismatchGranularity.jurisdictionLevel
  recipient := DisclosureRecipient.publicReader

/--
통화 불일치를 읽는 경로를 모은 목록.

**대응 비형식 개념:** 경로가 늘 때 판정을 함께 고치지 않아도 되게 하려면 그 전량을 모은 목록이
서야 한다.

**이 정의가 배제하는 사례:**
목록에 든 경로가 그 축을 읽는 경로의 전량이라고 보는 자리. 나라 수준 통화 구성 자료를 든 기록이 그
자료가 50개국과 일정 기간을 덮는다고 적고 부문과 상대국과 품목의 가름이 없다고 적으므로, 그 범위
밖의 주체를 보는 경로가 있을 수 있다. 이 목록은 이 회차가 실측으로 확인한 경로만 들며 그
전량이라고 주장하지 않는다.
조달처: E-41 §1 「50개국, 1990년부터 2017년까지」

**기각한 대체 정의:**
경로를 목록으로 모으지 않고 정리마다 경로를 직접 드는 안. 목록 선언이 하나 줄지만 경로가 늘 때 그
정리를 함께 고쳐야 하고 고치지 않으면 새 경로가 판정에서 빠지는데 그 빠짐이 컴파일에서 드러나지
않으며, 자산 구성의 공시 경로가 경로 여섯을 목록으로 모아 필터로 전량을 잰 선례가 그 자리를 목록에
둔다. 아무것도 내지 않는 경로를 그 목록에 함께 넣는 안도 기각했다. 그 경로는 구조가 비어 있지
않음을 보이는 자리여서 실재하는 공시가 아니고, 넣으면 다섯을 모두 내는 경로가 없다는 판정이
실재하지 않는 경로 하나로도 참이 되어 그 판정이 공허해진다.

**값을 담지 않는다.**
-/
-- DD:CF-2753
def currencyMismatchChannels (Node : Type) : List (CurrencyMismatchChannel Node) :=
  [supervisoryCreditRegistryChannel, listedFirmDisclosureChannel,
    externalPositionStatisticsChannel]

/--
그 경로들 가운데 통화 불일치를 축 다섯 모두에서 내는 것이 하나도 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록에 든 어느 경로가 한 주체에 대해 부채와 자산과 수익의 표시 통화와 파생 헤지와 조달 연결을
함께 내야 한다. 그러면 통화 불일치를 재는 공시 경로가 실재하고, 그 결손을 관측층에 등재하는 것이
이 파일의 산출이라는 판정이 그 자리에서 뒤집힌다. 그때는 정의층이 가른 두 개념 가운데 조달형도
측정 소스를 갖는다.

**가정을 두지 않는다.**

**이 진술이 축을 다섯으로 가른 사유를 받친다.** 축을 한 칸으로 접으면 어느 경로도 전량을 내지
못한다는 것만 서고 어느 축이 어디서 비는지가 서지 않는다. 다섯으로 가르면 경로마다 비는 자리가
달라 그 차이가 뒤의 아크가 조달처를 고를 때 읽힌다.

**T-3 분류:** 보조 보정이 아니다. 통화 불일치에 측정 소스가 없다는 것이 이 파일의 산출이며, 그
없음을 경로의 실물에서 받치는 것이 이 명제다. 증명이 각 경로의 칸을 읽어 닫히더라도 그 칸의 값이
지목 참조로 연 세 기록에서 유도된 것이므로, 이 명제가 드는 것은 정의의 전개가 아니라 그 세 기록의
귀결이다.
-/
-- DD:CF-2753
theorem no_channel_answers_all_axes {Node : Type} :
    ∀ C ∈ currencyMismatchChannels Node, ∀ n : Node, C.answersAllAxes n = false := by
  intro C hC n
  cases hC
  · rfl
  · rename_i hC
    cases hC
    · rfl
    · rename_i hC
      cases hC
      · rfl
      · rename_i hC
        cases hC

/--
그 경로들 가운데 조달 연결을 내는 것이 하나도 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록에 든 어느 경로가 어느 부채가 어느 통화의 자산을 조달했는지를 내야 한다. 그러면 조달형
불일치가 공시에서 읽히고, 그 축에 소스가 없다는 것을 새 항으로 받는 설계가 뜻을 잃는다. 자료의
결손이 아니라 화폐가 대체 가능해서 그 사슬이 끊긴다는 지목 참조의 문면도 그때는 그 축에 걸리지
않는다.

**가정을 두지 않는다.**

**다섯 축 가운데 이 축만 전량이 비는 것이 이 명제의 요지다.** 다른 넷은 경로마다 참인 자리가 있어
입도와 수신자를 바꾸면 메워지는 데 비해, 이 축은 어느 입도에서도 어느 수신자에게도 서지 않으므로
그 결손이 측정 체제의 선택으로 메워지지 않는다.

**T-3 분류:** 보조 보정이 아니다. 앞의 명제가 다섯을 합성한 술어로 결손을 들고 이 명제가 그 결손이
어느 축에 몰려 있는지를 든다. 앞의 명제가 이 명제에서 따라 나오나 그 역이 서지 않으므로 둘이 드는
것이 다르며, 조달형에 소스가 없다는 것이 새 항을 세운 사유이므로 그 사유가 이 자리에서 형식층에
선다.
-/
-- DD:CF-2753
theorem funding_link_unread_by_every_channel {Node : Type} :
    ∀ C ∈ currencyMismatchChannels Node, C.readsFundingLink = false := by
  intro C hC
  cases hC
  · rfl
  · rename_i hC
    cases hC
    · rfl
    · rename_i hC
      cases hC
      · rfl
      · rename_i hC
        cases hC
end CrisisFramework.Observation
