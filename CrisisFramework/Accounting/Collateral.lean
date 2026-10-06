/-
회계층 — 담보 장부

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(총액 기준으로 닫고 순액으로 닫지 않는다),
      L-8(색인), C-9(전면 `simp` 금지), A-6(기준선 차분), T-2(반증 조건), T-4(가정의 명시).

**수 체계: `ℤ`.** 정의층의 `Claim` 과 `Pledge` 가 수 체계를 매개변수로 받으므로 이 파일이 그
자리에 `ℤ` 를 넣는다. 금액이 `Term ℤ Obs` 이고 그 값을 그 시점의 판독에서 얻으므로 세 총계가
모두 환경을 받는다.

**세는 단위는 반환 청구권이 드는 금액이다.** 담보 제공에 수량 필드가 없고 담보물도 금액을 담지
않으므로, 얼마나 제공됐는지는 반환 청구권으로만 읽힌다.

**총계는 평가 전 값이다.** 평가율을 곱한 값을 더하면 합이 제공마다 다른 비율을 품어 공통분모가
필요해진다. 평가율은 제공별 판정이 든다.

**색인이 둘로 갈린다.** 커버리지 합은 떠받치는 청구권의 통화로 서고 제공 합과 머리 합은 담보의
종류물로 선다. L-12 가 환산을 막으므로 둘을 한 식에 두지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Algebra.Order.BigOperators.Group.Finset
import CrisisFramework.Definition.Collateral
import CrisisFramework.Definition.Trigger

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
커버리지 합.

**대응 비형식 개념:** 한 시점에 담보물이 상품 k 인 제공들이 떠받치는 청구권의 금액을 통화 c 로
모은 것. `CQ-fin-10` 이 묻는 두 값 가운데 앞의 것이다.

**이 정의가 배제하는 사례:**
리먼 유럽 법인의 파산에서 재담보된 고객 자산이 분리 보관되지 않아 고객이 일반 무담보 채권자로
떨어진 것(Singh·Aitken 2010). 그 자리에서 떠받쳐진 청구권은 그대로인데 담보가 사라졌는데, 이 합은
제공이 서 있는 동안의 커버리지를 세므로 담보권이 소멸한 뒤의 상태를 담지 않는다.

**기각한 대체 정의:**
평가율을 곱해 더하는 안. 합이 제공마다 다른 비율을 품어 공통분모가 필요해지고 `ℤ` 로 미는 결정이
그 자리에서 깨진다. 담보 실물의 합을 함께 내어 비교하는 안도 기각했다. 실물의 수량이 구조에 없고
그 가치가 가격을 요구하는데 가격은 동학층이다.
-/
-- DD:CF-798
def coverageTotal {PIdx Idx Asset Party Obs Ext Lvl Currency : Type}
    [DecidableEq Asset] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (k : Asset) (c : Currency) : ℤ :=
  ∑ i ∈ P.index,
    (if (P.assign i).pledged.asset = k
          ∧ (S.assign (P.assign i).secures).currency = c
     then evalTerm e (S.assign (P.assign i).secures).amount else 0)

/--
제공 합.

**대응 비형식 개념:** 한 시점에 재담보 권리가 붙어 받은 제공 전량의 반환 금액을 종류물 g 로 모은
것. 담보 속도의 분자가 세는 대상이며, 재무제표가 인도하거나 재담보하도록 허용된 금융상품의
공정가치로 공시하는 칸에 대응한다.

**이 정의가 배제하는 사례:**
미국 Regulation T 와 SEC Rule 15c3-3 의 140% 한도(Singh·Aitken 2010). 재담보 권리가 불린이라
한도가 구조에 없으므로 이 합은 그 한도를 넘는 몫까지 센다.

