/-
정의층 — 담보물의 점유와 끊김의 두 경로

규율: L-10(정의층은 무차원이고 시점 인덱스만 `ℕ`), L-13(정의층 대상은 시점 인덱스를 갖는 족이다),
      L-9(import 방향은 단방향), A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 의 서술),
      C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지), T-2(반증 조건), T-3(기여 분류),
      T-6(존재 형태).

**이 파일이 세우는 것은 담보 사슬의 고리가 끊기는 자리의 정의역이다.** 앞 페이즈가 끊김을 제3자의
처분 하나로 세웠고, 그 술어가 내놓는 쪽이 그 제공의 두 당사자가 아닐 것을 요구해 담보권을 설정한 자가
스스로 파는 경로를 조건으로 배제한다. 성문 규범이 그 경로를 따로 들고 요건을 달리 세우므로 그 경로가
구조에 없다는 것이 구멍으로 등재되어 있었다.

**점유를 사건이 아니라 상태로 둔다.** 담보권자의 점유와 매수인의 점유가 서로 다른 당사자를 보고 서로
다른 자리에서 끊김을 가르므로, 한 사건의 필드로는 두 방향이 담기지 않는다.

**기존 끊김 술어를 고치지 않는다.** 그 술어를 딛는 정리 다섯과 관측층 채널이 함께 움직이고 앞 페이즈가
세운 진술의 뜻이 소급해 바뀌므로, 새 술어를 세우고 두 술어의 관계를 정리로 든다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.OutrightDelivery
import CrisisFramework.Definition.IssuerIdentity

namespace CrisisFramework.Definition

/--
한 시점의 담보물 점유 상태.

**대응 비형식 개념:** 그 물건을 누가 쥐고 있는가. 소유도 권리도 아니고 사실상의 지배이며, 성문
규범이 담보권의 완성과 매수인의 자격을 이 상태에 걸어 둔다.

**이 정의가 배제하는 사례:**
담보권자가 물건을 쥐고 있는데도 통상의 영업 과정 매수인이 그 담보권을 끊는다고 보는 읽기. 담보권의
처분 뒤 존속을 다룬 규범이 담보권자가 물건을 점유하면 그 담보권이 매수인 조항의 영향을 받지 않는다고
적으므로, 점유의 자리가 없으면 그 배치와 담보물이 설정자의 손에 있는 배치가 한 꼴로 선다
(Uniform Commercial Code 제9-320조 (e)).
조달처: E-66 §2-4 「그러므로 점유하는 담보권자는 통상의 영업 과정 매수인에게도 자기 권리를 잃지 않는다」

**기각한 대체 정의:**
점유를 확정 인도의 필드로 두는 안. 인도는 사건이고 점유는 상태여서 한 인도가 끝난 뒤에도 점유가
움직이며, 그 필드로는 인도가 없는 시점의 점유가 서지 않는다. 점유를 담보 제공의 필드로 두는 안도
기각했다. 담보권자의 점유와 매수인의 점유가 서로 다른 당사자를 보는데 제공은 매수인을 알지 못한다.

**점유자를 선택 타입으로 받는다.** 담보물이 어디에 있는지가 서지 않는 배치가 실재하고, 그 자리를
거짓으로 접으면 담보권자가 점유하지 않는 것으로 읽혀 끊김을 막는 조건이 저절로 열린다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3878
structure CollateralPossession (Asset Party : Type) where
  /-- 그 자산을 쥐고 있는 당사자. 서지 않으면 `none`. -/
  possessorOf : Asset → Option Party

/-- witness (A-3). **무엇을 증거하는가.** `CollateralPossession` 이 비어 있지 않다. 어느 자산의
점유자도 서지 않는 상태 하나를 든다. -/
-- DD:CF-3878
def CollateralPossession.trivial : CollateralPossession Unit Unit where
  possessorOf := fun _ => none

/--
점유 상태의 시점 족.

