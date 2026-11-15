/-
관측층 — 제약이 낸 이어짐이 공시에서 어떻게 관측되는가

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원이며 수치 리터럴도
      금지), L-9(import 방향은 단방향), A-1(`axiom` 금지), A-3(witness 의무), A-8(변이 검사와
      논리 결합의 증거), C-1·C-2(`noncomputable` 과 `Classical` 금지), C-3(판정 술어의 결정
      가능성), C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시), T-6(존재 형태),
      W-11(관측층을 정의층과 같은 페이즈에서 병행한다).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 축을 내는가만 `Bool` 로 들고, 주체는 매개변수로
받아 구체 타입을 박지 않는다.

**이 파일이 세우는 것은 제약이 낸 이어짐이 공시에서 어떻게 관측되는가 또는 관측되지 않는가다.** 한
노드에 걸린 제약의 적격 판정이 공시에서 읽히는 것과 그 판정이 낸 이어짐의 쌍이 공시에서 읽히는 것이
다른 축이며, 두 축을 한 칸으로 접으면 앞만 읽히는 경로가 둘을 다 내는 것으로 서고 그러면 뒤의 결손이
사라진다.

**적격 판정을 내는 경로가 실재하되 그 판정이 낸 쌍을 내는 경로가 없는 것이 이 파일의 산출이다.**
적격성이 시점 함수로 공표되는 데 비해 어느 자산이 실제로 담보로 제공됐는지는 분류 없는 단일 금액으로만
서므로, 그 결손이 재야 할 것이 정해지지 않은 데서 오지 않고 그것을 내는 자리가 없는 데서 온다는 것이
그 자리에서 선다.

**이어짐의 축을 두 경로에서 재고 한 경로에서 재지 않는다.** 이 파일이 세우는 경로 목록이 그 축을
거짓으로 내는 것과 앞 페이즈가 세운 망 색인 경로 목록이 담보 제공의 종류에서 그 축을 거짓으로 내는
것이 서로 독립이며, 한 경로에서만 재면 그 거짓이 이 파일의 칸을 적은 방식에서 오는지 공시의 성질에서
오는지가 갈리지 않는다.

**경로 전량을 훑는 판정을 목록 전칭이 아니라 목록 접기로 둔다.** 전칭으로 두면 목록 멤버십을 푸는
증명이 명제 외연성을 끌어오는데 접기로 두면 계산으로 닫혀 공리가 비며, 관측층의 공리 기준선이 비어
있으므로 그 차이가 기준선 초과를 가른다.

**정리의 증명과 적재 선언은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며, 이
파일이 딛는 적재 선언도 집행이 쓴다. 그 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을
부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.NetworkKind
import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.NetworkIndexChannel
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

open CrisisFramework.Definition

/--
제약이 낸 이어짐을 내는 공시 경로.

**대응 비형식 개념:** 한 공시가 제약이 낸 이어짐의 어느 축을 내는가. 그 사상이 받는 적격 판정을
내는 축과 그 판정이 낸 쌍을 내는 축이 경로마다 따로 갈리므로 그 갈림을 칸으로 든다.

**이 정의가 배제하는 사례:**
적격 판정을 공표하는 경로가 그 판정이 낸 쌍까지 낸다고 보는 읽기. 회계기준을 훑은 기록이 담보
제공분을 단일 금액으로 들고 분류를 그 자리에 걸지 않는다고 적으므로, 한 칸으로 접으면 적격성만
읽히는 자리가 쌍까지 읽히는 자리로 서고 그 결손이 사라진다.
조달처: E-45 §2-2 「어느 상품이 담보로 제공됐는지가 서지 않는다」

**기각한 대체 정의:**
적격 판정의 축을 앞서 선 제약 인자 경로의 칸에서 받아 이 구조를 세우지 않는 안. 타입이 늘지 않으나
그 경로의 칸이 자기자본과 부채 총계와 부채 측 상한을 들고 자산의 적격 판정을 들지 않으므로, 받으면
이 사상이 받는 제약과 다른 제약의 인자가 축으로 선다. 수취인과 값의 성질을 칸에서 빼는 안도
기각했다. 두 축이 같은 수취인에게 가는지와 같은 성질의 값인지가 그 결손의 해소 경로를 가르는데,
빼면 그 가름이 이 파일에서 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-3769
structure InducedLinkChannel (Node : Type) where
  /-- 그 경로가 그 사상이 받는 제약의 적격 판정을 내는가. -/
  readsInducingConstraint : Bool
  /-- 그 경로가 그 판정이 낸 쌍이 그 망에 드는지를 내는가. -/
  readsInducedMembership : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/-- witness (A-3). **무엇을 증거하는가.** `InducedLinkChannel` 이 비어 있지 않다. 두 축을
