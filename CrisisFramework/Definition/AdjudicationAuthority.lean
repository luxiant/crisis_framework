/-
정의층 — 판정이 서는 준거의 층과 그 해소

규율: L-9(import 방향은 단방향), L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족으로 정의한다), A-1(`axiom` 금지),
      A-3(witness 의무), C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-7(용어집 선행 등록),
      D-8(witness 의 서술), T-6(존재 형태).

**이 파일이 세우는 것은 한 판정이 어느 준거 아래에서 섰는가를 담는 자리다.** 신용장의 문면과 편입한
규칙과 국제표준은행관행이 한 묶음의 세 층으로 서고, 기초가 되는 매매계약의 준거법은 그 묶음 밖에서
따로 선다. 같은 사건을 두 묶음이 달리 판정하는 것이 이 자리가 담는 것이다.

**그 불일치를 해소하지 않는다.** 뭉치 안 문헌 사이의 차이를 봉합하지 말고 기록하라는 요구가 제도
사이의 차이에도 그대로 걸리며, 그 독립이 결손이 아니라 제도가 끊어 놓은 설계다.

**이 파일은 수를 시점 인덱스로만 쓴다.** 그 밖의 자리에 수가 서지 않는다.

**용어집의 선행 등록을 받지 않는다.** 그 요구의 판별 시험이 그 개념을 원 문헌이나 성문 규범이 자기
문면으로 세우는가를 묻는데, 그 규범이 세 층을 각각 자기 문면으로 들되 그 셋을 묶는 개념을 세우지
않으므로 이 열거는 판정을 층에 매는 색인이고 표현 수단이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Nat.Notation

namespace CrisisFramework.Definition

/--
한 묶음 안에서 판정이 설 수 있는 층.

**대응 비형식 개념:** 신용장 아래의 판정이 무엇에 기대어 서는가. 신용장이 자기 문면으로 적은 것과
그 신용장이 편입한 규칙과 그 규칙을 해석하는 은행 관행이 그 셋이다.

**이 정의가 배제하는 사례:**
기초가 되는 매매계약의 준거법. 그 법은 같은 선적을 판정하면서도 이 묶음의 한 층으로 서지 않는다.
예비 고찰이 신용장과 그 조건변경의 문면을 그 계약과 독립으로 두기 때문이며, 한 열거에 넣으면 넷
사이에 한 방향의 서열이 서는 것으로 읽혀 그 규범이 세우지 않은 것을 구조가 주장한다.
조달처: E-67 §2-3 「기초가 되는 매매 또는 다른 계약과 독립」

**기각한 대체 정의:**
층을 수로 매기고 그 수의 순서로 서열을 두는 안. 위층이 아래층을 덮는 것만이면 그 꼴로 접히는데,
예비 고찰이 그 규칙의 정의가 뜻밖의 결과를 내며 환적 금지를 세우려면 한 하위 조항을 배제해야
한다고 적어 **아래층의 정의가 위층의 평문을 다시 읽게 만드는 자리**를 든다. 그 자리는 한 방향의
수 순서로 서지 않으므로 열거만 두고 순서를 구조에 박지 않는다.
-/
-- DD:CF-4023
inductive CreditAuthority where
  /-- 신용장이 자기 문면으로 적은 것. -/
  | creditTerms
  /-- 그 신용장이 편입한 규칙. -/
  | incorporatedRules
  /-- 그 규칙을 해석하는 국제표준은행관행. -/
  | bankingPractice
  deriving DecidableEq

/--
한 사건에 대해 층마다 내려진 판정과 그 층이 그 사건을 다스리는가.

**대응 비형식 개념:** 같은 사건을 세 층이 각각 어떻게 판정하는가, 그리고 그 사건이 어느 층에서
정해지는가. 신용장이 한 조항을 명시로 배제했으면 그 사건은 그 층에서 정해지고 아래층으로 내려가지
않는다.

**이 정의가 배제하는 사례:**
한 층이 모든 사건을 다스린다고 보는 읽기. 예비 고찰이 그 관행을 신용장의 문면이 해당 조항을 명시로
고치거나 배제하지 않는 한에서 선다고 적으므로, 다스리는 범위가 층에 고정되지 않고 사건마다 갈린다.
조달처: E-67 §2-2 「명시로 고치거나 배제하지 않는 한에서」

**기각한 대체 정의:**
다스리는가를 구조가 계산하게 두는 안. 신용장이 어느 조항을 배제했는지는 그 문면을 읽어야 서고
구조가 그 읽기를 하지 않으므로, 계산으로 두면 제도가 갖지 않는 표현력을 문법이 갖게 된다.
-/
-- DD:CF-4023
structure AuthorityVerdict (Event : Type) where
  /-- 그 층이 그 사건에 내린 판정. -/
  byLayer : CreditAuthority → Event → Bool
  /-- 그 층이 그 사건을 다스리는가. -/
  governs : CreditAuthority → Event → Bool

