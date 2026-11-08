/-
관측층 — 중앙은행 통화 교환 약정의 측정 사상

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원이며 수치 리터럴도
      금지), L-9(import 방향은 단방향), A-1(`axiom` 금지), A-3(witness 의무),
      C-1·C-2(`noncomputable` 과 `Classical` 금지), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-8(witness 의 서술),
      T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시), T-6(존재 형태).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 축을 내는가만 `Bool` 로 들고, 시점과 수 체계는
매개변수로 받아 구체 타입을 박지 않는다.

**이 파일이 세우는 것은 통화 교환 약정의 도달 범위가 공표 수치에서 어떻게 관측되는가 또는
관측되지 않는가다.** 정의층이 그 범위를 고리 둘로 세우는데 그 둘이 서로 다른 공시에서 오므로 한
경로만으로는 그 범위가 서지 않는다.

**끝내는 통지를 내는 공표 경로가 하나도 없는 것이 이 파일의 산출이다.** 관측층에 등재되는 소스
없음이 프레임워크의 주요 산출물 가운데 하나이므로 그 영이 결손의 기록이고 결함의 기록이 아니다.

**답할 항의 답이 발행자에 걸린다.** 같은 물음이 두 고리를 함께 덮는 발행자에서는 참거짓을 내고 그
가운데 하나만 덮는 발행자에서는 측정 소스 없음을 내므로, 그 갈림이 측정 가능성이 변수에 붙지 않고
쌍에 붙는다는 사실을 타입으로 든다.

**정리의 증명은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채운다. 그 진술이
증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께
확인했으나, 쓴 전술은 싣지 않는다.

**경로 전량을 훑는 판정을 목록 전칭이 아니라 목록 접기로 둔다.** 전칭으로 두면 목록 멤버십을 푸는
증명이 명제 외연성을 끌어오는데 접기로 두면 계산으로 닫혀 공리가 비며, 관측층의 공리 기준선이
비어 있으므로 그 차이가 기준선 초과를 가른다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.CentralBankSwapLine
import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

open CrisisFramework.Definition

/--
한 경로가 값을 내는 단위.

**대응 비형식 개념:** 공시가 어느 묶음을 단위로 값을 내는가. 한 국제 기구의 지침이 활성화된 자금만
거시 통계에 기재하고 기본 약정의 최대 금액은 기재하지 않는다고 적어 같은 약정의 두 층이 서로 다른
단위로 기재됨을 밝힌다.

**이 정의가 배제하는 사례:**
공시의 단위를 쌍 하나로만 보는 읽기. 그 지침이 요청 중앙은행에 활성화된 자금만 기재한다고 적어
집계된 수치가 쌍별로 풀리지 않는 자리를 두므로, 단위를 하나로 두면 그 집계가 쌍별 값으로 읽힌다.
조달처: E-63 §3-2 「요청 중앙은행에 활성화된 자금만 거시 통계에 기재하고 기본 약정의 최대 금액은 기재하지 않는다」

**기각한 대체 정의:**
입도를 쌍별인가 아닌가의 두 값으로 두는 안. 칸이 짧아지나 수취자 하나를 단위로 내는 공시와 여러
쌍을 묶은 집계가 같은 값으로 서고, 앞은 그 수취자의 쌍이 하나일 때 쌍별 값으로 풀리는데 뒤는 풀리지
않으므로 그 갈림이 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
inductive SwapLineGranularity where
  /-- 공급자와 수취자의 쌍을 단위로 값을 내는 입도. -/
  | pairLevel
  /-- 수취자 하나를 단위로 값을 내는 입도. -/
  | recipientLevel
  /-- 여러 쌍을 묶은 집계를 단위로 값을 내는 입도. -/
  | aggregateLevel
  deriving DecidableEq, Repr

/--
그 값이 선 성질.

**대응 비형식 개념:** 그 값이 당국의 공식 자료인가 읽는 쪽의 추정인가. 한 국제 기구의 지침이
활성화와 부채와 사용에 관한 가정이 직원 추정이고 당국이 제공한 공식 자료가 아님을 투명하게 밝혀야
한다고 적는다.

**이 정의가 배제하는 사례:**
공표된 값을 전부 공식 자료로 보는 읽기. 그 지침이 그 가정들을 직원 추정이라고 밝혀야 한다고 적어
공표의 사실과 공식성의 사실을 가르므로, 둘을 접으면 추정으로 메운 칸이 공식 자료로 읽힌다.
조달처: E-63 §5-3 「활성화와 부채와 사용에 관한 가정이 직원 추정이고 당국이 제공한 공식 자료가 아님을 투명하게 밝혀야 한다」

**기각한 대체 정의:**
값의 성질을 경로가 아니라 축마다 두는 안. 한 경로의 어떤 축이 공식이고 다른 축이 추정인 자리를
담을 수 있으나, 그 지침이 성질을 자료의 출처에 붙이고 축에 붙이지 않으므로 그 세분이 공시에서
유도되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
inductive MeasurementProvenance where
  /-- 당국이 제공한 공식 자료. -/
  | officialReport
  /-- 공표 자료에서 읽는 쪽이 유도한 추정. -/
  | staffEstimate
  deriving DecidableEq, Repr

/--
약정의 축마다 그 값을 내는 공시 경로.

**대응 비형식 개념:** 한 공시가 통화 교환 약정의 어느 축을 내는가. 축이 여럿이고 경로마다 내는
축이 다르므로 그 갈림을 칸으로 든다.

**이 정의가 배제하는 사례:**
한 발행자의 공시가 어느 축을 내지 않을 때 같은 발행자의 다른 문면이 그것을 메운다고 보는 읽기. 한
발행자의 공시를 훑은 기록이 그 결손이 같은 발행자의 다른 문면에서도 메워지지 않는다고 적으므로,
발행자를 단위로 두면 그 결손이 경로의 결손으로 보이고 발행자의 결손으로 보이지 않는다.
조달처: E-61 §2-2 「그 결손이 같은 발행자의 다른 문면에서도 메워지지 않는다」

