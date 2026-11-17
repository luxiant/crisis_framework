/-
정의층 — 조건변경의 효력과 그것이 움직이는 조항 족

규율: L-9(import 방향은 단방향), L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족으로 정의한다), A-1(`axiom` 금지),
      A-3(witness 의무), C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-7(용어집 선행 등록),
      D-8(witness 의 서술), T-6(존재 형태).

**이 파일이 세우는 것은 조건의 충족이 조건 자체를 바꾸는 자리다.** 그 규칙이 수익자의 수락 통지가
없더라도 변경 내용에 부합하는 제시가 있으면 수락한 것으로 간주하고 그 순간부터 신용장이 변경된
것으로 보므로, 조항 족의 값이 자기 값에 의존하는 것으로 읽혔다.

**그 의존은 조항의 문면과 그 효력을 가르면 사라진다.** 변경이 내놓은 조항의 문면은 발행 시점에
고정되어 있고 정해지지 않은 것은 그것이 효력을 갖는가뿐이다. 부합을 재는 시점마다 쓰이는 조항이
그 고정된 문면이고 그때 효력을 갖는 조항이 아니므로, 족의 값이 자기 값이 아니라 이력에 의존한다.
**그래서 효력이 시점 위의 재귀로 서고 계산으로 닫힌다.**

**부합의 판정을 준거의 해소에서 받는다.** 제시가 변경의 조항에 부합했는가는 신용장의 준거 아래에서
내려지는 판정이므로, 그것을 또 하나의 받은 참거짓으로 두면 그 판정이 어느 준거에서 왔는지가 구조에서
사라진다. 그래서 이 파일이 준거를 담는 파일을 적재한다.

**이 파일은 수를 시점 인덱스로만 쓴다.** 그 밖의 자리에 수가 서지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.AdjudicationAuthority
import CrisisFramework.Definition.Trigger

namespace CrisisFramework.Definition

/--
조건변경의 기록.

**대응 비형식 개념:** 신용장에 조건변경이 통지된 뒤에 그 변경이 효력을 갖는지를 정하는 재료.
변경 전의 조항과 변경이 내놓은 조항과 변경이 통지된 시점과 각 시점의 제시가 변경의 조항에
부합했는가와 수익자가 수락을 명시로 통지한 시점이 그것이다.

**이 정의가 배제하는 사례:**
수익자의 명시 통지 없이는 수락이 서지 않는다는 읽기. 그 조문이 통지를 요구하면서도 통지가 없더라도
변경 내용에 부합하는 제시가 있으면 수락한 것으로 간주한다고 적으므로, 통지를 필수로 두면 그 간주가
구조에서 사라진다.
조달처: E-21 §2-8 「변경 내용에 부합하는 제시가 있으면 수락한 것으로 간주」

**기각한 대체 정의:**
변경 뒤의 조항을 시점에서 조항으로 가는 족 하나로 두고 그 족의 값이 자기 값의 충족에 의존한다고
적는 안. 그러면 그 족이 잘 정의되지 않고, 그 의존이 실은 문면과 효력을 가르면 사라지는 것이므로
표현되지 않는 것이 아니라 잘못 쪼갠 것이 된다.

**부합의 판정을 준거의 해소로 받는다.** 그 사건의 색인이 제시가 선 시점이다.
-/
-- DD:CF-4024
structure AmendmentRecord (Num Obs Ext Lvl : Type) where
  /-- 조건변경 전의 조항. -/
  original : Trigger Num Obs Ext Lvl
  /-- 조건변경이 내놓은 조항. 발행 시점에 고정된다. -/
  amended : Trigger Num Obs Ext Lvl
  /-- 조건변경이 통지된 시점. -/
  issued : ℕ
  /-- 그 시점의 제시가 변경의 조항에 부합했는가. 신용장의 준거가 해소한다. -/
  conforms : AuthorityVerdict ℕ
  /-- 수익자가 수락을 명시로 통지한 시점. 통지가 없으면 없음. -/
  noticed : Option ℕ

/-- witness (A-3). **무엇을 증거하는가.** `AmendmentRecord` 가 비어 있지 않다. 변경 전후의
조항이 같고 통지도 부합도 없는 기록 하나를 든다. -/
-- DD:CF-4024
def AmendmentRecord.trivial : AmendmentRecord Unit Unit Unit Unit where
  original := .check (.eq () ())
  amended := .check (.eq () ())
  issued := 0
  conforms := AuthorityVerdict.trivial
  noticed := none

/--
조건변경이 그 시점에 효력을 갖는가.

