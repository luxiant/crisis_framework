/-
회계층 — 상환 실패가 보유자의 제약 인자로 옮겨 가는 사슬

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), C-9(전면 `simp` 금지), A-6(기준선 차분),
      T-2(반증 조건), T-3(보조 보정과 기여의 분류), T-4(가정의 명시), T-6(존재 형태),
      D-2(docstring 3항목), D-3(배제 사례의 조달처).

**수 체계: `ℤ`.** 익스포저와 담보와 자기자본과 부채 총계를 정수로 받아 맞댄다.

**이 파일이 세우는 것은 사슬이고 제약 구조체를 고치지 않는다.** 제약 구조체의 필드가 부채 측 한도와
자산 측 적격성 둘이고 그 둘이 외생 함수여서 실현된 상환 실패가 움직일 자리가 그 구조체에 없으므로,
사슬이 자기자본을 거쳐 부채수용력 여지로 들어간다. 그 여지의 머리말이 초석 명제가 전파의 매개로 드는
둘 가운데 부채수용력 쪽이 그 값이라고 적는 자리가 이 사슬의 우변이다.

**사슬의 칸마다 정리를 따로 둔다.** 자기자본의 감소가 여지를 줄이는 칸과 그 여지의 감소가 실효 조달
한도를 줄이는 칸과 그 한도의 감소가 상환 실패를 세우는 칸이 서로 다른 가정을 요구하고 가운데 칸이
최소 연산 때문에 조건부로만 서므로, 한 정리로 묶으면 어느 가정이 어느 칸에 걸리는지가 진술문에서
서지 않는다.

**증명은 미완 표지로 둔다.** 진술과 타입과 문서화 문면이 결정 세션의 몫이고 증명과 전술과 `import`
가 집행의 몫이므로, 이 파일의 각 정리는 그 표지를 달고 집행이 그 자리를 채운다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Accounting.DebtCapacity
import CrisisFramework.Accounting.Repayment
import CrisisFramework.Definition.LossBearer
import CrisisFramework.Definition.NetworkKind

namespace CrisisFramework.Accounting

open CrisisFramework.Definition

/--
생존자 부담의 금액.

**대응 비형식 개념:** 어느 청구권의 의무자가 상환에 실패했을 때 그 부도난 쪽이 미리 낸 담보가 흡수한
뒤에 살아남은 쪽의 자기자본이 지는 몫. 담보가 익스포저를 덮으면 살아남은 쪽이 지는 몫이 없고, 덮지
못하면 그 차이가 그 몫이다.

**이 정의가 배제하는 사례:**
담보가 부도 시점에 그 금액으로 서지 않는 자리. 증거금 규범이 개시증거금을 상대방이 부도났을 때 포지션을
닫고 대체하는 동안 생길 수 있는 잠재적 장래 익스포저를 덮는 것으로 두므로, 그 담보가 덮는 것은 부도
시점의 익스포저가 아니라 그 뒤의 처분 구간에서 벌어지는 익스포저다. 이 값은 한 시점의 두 수를 맞대며 그
구간에서 익스포저가 벌어지는 것을 담지 않는다(BCBS · IOSCO 2020).
조달처: E-43 §2-1 「변동증거금은 이미 발생한 현재 익스포저를 덮고」

**기각한 대체 정의:**
음수를 그대로 내는 안. 담보가 익스포저를 넘으면 그 차이가 음수로 서는데 살아남은 쪽이 음의 손실을 지는
것이 아니고 그 남는 담보가 부도난 쪽에 돌아가는 것이어서, 음수를 그대로 내면 그 값이 자기자본을 늘리는
것으로 읽힌다. 담보 계약의 두 양식이 신용보전금액을 음수가 되면 영으로 본다고 적어 그 자름이 실물에
선례를 갖는다. 부채수용력 여지가 같은 자름을 기각한 사유는 그 자름이 제약이 이미 물린 자리와 아직 여유가
있는 자리를 같은 값으로 접는다는 것인데, 이 값의 목적이 물림을 재는 것이 아니라 흡수 뒤 남는 몫을 재는
것이어서 그 사유가 이 자리에 걸리지 않는다.

**수 체계를 받지 않는다.** 두 인자가 `ℤ` 이며 회계층의 기본 수 체계다.
-/
-- DD:CF-3932
def survivorLossOf (exposure obligorCollateral : ℤ) : ℤ :=
  if exposure ≤ obligorCollateral then 0 else exposure - obligorCollateral

/--
부담 주체별 몫의 금액.

