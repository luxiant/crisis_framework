/-
관측층 — 손실 전달 사슬의 공시 경로

규율: L-14(값을 담지 않는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), T-2(반증 조건), T-3(분류), A-3(witness), A-8(논리 결합의 증거).

**값을 담지 않는다.** 이 파일은 어느 공시 경로가 무엇을 내는지의 명세만 담고 금액을 담지 않는다.
금액은 회계층이 익스포저와 담보와 자기자본을 수로 맞대어 낸다.

**채널을 사슬의 칸마다 가르지 않고 하나로 둔다.** 생존자 부담의 금액과 그것을 낳은 상환 실패와 두
부담의 가름이 전부 같은 결손을 내므로, 칸마다 채널을 세우면 증거 인스턴스와 정리가 그 자리마다
되풀이된다. 앞 페이즈의 두 채널이 같은 꼴로 섰다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

/--
손실 전달 사슬의 공시 경로.

**대응 비형식 개념:** 어느 보유자의 자기자본이 어느 의무자의 상환 실패로 줄었는지를 공표 수치에서
읽을 수 있는가. 그 읽기가 서려면 생존자 부담의 금액과 그것을 낳은 상환 실패가 같은 경로에서 함께
나와야 하며, 둘 가운데 하나만 내는 경로로는 그 귀속이 서지 않는다.

**이 정의가 배제하는 사례:**
손상 판정이 체제에 따라 갈리는 자리. 역사적 원가에 손상을 붙인 실무 체제에서 그 판정이 유사 거래의
할인율로 이뤄지면 시가에 가까워지므로, 같은 상환 실패가 체제마다 다른 금액으로 장부에 서거나 서지
않는다. 이 명세는 어느 경로가 그 금액을 내는가만 받으며 그 금액을 정하는 체제를 받지 않는다
(Plantin · Sapra · Shin 2007).
조달처: E-16 §2-5 「장부가 평가익을 반영하지 않으니 실현하려고 판다」

**기각한 대체 정의:**
읽는 칸을 하나로 두는 안. 그 귀속이 금액과 상환 실패의 곱으로만 서므로 칸을 하나로 두면 어느 쪽이
빠져서 귀속이 서지 않는지가 구조에 남지 않는다. 두 부담의 가름을 읽는 칸을 두지 않는 안도 기각했다.
증거금 규범이 그 가름을 자기 문면으로 들고 그 문면이 공시 경로의 하나이므로, 그 칸을 빼면 규범이 드는
것과 수치가 내는 것이 같은 자리에서 맞대어지지 않는다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거이며 수를 들지 않는다.
-/
-- DD:CF-3936
structure LossTransmissionChannel (Party : Type) where
  /-- 그 경로가 보유자별 생존자 부담의 금액을 내는가. -/
  readsSurvivorLoss : Bool
  /-- 그 경로가 그 부담을 낳은 상환 실패를 의무자 단위로 내는가. -/
  readsObligorFailure : Bool
  /-- 그 경로가 두 부담의 가름을 문면으로 드는가. -/
  statesBearerSplit : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance
  deriving Repr

/--
witness (A-3).

**무엇을 증거하는가.** `LossTransmissionChannel` 이 비어 있지 않다. 세 칸을 하나도 내지 않는 경로이며
존재 정리는 이 값을 딛지 않는다.
-/
-- DD:CF-3936
def LossTransmissionChannel.noSource : LossTransmissionChannel Unit where
  readsSurvivorLoss := false
  readsObligorFailure := false
  statesBearerSplit := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 귀속을 답하는가.

**대응 비형식 개념:** 그 경로 하나로 어느 상환 실패가 어느 보유자의 자기자본을 줄였는지가 서는가.
금액과 상환 실패를 함께 내야 서므로 두 칸의 곱이다.

**이 정의가 배제하는 사례:**
두 경로를 맞대어 귀속을 복원하는 자리. 감독 보고가 의무자 단위를 내고 공시가 금액을 낼 때 그 둘을
맞대면 귀속이 설 수 있으나, 받는 쪽이 갈려 한쪽만 보는 관측자에게는 그 맞댐이 서지 않는다. 이 판정은
한 경로를 단위로 두며 경로 사이의 맞댐을 받지 않는다(BCBS · IOSCO 2020).
조달처: E-43 §2-5 「자본은 그 주체의 활동 전체가 공유한다」

