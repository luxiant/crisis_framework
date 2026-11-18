/-
관측층 — 신용장과 서류의 문면에서 읽히는 네 물음

규율: L-14(값을 담지 않는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), T-2(반증 조건), T-3(분류), A-3(witness),
      A-8(논리 결합의 증거).

**값을 담지 않는다.** 이 파일은 어느 공시 경로가 무엇을 내는지의 명세만 담고 금액을 담지 않는다.
어느 서류 쌍의 차이가 어느 갈래에 드는지와 아래층의 정의가 그 평문을 무르게 하는지와 비서류적 조건의
충족을 보일 서류가 정해졌는지에 소스가 없다는 것이 이 파일의 산출이다.

**판정 불가의 까닭이 둘로 갈린다.** 갈래의 소속과 요건의 지위는 그 값을 내는 공시 경로가 없는 것이므로
측정 소스 없음을 들고, 무르게 함은 그 규칙의 문면이 간행되어 있는데도 그 정의가 이 조항을 무르게
하는지가 두 문면을 함께 읽는 일이므로 법문 모호를 든다. 소스가 없는 것과 문면이 있는데 읽기가 갈리는
것이 다른 막힘이다.

**저촉 기준의 지위는 관측된다.** 은행이 거절하려면 하자를 전부 적어야 하므로 비서류적 조건이 가리키는
자료가 어긋난 자리는 그 통지에 하자로 서며, 그 요건의 지위와 저촉 기준의 지위가 한 축이 아니라는 것이
이 파일의 가름이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

/--
신용장과 서류의 문면에 걸린 네 물음의 공시 경로.

**대응 비형식 개념:** 어느 서류 쌍의 차이가 저촉이 아닌 차이의 어느 갈래에 드는가와, 아래층의 정의가
그 평문을 무르게 하는가와, 비서류적 조건의 충족을 보일 서류가 정해졌는가와, 그 조건이 가리키는 자료가
어긋났는가를 공표 수치에서 읽을 수 있는가.

**이 정의가 배제하는 사례:**
서류의 심사 결과 하나가 네 물음에 함께 답한다는 읽기. 그 규칙이 거절하려면 시한 안에 통지하고 하자를
전부 적어야 한다고 적으므로 그 통지가 하자로 선 자리는 내지만 하자가 아닌 차이의 갈래는 내지 않는다.
조달처: E-21 §2-7 「거절하려면 시한 안에 통지해야 하고 하자를 전부 적어야 하며」

**기각한 대체 정의:**
경로의 이름만 담고 무엇에 답하는지를 담지 않는 안. 그러면 소스 없음이 무엇에 대한 없음인지가 서지
않아 관측층에 등재되는 소스 없음이 산출로 읽히지 않는다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거이며 수를 들지 않는다.
-/
-- DD:CF-4058
structure CreditTextChannel (Node : Type) where
  /-- 그 경로를 내는 쪽. -/
  publisher : Node
  /-- 그 서류 쌍의 차이가 어느 갈래에 드는가를 그 경로가 내는가. -/
  showsNonConflictKind : Bool
  /-- 아래층의 정의가 그 평문을 무르게 하는가를 그 경로가 내는가. -/
  showsWeakeningDefinition : Bool
  /-- 비서류적 조건의 충족을 보일 서류가 정해졌는가를 그 경로가 내는가. -/
  showsRequirementStatus : Bool
  /-- 그 조건이 가리키는 자료가 어긋났는가를 그 경로가 내는가. -/
  showsConflictCriterionStatus : Bool

/-- witness (A-3). **무엇을 증거하는가.** `CreditTextChannel` 이 비어 있지 않다. 어느 칸도 내지
않는 경로 하나를 든다. -/
-- DD:CF-4058
def CreditTextChannel.noSource : CreditTextChannel Unit where
  publisher := ()
  showsNonConflictKind := false
  showsWeakeningDefinition := false
  showsRequirementStatus := false
  showsConflictCriterionStatus := false

/--
그 경로가 갈래의 소속을 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 그 차이가 뜻을 바꾸지 않는 오기인지 더 적힌 정보인지를 말할
수 있는가.

