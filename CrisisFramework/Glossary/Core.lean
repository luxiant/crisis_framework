/-
용어집 — 핵심 개념

규율: V-1(개념의 존재와 관계만), V-2(관계 4종), V-6(A-3 적용 제외).
이 파일은 성질을 담지 않는다. 성질을 갖는 정의는 Definition/ 이하에 둔다(D-7).

이 파일은 네 형식층 전체의 선행 조건이며 어떤 층도 아니다.
따라서 수를 쓰지 않고, 다른 어떤 CrisisFramework 모듈도 import 하지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

namespace CrisisFramework.Glossary

/--
개념 식별자.

집계 정리(J-9)에 필요한 최소 집합만 등재한다. 확장은 사용처가 생길 때 한다.
-/
-- DD:CF-76
inductive Concept where
  /-- 의사결정 단위. 대차대조표 관리의 결정이 하나로 내려지는 최소 단위. 노드의 정의. -/
  | decisionUnit
  /-- 대차대조표. 통화로 색인된 족(L-12). -/
  | balanceSheet
  /-- 자기자본. 대차대조표의 잔여 항목. -/
  | equity
  /-- 제약. 노드가 무엇을 할 수 있는지의 한계. -/
  | constraint
  /-- 부채 측 한도. 얼마나 빌릴 수 있는가. -/
  | constraintLiabilityCap
  /-- 자산 측 적격성. 무엇을 보유할 수 있는가. -/
  | constraintAssetEligibility
  /-- 신용공급. 노드가 공여할 수 있는 신용의 양. -/
  | creditSupply
  /-- 신호. 발동조건이 읽는 것. 아래 둘의 상위 개념이며 형식층 대상을 갖지 않는다. -/
  | signal
  /-- 검증 가능 신호. 계약 당사자와 법원이 함께 확인할 수 있는 감사된 회계수치. -/
  | verifiableSignal
  /-- 외생 확인 신호. 모형이 계산하지 않고 밖에서 받는 판정. -/
  | exogenousSignal
  /-- 발동조건. 조건부 청구권이 요구를 발생시키는 조건. -/
  | triggerCondition
  /-- 결제 방식. 교역 한 건의 대금이 물품에 대해 언제, 누구를 통해 치러지는가. 아래 다섯의 상위 개념이다. -/
  | tradePaymentMethod
  /-- 선지급. 수입자가 선적 전에 대금을 치른다. -/
  | cashInAdvance
  /-- 신용장. 은행이 일치하는 제시에 대해 결제를 확약한다. -/
  | letterOfCredit
  /-- 추심. 은행이 서류를 다루되 지급을 확약하지 않는다. -/
  | documentaryCollection
  /-- 후지급. 물품이 먼저 인도되고 대금은 기일에 치러진다. -/
  | openAccount
  /-- 그 밖의 결제 조건. 위 넷 가운데 어느 것도 들지 않는다. -/
  | otherPaymentTerms
  /-- 청구권. 한 당사자가 다른 당사자에게 통화나 종류물의 일정량을 특정 조건 아래 요구할 수 있는 권리. -/
  | claim
  /-- 반환 청구권. 담보를 받은 쪽이 같은 종류의 것을 돌려줄 의무에 대응하는 권리. -/
  | returnClaim
  /-- 담보물. 담보로 제공될 수 있는 것. 아래 둘의 상위 개념이다. -/
  | pledgeableAsset
  /-- 청구권인 담보물. 청구권 집합의 색인으로 함께 지목된다. -/
  | claimPledgeable
  /-- 청구권이 아닌 담보물. 색인을 갖지 않는 것 전부이며, 외부 자산과 외연이 같아질 수 있으나
      판정이 다르다. 이쪽은 색인의 유무로 서고 외부 자산은 대차대조표의 대응물로 선다. -/
  | nonClaimPledgeable
  /-- 외부 자산. 다른 노드의 대차대조표에 대응물이 없는 말단 자산. -/
  | externalAsset
  /-- 담보 제공. 담보물 하나가 청구권 하나를 떠받치고 반환 의무 하나를 낳는 관계. -/
  | pledge
  /-- 재담보. 받은 담보를 처분하고 같은 종류의 것을 돌려줄 의무만 지는 것. -/
  | rehypothecation
  /-- 원천 담보. 재담보 권리가 딸린 제공. -/
  | sourceCollateral
  /-- 재담보된 담보. 권리가 있고 실제로 다시 제공된 것. -/
  | rehypothecatedCollateral
  /-- 재담보 가능 담보. 권리가 있으나 아직 다시 제공되지 않은 것. -/
  | rehypothecatableCollateral
  /-- 담보 제공에 붙는 비율. 아래 둘의 상위 개념이다. -/
  | pledgeRate
  /-- 떠받쳐야 할 것에 요구되는 자기자본의 몫. 개시증거금과 변동증거금이 든다. -/
  | exposureMargin
  /-- 떠받치는 것을 얼마로 쳐 주는가. 차감률이 아니라 곱하는 비율이다. -/
  | valuationRate
  /-- 자본청구권. 발행자의 자기자본에 대한 잔여 청구권이며, 요구할 금액이 상수가 아니라 그
      자기자본에 걸린다. -/
  | equityClaim
  /-- 외부 자산의 몫. 한 당사자가 외부 자산 하나에서 갖는 지분이며 아래 둘의 상위 개념이다. -/
  | externalAssetShare
  /-- 보유 몫. 담보로 내놓지 않고 들고 있는 지분. -/
  | heldAssetShare
  /-- 제공된 몫. 담보로 내놓아 어느 제공에 묶인 지분. -/
  | pledgedAssetShare
  /-- 화폐성. 청구권이 액면가를 약속하는 모양이며 아래 셋의 상위 개념이다. -/
  | moneyness
  /-- 화폐. 요구 시 액면가를 약속한다. -/
  | money
  /-- 화폐 유사. 만기 시 액면가를 약속하며 명시된 만기가 익일 초과 1년 미만이다. -/
  | moneyLike
  /-- 그 밖의 청구권. 위 둘 가운데 어느 것도 들지 않는다. -/
  | nonMoney
  /-- 액면가 약속의 강도. 정부로부터의 근접성이며 아래 넷의 상위 개념이다. -/
  | parPromiseStrength
  /-- 순수 공적 화폐. 공적 자산이 떠받치고 공적 백스톱이 직접 받친다. -/
  | publicMoney
  /-- 부보 화폐. 사적 자산이 떠받치고 공적 백스톱이 직접 받친다. -/
  | insuredMoney
  /-- 공적 그림자 화폐. 공적 자산이 떠받치고 공적 백스톱이 간접으로만 받친다. -/
  | publicShadowMoney
  /-- 순수 사적 화폐. 사적 자산이 떠받치고 공적 백스톱이 받치지 않는다. -/
  | privateShadowMoney
  /-- 담보권을 세우는 제공. 소유권이 제공자에게 남는다. -/
  | securityInterestPledge
  /-- 소유권을 넘기는 제공. 같은 종류의 것을 돌려줄 의무가 선다. -/
  | titleTransferPledge
  /-- 그 주체에게 화폐인 것. 한 주체가 자기보다 위계가 높은 주체의 화폐부채로 보유하는 것이며,
      무엇이 그것인지가 주체마다 다르다. -/
  | nodeMoneyAsset
  /-- 지급능력. 자산의 합이 부채의 합에 모자라지 않은 상태. -/
  | solvency
  /-- 인출 충족. 그 구간에 돌려달라는 요구를 당장 내줄 수 있는 것으로 전부 맞출 수 있는 상태. -/
  | withdrawalCoverage
  /-- 상환 실패. 지급 의무가 선 액수를 그 구간에 내준 액수가 다 맞추지 못한 상태. -/
  | repaymentFailure
  /-- 유동성 풋. 만기 불일치를 운영하는 주체가 공황에서 추가 유동성에 닿는 선택권이며, 그 여지가
      모두에게 같지 않아 주체 사이에 위계를 이룬다. -/
  | liquidityPut
  /-- 사적 유동성 풋. 집행이 사적 시장 참가자에 달린 유동성 풋이다. -/
  | privateLiquidityPut
  /-- 공적 유동성 풋. 집행이 중앙은행에 달린 유동성 풋이다. -/
  | publicLiquidityPut
  /-- 자금조달 유동성 접근. 자산을 담보로 빌려 유동성에 닿는 선택권이다. -/
  | fundingLiquidityAccess
  /-- 시장 유동성 접근. 자산을 팔아 유동성에 닿는 선택권이다. -/
  | marketLiquidityAccess
  /-- 최후대출자 접근. 자산을 중앙은행에 넘겨 유동성에 닿는 선택권이다. -/
  | lastResortLendingAccess
  /-- 통화 백스톱 접근. 주권이 갖는 선택권이며 중앙은행이 집행한다. -/
  | currencyBackstopAccess
  /-- 신용 풋. 화폐 청구권의 액면가 약속에 붙는 신용 보호이며, 보호의 수준이 청구권마다 달라
      수단 종류 사이에 위계를 이룬다. -/
  | creditPut
  /-- 사적 신용 풋. 제공자가 사적 주체인 신용 풋이다. -/
  | privateCreditPut
  /-- 공적 신용 풋. 제공자가 공적 부문인 신용 풋이다. -/
  | publicCreditPut
  /-- 최종 채권자 청구권. 최종 국내 채권자가 드는 청구권이며, 원전이 핵심이라 부르는 것이다. -/
  | ultimateCreditorClaim
  /-- 최종성 미판정 청구권. 보유자 부문만으로는 최종 국내 채권자가 드는지가 갈리지 않는
      청구권이며, 원전이 중간이라 부르는 것이다. -/
  | undeterminedUltimacyClaim
  /-- 비최종 채권자 청구권. 중개기관이나 해외 채권자가 드는 청구권이며, 원전이 비핵심이라 부르는
      것이다. -/
  | nonUltimateCreditorClaim
  /-- 소매 유출 동등 청구권. 감독 규범이 소매예금과 똑같이 취급하는 무담보 도매 조달이다. -/
  | retailOutflowEquivalentClaim
  /-- 장부 레버리지 조정 모드. 자산이 부채와 자기자본의 합이라는 항등식의 세 성분 가운데
      무엇을 고정한 채 레버리지를 올리는가이며 아래 셋의 상위 개념이다. -/
  | bookLeverageAdjustmentMode
  /-- 자산 고정 조정. 자산 총액을 고정한 채 부채를 발행해 자기자본을 줄인다. -/
  | assetFixedAdjustment
  /-- 부채 고정 조정. 부채 총액을 고정한 채 자산가격의 변동이나 자산매각 배당으로
      자기자본이 움직인다. -/
  | liabilityFixedAdjustment
  /-- 자기자본 고정 조정. 자기자본을 고정한 채 차입으로 자산을 넓힌다. -/
  | equityFixedAdjustment
  /-- 보통주 장부자본. 자본 가운데 보통주만 센 장부금액이다. -/
  | commonShareBookCapital
  /-- 후순위 포함 장부자본. 자기자본에 후순위채를 더해 센 장부금액이다. -/
  | subordinatedInclusiveBookCapital
  /-- 담보 여력. 그 주체가 담보로 내놓지 않고 들고 있는 몫 가운데 제약의 자산 측 적격성을 통과
      하는 것의 양이다. 초석 명제가 전파의 매개로 드는 둘 가운데 하나다. -/
  | collateralCapacity
  /-- 부채수용력. 그 주체가 제약에 물리기까지 더 질 수 있는 부채의 양이다. 초석 명제가 전파의
      매개로 드는 둘 가운데 다른 하나다. -/
  | debtCapacity
  /-- 자산 감소의 까닭. 그 주체의 자산 총액이 두 시점 사이에 줄었을 때 그것이 무엇 때문인가. -/
  | assetReductionCause
  /-- 상환에 따른 소멸. 자산이 줄면서 부채가 함께 줄었다. -/
  | repaymentExtinction
  /-- 매각. 자산이 줄었는데 부채가 함께 줄지 않았다. -/
  | assetSaleReduction
  /-- 보유자 위임. 청구권의 보유자가 자기 대차대조표를 무엇을 위해 운용하는가이며 아래 셋의
      상위 개념이다. -/
  | holderMandate
  /-- 부채 대응 위임. 자기 부채를 맞추려고 운용하며 자산과 부채의 구조적 불일치를 줄인다. -/
  | liabilityMatchingMandate
  /-- 기준 초과 위임. 비교 기준을 넘는 수익을 내려고 운용하며 차입으로 노출을 넓힌다. -/
  | benchmarkBeatingMandate
  /-- 손실 회피 위임. 원금을 지키려고 운용하며 신용과 만기와 유동성 위험을 피한다. -/
  | lossAvoidanceMandate
  /-- 경제적 자본. 그 주체가 자기 위험을 덮으려고 내부에서 배분하는 자본이다. -/
  | economicCapital
  /-- 규제자본. 감독 규범이 비율의 분자로 세는 자본이며 장부자본에서 공제와 가산을 거친다. -/
  | regulatoryCapital
  /-- 자본 조정 체제. 한 자본 개념에서 다른 자본 개념으로 갈 때 어느 항목에 어느 방향의 조정을
      걸고 어느 항목을 쓰지 않는가의 선택이며, 감독 지침이 그 선택을 기관의 책임으로 둔다. -/
  | capitalAdjustmentRegime
  /-- 위험가중자산. 자산마다 가중을 곱해 더한 값이며 규제 비율의 분모다. -/
  | riskWeightedAsset
  /-- 지급능력 제약 축. 자기자본의 부호가 걸리는 축이다. -/
  | solvencyConstraintAxis
  /-- 유동성 제약 축. 조달의 접근이 걸리는 축이다. -/
  | liquidityConstraintAxis
  /-- 결정 시계. 대차대조표 관리의 결정이 평가받는 시점까지의 기간이며 의사결정 단위에 붙는다. -/
  | decisionHorizon
  /-- 시계 불일치. 그 단위가 든 자산의 만기가 결정 시계를 넘는 상태이며 조달과 자산의 만기
      불일치와 측정 소스가 다르다. -/
  | horizonMismatch
  /-- 자산 분할 체제. 한 주체의 자산 총액을 범주로 가를 때 그 가름이 삼는 축이다. -/
  | assetPartitionRegime
  /-- 유동성 단의 체제. 자산을 환가의 확실성으로 가르고 단마다 가중이 붙는다. -/
  | liquidityTierRegime
  /-- 만기 구간의 체제. 자산을 잔존만기로 가르고 구간마다 하한이 걸린다. -/
  | maturityBucketRegime
  /-- 수단 유형의 체제. 자산을 발행자와 담보와 양도성으로 가르고 금액만 공시된다. -/
  | instrumentClassRegime
  /-- 부담 상태의 체제. 자산을 담보로 제공됐는가로 가른다. -/
  | encumbranceStateRegime
  /-- 시장 조달 접근. 자기 부채를 시장에 발행해 유동성에 닿는 선택권이며, 그 여지가 같은 보유자
      부문 안에서도 갈려 최종성을 가르는 축이 된다. -/
  | marketFundingAccess
  /-- 중앙은행 담보 적격성. 한 증권이 중앙은행의 대출 제도에서 담보로 받아들여지는 성질이며,
      증권에만 붙지 않고 증권과 보유자의 쌍에 붙는다. -/
  | centralBankCollateralEligibility
  /-- 통화. 대차대조표를 색인하는 축이며 발행되는 영역과 쓰이는 영역이 갈릴 수 있다. -/
  | currency
  /-- 자금조달 통화. 부채 계약을 표시하는 역할을 맡는 통화이며, 원 문헌이 그 역할을 셋째로 들고
      자주 간과된다고 적는다. -/
  | fundingCurrency
  /-- 공적 준비통화. 공적 부문이 대외 지급 준비로 보유하는 역할을 맡는 통화. -/
  | officialReserveCurrency
  /-- 교역 표시통화. 재화와 서비스의 국제 교역을 표시하는 역할을 맡는 통화. -/
  | tradeInvoicingCurrency
  /-- 국제통화. 자국 관할권보다 넓은 영역을 갖는 통화이며, 역외에서 비거주자 사이의 거래를
      표시한다. -/
  | internationalCurrency
  /-- 자국통화. 한 노드에게 그 통화가 자기 영역의 통화인 관계이며, 노드의 나라가 아니라 통화가
      쓰이는 영역이 그 여부를 정한다. -/
  | domesticCurrency
  /-- 통화 불일치. 한 주체의 장부에서 자산과 부채의 표시 통화가 어긋난 상태이며, 그 어긋남이
      무엇으로 색인되는지는 아래 둘이 가른다. -/
  | currencyMismatch
  /-- 순노출 통화 불일치. 어느 통화 축에서 자산과 부채의 차가 영이 아닌 상태이며, 그 축 하나로
      색인된다. 대외 포지션의 통화 구성 통계와 감독 당국의 신용등록부가 그 값을 낸다. -/
  | currencyPositionMismatch
  /-- 조달 연결 통화 불일치. 어느 통화로 진 부채가 다른 통화의 자산을 조달한 상태이며, 부채 통화와
      자산 통화의 쌍으로 색인된다. 그 값을 내는 공시 경로가 없다. -/
  | currencyFundingLinkMismatch
  /-- 통화 불일치 전달. 한 주체의 통화 불일치가 그 주체의 상환 실패 가능성을 높이는
      관계이며, 그 가능성이 그 주체의 청구권을 보유한 주체의 제약 인자로 옮겨 가는 뒤 고리는
      조달처가 없어 이 회차가 등재하지 않았다. -/
  | currencyMismatchTransmission
  /-- 중앙은행 유동성 라인. 한 중앙은행이 다른 중앙은행에 자기 통화를 공급하는 기본 약정이며,
      공급의 대가로 무엇을 받는가가 그 아래의 갈래를 가른다. -/
  | centralBankLiquidityLine
  /-- 중앙은행 스왑 라인. 상대 중앙은행의 통화를 대가로 받는 유동성 라인이며, 그 대가가 만기에
      같은 환율로 되돌아가므로 공급자가 환위험을 지지 않는다. -/
  | centralBankSwapLine
  /-- 중앙은행 레포 라인. 적격 담보를 대가로 받는 유동성 라인이며, 그 담보가 공급자의 자국 통화
      표시 국채로 제한되므로 상대 통화의 잔고가 공급자에게 서지 않는다. -/
  | centralBankRepoLine
  /-- 환위험 귀속. 되돌리는 거래의 환율이 처음과 같은지에 따라 환율 변동의 부담이 어느 주체의
      장부에 서는가이며, 그 조항이 그것을 정하지 않는 자리가 아무도 지지 않는 자리와 다르다. -/
  | fxRiskAttribution
  deriving DecidableEq, Repr

