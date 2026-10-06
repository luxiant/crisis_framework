/-
정의층 — 담보 관계

규율: L-10(무차원. 수 체계를 매개변수로 받는다), L-13(시점 인덱스를 갖는 족),
C-3(판정은 계산으로 낸다), A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 예외).

이 파일은 담보가 무엇을 떠받치고 그 사슬이 어떻게 이어지는지를 담는다. 얼마나 떠받치는지는
마진이 들고, 몇 번인지의 총계는 담보 장부가 든다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Finset.Card
import CrisisFramework.Definition.Claim

namespace CrisisFramework.Definition

/--
담보물.

**대응 비형식 개념:** 담보로 제공될 수 있는 것. 자산 하나이며, 그것이 청구권이면 청구권 집합의
색인으로 함께 지목된다.

**이 정의가 배제하는 사례:**
2014년 칭다오항 금속 금융에서 은행들이 담보로 잡았다고 믿은 금속과 실제로 여러 번 돌아간
창고증권이 이 구조에서 서로 다른 값이 되므로, 둘을 하나로 보는 실무의 읽기가 담기지 않는다
(Reuters 2014년 6월 보도). 그리고 주식이 색인을 받지 못해 청구권이 아닌 칸으로 가는데, 주식은
발행기업의 자본이라 다른 노드의 대차대조표에 대응물이 없는 말단이 아니다. 담을 정의가 없다는
것은 구멍으로 등재되어 있다.

**기각한 대체 정의:**
청구권 색인과 외부 자산 값의 두 생성자를 갖는 합 타입으로 두는 안. 완전성이 생성자가 둘뿐인
데서 나오므로 청구권이 아닌 것을 여집합으로 정의한 것이 아니라 둘로 이름 붙인 것이 되고, 분할이
정의만으로 따라 나온다는 주장을 적을 근거가 구조에 없다.

**분할의 완전성은 여집합의 귀결이다(V-7).** `asClaim` 이 `none` 인 것이 색인을 갖지 않는 것
전부를 받는다.

**수 체계를 받지 않는다.** 이 구조는 무엇이 담보가 될 수 있는지만 담고 얼마인지를 담지 않는다.
-/
-- DD:CF-728
structure Pledgeable (Idx Asset : Type) where
  /-- 담보로 제공되는 자산. -/
  asset : Asset
  /-- 그 자산이 청구권이면 청구권 집합에서의 색인. 아니면 `none`. -/
  asClaim : Option Idx

/--
그 담보물이 청구권인가.

**대응 비형식 개념:** 담보로 잡힌 것이 다른 노드에 대한 권리인가, 아니면 그런 대응물이 없는
물건인가.

**이 정의가 배제하는 사례:**
창고증권처럼 물건을 가리키는 권리증권은 이 술어에서 참이 되는데, 담보 가치를 매기는 쪽이 보는
것은 그 뒤의 금속이다. 가리키는 것과 가리켜지는 것을 잇는 관계가 이 구조에 없으므로 2014년
칭다오항에서 증서가 겹친 것과 금속이 겹친 것을 가르지 못한다(Reuters 2014년 6월 보도).

**기각한 대체 정의:**
담보물의 종류를 열거형으로 두고 그것으로 판정하는 안. 종류를 미리 열거하면 새 수단이 들어올
때마다 정의층을 손대야 하고, 관측층에 사상을 더해 넓히는 길이 막힌다.
-/
-- DD:CF-729
def Pledgeable.isClaimBacked {Idx Asset : Type} (c : Pledgeable Idx Asset) : Bool :=
  c.asClaim.isSome

/-- witness (A-3). `Pledgeable` 이 비어 있지 않음을 보인다. 자산이 `Unit` 이고 색인이 없는 담보물. -/
-- DD:CF-31
def Pledgeable.trivial : Pledgeable Unit Unit where
  asset := ()
  asClaim := none

/--
담보 제공.

**대응 비형식 개념:** 담보물 하나가 청구권 하나를 떠받치고, 그 대가로 받은 쪽이 같은 종류의 것을
돌려줄 의무를 지는 관계.

