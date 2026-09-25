/-
관측층 — `CQ-fin` 열하나의 고정 선언

규율: L-14(값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원이다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 역사 사례),
      C-3(판정 가능성), P-1(선언이 정의를 강제한다).

이 파일은 열한 물음의 서명을 고정한다. 답 함수의 본문은 여기에 없고 뒤의 아크들이 채운다.
서명이 요구하는 매개변수의 목록이 곧 채워야 할 정의의 목록이며, 정의를 먼저 완성하지 않고
서명을 먼저 세우는 순서가 구멍을 드러낸다.

수 타입을 쓰지 않는다. 시점과 금액과 영역 타입을 전부 매개변수로 받으므로 이 파일에는 수치
리터럴도 수 타입도 없다. 정의층이 `Num` 으로 수 체계를 추상화한 것과 같은 방법이며, 금액의
실제 수 체계는 회계층이 L-15 에 따라 정한다. 매개변수의 이름을 `Num` 이 아니라 `Amount` 로
둔 것은 관측층의 답이 전부 금액이기 때문이다.

그 결과로 이 파일은 아무것도 import 하지 않는다. L-9 는 의존의 방향만 정하고 import 를
강제하지 않으므로 위반이 아니며, 재유입할 때 이 선언만 떼어 갈 수 있다는 이점이 따라온다.

시점은 `Time` 매개변수로 받는다. 두 시점을 받는 물음에서 그 둘의 순서는 타입에 표현되지
않으며, 구간의 적형성은 이 선언이 담지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

namespace CrisisFramework.Observation

/--
판정 불가의 까닭.

**대응 비형식 개념:** 물음에 답할 수 없을 때 그 못 함이 어디서 오는가.

**이 정의가 배제하는 사례:**
2008년 3월 Bear Stearns 의 실패를 두고 미국 증권거래위원회 위원장이 자본이 아니라 신뢰의
문제였다고 공개 서한으로 적었는데, 그 판단이 옳은지를 가리려면 감독 기준 충족 여부가 아니라
자산의 실현 수익률을 알아야 했다. 이 열거는 그 값을 재는 **소스가 없다는 것**과 그 값을
알아도 반사실을 평가할 수 없다는 것을 가르지만, **어느 관측자에게 없는가**는 가르지 않는다.
관측자 상대성이 구멍으로 열려 있다.

**기각한 대체 정의:**
까닭을 묻지 않고 판정 불가를 한 칸으로 두는 안. 소스가 없어서 못 재는 것과 잴 대상이
실현되지 않아서 못 재는 것은 해소 경로가 다르다. 앞은 조달로 풀리고 뒤는 풀리지 않는다.
-/
-- DD:CF-571
inductive UndeterminedReason where
  /-- 측정 소스가 없다. 재야 할 것은 정해졌으나 그것을 내는 자리가 없다. -/
  | noMeasurementSource
  /-- 법적 문면이 갈린다. 문면은 있으나 그것이 무엇을 자르는지가 하나로 읽히지 않는다. -/
  | legalTextAmbiguous
  /-- 반사실을 평가하지 못한다. 답이 실현되지 않은 세계의 값을 요구한다. -/
  | counterfactualUnevaluated
  deriving DecidableEq, Repr

/--
참과 거짓과 판정 불가의 삼분.

**대응 비형식 개념:** 관측자가 낼 수 있는 진리값. 답이 서지 않는 것도 답의 한 칸이다.

**이 정의가 배제하는 사례:**
2013년 테이퍼 텐트럼에서 신흥국 국채의 매도 압력이 얼마나 강했는지는 정도의 문제였는데,
이 열거는 정도를 담지 않는다. 강도를 담으려면 실수가 필요해지고 그 순간 동학층으로 밀린다.