**대응 비형식 개념:** 시점마다 누가 무엇을 쥐고 있는가. 점유가 옮겨 다니므로 한 시점의 상태만으로는
끊김이 어느 시점에 섰는지가 서지 않는다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**이 정의가 배제하는 사례:**
점유를 시점 없는 상태로 두고 끊김을 재는 읽기. 같은 규범이 매수인의 자격을 점유의 취득에 걸고 담보권의
보호를 담보권자의 점유에 거는데, 그 둘이 시점에 따라 갈리므로 시점이 없으면 인도 전의 배치와 인도 뒤의
배치가 한 꼴로 선다(Uniform Commercial Code 제1-201조 (b)(9)).
조달처: E-66 §3-2 「그 귀결로 끊김은 담보물이 담보권자의 손을 떠나 있을 때에만 선다」

**기각한 대체 정의:**
족을 자산에서 시점으로 가는 사상으로 두는 안. 그러면 시점이 자산마다 따로 서고 한 시점의 상태를 통째로
드는 자리가 사라진다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3878
abbrev CollateralPossessionFamily (Asset Party : Type) := ℕ → CollateralPossession Asset Party

/-- 한 상태를 모든 시점에 두는 족. 시점에 따라 변하지 않는 점유를 드는 수단이다. -/
-- DD:CF-3878
def CollateralPossessionFamily.constant {Asset Party : Type}
    (G : CollateralPossession Asset Party) : CollateralPossessionFamily Asset Party :=
  fun _ => G

/--
그 당사자가 그 자산을 쥐고 있는가.

**대응 비형식 개념:** 지목한 당사자가 그 물건의 점유자인가. 점유자가 서지 않는 자리에서는 거짓이다.

**이 정의가 배제하는 사례:**
점유자가 서지 않는 자리를 참으로 접는 읽기. 같은 규범이 담보권자의 점유를 끊김을 막는 조건으로 두므로
그 자리를 참으로 접으면 점유가 재어지지 않는 배치에서 끊김이 전부 막히고, 그러면 제3자의 처분으로
담보권이 끊긴 사례가 구조에서 사라진다(Uniform Commercial Code 제9-320조 (e)).
조달처: E-66 §2-4 「담보권자가 제9-313조에 따라 물건을 점유하고 있으면 그 담보권은 (a)항과 (b)항의 영향을 받지 않는다」

