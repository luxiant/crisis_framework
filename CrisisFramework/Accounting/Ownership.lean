/-
회계층 — 외부 자산의 소유 장부

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(색인을 갈라 두고 환산하지 않는다),
      C-9(전면 `simp` 금지), A-6(기준선 차분), T-2(반증 조건), T-4(가정의 명시).

**수 체계: `ℤ`.** 정의층의 `AssetShare` 가 수 체계를 매개변수로 받으므로 이 파일이 그 자리에
`ℤ` 를 넣는다. 몫은 스케일된 정수이며 완전 배분의 단위도 정수다.

**세는 단위가 담보 장부와 다르다.** 담보 장부는 반환 청구권이 드는 금액을 세고 이 파일은 외부
자산의 몫을 센다. 색인이 갈리므로 두 총계를 한 식에 두지 않는다.

**중복이 두 합의 비교로 선다.** 내놓은 몫의 합이 보유 몫의 합을 넘는 것이 중복이며, 담보물의 같음
판정을 세우지 않고도 그 비교가 서는 것이 이 층의 산출이다.

**개수가 여기서 선다.** 제공의 수가 자연수이며 정의층이 시점 인덱스 밖의 자연수를 쓰지 못하므로
(L-10) 그 셈이 이 층의 몫이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Algebra.Order.BigOperators.Group.Finset
import CrisisFramework.Definition.Ownership

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
그 자산에 선 보유 몫의 합.

**대응 비형식 개념:** 하나의 외부 자산을 두고 담보로 내놓지 않은 채 기록된 몫을 모은 값. 완전
배분이고 아무도 내놓지 않았으면 단위와 같다.

**이 정의가 배제하는 사례:**
거래소가 등록 창고 안의 재고는 등록분과 등록되지 않은 보관분을 모두 공표하되 거래소에 등록된
창고의 밖은 범위에 두지 않으므로(LME 2025년 4월 공표분), 이 합이 모으는 몫 가운데 공시로
확인되는 것과 확인되지 않는 것이 한 값에 섞인다. 2014년 칭다오항의 금속이 보세창고에 있었으므로
중복 계상의 정본 사례가 바로 확인되지 않는 쪽이다.

**기각한 대체 정의:**
몫에 평가율을 곱한 값을 더하는 안. 합이 자산마다 다른 비율을 품어 공통분모가 필요해지며, 담보
장부가 총계를 평가 전 값으로 둔 것과 같은 사유다. 자산을 가르지 않고 전량을 더하는 안도
기각했다. 서로 다른 자산의 몫을 더하면 단위가 섞여 완전 배분과 맞댈 상대가 사라진다.

**음수를 거르지 않는다.** 공매도가 음의 몫으로 나타나므로 거르면 그 포지션이 합에서 사라진다.
그래서 이 합은 순액이며, 총액으로 보려면 부호별로 따로 모아야 한다. 그 분리는 이 페이즈가
세우지 않는다.
-/
-- DD:CF-975
def heldShareTotalOn {SIdx Asset Party PIdx : Type} [DecidableEq Asset]
    (H : ShareSet SIdx Asset Party PIdx ℤ) (a : Asset) : ℤ :=
  ∑ i ∈ H.index,
    (if (H.assign i).asset = a ∧ (H.assign i).kind = ShareKind.held
     then (H.assign i).share else 0)

/--
그 자산에 선 제공된 몫의 합.

**대응 비형식 개념:** 하나의 외부 자산을 두고 담보로 내놓아 기록된 몫을 모은 값.

**이 정의가 배제하는 사례:**
소유권을 넘기는 구조로 금융한 재고. 그 재고가 장부에서 제거되므로 담보로 제공된 재고자산의
공시에 들지 않고, 2014년 칭다오항 금융의 상당 부분이 그 구조였다(IAS 2 제36조 (h)와
Minko 2016 §2.4). 같은 경제적 실질이 회계 분류 하나로 이 합에서 사라진다.

