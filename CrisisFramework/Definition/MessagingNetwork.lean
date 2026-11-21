/-
정의층 — 금융 전문 체계에의 접속과 그 위에서 유도되는 전문의 고리

규율: L-9(import 방향은 단방향), L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족으로 정의한다), A-1(`axiom` 금지),
      A-3(witness 의무), A-8(변이 검사와 논리 결합의 증거), C-1·C-2(`noncomputable` 과
      `Classical` 금지), C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-7(용어집 선행 등록),
      D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시),
      T-6(존재 형태).

**이 파일이 세우는 것은 금융 전문이 오가는 망의 구조다.** 앞 아크가 같은 노드 집합 위에 여러 그래프가
선다는 것을 담는 자리를 세웠는데 그 열거가 담보와 소유와 중앙은행 사이의 약정과 통화 불일치의 전달과
교역 금융의 다리를 들고 금융 전문의 망을 들지 않았으며, 제재가 끊는 것이 바로 그 망이다.

**전문 체계를 노드로 두지 않고 별도 대상으로 둔다.** 한 나라의 중앙은행이 세운 체계를 노드로 두면
그 중앙은행이 이미 노드이므로 같은 주체가 둘로 서고, 망 종류의 열거가 노드 집합 위의 그래프를 색인하
므로 체계는 그 열거의 원소가 아니다. 그래서 주체와 체계 사이의 접속을 따로 세우고 두 주체 사이의
전문 고리를 그 접속에서 유도한다.

**체계를 이름으로 열거하지 않고 타입 매개변수로 받는다.** 절단의 대상이 시점에 따라 넓어져 뒤의 날에
한 나라 법으로 세워진 어느 법인이든 금융 전문 기능을 품은 체계가 걸리므로, 이름으로 열거하면 그 열거가
뒤의 시점에 거짓이 된다.

**유한 집합을 쓰지 않는다.** 그 집합이 몫의 건전성과 명제 외연성을 끌어오고 관측층이 이 대상을 서명
에서 받는 자리가 그 초과를 내며, 같은 사유가 망 종류의 열거를 세운 자리에 이미 문면으로 서 있다.

**이 파일은 수를 시점 인덱스로만 쓴다.** 그 밖의 자리에 수가 서지 않는다.

**정리의 증명과 적재 선언은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며, 이
파일이 딛는 적재 선언도 집행이 쓴다. 그 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을
부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.NetworkKind

namespace CrisisFramework.Definition
/--
주체가 금융 전문 체계에 접속하는가.

**대응 비형식 개념:** 한 주체가 금융 전문을 주고받는 체계의 참가자인가. 제재가 끊는 것이 그 체계에
연결하는 행위이므로 그 연결이 주체마다 서는 자리가 먼저 표현되어야 한다.

**이 정의가 배제하는 사례:**
한 편이 지급의 사슬을 여섯 자리로 들면서 전문 체계를 그 사슬의 자리에 두지 않고 그 변이 타는 기반
으로 든 것. 체계를 노드로 두면 그 체계를 세운 중앙은행이 이미 노드이므로 같은 주체가 둘로 서며, 그
편의 사슬에서 체계가 자리를 갖지 않는 것이 그 가름을 받친다.
조달처: E-71 §2-5 「전문 체계는 사슬의 노드가 아니라 그 변이 타는 기반이며」

**기각한 대체 정의:**
체계를 망 종류의 열거에 원소로 더하는 안. 선언이 하나 줄어드나 그 열거가 노드 집합 위의 그래프를
색인하는데 체계는 그래프가 아니라 그 그래프가 타는 기반이므로 그 대응이 깨진다. 접속을 주체의 필드로
두는 안도 기각했다. 한 주체가 체계 여럿에 접속하므로 필드가 체계마다 서야 하고 그러면 체계의 열거가
타입에 박혀 그 집합이 넓어질 때 거짓이 된다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4398
structure MessagingSystemAccess (System Node : Type) where
  /-- 그 주체가 그 체계에 접속하는가. -/
  connected : System → Node → Bool

/--
시점마다의 접속 (L-13).

