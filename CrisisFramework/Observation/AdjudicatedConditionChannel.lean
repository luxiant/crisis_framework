/-
관측층 — 판정 기관이 내리는 세 판정이 읽히는 경로

규율: L-14(값을 담지 않는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), T-2(반증 조건), T-3(분류), A-3(witness),
      A-8(논리 결합의 증거).

**값을 담지 않는다.** 이 파일은 어느 공시 경로가 무엇을 내는지의 명세만 담고 금액을 담지 않는다.
서류의 저촉과 판정자의 절차와 매수인의 회수할 권리에 측정 소스가 없다는 것이 이 파일의 산출이다.

**구조를 하나로 두고 판정을 셋으로 둔다.** 이 회차가 묻는 셋이 서로 다른 것을 묻되 전부 같은 결손을
내므로 구조를 셋으로 두면 받는 쪽과 값의 성질의 칸이 되풀이되고, 그 가름이 판정에 서면 어느 판정이
어느 물음에 답하는지가 선다. 앞 페이즈의 채널이 구조 하나에 판정 둘을 둔 것이 선례다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

/--
판정 기관이 내리는 세 판정의 공시 경로.

**대응 비형식 개념:** 서류끼리 저촉하는가와 판정자가 절차를 지켰는가와 매수인이 물건을 회수할 권리를
갖는가를 공표 수치에서 읽을 수 있는가. 앞의 둘은 그 판정과 그것이 딛는 재료가 같은 경로에서 함께
나와야 서고, 셋째는 판정 하나로 선다.

**이 정의가 배제하는 사례:**
신용장에 적혔으나 그 조건과의 일치를 나타낼 서류가 명시되지 않은 조건. 조문이 그런 조건을 기재되지
않은 것으로 보고 무시하므로 그 조건이 제시된 서류의 색인에 들지 않고, 이 명세는 어느 경로가 그 색인을
내는가만 받으며 문면에만 남은 조건을 받지 않는다.
조달처: E-21 §2-4 「은행은 그 조건을 기재되지 않은 것으로 보고 무시한다」

**기각한 대체 정의:**
판정의 칸만 두고 그것이 딛는 재료의 칸을 빼는 안. 저촉의 판정이 제시된 서류의 색인 없이는 어느 쌍에
대한 것인지가 서지 않고 실권의 판정이 통지의 시점과 하자 적시의 완전성 없이는 유도되지 않으므로, 그
칸을 빼면 판정만 내는 경로가 그 물음을 답하는 것으로 읽힌다. 세 물음마다 구조를 따로 세우는 안도
기각했다. 세 구조가 받는 쪽과 값의 성질의 칸에서 같아 그 꼴이 되풀이된다.

**수 체계를 받지 않는다.** 일곱 칸이 전부 판정과 열거이며 수를 들지 않는다.
-/
-- DD:CF-3988
structure AdjudicatedConditionChannel (Node : Type) where
  /-- 그 경로가 제시된 서류의 색인을 내는가. -/
  readsPresentedDocuments : Bool
  /-- 그 경로가 서류 쌍의 저촉 판정을 내는가. -/
  readsConflictRuling : Bool
  /-- 그 경로가 거절 통지의 시점을 내는가. -/
  readsNoticeTiming : Bool
  /-- 그 경로가 하자 적시의 완전성을 내는가. -/
  readsDefectCompleteness : Bool
  /-- 그 경로가 매수인의 회수할 권리에 대한 판정을 내는가. -/
  readsRecoveryRuling : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance
  deriving Repr

/--
witness (A-3).

**무엇을 증거하는가.** `AdjudicatedConditionChannel` 이 비어 있지 않다. 다섯 칸을 하나도 내지
않는 경로이며 존재 정리는 이 값을 딛지 않는다.
-/
-- DD:CF-3988
def AdjudicatedConditionChannel.noSource : AdjudicatedConditionChannel Unit where
  readsPresentedDocuments := false
  readsConflictRuling := false
  readsNoticeTiming := false
  readsDefectCompleteness := false
  readsRecoveryRuling := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 서류의 저촉을 답하는가.

