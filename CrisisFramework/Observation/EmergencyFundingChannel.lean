/-
관측층 — 긴급 조달 접근의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 수를 쓰지 않는다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 예외),
      T-2(반증 조건), T-4(가정의 명시).

**풋을 사적과 공적 두 칸으로 가른다.** 사적 풋은 사적 시장 참가자가 집행하고 공적 풋은 중앙은행이
집행하므로 그 접근을 내는 공시가 서로 다른 데서 나온다. 한 칸으로 두면 한쪽에 소스가 있는 것이
다른 쪽의 결손을 덮으며, 그 결손이 이 파일의 산출이다.

**소스 없음을 경로마다 등재하고 전칭으로 등재하지 않는다.** 중앙은행 대출 제도에 접근할 수 있는
상대방을 참가 자격이 따로 정하는데 그 문면을 아직 열지 않았으므로, 어떤 경로도 그 칸을 내지 못한다는
단정은 열지 않은 편의 성질을 근거로 쓰는 것이 된다. 그 문면을 읽는 것은 구멍으로 등재되어 있다.

**주체의 타입을 매개변수로 받는다.** 단계를 드는 칸이 없으므로 이 파일에는 수 타입도 수치 리터럴도
없다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/
import CrisisFramework.Definition.EmergencyFunding

open CrisisFramework.Definition

namespace CrisisFramework.Observation

/--
긴급 조달 접근의 공시 경로.

**대응 비형식 개념:** 어느 공시가 한 주체의 긴급 조달 단계와 그 단계가 닿는 풋을 읽을 재료를
내는가. 접근이 사적 시장 참가자에 달린 것과 중앙은행에 달린 것으로 갈리므로 경로가 그 둘을
가르는지를 칸으로 받는다.

**이 정의가 배제하는 사례:**
중앙은행이 공표하는 적격담보 목록. 그 문면이 어느 증권을 어느 등급으로 받고 얼마를 깎는지를
범주별로 가르는데(영란은행, 2026년 6월 18일판) 적격성이 증권에 붙고 주체에 붙지 않으며, 중앙은행
대출 제도에 접근할 수 있는 상대방은 참가 자격이 따로 정한다. 이 구조의 칸이 보는 것은 주체여서
그 목록으로는 어느 칸도 채워지지 않는다.

**기각한 대체 정의:**
풋 넷마다 칸을 하나씩 두어 넷으로 받는 안. 사적 풋 둘이 같은 시장 참가자에 달려 있고 공적 풋 둘이
같은 중앙은행에 달려 있어 그 소스가 둘로 갈리므로, 넷으로 두면 같은 소스를 두 칸이 나누어 받고 그
가름의 근거가 어디에도 없다. 칸을 하나만 두어 접근 전체를 가르는지로 받는 안도 기각했다. 한 칸으로
두면 사적 풋에 소스가 있는 것이 공적 풋의 결손을 덮으며, 화폐성 위계의 공시 경로가 받침을 두 칸으로
가른 사유가 이 자리에 그대로 걸린다.

**값을 담지 않는다.**
-/
-- DD:CF-1622
structure EmergencyFundingChannel (Entity : Type) where
  /-- 그 주체가 어느 긴급 조달 단계에 서는지를 이 경로가 보는가. -/
  coversTierAssignment : Entity → Bool
  /-- 이 경로가 사적 풋의 접근을 가르는가. 자산을 담보로 빌릴 여지와 팔 여지가 그것이다. -/
  resolvesPrivatePut : Bool
  /-- 이 경로가 공적 풋의 접근을 가르는가. 중앙은행 대출 제도의 상대방 자격과 통화 백스톱의
      보유자가 그것이다. -/
  resolvesPublicPut : Bool

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `EmergencyFundingChannel` 이 비어 있지 않음을 보인다. 어느 주체도 보지
않고 두 축을 하나도 가르지 않는 경로다.
-/
-- DD:CF-31
def EmergencyFundingChannel.noSource {Entity : Type} : EmergencyFundingChannel Entity where
  coversTierAssignment := fun _ => false
  resolvesPrivatePut := false
  resolvesPublicPut := false

/--
적격담보 공시를 긴급 조달 접근의 경로로 읽은 것.

**대응 비형식 개념:** 중앙은행이 담보로 받는 자산의 범주를 공표하는 문면을 주체의 긴급 조달 접근을
읽는 경로로 세운 것. 그 공시가 최후대출자 접근의 재료로 보이나 가르는 것이 증권이어서 주체를 가르지
않는다.

**세 칸이 모두 거짓인 것이 이 선언의 산출이다.** 소스 없음을 경로마다 등재하는 자리이며, 아무 주체도
보지 않는 경로가 비어 있지 않음을 보이는 witness 와 값이 같아도 드는 것이 다르다. 앞은 구조가 비어
있지 않음을 보이고 이것은 실재하는 공시가 그 칸을 내지 못함을 보인다.

**이 정의가 배제하는 사례:**
영란은행이 어느 개별 증권에든 언제든 추가 할인율을 적용할 권리를 유보하고 이미 인도된 거래의 담보에도
그렇게 한다고 적은 것(영란은행, 2026년 6월 18일판). 그 유보가 공시 자신이 명시한 것이므로 공적 풋
칸의 거짓은 공시의 결손이 아니라 공시가 스스로 둔 재량이며, 이 선언은 그 재량의 범위를 담지 않는다.
비영국 국가의 은행채 보증 제도가 영란은행의 재량으로 심사되는 것도 같은 축에 선다.

**기각한 대체 정의:**
사적 풋 칸을 참으로 두는 안. 자산을 담보로 빌릴 여지가 그 자산의 적격성에 걸리는 것으로 보이나
적격성을 정하는 쪽이 사적 상대방이고 중앙은행의 목록이 그것을 정하지 않으므로, 참으로 두면 공적
기준으로 사적 접근을 읽었다고 주장하게 된다. 이 경로를 세우지 않고 아무 주체도 보지 않는 경로 하나로
갈음하는 안도 기각했다. 그 경로는 구조가 비어 있지 않음을 보이는 자리여서 실재하는 공시를 들지
않으므로, 갈음하면 실재하는 공시가 그 칸을 내지 못한다는 사실이 어디에도 남지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-1623
def eligibleCollateralDisclosureChannel {Entity : Type} : EmergencyFundingChannel Entity where
  coversTierAssignment := fun _ => false
  resolvesPrivatePut := false
  resolvesPublicPut := false

/--
적격담보 공시는 긴급 조달 접근의 어느 칸도 내지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
중앙은행이 공표하는 적격담보 문면이 어느 주체가 그 담보를 넘길 수 있는지를 함께 가르거나, 그 목록이
사적 상대방이 받는 담보의 범위를 정해야 한다. 그 문면이 자산의 범주를 가르고 상대방 자격을 따로
정하므로, 이 명제가 거짓이면 그 공시가 두 색인을 함께 든다는 뜻이다.

**가정을 두지 않는다.**
-/
-- DD:CF-1623
theorem eligibleCollateralDisclosureChannel_resolves_nothing {Entity : Type} :
    (∀ e : Entity,
      (eligibleCollateralDisclosureChannel (Entity := Entity)).coversTierAssignment e = false) ∧
    (eligibleCollateralDisclosureChannel (Entity := Entity)).resolvesPrivatePut = false ∧
    (eligibleCollateralDisclosureChannel (Entity := Entity)).resolvesPublicPut = false := by
  exact ⟨fun _ => rfl, rfl, rfl⟩

end CrisisFramework.Observation
