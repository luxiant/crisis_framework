/-
회계층 — 통화 불일치를 진 채무자에 대한 청구권과 통화별 지급능력

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(총액 기준으로 닫고 통화 간 환산을 금지한다),
      L-9(import 방향은 단방향), A-1(`axiom` 금지), A-6(기준선 차분),
      C-1·C-2(`noncomputable` 과 `Classical` 금지), C-3(판정 술어는 `Decidable`),
      C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시), T-6(존재 형태).

**수 체계: `ℤ`.** 정의층의 청구권이 수 체계를 매개변수로 받으므로 이 파일이 그 자리에 `ℤ` 를
넣는다.

**이 파일이 세우는 것은 불일치가 채권자 쪽 장부에 어떻게 서는가다.** 불일치의 판정이 정의층에
이미 서고 그 판정이 채무자에 붙으므로, 그 채무자에 대한 청구권을 채권자 쪽에서 세는 자리가
회계층에 선다.

**집계마다 통화를 인자로 받는다.** 통화 간 환산을 금지하는 요구가 색인 없는 합을 막으므로 이
파일의 두 집계와 두 판정이 통화를 받고 그 통화의 청구권만 센다.

**지급능력을 통화마다 따로 내고 통화를 가로지른 하나로 접지 않는다.** 접으려면 통화 사이의
환산이 필요하고 그 환산이 금지되므로, 전체 지급능력은 통화의 목록 위의 전칭으로만 선다.
-/

import Mathlib.Algebra.BigOperators.Ring.Finset
import CrisisFramework.Definition.Claim
import CrisisFramework.Definition.CurrencyMismatch
import CrisisFramework.Accounting.Repayment

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
한 보유자가 그 통화로 든 청구권의 금액 합.

**대응 비형식 개념:** 한 금융 주체가 특정 통화 표시로 보유한 청구권의 총액. 부채 쪽 총계가 이미
통화를 받는 관례로 서 있어 자산 쪽에도 같은 색인이 선다.

**이 정의가 배제하는 사례:**
보유자의 청구권을 통화 색인 없이 하나로 더하는 읽기. 한 감독 보고를 다룬 문면이 대출의 표시 통화가
그 보고의 뒤 시기에 칸이 생겨 그 시점부터만 읽힌다고 적으므로, 색인 없이 더하면 그 칸이 없던
시기의 값과 생긴 뒤의 값이 같은 꼴로 서서 통화 색인의 부재가 집계에서 사라진다
(Niepmann·Schmidt-Eisenlohr 2019).
조달처: E-65 §3-1 「대출의 표시 통화는 그 보고의 뒤 시기에 칸이 생겨 그 시점부터만 읽힌다」

**기각한 대체 정의:**
자기 청구권을 세는 자리에서 거르는 선례를 그대로 옮겨 양쪽 끝이 같은 당사자인 청구권을 빼는 안.
보유자 쪽 총계는 그 보유자가 든 것을 전량 세는 값이고 자기 청구권도 그 보유자의 자산으로 서 있어서,
빼면 통화별 지급능력 판정의 자산 쪽이 부채 쪽과 다른 유니버스를 갖는다.

**금액이 항이므로 환경을 받는다.**
-/
-- DD:CF-3101
def claimTotalOfHolder {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (h : Party) (c : Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).holder = h ∧ (S.assign i).currency = c
     then evalTerm e (S.assign i).amount else 0)

/--
그 통화 축에 불일치가 선 채무자에 대한 청구권의 금액 합.

**대응 비형식 개념:** 한 금융 주체가 든 어느 통화 표시 청구권 가운데 채무자 쪽에 다른 통화 축의
통화 불일치가 선 것의 총액. 불일치가 채권자의 장부가 아니라 채무자의 장부에 서는데 그 채무자의
상환 능력을 통해 채권자의 제약 인자로 전달되며, 표시 통화와 불일치 통화가 다른 축이므로 둘을 따로
받는다.

**이 정의가 배제하는 사례:**
불일치를 채권자 쪽 장부에서 찾는 읽기. 한 모형을 다룬 문면이 은행이 외화 대출의 자금을 정확히 그
금액만큼 외화로 조달하므로 자기 대차대조표에 불일치를 남기지 않는다고 적으면서 불일치가 금융
주체에 서지 않고 비금융 주체에만 선다고 적으므로, 채권자 쪽에서 찾으면 그 전달의 출발점이 빈
자리가 된다(Niepmann·Schmidt-Eisenlohr 2019).
조달처: E-65 §2-1 「불일치가 금융 주체에 서지 않고 비금융 주체에만 선다」

