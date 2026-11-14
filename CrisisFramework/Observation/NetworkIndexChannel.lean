/-
관측층 — 망의 색인이 공시에서 어떻게 관측되는가

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원이며 수치 리터럴도
      금지), L-9(import 방향은 단방향), A-1(`axiom` 금지), A-3(witness 의무), A-8(변이 검사와
      논리 결합의 증거), C-1·C-2(`noncomputable` 과 `Classical` 금지), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-8(witness 의 서술),
      T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시), T-6(존재 형태).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 축을 내는가만 `Bool` 로 들고, 시점과 주체는
매개변수로 받아 구체 타입을 박지 않는다.

**이 파일이 세우는 것은 망의 색인이 공표 수치에서 어떻게 관측되는가 또는 관측되지 않는가다.** 한
쌍이 그 망에 드는지를 내는 것과 그 망의 쌍 전량을 내는 것이 다른 축이며, 두 축을 한 칸으로 접으면
자기 쌍만 내는 공시가 전량을 내는 것으로 서고 그 결손이 사라진다.

**완비성을 내는 경로가 실재하되 그 값의 성질이 공식 보고가 아닌 것이 이 파일의 산출이다.** 각
발행자의 공시가 자기 상대방만 드는 데 비해 제삼자의 분석이 빠진 쪽을 서술하므로, 그 결손이 소스의
부재가 아니라 공표의 재량 밖에 있다는 것이 그 자리에서 선다.

**이 파일이 답할 항 하나를 내린다.** 그 항이 주체와 시점과 그 시점의 망 종류 셋을 받는데 앞의 둘이
앞 아크들에서 이미 서고 셋째가 추상 매개변수로 남아 있었으며, 정의층이 그 열거를 세우고 이 파일이
상수 족으로 그 자리를 채운다. **제재의 절단 자체는 외생으로 받는다.** 시점 t 에 주체 n 이 어느
층에서 잘렸는가는 정의층 술어이고 그 시점열은 동학층의 외생 입력이며 시점열이 데이터이지 모형이
아니므로, 조립 선언이 그 절단을 함수로 받고 새 정의층 타입을 세우지 않는다.

**경로 전량을 훑는 판정을 목록 전칭이 아니라 목록 접기로 둔다.** 전칭으로 두면 목록 멤버십을 푸는
증명이 명제 외연성을 끌어오는데 접기로 두면 계산으로 닫혀 공리가 비며, 관측층의 공리 기준선이
비어 있으므로 그 차이가 기준선 초과를 가른다.

**정리의 증명과 적재 선언은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며,
이 파일이 딛는 적재 선언도 집행이 쓴다. 그 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고
결론을 부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.NetworkKind
import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

open CrisisFramework.Definition

/--
망의 색인을 내는 공시 경로.

**대응 비형식 개념:** 한 공시가 어느 종류의 망에서 어느 쌍이 이어지는지를 내는가. 경로마다 내는
종류가 다르고 같은 종류를 내는 경로 사이에서도 내는 범위가 다르므로 그 갈림을 칸으로 든다.

**이 정의가 배제하는 사례:**
한 발행자의 상대방 표가 그 망의 쌍 전량을 낸다고 보는 읽기. 그 표를 훑은 기록이 그 표가 이 발행자의
상대방만 들고 그 상대방들이 서로 맺은 약정을 들지 않는다고 적으므로, 전량을 낸다고 보면 그 밖의
쌍이 이어지지 않은 것으로 선다.
조달처: E-60 §4-1 「그 상대방들이 서로 또는 제삼자와 맺은 약정을 들지 않는다」

**기각한 대체 정의:**
한 쌍이 드는지를 내는가와 그 망의 쌍 전량을 내는가를 한 칸으로 접는 안. 칸이 짧아지나 자기 쌍만
내는 공시와 전량을 내는 공시가 같은 값으로 서고, 앞은 그 발행자를 한쪽 끝으로 갖는 쌍만 유도되는데
뒤는 그렇지 않으므로 그 갈림이 사라진다. 경로를 종류마다 따로 세우는 안도 기각했다. 한 공시가 여러
종류를 함께 내는 자리가 있고 그 공시의 수취인과 값의 성질이 종류마다 중복으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-3743
structure NetworkIndexChannel (Node : Type) where
  /-- 그 경로가 그 종류의 망을 내는가. -/
  readsKind : NetworkKind → Bool
  /-- 그 경로가 한 쌍이 그 망에 드는지를 내는가. -/
  readsMembership : Bool
  /-- 그 경로가 그 망의 쌍 전량을 내는가. -/
  readsCompleteness : Bool
  /-- 그 경로가 자기 노드를 한쪽 끝으로 갖는 쌍만 내는가. -/
  coversOwnPairsOnly : Bool
  /-- 그 경로가 그 종류가 그 시점에 섰는지를 내는가. -/
  readsVintage : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/--
