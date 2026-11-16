/-
관측층 — 담보권이 끊기는 자리의 외생 확인 신호가 공시에서 어떻게 관측되는가

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원이며 수치 리터럴도
      금지), L-9(import 방향은 단방향), A-1(`axiom` 금지), A-3(witness 의무), A-8(변이 검사와
      논리 결합의 증거), C-1·C-2(`noncomputable` 과 `Classical` 금지), C-3(판정 술어의 결정
      가능성), C-9(전면 `simp` 금지), C-10(검증 불가능한 조항을 외생 확인 신호로 두고 그 신호에
      측정 소스가 없다는 사실을 관측층에 등재한다), D-1·D-2(docstring 3항목), D-3(배제 사례는
      실제 문면), D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시),
      W-11(관측층을 정의층과 같은 페이즈에서 병행한다).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 축을 내는가만 `Bool` 로 들고, 주체는 매개변수로
받아 구체 타입을 박지 않는다.

**이 파일이 받는 것은 재어지지 않는 몫뿐이다.** 끊김의 요건 가운데 같은 종류물을 가리키는 이전이 서
있는지와 내놓는 쪽이 그 제공의 두 당사자가 아닌지는 구조에서 재어지므로 그 관측은 앞서 선 명세들이
이미 받으며, 이 명세는 외생 확인 신호 하나만 받는다.

**그 신호의 축을 둘로 가른다.** 통상의 영업 과정인지를 내는 축과 내놓는 쪽이 대체 가능 물건을
매매하는 자인지를 내는 축이며, 두 축이 그 규범의 요건을 그대로 따른다.

**규범이 서 있는 것과 그 요건의 성립이 공시되는 것이 다른 사실이다.** 끊김의 규칙은 성문으로 서 있고
그 요건도 문면으로 서 있으나, 그 요건이 어느 경우에 성립했는지를 내는 자리가 없다. **그래서 이 결손은
규칙을 몰라서 서는 것이 아니라 사실을 내는 경로가 없어서 선다.**

**경로 전량을 훑는 판정을 목록 전칭이 아니라 목록 접기로 둔다.** 전칭으로 두면 목록 멤버십을 푸는
증명이 명제 외연성을 끌어오는데 접기로 두면 계산으로 닫혀 공리가 비며, 관측층의 공리 기준선이 비어
있으므로 그 차이가 기준선 초과를 가른다.

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
끊김의 외생 확인 신호를 내는 경로.

**대응 비형식 개념:** 한 자리가 그 신호의 어느 축을 내는가. 그 규범이 요건을 둘로 들므로 축도 둘이며,
그 요건을 문면으로 드는 것과 그 요건의 성립을 내는 것을 가르는 칸을 함께 든다.

**이 정의가 배제하는 사례:**
증권의 보유가 그 신호를 대신한다고 보는 읽기. 창고증권의 규범을 읽은 기록이 증권을 잡은 쪽의 권리가
창고업자의 처분으로 끊기므로 증권의 보유가 물건의 확보를 보장하지 않는다고 적으므로, 대신한다고 보면
끊긴 자리가 끊기지 않은 것으로 선다.
조달처: E-47 §2-5 「증권의 보유가 물건의 확보를 보장하지 않는다」

**기각한 대체 정의:**
요건 둘을 한 칸으로 접는 안. 칸이 줄어드나 통상의 영업 과정인지는 분쟁이 서야 정해지고 대체 가능 물건을
매매하는 자인지는 영업의 성질이어서 해소 경로가 다른데, 접으면 그 가름이 사라진다. 그 요건을 문면으로
드는 칸을 두지 않는 안도 기각했다. 규칙이 서 있는 것과 그 성립이 공시되는 것이 다른 사실인데, 빼면
이 결손이 규칙의 부재로 읽힌다.

