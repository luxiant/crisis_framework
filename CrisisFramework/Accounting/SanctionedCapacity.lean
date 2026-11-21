/-
회계층 — 제재의 절단이 담보의 적격성을 좁혀 실효 조달 한도를 누르는 자리

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(색인을 갈라 두고 환산하지 않는다),
      L-9(import 방향은 단방향), A-1(`axiom` 금지), A-6(기준선 차분), C-1·C-2(`noncomputable` 과
      `Classical` 금지), C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목),
      D-3(배제 사례는 실제 문면), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시),
      T-6(존재 형태).

**이 파일이 세우는 것은 법적 절단이 제약식을 바꾸는 자리다.** 같은 층이 실효 조달 한도를 부채수용력
여지와 담보 여력의 작은 쪽으로 두고 그 담보 여력이 적격성을 인자로 받으므로, 절단이 그 적격성을
좁히는 것이 그 사슬이 닫히는 자리다. 초석 명제가 전파되는 것을 손실이 아니라 담보 가용성과 그에 따른
부채수용력으로 드는 것이 그 자리를 받친다.

**제약식을 새로 세우지 않는다.** 그 층이 한도를 이미 들고 이 파일이 그 인자를 바꾸는 몫만 받으므로,
적격성을 좁힌 제약을 내는 선언 하나와 그 좁힘이 한도를 누른다는 정리들이 이 파일의 전량이다.

**통화 가드를 두지 않는다.** L-12 의 가드가 걸리는 자리는 합의 피가수가 청구권의 금액 항을 평가하는
선언이고 이 파일의 선언은 그런 합을 두지 않으며, 담보 여력의 금액 판본을 내는 선언도 몫과 기재값의
곱을 더하므로 그 자리에 들지 않는다. 쓰지 않는 통화 인자를 서명에 받으면 L-12 가 막으려는 것과
무관한 인자가 선다.

**수 체계를 매개변수로 받는 선언이 하나 선다.** 적격성을 좁히는 선언이 산술을 쓰지 않으므로 수
체계를 받지 않아도 되고, 그 선언을 부르는 정리들이 그 자리에 `ℤ` 를 넣는다.

**정리의 증명은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며, 그 진술이 증명
가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나,
쓴 전술은 싣지 않는다.

**적재 선언은 진술이 딛는 것만 이 파일이 들고 증명이 더 요구하는 것은 집행이 더한다.** 진술과 타입을
결정 세션이 쓰므로 그 진술이 이름을 해소하는 데 필요한 적재가 이 파일의 몫이고, 전술이 더 요구하는
적재는 그 전술을 쓰는 쪽의 몫이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Accounting.DebtCapacity
import CrisisFramework.Definition.SanctionCut

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting
/--
잘린 변에서 오는 담보를 적격에서 뺀 제약.

**대응 비형식 개념:** 법이 그 상대방과의 변을 자르면 그 상대방에서 온 담보가 조달에 쓰이지 못하는
것. 부채 측 상한은 그대로 두고 자산 측 적격성만 좁아진다.

**이 정의가 배제하는 사례:**
이미 맺은 계약 아래의 담보가 유예에 덮이는 자리. 그 조문을 훑은 기록이 어느 날 이전에 맺은 계약과 그
이행에 필요한 부수 계약에 다른 날까지 금지가 미치지 않음을 들어 한 거래가 금지되는지가 그것이 딛는
계약의 체결 시점에 함께 걸린다고 적으므로, 이 선언은 절단의 판정을 받아 쓰기만 하고 그 유예를 담지
않는다. 유예를 받은 담보가 적격에서 빠지지 않게 하는 몫은 그 판정을 주는 쪽에 있다.
조달처: E-68 §2-9 「그것이 딛는 계약의 체결 시점에 함께 걸린다」

**기각한 대체 정의:**
담보 여력을 내는 선언 안에서 절단을 보게 하는 안. 선언이 하나 줄어드나 그 선언의 적격성 인자가 좁아질
때 담보 여력이 줄어든다는 정리가 이미 서 있으므로 그 정리가 이 좁힘을 받으려면 좁힘이 제약 쪽에 서야
하고, 안에서 보게 하면 그 정리를 다시 세우게 된다. 부채 측 상한도 함께 누르는 안도 기각했다. 절단이
자산 측에서 오는데 상한을 누르면 두 축의 물림이 한 인자로 접히고, 두 상한이 서로 다른 축에서 온다는
것이 그 접기에서 사라진다.

