/-
회계층 — 통화 교환 약정의 인출 총액과 한도

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(총액 기준으로 닫고 통화 간 환산을 금지한다),
      L-9(import 방향은 단방향), A-1(`axiom` 금지), A-6(기준선 차분),
      C-1·C-2(`noncomputable` 과 `Classical` 금지), C-3(판정 술어는 `Decidable`),
      C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시), T-6(존재 형태).

**수 체계: `ℤ`.** 약정의 한도가 수 체계를 매개변수로 받는 항이므로 이 파일이 그 자리에 `ℤ` 를
넣고 그 항을 환경에서 읽는다.

**이 파일이 세우는 것은 개별 거래가 기본 약정의 한도에 어떻게 묶이는가다.** 개별 거래가 청구권으로
이미 서므로 따로 타입을 세우지 않고 그 청구권 집합에서 그 약정에 딸린 것을 거르는 자리가 선다.

**한도의 부재와 한도의 충족을 한 판정으로 묶는다.** 한도가 없으면 그 판정이 늘 참이고 그 참이
금액 영과 다른 사실이므로, 선택 타입의 두 값이 그 판정의 두 갈래로 간다.
-/

import Mathlib.Algebra.BigOperators.Ring.Finset
import CrisisFramework.Definition.CentralBankSwapLine
import CrisisFramework.Accounting.Repayment

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
그 약정에 딸려 인출된 금액의 합.

**대응 비형식 개념:** 한 기본 약정 아래에서 실제로 발동된 개별 거래의 미결제 원금 총액. 국제
기구의 지침이 그 총액만 거시 통계에 기재하고 기본 약정의 최대 금액은 기재하지 않는다고 적는다.

**이 정의가 배제하는 사례:**
약정의 최대 금액을 기재된 총액으로 보는 읽기. 국제 기구의 지침이 요청 중앙은행에 활성화된 자금만
거시 통계에 기재하고 기본 약정의 최대 금액은 기재하지 않는다고 적으므로, 최대 금액을 총액으로
보면 기재되지 않는 값이 장부에 선다.
조달처: E-63 §3-2 「요청 중앙은행에 활성화된 자금만 거시 통계에 기재하고 기본 약정의 최대 금액은 기재하지 않는다」

**기각한 대체 정의:**
개별 거래의 타입을 따로 세우고 그 집합 위에서 더하는 안. 개별 거래가 청구권 셋과 담보 하나의
합성으로 이미 서므로 타입을 또 세우면 같은 실물이 두 색인을 갖고, 그 둘이 갈릴 수 있다.

**세 조건을 함께 받는다.** 채무자가 수취자이고 보유자가 공급자이며 표시 통화가 공급 통화인 것이
그 약정에 딸린 거래의 조건이고, 통화 색인을 빼면 통화 간 환산이 선다.
-/
-- DD:CF-3102
def drawnTotalUnder {Idx Node Obs Ext Lvl Currency : Type}
    [DecidableEq Node] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Node ℤ Obs Ext Lvl Currency)
    (s : CentralBankSwapLine Node Currency ℤ Obs) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).obligor = s.recipient ∧ (S.assign i).holder = s.supplier
        ∧ (S.assign i).currency = s.suppliedCurrency
     then evalTerm e (S.assign i).amount else 0)

/--
그 약정의 인출 총액이 수취자의 그 통화 부채 총계를 넘지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
금액이 전부 음이 아닌 청구권 집합인데 그 약정의 인출 총액이 수취자의 그 통화 부채 총계보다 커야
한다. 그 관측은 그 약정에 딸린 거래가 수취자의 부채로 서지 않는다는 뜻이며, 그러면 미결제 원금을
부채로 기재하라는 지침이 이 구조에서 성립하지 않는다.

