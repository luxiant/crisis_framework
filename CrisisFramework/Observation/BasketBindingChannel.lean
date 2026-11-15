/-
관측층 — 바스켓 표시 청구권의 묶음이 공시에서 어떻게 관측되는가

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원이며 수치 리터럴도
      금지), L-9(import 방향은 단방향), A-1(`axiom` 금지), A-3(witness 의무), A-8(변이 검사와
      논리 결합의 증거), C-1·C-2(`noncomputable` 과 `Classical` 금지), C-3(판정 술어의 결정
      가능성), C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시),
      W-11(관측층을 정의층과 같은 페이즈에서 병행한다).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 축을 내는가만 `Bool` 로 들고, 다리와 의무와
통화를 구체 타입으로 박지 않는다.

**이 파일이 세우는 것은 바스켓 표시 청구권의 묶음이 공시에서 어떻게 관측되는가 또는 관측되지
않는가다.** 금융전문 표준이 통화 필드를 필수로 두고 그 어휘를 닫힌 코드 집합으로 강제하므로 한 전문이
통화 하나를 들고 바스켓이 여러 전문으로 서며, 그 전문 안에 어느 다리가 어느 의무에 묶이는지가 서지
않는다.

**그러므로 이 명세가 내는 것은 묶음의 값이 아니라 묶음을 내는 경로의 부재다.** 통화와 금액이 둘 다
필수 필드로 읽히는데도 묶음이 읽히지 않으므로, 그 결손이 자료의 양에서 오지 않고 명세의 단위가 소스가
아니라 소스와 축의 짝이라는 데서 온다.

**통화별 몫의 결손이 금액의 결손이 아니라 묶음의 결손에서 유도된다.** 몫을 내려면 다리의 금액과 그
다리가 어느 의무에 묶이는지가 함께 서야 하는데 앞은 필수 필드이고 뒤가 어디에도 없으므로, 그 몫의
결손이 재야 할 것이 정해지지 않은 데서 오지 않고 그것을 내는 자리가 없는 데서 온다. 그 결손은 차단의
축 가운데 자료의 공백이며 이 프로젝트가 푸는 정의 공백이 아니다.

**경로 전량을 훑는 판정을 목록 전칭이 아니라 목록 접기로 둔다.** 전칭으로 두면 목록 멤버십을 푸는
증명이 명제 외연성을 끌어오는데 접기로 두면 계산으로 닫혀 공리가 비며, 관측층의 공리 기준선이 비어
있으므로 그 차이가 기준선 초과를 가른다.

**정리의 증명과 적재 선언은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며, 이
파일이 딛는 적재 선언도 집행이 쓴다. 그 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을
부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

/--
바스켓 표시 청구권의 묶음을 내는 공시 경로.

**대응 비형식 개념:** 한 공시가 바스켓의 어느 축을 내는가. 다리의 표시 통화를 내는 축과 그 다리의
금액을 내는 축과 그 다리가 어느 의무에 묶이는지를 내는 축이 경로마다 따로 갈리므로 그 갈림을 칸으로
든다.

**이 정의가 배제하는 사례:**
통화와 금액을 내는 전문이 그 다리가 어느 의무에 묶이는지까지 낸다고 보는 읽기. 금융전문 표준을 훑은
기록이 그 전문의 범위가 신용장의 조건을 알리는 것이고 발행 뒤의 흐름을 담지 않는다고 적으므로, 낸다고
보면 한 전문이 자기 다리의 값을 드는 것과 여러 다리를 한 의무로 묶는 것이 같은 칸에 선다.
조달처: E-42 §2-6 「발행 뒤의 흐름을 이 메시지가 담지 않는다」

**기각한 대체 정의:**
통화와 금액을 한 칸으로 접는 안. 그 표준의 필수 필드가 둘을 함께 담으므로 그 전문에 대해서는 접어도
값이 같으나, 금액에 허용 편차와 추가 금액을 더하는 선택 필드가 따로 서서 금액이 하나의 수로 서지
않는데 통화는 그 선택에 걸리지 않으므로 두 축의 결손이 갈리는 자리가 사라진다. 묶음의 축을 통화의 축의
부정으로 두는 안도 기각했다. 통화를 내지 않는 경로가 묶음을 내는 것으로 서며, 어느 축도 내지 않는
경로가 그 부정에서 참이 되어 아무것도 내지 않는 자리가 묶음을 내는 자리로 둔갑한다.

