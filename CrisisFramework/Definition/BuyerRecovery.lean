/-
정의층 — 매수인의 자격에서 점유 밖의 몫

규율: L-9(import 방향은 단방향), L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족으로 정의한다), A-1(`axiom` 금지),
      A-8(변이 검사와 논리 결합의 증거), C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), T-2(반증 조건), T-3(기여 분류),
      T-6(존재 형태).

**이 파일이 세우는 것은 통상의 영업 과정 매수인의 자격에서 점유 밖의 몫이다.** 성문 규범이 그 자격의
한 축을 점유를 취득했거나 매도인으로부터 물건을 회수할 권리를 가질 것으로 두는데 앞 페이즈가 앞의 몫만
받았고, 받은 구멍이 그 빠짐을 적는다.

**기존 외생 확인 신호에 셋째를 더하지 않는다.** 앞 페이즈의 결정이 그 신호가 받는 몫을 선의와 통상의
과정 둘로 못박았고 그 항목이 원장에 살아 있으므로, 셋째를 더하면 그 결정이 뒤집히고 폐기 레코드가
유일한 길이 된다. 그 권리를 판정 기관이 내리는 이진 판정으로 받아 그 신호 옆에 세운다.

**기존 점유 술어와 끊김 술어를 고치지 않는다.** 그 둘을 딛는 정리와 관측층 채널이 함께 움직이고 앞
페이즈가 세운 진술의 뜻이 소급해 바뀌므로, 새 술어를 세우고 두 술어가 갈리는 배치를 정리가 든다.

**이 파일은 수를 시점 인덱스로만 쓴다.** 그 밖의 자리에 수가 서지 않는다.

**용어집의 선행 등록을 받지 않는다.** 이 파일이 세우는 것이 구조체가 아니라 판정이고, 그 판정이 받는
권리는 판정 기관이 내리는 이진 판정을 인도의 색인에 매는 표현 수단이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.AdjudicatedCondition
import CrisisFramework.Definition.CollateralPossession

namespace CrisisFramework.Definition

/--
그 인도의 받는 쪽이 통상의 영업 과정 매수인의 점유 축을 충족하는가.

**대응 비형식 개념:** 매수인이 물건을 받았거나, 받지 못했더라도 매도인으로부터 그것을 회수할 권리를
갖는가. 성문 규범이 그 자격의 한 축을 그 둘의 논리합으로 둔다.

**이 정의가 배제하는 사례:**
매수인이 물건을 받지도 못하고 회수할 권리도 갖지 못한 자리에서 그 축이 선다고 보는 읽기. 같은 규범이
그 축을 점유의 취득이나 회수할 권리로 두므로, 둘 다 없으면 그 자격이 서지 않는다.
조달처: E-66 §2-7 「점유를 취득했거나 제2편에 따라 매도인으로부터 물건을 회수할 권리를 가져야 하며」

**기각한 대체 정의:**
그 권리를 인도 구조의 외생 확인 신호에 더해 그 신호가 받는 몫을 셋으로 넓히는 안. 앞 페이즈의 결정이
그 몫을 선의와 통상의 과정 둘로 못박았고 그 항목이 원장에 살아 있어 셋째를 더하면 그 결정이 뒤집히며,
원장이 수정 불가여서 폐기 레코드가 유일한 길이 된다. 그 권리를 점유 상태의 필드로 두는 안도 기각했다.
점유는 물건을 쥔 상태이고 그 권리는 쥐지 못한 자리에서 서는 것이어서 한 필드가 두 뜻을 들게 된다.

