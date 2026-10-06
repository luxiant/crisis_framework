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

/--
청구권 담보의 커버리지 합.

**대응 비형식 개념:** 한 시점에 담보물이 청구권 j 인 제공들이 떠받치는 청구권의 금액을 통화 c 로
모은 것. 그 청구권 j 자신의 금액과 맞대면 같은 청구권이 몇 번 떠받치는지가 서므로, 담보 중복
계상을 재는 앞값이다. `coverageTotal` 과 색인만 다르다.

**이 정의가 배제하는 사례:**
미국 삼자 레포의 담보가 수탁기관에 분리 보관되어 거리로 나가지 못하고 재담보 대상이 아닌 것
(Singh 2011). 그 자리에서는 한 담보물에 제공이 하나만 붙으므로 이 합이 늘 그 청구권의 금액과
같거나 작고, 중복을 재는 이 합이 중복이 구조로 금지된 자리를 가려내지 못한다. 이 합은 중복이 있을
수 있는 자리에서만 뜻을 가진다.

**기각한 대체 정의:**
`coverageTotal` 에 담보물의 종류를 받는 인자를 더해 하나로 합치는 안. 색인이 자산 종류와 청구권
색인으로 갈리는데 둘을 한 인자로 받으면 그 인자의 타입이 합 타입이 되고, 담보물이 청구권일 때만
서는 중복 판정이 자산 종류 쪽에서도 서는 것처럼 읽힌다. 같은 청구권을 가리키는 제공의 수를 세어
배수를 내는 안도 기각했다. 제공마다 떠받치는 금액이 다르므로 수가 배수를 내지 못한다.
-/
-- DD:CF-840
def claimCoverageTotal {PIdx Idx Asset Party Obs Ext Lvl Currency : Type}
    [DecidableEq Idx] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (j : Idx) (c : Currency) : ℤ :=
  ∑ i ∈ P.index,
    (if (P.assign i).pledged.asClaim = some j
          ∧ (S.assign (P.assign i).secures).currency = c
     then evalTerm e (S.assign (P.assign i).secures).amount else 0)

/--
한 청구권이 자기 금액보다 많은 청구권을 떠받치는 담보 배치가 있다.

**대응 비형식 개념:** 같은 청구권을 담보로 제공이 여럿 서면 그 제공들이 떠받치는 금액의 합이 그
청구권 자신의 금액을 넘는다. 넘는 배수가 곧 그 청구권이 몇 번 떠받치는지이며, 이것이 담보 중복
계상이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 모든 담보 배치에서 커버리지 합이 담보 청구권의
금액을 넘지 않는다는 증명. 담보물에 점유를 두어 같은 청구권에 제공이 둘 서는 것을 구조로 막으면
그렇게 되는데, 점유를 담지 않기로 한 결정이 서 있고 그 결정은 2014년 칭다오항 금속 금융 같은 중복
제공을 담으려고 내린 것이다.

**존재 형태로 진술하는 까닭(T-6):** 시스템 수준의 제약이 개별 청구권의 상태를 결정하지 않는다.
어느 청구권이 여러 번 떠받치는지는 그 청구권을 담보로 든 제공이 몇인가에 달려 있고, 총계만으로는
정해지지 않는다.

**이 진술이 `PH-R8` 이 든 같음 판정을 처음 실물로 쓴다.** 중복을 재는 것이 담보물의 같음 판정인데
청구권 담보에서는 색인이 그 판정을 주므로, 외부 자산에서 서지 않던 것이 이 자리에서 선다.
-/
-- DD:CF-841
theorem exists_claimCoverageTotal_gt_amount :
    ∃ (e : Env ℤ Unit Unit Unit)
      (S : ClaimSet Bool Bool ℤ Unit Unit Unit Unit)
      (P : PledgeSet Bool Bool Unit)
      (j : Bool),
      evalTerm e (S.assign j).amount < claimCoverageTotal e S P j () := by
  -- 증인은 청구권 둘과 제공 둘을 두고 제공 둘의 담보물을 같은 청구권 `false` 로 두는 배치다.
  -- 그러면 그 청구권 하나가 제공 둘을 떠받치므로 커버리지 합이 자기 금액의 두 배가 된다.
  -- `Env` 와 `Claim` 의 나머지 필드는 바로 앞 존재 진술의 증인과 같은 값을 쓴다.
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
              { pledged := { asset := (), asClaim := some false }
                secures := i
                returns := i
                rehypothecable := true } },
          false, ?_⟩
  -- 증인이 전부 유한하고 계산되는 자료이므로 커널 평가로 닫힌다. 왼쪽이 1 이고 오른쪽이 2 다.
  decide