/-- witness (A-3). **무엇을 증거하는가.** `AuthorityVerdict` 가 어느 사건 타입에서나 비어 있지
않다. 어느 층도 다스리지 않고 어느 판정도 거짓인 자리 하나를 든다. 사건 타입을 매개변수로 받는
꼴은 `ShareChannel.noSource` 가 선례를 둔다. -/
-- DD:CF-4023
def AuthorityVerdict.trivial {Event : Type} : AuthorityVerdict Event where
  byLayer := fun _ _ => false
  governs := fun _ _ => false

/--
시점 인덱스를 갖는 판정 족 (L-13).

**대응 비형식 개념:** 같은 사건에 대한 판정이 시간에 따라 달라지는 것. 조건변경과 면제와 유예가
그 자리다.

**이 정의가 배제하는 사례:**
판정을 시점 없이 하나로 두는 읽기. 조건변경이 그 규칙의 조문으로 서 있고 그 조문이 변경의 순간부터
신용장이 변경된 것으로 보므로, 시점이 없으면 변경 전후가 같은 판정으로 읽힌다.
조달처: E-21 §2-8 「그 순간부터 신용장이 변경된 것으로 본다」

**기각한 대체 정의:**
시간 의존을 회계층에서만 처리하고 정의층은 판정 하나를 고정으로 두는 안. 재유입처가 시계열
시뮬레이션을 수행하므로 재유입 시 정의층에 시점이 필요하다.
-/
-- DD:CF-4023
abbrev AuthorityVerdictFamily (Event : Type) := ℕ → AuthorityVerdict Event

/-- 한 판정을 모든 시점에 두는 족. 시점에 따라 변하지 않는 판정을 드는 수단이다. -/
-- DD:CF-4023
def AuthorityVerdictFamily.constant {Event : Type}
    (V : AuthorityVerdict Event) : AuthorityVerdictFamily Event :=
  fun _ => V

/--
세 층의 판정을 그 서열로 해소한다.

**대응 비형식 개념:** 위층이 그 사건을 다스리면 그 층의 판정이 서고, 다스리지 않으면 아래층으로
내려간다. 신용장이 적은 것이 먼저이고 그다음이 편입한 규칙이며 마지막이 그 관행이다.

**이 정의가 배제하는 사례:**
세 층의 판정을 다수결이나 논리곱으로 묶는 읽기. 예비 고찰이 그 관행을 위층이 명시로 고치거나
배제하지 않는 한에서 세우므로 층 사이가 투표가 아니라 덮음이고, 묶으면 위층의 명시한 배제가
아래층 둘에 눌린다.
조달처: E-67 §2-2 「명시로 고치거나 배제하지 않는 한에서」

**기각한 대체 정의:**
어느 층도 다스리지 않을 때 판정을 없음으로 내는 안. 그러면 반환 타입이 선택 타입이 되고 그 없음을
전파하는 규칙이 계약 문서에 없으므로, 제도가 갖지 않는 표현력을 문법이 갖게 된다. 관행이 최종
해석자로 남는 것이 그 규범의 꼴이므로 마지막 층을 바닥으로 둔다.
-/
-- DD:CF-4023
def AuthorityVerdict.resolve {Event : Type}
    (V : AuthorityVerdict Event) (e : Event) : Bool :=
  if V.governs .creditTerms e then V.byLayer .creditTerms e
  else if V.governs .incorporatedRules e then V.byLayer .incorporatedRules e
  else V.byLayer .bankingPractice e

/--
같은 사건을 신용장의 준거와 기초 계약의 준거가 달리 판정하는가.

**대응 비형식 개념:** 같은 선적이 한쪽에서는 일치하는 제시이고 다른 쪽에서는 계약 위반인 것.

**이 정의가 배제하는 사례:**
두 판정이 갈리면 하나를 버리고 하나를 남기는 읽기. 예비 고찰이 신용장과 그 계약을 독립으로 두므로
그 갈림이 어느 한쪽의 오류가 아니며, 봉합을 금지하는 요구가 그 자리에 걸린다.
조달처: E-67 §4-2 「다른 쪽에서 계약 위반인 것은 제도가 끊어 놓은 결과다」

**기각한 대체 정의:**
기초 계약의 판정을 세 층 옆의 넷째 층으로 두고 같은 해소를 돌리는 안. 그러면 한 묶음 안의 덮음이
두 묶음 사이에도 서는 것으로 읽혀, 그 규범이 독립이라고 적은 것을 구조가 서열로 바꾼다.
-/
-- DD:CF-4023
def verdictsDiverge {Event : Type}
    (V : AuthorityVerdict Event) (contractLaw : Event → Bool) (e : Event) : Bool :=
  V.resolve e != contractLaw e