**대응 비형식 개념:** 그 경로 하나로 낸 서류끼리 어긋났는지가 서는가. 제시된 서류의 색인과 그 쌍의
판정이 함께 나와야 서므로 두 칸의 곱이다.

**이 정의가 배제하는 사례:**
서류의 문언이 다르다는 것만 공표하는 경로. 조문이 서류상의 정보가 반드시 일치할 필요는 없다고 정하므로
다름이 곧 저촉이 아니고, 다름만 내는 경로는 그 판정을 내지 않는다.
조달처: E-21 §2-3 「서류상의 정보가 반드시 일치할 필요는 없으나」

**기각한 대체 정의:**
판정의 칸만 읽는 안. 그 판정이 어느 쌍에 대한 것인지가 제시된 서류의 색인 없이는 서지 않으므로, 칸
하나만 읽으면 색인을 내지 않는 경로가 그 물음을 답하는 것으로 읽힌다. 다섯 칸의 곱으로 두는 안도
기각했다. 통지의 시점과 하자 적시는 다른 물음에 속하고 그 칸을 곱에 넣으면 두 물음이 한 판정에 접힌다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-3988
def AdjudicatedConditionChannel.answersDocumentConflict {Node : Type}
    (c : AdjudicatedConditionChannel Node) : Bool :=
  c.readsPresentedDocuments && c.readsConflictRuling

/--
그 경로가 판정자의 실권을 답하는가.

**대응 비형식 개념:** 그 경로 하나로 그 은행이 그 조의 규정을 따랐는지가 서는가. 통지의 시점과 하자
적시의 완전성이 함께 나와야 서므로 두 칸의 곱이다.

**이 정의가 배제하는 사례:**
통지가 있었다는 사실만 공표하는 경로. 조문이 거절하려면 시한 안에 통지해야 하고 하자를 전부 적어야
한다고 함께 요구하므로, 통지의 유무만 내는 경로는 그 판정을 내지 않는다.
조달처: E-21 §2-7 「거절하려면 시한 안에 통지해야 하고 하자를 전부 적어야 하며」

**기각한 대체 정의:**
통지의 시점만 읽는 안. 시한 안에 통지했더라도 하자를 일부만 적었으면 실권이 서므로, 시점만 읽으면 그
자리가 재어지지 않는다. 그 둘을 합으로 두는 안도 기각했다. 합으로 두면 둘 가운데 하나만 내는 경로가 그
판정을 답하는 것이 되어 그 결손이 사라진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-3988
def AdjudicatedConditionChannel.answersExaminerPreclusion {Node : Type}
    (c : AdjudicatedConditionChannel Node) : Bool :=
  c.readsNoticeTiming && c.readsDefectCompleteness

/--
그 경로가 매수인의 회수할 권리를 답하는가.

**대응 비형식 개념:** 그 경로 하나로 매수인이 매도인으로부터 물건을 회수할 권리를 갖는지가 서는가. 그
판정을 내는 칸 하나가 그 답을 정하므로 칸을 그대로 읽는다.

**이 정의가 배제하는 사례:**
매수인이 물건을 받았는지만 공표하는 경로. 성문 규범이 그 자격의 축을 점유의 취득이나 회수할 권리로
두므로 점유만 내는 경로는 그 권리를 내지 않는다.
조달처: E-66 §2-7 「점유를 취득했거나 제2편에 따라 매도인으로부터 물건을 회수할 권리를 가져야 하며」

**기각한 대체 정의:**
점유의 칸을 곱에 넣는 안. 점유는 앞 페이즈의 구조가 담는 상태이고 그 권리는 점유가 없는 자리에서 서는
것이므로, 곱에 넣으면 그 권리만 선 자리가 거짓으로 선다. 그 권리를 저촉의 판정과 한 칸으로 묶는 안도
기각했다. 두 판정이 서로 다른 규범에서 오고 색인도 서류의 쌍과 인도로 갈린다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-3988
def AdjudicatedConditionChannel.answersRecoveryRight {Node : Type}
    (c : AdjudicatedConditionChannel Node) : Bool :=
  c.readsRecoveryRuling

