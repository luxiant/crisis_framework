/-
정의층 — 부채수용력의 담보 의존

규율: L-10(무차원. 수 체계를 매개변수로 받는다), C-3(판정은 계산으로 낸다),
D-1·D-2(docstring 3항목), T-2(반증 조건), T-4(가정을 진술에 명시한다), R-6(선언마다 표지).

이 파일은 그 의존이 누구의 부채수용력에 걸리는지를 담는다. 담보가 무엇을 떠받치는지는 담보
관계가 들고 얼마나 떠받치는지는 마진이 드는데, 아래 선언은 그 둘을 함께 딛는다. 그래서 어느
쪽의 주제도 아니며 자기 파일에 선다.

**이름 공간 접두 `PledgeSet.` 를 유지한다.** 세 술어의 주 대상이 담보 제공 집합이고 B3 에
해당하는 선언이 그 둘을 `P.securesBorrowingOf` 로 부른다. 이 리포의 선언이 대개 그 주 대상을
세운 파일에 사나, `RatesSet.isOrphan` 이 `PledgeSet` 을 첫 명시 인자로 받으면서 마진에 사는
것이 이미 그 자리를 가른 선례다. 이름이 대상을 가리키는 것이 자리의 관례보다 앞선다.

**시점 인덱스를 받지 않으므로 L-13 의 대상이 아니다.** 세 술어가 시점 족이 아니라 담보 제공
집합 위의 술어이기 때문이며, 시점에 따라 변하는 것은 그 집합과 청구권 집합을 주는 쪽이 든다.

**`import` 셋 가운데 앞의 둘이 transitive 로 겹치나 그대로 명시한다.** 마진이 담보 관계와
발동조건을 함께 명시한 것이 그 관례다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Finset.Card
import CrisisFramework.Definition.Collateral
import CrisisFramework.Definition.Margin

namespace CrisisFramework.Definition

/--
그 주체가 그 담보물을 직접 내놓아 빌린 자리가 있는가.

**대응 비형식 개념:** 주체 m 이 상품 k 를 담보로 제공하고 그 담보가 떠받치는 채무를 스스로
지는 배치. 재고를 금융해 구매력을 늘리는 거래업체가 그 자리에 선다.

**이 정의가 배제하는 사례:**
중국의 상품 담보 금융에서 금융 투자자가 구리를 수입해 보세창고의 창고증권을 담보로 위안화를
빌리고 그 돈을 국내 고수익에 투자한 것(Tang·Zhu 2016 §1). 그 구리는 세관에 들어가지 않고
창고에 머물러 실물 소비로 가지 않으므로, 이 술어가 참을 내는데도 그 의존이 교역 물량으로
넘어가지 않는다. 의존과 전달이 다른 것이며 이 술어는 앞만 잰다.

**기각한 대체 정의:**
비율 조의 배정을 묻지 않는 안. 담보 차입이 서면 율이 따라온다고 보았으나, 구조가
`RatesSet.isOrphan` 으로 그 어긋남을 재므로 제공이 서고 율이 서지 않는 배치가 구조에서
가능하고 그 자리 자체가 결손의 신호다. 담보물을 색인이 아니라 반환 청구권의 종류물로 재는
안도 기각했다. 종류물로 재는 것은 사슬이 이어지는지를 보는 자리이고, 이 술어가 묻는 것은
그 제공에 실제로 걸린 담보물이 무엇인가다.

**금액을 쓰지 않는다.** 당사자와 색인의 비교와 비율 조의 존재만 보므로 정의층에 선다(L-10).
-/
-- DD:CF-925
def PledgeSet.securesBorrowingOf
    {PIdx RIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq PIdx] [DecidableEq Party] [DecidableEq Asset]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset)
    (R : RatesSet RIdx PIdx Num Obs)
    (m : Party) (k : Asset) : Bool :=
  decide (∃ i ∈ P.index,
    (decide ((P.assign i).pledged.asset = k)
      && decide ((S.assign (P.assign i).secures).obligor = m)
      && R.hasRates i) = true)

/--
그 주체가 그 담보물을 받았다가 다시 내놓아 빌린 자리가 있는가.