**대응 비형식 개념:** 어느 시점에 어느 주체가 어느 체계에 접속하는가. 절단이 접속을 끊고 그 끊김이
시점에 걸리므로 접속이 시점의 족으로 선다.

**이 정의가 배제하는 사례:**
한 조문이 같은 항에서 앞선 날과 뒤의 날에 걸리는 체계를 다르게 든 것. 접속을 시점과 무관한 상수로
두면 그 넓어짐이 구조에서 사라지고 한번 선 접속이 영구히 서는 것으로 읽힌다.
조달처: E-68 §2-8 「뒤의 날에 걸리는 것이 그 중앙은행의 체계 전량과 그 나라 법으로 세워진 어느 법인이든 금융 전문 기능을 품은 체계다」

**기각한 대체 정의:**
접속 구조체 안에 시점을 받는 필드를 더하는 안. 필드를 더하면 그 구조체를 받는 선언이 전부 그 필드를
채워야 하고 시점을 쓰지 않는 자리까지 값을 지어 넣게 되며, 족으로 올리면 기존 구조체가 그대로 서고
시점을 쓰지 않는 자리가 상수 축약으로 닫힌다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-4398
abbrev MessagingSystemAccessFamily (System Node : Type) := ℕ → MessagingSystemAccess System Node

/-- witness (A-3). **무엇을 증거하는가.** 접속 구조체가 비어 있지 않다. 어느 주체도 어느 체계에
접속하지 않는 접속 하나를 든다. -/
-- DD:CF-4398
def MessagingSystemAccess.trivial : MessagingSystemAccess Unit Unit where
  connected := fun _ _ => false

/-- 한 접속을 모든 시점에 두는 족. 선례가 같은 꼴을 둔다. -/
-- DD:CF-4398
def MessagingSystemAccess.constant {System Node : Type} (A : MessagingSystemAccess System Node) :
    MessagingSystemAccessFamily System Node := fun _ => A

/--
두 주체가 그 체계를 함께 쓰는가.

**대응 비형식 개념:** 한 체계가 두 주체 사이의 전문을 받칠 수 있는가. 전문이 체계를 타고 오가므로 두
주체가 같은 체계에 접속해야 그 둘 사이에 전문의 변이 선다.

**이 정의가 배제하는 사례:**
한 편이 그 체계의 사슬을 양자 관계의 연쇄로 들면서 변마다 전문이 오가는 것을 든 것. 접속을 한쪽
주체만 보고 판정하면 보내는 쪽이 접속했다는 것만으로 변이 서고, 받는 쪽이 끊긴 자리가 구조에서
사라진다.
조달처: E-71 §2-1 「그 망의 변이 두 주체 사이에 서고 한 주체와 전체 사이에 서지 않는다」

**기각한 대체 정의:**
두 주체의 접속을 합으로 접는 안. 한쪽만 접속해도 변이 서나 전문이 오가려면 양쪽이 같은 체계에 서야
하므로 그 꼴이 끊긴 쌍을 이어진 것으로 낸다. 접속을 쌍에 바로 붙이는 안도 기각했다. 체계가 어느
것인지가 사라져 한 체계가 끊길 때 남는 체계를 가릴 수 없다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4399
def MessagingSystemAccess.sharedBy {System Node : Type} (A : MessagingSystemAccess System Node)
    (s : System) (a b : Node) : Bool :=
  A.connected s a && A.connected s b

/--
두 주체가 그 체계 목록의 어느 하나에서 전문을 주고받을 수 있는가.

**대응 비형식 개념:** 두 주체 사이에 금융 전문의 고리가 서는가. 공유하는 체계가 하나라도 있으면 그
고리가 서고 하나도 없으면 서지 않는다.

**이 정의가 배제하는 사례:**
한 조문이 금지의 대상을 한 체계에서 그 중앙은행의 체계 전량으로 넓힌 것. 체계를 하나로 두고 판정하면
그 하나가 끊길 때 고리가 전량 사라지는 것으로 서는데, 그 조문이 체계를 여럿 드는 꼴로 넓어지므로
남는 체계가 있는 배치가 표현되어야 한다.
조달처: E-68 §2-8 「같은 항에서 앞선 날에 걸리는 것이 그 나라 중앙은행의 금융 전문 체계와 그 중앙은행이 세운 동등한」