/--
위층이 다스리면 그 층의 판정이 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
신용장이 명시로 정한 사건에서 해소가 아래층의 판정을 내야 한다. 그 관측은 예비 고찰이 세운 서열이
구조에서 뒤집혔다는 뜻이다.

**가정과 그 배제 사례(T-4·T-5):** 그 사건을 가장 위층이 다스린다는 것을 진술문의 인자로 둔다.
그 가정이 배제하는 것은 신용장이 그 사건을 적지 않은 배치이며, 거기서는 해소가 아래층으로 내려가
이 등식이 성립하지 않는다.

**T-3 분류:** 보조 보정이다. 해소의 정의를 전개하면 증명이 닫히므로 기여 목록에 들지 않는다.
-/
-- DD:CF-4023
theorem resolve_of_creditTerms_governs {Event : Type}
    (V : AuthorityVerdict Event) (e : Event)
    (h : V.governs .creditTerms e = true) :
    V.resolve e = V.byLayer .creditTerms e := by
  -- 해소를 펼치면 첫 분기의 조건이 가정과 같으므로 그 분기의 판정이 선다.
  unfold AuthorityVerdict.resolve
  rw [if_pos h]

/--
위층이 다스리지 않으면 아래층이 값을 가르는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
위층이 다스리지 않는데도 해소가 늘 위층의 판정을 내야 한다. 그 관측은 다스리는가를 받는 필드가
어느 계산에도 읽히지 않는다는 뜻이며, 그러면 그 필드가 유령으로 선다.

**존재 형태로 진술하는 까닭(T-6):**
층마다 그 층만 다스리는 배치를 들어야 보인다. 임의의 판정에서 아래층이 가르는 것이 아니라 위층이
비켜선 자리에서만 그 가름이 보인다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 세 층이 각각 홀로 값을 가르는 경로를 드는 유일한 자리이고, 그 경로를 들지
않으면 해소가 한 층만 읽는 것과 외연으로 구별되지 않는다.
-/
-- DD:CF-4023
theorem exists_resolve_from_each_layer :
    ∃ (V₁ V₂ V₃ : AuthorityVerdict Unit),
      V₁.resolve () = true ∧ V₂.resolve () = true ∧ V₃.resolve () = true ∧
      V₁.byLayer .creditTerms () = true ∧
      V₂.byLayer .creditTerms () = false ∧ V₂.byLayer .incorporatedRules () = true ∧
      V₃.byLayer .creditTerms () = false ∧ V₃.byLayer .incorporatedRules () = false ∧
      V₃.byLayer .bankingPractice () = true := by
  -- 위층이 다스리며 참을 내는 배치와, 위층이 비켜서고 가운데 층이 다스리며 참을 내는 배치와,
  -- 위의 두 층이 비켜서고 바닥 층만 참을 내는 배치를 든다. 칸마다 계산하면 값이 나오므로
  -- `rfl` 로 닫힌다.
  exact ⟨⟨fun _ _ => true, fun _ _ => true⟩,
    ⟨fun l _ => match l with
      | .creditTerms => false
      | .incorporatedRules => true
      | .bankingPractice => false,
     fun l _ => match l with
      | .creditTerms => false
      | .incorporatedRules => true
      | .bankingPractice => false⟩,
    ⟨fun l _ => match l with
      | .creditTerms => false
      | .incorporatedRules => false
      | .bankingPractice => true,
     fun _ _ => false⟩,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
두 준거의 판정이 갈리는 배치가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
신용장의 준거 아래의 판정과 기초 계약의 준거 아래의 판정이 언제나 같아야 한다. 그 관측은 두 제도가
같은 사건을 같게 판정한다는 뜻이며, 그러면 그 구멍이 적은 불일치가 서지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
불일치는 갈리는 배치를 들어야 보인다. 임의의 배치에서 갈리는 것이 아니라 그런 배치가 실재하는
것이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 같은 사건이 두 준거에서 달리 판정될 수 있다는 것이 이 구조에서 실제로
서는지를 드는 유일한 자리다.
-/
-- DD:CF-4023
theorem exists_verdictsDiverge :
    ∃ (V : AuthorityVerdict Unit) (contractLaw : Unit → Bool),
      verdictsDiverge V contractLaw () = true := by
  -- 어느 층도 다스리지 않고 바닥 층이 거짓을 내는 배치와, 참을 내는 기초 계약의 판정을 든다.
  -- 해소가 거짓이고 계약의 판정이 참이어서 둘이 갈리며, 칸마다 계산하면 값이 나오므로 `rfl` 로
  -- 닫힌다.
  exact ⟨AuthorityVerdict.trivial, fun _ => true, rfl⟩

end CrisisFramework.Definition