**이 정의가 배제하는 사례:**
ISDA 마스터 계약 아래의 증거금은 개별 거래가 아니라 일괄정산 대상 전체의 순 익스포저에 걸리는데,
이 구조는 떠받치는 청구권을 하나씩만 지목하므로 그 순액이 담기지 않는다. 도산 시 담보물이
도산재단에 드는지도 담기지 않는다. 소유권이 넘어가는 레포와 담보권만 설정되는 질권이 이 구조에서
같은 모양이 되기 때문이며, 2014년 칭다오항 금속 금융의 상당 부분이 상품 레포였고 진정매매의
성립이 소송에서 다투어졌다(Reuters 2014년 12월 보도).

**기각한 대체 정의:**
반환 청구권을 두지 않고 떠받치는 청구권의 당사자에서 유도만 하는 안. 담보를 제공한 자와 채무를
지는 자가 갈리는 물상보증과 다단계 증권화가 담기지 않고, 반환 의무가 청구권 집합 밖에 살아
집계에 잡히지 않는다. 당사자 넷을 자기 필드로 명시하는 안도 기각했다. 두 청구권에서 전부
유도되므로 중복이고 어긋날 자리만 는다. 앞 제공을 `prior` 로 지목해 사슬을 명시하는 안도
기각했다. 사슬이 선형으로 강제되어 받은 바스켓을 쪼개 여러 갈래로 재제공하는 것이 담기지 않는다.
떠받치는 대상을 청구권 하나가 아니라 청구권 집합으로 직접 받는 안도 기각했다. 집계가 중첩되고
조의 집합으로 두면 같은 담보물이 여러 조에 나타나는 것이 곧 중복 계상이라는 읽기가 한 겹
멀어진다. 점유자를 이 구조의 필드로 두는 안도 기각했다. 같은 담보물의 제공 둘이 서로 다른
점유자를 들 수 있어 유일성을 구조가 막지 못하므로, 점유를 담는 값은 치르면서 담는 이유인
유일성은 얻지 못한다.

**네 당사자 사이에 정합을 걸지 않는다.** 담보 제공자와 담보 수취자는 반환 청구권의 권리자와
의무자이고, 채무자와 채권자는 떠받치는 청구권의 의무자와 권리자다. 넷을 묶으면 물상보증과
담보 대리인 구조가 배제된다. 증권대여에서 수탁기관이 대리인으로 끼는 것은 J-1 의 귀결로 갈린다.
순수 대리는 노드가 아니어서 본인이 당사자로 서고, 보증을 선 대리는 노드이므로 본인에 대한 보증
청구권 하나로 담긴다.

**점유를 담지 않는다.** 점유를 매 시점 유일하게 두면 같은 실물에 제공이 여럿 서는 일이 구조상
불가능해지는데, 그것은 일어난 일이다.

**생애를 떠받치는 청구권에 묶지 않는다.** 변동증거금이 피담보채무가 살아 있는 동안에도 오가며
반환 의무를 쌓았다 줄였다 하기 때문이다.
-/
-- DD:CF-735
structure Pledge (Idx Asset : Type) where
  /-- 제공되는 담보물. -/
  pledged : Pledgeable Idx Asset
  /-- 이 담보가 떠받치는 청구권의 색인. 의무자가 채무자이고 권리자가 채권자다. -/
  secures : Idx
  /-- 담보를 돌려받을 권리의 색인. 의무자가 담보 수취자이고 권리자가 담보 제공자다. -/
  returns : Idx
  /-- 받은 쪽이 자기 명의로 다시 제공할 수 있는가. -/
  rehypothecable : Bool

/-- witness (A-3). `Pledge` 가 비어 있지 않음을 보인다. 모든 자리가 `Unit` 이고 재담보 권리가 없는 제공. -/
-- DD:CF-31
def Pledge.trivial : Pledge Unit Unit where
  pledged := Pledgeable.trivial
  secures := ()
  returns := ()
  rehypothecable := false

/--
그 제공이 재담보 권리를 지니는가.

**대응 비형식 개념:** 재담보 권리가 딸려 있어 사슬의 출발점이 될 수 있는 담보.

**이 정의가 배제하는 사례:**
미국 프라임브로커리지의 재담보는 고객 차변잔액의 140% 까지로 묶여 있는데, 권리가 불린 하나이므로
그 한도가 담기지 않는다. 그리고 원천 담보의 측정 소스가 수탁기관 단위로 집계되어 본인별로
쪼개지지 않는 것이 이 술어와 공시 사이의 어긋남이며, 구멍으로 등재되어 있다.

