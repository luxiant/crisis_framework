/-
정의층 — 제약이 낸 이어짐

규율: L-9(import 방향은 단방향), L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족으로 정의한다), A-1(`axiom` 금지),
      A-3(witness 의무), A-8(변이 검사와 논리 결합의 증거), C-1·C-2(`noncomputable` 과
      `Classical` 금지), C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-7(용어집 선행 등록),
      D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시),
      T-6(존재 형태).

**이 파일이 세우는 것은 엣지가 제약의 함수라는 것을 담는 자리다.** 앞 페이즈가 같은 노드 집합 위에
여러 그래프가 선다는 것을 담았으나 그 이어짐이 외생으로 받아지기만 했고, 한 노드의 제약이 조이면서
그 노드를 한쪽 끝으로 갖는 쌍이 끊기는 것을 담는 자리가 서지 않았다.

**제약 상태를 받고 계산하지 않는다.** 층을 가르는 시험이 모형이 그 값을 계산하는가 받는가이므로 제약
상태를 받으면 이 사상이 정의층에 서고 계산하면 동학층으로 밀리는데, 동학층 산출이 재유입의 범위에서
빠지므로 계산하는 꼴로 담으면 이 아크의 산출이 건너가지 못한다.

**이 유도가 이어짐의 족과 일치한다는 주장을 이 파일이 세우지 않는다.** 회계층의 기재값과 그 값의
결정을 다른 층에 두고 동학층이 그 일치를 주장하는 꼴이 규율에 이미 서 있으므로, 정의층이 유도 사상을
들고 그 일치의 주장이 동학층에 선다. 그 주장을 이 자리에 두면 이어짐의 족이 유도의 상으로 좁혀져
외생으로 받는 길이 막힌다.

**시점을 사상이 인자로 받고 열거를 타입족으로 올리지 않는다.** 앞 페이즈가 망의 종류가 그 시점에
섰는지를 내는 술어를 시점을 받는 꼴로 두었고 정의층 대상이 시점 인덱스를 갖는 요구가 그 술어가 시점을
받는 것으로 충족된다는 판정이 그 자리에 섰으므로, 그 꼴을 옮겨 쓴다.

**이 파일은 수를 시점 인덱스로만 쓴다.** 그 밖의 자리에 수가 서지 않는다.

**용어집의 선행 등록을 받지 않는다.** 그 요구의 판별 시험이 그 개념을 들 수 있는가가 아니라
그 개념이 누구의 것인가를 묻고 원 문헌이나 성문 규범이 자기 문면으로 그 개념을 세울 때에만
등록하게 하는데, 이 파일이 세우는 구조체는 이미 등록된 개념 위에 선 사상이어서 표현 수단이다.
앞 페이즈가 망의 이어짐을 같은 사유로 등록 없이 세운 선례가 있다.

**정리의 증명과 적재 선언은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며, 이
파일이 딛는 적재 선언도 집행이 쓴다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.Constraint
import CrisisFramework.Definition.NetworkKind

namespace CrisisFramework.Definition

/--
제약이 낸 이어짐.

**대응 비형식 개념:** 어느 시점에 각 노드에 걸린 제약이 그 시점의 이어짐을 어떻게 정하는가. 한
노드의 제약이 조이면 그 노드를 한쪽 끝으로 갖는 쌍이 끊기므로 이어짐이 제약의 함수로 선다.

**이 정의가 배제하는 사례:**
외환 규제가 결제를 멈추어 고리가 끊긴 자리. 한 성문 규범을 훑은 기록이 외국통화의 즉시 송금이
불가능하면 서류가 넘어가지 않는다고 적으므로, 그 끊김이 노드의 자기자본이나 그 노드에 걸린 제약에
서지 않고 이 사상이 받는 상태 밖에 있다.
조달처: E-33 §3-3 「외국통화의 즉시 송금이 불가능하면 서류가 넘어가지 않는다」

