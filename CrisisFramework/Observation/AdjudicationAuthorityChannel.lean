/-
관측층 — 준거와 조건변경의 세 판정이 읽히는 경로

규율: L-14(값을 담지 않는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), T-2(반증 조건), T-3(분류), A-3(witness),
      A-8(논리 결합의 증거).

**값을 담지 않는다.** 이 파일은 어느 공시 경로가 무엇을 내는지의 명세만 담고 금액을 담지 않는다.
신용장이 어느 조항을 명시로 배제했는가와 기초 계약의 준거법 아래의 판정과 제시가 조건변경의 조항에
부합했는가에 측정 소스가 없다는 것이 이 파일의 산출이다.

**구조를 하나로 두고 판정을 셋으로 둔다.** 이 회차가 묻는 셋이 서로 다른 것을 묻되 전부 같은 결손을
내므로 구조를 셋으로 두면 받는 쪽과 값의 성질의 칸이 되풀이되고, 그 가름이 판정에 서면 어느 판정이
어느 물음에 답하는지가 선다. 앞 페이즈의 채널이 구조 하나에 판정 셋을 둔 것이 선례다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

/--
준거와 조건변경의 세 판정의 공시 경로.

**대응 비형식 개념:** 신용장이 어느 조항을 명시로 배제했는가와 기초 계약의 준거법이 같은 사건을 어떻게
판정하는가와 제시가 조건변경의 조항에 부합했는가를 공표 수치에서 읽을 수 있는가. 셋이 전부 당사자
사이에만 서거나 분쟁이 서야 내려진다.

**이 정의가 배제하는 사례:**
전신 규약의 메시지가 그 경로가 된다는 읽기. 그 규약의 신용장 메시지가 통화와 금액을 필수 항목으로
강제하고 품목을 선택 항목의 자유 서술로 두므로, 어느 조항을 배제했는지는 그 메시지의 어느 항목도
구조화해 담지 않는다.
조달처: E-42 §2-4 「45A 가 물품과 용역의 서술을 담는다」

**기각한 대체 정의:**
경로의 이름만 담고 무엇에 답하는지를 담지 않는 안. 그러면 소스 없음이 무엇에 대한 없음인지가 서지
않아 관측층에 등재되는 소스 없음이 산출로 읽히지 않는다.

**수 체계를 받지 않는다.** 네 칸이 전부 판정과 열거이며 수를 들지 않는다.
-/
-- DD:CF-4026
structure AdjudicationAuthorityChannel (Node : Type) where
  /-- 그 경로를 내는 쪽. -/
  publisher : Node
  /-- 신용장이 어느 조항을 명시로 배제했는가를 그 경로가 내는가. -/
  showsAuthorityExclusion : Bool
  /-- 기초 계약의 준거법 아래의 판정을 그 경로가 내는가. -/
  showsContractLawVerdict : Bool
  /-- 제시가 조건변경의 조항에 부합했는가를 그 경로가 내는가. -/
  showsAmendmentConformity : Bool

/-- witness (A-3). **무엇을 증거하는가.** `AdjudicationAuthorityChannel` 이 비어 있지 않다.
어느 칸도 내지 않는 경로 하나를 든다. -/
-- DD:CF-4026
def AdjudicationAuthorityChannel.noSource : AdjudicationAuthorityChannel Unit where
  publisher := ()
  showsAuthorityExclusion := false
  showsContractLawVerdict := false
  showsAmendmentConformity := false

/--
그 경로가 조항의 명시한 배제를 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 신용장이 어느 조항을 배제했는지를 말할 수 있는가.

**이 정의가 배제하는 사례:**
신용장의 금액 항목이 그 답을 준다는 읽기. 그 규약이 금액을 필수 항목으로 강제하면서 조항의 배제를
담는 항목을 두지 않으므로, 금액이 서 있다는 것이 배제의 유무를 말해 주지 않는다.
조달처: E-42 §2-2 「32B 가 통화 코드와 금액을 함께 담고 필수다」

**기각한 대체 정의:**
답함을 세 칸의 논리합으로 두는 안. 그러면 다른 물음에 답하는 경로가 이 물음에도 답하는 것으로 세어진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4026
def AdjudicationAuthorityChannel.answersAuthorityExclusion {Node : Type}
    (C : AdjudicationAuthorityChannel Node) : Bool :=
  C.showsAuthorityExclusion

