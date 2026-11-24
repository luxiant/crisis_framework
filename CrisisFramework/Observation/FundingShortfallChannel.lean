/-
관측층 — 채워지지 않은 몫의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(무차원), L-9(import 방향은
      단방향), A-3(witness 의무), A-8(논리 결합마다 홀로 값을 가르는 자리의 증거),
      C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류), T-6(존재 형태).

**이 파일이 세우는 것은 회계층의 채워지지 않은 몫의 금액과 그 사건의 유무가 어느 공시에서 읽히는가의
명세다.** 증권발행실적보고서가 청약과 배정 현황 표와 실권주 처리내역과 미계약분 처리내역과 발행가를
드는 절을 따로 두므로, 그 절마다 무엇을 내는지를 칸으로 둔다.

**금액이 공표의 칸으로 서는지와 관측자의 계산으로 서는지를 가른다.** 어느 경로도 그 몫의 금액만을 받는
금액 칸을 두지 않으므로 그 금액은 몫의 수량과 발행가의 곱으로만 서고, 그 곱이 관측자의 계산이라는 것이
경로의 칸에서 판정으로 선다.

**빈 기재가 무엇을 내는지를 가른다.** 사건이 있을 때에만 기재되는 경로의 빔은 사건의 부재와 보고의
결손을 가르지 않고, 조건 없이 기재되는 경로가 그 꼴을 받을 때에만 빔이 부재를 낸다.

**값을 담지 않는다.** 금액도 수량도 이 파일에 서지 않고 그것을 내는 경로가 있는가만 선다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.FundingFailure
import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

open CrisisFramework.Definition

/--
채워지지 않은 몫의 공시 경로.

**대응 비형식 개념:** 한 공시가 조달 실패에서 채워지지 않은 몫의 사건과 그 수량과 금액과 단가를 내는가.
경로마다 받는 꼴과 기재되는 조건과 내는 칸이 다르며, 그 칸이 그 몫만 받는지가 함께 걸린다.

**이 정의가 배제하는 사례:**
청약과 배정 현황 표의 기타 행 금액을 실권주의 몫의 금액으로 읽는 자리(기업공시서식 작성기준
제13-1-1조). 그 행이 인수회사의 실권주 인수를 다른 것과 함께 받으므로 그 금액은 그 몫만의 금액이
아니며, 이 구조는 그 칸이 그 몫만 받는지를 따로 두어 그 읽기를 막는다.
조달처: E-73 §2-2 「그 열거가 등으로 열려 있으므로 그 칸의 값에서 실권주 인수분만 가려지지 않는다」

**기각한 대체 정의:**
경로에 값의 성질 칸을 두어 그 곱을 읽는 쪽이 유도한 추정으로 두는 안. 그 곱은 수량과 발행가가 공표된
자리에서 계산으로 정확히 서서 추정과 갈리므로, 추정으로 두면 정확한 계산이 편향을 품는 값과 같은 칸에
든다. 값의 성질을 드는 열거에 관측자의 계산을 생성자로 더하는 안도 기각했다. 이 파일이 그 곱으로 값을
내는 답 함수를 세우지 않아 그 생성자를 받는 자리가 서지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-4602
structure FundingShortfallChannel (Party : Type) where
  /-- 그 당사자를 이 경로가 보는가. -/
  coversParty : Party → Bool
  /-- 그 꼴의 사건을 이 경로가 받는가. -/
  coversKind : FundingFailureKind → Bool
  /-- 그 사건이 있을 때에만 이 경로가 기재되는가. -/
  conditionalOnEvent : Bool
  /-- 채워지지 않은 몫의 수량을 이 경로가 내는가. -/
  readsQuantity : Bool
  /-- 금액 칸을 이 경로가 내는가. -/
  readsAmount : Bool
  /-- 이 경로의 칸이 채워지지 않은 몫만 받는가. -/
  isolatesPortion : Bool
  /-- 발행가를 이 경로가 내는가. -/
  readsUnitPrice : Bool
  /-- 이 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient

