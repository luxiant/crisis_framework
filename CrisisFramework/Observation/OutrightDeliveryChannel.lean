/-
관측층 — 확정 인도가 공시에서 어떻게 관측되는가

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원이며 수치 리터럴도
      금지), L-9(import 방향은 단방향), A-1(`axiom` 금지), A-3(witness 의무), A-8(변이 검사와
      논리 결합의 증거), C-1·C-2(`noncomputable` 과 `Classical` 금지), C-3(판정 술어의 결정
      가능성), C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시),
      W-11(관측층을 정의층과 같은 페이즈에서 병행한다).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 축을 내는가만 `Bool` 로 들고, 주체는 매개변수로
받아 구체 타입을 박지 않는다.

**이 파일이 세우는 것은 반환 의무 없는 인도가 공시에서 관측되지 않는다는 것이다.** 소유권을 넘기는
구조로 한 금융은 재고가 장부에서 제거되어 담보 제공 공시를 비우므로, 그 인도는 공시가 잃는 바로 그
자리다.

**측정의 축을 둘로 가른다.** 내놓는 쪽과 받는 쪽이 누구인지를 내는 축과 넘어간 것이 어느 종류인지를
내는 축이며, 한 경로가 둘을 다 내야 그 인도가 그 경로에서 재어진다. 두 축을 한 칸으로 접으면 금액만
내는 경로가 둘을 다 내는 것으로 서고 그러면 당사자의 결손이 사라진다.

**그 결손이 두 축에 함께 걸리는 까닭을 경로의 범위와 포착이 든다.** 소유권이 넘어간 자산을 경제적
실질로 담는 경로는 교역 주체를 보지 않고, 교역 주체를 보는 경로는 법적 형식을 따라 그 자산을 장부에서
제거한다. 그래서 **범위와 포착을 함께 가진 경로가 없다는 것이 측정의 두 축이 함께 비는 까닭**이며, 그
교차가 비어 있음을 이 파일이 칸으로 든다.

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
확정 인도를 내는 공시 경로.

**대응 비형식 개념:** 한 공시가 반환 의무 없는 인도의 어느 축을 내는가. 측정의 두 축을 칸으로 들고,
그 두 축이 비는 까닭을 드는 범위와 포착의 칸을 함께 든다.

**이 정의가 배제하는 사례:**
담보 제공분을 금액으로 드는 주석이 넘어간 것의 종류를 낸다고 보는 읽기. 자산 부담의 공시를 훑은 기록이
재고자산의 분류별 장부금액을 요구하는 조항과 담보 제공분을 단일 금액으로 드는 조항을 가르고 뒤가 앞의
분류를 그 자리에 걸지 않는다고 적으므로, 낸다고 보면 분류 없는 총계가 종류별 값으로 읽힌다.
조달처: E-45 §2-2 「담보 제공분을 단일 금액으로 들고 (b) 의 분류를 그 자리에 걸지 않는다」

**기각한 대체 정의:**
측정의 두 축만 칸으로 두고 범위와 포착을 두지 않는 안. 타입이 줄어드나 두 축이 함께 비는 사실만 남고
그 까닭이 사라지므로, 그 결손이 공시의 항목이 모자란 데서 오는지 경로의 적용 대상이 갈린 데서 오는지가
구별되지 않는다. 수취인과 값의 성질을 칸에서 빼는 안도 기각했다. 두 축이 같은 수취인에게 가는지와 같은
성질의 값인지가 그 결손의 해소 경로를 가르는데, 빼면 그 가름이 이 파일에서 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-3808
structure OutrightDeliveryChannel (Party : Type) where
  /-- 그 경로가 내놓는 쪽과 받는 쪽이 누구인지를 내는가. -/
  readsConveyingParties : Bool
  /-- 그 경로가 넘어간 것이 어느 종류인지를 내는가. -/
  readsConveyedKind : Bool
  /-- 그 경로의 적용 대상이 교역 주체에 닿는가. -/
  coversTradingEntity : Bool
  /-- 그 경로가 소유권이 넘어간 이전을 포착하는가. -/
  capturesTitleTransfer : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/-- witness (A-3). **무엇을 증거하는가.** `OutrightDeliveryChannel` 이 비어 있지 않다. 네 칸을
하나도 내지 않는 경로 하나를 든다. -/
-- DD:CF-3808
def OutrightDeliveryChannel.noSource : OutrightDeliveryChannel Unit where
  readsConveyingParties := false
  readsConveyedKind := false
  coversTradingEntity := false
  capturesTitleTransfer := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 확정 인도를 답하는가.

