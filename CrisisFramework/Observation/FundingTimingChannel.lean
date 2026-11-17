/-
관측층 — 풋 대응의 시점 입력과 조달 실패 꼴의 가름이 읽히는 경로

규율: L-14(값을 담지 않는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), T-2(반증 조건), T-3(분류), A-3(witness),
      A-8(논리 결합의 증거).

**값을 담지 않는다.** 이 파일은 어느 공시 경로가 무엇을 내는지의 명세만 담고 금액을 담지 않는다.
시점마다의 풋 대응을 정하는 입력에 측정 소스가 없다는 것과 조달 실패의 두 꼴을 구별해 내는 경로가
없다는 것이 이 파일의 산출이다.

**구조를 하나로 두고 판정을 둘로 둔다.** 이 회차가 묻는 둘이 서로 다른 것을 묻고 그 가름이 판정에
서면 어느 판정이 어느 물음에 답하는지가 선다. 칸은 읽는 것마다 하나씩 두고 받는 쪽과 값의 성질은
두 물음이 공유하므로 하나씩 둔다. 앞 페이즈의 채널이 구조 하나에 증거 인스턴스 둘을 둔 것이 선례다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

/--
풋 대응의 시점 입력과 조달 실패 꼴의 공시 경로.

**대응 비형식 개념:** 어느 시점에 어느 단계가 어느 풋에 닿는지를 정하는 입력과, 막힌 조달이 두 꼴
가운데 어느 쪽인지의 가름을 공표 수치에서 읽을 수 있는가. 뒤의 읽기가 서려면 그 가름과 그 조달의 만기
축이 같은 경로에서 함께 나와야 하며, 만기 축이 없으면 갱신이 막힌 것과 완결이 막힌 것이 같아 보인다.

**이 정의가 배제하는 사례:**
그 기관의 도매 조달 만기 구성이 공시에 없고 성질만 서술로 남은 자리. 연차보고서가 단기와 중기의
균형된 혼합이라 적고 지역별 조달의 서술로 그 성격을 대신 들므로(Shin 2009) 그 범주의 만기 축이
공시에서 복원되지 않는다. 이 명세는 어느 경로가 그 축을 내는가만 받으며 서술로 남은 성격을 받지
않는다.
조달처: E-50 §4 「그 범주의 만기 축이 공시에서 복원되지 않는다」

**기각한 대체 정의:**
읽는 칸을 둘로 두고 만기 축의 칸을 빼는 안. 두 꼴의 가름이 만기 축 없이는 서지 않고 그 축의 부재가
이 회차의 조달에서 나온 사실이므로, 그 칸을 빼면 어느 경로가 왜 그 가름을 내지 못하는지가 구조에
남지 않는다. 두 물음마다 구조를 따로 세우는 안도 기각했다. 두 구조가 받는 쪽과 값의 성질의 칸에서
같아 그 꼴이 되풀이되고, 앞 페이즈의 채널도 구조 하나에 인스턴스 둘이었다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거이며 수를 들지 않는다.
-/
-- DD:CF-3960
structure FundingTimingChannel (Node : Type) where
  /-- 그 경로가 시점마다 어느 단계가 어느 풋에 닿는지를 정하는 입력을 내는가. -/
  readsPutTimingInput : Bool
  /-- 그 경로가 막힌 조달이 두 꼴 가운데 어느 쪽인지의 가름을 내는가. -/
  readsFailureKindSplit : Bool
  /-- 그 경로가 그 조달의 만기 축을 내는가. -/
  readsMaturityAxis : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance
  deriving Repr

/--
witness (A-3).

**무엇을 증거하는가.** `FundingTimingChannel` 이 비어 있지 않다. 세 칸을 하나도 내지 않는 경로이며
존재 정리는 이 값을 딛지 않는다.
-/
-- DD:CF-3960
def FundingTimingChannel.noSource : FundingTimingChannel Unit where
  readsPutTimingInput := false
  readsFailureKindSplit := false
  readsMaturityAxis := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 풋 대응의 시점 입력을 답하는가.

**대응 비형식 개념:** 그 경로 하나로 어느 시점에 어느 단계가 어느 풋에 닿는지가 서는가. 그 입력을
내는 칸 하나가 그 답을 정하므로 칸을 그대로 읽는다.

**이 정의가 배제하는 사례:**
공적 조치가 그 대응을 바꾸는 대신 노드를 신설한 자리. 비은행 대출 조성자에게 할인창구 접근을 부여하는
안이 기각되고 중앙은행이 별도 법인을 세웠으므로(Ashcraft · Malz · Pozsar 2012), 그 조치를 공표한
문서는 노드의 신설을 내고 단계의 대응을 내지 않는다. 이 판정은 그 대응의 입력만 받으며 노드 집합의
변화를 받지 않는다.
조달처: E-11 §3-2 「비은행 대출기관의 재무 상태와 대출 풀 전체의 위험을 정확히 평가할 지식이 없었다」

