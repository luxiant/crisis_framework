/-
관측층 — 자기 담보화의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(무차원), L-9(import 방향은
      단방향), A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 의 서술),
      C-9(전면 `simp` 금지), A-8(논리 결합마다 홀로 값을 가르는 자리의 증거),
      T-2(반증 조건), T-3(기여 분류).

**이 파일이 세우는 것은 자기 담보화의 두 재료가 어느 공시에서 읽히는가의 명세다.** 정의층이 그
판정을 제공자와 담보물 발행자의 같음으로 세우므로 그 둘이 다 읽혀야 그 판정이 관측된다.

**증권 단위 공시로는 재어지지 않는다.** 증권마다 발행자와 범주와 금액을 공표하게 하는 규칙이 있어
발행자 쪽은 읽히는데, 그 증권을 누가 담보로 내놓았는지는 어느 증권 단위 공시도 들지 않는다. 같은
증권이 누가 들고 있는지에 따라 다른 등급을 받으므로 **그 판정은 증권이 아니라 제공에 붙고, 제공을
단위로 드는 공시가 없다.**

**값을 담지 않는다.** 등급도 금액도 이 파일에 서지 않고 그것을 내는 경로가 있는가만 선다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

/--
자기 담보화의 공시 경로.

**대응 비형식 개념:** 한 공시가 그 판정의 재료를 내는가. 내놓은 당사자와 담보물의 발행자가 재료이고
경로마다 내는 것이 다르다.

**이 정의가 배제하는 사례:**
증권의 발행자가 공표되면 그 판정이 선다고 보는 읽기. 같은 증권이 누가 들고 있는지에 따라 다른 등급을
받으므로 발행자만으로는 그 판정이 서지 않고 내놓은 당사자가 함께 서야 한다(영란은행).
조달처: E-49 §3-4 「같은 증권이 누가 들고 있는지에 따라 다른 등급을 받는다」

**기각한 대체 정의:**
등급의 이동을 드는 칸을 두지 않는 안. 정책이 그 이동을 문면으로 적는 것과 그 이동이 걸린 제공을 공시가
집어내는 것이 다른 사실인데, 빼면 이 결손이 규칙의 부재로 읽힌다. 두 재료를 한 칸으로 접는 안도
기각했다. 발행자는 증권 단위 공시에서 읽히고 제공자는 어디에서도 읽히지 않아 결손의 자리가 다르며,
접으면 그 가름이 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-3840
structure SelfCollateralizationChannel (Party : Type) where
  /-- 그 경로가 제공마다 내놓은 당사자를 내는가. -/
  readsPledgeProvider : Bool
  /-- 그 경로가 그 담보물의 발행자를 내는가. -/
  readsSecurityIssuer : Bool
  /-- 그 경로가 등급의 이동을 문면으로 드는가. -/
  statesGradeStep : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/-- witness (A-3). **무엇을 증거하는가.** `SelfCollateralizationChannel` 이 비어 있지 않다. 세
칸을 하나도 내지 않는 경로 하나를 든다. -/
-- DD:CF-3840
def SelfCollateralizationChannel.noSource : SelfCollateralizationChannel Unit where
  readsPledgeProvider := false
  readsSecurityIssuer := false
  statesGradeStep := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 자기 담보화를 답하는가.

**대응 비형식 개념:** 한 경로만으로 그 판정이 재어지는가. 재료 둘이 다 한 경로에서 읽혀야 그 판정이
그 경로에서 재어진다.

**이 정의가 배제하는 사례:**
재료 하나만 읽히면 그 판정이 선다고 보는 읽기. 증권 단위 공시가 보유 증권마다 발행자와 범주와 금액을
들게 하면서 그 증권을 담보로 내놓은 당사자를 들지 않으므로, 하나로 세우면 발행자만 맞고 제공자가 비어
있는 자리가 재어진 것으로 선다(미국 증권거래위원회).
조달처: E-56 §2-15 「적어도 6개월간 매월 5영업일 이내에 전월 말일 기준의 투자 명세를 두고」