**대응 비형식 개념:** 한 경로만으로 그 인도가 재어지는가. 당사자와 종류가 둘 다 한 경로에서 읽혀야 그
인도가 그 경로에서 재어진다.

**이 정의가 배제하는 사례:**
두 경로가 축을 하나씩 내면 그 인도가 재어진다고 보는 읽기. 자산 부담의 공시를 훑은 기록이 가르는 칸을
가진 경로가 물음의 주체를 보지 않는다고 적어 두 경로의 교차가 비어 있음을 밝히므로, 경로를 가로질러
합치면 그 교차의 결손이 메워진 것으로 선다.
조달처: E-45 §3-2 「가르는 칸을 가진 경로가 물음의 주체를 보지 않는다」

**기각한 대체 정의:**
두 축의 논리합으로 두는 안. 답이 서는 자리가 늘어나나 종류만 내는 경로가 그 인도를 답하는 것으로
서며, 그러면 당사자가 어디에서도 읽히지 않는다는 사실이 이 판정에서 사라진다. 범위와 포착의 칸을 이
논리곱에 함께 넣는 안도 기각했다. 그 둘은 그 경로가 무엇을 내는가가 아니라 그 경로가 어디에 닿고
무엇을 포착하는가이며, 넣으면 측정의 결손과 적용 범위의 결손이 한 판정으로 접힌다.

**값을 담지 않는다.** 두 칸의 논리곱이며 수 타입을 언급하지 않는다.
-/
-- DD:CF-3808
def OutrightDeliveryChannel.answersOutrightDelivery {Party : Type}
    (ch : OutrightDeliveryChannel Party) : Bool :=
  ch.readsConveyingParties && ch.readsConveyedKind

/--
담보로 제공된 재고자산의 주석을 확정 인도의 경로로 읽은 것.

**대응 비형식 개념:** 재고자산 가운데 담보로 제공된 것을 주석으로 내게 하는 회계기준의 요구를 확정
인도의 경로로 세운 것. 그 경로가 교역 주체에 닿되 소유권이 넘어간 자산을 장부에서 제거한다.

**이 정의가 배제하는 사례:**
그 주석이 소유권을 넘기는 구조의 재고까지 담는다고 보는 읽기. 상품 담보 금융을 읽은 기록이 레포로 한
금융은 재고가 이미 장부에서 제거되어 그 주석이 요구하는 담보로 제공된 재고자산이 아니라고 적으므로,
담는다고 보면 공시가 비는 바로 그 경우가 공시에 든 것으로 선다.
조달처: E-46 §2-4 「그래서 레포로 한 금융은 회계기준의 담보 제공 공시를 비운다」

**기각한 대체 정의:**
이 경로를 세우지 않고 어느 경로도 교역 주체에 닿지 않는 것으로 두는 안. 목록이 짧아지나 교역 주체에
닿는 경로가 실재하되 그것이 이전을 포착하지 않는 것과 닿는 경로가 아예 없는 것이 다른 사실이며,
접으면 해소 경로가 조달인 몫과 그렇지 않은 몫이 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3808
def conveyanceInventoryNote : OutrightDeliveryChannel Unit where
  readsConveyingParties := false
  readsConveyedKind := false
  coversTradingEntity := true
  capturesTitleTransfer := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
자산 부담을 경제적 원칙으로 담는 감독 공시를 확정 인도의 경로로 읽은 것.

**대응 비형식 개념:** 자산 부담을 법적 형식이 아니라 경제적 원칙으로 정의하여 소유권이 넘어간 자산까지
담는 감독 규범의 공시를 확정 인도의 경로로 세운 것. 그 경로가 그 이전을 포착하되 적용 대상이 신용기관
이어서 교역 주체에 닿지 않는다.

**이 정의가 배제하는 사례:**
그 공시가 교역 주체의 인도까지 담는다고 보는 읽기. 자산 부담의 공시를 훑은 기록이 그 가이드라인의 적용
대상이 자본요구규정의 기관이며 교역 주체인 비금융기업이 그 범위에 들지 않는다고 적으므로, 담는다고
보면 그 공시가 닿지 않는 주체의 인도가 담긴 것으로 선다.
조달처: E-45 §2-5 「교역 주체인 비금융기업이 그 범위에 들지 않는다」