/-- witness (A-3). **무엇을 증거하는가.** `FundingShortfallChannel` 이 비어 있지 않다. 어느 당사자도
보지 않고 어느 꼴도 받지 않으며 어느 칸도 내지 않는 경로 하나를 든다. -/
-- DD:CF-4602
def FundingShortfallChannel.noSource {Party : Type} : FundingShortfallChannel Party where
  coversParty := fun _ => false
  coversKind := fun _ => false
  conditionalOnEvent := false
  readsQuantity := false
  readsAmount := false
  isolatesPortion := false
  readsUnitPrice := false
  recipient := DisclosureRecipient.publicReader

/--
그 경로가 채워지지 않은 몫의 금액을 공표의 칸으로 내는가.

**대응 비형식 개념:** 한 경로가 그 몫의 금액을 공표로 내려면 금액 칸을 내고 그 칸이 그 몫만 받아야 한다.
한쪽만 서면 그 금액이 공표의 칸으로 서지 않는다.

**이 정의가 배제하는 사례:**
인수기관별 표의 인수금액을 떠안은 금액으로 읽는 자리(기업공시서식 작성기준 별지 제24호 서식). 그 표가
금액을 들되 그 금액이 인수하기로 약정한 금액이어서 실권주의 몫에서 실제로 발동한 금액이 아니므로, 금액
칸이 있다는 것과 그 몫의 금액이 공표된다는 것이 다르다.
조달처: E-73 §2-3 「실권으로 발동한 금액을 따로 드는 칸이 그 표에 없다」

**기각한 대체 정의:**
금액 칸의 유무만 보는 안. 청약과 배정 현황 표의 기타 행이 인수회사의 실권주 인수를 다른 것과 함께
받는데도 그 금액을 내는 것으로 세어져, 그 몫만의 금액이 공표되지 않는다는 결손이 판정에서 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-4602
def FundingShortfallChannel.answersAmountByPublication {Party : Type}
    (c : FundingShortfallChannel Party) : Bool :=
  c.readsAmount && c.isolatesPortion

/--
그 경로의 빈 기재가 그 꼴의 사건이 없었음을 내는가.

**대응 비형식 개념:** 조건 없이 기재되는 경로가 그 꼴을 받으면 그 칸이 빈 것이 그 사건이 없었다는 것이다.
사건이 있을 때에만 기재되는 경로는 빈 기재가 사건의 부재인지 보고의 결손인지를 가르지 않는다.

**이 정의가 배제하는 사례:**
실권주 처리내역이 없는 보고서를 실권주가 없었던 발행으로 읽는 자리(기업공시서식 작성기준 제13-1-7조). 그
절이 실권주가 발생한 경우에만 기재되므로, 그 절이 비어 있는 것이 그 사건의 부재와 그 절의 누락을 가르지
않는다.
조달처: E-73 §2-7 「실권주 처리내역과 미계약분 처리내역이 둘 다 그 사건이 발생한 경우에만 기재된다」

**기각한 대체 정의:**
그 경로가 그 꼴을 받는가만 보는 안. 사건이 있을 때에만 기재되는 경로의 빔이 사건의 부재와 보고의 결손을
가르지 않는데도 그 빔을 부재로 센다.

**값을 담지 않는다.**
-/
-- DD:CF-4602
def FundingShortfallChannel.readsAbsenceOf {Party : Type}
    (c : FundingShortfallChannel Party) (k : FundingFailureKind) : Bool :=
  c.coversKind k && !c.conditionalOnEvent

/--
증권발행실적보고서의 청약과 배정 현황 표.

**대응 비형식 개념:** 청약자 유형마다 최초 배정과 청약 현황과 최종 배정 현황을 드는 표. 지분증권에서 넷째
유형인 기타 행이 인수회사의 실권주 인수를 받으며, 청약 현황과 최종 배정 현황이 수량과 금액을 든다.

**이 정의가 배제하는 사례:**
최초 배정과 최종 배정 현황의 차를 금액으로 내는 읽기(기업공시서식 작성기준 제13-1-1조). 최초 배정이 금액
칸을 들지 않으므로 그 차는 수량으로만 서고, 이 경로가 내는 금액은 최종 배정 현황의 것이다.
조달처: E-73 §2-1 「최초 배정이 금액 칸을 들지 않기 때문이다」