**대응 비형식 개념:** 그 시점에 신용장이 변경된 것으로 보는가. 통지로 수락이 섰거나, 발행 뒤의
어느 시점에 변경의 조항에 부합하는 제시가 있었으면 그렇다.

**이 정의가 배제하는 사례:**
발행 전의 제시가 수락을 세우는 읽기. 그 조문이 조건변경의 수락을 다루므로 변경이 통지되기 전의
제시가 그 변경을 수락한 것으로 읽힐 자리가 없으며, 가드를 두지 않으면 발행 시점이 구조의 필드로
서 있는데 어느 계산도 그것을 읽지 않아 그 필드가 유령으로 선다.
조달처: E-21 §2-8 「그 순간부터 신용장이 변경된 것으로 본다」

**기각한 대체 정의:**
효력을 그 시점의 부합만으로 두는 안. 그러면 부합하는 제시가 한 번 섰다가 뒤 시점에 서지 않을 때
효력이 되돌아가는데, 그 조문은 그 순간부터 변경된 것으로 본다고 적으므로 효력이 한 번 서면
유지된다.

**이 계산이 유한 탐색으로 닫힌다.** 시점까지의 구간을 훑으므로 결정 가능성이 타입에서 나온다.
-/
-- DD:CF-4024
def AmendmentRecord.accepted {Num Obs Ext Lvl : Type}
    (R : AmendmentRecord Num Obs Ext Lvl) (t : ℕ) : Bool :=
  decide (R.issued ≤ t) &&
    ((match R.noticed with
      | some s => decide (s ≤ t)
      | none => false)
     || (List.range (t + 1)).any
          (fun s => decide (R.issued ≤ s) && R.conforms.resolve s))

/--
그 시점에 효력을 갖는 조항.

**대응 비형식 개념:** 그 시점에 신용장의 조항이 무엇인가. 변경이 효력을 가지면 변경이 내놓은
조항이고 아니면 변경 전의 조항이다.

**이 정의가 배제하는 사례:**
조건변경이 통지된 순간부터 조항이 바뀐다는 읽기. 그 조문은 통지의 순간이 아니라 부합하는 제시가
선 순간부터 변경된 것으로 본다고 적으므로, 통지 시점을 경계로 두면 그 간주가 사라진다.
조달처: E-21 §2-8 「그 순간부터 신용장이 변경된 것으로 본다」

**기각한 대체 정의:**
두 조항을 함께 두고 둘 다 평가한 뒤 논리합으로 묶는 안. 그러면 변경 전의 조항이 변경 뒤에도 살아
남아 그 조문이 바꾼 것을 구조가 되돌린다.
-/
-- DD:CF-4024
def AmendmentRecord.clauseInForce {Num Obs Ext Lvl : Type}
    (R : AmendmentRecord Num Obs Ext Lvl) (t : ℕ) : Trigger Num Obs Ext Lvl :=
  if R.accepted t then R.amended else R.original

/--
그 기록이 내는 조항 족 (L-13).

**대응 비형식 개념:** 시점에서 그 시점의 조항으로 가는 함수. 조건변경이 그 함수를 움직이는 것이
이 파일이 담는 것이다.

**이 정의가 배제하는 사례:**
조건변경을 조항 족의 밖에 두고 회계층에서만 처리하는 읽기. 재유입처가 시계열 시뮬레이션을
수행하므로 재유입 시 정의층에 시점이 필요하고, 그 조문이 변경의 효력을 시점에 매므로 그 자리가
정의층이다.
조달처: E-21 §2-8 「그 순간부터 신용장이 변경된 것으로 본다」

**기각한 대체 정의:**
족을 새로 세우지 않고 기존 족의 생성자를 늘리는 안. 그 족은 시점에서 조항으로 가는 함수의 이름일
뿐이어서 늘릴 생성자가 없고, 늘리면 그 족을 딛는 앞 페이즈들의 진술이 함께 움직인다.
-/
-- DD:CF-4024
def AmendmentRecord.family {Num Obs Ext Lvl : Type}
    (R : AmendmentRecord Num Obs Ext Lvl) : TriggerFamily Num Obs Ext Lvl :=
  R.clauseInForce

/--
발행 전에는 효력이 서지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
변경이 통지되기 전의 시점에 그 변경이 효력을 가져야 한다. 그 관측은 발행 시점을 읽는 가드가 구조에
서 있지 않다는 뜻이며, 그러면 그 필드가 유령으로 선다.

**가정과 그 배제 사례(T-4·T-5):** 그 시점이 발행 시점보다 앞이라는 것을 진술문의 인자로 둔다.
그 가정이 배제하는 것은 발행 뒤의 시점이며, 거기서는 효력이 통지나 부합하는 제시에 걸려 참도
거짓도 될 수 있다.