발행자가 자기 상대방 표를 공표하는 경로.

**대응 비형식 개념:** 망의 한쪽 끝에 선 주체가 자기 상대방을 표로 내는 공시. 한 발행자의 정책 수단
면이 상대방을 열거하고 축마다 칸을 둔다.

**이 정의가 배제하는 사례:**
그 표가 망의 쌍 전량을 낸다고 보는 읽기. 그 표를 훑은 기록이 그 상대방들이 서로 또는 제삼자와 맺은
약정을 들지 않는다고 적으므로, 전량을 낸다고 보면 그 밖의 쌍이 이어지지 않은 것으로 선다.
조달처: E-60 §4-1 「그래서 도달 범위의 쌍별 값이 한 문면에서 유도되지 않는다」

**기각한 대체 정의:**
발행자의 공시를 종류마다 갈라 여러 경로로 세우는 안. 결손이 종류별로 보이나 같은 표에서 읽히는
종류들이 서로 다른 경로로 갈려 그 표가 자기 쌍만 낸다는 사실이 종류마다 중복으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-3743
def issuerCounterpartyTable : NetworkIndexChannel Unit where
  readsKind := fun k =>
    match k with
    | NetworkKind.collateralPledge => false
    | NetworkKind.ownershipShare => false
    | NetworkKind.centralBankSwap => true
    | NetworkKind.currencyMismatchTransmission => false
    | NetworkKind.tradeFinanceLink => false
  readsMembership := true
  readsCompleteness := false
  coversOwnPairsOnly := true
  readsVintage := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
제삼자가 그 망 전체를 분석하는 경로.

**대응 비형식 개념:** 망의 바깥에 선 쪽이 그 망의 구성과 빠진 쪽을 함께 서술하는 문면. 한 공공
기관의 분석이 그 망이 어느 주체를 계속 배제하는지를 적는다.

**이 정의가 배제하는 사례:**
그 분석의 값을 공식 자료로 보는 읽기. 그 분석을 훑은 기록이 중앙은행이 상대방 선택과 조건의 상세를
주지 않으므로 그 기준의 측정 소스가 공시가 아니라 연구의 추정이라고 적으므로, 공식으로 보면 유도의
불확실성이 값의 성질에서 사라진다.
조달처: E-62 §8-3 「그 기준의 측정 소스가 공시가 아니라 연구의 추정이다」

**기각한 대체 정의:**
제삼자의 분석을 경로 목록에서 빼는 안. 공식 자료만 남아 목록이 깔끔해지나 완비성을 내는 자리가
실재한다는 사실이 사라지고, 그러면 그 축의 결손이 어디에도 값이 없다는 뜻으로 읽힌다.

**값을 담지 않는다.**
-/
-- DD:CF-3743
def thirdPartyNetworkStudy : NetworkIndexChannel Unit where
  readsKind := fun k =>
    match k with
    | NetworkKind.collateralPledge => false
    | NetworkKind.ownershipShare => false
    | NetworkKind.centralBankSwap => true
    | NetworkKind.currencyMismatchTransmission => false
    | NetworkKind.tradeFinanceLink => false
  readsMembership := true
  readsCompleteness := true
  coversOwnPairsOnly := false
  readsVintage := true
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.staffEstimate

/--
교역 금융의 흐름을 집계하는 등록부 경로.

**대응 비형식 개념:** 교역에 붙는 자금조달 다리를 자료 원천이 내는 자리. 한 보고서가 원천마다 보는
것과 보지 못하는 것을 표로 가른다.