**값을 담지 않는다.**
-/
-- DD:CF-3809
structure PledgeDefeatChannel (Party : Type) where
  /-- 그 경로가 그 처분이 통상의 영업 과정이었는지를 내는가. -/
  readsOrdinaryCourse : Bool
  /-- 그 경로가 내놓는 쪽이 대체 가능 물건을 매매하는 자인지를 내는가. -/
  readsFungibleDealer : Bool
  /-- 그 경로가 끊김의 요건을 문면으로 드는가. -/
  statesQualification : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/-- witness (A-3). **무엇을 증거하는가.** `PledgeDefeatChannel` 이 비어 있지 않다. 세 칸을
하나도 내지 않는 경로 하나를 든다. -/
-- DD:CF-3809
def PledgeDefeatChannel.noSource : PledgeDefeatChannel Unit where
  readsOrdinaryCourse := false
  readsFungibleDealer := false
  statesQualification := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 끊김의 외생 신호를 답하는가.

**대응 비형식 개념:** 한 경로만으로 그 신호가 재어지는가. 요건 둘이 다 한 경로에서 읽혀야 그 신호가
그 경로에서 재어진다.

**이 정의가 배제하는 사례:**
요건 하나만 읽히면 그 신호가 선다고 보는 읽기. 창고증권의 규범을 읽은 기록이 대체 가능 물건을 매매하는
창고업자가 통상의 영업 과정에서 팔아야 매수인이 증권상의 청구를 벗어난다고 적어 요건 둘을 함께 걸므로,
하나로 세우면 영업의 성질만 맞고 처분의 성격이 아닌 자리가 끊긴 것으로 선다.
조달처: E-47 §2-5 「대체 가능 물건을 매매하는 창고업자가 통상의 영업 과정에서 매수인에게 그 물건을 팔면」

**기각한 대체 정의:**
요건을 문면으로 드는 칸을 이 논리곱에 함께 넣는 안. 그 칸은 그 경로가 무엇을 내는가가 아니라 그 규범이
무엇을 적는가이며, 넣으면 규칙이 서 있다는 사실이 그 사실이 관측된다는 것으로 세어진다.

**값을 담지 않는다.** 두 칸의 논리곱이며 수 타입을 언급하지 않는다.
-/
-- DD:CF-3809
def PledgeDefeatChannel.answersPledgeDefeat {Party : Type}
    (ch : PledgeDefeatChannel Party) : Bool :=
  ch.readsOrdinaryCourse && ch.readsFungibleDealer

/--
창고업자의 처분을 다루는 규범을 끊김의 경로로 읽은 것.

**대응 비형식 개념:** 대체 가능 물건을 매매하는 창고업자가 통상의 영업 과정에서 팔면 매수인이 증권상의
청구를 벗어나 취득한다고 적는 조문을 그 신호의 경로로 세운 것. 그 조문이 요건 둘을 문면으로 들되 그
요건의 성립을 내지 않는다.

**이 정의가 배제하는 사례:**
그 조문이 요건의 성립까지 낸다고 보는 읽기. 창고증권의 규범을 읽은 기록이 그 조문을 담보가 사라지는
경로로 적되 어느 처분이 그 요건을 채웠는지는 적지 않으므로, 낸다고 보면 규칙의 문면이 사례의 관측으로
선다.
조달처: E-47 §2-5 「이것이 담보가 사라지는 경로다」

**기각한 대체 정의:**
이 경로를 세우지 않고 어느 경로도 요건을 들지 않는 것으로 두는 안. 목록이 짧아지나 요건이 성문으로 서
있는 것과 어디에도 적히지 않은 것이 다른 사실이며, 접으면 이 결손이 규칙의 부재로 읽혀 해소 경로가
입법으로 간다.

**값을 담지 않는다.**
-/
-- DD:CF-3809
def warehouseDispositionNorm : PledgeDefeatChannel Unit where
  readsOrdinaryCourse := false
  readsFungibleDealer := false
  statesQualification := true
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
유통증권의 우선 규칙을 끊김의 경로로 읽은 것.

**대응 비형식 개념:** 수치인이 물건을 보관하고 유통증권을 발급한 동안에는 그 증권에 담보권을 완성한
쪽이 다른 방법으로 완성한 쪽보다 우선한다고 적는 조문을 그 신호의 경로로 세운 것. 그 조문이 권리의
순위를 정하되 끊김의 요건을 들지 않는다.

