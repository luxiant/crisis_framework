/-
관측층 — 제공별 몫의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(무차원), L-9(import 방향은
      단방향), A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 의 서술),
      C-9(전면 `simp` 금지), A-8(논리 결합마다 홀로 값을 가르는 자리의 증거),
      T-2(반증 조건), T-3(기여 분류).

**이 파일이 세우는 것은 제공별 몫의 두 재료가 어느 공시에서 읽히는가의 명세다.** 회계층이 그 몫을
평가율과 요구 금액의 교차곱으로 판정하므로 그 둘이 다 읽혀야 그 판정이 관측된다.

**공시된 격자가 실제 적용 평가율을 다하지 않는다.** 중앙은행의 담보 정책이 범주와 잔존만기의 격자를
공표하면서 어느 개별 증권에든 추가 할인율을 적용할 권리를 유보하고 통화 불일치와 집중도의 가산을 따로
두므로, 그 격자를 읽어도 어느 담보에 실제로 적용된 비율이 서지 않는다. **그 결손이 이 층의 산출이며
회계층의 결손이 아니다.**

**값을 담지 않는다.** 비율도 금액도 이 파일에 서지 않고 그것을 내는 경로가 있는가만 선다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

/--
제공별 몫의 공시 경로.

**대응 비형식 개념:** 한 공시가 그 몫의 재료를 내는가. 평가율과 요구 금액이 재료이고 경로마다 내는
것이 다르다.

**이 정의가 배제하는 사례:**
격자를 공표하는 경로가 적용된 평가율을 낸다고 보는 읽기. 중앙은행이 어느 개별 증권에든 언제든 추가
할인율을 적용할 권리를 유보하고 이미 인도된 거래의 담보에도 그렇게 한다고 적으므로, 공표된 격자와
적용된 비율이 갈린다(영란은행).
조달처: E-49 §2-13 「어느 개별 증권에든 언제든 추가 할인율을 적용할 권리를 유보하며」

**기각한 대체 정의:**
격자를 드는 칸을 두지 않는 안. 격자가 서 있는 것과 그 격자가 적용된 비율을 내는 것이 다른 사실인데,
빼면 이 결손이 공시의 부재로 읽힌다. 두 재료를 한 칸으로 접는 안도 기각했다. 요구 금액은 떠받치는
청구권에 붙고 평가율은 담보물에 붙어 색인이 다르며, 접으면 그 가름이 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-3839
structure CollateralShareChannel (Party : Type) where
  /-- 그 경로가 그 담보에 실제로 적용된 평가율을 내는가. -/
  readsAppliedRate : Bool
  /-- 그 경로가 제공마다 떠받치는 노출의 금액을 내는가. -/
  readsPledgeDemand : Bool
  /-- 그 경로가 범주와 잔존만기의 격자를 문면으로 드는가. -/
  statesRateGrid : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/-- witness (A-3). **무엇을 증거하는가.** `CollateralShareChannel` 이 비어 있지 않다. 세 칸을
하나도 내지 않는 경로 하나를 든다. -/
-- DD:CF-3839
def CollateralShareChannel.noSource : CollateralShareChannel Unit where
  readsAppliedRate := false
  readsPledgeDemand := false
  statesRateGrid := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 제공별 몫을 답하는가.

**대응 비형식 개념:** 한 경로만으로 그 몫이 재어지는가. 재료 둘이 다 한 경로에서 읽혀야 그 몫이 그
경로에서 재어진다.

**이 정의가 배제하는 사례:**
재료 하나만 읽히면 그 몫이 선다고 보는 읽기. 할인율 문서가 시장가격이 관측되지 않는 적격 담보에 가산을
더한다고 적어 비율 쪽만 들고 그 담보가 떠받치는 노출의 금액을 들지 않으므로, 하나로 세우면 분모만 맞고
분자가 비어 있는 자리가 재어진 것으로 선다(영란은행).
조달처: E-49 §11-4 「시장가격이 관측되지 않는 적격 담보에 5%p 를 더한다」

**기각한 대체 정의:**
격자를 드는 칸을 이 논리곱에 함께 넣는 안. 그 칸은 그 경로가 무엇을 내는가가 아니라 그 규범이 무엇을
적는가이며, 넣으면 격자가 공표된 사실이 비율이 관측된다는 것으로 세어진다.

**값을 담지 않는다.** 두 칸의 논리곱이며 수 타입을 언급하지 않는다.
-/
-- DD:CF-3839
def CollateralShareChannel.answersCollateralShare {Party : Type}
    (ch : CollateralShareChannel Party) : Bool :=
  ch.readsAppliedRate && ch.readsPledgeDemand

/--
할인율 격자를 공표하는 경로.

**대응 비형식 개념:** 중앙은행이 담보의 범주와 잔존만기로 할인율을 공표하는 문서. 격자는 들고 어느
담보에 실제로 적용된 비율은 들지 않는다.

**이 정의가 배제하는 사례:**
격자의 행과 열이 촘촘하면 적용된 비율이 유도된다고 보는 읽기. 그 격자가 할인율 행 스물여덟과 열 여덟을
내는데 같은 문서가 통화 불일치와 집중도의 가산을 그 격자 밖에 따로 두므로, 격자를 다 읽어도 가산이 선
담보의 비율이 서지 않는다(영란은행).
조달처: E-49 §2-11 「범주와 금리 유형의 격자가 할인율 행 스물여덟을 내고」

**기각한 대체 정의:**
이 경로를 두지 않는 안. 격자가 공표된다는 사실이 사라지고, 이 결손이 공시의 부재인지 공시의 불완전인지가
갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3839
def haircutGridDisclosure : CollateralShareChannel Unit where
  readsAppliedRate := false
  readsPledgeDemand := false
  statesRateGrid := true
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
추가 할인율의 재량 유보를 적는 경로.