**이 정의가 배제하는 사례:**
그 등록부가 교역 금융 다리의 쌍을 내는 자리라고 보는 읽기. 그 보고서를 훑은 기록이 은행 쪽 원천은
은행이 개입하는 방식만 보고 선지급과 후지급을 가르는 것은 기업 쪽 원천뿐이라고 적어 한 원천이 그
종류를 보면서 어떤 축은 내지 않음을 밝히므로, 쌍을 낸다고 보면 그 집계가 쌍별 값으로 읽힌다.
조달처: E-24 §3-3 「은행 쪽 원천은 은행이 개입하는 방식만 보고, 선지급과 후지급을 가르는 것은 기업 쪽 원천뿐이다」

**기각한 대체 정의:**
그 등록부를 경로 목록에서 빼는 안. 쌍을 내지 않는 경로가 사라져 목록이 짧아지나 그 종류의 망에 대해
어느 축도 내지 않는 자리가 실재한다는 사실이 목록에서 지워지고, 관측층에 등재되는 소스 없음이 주요
산출물이라는 요구가 그 자리에서 집행되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3743
def tradeFinanceRegistry : NetworkIndexChannel Unit where
  readsKind := fun k =>
    match k with
    | NetworkKind.collateralPledge => false
    | NetworkKind.ownershipShare => false
    | NetworkKind.centralBankSwap => false
    | NetworkKind.currencyMismatchTransmission => false
    | NetworkKind.tradeFinanceLink => true
  readsMembership := false
  readsCompleteness := false
  coversOwnPairsOnly := false
  readsVintage := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
망의 색인을 내는 경로의 목록.

**대응 비형식 개념:** 외부 관측자가 그 망의 구성을 읽을 수 있는 자리의 전량. 목록 전량을 훑는
판정이 이 목록에 걸린다.

**이 정의가 배제하는 사례:**
어느 축도 내지 않는 경로를 목록에서 빼는 읽기. 한 보고서를 훑은 기록이 원천마다 보는 것과 보지
못하는 것이 갈리는 표를 들고 그것이 관측 명세를 원천으로 색인하는 근거라고 적으므로, 빼면 그 색인이
원천 전량을 덮지 않고 아무것도 내지 않는다는 사실이 목록에서 사라진다.
조달처: E-24 §3-3 「관측 명세를 원천, 곧 공시 경로로 색인하는 근거다」

**기각한 대체 정의:**
경로를 수취인으로 걸러 공표되는 것만 목록에 두는 안. 이 목록의 세 경로가 전부 일반 관측자를
수취인으로 두어 그 거르기가 지금은 아무것도 걸러 내지 않으나, 걸러 내는 자리를 매번 다시 세우면
목록 전량을 훑는 판정이 그 거르기의 결과에 걸려 한 자리에 고정되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3743
def networkIndexChannels : List (NetworkIndexChannel Unit) :=
  [issuerCounterpartyTable, thirdPartyNetworkStudy, tradeFinanceRegistry]

/--
그 경로 목록이 그 종류의 망에서 쌍의 이어짐을 내는가.

**대응 비형식 개념:** 한 종류의 망에 대해 어느 쌍이 이어지는지를 읽을 수 있는가. 그 종류를 내는
경로가 있어도 그 경로가 쌍을 내지 않으면 이어짐이 서지 않으므로 두 칸이 함께 서야 한다.

**이 정의가 배제하는 사례:**
그 종류를 내는 경로가 있으면 그 망의 쌍이 읽힌다고 보는 읽기. 한 보고서를 훑은 기록이 은행 쪽
원천은 은행이 개입하는 방식만 본다고 적어 그 원천이 종류를 내면서 어떤 축은 내지 않음을 밝히므로,
종류만 보면 그 결손이 사라지고 집계가 쌍별 값으로 읽힌다.
조달처: E-24 §3-3 「은행 쪽 원천은 은행이 개입하는 방식만 보고, 선지급과 후지급을 가르는 것은 기업 쪽 원천뿐이다」

**기각한 대체 정의:**
종류를 내는 경로와 쌍을 내는 경로가 따로 있으면 이어짐이 읽힌다고 보는 안. 더 많은 자리에서 참이
되나 한 경로가 둘을 함께 내야 한다는 요구가 사라져 다른 종류의 쌍을 내는 경로가 이 종류의 이어짐을
메우는 것으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-3743
def readsNetworkCut {Node : Type} (chs : List (NetworkIndexChannel Node))
    (k : NetworkKind) : Bool :=
  chs.any (fun c => c.readsKind k && c.readsMembership)