**가정과 그 배제 사례(T-4·T-5):** 색인에 든 청구권의 금액이 전부 음이 아니라는 가정을 진술문에
둔다. 회계층의 수 체계가 `ℤ` 여서 금액이 음일 수 있고 그러면 부분집합의 합이 전체의 합보다 커질
수 있기 때문이다. 그 가정이 배제하는 것은 금액이 음인 항을 담은 청구권 집합이다.

**T-3 분류:** 기여다. 약정에 딸린 거래의 세 조건이 부채 총계의 두 조건을 강화한다는 설계가
부등식으로 서는 자리이므로 기여 목록에 든다.
-/
-- DD:CF-3102
theorem drawnTotalUnder_le_liabilityTotalOf {Idx Node Obs Ext Lvl Currency : Type}
    [DecidableEq Node] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Node ℤ Obs Ext Lvl Currency)
    (s : CentralBankSwapLine Node Currency ℤ Obs)
    (hnn : ∀ i ∈ S.index, 0 ≤ evalTerm e (S.assign i).amount) :
    drawnTotalUnder e S s ≤ liabilityTotalOf e S s.recipient s.suppliedCurrency := by
  unfold drawnTotalUnder liabilityTotalOf
  -- 부분합 부등식을 색인의 귀납으로 직접 세운다. `Finset.sum_le_sum` 이 선택공리를 끌어오는
  -- 것이 실측돼 있어(`docs/baseline.md` §2-2) 그 보조정리를 쓰지 않는다.
  have key : ∀ (u : Finset Idx) (F G : Idx → ℤ),
      (∀ i ∈ u, F i ≤ G i) → ∑ i ∈ u, F i ≤ ∑ i ∈ u, G i := by
    intro u F G hle
    induction u using Finset.cons_induction with
    | empty => rw [Finset.sum_empty, Finset.sum_empty]
    | cons a u ha ih =>
        rw [Finset.sum_cons, Finset.sum_cons]
        exact add_le_add (hle a (Finset.mem_cons_self a u))
          (ih fun i hi => hle i (Finset.mem_cons_of_mem hi))
  refine key _ _ _ fun i hi => ?_
  -- 세 조건이 다 서면 양변이 같은 금액이고, 보유자 조건만 거짓이면 왼쪽이 영이어서 비음수
  -- 가정이 받는다.
  by_cases h₁ : (S.assign i).obligor = s.recipient ∧ (S.assign i).holder = s.supplier
      ∧ (S.assign i).currency = s.suppliedCurrency
  · rw [if_pos h₁, if_pos (And.intro h₁.1 h₁.2.2)]
  · rw [if_neg h₁]
    by_cases h₂ : (S.assign i).obligor = s.recipient
        ∧ (S.assign i).currency = s.suppliedCurrency
    · rw [if_pos h₂]
      exact hnn i hi
    · rw [if_neg h₂]

/--
그 약정의 인출 총액이 한도 안에 있는가.

**대응 비형식 개념:** 한 기본 약정 아래의 미결제 원금 총액이 그 약정의 최대 차입 가능액을 넘지
않는가. 한도가 없는 약정에서는 이 판정이 늘 참이다.

**이 정의가 배제하는 사례:**
한도를 어느 장부에서 읽어 와 판정의 재료로 두는 읽기. 국제 기구의 지침을 훑은 기록이 약정의 총액이
어느 장부에도 서지 않고 부외 메모에서만 선택적으로 선다고 적으므로, 장부에서 읽으면 그 판정이
조달되지 않는 값에 매달린다. 그래서 한도를 약정의 조항에서 받고 장부에서 받지 않는다.
조달처: E-63 §8-2 「약정의 총액이 어느 장부에도 서지 않고 부외 메모에서만 선택적으로 선다」

**기각한 대체 정의:**
한도의 부재를 판정 불가로 내고 참거짓을 내지 않는 안. 한도가 없는 약정에서 그 판정이 서지 않는
것이 아니라 어떤 인출 총액에도 참이므로, 판정 불가로 두면 무제한 약정과 한도를 읽을 수 없는 약정이
한 값으로 선다.