**기각한 대체 정의:**
이 경로가 당사자나 종류의 축을 낸다고 두는 안. 그 공시는 부담을 진 자산의 총량을 내고 거래상대도
상품의 종류도 내지 않으므로, 낸다고 두면 사슬을 잇는 데 필요한 것이 공시에 있는 것으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-3808
def conveyanceEncumbranceReport : OutrightDeliveryChannel Unit where
  readsConveyingParties := false
  readsConveyedKind := false
  coversTradingEntity := false
  capturesTitleTransfer := true
  recipient := DisclosureRecipient.supervisor
  provenance := MeasurementProvenance.officialReport

/--
확정 인도를 내는 경로의 목록.

**대응 비형식 개념:** 외부 관측자가 그 인도의 두 축을 읽을 수 있는 자리의 전량. 목록 전량을 훑는
판정이 이 목록에 걸린다.

**이 정의가 배제하는 사례:**
두 축을 하나도 내지 않는 경로를 목록에서 빼는 읽기. 자산 부담의 공시를 훑은 기록이 레포로 한 상품 재고
금융이 교역 주체에 대해 어느 경로에도 서지 않는다고 적어 비어 있는 자리를 원소로 세므로, 빼면 그 교차의
결손이 목록에서 지워지고 남은 경로가 축을 덮는 것으로 읽힌다.
조달처: E-45 §3-2 「레포로 한 상품 재고 금융이 교역 주체에 대해 어느 경로에도 서지 않는다」

**기각한 대체 정의:**
목록을 비우고 소스 없음을 바로 적는 안. 그러면 어느 경로가 어디에 닿고 무엇을 포착하는지가 사라지고,
두 축의 결손이 한 경로의 항목이 모자란 데서 오는지 두 경로의 범위가 갈린 데서 오는지가 구별되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3808
def outrightDeliveryChannels : List (OutrightDeliveryChannel Unit) :=
  [conveyanceInventoryNote, conveyanceEncumbranceReport]

/--
확정 인도가 그 경로 목록에서 관측되는가.

**대응 비형식 개념:** 그 인도의 값을 외부 관측자가 낼 수 있는가. 낼 수 있으면 성립을 내고 낼 수 없으면
측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
두 축 가운데 하나라도 읽히면 답이 선다고 보는 읽기. 자산 부담의 공시를 훑은 기록이 레포로 한 상품 재고
금융이 교역 주체에 대해 어느 경로에도 서지 않는다고 적어 축을 하나씩 덮는 경로들이 그 인도를 메우지
못함을 밝히므로, 하나로 답을 세우면 그 인도가 재어지지 않는 자리가 재어진 것으로 선다.
조달처: E-45 §3-2 「레포로 한 상품 재고 금융이 교역 주체에 대해 어느 경로에도 서지 않는다」

**기각한 대체 정의:**
읽을 자리가 없을 때 구조가 그 대상을 담지 않는다는 까닭을 내는 안. 그 까닭이 형식층의 결손을 드는
자리인데 이 페이즈가 그 인도를 정의층에 세우므로 담는 대상이 있으며, 그러면 조달로 풀리는 결손이
구조의 결손으로 적힌다. 판정 불가를 쓰지 않고 거짓을 내는 안도 기각했다. 거짓은 그 인도가 없었다는
관측인데 읽을 자리가 없는 것은 그 관측이 아니다.

**값을 담지 않는다.** 목록 접기와 열거의 생성자만 쓴다.
-/
-- DD:CF-3808
def outrightDeliveryObserved {Party : Type}
    (chs : List (OutrightDeliveryChannel Party)) : ObservedTruth :=
  if chs.any (fun c => c.answersOutrightDelivery) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
어느 경로도 확정 인도를 답하지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
당사자와 종류를 함께 내는 경로가 하나라도 서야 한다. 그 관측은 그 인도의 값이 한 공시에서 재어진다는
뜻이며, 그러면 이 파일이 세우는 결손이 사라지고 그 인도의 관측 명세가 경로를 가로지르는 합치기 없이
닫힌다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 이 페이즈가 정의층에 세운 인도가 공시에서 답되지 않는다는 것이 이 파일의
산출이고, 관측층에 등재되는 소스 없음이 주요 산출물이라는 요구가 이 자리에서 서므로 기여 목록에 든다.

