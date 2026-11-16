/-
관측층 — 담보 사슬의 정의역이 공시에서 읽히는가

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(무차원), L-9(import 방향은
      단방향), A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 의 서술),
      C-9(전면 `simp` 금지), A-8(논리 결합마다 홀로 값을 가르는 자리의 증거),
      T-2(반증 조건), T-3(기여 분류).

**이 파일이 세우는 것은 이 회차가 정의층에 더한 세 축의 공시 경로 명세다.** 담보물의 점유자와 처분에서
내놓은 쪽과 담보물이 담은 기초자산의 조성자가 그 셋이며, 끊김의 판정과 자기 담보화의 판정이 그 위에
선다.

**셋을 한 채널이 받는다.** 셋이 전부 담보 사슬의 실물 상태가 공시에서 읽히는가를 묻고 답이 셋 모두
소스 없음이므로, 채널을 셋으로 가르면 같은 결손이 세 자리에 서고 그 자리마다 증거와 정리가 되풀이된다.

**값을 담지 않는다.** 점유자의 이름도 조성자의 이름도 이 파일에 서지 않고 그것을 내는 경로가 있는가만
선다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

/--
담보 사슬 정의역의 공시 경로.

**대응 비형식 개념:** 한 공시가 담보물의 실물 상태를 내는가. 누가 쥐고 있는지와 누가 내놓았는지와
담긴 자산을 누가 조성했는지가 재료이고 경로마다 내는 것이 다르다.

**이 정의가 배제하는 사례:**
부담된 자산의 금액이 공표되면 그 상태가 읽힌다고 보는 읽기. 자산 부담 공시를 다룬 기록이 담보 제공분을
단일 금액으로 들고 그 분류를 그 자리에 걸지 않는다고 적으므로, 금액이 서도 누가 쥐고 있는지는 그
경로에서 나오지 않는다(유럽은행감독청).
조달처: E-45 §2-2 「담보 제공분을 단일 금액으로 들고 (b) 의 분류를 그 자리에 걸지 않는다」

**기각한 대체 정의:**
세 축을 한 칸으로 접는 안. 셋이 서로 다른 공시 체계에 걸려 있고 결손의 자리가 다르므로, 접으면 어느
축에서 결손이 서는지가 사라진다. 점유를 제공자와 담보권자의 두 칸으로 가르는 안도 기각했다. 공시가
점유자를 아예 내지 않아 두 칸이 똑같이 비며, 가르면 비어 있는 칸만 늘어난다.

**값을 담지 않는다.**
-/
-- DD:CF-3881
structure CollateralChainDomainChannel (Party : Type) where
  /-- 그 경로가 담보물을 쥐고 있는 당사자를 내는가. -/
  readsPossessor : Bool
  /-- 그 경로가 처분에서 내놓은 당사자를 내는가. -/
  readsDisposalGiver : Bool
  /-- 그 경로가 담보물이 담은 기초자산의 조성자를 내는가. -/
  readsBackingOriginator : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/-- witness (A-3). **무엇을 증거하는가.** `CollateralChainDomainChannel` 이 비어 있지 않다. 세
칸을 하나도 내지 않는 경로 하나를 든다. -/
-- DD:CF-3881
def CollateralChainDomainChannel.noSource : CollateralChainDomainChannel Unit where
  readsPossessor := false
  readsDisposalGiver := false
  readsBackingOriginator := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 사슬 정의역의 세 재료를 답하는가.

**대응 비형식 개념:** 그 공시 하나로 끊김의 판정과 조성자의 판정이 함께 재어지는가. 세 재료가 다 서야
답이 된다.

**이 정의가 배제하는 사례:**
처분의 상대만 공표되면 끊김이 재어진다고 보는 읽기. 담보권의 처분 뒤 존속을 다룬 규범이 담보권자의
점유를 끊김을 막는 조건으로 두므로, 처분이 서도 점유가 서지 않으면 그 판정이 서지 않는다
(Uniform Commercial Code 제9-320조 (e)).
조달처: E-66 §2-4 「그러므로 점유하는 담보권자는 통상의 영업 과정 매수인에게도 자기 권리를 잃지 않는다」