**T-3 분류:** 보조 보정이다. 가드의 정의를 전개하면 증명이 닫히므로 기여 목록에 들지 않는다.
-/
-- DD:CF-4024
theorem accepted_false_of_lt_issued {Num Obs Ext Lvl : Type}
    (R : AmendmentRecord Num Obs Ext Lvl) (t : ℕ) (h : t < R.issued) :
    R.accepted t = false := by
  -- 효력을 펼치면 첫 인자가 발행 가드이고, 가정이 그 가드를 거짓으로 만들므로 곱 전체가 거짓이다.
  unfold AmendmentRecord.accepted
  rw [decide_eq_false (Nat.not_le_of_gt h), Bool.false_and]

/--
효력은 한 번 서면 뒤 시점에도 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 시점에 효력이 섰다가 뒤 시점에 서지 않아야 한다. 그 관측은 그 조문이 「그 순간부터」로 세운
것이 구조에서 되돌아간다는 뜻이며, 그러면 같은 신용장이 시점을 오가며 두 조항 사이를 왕복한다.

**가정과 그 배제 사례(T-4·T-5):** 앞 시점이 뒤 시점 이하라는 것과 앞 시점에 효력이 섰다는 것을
진술문의 인자로 둔다. 앞의 가정이 배제하는 것은 시점이 거꾸로 선 짝이고 뒤의 가정이 배제하는 것은
효력이 아직 서지 않은 시점이며, 뒤의 배치에서는 뒤 시점의 효력이 통지나 부합하는 제시에 걸려 참도
거짓도 될 수 있다.

**T-3 분류:** 기여다. 효력의 단조성은 그 조문이 적은 「그 순간부터」를 구조 안의 명제로 드는 유일한
자리이고, 그 재귀가 그것을 실제로 내는지를 이 정리가 재므로 기여 목록에 든다.
-/
-- DD:CF-4024
theorem accepted_monotone {Num Obs Ext Lvl : Type}
    (R : AmendmentRecord Num Obs Ext Lvl) (t u : ℕ)
    (hle : t ≤ u) (h : R.accepted t = true) :
    R.accepted u = true := by
  -- 효력을 발행 가드와 두 항의 합으로 가르고, 가드와 각 항이 뒤 시점에도 참으로 남음을 보인다.
  -- 가드와 통지의 항은 시점의 부등식이 이어져서 남고, 부합의 탐색은 앞 구간에서 찾은 시점이 뒤
  -- 구간에도 들어서 남는다.
  unfold AmendmentRecord.accepted at h ⊢
  obtain ⟨hg, hd⟩ := Bool.and_eq_true_iff.mp h
  refine Bool.and_eq_true_iff.mpr ⟨decide_eq_true (Nat.le_trans (of_decide_eq_true hg) hle), ?_⟩
  rcases Bool.or_eq_true_iff.mp hd with hn | hs
  · refine Bool.or_eq_true_iff.mpr (Or.inl ?_)
    cases hno : R.noticed with
    | none =>
      rw [hno] at hn
      exact Bool.noConfusion hn
    | some s =>
      rw [hno] at hn
      exact decide_eq_true (Nat.le_trans (of_decide_eq_true hn) hle)
  · refine Bool.or_eq_true_iff.mpr (Or.inr ?_)
    obtain ⟨s, hs₁, hs₂⟩ := List.any_eq_true.mp hs
    exact List.any_eq_true.mpr ⟨s, List.mem_range.mpr
      (Nat.lt_of_lt_of_le (List.mem_range.mp hs₁) (Nat.succ_le_succ hle)), hs₂⟩

/--
통지 없이 효력이 서는 배치가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
수락의 명시 통지가 없는 기록에서는 효력이 결코 서지 않아야 한다. 그 관측은 그 조문의 간주가 구조에
서지 않는다는 뜻이며, 그러면 이 파일이 담으려는 것이 남지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
간주는 통지가 없는데도 효력이 선 배치를 들어야 보인다. 임의의 기록에서 그런 것이 아니라 그런 기록이
실재하는 것이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 통지 없는 수락의 간주가 이 구조에서 실제로 서는지를 드는 유일한 자리다.
-/
-- DD:CF-4024
theorem exists_accepted_without_notice :
    ∃ (R : AmendmentRecord Unit Unit Unit Unit) (t : ℕ),
      R.noticed = none ∧ R.accepted t = true := by
  -- 통지 없이 시점 0 에 발행되고 그 시점의 제시가 부합한 기록을 든다. 발행 가드와 부합의 탐색이
  -- 함께 참이므로 효력이 서며, 칸마다 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨{ AmendmentRecord.trivial with conforms := ⟨fun _ _ => true, fun _ _ => true⟩ }, 0,
    rfl, rfl⟩