**기각한 대체 정의:**
`Bool` 로 두는 안. 판정 불가 칸을 뒤에 더하는 것은 답의 완전성이라는 전제를 바꾸므로
비보수적이며, 그 칸이 물음의 건전성을 위해 처음부터 필요하다.
-/
-- DD:CF-571
inductive ObservedTruth where
  /-- 성립한다. -/
  | holds
  /-- 성립하지 않는다. -/
  | fails
  /-- 판정할 수 없다. -/
  | undetermined (reason : UndeterminedReason)
  deriving DecidableEq, Repr

/--
값 또는 판정 불가.

**대응 비형식 개념:** 금액을 묻는 물음의 답. 금액이 서거나 서지 않는다.

**이 정의가 배제하는 사례:**
2008년 이후 교차통화 베이시스가 0 에서 벌어진 채 유지된 기간의 FX 스왑 잔액. 총액은 공표
수치에서 복원되지 않아 이 열거가 판정 불가로 접지만, 같은 기간에 그 포지션에 걸린 제약의
그림자 가격인 베이시스는 매일 관측됐다. 대리 관측이 있다는 것과 소스가 아예 없다는 것이 같은
칸에 든다.

**기각한 대체 정의:**
`Option` 으로 두는 안. 없음의 까닭이 사라지고, 관측층의 주된 산출물이 「소스 없음」이라는
사실 자체이므로 그 까닭을 잃으면 산출물을 잃는다.

**`Amount` 는 매개변수다.** 관측층은 수 체계를 언급하지 않으며 회계층이 L-15 에 따라 정한다.
-/
-- DD:CF-571
inductive ObservedValue (Amount : Type) where
  /-- 값이 섰다. -/
  | value (a : Amount)
  /-- 판정할 수 없다. -/
  | undetermined (reason : UndeterminedReason)
  deriving DecidableEq, Repr

/--
결제 방식별 몫의 변화.

**대응 비형식 개념:** 두 시점 사이에 각 결제 방식이 교역 가치에서 차지하는 몫이 줄었는가.
교역이 없던 경우와 사라진 경우를 몫의 변화와 가르는 것이 이 열거의 몫이다.

**이 정의가 배제하는 사례:**
2020년 상반기에 여러 회랑에서 교역이 줄었다가 하반기에 되돌아왔는데, 두 시점만 받는 이
열거는 그 사이의 경로를 담지 못한다. 줄었다가 되돌아온 것과 줄어서 머문 것이 같은 답을
받는다.

**기각한 대체 정의:**
몫의 변화량을 답에 넣는 안. 변화량은 비율이고 비율은 `ℚ` 를 부르며, L-15 가 `ℚ` 를 강제되는
경우로 한정한다. 줄었는가만 물으면 교차곱 정수 부등식으로 판정된다.
-/
-- DD:CF-571
inductive PaymentMethodShareChange (TradePaymentMethod : Type) where
  /-- 시작 시점에 교역이 없었다. 몫이 정의되지 않는다. -/
  | noTradeAtStart
  /-- 끝 시점에 교역이 사라졌다. -/
  | tradeVanished
  /-- 결제 방식마다 몫이 줄었는가. -/
  | shares (fell : TradePaymentMethod → ObservedTruth)
  /-- 실물 교역 자체를 판정할 수 없다. -/
  | undetermined (reason : UndeterminedReason)

/--
상환의 결과.

**대응 비형식 개념:** 두 시점 사이에 상환에 실패했는가. 실패했으면 지급능력 조건이
성립했는가이고, 실패하지 않았으면 대차대조표를 줄여 조정했는가이다. 지급능력 조건이
성립한 채로 실패한 것이 비유동성이다.

**이 정의가 배제하는 사례:**
2008년 9월 Lehman Brothers 의 채권 회수율이 선순위와 후순위 사이에서 크게 갈렸는데, 이
열거는 실패를 이항으로 두고 회수율을 담지 않는다. 원 논문도 롤오버 결정에서 부분 상환을
빼는 선행 연구를 따른다고 밝히므로, 이 결손은 형식화가 아니라 원 모형에서 온다.