/--
그 경로 목록이 그 종류의 망에서 쌍 전량을 내는가.

**대응 비형식 개념:** 한 종류의 망에 대해 빠진 쌍이 없음을 읽을 수 있는가. 이어짐을 내는 것과
전량을 내는 것이 다른 축이므로 그 판정이 따로 선다.

**이 정의가 배제하는 사례:**
한 발행자의 상대방 표가 그 망의 전량을 낸다고 보는 읽기. 그 표를 훑은 기록이 그 상대방들이 서로
또는 제삼자와 맺은 약정을 들지 않는다고 적으므로, 전량을 낸다고 보면 두 발행자의 공시를 맞대야
서는 값이 한 문면에서 유도되는 것으로 선다.
조달처: E-60 §4-1 「그 상대방들이 서로 또는 제삼자와 맺은 약정을 들지 않는다」

**기각한 대체 정의:**
전량을 내는가를 자기 쌍만 내는가의 부정으로 두는 안. 칸이 하나 줄지만 자기 쌍만 내지 않는 경로가
전량을 내는 것으로 서며, 어느 축도 내지 않는 경로가 그 부정에서 참이 되어 아무것도 내지 않는 자리가
전량을 내는 자리로 둔갑한다.

**값을 담지 않는다.**
-/
-- DD:CF-3743
def readsNetworkCompleteness {Node : Type} (chs : List (NetworkIndexChannel Node))
    (k : NetworkKind) : Bool :=
  chs.any (fun c => c.readsKind k && c.readsCompleteness)

/--
어느 공식 보고 경로도 그 망의 쌍 전량을 내지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
값의 성질이 공식 보고인 경로 가운데 전량을 내는 것이 하나라도 있어야 한다. 그 관측은 완비성의
결손이 공표의 재량에서 오지 않는다는 뜻이며, 그러면 이 파일이 세우는 산출의 근거가 사라진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 완비성을 내는 자리가 실재하되 그 값의 성질이 공식이 아니라는 것이 이 파일의
산출이고, 관측층에 등재되는 소스 없음이 주요 산출물이라는 요구가 이 자리에서 성질의 갈림으로 서므로
기여 목록에 든다.

**증명은 집행 증분이다.** 길은 목록을 접어 계산으로 닫는 것이다. 목록 멤버십의 전칭으로 두지 않는
사유는 그 꼴이 명제 외연성을 끌어오는데 관측층의 공리 기준선이 비어 있다는 데 있다. 이 진술이 증명
가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께
확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-3743
theorem no_official_channel_reads_completeness :
    networkIndexChannels.all (fun c =>
      !c.readsCompleteness
        || !decide (c.provenance = MeasurementProvenance.officialReport)) = true := by
  rfl

/--
전량을 내는 경로가 실재하고 그 값의 성질이 추정이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
전량을 내는 경로가 아예 없거나, 그 경로의 값 성질이 공식 보고여야 한다. 앞의 관측은 그 축에 값이
어디에도 없다는 뜻이고 뒤의 관측은 앞 정리와 부딪히므로, 이 명제가 그 결손이 소스의 부재가 아니라
공표의 재량에서 온다는 것을 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 소스 없음과 성질의 갈림이 다른 사실임을 보이므로 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 그 경로의 두 칸을 계산으로 닫는 것이며, 성질의 비동일을 부정 형태가
아니라 판정의 거짓으로 적어 명제 외연성을 끌어오지 않게 한다. 이 진술이 증명 가능함을 결정 세션의
사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지
않는다.
-/
-- DD:CF-3743
theorem completeness_read_only_by_estimate :
    thirdPartyNetworkStudy.readsCompleteness = true
      ∧ decide (thirdPartyNetworkStudy.provenance = MeasurementProvenance.officialReport) = false
      ∧ issuerCounterpartyTable.readsCompleteness = false := by
  exact ⟨rfl, rfl, rfl⟩

