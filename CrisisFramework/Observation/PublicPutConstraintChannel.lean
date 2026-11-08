/-
관측층 — 공적 유동성 풋 접근이 제약을 넓히는지의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 수를 쓰지 않는다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-3(배제 사례의 조달처),
      D-8(witness 예외), T-2(반증 조건), T-4(가정의 명시).

**넓힘의 두 축을 따로 받는다.** 부채 측 넓힘이 중앙은행의 대출 조건에서 오고 자산 측 넓힘이 적격
담보의 판정에서 오므로 소스가 둘이며, 한 칸으로 접으면 한쪽에 소스가 있는 것이 다른 쪽의 결손을
덮는다.

**소스 없음을 경로마다 등재하고 전칭으로 등재하지 않는다.** 중앙은행 대출 제도의 상대방 자격을 드는
문면이 뭉치에 들어오지 않았으므로 어떤 경로도 그 칸을 내지 못한다는 단정은 열지 않은 편의 성질을
근거로 쓰는 것이 된다.

**주체의 타입을 매개변수로 받는다.** 넓힘의 정도를 드는 칸이 없으므로 이 파일에는 수 타입도 수치
리터럴도 없다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.PublicPutAccess

open CrisisFramework.Definition

namespace CrisisFramework.Observation

/--
공적 유동성 풋 접근이 제약을 넓히는지를 보는 공시 경로.

**대응 비형식 개념:** 어느 공시가 한 주체의 공적 유동성 풋 접근과 그 접근이 제약의 두 필드를
넓히는지를 읽을 재료를 내는가. 넓힘이 부채 측과 자산 측에 각각 서고 그 두 넓힘의 소스가 서로 다른 데서
나오므로 축을 따로 받는다.

**이 정의가 배제하는 사례:**
한 중앙은행의 적격 담보 목록 문서가 자기 말미에 적격 담보를 계속 검토하겠다고 적고 어떤 증권이든
언제든 거절할 권리를 유보하며 그 결과로 공표된 목록에 구속되지 않는다고 적는 것. 그 유보가 적격성
자체를 열어 두므로 그 목록으로는 자산 측 넓힘의 칸이 서지 않으며, 이 구조의 칸이 보는 것은 그 넓힘이고
목록의 내용이 아니다.
조달처: E-49 §11-2 「공표된 적격 증권 목록에 구속되지 않는다고 적는다」

**기각한 대체 정의:**
긴급 조달 접근의 공시 경로를 그대로 쓰고 이 경로를 세우지 않는 안. 그 경로가 주체의 단계와 그 단계가
닿는 풋을 이미 칸으로 들어 겹쳐 보이나, 그것이 보는 것은 접근이고 이 경로가 보는 것은 그 접근이 제약을
움직이는가여서 색인이 다르다. 넓힘의 두 축을 한 칸으로 접는 안도 기각했다. 부채 측 넓힘이 중앙은행의
대출 조건에서 오고 자산 측 넓힘이 적격 담보의 판정에서 오므로 소스가 둘이며, 한 칸으로 접으면 한쪽에
소스가 있는 것이 다른 쪽의 결손을 덮는다.

**값을 담지 않는다.**
-/
-- DD:CF-3080
structure PublicPutConstraintChannel (Entity : Type) where
  /-- 그 주체가 공적 유동성 풋에 닿는지를 이 경로가 보는가. -/
  coversAccess : Entity → Bool
  /-- 이 경로가 그 접근이 부채 측 한도를 넓히는지를 가르는가. -/
  resolvesCapWidening : Bool
  /-- 이 경로가 그 접근이 자산 측 적격성을 넓히는지를 가르는가. -/
  resolvesEligibilityWidening : Bool

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `PublicPutConstraintChannel` 이 비어 있지 않음을 보인다. 어느
주체도 보지 않고 두 넓힘을 하나도 가르지 않는 경로다.
-/
-- DD:CF-3080
def PublicPutConstraintChannel.noSource {Entity : Type} :
    PublicPutConstraintChannel Entity where
  coversAccess := fun _ => false
  resolvesCapWidening := false
  resolvesEligibilityWidening := false