/--
개설된 신용장의 조건 문면.

**대응 비형식 개념:** 개설은행이 신용장을 열면서 그 조건과 요구 서류를 적는 자리. 무엇을 내야 하는지는
서고 낸 것끼리 어긋났는지는 서지 않는다.

**이 정의가 배제하는 사례:**
서류 아닌 조건이 그 문면에 적힌 자리. 조문이 그런 조건을 기재되지 않은 것으로 보고 무시하므로 그것이
요구된 서류의 색인에 서지 않으며, 이 경로가 내는 것은 서류로 나타낼 수 있는 조건에 그친다.
조달처: E-21 §2-4 「은행은 그 조건을 기재되지 않은 것으로 보고 무시한다」

**기각한 대체 정의:**
저촉 판정의 칸을 참으로 두는 안. 그 문면이 개설 시점에 서고 저촉은 제시가 있어야 판정되므로, 참으로
두면 아직 일어나지 않은 판정을 그 문면이 내는 것으로 읽힌다. 받는 쪽을 공개 독자로 두는 안도 기각했다.
그 문면이 수익자와 개설의뢰인에게 가고 공표되지 않는다.

**수 체계를 받지 않는다.** 일곱 칸이 전부 판정과 열거다.
-/
-- DD:CF-3988
def issuedCreditTerms : AdjudicatedConditionChannel Unit where
  readsPresentedDocuments := true
  readsConflictRuling := false
  readsNoticeTiming := false
  readsDefectCompleteness := false
  readsRecoveryRuling := false
  recipient := DisclosureRecipient.investor
  provenance := MeasurementProvenance.officialReport

/--
담보물의 처분을 다투는 재판의 기록.

**대응 비형식 개념:** 담보권이 끊겼는지를 다투어 법원이 판정을 내리고 그 판정이 기록으로 남는 자리.
다툰 건에 대해서만 서고 다투지 않은 건에 대해서는 서지 않는다.

**이 정의가 배제하는 사례:**
담보권자가 물건을 쥐고 있어 끊김이 처음부터 막힌 자리. 같은 규범이 담보권자의 점유를 끊김을 막는
조건으로 두므로 그 배치에서는 다툼이 서지 않고, 그래서 이 경로가 그 자리의 회수할 권리를 내지 않는다.
조달처: E-66 §3-2 「그 귀결로 끊김은 담보물이 담보권자의 손을 떠나 있을 때에만 선다」

**기각한 대체 정의:**
회수할 권리의 칸을 참으로 두는 안. 그 기록이 다툰 건에 대해서만 서고 끊김의 판정이 요구하는 것은 그
인도마다의 권리이므로, 참으로 두면 다투지 않은 인도의 권리가 그 기록에서 나오는 것으로 읽힌다. 값의
성질을 공표된 보고로 두는 안도 기각했다. 그 기록이 법원의 판정이고 공시 주체가 내는 보고가 아니다.

**수 체계를 받지 않는다.** 일곱 칸이 전부 판정과 열거다.
-/
-- DD:CF-3988
def collateralDisputeRecord : AdjudicatedConditionChannel Unit where
  readsPresentedDocuments := false
  readsConflictRuling := false
  readsNoticeTiming := false
  readsDefectCompleteness := false
  readsRecoveryRuling := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.staffEstimate

/--
이 회차가 든 경로의 목록.

**대응 비형식 개념:** 세 물음을 묻는 관측자가 가진 경로 전량. 이 목록이 전수라고 주장하지 않으며, 이
회차가 조달한 자리에서 나온 둘이다.

**이 정의가 배제하는 사례:**
목록 밖의 경로. 서류 아닌 조건을 개설은행이 심사하게 바꾼 약정이 보증채무로 취급된 자리가 그 부류이며,
그 약정의 문면이 이 회차의 조달에 들지 않으므로 이 목록이 받지 않는다.
조달처: E-21 §2-4 「은행은 그 조건을 기재되지 않은 것으로 보고 무시한다」