**이 정의가 배제하는 사례:**
그 우선 규칙이 서 있으면 끊김이 서지 않는다고 보는 읽기. 창고증권의 규범을 읽은 기록이 증권이
유통증권으로 적법하게 양도되었더라도 창고업자의 처분으로 매수인이 증권상의 청구를 벗어난다고 적으므로,
그렇게 보면 우선 규칙이 끊김을 막는 것으로 선다.
조달처: E-47 §2-5 「증권이 유통증권으로 적법하게 양도되었더라도 그렇다」

**기각한 대체 정의:**
이 경로가 요건을 문면으로 드는 것으로 두는 안. 그 조문이 드는 것은 완성과 우선의 규칙이고 처분의
성격이나 영업의 성질이 아니므로, 두면 요건을 드는 자리가 둘로 세어져 그 요건이 어느 조문에서 오는지가
흐려진다.

**값을 담지 않는다.**
-/
-- DD:CF-3809
def negotiableDocumentPriorityNorm : PledgeDefeatChannel Unit where
  readsOrdinaryCourse := false
  readsFungibleDealer := false
  statesQualification := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
끊김의 외생 신호를 내는 경로의 목록.

**대응 비형식 개념:** 외부 관측자가 그 신호의 두 축을 읽을 수 있는 자리의 전량. 목록 전량을 훑는
판정이 이 목록에 걸린다.

**이 정의가 배제하는 사례:**
요건을 들지 않는 경로를 목록에서 빼는 읽기. 창고증권의 규범을 읽은 기록이 우선 규칙과 처분의 조문을
따로 들고 뒤가 앞을 덮는다고 적으므로, 빼면 그 덮음이 사라지고 우선 규칙이 끊김의 자리에 서지 않는
사실이 목록에서 지워진다.
조달처: E-47 §2-6 「비유통증권에서는 그 우선 규칙이 서지 않고 완성의 길 셋이 열거된다」

**기각한 대체 정의:**
목록을 비우고 소스 없음을 바로 적는 안. 그러면 규범이 요건을 문면으로 든다는 사실이 사라지고, 이
결손이 조달로 풀리는 몫인지 아닌지가 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3809
def pledgeDefeatChannels : List (PledgeDefeatChannel Unit) :=
  [warehouseDispositionNorm, negotiableDocumentPriorityNorm]

/--
끊김의 외생 신호가 그 경로 목록에서 관측되는가.

**대응 비형식 개념:** 그 신호의 값을 외부 관측자가 낼 수 있는가. 낼 수 있으면 성립을 내고 낼 수 없으면
측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
요건이 성문으로 서 있으면 그 신호가 재어진다고 보는 읽기. 창고증권의 규범을 읽은 기록이 그 조문을 적되
어느 처분이 그 요건을 채웠는지를 적지 않으므로, 그렇게 보면 규칙의 문면이 값을 가진 관측으로 선다.
조달처: E-47 §2-5 「이것이 담보가 사라지는 경로다」

**기각한 대체 정의:**
판정이 이 모형의 범위 밖이라는 까닭을 내는 안. 그 까닭은 그 물음이 이 구조가 답할 것이 아니라는 뜻인데
이 페이즈가 그 신호를 정의층의 칸으로 세우므로 답할 자리가 있으며, 그러면 조달로 풀릴 수 있는 결손이
범위의 결손으로 적힌다. 법 문면이 모호하다는 까닭을 내는 안도 기각했다. 그 조문은 요건을 분명히 들고
그 요건의 성립이 공시되지 않을 뿐이다.

**값을 담지 않는다.** 목록 접기와 열거의 생성자만 쓴다.
-/
-- DD:CF-3809
def pledgeDefeatObserved {Party : Type}
    (chs : List (PledgeDefeatChannel Party)) : ObservedTruth :=
  if chs.any (fun c => c.answersPledgeDefeat) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