/--
제공마다 반환 청구권이 다르면 제공 합이 청구권 전량의 금액 합을 넘지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 제공마다 반환 청구권이 다르고 금액이 음수가
아닌데도 제공 합이 청구권 전량의 합을 넘는 담보 배치. 단사 가정이 제공을 서로 다른 청구권으로
보내므로 그런 배치가 설 수 없고, 반증은 단사 가정이 깨진 자리에서 온다.

**가정과 그 배제 사례(T-4·T-5):** 제공에서 반환 청구권으로의 사상이 단사라는 가정과 반환 청구권이
청구권 집합의 색인에 든다는 가정과 금액이 음수가 아니라는 가정을 진술에 명시한다. 첫째 가정의
배제 사례는 집계 반환금액이다. 두 계약 양식이 신용보전금액을 익스포저에 독립금액을 더하고 문턱을
뺀 값으로 한 식에 두고 반환 기제를 제공별로 따로 두지 않으므로(ISDA Credit Support Annex, 영국법
이전형 1995년 저작권 · 뉴욕법 담보권형 1994년 저작권), 반환
의무가 제공 단위가 아니라 당사자 쌍 단위로 선다. 그 양식에서는 제공 여럿이 같은 반환 청구권을
가리키며 가정이 깨진다.

**일대일을 구조로 강제하지 않는 까닭.** 강제하면 그 계약 양식이 표현 불가능해진다. 그래서 구조는
허용하고 이 정리가 가정으로 명시한다.

