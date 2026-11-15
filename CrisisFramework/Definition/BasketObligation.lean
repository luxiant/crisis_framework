/-
정의층 — 바스켓 표시 청구권의 의무 묶음

규율: L-9(import 방향은 단방향), L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외),
      L-12(회계층의 통화 간 환산 금지), L-13(정의층 대상은 시점 인덱스를 갖는 족으로 정의한다),
      A-1(`axiom` 금지), A-3(witness 의무), A-8(변이 검사와 논리 결합의 증거),
      C-1·C-2(`noncomputable` 과 `Classical` 금지), C-3(판정 술어는 `Decidable`),
      C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      D-7(용어집 선행 등록), D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류),
      T-4(가정의 명시), T-6(존재 형태).

**이 파일이 세우는 것은 여러 통화로 표시된 몫이 한 의무를 이룬다는 것을 담는 자리다.** 청구권
구조체가 표시 통화를 필드 하나로 받아 그 청구권이 쪼개지지 않으므로 바스켓은 여러 청구권으로 서고,
그 묶음은 청구권 사이의 관계이지 한 청구권의 필드가 아니다.

**이 파일은 금액을 들지 않는다.** 회계층이 통화 간 환산을 금지하고 항등식을 총액 기준으로 유지하므로
묶음이 금액을 더하면 그 자리에서 환산이 서며, 금액을 들지 않는 사상은 피가수를 갖지 않아 그 금지에
걸릴 자리가 없다. 금액을 통화별 몫으로 가르는 자리는 공시에서 읽히지 않는 가중치를 요구하므로 이
파일이 받지 않고 관측층이 소스 없음으로 등재한다.

**묶음을 의무 식별자로 가는 사상으로 둔다.** 같은 의무에 묶인 몫이 같은 상으로 나오므로 그 관계가
분할로 서고, 색인 집합의 합을 쓰지 않아 몫의 건전성과 명제 외연성을 끌어오지 않는다.

**이 파일은 수를 시점 인덱스로만 쓴다.** 그 밖의 자리에 수가 서지 않는다.

**용어집의 선행 등록을 받지 않는다.** 그 요구의 판별 시험이 그 개념을 들 수 있는가가 아니라
그 개념이 누구의 것인가를 묻고 원 문헌이나 성문 규범이 자기 문면으로 그 개념을 세울 때에만
등록하게 하는데, 이 파일이 세우는 구조체는 이미 등록된 개념 위에 선 사상이어서 표현 수단이다.
앞 페이즈가 망의 이어짐을 같은 사유로 등록 없이 세운 선례가 있다.

**정리의 증명과 적재 선언은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며, 이
파일이 딛는 적재 선언도 집행이 쓴다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Nat.Notation

namespace CrisisFramework.Definition

/--
바스켓 표시 청구권의 의무 묶음.

**대응 비형식 개념:** 여러 통화로 표시된 몫이 하나의 의무를 이루는 자리. 금액이 여러 통화의
가중합으로 정해지는 청구권이 그 부류이며, 표시 통화가 몫마다 다르므로 한 청구권으로 담기지 않는다.

**이 정의가 배제하는 사례:**
한 금융전문 안에서 그 묶음이 식별되는 자리. 그 표준을 훑은 기록이 신용장의 금액이 하나의 수로 서지
않고 통화 코드와 허용 편차와 추가 금액이 함께 그것을 정한다고 적으므로, 한 의무의 금액이 몫의 합으로
정해진다고 보면 그 편차와 추가 금액이 그 합에서 사라진다.
조달처: E-42 §2-3 「32B 의 값과 허용 편차와 추가 금액이 함께」

**기각한 대체 정의:**
몫마다 가중치를 필드로 두어 금액을 통화별로 가르는 안. 묶음의 금액이 구조에서 나오나 그 가중치가
어느 공시에서도 읽히지 않고, 가중합을 쓰는 순간 회계층의 환산 금지에 걸린다. 묶음을 두 몫 사이의
동치 관계로 두는 안도 기각했다. 관계를 쌍으로 두면 추이성이 성립함을 따로 증명해야 하고, 의무
식별자로 가는 사상은 그 성질을 공역의 상등에서 그대로 받는다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3765
structure BasketObligation (Leg Oblig Currency : Type) where
  /-- 그 몫이 어느 의무에 드는가. -/
  obligationOf : Leg → Oblig
  /-- 그 몫의 표시 통화. -/
  currencyOf : Leg → Currency

/--
시점마다의 의무 묶음 (L-13).

**대응 비형식 개념:** 어느 시점에 어느 몫이 어느 의무에 드는가. 의무의 구성이 조건 변경으로 시점에
따라 바뀌므로 그 묶음이 시점에 걸린다.

**이 정의가 배제하는 사례:**
의무의 구성이 시점과 무관하다고 보는 자리. 한 성문 규범을 훑은 기록이 금액과 수량과 단가에 붙은
근사 표현을 편차로 해석하고 그 조건이 신용장마다 달리 선다고 적으므로, 묶음을 상수로 두면 그 변경이
구조에서 사라진다.
조달처: E-21 §2-5 「제30조가 금액과 수량과 단가에 붙은 근사 표현을 10퍼센트의 편차로」

**기각한 대체 정의:**
묶음 구조체 안에 시점을 받는 필드를 더하는 안. 필드를 더하면 그 구조체를 받는 선언이 전부 그 필드를
채워야 하고 시점을 쓰지 않는 자리까지 값을 지어 넣게 되며, 족으로 올리면 기존 구조체가 그대로 서고
시점을 쓰지 않는 자리가 상수 축약으로 닫힌다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-3765
abbrev BasketObligationFamily (Leg Oblig Currency : Type) :=
  ℕ → BasketObligation Leg Oblig Currency

