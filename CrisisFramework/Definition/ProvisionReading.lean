/-
정의층 — 아래층의 정의가 위층의 평문을 다시 읽게 만드는 자리

규율: L-9(import 방향은 단방향), L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족으로 정의한다), A-1(`axiom` 금지),
      A-3(witness 의무), A-8(판정의 논리 결합마다 홀로 가르는 증거), C-3(판정 술어는
      `Decidable`), C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제
      문면), D-7(용어집 선행 등록), D-8(witness 의 서술), T-3(보조 보정과 기여의 분류),
      T-6(존재 형태).

**이 파일이 세우는 것은 신용장이 자기 문면으로 적은 조항이 효력을 갖는 조건이다.** 그 관행의 예비
고찰이 그 규칙의 여러 조항이 뜻밖의 결과를 내는 방식으로 용어를 정의한다고 적고, 선하증권을 요구하면서
환적을 금지한 신용장은 대개 그 금지가 효력을 가지려면 그 규칙의 한 하위 조항을 배제해야 한다고 적는다.

**그 자리는 앞 페이즈의 해소 함수와 덮음의 방향이 반대다.** 그 함수는 위층이 다스리면 그 층의 판정이
서고 다스리지 않으면 아래층으로 내려가는 것을 계산하는데, 이 자리는 아래층의 정의가 위층의 낱말의 뜻을
정하는 것이다. 그 함수를 고쳐 받으면 위층이 아래층을 덮는다는 서열의 뜻이 바뀌고 그 서열이 성문으로
선 것이므로, 구조를 따로 세우고 그 열거를 적재해 둘을 한 성분에 둔다.

**효력을 논리합으로 계산한다.** 아래층의 정의가 그 낱말을 무르게 하지 않거나, 신용장이 그 정의를 명시로
배제했거나, 그 낱말의 뜻을 신용장 자신의 층이 정했으면 그 낱말이 효력을 막지 않는다. 셋 가운데 어느
것도 서지 않는 낱말이 하나라도 있으면 그 조항은 금지를 적고도 효력을 갖지 않는다.

**이 파일은 수를 시점 인덱스로만 쓴다.** 그 밖의 자리에 수가 서지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Finset.Basic
import CrisisFramework.Definition.AdjudicationAuthority

namespace CrisisFramework.Definition

/--
신용장이 자기 문면으로 적은 조항의 읽기.

**대응 비형식 개념:** 그 조항의 문면에 선 낱말과, 그 낱말의 뜻을 정하는 준거 층과, 그 층의 정의가
그 조항을 무르게 하는가와, 신용장이 그 정의를 명시로 배제했는가.

**이 정의가 배제하는 사례:**
조항의 효력을 그 문면만으로 정하는 읽기. 그 관행의 예비 고찰이 환적을 금지한 신용장은 대개 그 금지가
효력을 가지려면 그 규칙의 한 하위 조항을 배제해야 한다고 적으므로, 문면만으로 정하면 금지를 적고도
효력이 서지 않는 자리가 구조에서 사라진다.
조달처: E-67 §2-4 「대개 그 금지가 효력을 가지려면 그 규칙의 한 하위 조항을 배제해야 한다」

**기각한 대체 정의:**
무르게 하는가를 구조가 계산하게 두는 안. 어느 정의가 어느 낱말을 무르게 하는지는 그 규칙의 문면과
그 신용장의 문면을 함께 읽어야 서고 구조가 그 읽기를 하지 않으므로, 계산으로 두면 제도가 갖지 않는
표현력을 문법이 갖게 된다. 그 소스 없음은 관측층이 받는다.
-/
-- DD:CF-4057
structure Provision (Word : Type) where
  /-- 그 조항의 문면에 선 낱말. -/
  words : Finset Word
  /-- 그 낱말의 뜻을 정하는 준거 층. -/
  definedBy : Word → CreditAuthority
  /-- 그 층의 정의가 그 조항을 무르게 하는가. -/
  weakens : Word → Bool
  /-- 신용장이 그 정의를 명시로 배제했는가. -/
  excluded : Word → Bool

