/-
회계층 — 청구권의 순포지션

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(총액 기준으로 닫고 순액으로 닫지 않는다),
      L-8(색인), C-9(전면 `simp` 금지), A-6(기준선 차분), T-2(반증 조건).

**수 체계: `ℤ`.** 정의층의 `Claim` 이 수 체계를 매개변수로 받으므로 이 파일이 그 자리에 `ℤ` 를
넣는다. 금액이 `Term ℤ Obs` 이고 그 값을 그 시점의 판독에서 얻으므로 정의가 환경을 받는다.

**순포지션은 총액을 대신하지 않는다.** L-12 가 항등식을 총액 기준으로 유지하고 순액으로 닫는 것을
금지하므로 이 파일의 값이 총액 항등식을 대체하지 않으며, 같은 청구권 집합 위에 선 다른 축이다. 총액이
집계로 줄어드는 몫을 그 항등식이 들고, 이 파일은 집계가 그 축에서 무엇을 보존하는지를 든다.

**자기 청구권을 거르지 않는다.** 양쪽 끝이 같은 당사자인 청구권은 권리자 쪽에서 더해지고 의무자
쪽에서 같은 값만큼 빠져 저절로 상쇄되므로, 거르는 분기를 두면 같은 값을 두 꼴로 내게 된다. 총액 쪽이
거르는 것은 그 합이 뺄셈을 쓰지 않아 상쇄가 서지 않기 때문이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Algebra.BigOperators.Ring.Finset
import CrisisFramework.Definition.Claim

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
한 당사자의 청구권 순포지션.

**대응 비형식 개념:** 그 당사자가 그 통화로 받을 것에서 줄 것을 뺀 값. 채권 쪽을 더하고 채무 쪽을
빼며, 청구권 아닌 자산과 부채는 들지 않는다.

**이 정의가 배제하는 사례:**
두 결정 단위를 하나로 합치면서 그 사이의 청구권을 순액으로 상계해 총액을 지우는 읽기. 글로벌 가치사슬을
다룬 편이 같은 실물 흐름이 한 결정 단위 안에서는 재고로 서고 결정 단위 둘로 갈리면 매출채권으로 선다고
적어 경계가 총액을 만든다는 것을 관찰로 두는데, 그 상계를 총액에 적용하면 그 관찰이 집계에서 사라진다
(Bruno·Kim·Shin 2018).
조달처: E-19 §3-1 「경계가 총액을 만든다는 것이 이 편의 관찰이며」

**통화를 인자로 받고 그 통화의 청구권만 센다.** 통화 간 환산을 금지하는 요구가 색인 없는 합을 막으므로,
통화를 받지 않으면 이 값이 통화를 가로지른 값이 된다. 같은 파일의 총액이 같은 사유로 통화를 받는다.

**기각한 대체 정의:**
자산 전량에서 부채 전량을 빼는 순자산으로 두는 안. 순자산은 청구권만으로 계산되지 않고 재고와 현금처럼
청구권 아닌 자산이 들어가는데 이 층의 청구권 집합이 그것을 담지 않으므로, 그 이름을 쓰면 담지 않는 것을
담은 것처럼 읽힌다. 자기 청구권을 세는 자리에서 거르는 안도 기각했다. 상쇄가 이미 서므로 거르는 분기가
값을 바꾸지 않고 두 꼴만 늘린다.

**금액이 항이므로 환경을 받는다.** 변동금리 청구권의 금액이 그 시점의 판독에 달려 있기 때문이다.
-/
-- DD:CF-3876
def netPosition {ι Party Obs Ext Lvl Currency : Type} [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (c : Currency) (p : Party)
    (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).currency = c then
      (if (S.assign i).holder = p then evalTerm e (S.assign i).amount else 0)
        - (if (S.assign i).obligor = p then evalTerm e (S.assign i).amount else 0)
     else 0)

/--
집계 뒤 노드의 순포지션은 그 노드의 섬유 위 당사자 순포지션의 합이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 당사자를 하나로 묶었을 때 그 노드의 순포지션이 두 당사자 순포지션의 합과 다른 사례가 관측되어야
한다. 그 관측은 묶인 두 당사자 사이의 청구권이 한쪽에서만 지워졌다는 뜻이며, 그러면 그 청구권이
권리자 쪽과 의무자 쪽에서 같은 값으로 서지 않는다.

**형식층 배정:** 회계층. `ℤ` 와 `Finset` 합을 쓴다(L-8 의 색인, L-15).

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 받은 구멍의 재개 조건이 청구권 순포지션의 섬유 위 합을 지목하고 이 항등식이
그 합을 세우는 자리이며, 정의를 전개하기만 해서는 서지 않고 합의 교환과 조건합의 접기를 거친다.