/--
측정 소스 태그.

**이름만 둔다.** 실제 측정 사상의 명세는 관측층(Observation/)이 보유한다.

L-9의 의존 방향이 관측층 → 정의층이므로, 용어집이 관측층을 참조할 수 없다.
그래서 태그와 명세가 분리된다. 이 분리는 층 구조가 강제한 것이지 설계 선택이 아니다.
-/
-- DD:CF-57
inductive SourceTag where
  /-- 규제 공시 (10-K, 10-Q 등). -/
  | regulatoryFiling
  /-- BIS 소재지 기준 은행통계. -/
  | bisLocational
  /-- 자금순환표. -/
  | flowOfFunds
  /-- 세관 신고. 나라에 따라 거래마다 결제 방식을 든다. -/
  | customsDeclaration
  /-- SWIFT 메시지. 신용장 개설(MT700)과 추심 대금 통지(MT400)다. -/
  | swiftMessage
  /-- 은행 감독 보고. 미국 FFIEC 009 의 교역금융 청구권이다. -/
  | bankSupervisoryReport
  /-- 외환 결제 통계. 수출입 대금을 결제 방식별로 가른다. -/
  | fxSettlementStatistics
  /-- 기업조사. 매출의 지급 시점을 묻는다. -/
  | enterpriseSurvey
  /-- 재무제표의 담보 주석. 받아서 인도하거나 재담보하도록 허용된 금융상품의 공정가치와 그중
      실제로 인도하거나 재담보한 금액을 든다. -/
  | pledgeNote
  /-- 재무제표에서 담보로 제공된 자산의 장부금액. 재고자산과 금융자산과 유형자산에 각각 다른
      조항이 걸리며 자산의 종류별 분해를 요구하지 않는다. 기준일 시점의 값이다. -/
  | encumberedAssetNote
  /-- 감독 규범의 자산 부담 공시. 제공된 자산과 제공되지 않은 자산을 범주별로 가르되 적용
      대상이 신용기관이고, 값이 분기 자료의 이동 중위값이다. -/
  | assetEncumbranceDisclosure
  /-- 금속 거래소 창고의 재고 공표. 등록분과 등록되지 않은 보관분을 일별로 들되 보유자를
      식별하지 않으며, 거래소에 등록된 창고의 밖은 범위에 들지 않는다. -/
  | exchangeWarehouseReport
  deriving DecidableEq, Repr

