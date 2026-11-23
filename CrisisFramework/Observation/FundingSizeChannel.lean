/-
관측층 — 조달형 통화 불일치 크기의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(무차원), L-9(import 방향은
      단방향), A-3(witness 의무), A-8(논리 결합마다 홀로 값을 가르는 자리의 증거),
      C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      D-4(한 정의에 한 개념), D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류),
      T-6(존재 형태).

**이 파일이 세우는 것은 회계층의 조달형 불일치 크기가 어느 공시에서 읽히는가의 명세다.** 그 크기가
부채 통화로 진 부채의 잔액과 자산 통화로 보유한 자산의 잔액의 쌍으로 서므로, 그 쌍이 관측되려면 두
성분이 둘 다 읽혀야 한다.

**기재 방식이 그 값의 뜻을 가른다.** 같은 장부를 순액으로 기재하면 외견상 불일치가 서고 총액으로
기재하면 그것이 사라지므로, 어느 방식을 읽는 경로인지를 칸으로 두지 않으면 같은 수를 내는 두 경로가
다른 것을 재고 있는 자리가 명세에서 사라진다.

**순노출형과의 독립이 그 칸에서 유도된다.** 순포지션을 읽는 경로가 순액 표시를 문면으로 드는가를
이미 칸으로 들므로, 이 파일의 경로가 순액 기재를 읽으면 두 축의 측정 대응이 독립이 아니다.

**값을 담지 않는다.** 금액도 잔액도 이 파일에 서지 않고 그것을 내는 경로가 있는가만 선다.

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
그 경로가 읽는 기재 방식.

**대응 비형식 개념:** 한 공시가 통화를 건너는 조달을 순액으로 적는가 총액으로 적는가. 같은 거래가
두 방식에서 다른 꼴로 서므로 그 방식이 경로가 내는 값의 뜻을 가른다.

**이 정의가 배제하는 사례:**
기재 방식을 묻지 않고 수만 받는 읽기. 지목 참조로 연 편이 자산을 외화로 들고 자기자본을 자국통화로
든 장부에서 순액 기재가 외견상 통화 불일치를 내고 총액 기재는 선물의 외화 부채가 그 자산을 상쇄해
그 불일치를 지운다고 적으므로, 방식을 묻지 않으면 불일치가 있다는 값과 없다는 값이 같은 장부에서
함께 서는 것이 모순으로 읽힌다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-2 「총액으로 기재하면 선물의 외화 부채가 그 외화 자산을 상쇄하므로」

**기각한 대체 정의:**
방식을 참거짓 한 칸으로 두어 총액인가만 묻는 안. 칸이 짧아지나 그 편이 임시 조사를 셋째 소스로
들면서 그 입도가 조사마다 다르다고 적어 방식이 서지 않는 경로가 실재하므로, 참거짓으로 두면 방식이
알려지지 않은 경로가 순액으로 접힌다. 방식을 경로가 아니라 축마다 두는 안도 기각했다. 그 편이 방식을
기재 관례에 붙이고 축에 붙이지 않으므로 그 세분이 공시에서 유도되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-4515
inductive MeasurementBasis where
  /-- 순액으로 기재한다. 상쇄된 뒤의 결과만 장부에 선다. -/
  | netBasis
  /-- 총액으로 기재한다. 상쇄되기 전의 양변이 장부에 선다. -/
  | grossBasis
  /-- 그 방식이 공시에서 읽히지 않는다. -/
  | basisUnstated
  deriving DecidableEq, Repr

/--
조달형 통화 불일치 크기의 공시 경로.

**대응 비형식 개념:** 한 공시가 그 크기의 재료를 내는가. 부채 성분과 자산 성분이 재료이고 경로마다
내는 것이 다르며, 그 값이 선 기재 방식과 성질이 함께 걸린다.

