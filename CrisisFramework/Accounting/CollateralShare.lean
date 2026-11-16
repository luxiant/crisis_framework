/-
회계층 — 제공별 몫과 조정 담보가치와 쓰지 않은 여력

규율: L-4(회계층에 `ℝ` 가 들어오면 위반), L-10·L-15(회계층의 기본 수 체계는 `ℤ`),
      L-12(통화 간 환산 금지와 통화 가드), L-9(import 방향은 단방향), A-3(witness 의무),
      D-1·D-2(docstring 3항목), D-5(오염 어간에 한정어를 붙인다), D-8(witness 의 서술),
      C-9(전면 `simp` 금지), T-2(반증 조건), T-3(기여 분류), T-6(존재 형태).

이 파일은 `ℤ` 만 쓴다. 평가율을 분자와 분모의 쌍으로 받고 판정에서 분모를 양변에 곱하므로 나눗셈을
쓰는 자리가 없고, 그래서 `ℚ` 가 강제되지 않는다.

**이 파일이 세우는 것은 제공 하나가 그 담보물에서 얼마를 요구하는가의 판정이다.** 정의층이 담보
제공을 담보물과 떠받치는 청구권과 반환 청구권의 묶음으로 세우고, 이 파일이 그 묶음마다 평가율을
붙여 조정 담보가치를 내고 요구 금액을 그것과 맞댄다. **그 자리가 서지 않아 그 진술을 쓸 수 없다는
것이 구멍으로 등재되어 있었다.**

**몫을 담보 제공의 필드로 넣지 않고 이 층의 판정으로 세운다.** 재담보 권리를 세운 선언의 기각
문단이 권리를 금액 한도로 두는 안을 배제하면서 그 사유로 정의층이 금액을 직접 들지 않는다는 것과
한도가 구속하는 자리가 커버리지 합이라 이 층의 일이라는 것을 들므로, 몫도 같은 자리에 선다.

**색인이 둘로 갈린다.** 평가율은 담보물에 붙고 요구 금액은 떠받치는 청구권에 붙는다. 담보 총계를
드는 선언들이 커버리지 합을 떠받치는 청구권의 통화로 세우고 제공 합을 담보의 종류물로 세운 것과
같은 가름이며, 이 파일의 판정은 그 둘을 한 표시로 묶을 수 없을 때 값을 내지 않는다.

**평가율로 두고 차감률로 두지 않는다.** 조문이 할인율을 적고 조정 담보가치를 담보가치에 100에서
할인율을 뺀 값을 곱해 100으로 나눈 것으로 적으므로, 차감률을 담으면 판정마다 그 뺄셈이 서고 분모가
100 으로 고정된다. 평가율로 두면 그 뺄셈이 한 번 서고 분모가 조문의 단위를 따른다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Algebra.BigOperators.Group.Finset.Defs
import CrisisFramework.Definition.Collateral
import CrisisFramework.Definition.Trigger

namespace CrisisFramework.Accounting

open CrisisFramework.Definition

/--
담보의 평가율.

**대응 비형식 개념:** 담보가치에 곱해 조정 담보가치를 내는 비율. 조문이 할인율로 적는 것의 여수이며,
분자와 분모의 쌍으로 받아 판정에서 분모를 양변에 곱해 나눗셈을 피한다.

**이 정의가 배제하는 사례:**
평가율이 담보의 범주와 잔존만기만으로 정해진다고 보는 정의. 중앙은행의 담보 정책을 읽은 기록이 담보의
통화가 대출의 통화와 다를 때 환율 변동을 감당하려고 가산을 더하고 통화마다 다시 더하며 포트폴리오의
집중도가 문턱을 넘으면 또 더한다고 적으므로, 격자가 그 비율을 다하지 않는다. 이 구조는 쌍만 들고 그
값이 어느 인자에서 왔는지를 들지 않으므로 그 가산이 선 자리도 담긴다(영란은행).
조달처: E-49 §11-5 「담보의 통화가 대출의 통화와 다를 때 환율 변동을 감당하려고 최소 6%p 를 더하고」

**기각한 대체 정의:**
차감률을 담고 판정마다 여수를 계산하는 안. 분모가 100 으로 고정되어 조문의 단위가 다른 자리에서
다시 환산이 서고, 그 환산이 정수 나눗셈이어서 버림이 생긴다. 격자를 생성자로 박는 안도 기각했다.
범주와 잔존만기의 격자가 발행자마다 다르고 시점에 따라 바뀌므로 한 발행자의 값만 담기며, 문턱을
생성자에 박지 않고 관할권을 색인으로 받는 포트폴리오 한도의 설계가 같은 사유로 섰다.
-/
-- DD:CF-3836
structure CollateralValuationRate where
  /-- 비율의 분자. -/
  num : ℤ
  /-- 비율의 분모. 영이면 판정이 자명하게 참이 되므로 조문의 단위를 그대로 받는다. -/
  den : ℤ
  deriving DecidableEq, Repr