/--
개념 간 관계.

V-2에 따라 정확히 넷이다. 다섯 번째 생성자를 추가하려면 규율 개정이 선행되어야 하며,
그 필요 자체를 P-1의 수확으로 기록해야 한다.

**다섯 번째 관계를 더하지 않기로 했다.** 화폐성이 스펙트럼이라는 것을 이 넷으로 적을 수 없다는
것이 구멍으로 서 있었으나, 그 분할은 명시된 만기로 배타적으로 서므로 이 넷이 담는다. 담기지 않는
것은 화폐성의 정도이고 그것이 가격 위험으로 재어져 수를 요구하므로, 무차원인 이 파일이 담지 못하는
것이 층의 귀결이다. 그 정도를 담는 층은 구멍으로 등재되어 있다.
-/
-- DD:CF-77
inductive ConceptRel where
  /-- 정제: `special` 은 `general` 의 특수 사례다. -/
  | refines (special general : Concept)
  /-- 배타: 두 개념은 겹치지 않는다. -/
  | excludes (a b : Concept)
  /-- 분할: `whole` 이 `parts` 로 나뉜다. 완전성은 증명되지 않는다(V-7). 정의만으로 따라 나오는 분할은 예외이며 그 경우 어느 귀결인지를 명시한다. -/
  | partitions (whole : Concept) (parts : List Concept)
  /-- 측정 대응: 해당 개념이 이 소스로 측정된다. 명세는 관측층. -/
  | measuredBy (c : Concept) (s : SourceTag)
  deriving Repr

/--
등록된 관계.

**주의:** `partitions` 의 완전성은 V-7에 따라 가정이며 기여 목록에 계상하지 않는다.
정의만으로 따라 나오는 분할은 예외이며, 아래 등록분 가운데 결제 방식의 분할 하나만 거기에 든다.
제약이 부채 측과 자산 측 둘로 나뉜다는 것은 현재까지 확인된 두 종류일 뿐,
셋째가 없다는 증명이 아니다.

**신호 분할의 V-4 사례.** 2007-08년에 같은 기능을 하던 두 종류의 유동성 풋이 갈렸다. 은행이
도관에 계약상 크레딧 라인으로 제공한 풋은 담보가치 하락과 ABCP 롤 실패와 헤어컷 상승을 거쳐
실제로 발동했고, SIV 와 도관에 대한 암묵적 풋은 이행되지 않았다. 갈린 자리가 조건이 문서에
있었는가이며, 그것이 검증 가능 신호와 외생 확인 신호를 가르는 축과 같다.
`docs/extractions/extraction-06-pozsar-adrian-ashcraft-boesky-2010.md` §10 이 그 대비를 든다.

**`measuredBy` 를 신호에 붙이지 않는다.** 신호에 측정 소스를 대응시키는 일은 관측 명세를
세우는 페이즈의 몫이고, 그 자리에서 관측자 상대성의 구멍이 발화하기 때문이다.

**결제 방식 분할은 정의만으로 완전하다.** 그 밖의 결제 조건이 넷 가운데 어느 것도 들지 않는
조건을 모두 받으므로 여집합의 귀결이다(V-7).

**결제 방식 분할의 V-4 사례.** 2008-09년 위기에 한 미국 수출기업에서 선지급 고객의 매입 감소와
이탈이 후지급 고객보다 컸고, 신규 고객은 선지급으로 더 많이 들어왔다(Antràs · Foley 2015). 같은
교역 감소가 결제 방식마다 다르게 나타났다.

**결제 방식에는 `measuredBy` 를 붙인다.** 관측 명세가 공시 경로로 색인되어 관측자 상대성의 걸림이
풀렸기 때문이다. 방식마다 측정 대응의 집합이 서로 달라 V-5 를 통과한다. 신호에 붙이지 않는다는 앞
문단은 그대로다.

**보유자 위임 분할의 모든 쌍이 배타적이다.** 한 보유자가 두 위임을 함께 받는 배치를 원전이 들지
않고 각 부류가 하나의 위임으로 정의되므로, 세 쌍 전부에 배타 관계를 등록한다.

**보유자 위임 분할의 V-4 사례.** 2008년 가을에 기관 현금풀이 프라임 머니펀드에서 빠져나가
정부전용 머니펀드와 국채로 옮겨 간 것과, 같은 시기에 레버리지 채권 포트폴리오가 딜러의 조달
축소로 포지션을 줄인 것이 같은 충격 아래에서 서로 반대 방향의 조정이었다. 앞은 손실 회피 위임이
자산 측 적격성을 좁힌 결과이고 뒤는 기준 초과 위임이 조달에 매달린 결과이므로, 한 위임으로는 두
행태가 함께 설명되지 않는다(Pozsar 2015).

**기준 초과 위임에만 `measuredBy` 를 붙이지 않는다.** 그 위임의 보유분이 공표 수치에서 읽히지
않는다는 것이 지목 참조한 편의 산출이므로, 측정 대응을 등록하면 관측층이 받을 소스 없음이 용어집에서
이미 해소된 것으로 읽힌다.

**자본의 계열 가운데 규제자본에 정제 관계를 두지 않는다.** 그 자본이 장부자본에서 공제와 가산을
거쳐 만들어져 포함 관계가 아니므로, 보통주 장부자본과 자기자본과 후순위 포함 장부자본이 이루는
사슬에 그것을 놓을 자리가 없다. **그 자리가 구멍으로 서 있고 이 페이즈가 그것을 해소하지 않는다.**

