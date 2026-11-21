/-
관측층 — 제재의 문면이 어느 주체를 어느 시점에 어느 갈래에서 자르는지를 읽는 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원이며 수치 리터럴도
      금지), L-9(import 방향은 단방향), A-1(`axiom` 금지), A-3(witness 의무), A-8(변이 검사와
      논리 결합의 증거), C-1·C-2(`noncomputable` 과 `Classical` 금지), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-8(witness 의 서술),
      T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시), T-6(존재 형태).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 축을 내는가만 `Bool` 로 들고, 시점과 주체는
매개변수로 받아 구체 타입을 박지 않는다.

**이 파일이 세우는 것은 제재의 문면 자체를 읽는 경로다.** 앞 아크가 망의 색인을 읽는 경로를 세웠고
그 경로가 어느 쌍이 이어지는지를 묻는 데 비해, 이 파일의 경로는 그 문면이 어느 주체를 어느 시점에
어느 갈래에서 자르는지를 묻는다.

**이 파일의 산출은 그 셋을 한 자리에서 내는 경로가 없다는 것이다.** 조달된 조문에서 주체의 열거는
부속서에 있고 시점은 세 자리에 흩어지며 금지되는 거래의 갈래는 조의 본문에 있다. 셋을 다 내는 경로가
실재하되 그 경로가 자기를 정본이 아니라 정본을 따라 편집된 문서라고 적으므로, 그 결손이 소스의
부재가 아니라 공표의 꼴에서 온다는 것이 그 자리에서 선다.

**그 칸을 정본의 사본인가로 두지 않고 그 경로의 문면이 자기를 편집본이라고 적는가로 둔다.** 정본의
사본인지를 칸으로 두면 그렇게 적지 않은 경로에 대해 그 성질을 지어내게 되고, 읽지 않은 편의 성질을
근거로 쓰지 말라는 요구가 그 자리에 걸린다. 문면의 자기 서술로 두면 두 값이 전량 조달된 문면에서
유도된다.

**앞 아크가 세운 조립을 그대로 두고 이 페이즈의 조립을 그 옆에 둔다.** 앞의 것이 망의 색인을 읽는
경로에 미정을 걸고 이 파일의 것이 제재의 문면을 읽는 경로에 그것을 걸므로, 둘이 같은 항의 답을 다른
측정 결손에 매단다. 하나로 접으면 어느 결손이 그 미정을 낳았는지가 답에서 사라진다.

**경로 구조체에 쓰지 않는 타입 매개변수를 두지 않는다.** 앞 아크의 경로 구조체가 노드 타입을 받으면서
어느 칸도 그것을 쓰지 않는데 그 자리를 받는 판정 함수가 그 타입 위에서 일반적이어서 그 꼴이 섰다. 이
파일의 판정은 경로의 칸만 보고 주체 타입을 쓰지 않으므로 그 매개변수가 쓰이는 자리가 없으며, 선례와
갈리는 자리가 여기 하나다.

**경로 전량을 훑는 판정을 목록 전칭이 아니라 목록 접기로 둔다.** 전칭으로 두면 목록 멤버십을 푸는
증명이 명제 외연성을 끌어오는데 접기로 두면 계산으로 닫혀 공리가 비며, 관측층의 공리 기준선이 비어
있으므로 그 차이가 기준선 초과를 가른다.

**정리의 증명은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며, 그 진술이 증명
가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나,
쓴 전술은 싣지 않는다.

**적재 선언은 진술이 딛는 것만 이 파일이 들고 증명이 더 요구하는 것은 집행이 더한다.** 진술과 타입을
결정 세션이 쓰므로 그 진술이 이름을 해소하는 데 필요한 적재가 이 파일의 몫이고, 전술이 더 요구하는
적재는 그 전술을 쓰는 쪽의 몫이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.SanctionCut
import CrisisFramework.Observation.AssetCompositionChannel
import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.SwapLineChannel

namespace CrisisFramework.Observation

open CrisisFramework.Definition