**기각한 대체 정의:**
이어짐의 족을 유도의 상으로 좁혀 외생으로 받는 길을 닫는 안. 위상이 내생이라는 것이 구조에 더 강하게
서나 제약 밖의 사유로 끊기는 자리가 담기지 않고, 그 자리가 바로 위의 배제 사례다. 이어짐 구조체에
제약을 받는 필드를 더하는 안도 기각했다. 필드를 더하면 그 구조체를 받는 선언이 전부 그 필드를 채워야
하고 제약을 쓰지 않는 자리까지 값을 지어 넣게 된다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 매개변수로 받는다.**
-/
-- DD:CF-3764
structure ConstraintInducedLink (Party Node Num Currency Asset : Type) where
  /-- 시점과 그 시점의 노드 상태 배정을 받아 그 시점의 이어짐을 낸다. -/
  induce : ℕ → NodeStateAssignment Party Num Currency Asset → NetworkMembership Node

/--
비어 있지 않음의 증거.

**무엇을 증거하는가.** 제약이 낸 이어짐 구조체가 비어 있지 않음을 증거한다. 어느 시점의 어느 상태에도
이어짐을 주지 않는 유도이며, 존재 정리는 이 값을 딛지 않는다.
-/
-- DD:CF-3764
def ConstraintInducedLink.trivial :
    ConstraintInducedLink Unit Unit Unit Unit Unit where
  induce := fun _ _ => { linked := fun _ _ _ => false }

/--
자산 적격성만 갈리는 노드 상태 배정.

**무엇을 증거하는가.** 제약이 갈리는 두 상태가 실재함을 증거한다. 자산 적격성을 인자로 받아 그 값만
갈리는 배정을 내며, 존재 정리가 두 값을 함께 딛는다.
-/
-- DD:CF-3764
def constraintStateBy (eligible : Bool) : NodeStateAssignment Unit Unit Unit Unit where
  stateOf := fun _ =>
    some
      { equity := fun _ => ()
        constraint :=
          { liabilityCap := fun _ => ()
            assetEligible := fun _ => eligible } }

/--
자산 적격성을 그대로 이어짐으로 내는 유도.

**무엇을 증거하는가.** 제약이 갈리면 이어짐이 갈리는 유도가 실재함을 증거한다. 상태를 갖지 않는
주체에는 이어짐을 주지 않으며, 존재 정리가 이 값을 딛는다.
-/
-- DD:CF-3764
def constraintInducedLinkWitness : ConstraintInducedLink Unit Unit Unit Unit Unit where
  induce := fun _ a =>
    { linked := fun _ _ _ =>
        match a.stateOf () with
        | some s => s.constraint.assetEligible ()
        | none => false }

/--
제약이 갈리면 이어짐이 갈리는 유도가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 유도든 제약이 다른 두 상태에서 같은 이어짐을 내야 한다. 그 관측은 제약이 이어짐을 가르지 않는다는
뜻이며, 그러면 이 파일이 담으려는 함수 관계가 담을 것을 갖지 않고 위상이 내생이라는 것이 구조에서
사라진다.

**존재 형태로 진술하는 까닭(T-6):**
제약이 이어짐을 가른다는 것은 갈리는 두 상태를 실제로 들어야 보이고, 임의의 유도에 대한 전칭으로는 그
갈림이 진술되지 않는다. 어느 상태에도 같은 이어짐을 주는 유도가 실재하므로 전칭은 거짓이고 존재가 그
갈림을 든다.

**가정을 두지 않는다.** 증거를 직접 들어 존재를 보인다.

**T-3 분류:** 기여다. 엣지가 제약의 함수라는 것이 구조에서 실제로 성립함을 보이고, 그 성립이 제약
상태를 받는 꼴로 선다는 설계가 이 정리로 재어지므로 기여 목록에 든다.
-/
-- DD:CF-3764
theorem exists_induce_split_by_constraint :
    (constraintInducedLinkWitness.induce 0 (constraintStateBy true)).linked
        NetworkKind.collateralPledge () () = true
      ∧ (constraintInducedLinkWitness.induce 0 (constraintStateBy false)).linked
          NetworkKind.collateralPledge () () = false := by
  sorry

end CrisisFramework.Definition
