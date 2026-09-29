/-
회계층 — 결제 방식별 몫

규율: L-15(회계층은 `ℤ`), C-9(전면 `simp` 금지), A-6(기준선 차분), T-2(반증 조건).

정의층의 몫 판정이 수 체계를 매개변수로 받으므로 이 파일이 그 자리에 `ℤ` 를 넣는다. 교차곱
부등식이므로 나눗셈이 들지 않고 `ℚ` 가 강제되지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/
import Mathlib.Tactic.Ring
import CrisisFramework.Definition.TradePayment

open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
정수 위의 몫 판정 해석.

**대응 비형식 개념:** 최소 화폐단위의 정수배로 적은 금액의 곱과 합과 비교(L-15).

**이 정의가 배제하는 사례:**
신용장의 대부분은 달러로 결제되지만 나머지는 다른 통화로 결제된다(CGFS 50). 여러 통화로 적힌 교역
가치를 한 합으로 모으려면 환산이 끼는데, 이 해석은 한 통화의 최소 단위로 적힌 금액만 더한다(L-12).

**기각한 대체 정의:**
`ℚ` 위의 해석. L-15 가 강제될 때만 허용하는데, 교차곱 부등식이 나눗셈을 피하므로 강제되지 않는다.
-/
-- DD:CF-660
def intShareArith : ShareArith ℤ where
  mul := fun a b => a * b
  add := fun a b => a + b
  zero := 0
  lt := fun a b => decide (a < b)
  le := fun a b => decide (a ≤ b)

/--
모든 결제 방식의 몫이 한꺼번에 줄 수는 없다.

**대응 비형식 개념:** 다섯 칸의 몫을 모두 더하면 전체가 되므로 모든 칸의 몫이 함께 줄 수 없다. 이
정리는 그것을 교차곱으로 진술한다. 분할이 정의만으로 완전해야 성립하며 그 밖 칸이 그 완전성을
받친다(여집합의 귀결, V-7).

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 정수의 항등식에서 나오므로 관측으로 반례를 만들
수 없다. 자료에서 모든 결제 방식의 몫이 함께 줄었다면, 그 자료의 분모가 방식별 가치의 합이 아니라는
뜻이다. 분류되지 않은 거래가 분모에만 들었거나 분자와 분모가 다른 경로에서 왔다.
-/
-- DD:CF-660
theorem exists_shareFell_eq_false (v₀ v₁ : TradePaymentMethod → ℤ) :
    ∃ m : TradePaymentMethod,
      shareFell intShareArith (v₀ m) (v₁ m)
        (TradePaymentMethod.total intShareArith v₀)
        (TradePaymentMethod.total intShareArith v₁) = false := by
  -- 다섯 칸의 판정을 차례로 갈라, `false` 인 칸이 나오면 그 칸이 증인이다. 다섯이 모두 `true` 면
  -- 다섯 교차곱 부등식을 더한 것이 `T₁ * T₀ < T₀ * T₁` 을 낳아 모순이 된다. 배중률을 쓰지 않고
  -- `Bool` 의 두 값을 가르므로 기준선이 오르지 않는다(A-6). 덧셈 부등식도 인스턴스 해결이
  -- `Classical.choice` 를 끌어오지 않는 `Int` 전용 보조정리를 쓴다.
  set T₀ := TradePaymentMethod.total intShareArith v₀ with hT₀
  set T₁ := TradePaymentMethod.total intShareArith v₁ with hT₁
  rcases (Bool.eq_false_or_eq_true
      (shareFell intShareArith (v₀ .cashInAdvance) (v₁ .cashInAdvance) T₀ T₁)).symm with hA | hA
  · exact ⟨.cashInAdvance, hA⟩
  rcases (Bool.eq_false_or_eq_true
      (shareFell intShareArith (v₀ .letterOfCredit) (v₁ .letterOfCredit) T₀ T₁)).symm with hB | hB
  · exact ⟨.letterOfCredit, hB⟩
  rcases (Bool.eq_false_or_eq_true
      (shareFell intShareArith (v₀ .documentaryCollection) (v₁ .documentaryCollection)
        T₀ T₁)).symm with hC | hC
  · exact ⟨.documentaryCollection, hC⟩
  rcases (Bool.eq_false_or_eq_true
      (shareFell intShareArith (v₀ .openAccount) (v₁ .openAccount) T₀ T₁)).symm with hD | hD
  · exact ⟨.openAccount, hD⟩
  rcases (Bool.eq_false_or_eq_true
      (shareFell intShareArith (v₀ .otherTerms) (v₁ .otherTerms) T₀ T₁)).symm with hE | hE
  · exact ⟨.otherTerms, hE⟩
  exfalso
  -- 판정이 `true` 라는 것은 그 칸의 교차곱 부등식이 성립한다는 뜻이다.
  have kA : v₁ .cashInAdvance * T₀ < v₀ .cashInAdvance * T₁ := of_decide_eq_true hA
  have kB : v₁ .letterOfCredit * T₀ < v₀ .letterOfCredit * T₁ := of_decide_eq_true hB
  have kC : v₁ .documentaryCollection * T₀ < v₀ .documentaryCollection * T₁ :=
    of_decide_eq_true hC
  have kD : v₁ .openAccount * T₀ < v₀ .openAccount * T₁ := of_decide_eq_true hD
  have kE : v₁ .otherTerms * T₀ < v₀ .otherTerms * T₁ := of_decide_eq_true hE
  -- 총액은 다섯 칸의 합이므로 분배법칙으로 양변을 그 합으로 되돌릴 수 있다.
  have e₀ : T₀ = v₀ .cashInAdvance + (v₀ .letterOfCredit
      + (v₀ .documentaryCollection + (v₀ .openAccount + v₀ .otherTerms))) := rfl
  have e₁ : T₁ = v₁ .cashInAdvance + (v₁ .letterOfCredit
      + (v₁ .documentaryCollection + (v₁ .openAccount + v₁ .otherTerms))) := rfl
  have hsum := Int.add_lt_add kA (Int.add_lt_add kB (Int.add_lt_add kC (Int.add_lt_add kD kE)))
  have hl : T₁ * T₀ = v₁ .cashInAdvance * T₀ + (v₁ .letterOfCredit * T₀
      + (v₁ .documentaryCollection * T₀ + (v₁ .openAccount * T₀ + v₁ .otherTerms * T₀))) := by
    rw [e₁]; ring
  have hr : v₀ .cashInAdvance * T₁ + (v₀ .letterOfCredit * T₁
      + (v₀ .documentaryCollection * T₁ + (v₀ .openAccount * T₁ + v₀ .otherTerms * T₁)))
      = T₀ * T₁ := by
    rw [e₀]; ring
  rw [← hl, hr, mul_comm T₁ T₀] at hsum
  exact lt_irrefl _ hsum

end CrisisFramework.Accounting