/--
시점에 따라 변하지 않는 묶음을 족으로 올린다.

**무엇을 증거하는가.** 시점을 쓰지 않는 자리가 족을 상수로 채워 닫힘을 증거한다.
-/
-- DD:CF-3765
def BasketObligation.constant {Leg Oblig Currency : Type}
    (B : BasketObligation Leg Oblig Currency) :
    BasketObligationFamily Leg Oblig Currency := fun _ => B

/--
두 몫이 같은 의무에 드는가.

**대응 비형식 개념:** 두 통화별 몫이 하나의 의무를 함께 이루는가. 묶음이 분할이므로 그 판정이 의무
식별자의 상등으로 나온다.

**이 정의가 배제하는 사례:**
한 몫이 두 의무에 함께 드는 자리. 한 성문 규범을 훑은 기록이 상업송장이 신용장과 같은 통화로 발행되어야
한다고 적어 한 신용장의 몫이 그 신용장에만 붙으므로, 한 몫이 둘에 드는 배치는 이 판정이 담지 않는다.
조달처: E-21 §8 「상업송장은 신용장과 같은 통화로 발행해야 한다」

**기각한 대체 정의:**
판정을 두 몫의 표시 통화가 다른지로 함께 묻는 안. 바스켓의 성질이 한 판정에 담기나 같은 의무에 같은
통화의 몫이 둘 드는 배치가 거짓으로 서고, 그 배치가 분할 선적에서 실재한다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3765
def BasketObligation.sameObligation {Leg Oblig Currency : Type} [DecidableEq Oblig]
    (B : BasketObligation Leg Oblig Currency) (i j : Leg) : Bool :=
  decide (B.obligationOf i = B.obligationOf j)

/--
비어 있지 않음의 증거.

**무엇을 증거하는가.** 의무 묶음 구조체가 비어 있지 않음을 증거한다. 몫과 의무와 통화가 전부 한 원소인
배치이며, 존재 정리는 이 값을 딛지 않는다.
-/
-- DD:CF-3765
def BasketObligation.trivial : BasketObligation Unit Unit Unit where
  obligationOf := fun _ => ()
  currencyOf := fun _ => ()

/--
두 통화로 표시된 몫.

**무엇을 증거하는가.** 한 의무가 서로 다른 표시 통화의 몫을 가질 수 있음을 증거할 색인이다. 원소
이름이 몫의 표시 통화에서 오고 비형식 개념에 대응하지 않는다.
-/
-- DD:CF-3765
inductive BasketWitnessLeg where
  /-- 한 통화로 표시된 몫. -/
  | firstCurrencyLeg
  /-- 다른 통화로 표시된 몫. -/
  | secondCurrencyLeg
  deriving DecidableEq, Repr

/--
두 표시 통화.

**무엇을 증거하는가.** 몫의 표시 통화가 갈림을 증거할 색인이다. 원소 이름이 그 갈림에서 오고 비형식
개념에 대응하지 않는다.
-/
-- DD:CF-3765
inductive BasketWitnessCurrency where
  /-- 한 표시 통화. -/
  | firstCurrency
  /-- 다른 표시 통화. -/
  | secondCurrency
  deriving DecidableEq, Repr

/--
두 통화의 몫이 한 의무에 드는 묶음.

**무엇을 증거하는가.** 같은 의무에 서로 다른 표시 통화의 몫이 드는 묶음이 실재함을 증거한다. 존재
정리가 이 값을 딛는다.
-/
-- DD:CF-3765
def basketObligationWitness :
    BasketObligation BasketWitnessLeg Unit BasketWitnessCurrency where
  obligationOf := fun _ => ()
  currencyOf := fun l =>
    match l with
    | BasketWitnessLeg.firstCurrencyLeg => BasketWitnessCurrency.firstCurrency
    | BasketWitnessLeg.secondCurrencyLeg => BasketWitnessCurrency.secondCurrency

/--
같은 의무에 드는 두 몫이 서로 다른 표시 통화를 갖는 자리가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
같은 의무에 드는 두 몫이 언제나 같은 표시 통화를 가져야 한다. 그 관측은 의무가 통화를 가로지르지
않는다는 뜻이며, 그러면 바스켓 표시 청구권이 한 청구권으로 담기고 이 파일이 세우는 묶음이 담을 것을
갖지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
의무가 통화를 가로지른다는 것은 갈리는 두 몫을 실제로 들어야 보이고, 임의의 묶음에 대한 전칭으로는 그
가로지름이 진술되지 않는다. 모든 몫에 같은 통화를 주는 묶음이 실재하므로 전칭은 거짓이고 존재가 그
갈림을 든다.

**가정을 두지 않는다.** 증거를 직접 들어 존재를 보인다.

**T-3 분류:** 기여다. 바스켓이 한 청구권으로 담기지 않는다는 전제가 구조에서 실제로 성립함을 보이고,
그 성립이 금액을 들지 않는 꼴로 선다는 설계가 이 정리로 재어지므로 기여 목록에 든다.
-/
-- DD:CF-3765
theorem exists_same_obligation_across_currencies :
    basketObligationWitness.sameObligation BasketWitnessLeg.firstCurrencyLeg
        BasketWitnessLeg.secondCurrencyLeg = true
      ∧ basketObligationWitness.currencyOf BasketWitnessLeg.firstCurrencyLeg ≠
          basketObligationWitness.currencyOf BasketWitnessLeg.secondCurrencyLeg := by
  sorry

end CrisisFramework.Definition