하나도 내지 않는 경로 하나를 든다. -/
-- DD:CF-3769
def InducedLinkChannel.noSource : InducedLinkChannel Unit where
  readsInducingConstraint := false
  readsInducedMembership := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
그 경로가 제약이 낸 이어짐을 답하는가.

**대응 비형식 개념:** 한 경로만으로 그 사상의 값이 재어지는가. 적격 판정과 그 판정이 낸 쌍이 둘 다
한 경로에서 읽혀야 그 사상이 그 경로에서 재어진다.

**이 정의가 배제하는 사례:**
두 경로가 축을 하나씩 내면 그 사상이 재어진다고 보는 읽기. 담보 공시를 훑은 기록이 가르는 칸을 가진
경로가 물음의 주체를 보지 않는다고 적어 두 경로의 교차가 비어 있음을 밝히므로, 경로를 가로질러
합치면 그 교차의 결손이 메워진 것으로 선다.
조달처: E-45 §3-2 「가르는 칸을 가진 경로가 물음의 주체를 보지 않는다」

**기각한 대체 정의:**
두 축의 논리합으로 두는 안. 답이 서는 자리가 늘어나나 적격 판정만 내는 경로가 그 사상을 답하는
것으로 서며, 그러면 쌍이 어디에서도 읽히지 않는다는 사실이 이 판정에서 사라진다.

**값을 담지 않는다.** 두 칸의 논리곱이며 수 타입을 언급하지 않는다.
-/
-- DD:CF-3769
def InducedLinkChannel.answersInducedLink {Node : Type}
    (ch : InducedLinkChannel Node) : Bool :=
  ch.readsInducingConstraint && ch.readsInducedMembership

/--
중앙은행이 공표하는 적격 담보 목록을 그 사상이 받는 제약을 읽는 경로로 읽은 것.

**대응 비형식 개념:** 어느 자산이 담보로 받아들여지는지를 공표하는 목록을 그 사상이 받는 적격
판정의 경로로 세운 것. 그 목록이 범주마다 적격 여부를 들고 그 적격이 시점에 따라 바뀐다.

**이 정의가 배제하는 사례:**
그 목록이 적격 판정을 다한다고 보는 읽기. 그 공시를 훑은 기록이 그 중앙은행이 어느 개별 증권에든
언제든 추가 할인율을 적용할 권리를 유보한다고 적으므로, 다한다고 보면 공표된 목록과 실제 판정이
갈리는 자리가 이 경로의 칸에서 사라진다. 이 선언이 드는 것은 적격 판정의 문면이 그 목록에 선다는
것이고 그 문면이 판정을 다한다는 것이 아니다.
조달처: E-49 §2-13 「어느 개별 증권에든 언제든 추가 할인율을 적용할 권리를 유보하며, 이미 인도된 거래의 담보에도 그렇게 한다」

**기각한 대체 정의:**
이 경로를 세우지 않고 적격 판정의 축을 어느 경로도 내지 않는 것으로 두는 안. 두 축이 함께 비어
목록이 짧아지나 적격성이 공표되는 것과 쌍이 공표되지 않는 것이 다른 사실인데, 접으면 그 둘이 한
경로의 거짓 칸으로 서고 해소 경로가 조달인 몫과 그렇지 않은 몫이 갈리지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3769
def eligibleCollateralList : InducedLinkChannel Unit where
  readsInducingConstraint := true
  readsInducedMembership := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
담보 제공분의 주석을 그 판정이 낸 쌍을 읽는 경로로 읽은 것.

**대응 비형식 개념:** 담보로 제공된 자산을 금액으로 드는 공시 주석을 그 사상이 낸 쌍의 경로로 세운
것. 그 주석이 제공분의 금액을 들되 어느 자산이 누구에게 제공됐는지를 들지 않는다.

**이 정의가 배제하는 사례:**
그 주석이 어느 자산이 담보로 제공됐는지를 낸다고 보는 읽기. 회계기준 셋을 훑은 기록이 재고자산의
분류별 장부금액을 요구하는 조항과 담보 제공분을 단일 금액으로 드는 조항을 가르고 뒤가 앞의 분류를
그 자리에 걸지 않는다고 적으므로, 낸다고 보면 분류 없는 총계가 쌍별 값으로 읽힌다.
조달처: E-45 §2-2 「담보 제공분을 단일 금액으로 들고 (b) 의 분류를 그 자리에 걸지 않는다」