**대응 비형식 개념:** 한 익스포저를 두 부담 주체가 나누어 질 때 각 주체가 지는 금액. 채무자 부담은
부도난 쪽이 낸 담보가 지는 몫이고 생존자 부담은 그 담보를 넘는 몫이다.

**이 정의가 배제하는 사례:**
마진과 자본이 색인되는 단위가 다른 자리. 증거금 규범이 마진을 포트폴리오마다 따로 지정해 그
포트폴리오의 위험 변화에 맞춰 조정하고 자본을 그 주체의 활동 전체가 공유하게 두므로, 두 부담이 같은
익스포저를 나누면서도 그 금액이 매겨지는 단위가 다르다. 이 값은 한 익스포저를 단위로 두며 그 단위의
다름을 담지 않는다(BCBS · IOSCO 2020).
조달처: E-43 §2-5 「자본은 그 주체의 활동 전체가 공유한다」

**기각한 대체 정의:**
두 몫을 각각 따로 선언하는 안. 따로 두면 부담 주체의 열거와 그 금액 사이의 대응이 구조에 서지 않고 그
열거가 어느 금액도 받지 않는 표현 수단으로 떨어지며, 두 몫의 합이 익스포저와 같다는 항등식의 좌변을 그
열거로 유도할 수 없다. 부담 주체를 받지 않고 쌍을 내는 안도 기각했다. 쌍으로 내면 그 두 성분이 어느
주체의 몫인지가 자리로만 서고, 열거가 늘어날 때 그 자리가 소리 없이 어긋난다.

**수 체계를 받지 않는다.** 두 인자가 `ℤ` 이며 회계층의 기본 수 체계다.
-/
-- DD:CF-3932
def lossBorneBy (b : LossBearer) (exposure obligorCollateral : ℤ) : ℤ :=
  match b with
  | LossBearer.obligorPostedCollateral =>
      if exposure ≤ obligorCollateral then exposure else obligorCollateral
  | LossBearer.survivorCapital => survivorLossOf exposure obligorCollateral

/--
두 부담의 합이 익스포저와 같다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 두 부담의 합이 익스포저와 갈리는 두 수의 배치.
담보가 익스포저를 덮는 자리에서는 채무자 부담이 익스포저이고 생존자 부담이 영이며 덮지 못하는 자리에서는
채무자 부담이 담보이고 생존자 부담이 그 차이이므로, 그런 배치가 설 수 없고 반증은 두 판정 가운데 하나의
분기가 뒤집힌 구현에서만 온다.

**가정을 두지 않는다.** 담보가 음수인 배치에서도 두 분기가 같은 조건으로 갈리고 그 합이 익스포저와
같으므로, 음이 아님을 가정으로 둘 필요가 없다.

**T-3 분류:** 보조 보정이 아니다. 이 항등식이 부담 주체 분할의 완전성을 금액의 자리에서 드는 유일한
진술이고, 그 완전성이 정의만으로 따라 나온다는 정의층의 주장이 이 등식에서 재어진다.
-/
-- DD:CF-3932
theorem lossBorneBy_add_eq_exposure (exposure obligorCollateral : ℤ) :
    lossBorneBy LossBearer.obligorPostedCollateral exposure obligorCollateral
        + lossBorneBy LossBearer.survivorCapital exposure obligorCollateral = exposure := by
  -- 두 몫을 펼치면 같은 조건을 두 번 읽는 조건식 둘의 합이 되므로, 그 조건을 `by_cases` 로 한 번
  -- 가르고 두 분기를 `if_pos` 와 `if_neg` 로 고정한 뒤 남는 정수 등식을 `omega` 로 닫는다.
  show (if exposure ≤ obligorCollateral then exposure else obligorCollateral)
      + (if exposure ≤ obligorCollateral then 0 else exposure - obligorCollateral) = exposure
  by_cases h : exposure ≤ obligorCollateral
  · rw [if_pos h, if_pos h]
    omega
  · rw [if_neg h, if_neg h]
    omega

/--
담보가 익스포저를 덮으면 생존자 부담이 영이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 담보가 익스포저를 덮는데 생존자 부담이 영이 아닌
배치. 조건식의 첫 분기가 그 자리를 받으므로 그런 배치가 설 수 없고, 반증은 그 분기가 뒤집힌 구현에서만
온다.

**가정과 그 배제 사례(T-4·T-5):** 익스포저가 담보 이하라는 가정을 진술에 명시한다. 그 가정이 배제하는
자리는 익스포저가 담보를 넘는 배치이며 거기서 생존자 부담이 양이다. 담보가 부도 시점에 그 금액으로 서지
않는 자리도 그 가정 안에 들어오고 그 구간의 벌어짐을 담는 구조가 형식층에 없다.