/-- witness (A-3). **무엇을 증거하는가.** `Provision` 이 어느 낱말 타입에서나 비어 있지 않다.
낱말이 하나도 서지 않고 어느 정의도 무르게 하지 않는 조항 하나를 든다. -/
-- DD:CF-4057
def Provision.trivial {Word : Type} : Provision Word where
  words := ∅
  definedBy := fun _ => .creditTerms
  weakens := fun _ => false
  excluded := fun _ => false

/--
그 낱말이 그 조항의 효력을 막지 않는가.

**대응 비형식 개념:** 그 낱말의 뜻에서 오는 세 길 가운데 하나라도 서면 그 낱말이 효력을 막지 않는다.
아래층의 정의가 무르게 하지 않거나, 신용장이 그 정의를 명시로 배제했거나, 그 뜻을 신용장 자신의 층이
정한 것이 그 셋이다.

**이 정의가 배제하는 사례:**
명시 배제를 두면 아래층의 정의가 여전히 그 낱말의 뜻을 정한다고 보는 읽기. 그 예비 고찰이 그 관행을
신용장의 문면이 해당 조항을 명시로 고치거나 배제하지 않는 한에서 세우므로, 배제된 조항의 정의가 효력을
막으면 그 조건이 구조에서 사라진다.
조달처: E-67 §2-2 「신용장의 문면이 해당 조항을 명시로 고치거나 배제하지 않는 한에서」

**기각한 대체 정의:**
무르게 함과 배제를 곱으로 묶어 효력을 막는 조건으로 두는 안. 두 꼴이 외연으로 같으나 그 예비 고찰이
효력을 갖는 조건을 적고 있으므로 그 문면의 방향을 따라 합으로 둔다. 신용장 자신의 층이 정한 낱말을
그 합에서 빼면 위층이 자기 평문을 스스로 무르게 하는 배치가 서고, 그 서열이 성문으로 선 것이므로 그
자리를 셋째 길로 둔다.
-/
-- DD:CF-4057
def Provision.wordAllows {Word : Type} (V : Provision Word) (w : Word) : Bool :=
  !V.weakens w || V.excluded w || decide (V.definedBy w = CreditAuthority.creditTerms)

/--
그 조항이 효력을 갖는가.

**대응 비형식 개념:** 그 조항의 문면에 선 낱말이 전부 효력을 막지 않으면 그 조항이 효력을 갖는다.

**이 정의가 배제하는 사례:**
낱말 하나가 효력을 막아도 조항의 나머지가 효력을 갖는다고 보는 읽기. 그 예비 고찰이 환적을 금지한
신용장의 금지 전체가 효력을 잃는 것으로 적으므로, 낱말마다 효력을 쪼개면 그 금지가 반쯤 서는 배치가
구조에 생긴다.
조달처: E-67 §2-4 「대개 그 금지가 효력을 가지려면 그 규칙의 한 하위 조항을 배제해야 한다」

**기각한 대체 정의:**
효력을 낱말마다 내고 그 조항의 효력을 그 논리곱으로 두는 안. 외연은 같으나 조항을 단위로 두면 그
조항이 금지로서 서는지를 한 자리에서 묻게 되고, 관측층이 그 조항을 단위로 측정의 대상에 올린다.
-/
-- DD:CF-4057
def Provision.effective {Word : Type} [DecidableEq Word] (V : Provision Word) : Bool :=
  decide (∀ w ∈ V.words, V.wordAllows w = true)

/--
그 조항이 내는 읽기 족 (L-13).

**대응 비형식 개념:** 시점에서 그 시점의 조항 읽기로 가는 함수. 신용장이 어느 정의를 배제했는지가
조건변경으로 바뀌는 것이 이 족이 담는 것이다.

**이 정의가 배제하는 사례:**
읽기를 시점 없이 하나로 두는 읽기. 그 예비 고찰이 그 관행을 신용장의 문면이 명시로 고치거나 배제하지
않는 한에서 세우고 그 문면이 조건변경으로 바뀌므로, 시점이 없으면 배제 전후가 같은 읽기로 읽힌다.
조달처: E-67 §2-2 「신용장의 문면이 해당 조항을 명시로 고치거나 배제하지 않는 한에서」