**기각한 대체 정의:**
불일치의 판정을 청구권의 표시 통화 하나로 받고 채무자의 축을 보지 않는 안. 청구권의 표시 통화가
채무자의 불일치와 다른 축이고, 한 편이 불일치의 꼴을 부채의 통화와 그 부채가 조달한 자산의 통화의
쌍으로 두므로 표시 통화 하나로는 그 쌍이 유도되지 않는다. 표시 통화 하나를 합의 색인과 불일치
판정의 색인에 함께 쓰는 안도 기각한다. 그 꼴이 두 축을 따로 받는 꼴의 대각선과 정의로 같아 대각선의
어느 자리도 낼 수 없는 값을 비대각선이 내는 배치가 존재한다.

**판정을 정의층에서 받는다.** 그 판정이 정의층 대상이므로 이 파일은 그것을 인자로 받고 다시
정의하지 않는다.

인자 순서를 답할 항의 서명에서 받는다. 그 항이 금융 주체와 불일치 통화와 표시 통화의 순서로 받으
므로 이 선언도 그 순서를 따른다.
-/
-- DD:CF-3101
def claimsOnMismatchedDebtors {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (M : CurrencyPositionMismatch Party Currency)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (h : Party) (c : Currency) (d : Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).holder = h ∧ (S.assign i).currency = d
        ∧ M.mismatched (S.assign i).obligor c = true
     then evalTerm e (S.assign i).amount else 0)

/--
불일치 채무자에 대한 청구권의 합이 그 보유자의 그 표시 통화 총계를 넘지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
금액이 전부 음이 아닌 청구권 집합인데 어느 통화 축에서 불일치를 가진 채무자에 대한 합이 그
보유자의 그 표시 통화 총계보다 커야 한다. 그 관측은 불일치 판정이 거르는 것이 그 총계가 세는
것의 부분집합이 아니라는 뜻이며, 그러면 두 집계가 서로 다른 유니버스를 세고 있다.

**가정과 그 배제 사례(T-4·T-5):** 색인에 든 청구권의 금액이 전부 음이 아니라는 가정을 진술문에
둔다. 회계층의 수 체계가 `ℤ` 여서 금액이 음일 수 있고 그러면 부분집합의 합이 전체의 합보다 커질
수 있기 때문이다. 그 가정이 배제하는 것은 금액이 음인 항을 담은 청구권 집합이며, 상계로 금액이
음이 된 자리가 그 사례다. 불일치 통화는 가정에 들지 않는다. 그 축이 걸러내는 쪽에만 서므로
어느 값이든 왼쪽이 오른쪽의 부분합이다.

