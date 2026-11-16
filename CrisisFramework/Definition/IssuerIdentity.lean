/-
정의층 — 제공자와 담보물 발행자의 동일성

규율: L-10(정의층은 무차원이고 시점 인덱스만 `ℕ` 이다), L-13(정의층 대상은 시점 인덱스를 갖는
      족이다), L-9(import 방향은 단방향), A-3(witness 의무), D-1·D-2(docstring 3항목),
      D-3(배제 사례는 실제 역사 사례다), D-7(성질을 갖는 정의는 용어집에 선행 등록된다),
      C-3(판정 술어는 `Decidable` 을 갖는다), T-2(반증 조건), T-3(기여 분류), T-6(존재 형태).

**이 파일이 세우는 것은 담보물의 발행자가 그 제공자 자신인가의 판정이다.** 중앙은행의 담보 정책이
참가자가 조성한 자산을 담은 증권의 등급을 한 칸 내리면서 그 판정을 발행 구조에 걸고, 형식층에 그
구조가 없다는 것이 구멍으로 등재되어 있었다.

**색인이 둘로 갈린다.** 제공자는 반환 청구권의 권리자에서 읽고 발행자는 담보물이 청구권일 때 그
청구권의 의무자에서 읽는다. 사슬의 이어짐을 두 반환 청구권에서 읽는 선언과 같은 가름이며, 떠받치는
청구권은 이 판정에 들지 않는다.

**담보물이 청구권이 아니면 값을 내지 않는다.** 담보물 구조체가 청구권인지를 선택으로 들므로 그
자리에서 발행자가 서지 않고, 영이나 거짓으로 채우면 결손이 판정으로 읽힌다.

**이 파일이 담지 못하는 것을 한 자리에 적는다.** 그 정책이 묻는 것은 담보물 자신의 발행자가 아니라
그 담보물이 담은 기초자산의 조성자인데, 담보물 구조체는 그 자산이 청구권인지와 그 색인만 들고 그
청구권이 다시 무엇을 담는지를 들지 않는다. **그 결손은 구멍으로 등재되며 이 파일이 메우지 않는다.**
담보물 판정 술어의 docstring 이 가리키는 것과 가리켜지는 것을 잇는 관계가 없다는 같은 결손을 이미
적었고, 이 자리가 그 결손의 둘째 사례다.

**수를 쓰지 않는다.** 등급이 한 칸 내려간다는 것은 순서의 이동이고 그것을 이 파일이 담지 않는다.
담보의 등급이 이 구조에 서지 않으며 그 이동을 담으려면 등급의 공역이 먼저 서야 한다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.Collateral

namespace CrisisFramework.Definition

/--
그 제공의 제공자.

**대응 비형식 개념:** 담보를 내놓은 당사자. 반환 청구권의 권리자이며, 돌려받을 권리를 가진 쪽이
내놓은 쪽이라는 것이 그 읽기의 근거다.

**이 정의가 배제하는 사례:**
제공자를 거래 단위로 읽는 안. 증거금 규범이 개시증거금을 양쪽이 서로 내게 하고 각자가 받은 것을
상계하지 못하게 하므로 한 거래에 제공자가 둘이고, 거래 단위로 읽으면 그 둘이 한 당사자로 접힌다.
제공을 둘로 두면 각 제공의 제공자가 서로 다르게 선다(바젤은행감독위원회·국제증권감독기구).
조달처: E-43 §4-3 「규범은 개시증거금을 양쪽이 서로 내게 하고 각자가 받은 것을 상계하지 못하게 한다」