**값을 담지 않는다.**
-/
-- DD:CF-3770
structure BasketBindingChannel where
  /-- 그 경로가 그 다리의 표시 통화를 내는가. -/
  readsLegCurrency : Bool
  /-- 그 경로가 그 다리의 금액을 내는가. -/
  readsLegAmount : Bool
  /-- 그 경로가 그 다리가 어느 의무에 묶이는지를 내는가. -/
  readsObligationIdentity : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/-- witness (A-3). **무엇을 증거하는가.** `BasketBindingChannel` 이 비어 있지 않다. 세 축을
하나도 내지 않는 경로 하나를 든다. -/
-- DD:CF-3770
def BasketBindingChannel.noSource : BasketBindingChannel where
  readsLegCurrency := false
  readsLegAmount := false
  readsObligationIdentity := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 바스켓의 묶음을 답하는가.

**대응 비형식 개념:** 한 경로만으로 어느 다리들이 한 의무를 이루는지가 재어지는가. 다리의 표시
통화와 그 다리가 묶이는 의무가 둘 다 한 경로에서 읽혀야 그 묶음이 그 경로에서 재어진다.

**이 정의가 배제하는 사례:**
의무의 식별만 읽히면 묶음이 재어진다고 보는 읽기. 금융전문 표준을 훑은 기록이 같은 메시지에서 축마다
관측 가능성이 갈린다고 적고 명세의 단위가 소스와 축의 짝이어야 한다고 적으므로, 한 축으로 답을 세우면
통화가 갈리는 다리들을 한 의무로 묶는 것과 통화를 모르고 묶는 것이 같은 값으로 선다.
조달처: E-42 §3-2 「같은 메시지에서 통화와 시점과 금액은 필수이고 어휘가 닫혀 있는데」

**기각한 대체 정의:**
세 축의 논리곱으로 두는 안. 더 좁은 자리에서만 참이 되나 금액은 묶음의 성립과 다른 축이고 그 금액이
선택 필드로 갈리는 자리가 따로 서므로, 넣으면 금액의 결손이 묶음의 결손으로 세어진다.

**값을 담지 않는다.** 두 칸의 논리곱이며 수 타입을 언급하지 않는다.
-/
-- DD:CF-3770
def BasketBindingChannel.answersBinding (ch : BasketBindingChannel) : Bool :=
  ch.readsLegCurrency && ch.readsObligationIdentity

/--
신용장의 발행을 알리는 전문을 바스켓의 다리를 읽는 경로로 읽은 것.

**대응 비형식 개념:** 금융전문 표준이 신용장의 조건을 알리는 메시지로 정한 서식을 바스켓의 한 다리를
읽는 경로로 세운 것. 그 서식이 통화 코드와 금액을 필수 필드로 함께 담는다.

**이 정의가 배제하는 사례:**
그 필수 필드가 신용장의 금액을 하나의 수로 낸다고 보는 읽기. 그 표준을 훑은 기록이 그 필드의 값과
허용 편차와 추가 금액이 함께 있어야 범위가 정해진다고 적으므로, 하나의 수로 보면 그 다리의 금액이
단일 값으로 읽히고 선택 필드가 비어 있는 자리와 서 있는 자리가 구별되지 않는다.
조달처: E-42 §2-3 「32B 의 값과 허용 편차와 추가 금액이 함께」

**기각한 대체 정의:**
이 경로가 의무의 식별까지 내는 것으로 두는 안. 한 경로가 묶음을 답하여 이 파일의 산출이 사라지는데,
그 전문의 범위가 발행을 알리는 것이고 여러 전문을 한 의무로 묶는 식별자를 그 서식이 필수로 두지
않으므로 두면 공시가 내지 않는 축이 내는 것으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-3770
def documentaryCreditIssue : BasketBindingChannel where
  readsLegCurrency := true
  readsLegAmount := true
  readsObligationIdentity := false
  recipient := DisclosureRecipient.supervisor
  provenance := MeasurementProvenance.officialReport

/--
상업송장의 묶음을 바스켓의 다리를 읽는 경로로 읽은 것.

**대응 비형식 개념:** 신용장 거래의 통일 규칙이 요구하는 상업송장을 바스켓의 한 다리를 읽는 경로로
세운 것. 그 규칙이 송장의 표시 통화를 신용장의 것과 같게 강제한다.