**기각한 대체 정의:**
시간 의존을 회계층에서만 처리하고 정의층은 읽기 하나를 고정으로 두는 안. 재유입처가 시계열
시뮬레이션을 수행하므로 재유입 시 정의층에 시점이 필요하다.
-/
-- DD:CF-4057
abbrev ProvisionFamily (Word : Type) := ℕ → Provision Word

/-- 한 읽기를 모든 시점에 두는 족. 시점에 따라 변하지 않는 읽기를 드는 수단이다. -/
-- DD:CF-4057
def ProvisionFamily.constant {Word : Type} (V : Provision Word) : ProvisionFamily Word :=
  fun _ => V

/--
어느 정의도 무르게 하지 않으면 그 조항이 효력을 갖는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 낱말도 무르게 되지 않는 조항에서 효력이 서지 않아야 한다. 그 관측은 효력의 계산이 무르게 함을
읽지 않는다는 뜻이며, 그러면 그 세 길 가운데 첫째가 아무것도 하지 않는다.

**가정과 그 배제 사례(T-4·T-5):** 그 조항의 어느 낱말도 무르게 되지 않는다는 것을 진술문의 인자로
둔다. 그 가정이 배제하는 것은 무르게 되는 낱말이 선 조항이며, 거기서는 효력이 명시 배제와 그 낱말의
층에 걸려 참도 거짓도 될 수 있다.

**T-3 분류:** 보조 보정이다. 두 판정의 정의를 전개하면 증명이 닫히므로 기여 목록에 들지 않는다.
-/
-- DD:CF-4057
theorem effective_of_no_weakening {Word : Type} [DecidableEq Word]
    (V : Provision Word) (h : ∀ w, V.weakens w = false) :
    V.effective = true := by
  -- 효력을 펼쳐 낱말마다의 판정으로 내리고, 무르게 함의 가정으로 첫 항을 참으로 바꾸면 논리합이
  -- 참이 된다.
  unfold Provision.effective
  apply decide_eq_true
  intro w _
  unfold Provision.wordAllows
  rw [h w, Bool.not_false, Bool.true_or, Bool.true_or]

/--
금지를 적고도 효력이 서지 않는 배치가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
신용장이 자기 문면으로 적은 조항은 언제나 효력을 가져야 한다. 그 관측은 아래층의 정의가 위층의 평문을
다시 읽게 만드는 자리가 이 구조에 담기지 않는다는 뜻이며, 그러면 그 구멍이 적은 것이 남지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
그 자리는 아래층이 정한 낱말이 무르게 하고 그 정의가 배제되지 않은 조항을 들어야 보인다. 임의의
조항에서 효력이 서지 않는 것이 아니라 그런 조항이 실재하는 것이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 구멍이 적은 자리가 이 구조에서 실제로 서는지를 드는 유일한 자리다.
-/
-- DD:CF-4057
theorem exists_prohibition_without_effect :
    ∃ V : Provision Bool,
      V.weakens true = true ∧ V.excluded true = false ∧
      V.definedBy true = CreditAuthority.incorporatedRules ∧ V.effective = false := by
  -- 낱말 하나를 든 조항에서 그 낱말의 뜻을 편입한 규칙이 정하고, 그 정의가 무르게 하며 배제되지
  -- 않은 배치를 든다. 칸마다 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨⟨{true}, fun _ => .incorporatedRules, fun _ => true, fun _ => false⟩,
    rfl, rfl, rfl, rfl⟩

/--
명시 배제가 그 효력을 되살린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 정의를 명시로 배제해도 효력이 서지 않아야 한다. 그 관측은 그 예비 고찰이 적은 배제의 효과가 구조에
서지 않는다는 뜻이며, 그러면 금지를 세울 길이 아예 없다.