**기각한 대체 정의:**
등급의 이동을 드는 칸을 이 논리곱에 함께 넣는 안. 그 칸은 그 경로가 무엇을 내는가가 아니라 그 규범이
무엇을 적는가이며, 넣으면 정책이 그 이동을 적는 사실이 그 이동이 관측된다는 것으로 세어진다.

**값을 담지 않는다.** 두 칸의 논리곱이며 수 타입을 언급하지 않는다.
-/
-- DD:CF-3840
def SelfCollateralizationChannel.answersSelfCollateralization {Party : Type}
    (ch : SelfCollateralizationChannel Party) : Bool :=
  ch.readsPledgeProvider && ch.readsSecurityIssuer

/--
적격담보 정책을 공표하는 경로.

**대응 비형식 개념:** 중앙은행이 어느 담보를 어느 등급으로 받는지를 공표하는 문서. 등급의 이동은
문면으로 들고 그 이동이 걸린 제공은 들지 않는다.

**이 정의가 배제하는 사례:**
정책이 그 배치를 적으면 그 배치가 공시된다고 보는 읽기. 그 정책이 참가자가 조성한 자산을 담은 증권을
한 등급 아래에서 고려한다고 적으면서 어느 참가자가 어느 증권을 내놓았는지는 적지 않으므로, 그렇게 보면
규칙의 문면이 값을 가진 관측으로 선다(영란은행).
조달처: E-49 §2-9 「증권화를 담은 증권화는 받지 않는다」

**기각한 대체 정의:**
이 경로를 두지 않는 안. 정책이 그 이동을 적는다는 사실이 사라지고, 이 결손이 규칙의 부재인지 공시의
결손인지가 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3840
def collateralEligibilityPolicy : SelfCollateralizationChannel Unit where
  readsPledgeProvider := false
  readsSecurityIssuer := false
  statesGradeStep := true
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
증권 단위 보유 명세를 공표하는 경로.

**대응 비형식 개념:** 보유 증권마다 발행자와 범주와 금액을 공개 웹사이트에 올리게 하는 규칙. 발행자는
내고 그 증권을 담보로 내놓은 당사자는 내지 않는다.

**이 정의가 배제하는 사례:**
입도가 증권까지 내려가면 제공도 집어낸다고 보는 읽기. 그 규칙이 증권마다 식별번호까지 들게 하면서 그
증권이 담보로 제공되었는지와 누가 제공했는지를 들지 않으므로, 입도가 내려가도 제공의 축은 열리지
않는다(미국 증권거래위원회).
조달처: E-56 §2-15 「적어도 6개월간 매월 5영업일 이내에 전월 말일 기준의 투자 명세를 두고」

**기각한 대체 정의:**
이 경로가 발행자를 낸다는 것을 거짓으로 두는 안. 그 규칙이 발행자의 이름을 명시적으로 들게 하므로
거짓이며, 그러면 결손의 자리가 발행자 쪽으로 옮겨져 제공자 쪽이 비어 있다는 산출이 흐려진다.

**값을 담지 않는다.**
-/
-- DD:CF-3840
def securityLevelHoldingDisclosure : SelfCollateralizationChannel Unit where
  readsPledgeProvider := false
  readsSecurityIssuer := true
  statesGradeStep := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
자기 담보화의 공시 경로 목록.

**대응 비형식 개념:** 이 읽기가 확보한 경로 전부. 둘이며 어느 쪽도 두 재료를 다 내지 않는다.

**이 정의가 배제하는 사례:**
경로가 여럿이면 그 합집합이 재료를 다 덮는다고 보는 읽기. 발행자를 내는 경로와 등급의 이동을 적는 경로가
둘 다 서 있어도 제공자를 내는 경로가 없으므로, 합집합도 그 재료를 내지 않는다(미국 증권거래위원회).
조달처: E-56 §2-15 「적어도 6개월간 매월 5영업일 이내에 전월 말일 기준의 투자 명세를 두고」