/--
이어짐을 내는 종류와 내지 않는 종류가 둘 다 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록이 망의 종류 전량에 대해 같은 값을 내야 한다. 그 관측은 측정 가능성이 종류에 걸리지 않는다는
뜻이며, 그러면 종류를 가른 것이 관측의 축에서 아무것도 바꾸지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
종류마다 갈린다는 것은 양쪽이 실제로 서는 종류를 들어야 보이고, 임의의 종류에 대한 전칭으로는 그
갈림이 진술되지 않는다. 시스템 수준의 공표 경계가 개별 종류의 이어짐 칸을 결정하지 않는 자리다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 측정 가능성이 망의 종류에 붙는다는 것을 보이므로 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 목록을 두 종류에서 각각 접어 계산으로 닫는 것이다. 존재를 목록
멤버십으로 적지 않고 접기로 적는 사유는 그 꼴이 공리를 끌어오지 않고 계산 가능성을 지킨다는 데
있다. 이 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에
실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-3743
theorem cut_splits_across_kinds :
    readsNetworkCut networkIndexChannels NetworkKind.centralBankSwap = true
      ∧ readsNetworkCut networkIndexChannels NetworkKind.tradeFinanceLink = false := by
  exact ⟨rfl, rfl⟩

/--
두 판정이 각 인자에서 홀로 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정들이 어느 인자 하나만 참인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는
뜻이며, 그러면 종류만 내고 쌍을 내지 않는 경로가 이어짐을 내는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로,
각 인자가 홀로 참인 자리를 이 정리가 든다.

**증명은 집행 증분이다.** 길은 여섯 값을 각각 계산으로 닫는 것이다. 이 진술이 증명 가능함을 결정
세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은
싣지 않는다.
-/
-- DD:CF-3743
theorem reads_pin_each_conjunct :
    readsNetworkCut [tradeFinanceRegistry] NetworkKind.tradeFinanceLink = false
      ∧ readsNetworkCut [issuerCounterpartyTable] NetworkKind.collateralPledge = false
      ∧ readsNetworkCut [issuerCounterpartyTable] NetworkKind.centralBankSwap = true
      ∧ readsNetworkCompleteness [issuerCounterpartyTable] NetworkKind.centralBankSwap = false
      ∧ readsNetworkCompleteness [thirdPartyNetworkStudy] NetworkKind.collateralPledge = false
      ∧ readsNetworkCompleteness [thirdPartyNetworkStudy] NetworkKind.centralBankSwap = true := by
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
답할 항을 경로 목록과 절단의 족에 걸어 조립한다.

**대응 비형식 개념:** 제재의 문면이 어느 망을 자르는지를 묻는 물음의 답이 그 망의 색인을 내는 공시에
걸린다는 사실. 그 종류의 이어짐을 읽을 자리가 서면 절단의 값을 참거짓으로 내고 서지 않으면 측정
소스 없음을 낸다.

**이 정의가 배제하는 사례:**
그 물음의 측정 가능성이 주체에 붙는다고 보는 읽기. 한 공공 기관의 분석을 훑은 기록이 그 선진국 망이
신흥국을 계속 배제한다고 적어 종류마다 드는 주체가 갈리는 것을 밝히므로, 주체에 붙는다고 보면 한
종류에서 서고 다른 종류에서 서지 않는 자리가 담기지 않는다.
조달처: E-62 §4-1 「그 선진국 망이 일부 신흥국이 그 발행자와 스왑 약정을 체결하려 했는데도 신흥국을 계속 배제한다고 적는다」

**기각한 대체 정의:**
절단의 술어를 정의층 구조체로 세워 이 선언이 그것을 받게 하는 안. 타입이 하나 늘고 그 구조체가
실제 문면에서 조달한 배제 사례를 요구하는데, 제재의 시점열이 동학층의 외생 입력이고 시점열이
데이터이지 모형이 아니라는 판정이 이미 서 있으므로 그 구조체가 담을 것이 함수 하나다. 전량을 내는
경로가 없으면 답을 내지 않는 안도 기각했다. 이 물음이 한 주체가 잘렸는지를 묻고 빠진 쌍이 없음을
묻지 않으므로, 완비성을 요구하면 답이 서는 자리가 과하게 좁아진다.

**값을 담지 않는다.**
-/
-- DD:CF-3744
def sanctionTextCutVia {Time Node : Type}
    (chs : List (NetworkIndexChannel Node))
    (cut : Time → Node → NetworkKind → Bool) :
    CQ.SanctionTextCut Time Node (fun _ => NetworkKind) where
  answer := fun n t k =>
    if readsNetworkCut chs k then
      (if cut t n k then ObservedTruth.holds else ObservedTruth.fails)
    else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