**기각한 대체 정의:**
세 칸의 곱으로 두는 안. 두 부담의 가름을 문면으로 드는 것은 규범이 이미 하는 일이고 그것이 수치의
귀속을 세우지 않으므로, 그 칸을 곱에 넣으면 규범을 드는 경로가 귀속을 답하는 것으로 읽힌다. 합으로
두는 안도 기각했다. 합으로 두면 금액만 내는 경로가 귀속을 답하는 것이 되어 그 결손이 사라진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-3936
def LossTransmissionChannel.answersAttribution {Party : Type}
    (c : LossTransmissionChannel Party) : Bool :=
  c.readsSurvivorLoss && c.readsObligorFailure

/--
손상 공시의 경로.

**대응 비형식 개념:** 보유자가 자기 장부에서 인식한 손상을 공표하는 자리. 그 금액이 기간 합계로 나오고
그것을 낳은 개별 상환 실패가 그 자리에서 나오지 않는다.

**이 정의가 배제하는 사례:**
그 금액이 체제에 따라 서지 않는 자리. 손상을 붙이지 않은 역사적 원가 체제에서는 그 상환 실패가 장부에
금액으로 서지 않으므로, 같은 사건에서 이 경로가 아무 값도 내지 않는다. 이 값은 그 체제가 손상을 붙인
자리를 받으며 붙이지 않은 체제를 받지 않는다(Plantin · Sapra · Shin 2007).
조달처: E-16 §6 「역사적 원가에 손상(impairment)을 붙인 실무 체제에 대한 저자들의 예측」

**기각한 대체 정의:**
받는 쪽을 감독자로 두는 안. 손상이 재무제표의 자리이고 그 제표가 일반 독자에게 공표되므로 받는 쪽이
공개 독자다. 값의 성질을 추정으로 두는 안도 기각했다. 그 금액이 공표된 제표의 수치이고 작성자의 추정이
그 안에 들어 있더라도 그 경로가 내는 것은 공표된 보고다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거다.
-/
-- DD:CF-3936
def impairmentDisclosure : LossTransmissionChannel Unit where
  readsSurvivorLoss := true
  readsObligorFailure := false
  statesBearerSplit := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
증거금 규범이 드는 경로.

**대응 비형식 개념:** 규범이 두 부담의 가름을 자기 문면으로 드는 자리. 마진이 채무자 부담이고 자본이
생존자 부담이라는 것을 그 문면이 적으나 어느 보유자가 얼마를 졌는지는 적지 않는다.

**이 정의가 배제하는 사례:**
규범이 재는 손실이 실현된 손실이 아닌 자리. 개별 익스포저에 걸린 자본 요건이 상대방이 부도났을 때의
손실이 아니라 그 부도 확률로 가중된 손실을 덮도록 설계되어 있으므로, 그 문면이 드는 금액은 실현된
부담이 아니다. 이 값은 그 가름을 드는 칸만 참으로 두고 금액을 내는 두 칸을 거짓으로 둔다
(BCBS · IOSCO 2020).
조달처: E-43 §2-5 「부도 확률로 가중된 손실을 덮도록 설계되어 있다」

**기각한 대체 정의:**
이 경로를 목록에 두지 않는 안. 목록에 두지 않으면 규범이 그 가름을 드는 사실이 관측층에 서지 않고, 그
가름을 용어집이 등재한 근거가 어느 경로에도 닿지 않는다. 금액을 내는 칸을 참으로 두는 안도 기각했다.
그 규범이 드는 것은 요건의 산정 기준이고 실현된 부담의 금액이 아니다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거다.
-/
-- DD:CF-3936
def marginRequirementNorm : LossTransmissionChannel Unit where
  readsSurvivorLoss := false
  readsObligorFailure := false
  statesBearerSplit := true
  recipient := DisclosureRecipient.supervisor
  provenance := MeasurementProvenance.officialReport

/--
이 회차가 든 경로의 목록.

**대응 비형식 개념:** 손실 전달 사슬을 묻는 관측자가 가진 경로 전량. 이 목록이 전수라고 주장하지
않으며, 이 회차가 조달한 자리에서 나온 둘이다.

**이 정의가 배제하는 사례:**
목록 밖의 경로. 중앙은행이 담보 틀의 적격성 판정에서 쓰는 내부 자료가 그 부류이며, 그 자료가 공시로
나오지 않으므로 이 목록이 받지 않는다. 영란은행의 틀이 자기 공시가 불완전함을 문면으로 적는 것이 그
자리다(영란은행 2026).
조달처: E-49 §2-13 「그리고 정부보증 은행채 제도의 적격성이 재량으로 심사된다」

**기각한 대체 정의:**
전수라고 적는 안. 뭉치 밖의 경로를 이 회차가 조사하지 않았으므로 전수 주장을 세울 근거가 없다. 목록을
두지 않고 판정을 경로마다 따로 쓰는 안도 기각했다. 목록이 없으면 관측 결과를 내는 함수가 받을 변이
서지 않는다.

