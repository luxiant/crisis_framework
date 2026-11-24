/-
회계층 — 조달 실패의 금액과 그 금액이 노드를 가로지르는 자리

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(총액 기준으로 닫고 통화 간 환산을 금지한다),
      L-9(import 방향은 단방향), A-6(기준선 차분), C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목),
      D-3(배제 사례는 실제 문면), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시).

**수 체계: `ℤ`.** 정의층의 청구권이 수 체계를 매개변수로 받으므로 이 파일이 그 자리에 `ℤ` 를 넣는다.

**이 파일이 세우는 것은 채워지지 않은 몫의 통화별 금액과, 조달 실패의 꼴이 그 몫을 세운 집합에서 그 금액이
어느 노드의 어느 총계에 서는가다.** 정의층이 그 꼴마다 몫을 약정한 노드로 옮기거나 조달을 구한 노드에
남기거나 집합에서 걷는 연산을 세웠으므로, 이 파일의 항등식은 그 연산이 낸 집합과 예정된 집합의 총계를
맞댄다.

**좌변과 우변이 다른 노드를 가리키는 자리가 있다.** 약정이 떠안는 꼴에서 그 금액은 조달을 구한 노드의
부채에서 빠지지 않고 약정한 노드의 보유에 서므로, 그 금액을 잇는 항등식이 한 노드 안에서 닫히지 않는다.
노드 전량을 합하는 보존 정리가 그 금액이 어느 노드에 서든 사라지지 않음을 든다.

**보유자 쪽 총계와 부채 총계는 앞선 파일의 정의를 그대로 쓴다.** 다시 정의하지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Algebra.BigOperators.Ring.Finset
import CrisisFramework.Definition.Claim
import CrisisFramework.Definition.FundingFailure
import CrisisFramework.Accounting.Repayment
import CrisisFramework.Accounting.CurrencyMismatch

namespace CrisisFramework.Accounting

open CrisisFramework.Definition

/--
채워지지 않은 몫의 금액.

**대응 비형식 개념:** 예정된 청구권 집합에서 채워지지 않은 몫의 색인에 든 청구권의 금액을 통화 c 로 모은
것. 조달 실패의 꼴이 그 몫을 어디에 세우든 이 금액이 그 자리에서 움직이는 크기다.

**이 정의가 배제하는 사례:**
한 발행을 여러 인수기관이 나누어 떠안은 배치에서 인수기관마다의 몫. 증권발행실적보고서의 인수기관별 표가
인수기관마다 인수금액을 드는데(기업공시서식 작성기준 별지 제24호 서식), 이 합은 몫의 색인 집합 하나를
받으므로 인수기관마다의 금액은 몫을 갈라 거듭 재야 서고, 그 표의 금액은 약정이어서 실제로 떠안은 금액과
다를 수 있다.
조달처: E-73 §2-3 「그 인수금액이 인수기관이 인수하기로 약정한 금액이며」

**기각한 대체 정의:**
그 금액을 약정한 노드의 부채로 세는 총계로 두는 안. 공시 서식을 읽은 기록이 그 금액을 인수회사가 대금을
지급하는 의무로 적었으나 그 의무는 대금이 지급되면 사라지고 남는 것이 그 노드가 그 증권을 보유하는
것이어서, 부채로 세면 결제 뒤의 집합에서 그 금액이 서지 않는다.

**통화를 받는다.** 그 몫의 청구권이 여러 통화로 표시될 수 있고 통화 간 환산이 금지되므로 통화별로 낸다.
-/
-- DD:CF-4597
def shortfallTotal {ι Party Obs Ext Lvl Currency : Type} [DecidableEq ι] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) (D : Finset ι)
    (c : Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if i ∈ D ∧ (S.assign i).currency = c then evalTerm e (S.assign i).amount else 0)