**기각한 대체 정의:**
경로를 발행자별 구조체로 두고 축마다 칸을 두지 않는 안. 발행자의 결손이 한 자리에 모이나 한
발행자가 여러 공시 경로를 갖고 그 경로마다 내는 축이 달라 그 갈림이 사라진다. 그리고 축의 열거를
타입으로 두고 경로가 그 열거의 집합을 드는 안도 기각했다. 칸이 늘고 줄 때 그 열거를 함께 고쳐야
하는데 축의 수가 정의층 구조체의 필드 수에 매여 있으므로 그 둘이 갈릴 수 있다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
structure SwapLineChannel (Node : Type) where
  /-- 그 경로가 공급자 쪽을 덮는가. -/
  coversSupplier : Node → Bool
  /-- 그 경로가 수취자 쪽을 덮는가. -/
  coversRecipient : Node → Bool
  /-- 그 경로가 공급되는 통화를 내는가. -/
  readsSuppliedCurrency : Bool
  /-- 그 경로가 예정 종료일을 내는가. -/
  readsScheduledEnd : Bool
  /-- 그 경로가 약정의 한도를 내는가. -/
  readsCap : Bool
  /-- 그 경로가 그 쌍의 상호성을 내는가. -/
  readsReciprocity : Bool
  /-- 그 경로가 성립 조건이 붙는 자리를 내는가. -/
  readsAdmissionLocus : Bool
  /-- 그 경로가 재대출 적격성을 내는가. -/
  readsOnlendingEligibility : Bool
  /-- 그 경로가 접근의 둘째 층인 발동을 내는가. -/
  readsActivation : Bool
  /-- 그 경로가 접근의 셋째 층인 가용을 내는가. -/
  readsDrawdownAvailability : Bool
  /-- 그 경로가 약정을 끝내는 통지를 내는가. -/
  readsTermination : Bool
  /-- 그 경로가 공급하는 쪽의 환율 변동 노출을 내는가. -/
  readsSupplierFxExposure : Bool
  /-- 그 경로가 받는 쪽의 환율 변동 노출을 내는가. -/
  readsRecipientFxExposure : Bool
  /-- 그 경로가 값을 내는 입도. 어느 축도 내지 않는 경로는 이 자리가 비어 있다. -/
  granularity : Option SwapLineGranularity
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/--
그 경로가 축을 하나라도 내는가.

**대응 비형식 개념:** 그 공시가 이 물음에 대해 아무것도 내지 않는가. 축의 결손이 경로마다 다르므로
전부 비는 경로를 가르는 자리가 따로 선다.

**이 정의가 배제하는 사례:**
축을 하나도 내지 않는 경로를 목록에서 빼는 읽기. 한 발행자의 공시를 훑은 기록이 관측층에 등재되는
소스 없음이 주요 산출물이라는 요구가 이 자리에서 발행자별로 갈린 꼴로 선다고 적으므로, 빈 경로를
빼면 그 발행자가 아무것도 내지 않는다는 사실이 목록에서 사라진다.
조달처: E-63 §6-4 「관측층에 등재되는 소스 없음이 주요 산출물이라는 요구가 이 자리에서 발행자별로 갈린 꼴로 선다」

**기각한 대체 정의:**
축의 논리합을 입도 칸의 유무로 갈음하는 안. 칸 하나로 닫히나 입도가 값을 내는 단위이고 축을 내는가와
다른 축이어서, 축을 내면서 입도가 비는 경로와 축을 내지 않으면서 입도가 선 경로가 둘 다 설 수 있다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def SwapLineChannel.readsAnyFact {Node : Type} (c : SwapLineChannel Node) : Bool :=
  c.readsSuppliedCurrency || c.readsScheduledEnd || c.readsCap || c.readsReciprocity
    || c.readsAdmissionLocus || c.readsOnlendingEligibility || c.readsActivation
    || c.readsDrawdownAvailability || c.readsTermination

/--
공급 중앙은행이 자기 상대방 표를 공표하는 경로.

**대응 비형식 개념:** 공급하는 쪽이 자기 약정의 상대방과 그 조건을 표로 내는 공시. 한 발행자의
정책 수단 면이 상대방을 열거하고 한도와 기간과 상호성의 칸을 각각 둔다.

**이 정의가 배제하는 사례:**
그 표가 약정의 모든 축을 낸다고 보는 읽기. 한 발행자의 공시를 훑은 기록이 한도와 기간과 상호성이
서로 독립인 세 축으로 서고 한 상대방의 지위가 그 셋의 조합으로 정해진다고 적으면서 재대출 적격성과
발동과 가용의 칸은 그 표에 없다고 적으므로, 전부 낸다고 보면 그 결손이 사라진다.
조달처: E-60 §2-1 「그래서 한도와 기간과 상호성이 서로 독립인 세 축으로 서고, 한 상대방의 지위가 그 셋의 조합으로 정해진다」

**기각한 대체 정의:**
공급자의 공시를 하나의 경로로 묶지 않고 축마다 경로를 세우는 안. 결손이 축별로 보이나 같은 표에서
읽히는 축들이 서로 다른 경로로 갈려 그 표가 쌍별 입도를 갖는다는 사실이 축마다 중복으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def supplierCounterpartyTable : SwapLineChannel Unit where
  coversSupplier := fun _ => true
  coversRecipient := fun _ => true
  readsSuppliedCurrency := true
  readsScheduledEnd := true
  readsCap := true
  readsReciprocity := true
  readsAdmissionLocus := true
  readsOnlendingEligibility := false
  readsActivation := false
  readsDrawdownAvailability := false
  readsTermination := false
  readsSupplierFxExposure := true
  readsRecipientFxExposure := false
  granularity := some .pairLevel
  recipient := .publicReader
  provenance := .officialReport

/--
수취 중앙은행이 자기 재대출 조건을 공표하는 경로.

**대응 비형식 개념:** 받은 외화를 자기 관할에 다시 대출하는 조건을 수취자가 내는 공시. 공급하는
쪽의 질의응답이 그 조건이 모든 경우에 외국 중앙은행에 의해 공표된다고 적는다.