/--
제재의 문면을 읽는 공표 경로.

**대응 비형식 개념:** 한 공표가 제재의 문면에서 어느 축을 내는가. 주체와 시점과 금지되는 거래의
갈래가 서로 다른 자리에 실리므로 축마다 칸을 두고, 그 셋을 한 자리에서 내는지를 따로 묻는다.

**이 정의가 배제하는 사례:**
세 축을 내는 경로가 있으면 그 셋이 한 자리에서 읽힌다고 보는 읽기. 그 조문을 훑은 기록이 주체의
열거는 부속서에 있고 시점은 세 자리에 흩어지며 망 종류는 조의 본문에 있다고 적으므로, 한 자리를 묻지
않으면 세 축을 맞추는 비용이 구조에서 사라지고 그 맞춤이 읽는 쪽의 몫이라는 사실이 지워진다.
조달처: E-68 §4-1 「주체의 열거는 부속서에 있고 시점은 세 자리에 흩어지며 망 종류는 조의 본문에 있다」

**기각한 대체 정의:**
세 축을 한 칸으로 접고 그 세 축을 다 내는 경로만 참으로 두는 안. 칸이 줄어드나 두 축만 내는 경로와 어느
축도 내지 않는 경로가 같은 값으로 서고, 그 갈림이 이 파일의 산출을 받치는 자리이므로 접으면 결손의
꼴이 사라진다. 경로가 내는 값이 정본의 사본인지를 칸으로 두는 안도 기각했다. 그렇게 적지 않은 경로에
대해 그 성질을 지어내게 되고, 읽지 않은 편의 성질을 근거로 쓰지 말라는 요구가 그 자리에 걸린다.

**값을 담지 않는다.**
-/
-- DD:CF-4428
structure SanctionCutChannel where
  /-- 그 경로가 어느 주체가 금지의 안에 서는지를 내는가. -/
  readsEntity : Bool
  /-- 그 경로가 그 금지가 어느 시점에 걸리는지를 내는가. -/
  readsTime : Bool
  /-- 그 경로가 금지되는 거래의 갈래를 내는가. -/
  readsDealKind : Bool
  /-- 그 경로가 그 셋을 한 자리에서 내는가. -/
  readsAllInOnePlace : Bool
  /-- 그 경로의 문면이 자기를 정본을 따라 편집된 것이라고 적는가. -/
  declaresEditedFromAuthentic : Bool
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient
  /-- 그 경로가 내는 값의 성질. -/
  provenance : MeasurementProvenance

/-- witness (A-3). **무엇을 증거하는가.** 경로 구조체가 비어 있지 않다. 어느 축도 내지 않고 자기를
편집본이라고도 적지 않는 경로 하나를 든다. -/
-- DD:CF-4428
def SanctionCutChannel.trivial : SanctionCutChannel where
  readsEntity := false
  readsTime := false
  readsDealKind := false
  readsAllInOnePlace := false
  declaresEditedFromAuthentic := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
금지를 세운 조문의 통합본을 읽는 경로.

**대응 비형식 개념:** 개정 행위들을 한 문면으로 모아 둔 통합본. 주체와 시점과 갈래를 다 들되 그
자리가 부속서와 개정 표지와 조의 본문으로 흩어진다.

**이 정의가 배제하는 사례:**
그 문면을 정본으로 보는 읽기. 그 통합본을 훑은 기록이 문서의 머리가 그 문면을 순전히 문서화 도구로
두고 법적 효력이 없다고 적음을 들므로, 정본으로 보면 그 경로가 내는 값의 성질이 사라지고 관보에
공표된 행위를 열어야 하는 몫이 구조에서 지워진다.
조달처: E-68 §2-1 「문서의 머리가 이 문면을 순전히 문서화 도구로 두고 법적 효력이 없다고 적으며」