**기각한 대체 정의:**
묶인 제공의 색인마다 따로 모으는 안. 제공별 총계는 그 제공이 요구하는 몫 하나이므로 합이 될
것이 없고, 자산 단위로 모아야 보유 몫과 맞댈 상대가 선다. 제공의 실재를 확인하고 모으는 안도
기각했다. 제공 집합을 인자로 더 받아야 하며, 낡은 지목을 거르는 일은 그 정합을 따로 판정하는
자리의 몫이다.

**색인이 보유 몫과 같다.** 둘이 한 집합에 살고 종류로만 갈리므로 두 합이 같은 단위로 서고 한
부등식에 들어간다. L-12 가 막는 환산이 일어나지 않는다.
-/
-- DD:CF-975
def pledgedShareTotalOn {SIdx Asset Party PIdx : Type} [DecidableEq Asset]
    (H : ShareSet SIdx Asset Party PIdx ℤ) (a : Asset) : ℤ :=
  ∑ i ∈ H.index,
    (if (H.assign i).asset = a ∧ (H.assign i).kind = ShareKind.pledged
     then (H.assign i).share else 0)

/--
그 자산을 가리키는 외부 자산 제공의 수.

**대응 비형식 개념:** 하나의 외부 자산이 그 시점에 몇 개의 차입을 떠받치고 있는가.

**이 정의가 배제하는 사례:**
제공마다 얼마를 요구하는지. 이 수는 제공을 하나씩 세고 그 크기를 세지 않으므로, 2014년 칭다오항
에서 담보물의 가치가 약 3억 8천만 달러인데 얻은 금융이 약 42억 달러였던 그 배수를 내지 못한다
(Minko 2016 §2.5). 크기는 몫의 두 합이 든다.

**기각한 대체 정의:**
청구권인 담보물까지 함께 세는 안. 담보물이 청구권이면 청구권 집합의 색인으로 제공들을 묶을 수
있어 담보 장부의 세 총계가 이미 그 자리를 덮는다. 제공의 색인을 세지 않고 떠받치는 청구권의
색인을 세는 안도 기각했다. 한 제공이 청구권 하나를 떠받치므로 같은 수가 나오나, 떠받치는
청구권이 같은 제공 둘이 설 수 있어 그때 두 수가 갈린다.

**이 수가 중복의 판정에 들지 않는다.** 판정은 두 합의 비교가 들고 이 수는 그 자리의 규모를
따로 드는 관측이다. 칭다오항에서 은행 스물다섯이 걸린 것이 그 규모다.
-/
-- DD:CF-975
def pledgeCountOn {PIdx Idx Asset : Type} [DecidableEq Asset]
    (P : PledgeSet PIdx Idx Asset) (a : Asset) : ℕ :=
  (P.index.filter (fun i =>
    (P.assign i).pledged.asset = a ∧ (P.assign i).pledged.asClaim.isNone = true)).card

/--
그 자산에 선 제공된 몫의 합이 보유 몫의 합을 넘는 배치가 존재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 어떤 몫 집합에서도 내놓은 몫의 합이 보유 몫의
합을 넘지 못하는 것. 그러려면 내놓는 일이 보유를 줄이는 것과 한 조작으로 묶여야 하는데, 구조가
두 종류를 한 집합의 독립한 항으로 두므로 그런 강제가 없다. 2014년 칭다오항에서 담보물의 가치가
약 3억 8천만 달러인데 얻은 금융이 약 42억 달러였던 것이 실제로 관측된 반례다(Minko 2016 §2.5).

**가정과 그 배제 사례(T-4·T-5):** 가정을 두지 않는다. 존재 진술이므로 배치 하나를 세우면 서고,
그 배치가 현실에서 일어났다는 것은 위의 사례가 든다. 다만 **이 진술은 그런 배치가 가능하다는
것만 들고 그것이 위법이라는 것은 들지 않는다.** 대체 가능 물건에서는 초과 발행된 증권도 권리를
주고 권리자들이 공유하므로(UCC 제7-402조와 제7-207조), 내놓은 몫이 보유를 넘는 상태가 법적으로
성립한다.