**수 체계를 매개변수로 받는다.** 이 선언이 산술을 쓰지 않으므로 받은 수 체계를 그대로 넘긴다.
-/
-- DD:CF-4426
def narrowedByCut {Num Currency Asset Party : Type} (k : Constraint Num Currency Asset)
    (sourceOf : Asset → Party) (cutEdge : Party → Party → Bool) (p : Party) :
    Constraint Num Currency Asset where
  liabilityCap := k.liabilityCap
  assetEligible := fun a => k.assetEligible a && !cutEdge p (sourceOf a)

/--
좁힌 적격성이 서면 좁히기 전의 적격성도 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
좁힌 쪽에서 적격인데 좁히기 전에 적격이 아닌 자산이 있어야 한다. 그 관측은 그 좁힘이 적격성을 넓히는
자리가 있다는 뜻이며, 그러면 담보 여력의 단조 정리가 이 좁힘을 받을 수 없다.

**가정을 두지 않는다.** 결론이 논리곱의 왼쪽 항에서 바로 따라 나온다.

**T-3 분류:** 보조 보정이다. 그 진술이 좁힘의 정의를 넘어 드는 몫을 갖지 않는다. 담보 여력의 단조
정리가 요구하는 함의를 이 좁힘에 대해 세우는 자리이므로 선언으로 둔다.
-/
-- DD:CF-4426
theorem narrowedByCut_assetEligible_imp {Num Currency Asset Party : Type}
    (k : Constraint Num Currency Asset) (sourceOf : Asset → Party)
    (cutEdge : Party → Party → Bool) (p : Party) (a : Asset) :
    (narrowedByCut k sourceOf cutEdge p).assetEligible a = true → k.assetEligible a = true := by
  -- 좁힌 적격성이 원래 적격성과 절단의 부정의 논리곱이므로, 원래 적격성의 값으로 갈라 닫는다.
  show (k.assetEligible a && !cutEdge p (sourceOf a)) = true → k.assetEligible a = true
  cases k.assetEligible a
  · exact fun h => h
  · exact fun _ => rfl

/--
좁힘의 판정이 각 인자에서 홀로 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
좁히기 전에 적격이 아닌 자산이 좁힌 쪽에서 적격이 되거나, 잘린 변에서 온 자산이 좁힌 쪽에서 적격으로
남아야 한다. 앞의 관측은 그 판정이 논리곱이 아니라는 뜻이고 뒤의 관측은 절단이 적격성에 닿지 않는다는
뜻이며, 둘 다 이 좁힘이 두 인자를 쓴다는 설계가 무너졌음을 가리킨다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 그 진술이 좁힘의 정의를 넘어 드는 몫을 갖지 않고 A-8 이 요구하는 증거를
드는 자리다. 결론을 부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가
서지 않으므로, 각 인자가 홀로 값을 가르는 자리를 이 정리가 든다.
-/
-- DD:CF-4426
theorem narrowedByCut_pins_each_conjunct :
    (narrowedByCut (Constraint.mk (fun _ => 0) (fun _ => true) : Constraint ℤ Unit Unit)
        (fun _ => ()) (fun _ _ => false) ()).assetEligible () = true
      ∧ (narrowedByCut (Constraint.mk (fun _ => 0) (fun _ => false) : Constraint ℤ Unit Unit)
        (fun _ => ()) (fun _ _ => false) ()).assetEligible () = false
      ∧ (narrowedByCut (Constraint.mk (fun _ => 0) (fun _ => true) : Constraint ℤ Unit Unit)
        (fun _ => ()) (fun _ _ => true) ()).assetEligible () = false := by
  -- 제약과 절단이 상수로 주어져 세 등식이 계산으로 닫힌다.
  exact ⟨rfl, rfl, rfl⟩