**T-3 분류:** 보조 보정이며 기여 목록에서 뺀다. 정의를 전개하고 분기를 가르면 닫히나, 생존자 부담이
자기자본을 줄이는 칸이 그 영을 딛으므로 선언으로 둔다.
-/
-- DD:CF-3932
theorem survivorLossOf_eq_zero_of_le (exposure obligorCollateral : ℤ)
    (h : exposure ≤ obligorCollateral) :
    survivorLossOf exposure obligorCollateral = 0 := by
  -- 조건식을 펼치고 가정 `h` 를 `if_pos` 에 먹여 첫 분기를 고른다.
  show (if exposure ≤ obligorCollateral then 0 else exposure - obligorCollateral) = 0
  rw [if_pos h]

/--
생존자 부담이 양이면 부채수용력 여지가 줄어든다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 생존자 부담이 양이고 레버리지 상한이 양인데 그
부담만큼 줄어든 자기자본에서 그 여지가 줄지 않는 배치. 그 여지가 자기자본의 곱에서 부채 총계를 뺀
값이므로 그런 배치는 그 곱이 자기자본에 대해 증가하지 않을 때에만 서고, 상한이 양이라는 가정이 그 자리를
막는다.

**가정과 그 배제 사례(T-4·T-5):** 레버리지 상한이 양이고 생존자 부담이 양이라는 두 가정을 진술에
명시한다. 앞의 가정이 배제하는 자리는 상한이 영이나 음인 배치이며 거기서는 자기자본의 감소가 그 여지를
줄이지 않거나 늘린다. 뒤의 가정이 배제하는 자리는 담보가 익스포저를 덮는 배치이며 거기서 그 부담이
영이다.

**T-3 분류:** 보조 보정이 아니다. 이 진술이 실현된 상환 실패를 보유자의 제약 인자에 잇는 사슬의 첫
칸이고, 그 사슬이 서지 않는다는 것이 이 페이즈가 받은 구멍의 내용이다.
-/
-- DD:CF-3932
theorem debtCapacityHeadroom_lt_of_survivorLoss_pos
    (liabilityTotal cap equity exposure obligorCollateral : ℤ)
    (hcap : 0 < cap)
    (hloss : 0 < survivorLossOf exposure obligorCollateral) :
    debtCapacityHeadroom liabilityTotal cap
        (equity - survivorLossOf exposure obligorCollateral)
      < debtCapacityHeadroom liabilityTotal cap equity := by
  -- 부담이 양이므로 줄어든 자기자본이 원래 자기자본보다 작고, 상한이 양이므로 곱이 그 순서를
  -- 지킨다. `Int.mul_lt_mul_of_pos_left` 로 곱의 단조를 받고 같은 부채 총계를 뺀 비교를 `omega`
  -- 로 닫는다. 전면 `simp` 와 `linarith` 를 쓰지 않는다.
  have hLess : equity - survivorLossOf exposure obligorCollateral < equity := by omega
  have hMul : creditSupply cap (equity - survivorLossOf exposure obligorCollateral)
      < creditSupply cap equity :=
    Int.mul_lt_mul_of_pos_left hLess hcap
  show creditSupply cap (equity - survivorLossOf exposure obligorCollateral) - liabilityTotal
      < creditSupply cap equity - liabilityTotal
  omega

/--
담보 쪽이 물리면 그 여지의 감소가 실효 조달 한도를 줄이지 않는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 한도가 두 상한의 최소인데 담보 쪽이 작은 어느
배치에서도 부채 측 상한의 감소가 그 최소를 줄이는 것. 한 배치를 들면 반증되므로 이 진술은 그 배치의
실재만 요구한다.

**존재 형태로 진술하는 까닭(T-6):** 시스템 수준 제약이 개별 노드 상태를 결정하지 않는다. 자기자본의
감소가 부채 측 상한을 줄이는 것은 전칭으로 서나 그것이 실효 한도를 줄이는지는 담보 쪽이 물리는지에
달려 있고, 그 물림이 그 노드의 자산 적격성과 보유 몫에서 오므로 전칭이 거짓이다.