**기각한 대체 정의:**
그 기타 행이 채워지지 않은 몫만 받는다고 두는 안. 그 열거가 등으로 열려 있어 그 칸의 값에서 실권주
인수분만 가려지지 않으므로, 그렇게 두면 그 몫의 금액이 공표의 칸으로 서는 것으로 세어진다.

**값을 담지 않는다.**
-/
-- DD:CF-4602
def allotmentTableChannel : FundingShortfallChannel Unit where
  coversParty := fun _ => true
  coversKind := fun
    | .rolloverFailure .shifted => false
    | .rolloverFailure .runoff => false
    | .pipelineFailure .shifted => true
    | .pipelineFailure .retained => false
    | .pipelineFailure .lapsed => false
  conditionalOnEvent := false
  readsQuantity := true
  readsAmount := true
  isolatesPortion := false
  readsUnitPrice := false
  recipient := DisclosureRecipient.publicReader

/--
증권발행실적보고서의 실권주 처리내역.

**대응 비형식 개념:** 유상증자에서 실권주가 발생한 경우에 그 처리를 제3자배정과 실권주 공모로 갈라 드는 절.
그 표들이 배정주식수와 대표주관회사 인수분을 주식수로 들고 금액 칸을 들지 않는다.

**이 정의가 배제하는 사례:**
대표주관회사 인수분을 금액으로 읽는 자리(기업공시서식 작성기준 제13-1-7조). 그 인수분이 주식수로만 서므로
그 금액은 그 수량에 발행가를 곱해야 서고, 그 곱이 이 절에 서지 않는다.
조달처: E-73 §2-4 「대표주관회사 인수분도 주식수이며, 그 금액을 내려면 수량에 발행가를 곱해야 한다」

**기각한 대체 정의:**
제3자배정과 실권주 공모의 표를 경로 둘로 가르는 안. 그 표들이 한 절에서 같은 조건으로 기재되고 둘 다
수량만 들어 칸이 갈리지 않으므로, 가르면 같은 칸의 경로가 둘 선다.

**값을 담지 않는다.**
-/
-- DD:CF-4602
def forfeitedShareDispositionChannel : FundingShortfallChannel Unit where
  coversParty := fun _ => true
  coversKind := fun
    | .rolloverFailure .shifted => false
    | .rolloverFailure .runoff => false
    | .pipelineFailure .shifted => true
    | .pipelineFailure .retained => false
    | .pipelineFailure .lapsed => false
  conditionalOnEvent := true
  readsQuantity := true
  readsAmount := false
  isolatesPortion := true
  readsUnitPrice := false
  recipient := DisclosureRecipient.publicReader

/--
증권발행실적보고서의 미계약분 처리내역.

**대응 비형식 개념:** 투자계약증권에서 미계약분이 발생한 경우에 계약이 체결되지 않은 내용과 향후
처리계획을 드는 절. 표를 두지 않는 산문이어서 수량과 금액의 칸이 서지 않는다.

**이 정의가 배제하는 사례:**
지분증권의 미계약분을 이 절에서 찾는 읽기(기업공시서식 작성기준 제13-1-8조). 지분증권의 경우에 기재할 절의
열거가 실권주 처리내역까지이고 이 절을 들지 않으므로, 이 경로가 받는 것은 투자계약증권의 몫이다.
조달처: E-73 §2-5 「지분증권의 경우에 기재할 절의 열거가 실권주 처리내역까지이고」

**기각한 대체 정의:**
그 절이 수량을 낸다고 두는 안. 그 조가 표를 두지 않고 계약이 체결되지 않은 내용과 향후 처리계획을 적는
산문이어서 수량의 칸이 서지 않으므로, 수량을 낸다고 두면 산문에 적힌 수가 칸으로 세어진다.