**대응 비형식 개념:** 주체 m 이 상품 k 를 담보로 받은 쪽이었고, 받은 것을 다시 내놓아 자기
채무를 떠받친 배치. 담보를 받아 재사용하는 중개자가 그 자리에 선다.

**이 정의가 배제하는 사례:**
같은 규범이 개시증거금의 재담보를 원칙으로 금지하고 열두 조건 아래 한 번만 허용하는데, 이
술어는 사슬이 몇 단계인지를 세지 않고 닿는지만 보므로 그 한 번 제한이 담기지 않는다
(BCBS·IOSCO 2020년 4월 제5요소). 한 번 거친 것과 여러 번 거친 것이 이 술어에서 같아 보인다.

**기각한 대체 정의:**
사슬의 단계 수를 밖에서 받는 안. `PledgeSet.reachesWithin` 의 docstring 이 그 값이 모자라면
닿는데도 거짓이 된다고 적고 호출하는 쪽이 색인의 크기를 주는 것을 기대하는 쓰임으로 두므로,
밖에서 받으면 이 술어가 그 결손을 그대로 물려받는다. 받은 자리를 반환 청구권의 권리자로 읽는
안도 기각했다. 그 자리는 자기 자산을 묶은 담보 제공자이고 여력이 오히려 줄어드는 쪽이므로
의존의 방향이 반대다.

**단계 수를 색인의 크기로 고정한다.** `PledgeSet.inCycle` 이 같은 값을 쓰는 선례다.
-/
-- DD:CF-926
def PledgeSet.securesRechainedBorrowingOf
    {PIdx RIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq PIdx] [DecidableEq Party] [DecidableEq Asset] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset)
    (R : RatesSet RIdx PIdx Num Obs)
    (m : Party) (k : Asset) : Bool :=
  decide (∃ j ∈ P.index,
    (decide ((S.assign (P.assign j).secures).obligor = m)
      && R.hasRates j
      && decide (∃ i ∈ P.index,
           (decide ((P.assign i).pledged.asset = k)
             && decide ((S.assign (P.assign i).returns).obligor = m)
             && P.reachesWithin S P.index.card i j) = true)) = true)

/--
그 주체의 부채수용력이 그 담보물에 걸려 있는가.

**대응 비형식 개념:** 상품 k 의 가치가 떨어졌을 때 주체 m 이 빌릴 수 있는 양이 줄어드는
구조적 자리가 있는가. 직접 내놓은 것과 받아서 다시 내놓은 것이 둘 다 그 자리에 든다.

**이 정의가 배제하는 사례:**
2022년 유럽 천연가스와 전력 시장에서 현물을 든 쪽이 선물 포지션의 변동증거금을 현금으로 냈고
개시증거금이 가격보다 빠르게 올라 실효 레버리지가 꺾인 것(BIS Bulletin No 77, 2023년 9월).
그 자리에서 담보물은 현금과 고유동성 자산이고 상품은 포지션의 기초자산이므로, 담보물이 상품인
배치만 참으로 내는 이 술어가 그 경로를 담지 않는다. 부채수용력이 상품 가격에 걸린 것은 같은데
걸리는 통로가 다르다.

**기각한 대체 정의:**
담보로 내놓지 않은 여력을 함께 묻는 안. 담보 가능한 자산을 얼마나 들고 있는지를 담는 대상이
정의층에 없으므로 물을 것이 없다. `Constraint.assetEligible` 이 적격성만 들고 보유를 들지
않으며, 그 결손은 구멍으로 등재한다. 두 자리를 하나의 술어로 합쳐 두는 안도 기각했다. 직접
의존과 사슬을 거친 의존은 공시에서 보이는 정도가 다르고, 아래 정리 둘이 그 독립을 보인다.

**답이 참 쪽으로만 선다.** 이 술어가 거짓을 낸다고 해서 의존이 없는 것이 아니다. 내놓지 않은
여력이 구조에 없기 때문이며, 그 비대칭을 관측층이 판정 불가로 받는다.
-/
-- DD:CF-925
def PledgeSet.debtCapacityDependsOn
    {PIdx RIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq PIdx] [DecidableEq Party] [DecidableEq Asset] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset)
    (R : RatesSet RIdx PIdx Num Obs)
    (m : Party) (k : Asset) : Bool :=
  P.securesBorrowingOf S R m k || P.securesRechainedBorrowingOf S R m k