**이 정의가 배제하는 사례:**
재대출 조건을 공급자의 공시에서 읽는 읽기. 공급하는 쪽의 질의응답이 그 대출을 규율하는 조건이 모든
경우에 외국 중앙은행에 의해 공표된다고 적어 그 값의 거처가 수취자임을 밝히므로, 공급자에서 읽으면
도달 범위의 둘째 고리가 빈 채로 닫힌다.
조달처: E-61 §6 「그 대출을 규율하는 조건이 모든 경우에 외국 중앙은행에 의해 공표된다」

**기각한 대체 정의:**
수취자의 공시를 공급자의 경로에 흡수하는 안. 경로가 줄어드나 한 수취자가 여러 공급자와 약정을
가지면 그 재대출 조건이 공급자마다 중복으로 서고 그 중복이 서로 다른 값을 가질 수 있다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def recipientOnlendingTerms : SwapLineChannel Unit where
  coversSupplier := fun _ => false
  coversRecipient := fun _ => true
  readsSuppliedCurrency := true
  readsScheduledEnd := false
  readsCap := false
  readsReciprocity := false
  readsAdmissionLocus := false
  readsOnlendingEligibility := true
  readsActivation := false
  readsDrawdownAvailability := false
  readsTermination := false
  readsSupplierFxExposure := false
  readsRecipientFxExposure := false
  granularity := some .recipientLevel
  recipient := .publicReader
  provenance := .officialReport

/--
거시 통계가 활성화된 거래만 기재하는 경로.

**대응 비형식 개념:** 국제 기구의 통계 지침이 정한 기재 범위. 그 지침이 통계와 회계의 목적에서는
활성화된 거래만 기재한다고 적는다.

**이 정의가 배제하는 사례:**
거시 통계가 약정의 한도를 낸다고 보는 읽기. 그 지침이 통계와 회계의 목적에서는 그 활성화된 거래만
기재한다고 적으므로, 한도를 낸다고 보면 발동되지 않은 잔량이 통계에서 읽히는 것으로 선다.
조달처: E-63 §3-2 「통계와 회계의 목적에서는 그 활성화된 거래만 기재한다」

**기각한 대체 정의:**
통계의 기재 범위를 입도 칸으로만 담고 축의 칸을 두지 않는 안. 입도가 집계임을 들 수 있으나 어느
축이 그 집계에 드는가가 사라지고, 활성화된 거래만 기재한다는 것은 입도의 사실이 아니라 축의
사실이다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def macroStatisticsActivated : SwapLineChannel Unit where
  coversSupplier := fun _ => false
  coversRecipient := fun _ => true
  readsSuppliedCurrency := true
  readsScheduledEnd := false
  readsCap := false
  readsReciprocity := false
  readsAdmissionLocus := false
  readsOnlendingEligibility := false
  readsActivation := true
  readsDrawdownAvailability := false
  readsTermination := false
  readsSupplierFxExposure := false
  readsRecipientFxExposure := false
  granularity := some .aggregateLevel
  recipient := .publicReader
  provenance := .officialReport

/--
준비자산 서식에서 유도되는 경로.

**대응 비형식 개념:** 국제 기구의 준비자산 공시 서식에서 읽는 쪽이 값을 유도하는 자리. 한 발행자의
문면을 훑은 기록이 그 유도가 보고국마다 다르게 선다고 적는다.

**이 정의가 배제하는 사례:**
그 서식에서 유도한 값을 공식 자료로 보는 읽기. 그 기록이 그 셋이 전부 추측형으로 서술되므로 그
값의 실재가 보고국마다 다르다고 적으므로, 공식으로 보면 유도의 불확실성이 값의 성질에서 사라진다.
조달처: E-63 §5-2 「그 셋이 전부 추측형으로 서술되므로 그 값의 실재가 보고국마다 다르다」

**기각한 대체 정의:**
그 서식을 거시 통계의 경로에 흡수하는 안. 경로가 줄어드나 거시 통계가 활성화된 거래를 공식으로
내는 데 비해 이 서식은 읽는 쪽이 유도하므로 값의 성질이 갈리고, 그 갈림이 같은 축을 두 성질로
읽는다는 사실을 담는 자리다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def reserveTemplateDerived : SwapLineChannel Unit where
  coversSupplier := fun _ => false
  coversRecipient := fun _ => true
  readsSuppliedCurrency := false
  readsScheduledEnd := false
  readsCap := false
  readsReciprocity := false
  readsAdmissionLocus := false
  readsOnlendingEligibility := false
  readsActivation := true
  readsDrawdownAvailability := false
  readsTermination := false
  readsSupplierFxExposure := false
  readsRecipientFxExposure := false
  granularity := some .aggregateLevel
  recipient := .publicReader
  provenance := .staffEstimate

/--
수취 중앙은행의 연차 재무제표가 내는 경로.

**대응 비형식 개념:** 수취자의 재무제표에서 읽히는 사용 조건. 한 발행자의 문면을 훑은 기록이 그
값의 거처가 수취자의 재무제표라고 적는다.

**이 정의가 배제하는 사례:**
사용 조건을 실재하지 않는 범주로 보는 읽기. 그 기록이 사용 조건이 실재하는 범주이고 그 값의 거처가
수취자의 재무제표라고 적으므로, 없는 범주로 보면 그 경로가 목록에서 빠지고 그 결손이 축의 거짓이
아니라 경로의 부재로 선다.
조달처: E-63 §5-2 「그래서 사용 조건이 실재하는 범주이고 그 값의 거처가 수취자의 재무제표다」

**기각한 대체 정의:**
재무제표를 수취자의 재대출 조건 경로에 흡수하는 안. 수취자의 공시가 한 경로로 모이나 재대출 조건이
공표의 사실이고 재무제표의 사용 조건이 회계의 사실이어서 입도와 성질이 갈린다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def recipientAnnualAccounts : SwapLineChannel Unit where
  coversSupplier := fun _ => false
  coversRecipient := fun _ => true
  readsSuppliedCurrency := true
  readsScheduledEnd := false
  readsCap := false
  readsReciprocity := false
  readsAdmissionLocus := false
  readsOnlendingEligibility := false
  readsActivation := true
  readsDrawdownAvailability := true
  readsTermination := false
  readsSupplierFxExposure := false
  readsRecipientFxExposure := false
  granularity := some .recipientLevel
  recipient := .publicReader
  provenance := .officialReport

