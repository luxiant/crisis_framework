/-
관측층 — 보유자를 쪼개는 두 축의 답과 그 둘의 정제 관계

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원),
      L-9(import 방향은 단방향), D-1·D-2(docstring 3항목),
      D-5(오염 어간에 한정어를 붙인다), T-2(반증 조건), T-3(기여 분류),
      T-4(가정의 명시), T-6(존재 형태).

이 파일은 수를 한 번도 쓰지 않고 금액도 담지 않는다. 두 답이 전부 판정 불가의 칸을 내고 그 까닭이
측정 소스 없음이므로, 값이 서는 자리가 없다.

**이 파일이 세우는 것은 이 아크가 내릴 항 둘의 답이다.** 고정 절이 두 항의 서명을 들고 그 서명이
매개변수를 추상 타입으로 받으므로, 그 매개변수에 구체 타입을 먹인 답이 이 파일에 선다. **고정 뒤의
개변이 새 항을 더하는 것과 답이 받는 열거에 원소를 더하는 것과 판정 불가의 까닭을 세분하는 것 셋에서만
들어가는데, 매개변수의 구체화가 그 셋에 들지 않으므로 이 파일이 고정 절을 움직이지 않는다.**

**제약 유형의 자리에 보유자 위임이 서고 노드의 자리에 의사결정 단위가 선다.** 앞의 물음이 제약
유형의 보유자가 드는 금액을 묻어 보유자를 쪼개므로 보유자에 붙는 축이 들어야 하고, 뒤의 물음이
노드를 묻고 노드를 의사결정 단위로 정의한 결정이 이미 서 있다.

**두 쪼갬이 정제 관계에 있다.** 의사결정 단위가 운용 위임을 필드로 품으므로 그 필드로 가는 투영이
단위별 쪼갬에서 위임별 쪼갬으로 가는 사상이며, 결정 시계의 맞음이 위임으로 정해지지 않는다는 정리가
그 역이 서지 않음을 받친다.

**두 답이 전부 소스 없음으로 접히는 근거가 이미 선 정리 둘이다.** 보유자 위임의 공시 경로 전량이
위임을 풀지 못한다는 정리와 의사결정 단위의 경로 전량이 수단의 보유자도 시계의 맞음도 풀지 못한다는
정리가 서 있으므로, 그 접힘이 이 파일의 새 주장이 아니라 그 둘의 집행이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Definition.DecisionUnit

namespace CrisisFramework.Observation

open CrisisFramework.Definition

/--
보유자 위임별 청구권 금액의 답.

**대응 비형식 개념:** 한 나라에 대한 청구권 가운데 어느 운용 위임을 받는 보유자가 든 몫이 얼마인가.
이 아크가 내릴 항 하나가 그것을 묻고 그 서명이 제약 유형을 매개변수로 받으므로, 보유자 위임의 열거를
그 자리에 먹인 것이 이 답이다.

**이 정의가 배제하는 사례:**
한 보유자가 위임 둘을 함께 받는 자리. 원전이 생태계를 네 부류로 틀 잡으면서 각 부류에 하나의 위임을
붙이는데 한 법인이 여러 위임의 운용을 함께 맡는 것이 실무이고, 이 답은 위임을 정의역으로 받아 금액을
내므로 그 겹침을 담지 못한다. 그 자리는 의사결정 단위의 입도가 법인이 아니라는 결정이 받으며, 같은
법인의 여러 단위가 다른 위임에 서는 꼴로만 표현된다(Pozsar 2015).
조달처: E-53 §2-1 「그 주체는 현금풀을 낳는 쪽이고 청구권을 자기 대차대조표에 드는 쪽이 아니다」

**기각한 대체 정의:**
제약 축의 열거를 그 자리에 먹이는 안. 지급능력과 유동성 둘이 제약의 성질이고 보유자의 성질이 아니어서
색인이 다르며, 그 물음이 보유자를 쪼개므로 보유자에 붙는 축이 들어야 한다. 그 둘의 곱을 먹이는 안도
기각했다. 자본을 분모로 쓰는가와 자산 측 적격성으로 묶는가를 위임이 술어 둘로 이미 가르므로 제약의
꼴이 위임에서 유도되고, 곱을 먹이면 같은 가름이 두 축에 함께 선다.