**판정이 `Bool` 을 내므로 C-3 이 타입 선택으로 충족된다.**
-/
-- DD:CF-3102
def withinCap {Idx Node Obs Ext Lvl Currency : Type}
    [DecidableEq Node] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Node ℤ Obs Ext Lvl Currency)
    (s : CentralBankSwapLine Node Currency ℤ Obs) : Bool :=
  match s.cap with
  | none => true
  | some t => decide (drawnTotalUnder e S s ≤ evalTerm e t)

/--
한도가 없는 약정에서는 한도 판정이 늘 참이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
한도를 두지 않은 약정인데 그 한도 판정이 거짓이어야 한다. 그 관측은 한도의 부재가 금액 영으로
담겨 있다는 뜻이며, 그러면 한도가 영인 약정과 무제한인 약정이 같은 값으로 선다.

**가정과 그 배제 사례(T-4·T-5):** 그 약정이 무제한이라는 가정을 진술문에 둔다. 그 가정을 빼면
임의의 약정에 대한 전칭이 되어 거짓이며, 그 가정이 배제하는 것은 최대 차입 가능액을 둔 약정이다.

**T-3 분류:** 보조 보정이다. 무제한 판정과 한도 판정의 정의를 전개하면 선택 타입의 분기로 닫히므로
기여 목록에서 제외한다.
-/
-- DD:CF-3102
theorem withinCap_of_isUncapped {Idx Node Obs Ext Lvl Currency : Type}
    [DecidableEq Node] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Node ℤ Obs Ext Lvl Currency)
    (s : CentralBankSwapLine Node Currency ℤ Obs)
    (h : s.isUncapped = true) : withinCap e S s = true := by
  unfold withinCap
  cases hc : s.cap with
  | none => rfl
  | some t =>
    unfold CentralBankSwapLine.isUncapped at h
    rw [hc] at h
    exact Bool.noConfusion h

/--
한도 판정이 거짓인 자리가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 청구권 집합과 어느 약정에서도 인출 총액이 한도를 넘지 않아야 한다. 그 관측은 한도가 구조적으로
구속하지 않는다는 뜻이며, 그러면 한도를 타입에 둔 것이 아무것도 가르지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
한도가 구속함은 넘는 자리 하나를 들어야 보이고, 임의의 약정과 집합에 대한 전칭으로는 그 구속이
진술되지 않는다. 시스템 수준의 한도 관례가 개별 약정의 충족 여부를 결정하지 않는 자리다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 한도 판정의 두 갈래가 실제로 둘 다 서는 것을 보이므로 기여 목록에 든다.
-/
-- DD:CF-3102
theorem exists_not_withinCap :
    ∃ (e : Env ℤ Unit Unit Unit) (S : ClaimSet Unit Bool ℤ Unit Unit Unit Unit)
      (s : CentralBankSwapLine Bool Unit ℤ Unit), withinCap e S s = false := by
  -- 증인은 한도가 영인 약정 아래에서 금액 일인 거래 하나가 인출된 배치다.
  refine ⟨{ ops := { mul := fun a b => a * b
                     add := fun a b => a + b
                     le := fun a b => decide (a ≤ b)
                     lt := fun a b => decide (a < b)
                     lvlAtLeast := fun _ _ => true
                     lvlEq := fun _ _ => true }
            reading := { obs := fun _ => 0, extLvl := fun _ => () } },
          { index := Finset.univ
            assign := fun _ =>
              { obligor := false
                holder := true
                currency := ()
                amount := Term.const 1
                trigger :=
                  TriggerFamily.constant (Trigger.le (Term.const 0) (Term.const 1))
                inception := 0
                expiry := 0
                exercisable := fun _ => true } },
          { supplier := true, recipient := false, suppliedCurrency := (), scheduledEnd := none,
            cap := some (Term.const 0), reciprocal := false, reversalAtInitialRate := false },
          ?_⟩
  decide

end CrisisFramework.Accounting