**이 정의가 배제하는 사례:**
송장의 통화가 신용장과 같아야 한다는 것에서 여러 송장이 한 의무에 묶인다는 것이 유도된다고 보는 읽기.
그 규칙을 훑은 기록이 상업송장은 신용장과 같은 통화로 발행해야 한다고만 적으므로, 유도된다고 보면 같은
통화를 쓰는 다른 신용장의 송장이 같은 의무의 다리로 세어진다.
조달처: E-21 §8 「상업송장은 신용장과 같은 통화로 발행해야 한다」

**기각한 대체 정의:**
이 경로를 목록에서 빼고 발행 전문 하나로 갈음하는 안. 목록이 짧아지나 통화의 축이 한 경로에서만 읽히는
것과 두 경로에서 읽히는 것이 다른 사실이며, 갈음하면 그 축의 값이 한 서식의 필수 필드 하나에 걸려 그
축이 공시의 성질을 재는지 그 서식의 설계를 재는지가 구별되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3770
def commercialInvoiceSet : BasketBindingChannel where
  readsLegCurrency := true
  readsLegAmount := true
  readsObligationIdentity := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
바스켓의 묶음을 내는 경로의 목록.

**대응 비형식 개념:** 외부 관측자가 바스켓의 세 축을 읽을 수 있는 자리의 전량. 목록 전량을 훑는
판정이 이 목록에 걸린다.

**이 정의가 배제하는 사례:**
축을 하나씩 내는 경로가 둘이면 그 축들이 합쳐져 묶음이 읽힌다고 보는 읽기. 금융전문 표준을 훑은
기록이 관측 명세를 소스 단위로 색인하면 축마다의 갈림이 사라진다고 적으므로, 합친다고 보면 소스와
축의 짝이 아니라 소스가 명세의 단위가 되고 묶음의 결손이 경로의 합집합에서 메워진 것으로 선다.
조달처: E-42 §3-2 「그러므로 관측 명세를 소스 단위로 색인하면 이 갈림이 사라진다」

**기각한 대체 정의:**
수취인으로 걸러 일반 관측자에게 가는 것만 목록에 두는 안. 두 경로의 수취인이 갈려 그 거르기가 지금
하나를 걸러 내는데, 걸러 내면 감독 당국에게만 가는 자리에서도 묶음이 읽히지 않는다는 사실이 목록에서
사라지고 그 결손이 공표의 재량에서 온 것으로 읽힌다.

**값을 담지 않는다.**
-/
-- DD:CF-3770
def basketBindingChannels : List BasketBindingChannel :=
  [documentaryCreditIssue, commercialInvoiceSet]

/--
바스켓의 묶음이 그 경로 목록에서 관측되는가.

**대응 비형식 개념:** 어느 다리들이 한 의무를 이루는지를 외부 관측자가 낼 수 있는가. 낼 수 있으면
성립을 내고 낼 수 없으면 측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
통화가 필수 필드로 읽히므로 묶음도 읽힌다고 보는 읽기. 그 표준을 훑은 기록이 통화 코드와 금액을 함께
담는 필드가 필수라고 적되 여러 전문을 한 의무로 묶는 식별자를 필수로 들지 않으므로, 읽힌다고 보면 한
다리의 값이 서는 것과 다리들이 묶이는 것이 같은 답으로 선다.
조달처: E-42 §2-2 「32B 가 통화 코드와 금액을 함께 담고 필수다」

**기각한 대체 정의:**
읽을 자리가 없을 때 구조가 그 대상을 담지 않는다는 까닭을 내는 안. 그 까닭이 형식층의 결손을 드는
자리인데 이 페이즈가 그 묶음을 정의층에 세우므로 담는 대상이 있으며, 그러면 조달로 풀리는 결손이
구조의 결손으로 적힌다. 귀속이 유일하지 않다는 까닭을 내는 안도 기각했다. 그 까닭은 자료가 있어도 값이
하나로 정해지지 않는 자리인데 여기서는 그 자료 자체가 공시에 서지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3770
def basketBindingObserved (chs : List BasketBindingChannel) : ObservedTruth :=
  if chs.any (fun c => c.answersBinding) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
그 경로가 바스켓의 통화별 몫을 답하는가.

