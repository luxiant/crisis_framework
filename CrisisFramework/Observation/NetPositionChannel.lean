/-
관측층 — 청구권 순포지션의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(무차원), L-9(import 방향은
      단방향), A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 의 서술),
      C-9(전면 `simp` 금지), A-8(논리 결합마다 홀로 값을 가르는 자리의 증거),
      T-2(반증 조건), T-3(기여 분류).

**이 파일이 세우는 것은 집계가 순포지션에 하는 일이 어느 공시에서 읽히는가의 명세다.** 회계층이 집계
뒤 노드의 순포지션을 그 노드의 섬유 위 당사자 순포지션의 합으로 세우므로, 그 항등식이 관측되려면
당사자별 값과 그 섬유가 둘 다 읽혀야 한다.

**연결 공시로는 재어지지 않는다.** 연결재무제표가 묶인 뒤의 값을 내고 그 묶음이 어느 당사자를 담았는지를
칸으로 내지 않으므로, 섬유 쪽이 비어 있다. 같은 실물 흐름이 한 결정 단위 안에서는 재고로 서고 둘로
갈리면 매출채권으로 서는데 그 경계를 공시가 드러내지 않는다.

**값을 담지 않는다.** 금액도 순포지션도 이 파일에 서지 않고 그것을 내는 경로가 있는가만 선다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

/--
청구권 순포지션의 공시 경로.

**대응 비형식 개념:** 한 공시가 그 항등식의 재료를 내는가. 당사자별 순포지션과 당사자에서 노드로 가는
묶음이 재료이고 경로마다 내는 것이 다르다.

**이 정의가 배제하는 사례:**
연결된 뒤의 값이 공표되면 그 항등식이 재어진다고 보는 읽기. 글로벌 가치사슬을 다룬 편이 경계가 총액을
만든다는 것을 관찰로 두므로 묶음이 어디에 그어졌는지가 서지 않으면 그 합이 무엇 위의 합인지도 서지
않는다(Bruno·Kim·Shin 2018).
조달처: E-19 §3-1 「청구권 집합이 노드 분할에 의존한다」

**기각한 대체 정의:**
순액 표시의 유무를 드는 칸을 두지 않는 안. 공시가 순액으로 표시한다는 것과 그 순액이 당사자별로
쪼개진다는 것이 다른 사실인데, 빼면 표시의 꼴과 재료의 유무가 한 칸에 묻힌다. 두 재료를 한 칸으로
접는 안도 기각했다. 당사자별 값은 감독 보고에서 읽히고 섬유는 어디에서도 읽히지 않아 결손의 자리가
다르며, 접으면 그 가름이 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-3880
structure NetPositionChannel (Party : Type) where
  /-- 그 경로가 당사자별 청구권 잔액을 내는가. -/
  readsPartyLevelPosition : Bool
  /-- 그 경로가 어느 당사자가 어느 노드로 묶이는지를 내는가. -/
  readsConsolidationFiber : Bool
  /-- 그 경로가 순액 표시를 문면으로 드는가. -/
  statesNetPresentation : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/-- witness (A-3). **무엇을 증거하는가.** `NetPositionChannel` 이 비어 있지 않다. 세 칸을 하나도
내지 않는 경로 하나를 든다. -/
-- DD:CF-3880
def NetPositionChannel.noSource : NetPositionChannel Unit where
  readsPartyLevelPosition := false
  readsConsolidationFiber := false
  statesNetPresentation := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 순포지션의 섬유 위 합을 답하는가.

**대응 비형식 개념:** 그 공시 하나로 그 항등식의 양변이 재어지는가. 당사자별 값과 묶음이 둘 다 서야
답이 된다.

**이 정의가 배제하는 사례:**
당사자별 값이 공표되면 그 합이 재어진다고 보는 읽기. 한 감독 보고를 다룬 문면이 대출의 표시 통화 칸이
시기에 따라 서고 그 보고가 차주의 소속 묶음을 내지 않음을 적으므로, 당사자별 값만으로는 어느 노드의
합인지가 서지 않는다(Niepmann·Schmidt-Eisenlohr 2019).
조달처: E-65 §3-1 「대출의 표시 통화는 그 보고의 뒤 시기에 칸이 생겨 그 시점부터만 읽힌다」

**기각한 대체 정의:**
순액 표시의 유무를 답의 인자로 넣는 안. 그 표시는 공시의 꼴이고 재료가 아니어서 넣으면 꼴이 재료의
자리에 서며, 순액으로 표시하지 않는 공시가 재료를 다 내는 배치가 답에서 빠진다.

**값을 담지 않는다.**
-/
-- DD:CF-3880
def NetPositionChannel.answersNetPosition {Party : Type} (c : NetPositionChannel Party) : Bool :=
  c.readsPartyLevelPosition && c.readsConsolidationFiber

/--
연결된 뒤의 값을 공표하는 경로.

**대응 비형식 개념:** 묶인 단위의 재무제표. 순액 표시를 문면으로 들되 어느 당사자가 그 묶음에 들었는지를
칸으로 내지 않는다.

**이 정의가 배제하는 사례:**
연결의 경계가 공시에서 읽힌다고 보는 읽기. 같은 편이 같은 실물 흐름이 한 결정 단위 안에서는 재고로
서고 결정 단위 둘로 갈리면 매출채권으로 선다고 적으므로 경계가 값을 만드는데, 그 경계 자체는 공시의
칸이 아니다(Bruno·Kim·Shin 2018).
조달처: E-19 §3-1 「경계가 총액을 만든다는 것이 이 편의 관찰이며」