**기각한 대체 정의:**
만기 축의 칸을 곱에 넣는 안. 만기 축은 조달 실패의 두 꼴을 가르는 데 쓰이고 풋 대응의 시점과 색인이
다르므로, 곱에 넣으면 만기 축을 내지 않는 경로가 그 입력을 내더라도 이 판정이 거짓을 내게 된다. 세 칸의
합으로 두는 안도 기각했다. 합으로 두면 가름만 내는 경로가 그 입력을 답하는 것이 되어 그 결손이 사라진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-3960
def FundingTimingChannel.answersPutTiming {Node : Type}
    (c : FundingTimingChannel Node) : Bool :=
  c.readsPutTimingInput

/--
그 경로가 조달 실패 꼴의 가름을 답하는가.

**대응 비형식 개념:** 그 경로 하나로 막힌 조달이 갱신이 막힌 것인지 완결이 막힌 것인지가 서는가. 그
가름과 그 조달의 만기 축을 함께 내야 서므로 두 칸의 곱이다.

**이 정의가 배제하는 사례:**
증권화 채권이 인출 전후로 거의 변하지 않은 자리. 원문이 그 까닭을 그 채권이 길게 상환되는 구조였다는
데 두므로(Shin 2009) 그 범주의 안정성이 만기에서 유도되는데, 그 유도가 서는 범주와 만기 축이 공시에서
복원되지 않는 범주가 같은 보고서 안에서 갈린다. 이 판정은 한 경로를 단위로 두며 범주마다 다른 축의
가용성을 받지 않는다.
조달처: E-50 §3 「그 채권이 해마다 여러 번 갈아야 하는 단기 조달이 아니라 길게 상환되는 구조였다」

**기각한 대체 정의:**
가름의 칸만 읽는 안. 그 가름이 만기 축 없이는 공시에서 유도되지 않고 그 축의 부재가 이 회차의 조달에서
나온 사실이므로, 칸 하나만 읽으면 축을 내지 않는 경로가 그 가름을 답하는 것으로 읽힌다. 세 칸의 곱으로
두는 안도 기각했다. 풋 대응의 시점 입력은 다른 물음에 속하고 그 칸을 곱에 넣으면 두 물음이 한 판정에
접힌다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-3960
def FundingTimingChannel.answersFailureKind {Node : Type}
    (c : FundingTimingChannel Node) : Bool :=
  c.readsFailureKindSplit && c.readsMaturityAxis

/--
연차보고서의 조달 구성 공시.

**대응 비형식 개념:** 그 기관이 자기 조달의 범주별 잔액을 연차보고서로 공표하는 자리. 범주는 서고
그 범주의 만기 축은 서지 않는다.

**이 정의가 배제하는 사례:**
담보부채권이 오히려 늘어난 자리. 원문이 그 까닭으로 분리된 주택담보 자산에 쓰인 유동성 없는 장기
부채라는 성질을 드는데(Shin 2009) 그 성질이 공시의 범주 이름에 서지 않고 원문의 서술로 들어오므로,
이 경로가 내는 것은 범주별 잔액이고 그 범주의 성질이 아니다.
조달처: E-50 §3 「분리된 주택담보 자산에 쓰인 유동성 없는 장기 부채라는 성질을 든다」

**기각한 대체 정의:**
만기 축의 칸을 참으로 두는 안. 그 보고서가 단기와 중기의 균형된 혼합이라 적고 중기를 6개월 이상으로
정의하나 범주별 만기 구성을 내지 않으므로, 참으로 두면 서술로 남은 성격이 공시된 축으로 읽힌다. 받는
쪽을 공개 독자로 두는 안도 기각했다. 연차보고서의 그 자리가 투자자에게 조달 구성을 알리는 공시이고
앞선 채널들이 같은 부류를 투자자로 두었다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거다.
-/
-- DD:CF-3960
def annualReportFundingBreakdown : FundingTimingChannel Unit where
  readsPutTimingInput := false
  readsFailureKindSplit := false
  readsMaturityAxis := false
  recipient := DisclosureRecipient.investor
  provenance := MeasurementProvenance.officialReport

/--
긴급 유동성 제도의 공표 조건.

**대응 비형식 개념:** 중앙은행이 자기 긴급 유동성 제도의 대상과 조건을 공표하는 자리. 그 제도가 어느
주체에게 열렸는지는 서고 그것이 단계와 풋의 대응을 바꾸었는지는 서지 않는다.