**값을 담지 않는다.**
-/
-- DD:CF-2575
def claimsByHolderMandate {Time Country Currency Amount : Type} :
    CQ.ClaimsByHolderConstraintKind Time Country HolderMandate Currency Amount where
  answer := fun _ _ _ _ => ObservedValue.undetermined .noMeasurementSource

/--
의사결정 단위별 청구권 금액의 답.

**대응 비형식 개념:** 한 나라에 대한 청구권 가운데 어느 의사결정 단위가 든 몫이 얼마인가. 이 아크가
내릴 항 하나가 노드를 묻고 노드를 의사결정 단위로 정의한 결정이 서 있으므로, 그 구조를 그 자리에
먹인 것이 이 답이다.

**이 정의가 배제하는 사례:**
부문으로 단위를 유도하려는 자리. 국제 기준의 편람이 중앙은행을 금융체계의 핵심 측면을 통제하는
금융기관으로 정의하면서 그 배정을 부문 배정의 일반 규칙의 예외로 명시하므로, 부문이 기능에서
유도되지 않고 규약으로 정해지는 자리가 있다. 이 답은 단위를 정의역으로 받으므로 부문 통계에서 단위가
되돌려지지 않는 결손을 담지 못하며, 그 결손은 부문 배정의 사상이 전사도 단사도 아님을 드는 정리
둘이 이미 든다(국민계정체계 편람).
조달처: E-54 §2-4 「조문 5.147 이 중앙은행을 금융체계의 핵심 측면을 통제하는 금융기관으로 정의하고」

**기각한 대체 정의:**
법인을 그 자리에 먹이는 안. 공시가 법인을 색인으로 두므로 조달이 쉬우나 현금풀이 여러 법인의 현금을
단일 의사결정자가 관리하여 법인 입도로는 노드가 되지 않으며, 그 결정이 이미 서 있다. 보유자 위임만
먹이는 안도 기각했다. 그러면 두 항의 답이 같은 색인을 받아 한 항이 다른 항을 더하는 것이 없다.

**값을 담지 않는다.**
-/
-- DD:CF-2575
def claimsByDecisionUnit {Time Country Currency Amount : Type} :
    CQ.ClaimsByDecisionUnit Time Country DecisionUnit Currency Amount where
  answer := fun _ _ _ _ => ObservedValue.undetermined .noMeasurementSource

/--
단위별 답이 위임별 답을 정제한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 답 가운데 하나가 어느 자리에서 값을 내야 한다. 보유자 위임의 공시 경로 전량이 위임을 풀지 못하고
의사결정 단위의 경로 전량이 수단의 보유자도 시계의 맞음도 풀지 못하므로, 이 명제가 거짓이면 그
경로들 가운데 하나가 지금 드는 것보다 가는 색인을 들거나 그 밖의 공시가 새로 선 것이다.

**가정을 두지 않는다.**

**이 진술이 두 항이 한 구조물에 속함을 받친다.** 의사결정 단위가 운용 위임을 필드로 품으므로 그
필드로 가는 투영이 두 쪼갬을 잇고, 지시 단위가 페이즈이고 재유입 단위가 정리라는 가름 아래에서 한
지시서에 담긴 두 항이 import 로 묶여 있어야 한다는 요구가 이 자리에서 충족된다.

**T-3 분류:** 보조 보정이 아니다. 두 답이 같은 값을 내는 것은 정의를 전개하면 따라 나오나 이 명제가
드는 것은 그 값이 같다는 사실이 아니라 **투영이 두 쪼갬을 잇는다는 구조**이며, 그 구조가 이 아크의
판별선이 묻는 쪼갬 둘의 관계다.
-/
-- DD:CF-2575
theorem decisionUnitAnswer_refines_mandateAnswer
    {Time Country Currency Amount : Type} :
    ∀ (c : Country) (u : DecisionUnit) (cur : Currency) (t : Time),
      (claimsByDecisionUnit (Time := Time) (Country := Country)
          (Currency := Currency) (Amount := Amount)).answer c u cur t
        = (claimsByHolderMandate (Time := Time) (Country := Country)
            (Currency := Currency) (Amount := Amount)).answer c u.mandate cur t := by
  exact fun _ _ _ _ => rfl