**기각한 대체 정의:**
지급불능과 비유동성의 이분으로 두는 안. 그 분해는 실패한 경우만 가르고 실패하지 않은
경우를 가르지 않는데, 초석 명제가 위계 상단의 노드는 디폴트하지 않고 조정한다고 들므로
조정 칸이 있어야 한다. 그 칸의 근거는 이 분해를 준 편이 아니라 제약과 레버리지의 순환을
다루는 편들에 있다.
-/
-- DD:CF-571
inductive RepaymentOutcome where
  /-- 실패하지 않았다. 대차대조표를 줄여 조정했는가를 함께 든다. -/
  | noFailure (balanceSheetReduced : ObservedTruth)
  /-- 실패했다. 지급능력 조건이 성립했으면 비유동성이다. -/
  | failure (solvencyConditionHeld : ObservedTruth)
  /-- 실패 여부 자체를 판정할 수 없다. -/
  | undetermined (reason : UndeterminedReason)
  deriving DecidableEq, Repr

namespace CQ

/--
`CQ-fin-1` 교역의 결제 구성.

**대응 비형식 개념:** 나라 X가 나라 Y로 보내는 품목 k의 교역에서, 두 시점 사이에 각 결제
방식이 교역 가치에서 차지하는 몫은 줄었는가. 교역 감소가 특정 결제 방식에 몰렸는지를 보고
금융 충격과 양립하는 감소로 게재할지 정하는 데 복무한다.

**이 정의가 배제하는 사례:**
2022년 3월 러시아가 이른바 불우호국에 가스 대금의 루블 결제를 요구한 것. 이때 바뀐 것은
결제 **통화**인데 이 물음은 결제 **방식**의 몫만 묻는다. 두 축이 다르므로 통화가 통째로
갈리는 사건이 몫의 변화로는 나타나지 않는다.

**기각한 대체 정의:**
「파는 쪽이 보내지 않은 것인가, 사는 쪽의 자금조달이 서지 않은 것인가」로 묻는 안. 배타적
이분법을 전제하는데 두 원인이 동시에 성립하거나 둘 다 아닐 수 있고, 개별 거래의 자금조달은
계약 당사자만 알아서 밖에서 보는 관측자에게 소스가 구조적으로 없다.
-/
-- DD:CF-582
structure TradePaymentComposition
    (Time Country Commodity TradePaymentMethod : Type) where
  /-- 보내는 나라와 받는 나라와 품목과 두 시점을 받아 결제 방식별 몫의 변화를 낸다. -/
  answer : Country → Country → Commodity → Time → Time →
             PaymentMethodShareChange TradePaymentMethod

/-- witness (A-3). -/
-- DD:CF-31
def TradePaymentComposition.trivial :
    TradePaymentComposition Unit Unit Unit Unit where
  answer := fun _ _ _ _ _ => .undetermined .noMeasurementSource

/--
`CQ-fin-2` 교역 금융의 통화.

**대응 비형식 개념:** 나라 X가 나라 Y로 보내는 품목 k의 교역을 금융한 청구권 가운데, 한
시점에 통화 c로 표시된 청구권의 금액은 얼마인가. 교역을 표시한 통화와 상관없이 청구권이
표시된 통화로 센다. 한 통화의 자금조달 여건이 조일 때 어느 교역을 감시 대상으로 올릴지
정하는 데 복무한다.

**이 정의가 배제하는 사례:**
2008년 유럽 은행들이 FX 스왑을 거쳐 합성 달러로 자금을 조달한 것. 그 노출은 표시 통화
기준의 통계에 잡히지 않았고, 표시 통화로 세는 이 물음은 한 자금조달 다리가 여러 통화에
걸리는 경우를 담지 못한다.