**논리합이 둘이다.** 받는 쪽이 옮겨진 물건을 쥐고 있는가와 그 인도에 대해 회수할 권리가 판정됐는가다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Bool` 이므로 판정이 그 타입의 `DecidableEq` 에서
나온다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3986
def OutrightDelivery.takerQualifies {Idx Asset Party DIdx : Type}
    [DecidableEq Asset] [DecidableEq Party]
    (G : CollateralPossession Asset Party) (A : AdjudicatedCondition DIdx) (k : DIdx)
    (d : OutrightDelivery Idx Asset Party) : Bool :=
  d.takerHolds G || A.holds k

/--
그 제공의 담보권이 두 경로 가운데 하나로 끊겼는가. 매수인의 자격을 점유 밖까지 받는 판정이다.

**대응 비형식 개념:** 담보로 잡힌 물건이 설정자나 맡김을 받은 상인의 손에서 팔려 나가, 매수인이 그
물건을 받았거나 매도인으로부터 그것을 회수할 권리를 얻었고, 담보권자가 그것을 쥐고 있지 않아, 담보를
잡은 쪽의 권리가 그 물건에 닿지 못하게 된 상태.

**이 정의가 배제하는 사례:**
매수인이 물건을 받지 못한 자리에서 그 끊김이 언제나 막힌다고 보는 읽기. 같은 규범이 그 자격의 축을
점유의 취득이나 회수할 권리로 두므로, 점유만 보면 물건을 받지 못했으나 회수할 권리를 가진 매수인이
자격을 잃은 것으로 선다.
조달처: E-66 §3-2 「그 귀결로 끊김은 담보물이 담보권자의 손을 떠나 있을 때에만 선다」

**기각한 대체 정의:**
앞 페이즈의 끊김 술어를 고쳐 그 인자를 자격으로 바꾸는 안. 그 술어를 딛는 정리 셋과 그것을 읽는 자리가
함께 움직이고 앞 페이즈가 세운 진술의 뜻이 소급해 바뀌므로, 새 술어를 세우고 두 술어가 갈리는 배치를
정리가 드는 쪽을 골랐다. 내놓는 쪽의 두 경로를 한 조건으로 접는 안도 기각했다. 같은 규범이 두 경로가
요구하는 것이 다르다고 적으므로 접으면 요건이 섞인다.
조달처: E-66 §2-3 「매도인이 아닌 다른 사람이 설정한 담보권은 이 항으로 끊기지 않는다」

**논리곱이 다섯이고 그 가운데 둘이 논리합이다.** 옮겨진 담보물의 자산이 그 제공의 담보물의 자산과 같은
것과, 두 경로의 논리합과, 매수인의 자격이 드는 논리합과, 담보권자의 점유 없음과, 외생 확인 신호다.

**점유를 두 시점에서 읽는다.** 담보권자의 점유는 처분이 선 시점에 재어지고 매수인의 점유는 인도가 끝난
뒤에 재어지며, 회수할 권리의 판정도 뒤의 시점에서 읽는다.

**범위는 확정 인도 파일의 기본 판정과 같다.** 인도가 옮긴 것이 청구권이 아닌 자리에 그친다. 보호받는
매수인의 자격은 값과 반대 청구의 통지 없음과 지배를 함께 요구하므로(E-99 §4-1), 점유와 회수할 권리로
자격을 받는 이 판정이 그 자리에 맞지 않는다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Bool` 이므로 판정이 그 타입의 `DecidableEq` 에서
나온다.