/--
위임별 답이 의사결정 단위를 가르지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
위임마다 결정 시계의 맞음이 하나로 정해져 서로 다른 두 단위가 같은 위임을 받을 수 없어야 한다. 원전이
위임 셋을 들면서 그 셋에 시계를 붙이지 않고 시계의 축을 든 편이 위임을 들지 않으므로, 이 명제가
거짓이면 두 축을 함께 드는 편이 뭉치에 있고 그것을 빠뜨린 것이다.

**존재 형태로 진술하는 까닭(T-6):** 위임이 단위를 가르지 못하는 것은 어느 위임에 단위 둘이 서는지에
걸리므로 전칭으로 세우면 거짓이다. 위임이 셋이고 시계의 맞음이 둘이어서 모든 위임에 단위 둘이 서나,
이 명제가 드는 것은 역사상이 함수로 서지 않는다는 것이고 존재 하나로 그것이 선다.

**T-3 분류:** 보조 보정이 아니다. 앞의 명제와 짝을 이루어 정제가 한 방향으로만 선다는 것을 들며,
그 비대칭이 이 아크가 내릴 항 둘이 서로 다른 것을 묻는다는 근거다.
-/
-- DD:CF-2575
theorem mandateAnswer_does_not_separate_decision_units
    {Time Country Currency Amount : Type} :
    ∃ u v : DecisionUnit,
      u ≠ v ∧ u.mandate = v.mandate
        ∧ ∀ (c : Country) (cur : Currency) (t : Time),
            (claimsByHolderMandate (Time := Time) (Country := Country)
                (Currency := Currency) (Amount := Amount)).answer c u.mandate cur t
              = (claimsByHolderMandate (Time := Time) (Country := Country)
                  (Currency := Currency) (Amount := Amount)).answer c v.mandate cur t := by
  exact ⟨⟨.lossAvoidance, .horizonCoversMaturity⟩, ⟨.lossAvoidance, .maturityExceedsHorizon⟩,
    fun h => DecisionHorizonFit.noConfusion (congrArg DecisionUnit.horizonFit h), rfl,
    fun _ _ _ => rfl⟩

/--
두 답이 전부 측정 소스 없음으로 접힌다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 답 가운데 하나가 어느 자리에서 값을 내거나 판정 불가의 다른 까닭을 내야 한다. 까닭의 열거가
측정 소스 없음과 법적 문면의 갈림과 반사실의 미평가와 구조의 결손과 결정의 범위 밖 다섯을 드는데,
이 두 답의 결손이 재야 할 것은 정해졌으나 그것을 내는 자리가 없는 부류이므로 그 첫째 칸에 선다.

**가정을 두지 않는다.**

**이 진술이 두 항의 처분을 받친다.** 쪼개는 축이 이 페이즈에서 서면 무엇을 재야 하는지가 서므로 두
항이 정의 공백을 벗어나고, 그 재는 것에 소스가 없는 것은 조달의 결손이어서 다른 축이다. **그래서 이
명제가 드는 소스 없음이 두 항의 처분을 해소로 두는 것과 어긋나지 않는다.**

**T-3 분류:** 보조 보정이 아니다. 두 답이 내는 칸과 그 까닭이 무엇인지를 이 명제가 들며, 그것이
관측층에 등재되는 소스 없음이고 프레임워크의 주요 산출물 가운데 하나다.
-/
-- DD:CF-2575
theorem holderSplitAnswers_lack_measurement_source
    {Time Country Currency Amount : Type} :
    (∀ (c : Country) (m : HolderMandate) (cur : Currency) (t : Time),
      (claimsByHolderMandate (Time := Time) (Country := Country)
          (Currency := Currency) (Amount := Amount)).answer c m cur t
        = ObservedValue.undetermined .noMeasurementSource)
    ∧ (∀ (c : Country) (u : DecisionUnit) (cur : Currency) (t : Time),
        (claimsByDecisionUnit (Time := Time) (Country := Country)
            (Currency := Currency) (Amount := Amount)).answer c u cur t
          = ObservedValue.undetermined .noMeasurementSource) := by
  exact ⟨fun _ _ _ _ => rfl, fun _ _ _ _ => rfl⟩

end CrisisFramework.Observation