**기각한 대체 정의:**
임의의 체계 타입 위의 존재 진술로 두는 안. 목록을 받지 않아 짧으나 그 진술이 `Prop` 이어서 판정
가능성이 서지 않고 C-3 이 요구하는 자리가 비며, 임의의 타입에 그 인스턴스를 줄 수단이 없다. 목록을
전량 접는 안도 기각했다. 빈 목록에서 참을 내어 체계가 하나도 없는 자리가 모든 쌍이 이어지는 것으로
서며, 이 자리의 접기는 빈 목록에서 거짓을 내는 것이 옳다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4399
def MessagingSystemAccess.linkedVia {System Node : Type} (A : MessagingSystemAccess System Node)
    (ss : List System) (a b : Node) : Bool :=
  ss.any (fun s => A.sharedBy s a b)

/--
체계가 하나도 없으면 어느 쌍도 전문을 주고받지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
체계가 하나도 없는 자리에서 어떤 쌍이 전문을 주고받아야 한다. 그 관측은 전문이 체계를 타지 않는다는
뜻이며, 그러면 접속이 고리를 정하지 않고 이 구조가 아무것도 가르지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 그 진술이 접기의 정의를 넘어 드는 몫을 갖지 않는다. 빈 목록에서 거짓을
내는 것이 그 접기를 고른 선언의 기각 문단에 이미 서 있으므로 그 사실을 드는 유일한 자리가 아니다.
-/
-- DD:CF-4399
theorem linked_via_nil_false {System Node : Type} (A : MessagingSystemAccess System Node)
    (a b : Node) : A.linkedVia [] a b = false := by
  -- 빈 목록의 접기가 정의상 거짓이므로 전개만으로 값이 나와 `rfl` 로 닫힌다.
  rfl

/--
공유의 판정이 각 인자에서 홀로 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 한쪽만 접속한 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는 뜻이며,
그러면 한쪽이 끊긴 쌍이 이어진 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 그 진술이 공유의 정의를 넘어 드는 몫을 갖지 않고 A-8 이 요구하는 증거를
드는 자리다. 결론을 부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가
서지 않으므로, 각 인자가 홀로 참인 자리를 이 정리가 든다.
-/
-- DD:CF-4399
theorem shared_pins_each_conjunct :
    (MessagingSystemAccess.mk (fun (_ : Unit) (n : Bool) => n)).sharedBy () true true = true
      ∧ (MessagingSystemAccess.mk (fun (_ : Unit) (n : Bool) => n)).sharedBy () true false = false
      ∧ (MessagingSystemAccess.mk (fun (_ : Unit) (n : Bool) => n)).sharedBy () false true = false
      ∧ (MessagingSystemAccess.mk (fun (_ : Unit) (n : Bool) => n)).sharedBy () false false
          = false := by
  -- 접속이 주체의 값을 그대로 돌려주고 공유의 판정이 그 위의 논리곱이므로 각 등식이 계산으로
  -- 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
한 체계가 빠져도 다른 체계를 공유하는 쌍이 남는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 배치에서도 한 체계를 뺀 목록이 모든 쌍을 끊어야 한다. 그 관측은 체계가 실질적으로 하나뿐이라는
뜻이며, 그러면 절단이 체계를 가리지 않고 망을 통째로 끊는 것과 같아진다.

**가정을 두지 않는다.**

**존재 형태로 진술하는 까닭(T-6):** 체계의 목록이라는 시스템 수준의 값이 개별 쌍의 이어짐을 정하지
않는다. 같은 목록에서 어떤 쌍은 끊기고 어떤 쌍은 남으므로 전칭으로 세우면 거짓이다.