**`exists_claimCoverageTotal_gt_amount` 와 방향이 반대다.** 그 진술의 중복은 재야 할 대상이고
이 진술의 중복은 세면 안 되는 것을 세는 결함이다. 색인도 다르다. 앞은 담보물이 가리키는 청구권에
걸리고 뒤는 반환 청구권에 걸린다.
-/
-- DD:CF-842
theorem pledgedTotal_le_claimSetTotal {PIdx Idx Asset Party Obs Ext Lvl Currency : Type}
    [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (g : Currency)
    (hinj : ∀ i₁ ∈ P.index, ∀ i₂ ∈ P.index,
      (P.assign i₁).returns = (P.assign i₂).returns → i₁ = i₂)
    (hmem : ∀ i ∈ P.index, (P.assign i).returns ∈ S.index)
    (hnn : ∀ j ∈ S.index, 0 ≤ evalTerm e (S.assign j).amount) :
    pledgedTotal e S P g ≤ ∑ j ∈ S.index, evalTerm e (S.assign j).amount := by
  -- 색인을 옮기는 Mathlib 보조정리를 하나도 부르지 않는다. `Finset.sum_le_sum` 과
  -- `Finset.sum_nonneg` 과 `Finset.sum_le_sum_of_subset_of_nonneg` 이 핀된 판에서
  -- `Classical.choice` 를 끄는 것이 실측됐고(`docs/baseline.md` §2-2), 회계층 기준선이
  -- `[propext, Quot.sound]` 이므로 그 한 번으로 A-6 의 초과가 선다.
  --
  -- 진술에 `DecidableEq Idx` 가 없으므로 `Finset.erase` 와 `Finset.image` 와 `Finset.filter`
  -- 를 쓸 수 없다. 그 셋이 전부 판정을 요구하는데, 가정을 더해 통과시키는 것은 W-1 이 막는다.
  -- 그래서 청구권 집합에서 한 원소를 떼는 일을 `Multiset.exists_cons_of_mem` 으로 받는다.
  -- 그 보조정리는 판정을 요구하지 않고 Nodup 에서 분해를 바로 낸다.
  have snn : ∀ (t : Finset Idx), (∀ j ∈ t, 0 ≤ evalTerm e (S.assign j).amount) →
      0 ≤ ∑ j ∈ t, evalTerm e (S.assign j).amount := by
    intro t
    induction t using Finset.cons_induction with
    | empty => intro _; rw [Finset.sum_empty]
    | cons b u hb ih =>
        intro h
        rw [Finset.sum_cons]
        exact add_nonneg (h b (Finset.mem_cons_self b u))
          (ih fun j hj => h j (Finset.mem_cons_of_mem hj))
  -- 든 원소 하나를 머리로 떼어 `cons` 로 다시 세운다. 판정이 없으므로 `erase` 를 쓰지 못한다.
  have split : ∀ (t : Finset Idx) (a : Idx), a ∈ t →
      ∃ (t' : Finset Idx) (h' : a ∉ t'), t = Finset.cons a t' h' := by
    intro t a h
    obtain ⟨m, hm⟩ := Multiset.exists_cons_of_mem (Finset.mem_val.mpr h)
    have hnd : (a ::ₘ m).Nodup := hm ▸ t.nodup
    exact ⟨⟨m, (Multiset.nodup_cons.mp hnd).2⟩, (Multiset.nodup_cons.mp hnd).1,
      Finset.val_injective hm⟩
  -- 단사 사상을 따라 색인을 옮기는 부분합 부등식. 제공 하나를 떼면 그것이 가리키는 청구권도
  -- 함께 떼이고, 단사 가정이 남은 제공들이 그 청구권을 가리키지 않음을 준다.
  have key : ∀ (s : Finset PIdx) (t : Finset Idx),
      (∀ i ∈ s, (P.assign i).returns ∈ t) →
      (∀ i₁ ∈ s, ∀ i₂ ∈ s, (P.assign i₁).returns = (P.assign i₂).returns → i₁ = i₂) →
      (∀ j ∈ t, 0 ≤ evalTerm e (S.assign j).amount) →
      ∑ i ∈ s, evalTerm e (S.assign (P.assign i).returns).amount
        ≤ ∑ j ∈ t, evalTerm e (S.assign j).amount := by
    intro s
    induction s using Finset.cons_induction with
    | empty =>
        intro t _ _ hn
        rw [Finset.sum_empty]
        exact snn t hn
    | cons a s' ha ih =>
        intro t hm hj hn
        obtain ⟨t', ht', rfl⟩ :=
          split t (P.assign a).returns (hm a (Finset.mem_cons_self a s'))
        rw [Finset.sum_cons, Finset.sum_cons]
        refine add_le_add (le_refl _) ?_
        refine ih t' (fun i hi => ?_)
          (fun i₁ h₁ i₂ h₂ he =>
            hj i₁ (Finset.mem_cons_of_mem h₁) i₂ (Finset.mem_cons_of_mem h₂) he)
          (fun j hjm => hn j (Finset.mem_cons_of_mem hjm))
        rcases Finset.mem_cons.mp (hm i (Finset.mem_cons_of_mem hi)) with h | h
        · have hia : i = a :=
            hj i (Finset.mem_cons_of_mem hi) a (Finset.mem_cons_self a s') h
          exact absurd (hia ▸ hi) ha
        · exact h
  -- 항마다의 부등식을 부분합으로 올리는 단조성. 앞 정리가 쓴 것과 같은 형이다.
  have mono : ∀ (s : Finset PIdx) (F G : PIdx → ℤ),
      (∀ i ∈ s, F i ≤ G i) → ∑ i ∈ s, F i ≤ ∑ i ∈ s, G i := by
    intro s F G h
    induction s using Finset.cons_induction with
    | empty => rw [Finset.sum_empty, Finset.sum_empty]
    | cons a t ha ih =>
        rw [Finset.sum_cons, Finset.sum_cons]
        exact add_le_add (h a (Finset.mem_cons_self a t))
          (ih fun i hi => h i (Finset.mem_cons_of_mem hi))
  calc pledgedTotal e S P g
      ≤ ∑ i ∈ P.index, evalTerm e (S.assign (P.assign i).returns).amount := by
        simp only [pledgedTotal]
        refine mono _ _ _ fun i hi => ?_
        -- 조건이 서면 양변이 같고, 서지 않으면 왼쪽이 0 이어서 비음수 가정이 받는다. 판정
        -- 명제를 `by_cases` 로 가르므로 배중률을 쓰지 않는다.
        by_cases h : (P.assign i).carriesRehypothecationRight = true
            ∧ (S.assign (P.assign i).returns).currency = g
        · rw [if_pos h]
        · rw [if_neg h]
          exact hnn _ (hmem i hi)
    _ ≤ ∑ j ∈ S.index, evalTerm e (S.assign j).amount := key P.index S.index hmem hinj hnn

end CrisisFramework.Accounting