**이 정의가 배제하는 사례:**
통상적 경로가 막힌 까닭이 단기금리가 이미 영 근처였다는 것(Ashcraft · Malz · Pozsar 2012). 그 사실은
중앙은행 노드의 제약이 상태에 매인다는 구조적 정보이고 그 제도의 대상과 조건이 아니므로, 이 경로가 내는
것에 들지 않는다. 그 제약은 회계층과 동학층이 받는다.
조달처: E-11 §3-2 「중앙은행 노드의 제약이 상태 의존적이라는 구조적 정보」

**기각한 대체 정의:**
값의 성질을 공표된 보고로 두는 안. 그 제도를 다룬 문면이 기각된 대안과 그 사유를 저자들의 판단으로
들고 그 저자들이 중앙은행 직원이므로, 그 경로가 내는 것은 직원의 추정이다. 풋 대응의 시점 입력 칸을
참으로 두는 안도 기각했다. 그 조치가 단계의 풋 접근을 바꾼 것이 아니라 노드 집합을 바꾼 것이어서,
참으로 두면 이 회차가 가른 두 축이 한 칸에 접힌다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거다.
-/
-- DD:CF-3960
def emergencyFacilityTerms : FundingTimingChannel Unit where
  readsPutTimingInput := false
  readsFailureKindSplit := false
  readsMaturityAxis := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.staffEstimate

/--
이 회차가 든 경로의 목록.

**대응 비형식 개념:** 두 물음을 묻는 관측자가 가진 경로 전량. 이 목록이 전수라고 주장하지 않으며, 이
회차가 조달한 자리에서 나온 둘이다.

**이 정의가 배제하는 사례:**
목록 밖의 경로. 같은 시기에 무너진 다른 유럽 은행의 부외 기구가 단기 증권을 갈아야 하는 데서 온 자리가
그 부류이며(Shin 2009), 그 기구의 조달 공시가 이 회차의 조달에 들지 않으므로 이 목록이 받지 않는다.
조달처: E-50 §3 「같은 시기에 무너진 다른 유럽 은행의 부외 기구는 단기 증권을 갈아야 하는 데서 왔고」

**기각한 대체 정의:**
전수라고 적는 안. 뭉치 밖의 경로를 이 회차가 조사하지 않았으므로 전수 주장을 세울 근거가 없다. 목록을
두지 않고 판정을 경로마다 따로 쓰는 안도 기각했다. 목록이 없으면 관측 결과를 내는 함수가 받을 변이
서지 않는다.

**수 체계를 받지 않는다.** 목록이 경로를 들며 수를 들지 않는다.
-/
-- DD:CF-3960
def fundingTimingChannels : List (FundingTimingChannel Unit) :=
  [annualReportFundingBreakdown, emergencyFacilityTerms]

/--
그 목록에서 풋 대응의 시점 입력이 관측되는가.

**대응 비형식 개념:** 가진 경로 가운데 하나라도 그 입력을 내면 관측이 서고, 하나도 내지 않으면 측정
소스가 없어서 판정되지 않는다.

**이 정의가 배제하는 사례:**
판정되지 않는 까닭이 소스의 부재가 아닌 자리. 그 조치가 노드를 신설한 것이어서 단계의 대응을 묻는
질문이 그 자리에서 답을 갖지 않는 것은 구조가 그 대상을 들지 않는 것이며(Ashcraft · Malz · Pozsar
2012), 이 함수는 그 까닭을 내지 않고 소스의 부재만 낸다.
조달처: E-11 §3-1 「정책 주체가 노드를 신설해서 경계 자체를 바꾼다」

**기각한 대체 정의:**
거짓을 내는 안. 소스가 없다는 것과 그 명제가 거짓이라는 것이 다르고, 관측층이 그 둘을 가르는 열거를
이미 들고 있으므로 거짓을 내면 그 가름이 사라진다. 까닭을 구조의 부재로 두는 안도 기각했다. 이 회차가
시점을 받는 족을 세웠으므로 구조에 대상이 있고, 없는 것은 그 족의 값을 정하는 입력이다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-3960
def putTimingInputObserved {Node : Type}
    (chs : List (FundingTimingChannel Node)) : ObservedTruth :=
  if chs.any (fun c => c.answersPutTiming) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
그 목록에서 조달 실패 꼴의 가름이 관측되는가.

**대응 비형식 개념:** 가진 경로 가운데 하나라도 그 가름과 만기 축을 함께 내면 관측이 서고, 하나도
내지 않으면 측정 소스가 없어서 판정되지 않는다.

**이 정의가 배제하는 사례:**
판정되지 않는 까닭이 소스의 부재가 아닌 자리. 원문이 두 견해를 갈라 세우지 말라고 덧붙이면서 그 인출의
설명이 조정 조율의 실패만으로는 서지 않는다고 적는 것은 설명의 불완전이며(Shin 2009), 이 함수는 그
까닭을 내지 않고 소스의 부재만 낸다.
조달처: E-50 §6 「채권자가 많으면 조정 조율이 인출의 심각성을 키우므로」