**기각한 대체 정의:**
목록을 비우고 소스 없음을 바로 적는 안. 그러면 발행자가 공시된다는 사실이 사라지고, 이 결손이 어느
재료에서 서는지가 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3840
def selfCollateralizationChannels : List (SelfCollateralizationChannel Unit) :=
  [collateralEligibilityPolicy, securityLevelHoldingDisclosure]

/--
자기 담보화가 그 경로 목록에서 관측되는가.

**대응 비형식 개념:** 그 판정의 값을 외부 관측자가 낼 수 있는가. 낼 수 있으면 성립을 내고 낼 수 없으면
측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
발행자가 공표되어 있으면 그 판정이 재어진다고 보는 읽기. 같은 증권이 누가 들고 있는지에 따라 다른 등급을
받으므로 발행자만으로는 그 판정이 서지 않는다(영란은행).
조달처: E-49 §3-4 「같은 증권이 누가 들고 있는지에 따라 다른 등급을 받는다」

**기각한 대체 정의:**
구조가 그 대상을 담지 않는다는 까닭을 내는 안. 정의층이 그 판정을 세우므로 담는 대상이 있으며, 그러면
조달로 풀릴 수 있는 결손이 구조의 결손으로 적힌다. 귀속이 유일하지 않다는 까닭을 내는 안도 기각했다.
제공자는 제공마다 하나로 정해지고 그것이 공시되지 않을 뿐이다.

**값을 담지 않는다.** 목록 접기와 열거의 생성자만 쓴다.
-/
-- DD:CF-3840
def selfCollateralizationObserved {Party : Type}
    (chs : List (SelfCollateralizationChannel Party)) : ObservedTruth :=
  if chs.any (fun c => c.answersSelfCollateralization) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
그 답이 두 인자를 각각 고정한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 참인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는 뜻이며,
그러면 발행자만 내고 제공자를 내지 않는 경로가 그 판정을 답하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로, 각
인자가 홀로 참인 자리를 이 정리가 든다.

**갱신 문법으로 각 인자가 홀로 참인 자리를 든다.** 두 축이 다 참인 경로가 실재하는 인스턴스에 서지
않으므로 새 경로를 세우지 않고 이미 선 값의 그 칸만 바꾼 것을 리터럴로 든다.
-/
-- DD:CF-3840
theorem self_collateralization_answer_pins_each_conjunct :
    collateralEligibilityPolicy.answersSelfCollateralization = false
      ∧ securityLevelHoldingDisclosure.answersSelfCollateralization = false
      ∧ ({ securityLevelHoldingDisclosure with
            readsPledgeProvider := true } :
              SelfCollateralizationChannel Unit).answersSelfCollateralization = true
      ∧ ({ securityLevelHoldingDisclosure with
            readsSecurityIssuer := false } :
              SelfCollateralizationChannel Unit).answersSelfCollateralization = false
      ∧ ({ collateralEligibilityPolicy with
            readsPledgeProvider := true } :
              SelfCollateralizationChannel Unit).answersSelfCollateralization = false := by
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

/--
자기 담보화의 관측이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 경로 목록에서 답이 성립으로 서야 한다. 그 관측은 그 판정의 값이 공시에서 재어진다는 뜻이며, 그러면
이 페이즈가 정의층에 세운 자기 담보화의 판정이 공시된 값으로 닫히고 그 결손이 기록될 자리가 없다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 타입으로 서는 것을 보이고, 그 등재가 이 페이즈가
정의층에 세운 판정의 두 재료에서 실제로 선다는 것이 이 정리의 산출이므로 기여 목록에 든다.
-/
-- DD:CF-3840
theorem self_collateralization_observed_undetermined :
    selfCollateralizationObserved selfCollateralizationChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

end CrisisFramework.Observation