**기각한 대체 정의:**
통합본을 세 축마다 다른 경로로 가르는 안. 결손이 축마다 보이나 한 문면이 셋을 함께 들므로 그 문면의
값 성질과 수취인이 셋에 중복으로 서고, 셋을 한 자리에서 내지 않는다는 이 파일의 산출이 경로의
가름으로 미리 접힌다.

**값을 담지 않는다.**
-/
-- DD:CF-4428
def consolidatedRegulationText : SanctionCutChannel where
  readsEntity := true
  readsTime := true
  readsDealKind := true
  readsAllInOnePlace := false
  declaresEditedFromAuthentic := true
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
지정 목록의 부속서 표를 읽는 경로.

**대응 비형식 개념:** 주체의 이름 옆에 발효 시점의 칸을 두는 표. 주체와 시점을 함께 내되 금지되는
거래의 갈래를 들지 않는다.

**이 정의가 배제하는 사례:**
그 칸의 표기가 한 꼴이라고 보는 읽기. 그 부속서를 훑은 기록이 그 칸의 표기 꼴이 한 표 안에서 둘로
섞인다고 적으므로, 한 꼴로 보면 그 표를 읽는 쪽이 두 꼴을 함께 받아야 하는 몫이 구조에서 사라진다.
조달처: E-68 §2-12 「그 칸의 표기 꼴이 한 표 안에서 둘로 섞인다」

**기각한 대체 정의:**
부속서의 표를 통합본의 경로에 접어 넣는 안. 경로가 하나 줄어드나 주체마다의 발효 시점을 내는 자리가 그
표뿐이므로, 접으면 그 시점이 조의 본문에서 읽히는 것과 표의 칸에서 읽히는 것이 한 값으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-4428
def designationAnnexTable : SanctionCutChannel where
  readsEntity := true
  readsTime := true
  readsDealKind := false
  readsAllInOnePlace := false
  declaresEditedFromAuthentic := true
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
제재 목록의 평면 자료 파일을 읽는 경로.

**대응 비형식 개념:** 다른 발행 주체가 자기 목록을 고정 길이와 쉼표 구분의 꼴로 내는 파일. 주체를
내되 그 지정이 언제부터 효력을 갖는지를 내지 않는다.

**이 정의가 배제하는 사례:**
그 주 표가 시점을 낸다고 보는 읽기. 그 자료 명세를 훑은 기록이 그 표가 드는 칸을 열거하는데 그
열거에 시점이 들지 않으므로, 낸다고 보면 어느 칸도 들지 않는 축이 읽히는 것으로 서고 그 결손이
공표 꼴에서 온다는 사실이 사라진다.
조달처: E-69 §2-2 「고정 길이의 주 표가 드는 칸은 고유 식별자와 이름과 유형과 제재 계획의 이름과 직함과」

**기각한 대체 정의:**
평면 자료 파일을 경로 목록에서 빼는 안. 시점을 내지 않는 경로가 사라져 목록이 짧아지나 같은 발행 주체의 다른
꼴이 그 축을 내므로 그 갈림이 공표 꼴의 축에서 온다는 것이 목록에서 지워진다.

**값을 담지 않는다.**
-/
-- DD:CF-4428
def sanctionsListFlatFile : SanctionCutChannel where
  readsEntity := true
  readsTime := false
  readsDealKind := false
  readsAllInOnePlace := false
  declaresEditedFromAuthentic := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
제재 목록의 진보된 스키마를 읽는 경로.

**대응 비형식 개념:** 같은 목록을 사건과 조치의 요소로 구조화해 내는 꼴. 주체와 시점을 함께 내되 그
조치의 갈래를 내고 금지되는 거래의 갈래를 내지 않는다.

**이 정의가 배제하는 사례:**
그 스키마의 조치 갈래를 금지되는 거래의 갈래로 보는 읽기. 그 스키마를 훑은 기록이 조치 요소가 기간을
필수 자식으로 들며 조치 갈래의 식별자를 속성으로 든다고 적으므로, 그 둘을 한 축으로 보면 조치의
이름이 망의 종류로 읽히고 그 대응이 조달된 문면에 없는 채로 선다.
조달처: E-69 §3-2 「그 요소가 기간을 필수 자식으로 들며 조치 갈래의 식별자를 속성으로 든다」