어느 주체도 어느 종류에서도 자르지 않는 절단의 족.

**대응 비형식 개념:** 절단이 외생이라는 것을 증거에서 드러내는 값이며, 정리 둘이 이 값을 딛는다.

**이 정의가 배제하는 사례:**
절단의 값이 답을 가른다고 보는 자리. 이 족이 어느 자리에서도 거짓을 내는데 아래 정리가 종류에 따라
답이 갈리는 것을 들므로, 그 갈림이 절단의 값에서 오지 않고 경로의 구성에서 온다는 것이 이 값으로
재어진다. 절단에 참을 주는 값을 쓰면 그 갈림이 어느 쪽에서 왔는지가 흐려진다.
조달처: E-62 §8-3 「중앙은행이 상대방 선택과 조건의 상세를 주지 않는다고 이 편이 적으므로」

**기각한 대체 정의:**
절단이 어느 종류에서 참을 내는 값을 증거로 두는 안. 성립과 불성립을 함께 보일 수 있으나 이 파일이
드는 것은 절단의 값이 아니라 그 값을 읽을 자리가 있는가이며, 참을 주면 그 둘이 한 증거에 섞인다.

**값을 담지 않는다.**
-/
-- DD:CF-3744
def noSanctionCut : Unit → Unit → NetworkKind → Bool := fun _ _ _ => false

/--
이어짐을 읽을 자리가 없는 종류에서 답이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 종류에서 답이 참거짓으로 서야 한다. 그 관측은 답이 경로의 구성에 걸리지 않는다는 뜻이며,
그러면 읽을 자리가 없는 자리와 있는 자리가 같은 답을 내어 소스 없음이 답으로 둔갑한다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 타입으로 서는 것을 보이고, 그 등재가 이 아크가
내리는 항의 답에서 실제로 선다는 것이 이 정리의 산출이므로 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 경로 목록을 접고 분기를 계산으로 닫는 것이다. 이 진술이 증명
가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께
확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-3744
theorem sanction_answer_undetermined_when_kind_unread :
    (sanctionTextCutVia networkIndexChannels noSanctionCut).answer ()
        () NetworkKind.collateralPledge
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  rfl

/--
같은 절단의 족 아래에서 답이 망의 종류에 따라 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
종류를 바꾸어도 답이 같아야 한다. 그 관측은 종류를 가른 것이 답에서 아무것도 바꾸지 않는다는 뜻이며,
그러면 망의 종류를 열거로 세운 것이 이 항의 답에 닿지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
답이 종류에 걸린다는 것은 갈리는 두 종류를 실제로 들어야 보이고, 임의의 두 종류에 대한 전칭으로는
그 갈림이 진술되지 않는다. 경로 목록이 종류 전량에 같은 값을 주는 배치를 가질 수 있으므로 전칭은
거짓이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 이 아크가 내리는 항의 셋째 인자가 실물로 서고 그 인자가 답을 실제로 가른다는
것을 보이므로 기여 목록에 든다.

**증명은 집행 증분이다.** 길은 두 답을 각각 계산으로 닫고 비동일을 판정의 거짓으로 적는 것이다. 이
진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도
함께 확인했으나, 쓴 전술은 싣지 않는다.
-/
-- DD:CF-3744
theorem sanction_answer_splits_on_kind :
    decide ((sanctionTextCutVia networkIndexChannels noSanctionCut).answer ()
          () NetworkKind.centralBankSwap
        = (sanctionTextCutVia networkIndexChannels noSanctionCut).answer ()
            () NetworkKind.tradeFinanceLink) = false := by
  rfl

/-- witness (A-3). **무엇을 증거하는가.** 공시 경로 구조체가 비어 있지 않다. 어느 종류도 어느
축도 내지 않는 경로 하나를 든다. -/
-- DD:CF-3743
def NetworkIndexChannel.trivial : NetworkIndexChannel Unit where
  readsKind := fun _ => false
  readsMembership := false
  readsCompleteness := false
  coversOwnPairsOnly := false
  readsVintage := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

end CrisisFramework.Observation