**값을 담지 않는다.**
-/
-- DD:CF-4602
def uncontractedDispositionChannel : FundingShortfallChannel Unit where
  coversParty := fun _ => true
  coversKind := fun
    | .rolloverFailure .shifted => false
    | .rolloverFailure .runoff => false
    | .pipelineFailure .shifted => false
    | .pipelineFailure .retained => false
    | .pipelineFailure .lapsed => true
  conditionalOnEvent := true
  readsQuantity := false
  readsAmount := false
  isolatesPortion := true
  readsUnitPrice := false
  recipient := DisclosureRecipient.publicReader

/--
증권발행실적보고서의 발행가를 드는 절.

**대응 비형식 개념:** 그 발행의 단가를 드는 자리. 어느 꼴의 사건도 받지 않으나 채워지지 않은 몫의 금액을
수량에서 내는 곱의 한 인자가 이 자리에 선다.

**이 정의가 배제하는 사례:**
실권주 처리내역의 수량과 이 절의 발행가를 곱한 값을 공표된 금액으로 읽는 자리(기업공시서식 작성기준
제13-1-7조). 그 곱은 관측자가 두 절의 값을 맞대어 내는 것이어서 공표의 칸이 아니다.
조달처: E-73 §3-3 「그 곱이 관측자의 계산이고 공표의 칸이 아니다」

**기각한 대체 정의:**
발행가를 드는 절을 경로로 두지 않는 안. 그 곱의 한 인자가 그 절에 서므로, 두지 않으면 그 몫의 금액이
수량과 발행가의 곱으로 선다는 것이 경로의 목록에서 유도되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-4602
def issuePriceChannel : FundingShortfallChannel Unit where
  coversParty := fun _ => true
  coversKind := fun _ => false
  conditionalOnEvent := false
  readsQuantity := false
  readsAmount := false
  isolatesPortion := false
  readsUnitPrice := true
  recipient := DisclosureRecipient.publicReader

/--
채워지지 않은 몫의 공시 경로 전량.

**대응 비형식 개념:** 이 뭉치가 조달한 증권발행실적보고서에서 그 몫의 사건과 수량과 금액과 단가를 낼 수
있는 경로의 목록. 목록에 들었다는 것과 그 몫의 금액을 공표한다는 것이 다르다.

**이 정의가 배제하는 사례:**
이 목록이 세상의 경로 전량이라고 보는 읽기. 공시 서식을 읽은 기록이 합병등과 집합투자증권의 서식을 열지
않았다고 적으므로, 이 목록이 드는 것은 그 기록이 연 증권발행실적보고서의 절이지 공표 전량이 아니다.
조달처: E-73 §7 「합병등과 집합투자증권의 세 서식도 열지 않았다」

**기각한 대체 정의:**
소스 없음 증인을 목록에 넣는 안. 목록이 비지 않음을 그 자리에서 보이나 그 증인이 어느 칸도 내지 않아 판정을
바꾸지 않고, 넣으면 실재하는 경로와 증거용 경로가 같은 목록에 섞인다.

**값을 담지 않는다.**
-/
-- DD:CF-4602
def fundingShortfallChannels : List (FundingShortfallChannel Unit) :=
  [allotmentTableChannel,
   forfeitedShareDispositionChannel,
   uncontractedDispositionChannel,
   issuePriceChannel]

/--
빈 기재가 그 꼴의 사건이 없었음을 내는가.

**대응 비형식 개념:** 경로 목록에서 그 꼴을 받으며 조건 없이 기재되는 경로를 찾으면 빈 기재가 그 사건의
부재를 내고, 찾지 못하면 측정 소스가 없다는 까닭으로 판정 불가가 선다.

**이 정의가 배제하는 사례:**
미계약분 처리내역이 없는 투자계약증권의 보고서를 미계약분이 없었던 발행으로 읽는 자리(기업공시서식 작성기준
제13-1-8조). 그 절이 미계약분이 발생한 경우에만 기재되고 그 꼴을 받는 다른 경로가 없으므로, 그 빔이 부재를
내지 않는다.
조달처: E-73 §2-5 「미계약분이 발생한 경우에만 기재하게 한다」