/--
그 경로가 기초 계약의 준거법 아래의 판정을 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 같은 선적이 계약 위반인지를 말할 수 있는가.

**이 정의가 배제하는 사례:**
신용장의 서류 심사 결과가 그 답을 준다는 읽기. 예비 고찰이 신용장과 그 계약을 독립으로 두므로 한쪽의
판정이 다른 쪽의 판정을 말해 주지 않는다.
조달처: E-67 §2-3 「기초가 되는 매매 또는 다른 계약과 독립」

**기각한 대체 정의:**
그 판정을 신용장의 세 층 옆의 넷째 층으로 두고 같은 경로가 내게 하는 안. 그러면 두 묶음 사이에
서열이 서는 것으로 읽혀 그 규범이 독립이라고 적은 것을 구조가 바꾼다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4026
def AdjudicationAuthorityChannel.answersContractLawVerdict {Node : Type}
    (C : AdjudicationAuthorityChannel Node) : Bool :=
  C.showsContractLawVerdict

/--
그 경로가 조건변경에 대한 부합을 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 어느 제시가 조건변경의 조항에 부합했는지를 말할 수 있는가.

**이 정의가 배제하는 사례:**
조건변경의 통지문이 그 답을 준다는 읽기. 그 조문이 통지가 없더라도 부합하는 제시가 있으면 수락한
것으로 간주하므로, 통지문은 변경의 문면을 내고 부합의 유무를 내지 않는다.
조달처: E-21 §2-8 「변경 내용에 부합하는 제시가 있으면 수락한 것으로 간주」

**기각한 대체 정의:**
부합을 서류의 심사 결과와 같은 칸으로 두는 안. 심사 결과는 신용장의 그때 조항에 대한 것이고 이
물음은 변경의 조항에 대한 것이어서 두 칸이 같은 것을 묻지 않는다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4026
def AdjudicationAuthorityChannel.answersAmendmentConformity {Node : Type}
    (C : AdjudicationAuthorityChannel Node) : Bool :=
  C.showsAmendmentConformity

/--
조건변경의 통지문.

**대응 비형식 개념:** 개설은행이 조건변경을 통지하면서 내는 문면. 변경의 내용은 거기 서나 그 변경이
수락됐는지는 거기 서지 않는다.

**이 정의가 배제하는 사례:**
그 통지문이 수락의 유무를 낸다는 읽기. 그 조문이 수익자의 통지를 요구하면서도 통지 없는 간주를
함께 두므로, 통지문에 수락이 적혀 있지 않은 것이 수락이 없다는 뜻이 아니다.
조달처: E-21 §2-8 「변경 내용에 부합하는 제시가 있으면 수락한 것으로 간주」

**기각한 대체 정의:**
조건변경에 대한 부합의 칸을 참으로 두는 안. 그 통지문이 변경의 내용을 담고 그 뒤의 제시가 부합했는지는
담지 않으므로, 참으로 두면 아직 일어나지 않은 판정을 그 문면이 내는 것으로 읽힌다. 이 경로를 목록에서
빼는 안도 기각했다. 칸이 전부 거짓인 경로가 목록에 서는 것이 그 물음에 답하는 자리가 없다는 관측을
드는 유일한 꼴이다.

**수 체계를 받지 않는다.** 네 칸이 전부 판정과 열거다.
-/
-- DD:CF-4026
def advisedAmendmentNotice : AdjudicationAuthorityChannel Unit where
  publisher := ()
  showsAuthorityExclusion := false
  showsContractLawVerdict := false
  showsAmendmentConformity := false

/--
분쟁의 판정 기록.

**대응 비형식 개념:** 분쟁이 서서 법원이나 중재가 내린 판정이 남는 기록. 기초 계약의 준거법 아래의
판정이 거기 서나 공표 수치로 집계되지 않는다.

**이 정의가 배제하는 사례:**
그 기록이 신용장의 조항 배제를 낸다는 읽기. 분쟁이 선 사건에 대해서만 기록이 서므로 분쟁이 서지
않은 신용장의 배제는 그 기록에 들지 않는다.
조달처: E-67 §2-2 「명시로 고치거나 배제하지 않는 한에서」