/-- witness (A-3). **무엇을 증거하는가.** `CollateralValuationRate` 가 비어 있지 않다. 깎지
않는 평가율 하나를 든다. -/
-- DD:CF-3836
def CollateralValuationRate.full : CollateralValuationRate where
  num := 1
  den := 1

/--
담보물이 청구권일 때 그 청구권의 금액.

**대응 비형식 개념:** 담보가치. 담보물이 청구권이면 그 청구권의 금액 항을 평가한 값이고, 청구권이
아니면 이 구조에 값이 없다.

**이 정의가 배제하는 사례:**
담보물이면 값이 선다고 보는 읽기. 창고증권의 규범이 대체 가능 물건의 로트를 혼합할 수 있게 하므로
어느 로트가 그 증권의 담보물인지가 서지 않고, 그러면 그 물건의 값이 증권 단위로 서지 않는다. 담보물
판정 술어의 docstring 이 가리키는 것과 가리켜지는 것을 잇는 관계가 없다는 결손을 이미 적으며, 이
선언은 그 자리에서 값을 내지 않고 선택으로 비워 그 결손을 판정의 정의역에 남긴다(통일상법전).
조달처: E-47 §2-2 「대체 가능 물건의 서로 다른 로트는 혼합할 수 있다」

**기각한 대체 정의:**
값이 없는 자리에 영을 돌려주는 안. 영은 값이 없다는 것이 아니라 값이 영이라는 것이고, 그러면 몫의
판정이 자명하게 거짓으로 서서 결손이 판정으로 읽힌다. 담보물의 금액을 인자로 받는 안도 기각했다.
받으면 그 값의 출처가 구조에 없어 어디서 왔는지가 이 층에서 서지 않는다.
-/
-- DD:CF-3836
def pledgedClaimValue {Idx Asset Party Obs Ext Lvl Currency : Type}
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Pledge Idx Asset) : Option ℤ :=
  match p.pledged.asClaim with
  | some i => some (evalTerm e (S.assign i).amount)
  | none => none

/--
제공이 요구하는 금액.

**대응 비형식 개념:** 그 제공이 떠받치는 청구권이 드는 금액. 제공이 담보물에서 요구하는 몫의 분자
쪽이며, 평가율이 담보물에 붙는 것과 색인이 다르다.

**이 정의가 배제하는 사례:**
요구 금액이 반환 청구권에서 온다고 보는 읽기. 담보 제공 구조체가 떠받치는 청구권과 반환 청구권을
따로 들고 반환 청구권은 돌려줄 의무를 드는 자리이므로, 반환 쪽을 읽으면 담보가 떠받치는 노출이 아니라
담보 자신의 반환 의무가 세어진다. 증거금 규범을 읽은 기록이 그 둘이 서로 다른 것에 붙음을 든다.
조달처: E-43 §3-4 「부속서 둘이 서로 다른 것에 붙으므로」

**기각한 대체 정의:**
요구 금액을 평가한 값이 아니라 금액 항 자체로 두는 안. 항은 신호를 읽으므로 비교에 쓰려면 평가가
서야 하고, 평가를 판정으로 미루면 같은 항이 여러 판정에서 서로 다른 환경으로 평가될 수 있다.
-/
-- DD:CF-3836
def pledgeDemandValue {Idx Asset Party Obs Ext Lvl Currency : Type}
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Pledge Idx Asset) : ℤ :=
  evalTerm e (S.assign p.secures).amount

/--
그 제공의 요구 금액이 조정 담보가치 안에 드는가.

**대응 비형식 개념:** 한 제공이 요구하는 몫이 그 담보물의 평가된 값을 넘지 않는가. 분모를 양변에
곱한 정수 부등식으로 쓰므로 나눗셈이 서지 않는다.

**이 정의가 배제하는 사례:**
표시가 다른 두 청구권을 한 부등식에 두는 읽기. 담보의 표시가 떠받치는 청구권의 표시와 다를 때 그
비교는 환산을 요구하고 L-12 가 이 층에서 그것을 막으므로, 이 선언은 그 자리에서 참도 거짓도 내지
않고 값을 비운다. 담보가 외화이고 노출이 자국통화인 자리가 중앙은행의 담보 정책에서 가산의 인자로
서므로 그 배치가 실재한다(영란은행).
조달처: E-49 §11-5 「미국 달러 레포 제도와 유로 유동성 제도에서 통화 불일치의 규모가 문턱을 넘으면」