**이 정의가 배제하는 사례:**
하자의 목록이 그 답을 준다는 읽기. 그 관행이 뜻을 바꾸지 않는 예를 셋 들고 그 뒤에 뜻을 바꾸는 예를
하나 들어 경계를 그리므로, 하자로 적히지 않았다는 것이 어느 갈래에 들었는지를 말해 주지 않는다.
조달처: E-67 §2-5 「뜻을 바꾸는 예를 하나 들어 경계를 그린다」

**기각한 대체 정의:**
답함을 네 칸의 논리합으로 두는 안. 그러면 다른 물음에 답하는 경로가 이 물음에도 답하는 것으로 세어진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4058
def CreditTextChannel.answersNonConflictKind {Node : Type}
    (C : CreditTextChannel Node) : Bool :=
  C.showsNonConflictKind

/--
그 경로가 무르게 함을 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 그 규칙의 정의가 이 신용장의 금지를 무르게 하는지를 말할 수
있는가.

**이 정의가 배제하는 사례:**
그 규칙의 간행 문면이 그 답을 준다는 읽기. 그 예비 고찰이 그 규칙의 여러 조항이 뜻밖의 결과를 내는
방식으로 용어를 정의한다고 적고 환적을 금지한 신용장이 대개 한 하위 조항을 배제해야 한다고 적으므로,
무르게 하는지는 그 규칙과 그 신용장의 두 문면을 함께 읽어야 서는 판정이다.
조달처: E-67 §2-4 「대개 그 금지가 효력을 가지려면 그 규칙의 한 하위 조항을 배제해야 한다」

**기각한 대체 정의:**
무르게 함을 갈래의 소속과 같은 칸으로 두는 안. 앞은 문면이 아예 없는 것이고 뒤는 문면이 있는데 읽기가
갈리는 것이어서 두 막힘의 까닭이 다르며, 한 칸에 두면 그 가름이 사라진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4058
def CreditTextChannel.answersWeakeningDefinition {Node : Type}
    (C : CreditTextChannel Node) : Bool :=
  C.showsWeakeningDefinition

/--
그 경로가 요건의 지위를 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 그 조건의 충족을 보일 서류가 신용장에 정해졌는지를 말할 수
있는가.

**이 정의가 배제하는 사례:**
은행이 그 조건을 무시했다는 사실이 그 답을 준다는 읽기. 그 규칙이 그 조건을 기재되지 않은 것으로 보고
무시한다고 적으므로 무시된 결과만 보이고 그 조건이 신용장에 섰는지는 그 문면에만 선다.
조달처: E-21 §2-4 「은행은 그 조건을 기재되지 않은 것으로 보고 무시한다」

**기각한 대체 정의:**
요건의 지위와 저촉 기준의 지위를 한 칸으로 두는 안. 앞은 신용장의 문면에만 서고 뒤는 거절 통지에
하자로 서므로 한 칸에 두면 있는 소스가 없는 소스를 가린다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4058
def CreditTextChannel.answersRequirementStatus {Node : Type}
    (C : CreditTextChannel Node) : Bool :=
  C.showsRequirementStatus

/--
그 경로가 저촉 기준의 지위를 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 그 조건이 가리키는 자료가 낸 서류에서 어긋났는지를 말할 수
있는가.

**이 정의가 배제하는 사례:**
그 어긋남도 어디서도 관측되지 않는다고 보는 읽기. 그 관행이 정해진 서류에 담긴 자료가 그 조건과
어긋나서는 안 된다고 적고 그 규칙이 거절 통지에 하자를 전부 적게 하므로, 그 어긋남이 하자로 적히는
자리가 있다.
조달처: E-67 §2-7 「그러나 정해진 서류에 담긴 자료가 그 조건과 어긋나서는 안 된다」

**기각한 대체 정의:**
그 칸을 두지 않고 세 물음으로 닫는 안. 그러면 네 판정이 전부 결손을 내어 이 파일이 소스 없음을 세 번
되풀이한 것이 되고, 요건의 지위와 저촉 기준의 지위가 갈린다는 이 회차의 처분이 관측층에서 재어지지
않는다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4058
def CreditTextChannel.answersConflictCriterionStatus {Node : Type}
    (C : CreditTextChannel Node) : Bool :=
  C.showsConflictCriterionStatus

/--
편입한 규칙의 간행 문면.

**대응 비형식 개념:** 신용장이 편입한 규칙이 간행된 문면. 용어의 정의가 거기 서나 그 정의가 어느
신용장의 어느 조항을 무르게 하는지는 거기 서지 않는다.