**기각한 대체 정의:**
조치의 갈래를 금지되는 거래의 갈래로 받는 안. 그 축이 채워져 보이나 조치의 갈래가 무엇을 금지하는가를
직접 들지 않으므로 그 대응을 지어내게 되고, 지어낸 대응이 이 파일의 산출을 거짓으로 만든다.

**값을 담지 않는다.**
-/
-- DD:CF-4428
def sanctionsListAdvancedSchema : SanctionCutChannel where
  readsEntity := true
  readsTime := true
  readsDealKind := false
  readsAllInOnePlace := false
  declaresEditedFromAuthentic := false
  recipient := DisclosureRecipient.publicReader
  provenance := MeasurementProvenance.officialReport

/--
제재의 문면을 읽는 경로의 목록.

**대응 비형식 개념:** 외부 관측자가 그 문면을 읽을 수 있는 자리의 전량. 목록 전량을 훑는 판정이 이
목록에 걸린다.

**이 정의가 배제하는 사례:**
같은 발행 주체의 여러 공표 꼴을 한 경로로 보는 읽기. 그 자료 명세를 훑은 기록이 명세가 각 공표에
딸린 파일을 꼴마다 열거한다고 적으므로, 하나로 보면 꼴마다 내는 축이 다르다는 것이 목록에서 사라지고
시점의 결손이 발행 주체에서 온 것으로 읽힌다.
조달처: E-69 §2-1 「명세가 각 공표에 딸린 파일을 꼴마다 열거한다」

**기각한 대체 정의:**
경로를 발행 주체로 묶어 둘만 두는 안. 목록이 짧아지나 한 주체의 두 꼴이 시점 축에서 갈리므로 그
갈림이 묶음 안으로 숨고, 그 결손이 주체의 축인지 꼴의 축인지가 목록에서 서지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-4428
def sanctionCutChannels : List SanctionCutChannel :=
  [consolidatedRegulationText, designationAnnexTable, sanctionsListFlatFile,
   sanctionsListAdvancedSchema]

/--
그 경로 목록이 세 축을 다 내는가.

**대응 비형식 개념:** 어느 경로가 주체와 시점과 금지되는 거래의 갈래를 함께 내는가. 셋을 다 내는
경로가 하나라도 있으면 그 답이 참거짓으로 설 수 있다.

**이 정의가 배제하는 사례:**
축마다 다른 경로가 내면 셋이 읽힌다고 보는 읽기. 그 조문을 훑은 기록이 그 경로가 셋을 한 자리에서
내지 않는다고 적으면서 그 셋이 어느 자리에 있는지를 각각 드므로, 경로를 가로질러 모으면 그 맞춤의
몫이 읽는 쪽에 있다는 사실이 판정에서 사라진다.
조달처: E-68 §4-1 「주체의 열거는 부속서에 있고 시점은 세 자리에 흩어지며 망 종류는 조의 본문에 있다」

**기각한 대체 정의:**
축마다 따로 접어 셋의 곱으로 두는 안. 경로를 가로질러 모으는 꼴이어서 한 경로가 셋을 함께 내야 한다는
요구가 사라지고, 두 축만 내는 경로 둘이 셋을 내는 경로 하나와 같은 값으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-4428
def readsThreeAxes (chs : List SanctionCutChannel) : Bool :=
  chs.any (fun c => c.readsEntity && c.readsTime && c.readsDealKind)

/--
그 경로 목록이 세 축을 한 자리에서 내는가.

**대응 비형식 개념:** 어느 경로가 그 셋을 한 문면의 한 자리에서 내는가. 셋을 다 내는 것과 한 자리에서
내는 것이 다른 축이므로 그 판정이 따로 선다.