**총액 쪽과 방향이 다르다.** 총액은 집계로 줄고 그 줄어드는 몫이 새로 내부화된 청구권의 금액인데,
순포지션은 줄지 않고 섬유 위로 모인다. 그 다름이 이 파일이 내는 것이다.
-/
-- DD:CF-3876
theorem netPosition_mapParty_eq_sum_fiber
    {ι Party Node Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [Fintype Party] [DecidableEq Node] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (c : Currency) (f : Party → Node) (n : Node)
    (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) :
    netPosition e c n (S.mapParty f)
      = ∑ p ∈ Finset.univ.filter (fun p => f p = n), netPosition e c p S := by
  -- 두 유한합의 순서를 바꾼다. 라이브러리의 교환 보조정리는 기준선 밖의 공리를 끌어오므로 직접 증명한다.
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
  -- 섬유에 든다는 것은 그 당사자의 상이 그 노드라는 것과 같다.
  have fib : ∀ (q : Party) (x : ℤ),
      (if q ∈ Finset.univ.filter (fun p => f p = n) then x else 0)
        = if f q = n then x else 0 := by
    intro q x
    by_cases hq : f q = n
    · rw [if_pos (Finset.mem_filter.mpr ⟨Finset.mem_univ q, hq⟩), if_pos hq]
    · have hn : q ∉ Finset.univ.filter (fun p => f p = n) :=
        fun hm => hq (Finset.mem_filter.mp hm).2
      rw [if_neg hn, if_neg hq]
  have hidx : (S.mapParty f).index = S.index := rfl
  unfold netPosition
  rw [hidx, swap]
  refine Finset.sum_congr rfl ?_
  intro i _
  have ho : ((S.mapParty f).assign i).obligor = f (S.assign i).obligor := rfl
  have hh : ((S.mapParty f).assign i).holder = f (S.assign i).holder := rfl
  have hc : ((S.mapParty f).assign i).currency = (S.assign i).currency := rfl
  have ha : ((S.mapParty f).assign i).amount = (S.assign i).amount := rfl
  rw [ho, hh, hc, ha]
  by_cases hcur : (S.assign i).currency = c
  · rw [if_pos hcur]
    conv_rhs => enter [2, p]; rw [if_pos hcur]
    rw [Finset.sum_sub_distrib, pick, pick, fib, fib]
  · rw [if_neg hcur]
    conv_rhs => enter [2, p]; rw [if_neg hcur]
    rw [Finset.sum_const_zero]

/--
당사자 전량의 순포지션 합은 영이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 청구권이 권리자 쪽에 더해지는 값과 의무자 쪽에서 빠지는 값이 다른 사례가 관측되어야 한다. 그
관측은 한 청구권의 금액이 보는 쪽에 따라 달라진다는 뜻이며, 그러면 그 금액이 청구권의 성질이 아니라
당사자의 성질이 된다.

**형식층 배정:** 회계층. `ℤ` 와 `Finset` 합을 쓴다(L-8 의 색인, L-15).

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 집계가 순포지션의 전체 합을 바꾸지 않는다는 것이 이 항등식과 앞의 항등식에서
함께 나오며, 그 둘이 서야 받은 구멍이 묻는 순자산 보존의 청구권 몫이 진술된다.

**이 값이 순자산이 아니다.** 자산에 청구권 아닌 것이 들어가므로 이 합이 영이라는 것은 청구권 축에서
서로 마주보는 값이 상쇄된다는 뜻이고, 순자산이 보존된다는 뜻이 아니다. 그 남는 몫이 구멍으로 선다.
-/
-- DD:CF-3876
theorem sum_netPosition_eq_zero
    {ι Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [Fintype Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (c : Currency)
    (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) :
    ∑ p ∈ Finset.univ, netPosition e c p S = 0 := by
  -- 당사자 전량을 한 점으로 묶으면 섬유가 전량이 되고, 묶인 뒤에는 권리자와 의무자가 같아 항마다 상쇄된다.
  have h := netPosition_mapParty_eq_sum_fiber e c (fun _ : Party => ()) () S
  rw [Finset.filter_true_of_mem (fun p _ => rfl)] at h
  rw [← h]
  unfold netPosition
  refine (Finset.sum_congr rfl ?_).trans Finset.sum_const_zero
  intro i _
  have hx : ((S.mapParty fun _ => ()).assign i).holder
      = ((S.mapParty fun _ => ()).assign i).obligor := rfl
  rw [hx, sub_self, ite_self]

/--
집계가 순포지션의 전체 합을 바꾸지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
당사자를 노드로 묶은 뒤의 전체 합이 묶기 전의 전체 합과 다른 사례가 관측되어야 한다. 두 값이 각각
영이므로 그 관측은 앞 항등식이 한쪽에서 깨진다는 뜻이다.

**형식층 배정:** 회계층. `ℤ` 와 `Finset` 합을 쓴다(L-8 의 색인, L-15).

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 앞 항등식을 두 자리에 적용하면 닫히므로 기여 목록에서 제외한다. 그 대신
총액 쪽의 항등식과 나란히 읽히는 자리를 세운다.
-/
-- DD:CF-3876
theorem sum_netPosition_mapParty_eq_sum_netPosition
    {ι Party Node Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [Fintype Party] [DecidableEq Node] [Fintype Node]
    [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (c : Currency) (f : Party → Node)
    (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) :
    ∑ n ∈ Finset.univ, netPosition e c n (S.mapParty f)
      = ∑ p ∈ Finset.univ, netPosition e c p S := by
  rw [sum_netPosition_eq_zero, sum_netPosition_eq_zero]

end CrisisFramework.Accounting