**존재 형태로 진술하는 까닭(T-6):**
배제의 효과는 앞 정리의 조항에서 배제만 바꾼 배치를 들어야 보인다. 임의의 조항에서 효력이 서는 것이
아니라 그 하나의 칸이 값을 뒤집는 것이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 예비 고찰이 금지를 세우는 길로 적은 것이 이 구조에서 실제로 통하는지를 드는
유일한 자리다.
-/
-- DD:CF-4057
theorem exists_exclusion_restores_effect :
    ∃ V : Provision Bool,
      V.weakens true = true ∧ V.excluded true = true ∧
      V.definedBy true = CreditAuthority.incorporatedRules ∧ V.effective = true := by
  -- 앞 정리의 조항에서 명시 배제의 칸만 참으로 바꾼다. 칸마다 계산하면 값이 나오므로 `rfl` 로
  -- 닫힌다.
  exact ⟨⟨{true}, fun _ => .incorporatedRules, fun _ => true, fun _ => true⟩,
    rfl, rfl, rfl, rfl⟩

/--
신용장 자신의 층이 정한 낱말은 그 평문을 무르게 하지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
신용장이 자기 문면으로 뜻을 정한 낱말이 그 조항의 효력을 막아야 한다. 그 관측은 위층이 자기 평문을
스스로 무르게 하는 배치가 구조에 선다는 뜻이며, 그러면 준거의 서열이 그 자리에서 뒤집힌다.

**존재 형태로 진술하는 까닭(T-6):**
그 셋째 길은 무르게 함이 참인데도 효력이 서는 배치를 들어야 보인다. 임의의 조항에서 그런 것이 아니라
그 층이 신용장 자신인 조항이 실재하는 것이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 이 파일이 준거의 열거를 적재하는 근거가 이 자리이고, 그 적재가 꾸며 낸 것이
아니라 그 예비 고찰이 세운 서열에서 온다는 것을 드는 유일한 자리다.
-/
-- DD:CF-4057
theorem exists_own_layer_cannot_undercut :
    ∃ V : Provision Bool,
      V.weakens true = true ∧ V.excluded true = false ∧
      V.definedBy true = CreditAuthority.creditTerms ∧ V.effective = true := by
  -- 앞 정리의 첫 조항에서 그 낱말의 뜻을 정하는 층만 신용장 자신으로 바꾼다. 칸마다 계산하면
  -- 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨⟨{true}, fun _ => .creditTerms, fun _ => true, fun _ => false⟩,
    rfl, rfl, rfl, rfl⟩

/--
낱말의 판정이 세 항에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
세 항 가운데 하나만 참인 자리에서 그 판정이 거짓을 내야 한다. 그 관측은 그 판정이 합이 아니라는
뜻이며, 그러면 무르게 하지 않음과 명시 배제와 자기 층 가운데 둘이 지워진다.

**존재 형태로 진술하는 까닭(T-6):**
항마다 그 하나만 참인 배치를 들어야 보인다. 임의의 배치에서 각 항이 홀로 가르는 것이 아니라 나머지가
거짓인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 판정의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 논리
결합마다 각 인자가 홀로 값을 가르는 경로를 증거로 들라는 A-8 의 요구가 이 자리에 걸린다.
-/
-- DD:CF-4057
theorem wordAllows_pins_each_disjunct :
    ∃ V₀ V₁ V₂ V₃ : Provision Bool,
      V₀.wordAllows true = false ∧
      V₁.wordAllows true = true ∧ V₂.wordAllows true = true ∧ V₃.wordAllows true = true ∧
      V₁.weakens true = false ∧ V₂.excluded true = true ∧
      V₃.definedBy true = CreditAuthority.creditTerms := by
  -- 세 항이 전부 거짓인 조항과, 세 항 가운데 하나씩만 참인 조항 셋을 든다. 낱말의 판정은 조항의
  -- 낱말 집합을 읽지 않으므로 그 집합을 비워 둔다. 칸마다 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨⟨∅, fun _ => .incorporatedRules, fun _ => true, fun _ => false⟩,
    ⟨∅, fun _ => .incorporatedRules, fun _ => false, fun _ => false⟩,
    ⟨∅, fun _ => .incorporatedRules, fun _ => true, fun _ => true⟩,
    ⟨∅, fun _ => .creditTerms, fun _ => true, fun _ => false⟩,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Definition