**기각한 대체 정의:**
이 경로를 적격 판정의 축도 내는 것으로 두는 안. 한 경로가 두 축을 내어 그 사상이 재어지나 그 주석이
드는 것은 제공된 금액이고 그 자산이 담보로 받아들여지는지의 판정이 아니므로, 두면 공시가 내지 않는
축이 내는 것으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-3769
def pledgedAssetNote : InducedLinkChannel Unit where
  readsInducingConstraint := false
  readsInducedMembership := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
제약이 낸 이어짐을 내는 경로의 목록.

**대응 비형식 개념:** 외부 관측자가 그 사상의 두 축을 읽을 수 있는 자리의 전량. 목록 전량을 훑는
판정이 이 목록에 걸린다.

**이 정의가 배제하는 사례:**
어느 축도 내지 않는 경로를 목록에서 빼는 읽기. 담보 공시를 훑은 기록이 두 경로가 교차로 비어 있고
그 교차가 둘이라고 적어 비어 있는 자리를 원소로 세므로, 빼면 그 교차의 결손이 목록에서 지워지고
남은 경로가 축을 하나씩 덮는 것으로 읽힌다.
조달처: E-45 §3-2 「제공하지 않은 자산을 가르는 경로는 교역 주체를 보지 않고」

**기각한 대체 정의:**
적격 판정을 내는 경로만 목록에 두는 안. 목록이 짧아지고 전량을 훑는 판정의 값이 달라지지 않으나,
쌍을 내는 축이 거짓인 경로가 실재한다는 사실이 사라져 그 축의 결손이 경로의 부재로 읽힌다.

**값을 담지 않는다.**
-/
-- DD:CF-3769
def inducedLinkChannels : List (InducedLinkChannel Unit) :=
  [eligibleCollateralList, pledgedAssetNote]

/--
앞 페이즈가 세운 망 색인 경로가 담보 제공의 종류에서 쌍의 이어짐을 내는가.

**대응 비형식 개념:** 이 사상이 낸 이어짐의 축을 이 파일의 칸이 아니라 이미 선 망 색인 경로 목록에서
받은 값. 같은 축을 두 경로에서 재는 자리이며 두 값이 서로 독립이다.

**이 정의가 배제하는 사례:**
이 파일의 칸이 그 축을 거짓으로 내므로 그 축이 공시에서 읽히지 않는다고 보는 읽기. 망 색인 경로를
세운 자리가 자기 쌍만 내는 공시와 전량을 내는 공시를 가르고 교역 금융의 다리에서 어느 축도 내지
않는 경로를 원소로 두므로, 한 경로에서만 재면 그 거짓이 칸을 적은 방식에서 오는지 공시의 성질에서
오는지가 갈리지 않는다.
조달처: E-24 §3-3 「관측 명세를 원천, 곧 공시 경로로 색인하는 근거다」

**기각한 대체 정의:**
이 선언을 세우지 않고 이 파일의 칸만으로 그 축을 내는 안. 선언이 하나 줄고 목록 전량을 훑는 판정이
그대로 서나, 같은 축의 값이 한 경로에서만 나와 그 값이 공시의 성질을 재는지 이 파일의 칸을 재는지가
구별되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3769
def pledgeMembershipReadByIndex : Bool :=
  readsNetworkCut networkIndexChannels NetworkKind.collateralPledge

/--
제약이 낸 이어짐이 그 경로 목록에서 관측되는가.

**대응 비형식 개념:** 그 사상의 값을 외부 관측자가 낼 수 있는가. 낼 수 있으면 성립을 내고 낼 수
없으면 측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
두 축 가운데 하나라도 읽히면 답이 선다고 보는 읽기. 담보 공시를 훑은 기록이 레포로 한 상품 재고
금융이 교역 주체에 대해 어느 경로에도 서지 않는다고 적어 축을 하나씩 덮는 경로들이 그 사상을 메우지
못함을 밝히므로, 하나로 답을 세우면 그 사상이 재어지지 않는 자리가 재어진 것으로 선다.
조달처: E-45 §3-2 「레포로 한 상품 재고 금융이 교역 주체에 대해 어느 경로에도 서지 않는다」

**기각한 대체 정의:**
읽을 자리가 없을 때 구조가 그 대상을 담지 않는다는 까닭을 내는 안. 그 까닭이 형식층의 결손을 드는
자리인데 이 페이즈가 그 사상을 정의층에 세우므로 담는 대상이 있으며, 그러면 조달로 풀리는 결손이
구조의 결손으로 적힌다. 판정 불가를 쓰지 않고 거짓을 내는 안도 기각했다. 거짓은 그 쌍이 이어지지
않았다는 관측인데 읽을 자리가 없는 것은 그 관측이 아니다.