**기각한 대체 정의:**
표시가 다를 때 거짓을 돌려주는 안. 거짓은 몫이 넘친다는 것이고 표시가 다른 것은 재어지지 않는다는
것이라 뜻이 다르며, 그러면 환산 금지가 제약 위반으로 읽힌다. 표시를 인자로 받아 양쪽에 같은 값을
요구하는 안도 기각했다. 그 인자가 두 청구권의 표시와 어긋나도 판정이 서므로 가드가 헐거워진다.
-/
-- DD:CF-3836
def pledgeShareCovered {Idx Asset Party Obs Ext Lvl Currency : Type}
    [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Pledge Idx Asset) (r : CollateralValuationRate) : Option Bool :=
  match p.pledged.asClaim with
  | some i =>
      if (S.assign i).currency = (S.assign p.secures).currency then
        some (decide (r.den * pledgeDemandValue e S p
                        ≤ r.num * evalTerm e (S.assign i).amount))
      else none
  | none => none

/--
한 담보물에 걸린 요구 금액의 총계.

**대응 비형식 개념:** 그 담보물이 이미 떠받치고 있는 노출의 합. 쓰지 않은 여력의 분모 쪽이며, 같은
담보물을 드는 제공이 여럿일 때 그 합이 여력을 깎는다.

**이 정의가 배제하는 사례:**
표시를 가로질러 더하는 읽기. 같은 종류물을 담보로 받은 제공들이 서로 다른 표시의 노출을 떠받칠 수
있고 그 합은 환산을 요구하므로, 이 선언은 담보의 종류물과 노출의 표시를 둘 다 가드로 받아 한 표시
안에서만 더한다. 통화 축이 대칭적 색인이 아니라는 확정 결정이 같은 자리에 선다.
조달처: E-49 §11-5 「최대 단일 채권의 시장가치가 인도된 회사채 전체 시장가치의 2%를 넘으면」

**기각한 대체 정의:**
담보의 종류물만 가드로 받는 안. 노출의 표시가 섞여 그 합이 통화를 가로지른 합이 된다. 노출의 표시만
받는 안도 기각했다. 서로 다른 담보물에 걸린 요구가 한 합으로 서서 여력이 담보물마다 서지 않는다.
-/
-- DD:CF-3836
def collateralDemandTotal {PIdx Idx Asset Party Obs Ext Lvl Currency : Type}
    [DecidableEq Asset] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (k : Asset) (c : Currency) : ℤ :=
  ∑ i ∈ P.index,
    (if (P.assign i).pledged.asset = k
          ∧ (S.assign (P.assign i).secures).currency = c
     then pledgeDemandValue e S (P.assign i) else 0)

/--
그 담보물에 남은 여력.

**대응 비형식 개념:** 평가율이 허용하는 몫에서 이미 쓴 몫을 뺀 것. 저장하지 않고 두 교차곱의 차이로
유도하므로 구조에 칸이 서지 않는다.

**이 정의가 배제하는 사례:**
여력을 구조에 저장하는 읽기. 증거금 규범을 읽은 기록이 재담보 권리의 조건 가운데 범위를 좁히는 것과
권리의 발생에 행위를 요구하는 것을 가르므로 쓸 수 있는 몫이 조건마다 달라지며, 그 값을 구조에 저장하면
저장된 수가 그 조건과 어긋난 채 남는다. 재담보 권리를 세운 선언의 이름 문단이 권리를 지닌 것과 이미 쓴
것과 아직 쓰지 않은 것 셋을 나란히 두었고, 마지막은 앞의 둘에서 유도되는 값이다(바젤은행감독위원회·
국제증권감독기구).
조달처: E-43 §4-3 「규범의 열두 조건 가운데 분리보관과 1회 한정은 권리의 범위를 좁히고」

**기각한 대체 정의:**
여력을 참거짓으로만 내는 안. 남은 몫의 크기를 묻는 진술이 그 값으로는 답해지지 않으며, 이 자리가 받는
구멍의 재개 트리거가 그 크기를 요구하는 진술을 명시적으로 든다. 담보물의 값을 더해 총계로 두는 안도
기각했다. 담보물마다 평가율이 다르므로 그 합이 제공마다 다른 비율을 품는다.
-/
-- DD:CF-3836
def collateralHeadroom {PIdx Idx Asset Party Obs Ext Lvl Currency : Type}
    [DecidableEq Asset] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (p : Pledge Idx Asset)
    (r : CollateralValuationRate) (c : Currency) : Option ℤ :=
  match p.pledged.asClaim with
  | some i =>
      if (S.assign i).currency = c then
        some (r.num * evalTerm e (S.assign i).amount
                - r.den * collateralDemandTotal e S P p.pledged.asset c)
      else none
  | none => none