**기각한 대체 정의:**
선택 타입을 그대로 내보내는 안. 이 술어를 받는 자리가 끊김의 조건을 곱으로 묶는 자리이고 그 곱이
`Bool` 을 요구하므로, 선택 타입을 내보내면 그 접기가 쓰는 자리마다 따로 서고 접는 방향이 갈린다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Bool` 이므로 판정이 그 타입의 `DecidableEq` 에서
나온다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3878
def CollateralPossession.heldBy {Asset Party : Type} [DecidableEq Asset] [DecidableEq Party]
    (G : CollateralPossession Asset Party) (a : Asset) (p : Party) : Bool :=
  (G.possessorOf a).any (fun q => decide (q = p))

/--
그 제공의 담보권자가 담보물을 쥐고 있는가.

**대응 비형식 개념:** 담보를 잡은 쪽이 그 물건을 손에 들고 있는가. 반환 청구권의 의무자가 담보를
돌려줄 쪽이므로 그 당사자가 담보권자다.

**이 정의가 배제하는 사례:**
담보를 잡은 쪽을 떠받치는 청구권의 권리자로 읽는 읽기. 증거금 규범을 읽은 기록이 개시증거금과
헤어컷의 색인이 갈리는 자리를 들어 떠받쳐야 할 것과 떠받치는 것이 한 축에 서지 않음을 적으므로, 그
읽기는 담보가 제3자에게 맡겨진 배치에서 어긋난다(ISDA 2016).
조달처: E-43 §2-4 「앞은 떠받쳐야 할 것에 붙고 뒤는 떠받치는 것에 붙는다」

**기각한 대체 정의:**
담보권자를 제공의 필드로 새로 두는 안. 반환 청구권이 그 당사자를 이미 들고 앞 페이즈가 제공자를 그
청구권의 권리자로 읽었으므로, 필드를 더하면 같은 당사자가 두 자리에 서고 어긋날 수 있다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Bool` 이므로 판정이 그 타입의 `DecidableEq` 에서
나온다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3878
def Pledge.pledgeeHolds {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Asset] [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (G : CollateralPossession Asset Party)
    (p : Pledge Idx Asset) : Bool :=
  G.heldBy p.pledged.asset (S.assign p.returns).obligor

/--
그 인도의 받는 쪽이 옮겨진 물건을 쥐고 있는가.

**대응 비형식 개념:** 매수인이 물건을 받았는가. 성문 규범이 통상의 영업 과정 매수인의 자격에 점유의
취득을 넣으므로, 물건을 받지 못한 매수인은 그 자격을 얻지 못한다.

**이 정의가 배제하는 사례:**
매수인이 물건을 받지 못했는데도 담보권이 끊긴다고 보는 읽기. 같은 규범이 매수인의 자격 다섯 축 가운데
하나로 점유의 취득이나 회수할 권리를 들므로, 그 축이 없으면 인도 계약만으로 끊김이 서게 된다
(Uniform Commercial Code 제1-201조 (b)(9)).
조달처: E-66 §2-7 「점유를 취득했거나 제2편에 따라 매도인으로부터 물건을 회수할 권리를 가져야 하며」

**기각한 대체 정의:**
회수할 권리를 함께 받는 안. 그 권리는 매매법의 판정이고 구조가 재지 못하므로, 그것을 받으려면 외생
확인 신호를 하나 더 세워야 하는데 이 회차가 그 신호를 좁히는 쪽으로 가고 있어 방향이 어긋난다. 그
몫이 남는다는 사실은 이 술어의 한계이며 뭉치의 문면에서 조달되지 않는다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Bool` 이므로 판정이 그 타입의 `DecidableEq` 에서
나온다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3878
def OutrightDelivery.takerHolds {Idx Asset Party : Type}
    [DecidableEq Asset] [DecidableEq Party]
    (G : CollateralPossession Asset Party)
    (d : OutrightDelivery Idx Asset Party) : Bool :=
  G.heldBy d.conveyed.asset d.taker

/--
그 인도를 내놓은 쪽이 그 제공의 담보 제공자인가.

**대응 비형식 개념:** 담보권을 설정한 자가 스스로 판 경우인가. 성문 규범의 첫째 경로가 그 같음을
요구한다.

**이 정의가 배제하는 사례:**
설정자가 아닌 제3자가 판 자리에서도 첫째 경로가 열린다고 보는 읽기. 같은 규범이 끊기는 담보권을 그
매수인의 매도인이 설정한 것으로 한정하므로, 그 한정이 없으면 다른 사람이 설정한 담보권까지 그 항으로
끊긴다(Uniform Commercial Code 제9-320조 (a)).
조달처: E-66 §2-3 「매도인이 아닌 다른 사람이 설정한 담보권은 이 항으로 끊기지 않는다」

**기각한 대체 정의:**
설정자를 떠받치는 청구권의 의무자로 읽는 안. 그 당사자는 담보로 떠받쳐지는 채무를 지는 쪽이고 담보를
내놓은 쪽과 다를 수 있으므로, 제3자가 담보를 대신 내놓은 배치에서 어긋난다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Bool` 이므로 판정이 그 타입의 `DecidableEq` 에서
나온다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3883
def OutrightDelivery.bySettlorOf {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (p : Pledge Idx Asset) (d : OutrightDelivery Idx Asset Party) : Bool :=
  decide (d.giver = Pledge.provider S p)

/--
그 인도를 내놓은 쪽이 그 제공의 두 당사자가 아닌가.

**대응 비형식 개념:** 소유자가 물건을 맡긴 상인이 판 경우인가. 성문 규범의 둘째 경로가 그 자리에
서며, 내놓는 쪽이 담보 제공자도 담보권자도 아니다.

**이 정의가 배제하는 사례:**
맡긴 상인의 처분과 설정자의 처분을 한 경로로 묶는 읽기. 같은 규범이 두 경로가 요구하는 것이 다르다고
적고 앞은 내놓는 쪽과 설정자의 같음을 요구하고 뒤는 맡김의 성립과 상인의 자격을 요구하므로, 묶으면
요건이 섞인다(Uniform Commercial Code 제2-403조 (2)).
조달처: E-66 §3-1 「앞은 내놓는 쪽과 담보권의 설정자가 같을 것을 요구하고, 뒤는 맡김의 성립과 상인의 자격을 요구한다」

**기각한 대체 정의:**
내놓는 쪽이 담보권자가 아니라는 한 조건으로 두 경로를 접는 안. 제공자와 담보권자가 다른 배치에서는 그
조건과 두 경로의 합이 외연으로 같아지나 요건이 달라 그 같음이 우연이며, 접으면 설정자 경로가 요구하는
것과 맡긴 상인 경로가 요구하는 것이 한 자리에 묻힌다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Bool` 이므로 판정이 그 타입의 `DecidableEq` 에서
나온다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3883
def OutrightDelivery.byEntrusteeOf {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (p : Pledge Idx Asset) (d : OutrightDelivery Idx Asset Party) : Bool :=
  decide (d.giver ≠ Pledge.provider S p) && decide (d.giver ≠ (S.assign p.returns).obligor)

/--
그 제공의 담보권이 두 경로 가운데 하나로 끊겼는가.

**대응 비형식 개념:** 담보로 잡힌 물건이 설정자나 맡김을 받은 상인의 손에서 팔려 나가, 매수인이 그
물건을 받고 담보권자가 그것을 쥐고 있지 않아, 담보를 잡은 쪽의 권리가 그 물건에 닿지 못하게 된 상태.

**이 정의가 배제하는 사례:**
담보권자가 물건을 쥐고 있는 자리에서도 끊김이 선다고 보는 읽기. 성문 규범이 담보권자의 점유를 끊김을
막는 조건으로 두고 매수인의 점유 취득을 자격의 축으로 두므로, 그 둘을 빼면 담보물이 담보권자의 손에
있는 배치에서도 끊김이 선다(Uniform Commercial Code 제9-320조 (e)).
조달처: E-66 §3-2 「담보권자가 물건을 쥐고 있으면 (e)항이 막고, 매수인이 물건을 받지 못했으면 (b)(9)가 막는다」

**기각한 대체 정의:**
앞 페이즈의 술어를 고쳐 경로를 더하는 안. 그 술어를 딛는 정리 다섯과 관측층 채널이 함께 움직이고 그
진술의 뜻이 소급해 바뀌므로, 새 술어를 세우고 두 술어의 관계를 정리로 드는 쪽을 골랐다. 외생 확인
신호를 통째로 빼는 안도 기각했다. 선의와 통상의 과정은 분쟁이 서야 법원이 내리는 판정이어서 구조가
재지 못한다.

**외생 확인 신호가 받는 몫이 둘로 줄어든다.** 성문 규범이 매수인의 자격을 다섯 축으로 드는데 점유의
취득이 이 파일의 점유 상태에서 재어지고, 금전채무의 담보로 취득하는 자의 배제가 담보 제공과 확정 인도를
서로 배타로 둔 용어집의 등록에서 재어지며, 대량 양도로 취득하는 자의 배제는 통상의 과정 밖의 이전이어서
그 판정에 흡수된다. 그래서 신호가 받는 것이 선의와 통상의 과정 둘이다.

**논리곱이 다섯이고 그 가운데 하나가 논리합이다.** 옮겨진 담보물의 자산이 그 제공의 담보물의 자산과
같은 것과, 두 경로의 논리합과, 매수인의 점유와, 담보권자의 점유 없음과, 외생 확인 신호다.

**점유를 두 시점에서 읽는다.** 규범의 두 조문이 보는 시점이 다르다. 담보권자의 점유는 처분이 선
시점에 재어지고 매수인의 점유는 인도가 끝난 뒤에 재어지므로, 한 상태로 둘을 읽으면 점유자가 하나뿐인
구조에서 두 조건이 서로 배타가 되어 매수인의 점유가 담보권자의 점유 없음을 함의하고 그 곱이 접힌다.
그래서 이 판정이 점유의 족과 두 시점을 받는다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Bool` 이므로 판정이 그 타입의 `DecidableEq` 에서
나온다.

**수 체계를 받지 않는다.**

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.** 두 시점 인자가 그 인덱스다.
-/
-- DD:CF-3883
def PledgeSet.rightDefeatedByPath {PIdx DIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Asset] [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (D : DeliverySet DIdx Idx Asset Party)
    (G : CollateralPossessionFamily Asset Party) (tSale tAfter : ℕ)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx) : Bool :=
  decide (∃ k ∈ D.index,
    (decide ((D.assign k).conveyed.asset = (P.assign i).pledged.asset)
      && ((D.assign k).bySettlorOf S (P.assign i) || (D.assign k).byEntrusteeOf S (P.assign i))
      && (D.assign k).takerHolds (G tAfter)
      && !((P.assign i).pledgeeHolds S (G tSale))
      && (D.assign k).defeatsPriorClaims) = true)

/--
담보권자가 담보물을 쥐고 있으면 그 담보권은 이 경로로 끊기지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
담보권자가 물건을 점유하고 있는데도 이 판정이 참인 자리가 있어야 한다. 그 관측은 그 점유가 판정의
곱에서 빠졌다는 뜻이며, 성문 규범이 그 점유를 끊김을 막는 조건으로 두므로 그러면 이 술어가 그 규범과
어긋난다.

**가정과 그 배제 사례(T-4·T-5):** 처분이 선 시점에 그 제공의 담보권자가 담보물을 쥐고 있다는 것을
진술문의 인자로 둔다. 그 가정이 배제하는 것은 담보물이 담보권자의 손을 떠난 배치이며, 거기서는 이 판정이 나머지 네
인자에 걸려 참도 거짓도 될 수 있다.

**T-3 분류:** 보조 보정이다. 판정의 곱을 전개하면 그 인자가 거짓인 자리에서 곱이 거짓이라는 등식으로
닫히므로 기여 목록에서 제외한다. 그 대신 규범의 그 조문이 구조에서 실제로 걸린다는 것을 이 진술이
든다.
-/
-- DD:CF-3883
theorem rightDefeatedByPath_eq_false_of_pledgeeHolds
    {PIdx DIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Asset] [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (D : DeliverySet DIdx Idx Asset Party)
    (G : CollateralPossessionFamily Asset Party) (tSale tAfter : ℕ)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx)
    (h : (P.assign i).pledgeeHolds S (G tSale) = true) :
    P.rightDefeatedByPath S D G tSale tAfter i = false := by
  unfold PledgeSet.rightDefeatedByPath
  apply decide_eq_false
  intro ⟨k, _, hk⟩
  rw [h, Bool.not_true, Bool.and_false, Bool.false_and] at hk
  exact Bool.noConfusion hk

/--
설정자가 스스로 판 자리에서 이 경로가 앞 페이즈의 술어보다 넓다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
내놓는 쪽이 담보 제공자인 자리에서 앞 페이즈의 술어가 이미 참이어야 한다. 그 술어가 내놓는 쪽이 그
제공의 두 당사자가 아닐 것을 요구하므로, 그 관측은 그 요구가 그 술어에 서 있지 않다는 뜻이다.

**존재 형태로 진술하는 까닭(T-6):**
넓어짐은 두 술어의 값이 갈리는 배치를 들어야 보인다. 임의의 배치에서 넓어지는 것이 아니라 설정자가
내놓은 자리에서만 갈리므로, 그 배치가 실재함이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 받은 구멍이 적은 결손이 실제로 메워졌음을 보이는 자리이고, 두 술어 가운데 앞의
것이 거짓이고 뒤의 것이 참인 배치가 실재한다는 것이 이 정리의 산출이므로 기여 목록에 든다.
-/
-- DD:CF-3883
theorem exists_settlor_path_beyond_rightDefeated :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (D : DeliverySet Unit Bool Bool (Option Bool))
      (G : CollateralPossessionFamily Bool (Option Bool))
      (P : PledgeSet Bool Bool Bool) (i : Bool),
      P.rightDefeatedByPath S D G 0 1 i = true ∧ P.rightDefeated S D i = false := by
  exact ⟨⟨∅, fun _ =>
      { obligor := some false, holder := some true, currency := false, amount := Term.const (),
        trigger := TriggerFamily.constant (Trigger.le (Term.const ()) (Term.const ())),
        inception := 0, expiry := 0, exercisable := fun _ => true }⟩,
    ⟨{()}, fun _ => ⟨⟨false, none⟩, some true, none, true⟩⟩,
    fun _ => ⟨fun _ => some none⟩,
    ⟨∅, fun _ => ⟨⟨false, none⟩, false, true, false⟩⟩, true, rfl, rfl⟩

/--
그 끊김 판정이 각 인자에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 거짓인 자리에서 참을 내야 한다. 그 관측은 그 판정이 곱이 아니라는 뜻이며,
그러면 다른 물건이 옮겨진 인도나 두 경로 어디에도 들지 않는 인도나 매수인이 받지 못한 인도나 담보권자가
쥐고 있는 담보물이나 요건이 갖추어지지 않은 인도가 담보권을 끊은 것으로 세어진다.

**존재 형태로 진술하는 까닭(T-6):**
인자마다 그 하나만 거짓인 배치를 들어야 보인다. 임의의 배치에서 각 인자가 홀로 가르는 것이 아니라
나머지가 전부 참인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 판정의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 결론을
부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로, 각
인자가 홀로 거짓인 자리를 이 정리가 든다.

**점유의 두 인자를 시점으로 가른다.** 점유자가 하나뿐이므로 한 시점에서는 매수인의 점유와 담보권자의
점유가 함께 참일 수 없고, 두 시점을 받는 꼴에서만 그 둘이 홀로 가른다.
-/
-- DD:CF-3883
theorem rightDefeatedByPath_pins_each_conjunct :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (d : OutrightDelivery Bool Bool (Option Bool))
      (G Gtaker Gpledgee : CollateralPossessionFamily Bool (Option Bool))
      (P : PledgeSet Bool Bool Bool) (i : Bool),
      P.rightDefeatedByPath S (DeliverySet.mk {()} (fun _ => d)) G 0 1 i = true
        ∧ P.rightDefeatedByPath S
            (DeliverySet.mk {()}
              (fun _ => { d with conveyed := { d.conveyed with
                                                asset := !d.conveyed.asset } })) G 0 1 i = false
        ∧ P.rightDefeatedByPath S
            (DeliverySet.mk {()} (fun _ => { d with giver := some false })) G 0 1 i = false
        ∧ P.rightDefeatedByPath S (DeliverySet.mk {()} (fun _ => d)) Gtaker 0 1 i = false
        ∧ P.rightDefeatedByPath S (DeliverySet.mk {()} (fun _ => d)) Gpledgee 0 1 i = false
        ∧ P.rightDefeatedByPath S
            (DeliverySet.mk {()}
              (fun _ => { d with defeatsPriorClaims := false })) G 0 1 i = false := by
  exact ⟨⟨∅, fun _ =>
      { obligor := some false, holder := some true, currency := false, amount := Term.const (),
        trigger := TriggerFamily.constant (Trigger.le (Term.const ()) (Term.const ())),
        inception := 0, expiry := 0, exercisable := fun _ => true }⟩,
    ⟨⟨false, none⟩, some true, none, true⟩,
    fun _ => ⟨fun _ => some none⟩,
    fun _ => ⟨fun _ => none⟩,
    fun t => ⟨fun _ => some (if t = 0 then some false else none)⟩,
    ⟨∅, fun _ => ⟨⟨false, none⟩, false, true, false⟩⟩, true,
    rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Definition