**T-3 분류:** 기여다. 두 집계가 같은 색인 위에 서고 뒤의 조건이 앞의 조건을 강화한다는 설계가
부등식으로 서는 자리이며, 그 강화가 표시 통화와 다른 축에서 와도 부분합 관계가 유지됨을 드는
자리이므로 기여 목록에 든다.
-/
-- DD:CF-3101
theorem claimsOnMismatchedDebtors_le_claimTotalOfHolder
    {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (M : CurrencyPositionMismatch Party Currency)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (h : Party) (c : Currency) (d : Currency)
    (hnn : ∀ i ∈ S.index, 0 ≤ evalTerm e (S.assign i).amount) :
    claimsOnMismatchedDebtors e M S h c d ≤ claimTotalOfHolder e S h d := by
  unfold claimsOnMismatchedDebtors claimTotalOfHolder
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
  -- 세 조건이 다 서면 양변이 같은 금액이고, 불일치 판정만 거짓이면 왼쪽이 영이어서 비음수
  -- 가정이 받는다.
  by_cases h₁ : (S.assign i).holder = h ∧ (S.assign i).currency = d
      ∧ M.mismatched (S.assign i).obligor c = true
  · rw [if_pos h₁, if_pos (And.intro h₁.1 h₁.2.1)]
  · rw [if_neg h₁]
    by_cases h₂ : (S.assign i).holder = h ∧ (S.assign i).currency = d
    · rw [if_pos h₂]
      exact hnn i hi
    · rw [if_neg h₂]

/--
표시 통화와 불일치 통화를 따로 받는 꼴이 대각선으로 접히지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 통화를 따로 받은 값이 영이 아닌 배치마다 두 통화 가운데 하나를 양쪽 색인에 함께 넣은 값도
영이 아니어야 한다. 그 관측은 표시 통화와 채무자의 불일치가 같은 축이라는 뜻이며, 그러면 두
인자를 따로 받을 까닭이 사라진다.

**존재 형태로 진술하는 까닭(T-6):** 두 축이 다름을 드는 것이 어느 한 배치의 성질이고 모든 배치에
대한 전칭이 아니다. 두 축이 같아지는 배치가 따로 있으므로 전칭으로 세우면 거짓이 된다.

가정을 두지 않는다. 증인을 리터럴로 들고 세 등식이 전부 결정 가능하므로 가정이 설 자리가 없다.

**T-3 분류:** 기여다. 두 인자를 따로 받는 설계가 필요하다는 것을 반례의 부재가 아니라 증인의
존재로 세우는 자리이므로 기여 목록에 든다.
-/
-- DD:CF-3101
theorem exists_claimsOnMismatchedDebtors_offDiagonal :
    ∃ (e : Env ℤ Unit Unit Unit) (M : CurrencyPositionMismatch Bool Bool)
      (S : ClaimSet Unit Bool ℤ Unit Unit Unit Bool),
      claimsOnMismatchedDebtors e M S false true false = 1
      ∧ claimsOnMismatchedDebtors e M S false false false = 0
      ∧ claimsOnMismatchedDebtors e M S false true true = 0 := by
  -- 증인은 청구권 하나가 `false` 통화로 표시되고 그 채무자가 `true` 통화 축에서만 불일치를 지는
  -- 배치다. 표시 통화가 `false` 이고 불일치 통화가 `true` 인 자리에서만 그 청구권이 세어지고,
  -- 두 통화가 같은 두 자리에서는 표시 통화나 불일치 판정이 그것을 걸러 낸다.
  refine ⟨{ ops := { mul := fun a b => a * b
                     add := fun a b => a + b
                     le := fun a b => decide (a ≤ b)
                     lt := fun a b => decide (a < b)
                     lvlAtLeast := fun _ _ => true
                     lvlEq := fun _ _ => true }
            reading := { obs := fun _ => 0, extLvl := fun _ => () } },
          { directionOf := fun _ c =>
              bif c then MismatchDirection.liabilityHeavy else MismatchDirection.balanced },
          { index := Finset.univ
            assign := fun _ =>
              { obligor := true
                holder := false
                currency := false
                amount := Term.const 1
                trigger :=
                  TriggerFamily.constant (Trigger.le (Term.const 0) (Term.const 1))
                inception := 0
                expiry := 0
                exercisable := fun _ => true } },
          ?_, ?_, ?_⟩
  · decide
  · decide
  · decide

/--
그 통화 축에서 지급능력이 서는가.

**대응 비형식 개념:** 한 주체가 특정 통화 표시로 진 부채를 같은 통화 표시로 든 청구권으로 덮는가.
통화마다 따로 재며 통화를 가로지른 하나의 값으로 접지 않는다.

**이 정의가 배제하는 사례:**
지급능력을 통화를 가로지른 하나의 값으로 재는 읽기. 한 모형을 다룬 문면이 통화별 자금 시장이
분리되어 있다는 가정을 두고 그 아래에서 환율이 움직일 때 바뀌는 것이 차입자가 갚을 수 있는가라고
적으므로, 하나로 접으면 그 분리가 사라지고 환율 변동이 어느 축에 닿는지가 담기지 않는다
(Niepmann·Schmidt-Eisenlohr 2019).
조달처: E-65 §2-1 「그래서 환율이 움직일 때 바뀌는 것은 은행의 포지션이 아니라 차입자가 갚을 수 있는가다」

**기각한 대체 정의:**
자산 쪽을 불일치 채무자에 대한 청구권으로 좁혀 그것만 부채와 맞대는 안. 불일치가 상환 능력을 통해
전달되는 것이고 상환에 쓰이는 자산이 그 축으로 좁혀지지 않으므로, 좁히면 불일치가 없는 채무자에
대한 청구권이 상환 재원에서 빠진다.

**판정이 `Bool` 을 내므로 C-3 이 타입 선택으로 충족된다.**
-/
-- DD:CF-3101
def solventIn {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (c : Currency) : Bool :=
  decide (liabilityTotalOf e S p c ≤ claimTotalOfHolder e S p c)

/--
드는 통화 전량에서 지급능력이 서는가.

**대응 비형식 개념:** 한 주체가 자기가 쓰는 통화 모두에서 통화별 지급능력을 갖추는가. 통화의
유니버스를 목록으로 받으므로 그 목록 밖의 통화는 이 판정에 들지 않는다.

**이 정의가 배제하는 사례:**
통화의 유니버스를 타입 전량으로 두고 목록을 받지 않는 읽기. 한 편이 증거 열거를 달러와 유로 둘로
닫으면서 파운드와 엔을 그 둘에 넣으면 두 역할의 칸을 채울 근거가 없다고 적으므로, 타입 전량으로
두면 값이 없는 통화가 전칭에 들어와 판정이 조달되지 않는다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-4 「그 둘을 증거에 넣으면 그 두 역할의 칸을 채울 근거가 없다」

**기각한 대체 정의:**
통화별 판정의 논리곱을 유한 집합 위의 접기로 두는 안. 색인 타입에 유한성 인스턴스를 요구하게 되고
그 요구가 통화의 유니버스를 조달의 범위와 무관하게 정한다.

**목록 위의 전칭이므로 통화 간 환산이 서지 않는다.**
-/
-- DD:CF-3101
def solventInEvery {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (cs : List Currency) : Bool :=
  cs.all (fun c => solventIn e S p c)

/--
전량 지급능력이 서면 목록에 든 통화마다 지급능력이 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
드는 통화 전량에서 지급능력이 서는데 그 목록에 든 어느 통화에서는 서지 않아야 한다. 그 관측은
전량 판정이 통화별 판정의 논리곱이 아니라는 뜻이며, 그러면 전량 판정이 통화 간 환산을 숨기고 있다.

**가정과 그 배제 사례(T-4·T-5):** 그 통화가 목록에 든다는 가정을 진술문에 둔다. 그 가정을 빼면
목록 밖의 통화에 대한 전칭이 되어 거짓이며, 그 가정이 배제하는 것은 조달 범위 밖의 통화다.

**T-3 분류:** 보조 보정이다. 목록 전량 판정의 정의를 전개하면 멤버십에서 바로 따라 나오므로 기여
목록에서 제외한다.
-/
-- DD:CF-3101
theorem solventIn_of_solventInEvery {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (cs : List Currency) (c : Currency)
    (hall : solventInEvery e S p cs = true) (hc : c ∈ cs) :
    solventIn e S p c = true := by
  unfold solventInEvery at hall
  exact List.all_eq_true.mp hall c hc

/--
한 통화에서 지급능력이 서고 다른 통화에서 서지 않는 자리가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 청구권 집합에서도 통화별 지급능력이 통화를 가로질러 같아야 한다. 그 관측은 통화 축이 지급능력
판정에 걸리지 않는다는 뜻이며, 그러면 통화를 별도 축으로 둔 결정이 이 자리에서 아무것도 바꾸지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
통화별 지급능력의 독립은 두 통화에서 값이 갈리는 집합 하나를 들어야 보이고, 임의의 집합에 대한
전칭으로는 그 독립이 진술되지 않는다. 시스템 수준의 지급능력이 통화별 지급능력을 결정하지 않는
자리다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 통화를 가로지른 하나의 지급능력 값이 서지 않음을 보이므로 기여 목록에 든다.
-/
-- DD:CF-3101
theorem exists_solventIn_differs :
    ∃ (e : Env ℤ Unit Unit Unit) (S : ClaimSet Bool Bool ℤ Unit Unit Unit Bool),
      solventIn e S true true = true ∧ solventIn e S true false = false := by
  -- 증인은 두 청구권이 모두 `false` 통화로 `true` 의 부채인 배치다. `true` 통화에서는 양쪽이
  -- 영이어서 지급능력이 서고, `false` 통화에서는 부채만 있어 서지 않는다.
  refine ⟨{ ops := { mul := fun a b => a * b
                     add := fun a b => a + b
                     le := fun a b => decide (a ≤ b)
                     lt := fun a b => decide (a < b)
                     lvlAtLeast := fun _ _ => true
                     lvlEq := fun _ _ => true }
            reading := { obs := fun _ => 0, extLvl := fun _ => () } },
          { index := Finset.univ
            assign := fun _ =>
              { obligor := true
                holder := false
                currency := false
                amount := Term.const 1
                trigger :=
                  TriggerFamily.constant (Trigger.le (Term.const 0) (Term.const 1))
                inception := 0
                expiry := 0
                exercisable := fun _ => true } },
          ?_, ?_⟩
  · decide
  · decide

end CrisisFramework.Accounting