**값을 담지 않는다.**
-/
-- DD:CF-3769
def inducedLinkObserved {Node : Type}
    (chs : List (InducedLinkChannel Node)) : ObservedTruth :=
  if chs.any (fun c => c.answersInducedLink) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
어느 경로도 제약이 낸 이어짐을 답하지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
적격 판정과 그 판정이 낸 쌍을 함께 내는 경로가 하나라도 서야 한다. 그 관측은 그 사상의 값이 한
공시에서 재어진다는 뜻이며, 그러면 이 파일이 세우는 결손이 사라지고 그 사상의 관측 명세가 경로를
가로지르는 합치기 없이 닫힌다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 적격 판정을 내는 자리가 실재하는데도 그 사상이 답되지 않는다는 것이 이 파일의
산출이고, 관측층에 등재되는 소스 없음이 주요 산출물이라는 요구가 이 자리에서 두 축의 갈림으로
서므로 기여 목록에 든다.

**진술의 꼴.** 목록 멤버십의 전칭으로 두지 않는 사유는 그 꼴이 명제 외연성을 끌어오는데 관측층의
공리 기준선이 비어 있다는 데 있다.
-/
-- DD:CF-3769
theorem no_channel_answers_induced_link :
    inducedLinkChannels.all (fun c => !c.answersInducedLink) = true := by
  rfl

/--
적격 판정의 축은 읽히고 쌍의 축은 어느 경로에서도 읽히지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
적격 판정을 내는 경로가 아예 없거나, 쌍을 내는 경로가 하나라도 서야 한다. 앞의 관측은 두 축이 함께
비어 있다는 뜻이고 뒤의 관측은 그 결손이 조달로 풀린다는 뜻이므로, 이 명제가 그 결손이 두 축 가운데
뒤의 것에만 걸린다는 것을 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 소스가 아예 없는 것과 축 하나에만 없는 것이 다른 사실임을 보이고 그 갈림이
해소 경로를 가르므로 기여 목록에 든다.

**이 정리가 같은 축을 두 경로에서 잰다.** 앞의 두 항이 이 파일의 칸을 읽고 뒤의 한 항이 앞 페이즈가
세운 망 색인 경로 목록을 읽으므로, 그 축의 거짓이 이 파일의 칸을 적은 방식에서 오지 않는다.
-/
-- DD:CF-3769
theorem induced_link_axes_split :
    eligibleCollateralList.readsInducingConstraint = true
      ∧ inducedLinkChannels.all (fun c => !c.readsInducedMembership) = true
      ∧ pledgeMembershipReadByIndex = false := by
  exact ⟨rfl, rfl, rfl⟩

/--
그 판정이 각 인자에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 참인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는
뜻이며, 그러면 적격 판정만 내고 쌍을 내지 않는 경로가 그 사상을 답하는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로,
각 인자가 홀로 참인 자리를 이 정리가 든다.

**갱신 문법으로 각 인자가 홀로 참인 자리를 든다.** 두 축이 함께 참인 경로와 쌍만 참인 경로가 실재하는 인스턴스에
서지 않으므로 새 경로를 세우지 않고 이미 선 값의 그 칸만 바꾼 것을 리터럴로 든다.
-/
-- DD:CF-3769
theorem induced_link_answer_pins_each_conjunct :
    eligibleCollateralList.answersInducedLink = false
      ∧ pledgedAssetNote.answersInducedLink = false
      ∧ ({ eligibleCollateralList with
            readsInducedMembership := true } :
              InducedLinkChannel Unit).answersInducedLink = true
      ∧ ({ eligibleCollateralList with
            readsInducingConstraint := false,
            readsInducedMembership := true } :
              InducedLinkChannel Unit).answersInducedLink = false := by
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
그 사상의 관측이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 경로 목록에서 답이 성립으로 서야 한다. 그 관측은 그 사상의 값이 공시에서 재어진다는 뜻이며,
그러면 이 아크가 정의층에 세운 사상이 관측층에서 값을 갖고 그 결손이 기록될 자리가 없다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 타입으로 서는 것을 보이고, 그 등재가 이
페이즈가 정의층에 세운 사상에서 실제로 선다는 것이 이 정리의 산출이므로 기여 목록에 든다.
-/
-- DD:CF-3769
theorem induced_link_observed_undetermined :
    inducedLinkObserved inducedLinkChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

end CrisisFramework.Observation