**이 정의가 배제하는 사례:**
셋을 다 내는 경로가 그 셋을 한 자리에서 낸다고 보는 읽기. 그 조문을 훑은 기록이 그 경로가 셋을 한
자리에서 내지 않는다고 적으므로, 같다고 보면 이 파일의 산출이 그 자리에서 거짓이 된다.
조달처: E-68 §4-1 「다만 그 경로가 셋을 한 자리에서 내지 않는다」

**기각한 대체 정의:**
한 자리에서 내는가를 세 축을 다 내는가의 부정으로 두는 안. 칸이 하나 줄지만 두 축만 내는 경로가 한
자리에서 내는 것으로 서고, 어느 축도 내지 않는 경로가 그 부정에서 참이 되어 아무것도 내지 않는 자리가
한 자리에서 내는 자리로 둔갑한다.

**값을 담지 않는다.**
-/
-- DD:CF-4429
def readsThreeAxesInOnePlace (chs : List SanctionCutChannel) : Bool :=
  chs.any (fun c =>
    c.readsEntity && c.readsTime && c.readsDealKind && c.readsAllInOnePlace)

/--
세 축을 다 내는 경로가 있으나 그 셋을 한 자리에서 내는 경로가 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
세 축을 다 내는 경로가 아예 없거나, 그 셋을 한 자리에서 내는 경로가 하나라도 있어야 한다. 앞의
관측은 그 축에 값이 어디에도 없다는 뜻이고 뒤의 관측은 그 맞춤의 몫이 읽는 쪽에 없다는 뜻이며, 둘 다
이 파일의 산출이 드는 결손의 꼴을 바꾼다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 제재가 어느 주체를 어느 망에서 자르는지를 한 자리에서 읽는 경로가 없다는 것이
이 아크의 산출이고, 그 결손이 소스의 부재와 다른 사실임을 함께 보이므로 기여 목록에 든다.

**진술의 꼴.** 목록 멤버십의 전칭으로 두지 않는 사유는 그 꼴이 명제 외연성을 끌어오는데 관측층의
공리 기준선이 비어 있다는 데 있다.
-/
-- DD:CF-4429
theorem three_axes_read_but_not_in_one_place :
    readsThreeAxes sanctionCutChannels = true
      ∧ readsThreeAxesInOnePlace sanctionCutChannels = false := by
  -- 경로 목록과 칸의 값이 모두 리터럴이므로 두 접기가 계산으로 닫힌다.
  exact ⟨rfl, rfl⟩

/--
세 축을 다 내는 경로가 자기를 편집본이라고 적는 것뿐이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
세 축을 다 내면서 자기를 편집본이라고 적지 않는 경로가 그 목록에 서야 한다. 그 관측은 그 셋을 내는
자리가 정본을 따라 편집된 문서에 한정되지 않는다는 뜻이며, 그러면 이 결손이 공표의 꼴에서 온다는
서술이 그 자리에서 무너진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 셋을 내는 값의 성질이 갈린다는 것을 보이고, 그 성질이 소스의 부재와 다른
사실임을 드는 자리가 여기뿐이므로 기여 목록에 든다.

**진술의 꼴.** 성질의 비동일을 부정 형태가 아니라 접기의 값으로 적는 사유는 그 꼴이 명제 외연성을
끌어오지 않는다는 데 있다.
-/
-- DD:CF-4429
theorem three_axes_only_from_edited_text :
    sanctionCutChannels.all (fun c =>
      !(c.readsEntity && c.readsTime && c.readsDealKind)
        || c.declaresEditedFromAuthentic) = true
      ∧ consolidatedRegulationText.declaresEditedFromAuthentic = true
      ∧ sanctionsListAdvancedSchema.declaresEditedFromAuthentic = false := by
  -- 목록 접기와 칸의 투영이 계산으로 닫힌다.
  exact ⟨rfl, rfl, rfl⟩