**대응 비형식 개념:** 한 경로만으로 바스켓의 금액이 통화마다 어떻게 갈리는지가 재어지는가. 다리의
금액과 그 다리가 묶이는 의무가 둘 다 한 경로에서 읽혀야 그 몫이 그 경로에서 재어진다.

**이 정의가 배제하는 사례:**
금액이 필수 필드로 읽히므로 통화별 몫도 읽힌다고 보는 읽기. 그 표준을 훑은 기록이 같은 메시지에서
축마다 관측 가능성이 갈린다고 적으므로, 읽힌다고 보면 한 다리의 금액이 서는 것과 여러 다리의 금액이
한 의무 안에서 통화마다 갈리는 것이 같은 칸에 선다.
조달처: E-42 §3-2 「같은 메시지에서 통화와 시점과 금액은 필수이고 어휘가 닫혀 있는데」

**기각한 대체 정의:**
표시 통화의 축을 이 판정에 더하는 안. 몫이 통화에 걸리므로 통화의 축이 필요해 보이나 그 축이 묶음의
판정에서 이미 서 있고 이 판정이 묶음의 판정과 갈리는 자리는 금액의 축이므로, 더하면 두 판정이 같은
칸을 공유하여 몫의 결손이 묶음의 결손에서 유도된다는 것이 보이지 않는다.

**값을 담지 않는다.** 두 칸의 논리곱이며 수 타입을 언급하지 않는다.
-/
-- DD:CF-3771
def BasketBindingChannel.answersCurrencyWeight (ch : BasketBindingChannel) : Bool :=
  ch.readsLegAmount && ch.readsObligationIdentity

/--
바스켓의 통화별 몫이 그 경로 목록에서 관측되는가.

**대응 비형식 개념:** 바스켓의 금액이 통화마다 어떻게 갈리는지를 외부 관측자가 낼 수 있는가. 낼 수
있으면 성립을 내고 낼 수 없으면 측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
그 몫의 결손을 이 프로젝트가 푸는 정의 공백으로 보는 읽기. 그 표준을 훑은 기록이 통화와 금액을 담는
필드가 필수이고 어휘가 닫혀 있다고 적어 재야 할 것이 공시에 구조화되어 있음을 밝히므로, 정의 공백으로
보면 재야 할 것이 정해졌는데 그것을 내는 자리가 없는 것과 무엇을 재야 하는지가 서지 않은 것이 한 칸에
든다.
조달처: E-42 §2-2 「어휘가 표준으로 닫혀 있으므로 자유 텍스트가 아니다」

**기각한 대체 정의:**
그 몫을 묶음의 판정 하나로 갈음하고 이 선언을 세우지 않는 안. 선언이 하나 줄고 두 판정의 값이 이
목록에서 같으나, 묶음이 읽히는 경로가 뒤에 서면 그 경로가 금액을 내지 않을 수 있어 두 값이 갈리며
그때 이 몫의 결손이 묶음의 결손에 흡수되어 보이지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3771
def basketCurrencyWeightObserved (chs : List BasketBindingChannel) : ObservedTruth :=
  if chs.any (fun c => c.answersCurrencyWeight) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
어느 경로도 바스켓의 묶음을 답하지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
다리의 표시 통화와 그 다리가 묶이는 의무를 함께 내는 경로가 하나라도 서야 한다. 그 관측은 그 묶음이
한 공시에서 재어진다는 뜻이며, 그러면 이 파일이 세우는 결손이 사라지고 그 묶음의 관측 명세가 경로를
가로지르는 합치기 없이 닫힌다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 통화가 필수 필드로 읽히는데도 그 묶음이 답되지 않는다는 것이 이 파일의 산출이고,
관측층에 등재되는 소스 없음이 주요 산출물이라는 요구가 이 자리에서 축의 갈림으로 서므로 기여 목록에
든다.

**진술의 꼴.** 목록 멤버십의 전칭으로 두지 않는 사유는 그 꼴이 명제 외연성을 끌어오는데 관측층의
공리 기준선이 비어 있다는 데 있다.
-/
-- DD:CF-3770
theorem no_channel_answers_basket_binding :
    basketBindingChannels.all (fun c => !c.answersBinding) = true := by
  sorry

