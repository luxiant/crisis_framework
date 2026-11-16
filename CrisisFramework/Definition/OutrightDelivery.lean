/-
정의층 — 확정 인도와 그것을 거쳐 잇는 담보 사슬

규율: L-9(import 방향은 단방향), L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족으로 정의한다), A-1(`axiom` 금지),
      A-3(witness 의무), A-8(변이 검사와 논리 결합의 증거), C-1·C-2(`noncomputable` 과
      `Classical` 금지), C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-7(용어집 선행 등록),
      D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시),
      T-6(존재 형태).

**이 파일이 세우는 것은 반환 의무가 서지 않는 고리를 담보 사슬이 세는 자리다.** 앞 아크가 사슬의
이어짐을 두 반환 청구권에서 읽기로 정했고 그 귀결로 반환 의무가 없는 고리가 사슬에서 빠졌는데, 받은
구멍이 그 빠짐을 **담보 사슬이 저자의 사슬보다 짧다**로 적는다.

**가르는 축이 반환 의무의 유무이고 소유권의 이전이 아니다.** 소유권이 넘어가면서도 등가물의 반환
의무가 서는 제공이 용어집에 이미 등록되어 있고 그 반환 청구권으로 기존 구조가 그것을 받고 있으므로,
소유권을 축으로 두면 그 제공이 이 파일 쪽으로 떨어진다.

**담보 제공을 넓히지 않고 그 옆에 세운다.** 받은 구멍이 담보 제공이 아닌 이전을 구조가 받아야 하고
그것은 담보의 판별선 밖이라고 적으며, 용어집이 제공을 두 꼴로 분할하고 그 둘을 배타로 등록해 두어
셋째 칸을 더하는 길이 그 분할을 깨뜨린다. 기존 이어짐 술어도 고치지 않고 새 관계가 그것을 논리합으로
품게 하여 앞 사슬이 새 사슬의 부분으로 남는다.

**사슬의 머리를 재는 술어도 새로 세우고 기존 것을 고치지 않는다.** 기존 머리 술어의 문서화 문면이
담보 속도의 분모가 세는 대상이 그것이라고 적으므로, 그것을 새 관계로 다시 가리키면 분모가 세는 대상이
조용히 바뀐다. 두 술어가 갈리는 자리가 실재하며 분모가 어느 쪽을 세는지는 구멍으로 등재된다.

**이 파일은 수를 시점 인덱스와 단계 수로만 쓴다.** 그 밖의 자리에 수가 서지 않는다.

**용어집의 선행 등록을 받는다.** 그 요구의 판별 시험이 그 개념을 원 문헌이나 성문 규범이 자기 문면으로
세우는가를 묻는데, 거래 결제 인도를 연쇄의 회전으로 세는 편과 통상의 영업 과정의 매도를 적는 조문이
둘 다 그 개념을 자기 문면으로 세우므로 이 파일의 구조체는 표현 수단이 아니다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.Collateral

namespace CrisisFramework.Definition

/--
확정 인도.

**대응 비형식 개념:** 담보물 하나가 한 당사자에게서 다른 당사자에게로 옮겨지면서 돌려줄 의무가
서지 않는 것. 거래의 결제로 인도하는 것과 통상의 영업 과정에서 파는 것이 그 부류다.

**이 정의가 배제하는 사례:**
소유권이 넘어가면서도 등가물의 반환 의무가 서는 담보 제공. 증거금 규범의 계약 양식 둘을 읽은 기록이
영국법 이전형에서 모든 권리와 소유권이 받는 쪽에 넘어가고 담보권을 만들지 않으면서도 반환 대상이 등가
신용보전으로 선다고 적으므로, 그 양식은 반환 청구권을 들어 담보 제공으로 서고 이 구조가 받지 않는다.
조달처: E-43 §2-6 「모든 권리와 소유권이 받는 쪽에 넘어간다」