**기각한 대체 정의:**
이 경로를 두지 않는 안. 순액 표시가 공시에 선다는 사실이 사라지고, 이 결손이 표시의 부재인지 재료의
결손인지가 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3880
def consolidatedStatementDisclosure : NetPositionChannel Unit where
  readsPartyLevelPosition := false
  readsConsolidationFiber := false
  statesNetPresentation := true
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
대출 단위 값을 감독 당국에 내는 경로.

**대응 비형식 개념:** 차주별 잔액을 칸으로 드는 감독 보고. 당사자별 값은 내되 그 차주가 어느 결정
단위로 묶이는지는 내지 않는다.

**이 정의가 배제하는 사례:**
입도가 대출까지 내려가면 묶음도 읽힌다고 보는 읽기. 같은 문면이 그 보고의 칸이 시기에 따라 생기고
사라진다고 적으므로 입도가 내려가도 없는 칸은 열리지 않는다(Niepmann·Schmidt-Eisenlohr 2019).
조달처: E-65 §3-1 「대출의 표시 통화는 그 보고의 뒤 시기에 칸이 생겨 그 시점부터만 읽힌다」

**기각한 대체 정의:**
이 경로가 당사자별 값을 낸다는 것을 거짓으로 두는 안. 그 보고가 차주 단위의 잔액을 들게 하므로
거짓이며, 그러면 결손의 자리가 당사자 쪽으로 옮겨져 섬유 쪽이 비어 있다는 산출이 흐려진다.

**값을 담지 않는다.**
-/
-- DD:CF-3880
def supervisoryLoanLevelReport : NetPositionChannel Unit where
  readsPartyLevelPosition := true
  readsConsolidationFiber := false
  statesNetPresentation := false
  recipient := DisclosureRecipient.supervisor
  provenance := MeasurementProvenance.officialReport

/--
청구권 순포지션의 공시 경로 목록.

**대응 비형식 개념:** 이 읽기가 확보한 경로 전부. 둘이며 어느 쪽도 두 재료를 다 내지 않는다.

**이 정의가 배제하는 사례:**
경로가 여럿이면 그 합집합이 재료를 다 덮는다고 보는 읽기. 당사자별 값을 내는 경로와 순액 표시를 드는
경로가 둘 다 서 있어도 묶음을 내는 경로가 없으므로 합집합도 그 재료를 내지 않는다
(Bruno·Kim·Shin 2018).
조달처: E-19 §3-1 「청구권 집합이 노드 분할에 의존한다」

**기각한 대체 정의:**
목록을 비우고 소스 없음을 바로 적는 안. 그러면 당사자별 값이 감독 보고에서 읽힌다는 사실이 사라지고,
이 결손이 어느 재료에서 서는지가 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3880
def netPositionChannels : List (NetPositionChannel Unit) :=
  [consolidatedStatementDisclosure, supervisoryLoanLevelReport]

/--
순포지션의 섬유 위 합이 그 경로 목록에서 관측되는가.

**대응 비형식 개념:** 그 항등식의 양변을 외부 관측자가 낼 수 있는가. 낼 수 있으면 성립을 내고 낼 수
없으면 측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
연결 공시가 있으므로 그 항등식이 재어진다고 보는 읽기. 같은 편이 경계가 총액을 만든다고 적어 그 경계가
값의 전제임을 드는데 공시가 그 경계를 칸으로 내지 않으므로, 연결된 값만으로는 섬유 위 합이 재어지지
않는다(Bruno·Kim·Shin 2018).
조달처: E-19 §3-1 「경계가 총액을 만든다는 것이 이 편의 관찰이며」

**기각한 대체 정의:**
구조가 그 대상을 담지 않는다는 까닭을 내는 안. 회계층이 그 항등식을 세우므로 담는 대상이 있으며,
그러면 조달로 풀릴 수 있는 결손이 구조의 결손으로 적힌다.

**값을 담지 않는다.** 목록 접기와 열거의 생성자만 쓴다.
-/
-- DD:CF-3880
def netPositionObserved {Party : Type} (chs : List (NetPositionChannel Party)) : ObservedTruth :=
  if chs.any (fun c => c.answersNetPosition) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
그 답이 두 인자를 각각 고정한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 참인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는 뜻이며,
그러면 당사자별 값만 내고 묶음을 내지 않는 경로가 그 항등식을 답하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로, 각
인자가 홀로 참인 자리를 이 정리가 든다.
-/
-- DD:CF-3880
theorem net_position_answer_pins_each_conjunct :
    ∃ cParty cFiber : NetPositionChannel Unit,
      cParty.readsPartyLevelPosition = true ∧ cParty.readsConsolidationFiber = false
        ∧ cParty.answersNetPosition = false
        ∧ cFiber.readsPartyLevelPosition = false ∧ cFiber.readsConsolidationFiber = true
        ∧ cFiber.answersNetPosition = false := by
  exact ⟨supervisoryLoanLevelReport,
    { readsPartyLevelPosition := false, readsConsolidationFiber := true,
      statesNetPresentation := false, recipient := DisclosureRecipient.publicReader,
      provenance := MeasurementProvenance.officialReport },
    rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
그 경로 목록에서 순포지션의 섬유 위 합이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록의 어느 경로가 두 재료를 다 내야 한다. 그 관측은 당사자별 값과 묶음을 함께 내는 공시가 실재한다는
뜻이며, 그러면 이 결손이 조달로 풀린다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 이 프레임워크의 주요 산출 가운데 하나이고, 회계층이
세운 항등식이 공표 수치에서 재어지지 않는다는 것이 이 진술의 내용이므로 기여 목록에 든다.
-/
-- DD:CF-3880
theorem net_position_observed_undetermined :
    netPositionObserved netPositionChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

end CrisisFramework.Observation
