/-
회계층 — 위계 위치로 가른 부채 총계

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(색인을 갈라 두고 환산하지 않는다),
      C-9(전면 `simp` 금지), A-6(기준선 차분), T-2(반증 조건), T-4(가정의 명시).

**수 체계: `ℤ`.** 청구권의 금액이 수 체계를 매개변수로 받으므로 이 파일이 그 자리에 `ℤ` 를 넣는다.

**이 파일이 이 아크의 판별선에 답한다.** 위계 위치가 대차대조표 제약의 어느 계수로 들어가는가가 그
판별선인데, 들어오는 자리가 계수 자체가 아니라 **부채 총계를 가르는 판정**이다. 보유자가 의무자보다
위계에서 아래에 있는지를 화폐자산 사상의 비교 함수가 내고, 그 판정이 한 청구권 집합을 두 총계로
가른다.

**레버리지를 새로 세우지 않는다.** 같은 층의 신용공급이 상한과 자기자본의 곱으로 서 있고 그 상한이
레버리지의 자리이므로, 이 파일은 그 상한이 움직일 때 갈린 두 총계가 어떻게 움직이는지를 든다.

**통화를 가른 채로 둔다.** 두 총계가 통화를 인자로 받고 그 안에서만 더하므로 환산이 일어나지 않으며,
항등식이 총액 기준으로 선다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Accounting.Repayment
import CrisisFramework.Accounting.Aggregation

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
보유자가 의무자보다 위계에서 아래에 있는 청구권의 부채 총계.

**대응 비형식 개념:** 그 주체가 자기보다 위계에서 아래에 있는 보유자에게 진 부채를 모은 값. 화폐자산
사상이 가계와 같은 비은행 보유자를 은행보다 아래에 두고 은행끼리를 동급에 두는 배치에서는 이 총계가
은행 부문 밖에 대한 부채를 모은다. 그 배치는 이 총계가 받는 입력이며 이 총계가 주장하지 않는다.

**이 정의가 배제하는 사례:**
원전이 중간 범주로 둔 중개기관에 대한 부채. 가름의 초점을 그 부채가 최종 국내 채권자에 대한 것인가에
두고 최종 국내 채권자와 중개기관과 해외 채권자 셋을 가르는데(Shin and Shin 2010), 이 총계는 위계
위치의 아래 여부로 둘만 가르므로 중개기관이 어느 쪽에 드는지가 그 사상이 내는 강도로 정해지고 범주
이름으로 정해지지 않는다. 원문이 그 분할이 깔끔하지 않다고 직접 적은 자리가 그것이다.
조달처: E-51 §2 「최종 국내 채권자에 대한 부채와, 중개기관에 대한 부채와, 해외 채권자에 대한 부채다」

**기각한 대체 정의:**
보유자 부문의 열거를 인자로 받아 가르는 안. 부문이 노드에 대한 관측 투영이고 위계는 주체에 붙은
순서여서 색인이 갈리며, 두 가름을 맞대는 자리는 주체에서 보유자 부문으로 가는 배정(`SectorAssignment`)이
따로 든다. 청구권에 위계 등급 필드를 더하는 안도
기각했다. 위계가 청구권 하나의 성질이 아니라 두 주체 사이의 관계이므로 필드로 두면 같은 두 주체의
청구권들이 다른 등급을 가질 수 있다.

**보조 논증 판정:** 주장은 화폐자산 사상이 비은행 보유자를 은행보다 아래에 두고 은행끼리를 동급에 두어
이 총계가 은행 부문 밖에 대한 부채를 모으고 그 여집합의 총계가 은행 부문과 그 위에 대한 부채를
모은다는 것이며, 그 자리는 화폐의 위계와 원전의 보유자 가름을 잇는 이음이다. 이 주장이 거짓이려면
비은행 보유자가 은행과 같거나 센 화폐자산을 들거나 은행끼리 화폐자산의 강도가 갈리는 배치가
관측되어야 한다. 두 가름은 중개기관에서 갈린다. 원전의 원칙이 중개기관에 대한 부채를 비핵심으로 두는데
(E-51 §2) 머니마켓펀드 같은 중개기관이 든 것이 은행보다 약한 화폐자산이어서 위계로는 아래에 서며, 그
갈림을 봉합하지 않고 적는다. 이 판정을 원장의 `CF-4982` 가 받는다.
- 인자 1 · 측정 불가 · 측정 소스 없음(`noMeasurementSource`). 비은행 보유자의 화폐자산이 은행의 것보다
  약하다. 위계의 순서를 묻는 항의 조립이 자금순환표 경로에서 두 주체의 상대 위치를 소스 없음으로
  접는다(`flowOfFundsStrengthChannel_order_undetermined`)