**기각한 대체 정의:**
전수라고 적는 안. 뭉치 밖의 경로를 이 회차가 조사하지 않았으므로 전수 주장을 세울 근거가 없다. 목록을
두지 않고 판정을 경로마다 따로 쓰는 안도 기각했다. 목록이 없으면 관측 결과를 내는 함수가 받을 변이
서지 않는다.

**수 체계를 받지 않는다.** 목록이 경로를 들며 수를 들지 않는다.
-/
-- DD:CF-3988
def adjudicatedConditionChannels : List (AdjudicatedConditionChannel Unit) :=
  [issuedCreditTerms, collateralDisputeRecord]

/--
그 목록에서 서류의 저촉이 관측되는가.

**대응 비형식 개념:** 가진 경로 가운데 하나라도 그 판정과 그 색인을 함께 내면 관측이 서고, 하나도
내지 않으면 측정 소스가 없어서 판정되지 않는다.

**이 정의가 배제하는 사례:**
판정되지 않는 까닭이 소스의 부재가 아닌 자리. 그 판정의 기준이 계약 문면 밖의 관행에 있어 그 기준의
문면이 조달되지 않은 것은 조달의 결손이며, 이 함수는 그 까닭을 내지 않고 소스의 부재만 낸다.
조달처: E-21 §3-2 「비교되는 것은 값이 아니라 문언이며 비교의 기준이 계약 밖에 있다」

**기각한 대체 정의:**
거짓을 내는 안. 소스가 없다는 것과 그 명제가 거짓이라는 것이 다르고, 관측층이 그 둘을 가르는 열거를
이미 들고 있으므로 거짓을 내면 그 가름이 사라진다. 까닭을 구조의 부재로 두는 안도 기각했다. 이 회차가
그 판정을 받는 구조를 세웠으므로 구조에 대상이 있고, 없는 것은 그 판정을 내는 경로다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-3988
def documentConflictObserved {Node : Type}
    (chs : List (AdjudicatedConditionChannel Node)) : ObservedTruth :=
  if chs.any (fun c => c.answersDocumentConflict) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
그 목록에서 판정자의 실권이 관측되는가.

**대응 비형식 개념:** 가진 경로 가운데 하나라도 통지의 시점과 하자 적시의 완전성을 함께 내면 관측이
서고, 하나도 내지 않으면 측정 소스가 없어서 판정되지 않는다.

**이 정의가 배제하는 사례:**
그 통지가 제시인에게만 가고 공표되지 않는 자리. 조문이 그 통지를 제시인에게 하도록 요구할 뿐 공표를
요구하지 않으므로 그 시점과 내용이 당사자 사이에만 서며, 이 함수는 그것을 내는 경로가 목록에 있는지만
받는다.
조달처: E-21 §2-7 「거절하려면 시한 안에 통지해야 하고 하자를 전부 적어야 하며」

**기각한 대체 정의:**
그 통지를 경로로 세우는 안. 공시 경로는 관측자가 밖에서 읽는 자리이고 그 통지는 당사자 사이의 문면
이므로, 경로로 세우면 관측자가 갖지 않는 것을 가진 것으로 읽힌다. 거짓을 내는 안도 기각했다. 소스가
없다는 것과 그 명제가 거짓이라는 것이 다르다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-3988
def examinerPreclusionObserved {Node : Type}
    (chs : List (AdjudicatedConditionChannel Node)) : ObservedTruth :=
  if chs.any (fun c => c.answersExaminerPreclusion) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
그 목록에서 매수인의 회수할 권리가 관측되는가.

**대응 비형식 개념:** 가진 경로 가운데 하나라도 그 판정을 내면 관측이 서고, 하나도 내지 않으면 측정
소스가 없어서 판정되지 않는다.