**기각한 대체 정의:**
담보 제공의 두 색인 필드를 선택으로 열어 이 자리를 담는 안. 받은 구멍이 담보 제공이 아닌 이전을
구조가 받아야 하고 그것은 담보의 판별선 밖이라고 적으므로 그 문면과 부딪히며, 용어집이 제공을 담보권형과
소유권 이전형으로 분할하고 그 둘을 배타로 등록해 두어 어느 꼴에도 들지 않는 제공이 서게 된다. 옮겨진
것의 종류물을 칸으로 들어 사슬의 이어짐을 그것으로 재는 안도 기각했다. 그러면 이어짐의 논리곱이 넷이
되어 각 인자가 홀로 값을 가르는 자리를 드는 정리가 청구권 집합을 둘 들어야 하고, 기존 이어짐 술어가
종류물의 같음을 두 반환 청구권에서 한 번만 재는 것과 꼴이 갈린다.

**옮겨진 담보물을 든다.** 그것이 공시에서 읽히는지를 관측층이 묻는 축이고, 담보권이 끊기는 판정이
제공의 담보물과 맞대는 자리다.

**법적 판정을 외생 확인 신호 하나로 받는다.** 통상의 영업 과정인지와 대체 가능 물건을 매매하는 자인지는
분쟁이 서야 법원이 내리므로 구조가 재지 못하며, 검증 불가능한 조항을 외생 확인 신호로 두라는 요구가 그
자리를 정한다.
-/
-- DD:CF-3802
structure OutrightDelivery (Idx Asset Party : Type) where
  /-- 옮겨진 담보물. -/
  conveyed : Pledgeable Idx Asset
  /-- 내놓는 쪽. -/
  giver : Party
  /-- 받는 쪽. -/
  taker : Party
  /-- 앞선 청구를 벗어나 취득하는 요건이 충족됐는가. 외생 확인 신호다. -/
  defeatsPriorClaims : Bool

/-- witness (A-3). **무엇을 증거하는가.** `OutrightDelivery` 가 비어 있지 않다. 모든 자리가
`Unit` 이고 앞선 청구를 벗어나지 않는 인도 하나를 든다. -/
-- DD:CF-3802
def OutrightDelivery.trivial : OutrightDelivery Unit Unit Unit where
  conveyed := Pledgeable.trivial
  giver := ()
  taker := ()
  defeatsPriorClaims := false

/--
그 인도가 두 제공 사이를 잇는가.

**대응 비형식 개념:** 앞 제공으로 담보를 받은 쪽이 그것을 확정 인도로 내놓고, 그 인도를 받은 쪽이
뒤 제공의 제공자인가. 사슬이 반환 의무 없는 고리를 건너 한 단계 이어지는 자리다.

**이 정의가 배제하는 사례:**
같은 두 당사자 사이에서 다른 물건이 옮겨진 인도. 이 술어가 옮겨진 담보물을 맞대지 않고 당사자와
종류물만 보므로 그 인도도 이어짐을 낸다. 기존 이어짐 술어가 담보물의 같음으로 재는 안을 재담보에서
돌아오는 것이 그 물건이 아니라 등가물이라는 사유로 이미 기각했으므로 그 느슨함이 이 술어에서 더
넓어지지 않는다.
조달처: E-08 §2-2 「단 하나의 국채가 네 가지 서로 다른 거래를 받친다」

**기각한 대체 정의:**
당사자를 인도의 두 칸이 아니라 제공의 반환 청구권에서 읽는 안. 확정 인도는 반환 청구권을 갖지 않으므로
읽을 자리가 없다. 종류물의 같음을 인도가 든 칸으로 재는 안도 기각했다. 그러면 논리곱이 넷이 되고 각
인자가 홀로 값을 가르는 자리를 드는 정리가 청구권 집합을 둘 들어야 한다.