**담보물 분할은 정의만으로 완전하다.** 청구권이 아닌 담보물이 색인을 갖지 않는 것 전부를 받으므로
여집합의 귀결이다(V-7). 외부 자산은 그 칸의 진부분집합이며 다른 노드의 대차대조표에 대응물이 없는
말단만 든다. 자본청구권이 색인을 받지 못해 그 칸에 들어오는 것이 그 차이이고, 그것을 담을 정의가
없다는 것은 구멍으로 등재되어 있다.

**담보물 분할의 V-4 사례.** 2014년 산둥성 칭다오항과 펑라이항에 보관된 금속 약 40만 톤에 대해
창고증권이 여러 장 발행되어 서로 다른 은행의 대출 담보로 쓰였다(Reuters 2014년 6월 보도). 실물
가치 약 3억 8천만 달러에 조달액이 42억 달러였다. 여러 번 돌아간 것은 창고증권이고 은행이 잡았다고
믿은 것은 금속이므로, 둘이 다른 칸에 서는 것이 이 분할의 실물이다.

**담보 축 셋에는 `measuredBy` 를 붙이지 않는다.** 원천 담보와 재담보된 담보와 재담보 가능 담보가
현행 `SourceTag` 의 입도에서는 전부 규제 공시 하나로 모이고, 재무제표 안의 다른 줄이라는 것은 그
입도 아래다. 그 상태로 붙이면 G-2 에 걸린다. 측정 소스를 대응시키는 일은 관측 명세를 세우는
페이즈의 몫이며, 신호에 붙이지 않는다는 앞 문단과 같은 형이다.

**비율 둘을 분할로 두지 않고 정제와 배타로 둔다.** 비율이 둘뿐이라는 근거가 없으므로 완전성을
주장하지 않으며, V-7 이 분할의 완전성을 가정으로 두는 자리를 애초에 만들지 않는다. 그래서 V-4 가
요구하는 분할의 사례도 걸리지 않는다. 둘이 겹치지 않는 것은 색인이 다르기 때문이다. 앞은 떠받쳐야
할 것에 붙고 뒤는 떠받치는 것에 붙으며, 표준 개시증거금 일람이 익스포저 명목금액의 백분율로 서고
표준 헤어컷 일람이 담보 자산 시장가치의 백분율로 서는 것이 그 실물이다(BCBS · IOSCO 2020년 4월
부속서 A 와 부속서 B).

**비율 둘에도 `measuredBy` 를 붙이지 않는다.** 현행 `SourceTag` 의 입도에서 둘이 전부 규제 공시
하나로 모이므로 그 상태로 붙이면 G-2 에 걸린다. 담보 축 셋에 붙이지 않은 것과 같은 사유이며,
측정 소스를 대응시키는 일은 관측 명세를 세우는 페이즈의 몫이다.

**담보물 분할의 V-5 판정이 섰다.** 청구권인 담보물은 재무제표의 담보 주석에서 측정되고 청구권이
아닌 담보물은 그 주석에 들지 않는다. **그 주석이 드는 것이 「담보로 받은 금융상품의 공정가치」이기
때문이며**(Singh·Aitken 2010 상자 1 이 인용한 재무제표 문면), 상품 재고를 담보로 받은 것은 그
문면의 한정에서 빠진다. 측정 대응이 한쪽에만 있으므로 둘이 다르고, V-5 가 요구하는 판정의 재료가
이 자리에서 선다.

**상품 재고가 그 칸에 서지 않는다는 것은 저자의 주장이 아니라 그 문면의 한정에서 따라 나오는
판정이다.** 저자는 그 주석을 재담보 가능 담보의 측정 소스로 쓰면서 담보물의 종류를 가르지 않는다.
그러므로 이 판정의 근거는 인용된 문면이고 저자의 서술이 아니다.

**한쪽의 측정 대응이 없다는 것을 용어집이 적지 않는다.** V-2 의 네 관계에 「측정 대응 없음」이
없고, L-14 가 소스 없음의 등재를 관측층의 몫으로 둔다. 그래서 이 등재는 한쪽에만 서고 없는 쪽은
관측층의 공시 경로가 칸으로 든다.

**기각한 대체 정의:** 몫의 두 종류를 `partitions` 로 등록하는 안을 기각했다. 그 생성자가
완전성을 가정으로 두는데 실제 반례가 있기 때문이며, 소유권을 넘기는 구조로 금융한 재고가 장부에서
제거되어 보유와 제공 어느 칸에도 들지 않는다(Minko 2016 §2.4). `refines` 둘과 `excludes` 하나로
두면 둘이 상위 개념의 특수 사례이고 서로 겹치지 않는다는 것만 서며, 둘이 전부라는 것은 서지 않는다.
비율의 두 용법이 같은 형으로 등재된 선례가 위에 있다.

**분할의 완전성은 여집합의 귀결이다(V-7).** 화폐성의 분할에서 그 밖의 청구권이 앞의 둘에 들지
않는 것을 모두 받으므로 그렇다. 저자가 정의하는 등급은 둘이고 명시된 만기가 1년 이상인 청구권을 등급으로
세우지 않으므로, 셋째 칸은 그 나머지를 받는 자리다.

**화폐성 분할의 모든 쌍이 배타적이다.** 등급을 가르는 것이 명시된 만기이고 그것이 한 시점에 한
값이므로 세 쌍이 전부 배타적이며, 그 세 쌍을 아래가 등록한다. 경계가 스펙트럼이라는 저자의 단서는
화폐성이 정도를 갖는다는 것이고 그 정도는 가격 위험으로 재어지므로, 분할의 배타성이 아니라 분할과
실질의 대응이 거친 자리다. 그 정도를 담는 층은 구멍으로 등재되어 있다.

**화폐성 분할의 V-4 사례.** 저자가 정기예금을 해지 가능한 것과 양도 가능한 것으로 가르고 해지
가능한 것이 벌칙을 치르면 만기 전에 전환된다고 적는다(Pozsar 2014 각주 7 과 각주 14). 그 청구권의
명시된 만기는 만기 시 액면가를 약속하므로 화폐 유사 칸에 서는데 벌칙을 치르면 요구 시 전환이
서므로, 이 분할이 그 자리를 가르지 못한다. 같은 각주가 요구불예금과 정기예금을 개념적 골포스트라
부르고 실물의 예금 종류를 열거한다.

**액면가 약속의 강도를 분할로 두지 않고 정제와 배타로 둔다.** 네 범주가 전부라는 근거가 없으므로
완전성을 주장하지 않으며, V-7 이 분할의 완전성을 가정으로 두는 자리를 애초에 만들지 않는다. 그래서
V-4 가 요구하는 분할의 사례도 걸리지 않는다. 저자가 그 그림이 핵심 기관과 수단만 담고 무부보 예금
밖의 사적 어음은 담지 않는다고 적는 것이 그 근거다(Pozsar 2014 본문과 각주 15). 넷이 서로 겹치지
않는 것은 두 축의 값이 각각 한 값이기 때문이고, 그 축은 무엇이 떠받치는가와 공적 백스톱이 직접
받치는가 간접으로 받치는가 받치지 않는가다. 두 축을 개념으로 등재하지 않는 까닭은 네 범주의
완전성을 주장하지 않아 곱의 귀결을 세울 필요가 없고, 등재하면 V-4 가 분할마다 사례를 요구하는데 그
사례가 네 범주의 사례와 같은 자리에서 나와 입도가 양쪽에서 갈리기 때문이다. 비율의 두 용법이 같은
형으로 등재된 선례가 위에 있다.

**화폐성과 강도에 `measuredBy` 를 붙이지 않는다.** 현행 `SourceTag` 의 입도에서 둘이 전부 자금순환표
하나로 모이고 통화지표의 줄이라는 것은 그 입도 아래이므로, 그 상태로 붙이면 G-2 에 걸린다. 그리고
통화지표를 소스로 쓰면 위계가 그 지표의 정의에 매달리는 문제가 선행 추출에서 이미 제기되어 구멍으로
서 있다. 담보 축 셋과 비율 둘에 붙이지 않은 것과 같은 형이다.

**담보 제공의 법적 형태 분할의 모든 쌍이 배타적이다.** 쌍이 하나이고 그것을 아래가 등록한다. 한
제공에서 소유권이 넘어가는 것과 담보권만 서는 것이 함께 성립하지 않는다.

**분할의 완전성을 주장하지 않는다(V-7).** 담보 제공의 법적 형태에서 두 칸 밖의 형식이 법역마다
있을 수 있으며, 그 열거를 드는 관측층 선언의 docstring 이 같은 판정을 이미 든다.