**기각한 대체 정의:**
세 칸을 전부 참으로 두는 안. 그 기록이 다툰 건에 대해서만 서고 조항의 배제와 조건변경의 부합은 다툼이
없는 건에서도 물어지므로, 참으로 두면 다투지 않은 건의 판정이 그 기록에서 나오는 것으로 읽힌다. 이
경로를 목록에서 빼는 안도 기각했다. 그 기록이 기초 계약의 준거법 아래의 판정을 실제로 내므로 빼면 세
물음이 전부 소스 없음으로 접히고 그 가름이 사라진다.

**수 체계를 받지 않는다.** 네 칸이 전부 판정과 열거다.
-/
-- DD:CF-4026
def arbitralAwardRecord : AdjudicationAuthorityChannel Unit where
  publisher := ()
  showsAuthorityExclusion := false
  showsContractLawVerdict := true
  showsAmendmentConformity := false

/--
이 회차가 든 경로의 목록.

**대응 비형식 개념:** 세 판정을 낼 수 있을 법한 경로를 모은 것.

**이 정의가 배제하는 사례:**
전신 규약의 신용장 메시지를 이 목록에 넣는 읽기. 그 메시지는 통화와 금액을 내고 세 판정 가운데
어느 것도 내지 않으므로, 넣으면 목록이 답하지 않는 경로로 불어난다.
조달처: E-42 §2-4 「45A 가 물품과 용역의 서술을 담는다」

**기각한 대체 정의:**
목록을 판정마다 따로 두는 안. 그러면 한 경로가 여러 목록에 들고 그 중복이 관측 결과의 계산에서
되풀이되며, 경로를 더하는 회차가 어느 목록에 더할지를 매번 고르게 된다.

**수 체계를 받지 않는다.** 목록이 경로를 들며 수를 들지 않는다.
-/
-- DD:CF-4026
def adjudicationAuthorityChannels : List (AdjudicationAuthorityChannel Unit) :=
  [advisedAmendmentNotice, arbitralAwardRecord]

/--
조항의 명시한 배제가 어느 경로에서도 관측되지 않는다.

**대응 비형식 개념:** 그 목록의 어느 경로도 그 물음에 답하지 않는 것.

**이 정의가 배제하는 사례:**
한 경로라도 답하면 관측된 것으로 보는 읽기. 이 물음은 그 목록 전체에 대한 것이고 한 경로의 성질이
아니므로, 경로 하나로 판정하면 목록의 나머지가 읽히지 않는다.
조달처: E-67 §2-2 「명시로 고치거나 배제하지 않는 한에서」

