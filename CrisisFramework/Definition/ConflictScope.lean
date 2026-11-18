/-
정의층 — 저촉의 범위: 열거로 좁히는 차이와 비서류적 조건의 두 지위

규율: L-9(import 방향은 단방향), L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족으로 정의한다), A-1(`axiom` 금지),
      A-3(witness 의무), A-8(판정의 논리 결합마다 홀로 가르는 증거), C-3(판정 술어는
      `Decidable`), C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제
      문면), D-7(용어집 선행 등록), D-8(witness 의 서술), T-3(보조 보정과 기여의 분류),
      T-6(존재 형태), V-7(분할의 완전성).

**이 파일이 세우는 것은 제시의 판정에서 무엇이 저촉인가다.** 앞 페이즈가 저촉을 판정 기관에게서
통째로 받는 자리를 세웠는데, 그 관행이 저촉이 아닌 차이의 갈래를 문단으로 열거하고 비서류적 조건을
요건에서 지우면서 저촉의 기준으로는 남기므로 제도가 그 경계를 두 자리에서 그어 둔다.

**받는 자리와 계산하는 자리의 경계를 제도가 그은 자리로 좁힌다.** 열거에 드는 차이는 구조가 저촉에서
빼고 열거 밖의 차이만 판정 기관이 받으며, 비서류적 조건은 요건의 지위와 저촉 기준의 지위를 따로
계산한다.

**앞 페이즈가 세운 저촉 판정을 고치지 않는다.** 그 판정이 착지해 그 문서화 문면이 영구히 남았으므로
좁힌 판정을 따로 세우고 앞의 것이 뒤의 것을 함의하는 관계를 정리로 든다.

**그 좁힘이 준거의 층에 걸린다.** 그 열거의 갈래가 전부 그 관행의 문단에서 오고 그 관행은 신용장의
문면이 해당 조항을 명시로 고치거나 배제하지 않는 한에서 서므로, 신용장이 그 문단을 명시로 배제하면
그 갈래에 의한 좁힘 자체가 서지 않는다. 그래서 이 파일이 준거를 담는 파일을 적재한다.

**이 파일은 수를 시점 인덱스로만 쓴다.** 그 밖의 자리에 수가 서지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.AdjudicationAuthority
import CrisisFramework.Definition.DocumentaryCompliance

namespace CrisisFramework.Definition

/--
저촉이 아닌 차이의 갈래.

**대응 비형식 개념:** 서류 사이에 차이가 있어도 저촉으로 보지 않는 네 자리. 계산의 재현과 뜻을
바꾸지 않는 오기와 더 적힌 정보와 요구 밖의 언어가 그 넷이다.

**이 정의가 배제하는 사례:**
저촉이 아닌 차이를 하나의 추상 규칙으로 두는 읽기. 그 관행이 뜻을 바꾸지 않는 예를 셋 들고 그 뒤에
뜻을 바꾸는 예를 하나 들어 경계를 그리므로, 그 가름이 규칙이 아니라 열거이고 소속의 판정이 그 문단의
예시에 걸린다.
조달처: E-67 §2-5 「뜻을 바꾸는 예를 하나 들어 경계를 그린다」

**기각한 대체 정의:**
갈래마다 그 소속을 가르는 술어를 구조가 계산하게 두는 안. 그 경계가 예시로만 그어져 있으므로
계산으로 두면 제도가 갖지 않는 표현력을 문법이 갖게 된다. 소속을 받는 자리로 두고 그 갈래에 드는
차이를 저촉에서 빼는 것만 계산한다.

**분할의 완전성을 주장하지 않는다(V-7).** 그 관행의 일반 원칙이 판정의 준거 가운데 하나로 그
간행물 자신을 들어 잔여가 명시로 열려 있으므로, 이 넷이 저촉이 아닌 차이를 빠짐없이 덮는다는 근거가
없다.
-/
-- DD:CF-4055
inductive NonConflictKind where
  /-- 계산의 재현. 서류가 계산을 적으면 적힌 합계가 저촉하지 않는지만 본다. -/
  | calculationRestated
  /-- 뜻을 바꾸지 않는 오기. -/
  | harmlessTypo
  /-- 더 적힌 정보. 한 서류가 더 자세한 표시를 들고 다른 서류가 들지 않는 것. -/
  | extraDetail
  /-- 요구 밖의 언어로 적힌 자료. -/
  | languageBeyondRequest
  deriving DecidableEq