**기각한 대체 정의:**
한 경로가 가름을 내고 다른 경로가 만기 축을 낼 때 그 둘을 맞대어 관측을 세우는 안. 받는 쪽이 갈려
한쪽만 보는 관측자에게는 그 맞댐이 서지 않으므로, 이 판정은 한 경로를 단위로 두며 경로 사이의 맞댐을
받지 않는다. 경로의 수를 받아 임계를 두는 안도 기각했다. 하나가 답하면 가름이 서므로 임계가 하나보다
클 근거가 없다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-3960
def failureKindSplitObserved {Node : Type}
    (chs : List (FundingTimingChannel Node)) : ObservedTruth :=
  if chs.any (fun c => c.answersFailureKind) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
가름 판정의 두 인자가 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 두 인자 가운데 하나만 참인 경로에서 그 판정이 참을
내는 것. 네 증인이 그 네 조합을 전부 들므로 그런 배치가 설 수 없고, 반증은 그 곱이 합으로 바뀐
구현에서만 온다.

**가정을 두지 않는다.** 증인이 네 조합을 자기 값으로 들고 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 논리 결합을 세우는 자리마다 각 인자가 홀로 값을 가르는 경로를 증거로
들라는 요구가 이 자리에 걸리고, 그 증거가 없으면 그 결합을 뒤집은 변이가 통과한다.
-/
-- DD:CF-3960
theorem funding_timing_answer_pins_each_conjunct :
    ∃ c₁ c₂ c₃ c₄ : FundingTimingChannel Unit,
      c₁.answersFailureKind = true ∧ c₂.answersFailureKind = false ∧
        c₃.answersFailureKind = false ∧ c₄.answersFailureKind = false ∧
          c₂.readsFailureKindSplit = true ∧ c₃.readsMaturityAxis = true ∧
            c₄.readsFailureKindSplit = false ∧ c₄.readsMaturityAxis = false := by
  -- 두 인자가 함께 참인 경로와 가름만 내는 경로와 만기 축만 내는 경로와 두 인자가 함께 거짓인
  -- 연차보고서의 조달 구성 공시를 든다. 증거 인스턴스 `FundingTimingChannel.noSource` 는 딛지
  -- 않는다. 칸마다 정의를 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨
    { readsPutTimingInput := false, readsFailureKindSplit := true, readsMaturityAxis := true,
      recipient := DisclosureRecipient.publicReader,
      provenance := MeasurementProvenance.officialReport },
    { readsPutTimingInput := false, readsFailureKindSplit := true, readsMaturityAxis := false,
      recipient := DisclosureRecipient.publicReader,
      provenance := MeasurementProvenance.officialReport },
    { readsPutTimingInput := false, readsFailureKindSplit := false, readsMaturityAxis := true,
      recipient := DisclosureRecipient.publicReader,
      provenance := MeasurementProvenance.officialReport },
    annualReportFundingBreakdown,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
이 회차가 든 경로로는 풋 대응의 시점 입력이 판정되지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 목록의 어느 경로가 시점마다의 풋 대응을 정하는
입력을 내는 것. 연차보고서가 조달 구성을 내고 제도의 공표 조건이 노드의 신설을 내므로 그런 경로가 그
목록에 없고, 반증은 그 목록에 경로가 더해지는 회차에서 온다.

**가정을 두지 않는다.** 그 목록이 상수이므로 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 이 진술이 이 페이즈의 관측층 산출 가운데 하나이며, 시점을 받는 족의
값을 정하는 입력에 측정 소스가 없다는 것이 관측층에 등재되는 결손이다.
-/
-- DD:CF-3960
theorem put_timing_input_observed_undetermined :
    putTimingInputObserved fundingTimingChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
이 회차가 든 경로로는 조달 실패 꼴의 가름이 판정되지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 목록의 어느 경로가 그 가름과 만기 축을 함께 내는
것. 두 경로가 그 가름을 내지 않고 만기 축도 내지 않으므로 그런 경로가 그 목록에 없고, 반증은 그 목록에
경로가 더해지는 회차에서 온다.

**가정을 두지 않는다.** 그 목록이 상수이므로 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 이 진술이 이 페이즈의 관측층 산출 가운데 하나이며, 두 꼴을 구별해
내는 공시 경로가 없다는 것이 용어집에서 그 분할에 측정 대응을 붙이지 않은 근거다.
-/
-- DD:CF-3960
theorem failure_kind_split_observed_undetermined :
    failureKindSplitObserved fundingTimingChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

end CrisisFramework.Observation