**수 체계를 받지 않는다.** 목록이 경로를 들며 수를 들지 않는다.
-/
-- DD:CF-3936
def lossTransmissionChannels : List (LossTransmissionChannel Unit) :=
  [impairmentDisclosure, marginRequirementNorm]

/--
그 목록에서 귀속이 관측되는가.

**대응 비형식 개념:** 가진 경로 가운데 하나라도 귀속을 답하면 관측이 서고, 하나도 답하지 않으면 측정
소스가 없어서 판정되지 않는다.

**이 정의가 배제하는 사례:**
판정되지 않는 까닭이 소스의 부재가 아닌 자리. 담보 계약의 두 양식이 신용보전금액을 한 식으로 두면서
법적 성질로 갈리므로 같은 사건의 판정이 법문에서 갈리는 자리가 있고, 그것은 소스의 부재가 아니라 법문의
모호다. 이 함수는 그 까닭을 내지 않고 소스의 부재만 낸다(ISDA 1995 · 1994).
조달처: E-43 §2-7 「둘 다 신용보전금액을 익스포저에 독립금액을 더하고 문턱을 뺀 값으로 두며, 음수가 되면 0 으로」

**기각한 대체 정의:**
거짓을 내는 안. 소스가 없다는 것과 그 명제가 거짓이라는 것이 다르고, 관측층이 그 둘을 가르는 열거를
이미 들고 있으므로 거짓을 내면 그 가름이 사라진다. 경로의 수를 받아 임계를 두는 안도 기각했다. 하나가
답하면 귀속이 서므로 임계가 하나보다 클 근거가 없다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-3936
def lossTransmissionObserved {Party : Type}
    (chs : List (LossTransmissionChannel Party)) : ObservedTruth :=
  if chs.any (fun c => c.answersAttribution) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
귀속 판정의 두 인자가 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 두 인자 가운데 하나만 참인 경로에서 그 판정이
참을 내는 것. 네 증인이 그 네 조합을 전부 들므로 그런 배치가 설 수 없고, 반증은 그 곱이 합으로 바뀐
구현에서만 온다.

**가정을 두지 않는다.** 증인이 네 조합을 자기 값으로 들고 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 논리 결합을 세우는 자리마다 각 인자가 홀로 값을 가르는 경로를
증거로 들라는 요구가 이 자리에 걸리고, 그 증거가 없으면 그 결합을 뒤집은 변이가 통과한다.
-/
-- DD:CF-3936
theorem loss_transmission_answer_pins_each_conjunct :
    ∃ c₁ c₂ c₃ c₄ : LossTransmissionChannel Unit,
      c₁.answersAttribution = true ∧ c₂.answersAttribution = false ∧
        c₃.answersAttribution = false ∧ c₄.answersAttribution = false ∧
          c₂.readsSurvivorLoss = true ∧ c₃.readsObligorFailure = true ∧
            c₄.readsSurvivorLoss = false ∧ c₄.readsObligorFailure = false := by
  -- 두 인자가 함께 참인 경로와 금액만 내는 손상 공시와 상환 실패만 내는 경로와 두 인자가 함께
  -- 거짓인 규범을 든다. 세 칸을 하나도 내지 않는 증거 인스턴스는 딛지 않는다. 칸마다 정의를
  -- 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨
    { readsSurvivorLoss := true, readsObligorFailure := true, statesBearerSplit := false,
      recipient := DisclosureRecipient.publicReader,
      provenance := MeasurementProvenance.officialReport },
    impairmentDisclosure,
    { readsSurvivorLoss := false, readsObligorFailure := true, statesBearerSplit := false,
      recipient := DisclosureRecipient.publicReader,
      provenance := MeasurementProvenance.officialReport },
    marginRequirementNorm,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
이 회차가 든 경로로는 귀속이 판정되지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 목록의 어느 경로가 금액과 상환 실패를 함께 내는
것. 손상 공시가 금액만 내고 규범이 가름만 드므로 그런 경로가 그 목록에 없고, 반증은 그 목록에 경로가
더해지는 회차에서 온다.

**가정을 두지 않는다.** 그 목록이 상수이므로 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 이 진술이 이 페이즈의 관측층 산출이며, 사슬의 귀속에 측정 소스가
없다는 것이 관측층에 등재되는 결손이다.
-/
-- DD:CF-3936
theorem loss_transmission_observed_undetermined :
    lossTransmissionObserved lossTransmissionChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

end CrisisFramework.Observation