/--
담보물이 청구권이 아니면 몫의 판정이 값을 내지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
담보물이 청구권이 아닌 제공에서 몫의 판정이 참이나 거짓을 내야 한다. 그 관측은 이 층이 청구권 아닌
담보물의 값을 어디선가 읽는다는 뜻이며, 그러면 외부 자산의 값이 구조에 선다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 판정의 정의를 전개하면 선택 분기로 닫히므로 기여 목록에서 제외한다.
-/
-- DD:CF-3836
theorem pledge_share_undefined_without_claim
    {Idx Asset Party Obs Ext Lvl Currency : Type} [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Pledge Idx Asset) (r : CollateralValuationRate)
    (h : p.pledged.asClaim = none) :
    pledgeShareCovered e S p r = none := by
  unfold pledgeShareCovered
  rw [h]

/--
그 담보물에 걸린 요구가 이 제공 하나뿐이면 여력이 음이 아닌 것과 몫이 덮이는 것이 같다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
요구가 하나뿐인 담보물에서 여력이 음이 아니면서 몫이 덮이지 않거나 그 반대가 되어야 한다. 그 관측은
여력의 유도가 몫의 판정과 다른 부등식을 쓴다는 뜻이며, 그러면 유도가 저장을 갈음하지 못한다.

**가정과 그 배제 사례(T-4·T-5):** 그 담보물에 걸린 요구의 총계가 이 제공의 요구와 같다는 것과 담보의
표시가 노출의 표시와 같다는 것을 진술문의 인자로 둔다. 앞을 빼면 같은 담보물에 제공이 둘 걸린 배치에서
거짓이고, 뒤를 빼면 두 판정이 값을 내지 않는 자리가 서로 다르다. 이 진술이 배제하는 것은 같은 담보물에
요구가 여럿 걸린 배치다.

**T-3 분류:** 보조 보정이 아니다. 여력을 저장하지 않고 유도하기로 한 설계의 효력을 이 명제가 들며,
유도가 몫의 판정과 같은 부등식을 쓴다는 것이 그 설계의 요건이다.
-/
-- DD:CF-3836
theorem headroom_nonneg_iff_covered
    {PIdx Idx Asset Party Obs Ext Lvl Currency : Type}
    [DecidableEq Asset] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (P : PledgeSet PIdx Idx Asset) (p : Pledge Idx Asset)
    (r : CollateralValuationRate) (i : Idx) (c : Currency)
    (hc : p.pledged.asClaim = some i)
    (hk : (S.assign i).currency = c)
    (hs : (S.assign p.secures).currency = c)
    (ht : collateralDemandTotal e S P p.pledged.asset c = pledgeDemandValue e S p) :
    collateralHeadroom e S P p r c = some (r.num * evalTerm e (S.assign i).amount
        - r.den * pledgeDemandValue e S p)
      ∧ pledgeShareCovered e S p r
          = some (decide (r.den * pledgeDemandValue e S p
                            ≤ r.num * evalTerm e (S.assign i).amount)) := by
  refine ⟨?_, ?_⟩
  · unfold collateralHeadroom
    rw [hc]
    show (if (S.assign i).currency = c then _ else none) = _
    rw [if_pos hk, ht]
  · unfold pledgeShareCovered
    rw [hc]
    show (if (S.assign i).currency = (S.assign p.secures).currency then _ else none) = _
    rw [if_pos (hk.trans hs.symm)]

/--
같은 담보물에 제공이 둘 걸리면 둘 다 덮이면서 여력이 음인 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
제공마다 몫이 덮이면 그 담보물의 여력이 늘 음이 아니어야 한다. 그 관측은 제공별 판정이 담보물 수준의
제약을 함의한다는 뜻이며, 그러면 여력을 따로 유도할 까닭이 없다.

**존재 형태로 진술하는 까닭(T-6):** 담보물 수준의 제약이 개별 제공의 판정을 정하지 않으므로 전칭으로
세우면 거짓이다. 어느 배치에서 그 어긋남이 서는가가 이 진술이 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이 아니다. 제공별 판정과 담보물별 여력을 둘 다 세운 설계의 까닭을 이 명제가
들며, 하나가 다른 하나를 갈음하지 않는다는 것이 그 까닭이다.
-/
-- DD:CF-3836
theorem per_pledge_cover_does_not_bound_headroom :
    ∃ (r : CollateralValuationRate) (v d : ℤ),
      r.den * d ≤ r.num * v ∧ r.num * v - r.den * (d + d) < 0 := by
  exact ⟨CollateralValuationRate.full, 1, 1, by decide, by decide⟩

end CrisisFramework.Accounting