/--
서류 쌍의 차이를 그 열거에 매는 분류.

**대응 비형식 개념:** 어느 서류 쌍의 차이가 어느 갈래에 드는가, 그리고 그 갈래를 세운 문단이 어느
준거 층에서 오며 그 층이 그 갈래를 아직 다스리는가.

**이 정의가 배제하는 사례:**
그 열거를 신용장과 무관하게 늘 서는 것으로 보는 읽기. 그 관행의 예비 고찰이 그 간행물의 관행을
신용장의 문면이 해당 조항을 명시로 고치거나 배제하지 않는 한에서 세우므로, 신용장이 그 문단을 명시로
배제하면 그 갈래가 서지 않는다.
조달처: E-67 §2-2 「신용장의 문면이 해당 조항을 명시로 고치거나 배제하지 않는 한에서」

**기각한 대체 정의:**
그 넷이 전부 그 관행의 문단에서 오므로 층을 계산에 박아 넣는 안. 그 열거가 닫히지 않고 잔여가
명시로 열려 있어 뒤에 더해지는 갈래가 다른 층에서 올 수 있으므로, 층을 받는 자리로 두어야 그 자리가
구조에 남는다.
-/
-- DD:CF-4055
structure DifferenceClassification (DocIdx : Type) where
  /-- 그 서류 쌍의 차이가 드는 갈래. 열거 밖이면 없음이다. -/
  kindOf : DocIdx × DocIdx → Option NonConflictKind
  /-- 그 갈래를 세운 문단이 오는 준거 층. -/
  authority : NonConflictKind → CreditAuthority
  /-- 그 층이 그 갈래를 다스리는가. 신용장이 명시로 배제하면 다스리지 않는다. -/
  governing : AuthorityVerdict NonConflictKind

/-- witness (A-3). **무엇을 증거하는가.** `DifferenceClassification` 이 어느 서류 색인 타입에서나
비어 있지 않다. 어느 쌍도 갈래에 들지 않고 어느 층도 다스리지 않는 분류 하나를 든다. -/
-- DD:CF-4055
def DifferenceClassification.trivial {DocIdx : Type} : DifferenceClassification DocIdx where
  kindOf := fun _ => none
  authority := fun _ => .bankingPractice
  governing := AuthorityVerdict.trivial

/--
그 쌍의 차이를 열거가 좁히는가.

**대응 비형식 개념:** 그 차이가 네 갈래 가운데 하나에 들고 그 갈래를 세운 층이 아직 그것을 다스리면
그 차이는 저촉으로 세지 않는다.

**이 정의가 배제하는 사례:**
갈래에 들면 무조건 좁는다는 읽기. 그 관행이 자기 관행을 신용장의 문면이 명시로 고치거나 배제하지
않는 한에서 세우므로, 배제된 문단의 갈래가 좁히면 구조가 제도에 없는 것을 주장한다.
조달처: E-67 §2-2 「신용장의 문면이 해당 조항을 명시로 고치거나 배제하지 않는 한에서」

**기각한 대체 정의:**
좁힘을 서류 쌍마다의 참거짓으로 받는 안. 그러면 갈래가 구조에 남지 않아 어느 문단이 그 좁힘을 세웠는지
사라지고, 관측층이 그 갈래별 소스를 묻는 자리도 함께 사라진다.
-/
-- DD:CF-4055
def DifferenceClassification.narrows {DocIdx : Type}
    (K : DifferenceClassification DocIdx) (p : DocIdx × DocIdx) : Bool :=
  match K.kindOf p with
  | some k => K.governing.governs (K.authority k) k
  | none => false