**수 체계를 받지 않는다.**

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.** 두 시점 인자가 그 인덱스다.
-/
-- DD:CF-3986
def PledgeSet.rightDefeatedByQualification
    {PIdx DIdx Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Asset] [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (D : DeliverySet DIdx Idx Asset Party)
    (G : CollateralPossessionFamily Asset Party)
    (R : AdjudicatedConditionFamily DIdx) (tSale tAfter : ℕ)
    (P : PledgeSet PIdx Idx Asset) (i : PIdx) : Bool :=
  decide (∃ k ∈ D.index,
    (decide ((D.assign k).conveyed.asset = (P.assign i).pledged.asset)
      && ((D.assign k).bySettlorOf S (P.assign i) || (D.assign k).byEntrusteeOf S (P.assign i))
      && (D.assign k).takerQualifies (G tAfter) (R tAfter) k
      && !((P.assign i).pledgeeHolds S (G tSale))
      && (D.assign k).defeatsPriorClaims) = true)

/--
회수할 권리가 선 자리에서 이 판정이 앞 페이즈의 판정보다 넓다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
매수인이 물건을 받지 못했는데 회수할 권리가 선 자리에서 앞 페이즈의 판정이 이미 참이어야 한다. 그
판정이 매수인의 점유를 인자로 요구하므로, 그 관측은 그 요구가 그 판정에 서 있지 않다는 뜻이다.

**존재 형태로 진술하는 까닭(T-6):**
넓어짐은 두 판정의 값이 갈리는 배치를 들어야 보인다. 임의의 배치에서 넓어지는 것이 아니라 매수인이
점유를 얻지 못하고 회수할 권리만 가진 자리에서만 갈리므로, 그 배치가 실재함이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 받은 구멍이 적은 결손이 실제로 메워졌음을 보이는 자리이고, 자격의 논리합 가운데
뒤의 몫이 홀로 끊김을 세우는 배치가 실재한다는 것을 구조 안의 명제로 드는 자리가 여기뿐이므로 기여
목록에 든다.
-/
-- DD:CF-3986
theorem exists_recovery_path_beyond_possession :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (D : DeliverySet Unit Bool Bool (Option Bool))
      (G : CollateralPossessionFamily Bool (Option Bool))
      (R : AdjudicatedConditionFamily Unit)
      (P : PledgeSet Bool Bool Bool) (i : Bool),
      P.rightDefeatedByQualification S D G R 0 1 i = true
        ∧ P.rightDefeatedByPath S D G 0 1 i = false := by
  -- 매도인이 판 물건을 매수인도 담보권자도 쥐지 않고 회수할 권리만 판정된 배치를 든다. 매수인의
  -- 점유를 요구하는 앞 판정은 거짓이고 자격의 논리합을 받는 새 판정은 참이므로, 칸마다 계산하면
  -- 값이 나와 `rfl` 로 닫힌다.
  exact ⟨⟨∅, fun _ =>
      { obligor := some false, holder := some true, currency := false, amount := Term.const (),
        trigger := TriggerFamily.constant (Trigger.le (Term.const ()) (Term.const ())),
        inception := 0, expiry := 0, exercisable := fun _ => true }⟩,
    ⟨{()}, fun _ => ⟨⟨false, none⟩, some true, none, true⟩⟩,
    fun _ => ⟨fun _ => none⟩,
    fun _ => ⟨fun _ => true⟩,
    ⟨∅, fun _ => ⟨⟨false, none⟩, false, true, false⟩⟩, true, rfl, rfl⟩

/--
그 자격 판정이 각 분기에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 두 분기가 모두 거짓인 자리에서 참을 내거나, 한 분기만 참인 자리에서 거짓을 내야 한다. 그
관측은 그 판정이 논리합이 아니라는 뜻이며, 그러면 점유에서 오는 자격과 회수할 권리에서 오는 자격 가운데
하나가 구조에서 사라진다.

**존재 형태로 진술하는 까닭(T-6):**
분기마다 그 하나만 참인 배치를 들어야 보인다. 임의의 배치에서 각 분기가 홀로 가르는 것이 아니라
나머지가 거짓인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 판정의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 그 대신
규범이 자격의 축으로 든 둘이 구조에서 각각 걸린다는 것을 이 진술이 든다.
-/
-- DD:CF-3986
theorem takerQualifies_pins_each_disjunct :
    ∃ (d : OutrightDelivery Bool Bool (Option Bool))
      (Ghold Gempty : CollateralPossession Bool (Option Bool))
      (Ryes Rno : AdjudicatedCondition Unit),
      d.takerQualifies Ghold Rno () = true
        ∧ d.takerQualifies Gempty Rno () = false
        ∧ d.takerQualifies Gempty Ryes () = true := by
  -- 매수인이 물건을 쥔 점유와 아무도 쥐지 않은 점유를 들고, 회수할 권리를 참으로 내는 판정과
  -- 거짓으로 내는 판정을 든다. 칸마다 계산하면 값이 나오므로 `rfl` 로 닫힌다.
  exact ⟨⟨⟨false, none⟩, some true, none, true⟩,
    ⟨fun _ => some none⟩, ⟨fun _ => none⟩,
    ⟨fun _ => true⟩, ⟨fun _ => false⟩, rfl, rfl, rfl⟩

/--
그 끊김 판정이 각 인자에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 거짓인 자리에서 참을 내야 한다. 그 관측은 그 판정이 곱이 아니라는 뜻이며,
그러면 다른 물건이 옮겨진 인도나 두 경로 어디에도 들지 않는 인도나 자격을 얻지 못한 매수인이나
담보권자가 쥐고 있는 담보물이나 요건이 갖추어지지 않은 인도가 담보권을 끊은 것으로 세어진다.

**존재 형태로 진술하는 까닭(T-6):**
인자마다 그 하나만 거짓인 배치를 들어야 보인다. 임의의 배치에서 각 인자가 홀로 가르는 것이 아니라
나머지가 전부 참인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 판정의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 그 대신
앞 페이즈의 판정이 든 다섯 인자가 자격을 넓힌 뒤에도 각각 걸린다는 것을 이 진술이 든다.
-/
-- DD:CF-3986
theorem rightDefeatedByQualification_pins_each_conjunct :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (d : OutrightDelivery Bool Bool (Option Bool))
      (G Gpledgee : CollateralPossessionFamily Bool (Option Bool))
      (R Rno : AdjudicatedConditionFamily Unit)
      (P : PledgeSet Bool Bool Bool) (i : Bool),
      P.rightDefeatedByQualification S (DeliverySet.mk {()} (fun _ => d)) G R 0 1 i = true
        ∧ P.rightDefeatedByQualification S
            (DeliverySet.mk {()}
              (fun _ => { d with conveyed := { d.conveyed with
                                                asset := !d.conveyed.asset } })) G R 0 1 i = false
        ∧ P.rightDefeatedByQualification S
            (DeliverySet.mk {()} (fun _ => { d with giver := some false })) G R 0 1 i = false
        ∧ P.rightDefeatedByQualification S (DeliverySet.mk {()} (fun _ => d)) G Rno 0 1 i = false
        ∧ P.rightDefeatedByQualification S
            (DeliverySet.mk {()} (fun _ => d)) Gpledgee R 0 1 i = false
        ∧ P.rightDefeatedByQualification S
            (DeliverySet.mk {()}
              (fun _ => { d with defeatsPriorClaims := false })) G R 0 1 i = false := by
  -- 아무도 물건을 쥐지 않는 점유 위에서 회수할 권리만 판정된 배치를 들고, 다섯 인자를 하나씩
  -- 거짓으로 돌린다. 담보권자의 점유는 처분 시점 0 에서만 서게 둔다. 칸마다 계산하면 값이
  -- 나오므로 `rfl` 로 닫힌다.
  exact ⟨⟨∅, fun _ =>
      { obligor := some false, holder := some true, currency := false, amount := Term.const (),
        trigger := TriggerFamily.constant (Trigger.le (Term.const ()) (Term.const ())),
        inception := 0, expiry := 0, exercisable := fun _ => true }⟩,
    ⟨⟨false, none⟩, some true, none, true⟩,
    fun _ => ⟨fun _ => none⟩,
    fun t => ⟨fun _ => if t = 0 then some (some false) else none⟩,
    fun _ => ⟨fun _ => true⟩,
    fun _ => ⟨fun _ => false⟩,
    ⟨∅, fun _ => ⟨⟨false, none⟩, false, true, false⟩⟩, true,
    rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Definition