/--
효력의 판정이 각 항에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 두 항 가운데 하나만 참인 자리에서 거짓을 내야 한다. 그 관측은 그 판정이 합이 아니라는
뜻이며, 그러면 통지로 선 수락이나 부합으로 선 간주 가운데 하나가 지워진다.

**존재 형태로 진술하는 까닭(T-6):**
항마다 그 하나만 참인 배치를 들어야 보인다. 임의의 배치에서 각 항이 홀로 가르는 것이 아니라
나머지가 거짓인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 판정의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로,
각 항이 홀로 참인 자리를 이 정리가 든다.
-/
-- DD:CF-4024
theorem accepted_pins_each_disjunct :
    ∃ (R₁ R₂ : AmendmentRecord Unit Unit Unit Unit),
      R₁.noticed = some 0 ∧ R₁.conforms.resolve 0 = false ∧ R₁.accepted 0 = true ∧
      R₂.noticed = none ∧ R₂.conforms.resolve 0 = true ∧ R₂.accepted 0 = true := by
  -- 시점 0 에 통지가 서고 부합이 없는 기록과, 통지가 없고 시점 0 의 제시가 부합한 기록을 든다.
  -- 앞의 기록은 통지의 항만 참이고 뒤의 기록은 부합의 항만 참이며, 칸마다 계산하면 값이 나오므로
  -- `rfl` 로 닫힌다.
  exact ⟨{ AmendmentRecord.trivial with noticed := some 0 },
    { AmendmentRecord.trivial with conforms := ⟨fun _ _ => true, fun _ _ => true⟩ },
    rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
부합의 탐색 안에서 두 인자가 곱으로 묶인다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
발행 뒤의 어느 시점도 부합하지 않는 기록에서 효력이 서야 한다. 그 관측은 그 탐색이 두 인자를 합으로
묶는다는 뜻이며, 그러면 발행 시점이 지났다는 것만으로 간주가 서서 그 조문이 요구하는 부합이 지워진다.

**존재 형태로 진술하는 까닭(T-6):**
두 인자 가운데 하나만 참인 배치를 들어야 보인다. 임의의 기록에서 그 곱이 합과 갈리는 것이 아니라
부합이 어디서도 서지 않는 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 탐색의 곱을 합으로 뒤집은 변이가 이 증거 없이 통과하고, 논리 결합을 세우는
자리마다 각 인자가 홀로 값을 가르는 경로를 증거로 들라는 요구가 이 자리에 걸린다.
-/
-- DD:CF-4024
theorem exists_not_accepted_without_conformity :
    ∃ (R : AmendmentRecord Unit Unit Unit Unit),
      R.issued = 0 ∧ R.noticed = none ∧ R.conforms.resolve 0 = false ∧
      R.accepted 0 = false := by
  -- 통지도 부합도 없는 기록을 든다. 발행 가드는 참이나 두 항이 모두 거짓이어서 효력이 서지 않으며,
  -- 칸마다 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨AmendmentRecord.trivial, rfl, rfl, rfl, rfl⟩

/--
효력이 서면 그 시점의 조항이 변경이 내놓은 조항이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
효력이 선 시점에 변경 전의 조항이 서야 한다. 그 관측은 효력과 조항 사이의 고리가 끊겼다는 뜻이며,
그러면 효력을 계산한 것이 어느 조항도 움직이지 않는다.

**가정과 그 배제 사례(T-4·T-5):** 그 시점에 효력이 섰다는 것을 진술문의 인자로 둔다. 그 가정이
배제하는 것은 효력이 서지 않은 시점이며, 거기서는 서 있는 조항이 변경 전의 것이어서 이 등식의
오른쪽이 달라진다.

**T-3 분류:** 보조 보정이다. 조항 족의 정의를 전개하면 증명이 닫히므로 기여 목록에 들지 않는다.
-/
-- DD:CF-4024
theorem clauseInForce_of_accepted {Num Obs Ext Lvl : Type}
    (R : AmendmentRecord Num Obs Ext Lvl) (t : ℕ) (h : R.accepted t = true) :
    R.clauseInForce t = R.amended := by
  -- 조항을 펼치면 분기의 조건이 가정과 같으므로 변경이 내놓은 조항이 선다.
  unfold AmendmentRecord.clauseInForce
  rw [if_pos h]

end CrisisFramework.Definition