/--
열거로 좁힌 저촉 판정.

**대응 비형식 개념:** 낸 서류끼리 어긋난 자리 가운데 열거가 좁히지 않은 것만 저촉으로 세는 판정.

**이 정의가 배제하는 사례:**
좁힘을 판정 기관의 판정 자체에 섞어 넣는 읽기. 그 관행이 저촉의 판정을 서류 종류마다 다른 문단으로
흩어 두고 저촉이 아닌 차이의 갈래를 일반 원칙의 문단으로 따로 열거하므로, 두 자리가 제도에서 갈려
있고 섞으면 그 갈림이 사라진다.
조달처: E-67 §2-5 「낱말이나 문장의 뜻을 바꾸지 않는 오기는 하자가 아니다」

**기각한 대체 정의:**
앞 페이즈의 저촉 판정을 고쳐 분류를 인자로 더하는 안. 그 판정이 착지해 그 문서화 문면이 영구히
남았으므로 고치면 그 표지가 가리키는 결정과 그 문면이 어긋나며, 따로 세우면 둘이 함께 서고 앞이
뒤를 함의하는 관계가 정리로 선다.
-/
-- DD:CF-4055
def Presentation.noConflictNarrowed {DocIdx : Type} [DecidableEq DocIdx]
    (P : Presentation DocIdx) (C : AdjudicatedCondition (DocIdx × DocIdx))
    (K : DifferenceClassification DocIdx) : Bool :=
  decide (∀ a ∈ P.presented, ∀ b ∈ P.presented,
    (C.holds (a, b) && !K.narrows (a, b)) = false)

/--
비서류적 조건.

**대응 비형식 개념:** 신용장이 두었으나 그 충족을 보일 서류를 정하지 않은 조건. 그 충족을 보일 서류와
그 조건이 가리키는 자료를 담은 서류와 그 자료가 조건과 어긋나는가가 그 재료다.

**이 정의가 배제하는 사례:**
그 조건을 기재되지 않은 것으로 통째로 지우는 읽기. 그 관행이 그 충족을 어느 서류로도 보일 필요가
없다고 적고 이어서 정해진 서류에 담긴 자료가 그 조건과 어긋나서는 안 된다고 적으므로, 지우면 뒤의
문면이 구조에서 사라진다.
조달처: E-67 §2-7 「그러나 정해진 서류에 담긴 자료가 그 조건과 어긋나서는 안 된다」

**기각한 대체 정의:**
그 조건을 발동조건의 문법으로 받는 안. 그 문법이 교차곱 정수 부등식과 외생 확인을 원자로 두고 지위의
칸을 갖지 않으므로 그것으로 받으면 두 지위 가운데 하나가 사라지며, 생성자에 지위의 칸을 더하면 한
생성자가 판정과 쓰임의 두 축을 함께 들어 어느 칸이 어느 축을 가르는지가 서지 않는다.
-/
-- DD:CF-4056
structure NondocumentaryCondition (DocIdx : Type) where
  /-- 그 충족을 보일 서류. 신용장이 정하지 않았으면 없음이다. -/
  evidencing : Option DocIdx
  /-- 그 조건이 가리키는 자료를 담은 서류. -/
  bearing : Finset DocIdx
  /-- 그 서류의 자료가 그 조건과 어긋나는가. -/
  contradicts : DocIdx → Bool

/-- witness (A-3). **무엇을 증거하는가.** `NondocumentaryCondition` 이 어느 서류 색인 타입에서나
비어 있지 않다. 충족을 보일 서류가 정해지지 않고 가리키는 자료도 없는 조건 하나를 든다. -/
-- DD:CF-4056
def NondocumentaryCondition.trivial {DocIdx : Type} : NondocumentaryCondition DocIdx where
  evidencing := none
  bearing := ∅
  contradicts := fun _ => false

/--
그 조건이 제시의 요건으로 서는가.

**대응 비형식 개념:** 그 조건의 충족을 어느 서류로 보여야 하는가. 신용장이 그 서류를 정했으면 요건으로
서고 정하지 않았으면 서지 않는다.