**이 정의가 배제하는 사례:**
불일치를 읽는 경로가 그 크기도 낸다고 보는 읽기. 그 편이 대차대조표가 드는 것은 스왑과 선물의 연쇄가
낸 최종 결과이고 그것이 외견상 불일치로 나타난다고 적으면서 둘째 소스가 그 외견상 불일치를 거꾸로
읽어 스왑의 금액을 유추한다고 적으므로, 불일치의 존재를 읽는 것과 그 크기를 내는 것이 다른 조작이다
(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-4 「그 값이 총 부채 포지션을 과소추정한다」

**기각한 대체 정의:**
통화 불일치의 축을 드는 기존 구조체에 칸을 더하는 안. 선언이 줄고 축이 한자리에 모이나 그 구조체가
어느 부채가 어느 통화의 자산을 조달했는지를 읽는가를 묻고 이 구조체가 그 크기를 내는가를 물어 두
비형식 개념이 갈리므로, 한 정의가 둘 이상의 개념에 대응하면 분할하라는 요구가 걸린다. 두 성분을 한
칸으로 접는 안도 기각했다. 회계층이 그 크기를 두 통화의 잔액 쌍으로 내고 그 둘을 더하거나 빼지
않으므로, 접으면 한 성분만 내는 경로가 그 쌍을 내는 것으로 세어진다.

**값을 담지 않는다.**
-/
-- DD:CF-4515
structure FundingSizeChannel (Party : Type) where
  /-- 그 당사자를 이 경로가 보는가. -/
  coversParty : Party → Bool
  /-- 부채 통화로 진 부채의 잔액을 이 경로가 내는가. -/
  readsDebtLeg : Bool
  /-- 자산 통화로 보유한 자산의 잔액을 이 경로가 내는가. -/
  readsAssetLeg : Bool
  /-- 이 경로가 읽는 기재 방식. -/
  basis : MeasurementBasis
  /-- 이 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance
  /-- 투기와 헤지의 쓰임을 이 경로가 가르는가. -/
  separatesHedgeUse : Bool
  /-- 이 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient

/-- witness (A-3). **무엇을 증거하는가.** `FundingSizeChannel` 이 비어 있지 않다. 어느 당사자도
보지 않고 두 성분을 하나도 내지 않으며 기재 방식이 읽히지 않는 경로 하나를 든다. -/
-- DD:CF-4515
def FundingSizeChannel.noSource {Party : Type} : FundingSizeChannel Party where
  coversParty := fun _ => false
  readsDebtLeg := false
  readsAssetLeg := false
  basis := MeasurementBasis.basisUnstated
  provenance := MeasurementProvenance.officialReport
  separatesHedgeUse := false
  recipient := DisclosureRecipient.publicReader

/--
그 경로가 그 크기를 답하는가.

**대응 비형식 개념:** 한 경로가 그 쌍을 내려면 두 성분을 둘 다 내야 한다. 한쪽만 내는 경로는 그 쌍을
답하지 않는다.

**이 정의가 배제하는 사례:**
한 성분만 내는 경로를 답하는 것으로 세는 읽기. 그 편이 첫째 소스가 보고하는 딜러 은행의 명목 금액을
수단과 거래상대와 통화와 만기로 가른다고 적으면서 그 잔액에서 총액을 내는 길이 방향 가정과 비거주자
비중 추정을 지난다고 적으므로, 한 변의 잔액이 있다는 것과 그 쌍이 선다는 것이 다르다
(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-5 「각 단계가 가정이고 그 가정이 값을 바꾼다」

**기각한 대체 정의:**
논리합으로 두어 한 성분만 내도 답하는 것으로 보는 안. 답하는 경로가 늘어나나 그 쌍이 두 통화의
잔액이고 한쪽이 비면 그 크기가 서지 않으므로, 논리합으로 두면 비어 있는 쪽이 영으로 접혀 불일치가
없는 것과 구별되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-4515
def FundingSizeChannel.answersSize {Party : Type} (c : FundingSizeChannel Party) : Bool :=
  c.readsDebtLeg && c.readsAssetLeg

/--
딜러가 보고하는 파생상품 잔액 통계.

**대응 비형식 개념:** 보고하는 딜러 은행의 명목 금액을 수단과 거래상대와 통화와 만기로 가르는 집계.
그 잔액이 총액으로 서나 당사자별 자산 잔액을 내지 않는다.

**이 정의가 배제하는 사례:**
이 경로가 그 쌍을 낸다고 보는 읽기. 그 편이 그 잔액에서 총액을 내는 길이 고객을 비은행의 대리로 두는
가정과 방향 가정과 비거주자 비중 추정을 지난다고 적으므로, 이 경로가 내는 것은 한 변의 명목 잔액이지
두 성분의 쌍이 아니다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-5 「파생상품 통계에서 고객에 대한 그 통화 표시 선물과 스왑의 잔액을 받는다」

**기각한 대체 정의:**
딜러가 보고하는 파생상품 잔액 통계를 경로로 두지 않는 안. 첫째 소스가 실재한다는 사실이
사라지고, 그 쌍이 서지 않는 것이 소스의 부재인지 재료의 결손인지가 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-4515
def derivativeStatisticsChannel : FundingSizeChannel Unit where
  coversParty := fun _ => true
  readsDebtLeg := true
  readsAssetLeg := false
  basis := MeasurementBasis.grossBasis
  provenance := MeasurementProvenance.officialReport
  separatesHedgeUse := false
  recipient := DisclosureRecipient.publicReader

/--
외견상 불일치를 거꾸로 읽어 유추하는 집계.

**대응 비형식 개념:** 대차대조표에 보이는 외견상 통화 불일치에서 스왑과 선물의 금액을 유추하는 경로.
순 외화 포지션이 영이라는 가정에 기대며 그 값이 순액이다.

**이 정의가 배제하는 사례:**
이 경로가 내는 값을 총액으로 읽는 자리. 그 편이 그 유추가 순 포지션을 스왑의 순 사용으로 두므로 그
값이 총 부채 포지션을 과소추정한다고 적고 그 과소추정이 딜러 은행에서 특히 크다고 적으므로, 이
경로의 값을 총액으로 읽으면 그 부채가 사라진다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-4 「그 값이 총 부채 포지션을 과소추정한다」

**기각한 대체 정의:**
외견상 불일치를 거꾸로 읽어 유추하는 집계의 기재 방식을 총액으로 두는 안. 보고 모집단이 첫째 소스보다
넓으므로 그 값이 더 넓은 집계로 읽히나, 그 편이 그 유추가 외견상 불일치에서 온다고 적어 그 값이
순액에서 유도됨을 밝히므로 총액으로 두면 그 유도가 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-4515
def inferredFromApparentMismatchChannel : FundingSizeChannel Unit where
  coversParty := fun _ => true
  readsDebtLeg := true
  readsAssetLeg := true
  basis := MeasurementBasis.netBasis
  provenance := MeasurementProvenance.staffEstimate
  separatesHedgeUse := false
  recipient := DisclosureRecipient.publicReader

/--
대외 포지션의 통화 구성을 내는 계열.

**대응 비형식 개념:** 당국 설문으로 받은 실측과 합성 가중치로 메운 값이 한 계열에 이어 붙은 자료.
통화별 잔액을 내되 그 칸의 일부가 추정이다.

**이 정의가 배제하는 사례:**
이 계열의 한 칸을 전부 실측으로 읽는 자리. 지목 참조로 연 편의 기록이 저자들이 당국 설문으로 받은
실측을 쓰고 없는 자리는 합성 가중치로 메운 뒤 그 둘을 이어 붙인다고 적고 그 합성에 편향이 있으며
방향이 알려져 있다고 적으므로, 전부 실측으로 읽으면 그 편향이 명세에서 사라진다
(Bénétrix·Gautam·Juvenal·Schmitz 2019).
조달처: E-41 §2-2 「없는 자리는 합성 가중치로 메운 뒤 그 둘을 이어 붙인다」

**기각한 대체 정의:**
대외 포지션의 통화 구성을 내는 계열의 성질을 추정으로 두는 안. 합성으로 메운 몫이 있다는
사실은 서나 당국이 보고한 실측도 같은 계열에 들어 있으므로, 추정으로 두면 그 실측이 사라지고 그
계열과 유추로만 선 계열이 같은 칸에 든다.

**값을 담지 않는다.**
-/
-- DD:CF-4515
def externalPositionCurrencyCompositionChannel : FundingSizeChannel Unit where
  coversParty := fun _ => true
  readsDebtLeg := true
  readsAssetLeg := true
  basis := MeasurementBasis.basisUnstated
  provenance := MeasurementProvenance.mixedSeries
  separatesHedgeUse := false
  recipient := DisclosureRecipient.publicReader

/--
그 크기를 내는 것으로 후보가 되는 경로 전량.

**대응 비형식 개념:** 이 뭉치가 조달한 문면에서 그 크기의 재료를 낼 수 있는 경로의 목록. 목록에
들었다는 것과 그 쌍을 답한다는 것이 다르다.

**이 정의가 배제하는 사례:**
이 목록이 전수라고 보는 읽기. 그 편이 보고 범위가 닫히지 않고 여러 나라에 본점을 둔 은행의 달러
장부가 부분적으로만 보이며 보고하지 않는 은행 체계의 포지션은 아예 잡히지 않는다고 적으므로, 이
목록이 드는 것은 이 뭉치가 조달한 경로이지 세상의 경로 전량이 아니다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-4 「그 값이 총 부채 포지션을 과소추정한다」

**기각한 대체 정의:**
소스 없음 witness 를 후보 경로의 목록에 넣는 안. 목록이 비지 않음을 그 자리에서 보이나 그
witness 가 어느 축도 내지 않는 경로여서 관측 결과를 바꾸지 않고, 넣으면 실재하는 경로와 증거용
경로가 같은 목록에 섞인다.

**값을 담지 않는다.**
-/
-- DD:CF-4515
def fundingSizeChannels : List (FundingSizeChannel Unit) :=
  [derivativeStatisticsChannel,
   inferredFromApparentMismatchChannel,
   externalPositionCurrencyCompositionChannel]

/--
그 경로가 그 크기를 총액으로 답하는가.

**대응 비형식 개념:** 회계층의 그 크기가 총액 기준으로 서므로 그 쌍을 내는 경로가 총액 기재를 읽어야
그 크기를 답한다. 두 성분을 내되 순액으로 읽는 경로는 다른 것을 재고 있다.

**이 정의가 배제하는 사례:**
두 성분을 내는 경로를 전부 답하는 것으로 세는 읽기. 그 편이 같은 장부를 순액으로 기재하면 외견상
통화 불일치가 서고 총액으로 기재하면 그것이 사라진다고 적으므로, 방식을 묻지 않으면 불일치를 지우는
기재와 드러내는 기재가 같은 답으로 세어진다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-2 「자산을 외화로 들고 자기자본을 자국통화로 든 장부를」

**기각한 대체 정의:**
방식이 읽히지 않는 경로를 총액으로 보아 답하게 하는 안. 답하는 경로가 늘어나나 그 편이 임시 조사의
입도가 조사마다 다르다고 적어 방식이 서지 않는 자리가 실재하므로, 총액으로 접으면 재어지지 않은
것이 재어진 것으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-4515
def FundingSizeChannel.answersGrossSize {Party : Type} (c : FundingSizeChannel Party) : Bool :=
  c.answersSize && (c.basis == MeasurementBasis.grossBasis)

/--
그 크기가 관측되는가.

**대응 비형식 개념:** 경로 목록에서 그 크기를 총액으로 답하는 경로를 찾으면 값이 서고, 찾지 못하면
측정 소스가 없다는 까닭으로 판정 불가가 선다.

**이 정의가 배제하는 사례:**
한 경로가 한 성분을 내면 그 크기가 관측된다고 보는 읽기. 그 편이 복원의 소스를 셋으로 들면서 그
가운데 어느 것도 총액을 바로 내지 않고 가정의 사슬을 지나야 한다고 적으므로, 성분의 존재를 크기의
관측으로 세면 그 사슬이 사라진다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-3 「그 유추가 순 외화 포지션이 영이라는 가정에 기대며」

**기각한 대체 정의:**
판정 불가의 까닭을 귀속이 유일하지 않다로 두는 안. 대체 가능한 수단이 어느 자금이 어느 자산을
조달했는지의 사슬을 끊는다는 까닭이 이 자리에도 걸리나, 이 파일이 묻는 것은 그 쌍을 총액으로 내는
경로의 존재이고 그 경로가 아예 없으므로 측정 소스의 부재가 그 까닭이다.

**값을 담지 않는다.**
-/
-- DD:CF-4515
def fundingSizeObserved {Party : Type} (chs : List (FundingSizeChannel Party)) : ObservedTruth :=
  if chs.any (fun c => c.answersGrossSize) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
그 경로가 순액 표시에 묶이는가.

**대응 비형식 개념:** 순포지션을 읽는 경로가 순액 표시를 문면으로 드는가를 칸으로 들므로, 이 파일의
경로가 순액 기재를 읽으면 두 축이 같은 기재를 읽는 것이고 그 측정 대응이 독립이 아니다.

**이 정의가 배제하는 사례:**
두 축이 다른 개념이므로 그 측정 대응도 다르다고 보는 읽기. 그 편이 두 측정이 한 회계 관례의 두 기재
방식임을 드므로 둘이 서로 다른 개념이라는 판정은 서되 그 둘을 재는 경로가 같은 자료를 두 꼴로 읽는
것일 수 있다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-2 「대차대조표가 드는 것은 스왑과 선물의 연쇄가 낸 최종 결과이고」

**기각한 대체 정의:**
순액 표시에 묶이는가의 판정을 두지 않고 두 축이 독립이라고 적는 안. 선언이 줄어드나 그 독립이
문서화 문면에만 서면 판정에 걸리지 않아 두 축을 함께 쓰는 자리가 그 묶임을 보지 않고 쓸 수 있으며,
관측층이 두 축을 따로 둔 것이 흔들린다는 결손이 그대로 남는다.

**값을 담지 않는다.**
-/
-- DD:CF-4515
def FundingSizeChannel.tiesToNetPresentation {Party : Type}
    (c : FundingSizeChannel Party) : Bool :=
  c.basis == MeasurementBasis.netBasis

/--
그 크기가 어느 경로에서도 총액으로 관측되지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록의 어느 경로가 두 성분을 둘 다 내면서 총액 기재를 읽어야 한다. 그 관측은 그 쌍을 총액으로
내는 공시가 실재한다는 뜻이며, 그러면 회계층의 그 크기가 복원의 사슬을 지나지 않고 바로 선다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 크기가 어느 공시에서도 총액으로 서지 않는다는 것을 구조 안의 명제로 드는
유일한 자리이며, 소스 없음이 이 층의 주된 산출물이므로 전개로 닫히는 증명이어도 그 몫이 있다.
-/
-- DD:CF-4515
theorem funding_size_observed_undetermined :
    fundingSizeObserved fundingSizeChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

/--
그 판정이 두 인자를 각각 고정한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 참인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는
뜻이며, 그러면 한 성분만 내는 경로가 그 쌍을 답하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다.
판정 반환 함수의 논리 결합마다 홀로 값을 가르는 경로를 증거로 드는 정리를 같은 파일에 두라는 A-8 의
요구를 이 명제가 받으며, 결론을 부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거
위에서 재어졌는지가 서지 않으므로 각 인자가 홀로 값을 가르는 자리를 이 명제가 든다.
-/
-- DD:CF-4515
theorem answers_size_pins_each_leg :
    (FundingSizeChannel.answersSize
      ({ coversParty := fun _ => true, readsDebtLeg := true, readsAssetLeg := false,
         basis := MeasurementBasis.grossBasis,
         provenance := MeasurementProvenance.officialReport,
         separatesHedgeUse := false,
         recipient := DisclosureRecipient.publicReader } : FundingSizeChannel Unit) = false)
    ∧ (FundingSizeChannel.answersSize
      ({ coversParty := fun _ => true, readsDebtLeg := false, readsAssetLeg := true,
         basis := MeasurementBasis.grossBasis,
         provenance := MeasurementProvenance.officialReport,
         separatesHedgeUse := false,
         recipient := DisclosureRecipient.publicReader } : FundingSizeChannel Unit) = false)
    ∧ (FundingSizeChannel.answersSize
      ({ coversParty := fun _ => true, readsDebtLeg := true, readsAssetLeg := true,
         basis := MeasurementBasis.grossBasis,
         provenance := MeasurementProvenance.officialReport,
         separatesHedgeUse := false,
         recipient := DisclosureRecipient.publicReader } : FundingSizeChannel Unit) = true) := by
  exact ⟨rfl, rfl, rfl⟩

/--
총액 판정이 두 인자를 각각 고정한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 두 성분을 내되 총액이 아닌 경로에서 참을 내거나, 총액을 읽되 한 성분만 내는 경로에서
참을 내야 한다. 그 관측은 기재 방식이 그 판정에 걸리지 않는다는 뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 전개로 닫히나 그 판정이 논리곱이므로, 그 논리 결합마다 홀로 값을
가르는 경로를 증거로 드는 정리를 같은 파일에 두라는 A-8 의 요구를 이 명제가 받으며 각 인자가 홀로
값을 가르는 자리를 이 명제가 든다.
-/
-- DD:CF-4515
theorem answers_gross_size_pins_each_conjunct :
    (FundingSizeChannel.answersGrossSize inferredFromApparentMismatchChannel = false)
    ∧ (FundingSizeChannel.answersGrossSize derivativeStatisticsChannel = false)
    ∧ (FundingSizeChannel.answersGrossSize
      ({ coversParty := fun _ => true, readsDebtLeg := true, readsAssetLeg := true,
         basis := MeasurementBasis.grossBasis,
         provenance := MeasurementProvenance.officialReport,
         separatesHedgeUse := false,
         recipient := DisclosureRecipient.publicReader } : FundingSizeChannel Unit) = true) := by
  exact ⟨rfl, rfl, rfl⟩

/--
두 축의 측정 대응이 독립이 아닌 배치가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 목록의 어느 경로도 순액 기재를 읽지 않아야 한다. 그 관측은 그 크기를 내는 경로가 순포지션 경로와
다른 기재를 읽는다는 뜻이며, 그러면 두 축을 따로 둔 설계가 그 자리에서 흔들리지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 축을 따로 둔 설계가 흔들리는 자리를 반례의 부재가 아니라 증인의 존재로
세우며, 시스템 수준 제약이 개별 경로의 상태를 결정하지 않으므로 존재 형태로 든다.
-/
-- DD:CF-4515
theorem exists_channel_tying_to_net_presentation :
    ∃ c ∈ fundingSizeChannels, FundingSizeChannel.tiesToNetPresentation c = true := by
  -- 증인은 목록의 둘째 경로인 외견상 불일치를 거꾸로 읽어 유추하는 집계이고, 그 경로가 순액 기재를
  -- 읽는다.
  exact ⟨inferredFromApparentMismatchChannel, List.Mem.tail _ (List.Mem.head _), rfl⟩

/--
기재 방식이 갈리는 두 경로가 함께 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 목록의 경로가 전부 같은 기재 방식을 읽어야 한다. 그 관측은 방식을 칸으로 둘 까닭이 없다는 뜻이며,
그러면 그 칸이 어느 경로도 가르지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 기재 방식을 칸으로 둔 선택이 필요하다는 것을 증인의 존재로 세우며, 전칭으로
세우면 같은 방식을 읽는 두 경로도 실재하므로 거짓이 된다.
-/
-- DD:CF-4515
theorem exists_basis_divergence :
    ∃ a ∈ fundingSizeChannels, ∃ b ∈ fundingSizeChannels, a.basis ≠ b.basis := by
  -- 증인은 총액 기재를 읽는 첫째 경로와 순액 기재를 읽는 둘째 경로다.
  exact ⟨derivativeStatisticsChannel, List.Mem.head _,
    inferredFromApparentMismatchChannel, List.Mem.tail _ (List.Mem.head _),
    fun h => MeasurementBasis.noConfusion h⟩

/--
어느 경로도 투기와 헤지의 쓰임을 가르지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 목록의 어느 경로가 그 쓰임을 가르는 칸을 내야 한다. 그 관측은 그 구별을 내는 공표가 실재한다는
뜻이며, 그러면 그 수단의 잔액이 헤지의 크기를 잰다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 구별이 어느 소스에서도 가려지지 않는다는 것을 구조 안의 명제로 드는 유일한
자리이며, 그 결손이 이 층의 산출물이다.
-/
-- DD:CF-4515
theorem no_channel_separates_hedge_use :
    ∀ c ∈ fundingSizeChannels, c.separatesHedgeUse = false := by
  intro c hc
  unfold fundingSizeChannels at hc
  cases hc with
  | head => rfl
  | tail _ hc => cases hc with
    | head => rfl
    | tail _ hc => cases hc with
      | head => rfl
      | tail _ hc => cases hc

/--
실측과 합성이 한 계열에 이어 붙은 경로가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 목록의 어느 경로도 그 성질을 들지 않아야 한다. 그 관측은 모든 경로가 공식 자료이거나 추정이라는
뜻이며, 그러면 그 성질을 드는 생성자가 어느 경로도 가르지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 값의 성질이 둘로 갈리지 않는 자리가 실재한다는 것을 증인의 존재로 세우며, 그
자리가 이 페이즈가 받은 결손의 요지다.
-/
-- DD:CF-4515
theorem exists_mixed_provenance :
    ∃ c ∈ fundingSizeChannels, c.provenance = MeasurementProvenance.mixedSeries := by
  -- 증인은 목록의 셋째 경로인 대외 포지션의 통화 구성을 내는 계열이다.
  exact ⟨externalPositionCurrencyCompositionChannel,
    List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)), rfl⟩

end CrisisFramework.Observation