/--
약정이 떠안는 꼴의 실현은 노드마다의 부채 총계를 예정과 같게 둔다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 인수회사가 실권주를 떠안거나 크레딧 라인이 갱신되지
않은 몫을 떠안은 뒤에 어느 노드의 그 통화 부채가 예정과 달라지는 것. 그러면 그 떠안음이 보유자만 바꾸는
것이 아니라 부채의 의무자나 금액을 바꾼 것이고, 약정이 떠안는 꼴을 보유자의 교체로 둔 정의층의 연산이
거짓이 된다.

**가정과 그 배제 사례(T-4·T-5):** 그 꼴이 약정이 떠안는 꼴이라는 가정을 진술문에 둔다. 그 가정이 배제하는
것은 부채 유출과 부담 불성립처럼 그 몫을 걷는 꼴이며, 그 꼴에서는 조달을 구한 노드의 부채가 준다.

**T-3 분류:** 기여다. 약정이 떠안는 꼴에서 조달을 구한 노드의 조달이 예정대로 선다는 것을 부채 총계의
등식으로 드는 유일한 자리이며, 좌변이 실현된 집합이고 우변이 예정된 집합이어서 두 집합의 총계를 맞댄다.
-/
-- DD:CF-4597
theorem liabilityTotalOf_realize_of_borneByCommitment
    {ι Party Obs Ext Lvl Currency : Type}
    [DecidableEq ι] [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (k : FundingFailureKind) (seeker bearer p : Party)
    (c : Currency) (D : Finset ι) (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency)
    (hk : k.borneByCommitment = true) :
    liabilityTotalOf e (k.realize seeker bearer D S) p c = liabilityTotalOf e S p c := by
  have hr : k.realize seeker bearer D S = S.reassignHolder D bearer := if_pos hk
  rw [hr]
  unfold liabilityTotalOf
  refine Finset.sum_congr rfl ?_
  intro i _
  -- 보유자만 바꾼 청구권은 의무자와 통화와 금액이 그대로다.
  by_cases hi : i ∈ D
  · have ha : (S.reassignHolder D bearer).assign i = { S.assign i with holder := bearer } :=
      if_pos hi
    rw [ha]
  · have ha : (S.reassignHolder D bearer).assign i = S.assign i := if_neg hi
    rw [ha]

/--
약정이 떠안는 꼴의 실현에서 약정한 노드의 보유 총계가 채워지지 않은 몫의 금액만큼 는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 대표주관회사가 실권주를 인수한 뒤에 그 인수회사가 그
통화로 보유한 청구권의 총계가 예정보다 그 몫의 금액과 다른 크기로 늘거나 늘지 않는 것. 그러면 그 금액이
약정한 노드에 선다는 이 파일의 전제가 거짓이 된다.

**가정과 그 배제 사례(T-4·T-5):** 가정이 둘이다. 그 꼴이 약정이 떠안는 꼴이라는 가정이 부담 잔류와 몫을
걷는 꼴을 배제하고, 약정한 노드가 그 몫을 예정에서 이미 보유하지 않았다는 가정이 인수회사가 청약자로서 그
몫의 일부를 이미 배정받은 자리를 배제한다. 뒤의 가정을 빼면 그 몫이 예정과 실현에서 같은 노드에 서므로
그 몫만큼의 증가가 서지 않아 진술이 거짓이 된다.

**T-3 분류:** 기여다. 조달 실패의 금액이 조달을 구한 노드가 아니라 약정한 노드의 총계에 서는 것을 드는
자리이며, 그 금액을 잇는 항등식의 좌변과 우변이 다른 노드를 가리킨다.
-/
-- DD:CF-4597
theorem claimTotalOfHolder_realize_of_borneByCommitment
    {ι Party Obs Ext Lvl Currency : Type}
    [DecidableEq ι] [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (k : FundingFailureKind) (seeker bearer : Party)
    (c : Currency) (D : Finset ι) (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency)
    (hk : k.borneByCommitment = true)
    (hD : ∀ i ∈ S.index, i ∈ D → (S.assign i).holder ≠ bearer) :
    claimTotalOfHolder e (k.realize seeker bearer D S) bearer c
      = claimTotalOfHolder e S bearer c + shortfallTotal e S D c := by
  have hr : k.realize seeker bearer D S = S.reassignHolder D bearer := if_pos hk
  rw [hr]
  unfold claimTotalOfHolder shortfallTotal
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl ?_
  intro i hi
  by_cases hiD : i ∈ D
  · have ha : (S.reassignHolder D bearer).assign i = { S.assign i with holder := bearer } :=
      if_pos hiD
    rw [ha]
    have hne := hD i hi hiD
    by_cases hc : (S.assign i).currency = c
    · have p1 : ({ S.assign i with holder := bearer } : Claim Party ℤ Obs Ext Lvl Currency).holder
          = bearer ∧ ({ S.assign i with holder := bearer } : Claim Party ℤ Obs Ext Lvl Currency).currency
          = c :=
        ⟨rfl, hc⟩
      have n2 : ¬((S.assign i).holder = bearer ∧ (S.assign i).currency = c) := fun h => hne h.1
      have p3 : i ∈ D ∧ (S.assign i).currency = c := ⟨hiD, hc⟩
      rw [if_pos p1, if_neg n2, if_pos p3, zero_add]
    · have n1 : ¬(({ S.assign i with holder := bearer } : Claim Party ℤ Obs Ext Lvl Currency).holder
          = bearer ∧ ({ S.assign i with holder := bearer } : Claim Party ℤ Obs Ext Lvl Currency).currency
          = c) :=
        fun h => hc h.2
      have n2 : ¬((S.assign i).holder = bearer ∧ (S.assign i).currency = c) := fun h => hc h.2
      have n3 : ¬(i ∈ D ∧ (S.assign i).currency = c) := fun h => hc h.2
      rw [if_neg n1, if_neg n2, if_neg n3, add_zero]
  · have ha : (S.reassignHolder D bearer).assign i = S.assign i := if_neg hiD
    have n3 : ¬(i ∈ D ∧ (S.assign i).currency = c) := fun h => hiD h.1
    rw [ha, if_neg n3, add_zero]

/--
부담 잔류의 실현에서 조달을 구한 노드의 보유 총계가 채워지지 않은 몫의 금액만큼 는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 팔리지 않은 증권화 발행분이 대차대조표로 되돌아온 뒤에
그 기관이 그 통화로 보유한 청구권의 총계가 예정보다 그 발행분의 금액만큼 늘지 않는 것. 그러면 그 몫이 그
노드의 자산에 남는다는 판정이 금액에서 서지 않는다.

**가정과 그 배제 사례(T-4·T-5):** 가정이 둘이다. 그 꼴이 자산을 남기는 꼴이라는 가정이 약정이 떠안는 꼴과
몫을 걷는 꼴을 배제하고, 조달을 구한 노드가 그 몫을 예정에서 이미 보유하지 않았다는 가정이 그 노드가 자기
발행분의 일부를 처음부터 남기기로 한 자리를 배제한다.

**T-3 분류:** 기여다. 되돌아온 발행분의 금액이 그 노드의 보유 쪽 총계에 서는 것을 드는 유일한 자리이며,
몫을 옮기는 꼴과 그 몫을 남기는 꼴의 금액이 같은 실현 연산 위의 항등식으로 이어진다.
-/
-- DD:CF-4597
theorem claimTotalOfHolder_realize_of_enlargesAssets
    {ι Party Obs Ext Lvl Currency : Type}
    [DecidableEq ι] [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (k : FundingFailureKind) (seeker bearer : Party)
    (c : Currency) (D : Finset ι) (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency)
    (hk : k.enlargesAssets = true)
    (hD : ∀ i ∈ S.index, i ∈ D → (S.assign i).holder ≠ seeker) :
    claimTotalOfHolder e (k.realize seeker bearer D S) seeker c
      = claimTotalOfHolder e S seeker c + shortfallTotal e S D c := by
  -- 판정이 꼴마다 정확히 하나만 참이므로 약정이 떠안는 꼴이 아니다.
  have hb : k.borneByCommitment = false := by
    have h := (FundingFailureKind.landing_exclusive_and_exhaustive k).1
    rw [hk, Bool.and_true] at h
    exact h
  have hr : k.realize seeker bearer D S = S.reassignHolder D seeker := by
    unfold FundingFailureKind.realize
    rw [if_neg (by rw [hb]; exact Bool.false_ne_true), if_pos hk]
  rw [hr]
  unfold claimTotalOfHolder shortfallTotal
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl ?_
  intro i hi
  by_cases hiD : i ∈ D
  · have ha : (S.reassignHolder D seeker).assign i = { S.assign i with holder := seeker } :=
      if_pos hiD
    rw [ha]
    have hne := hD i hi hiD
    by_cases hc : (S.assign i).currency = c
    · have p1 : ({ S.assign i with holder := seeker } : Claim Party ℤ Obs Ext Lvl Currency).holder
          = seeker ∧ ({ S.assign i with holder := seeker } : Claim Party ℤ Obs Ext Lvl Currency).currency
          = c :=
        ⟨rfl, hc⟩
      have n2 : ¬((S.assign i).holder = seeker ∧ (S.assign i).currency = c) := fun h => hne h.1
      have p3 : i ∈ D ∧ (S.assign i).currency = c := ⟨hiD, hc⟩
      rw [if_pos p1, if_neg n2, if_pos p3, zero_add]
    · have n1 : ¬(({ S.assign i with holder := seeker } : Claim Party ℤ Obs Ext Lvl Currency).holder
          = seeker ∧ ({ S.assign i with holder := seeker } : Claim Party ℤ Obs Ext Lvl Currency).currency
          = c) :=
        fun h => hc h.2
      have n2 : ¬((S.assign i).holder = seeker ∧ (S.assign i).currency = c) := fun h => hc h.2
      have n3 : ¬(i ∈ D ∧ (S.assign i).currency = c) := fun h => hc h.2
      rw [if_neg n1, if_neg n2, if_neg n3, add_zero]
  · have ha : (S.reassignHolder D seeker).assign i = S.assign i := if_neg hiD
    have n3 : ¬(i ∈ D ∧ (S.assign i).currency = c) := fun h => hiD h.1
    rw [ha, if_neg n3, add_zero]

/--
몫을 걷는 꼴의 실현에서 조달을 구한 노드의 부채 총계에 그 몫의 금액을 더하면 예정과 같다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 만기가 온 도매 조달이 갱신되지 않거나 미계약분이 생긴
뒤에 그 노드의 그 통화 부채가 예정보다 그 몫의 금액과 다른 크기로 주는 것. 그러면 그 몫을 걷는 것이 그
노드의 조달 쪽만 줄인다는 이 파일의 전제가 거짓이 된다.

**가정과 그 배제 사례(T-4·T-5):** 가정이 둘이다. 그 꼴이 조달 쪽을 줄이는 꼴이라는 가정이 약정이 떠안는
꼴과 부담 잔류를 배제하고, 그 몫의 청구권이 전부 조달을 구한 노드의 부채라는 가정이 그 몫에 다른 노드가
의무를 지는 청구권이 섞인 자리를 배제한다. 그 자리에서는 걷힌 금액의 일부가 다른 노드의 부채에서 빠진다.

**T-3 분류:** 기여다. 부채 유출과 부담 불성립의 금액이 조달을 구한 노드의 부채 쪽에서 빠지는 크기를 드는
유일한 자리다.
-/
-- DD:CF-4597
theorem liabilityTotalOf_realize_add_of_shrinksFunding
    {ι Party Obs Ext Lvl Currency : Type}
    [DecidableEq ι] [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (k : FundingFailureKind) (seeker bearer : Party)
    (c : Currency) (D : Finset ι) (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency)
    (hk : k.shrinksFunding = true)
    (hD : ∀ i ∈ S.index, i ∈ D → (S.assign i).obligor = seeker) :
    liabilityTotalOf e (k.realize seeker bearer D S) seeker c + shortfallTotal e S D c
      = liabilityTotalOf e S seeker c := by
  -- 판정이 꼴마다 정확히 하나만 참이므로 약정이 떠안는 꼴도 자산을 남기는 꼴도 아니다.
  have hx := FundingFailureKind.landing_exclusive_and_exhaustive k
  have hb : k.borneByCommitment = false := by
    have h := hx.2.1
    rw [hk, Bool.and_true] at h
    exact h
  have he : k.enlargesAssets = false := by
    have h := hx.2.2.1
    rw [hk, Bool.and_true] at h
    exact h
  have hr : k.realize seeker bearer D S = S.withoutIndices D := by
    unfold FundingFailureKind.realize
    rw [if_neg (by rw [hb]; exact Bool.false_ne_true),
      if_neg (by rw [he]; exact Bool.false_ne_true)]
  rw [hr]
  unfold liabilityTotalOf shortfallTotal
  -- 걷은 색인 위의 합을 원래 색인 위의 조건합으로 펼친다.
  have hfilter : ∀ (s : Finset ι) (g : ι → ℤ),
      ∑ i ∈ s.filter (fun i => i ∉ D), g i = ∑ i ∈ s, (if i ∉ D then g i else 0) := by
    intro s g
    induction s using Finset.cons_induction with
    | empty => rfl
    | cons a s ha ih =>
        rw [Finset.sum_cons]
        by_cases haD : a ∉ D
        · rw [Finset.filter_cons_of_pos (fun i => i ∉ D) a s ha haD, Finset.sum_cons, ih,
            if_pos haD]
        · rw [Finset.filter_cons_of_neg (fun i => i ∉ D) a s ha haD, ih, if_neg haD, zero_add]
  rw [show (S.withoutIndices D).index = S.index.filter (fun i => i ∉ D) from rfl,
    show (S.withoutIndices D).assign = S.assign from rfl, hfilter, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl ?_
  intro i hi
  by_cases hiD : i ∈ D
  · have ho := hD i hi hiD
    have n0 : ¬(i ∉ D) := fun h => h hiD
    rw [if_neg n0, zero_add]
    by_cases hc : (S.assign i).currency = c
    · rw [if_pos ⟨hiD, hc⟩, if_pos ⟨ho, hc⟩]
    · rw [if_neg (fun h => hc h.2), if_neg (fun h => hc h.2)]
  · have n3 : ¬(i ∈ D ∧ (S.assign i).currency = c) := fun h => hiD h.1
    rw [if_pos hiD, if_neg n3, add_zero]

/--
노드 전량의 보유 총계에 몫을 걷는 꼴의 금액을 더하면 예정된 집합의 같은 합이 된다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 조달 실패가 선 뒤에 노드 전량이 그 통화로 보유한
청구권의 합이 예정과 견주어 걷힌 몫의 금액과 다른 크기로 달라지는 것. 그러면 약정한 노드에서 늘어난
금액이 예정된 보유자들에서 준 금액과 맞지 않으므로, 그 금액이 노드를 건너 사라지지 않는다는 이 파일의
전제가 거짓이 된다.

**가정을 두지 않는다.** 그 꼴을 전칭으로 받고 조달 쪽을 줄이는 꼴인지를 진술문의 조건 항이 가르므로
명제로 된 가정이 서지 않는다. 당사자가 유한하다는 것은 인스턴스로 받는다.

**T-3 분류:** 기여다. 노드마다의 항등식만으로는 그 금액이 약정한 노드에서 늘어난 만큼 예정된 보유자들에서
줄었다는 것이 서지 않으므로, 노드를 건너 합하는 보존을 드는 유일한 자리다.
-/
-- DD:CF-4597
theorem sum_claimTotalOfHolder_realize_add
    {ι Party Obs Ext Lvl Currency : Type}
    [DecidableEq ι] [DecidableEq Party] [Fintype Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (k : FundingFailureKind) (seeker bearer : Party)
    (c : Currency) (D : Finset ι) (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) :
    ∑ p ∈ Finset.univ, claimTotalOfHolder e (k.realize seeker bearer D S) p c
        + (if k.shrinksFunding = true then shortfallTotal e S D c else 0)
      = ∑ p ∈ Finset.univ, claimTotalOfHolder e S p c := by
  -- 두 유한합의 순서를 바꾼다. 라이브러리의 교환 보조정리는 기준선 밖의 공리를 끌어오므로 직접 세운다.
  have swap : ∀ (s : Finset Party) (t : Finset ι) (g : Party → ι → ℤ),
      ∑ p ∈ s, ∑ i ∈ t, g p i = ∑ i ∈ t, ∑ p ∈ s, g p i := by
    intro s t g
    induction s using Finset.cons_induction with
    | empty =>
        rw [Finset.sum_empty]
        exact ((Finset.sum_congr rfl (fun i _ => Finset.sum_empty)).trans
          Finset.sum_const_zero).symm
    | cons a s ha ih =>
        rw [Finset.sum_cons, ih, ← Finset.sum_add_distrib]
        exact Finset.sum_congr rfl (fun i _ => (Finset.sum_cons (f := fun p => g p i) ha).symm)
  -- 한 당사자를 지목하는 항의 합은 그 당사자가 그 집합에 들 때에만 금액을 낸다.
  have pick : ∀ (s : Finset Party) (q : Party) (x : ℤ),
      (∑ p ∈ s, if q = p then x else 0) = if q ∈ s then x else 0 := by
    intro s q x
    induction s using Finset.cons_induction with
    | empty => rw [Finset.sum_empty, if_neg (Finset.notMem_empty q)]
    | cons b s hb ih =>
        rw [Finset.sum_cons, ih]
        by_cases hq : q = b
        · have hn : q ∉ s := fun h => hb (hq ▸ h)
          rw [if_pos hq, if_neg hn, if_pos (Finset.mem_cons.mpr (Or.inl hq)), add_zero]
        · rw [if_neg hq, zero_add]
          by_cases hs : q ∈ s
          · rw [if_pos hs, if_pos (Finset.mem_cons.mpr (Or.inr hs))]
          · have hn : q ∉ Finset.cons b s hb := fun h => (Finset.mem_cons.mp h).elim hq hs
            rw [if_neg hs, if_neg hn]
  -- 노드 전량의 보유 총계는 보유자가 누구든 그 통화의 금액 합과 같다.
  have total : ∀ (T : ClaimSet ι Party ℤ Obs Ext Lvl Currency),
      ∑ p ∈ Finset.univ, claimTotalOfHolder e T p c
        = ∑ i ∈ T.index,
            (if (T.assign i).currency = c then evalTerm e (T.assign i).amount else 0) := by
    intro T
    unfold claimTotalOfHolder
    rw [swap]
    refine Finset.sum_congr rfl ?_
    intro i _
    by_cases hc : (T.assign i).currency = c
    · rw [if_pos hc]
      have hcong : ∀ p ∈ (Finset.univ : Finset Party),
          (if (T.assign i).holder = p ∧ (T.assign i).currency = c
            then evalTerm e (T.assign i).amount else 0)
            = if (T.assign i).holder = p then evalTerm e (T.assign i).amount else 0 := by
        intro p _
        by_cases hp : (T.assign i).holder = p
        · rw [if_pos ⟨hp, hc⟩, if_pos hp]
        · rw [if_neg (fun h => hp h.1), if_neg hp]
      rw [Finset.sum_congr rfl hcong, pick, if_pos (Finset.mem_univ _)]
    · rw [if_neg hc]
      have hzero : ∀ p ∈ (Finset.univ : Finset Party),
          (if (T.assign i).holder = p ∧ (T.assign i).currency = c
            then evalTerm e (T.assign i).amount else 0) = 0 :=
        fun p _ => if_neg (fun h => hc h.2)
      rw [Finset.sum_congr rfl hzero, Finset.sum_const_zero]
  -- 보유자만 바꾼 집합은 색인과 표시 통화와 금액을 그대로 둔다.
  have keep : ∀ (q : Party),
      ∑ i ∈ (S.reassignHolder D q).index,
          (if ((S.reassignHolder D q).assign i).currency = c
            then evalTerm e ((S.reassignHolder D q).assign i).amount else 0)
        = ∑ i ∈ S.index,
          (if (S.assign i).currency = c then evalTerm e (S.assign i).amount else 0) := by
    intro q
    refine Finset.sum_congr rfl ?_
    intro i _
    by_cases hi : i ∈ D
    · have ha : (S.reassignHolder D q).assign i = { S.assign i with holder := q } := if_pos hi
      rw [ha]
    · have ha : (S.reassignHolder D q).assign i = S.assign i := if_neg hi
      rw [ha]
  have hx := FundingFailureKind.landing_exclusive_and_exhaustive k
  rw [total, total]
  by_cases hs : k.shrinksFunding = true
  · have hb : k.borneByCommitment = false := by
      have h := hx.2.1
      rw [hs, Bool.and_true] at h
      exact h
    have he : k.enlargesAssets = false := by
      have h := hx.2.2.1
      rw [hs, Bool.and_true] at h
      exact h
    have hr : k.realize seeker bearer D S = S.withoutIndices D := by
      unfold FundingFailureKind.realize
      rw [if_neg (by rw [hb]; exact Bool.false_ne_true),
        if_neg (by rw [he]; exact Bool.false_ne_true)]
    have hfilter : ∀ (s : Finset ι) (g : ι → ℤ),
        ∑ i ∈ s.filter (fun i => i ∉ D), g i = ∑ i ∈ s, (if i ∉ D then g i else 0) := by
      intro s g
      induction s using Finset.cons_induction with
      | empty => rfl
      | cons a s ha ih =>
          rw [Finset.sum_cons]
          by_cases haD : a ∉ D
          · rw [Finset.filter_cons_of_pos (fun i => i ∉ D) a s ha haD, Finset.sum_cons, ih,
              if_pos haD]
          · rw [Finset.filter_cons_of_neg (fun i => i ∉ D) a s ha haD, ih, if_neg haD, zero_add]
    rw [hr, if_pos hs, show (S.withoutIndices D).index = S.index.filter (fun i => i ∉ D) from rfl,
      show (S.withoutIndices D).assign = S.assign from rfl, hfilter]
    unfold shortfallTotal
    rw [← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl ?_
    intro i _
    by_cases hiD : i ∈ D
    · have n0 : ¬(i ∉ D) := fun h => h hiD
      rw [if_neg n0, zero_add]
      by_cases hc : (S.assign i).currency = c
      · rw [if_pos ⟨hiD, hc⟩, if_pos hc]
      · rw [if_neg (fun h => hc h.2), if_neg hc]
    · have n3 : ¬(i ∈ D ∧ (S.assign i).currency = c) := fun h => hiD h.1
      rw [if_pos hiD, if_neg n3, add_zero]
  · rw [if_neg hs, add_zero]
    unfold FundingFailureKind.realize
    by_cases hb : k.borneByCommitment = true
    · rw [if_pos hb, keep]
    · rw [if_neg hb]
      by_cases he : k.enlargesAssets = true
      · rw [if_pos he, keep]
      · -- 세 판정이 다 거짓인 꼴은 정확히 하나가 참이라는 정리에 어긋난다.
        exfalso
        have h4 := hx.2.2.2
        have hb' : k.borneByCommitment = false := by
          cases h : k.borneByCommitment
          · rfl
          · exact absurd h hb
        have he' : k.enlargesAssets = false := by
          cases h : k.enlargesAssets
          · rfl
          · exact absurd h he
        have hs' : k.shrinksFunding = false := by
          cases h : k.shrinksFunding
          · rfl
          · exact absurd h hs
        rw [hb', he', hs'] at h4
        exact Bool.false_ne_true h4

end CrisisFramework.Accounting