**기각한 대체 정의:**
판정 불가의 까닭을 새로 세우는 안. 사건의 부재를 내는 자리가 없다는 것이 측정 소스가 없다는 까닭의 문면과
같으므로, 새 까닭을 세우면 같은 사실이 두 까닭으로 갈린다.

**값을 담지 않는다.**
-/
-- DD:CF-4602
def emptyReportShowsAbsence {Party : Type} (chs : List (FundingShortfallChannel Party))
    (k : FundingFailureKind) : ObservedTruth :=
  if chs.any (fun c => c.readsAbsenceOf k) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
어느 경로도 채워지지 않은 몫의 금액을 공표의 칸으로 내지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록의 어느 경로가 금액 칸을 내면서 그 칸이 그 몫만 받아야 한다. 그 관측은 실권주의 몫이나 미계약분의
금액을 그것만으로 드는 칸이 서식에 있다는 뜻이며, 그러면 그 금액이 관측자의 계산이 아니라 공표로 선다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 몫의 금액이 어느 공시에서도 공표의 칸으로 서지 않는다는 것을 구조 안의 명제로
드는 유일한 자리이며, 소스 없음이 이 층의 주된 산출물이므로 전개로 닫히는 증명이어도 그 몫이 있다.
-/
-- DD:CF-4602
theorem no_channel_answers_shortfall_amount_by_publication :
    ∀ c ∈ fundingShortfallChannels, c.answersAmountByPublication = false := by
  intro c hc
  unfold fundingShortfallChannels at hc
  cases hc with
  | head => rfl
  | tail _ hc => cases hc with
    | head => rfl
    | tail _ hc => cases hc with
      | head => rfl
      | tail _ hc => cases hc with
        | head => rfl
        | tail _ hc => cases hc

/--
그 몫의 수량만을 내는 경로와 발행가를 내는 경로가 함께 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록에서 그 몫만 받는 칸으로 수량을 내는 경로나 발행가를 내는 경로가 없어야 한다. 그 관측은 그 몫의
금액을 수량과 발행가의 곱으로도 세울 수 없다는 뜻이며, 그러면 그 금액이 관측자의 계산으로도 서지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 몫의 금액이 공표가 아니라 관측자의 계산으로 선다는 것을 그 곱의 인자를 내는
경로의 존재로 세우며, 그 곱이 어느 경로의 칸에도 서지 않는다는 앞 정리와 짝을 이룬다. 시스템 수준 제약이
개별 경로의 상태를 결정하지 않으므로 존재 형태로 든다.
-/
-- DD:CF-4602
theorem exists_isolated_quantity_and_issue_price :
    (∃ a ∈ fundingShortfallChannels, a.readsQuantity = true ∧ a.isolatesPortion = true)
      ∧ (∃ b ∈ fundingShortfallChannels, b.readsUnitPrice = true) := by
  -- 수량의 증인은 목록의 둘째 경로인 실권주 처리내역이고 발행가의 증인은 넷째 경로다.
  exact ⟨⟨forfeitedShareDispositionChannel, List.Mem.tail _ (List.Mem.head _), rfl, rfl⟩,
    ⟨issuePriceChannel, List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))), rfl⟩⟩

/--
부담 불성립의 사건이 없었다는 것은 빈 기재에서 판정되지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록에서 부담 불성립을 받으며 조건 없이 기재되는 경로가 있어야 한다. 그 관측은 미계약분이 없었다는
것을 공표가 낸다는 뜻이며, 그러면 그 빔이 사건의 부재와 보고의 결손을 가른다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 미계약분 처리내역만 그 꼴을 받아 빈 기재가 부재를 내지 않는다는 것을 구조 안의
명제로 드는 유일한 자리이며, 그 결손이 이 층의 산출물이다.
-/
-- DD:CF-4602
theorem empty_report_lapsed_undetermined :
    emptyReportShowsAbsence fundingShortfallChannels (.pipelineFailure .lapsed)
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