**기각한 대체 정의:**
참거짓을 내는 안. 소스가 없다는 것과 그 명제가 거짓이라는 것이 다르므로 판정 불가의 칸이 따로
필요하며, 삼분을 드는 열거가 그 칸을 받는다. 그 까닭을 측정 소스의 부재가 아닌 쪽으로 세분해 드는
안도 기각했다. 이 자리의 결손이 전부 그 부재이고 다른 까닭이 서지 않는다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4026
def authorityExclusionObserved {Node : Type}
    (chs : List (AdjudicationAuthorityChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersAuthorityExclusion) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
기초 계약의 준거법 아래의 판정이 어느 경로에서 관측되는가.

**대응 비형식 개념:** 그 목록의 어느 경로가 그 물음에 답하는 것.

**이 정의가 배제하는 사례:**
그 판정이 어디서도 관측되지 않는다고 보는 읽기. 분쟁의 판정 기록이 그 판정을 들므로 그 물음은
소스가 없는 것이 아니라 집계되지 않는 것이다.
조달처: E-67 §4-2 「다른 쪽에서 계약 위반인 것은 제도가 끊어 놓은 결과다」

**기각한 대체 정의:**
참거짓을 내는 안. 한 파일의 세 판정이 한 꼴을 써야 그 결손이 한 기준에서 읽히고, 이 판정만
참거짓으로 두면 소스가 있는 자리와 없는 자리가 다른 타입으로 갈린다. 이 판정도 소스 없음으로 두는
안도 기각했다. 분쟁의 판정 기록이 그것을 들므로 소스가 없는 것이 아니라 집계되지 않는 것이다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4026
def contractLawVerdictObserved {Node : Type}
    (chs : List (AdjudicationAuthorityChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersContractLawVerdict) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
조건변경에 대한 부합이 어느 경로에서도 관측되지 않는다.

**대응 비형식 개념:** 그 목록의 어느 경로도 그 물음에 답하지 않는 것.

**이 정의가 배제하는 사례:**
조건변경의 통지문이 그 답을 준다고 보는 읽기. 그 조문이 통지 없는 간주를 두므로 통지문이 부합의
유무를 내지 않는다.
조달처: E-21 §2-8 「변경 내용에 부합하는 제시가 있으면 수락한 것으로 간주」

**기각한 대체 정의:**
참거짓을 내는 안. 소스가 없다는 것과 그 명제가 거짓이라는 것이 다르다. 그 까닭을 구조가 그 대상을
담지 않는 쪽으로 두는 안도 기각했다. 이 회차가 그 부합을 구조의 칸으로 담았으므로 결손이 구조의
결손이 아니라 소스의 결손이다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4026
def amendmentConformityObserved {Node : Type}
    (chs : List (AdjudicationAuthorityChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersAmendmentConformity) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
조항의 명시한 배제에 측정 소스가 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 회차가 든 경로 가운데 하나가 신용장의 조항 배제를 내야 한다. 그 관측은 그 배제가 공표되는 자리가
있다는 뜻이며, 그러면 관측층이 그 소스를 명세로 들 수 있다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 이 프레임워크의 주요 산출 가운데 하나이고, 그
없음이 이 구조에서 실제로 서는지를 드는 유일한 자리다.
-/
-- DD:CF-4026
theorem authority_exclusion_observed_undetermined :
    authorityExclusionObserved adjudicationAuthorityChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
조건변경에 대한 부합에 측정 소스가 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 회차가 든 경로 가운데 하나가 그 부합을 내야 한다. 그 관측은 통지 없는 간주가 공표되는 자리가
있다는 뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 없음이 이 구조에서 실제로 서는지를 드는 유일한 자리다.
-/
-- DD:CF-4026
theorem amendment_conformity_observed_undetermined :
    amendmentConformityObserved adjudicationAuthorityChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
기초 계약의 준거법 아래의 판정은 한 경로에서 관측된다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
분쟁의 판정 기록이 그 판정을 내지 않아야 한다. 그 관측은 그 판정이 어디에도 남지 않는다는 뜻이며,
그러면 세 물음이 같은 결손을 내어 판정을 셋으로 가른 것이 값을 잃는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 세 물음이 같은 결손을 내지 않는다는 것을 드는 유일한 자리이고, 그 가름이
없으면 이 파일이 소스 없음을 세 번 되풀이한 것이 된다.
-/
-- DD:CF-4026
theorem contract_law_verdict_observed_determined :
    contractLawVerdictObserved adjudicationAuthorityChannels = ObservedTruth.holds := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
세 답함이 각 칸에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 답함이 자기 칸이 아닌 칸을 읽어야 한다. 그 관측은 세 답함이 같은 칸을 읽는다는 뜻이며, 그러면
판정을 셋으로 가른 것이 이름만 다른 셋이 된다.

**존재 형태로 진술하는 까닭(T-6):**
칸마다 그 하나만 참인 경로를 들어야 보인다. 임의의 경로에서 각 칸이 홀로 가르는 것이 아니라
나머지가 거짓인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 답함의 정의를 전개하면 증명이 닫히므로 기여 목록에 들지 않는다.
-/
-- DD:CF-4026
theorem channel_answers_pin_each_field :
    ∃ (C₁ C₂ C₃ : AdjudicationAuthorityChannel Unit),
      C₁.answersAuthorityExclusion = true ∧
      C₁.answersContractLawVerdict = false ∧ C₁.answersAmendmentConformity = false ∧
      C₂.answersAuthorityExclusion = false ∧
      C₂.answersContractLawVerdict = true ∧ C₂.answersAmendmentConformity = false ∧
      C₃.answersAuthorityExclusion = false ∧
      C₃.answersContractLawVerdict = false ∧ C₃.answersAmendmentConformity = true := by
  -- 칸마다 하나만 참인 경로 셋을 든다. 답함이 자기 칸을 그대로 읽으므로 칸마다 계산하면 값이
  -- 나와 `rfl` 로 닫힌다.
  exact ⟨⟨(), true, false, false⟩, ⟨(), false, true, false⟩, ⟨(), false, false, true⟩,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Observation