**이 정의가 배제하는 사례:**
그 문면이 무르게 함을 낸다는 읽기. 그 예비 고찰이 그 규칙의 정의가 뜻밖의 결과를 낸다고 적고 금지를
세우려면 한 하위 조항을 배제해야 한다고 적으므로, 그 정의만 보고는 어느 조항이 무르게 되는지가 서지
않는다.
조달처: E-67 §2-4 「대개 그 금지가 효력을 가지려면 그 규칙의 한 하위 조항을 배제해야 한다」

**기각한 대체 정의:**
무르게 함의 칸을 참으로 두는 안. 그 간행 문면이 정의를 내고 그 적용을 내지 않으므로, 참으로 두면
법문의 읽기가 공표된 값으로 읽힌다. 이 경로를 목록에서 빼는 안도 기각했다. 칸이 전부 거짓인 경로가
목록에 서는 것이 그 막힘이 소스의 부재가 아니라 읽기의 갈림이라는 관측을 드는 꼴이다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거다.
-/
-- DD:CF-4058
def incorporatedRulesText : CreditTextChannel Unit where
  publisher := ()
  showsNonConflictKind := false
  showsWeakeningDefinition := false
  showsRequirementStatus := false
  showsConflictCriterionStatus := false

/--
은행의 거절 통지.

**대응 비형식 개념:** 은행이 제시를 거절하면서 하자를 적어 보내는 통지. 어긋난 자리가 거기 서나 어긋나지
않은 차이의 갈래는 거기 서지 않는다.

**이 정의가 배제하는 사례:**
그 통지가 갈래의 소속을 낸다는 읽기. 그 규칙이 하자를 전부 적게 하므로 적히지 않은 차이가 있다는 것은
알 수 있으나, 그것이 네 갈래 가운데 어느 것에 들어서 빠졌는지는 그 통지가 들지 않는다.
조달처: E-21 §2-7 「거절하려면 시한 안에 통지해야 하고 하자를 전부 적어야 하며」

**기각한 대체 정의:**
요건의 지위의 칸을 참으로 두는 안. 그 규칙이 비서류적 조건을 기재되지 않은 것으로 보고 무시하게 하므로
그 조건은 하자의 목록에 요건으로 서지 않으며, 참으로 두면 무시된 조건이 그 통지에서 읽히는 것으로
읽힌다. 네 칸을 전부 거짓으로 두는 안도 기각했다. 그 조건이 가리키는 자료의 어긋남은 하자이므로 그
통지에 실제로 서고, 거짓으로 두면 네 물음이 전부 결손으로 접혀 그 가름이 사라진다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거다.
-/
-- DD:CF-4058
def examinerRefusalNotice : CreditTextChannel Unit where
  publisher := ()
  showsNonConflictKind := false
  showsWeakeningDefinition := false
  showsRequirementStatus := false
  showsConflictCriterionStatus := true

/--
이 회차가 든 경로의 목록.

**대응 비형식 개념:** 네 물음을 낼 수 있을 법한 경로를 모은 것.

**이 정의가 배제하는 사례:**
그 관행의 간행 문면을 이 목록에 넣는 읽기. 그 일반 원칙이 판정의 준거 가운데 하나로 그 간행물 자신을
들어 열거가 닫히지 않으므로, 그 문면을 경로로 넣으면 판정의 준거가 공시 경로로 읽힌다.
조달처: E-67 §2-8 「판정의 준거 가운데 하나가 이 간행물 자신이고」

**기각한 대체 정의:**
목록을 물음마다 따로 두는 안. 그러면 한 경로가 여러 목록에 들고 그 중복이 관측 결과의 계산에서
되풀이되며, 경로를 더하는 회차가 어느 목록에 더할지를 매번 고르게 된다.

**수 체계를 받지 않는다.** 목록이 경로를 들며 수를 들지 않는다.
-/
-- DD:CF-4058
def creditTextChannels : List (CreditTextChannel Unit) :=
  [incorporatedRulesText, examinerRefusalNotice]

/--
갈래의 소속이 어느 경로에서도 관측되지 않는다.

**대응 비형식 개념:** 그 목록의 어느 경로도 그 물음에 답하지 않는 것.