**기각한 대체 정의:**
답을 단일 통화로 두고 「어느 통화인가」를 묻는 안. 합성 자금조달이 한 다리를 여러 통화에
걸치게 하므로 단일 통화로는 답이 서지 않는다. 통화마다 금액을 묻는 형태로 두면 여러 통화에
걸친 경우가 여러 답으로 나뉘어 표현된다.
-/
-- DD:CF-582
structure TradeFinanceCurrency
    (Time Country Commodity Currency Amount : Type) where
  /-- 보내는 나라와 받는 나라와 품목과 표시 통화와 시점을 받아 금액을 낸다. -/
  answer : Country → Country → Commodity → Currency → Time → ObservedValue Amount

/-- witness (A-3). -/
-- DD:CF-31
def TradeFinanceCurrency.trivial :
    TradeFinanceCurrency Unit Unit Unit Unit Unit where
  answer := fun _ _ _ _ _ => .undetermined .noMeasurementSource

/--
`CQ-fin-3` 제재 문면의 절단.

**대응 비형식 개념:** 한 시점에 효력이 있는 제재의 문면에 따르면, 주체 n은 망 ℓ에서 잘려
있는가. 제재가 어느 경로를 법적으로 끊는지 가려 다시 볼 교역과 자금조달 흐름을 고르는 데
복무한다.

**이 정의가 배제하는 사례:**
2012년 이후 이란 제재에서 문면상 허용된 인도적 교역의 결제가 코레스 은행들의 위험 회피로
끊긴 것. 문면을 기준으로 삼는 이 술어는 과잉준수를 담지 못한다. 문면이 자르지 않은 자리가
실제로 끊기는 경우가 배제된다.

**기각한 대체 정의:**
답을 「잘린 층」이라는 고정 열거의 한 원소로 두는 안. 층 타입이 시점에 따라 바뀔 수 있다는
것이 K-8 로 열려 있으므로, 열거를 넓히면 답의 공역 타입이 바뀌어 고정을 어긴다. 층 위의
술어로 두면 층을 더하는 것이 새 삼항을 더할 뿐 옛 삼항의 답을 바꾸지 않는다.

**망의 종류가 시점에 딸린다.** `NetworkKind : Time → Type` 이 K-8 을 타입으로 드러낸다.
-/
-- DD:CF-582
structure SanctionTextCut
    (Time Entity : Type) (NetworkKind : Time → Type) where
  /-- 주체와 시점과 그 시점의 망 종류를 받아 잘렸는지를 낸다. -/
  answer : Entity → (t : Time) → NetworkKind t → ObservedTruth

/-- witness (A-3). -/
-- DD:CF-31
def SanctionTextCut.trivial :
    SanctionTextCut Unit Unit (fun _ => Unit) where
  answer := fun _ _ _ => .undetermined .noMeasurementSource

/--
`CQ-fin-4` 담보에 걸린 부채수용력.

**대응 비형식 개념:** 한 시점에 교역 주체 m의 부채수용력은 상품 k의 담보 가치에 걸려
있는가. 상품 가격의 충격이 교역 주체의 자금조달을 거쳐 교역 물량으로 넘어갈 자리를 감시
대상으로 올릴지 정하는 데 복무한다.

**이 정의가 배제하는 사례:**
2022년 3월 런던금속거래소의 니켈 가격이 장중에 급등해 거래가 정지되고 체결이 취소된 것.
그때 문제가 된 것은 의존의 유무가 아니라 증거금 요구의 **크기**였는데, 이 술어는 의존이
있는지만 답한다. 의존이 있다는 것은 그 사건 전에도 참이었다.

**기각한 대체 정의:**
전달 크기를 답에 넣는 안. 담보 가치는 값이고 값의 결정은 동학층이므로, 크기를 물으면 답이
동학층으로 떨어져 재유입 산출물로는 답해지지 않는다.
-/
-- DD:CF-582
structure DebtCapacityCollateralDependence
    (Time Entity Commodity : Type) where
  /-- 교역 주체와 상품과 시점을 받아 구조적 의존이 있는지를 낸다. -/
  answer : Entity → Commodity → Time → ObservedTruth