**가정을 두지 않는다.** 존재 진술이므로 증인이 그 조건을 자기 값으로 들고 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 이 진술이 사슬이 끊기는 자리를 구조 안의 명제로 드는 유일한 자리다.
-/
-- DD:CF-3932
theorem exists_effectiveFundingLimit_eq_of_collateral_binds :
    ∃ headroom collateralAmount loss : ℤ,
      0 < loss ∧ collateralAmount ≤ headroom - loss ∧
        effectiveFundingLimit (headroom - loss) collateralAmount
          = effectiveFundingLimit headroom collateralAmount := by
  -- 여지 2 와 담보 0 과 부담 1 을 든다. 담보 쪽이 물려 줄기 전과 뒤의 실효 한도가 모두 담보와
  -- 같으므로 그 판정이 계산으로 나오고 `decide` 로 닫힌다.
  exact ⟨2, 0, 1, by decide⟩

/--
그 한도의 감소가 상환 실패를 세우는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 어느 배치에서도 그 한도가 줄어들기 전에 상환 실패가
서지 않았으면서 줄어든 뒤에도 서지 않는 것. 한 배치를 들면 반증되므로 이 진술은 그 배치의 실재만
요구한다.

**존재 형태로 진술하는 까닭(T-6):** 그 한도의 감소가 상환 실패를 전칭으로 세우지 않는다. 의무액이 그
한도보다 충분히 작으면 줄어든 한도도 그 의무를 덮으므로, 상환 실패가 서는 것은 그 감소가 의무액을
가로지르는 배치에서만이다.

**가정을 두지 않는다.** 존재 진술이므로 증인이 그 조건을 자기 값으로 들고 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 이 진술이 사슬의 마지막 칸이며, 같은 층의 앞선 진술이 그 한도가
의무를 덮으면 상환 실패가 서지 않음을 들므로 이 진술이 그 대우의 자리를 실제 배치로 채운다.
-/
-- DD:CF-3932
theorem exists_failsRepayment_of_headroom_drop :
    ∃ due headroom collateralAmount loss : ℤ,
      0 < loss ∧
        failsRepayment due (effectiveFundingLimit headroom collateralAmount) = false ∧
          failsRepayment due (effectiveFundingLimit (headroom - loss) collateralAmount) = true := by
  -- 의무 2 와 여지 2 와 담보 5 와 부담 1 을 든다. 부채 쪽이 물려 실효 한도가 2 에서 1 로 줄고 그
  -- 감소가 의무액을 가로지르므로 그 판정이 계산으로 나오고 `decide` 로 닫힌다.
  exact ⟨2, 2, 5, 1, by decide⟩

/--
어느 쌍도 이어지지 않은 배치에서도 제약의 조임이 그 여지를 줄인다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 이어짐 술어가 어느 쌍에도 참이 아닌 모든 배치에서
부채 측 상한의 감소가 그 여지를 줄이지 않는 것. 한 배치를 들면 반증되므로 이 진술은 그 배치의 실재만
요구한다.

**존재 형태로 진술하는 까닭(T-6):** 전파의 규모가 연결 구조에 비례한다는 절을 전칭으로 세우면 거짓이다.
레버리지 제약을 다룬 편이 디폴트 없이 네트워크 없이 증폭이 발생한다고 적고 그 주장이 그 모형에서 지지되지
않는다고 적으므로, 이 진술이 그 전칭의 반례 배치를 구조 안에 든다.

**가정을 두지 않는다.** 존재 진술이므로 증인이 그 조건을 자기 값으로 들고 가정이 서지 않는다.

**T-3 분류:** 보조 보정이 아니다. 이 진술이 이 페이즈가 받은 두 구멍 가운데 전파 규모를 묻는 쪽을
처분하는 자리다.
-/
-- DD:CF-3934
theorem exists_headroom_lt_without_link :
    ∃ (m : NetworkMembership Unit) (liabilityTotal cap cap' equity : ℤ),
      (∀ k a b, m.linked k a b = false) ∧ cap' < cap ∧ 0 < equity ∧
        debtCapacityHeadroom liabilityTotal cap' equity
          < debtCapacityHeadroom liabilityTotal cap equity := by
  -- 어느 쌍도 잇지 않는 이어짐의 증거 인스턴스와 부채 총계 0 과 상한 1 · 0 과 자기자본 1 을 든다.
  -- 여지의 감소는 같은 층의 상한 단조 정리에 자기자본과 상한의 두 부등식을 먹여 받는다.
  exact ⟨NetworkMembership.trivial, 0, 1, 0, 1, fun _ _ _ => rfl, by decide, by decide,
    debtCapacityHeadroom_lt_of_liabilityCap_lt 0 0 1 1 (by decide) (by decide)⟩

end CrisisFramework.Accounting