/--
당국이 양자로만 제공하는 비공표 경로.

**대응 비형식 개념:** 공표되지 않고 양자로 전달되는 자리. 한 발행자의 문면을 훑은 기록이 그것이
공표 경로가 아니라고 적는다.

**이 정의가 배제하는 사례:**
양자 제공을 공표 경로로 세는 읽기. 그 기록이 첫째는 당국이 양자로 제공하는 것이므로 공표 경로가
아니라고 적으므로, 공표로 세면 끝내는 통지를 내는 공표 경로가 있는 것으로 선다.
조달처: E-63 §5-2 「첫째는 당국이 양자로 제공하는 것이므로 공표 경로가 아니다」

**기각한 대체 정의:**
비공표 경로를 목록에서 빼는 안. 공표 경로의 목록이 깔끔해지나 그 축을 내는 자리가 실재한다는 사실이
사라지고, 그러면 그 축의 결손이 어디에도 값이 없다는 뜻으로 읽힌다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def confidentialBilateral : SwapLineChannel Unit where
  coversSupplier := fun _ => true
  coversRecipient := fun _ => true
  readsSuppliedCurrency := true
  readsScheduledEnd := true
  readsCap := true
  readsReciprocity := true
  readsAdmissionLocus := true
  readsOnlendingEligibility := true
  readsActivation := true
  readsDrawdownAvailability := true
  readsTermination := true
  readsSupplierFxExposure := false
  readsRecipientFxExposure := true
  granularity := some .pairLevel
  recipient := .supervisor
  provenance := .officialReport

/--
공표되는 경로의 목록.

**대응 비형식 개념:** 외부 관측자가 접근할 수 있는 경로의 전량. 비공표 경로를 그 목록에서 빼는
것이 공표와 비공표의 가름이다.

**이 정의가 배제하는 사례:**
비공표 경로를 그 목록에 넣는 읽기. 한 발행자의 문면을 훑은 기록이 개별 인출의 활성화 상태와 상환
조건은 공표하지 않는다고 적으므로, 넣으면 공표 경로가 그 축을 내는 것으로 선다.
조달처: E-63 §6-4 「개별 인출의 활성화 상태와 상환 조건은 공표하지 않는다」

**기각한 대체 정의:**
공표 여부를 목록이 아니라 경로의 수신자 칸으로만 가르는 안. 칸이 이미 있어 목록을 두지 않을 수
있으나 그 칸을 걸러 목록을 만드는 자리가 매번 다시 서고, 목록 전량을 훑는 판정이 그 거르기의
결과에 걸리므로 그 거르기가 한 자리에 고정되어야 한다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def publicChannels : List (SwapLineChannel Unit) :=
  [supplierCounterpartyTable, recipientOnlendingTerms, macroStatisticsActivated,
   reserveTemplateDerived, recipientAnnualAccounts]

/--
어느 공표 경로도 약정을 끝내는 통지를 내지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공표 경로 가운데 끝내는 통지를 내는 것이 하나라도 있어야 한다. 그 관측은 그 축의 결손이 공표
경로의 결손이 아니라는 뜻이며, 그러면 이 파일이 세우는 산출의 근거가 사라진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 프레임워크의 주요 산출물 가운데 하나이므로
그 영이 이 파일의 산출이고 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 목록을 접어 계산으로 닫는 것이다. 목록 멤버십의 전칭으로 두지 않는
사유는 그 꼴이 명제 외연성을 끌어오는데 관측층의 공리 기준선이 비어 있다는 데 있다. 이 진술이 증명
가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께
확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2976
theorem no_public_channel_reads_termination :
    publicChannels.all (fun c => !c.readsTermination) = true := by
  rfl

/--
끝내는 통지를 내는 경로가 실재하고 그 수신자가 공표 상대가 아니다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 축을 내는 경로가 아예 없거나, 그 경로의 수신자가 공표 상대여야 한다. 앞의 관측은 그 축에 값이
어디에도 없다는 뜻이고 뒤의 관측은 앞 정리와 부딪히므로, 이 명제가 그 결손이 공표의 가름에서
온다는 것을 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 결손이 축의 부재가 아니라 공표 경계의 귀결임을 보이므로 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 그 경로의 두 칸을 계산으로 닫는 것이며, 수신자의 비동일을 부정
형태가 아니라 판정의 거짓으로 적어 명제 외연성을 끌어오지 않게 한다. 이 진술이 증명 가능함을 결정
세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은
싣지 않는다.
-/
-- DD:CF-2976
theorem termination_read_only_by_nonpublic :
    confidentialBilateral.readsTermination = true
      ∧ decide (confidentialBilateral.recipient = DisclosureRecipient.publicReader) = false := by
  exact ⟨rfl, rfl⟩

/--
한도를 내는 공표 경로와 내지 않는 공표 경로가 둘 다 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공표 경로가 한도에 대해 전부 같은 값을 내야 한다. 그 관측은 한도의 측정 가능성이 경로에 걸리지
않는다는 뜻이며, 그러면 측정 가능성이 변수에 붙고 쌍에 붙지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
경로마다 갈린다는 것은 양쪽이 실제로 서는 경로를 들어야 보이고, 임의의 공표 경로에 대한 전칭으로는
그 갈림이 진술되지 않는다. 시스템 수준의 공표 경계가 개별 경로의 한도 칸을 결정하지 않는 자리다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 측정 가능성이 변수에 붙지 않고 경로에 붙는다는 것을 보이므로 기여 목록에
든다.

**증명은 집행 증분이다.** 길은 목록을 두 방향으로 접어 계산으로 닫는 것이다. 존재를 목록 멤버십으로
적지 않고 접기로 적는 사유는 그 꼴이 공리를 끌어오지 않고 계산 가능성을 지킨다는 데 있다. 이 진술이
증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께
확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2976
theorem cap_splits_public_channels :
    publicChannels.any (fun c => c.readsCap) = true
      ∧ publicChannels.any (fun c => !c.readsCap) = true := by
  exact ⟨rfl, rfl⟩