/-- witness (A-3). -/
-- DD:CF-31
def DebtCapacityCollateralDependence.trivial :
    DebtCapacityCollateralDependence Unit Unit Unit where
  answer := fun _ _ _ => .undetermined .noMeasurementSource

/--
`CQ-fin-5` 보유자 유형.

**대응 비형식 개념:** 한 시점에 나라 X에 대한 청구권 가운데, 제약 유형 j의 보유자가 드는
통화 c 표시 청구권의 금액은 얼마인가. 한 나라의 자금조달 긴축을 은행 경로와 채권시장 경로
가운데 어디서 감시할지 정하는 데 복무한다.

**이 정의가 배제하는 사례:**
2013년 테이퍼 텐트럼에서 신흥국 자국통화 국채가 팔린 것. 그때 보유자 구성이 먼저 바뀐 것이
아니라 같은 보유자의 제약이 조여서 매도가 나왔는데, 보유자 유형별 금액만 묻는 이 물음은
제약이 조이는 것을 담지 못한다.

**기각한 대체 정의:**
제약이 실제로 구속하는지를 함께 묻는 안. 구속 여부는 위험 측정의 변화에 매달리므로
동학층이고, 재유입 산출물로 답해지지 않는다.
-/
-- DD:CF-582
structure ClaimsByHolderConstraintKind
    (Time Country HolderConstraintKind Currency Amount : Type) where
  /-- 나라와 보유자 제약 유형과 표시 통화와 시점을 받아 금액을 낸다. -/
  answer : Country → HolderConstraintKind → Currency → Time → ObservedValue Amount

/-- witness (A-3). -/
-- DD:CF-31
def ClaimsByHolderConstraintKind.trivial :
    ClaimsByHolderConstraintKind Unit Unit Unit Unit Unit where
  answer := fun _ _ _ _ => .undetermined .noMeasurementSource

/--
`CQ-fin-6` 통화 교환의 도달 범위.

**대응 비형식 개념:** 한 시점에 주체 n은 중앙은행 간 통화 교환 s가 공급하는 외화가
구조적으로 닿는 범위 안에 있는가. 외화 자금조달 긴축이 중앙은행의 공급으로 풀릴 자리와
풀리지 않을 자리를 가려 감시할지 정하는 데 복무한다.

**이 정의가 배제하는 사례:**
2008년 연준의 달러 스왑라인이 여러 중앙은행에 열려 있었으나 실제 인출은 중앙은행마다
크게 달랐던 것. 구조적 도달 범위 안에 있으면서도 공급을 받지 못한 자리가 있었는데, 이
술어는 범위만 묻고 활성화와 인출을 묻지 않는다.

**기각한 대체 정의:**
실제 유동성 흐름이 닿았는지를 묻는 안. 활성화와 인출은 결정이므로 동학층으로 떨어진다.
구조적 도달 범위로 좁히면 유한 그래프의 도달 가능성이라 판정된다.
-/
-- DD:CF-582
structure SwapLineReach
    (Time Entity CentralBankSwapLine : Type) where
  /-- 주체와 통화 교환과 시점을 받아 도달 범위 안에 있는지를 낸다. -/
  answer : Entity → CentralBankSwapLine → Time → ObservedTruth

/-- witness (A-3). -/
-- DD:CF-31
def SwapLineReach.trivial :
    SwapLineReach Unit Unit Unit where
  answer := fun _ _ _ => .undetermined .noMeasurementSource

/--
`CQ-fin-7` 결정 단위별 보유.

**대응 비형식 개념:** 한 시점에 나라 X에 대한 청구권 가운데, 의사결정 단위 d가 드는 통화 c
표시 청구권의 금액은 얼마인가. 청구권을 든 법인의 소재지가 아니라 그 법인이 속한 결정
단위로 센다. 허브를 거친 자금조달을 허브 소재국에 대한 의존으로 오독하지 않고 게재하는 데
복무한다.