**이 정의가 배제하는 사례:**
그 권리가 다툼이 선 뒤에야 판정되는 자리. 같은 규범이 매수인의 자격을 다섯 축으로 들고 그 가운데 선의와
통상의 과정이 분쟁이 서야 법원이 내리는 판정이므로, 다투지 않은 인도에 대해서는 그 판정 자체가 서지
않는다. 이 함수는 그 까닭을 내지 않고 소스의 부재만 낸다.
조달처: E-66 §2-7 「점유를 취득했거나 제2편에 따라 매도인으로부터 물건을 회수할 권리를 가져야 하며」

**기각한 대체 정의:**
점유의 관측으로 그것을 대신하는 안. 그 권리가 점유가 없는 자리에서 서는 것이므로 점유의 관측으로는 그
자리가 재어지지 않는다. 다툼의 기록이 그 판정을 낸다고 두는 안도 기각했다. 그 기록이 다툰 건에 대해서만
서고 끊김의 판정이 요구하는 것은 인도마다의 권리다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-3988
def recoveryRightObserved {Node : Type}
    (chs : List (AdjudicatedConditionChannel Node)) : ObservedTruth :=
  if chs.any (fun c => c.answersRecoveryRight) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
저촉 판정의 두 인자가 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 두 인자 가운데 하나만 참인 경로에서 그 판정이 참을
내는 것. 네 증인이 그 네 조합을 전부 들므로 그런 배치가 설 수 없고, 반증은 그 곱이 합으로 바뀐
구현에서만 온다.

**가정을 두지 않는다.** 증인이 네 조합을 자기 값으로 들고 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 논리 결합을 세우는 자리마다 각 인자가 홀로 값을 가르는 경로를 증거로
들라는 요구가 이 자리에 걸리고, 그 증거가 없으면 그 결합을 뒤집은 변이가 통과한다.
-/
-- DD:CF-3988
theorem document_conflict_answer_pins_each_conjunct :
    ∃ c₁ c₂ c₃ c₄ : AdjudicatedConditionChannel Unit,
      c₁.answersDocumentConflict = true ∧ c₂.answersDocumentConflict = false ∧
        c₃.answersDocumentConflict = false ∧ c₄.answersDocumentConflict = false ∧
          c₂.readsPresentedDocuments = true ∧ c₃.readsConflictRuling = true ∧
            c₄.readsPresentedDocuments = false ∧ c₄.readsConflictRuling = false := by
  -- 두 인자가 함께 참인 경로와 색인만 내는 경로와 판정만 내는 경로와 두 인자가 함께 거짓인
  -- 다툼의 기록을 든다. 증거 인스턴스 `AdjudicatedConditionChannel.noSource` 는 딛지 않는다.
  -- 칸마다 정의를 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨
    { readsPresentedDocuments := true, readsConflictRuling := true, readsNoticeTiming := false,
      readsDefectCompleteness := false, readsRecoveryRuling := false,
      recipient := DisclosureRecipient.investor,
      provenance := MeasurementProvenance.officialReport },
    issuedCreditTerms,
    { readsPresentedDocuments := false, readsConflictRuling := true, readsNoticeTiming := false,
      readsDefectCompleteness := false, readsRecoveryRuling := false,
      recipient := DisclosureRecipient.investor,
      provenance := MeasurementProvenance.officialReport },
    collateralDisputeRecord,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
실권 판정의 두 인자가 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 두 인자 가운데 하나만 참인 경로에서 그 판정이 참을
내는 것. 네 증인이 그 네 조합을 전부 들므로 그런 배치가 설 수 없고, 반증은 그 곱이 합으로 바뀐
구현에서만 온다.