**기각한 대체 정의:**
제공자를 떠받치는 청구권의 의무자로 읽는 안. 떠받치는 청구권의 의무자는 담보를 받는 쪽일 수도 있고
제3자일 수도 있으므로 그 자리가 제공자를 정하지 않는다. 담보물의 의무자로 읽는 안도 기각했다. 그것은
담보물의 발행자이고 이 선언이 가르려는 것이 바로 그 둘의 다름이다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3837
def Pledge.provider {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (p : Pledge Idx Asset) : Party :=
  (S.assign p.returns).holder

/--
담보물이 청구권일 때 그 청구권의 의무자.

**대응 비형식 개념:** 담보물의 발행자. 담보물이 청구권이면 그 청구권의 의무를 지는 당사자이고,
청구권이 아니면 이 구조에 발행자가 없다.

**이 정의가 배제하는 사례:**
담보물의 발행자가 그 담보물이 담은 자산의 조성자와 같다고 보는 읽기. 중앙은행의 담보 정책이 기초자산에
조건을 따로 걸어 그것이 현금이어야 하고 합성이어서는 안 된다고 적으므로 기초자산이 담보물 자신과 다른
것이며, 그러면 발행자와 조성자가 서로 다른 당사자일 수 있다(영란은행).
조달처: E-49 §2-9 「기초자산은 현금이어야 하고 합성이어서는 안 된다」

**기각한 대체 정의:**
청구권이 아닌 담보물에 발행자를 인자로 받아 채우는 안. 받으면 그 값의 출처가 구조에 없어 어디서 왔는지가
이 층에서 서지 않고, 창고증권이 가리키는 물건의 발행자가 누구인지는 애초에 서지 않는다. 그 자리를
제공자로 채우는 안도 기각했다. 그러면 모든 외부 자산 담보가 자기 발행으로 판정된다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3837
def Pledge.pledgedIssuer {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (p : Pledge Idx Asset) : Option Party :=
  match p.pledged.asClaim with
  | some i => some (S.assign i).obligor
  | none => none

/--
그 담보물의 발행자가 그 제공자 자신인가.

**대응 비형식 개념:** 자기 담보화. 내놓은 쪽이 그 담보물의 의무를 지는 쪽과 같은 배치이며, 중앙은행의
담보 정책이 그 배치의 등급을 한 칸 내린다.

**이 정의가 배제하는 사례:**
그 판정이 증권의 성질이라고 보는 읽기. 같은 증권이 누가 들고 있는지에 따라 다른 등급을 받으므로 그
판정이 증권마다 서지 않고 제공마다 서며, 증권 단위로 읽으면 한 발행자의 증권을 다른 당사자가 내놓은
자리까지 등급이 내려간다(영란은행).
조달처: E-49 §3-4 「같은 증권이 누가 들고 있는지에 따라 다른 등급을 받는다」

**기각한 대체 정의:**
담보물이 청구권이 아닐 때 거짓을 돌려주는 안. 거짓은 자기 발행이 아니라는 것이고 청구권이 아닌 것은
재어지지 않는다는 것이라 뜻이 다르며, 그러면 외부 자산 담보가 전량 자기 발행이 아닌 것으로 세어진다.
제공자와 발행자의 쌍을 돌려주는 안도 기각했다. 쌍은 판정이 아니라 재료이고 그 비교를 쓰는 쪽마다 다시
세우게 된다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3837
def Pledge.isSelfIssued {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (p : Pledge Idx Asset) : Option Bool :=
  match p.pledged.asClaim with
  | some i => some (decide ((S.assign i).obligor = Pledge.provider S p))
  | none => none

/--
담보물이 청구권이 아니면 자기 발행 판정이 값을 내지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
담보물이 청구권이 아닌 제공에서 자기 발행 판정이 참이나 거짓을 내야 한다. 그 관측은 이 층이 청구권
아닌 담보물의 발행자를 어디선가 읽는다는 뜻이며, 그러면 외부 자산의 발행 구조가 구조에 선다.

**가정과 그 배제 사례(T-4·T-5):** 담보물이 청구권이 아니라는 것을 진술문의 인자로 둔다. 빼면 담보물이
청구권인 제공에서 거짓이며 그 자리에서 판정이 값을 낸다. 이 진술이 배제하는 것은 담보물이 청구권인
배치다.

**T-3 분류:** 보조 보정이다. 판정의 정의를 전개하면 선택 분기로 닫히므로 기여 목록에서 제외한다.
-/
-- DD:CF-3837
theorem self_issue_undefined_without_claim
    {Idx Asset Party Num Obs Ext Lvl Currency : Type} [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (p : Pledge Idx Asset)
    (h : p.pledged.asClaim = none) :
    Pledge.isSelfIssued S p = none := by
  unfold Pledge.isSelfIssued
  rw [h]

/--
같은 담보물을 내놓은 두 제공이 서로 다른 자기 발행 판정을 받는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
같은 담보물을 드는 두 제공이 늘 같은 판정을 받아야 한다. 그 관측은 그 판정이 증권의 성질이라는 뜻이며,
그러면 등급의 이동을 증권 단위로 공시할 수 있고 제공마다 다시 재지 않아도 된다.

**가정과 그 배제 사례(T-4·T-5):** 두 제공의 담보물이 같다는 것과 그 담보물이 청구권이라는 것과 두 반환
청구권의 권리자가 다르다는 것과 그 담보물의 의무자가 앞 제공의 제공자와 같다는 것을 진술문의 인자로
둔다. 담보물이 같다는 것을 빼면 두 판정이 서로 다른 담보물을 읽어 이 진술이 뜻을 잃고, 권리자가 다르다는
것을 빼면 두 판정이 같아 거짓이다. 이 진술이 배제하는 것은 한 당사자가 두 제공을 다 내놓은 배치다.

**T-3 분류:** 보조 보정이 아니다. 자기 발행을 증권의 성질로 두지 않고 제공의 성질로 둔 설계의 효력을
이 명제가 들며, 그 판정이 제공마다 갈린다는 것이 그 설계의 요건이다.
-/
-- DD:CF-3837
theorem self_issue_varies_with_provider
    {Idx Asset Party Num Obs Ext Lvl Currency : Type} [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (p q : Pledge Idx Asset) (i : Idx)
    (hp : p.pledged.asClaim = some i)
    (hq : q.pledged = p.pledged)
    (hne : Pledge.provider S q ≠ Pledge.provider S p)
    (heq : (S.assign i).obligor = Pledge.provider S p) :
    Pledge.isSelfIssued S p = some true ∧ Pledge.isSelfIssued S q = some false := by
  have hq' : q.pledged.asClaim = some i := by rw [hq, hp]
  refine ⟨?_, ?_⟩
  · unfold Pledge.isSelfIssued
    rw [hp]
    exact congrArg some (decide_eq_true heq)
  · unfold Pledge.isSelfIssued
    rw [hq']
    exact congrArg some (decide_eq_false (fun h => hne (h.symm.trans heq)))

end CrisisFramework.Definition