**기각한 대체 정의:**
권리를 이미 쓴 제공만 세는 안. 재무제표가 허용된 금액과 실제로 인도하거나 재담보한 금액을 따로
드는데 속도의 분자는 앞의 것이므로, 뒤로 두면 저자의 분자와 다른 것을 센다.
-/
-- DD:CF-802
def pledgedTotal {PIdx Idx Asset Party Obs Ext Lvl Currency : Type}
    [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (g : Currency) : ℤ :=
  ∑ i ∈ P.index,
    (if (P.assign i).carriesRehypothecationRight = true
          ∧ (S.assign (P.assign i).returns).currency = g
     then evalTerm e (S.assign (P.assign i).returns).amount else 0)

/--
머리 합.

**대응 비형식 개념:** 제공 합이 세는 것 가운데 사슬의 머리인 것만 모은 것. 담보 속도의 분모가
세는 대상이며, 저자가 궁극 원천에서 채굴된 담보라 부르는 자리다.

**이 정의가 배제하는 사례:**
딜러가 자기 대차대조표로 대는 담보(Singh 2011). 그 딜러가 받는 쪽이기도 하므로 머리 판정이
거짓을 내고 이 합에서 빠지는데, 저자는 그 금액이 딜러 사이에서 도는 담보에 견주어 아주 작다는
근거로 넘긴다. 구조는 그 크기를 재지 못한다.

**기각한 대체 정의:**
속도를 비 하나로 내는 안. `ℚ` 가 강제되어 회계층의 기본 수 체계를 `ℤ` 로 둔 자리가 깨지고,
분모가 0 인 배치에서 식이 정의되지 않는다. 두 총계를 각각 내면 문턱 비교가 교차곱 정수 부등식으로
선다.
-/
-- DD:CF-803
def sourceTotal {PIdx Idx Asset Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (g : Currency) : ℤ :=
  ∑ i ∈ P.index,
    (if (P.assign i).carriesRehypothecationRight = true
          ∧ P.isChainHead S i = true
          ∧ (S.assign (P.assign i).returns).currency = g
     then evalTerm e (S.assign (P.assign i).returns).amount else 0)

/--
머리 합은 제공 합을 넘지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 머리인 제공의 반환 금액을 모은 값이 권리가
붙은 제공 전량의 반환 금액을 모은 값보다 큰 담보 배치. 머리인 제공이 권리가 붙은 제공의
부분집합이므로 금액이 음수가 아닌 동안은 그런 배치가 설 수 없고, 반증은 음수 금액을 지닌 배치에서
온다.

**가정과 그 배제 사례(T-4·T-5):** 반환 청구권의 금액이 음수가 아니라는 가정을 진술에 명시한다.
두 계약 양식이 신용보전금액을 익스포저에 독립금액을 더하고 문턱을 뺀 값으로 두고 음수가 되면
0 으로 본다고 적으므로(ISDA Credit Support Annex), 그 식의 값은 음수가 될 수 있다. 그 식을 반환
청구권의 금액으로 옮겨 적으면 가정이 깨지며, 가정은 그 자리를 배제한다.

**이 정리가 속도를 아래에서 조인다.** 두 총계의 비가 1 보다 작아지지 않는다는 것이고, 위에서
조이는 것은 존재 진술이다.
-/
-- DD:CF-813
theorem sourceTotal_le_pledgedTotal {PIdx Idx Asset Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (g : Currency)
    (hnn : ∀ i ∈ P.index,
      0 ≤ evalTerm e (S.assign (P.assign i).returns).amount) :
    sourceTotal e S P g ≤ pledgedTotal e S P g := by
  -- 머리 합의 조건이 제공 합의 조건에 머리 판정을 하나 더 얹은 것이므로, 색인의 항마다
  -- 부등식을 세워 부분합으로 올린다. `linarith` 를 쓰지 않는다. 그 전술이 `ℤ` 위의 자명한
  -- 목표에서도 `Classical.choice` 를 끌어오는 것이 실측된 자리이고, 회계층 기준선이
  -- `[propext, Quot.sound]` 이므로 그 한 번으로 A-6 의 초과가 선다.
  simp only [sourceTotal, pledgedTotal]
  -- `Finset.sum_le_sum` 을 쓰지 않고 부분합 부등식을 색인의 귀납으로 직접 세운다. 그 보조정리
  -- 자체가 `Classical.choice` 에 의존하는 것을 실측했고, 쓰는 자리가 `ℤ` 위의 비음수 항
  -- 비교뿐이라 고전논리가 요구되지 않는다. 쓰는 부품 다섯이 전부 기준선 이하다.
  have key : ∀ (s : Finset PIdx) (F G : PIdx → ℤ),
      (∀ i ∈ s, F i ≤ G i) → ∑ i ∈ s, F i ≤ ∑ i ∈ s, G i := by
    intro s F G h
    induction s using Finset.cons_induction with
    | empty => rw [Finset.sum_empty, Finset.sum_empty]
    | cons a t ha ih =>
        rw [Finset.sum_cons, Finset.sum_cons]
        exact add_le_add (h a (Finset.mem_cons_self a t))
          (ih fun i hi => h i (Finset.mem_cons_of_mem hi))
  refine key _ _ _ fun i hi => ?_
  -- 세 조건이 다 서면 양변이 같은 금액이고, 머리 판정만 거짓이면 왼쪽이 0 이어서 비음수
  -- 가정이 받는다. 배중률을 쓰지 않고 판정 명제를 `by_cases` 로 가르므로 기준선이 오르지 않는다.
  by_cases h₁ : (P.assign i).carriesRehypothecationRight = true
      ∧ P.isChainHead S i = true
      ∧ (S.assign (P.assign i).returns).currency = g
  · rw [if_pos h₁, if_pos (And.intro h₁.1 h₁.2.2)]
  · rw [if_neg h₁]
    by_cases h₂ : (P.assign i).carriesRehypothecationRight = true
        ∧ (S.assign (P.assign i).returns).currency = g
    · rw [if_pos h₂]
      exact hnn i hi
    · rw [if_neg h₂]

/--
제공 합이 양인데 머리 합이 0 인 담보 배치가 있다.

**대응 비형식 개념:** 두 당사자가 서로에게 같은 종류물을 내놓으면 둘 다 받는 쪽이므로 어느
제공도 머리가 아니다. 그러면 분모가 0 이고 분자는 양이어서 속도가 위로 유계가 아니다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 제공 합이 양이면 머리 합도 양이라는 것이
모든 담보 배치에서 성립한다는 증명. 순환 사슬을 금지하면 그렇게 되는데, 시점 인덱스가 `ℕ` 이라
같은 시점 안의 순서를 구조가 줄 수 없으므로 순환을 금지하지 않기로 한 결정이 서 있다.

**존재 형태로 진술하는 까닭(T-6):** 시스템 수준의 제약이 개별 제공의 상태를 결정하지 않는다.
어느 제공이 머리인지는 그 당사자가 그 종류물로 무엇을 받았는가에 달려 있고, 총계만으로는 정해지지
않는다.

**Singh 2011 의 상자 3 이 산문으로 무한 회전이라 부른 자리를 이 진술이 잡는다.**
-/
-- DD:CF-814
theorem exists_pledgedTotal_pos_and_sourceTotal_eq_zero :
    ∃ (e : Env ℤ Unit Unit Unit)
      (S : ClaimSet Bool Bool ℤ Unit Unit Unit Unit)
      (P : PledgeSet Bool Bool Unit),
      0 < pledgedTotal e S P () ∧ sourceTotal e S P () = 0 := by
  -- 증인은 두 당사자가 서로에게 같은 종류물을 내놓는 배치다. 반환 청구권 `j` 의 의무자를 `!j`
  -- 로 두고 권리자를 `j` 로 두면, 어느 제공 `i` 에 대해서도 `k = !i` 가 그 제공으로 이어 들어오는
  -- 제공이 되어 머리 판정이 전부 거짓이 된다. 그래서 분모가 0 이고 분자는 둘이다.
  refine ⟨{ ops := { mul := fun a b => a * b
                     add := fun a b => a + b
                     le := fun a b => decide (a ≤ b)
                     lt := fun a b => decide (a < b)
                     lvlAtLeast := fun _ _ => true
                     lvlEq := fun _ _ => true }
            reading := { obs := fun _ => 0, extLvl := fun _ => () } },
          { index := Finset.univ
            assign := fun j =>
              { obligor := !j
                holder := j
                currency := ()
                amount := Term.const 1
                trigger :=
                  TriggerFamily.constant (Trigger.le (Term.const 0) (Term.const 1))
                inception := 0
                expiry := 0
                exercisable := fun _ => true } },
          { index := Finset.univ
            assign := fun i =>
              { pledged := { asset := (), asClaim := none }
                secures := i
                returns := i
                rehypothecable := true } },
          ?_, ?_⟩
  -- 증인이 전부 유한하고 계산되는 자료이므로 두 값이 커널 평가로 닫힌다. `Bool` 의 두 값과
  -- `Unit` 의 한 값과 `ℤ` 의 비교가 모두 판정 인스턴스를 이미 가지므로 C-2 가 경계한 자리를
  -- 밟지 않는다.
  · decide
  · decide

end CrisisFramework.Accounting