**기각한 대체 정의:**
권리를 금액 한도로 두는 안. 정의층이 금액을 직접 들지 않으므로 수 체계를 끌어오게 되고, 한도가
구속하는 자리는 커버리지 합이라 회계층이다. C-10 의 발동조건 문법으로 두는 안도 기각했다. 140%
규칙이 차변잔액 위의 교차곱 정수 부등식이라 문법에 들어맞지만, 권리 하나 때문에 매개변수 넷이
딸려 온다.

**이름이 「원천 담보」가 아닌 까닭.** 저자가 쓰는 원천 담보는 사슬의 머리이고 담보 속도의
분모다. 이 술어는 권리가 붙어 받은 제공 전량을 가르므로 그 분자의 거름망이며, 저자의 이름을
붙이면 읽는 사람이 분자와 분모를 거꾸로 받는다. 권리를 지닌 것과 그 권리를 이미 쓴 것과 아직
쓰지 않은 것 셋이 나란히 읽히도록 이름을 골랐다.
-/
-- DD:CF-742
def Pledge.carriesRehypothecationRight {Idx Asset : Type} (p : Pledge Idx Asset) : Bool :=
  p.rehypothecable

/--
사슬이 한 단계 이어지는가.

**대응 비형식 개념:** 앞 제공으로 담보를 받은 쪽이 그것을 다시 내놓은 것이 뒤 제공인가.

**이 정의가 배제하는 사례:**
E-08 의 연쇄 예시 네 단계 가운데 회전 2 가 거래 결제 인도여서 떠받치는 청구권이 없다. 매도로
소유권이 넘어간 자리이므로 이 술어가 그 단계를 사슬의 고리로 세지 않는다. 저자가 그 네 단계를
속도의 사례로 들었으므로, 속도의 분모와 분자가 같은 대상을 세는지가 미확인으로 남는다.

**기각한 대체 정의:**
이어짐을 담보물 색인이 같은 것으로 재는 안. 위 회전 2 에서 사슬이 끊긴다. 재담보에서 돌아오는
것은 그 물건이 아니라 등가물이므로 반환 청구권의 종류물로 재는 것이 실물에 맞다.