어느 경로도 끊김의 외생 신호를 답하지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
처분의 성격과 영업의 성질을 함께 내는 경로가 하나라도 서야 한다. 그 관측은 그 신호가 공시에서 재어진다는
뜻이며, 그러면 검증 불가능한 조항을 외생 신호로 둔 설계가 그 자리에서 필요하지 않게 된다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 검증 불가능한 조항을 외생 신호로 두면 그 신호의 소스 없음을 관측층에 등재하라는
요구가 이 자리에서 실제로 선다는 것이 이 정리의 산출이므로 기여 목록에 든다.

**진술의 꼴.** 목록 멤버십의 전칭으로 두지 않는 사유는 그 꼴이 명제 외연성을 끌어오는데 관측층의 공리
기준선이 비어 있다는 데 있다.
-/
-- DD:CF-3809
theorem no_channel_answers_pledge_defeat :
    pledgeDefeatChannels.all (fun c => !c.answersPledgeDefeat) = true := by
  rfl

/--
요건은 문면으로 서 있고 그 성립은 어느 경로에서도 읽히지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
요건을 문면으로 드는 경로가 아예 없거나, 그 요건의 성립을 내는 경로가 하나라도 서야 한다. 앞의 관측은
이 결손이 규칙의 부재에서 온다는 뜻이고 뒤의 관측은 그 결손이 조달로 풀린다는 뜻이므로, 어느 쪽이든 이
명제가 드는 가름이 서지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 규칙을 몰라서 서는 결손과 사실을 내는 경로가 없어서 서는 결손이 다른 사실이고 그
갈림이 해소 경로를 가르므로 기여 목록에 든다.
-/
-- DD:CF-3809
theorem pledge_defeat_rule_stated_not_reported :
    warehouseDispositionNorm.statesQualification = true
      ∧ pledgeDefeatChannels.all (fun c => !c.readsOrdinaryCourse) = true
      ∧ pledgeDefeatChannels.all (fun c => !c.readsFungibleDealer) = true := by
  exact ⟨rfl, rfl, rfl⟩

/--
그 판정이 각 인자에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 참인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는 뜻이며,
그러면 영업의 성질만 내고 처분의 성격을 내지 않는 경로가 그 신호를 답하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로, 각
인자가 홀로 참인 자리를 이 정리가 든다.

**갱신 문법으로 각 인자가 홀로 참인 자리를 든다.** 두 축 가운데 어느 하나만 참인 경로가 실재하는
인스턴스에 서지 않으므로 새 경로를 세우지 않고 이미 선 값의 그 칸만 바꾼 것을 리터럴로 든다.
-/
-- DD:CF-3809
theorem pledge_defeat_answer_pins_each_conjunct :
    warehouseDispositionNorm.answersPledgeDefeat = false
      ∧ negotiableDocumentPriorityNorm.answersPledgeDefeat = false
      ∧ ({ warehouseDispositionNorm with
            readsOrdinaryCourse := true,
            readsFungibleDealer := true } :
              PledgeDefeatChannel Unit).answersPledgeDefeat = true
      ∧ ({ warehouseDispositionNorm with
            readsOrdinaryCourse := true } :
              PledgeDefeatChannel Unit).answersPledgeDefeat = false
      ∧ ({ warehouseDispositionNorm with
            readsFungibleDealer := true } :
              PledgeDefeatChannel Unit).answersPledgeDefeat = false := by
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

/--
그 신호의 관측이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 경로 목록에서 답이 성립으로 서야 한다. 그 관측은 그 신호의 값이 공시에서 재어진다는 뜻이며, 그러면
이 페이즈가 정의층에 세운 끊김의 판정이 외생 신호 없이 닫히고 그 결손이 기록될 자리가 없다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 타입으로 서는 것을 보이고, 그 등재가 이 페이즈가
정의층에 세운 판정의 외생 신호에서 실제로 선다는 것이 이 정리의 산출이므로 기여 목록에 든다.
-/
-- DD:CF-3809
theorem pledge_defeat_observed_undetermined :
    pledgeDefeatObserved pledgeDefeatChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

end CrisisFramework.Observation