**이 정의가 배제하는 사례:**
서류가 정해지지 않은 조건도 요건으로 세우는 읽기. 그 관행이 그 충족을 어느 서류로도 보일 필요가 없다고
적으므로, 요건으로 세우면 제시가 보일 수 없는 것을 요구받는다.
조달처: E-67 §2-7 「그 충족을 어느 서류로도 보일 필요가 없다」

**기각한 대체 정의:**
요건의 지위와 저촉 기준의 지위를 한 칸에서 내는 안. 그러면 어느 쪽으로 받아도 다른 쪽이 사라지며, 그
사라짐이 이 파일이 담으려는 것이다.
-/
-- DD:CF-4056
def NondocumentaryCondition.standsAsRequirement {DocIdx : Type}
    (N : NondocumentaryCondition DocIdx) : Bool :=
  N.evidencing.isSome

/--
그 조건이 낸 저촉.

**대응 비형식 개념:** 낸 서류 가운데 그 조건이 가리키는 자료를 담은 것이 있고 그 자료가 조건과
어긋나면 저촉이다. 그 조건이 요건으로 지워졌는지와 무관하게 선다.

**이 정의가 배제하는 사례:**
요건으로 지워진 조건은 저촉도 낼 수 없다는 읽기. 그 관행이 충족을 보일 필요가 없다고 적은 바로 뒤에
정해진 서류의 자료가 그 조건과 어긋나서는 안 된다고 적으므로, 두 지위가 한 조건에 함께 선다.
조달처: E-67 §2-7 「그러나 정해진 서류에 담긴 자료가 그 조건과 어긋나서는 안 된다」

**기각한 대체 정의:**
낸 서류를 보지 않고 그 조건이 가리키는 서류 전량에서 어긋남을 찾는 안. 그 문면이 정해진 서류에 담긴
자료를 들므로 내지 않은 서류의 자료는 그 판정에 들지 않으며, 전량에서 찾으면 제시 밖의 자료가 저촉을
낸다.
-/
-- DD:CF-4056
def NondocumentaryCondition.conflicts {DocIdx : Type} [DecidableEq DocIdx]
    (N : NondocumentaryCondition DocIdx) (P : Presentation DocIdx) : Bool :=
  decide (∃ d ∈ N.bearing ∩ P.presented, N.contradicts d = true)

/--
그 분류가 내는 족 (L-13).

**대응 비형식 개념:** 시점에서 그 시점의 분류로 가는 함수. 신용장이 어느 문단을 배제했는지가
조건변경으로 바뀌는 것이 이 족이 담는 것이다.

**이 정의가 배제하는 사례:**
분류를 시점 없이 하나로 두는 읽기. 그 규칙이 조건변경을 자기 조문으로 세우고 변경의 순간부터 신용장이
변경된 것으로 보므로, 시점이 없으면 배제 전후가 같은 분류로 읽힌다.
조달처: E-67 §2-2 「신용장의 문면이 해당 조항을 명시로 고치거나 배제하지 않는 한에서」

**기각한 대체 정의:**
시간 의존을 회계층에서만 처리하고 정의층은 분류 하나를 고정으로 두는 안. 재유입처가 시계열
시뮬레이션을 수행하므로 재유입 시 정의층에 시점이 필요하다.
-/
-- DD:CF-4055
abbrev DifferenceClassificationFamily (DocIdx : Type) := ℕ → DifferenceClassification DocIdx

/-- 한 분류를 모든 시점에 두는 족. 시점에 따라 변하지 않는 분류를 드는 수단이다. -/
-- DD:CF-4055
def DifferenceClassificationFamily.constant {DocIdx : Type}
    (K : DifferenceClassification DocIdx) : DifferenceClassificationFamily DocIdx :=
  fun _ => K

/--
좁히지 않은 판정이 서면 좁힌 판정도 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어긋난 자리가 하나도 없는 제시에서 좁힌 판정이 저촉을 내야 한다. 그 관측은 좁힘이 저촉을 늘린다는
뜻이며, 그러면 그 열거가 제도가 적은 것과 반대로 작동한다.