**이 정의가 배제하는 사례:**
2008년 9월 Lehman Brothers 의 런던 법인이 도산 절차에 들어가면서 그 법인이 들고 있던 고객
자산이 동결된 것. 그전까지 하나의 결정 단위로 관리되던 현금이 법인 경계를 따라 갈렸는데,
이 물음은 시점마다 결정 단위를 주어진 것으로 받으므로 귀속이 법적 절차로 사후에 재정의되는
것을 담지 못한다.

**기각한 대체 정의:**
소재지로 세는 안. 소재지는 J-1 이 관측 투영으로 두는 것이고, 허브를 거친 자금조달을 허브
소재국에 대한 의존으로 읽게 만든다.
-/
-- DD:CF-582
structure ClaimsByDecisionUnit
    (Time Country Node Currency Amount : Type) where
  /-- 나라와 의사결정 단위와 표시 통화와 시점을 받아 금액을 낸다. -/
  answer : Country → Node → Currency → Time → ObservedValue Amount

/-- witness (A-3). -/
-- DD:CF-31
def ClaimsByDecisionUnit.trivial :
    ClaimsByDecisionUnit Unit Unit Unit Unit Unit where
  answer := fun _ _ _ _ => .undetermined .noMeasurementSource

/--
`CQ-fin-8` 위계의 순서.

**대응 비형식 개념:** 한 시점에 화폐성 위계에서 주체 m은 주체 n보다 위에 있는가. 교역
상대가 위계에서 어느 주체들의 아래에 있는지 가려 게재할지 정하는 데 복무한다. 위계 위치와
실패의 관계는 이 물음이 전제하지 않으며 `CQ-fin-9` 와 짝지어 검증한다.

**이 정의가 배제하는 사례:**
2008년 10월 연준이 기업어음 매입 기구를 세워 시장이 팔고 있는 것을 사겠다고 약속한 것.
J-4 가 위계 최상단을 그 기능으로 정의하는데, 두 주체의 상대 위치만 묻는 이 술어는 그
기능을 담지 못한다. 최상단이 「위가 없는 노드」로만 표현된다.

**기각한 대체 정의:**
위계 위치와 실패의 관계를 함께 묻는 안. 초석 명제가 상단의 노드는 조정하고 하단에서 상환
실패가 난다고 드는데, 그것을 물음에 넣으면 CQ가 자기가 검증할 이론을 전제로 품는다.
-/
-- DD:CF-582
structure MonetaryHierarchyOrder
    (Time Entity : Type) where
  /-- 두 주체와 시점을 받아 앞이 뒤보다 위에 있는지를 낸다. -/
  answer : Entity → Entity → Time → ObservedTruth

/-- witness (A-3). -/
-- DD:CF-31
def MonetaryHierarchyOrder.trivial :
    MonetaryHierarchyOrder Unit Unit where
  answer := fun _ _ _ => .undetermined .noMeasurementSource

/--
`CQ-fin-9` 상환의 결과.

**대응 비형식 개념:** 두 시점 사이에 주체 n은 상환에 실패했는가. 실패했다면 지급능력 조건이
성립했는가이고, 실패하지 않았다면 대차대조표를 줄여 조정했는가이다. 그 실패를 유동성 공급으로
되돌아갈 교란으로 게재할지 정하고, 실패하지 않은 주체가 조정으로 긴축을 흡수했는지를 보는 데
복무한다.

**이 정의가 배제하는 사례:**
2008년 9월 Lehman Brothers 채권의 회수율이 등급마다 갈린 것. 이 물음은 실패를 이항으로 두고
회수율을 담지 않으며, 그 결손은 답 타입에서 온 것이 아니라 분해를 준 원 모형이 부분 상환을
빼기 때문이다.

**기각한 대체 정의:**
지급불능과 비유동성의 이분으로 두는 안. 그 분해는 실패한 경우만 가르고 실패하지 않은 경우의
조정을 담지 않는다. 그리고 그 분해에서 지급능력 조건은 장부에 없는 자산 수익률을 인자로
가지므로, 성립 여부를 사후에도 재지 못하는 경우가 남는다.
-/
-- DD:CF-582
structure RepaymentAndAdjustment
    (Time Entity : Type) where
  /-- 주체와 두 시점을 받아 상환의 결과를 낸다. -/
  answer : Entity → Time → Time → RepaymentOutcome