- 인자 2 · 측정 불가 · 측정 소스 없음(`noMeasurementSource`). 은행끼리 화폐자산의 강도가 같다. 첫째와
  같은 정리가 접는다
- 인자 3 · 공표 실측 · 은행 부문의 부채를 보유 부문으로 가른 액수. 자금순환표가 제도부문과 수단의
  교차로 짜이고 수단마다 보유 부문의 집합이 읽힌다(E-81 §2-4 · E-81 §2-7)
- 결합 · 측정 불가
- 우회 · 외생 입력 · 인자 1 · 두 총계가 화폐자산 사상을 인자로 받으므로 그 사상이 보유자에게 주는 강도를
  입력으로 받으며, 그 입력의 소스 없음은 화폐성 위계 공시 경로가 등재한다
- 우회 · 외생 입력 · 인자 2 · 첫째와 같다
- 우회 뒤의 결합 · 공표 실측

**판정이 비교 함수에서 나온다.** 화폐자산 사상이 주체마다 액면가 약속의 강도를 선택으로 내고 그
비교가 값을 갖지 않는 주체를 가장 아래로 두므로, 이 총계가 그 관례를 그대로 받는다.
-/
-- DD:CF-1884
def liabilityTotalBelowOf {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (M : MoneyAsset Party) (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (c : Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).obligor = p ∧ (S.assign i).currency = c
          ∧ M.aboveOrEqual (S.assign i).holder p = false
     then evalTerm e (S.assign i).amount else 0)

/--
보유자가 의무자보다 위계에서 아래에 있지 않은 청구권의 부채 총계.

**대응 비형식 개념:** 그 주체가 자기와 동급이거나 자기보다 위에 있는 보유자에게 진 부채를 모은 값.
화폐자산 사상이 은행끼리를 동급에 두는 배치에서는 은행끼리의 청구권이 아래에 서지 않아 이 총계가 은행
부문 안에 대한 부채를 모으고, 중앙은행이 보유자인 청구권도 그 위에 서서 이 총계에 든다. 그 배치는 이
총계가 받는 입력이다.

**이 정의가 배제하는 사례:**
해외 채권자에 대한 부채. 원전이 그것을 셋 가운데 하나로 두고 비핵심으로 묶는데(Shin and Shin 2010),
위계 위치가 통화 축을 받지 않으므로 해외 채권자가 동급인지 아래인지가 그 사상이 내는 강도로만
정해진다. 그래서 이 총계가 그 범주를 따로 세지 않고, 통화 축과 위계 축을 하나로 통합하는 방향은
이 페이즈가 세우지 않는다.
조달처: E-51 §2 「규칙은 앞의 것을 핵심으로 두고 뒤의 둘을 비핵심으로 두는 것이다」

**기각한 대체 정의:**
아래에 있는 총계를 전량에서 뺀 값으로 두는 안. 차로 닫으면 L-12 가 금지한 순액 닫힘이 되고 두
총계를 각각 훑는 꼴이 사라져 합의 정리가 공허해진다. 비교 함수의 부정을 쓰지 않고 위에 있음을 따로
판정하는 안도 기각했다. 동급인 자리가 어느 쪽에도 들지 않게 되어 합이 전량이 되지 않는다.

**이 총계가 아래 총계의 여집합이다.** 조건절의 비교 판정이 `Bool` 이므로 두 조건이 참과 거짓으로
갈리고, 그 둘의 합이 전량임을 아래의 정리가 든다.
-/
-- DD:CF-1884
def liabilityTotalNotBelowOf {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (M : MoneyAsset Party) (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (c : Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).obligor = p ∧ (S.assign i).currency = c
          ∧ M.aboveOrEqual (S.assign i).holder p = true
     then evalTerm e (S.assign i).amount else 0)

/--
위계로 갈린 두 총계의 합이 부채 총계다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 주체의 같은 통화 부채 가운데 보유자가 아래에
있는 것도 아니고 아래에 있지 않은 것도 아닌 청구권, 또는 양쪽에 함께 드는 청구권. 비교 판정이
`Bool` 을 내므로 참과 거짓이 그 집합을 빠짐없이 겹치지 않게 가르고, 그래서 그런 청구권이 서면 그
판정이 함수가 아니다.

**가정과 그 배제 사례(T-4·T-5):** 가정을 두지 않는다. 금액의 부호를 가리지 않으므로 음의 금액을
지닌 배치에서도 서며, 등식이어서 부등식과 달리 부호 가정을 요구하지 않는다.

**이 등식이 L-12 를 지킨다.** 두 총계가 각각 집합을 훑어 더하고 차로 닫지 않으므로 순액 닫힘이
일어나지 않으며, 통화를 가른 채로 더하므로 환산도 없다.
-/
-- DD:CF-1885
theorem liabilityTotalBelowOf_add_liabilityTotalNotBelowOf
    {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (M : MoneyAsset Party) (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (c : Currency) :
    liabilityTotalBelowOf M e S p c + liabilityTotalNotBelowOf M e S p c
      = liabilityTotalOf e S p c := by
  -- 세 총계가 같은 색인 위의 합이므로, 항마다 등식을 세워 색인의 귀납으로 합에 올린다. 합을
  -- 나누는 보조정리를 쓰지 않고 그 등식을 직접 세운다.
  simp only [liabilityTotalBelowOf, liabilityTotalNotBelowOf, liabilityTotalOf]
  have key : ∀ (s : Finset Idx) (F G K : Idx → ℤ),
      (∀ i ∈ s, F i + G i = K i) → ∑ i ∈ s, F i + ∑ i ∈ s, G i = ∑ i ∈ s, K i := by
    intro s F G K h
    induction s using Finset.cons_induction with
    | empty => rw [Finset.sum_empty, Finset.sum_empty, Finset.sum_empty, add_zero]
    | cons a t ha ih =>
        rw [Finset.sum_cons, Finset.sum_cons, Finset.sum_cons,
          ← h a (Finset.mem_cons_self a t), ← ih fun i hi => h i (Finset.mem_cons_of_mem hi)]
        exact add_add_add_comm _ _ _ _
  refine key _ _ _ _ fun i _ => ?_
  -- 비교 판정이 `Bool` 이므로 그 값을 두 경우로 가르고, 각 경우에 의무자와 통화의 조건을 가른다.
  -- 한 경우에서 두 조건절 가운데 하나만 설 수 있으므로 두 항의 합이 부채 총계의 항과 같다.
  cases hb : M.aboveOrEqual (S.assign i).holder p
  · by_cases h₁ : (S.assign i).obligor = p ∧ (S.assign i).currency = c
    · have hT : (S.assign i).obligor = p ∧ (S.assign i).currency = c ∧ false = false :=
        And.intro h₁.1 (And.intro h₁.2 rfl)
      have hF : ¬((S.assign i).obligor = p ∧ (S.assign i).currency = c ∧ false = true) :=
        fun h => Bool.noConfusion h.2.2
      rw [if_pos hT, if_neg hF, if_pos h₁, add_zero]
    · have hF₁ : ¬((S.assign i).obligor = p ∧ (S.assign i).currency = c ∧ false = false) :=
        fun h => h₁ (And.intro h.1 h.2.1)
      have hF₂ : ¬((S.assign i).obligor = p ∧ (S.assign i).currency = c ∧ false = true) :=
        fun h => h₁ (And.intro h.1 h.2.1)
      rw [if_neg hF₁, if_neg hF₂, if_neg h₁, add_zero]
  · by_cases h₁ : (S.assign i).obligor = p ∧ (S.assign i).currency = c
    · have hF : ¬((S.assign i).obligor = p ∧ (S.assign i).currency = c ∧ true = false) :=
        fun h => Bool.noConfusion h.2.2
      have hT : (S.assign i).obligor = p ∧ (S.assign i).currency = c ∧ true = true :=
        And.intro h₁.1 (And.intro h₁.2 rfl)
      rw [if_neg hF, if_pos hT, if_pos h₁, zero_add]
    · have hF₁ : ¬((S.assign i).obligor = p ∧ (S.assign i).currency = c ∧ true = false) :=
        fun h => h₁ (And.intro h.1 h.2.1)
      have hF₂ : ¬((S.assign i).obligor = p ∧ (S.assign i).currency = c ∧ true = true) :=
        fun h => h₁ (And.intro h.1 h.2.1)
      rw [if_neg hF₁, if_neg hF₂, if_neg h₁, add_zero]

/--
부채 총계의 증가가 아래 총계의 증가보다 크면 아래가 아닌 총계가 는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 같은 주체와 통화에서 두 청구권 집합을 맞대어, 앞
집합의 부채 총계에 뒤 집합의 아래 총계를 더한 값이 뒤 집합의 부채 총계에 앞 집합의 아래 총계를 더한
값보다 작은데 아래가 아닌 총계가 늘지 않은 배치. 그런 배치가 서면 위계로 갈린 두 총계의 합이 부채
총계라는 등식이 깨진다.

**가정과 그 배제 사례(T-4·T-5):** 가정이 하나이고 진술에 명시한다. 앞 집합의 부채 총계에 뒤 집합의
아래 총계를 더한 값이 그 반대의 합보다 작다는 것이다. 그 가정이 배제하는 자리는 아래 총계가 부채
총계만큼 이상 늘어난 배치이며, 그 자리에서는 부채가 늘어도 그 증가가 아래의 보유자에게 가서 아래가
아닌 총계가 늘지 않는다. 증가를 차로 쓰지 않고 합으로 써 순액으로 닫지 않는다(L-12).

**이 정리가 같은 파일의 전칭에서 물림을 걷어 낸 몫이다.** 그 전칭은 두 시점에서 제약이 물린다는 가정으로
부채 총계의 증가를 상한의 상승에서 내는데, 이 정리는 그 증가를 입력으로 받아 부채 총계와 아래 총계의
관측에만 기댄다.

**T-3 분류:** 기여다. 합의 등식을 두 집합에 걸면 닫히나, 부채 총계와 아래 총계의 관측만으로 아래가
아닌 총계의 증가를 드는 자리가 구조 안에 이 정리 하나다.
-/
-- DD:CF-4982
theorem liabilityTotalNotBelowOf_lt_of_liabilityTotalOf_add_lt
    {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (M : MoneyAsset Party) (e : Env ℤ Obs Ext Lvl)
    (S₁ S₂ : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (c : Currency)
    (hGrow : liabilityTotalOf e S₁ p c + liabilityTotalBelowOf M e S₂ p c
      < liabilityTotalOf e S₂ p c + liabilityTotalBelowOf M e S₁ p c) :
    liabilityTotalNotBelowOf M e S₁ p c < liabilityTotalNotBelowOf M e S₂ p c := by
  -- 위계로 갈린 두 총계의 합이 부채 총계라는 등식을 두 집합에 걸면 남는 것이 정수의 선형 부등식이다.
  -- 마무리는 `linarith` 가 아니라 `omega` 이며 총계를 원자로 받는다.
  have h₁ := liabilityTotalBelowOf_add_liabilityTotalNotBelowOf M e S₁ p c
  have h₂ := liabilityTotalBelowOf_add_liabilityTotalNotBelowOf M e S₂ p c
  omega

/--
자기자본이 고정이고 아래 총계가 고정일 때 상한이 오르면 아래가 아닌 총계가 반드시 는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 자기자본이 양이고 두 시점에서 부채 총계가 상한과
자기자본의 곱과 같으며 아래 총계가 두 시점에서 같은데, 상한이 올랐음에도 아래가 아닌 총계가 늘지
않은 배치. 그런 배치가 서면 합의 등식이나 곱의 단조 가운데 하나가 깨진다.

**가정과 그 배제 사례(T-4·T-5):** 가정이 넷이고 전부 진술에 명시한다. 자기자본이 양인 것과 두
시점에서 제약이 물려 부채 총계가 곱과 같은 것과 아래 총계가 고정인 것과 상한이 오른 것이다. 물림
가정이 배제하는 자리는 제약이 상시 등식이 아니라 물렸을 때만 드러나는 부등식이라는 것이며, 물리지
않은 시점에서는 부채 총계가 곱보다 작아 이 전칭이 아무것도 말하지 않는다. 자기자본이 양이라는 가정이
배제하는 자리는 자기자본이 음이 된 배치이고, 그 자리에서는 상한이 올라도 곱이 내려간다.

**이 아크가 세우는 첫 전칭이다.** 앞 페이즈들이 존재 진술만 세운 데 비해 이것이 전칭으로 서며,
위계로 갈린 총계와 제약의 상한을 한 진술에 드는 첫 자리다. 원전이 국내 예금 청구권 총액을 상수로
두고 모든 은행의 레버리지가 오르면 국내 비은행 채권자에 대한 부채의 비율이 반드시 떨어진다고 적는
것이 그 원형이며, 비율을 쓰지 않고 총계로 두어 나눗셈을 피했다. 원전의 회계틀이 은행과 국내 가계 채권자 부문과 해외
채권자 부문만 색인하므로(E-51 §10) 그 모형 안에서는 위계의 가름과 원전의 보유자 가름이 갈리지 않는다.
**물림을 걷어 낸 몫은 `liabilityTotalNotBelowOf_lt_of_liabilityTotalOf_add_lt` 가 든다.** 그 정리가 부채
총계와 아래 총계의 관측만으로 아래가 아닌 총계의 증가를 들고, 이 정리는 물림이 그 증가를 상한의
상승에서 낸다는 자리로 남는다.

**보조 논증 판정:** 주장은 두 시점에서 제약이 물리고 아래 총계가 같다는 두 가정이 원전이 드는 국면을
현실에서 잡는다는 것이며, 그 자리는 진술에 든 행태 전제다. 이 주장이 거짓이려면 상한이 오른 두 시점
사이에서 부채 총계가 상한과 자기자본의 곱에 미치지 않거나 아래 총계가 움직인 주체가 관측되어야 한다.
이 판정을 원장의 `CF-4982` 가 받는다.
- 인자 1 · 측정 불가 · 측정 소스 없음(`noMeasurementSource`). 두 시점에서 부채 총계가 상한과 자기자본의
  곱과 같다. 상한을 감독 규범의 레버리지 비율 최저치로 읽으면 모든 은행이 그 비율과 최저 요건과 완충을
  분기마다 공시하여(E-56 §10-1) 완충이 선 은행에서 그 상한이 물리지 않고, 내부 한도와 담보 할인율이
  정하는 실효 상한은 공표되지 않으며 측정된 위험이 부채 측 한도를 정하는 사상의 구멍 `CF-4169` 가 살아
  있다
- 인자 2 · 측정 불가 · 측정 소스 없음(`noMeasurementSource`). 두 시점에서 아래 총계가 같다. 그 총계가
  화폐자산 사상을 인자로 받아 아래 총계의 판정 문단이 측정 불가로 든 위계 위치에 기댄다
- 인자 3 · 공표 실측 · 부채 총계. 공표 재무제표가 총자산과 장부자본을 들어 그 차로 선다(E-01 §4-1)
- 결합 · 측정 불가
- 우회 · 특징짓기 · 인자 1 · 물림을 쓰지 않고 합의 등식만으로 서는 같은 파일의 정리가 현실 독해를 받고,
  물림은 원전의 모형이 드는 국면으로 이 정리에 남는다
- 우회 · 외생 입력 · 인자 2 · 아래 총계를 화폐자산 사상과 함께 입력으로 받는다
- 우회 뒤의 결합 · 공표 실측
-/
-- DD:CF-1887
theorem liabilityTotalNotBelowOf_lt_of_liabilityCap_lt
    {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (M : MoneyAsset Party) (e : Env ℤ Obs Ext Lvl)
    (S₁ S₂ : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (c : Currency) (equity cap₁ cap₂ : ℤ)
    (hEquity : 0 < equity) (hCap : cap₁ < cap₂)
    (hBind₁ : liabilityTotalOf e S₁ p c = creditSupply cap₁ equity)
    (hBind₂ : liabilityTotalOf e S₂ p c = creditSupply cap₂ equity)
    (hBelow : liabilityTotalBelowOf M e S₁ p c = liabilityTotalBelowOf M e S₂ p c) :
    liabilityTotalNotBelowOf M e S₁ p c < liabilityTotalNotBelowOf M e S₂ p c := by
  -- 위계로 갈린 두 총계의 합이 부채 총계라는 등식을 두 시점에 걸고, 물림 가정으로 부채 총계를
  -- 상한과 자기자본의 곱으로 바꾼다. 아래 총계가 같으므로 남는 것은 두 곱의 비교이며, 자기자본이
  -- 양이고 상한이 오르므로 곱이 오른다. 마무리는 `linarith` 가 아니라 `omega` 이며 곱을 원자로 받는다.
  have h₁ := liabilityTotalBelowOf_add_liabilityTotalNotBelowOf M e S₁ p c
  have h₂ := liabilityTotalBelowOf_add_liabilityTotalNotBelowOf M e S₂ p c
  rw [hBind₁] at h₁
  rw [hBind₂] at h₂
  have hMul : creditSupply cap₁ equity < creditSupply cap₂ equity :=
    Int.mul_lt_mul_of_pos_right hCap hEquity
  omega

end CrisisFramework.Accounting