/--
적격담보 공시를 그 고리의 경로로 읽은 것.

**대응 비형식 개념:** 중앙은행이 담보로 받는 자산의 범주를 공표하는 문면을 공적 풋 접근이
제약을 넓히는지 읽는 경로로 세운 것. 그 공시가 자산 측 넓힘의 재료로 보이나 가르는 것이 증권이어서
주체를 가르지 않고, 그 적격성조차 공시가 확정하지 않는다.

그 칸이 전량 거짓인 것이 이 선언의 산출이다. 소스 없음을 경로마다 등재하는 자리이며, 아무 주체도
보지 않는 경로가 비어 있지 않음을 보이는 witness 와 값이 같아도 드는 것이 다르다. 앞은 구조가 비어
있지 않음을 보이고 이것은 실재하는 공시가 그 칸을 내지 못함을 보인다.

**이 정의가 배제하는 사례:**
그 중앙은행이 모든 적격성 요청을 정해진 서식으로 받고 그 판정에 든 실사 비용을 해당 참가자에게 청구할
수 있다고 적는 것. 적격성의 관측자가 공시를 읽는 쪽이 아니라 요청을 낸 참가자이므로 공시를 읽는
경로로는 그 칸이 서지 않으며, 이 선언은 그 절차의 내용을 담지 않는다.
조달처: E-49 §11-3 「적격성 요청을 정해진 서식으로 받고 실사 비용을 청구할 수 있다」

**기각한 대체 정의:**
자산 측 넓힘 칸을 참으로 두는 안. 적격 담보의 범주가 공표되어 있어 넓힘이 읽히는 것처럼 보이나 그
공시가 자기 목록에 구속되지 않는다고 적으므로, 참으로 두면 확정되지 않은 것을 확정된 것으로 주장하게
된다. 이 경로를 세우지 않고 아무 주체도 보지 않는 경로 하나로 갈음하는 안도 기각했다. 그 경로는 구조가
비어 있지 않음을 보이는 자리여서 실재하는 공시를 들지 않으므로, 갈음하면 실재하는 공시가 그 칸을 내지
못한다는 사실이 어디에도 남지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-3080
def eligibleCollateralDisclosurePutChannel {Entity : Type} :
    PublicPutConstraintChannel Entity where
  coversAccess := fun _ => false
  resolvesCapWidening := false
  resolvesEligibilityWidening := false

/--
적격담보 공시는 그 고리의 어느 칸도 내지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
중앙은행이 공표하는 적격담보 문면이 어느 주체가 공적 풋에 닿는지를 함께 가르거나, 그 접근이 부채 측
한도나 자산 측 적격성을 넓히는 정도를 정해야 한다. 그 문면이 자산의 범주를 가르고 상대방 자격을 따로
정하며 자기 목록에 구속되지 않는다고 적으므로, 이 명제가 거짓이면 그 공시가 세 색인을 함께 든다는
뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 이 프레임워크의 주요 산출물이며, 실재하는 공시가
그 칸을 내지 못한다는 것이 이 진술로 선다.
-/
-- DD:CF-3080
theorem eligibleCollateralDisclosurePutChannel_resolves_nothing {Entity : Type} :
    (∀ e : Entity,
      (eligibleCollateralDisclosurePutChannel (Entity := Entity)).coversAccess e = false) ∧
    (eligibleCollateralDisclosurePutChannel (Entity := Entity)).resolvesCapWidening = false ∧
    (eligibleCollateralDisclosurePutChannel (Entity := Entity)).resolvesEligibilityWidening
      = false := by
  exact ⟨fun _ => rfl, rfl, rfl⟩

end CrisisFramework.Observation