**가정과 그 배제 사례(T-4·T-5):** 좁히지 않은 판정이 섰다는 것을 진술문의 인자로 둔다. 그 가정이
배제하는 것은 어긋난 자리가 있는 제시이며, 거기서는 좁힌 판정이 그 자리를 열거가 덮는지에 따라 참도
거짓도 될 수 있다.

**T-3 분류:** 기여다. 그 열거가 저촉을 늘리지 않고 좁히기만 한다는 것이 이 파일의 처방이고, 그
한쪽 방향을 이 정리가 들고 반대 방향이 서지 않음을 뒤 정리가 든다.
-/
-- DD:CF-4055
theorem noConflictNarrowed_of_noConflict {DocIdx : Type} [DecidableEq DocIdx]
    (P : Presentation DocIdx) (C : AdjudicatedCondition (DocIdx × DocIdx))
    (K : DifferenceClassification DocIdx)
    (h : P.noConflict C = true) :
    P.noConflictNarrowed C K = true := by
  -- 좁히지 않은 판정의 가정에서 낸 서류의 쌍마다 어긋남이 거짓이라는 것을 꺼낸다. 좁힌 판정의
  -- 쌍마다의 값은 그 어긋남을 앞 인자로 둔 논리곱이므로, 앞 인자를 거짓으로 바꾸면 거짓이 된다.
  unfold Presentation.noConflict at h
  unfold Presentation.noConflictNarrowed
  have h' := of_decide_eq_true h
  apply decide_eq_true
  intro a ha b hb
  rw [h' a ha b hb, Bool.false_and]

/--
좁힌 판정이 서고 좁히지 않은 판정이 서지 않는 배치가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 판정이 언제나 같은 값을 내야 한다. 그 관측은 그 열거가 아무것도 좁히지 않는다는 뜻이며, 그러면 이
파일이 세운 분류가 값을 내지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
좁힘은 어긋난 자리가 열거에 드는 배치를 들어야 보인다. 임의의 제시에서 두 판정이 갈리는 것이 아니라
그런 배치가 실재하는 것이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 열거가 실제로 좁힌다는 것을 드는 유일한 자리이고, 좁히지 않으면 그 구멍이
적은 자리가 서지 않는다.
-/
-- DD:CF-4055
theorem exists_noConflictNarrowed_without_noConflict :
    ∃ (P : Presentation Bool) (C : AdjudicatedCondition (Bool × Bool))
      (K : DifferenceClassification Bool),
      P.noConflict C = false ∧ P.noConflictNarrowed C K = true := by
  -- 서류 하나를 낸 제시와 모든 쌍이 어긋나는 판정을 들고, 모든 쌍을 뜻을 바꾸지 않는 오기로 매고
  -- 그 층이 그 갈래를 다스리는 분류를 든다. 좁히지 않은 판정은 그 어긋남으로 거짓이 되고 좁힌
  -- 판정은 그 어긋남이 좁혀져 참이 되므로, 칸마다 계산하면 값이 나와 `rfl` 로 닫힌다.
  exact ⟨⟨{true}, ∅⟩, ⟨fun _ => true⟩,
    ⟨fun _ => some .harmlessTypo, fun _ => .bankingPractice, ⟨fun _ _ => false, fun _ _ => true⟩⟩, rfl, rfl⟩

/--
신용장의 명시 배제가 그 좁힘을 끈다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 갈래에 드는 차이가 그 문단의 배제와 무관하게 좁혀야 한다. 그 관측은 그 열거가 신용장의 문면 위에
서는 것이 아니라 그 밖에 선다는 뜻이며, 그러면 그 관행이 자기 관행에 걸어 둔 조건이 구조에서 사라진다.

**존재 형태로 진술하는 까닭(T-6):**
배제의 효과는 갈래에 들었는데도 좁히지 않는 배치를 들어야 보인다. 임의의 분류에서 그런 것이 아니라
그 층이 다스리지 않는 분류가 실재하는 것이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 이 파일이 준거를 담는 파일을 적재하는 근거가 이 자리이고, 그 적재가 꾸며 낸
것이 아니라 제도에서 온다는 것을 드는 유일한 자리다.
-/
-- DD:CF-4055
theorem exists_excluded_blocks_narrowing :
    ∃ (P : Presentation Bool) (C : AdjudicatedCondition (Bool × Bool))
      (K : DifferenceClassification Bool),
      K.kindOf (true, true) = some NonConflictKind.harmlessTypo ∧
      K.governing.governs CreditAuthority.bankingPractice NonConflictKind.harmlessTypo = false ∧
      K.narrows (true, true) = false ∧
      P.noConflictNarrowed C K = false := by
  -- 앞 정리의 배치에서 그 층이 어느 갈래도 다스리지 않는 판정으로만 바꾼다. 그 쌍이 갈래에 드는데도
  -- 좁혀지지 않아 어긋남이 그대로 저촉으로 서므로, 칸마다 계산하면 값이 나와 `rfl` 로 닫힌다.
  exact ⟨⟨{true}, ∅⟩, ⟨fun _ => true⟩,
    ⟨fun _ => some .harmlessTypo, fun _ => .bankingPractice, AuthorityVerdict.trivial⟩,
    rfl, rfl, rfl, rfl⟩

/--
좁힌 판정이 두 인자에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어긋남만 있고 좁힘이 없는 자리나 좁힘만 있고 어긋남이 없는 자리에서 그 판정이 뒤집혀야 한다. 그
관측은 그 판정이 곱이 아니라는 뜻이며, 그러면 어긋남과 좁힘 가운데 하나가 지워진다.

**존재 형태로 진술하는 까닭(T-6):**
인자마다 그 하나만 참인 배치를 들어야 보인다. 임의의 배치에서 그 곱이 합과 갈리는 것이 아니라
나머지가 거짓인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 판정의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 논리
결합마다 각 인자가 홀로 값을 가르는 경로를 증거로 들라는 A-8 의 요구가 이 자리에 걸린다.
-/
-- DD:CF-4055
theorem noConflictNarrowed_pins_each_conjunct :
    ∃ (P : Presentation Bool) (C₀ C₁ : AdjudicatedCondition (Bool × Bool))
      (K₀ K₁ : DifferenceClassification Bool),
      P.noConflictNarrowed C₁ K₀ = false ∧
      P.noConflictNarrowed C₁ K₁ = true ∧
      P.noConflictNarrowed C₀ K₀ = true := by
  -- 서류 하나를 낸 제시를 두고, 어느 쌍도 어긋나지 않는 판정과 모든 쌍이 어긋나는 판정을 들며,
  -- 아무것도 좁히지 않는 분류와 모든 쌍을 좁히는 분류를 든다. 어긋남만 있고 좁힘이 없는 자리에서
  -- 저촉이 서고, 좁힘이 서거나 어긋남이 없으면 저촉이 서지 않으므로 칸마다 계산하면 값이 나와
  -- `rfl` 로 닫힌다.
  exact ⟨⟨{true}, ∅⟩, ⟨fun _ => false⟩, ⟨fun _ => true⟩,
    DifferenceClassification.trivial,
    ⟨fun _ => some .harmlessTypo, fun _ => .bankingPractice, ⟨fun _ _ => false, fun _ _ => true⟩⟩,
    rfl, rfl, rfl⟩

/--
요건으로 서지 않는 조건이 저촉을 내는 배치가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
충족을 보일 서류가 정해지지 않은 조건은 저촉도 낼 수 없어야 한다. 그 관측은 두 지위가 한 칸에서
난다는 뜻이며, 그러면 그 관행이 두 문장으로 적어 둔 것 가운데 뒤가 사라진다.

**존재 형태로 진술하는 까닭(T-6):**
두 지위의 독립은 앞이 거짓이고 뒤가 참인 배치를 들어야 보인다. 임의의 조건에서 갈리는 것이 아니라
그런 조건이 실재하는 것이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 구멍이 적은 두 지위가 이 구조에서 실제로 갈리는지를 드는 유일한 자리다.
-/
-- DD:CF-4056
theorem exists_conflicts_without_requirement :
    ∃ (N : NondocumentaryCondition Bool) (P : Presentation Bool),
      N.standsAsRequirement = false ∧ N.conflicts P = true := by
  -- 충족을 보일 서류를 정하지 않고, 낸 서류 하나가 그 조건이 가리키는 자료를 담으며 그 자료가
  -- 어긋나는 조건을 든다. 칸마다 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨⟨none, {true}, fun _ => true⟩, ⟨{true}, ∅⟩, rfl, rfl⟩

/--
요건으로 서는 조건이 저촉을 내지 않는 배치가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
충족을 보일 서류가 정해진 조건은 언제나 저촉을 내야 한다. 그 관측은 두 지위가 한쪽으로 접힌다는
뜻이며, 그러면 요건으로 섰다는 것이 곧 어긋났다는 것이 되어 제시의 판정이 무너진다.

**존재 형태로 진술하는 까닭(T-6):**
독립은 두 방향을 함께 들어야 보인다. 앞 정리가 한 방향을 들고 이 정리가 반대 방향을 들며, 둘 가운데
하나만 서면 그 둘이 함의 관계로 읽힌다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 지위가 서로를 함의하지 않음을 드는 자리이고 앞 정리와 짝을 이룬다.
-/
-- DD:CF-4056
theorem exists_requirement_without_conflicts :
    ∃ (N : NondocumentaryCondition Bool) (P : Presentation Bool),
      N.standsAsRequirement = true ∧ N.conflicts P = false := by
  -- 충족을 보일 서류를 정하고, 낸 서류 하나가 그 조건이 가리키는 자료를 담되 그 자료가 어긋나지
  -- 않는 조건을 든다. 칸마다 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨⟨some true, {true}, fun _ => false⟩, ⟨{true}, ∅⟩, rfl, rfl⟩

/--
열거가 서류 쌍의 차이를 전량 좁혀도 비서류적 조건이 낸 저촉은 남는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
서류 쌍의 차이가 전량 좁혀진 제시에서 그 조건의 저촉도 함께 사라져야 한다. 그 관측은 제도가 저촉의
경계를 한 자리에서 그었다는 뜻이며, 그러면 이 파일이 두 반쪽으로 세운 것이 하나로 접힌다.

**존재 형태로 진술하는 까닭(T-6):**
두 자리가 갈리는 것은 한쪽이 전량 좁혀진 배치를 들어야 보인다. 임의의 제시에서 갈리는 것이 아니라
그런 배치가 실재하는 것이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 관행이 저촉의 경계를 서류 쌍의 문단과 비서류적 조건의 문단 둘로 그었다는
것을 구조 안의 명제로 드는 유일한 자리이고, 이 파일이 두 구멍을 한 자리에 담는 근거가 여기 선다.
-/
-- DD:CF-4056
theorem exists_nondocumentary_conflict_beyond_narrowing :
    ∃ (N : NondocumentaryCondition Bool) (P : Presentation Bool)
      (C : AdjudicatedCondition (Bool × Bool)) (K : DifferenceClassification Bool),
      P.noConflictNarrowed C K = true ∧ N.conflicts P = true := by
  -- 모든 쌍이 어긋나는 판정과 모든 쌍을 좁히는 분류를 들어 서류 쌍의 차이를 전량 좁히고, 낸 서류
  -- 하나가 담은 자료가 어긋나는 비서류적 조건을 든다. 칸마다 계산하면 값이 나오므로 `rfl` 로
  -- 닫힌다.
  exact ⟨⟨none, {true}, fun _ => true⟩, ⟨{true}, ∅⟩, ⟨fun _ => true⟩,
    ⟨fun _ => some .harmlessTypo, fun _ => .bankingPractice, ⟨fun _ _ => false, fun _ _ => true⟩⟩, rfl, rfl⟩

end CrisisFramework.Definition