/--
같은 축을 공식 보고와 추정이 함께 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 축을 내는 경로들의 값 성질이 전부 같아야 한다. 그 관측은 성질의 칸이 접힌다는 뜻이며, 그러면
공식 자료로 읽히는 값과 읽는 쪽이 유도한 값이 한 값으로 선다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 값의 성질을 담는 칸이 다른 칸으로 유도되지 않음을 보이므로 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 두 경로의 축 칸을 계산으로 닫고 성질의 비동일을 판정의 거짓으로
적는 것이다. 이 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이
컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2976
theorem activation_read_by_both_provenances :
    macroStatisticsActivated.readsActivation = true
      ∧ reserveTemplateDerived.readsActivation = true
      ∧ decide (macroStatisticsActivated.provenance = reserveTemplateDerived.provenance)
          = false := by
  exact ⟨rfl, rfl, rfl⟩

/--
축을 하나도 내지 않는 공표 경로는 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공표 경로 가운데 어느 축도 내지 않는 것이 하나라도 있어야 한다. 그 관측은 그 경로를 목록에 둔
것이 잘못이라는 뜻이 아니라, 소스 없음이 축의 거짓이 아니라 경로의 공백으로 서는 자리가 있다는
뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 소스 없음이 경로의 부재가 아니라 축의 거짓으로 선다는 설계가 목록 전량에서
실제로 성립함을 보이므로 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 목록을 접어 계산으로 닫는 것이다. 이 진술이 증명 가능함을 결정
세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴
전술은 싣지 않는다.
-/
-- DD:CF-2976
theorem every_public_channel_reads_something :
    publicChannels.all (fun c => c.readsAnyFact) = true := by
  rfl

/--
그 경로 목록이 그 약정의 쌍을 덮는가.

**대응 비형식 개념:** 공급자와 수취자의 쌍이 어느 공시에 함께 드는가. 도달 범위의 첫째 고리가
그 쌍에 붙으므로 그 쌍을 덮는 경로가 없으면 그 고리가 서지 않는다.

**이 정의가 배제하는 사례:**
공급자를 덮는 경로와 수취자를 덮는 경로가 따로 있으면 그 쌍이 덮인다고 보는 읽기. 한 발행자의
공시를 훑은 기록이 그래서 도달 범위의 쌍별 값이 한 문면에서 유도되지 않는다고 적으므로, 따로
덮이는 것을 쌍이 덮이는 것으로 보면 그 결손이 사라진다.
조달처: E-60 §4-1 「그래서 도달 범위의 쌍별 값이 한 문면에서 유도되지 않는다」

**기각한 대체 정의:**
쌍의 덮임을 두 칸의 논리곱이 아니라 경로 목록 전량에 대한 두 논리합의 곱으로 두는 안. 더 많은
자리에서 참이 되나 한 경로가 쌍을 함께 덮어야 한다는 요구가 사라져 앞의 사례가 통과한다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def coversPair {Node Currency Num Obs : Type} (chs : List (SwapLineChannel Node))
    (s : CentralBankSwapLine Node Currency Num Obs) : Bool :=
  chs.any (fun c => c.coversSupplier s.supplier && c.coversRecipient s.recipient)

/--
그 경로 목록이 그 수취자의 재대출 적격성을 내는가.

**대응 비형식 개념:** 도달 범위의 둘째 고리의 소스. 적격성이 수취자의 공시에서 오므로 그 수취자를
덮으면서 적격성을 내는 경로가 그 고리의 자리다.

**이 정의가 배제하는 사례:**
적격성을 공급자의 공시에서 읽는 읽기. 공급하는 쪽의 질의응답을 훑은 기록이 발행자의 공시를 읽어도
재대출의 조건이 서지 않으므로 그 값의 거처가 수취자의 공시라고 적으므로, 공급자에서 읽으면 둘째
고리가 빈 채로 닫힌다.
조달처: E-61 §6 「발행자의 공시를 읽어도 재대출의 조건이 서지 않으므로 그 값의 거처가 수취자의 공시이며」

**기각한 대체 정의:**
적격성을 내는 경로가 그 수취자를 덮는지를 묻지 않고 적격성 칸만 보는 안. 칸이 짧아지나 다른
수취자의 적격성을 내는 경로가 이 수취자의 고리를 메우는 것으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def readsOnlending {Node Currency Num Obs : Type} (chs : List (SwapLineChannel Node))
    (s : CentralBankSwapLine Node Currency Num Obs) : Bool :=
  chs.any (fun c => c.readsOnlendingEligibility && c.coversRecipient s.recipient)

/--
답할 항을 경로 목록과 적격성의 족에 걸어 조립한다.

**대응 비형식 개념:** 도달 범위를 묻는 물음의 답이 공시의 구성에 걸린다는 사실. 두 고리의 소스가
다 서면 성립과 불성립을 내고 어느 하나라도 서지 않으면 측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
그 물음의 측정 가능성이 변수에 붙는다고 보는 읽기. 한 발행자의 문면을 훑은 기록이 그래서 같은
변수의 측정 가능성이 발행자에 걸린다고 적으므로, 변수에 붙는다고 보면 한 발행자에서 서고 다른
발행자에서 서지 않는 자리가 담기지 않는다.
조달처: E-63 §6-4 「그래서 같은 변수의 측정 가능성이 발행자에 걸린다」

**기각한 대체 정의:**
두 고리의 소스 가운데 하나만 서면 부분적 성립을 내는 안. 답이 더 자주 서나 도달 범위가 두 고리의
합집합이어서 한 고리만으로는 그 합집합이 유도되지 않으며, 그 부분 값이 참거짓으로 읽히면 결손이
답으로 둔갑한다.

**값을 담지 않는다.**
-/
-- DD:CF-2976
def swapLineReachVia {Time Node Currency Num Obs : Type} [DecidableEq Node]
    (chs : List (SwapLineChannel Node))
    (E : Time → OnlendingEligibility Node Currency) :
    CQ.SwapLineReach Time Node (CentralBankSwapLine Node Currency Num Obs) where
  answer := fun n s t =>
    if coversPair chs s && readsOnlending chs s then
      (if s.reaches (E t) n then .holds else .fails)
    else .undetermined .noMeasurementSource