**담보 제공의 법적 형태 분할의 V-4 사례.** 같은 기능을 영국법은 소유권 이전으로 뉴욕법은 담보권
설정으로 짜고 반환 대상이 등가물과 그 물건으로 갈리며 도산 시 처리도 일괄정산과 담보권 실행으로
갈린다(ISDA Credit Support Annex 두 양식). 그리고 2014년 산둥성 두 항구에서 소유권을 넘기는 구조로
한 재고 금융에서 재고가 장부에서 제거되어 담보 제공 공시가 비었다(Minko 2016 §2.4.1).

**법적 형태 둘의 측정 대응이 다르다.** 재무제표에서 담보로 제공된 자산의 장부금액을 드는 주석이
담보권만 담고 감독 규범의 자산 부담 공시가 둘 다 담으므로, 담보권 쪽에 두 소스가 붙고 소유권 이전
쪽에 한 소스가 붙는다. 그 칸의 정본은 담보로 제공한 자산의 공시 경로를 드는 관측층 선언이다.
V-5 가 요구하는 판정의 재료가 이 자리에서 선다.

**그 주체에게 화폐인 것을 청구권의 정제로 둔다.** 보유되는 것이 청구권이고 그것이 화폐인지 화폐
유사인지가 이 개념의 판별선이 아니므로 등급 쪽에 붙이지 않는다. 분할로 두지 않는 까닭은 청구권이
이 개념과 그 밖의 것으로 갈린다는 완전성을 주장할 근거가 없는 것이며, 비율 둘과 액면가 약속의
강도를 정제와 배타로 둔 것과 같은 형이다. 보유의 상대가 누구인지는 성질이어서 V-1 에 따라 정의층이
받는다.

**그 주체에게 화폐인 것에 `measuredBy` 를 붙이지 않는다.** 현행 `SourceTag` 의 입도에서 그것이
자금순환표와 규제 공시로 모이고 어느 줄인지가 그 입도 아래이므로, 그 상태로 붙이면 G-2 에 걸린다.
화폐성과 강도와 담보 축 셋과 비율 둘에 붙이지 않은 것과 같은 사유다.

**중앙은행을 개념으로 등재하지 않는다.** 그 주체에게 화폐인 것과 함께 등재하는 안을 기각했다.
위계 최상단을 시장이 팔고 있는 것을 사겠다고 약속할 수 있는 유일한 주체로 가른 결정이 그 기능을
드는데(J-4), 기능은 성질이어서 V-1 에 따라 용어집이 담지 못한다. 등재하면 성질 없는 개념이
서고, 이 아크가 세운 구조는 그 자리를 화폐자산을 보유하지 않는 것이라는 한 값으로만 담으므로 그
값은 개념의 성질이 아니라 구조의 한 칸이다. 그리고 자국통화 무제약의 한계를 드는 등재가 그
자리에 걸려 있고 그것이 이 아크에서 깨므로, 등재하면 발화와 등재가 갈린다.

**상환 실패를 개념으로 등재하고 관계를 하나도 붙이지 않는다.** V-2 의 관계 넷 가운데 정제도 배타도
서지 않는다. 정제로 두려면 상위 개념이 있어야 하는데 지급능력과 인출 충족이 둘 다 상태이고 상환
실패가 그 특수 사례가 아니며, 배타로 두면 상환 실패와 인출 충족이 함께 서지 못한다고 주장하게 되는데
그것이 거짓이다. 당장 내줄 수 있는 것이 요구를 넘는데도 내주지 않는 자리가 있다. 관계 없는 개념의
선례가 셋이며 의사결정 단위와 발동조건과 인출 충족이 그것이다.

**이 정의가 배제하는 사례:**
신용장에서 제시 서류가 조건과 불일치하여 개설은행이 지급을 거절한 것. 조건이 충족되지 않아 지급
의무가 발생하지 않았으므로 상환 실패가 아니며, 그 거절이 적법하고 은행이 불일치를 들어 거절할 수
있다는 것이 규범에 적혀 있다(UCP 600 제16조). 그리고 은행이 정기예금의 조기 인출을 위약금 없이
허용해 약정 만기 전에 내준 것도 배제한다. 계약이 요구하지 않은 것을 내준 것이므로 상환 실패가
아니며, 감독 규범이 그 허용을 범주 재분류의 조건으로 든다(바젤 III LCR 제83절). **둘이 같은 축의
양쪽을 들어 의무 없는 불지급과 의무 없는 지급을 각각 배제한다.**

**기각한 대체 정의:** 상환 실패에 측정 대응을 거는 안을 기각했다. 조정과 실패가 공표 수치에서 같은
모양으로 보이고 범주별 공시가 그 둘을 가르지 않으므로, 측정 대응을 걸면 소스 없음이 소스 있음으로
기록되어 L-14 가 드는 주요 산출물이 그 자리에서 뒤집힌다. 측정 소스의 대응은 관측층의 자리로
넘어간다.

**상환 실패를 분할하지 않는다.** V-5 가 측정 대응이 다르지 않은 둘을 가르지 못하게 하고, 실패의
세 경로가 같은 데이터로 측정되어 G-1 과 G-2 가 어긋난다는 구멍이 그 분기를 확인되지 않은 것으로
두므로, 분할하면 구멍을 확인된 분기로 승격시킨다.

**풋을 열 개념으로 등재하고 유동성 풋 쪽을 3 단으로 세운다.** 최상위와 집행 주체별 둘과 기능 넷이
그 3 단이며, 신용 풋 쪽은 최상위와 집행 주체별 둘만 둔다. 사적과 공적이 별도 축이 아니라 기능 축의
묶음인 까닭은 기능이 그 풋을 누가 집행하는지를 이미 정하는 데 있다. 두 축으로 두면 곱이 원문에 없는
칸을 허용한다.

**긴급 조달 접근을 별도 개념으로 등재하지 않는다.** 그것과 유동성 풋 사이의 관계가 수단 관계인데
V-2 의 네 관계로 표현되지 않으며, 원문이 유동성 풋에 그 위계의 이름을 직접 주므로 별도 축이 필요
하지 않다. 등재하면 관계 없는 개념이 하나 더 서고 그 관계의 결손이 구멍으로 올라간다.

**명시성 축을 유동성 풋에 세우지 않는다.** 신호의 분할이 조건이 문서에 있는가를 축으로 이미 쓰고
그 분할의 역사 사례가 계약상 크레딧 라인으로 제공한 풋과 암묵적 풋을 가른 것이어서, 그 축이 이미
유동성 풋 위에서 재어진다. 또 세우면 측정 대응이 같은 둘을 분할하는 것이 되며 색인도 다르다. 기능은
풋에 붙고 명시성은 그 풋의 발동조건에 붙는다.

**신용 풋의 수단을 등재하지 않는다.** 그 위계가 청구권의 수단 종류에 붙고 국채와 부보예금과 레포와
머니펀드와 무부보예금의 다섯 단계를 드는데, 그 색인이 주체에 붙는 유동성 풋의 위계와 달라 이 자리가
받을 것이 아니다.

**풋 둘을 액면가 약속의 강도에 잇지 않는다.** 그 강도가 공적 유동성 풋과 신용 풋의 받침 양태에
달린 함수인데 V-2 의 네 관계가 함수 관계를 표현하지 않으며, 정제로 두면 강도가 풋의 특수 사례라고
주장하게 되어 거짓이다. 그 결손은 구멍으로 등재되어 있다.

**최종성의 셋을 청구권의 정제로 두고 분할로 두지 않는다.** 원전이 핵심과 중간과 비핵심 셋을 두고
그 가름의 초점을 그 부채가 최종 국내 채권자에 대한 것인가에 두는데(Shin and Shin 2011 · E-51 §2),
그 열거의 완전성이 원전의 표에 의존하므로 분할로 두면 주장할 근거가 없는 완전성을 주장하게 된다.
액면가 약속의 강도가 네 범주를 두 축의 곱이 아니라 조합의 열거로 보아 정제로만 등록한 것과 풋의
열이 같은 길을 간 것이 그 선례다. **분할로 두지 않으므로 배타성 문단과 V-4 사례의 요구가 이
자리에 서지 않는다.**

**최종성의 셋에 배타를 등록하지 않는다.** 같은 수단이 보유자에 따라 세 열에 걸쳐 서므로 수단
단위로는 배타가 아니고 수단과 보유자의 곱 단위로는 배타인데, 이 목록이 그 곱을 색인으로 들지
않으므로 등록하면 어느 단위의 배타인지가 그 자리에서 서지 않는다. 원전의 표에서 정기예금과
양도성예금증서가 세 열에 다 서는 것이 그 자리다(Shin and Shin 2011 · E-51 §4). 유동성 풋과 신용
풋의 배타성을 한 수단이 둘 다일 수 있는지가 판정되지 않아 등록하지 않은 것이 같은 형의 선례다.

