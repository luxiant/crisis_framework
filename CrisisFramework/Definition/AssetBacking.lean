/-
정의층 — 담보물이 담은 기초자산과 그 조성자

규율: L-10(정의층은 무차원이고 시점 인덱스만 `ℕ`), L-13(정의층 대상은 시점 인덱스를 갖는 족이다),
      L-9(import 방향은 단방향), A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 의 서술),
      C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지), T-2(반증 조건), T-3(기여 분류),
      T-6(존재 형태).

**이 파일이 세우는 것은 가리키는 것과 가리켜지는 것을 잇는 관계 한 단계다.** 앞 페이즈가 담보물의
발행자를 세웠고, 중앙은행의 담보 정책이 등급을 내리는 자리가 그 발행자가 아니라 **그 담보물이 담은
자산을 조성한 자**이므로 그 관계가 없으면 그 정책의 판정이 구조에서 서지 않는다. 그 결손이 구멍으로
등재되어 있었다.

**조성자가 의무자에서 유도되지 않는다.** 조성한 자는 그 청구권을 만들어 내놓은 쪽이고 의무자는 그
청구권을 갚을 쪽이어서 증권화에서 둘이 갈리므로, 조성자를 따로 받는 사상이 아니면 그 판정이 서지
않는다.

**한 단계만 세운다.** 담은 것이 다시 무엇을 담는지는 이 파일이 세우지 않으며, 같은 정책이 증권화를
담은 증권화를 아예 받지 않는다고 적어 그 되풀이를 규범 쪽에서도 끊는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.IssuerIdentity

namespace CrisisFramework.Definition

/--
한 시점의 기초자산 관계와 조성자 배정.

**대응 비형식 개념:** 어느 청구권이 어느 청구권을 담고 있는가와, 그 담긴 것을 누가 만들어 내놓았는가.
커버드본드가 담보풀을 담고 증권화가 기초자산을 담는 자리가 그것이다.

**이 정의가 배제하는 사례:**
담보물의 발행자를 그 담보물이 담은 자산의 조성자와 같다고 보는 읽기. 중앙은행의 담보 정책이 참가자가
조성한 자산을 담은 증권의 등급을 내리면서 그 판정을 담은 자산 쪽에 거므로, 두 당사자를 한 자리로
접으면 발행자가 다른 제3자인 증권화가 그 정책 밖으로 떨어진다(영란은행).
조달처: E-49 §2-9 「참가자가 originate 한 자산을 담은 커버드본드와 증권화는 Level B 로 받지 않고」

**기각한 대체 정의:**
담은 것을 청구권 하나로 두는 안. 커버드본드의 담보풀이 청구권 여럿이고 그 가운데 일부만 참가자가
조성한 배치가 실재하므로, 하나로 두면 그 일부가 재어지지 않는다. 조성자를 청구권 구조의 필드로 넣는
안도 기각했다. 그 구조가 의무자와 권리자를 이미 들고 조성자는 그 둘과 다른 축이며, 넣으면 청구권을
세우는 자리마다 그 값을 채워야 해 담보와 무관한 청구권에도 그 칸이 선다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3879
structure AssetBacking (Idx Party : Type) where
  /-- 그 청구권이 담은 기초자산의 색인. 담은 것이 없으면 빈 목록. -/
  backedBy : Idx → List Idx
  /-- 그 청구권을 조성한 당사자. 서지 않으면 `none`. -/
  originatorOf : Idx → Option Party

/-- witness (A-3). **무엇을 증거하는가.** `AssetBacking` 이 비어 있지 않다. 어느 청구권도 담은 것이
없고 조성자도 서지 않는 배정 하나를 든다. -/
-- DD:CF-3879
def AssetBacking.trivial : AssetBacking Unit Unit where
  backedBy := fun _ => []
  originatorOf := fun _ => none

/--
기초자산 관계의 시점 족.

**대응 비형식 개념:** 시점마다 무엇이 무엇을 담고 있는가. 담보풀이 교체되고 조성자가 바뀌므로 한
시점의 배정만으로는 그 정책의 판정이 어느 시점에 섰는지가 서지 않는다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**이 정의가 배제하는 사례:**
기초자산 관계를 시점 없는 배정으로 두는 읽기. 같은 정책이 적격성을 시점 함수로 두고 범주의 분할이
폐지되는 날짜를 따로 적으므로, 시점이 없으면 그 변경 앞뒤의 배치가 한 꼴로 선다(영란은행).
조달처: E-49 §2-12 「Level B 와 Level C 의 분할이 폐지된다」

**기각한 대체 정의:**
족을 색인마다의 시점 사상으로 두는 안. 그러면 시점이 청구권마다 따로 서고 한 시점의 관계를 통째로
드는 자리가 사라진다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3879
abbrev AssetBackingFamily (Idx Party : Type) := ℕ → AssetBacking Idx Party

/-- 한 배정을 모든 시점에 두는 족. 시점에 따라 변하지 않는 기초자산 관계를 드는 수단이다. -/
-- DD:CF-3879
def AssetBackingFamily.constant {Idx Party : Type} (B : AssetBacking Idx Party) :
    AssetBackingFamily Idx Party :=
  fun _ => B