/-- witness (A-3). **무엇을 증거하는가.** 공시 경로 구조체가 비어 있지 않다. 어느 축도 내지
않고 입도가 비어 있는 경로 하나를 든다. -/
-- DD:CF-2976
def SwapLineChannel.trivial : SwapLineChannel Unit where
  coversSupplier := fun _ => false
  coversRecipient := fun _ => false
  readsSuppliedCurrency := false
  readsScheduledEnd := false
  readsCap := false
  readsReciprocity := false
  readsAdmissionLocus := false
  readsOnlendingEligibility := false
  readsActivation := false
  readsDrawdownAvailability := false
  readsTermination := false
  readsSupplierFxExposure := false
  readsRecipientFxExposure := false
  granularity := none
  recipient := .publicReader
  provenance := .officialReport

/-- 두 고리의 소스가 다 서는 자리. 쌍을 덮는 경로와 적격성을 내는 경로가 함께 든다. -/
-- DD:CF-2976
def transparentChannels : List (SwapLineChannel Unit) :=
  [supplierCounterpartyTable, recipientOnlendingTerms]

/-- 활성화된 총계만 내는 자리. 두 고리의 소스가 다 서지 않는다. -/
-- DD:CF-2976
def opaqueChannels : List (SwapLineChannel Unit) :=
  [macroStatisticsActivated]

/-- 첫째 고리만 서는 자리. 쌍은 덮이나 적격성이 읽히지 않는다. -/
-- DD:CF-2976
def onlyPairChannels : List (SwapLineChannel Unit) :=
  [supplierCounterpartyTable]

/-- 둘째 고리만 서는 자리. 적격성은 읽히나 그 쌍이 한 경로에서 덮이지 않는다. -/
-- DD:CF-2976
def onlyOnlendingChannels : List (SwapLineChannel Unit) :=
  [recipientOnlendingTerms]

/-- 판정의 대상이 되는 약정 하나. 상시이고 무제한이며 상호다. -/
-- DD:CF-2976
def sampleLine : CentralBankSwapLine Unit Unit Unit Unit where
  supplier := ()
  recipient := ()
  suppliedCurrency := ()
  scheduledEnd := none
  cap := none
  reciprocal := true
  reversalAtInitialRate := true

/-- 어느 기관도 적격으로 두지 않는 적격성의 족. 시점을 단위 타입으로 받는다. -/
-- DD:CF-2976
def noOnlending : Unit → OnlendingEligibility Unit Unit :=
  fun _ => OnlendingEligibility.trivial

/--
두 고리의 소스가 다 서는 자리에서 그 답이 성립을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 고리의 소스가 다 서는 경로 목록에서도 그 답이 성립을 내지 않아야 한다. 그 관측은 소스가 서는
것과 답이 서는 것이 다른 축이라는 뜻이며, 그러면 측정 가능성의 판정이 답의 판정과 갈린다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 답할 항이 정의 공백을 벗어났다는 주장이 이 자리와 다음 자리의 짝으로
서므로 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 사상과 범위 술어를 전개하고 두 고리의 판정을 계산으로 닫는 것이다.
이 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는
것도 함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2976
theorem answer_holds_when_transparent :
    (swapLineReachVia transparentChannels noOnlending).answer
      sampleLine.recipient sampleLine () = ObservedTruth.holds := by
  rfl

/--
총계만 내는 자리에서 같은 물음이 측정 소스 없음을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 경로 목록에서도 그 답이 참거짓을 내야 한다. 그 관측은 활성화된 총계만으로 도달 범위가 유도된다는
뜻이며, 그러면 이 파일이 세우는 결손이 결손이 아니다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 소스 없음이 답 타입의 한 생성자로 실제로 서는 것을 보이므로 기여 목록에
든다.

**증명은 집행 증분이다.** 길은 사상을 전개하고 두 고리의 판정이 거짓임을 계산으로 닫는 것이다. 이
진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도
함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2976
theorem answer_undetermined_when_opaque :
    (swapLineReachVia opaqueChannels noOnlending).answer
      sampleLine.recipient sampleLine ()
        = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

/--
같은 약정에 대한 같은 물음이 경로 목록에 따라 다른 칸을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 경로 목록이 같은 칸을 내야 한다. 그 관측은 측정 가능성이 공시의 구성에 걸리지 않는다는 뜻이며,
앞의 두 정리와 부딪힌다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 측정 가능성이 변수에 붙지 않고 발행자에 붙는다는 주장이 이 자리에서 한
진술로 선다.

**증명은 집행 증분이다.** 길은 두 사상을 전개하고 두 칸의 비동일을 판정의 거짓으로 닫는 것이다.
비동일을 부정 형태로 적지 않는 사유는 그 꼴이 명제 외연성을 끌어올 수 있는데 관측층의 공리 기준선이
비어 있다는 데 있다. 이 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이
컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2976
theorem answer_splits_on_channels :
    decide ((swapLineReachVia transparentChannels noOnlending).answer
          sampleLine.recipient sampleLine ()
        = (swapLineReachVia opaqueChannels noOnlending).answer
          sampleLine.recipient sampleLine ()) = false := by
  rfl

/--
첫째 고리만 서는 자리도 측정 소스 없음을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
쌍이 덮이기만 하면 그 답이 참거짓을 내야 한다. 그 관측은 두 고리가 곱이 아니라 합으로 걸린다는
뜻이며, 그러면 적격성의 결손이 답을 막지 못한다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 고리가 곱으로 걸린다는 설계가 한 고리만 서는 자리에서 실제로 성립함을
보이므로 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 사상을 전개하고 둘째 고리의 판정이 거짓임을 계산으로 닫는 것이다.
이 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는
것도 함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2976
theorem answer_undetermined_when_only_pair_covered :
    (swapLineReachVia onlyPairChannels noOnlending).answer
      sampleLine.recipient sampleLine ()
        = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

/--
둘째 고리만 서는 자리도 측정 소스 없음을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
적격성이 읽히기만 하면 그 답이 참거짓을 내야 한다. 그 관측은 쌍의 덮임이 답에 걸리지 않는다는
뜻이며, 그러면 쌍별 값이 한 문면에서 유도되지 않는다는 결손이 답을 막지 못한다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 앞 정리와 짝을 이루어 두 고리가 서로 갈음되지 않음을 보이므로 기여 목록에
든다. 이 자리가 없으면 두 고리의 곱이 한 고리의 중복으로 읽힐 수 있다.