**당사자를 두 반환 청구권에서 읽는다.** 앞 제공의 수취자가 뒤 제공의 제공자인지를 본다.
-/
-- DD:CF-740
def Pledge.linksTo {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (p q : Pledge Idx Asset) : Bool :=
  decide ((S.assign p.returns).obligor = (S.assign q.returns).holder)
    && decide ((S.assign p.returns).currency = (S.assign q.returns).currency)

/--
한 시점의 담보 제공 집합.

**대응 비형식 개념:** 그 시점에 서 있는 담보 제공 전부. 색인과 배정으로 준다.

**이 정의가 배제하는 사례:**
같은 담보물이 여러 제공에 나타나는 것을 색인이 구별하므로 중복 계상이 구조에서 읽히는데, 그
중복이 적법한 재담보인지 점유 유일성이 깨진 사고인지를 이 구조가 가르지 않는다. 2014년 칭다오항
금속 금융이 뒤쪽이고 프라임브로커리지의 재담보가 앞쪽이다(Reuters 2014년 6월 보도).

**기각한 대체 정의:**
`Finset (Pledge ...)` 으로 두는 안. 담보물이 `Option` 필드를 품어 같음의 판정이 자산 타입에
매달리므로 색인 방식이 아니면 중복이 눌린다. `ClaimSet` 이 같은 사유로 색인을 쓰며 리포 안에서
관례가 갈리지 않는다.
-/
-- DD:CF-735
structure PledgeSet (PIdx Idx Asset : Type) where
  /-- 제공의 색인. -/
  index : Finset PIdx
  /-- 색인에서 제공으로의 배정. -/
  assign : PIdx → Pledge Idx Asset

/-- witness (A-3). `PledgeSet` 이 비어 있지 않음을 보인다. 색인이 빈 제공 집합. -/
-- DD:CF-31
def PledgeSet.trivial : PledgeSet Unit Unit Unit where
  index := ∅
  assign := fun _ => Pledge.trivial

/--
사슬이 주어진 단계 수 안에 이어지는가.

**대응 비형식 개념:** 한 제공에서 출발해 재제공을 거듭했을 때 다른 제공에 닿는가.

**이 정의가 배제하는 사례:**
단계 수를 밖에서 받으므로 그 값이 모자라면 닿는데도 거짓이 된다. 호출하는 쪽이 색인의 크기를
주는 것이 이 구조가 기대하는 쓰임이고, 그보다 작은 값을 주는 쓰임을 구조가 막지 않는다.

**기각한 대체 정의:**
단계 수 없이 전이 폐포를 직접 재는 안. 사슬에 순환이 설 수 있으므로 소박한 재귀가 종료하지
않고, 종료를 보이려면 방문 집합을 들고 다녀야 해서 정의가 판정 술어가 아니라 알고리즘이 된다.
색인을 `Finset.toList` 로 훑는 안도 기각했다. 핀된 Mathlib 에서 그 함수가 선택공리를 쓰는
`noncomputable` 정의라 몸이 계산 함수로 컴파일되지 않고, C-1 의 금지가 글자로 걸리기 전에
빌드가 먼저 거부한다. 색인을 `Finset.filter` 로 걸러 세는 안도 기각했다. 색인 타입에
`DecidableEq` 가 서명에 붙어 구조에 없던 제약이 는다.

**유한집합 위의 한정 존재를 `decide` 로 판정한다.** 그 인스턴스가 기준선을 넘지 않는 것이
실측됐고, C-3 이 요구하는 판정이 인스턴스 선언 없이 타입에서 나온다.

**순환을 금지하지 않는다.** 금지하면 당일 재담보가 배제되는데, 시점 인덱스가 자연수라 같은 시점
안의 순서를 구조가 줄 수 없다. 허용해도 색인이 유한하므로 C-3 에 걸리지 않는다.
-/
-- DD:CF-740
def PledgeSet.reachesWithin {PIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) : ℕ → PIdx → PIdx → Bool
  | 0, _, _ => false
  | n + 1, i, j =>
      (P.assign i).linksTo S (P.assign j)
        || decide (∃ k ∈ P.index,
             ((P.assign i).linksTo S (P.assign k) && P.reachesWithin S n k j) = true)

/--
그 제공에서 시작한 사슬이 자기로 돌아오는가.

**대응 비형식 개념:** 같은 담보가 돌고 돌아 처음 내놓은 자리로 다시 오는가.

**이 정의가 배제하는 사례:**
같은 시점 안에서 일어난 당일 재담보의 순서가 구조에 없으므로, 하루 안에서만 성립하는 순환과
시점을 건너는 순환이 이 술어에서 같아 보인다. 시점 인덱스가 자연수인 한 그 둘이 갈리지 않는다.

**기각한 대체 정의:**
순환을 구조로 금지하고 이 술어를 두지 않는 안. 금지하면 당일 재담보가 배제되고, 배제했다는
사실이 docstring 한 줄로 끝나 담보 속도의 분모가 서지 않는 자리가 드러나지 않는다.
-/
-- DD:CF-740
def PledgeSet.inCycle {PIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx) : Bool :=
  P.reachesWithin S P.index.card i i

/--
그 제공이 재담보된 담보인가.

**대응 비형식 개념:** 재담보 권리가 딸려 있고 실제로 다시 제공된 것.

**이 정의가 배제하는 사례:**
재무제표가 실제 재담보한 금액을 부외로 공시하는데 그 공시는 금액이고 이 술어는 제공 하나에
대한 판정이므로, 둘을 맞대려면 금액을 세는 자리가 따로 서야 한다. 그 총계는 담보 장부가 든다.

**기각한 대체 정의:**
다시 제공됐는지를 제공 자신의 필드로 두는 안. 사슬을 유도하기로 했으므로 그 필드가 사슬과
어긋날 수 있고, 어긋났을 때 어느 쪽이 참인지를 구조가 말하지 않는다. 색인을 `Finset.toList`
로 훑는 안도 기각했다. 그 함수가 핀된 판에서 `noncomputable` 이라 몸이 계산 함수로 서지 않는다.
-/
-- DD:CF-742
def PledgeSet.isRehypothecated {PIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx) : Bool :=
  (P.assign i).rehypothecable
    && decide (∃ k ∈ P.index, ((P.assign i).linksTo S (P.assign k)) = true)

/--
그 제공이 재담보 가능 담보인가.

**대응 비형식 개념:** 재담보 권리가 딸려 있으나 아직 다시 제공되지 않은 것.

**이 정의가 배제하는 사례:**
재무제표가 재담보 가능한 금액을 따로 공시하는데 그 값은 계약 한도이고 이 술어가 세는 것은
권리가 있고 아직 안 쓴 제공이다. 둘이 다른 대상이며 그 어긋남은 구멍으로 등재되어 있다.

**기각한 대체 정의:**
한도에서 이미 쓴 몫을 뺀 잔여로 두는 안. 한도가 구조에 없으므로 뺄 것이 없다.

**재담보된 담보와의 배타는 정의만으로 선다.** 이 술어가 앞 술어의 부정을 곱하기 때문이다.
원천 담보와는 배타가 아니다. 원천 담보가 출처의 축이고 이 둘이 상태의 축이라 겹친다.
-/
-- DD:CF-742
def PledgeSet.isRehypothecatable {PIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx) : Bool :=
  (P.assign i).rehypothecable && !(P.isRehypothecated S i)

/--
시점 인덱스를 갖는 담보 제공 집합 족 (L-13).

**대응 비형식 개념:** 시간에 따라 변하는 담보 제공의 집합.

**이 정의가 배제하는 사례:**
한 제공을 시간을 가로질러 추적할 수 없다. 레포가 롤오버될 때 실무는 같은 거래가 이어진 것으로
읽는데, 이 족은 옛 제공이 빠지고 새 제공이 드는 것으로만 그 사건을 담는다. `ClaimFamily` 가
같은 자리에서 같은 것을 배제한다.

**기각한 대체 정의:**
제공에 생애 구간을 필드로 두어 족을 쓰지 않는 안. 담보의 생애를 떠받치는 청구권에 묶지 않기로
했으므로 그 구간이 어디서 오는지가 서지 않고, 변동증거금처럼 오가는 제공이 구간 하나로 담기지
않는다.

**이 족을 무엇이 정하는지는 이 페이즈가 정하지 않는다.** `ClaimFamily` 와 `NodeFamily` 가 같은
자리에 있다.

**인덱스가 자연수인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-735
abbrev PledgeFamily (PIdx Idx Asset : Type) := ℕ → PledgeSet PIdx Idx Asset

/-- witness (A-3). `PledgeFamily` 가 비어 있지 않음을 보인다. 모든 시점에 같은 집합을 주는 족. -/
-- DD:CF-31
def PledgeFamily.constant {PIdx Idx Asset : Type}
    (P : PledgeSet PIdx Idx Asset) : PledgeFamily PIdx Idx Asset := fun _ => P

/--
그 제공이 사슬의 머리인가.

**대응 비형식 개념:** 어느 제공에서도 이어 들어오지 않은 담보 제공. 그 제공자가 그 종류물로
담보를 받은 적이 없으므로 그 담보가 사슬 밖에서 들어온 것이다. 담보 속도의 분모가 세는 대상이
이것이다.

**이 정의가 배제하는 사례:**
받기도 하고 내놓기도 하는 딜러가 자기 대차대조표로 대는 담보. 그 딜러는 받는 쪽이기도 하므로
이 술어가 거짓을 내고 그 담보가 분모에서 빠진다. Singh 2011 이 그 자리를 회전 계수가 무한인
것으로 보고 금액이 작아 결과에 영향이 없다고 적는데, 구조는 그 크기를 재는 수단을 갖지 않으므로
같은 근거로 넘길 수 없다.

**기각한 대체 정의:**
당사자의 종류로 가르는 안. 저자는 궁극 원천인 자산운용자에게서 채굴된 것을 분모로 두나, 노드를
의사결정 단위로 두고 기관유형을 관측 투영으로 보낸 결정이 서 있어 당사자의 종류가 정의층에 없다.
그 종류가 하는 일은 2차 보유분을 빼어 머리를 가리는 것이므로 측정 대리이지 정의가 아니며, 그
대리는 관측 명세가 받는다. 받은 것보다 더 내보낸 몫으로 재는 안도 기각했다. 저자의 분모는 급수의
0 차 항이고 그 몫은 당사자별 순유출이라 다른 대상이다.

**단계 수를 받지 않는다.** 머리인지는 한 걸음 안쪽만 보면 서므로 도달 판정이 필요하지 않다.
-/
-- DD:CF-804
def PledgeSet.isChainHead {PIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx) : Bool :=
  !decide (∃ k ∈ P.index, ((P.assign k).linksTo S (P.assign i)) = true)

end CrisisFramework.Definition