**기각한 대체 정의:**
두 재료만으로 답을 세우고 조성자를 따로 두는 안. 조성자 쪽도 담보물의 실물 상태이고 같은 공시 체계에서
비어 있으므로, 따로 두면 같은 결손이 두 자리에 선다.

**값을 담지 않는다.**
-/
-- DD:CF-3881
def CollateralChainDomainChannel.answersChainDomain {Party : Type}
    (c : CollateralChainDomainChannel Party) : Bool :=
  c.readsPossessor && c.readsDisposalGiver && c.readsBackingOriginator

/--
부담된 자산의 금액을 공표하는 경로.

**대응 비형식 개념:** 담보로 내준 자산의 총액을 칸으로 드는 감독 공시. 금액은 내되 그 자산을 누가 쥐고
있는지와 누구에게 넘어갔는지는 내지 않는다.

**이 정의가 배제하는 사례:**
입도가 자산 범주까지 내려가면 상대도 읽힌다고 보는 읽기. 같은 기록이 가르는 칸을 가진 경로가 물음의
주체를 보지 않는다고 적으므로, 범주가 내려가도 주체의 축은 열리지 않는다(유럽은행감독청).
조달처: E-45 §3-2 「가르는 칸을 가진 경로가 물음의 주체를 보지 않는다」

**기각한 대체 정의:**
이 경로를 두지 않는 안. 부담된 자산이 공시된다는 사실이 사라지고, 이 결손이 공시의 부재인지 칸의
결손인지가 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3881
def encumbranceAmountDisclosure : CollateralChainDomainChannel Unit where
  readsPossessor := false
  readsDisposalGiver := false
  readsBackingOriginator := false
  recipient := DisclosureRecipient.supervisor
  provenance := MeasurementProvenance.officialReport

/--
담보의 적격 범주와 할인율을 공표하는 경로.

**대응 비형식 개념:** 중앙은행이 무엇을 담보로 받는지를 적는 공시. 범주와 할인율은 내되 그 증권을 누가
조성했고 누가 쥐고 있는지는 내지 않는다.

**이 정의가 배제하는 사례:**
정책이 조성자를 판정에 쓰므로 그 값이 공시된다고 보는 읽기. 같은 공시가 어느 개별 증권에든 언제든 추가
할인율을 적용할 권리를 유보한다고 적어 판정의 재료를 공개하지 않으므로, 판정에 쓰이는 것과 공시되는
것이 다르다(영란은행).
조달처: E-49 §2-13 「어느 개별 증권에든 언제든 추가 할인율을 적용할 권리를 유보하며」

**기각한 대체 정의:**
이 경로가 조성자를 낸다고 두는 안. 그 공시가 적격 범주와 할인율의 격자만 들고 개별 증권의 조성자를
들지 않으므로 거짓이며, 그러면 조성자 쪽 결손이 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-3881
def centralBankCollateralSchedule : CollateralChainDomainChannel Unit where
  readsPossessor := false
  readsDisposalGiver := false
  readsBackingOriginator := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
담보 사슬 정의역의 공시 경로 목록.

**대응 비형식 개념:** 이 읽기가 확보한 경로 전부. 둘이며 어느 쪽도 세 재료를 하나도 내지 않는다.

**이 정의가 배제하는 사례:**
경로가 여럿이면 그 합집합이 재료를 덮는다고 보는 읽기. 부담 금액을 내는 경로와 적격 범주를 내는 경로가
둘 다 서 있어도 세 재료를 내는 칸이 어느 쪽에도 없으므로 합집합도 그것을 내지 않는다(유럽은행감독청).
조달처: E-45 §2-2 「담보 제공분을 단일 금액으로 들고 (b) 의 분류를 그 자리에 걸지 않는다」