**소매 유출 동등을 청구권의 정제로 등재한다.** 감독 규범이 소기업 고객이 제공한 무담보 도매 조달을
소매예금과 똑같이 취급하면서 그 경계를 금액과 은행의 내부 분류로 정하므로(바젤 III LCR 제89절·
제90절), 측정 방법이 원전의 핵심과 달라 G-1 에 따라 다른 개념이고 G-2 가 막지 않는다. 이 개념은
금액 문턱을 받아 정의층에 서지 못하나 **이 목록은 개념의 존재와 관계만 담아 수를 쓰지 않으므로**
등재가 막히지 않는다.

**최종 채권자 청구권과 소매 유출 동등 사이의 관계를 등록하지 않는다.** 어느 쪽도 다른 쪽을 포함하지
않아 정제가 아니고, 자연인의 요구불예금이 양쪽에 다 들어 배타가 아니며, 한쪽이 다른 쪽의 부분들로
쪼개지지 않아 분할도 아니다. 측정 대응은 개념과 소스를 잇는 관계여서 개념 사이에 쓰이지 않는다.
**V-2 의 네 관계로 표현되지 않으므로 그 결손은 구멍으로 등재되어 있다.**

**최종성의 셋과 소매 유출 동등에 측정 대응을 붙이지 않는다.** 원전의 측정 경로가 통화지표와 예금
범주의 합인데 현행 소스 표지가 통화지표를 들지 않으며, 규범 쪽의 경로는 감독 보고여서 밖의 관측자가
닿지 못한다. 그 표지를 더하는 것은 측정 대응을 등록하는 경우에만 설 자리가 생기므로 두 자리가 같은
처분을 받는다. 긴급 조달의 등재가 측정 대응을 붙이지 않은 것이 그 선례다.

**장부 레버리지 조정 모드의 셋을 분할로 등록한다.** 완전성을 주장할 근거가 있는 유일한 자리이기
때문이다. 비율 둘과 액면가 약속의 강도와 최종성 셋이 완전성을 주장할 근거가 없어 정제와 배타로만
섰는데, 이 셋은 자산이 부채와 자기자본의 합이라는 항등식의 세 성분 가운데 하나를 고정하는 것이어서
열거가 그 항등식에서 닫힌다.

**분할의 완전성은 회계 항등식의 귀결이다(V-7).** 확인된 귀결 셋 가운데 첫째이며 이 목록에서 그
귀결을 쓰는 첫 자리다. 여집합의 귀결이 담보물과 화폐성의 두 분할에 서 있고 사건 대수의 귀결은
이 목록에 선 자리가 없다.

**그 귀결이 전제 아래서만 선다.** 세 성분 가운데 정확히 하나가 고정된다는 전제이며, 세 성분이
다 움직이는 조정과 세 성분이 다 고정되어 레버리지가 움직이지 않는 조정은 그 분할의 정의역 밖이다.
전제를 적지 않으면 이 열거가 레버리지가 움직이는 모든 자리를 다한다고 읽힌다. 그 두 자리가 형식층에
담기지 않는 것은 구멍으로 등재되어 있다.

**장부 레버리지 조정 모드 분할의 모든 쌍이 배타적이다.** 쌍 셋에 배타 관계를 등록하며, 배타성이
관측이 아니라 그 전제에서 따라 나온다. 두 성분이 함께 고정되면 셋째도 항등식으로 고정되어 레버리지가
움직이지 않으므로 그것이 조정이 아니고, 그래서 두 모드가 함께 서는 배치가 없다.

**장부 레버리지 조정 모드 분할의 V-4 사례.**
자산 고정은 2000년대 중반 미국 투자은행이 부채를 발행해 자사주를 매입한 자리이고, 부채 고정은 같은
시기 미국 가계가 부채를 고정한 채 주택가격의 변동으로 자기자본이 움직인 자리이며, 자기자본 고정은
증권 브로커딜러가 차입으로 자산을 넓힌 자리다. 셋이 같은 그림의 세 축으로 관측됐다
(Adrian and Shin 2013).
조달처: E-01 §2 「Mode 1 — 자산 고정 (부채발행으로 자사주 매입)」

**이 분할이 배제하는 사례:**
상업은행의 레버리지 고정. 레버리지 대 자산의 기울기가 영에 가까워 수직선으로 서고, 레버리지를
고정하는 것이므로 레버리지를 올리는 방식의 분할이 그것을 담을 자리가 없다. 그래서 그것이 분할의
결손이 아니라 분할의 정의역 밖이며, 같은 그림에서 가계와 비금융기업과 증권 브로커딜러가 세 모드에
대응하는 데 비해 상업은행만 대응물을 갖지 않는다(Adrian and Shin 2008).
조달처: E-02 §2-1 「상업은행의 수직선(레버리지 고정)은 E-01의 3모드 분류에 대응물이 없는 네 번째 행태다」

**조정 마진의 축을 이 목록에 세우지 않는다.** 자본 조정과 자산 조정과 부채 조정 가운데 무엇으로
레버리지를 맞추는가가 그 축인데, 한 성분이 고정되면 나머지 둘이 움직이므로 한 모드가 조정 마진 둘에
대응하고 대응이 일대일이 아니다. 그래서 같은 분할이 아니며 통합하면 한쪽의 입도가 사라진다. 그 축이
이 아크의 판별선이 아니므로 세우는 자리를 열어 둔다.

**자본의 두 뜻을 더하고 자기자본을 사슬의 중간 자리로 쓴다.** 자본의 뜻이 보통주와 주주자본과 후순위
포함 자본 셋으로 갈리고 앞의 것이 뒤의 것의 부분인데, **가운데 자리가 대차대조표의 잔여 항목이고
자기자본이 이미 그것으로 서술되어 있다.** 그래서 중첩을 정제 둘로 등록하며, 그 중첩이 분할이 아니므로
배타성 문단과 V-4 사례의 요구가 이 자리에 서지 않는다.

**이 정의가 배제하는 사례:**
후순위채와 적립성 증권이 발행된 시점과 자본 계열에 들어간 시점이 갈린 자리. 그 둘이 먼저 발행되어
있었고 연차보고서의 자본 계열에 들어간 시점만 늦었으므로, 어느 뜻으로 세는가가 발행이 아니라 계열에
넣는 선택으로 정해진다. 그래서 이 사슬은 금액의 포함 관계를 들고 그 선택이 언제 바뀌는지는 들지
않는다(Shin 2009).
조달처: E-50 §7 「보통주와, 보통주에 우선주를 더한 주주자본과, 거기에 후순위채를 더한 총자본이다」

**기각한 대체 정의:**
자본의 세 뜻을 모두 새 개념으로 더해 보통주와 주주자본과 후순위 포함 자본 셋을 세우고 자기자본과
나란히 두는 안. 가운데 자리인 주주자본이 대차대조표의 잔여 항목이고 자기자본의 서술이 바로 그것이므로
셋을 다 더하면 같은 데이터로 측정되는 둘이 갈라지며, G-2 가 같은 데이터로 측정되면 분할하지 말라고
하고 V-5 가 측정 대응이 다르지 않은 두 개념을 가르지 말라고 하여 양쪽에 걸린다. 자기자본을 중간
자리로 쓰면 더하는 것이 둘로 줄고 사슬이 그대로 선다.

**자본의 두 뜻에 측정 대응을 붙이고 모드에는 붙이지 않는다.** 두 뜻이 규제 공시의 다른 줄에서 읽히고
같은 표지를 받는 정제 쌍의 선례가 대차대조표와 자기자본에 이미 서 있으므로 G-2 가 걸리지 않으며,
측정 체제의 선택이 두 시점 사이의 변화 방향을 뒤집는 것을 재려면 사슬의 세 자리가 다 관측돼야 한다.
모드는 세 성분의 두 시점 차분이 이루는 조합이라 공시의 한 줄로 서지 않고 대차대조표와 자기자본에서
유도되므로 새 표지를 더할 자리가 없다. **그 주체에게 화폐인 것에 붙이지 않은 것과 축이 다르다.**
그쪽은 어느 줄인지가 표지의 입도 아래여서 붙이면 G-2 에 걸리는 것이고 이쪽은 입도가 아니라 유도가
사유다.

**주체에서 노드 상태로 가는 사상을 등재하지 않는다.** 그 사상이 의사결정 단위와 대차대조표를 잇는
함수인데 V-2 의 네 관계가 함수 관계를 표현하지 않으며, 풋 둘을 액면가 약속의 강도에 잇지 않은 자리가
같은 사유로 섰다. 셋째 개념으로 세우면 관계 없는 개념이 하나 늘고 그 관계의 결손이 구멍으로 올라가며,
D-7 의 판별 시험이 그 선언의 docstring 이 대응 비형식 개념을 들 수 있는가인데 그 사상이 드는 것은
개념이 아니라 이미 선 두 개념 사이의 대응이다.

**위계로 부채를 가르는 것도 등재하지 않는다.** 그 가름이 보유자가 의무자보다 위계에서 아래에 있는지로
부채 총계를 나누는데, 그것이 드는 비형식 개념이 비최종 채권자 청구권과 색인이 달라 G-1 로는 다른
개념이 된다. 그런데 그 둘의 관계가 구멍으로 서 있으므로 등재하면 구멍을 확인된 개념으로 승격시키며,
상환 실패를 분할하지 않은 것이 같은 형이다.