/--
그 담보물이 담은 기초자산 가운데 그 제공자가 조성한 것이 있는가.

**대응 비형식 개념:** 참가자가 조성한 자산을 담은 증권인가. 중앙은행의 담보 정책이 그 배치의 등급을
한 칸 내리며, 그 판정이 담보물 자신의 발행자가 아니라 담긴 것의 조성자에 걸린다.

**이 정의가 배제하는 사례:**
담보물의 발행자가 제공자가 아니면 그 정책이 걸리지 않는다고 보는 읽기. 같은 정책이 참가자가 조성한
자산을 담은 커버드본드와 증권화를 들어 발행 주체가 특수목적기구인 자리까지 받으므로, 발행자만 보면
증권화가 그 판정에서 전부 빠진다(영란은행).
조달처: E-49 §3-4 「같은 증권이 누가 들고 있는지에 따라 다른 등급을 받는다」

**기각한 대체 정의:**
담은 것이 비었을 때 거짓을 돌려주는 안. 거짓은 조성자가 제공자가 아니라는 것이고 빈 목록은 담은 것이
재어지지 않는다는 것이라 뜻이 다르며, 그러면 담보풀이 공시되지 않은 증권이 전부 조성자가 다른 것으로
세어진다. 담은 것 전량이 제공자의 조성일 것을 요구하는 안도 기각했다. 그 정책이 담은 자산 가운데
참가자가 조성한 것이 있는지를 묻고 비율을 묻지 않는다.

**판정이 계산으로 나온다(C-3).** 반환 타입이 `Option Bool` 이고 그 안의 판정이 당사자의
`DecidableEq` 에서 나온다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3879
def Pledge.backingOriginatedByProvider {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (B : AssetBacking Idx Party)
    (p : Pledge Idx Asset) : Option Bool :=
  match p.pledged.asClaim with
  | some i =>
      match B.backedBy i with
      | [] => none
      | l => some (l.any (fun j => decide (B.originatorOf j = some (Pledge.provider S p))))
  | none => none

/--
담보물이 청구권이 아니면 그 판정이 값을 내지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
담보물이 청구권이 아닌 제공에서 이 판정이 값을 내야 한다. 그 관측은 청구권이 아닌 담보물에 기초자산의
색인이 서 있다는 뜻이며, 그러면 그 색인이 어디서 왔는지가 이 층에서 서지 않는다.

**가정과 그 배제 사례(T-4·T-5):** 그 담보물이 청구권이 아니라는 것을 진술문의 인자로 둔다. 그 가정이
배제하는 것은 담보물이 청구권인 제공이며, 거기서는 이 판정이 담은 것의 유무에 걸려 값을 내기도 하고
내지 않기도 한다.

**T-3 분류:** 보조 보정이다. 판정의 정의를 전개하면 선택 분기로 닫히므로 기여 목록에서 제외한다.
-/
-- DD:CF-3879
theorem backing_undefined_without_claim {Idx Asset Party Num Obs Ext Lvl Currency : Type}
    [DecidableEq Party]
    (S : ClaimSet Idx Party Num Obs Ext Lvl Currency)
    (B : AssetBacking Idx Party)
    (p : Pledge Idx Asset) (h : p.pledged.asClaim = none) :
    Pledge.backingOriginatedByProvider S B p = none := by
  unfold Pledge.backingOriginatedByProvider
  rw [h]

/--
담보물의 발행자가 제공자가 아닌데 담은 기초자산의 조성자는 제공자인 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 판정이 늘 같은 값을 내야 한다. 그 관측은 담보물의 발행자와 그 담보물이 담은 자산의 조성자가 언제나
같은 당사자라는 뜻이며, 증권화가 특수목적기구를 발행자로 두고 조성자를 따로 두므로 그러면 그 구조가
형식층에서 사라진다.

**존재 형태로 진술하는 까닭(T-6):**
두 판정이 갈리는 것은 그 쌍을 내는 배치를 들어야 보인다. 임의의 배치에서 갈리는 것이 아니라 발행자와
조성자가 서로 다른 당사자인 자리에서만 갈리기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 앞 페이즈의 발행자 판정이 받은 구멍의 절반만 받았다는 것이 이 배치로 보이며,
그 절반이 이 파일의 관계로 메워진다는 것이 이 정리의 산출이므로 기여 목록에 든다.
-/
-- DD:CF-3879
theorem exists_backing_originator_differs_from_issuer :
    ∃ (S : ClaimSet Bool (Option Bool) Unit Unit Unit Unit Bool)
      (B : AssetBacking Bool (Option Bool))
      (p : Pledge Bool Unit),
      Pledge.isSelfIssued S p = some false
        ∧ Pledge.backingOriginatedByProvider S B p = some true := by
  exact ⟨⟨∅, fun i =>
      { obligor := if i then none else some false, holder := if i then some true else none,
        currency := false, amount := Term.const (),
        trigger := TriggerFamily.constant (Trigger.le (Term.const ()) (Term.const ())),
        inception := 0, expiry := 0, exercisable := fun _ => true }⟩,
    ⟨fun _ => [true], fun j => if j then some (some true) else none⟩,
    ⟨⟨(), some false⟩, true, true, false⟩, rfl, rfl⟩

end CrisisFramework.Definition