**기각한 대체 정의:**
목록을 비우고 소스 없음을 바로 적는 안. 그러면 담보 쪽 공시가 서 있다는 사실이 사라지고, 이 결손이
공시 체계의 부재인지 칸의 결손인지가 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3881
def collateralChainDomainChannels : List (CollateralChainDomainChannel Unit) :=
  [encumbranceAmountDisclosure, centralBankCollateralSchedule]

/--
사슬의 정의역이 그 경로 목록에서 관측되는가.

**대응 비형식 개념:** 끊김과 조성자의 판정을 외부 관측자가 낼 수 있는가. 낼 수 있으면 성립을 내고 낼 수
없으면 측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
규범이 요건을 적으므로 그 요건의 값이 관측된다고 보는 읽기. 담보권의 처분 뒤 존속을 다룬 규범이 점유를
요건으로 들면서 그 상태를 공시하게 하지 않으므로, 조문의 문면과 값의 관측이 다른 사실이다
(Uniform Commercial Code 제9-320조 (e)).
조달처: E-66 §2-4 「그러므로 점유하는 담보권자는 통상의 영업 과정 매수인에게도 자기 권리를 잃지 않는다」

**기각한 대체 정의:**
구조가 그 대상을 담지 않는다는 까닭을 내는 안. 정의층이 세 축을 다 세우므로 담는 대상이 있으며, 그러면
조달로 풀릴 수 있는 결손이 구조의 결손으로 적힌다.

**값을 담지 않는다.** 목록 접기와 열거의 생성자만 쓴다.
-/
-- DD:CF-3881
def collateralChainDomainObserved {Party : Type}
    (chs : List (CollateralChainDomainChannel Party)) : ObservedTruth :=
  if chs.any (fun c => c.answersChainDomain) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
그 답이 세 인자를 각각 고정한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나가 거짓인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는
뜻이며, 그러면 점유자를 내지 않는 경로나 처분의 상대를 내지 않는 경로나 조성자를 내지 않는 경로가 그
물음을 답하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로, 각
인자가 홀로 거짓인 자리를 이 정리가 든다.
-/
-- DD:CF-3881
theorem chain_domain_answer_pins_each_conjunct :
    ∃ cAll cNoPossessor cNoGiver cNoOriginator : CollateralChainDomainChannel Unit,
      cAll.answersChainDomain = true
        ∧ cNoPossessor.readsPossessor = false ∧ cNoPossessor.answersChainDomain = false
        ∧ cNoGiver.readsDisposalGiver = false ∧ cNoGiver.answersChainDomain = false
        ∧ cNoOriginator.readsBackingOriginator = false
        ∧ cNoOriginator.answersChainDomain = false := by
  exact ⟨{ encumbranceAmountDisclosure with
            readsPossessor := true, readsDisposalGiver := true, readsBackingOriginator := true },
    { encumbranceAmountDisclosure with readsDisposalGiver := true, readsBackingOriginator := true },
    { encumbranceAmountDisclosure with readsPossessor := true, readsBackingOriginator := true },
    { encumbranceAmountDisclosure with readsPossessor := true, readsDisposalGiver := true },
    rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
그 경로 목록에서 사슬의 정의역이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록의 어느 경로가 세 재료를 다 내야 한다. 그 관측은 담보물의 점유자와 처분의 상대와 기초자산의
조성자를 함께 내는 공시가 실재한다는 뜻이며, 그러면 이 결손이 조달로 풀린다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 이 프레임워크의 주요 산출 가운데 하나이고, 이
회차가 정의층에 더한 세 축이 전부 공표 수치에서 재어지지 않는다는 것이 이 진술의 내용이므로 기여
목록에 든다.
-/
-- DD:CF-3881
theorem chain_domain_observed_undetermined :
    collateralChainDomainObserved collateralChainDomainChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

end CrisisFramework.Observation