**이름에 어간의 한정어를 붙이고 어느 분기인지를 이름이 든다.** 레버리지와 자본이 둘 다 오염 어간이고
이 목록이 그 두 어간을 쓰는 첫 자리인데, 어간 목록이 자본의 분기를 다섯으로 가르고 레버리지의 분기를
넷으로 가르므로 한정어가 어간 단독 사용을 피하는 데 그치지 않고 어느 분기인지를 들어야 그 목록의
목적이 선다. 그래서 둘 다 장부 쪽임을 이름이 들며, D-5 가 식별자를 원문 저자 표기에서 가져오지
않게 하므로 후순위채를 포함한다는 것을 이름이 직접 들고 원전의 집계 이름을 쓰지 않는다.

**담보 여력과 부채수용력을 등재하고 관계 없이 둔다.** 둘이 초석 명제가 전파의 매개로 든 것이고 이
아크의 산출이 그 둘 위에 서므로 등재하며, 집계 연산에 이름을 붙인 총계와 달리 둘이 비형식 담론에서
이름을 갖는다. 신용공급이 이 목록에 서 있고 부채 총계가 서 있지 않은 것이 그 가름의 선례다. 관계 없이
두는 사유가 둘이다. V-2 의 네 관계가 그 둘을 표현하지 않으며 여력이 어느 개념의 정제도 아니고 두
개념의 차이로 서는 값이어서 관계로 담기지 않고, 측정 대응을 붙이면 유도되는 것이 직접 재어지는 것처럼
읽혀 조정 모드에 붙이지 않은 사유와 같은 자리에 선다.

**자산 감소 까닭 분할의 완전성은 여집합의 귀결이다(V-7).** 자산이 줄었다는 조건 아래에서 부채가 함께
줄었는가의 참과 거짓이 두 부분을 빠짐없이 겹치지 않게 가르므로, 둘째가 첫째의 여집합이고 그 완전성이
정의만으로 따라 나온다. 조정 모드 분할이 회계 항등식의 귀결을 쓴 것과 달리 이 분할은 여집합의 귀결을
쓰며 그 꼴이 형식층의 여러 파일에 이미 서 있다.

**자산 감소 까닭 분할의 모든 쌍이 배타적이다.** 부분이 둘이므로 쌍이 하나이고 그 하나를 등록했다.
**그 배타가 관측이 아니라 여집합에서 따라 나오며 그 분할의 정의역이 자산이 줄어든 배치다.** 정의역을
적지 않으면 그 열거가 대차대조표가 움직이는 모든 자리를 다한다고 읽히는데, 자산 총액이 불변인 채 자산의
구성만 바뀌는 조정이 그 정의역 밖이고 그 자리를 담는 구조가 형식층에 없어 구멍으로 등재되어 있다.

**자산 감소 까닭 분할의 V-4 사례.** 2007년 도매조달 은행의 런에서 만기가 온 대출과 예금이 갱신되지
않아 연간 순유출이 났고 그것이 부채와 자산을 함께 줄인 자리다(Shin 2009). 그와 달리 롤오버 게임의
손상 함수가 인출량을 받아 대차대조표에 입히는 비용을 내고 그 미분이 자산 단위를 팔 때의 가격 할인이
되는 자리는 자산만 줄어드는 쪽이다(Morris · Shin 2016). **그 둘이 같은 인출 사건에서 갈린다.**
조달처: E-50 §4 「만기가 온 대출과 예금이 갱신되지 않아 연간 순유출이 났다」
조달처: E-17 §2-5 「번째 자산 단위를 팔 때의 가격 할인」

**금액 쪽 물림 판정을 등재하지 않는다.** 그 판정이 드는 것이 제약이 물렸는가이고 제약이 이미 개념으로
서서 부채 측 한도와 자산 측 적격성 둘로 분할되어 등록되어 있으므로, 물림을 셋째 부분으로 더하면 그 분할
등록이 거짓이 되고 셋째 개념으로 더하면 제약의 성질이 개념으로 승격한다. 몫 쪽 물림 판정을 세우면서
같은 자리를 등재하지 않은 것이 그 선례이며, 그 판정의 docstring 이 드는 대응 비형식 개념이 제약이 상시
등식이 아니라 물렸을 때만 드러나는 부등식이라는 것이어서 이미 선 제약 개념의 성질을 드는 것이고 새
개념이 아니다.

**시계 불일치에 측정 대응을 붙이지 않는다.** 그 개념이 결정 시계와 자산 만기를 함께 재야 서는
관계여서 한 소스로 서지 않으며, 결정 시계의 소스가 임원 보상 주기와 재임 기간이고 자산 만기의
소스가 만기 구조의 보고여서 둘이 다른 공시에 산다. 기준 초과 위임에만 측정 대응을 붙이지 않은
것이 같은 꼴이며, 그 자리와 달리 여기서는 두 소스가 각각 있고 그 둘을 한 주체에 대해 맞대는 공시가
없다는 것이 사유다. 결정 시계에 규제 공시를 붙이는 사유는 그 측정 소스로 임원 보상 주기와 재임
기간을 드는 기록이 있고 그 항목이 규제 공시에 선다는 것이다.

**자산 분할 체제 분할의 모든 쌍이 배타적이다.** 네 체제가 자산을 가르는 서로 다른 축이고 한 축이 다른 축의
정제가 아니므로 여섯 쌍 전부에 배타 관계를 등록한다. 한 자산이 네 축에서 각각 범주를 받는 것은
한 체제가 두 체제를 겸하는 것이 아니라 축이 넷이라는 뜻이며, 그 넷을 좌표의 네 칸이 함께 든다.

**자산 분할 체제 분할의 V-4 사례.** 2026년 11월에 하루 뒤 만기인 양도성예금증서가 유동성 규제의 축에서
금융기관 발행 채무로 세 단 전부에서 배제되어 비적격이면서, 머니마켓펀드 규범의 축에서는 일간 만기
자산이어서 하한을 채우는 칸에 들고 공개 투자 명세의 축에서는 자기 범주를 가진다(바젤 기준 2013년
유동성 규제 · 유럽연합 2017년 규정 · 미국 증권거래위원회 규칙). 한 축에서 가장 낮은 칸에 있는
것이 다른 축에서 가장 높은 칸에 있으므로 한 축을 잘게 쪼개어 다른 축을 유도할 수 없다.

**네 체제에 `measuredBy` 를 붙이지 않는다.** 그 축들을 보는 공시 경로가 여섯이고 그 가운데 닫힌
열거와 범주마다의 금액을 일반 관측자에게 내는 것이 하나뿐이므로, 측정 대응을 등록하면 관측층이 받을
소스 없음이 용어집에서 이미 해소된 것으로 읽힌다. 기준 초과 위임에만 그것을 붙이지 않은 것과 같은
꼴이다.

**자본 조정 체제에 관계를 두지 않는다.** 그 개념이 규제자본과 경제적 자본 둘을 사상으로 잇는데
관계가 정제와 배타와 분할과 측정 대응 넷으로 제한되고 그 넷에 사상으로 이어진다는 관계가 없으므로,
어느 관계로도 그 잇는 것을 표현할 수 없다. 규제자본을 자본 계열의 중첩 사슬에 놓지 않은 것이 공제와
가산을 거쳐 포함 관계가 아니라는 사유였고, 그 사슬에 놓지 않고 두 자본을 잇는 길이 형식층의 사상으로
섰으므로 그 사상의 틀이 용어집의 관계가 아니라 정의층과 회계층의 선언이 든다. **관계를 다섯째로
늘리는 길은 쓰지 않는다.** 화폐성 스펙트럼을 받는 다섯째 관계가 필요한가가 이미 미결로 서 있어 그
자리에서 함께 판정되어야 하며, 이 회차가 그것을 당겨 세우면 그 미결이 한 축만 보고 닫힌다.

**자본 조정 체제에 `measuredBy` 를 붙이지 않는다.** 그 체제를 보는 공시 경로가 셋이고 그 전량이
항목별 금액도 체제의 선택도 두 자본 사이의 대조도 내지 못하므로, 측정 대응을 등록하면 관측층이 받을
소스 없음이 용어집에서 이미 해소된 것으로 읽힌다. 네 체제에 그것을 붙이지 않은 것과 같은 꼴이다.

**통화 불일치 둘을 분할로 두지 않고 정제로만 둔다.** 분할로 두면 완전성을 주장하게 되는데 그 둘이
배타적이지 않아 한 주체가 둘을 함께 가질 수 있고 셋째 종류가 없다는 증거도 서지 않는다. 통화의
역할 다섯이 정제로만 등록되고 열거가 닫혔는지를 주장하지 않은 것이 그 선례이며, 비율 둘과 액면가
약속의 강도와 최종성 셋이 같은 길을 갔다. **분할로 두지 않으므로 배타성 문단과 V-4 사례의 요구가
이 자리에 서지 않는다.**