**T-3 분류:** 기여다. 절단이 체계를 가린다는 것과 망을 통째로 끊는다는 것이 다른 사실임을 구조
안에서 보이므로 기여 목록에 든다.
-/
-- DD:CF-4399
theorem link_survives_system_loss :
    ∃ (A : MessagingSystemAccess Bool Unit) (ss : List Bool) (s : Bool),
      A.linkedVia ss () () = true ∧ A.linkedVia (ss.erase s) () () = true := by
  -- 모든 주체가 모든 체계에 접속하는 배치와 체계 둘의 목록을 증거로 들고 앞의 체계를 뺀다. 남는
  -- 체계가 그 쌍을 받치므로 두 접기가 계산으로 참이 나와 `rfl` 로 닫힌다.
  exact ⟨⟨fun _ _ => true⟩, [true, false], true, rfl, rfl⟩

/--
전문의 고리를 망 종류 위의 이어짐으로 잇는다.

**대응 비형식 개념:** 금융 전문의 망이 같은 노드 집합 위의 한 그래프로 선다는 것. 앞 아크가 세운
이어짐이 종류를 받으므로 그 종류의 자리에 이 망이 들어간다.

**이 정의가 배제하는 사례:**
한 편이 같은 지급의 사슬 위에 선별과 전문과 계정 갱신의 띠 셋을 겹쳐 둔 것. 이어짐을 종류와 무관하게
두면 그 셋이 한 그래프로 접히고, 전문이 끊긴 것과 계정이 끊긴 것이 같은 값으로 선다.
조달처: E-71 §2-2 「한 지급의 사슬 위에 성질이 다른 세 층이 함께 서고 그 셋이 같은 노드 집합 위의 다른 그래프다」

**기각한 대체 정의:**
전문의 고리를 다른 종류의 자리에도 함께 내는 안. 선언이 짧아지나 교역 금융의 다리나 담보의 사슬에
전문의 값이 서서 그 종류의 이어짐이 거짓이 된다. 종류를 받지 않고 이어짐만 내는 안도 기각했다. 앞
아크가 세운 구조체가 종류를 받으므로 그 자리를 채우지 못한다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4401
def MessagingSystemAccess.asMembership {System Node : Type}
    (A : MessagingSystemAccess System Node) (ss : List System) : NetworkMembership Node where
  linked := fun k a b =>
    match k with
    | NetworkKind.collateralPledge => false
    | NetworkKind.ownershipShare => false
    | NetworkKind.centralBankSwap => false
    | NetworkKind.currencyMismatchTransmission => false
    | NetworkKind.tradeFinanceLink => false
    | NetworkKind.financialMessaging => A.linkedVia ss a b

/--
그 다리가 전문의 종류에서만 값을 내고 다른 종류에서 거짓을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 다리가 전문이 아닌 종류에서 참을 내거나 전문의 종류에서 유도된 이어짐과 다른 값을 내야 한다. 앞의
관측은 한 층의 변이 다른 층으로 새어 나간다는 뜻이고 뒤의 관측은 그 다리가 유도를 보존하지 않는다는
뜻이며, 둘 다 층을 가르는 설계가 무너졌음을 가리킨다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 진술이 다리의 정의를 넘어 드는 몫을 갖는다. 층을 가르는 설계가 실제로 서는지는
그 다리의 값에서만 읽히고 다른 선언이 그것을 주장하지 않으므로, 그 가둠을 구조 안의 명제로 드는 유일한
자리가 여기다. 열거의 원소마다 한 항을 두므로, 원소를 더하는 아크가 이 진술을 함께 넓히지 않으면 그
종류의 분기가 어느 명제에도 걸리지 않는다.
-/
-- DD:CF-4401
theorem membership_confined_to_messaging {System Node : Type}
    (A : MessagingSystemAccess System Node) (ss : List System) (a b : Node) :
    (A.asMembership ss).linked NetworkKind.financialMessaging a b = A.linkedVia ss a b
      ∧ (A.asMembership ss).linked NetworkKind.collateralPledge a b = false
      ∧ (A.asMembership ss).linked NetworkKind.ownershipShare a b = false
      ∧ (A.asMembership ss).linked NetworkKind.centralBankSwap a b = false
      ∧ (A.asMembership ss).linked NetworkKind.currencyMismatchTransmission a b = false
      ∧ (A.asMembership ss).linked NetworkKind.tradeFinanceLink a b = false := by
  -- 다리의 값이 종류마다 갈래로 정해지므로 여섯 종류에서 각 갈래가 전개만으로 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Definition