**증명은 집행 증분이다.** 길은 사상을 전개하고 첫째 고리의 판정이 거짓임을 계산으로 닫는 것이다.
이 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는
것도 함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-2976
theorem answer_undetermined_when_only_onlending_read :
    (swapLineReachVia onlyOnlendingChannels noOnlending).answer
      sampleLine.recipient sampleLine ()
        = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

/--
그 경로가 환위험 귀속의 두 면을 함께 내는가.

**대응 비형식 개념:** 한 공시가 공급하는 쪽의 노출과 받는 쪽의 노출을 한 문면에서 함께 내는가.
두 면이 서로 다른 발행자의 문면에 나뉘어 있어 한 경로가 둘을 함께 내는 자리가 따로 선다.

**이 정의가 배제하는 사례:**
두 면을 한 축으로 접어 환위험 공시의 유무로 보는 읽기. 한 발행자의 질의응답이 되돌리는 거래의
환율이 처음과 같으므로 자기가 환율 변동에 노출되지 않는다고 적고 다른 발행자의 문면이 차입하는
중앙은행이 환위험을 전부 진다고 적으므로, 한 축으로 접으면 어느 쪽 면이 선 공시인지가 사라진다.
조달처: E-61 §7 「그 서술이 자기 쪽의 노출을 들고 상대 쪽의 노출을 들지 않는다」

**기각한 대체 정의:**
두 면의 논리합을 축으로 두는 안. 환위험에 대해 무엇이든 내는 경로를 가르나 귀속이 서려면 두 면이
함께 서야 하므로, 논리합으로 두면 한 면만 내는 경로가 귀속을 내는 경로로 읽힌다.

**값을 담지 않는다.**
-/
-- DD:CF-3105
def SwapLineChannel.readsBothFxSides {Node : Type} (c : SwapLineChannel Node) : Bool :=
  c.readsSupplierFxExposure && c.readsRecipientFxExposure

/--
공표 경로 가운데 받는 쪽의 노출을 내는 것이 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공표 경로 가운데 받는 쪽의 노출을 내는 것이 하나라도 있어야 한다. 그 관측은 받는 쪽 면의 측정
소스가 공표 경로에 있다는 뜻이며, 그러면 그 면이 공공 기관 문면에서만 서는 것이 아니다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 환위험 귀속의 받는 쪽 면에 공표 소스가 없다는 것이 관측층에 등재되는
소스 없음이므로 기여 목록에 든다.
-/
-- DD:CF-3105
theorem no_public_channel_reads_recipientFxExposure :
    publicChannels.all (fun c => !c.readsRecipientFxExposure) = true := by
  rfl

/--
공표 경로 가운데 두 면을 함께 내는 것이 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공표 경로 가운데 두 면을 함께 내는 것이 하나라도 있어야 한다. 그 관측은 귀속이 공표 경로에서
유도된다는 뜻이며, 그러면 두 문면을 함께 기록하라는 요구가 이 자리에서 성립하지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 앞 명제가 한 면의 결손을 들고 이 명제가 귀속 자체의 결손을 들므로, 둘이
짝을 이루어 결손이 어느 층에서 오는지를 가른다.
-/
-- DD:CF-3105
theorem no_public_channel_reads_both_fx_sides :
    publicChannels.all (fun c => !c.readsBothFxSides) = true := by
  rfl

/--
공표 경로 가운데 공급하는 쪽의 노출을 내는 것이 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공표 경로 가운데 공급하는 쪽의 노출을 내는 것이 하나도 없어야 한다. 그 관측은 그 발행자의
질의응답이 자기 노출을 적은 것이 공표 경로에 들지 않는다는 뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 면의 결손이 비대칭임을 보이므로, 소스 없음이 축에 균일하게 걸리지 않고
면마다 갈린다는 것이 이 자리에서 선다.
-/
-- DD:CF-3105
theorem supplierFxExposure_read_by_some_public_channel :
    publicChannels.any (fun c => c.readsSupplierFxExposure) = true := by
  rfl

/--
받는 쪽의 노출을 내는 경로가 실재하고 그 수신자가 공표 상대가 아니다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 면을 내는 경로가 아예 없거나, 그 경로의 수신자가 공표 상대여야 한다. 앞의 관측은 그 면에 값이
어디에도 없다는 뜻이고 뒤의 관측은 앞선 명제와 부딪히므로, 이 명제가 그 결손이 공표의 가름에서
온다는 것을 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 받는 쪽 면의 결손이 자료의 부재가 아니라 수신자의 가름에서 온다는 것을
보이므로 기여 목록에 든다.
-/
-- DD:CF-3105
theorem fx_sides_split_across_channels :
    confidentialBilateral.readsRecipientFxExposure = true
      ∧ decide (confidentialBilateral.recipient = DisclosureRecipient.publicReader) = false := by
  exact ⟨rfl, rfl⟩

/--
두 면을 함께 내는 판정의 각 항이 홀로 참인 경로가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 면 가운데 하나만 내는 경로가 한쪽에 없어야 한다. 그 관측은 그 판정의 두 항이 함께만 움직인다는
뜻이며, 그러면 논리곱을 논리합으로 뒤집은 변이가 같은 값을 내어 그 판정이 재어지지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
두 항의 독립은 각 항이 홀로 참인 경로를 들어야 보이고, 임의의 경로에 대한 전칭으로는 그 독립이
진술되지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. A-8 의 변이 검사가 논리 결합을 뒤집은 사본에서 실패하려면 각 항이 홀로 참인
증거가 있어야 하며, 이 명제가 그 증거를 형식층에 둔다.
-/
-- DD:CF-3105
theorem readsBothFxSides_pins_each_conjunct :
    supplierCounterpartyTable.readsSupplierFxExposure = true
      ∧ supplierCounterpartyTable.readsBothFxSides = false
      ∧ confidentialBilateral.readsRecipientFxExposure = true
      ∧ confidentialBilateral.readsBothFxSides = false := by
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
그 경로 목록이 그 발행자의 성립 조건 자리를 내는가.