/--
통화와 금액의 축은 읽히고 의무 식별의 축은 어느 경로에서도 읽히지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
통화나 금액을 내는 경로가 아예 없거나, 의무 식별을 내는 경로가 하나라도 서야 한다. 앞의 관측은 세 축이
함께 비어 있다는 뜻이고 뒤의 관측은 그 결손이 조달로 풀린다는 뜻이므로, 이 명제가 그 결손이 세 축 가운데
마지막 것에만 걸린다는 것을 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 소스가 아예 없는 것과 축 하나에만 없는 것이 다른 사실임을 보이고 그 갈림이 해소
경로를 가르므로 기여 목록에 든다.
-/
-- DD:CF-3770
theorem basket_binding_axes_split :
    basketBindingChannels.all (fun c => c.readsLegCurrency) = true
      ∧ basketBindingChannels.all (fun c => c.readsLegAmount) = true
      ∧ basketBindingChannels.all (fun c => !c.readsObligationIdentity) = true := by
  sorry

/--
묶음의 판정이 각 인자에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 참인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는 뜻이며,
그러면 통화만 내고 의무 식별을 내지 않는 경로가 그 묶음을 답하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로, 각
인자가 홀로 참인 자리를 이 정리가 든다.

**갱신 문법으로 각 인자가 홀로 참인 자리를 든다.** 의무 식별만 참인 경로가 실재하는 인스턴스에 서지 않으므로 새 경로를
세우지 않고 이미 선 값의 그 칸만 바꾼 것을 리터럴로 든다.
-/
-- DD:CF-3770
theorem basket_binding_answer_pins_each_conjunct :
    documentaryCreditIssue.answersBinding = false
      ∧ { documentaryCreditIssue with
            readsObligationIdentity := true }.answersBinding = true
      ∧ { documentaryCreditIssue with
            readsLegCurrency := false,
            readsObligationIdentity := true }.answersBinding = false
      ∧ BasketBindingChannel.noSource.answersBinding = false := by
  sorry

/--
그 묶음의 관측이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 경로 목록에서 답이 성립으로 서야 한다. 그 관측은 그 묶음이 공시에서 재어진다는 뜻이며, 그러면 이
아크가 정의층에 세운 사상이 관측층에서 값을 갖고 그 결손이 기록될 자리가 없다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 타입으로 서는 것을 보이고, 그 등재가 이 페이즈가
정의층에 세운 사상에서 실제로 선다는 것이 이 정리의 산출이므로 기여 목록에 든다.
-/
-- DD:CF-3770
theorem basket_binding_observed_undetermined :
    basketBindingObserved basketBindingChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  sorry

/--
통화별 몫의 판정이 각 인자에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 참인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는 뜻이며,
그러면 금액만 내고 의무 식별을 내지 않는 경로가 그 몫을 답하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 판정 반환
함수를 새로 세우면 그 논리 결합마다 홀로 값을 가르는 경로를 증거로 들어야 하므로, 묶음의 판정을 드는
정리가 이 자리를 갈음하지 않는다.
-/
-- DD:CF-3771
theorem currency_weight_answer_pins_each_conjunct :
    documentaryCreditIssue.answersCurrencyWeight = false
      ∧ { documentaryCreditIssue with
            readsObligationIdentity := true }.answersCurrencyWeight = true
      ∧ { documentaryCreditIssue with
            readsLegAmount := false,
            readsObligationIdentity := true }.answersCurrencyWeight = false := by
  sorry

/--
금액이 읽히는데도 통화별 몫의 관측이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 경로 목록에서 그 몫의 답이 성립으로 서거나, 금액의 축이 어느 경로에서도 읽히지 않아야 한다. 앞의
관측은 그 몫이 공시에서 재어진다는 뜻이고 뒤의 관측은 그 결손이 금액의 결손이라는 뜻이므로, 이 명제가
그 몫의 결손이 금액에서 오지 않고 의무 식별에서 온다는 것을 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 몫을 이 아크가 받지 않고 관측층의 소스 없음으로 등재하기로 한 판정이 이
자리에서 실물로 서고, 그 결손이 재야 할 것이 정해지지 않은 데서 오지 않는다는 것이 이 정리의 산출이므로
기여 목록에 든다.
-/
-- DD:CF-3771
theorem basket_currency_weight_undetermined :
    basketBindingChannels.all (fun c => c.readsLegAmount) = true
      ∧ basketCurrencyWeightObserved basketBindingChannels
          = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  sorry

end CrisisFramework.Observation