**논리곱이 셋이다.** 앞쪽 당사자의 이어짐과 뒤쪽 당사자의 이어짐과 두 반환 청구권의 종류물의 같음이며,
셋째는 기존 이어짐 술어가 재는 것과 같은 축이다.
-/
-- DD:CF-3802
def OutrightDelivery.bridges {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (d : OutrightDelivery Idx Asset Party) (p q : Pledge Idx Asset) : Bool :=
  decide ((S.assign p.returns).obligor = d.giver)
    && decide (d.taker = (S.assign q.returns).holder)
    && decide ((S.assign p.returns).currency = (S.assign q.returns).currency)

/--
한 시점의 확정 인도 집합.

**대응 비형식 개념:** 그 시점에 선 확정 인도 전부. 색인과 배정으로 준다.

**이 정의가 배제하는 사례:**
같은 담보물이 여러 인도에 나타나는 것을 색인이 구별하므로 중복이 구조에서 읽히는데, 그 중복이
적법한 연쇄인지 같은 물건을 두 번 판 사고인지를 이 구조가 가르지 않는다. 창고증권의 규범을 읽은 기록이
중복 증권이 권리를 주지 않되 대체 가능 물건이 예외라고 적으므로 그 가름이 법에 있고 구조에 없다.
조달처: E-47 §2-4 「중복 증권은 그 물건에 아무 권리도 주지 않는다」

**기각한 대체 정의:**
색인 없이 인도의 유한 집합을 직접 두는 안. 담보물이 선택 필드를 품어 같음의 판정이 자산 타입에
매달리므로 색인 방식이 아니면 중복이 눌린다. 제공 집합과 청구권 집합이 같은 사유로 색인을 쓰며 리포
안에서 관례가 갈리지 않는다.

**제공 집합과 합치지 않는다.** 합치면 두 꼴이 한 색인에 들어 어느 항이 반환 의무를 지니는지가 배정에서
갈리지 않고, 기존 제공 집합을 받는 술어 전량의 유니버스가 조용히 넓어진다.
-/
-- DD:CF-3802
structure DeliverySet (DIdx Idx Asset Party : Type) where
  /-- 인도의 색인. -/
  index : Finset DIdx
  /-- 색인에서 인도로의 배정. -/
  assign : DIdx → OutrightDelivery Idx Asset Party

/-- witness (A-3). **무엇을 증거하는가.** `DeliverySet` 이 비어 있지 않다. 색인이 빈 인도 집합을
든다. -/
-- DD:CF-3802
def DeliverySet.trivial : DeliverySet Unit Unit Unit Unit where
  index := ∅
  assign := fun _ => OutrightDelivery.trivial

/--
시점 인덱스를 갖는 확정 인도 집합의 족 (L-13).

**대응 비형식 개념:** 시점마다 선 확정 인도 집합. 인도는 시점에 따라 서고 사라진다.

**이 정의가 배제하는 사례:**
같은 시점 안의 순서. 시점 인덱스가 자연수이므로 하루 안에서 인도가 둘 선 순서를 구조가 주지 않으며,
제공 집합의 족이 같은 자리에서 같은 한계를 안고 있다. 동적 연쇄를 읽은 기록이 그 연쇄에 단계 구분이
없다고 적으므로 그 순서를 구조가 주지 않는 것이 대상의 성질을 따른 것이다.
조달처: E-08 §2-2 「같은 자산이 반복 사용되며, 단계 구분이 없고 순환할 수 있다」

**기각한 대체 정의:**
시점을 인도 자신의 필드로 두는 안. 그러면 한 집합 안에 여러 시점의 인도가 섞여 그 시점의 인도 전부를
가리키는 자리가 사라진다.
-/
-- DD:CF-3802
abbrev DeliveryFamily (DIdx Idx Asset Party : Type) := ℕ → DeliverySet DIdx Idx Asset Party

/-- 시점에 따라 변하지 않는 족을 만든다. **무엇을 증거하는가를 들지 않는다.** 그 선언이 증거하는
구조가 따로 없고 시점에 따라 변하지 않는 족을 만드는 수단이기 때문이다. -/
-- DD:CF-3802
def DeliveryFamily.constant {DIdx Idx Asset Party : Type}
    (D : DeliverySet DIdx Idx Asset Party) : DeliveryFamily DIdx Idx Asset Party := fun _ => D

/--
사슬이 확정 인도를 거쳐서라도 한 단계 이어지는가.

**대응 비형식 개념:** 앞 제공에서 뒤 제공으로 한 걸음 가는 길이 제공 사이의 재제공이거나, 그 사이에
반환 의무 없는 인도가 한 번 끼인 것인가.

**이 정의가 배제하는 사례:**
인도가 둘 이어 끼인 고리. 이 술어가 인도 하나만 건너므로 딜러가 받은 담보를 확정 인도로 내놓고 그 받은
쪽이 다시 확정 인도로 넘긴 뒤에야 제공이 서는 경로를 한 걸음으로 세지 않는다. 상품 담보 금융을 읽은
기록이 같은 담보 구조가 전달의 유무로 갈린다고 적어 인도가 이어지는 꼴이 실재함을 밝힌다.
조달처: E-46 §3-1 「그래서 의존이 참인데 교역 물량으로 가는 전달이 없는 자리가 선다」

**기각한 대체 정의:**
기존 이어짐 술어를 고쳐 인도를 받게 하는 안. 그 술어를 딛는 재담보 판정과 순환 판정과 사슬 머리 판정이
전량 뜻을 갈아타고 앞 페이즈들이 그 술어로 세운 배제 사례가 가리키는 대상이 사라진다. 인도를 여러 번
건너는 전이 폐포로 두는 안도 기각했다. 한 걸음의 뜻이 사슬의 단계 수와 갈리면 단계 수를 받는 도달
판정이 무엇을 세는지가 서지 않는다.

**논리합이므로 기존 이어짐이 참인 자리에서 이 술어도 참이다.** 앞 사슬이 새 사슬의 부분으로 남는다.
-/
-- DD:CF-3802
def Pledge.linksVia {DIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (D : DeliverySet DIdx Idx Asset Party) (p q : Pledge Idx Asset) : Bool :=
  p.linksTo S q
    || decide (∃ t ∈ D.index, ((D.assign t).bridges S p q) = true)

/--
확정 인도를 거쳐서라도 주어진 단계 수 안에 이어지는가.

**대응 비형식 개념:** 한 제공에서 출발해 재제공과 확정 인도를 거듭했을 때 다른 제공에 닿는가.

**이 정의가 배제하는 사례:**
단계 수를 밖에서 받으므로 그 값이 모자라면 닿는데도 거짓이 된다. 기존 도달 판정이 같은 한계를 안고
있고 호출하는 쪽이 색인의 크기를 주는 것이 그 구조가 기대하는 쓰임이다. 인도가 끼인 걸음도 한 걸음으로
세므로 사슬의 길이가 제공의 수로 세어지고 인도의 수가 그 길이에 들지 않는다.
조달처: E-08 §2-2 「단 하나의 국채가 네 가지 서로 다른 거래를 받친다」

**기각한 대체 정의:**
단계 수 없이 전이 폐포를 직접 재는 안. 사슬에 순환이 설 수 있으므로 소박한 재귀가 종료하지 않는다.
인도의 수를 길이에 함께 세는 안도 기각했다. 저자의 회전 수가 제공과 인도를 가리지 않고 세는 것으로
읽히나 그 편이 그 수의 정의를 적지 않으므로, 세는 꼴을 정하면 읽지 않은 편의 성질을 근거로 쓰게 된다.

**유한집합 위의 한정 존재를 `decide` 로 판정한다.** 기존 도달 판정과 같은 꼴이며 인스턴스 선언이
붙지 않는다.
-/
-- DD:CF-3802
def PledgeSet.reachesWithinVia {PIdx DIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (D : DeliverySet DIdx Idx Asset Party)
    (P : PledgeSet PIdx Idx Asset) : ℕ → PIdx → PIdx → Bool
  | 0, _, _ => false
  | n + 1, i, j =>
      (P.assign i).linksVia S D (P.assign j)
        || decide (∃ k ∈ P.index,
             ((P.assign i).linksVia S D (P.assign k)
               && P.reachesWithinVia S D n k j) = true)

/--
그 제공이 확정 인도를 거쳐서도 사슬의 머리인가.

**대응 비형식 개념:** 어느 제공에서도 재제공으로든 확정 인도를 거쳐서든 이어 들어오지 않은 제공.

**이 정의가 배제하는 사례:**
확정 인도가 앞에 선 제공. 기존 머리 술어에서 그 제공은 머리로 서는데 이 술어에서는 머리가 아니므로
두 술어가 그 자리에서 갈리고, 담보 속도의 분모가 어느 쪽을 세는지가 이 구조에서 정해지지 않는다. 그
갈림은 구멍으로 등재되어 있다.
조달처: E-08 §2-2 「단 하나의 국채가 네 가지 서로 다른 거래를 받친다」

**기각한 대체 정의:**
기존 머리 술어를 이 관계로 다시 가리키는 안. 그 술어의 문서화 문면이 담보 속도의 분모가 세는 대상이
그것이라고 적으므로 분모가 세는 대상이 조용히 바뀌고, 그 술어를 이름으로 드는 결정 넷의 문면이 가리키는
대상이 사라진다.

**단계 수를 받지 않는다.** 머리인지는 한 걸음 안쪽만 보면 서므로 도달 판정이 필요하지 않다.
-/
-- DD:CF-3802
def PledgeSet.isChainHeadVia {PIdx DIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (D : DeliverySet DIdx Idx Asset Party)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx) : Bool :=
  !decide (∃ k ∈ P.index, ((P.assign k).linksVia S D (P.assign i)) = true)

/--
그 제공의 담보권이 제3자의 처분으로 끊겼는가.

**대응 비형식 개념:** 담보로 잡힌 물건이 그 제공의 두 당사자가 아닌 자의 손에서 팔려 나가, 담보를
잡은 쪽의 권리가 그 물건에 닿지 못하게 된 상태.

**이 정의가 배제하는 사례:**
창고업자가 팔았으나 통상의 영업 과정이 아니었거나 대체 가능 물건을 매매하는 자가 아니었던 경우. 창고증권의
규범을 읽은 기록이 그 두 요건을 함께 적으므로 요건이 갖추어지지 않으면 권리가 끊기지 않는데, 그 판정이
법적 판정이어서 구조가 재지 못하고 이 술어는 그것을 외생 확인 신호로 받는다.
조달처: E-47 §2-5 「대체 가능 물건을 매매하는 창고업자가 통상의 영업 과정에서 매수인에게 그 물건을 팔면」

**기각한 대체 정의:**
끊김을 제공 자신의 필드로 두는 안. 처분은 제공 밖의 사건이므로 그 필드가 인도 집합과 어긋날 수 있고
어긋났을 때 어느 쪽이 참인지를 구조가 말하지 않는다. 요건 전량을 구성적으로 재는 안도 기각했다. 통상의
영업 과정과 대체 가능 물건의 매매는 분쟁이 서야 법원이 내리는 판정이어서 신호로 받을 수밖에 없고,
검증 불가능한 조항을 외생 확인 신호로 두라는 요구가 그 자리를 이미 정한다.

**논리곱이 넷이다.** 옮겨진 담보물의 자산이 그 제공의 담보물의 자산과 같은 것과, 내놓는 쪽이 반환 청구권의 권리자가
아닌 것과 의무자가 아닌 것과, 외생 확인 신호다. 앞의 셋이 구성적으로 재어지고 넷째가 재어지지 않는다.
-/
-- DD:CF-3805
def PledgeSet.rightDefeated {PIdx DIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Asset] [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (D : DeliverySet DIdx Idx Asset Party)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx) : Bool :=
  decide (∃ t ∈ D.index,
    (decide ((D.assign t).conveyed.asset = (P.assign i).pledged.asset)
      && decide ((D.assign t).giver ≠ (S.assign (P.assign i).returns).holder)
      && decide ((D.assign t).giver ≠ (S.assign (P.assign i).returns).obligor)
      && (D.assign t).defeatsPriorClaims) = true)

/--
확정 인도를 거친 이어짐이 제공만의 이어짐보다 넓다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
확정 인도가 끼인 자리에서 기존 이어짐 술어가 이미 참이어야 한다. 그 관측은 반환 의무 없는 고리가
이미 사슬에 들어 있다는 뜻이며, 그러면 받은 구멍이 적은 짧음이 애초에 서지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 받은 구멍이 적은 짧음이 실제로 메워졌음을 보이는 자리이고, 두 술어 가운데 앞의
것이 거짓이고 뒤의 것이 참인 자리가 실재한다는 것이 이 정리의 산출이므로 기여 목록에 든다.

**존재 형태로 진술하는 까닭(T-6):** 확정 인도가 끼이면 늘 넓어지는 것이 아니다. 당사자가 이어지지
않는 인도는 아무것도 잇지 않으므로, 넓어지는 배치가 실재함이 이 정리가 드는 것이다.
-/
-- DD:CF-3806
theorem exists_delivery_step_beyond_pledge_step :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (D : DeliverySet Unit Bool Bool (Option Bool))
      (p q : Pledge Bool Bool),
      p.linksTo S q = false ∧ p.linksVia S D q = true := by
  sorry

/--
그 이어짐 판정이 각 인자에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 거짓인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는
뜻이며, 그러면 당사자가 이어지지 않는 인도나 종류물이 다른 두 제공이 사슬의 한 걸음으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 판정의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로, 각
인자가 홀로 거짓인 자리를 이 정리가 든다.

**갱신 문법으로 앞 두 인자를 가르고 셋째는 반환 청구권을 갈아 가른다.** 종류물의 같음이 인도의 칸이
아니라 두 청구권에서 재어지므로 그 인자는 뒤 제공의 반환 색인을 갈아야 갈린다.
-/
-- DD:CF-3806
theorem delivery_bridge_pins_each_conjunct :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (d : OutrightDelivery Bool Bool (Option Bool))
      (p q q' : Pledge Bool Bool),
      d.bridges S p q = true
        ∧ ({ d with giver := some false } :
             OutrightDelivery Bool Bool (Option Bool)).bridges S p q = false
        ∧ ({ d with taker := some true } :
             OutrightDelivery Bool Bool (Option Bool)).bridges S p q = false
        ∧ d.bridges S p q' = false
        ∧ q'.returns ≠ q.returns := by
  sorry

/--
한 걸음이 서지 않는데 그 뒤가 닿는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
첫 걸음이 서지 않는 모든 배치에서 그 뒤의 도달도 서지 않아야 한다. 그 관측은 도달 판정의 재귀가 첫
걸음을 요구하지 않는다는 뜻이며, 그러면 사슬이 아닌 쌍이 사슬로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 판정의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 그 재귀의
한 걸음과 그 뒤의 도달을 잇는 결합이 논리곱이어야 하는 것을 이 정리가 증거로 든다. 그 결합을 논리합으로
뒤집은 사본에서는 뒤의 도달만으로 앞의 도달이 서므로 첫 항이 거짓을 내지 못한다.

**기존 도달 판정이 이 자리를 비워 둔 것과 갈린다.** 그 판정의 같은 결합이 가리는 자리 없이 서 있고
그 사실이 계수로 보고되는데, 새로 세우는 판정은 그 계수를 늘리지 않아야 하므로 이 정리가 선다.

**존재 형태로 진술하는 까닭(T-6):** 첫 걸음이 서지 않는데 그 뒤가 닿는 것이 모든 배치에서 서는 것이
아니다. 그런 배치가 실재함이 그 결합을 가르는 데 필요한 전부다.
-/
-- DD:CF-3806
theorem exists_reach_via_tail_without_first_step :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (D : DeliverySet Unit Bool Bool (Option Bool))
      (P : PledgeSet Bool Bool Bool),
      P.reachesWithinVia S D 2 false true = false
        ∧ (P.assign false).linksVia S D (P.assign true) = false
        ∧ P.reachesWithinVia S D 1 true true = true := by
  sorry

/--
담보권이 끊긴 제공이 사슬에 그대로 서서 다른 제공에 닿는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
끊김이 선 제공이 어느 제공에도 닿지 못해야 한다. 그 관측은 사슬의 이어짐이 담보권의 존속을 보고 있다는
뜻이며, 그러면 사슬이 세는 고리가 담보 실물에 닿는 고리만으로 서서 커버리지의 합이 실물을 넘는 자리가
구조에서 사라진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 사슬의 이어짐이 담보권의 존속을 보지 않는다는 것을 보이고, 그 눈먼 자리가
이 페이즈가 세운 두 술어의 사이에서 실제로 선다는 것이 이 정리의 산출이므로 기여 목록에 든다.

**존재 형태로 진술하는 까닭(T-6):** 끊긴 제공이 늘 닿는
것도 늘 닿지 못하는 것도 아니며, 닿는 자리가 실재함이 이 정리가 드는 것이다.
-/
-- DD:CF-3806
theorem exists_right_defeated_and_still_reaches :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (D : DeliverySet Unit Bool Bool (Option Bool))
      (P : PledgeSet Bool Bool Bool) (i j : Bool),
      P.rightDefeated S D i = true
        ∧ P.reachesWithinVia S D P.index.card i j = true := by
  sorry

/--
그 끊김 판정이 각 인자에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 거짓인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는
뜻이며, 그러면 다른 물건이 옮겨진 인도나 그 제공의 당사자가 스스로 내놓은 인도나 요건이 갖추어지지
않은 인도가 담보권을 끊은 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 판정의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로, 각
인자가 홀로 거짓인 자리를 이 정리가 든다.

**당사자를 세 값으로 두어 두 당사자 인자를 따로 가른다.** 당사자가 둘이면 내놓는 쪽을 갈 때 두 인자가
함께 갈려 홀로 가르는 자리가 서지 않는다.
-/
-- DD:CF-3806
theorem right_defeat_pins_each_conjunct :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (d : OutrightDelivery Bool Bool (Option Bool))
      (P : PledgeSet Bool Bool Bool) (i : Bool),
      P.rightDefeated S (DeliverySet.mk {()} (fun _ => d)) i = true
        ∧ P.rightDefeated S
            (DeliverySet.mk {()} (fun _ => { d with giver := some false })) i = false
        ∧ P.rightDefeated S
            (DeliverySet.mk {()} (fun _ => { d with giver := some true })) i = false
        ∧ P.rightDefeated S
            (DeliverySet.mk {()} (fun _ => { d with defeatsPriorClaims := false })) i = false
        ∧ P.rightDefeated S
            (DeliverySet.mk {()}
              (fun _ => { d with conveyed := { d.conveyed with
                                                asset := !d.conveyed.asset } })) i
            = false := by
  sorry

/--
두 머리 술어가 갈리는 자리가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 술어가 모든 자리에서 같은 값을 내야 한다. 그 관측은 확정 인도가 사슬의 머리를 바꾸지 않는다는
뜻이며, 그러면 담보 속도의 분모가 어느 술어를 세는지를 묻는 자리가 서지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 분모가 세는 대상이 두 술어에서 갈린다는 것을 보이고, 그 갈림이 구멍으로
등재되는 근거이므로 기여 목록에 든다.

**존재 형태로 진술하는 까닭(T-6):** 두 술어가 모든 자리에서 갈리는 것이 아니다. 인도가 앞에 서지
않은 제공에서는 두 값이 같으므로, 갈리는 자리가 실재함이 이 정리가 드는 것이다.
-/
-- DD:CF-3806
theorem exists_chain_head_split_by_delivery :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (D : DeliverySet Unit Bool Bool (Option Bool))
      (P : PledgeSet Bool Bool Bool) (i : Bool),
      P.isChainHead S i = true ∧ P.isChainHeadVia S D i = false := by
  sorry

end CrisisFramework.Definition