**대응 비형식 개념:** 어느 발행자의 성립 기준이 어느 공시에 드는가. 성립 조건의 자리가 수취자의
성질과 두 주체 사이의 관계로 갈리고 그 둘을 내는 경로가 그 발행자를 덮어야 한다.

**이 정의가 배제하는 사례:**
성립 조건의 자리를 내는 경로가 그 발행자를 덮지 않아도 그 자리가 읽힌다고 보는 읽기. 공공 기관
문면이 두 발행자의 기준을 각각 분석한 연구를 인용하면서 그 기준이 공시에서 유도되지 않고 추정으로
복원된다고 적으므로, 덮지 않아도 읽힌다고 보면 그 추정이 공시로 읽힌다.
조달처: E-62 §8-3 「그 기준의 측정 소스가 공시가 아니라 연구의 추정이다」

**기각한 대체 정의:**
덮는 쪽을 공급자 하나로 닫는 안. 성립 조건의 넷째 기준이 두 주체 사이의 관계에 붙으므로 공급자
하나로 닫으면 그 기준이 어느 쪽 공시에서 읽히는지가 서지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3105
def readsAdmission {Node : Type} (chs : List (SwapLineChannel Node)) (n : Node) : Bool :=
  chs.any (fun c => c.readsAdmissionLocus && (c.coversSupplier n || c.coversRecipient n))

/--
성립 조건의 값을 경로 목록에 걸어 내는 사상.

**대응 비형식 개념:** 그 발행자의 성립 기준을 공시에서 읽을 수 있는가와 읽히면 무엇인가를 가르는
사상. 읽을 수 없는 자리를 거짓으로 접지 않고 비어 있음으로 낸다.

**이 정의가 배제하는 사례:**
읽을 수 없는 자리를 거짓으로 접는 읽기. 관측층에 등재되는 소스 없음이 주요 산출물이라는 요구가
이 자리에서 발행자별로 갈린 꼴로 선다고 한 기록이 적으므로, 거짓으로 접으면 그 기준을 두지 않는
발행자와 그 기준을 읽을 수 없는 발행자가 한 값으로 선다.
조달처: E-63 §6-4 「관측층에 등재되는 소스 없음이 주요 산출물이라는 요구가 이 자리에서 발행자별로 갈린 꼴로 선다」

**기각한 대체 정의:**
사상이 성립 조건의 거처 구조체를 내도록 두는 안. 그 구조체의 판정이 참거짓만 내므로 읽을 수 없는
자리를 담을 값이 없고, 그 결손이 거짓으로 접힌다.

**값을 담지 않는다.** 읽을 수 있는지를 경로에서 유도하고 값 자체는 인자로 받는다.
-/
-- DD:CF-3105
def admissionCriteriaVia {Node : Type} (chs : List (SwapLineChannel Node))
    (A : AdmissionCriteria Node) (n : Node) (l : AdmissionLocus) : Option Bool :=
  if readsAdmission chs n then some (A.usesLocus n l) else none

/--
어느 축도 내지 않는 경로만으로는 성립 조건이 비어 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 축도 내지 않는 경로 하나만으로 성립 조건의 값이 서야 한다. 그 관측은 그 사상이 경로의 축에
걸리지 않는다는 뜻이며, 그러면 소스 없음이 사상에서 유도되지 않는다.

**가정과 그 배제 사례(T-4·T-5):** 경로 목록이 어느 축도 내지 않는 경로 하나라는 것을 진술문의
인자로 둔다. 전칭으로 두면 성립 조건을 내는 경로가 든 목록에서 거짓이며, 이 진술이 배제하는 것은
그 자리를 내는 경로가 든 목록이다.

**T-3 분류:** 보조 보정이다. 사상과 경로 판정의 정의를 전개하면 목록 멤버십과 조건 분기로 닫히므로
기여 목록에서 제외한다.
-/
-- DD:CF-3105
theorem admissionCriteriaVia_undetermined_of_trivial
    (A : AdmissionCriteria Unit) (l : AdmissionLocus) :
    admissionCriteriaVia [SwapLineChannel.trivial] A () l = none := by
  rfl

/--
공표 경로 목록은 성립 조건의 자리를 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공표 경로 가운데 성립 조건의 자리를 내면서 그 발행자를 덮는 것이 하나도 없어야 한다. 그 관측은 그
자리의 측정 소스가 공표 경로에 없다는 뜻이며, 그러면 앞선 명제가 든 발행자별 가름이 이 축에서는
한쪽으로 닫힌다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 소스 없음이 축마다 갈린다는 것을 성립 조건 축에서 보이므로, 앞의 환위험 두
면과 맞대어 결손이 균일하지 않음이 선다.
-/
-- DD:CF-3105
theorem readsAdmission_publicChannels :
    readsAdmission publicChannels () = true := by
  rfl

/--
성립 조건 판정의 각 항이 홀로 값을 가르는 경로가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
성립 조건의 자리를 내지 않으면서 그 발행자를 덮는 경로에서 판정이 참이거나, 그 자리를 내면서 한
쪽만 덮는 경로에서 판정이 거짓이어야 한다. 그 관측은 그 판정의 두 결합이 함께만 움직인다는 뜻이며,
그러면 논리곱과 논리합을 뒤집은 변이가 같은 값을 내어 그 판정이 재어지지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
두 결합의 독립은 각 결합이 홀로 값을 가르는 경로를 들어야 보이고, 임의의 경로 목록에 대한 전칭으로는
그 독립이 진술되지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. A-8 의 논리 결합 변이가 뒤집은 사본에서 실패하려면 각 결합이 홀로 값을 가르는
증거가 있어야 하며, 이 명제가 그 증거를 형식층에 둔다.
-/
-- DD:CF-3105
theorem readsAdmission_pins_each_conjunct :
    readsAdmission [recipientOnlendingTerms] () = false
      ∧ readsAdmission [{ supplierCounterpartyTable with
            coversRecipient := fun _ => false }] () = true := by
  exact ⟨rfl, rfl⟩

end CrisisFramework.Observation