/--
부담 이전의 사건이 없었다는 것은 빈 기재에서 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
청약과 배정 현황 표가 사건이 있을 때에만 기재되거나 그 기타 행이 인수회사의 실권주 인수를 받지 않아야
한다. 그 관측은 그 행이 빈 것이 인수가 없었다는 것을 내지 않는다는 뜻이며, 그러면 부담 이전의 부재도 판정
불가로 선다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 조건 없이 기재되는 경로가 그 꼴을 받으면 빈 기재가 부재를 낸다는 판정이 실재하는
경로에서 서는 자리이며, 그 기타 행이 비지 않았을 때 그 값이 인수만인지는 가려지지 않으므로 이 판정이
부재만 읽는다는 것이 앞 정리와의 대비로 선다.
-/
-- DD:CF-4602
theorem empty_report_shifted_holds :
    emptyReportShowsAbsence fundingShortfallChannels (.pipelineFailure .shifted)
      = ObservedTruth.holds := by
  rfl

/--
롤오버 실패의 하위 꼴의 사건 유무는 빈 기재에서 판정되지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록의 어느 경로가 롤오버 실패의 어느 하위 꼴을 받으며 조건 없이 기재되어야 한다. 그 관측은 갱신되지
않은 몫을 약정이 떠안았는지를 가르는 공표가 실재한다는 뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 롤오버 실패의 하위 꼴을 가르는 공표가 이 목록에 없다는 것을 구조 안의 명제로 드는
유일한 자리이며, 그 공표를 기다리는 결손을 구멍 CF-4603 이 받는다.
-/
-- DD:CF-4602
theorem empty_report_rollover_undetermined (j : RolloverFailureKind) :
    emptyReportShowsAbsence fundingShortfallChannels (.rolloverFailure j)
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  cases j <;> rfl

/--
금액을 공표의 칸으로 내는가의 판정이 두 인자를 각각 고정한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 금액 칸만 내거나 그 몫만 받는 칸만 내는 경로에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이
아니라는 뜻이며, 그러면 그 몫만 받지 않는 금액 칸이 그 금액을 공표하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 판정 반환
함수의 논리 결합마다 홀로 값을 가르는 경로를 증거로 드는 정리를 같은 파일에 두라는 A-8 의 요구를 이
명제가 받는다.
-/
-- DD:CF-4602
theorem answers_amount_by_publication_pins_each_conjunct :
    (FundingShortfallChannel.answersAmountByPublication allotmentTableChannel = false)
    ∧ (FundingShortfallChannel.answersAmountByPublication forfeitedShareDispositionChannel = false)
    ∧ (FundingShortfallChannel.answersAmountByPublication
      ({ coversParty := fun _ => true, coversKind := fun _ => false,
         conditionalOnEvent := false, readsQuantity := false, readsAmount := true,
         isolatesPortion := true, readsUnitPrice := false,
         recipient := DisclosureRecipient.publicReader } : FundingShortfallChannel Unit) = true) := by
  exact ⟨rfl, rfl, rfl⟩

/--
빈 기재가 부재를 내는가의 판정이 두 인자를 각각 고정한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 그 꼴을 받되 사건이 있을 때에만 기재되는 경로나 조건 없이 기재되되 그 꼴을 받지 않는 경로에서
참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는 뜻이며, 그러면 빈 기재가 부재를 내지 않는 자리가
부재로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 판정 반환
함수의 논리 결합마다 홀로 값을 가르는 경로를 증거로 드는 정리를 같은 파일에 두라는 A-8 의 요구를 이
명제가 받는다.
-/
-- DD:CF-4602
theorem reads_absence_pins_each_conjunct :
    (FundingShortfallChannel.readsAbsenceOf forfeitedShareDispositionChannel
        (.pipelineFailure .shifted) = false)
    ∧ (FundingShortfallChannel.readsAbsenceOf allotmentTableChannel
        (.pipelineFailure .lapsed) = false)
    ∧ (FundingShortfallChannel.readsAbsenceOf allotmentTableChannel
        (.pipelineFailure .shifted) = true) := by
  exact ⟨rfl, rfl, rfl⟩

end CrisisFramework.Observation