/--
두 판정이 각 인자에서 홀로 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정들이 어느 인자 하나만 거짓인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는
뜻이며, 그러면 두 축만 내는 경로가 셋을 내는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 그 진술이 두 판정의 정의를 넘어 드는 몫을 갖지 않고 A-8 이 요구하는
증거를 드는 자리다. 결론을 부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서
재어졌는지가 서지 않으므로, 각 인자가 홀로 값을 가르는 자리를 이 정리가 든다. **목록의 네 경로가
주체를 전량 읽고 시점을 읽지 않는 경로가 갈래도 읽지 않으므로, 그 네 경로만으로는 주체와 시점의
인자가 홀로 갈리는 자리가 서지 않는다.** 그래서 그 자리를 경로 하나의 칸을 갱신 문법으로 바꾼
리터럴로 들며, 한 자리에서 셋을 내는 판정은 그 칸이 참인 경로를 그 꼴로 세워야 세 인자가 홀로
갈린다.
-/
-- DD:CF-4428
theorem reads_three_axes_pins_each_conjunct :
    readsThreeAxes [consolidatedRegulationText] = true
      ∧ readsThreeAxes [designationAnnexTable] = false
      ∧ readsThreeAxes [sanctionsListFlatFile] = false
      ∧ readsThreeAxes [sanctionsListAdvancedSchema] = false
      ∧ readsThreeAxesInOnePlace [consolidatedRegulationText] = false
      ∧ readsThreeAxes [{ consolidatedRegulationText with readsEntity := false }] = false
      ∧ readsThreeAxes [{ consolidatedRegulationText with readsTime := false }] = false
      ∧ readsThreeAxesInOnePlace [{ consolidatedRegulationText with readsAllInOnePlace := true }] = true
      ∧ readsThreeAxesInOnePlace [{ consolidatedRegulationText with readsEntity := false, readsAllInOnePlace := true }] = false
      ∧ readsThreeAxesInOnePlace [{ consolidatedRegulationText with readsTime := false, readsAllInOnePlace := true }] = false
      ∧ readsThreeAxesInOnePlace [{ consolidatedRegulationText with readsDealKind := false, readsAllInOnePlace := true }] = false := by
  -- 한 원소 목록 위의 접기가 그 경로의 칸의 곱으로 계산되고 갱신 문법의 리터럴도 칸의 값으로
  -- 펼쳐지므로 열한 등식이 계산으로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
답할 항을 경로 목록과 절단의 술어에 걸어 조립한다.

**대응 비형식 개념:** 제재의 문면이 한 주체를 한 망에서 자르는지를 묻는 물음의 답이 그 문면을 읽는
공표에 걸린다는 사실. 세 축을 다 내는 자리가 서면 절단의 값을 참거짓으로 내고 서지 않으면 측정 소스
없음을 낸다.

**이 정의가 배제하는 사례:**
그 답의 측정 가능성이 망의 종류에 붙는다고 보는 읽기. 그 조문을 훑은 기록이 주체의 열거와 시점과 갈래가
각각 다른 자리에 실린다고 적으므로, 종류에 붙는다고 보면 세 축 가운데 어느 축이 비어 그 답이 서지
않는지가 구조에서 사라진다.
조달처: E-68 §4-1 「주체의 열거는 부속서에 있고 시점은 세 자리에 흩어지며 망 종류는 조의 본문에 있다」

**기각한 대체 정의:**
세 축을 한 자리에서 내는 경로가 없으면 답을 내지 않는 안. 이 물음이 한 주체가 잘렸는지를 묻고 그 셋이
한 문면에 함께 실렸는지를 묻지 않으므로, 요구하면 답이 서는 자리가 과하게 좁아지고 맞춤의 비용이 답의
부재로 둔갑한다. 앞 아크의 조립을 고쳐 이 경로 목록을 받게 하는 안도 기각했다. 그 조립이 망의 색인을
읽는 경로에 미정을 걸고 이 조립이 제재의 문면을 읽는 경로에 그것을 걸므로 둘이 다른 결손을 드러내며,
하나로 접으면 어느 결손이 그 미정을 낳았는지가 답에서 사라진다.