**이 진술이 중복 계상의 형식적 표현이다.** 담보물의 같음 판정을 세우지 않고 몫의 두 합으로 재므로,
PH-R8 이 외부 자산에서 같음 판정이 서지 않는다고 적은 자리를 지나간다.
-/
-- DD:CF-976
theorem exists_pledgedShareTotalOn_gt_heldShareTotalOn :
    ∃ (H : ShareSet ℕ Unit Unit Unit ℤ) (a : Unit),
      heldShareTotalOn H a < pledgedShareTotalOn H a := by
  -- 증인은 한 자산에 보유 몫 하나와 제공된 몫 둘을 둔 집합이다. 보유의 합이 1 이고 제공된 몫의
  -- 합이 2 이므로 뒤가 앞을 넘는다. 색인이 유한하고 몫이 전부 계산되는 값이므로 두 합이 커널
  -- 평가로 닫히며, `Finset` 합의 부등식 보조정리를 하나도 부르지 않는다. 기준선을 넘기는 셋이
  -- `docs/baseline.md` §2-2 에 있어 그 길을 피했고, 전면 `simp` 도 쓰지 않는다(C-9).
  refine ⟨{ index := {0, 1, 2}
            assign := fun i =>
              if i = 0 then
                { asset := (), holder := (), share := 1
                  kind := ShareKind.held, pledge := none }
              else
                { asset := (), holder := (), share := 1
                  kind := ShareKind.pledged, pledge := some () } },
          (), ?_⟩
  decide

/--
같은 자산에 제공이 둘 이상 서 있으면서 내놓은 몫의 합이 보유 몫의 합을 넘지 않는 배치가
존재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 하나의 외부 자산에 제공이 둘 이상 선 모든
배치에서 내놓은 몫의 합이 보유 몫의 합을 넘는 것. 그러려면 자산을 나누어 여럿에게 맡기는 일이
구조상 불가능해야 하는데, 대체 가능 물건이 혼합되면 권리자들이 공유하므로(UCC 제7-207조) 그
배치가 정상이다.

**가정과 그 배제 사례(T-4·T-5):** 가정을 두지 않는다. 존재 진술이다.

**이 진술이 앞 진술과 짝을 이룬다.** 제공이 둘 이상이라는 것만으로는 중복이 아니며, 자산을 절반씩
나누어 맡긴 적법한 배치가 그 자리에 든다. **제공의 수를 세어 중복을 재면 그 배치가 중복으로
오판되고,** 두 합의 비교가 그 오판을 막는다. 그것이 몫을 담는 값이다.
-/
-- DD:CF-976
theorem exists_multiplePledges_and_pledgedShareTotalOn_le_heldShareTotalOn :
    ∃ (P : PledgeSet ℕ Unit Unit) (H : ShareSet ℕ Unit Unit ℕ ℤ) (a : Unit),
      P.hasMultiplePledgesOn a = true
        ∧ pledgedShareTotalOn H a ≤ heldShareTotalOn H a := by
  -- 증인은 자산을 절반씩 나누어 둘에게 맡긴 적법한 배치다. 제공 색인 둘이 같은 자산을 가리키고
  -- 담보물의 `asClaim` 이 없으므로 앞 항이 서며, 몫은 보유 2 에 제공된 몫 1 과 1 이어서 뒤 항이
  -- 등호로 선다. 두 집합의 색인 타입이 갈려도 무방하다는 것을 별지가 적었고, 여기서는 제공 색인을
  -- 자연수로 두어 몫이 제공을 지목한다. 두 판정이 커널 평가로 닫히고 전면 `simp` 를 쓰지 않는다.
  refine ⟨{ index := {0, 1}
            assign := fun _ =>
              { pledged := { asset := (), asClaim := none }
                secures := (), returns := (), rehypothecable := false } },
          { index := {0, 1, 2}
            assign := fun i =>
              if i = 0 then
                { asset := (), holder := (), share := 2
                  kind := ShareKind.held, pledge := none }
              else
                { asset := (), holder := (), share := 1
                  kind := ShareKind.pledged, pledge := some i } },
          (), ?_, ?_⟩
  · decide
  · decide

end CrisisFramework.Accounting