/--
잘린 변에서 오는 담보를 뺀 담보 여력은 빼기 전보다 크지 않다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어떤 몫 집합과 기재값에서 좁힌 적격성이 담보 여력을 키워야 한다. 그 관측은 적격성이 좁아지면 담보
여력이 줄어든다는 단조성이 깨진다는 뜻이며, 그러면 담보 가용성의 변화가 부채수용력으로 전달되는
사슬이 이 자리에서 끊긴다.

**가정과 그 배제 사례(T-4·T-5):** 몫과 기재값의 곱이 색인마다 비음수여야 한다. 같은 층의 몫 집합이
공매도를 음의 몫으로 받고 기재값이 충당금으로 음수가 될 수 있으므로 그 둘을 함께 배제하며, 그 가정이
담보 여력의 단조 정리가 요구하는 것과 같은 꼴이다.

**T-3 분류:** 기여다. 그 진술이 두 선언의 정의를 넘어 드는 몫을 갖는다. 법적 절단이 회계 제약의
인자를 움직인다는 것이 이 아크의 산출이고, 그 움직임을 구조 안의 명제로 드는 자리가 여기뿐이다.
-/
-- DD:CF-4427
theorem collateralCapacityAmountOf_le_of_cut
    {SIdx Asset Party PIdx Currency : Type} [DecidableEq Party]
    (H : ShareSet SIdx Asset Party PIdx ℤ)
    (k : Constraint ℤ Currency Asset) (carrying : Asset → ℤ) (p : Party)
    (sourceOf : Asset → Party) (cutEdge : Party → Party → Bool)
    (hNonneg : ∀ i ∈ H.index, 0 ≤ (H.assign i).share * carrying (H.assign i).asset) :
    collateralCapacityAmountOf H (narrowedByCut k sourceOf cutEdge p) carrying p
      ≤ collateralCapacityAmountOf H k carrying p := by
  -- 같은 층의 담보 여력 단조 정리에 좁힘의 함의를 먹인다. 합의 부등식 보조정리를 새로 쓰지 않는다.
  exact collateralCapacityAmountOf_le_of_assetEligible_imp H (narrowedByCut k sourceOf cutEdge p) k
    carrying p hNonneg (narrowedByCut_assetEligible_imp k sourceOf cutEdge p)

/--
담보 여력이 줄어들면 실효 조달 한도도 줄어들거나 같다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
담보 여력이 더 작은 자리에서 실효 한도가 더 커야 한다. 그 관측은 그 한도가 두 상한의 작은 쪽이
아니라는 뜻이며, 그러면 자산 측의 물림이 조달의 상한에 전달되지 않는다.

**가정을 두지 않는다.** 두 인자가 정수이고 결론이 조건식의 분기마다 정수 부등식으로 따라 나온다.

**T-3 분류:** 기여다. 그 진술이 한도의 정의를 넘어 드는 몫을 갖는다. 같은 층이 그 한도가 각 상한을
넘지 못한다는 것과 부채 측 상한이 작아지면 한도가 작아진다는 것을 들고 있으나 담보 측 인자의 단조성을
드는 자리가 없었고, 담보 가용성의 변화가 조달의 상한으로 전달되는 사슬이 그 자리에서 닫힌다.
-/
-- DD:CF-4427
theorem effectiveFundingLimit_le_of_collateralAmount_le
    (headroom c₁ c₂ : ℤ) (h : c₁ ≤ c₂) :
    effectiveFundingLimit headroom c₁ ≤ effectiveFundingLimit headroom c₂ := by
  -- 아래 자리의 최소를 같은 층의 두 상계 정리로 두 인자 아래에 묶고 한 원자로 접은 뒤, 위 자리의
  -- 조건식을 두 분기로 갈라 정수 부등식으로 닫는다. 전면 `simp` 와 `linarith` 를 쓰지 않으며
  -- 마무리는 `omega` 다.
  have h₁ := effectiveFundingLimit_le_headroom headroom c₁
  have h₂ := effectiveFundingLimit_le_collateralAmount headroom c₁
  generalize effectiveFundingLimit headroom c₁ = lo at h₁ h₂ ⊢
  show lo ≤ (if headroom ≤ c₂ then headroom else c₂)
  by_cases hc : headroom ≤ c₂
  · rw [if_pos hc]
    omega
  · rw [if_neg hc]
    omega