**진술의 꼴.** 목록 멤버십의 전칭으로 두지 않는 사유는 그 꼴이 명제 외연성을 끌어오는데 관측층의 공리
기준선이 비어 있다는 데 있다.
-/
-- DD:CF-3808
theorem no_channel_answers_outright_delivery :
    outrightDeliveryChannels.all (fun c => !c.answersOutrightDelivery) = true := by
  sorry

/--
측정의 두 축이 함께 비어 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
당사자를 내는 경로나 종류를 내는 경로가 하나라도 서야 한다. 그 관측은 그 결손이 두 축 가운데 하나에만
걸린다는 뜻이며, 그러면 남은 한 축의 조달만으로 그 인도가 재어지게 되어 해소 경로가 달라진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 축 하나에만 소스가 없는 것과 두 축에 함께 없는 것이 다른 사실이고 그 갈림이
해소 경로를 가르므로 기여 목록에 든다.
-/
-- DD:CF-3808
theorem outright_delivery_axes_both_absent :
    outrightDeliveryChannels.all (fun c => !c.readsConveyingParties) = true
      ∧ outrightDeliveryChannels.all (fun c => !c.readsConveyedKind) = true := by
  sorry

/--
범위와 포착의 교차가 비어 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
교역 주체에 닿으면서 소유권이 넘어간 이전을 포착하는 경로가 하나라도 서야 한다. 그 관측은 두 축이 함께
비는 까닭이 경로의 범위가 갈린 데 있지 않다는 뜻이며, 그러면 그 결손이 공시의 항목을 더하는 것만으로
풀린다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 축이 함께 비는 까닭을 이 정리가 들고, 그 까닭이 공시의 항목이 모자란 데
있지 않고 경로의 적용 대상과 포착이 어긋난 데 있다는 것이 해소 경로를 가르므로 기여 목록에 든다.

**이 정리가 범위와 포착을 따로 든다.** 교차가 비어 있다는 것만으로는 두 칸이 모두 거짓이어서 비는
경우와 하나씩 참이어서 비는 경우가 갈리지 않으므로, 각 칸이 참인 경로를 뒤의 두 항이 든다.
-/
-- DD:CF-3808
theorem outright_delivery_scope_capture_cross_empty :
    outrightDeliveryChannels.all
        (fun c => !(c.coversTradingEntity && c.capturesTitleTransfer)) = true
      ∧ conveyanceInventoryNote.coversTradingEntity = true
      ∧ conveyanceEncumbranceReport.capturesTitleTransfer = true := by
  sorry

/--
그 판정이 각 인자에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 참인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는 뜻이며,
그러면 종류만 내고 당사자를 내지 않는 경로가 그 인도를 답하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로, 각
인자가 홀로 참인 자리를 이 정리가 든다.

**갱신 문법으로 각 인자가 홀로 참인 자리를 든다.** 두 축 가운데 어느 하나만 참인 경로가 실재하는
인스턴스에 서지 않으므로 새 경로를 세우지 않고 이미 선 값의 그 칸만 바꾼 것을 리터럴로 든다.
-/
-- DD:CF-3808
theorem outright_delivery_answer_pins_each_conjunct :
    conveyanceInventoryNote.answersOutrightDelivery = false
      ∧ conveyanceEncumbranceReport.answersOutrightDelivery = false
      ∧ ({ conveyanceInventoryNote with
            readsConveyingParties := true,
            readsConveyedKind := true } :
              OutrightDeliveryChannel Unit).answersOutrightDelivery = true
      ∧ ({ conveyanceInventoryNote with
            readsConveyingParties := true } :
              OutrightDeliveryChannel Unit).answersOutrightDelivery = false
      ∧ ({ conveyanceInventoryNote with
            readsConveyedKind := true } :
              OutrightDeliveryChannel Unit).answersOutrightDelivery = false := by
  sorry

/--
그 인도의 관측이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 경로 목록에서 답이 성립으로 서야 한다. 그 관측은 그 인도의 값이 공시에서 재어진다는 뜻이며, 그러면
이 페이즈가 정의층에 세운 구조가 관측층에서 값을 갖고 그 결손이 기록될 자리가 없다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 타입으로 서는 것을 보이고, 그 등재가 이 페이즈가
정의층에 세운 구조에서 실제로 선다는 것이 이 정리의 산출이므로 기여 목록에 든다.
-/
-- DD:CF-3808
theorem outright_delivery_observed_undetermined :
    outrightDeliveryObserved outrightDeliveryChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  sorry

end CrisisFramework.Observation