**이 정의가 배제하는 사례:**
한 경로라도 답하면 관측된 것으로 보는 읽기. 이 물음은 그 목록 전체에 대한 것이고 한 경로의 성질이
아니므로, 경로 하나로 판정하면 목록의 나머지가 읽히지 않는다.
조달처: E-67 §2-5 「낱말이나 문장의 뜻을 바꾸지 않는 오기는 하자가 아니다」

**기각한 대체 정의:**
참거짓을 내는 안. 소스가 없다는 것과 그 명제가 거짓이라는 것이 다르므로 판정 불가의 칸이 따로
필요하며, 삼분을 드는 열거가 그 칸을 받는다. 그 까닭을 법문 모호로 두는 안도 기각했다. 그 갈래의
소속을 내는 문면이 아예 공표되지 않으므로 읽기의 갈림이 아니라 소스의 부재다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4058
def nonConflictKindObserved {Node : Type}
    (chs : List (CreditTextChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersNonConflictKind) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
무르게 함이 어느 경로에서도 관측되지 않으며 그 까닭이 법문 모호다.

**대응 비형식 개념:** 그 규칙의 문면이 간행되어 있는데도 그 정의가 이 조항을 무르게 하는지가 서지 않는
것. 두 문면을 함께 읽는 일이고 그 읽기가 갈린다.

**이 정의가 배제하는 사례:**
그 문면이 간행되었으므로 관측된다고 보는 읽기. 그 예비 고찰이 그 규칙의 조항이 뜻밖의 결과를 내는
방식으로 용어를 정의한다고 적고 금지를 세우려면 한 하위 조항을 배제해야 한다고 적으므로, 간행이 곧
적용의 판정이 아니다.
조달처: E-67 §2-4 「대개 그 금지가 효력을 가지려면 그 규칙의 한 하위 조항을 배제해야 한다」

**기각한 대체 정의:**
까닭을 측정 소스 없음으로 두는 안. 그 규칙의 문면이 간행되어 있어 소스가 없는 것이 아니고 그 적용의
읽기가 갈리는 것이므로, 소스 없음으로 적으면 자료를 조달하면 풀리는 막힘으로 읽힌다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4058
def weakeningDefinitionObserved {Node : Type}
    (chs : List (CreditTextChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersWeakeningDefinition) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.legalTextAmbiguous

/--
요건의 지위가 어느 경로에서도 관측되지 않는다.

**대응 비형식 개념:** 그 목록의 어느 경로도 그 조건의 충족을 보일 서류가 정해졌는지를 내지 않는 것.

**이 정의가 배제하는 사례:**
무시된 결과가 그 지위를 낸다고 보는 읽기. 그 규칙이 그 조건을 기재되지 않은 것으로 보고 무시하게 하므로
무시의 결과와 그 조건이 신용장에 섰는지가 다른 사실이다.
조달처: E-21 §2-4 「은행은 그 조건을 기재되지 않은 것으로 보고 무시한다」

**기각한 대체 정의:**
참거짓을 내는 안. 소스가 없다는 것과 그 명제가 거짓이라는 것이 다르다. 그 까닭을 구조가 그 대상을
담지 않는 쪽으로 두는 안도 기각했다. 이 회차가 그 지위를 구조의 판정으로 담았으므로 결손이 구조의
결손이 아니라 소스의 결손이다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4058
def requirementStatusObserved {Node : Type}
    (chs : List (CreditTextChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersRequirementStatus) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
저촉 기준의 지위가 한 경로에서 관측된다.

**대응 비형식 개념:** 그 목록의 어느 경로가 그 어긋남을 내는 것.

**이 정의가 배제하는 사례:**
그 어긋남도 어디서도 관측되지 않는다고 보는 읽기. 그 규칙이 거절하려면 하자를 전부 적어야 한다고 적고
그 관행이 정해진 서류의 자료가 그 조건과 어긋나서는 안 된다고 적으므로, 그 어긋남은 하자로 적힌다.
조달처: E-21 §2-7 「거절하려면 시한 안에 통지해야 하고 하자를 전부 적어야 하며」

**기각한 대체 정의:**
참거짓을 내는 안. 한 파일의 네 판정이 한 꼴을 써야 그 결손이 한 기준에서 읽히고, 이 판정만 참거짓으로
두면 소스가 있는 자리와 없는 자리가 다른 타입으로 갈린다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4058
def conflictCriterionStatusObserved {Node : Type}
    (chs : List (CreditTextChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersConflictCriterionStatus) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
갈래의 소속에 측정 소스가 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 회차가 든 경로 가운데 하나가 그 차이의 갈래를 내야 한다. 그 관측은 그 소속이 공표되는 자리가
있다는 뜻이며, 그러면 이 회차가 세운 열거의 소속이 자료에서 재어진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 이 프레임워크의 주요 산출 가운데 하나이고, 그
열거를 구조가 계산하게 한 뒤에도 소속을 받는 자리가 남는다는 사실을 드는 유일한 자리다.
-/
-- DD:CF-4058
theorem non_conflict_kind_observed_undetermined :
    nonConflictKindObserved creditTextChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
무르게 함이 법문 모호로 판정 불가다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 측정 소스 없음을 내거나 성립을 내야 한다. 앞은 그 규칙의 문면이 간행되지 않았다는 뜻이고
뒤는 그 적용이 자료에서 선다는 뜻이며, 어느 쪽이든 이 자리의 막힘이 읽기의 갈림이라는 판정이 바뀐다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 이 회차의 네 물음이 같은 결손을 내지 않는다는 것을 드는 자리이고, 그 까닭이
자료의 조달로 풀리지 않는다는 것이 그 구멍의 처분을 정한다.
-/
-- DD:CF-4058
theorem weakening_definition_observed_ambiguous :
    weakeningDefinitionObserved creditTextChannels
      = ObservedTruth.undetermined UndeterminedReason.legalTextAmbiguous := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
요건의 지위에 측정 소스가 없고 저촉 기준의 지위는 관측된다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 지위가 같은 판정을 내야 한다. 그 관측은 두 지위가 한 축이라는 뜻이며, 그러면 이 회차가 그 둘을
가른 것이 관측층에서 재어지지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 비서류적 조건의 두 지위가 측정의 자리에서도 갈린다는 것을 드는 유일한 자리이고,
그 가름이 이 회차가 그 구멍을 두 판정으로 담은 근거를 받친다.
-/
-- DD:CF-4058
theorem nondocumentary_status_observed_split :
    requirementStatusObserved creditTextChannels
        = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource ∧
      conflictCriterionStatusObserved creditTextChannels = ObservedTruth.holds := by
  -- 두 판정이 같은 목록 위의 계산이므로 칸마다 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl⟩

/--
네 답함이 각 칸에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 답함이 자기 칸이 아닌 칸을 읽어야 한다. 그 관측은 네 답함이 같은 칸을 읽는다는 뜻이며, 그러면
판정을 넷으로 가른 것이 이름만 다른 넷이 된다.

**존재 형태로 진술하는 까닭(T-6):**
칸마다 그 하나만 참인 경로를 들어야 보인다. 임의의 경로에서 각 칸이 홀로 가르는 것이 아니라 나머지가
거짓인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 답함의 정의를 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 논리
결합마다 각 인자가 홀로 값을 가르는 경로를 증거로 들라는 A-8 의 요구가 이 자리에 걸린다.
-/
-- DD:CF-4058
theorem credit_text_answers_pin_each_field :
    ∃ C₁ C₂ C₃ C₄ : CreditTextChannel Unit,
      C₁.answersNonConflictKind = true ∧ C₁.answersWeakeningDefinition = false ∧
        C₁.answersRequirementStatus = false ∧ C₁.answersConflictCriterionStatus = false ∧
      C₂.answersNonConflictKind = false ∧ C₂.answersWeakeningDefinition = true ∧
        C₂.answersRequirementStatus = false ∧ C₂.answersConflictCriterionStatus = false ∧
      C₃.answersNonConflictKind = false ∧ C₃.answersWeakeningDefinition = false ∧
        C₃.answersRequirementStatus = true ∧ C₃.answersConflictCriterionStatus = false ∧
      C₄.answersNonConflictKind = false ∧ C₄.answersWeakeningDefinition = false ∧
        C₄.answersRequirementStatus = false ∧ C₄.answersConflictCriterionStatus = true := by
  -- 칸마다 하나만 참인 경로 넷을 든다. 답함이 자기 칸을 그대로 읽으므로 칸마다 계산하면 값이
  -- 나와 `rfl` 로 닫힌다.
  exact ⟨⟨(), true, false, false, false⟩, ⟨(), false, true, false, false⟩,
    ⟨(), false, false, true, false⟩, ⟨(), false, false, false, true⟩,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Observation