**값을 담지 않는다.**
-/
-- DD:CF-4440
def sanctionCutVia {Time Entity : Type} (chs : List SanctionCutChannel)
    (cut : Entity → Time → NetworkKind → Bool) :
    CQ.SanctionTextCut Time Entity (fun _ => NetworkKind) where
  answer := fun e t k =>
    if readsThreeAxes chs then
      (if cut e t k then ObservedTruth.holds else ObservedTruth.fails)
    else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
어느 주체도 어느 시점에도 어느 종류에서도 자르지 않는 절단.

**대응 비형식 개념:** 절단이 외생이라는 것을 증거에서 드러내는 값이며, 정리 둘이 이 값을 딛는다.

**이 정의가 배제하는 사례:**
절단의 값이 답의 갈림을 낳는다고 보는 자리. 이 값이 어느 자리에서도 거짓을 내는데 아래 정리가 경로
목록에 따라 답이 갈리는 것을 들므로, 그 갈림이 절단의 값에서 오지 않고 경로의 구성에서 온다는 것이
이 값으로 재어진다. 그 조문을 훑은 기록이 열거에 넣는 것이 당국의 조작이라고 적어 그 값이 읽는 쪽의
계산이 아님을 밝히므로, 참을 주는 값을 쓰면 그 둘이 한 증거에 섞인다.
조달처: E-68 §2-3 「그 열거에 넣는 것이 당국의 조작이다」

**기각한 대체 정의:**
정의층의 절단 술어를 이 자리에 직접 넣는 안. 그 술어가 조치와 대상과 소유의 망을 인자로 받으므로 그
전량을 관측층이 지어 넣게 되고, 제재의 시점열이 동학층의 외생 입력이라는 판정이 이미 서 있으므로 이
파일이 받을 것은 함수 하나다.

**값을 담지 않는다.**
-/
-- DD:CF-4440
def noLegalCut {Time Entity : Type} : Entity → Time → NetworkKind → Bool := fun _ _ _ => false

/--
세 축을 다 내는 자리가 있으면 답이 참거짓으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록 아래에서 답이 측정 소스 없음으로 서야 한다. 그 관측은 세 축을 다 내는 자리가 있어도 답이
서지 않는다는 뜻이며, 그러면 이 아크가 내리는 항이 정의 공백을 벗어나지 못한다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 이 아크가 내리는 항의 답이 실제로 서는 자리를 드는 유일한 명제이고, 그 답이
절단의 값에서 오고 경로의 구성이 그 문턱을 준다는 것을 함께 보이므로 기여 목록에 든다.
-/
-- DD:CF-4440
theorem sanction_answer_determined_with_three_axes :
    (sanctionCutVia sanctionCutChannels (noLegalCut (Time := Unit) (Entity := Unit))).answer ()
        () NetworkKind.financialMessaging = ObservedTruth.fails := by
  -- 경로 목록이 세 축을 다 내므로 조건식이 절단의 값으로 계산되고, 절단이 거짓이어서 답이 거짓이다.
  rfl

/--
세 축을 다 내는 자리가 없으면 답이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록 아래에서 답이 참거짓으로 서야 한다. 그 관측은 답이 경로의 구성에 걸리지 않는다는 뜻이며,
그러면 읽을 자리가 없는 자리와 있는 자리가 같은 답을 내어 소스 없음이 답으로 둔갑한다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 타입으로 서는 것을 보이고, 그 등재가 이 아크가
내리는 항의 답에서 실제로 선다는 것이 이 정리의 산출이므로 기여 목록에 든다.
-/
-- DD:CF-4440
theorem sanction_answer_undetermined_without_three_axes :
    (sanctionCutVia [sanctionsListFlatFile]
          (noLegalCut (Time := Unit) (Entity := Unit))).answer () ()
        NetworkKind.financialMessaging
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 경로 목록이 세 축을 다 내지 않으므로 조건식이 측정 소스 없음으로 계산된다.
  rfl

end CrisisFramework.Observation
