/-
탐색 프로브 — 유한집합 위의 「하나라도 참인가」를 계산으로 내는 수단

**무엇을 재는가.** `Finset` 을 훑어 조건을 만족하는 원소가 하나라도 있는지를 `Bool` 로 내는
수단 네 가지가 핀된 판에서 계산 함수로 컴파일되는지와, 그 공리 의존이 정의층 기준선을 넘는지를
잰다. 재귀 함수의 몸 안에서도 서는지를 함께 재므로 후보 넷 가운데 둘이 재귀 형이다.

**언제 왜 섰는가.** 2026년 10월 3일의 `collateral-2` 구간 3 에서 섰다. 그 구간이 받은 별지가
담보 사슬의 도달 판정을 `Finset.toList` 로 훑도록 썼는데, 핀된 Mathlib 에서 그 함수가
선택공리를 쓰는 `noncomputable` 정의여서 `def` 가 계산 함수로 컴파일되지 않았다. C-1 과 C-2 가
`noncomputable` 과 선택공리를 금지하므로 그 자리를 우회할 수단이 필요했고, 결정 세션에 Lean
툴체인이 없어 무엇이 계산 가능한지는 집행이 처음 재는 값이었다. 그래서 후보를 재어 올리고
결정 세션이 고르는 방식으로 그 한계를 메웠다. 고른 것은 후보 ⓐ 와 그 재귀 형인 ⓒ 이며,
`CrisisFramework/Definition/Collateral.lean` 의 두 자리가 그것을 쓴다.

**어느 핀에서 잰 값인가.** `docs/baseline.md` §1 의 핀이며 Mathlib 태그가 `v4.32.2` 이고
툴체인이 `leanprover/lean4:v4.32.2` 다. A-6 이 핀을 갱신할 때 재측정을 요구하는데, 유한집합을
훑는 수단이 새 판에서도 계산 가능한지는 그때 다시 재야 하는 값이므로 이 파일을 남긴다.

**어떻게 재는가.** `lake env lean Scratch/CollateralProbe.lean` 을 돌린다. 오류가 없고 말미의
`#print axioms` 넷이 전부 `[propext, Quot.sound]` 를 내면 네 수단이 계산으로 서고 정의층
기준선을 넘지 않는다는 뜻이다. 2026년 10월 3일의 측정에서 넷이 그 값을 냈다.

**무엇을 기각했는가.** 후보 ⓑ 는 색인 타입에 `DecidableEq` 가 서명으로 붙어 구조에 없던 제약을
늘리므로 기각했고, 후보 ⓓ 는 같은 값을 내면서 `import` 가 하나 느는 것뿐이므로 기각했다. 둘을
지우지 않고 남기는 까닭은 기각의 사유가 계산 가능성이 아니라 서명과 의존이라는 점이 뒤의 재측정
에서도 그대로 쓰이기 때문이다.

**이 파일은 빌드 타깃 밖이며 검증된 파일을 건드리지 않는다(CLAUDE.md §6).** 선언 이름을
`CollateralProbe` 이름공간에 두어 정의층의 실물과 겹치지 않게 했고, 그래서 공리 감사와 변이
검사와 층별 검사의 유니버스에 들지 않는다.
-/

import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Fold
import CrisisFramework.Definition.Claim

namespace CollateralProbe

open CrisisFramework.Definition

structure Pledgeable (Idx Asset : Type) where
  asset : Asset
  asClaim : Option Idx

structure Pledge (Idx Asset : Type) where
  pledged : Pledgeable Idx Asset
  secures : Idx
  returns : Idx
  rehypothecable : Bool

def Pledge.linksTo {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (p q : Pledge Idx Asset) : Bool :=
  decide ((S.assign p.returns).obligor = (S.assign q.returns).holder)
    && decide ((S.assign p.returns).currency = (S.assign q.returns).currency)

structure PledgeSet (PIdx Idx Asset : Type) where
  index : Finset PIdx
  assign : PIdx → Pledge Idx Asset

/-- 후보 ⓐ. 비재귀 자리에 `decide (∃ k ∈ …)` 를 쓴다. -/
def candA {PIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx) : Bool :=
  (P.assign i).rehypothecable
    && decide (∃ k ∈ P.index, (P.assign i).linksTo S (P.assign k) = true)

/-- 후보 ⓑ. 비재귀 자리에 `Finset.filter` 와 `Finset.card` 를 쓴다. -/
def candB {PIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq PIdx] [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx) : Bool :=
  (P.assign i).rehypothecable
    && decide (0 < (P.index.filter (fun k => (P.assign i).linksTo S (P.assign k) = true)).card)

/-- 후보 ⓒ. 재귀 자리에 `decide (∃ k ∈ …)` 를 쓴다. -/
def PledgeSet.candC {PIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) : ℕ → PIdx → PIdx → Bool
  | 0, _, _ => false
  | n + 1, i, j =>
      (P.assign i).linksTo S (P.assign j)
        || decide (∃ k ∈ P.index,
             ((P.assign i).linksTo S (P.assign k) && P.candC S n k j) = true)

/-- 후보 ⓓ. 재귀 자리에 `Finset.fold` 를 쓴다. -/
def PledgeSet.candD {PIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) : ℕ → PIdx → PIdx → Bool
  | 0, _, _ => false
  | n + 1, i, j =>
      (P.assign i).linksTo S (P.assign j)
        || P.index.fold (· || ·) false (fun k =>
             (P.assign i).linksTo S (P.assign k) && P.candD S n k j)

#print axioms CollateralProbe.candA
#print axioms CollateralProbe.candB
#print axioms CollateralProbe.PledgeSet.candC
#print axioms CollateralProbe.PledgeSet.candD

end CollateralProbe