/--
직접 내놓아 빌렸는데 받아서 다시 내놓은 자리는 아닌 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 상품을 직접 담보로 내놓아 빌린 모든 배치에서
그 주체가 같은 상품을 담보로 받은 적이 있고 그 받은 제공에서 사슬이 이어져야 한다. 담보를
내놓는 모든 주체가 먼저 그 담보를 받은 쪽이었어야 하므로, 사슬에 머리가 없다는 뜻이 된다.

**가정을 두지 않는다**(T-4). 구체 배치 하나로 닫히므로 전칭 가정이 들어갈 자리가 없다.
-/
-- DD:CF-927
theorem exists_securesBorrowing_and_not_rechained :
    ∃ (S : ClaimSet Bool Bool Unit Unit Unit Unit Unit)
      (P : PledgeSet Bool Bool Unit)
      (R : RatesSet Bool Bool Unit Unit)
      (m : Bool) (k : Unit),
      P.securesBorrowingOf S R m k = true
        ∧ P.securesRechainedBorrowingOf S R m k = false := by
  refine
    ⟨{ index := {true}
     , assign := fun b =>
         { obligor := b
         , holder := !b
         , currency := ()
         , amount := Term.const ()
         , trigger := TriggerFamily.constant (Trigger.le (Term.const ()) (Term.const ()))
         , inception := 0
         , expiry := 0
         , exercisable := fun _ => true } }
    , { index := {true}
      , assign := fun _ =>
          { pledged := { asset := (), asClaim := none }
          , secures := true
          , returns := false
          , rehypothecable := false } }
    , { index := {true}
      , assign := fun _ =>
          { pledge := true
          , exposureMargin := Ratio.trivial
          , valuationRate := Ratio.trivial } }
    , true, (), ?_, ?_⟩
  · rfl
  · rfl

/--
받아서 다시 내놓아 빌렸는데 직접 내놓은 자리는 아닌 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 받은 담보를 다시 내놓아 빌린 모든 배치에서
뒤 제공의 담보물이 사슬 머리의 담보물과 같아야 한다. 재담보에서 돌아오는 것이 등가물이고 그
물건이 아니라는 전제가 그 자리에서 무너진다.

**가정을 두지 않는다**(T-4).

**담보물 타입이 `Bool` 인 까닭.** 그 타입이 `Unit` 이면 모든 담보물이 같아져 뒤 조건이 설 수
없다. 사슬 머리의 담보물을 `k` 로 두고 뒤 제공의 담보물을 다른 값으로 두어야 하므로 값이 둘
이상이어야 한다. **B4 는 그 조건이 걸리지 않아 `Unit` 으로 둔다.** 두 진술의 타입이 다른 것은
각자의 최소를 고른 결과다.
-/
-- DD:CF-927
theorem exists_rechained_and_not_securesBorrowing :
    ∃ (S : ClaimSet Bool Bool Unit Unit Unit Unit Unit)
      (P : PledgeSet Bool Bool Bool)
      (R : RatesSet Bool Bool Unit Unit)
      (m : Bool) (k : Bool),
      P.securesRechainedBorrowingOf S R m k = true
        ∧ P.securesBorrowingOf S R m k = false := by
  refine
    ⟨{ index := {true}
     , assign := fun b =>
         { obligor := b
         , holder := b
         , currency := ()
         , amount := Term.const ()
         , trigger := TriggerFamily.constant (Trigger.le (Term.const ()) (Term.const ()))
         , inception := 0
         , expiry := 0
         , exercisable := fun _ => true } }
    , { index := {false, true}
      , assign := fun b =>
          { pledged := { asset := !b, asClaim := none }
          , secures := b
          , returns := true
          , rehypothecable := true } }
    , { index := {true}
      , assign := fun _ =>
          { pledge := true
          , exposureMargin := Ratio.trivial
          , valuationRate := Ratio.trivial } }
    , true, true, ?_, ?_⟩
  · rfl
  · rfl

end CrisisFramework.Definition