**가정을 두지 않는다.** 증인이 네 조합을 자기 값으로 들고 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 조문이 통지의 시한과 하자 적시를 함께 요구하는 것이 이 판정에서
실제로 걸리는지를 드는 자리이고, 그 증거가 없으면 그 결합을 뒤집은 변이가 통과한다.
-/
-- DD:CF-3988
theorem examiner_preclusion_answer_pins_each_conjunct :
    ∃ c₁ c₂ c₃ c₄ : AdjudicatedConditionChannel Unit,
      c₁.answersExaminerPreclusion = true ∧ c₂.answersExaminerPreclusion = false ∧
        c₃.answersExaminerPreclusion = false ∧ c₄.answersExaminerPreclusion = false ∧
          c₂.readsNoticeTiming = true ∧ c₃.readsDefectCompleteness = true ∧
            c₄.readsNoticeTiming = false ∧ c₄.readsDefectCompleteness = false := by
  -- 두 인자가 함께 참인 경로와 통지의 시점만 내는 경로와 하자 적시만 내는 경로와 두 인자가 함께
  -- 거짓인 신용장의 조건 문면을 든다. 증거 인스턴스 `AdjudicatedConditionChannel.noSource` 는
  -- 딛지 않는다. 칸마다 정의를 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨
    { readsPresentedDocuments := false, readsConflictRuling := false, readsNoticeTiming := true,
      readsDefectCompleteness := true, readsRecoveryRuling := false,
      recipient := DisclosureRecipient.investor,
      provenance := MeasurementProvenance.officialReport },
    { readsPresentedDocuments := false, readsConflictRuling := false, readsNoticeTiming := true,
      readsDefectCompleteness := false, readsRecoveryRuling := false,
      recipient := DisclosureRecipient.investor,
      provenance := MeasurementProvenance.officialReport },
    { readsPresentedDocuments := false, readsConflictRuling := false, readsNoticeTiming := false,
      readsDefectCompleteness := true, readsRecoveryRuling := false,
      recipient := DisclosureRecipient.investor,
      provenance := MeasurementProvenance.officialReport },
    issuedCreditTerms,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
이 회차가 든 경로로는 서류의 저촉이 판정되지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 목록의 어느 경로가 제시된 서류의 색인과 그 쌍의
판정을 함께 내는 것. 신용장의 조건 문면이 색인만 내고 다툼의 기록이 둘 다 내지 않으므로 그런 경로가 그
목록에 없고, 반증은 그 목록에 경로가 더해지는 회차에서 온다.

**가정을 두지 않는다.** 그 목록이 상수이므로 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 이 진술이 이 페이즈의 관측층 산출 가운데 하나이며, 저촉의 판정에
측정 소스가 없다는 것이 관측층에 등재되는 결손이다.
-/
-- DD:CF-3988
theorem document_conflict_observed_undetermined :
    documentConflictObserved adjudicatedConditionChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
이 회차가 든 경로로는 판정자의 실권이 판정되지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 목록의 어느 경로가 통지의 시점과 하자 적시의
완전성을 함께 내는 것. 두 경로가 그 둘을 하나도 내지 않으므로 그런 경로가 그 목록에 없고, 반증은 그
목록에 경로가 더해지는 회차에서 온다.

**가정을 두지 않는다.** 그 목록이 상수이므로 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 이 진술이 이 페이즈의 관측층 산출 가운데 하나이며, 조문이 효과를
정한 절차가 밖에서 읽히지 않는다는 것이 관측층에 등재되는 결손이다.
-/
-- DD:CF-3988
theorem examiner_preclusion_observed_undetermined :
    examinerPreclusionObserved adjudicatedConditionChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
이 회차가 든 경로로는 매수인의 회수할 권리가 판정되지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 목록의 어느 경로가 그 판정을 내는 것. 신용장의
조건 문면이 담보물의 처분을 다루지 않고 다툼의 기록이 다툰 건에 대해서만 서므로 그런 경로가 그 목록에
없고, 반증은 그 목록에 경로가 더해지는 회차에서 온다.

**가정을 두지 않는다.** 그 목록이 상수이므로 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 이 진술이 이 페이즈의 관측층 산출 가운데 하나이며, 자격의 논리합
가운데 뒤의 몫에 측정 소스가 없다는 것이 관측층에 등재되는 결손이다.
-/
-- DD:CF-3988
theorem recovery_right_observed_undetermined :
    recoveryRightObserved adjudicatedConditionChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

end CrisisFramework.Observation