**통화 불일치 둘에 배타를 등록하지 않는다.** 둘이 함께 서는 배치가 실재하며, 순노출이 어느 통화
축에서도 균형인 주체가 그 부채로 다른 통화의 자산을 조달한 자리가 그것이다. 정의층의 존재 정리가
그 배치를 증거로 든다. 배타로 두면 그 정리가 거짓을 주장하는 것이 된다.

**통화 불일치 셋에 측정 대응을 붙이지 않는다.** 현행 소스 표지 가운데 통화 구성을 내는 것이 하나도
없고, 더하면 그 표지가 관측 채널의 칸이 드는 것을 함께 들어 전사가 된다. 그리고 이 아크가 결손을
축과 입도와 관측자의 조합에 걸었으므로 표지 하나로는 그 조합을 담을 수 없고 채널의 칸이 유일한
자리다. 담보 축 셋과 비율 둘과 화폐성과 강도에 붙이지 않은 것과 같은 형이며, 분할의 근거가 측정
방법의 다름인데 그 다름을 이 목록이 들지 않는 것은 어긋남이 아니다. 그 다름은 분할의 조건이고 측정
대응은 등록이어서 둘이 다른 사실이다.
-/
-- DD:CF-58
def registry : List ConceptRel :=
  [ .partitions .constraint [.constraintLiabilityCap, .constraintAssetEligibility]
  , .excludes .constraintLiabilityCap .constraintAssetEligibility
  , .refines .equity .balanceSheet
  , .measuredBy .equity .regulatoryFiling
  , .measuredBy .balanceSheet .regulatoryFiling
  , .measuredBy .creditSupply .flowOfFunds
  , .partitions .signal [.verifiableSignal, .exogenousSignal]
  , .excludes .verifiableSignal .exogenousSignal
  , .partitions .tradePaymentMethod
      [.cashInAdvance, .letterOfCredit, .documentaryCollection, .openAccount, .otherPaymentTerms]
  , .measuredBy .cashInAdvance .customsDeclaration
  , .measuredBy .cashInAdvance .enterpriseSurvey
  , .measuredBy .letterOfCredit .customsDeclaration
  , .measuredBy .letterOfCredit .swiftMessage
  , .measuredBy .letterOfCredit .bankSupervisoryReport
  , .measuredBy .letterOfCredit .fxSettlementStatistics
  , .measuredBy .documentaryCollection .swiftMessage
  , .measuredBy .documentaryCollection .fxSettlementStatistics
  , .measuredBy .openAccount .customsDeclaration
  , .measuredBy .otherPaymentTerms .customsDeclaration
  , .measuredBy .otherPaymentTerms .fxSettlementStatistics
  , .refines .returnClaim .claim
  , .partitions .pledgeableAsset [.claimPledgeable, .nonClaimPledgeable]
  , .excludes .claimPledgeable .nonClaimPledgeable
  , .measuredBy .claimPledgeable .pledgeNote
  , .refines .externalAsset .nonClaimPledgeable
  , .refines .rehypothecation .pledge
  , .refines .sourceCollateral .pledge
  , .refines .rehypothecatedCollateral .pledge
  , .refines .rehypothecatableCollateral .pledge
  , .excludes .rehypothecatedCollateral .rehypothecatableCollateral
  , .refines .exposureMargin .pledgeRate
  , .refines .valuationRate .pledgeRate
  , .excludes .exposureMargin .valuationRate
  , .refines .equityClaim .claim
  , .measuredBy .equityClaim .regulatoryFiling
  , .refines .heldAssetShare .externalAssetShare
  , .refines .pledgedAssetShare .externalAssetShare
  , .excludes .heldAssetShare .pledgedAssetShare
  , .measuredBy .heldAssetShare .exchangeWarehouseReport
  , .measuredBy .pledgedAssetShare .encumberedAssetNote
  , .partitions .moneyness [.money, .moneyLike, .nonMoney]
  , .excludes .money .moneyLike
  , .excludes .money .nonMoney
  , .excludes .moneyLike .nonMoney
  , .refines .publicMoney .parPromiseStrength
  , .refines .insuredMoney .parPromiseStrength
  , .refines .publicShadowMoney .parPromiseStrength
  , .refines .privateShadowMoney .parPromiseStrength
  , .excludes .publicMoney .insuredMoney
  , .excludes .publicMoney .publicShadowMoney
  , .excludes .publicMoney .privateShadowMoney
  , .excludes .insuredMoney .publicShadowMoney
  , .excludes .insuredMoney .privateShadowMoney
  , .excludes .publicShadowMoney .privateShadowMoney
  , .partitions .pledge [.securityInterestPledge, .titleTransferPledge]
  , .excludes .securityInterestPledge .titleTransferPledge
  , .measuredBy .securityInterestPledge .encumberedAssetNote
  , .measuredBy .securityInterestPledge .assetEncumbranceDisclosure
  , .measuredBy .titleTransferPledge .assetEncumbranceDisclosure
  , .refines .nodeMoneyAsset .claim
  , .measuredBy .solvency .regulatoryFiling
  , .refines .privateLiquidityPut .liquidityPut
  , .refines .publicLiquidityPut .liquidityPut
  , .refines .fundingLiquidityAccess .privateLiquidityPut
  , .refines .marketLiquidityAccess .privateLiquidityPut
  , .refines .lastResortLendingAccess .publicLiquidityPut
  , .refines .currencyBackstopAccess .publicLiquidityPut
  , .refines .privateCreditPut .creditPut
  , .refines .publicCreditPut .creditPut
  , .refines .ultimateCreditorClaim .claim
  , .refines .undeterminedUltimacyClaim .claim
  , .refines .nonUltimateCreditorClaim .claim
  , .refines .retailOutflowEquivalentClaim .claim
  , .partitions .bookLeverageAdjustmentMode
      [.assetFixedAdjustment, .liabilityFixedAdjustment, .equityFixedAdjustment]
  , .excludes .assetFixedAdjustment .liabilityFixedAdjustment
  , .excludes .assetFixedAdjustment .equityFixedAdjustment
  , .excludes .liabilityFixedAdjustment .equityFixedAdjustment
  , .refines .commonShareBookCapital .equity
  , .refines .equity .subordinatedInclusiveBookCapital
  , .measuredBy .commonShareBookCapital .regulatoryFiling
  , .measuredBy .subordinatedInclusiveBookCapital .regulatoryFiling
  , .partitions .assetReductionCause [.repaymentExtinction, .assetSaleReduction]
  , .excludes .repaymentExtinction .assetSaleReduction
  , .partitions .holderMandate
      [.liabilityMatchingMandate, .benchmarkBeatingMandate, .lossAvoidanceMandate]
  , .excludes .liabilityMatchingMandate .benchmarkBeatingMandate
  , .excludes .liabilityMatchingMandate .lossAvoidanceMandate
  , .excludes .benchmarkBeatingMandate .lossAvoidanceMandate
  , .measuredBy .liabilityMatchingMandate .regulatoryFiling
  , .measuredBy .lossAvoidanceMandate .regulatoryFiling
  , .refines .economicCapital .equity
  , .measuredBy .regulatoryCapital .regulatoryFiling
  , .measuredBy .riskWeightedAsset .regulatoryFiling
  , .excludes .solvencyConstraintAxis .liquidityConstraintAxis
  , .measuredBy .decisionHorizon .regulatoryFiling
  , .partitions .assetPartitionRegime
      [.liquidityTierRegime, .maturityBucketRegime, .instrumentClassRegime,
       .encumbranceStateRegime]
  , .excludes .liquidityTierRegime .maturityBucketRegime
  , .excludes .liquidityTierRegime .instrumentClassRegime
  , .excludes .liquidityTierRegime .encumbranceStateRegime
  , .excludes .maturityBucketRegime .instrumentClassRegime
  , .excludes .maturityBucketRegime .encumbranceStateRegime
  , .excludes .instrumentClassRegime .encumbranceStateRegime
  , .refines .marketFundingAccess .privateLiquidityPut
  , .refines .centralBankCollateralEligibility .constraintAssetEligibility
  , .refines .fundingCurrency .currency
  , .refines .officialReserveCurrency .currency
  , .refines .tradeInvoicingCurrency .currency
  , .refines .internationalCurrency .currency
  , .refines .domesticCurrency .currency
  , .refines .currencyPositionMismatch .currencyMismatch
  , .refines .currencyFundingLinkMismatch .currencyMismatch
  , .refines .centralBankSwapLine .centralBankLiquidityLine
  , .refines .centralBankRepoLine .centralBankLiquidityLine
  , .excludes .centralBankSwapLine .centralBankRepoLine
  ]

end CrisisFramework.Glossary