/-- witness (A-3). -/
-- DD:CF-31
def RepaymentAndAdjustment.trivial :
    RepaymentAndAdjustment Unit Unit where
  answer := fun _ _ _ => .undetermined .noMeasurementSource

/--
`CQ-fin-10` 담보 배수.

**대응 비형식 개념:** 한 시점에 상품 k를 담보로 한 청구권의 합과 그 실물의 가치는 통화 c로
각각 얼마인가. 상품 담보가 그 실물 가치의 몇 배에 해당하는 청구권을 떠받치는지 보고, 담보
가치의 충격이 증폭될 자리를 감시할지 정하는 데 복무한다.

**이 정의가 배제하는 사례:**
2008년 Lehman Brothers 의 프라임브로커리지에서 재담보된 고객 자산의 사슬이 끊긴 것. 그때
문제가 된 것은 평균 배수가 아니라 특정 사슬이 한 노드에서 끊겼다는 것인데, 두 총계만 내는
이 물음은 사슬의 모양을 담지 못한다.

**기각한 대체 정의:**
비율 하나로 답하는 안. 비율은 `ℚ` 를 부르고 L-15 가 `ℚ` 를 강제되는 경우로 한정하므로,
두 값을 각각 내면 배수의 판정이 교차곱 정수 부등식으로 선다.
-/
-- DD:CF-582
structure PledgedClaimsAndStock
    (Time Commodity Currency Amount : Type) where
  /-- 상품과 통화와 시점을 받아 담보로 제공된 청구권의 합과 실물의 가치를 함께 낸다. -/
  answer : Commodity → Currency → Time → ObservedValue Amount × ObservedValue Amount

/-- witness (A-3). -/
-- DD:CF-31
def PledgedClaimsAndStock.trivial :
    PledgedClaimsAndStock Unit Unit Unit Unit where
  answer := fun _ _ _ =>
    (.undetermined .noMeasurementSource, .undetermined .noMeasurementSource)

/--
`CQ-fin-11` 통화 불일치의 전달.

**대응 비형식 개념:** 한 시점에 금융 주체 m이 드는 통화 d 표시 청구권 가운데, 통화 c에서
통화 불일치를 가진 비금융 주체에 대한 청구권의 금액은 얼마인가. 통화 c가 절하될 때 교역
주체의 통화 불일치를 거쳐 제약이 조일 금융 주체를 가려 감시할지 정하는 데 복무한다.

**이 정의가 배제하는 사례:**
1997년 아시아 위기에서 기업의 통화 불일치가 은행의 제약으로 넘어가는 데 걸린 시간과 그
경로가 나라마다 달랐던 것. 이 물음은 한 시점의 잔액만 내고 전달 자체를 담지 못하며, 전달
엣지의 타입이 아직 정의되지 않았다는 것이 그 자리의 구멍이다.

**기각한 대체 정의:**
전달이 있었는지를 술어로 묻는 안. 전달 엣지의 타입이 정의되지 않아 술어를 쓸 수 없고,
금액을 물으면 그 공백이 답을 막는 자리로 드러난다.
-/
-- DD:CF-582
structure ClaimsOnMismatchedDebtors
    (Time Entity Currency Amount : Type) where
  /-- 금융 주체와 불일치 통화와 표시 통화와 시점을 받아 금액을 낸다. -/
  answer : Entity → Currency → Currency → Time → ObservedValue Amount

/-- witness (A-3). -/
-- DD:CF-31
def ClaimsOnMismatchedDebtors.trivial :
    ClaimsOnMismatchedDebtors Unit Unit Unit Unit where
  answer := fun _ _ _ _ => .undetermined .noMeasurementSource

end CQ

end CrisisFramework.Observation