/--
잘린 변에서 오는 담보를 빼면 실효 조달 한도가 줄어들거나 같다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 뺌이 실효 한도를 키우는 배치가 있어야 한다. 그 관측은 법적 절단이 조달의 상한을 늘릴 수 있다는
뜻이며, 그러면 제재가 자금조달을 조이는 방향으로만 작동한다는 이 아크의 사슬이 끊긴다.

**가정과 그 배제 사례(T-4·T-5):** 몫과 기재값의 곱이 색인마다 비음수여야 한다. 그 가정의 배제 사례가
앞 정리와 같고, 그 가정 없이는 음의 항이 빠지면서 합이 커질 수 있다.

**T-3 분류:** 기여다. 그 진술이 두 단조성의 합성이되 그 합성을 구조 안의 명제로 드는 유일한 자리이고,
초석 명제가 전파되는 것을 담보 가용성과 그에 따른 부채수용력으로 드는 것이 이 자리에서 타입으로
선다.
-/
-- DD:CF-4427
theorem effectiveFundingLimit_le_of_cut
    {SIdx Asset Party PIdx Currency : Type} [DecidableEq Party]
    (H : ShareSet SIdx Asset Party PIdx ℤ)
    (k : Constraint ℤ Currency Asset) (carrying : Asset → ℤ) (p : Party)
    (sourceOf : Asset → Party) (cutEdge : Party → Party → Bool) (headroom : ℤ)
    (hNonneg : ∀ i ∈ H.index, 0 ≤ (H.assign i).share * carrying (H.assign i).asset) :
    effectiveFundingLimit headroom
        (collateralCapacityAmountOf H (narrowedByCut k sourceOf cutEdge p) carrying p)
      ≤ effectiveFundingLimit headroom (collateralCapacityAmountOf H k carrying p) := by
  -- 담보 여력의 단조성과 한도의 단조성을 합성한다.
  exact effectiveFundingLimit_le_of_collateralAmount_le headroom _ _
    (collateralCapacityAmountOf_le_of_cut H k carrying p sourceOf cutEdge hNonneg)

/--
한 변을 자르면 실효 조달 한도가 엄격히 작아지는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 배치에서도 그 뺌이 한도를 같게 두어야 한다. 그 관측은 절단이 조달의 상한에 닿지 않는다는 뜻이며,
그러면 단조성이 등호로만 서서 법적 절단이 아무것도 바꾸지 않는 구조와 갈리지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
단조성만으로는 등호가 늘 서는 배치에서도 참이므로 그 사슬이 비지 않음을 보이려면 엄격히 작아지는
배치를 실제로 들어야 한다. 시스템 수준의 절단이 개별 주체의 한도를 결정하지 않으므로 전칭으로 세우면
거짓이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 절단이 제약식을 실제로 움직인다는 것을 드는 자리이고, 단조성이 등호로만 서는
구조와 이 구조를 가르는 유일한 명제이므로 기여 목록에 든다.
-/
-- DD:CF-4427
theorem exists_cut_strictly_lowers_limit :
    ∃ (H : ShareSet Unit Unit Unit Unit ℤ) (k : Constraint ℤ Unit Unit) (carrying : Unit → ℤ)
      (sourceOf : Unit → Unit) (cutEdge : Unit → Unit → Bool) (headroom : ℤ),
      effectiveFundingLimit headroom
          (collateralCapacityAmountOf H (narrowedByCut k sourceOf cutEdge ()) carrying ())
        < effectiveFundingLimit headroom (collateralCapacityAmountOf H k carrying ()) := by
  -- 보유 몫 하나와 그 자산의 출처를 자르는 절단을 둔다. 좁히기 전의 담보 여력이 하나이고 좁힌 뒤가
  -- 영이며, 여지를 그보다 크게 두면 한도가 담보 여력을 따라 내려간다. 구체 값이 계산되므로
  -- `decide` 로 닫는다.
  exact ⟨⟨{()}, fun _ => ⟨(), (), 1, ShareKind.held, none⟩⟩, ⟨fun _ => 0, fun _ => true⟩,
    fun _ => 1, fun _ => (), fun _ _ => true, 2, by decide⟩

end CrisisFramework.Accounting