**대응 비형식 개념:** 같은 문서가 자기 격자의 불완전함을 스스로 적는 자리. 격자도 적용된 비율도 내지
않으며, 그 유보가 이 결손을 공시 자신이 인정하는 꼴이다.

**이 정의가 배제하는 사례:**
재량 유보가 예외적 자리에만 걸린다고 보는 읽기. 그 문서가 이미 인도된 거래의 담보에도 그렇게 한다고
적어 유보의 범위를 거래의 시점으로도 닫지 않으므로, 예외로 두면 어느 담보가 그 예외인지가 서지
않는다(영란은행).
조달처: E-49 §2-13 「어느 개별 증권에든 언제든 추가 할인율을 적용할 권리를 유보하며」

**기각한 대체 정의:**
이 경로를 앞의 경로와 한 값으로 묶는 안. 격자를 드는 것과 유보를 적는 것이 같은 문서에 있어도 다른
사실이며, 묶으면 격자의 공표가 그 유보까지 공표하는 것으로 세어진다.

**값을 담지 않는다.**
-/
-- DD:CF-3839
def discretionaryHaircutReservation : CollateralShareChannel Unit where
  readsAppliedRate := false
  readsPledgeDemand := false
  statesRateGrid := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
제공별 몫의 공시 경로 목록.

**대응 비형식 개념:** 이 읽기가 확보한 경로 전부. 둘이며 어느 쪽도 두 재료를 다 내지 않는다.

**이 정의가 배제하는 사례:**
경로가 여럿이면 그 합집합이 재료를 다 덮는다고 보는 읽기. 두 경로가 같은 문서에서 오고 그 문서가 적용된
비율을 어디에서도 내지 않으므로, 합집합도 그 재료를 내지 않는다(영란은행).
조달처: E-49 §2-13 「어느 개별 증권에든 언제든 추가 할인율을 적용할 권리를 유보하며」

**기각한 대체 정의:**
목록을 비우고 소스 없음을 바로 적는 안. 그러면 격자가 공표된다는 사실이 사라지고, 이 결손이 조달로
풀리는 몫인지 아닌지가 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3839
def collateralShareChannels : List (CollateralShareChannel Unit) :=
  [haircutGridDisclosure, discretionaryHaircutReservation]

/--
제공별 몫이 그 경로 목록에서 관측되는가.

**대응 비형식 개념:** 그 몫의 값을 외부 관측자가 낼 수 있는가. 낼 수 있으면 성립을 내고 낼 수 없으면
측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
비율이 공표되어 있으면 그 몫이 재어진다고 보는 읽기. 그 문서가 격자를 공표하면서 개별 증권의 추가
할인율을 유보하므로, 그렇게 보면 공표된 표가 값을 가진 관측으로 선다(영란은행).
조달처: E-49 §2-13 「어느 개별 증권에든 언제든 추가 할인율을 적용할 권리를 유보하며」

**기각한 대체 정의:**
판정이 이 모형의 범위 밖이라는 까닭을 내는 안. 회계층이 그 몫을 판정으로 세우므로 답할 자리가 있으며,
그러면 조달로 풀릴 수 있는 결손이 범위의 결손으로 적힌다. 귀속이 유일하지 않다는 까닭을 내는 안도
기각했다. 그 비율은 담보마다 하나로 정해지고 그것이 공시되지 않을 뿐이다.

**값을 담지 않는다.** 목록 접기와 열거의 생성자만 쓴다.
-/
-- DD:CF-3839
def collateralShareObserved {Party : Type}
    (chs : List (CollateralShareChannel Party)) : ObservedTruth :=
  if chs.any (fun c => c.answersCollateralShare) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
그 답이 두 인자를 각각 고정한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 참인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는 뜻이며,
그러면 비율만 내고 금액을 내지 않는 경로가 그 몫을 답하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로, 각
인자가 홀로 참인 자리를 이 정리가 든다.

**갱신 문법으로 각 인자가 홀로 참인 자리를 든다.** 두 축 가운데 어느 하나만 참인 경로가 실재하는
인스턴스에 서지 않으므로 새 경로를 세우지 않고 이미 선 값의 그 칸만 바꾼 것을 리터럴로 든다.
-/
-- DD:CF-3839
theorem collateral_share_answer_pins_each_conjunct :
    haircutGridDisclosure.answersCollateralShare = false
      ∧ discretionaryHaircutReservation.answersCollateralShare = false
      ∧ ({ haircutGridDisclosure with
            readsAppliedRate := true,
            readsPledgeDemand := true } :
              CollateralShareChannel Unit).answersCollateralShare = true
      ∧ ({ haircutGridDisclosure with
            readsAppliedRate := true } :
              CollateralShareChannel Unit).answersCollateralShare = false
      ∧ ({ haircutGridDisclosure with
            readsPledgeDemand := true } :
              CollateralShareChannel Unit).answersCollateralShare = false := by
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

/--
제공별 몫의 관측이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 경로 목록에서 답이 성립으로 서야 한다. 그 관측은 그 몫의 값이 공시에서 재어진다는 뜻이며, 그러면
이 페이즈가 회계층에 세운 몫의 판정이 공시된 값으로 닫히고 그 결손이 기록될 자리가 없다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 타입으로 서는 것을 보이고, 그 등재가 이 페이즈가
회계층에 세운 판정의 두 재료에서 실제로 선다는 것이 이 정리의 산출이므로 기여 목록에 든다.
-/
-- DD:CF-3839
theorem collateral_share_observed_undetermined :
    collateralShareObserved collateralShareChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

end CrisisFramework.Observation
