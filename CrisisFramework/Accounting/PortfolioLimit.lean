/-
회계층 — 포트폴리오 한도의 문턱과 전량 판정

규율: L-4(회계층에 `ℝ` 가 들어오면 위반), L-10·L-15(회계층의 기본 수 체계는 `ℤ`),
      L-9(import 방향은 단방향), A-3(witness 의무), D-1·D-2(docstring 3항목),
      D-5(오염 어간에 한정어를 붙인다), D-8(witness 의 서술), C-9(전면 `simp` 금지),
      T-2(반증 조건), T-3(기여 분류), T-6(존재 형태).

이 파일은 `ℤ` 만 쓴다. 비율 제약을 분모를 양변에 곱한 교차곱 정수 부등식으로 쓰므로 나눗셈을
쓰는 자리가 없고, 그래서 `ℚ` 가 강제되지 않는다.

**이 파일이 세우는 것은 한 주체에 걸린 한도 전량을 모아 드는 판정이다.** 정의층이 한도의 걸림을
방향과 대상의 쌍으로 세우고, 이 파일이 그 쌍마다 문턱을 붙여 관할권별 일정을 만든 뒤 걸림의 목록을
받아 전량을 판정한다. **그 자리가 서지 않아 그 진술을 쓸 수 없다는 것이 구멍으로 등재되어 있었다.**

**문턱을 생성자에 박지 않고 관할권을 색인으로 받는 함수로 담는다.** 만기 하한을 재는 판정의 기각
문단이 하한을 구조에 박는 것을 배제 사례로 들며 그 사유가 한 관할권의 값만 담긴다는 것이므로, 관할권을
정의역으로 받는 일정이 그 기각을 피하면서 문턱을 담는 유일한 꼴이다.

**유동성 규제의 조정 금액 계열을 이 파일이 받지 않는다.** 그 계열이 총량의 몫이 아니라 조정 금액의
배수로 서고 회계층 유리수 디렉터리가 그 꼴을 이미 세웠으므로, 이 파일은 몫에 걸리는 한도만 받는다.
**그 둘을 한 판정으로 묶으면 서로 다른 꼴의 부등식이 한 함수에 들어간다.**

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Int.Notation
import CrisisFramework.Definition.PortfolioLimit

namespace CrisisFramework.Accounting

open CrisisFramework.Definition

/--
한도의 문턱.

**대응 비형식 개념:** 그 한도가 요구하는 몫. 조문이 비율로 적으므로 분자와 분모의 쌍으로 받고,
판정에서 분모를 양변에 곱해 나눗셈을 피한다.

**이 정의가 배제하는 사례:**
문턱이 몫이 아니라 다른 금액의 배수로 서는 자리. 유동성 규제가 둘째 단 자산의 최대액을 첫째 단 조정
금액의 분수로 적고 둘째 단 나머지의 최대액을 두 단 조정 금액의 합의 분수로 적으므로, 그 문턱의
분모가 총량이 아니라 조정 금액이다. 이 구조는 분자와 분모의 쌍만 들고 그 분모가 무엇에 곱해지는지는
판정이 정하므로, 조정 금액 계열은 이 파일의 판정이 받지 않고 회계층 유리수 디렉터리의 선언이
받는다(바젤은행감독위원회).
조달처: E-49 §10-2 「조정 Level 2B 자산의 최대액을 Level 1 과 Level 2 조정 금액의 합의 15/85」

**기각한 대체 정의:**
문턱을 하나의 유리수로 두는 안. 그러면 쌍을 다루는 번거로움이 사라지나 유리수가 회계층에서 강제되는
경우에만 허용되고 비율 제약은 교차곱으로 피할 수 있으므로, 쌍으로 두고 정수에 머무는 것이 그 요구를
따른다. 그리고 유리수를 쓰면 공리 기준선에 선택공리가 들어온다.
-/
-- DD:CF-2574
structure PortfolioLimitThreshold where
  /-- 문턱의 분자. -/
  num : ℤ
  /-- 문턱의 분모. 영이 아님은 판정이 요구하지 않고 쓰는 쪽이 보장한다. -/
  den : ℤ
  deriving DecidableEq, Repr

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `PortfolioLimitThreshold` 가 인스턴스를 갖는다. 분자와 분모가 같은
문턱이며 그 몫이 전액을 가리키므로, 하한에서는 그 대상의 금액이 총액과 같아야 하고 상한에서는
총액을 넘지 않으면 되어 어느 방향에서도 교차곱이 서는 자리다.
-/
-- DD:CF-2574
def PortfolioLimitThreshold.whole : PortfolioLimitThreshold where
  num := 1
  den := 1

/--
한 걸림의 문턱이 충족됐는가.

**대응 비형식 개념:** 그 대상의 금액이 총액에서 차지하는 몫이 문턱을 넘는가 넘지 않는가. 방향이
하한이면 넘어야 하고 상한이면 넘지 않아야 하므로, 같은 교차곱이 방향에 따라 부등호를 바꾼다.

**이 정의가 배제하는 사례:**
같은 축에 하한과 상한이 함께 걸리는 자리. 유럽의 머니마켓펀드 규범이 주간 하한의 계산에 계상할 수
있는 자산에 상한을 따로 두므로 한 범주에 두 방향이 함께 걸리는데, 이 함수는 걸림 하나를 받아 한
방향만 판정한다. 그 자리는 걸림 둘이 같은 대상을 드는 꼴로 서고 이 함수가 두 번 돌아야
한다(유럽연합).
조달처: E-56 §2-9 「같은 축에 하한과 상한이 함께 걸리고 상한은 계상의 상한이다」

**기각한 대체 정의:**
몫을 먼저 구하고 문턱과 비교하는 안. 그 꼴이 읽기 쉬우나 나눗셈을 쓰므로 정수에서 닫히지 않고
유리수를 부른다. 분모를 양변에 곱하면 같은 판정이 정수 부등식으로 서며, 원 문헌의 원시 조건이 이미
곱셈 부등식으로 쓰여 있으므로 이 꼴이 형식화의 편의가 아니라 대상의 성질이다.
-/
-- DD:CF-2574
def portfolioLimitMet
    (d : PortfolioLimitDirection) (amount total : ℤ)
    (th : PortfolioLimitThreshold) : Bool :=
  match d with
  | .floor => decide (th.den * amount ≥ th.num * total)
  | .cap => decide (th.den * amount ≤ th.num * total)

/--
한 관할권이 거는 한도의 일정.

**대응 비형식 개념:** 그 관할권이 어느 걸림에 어느 문턱을 두는가. 같은 축의 문턱이 관할권마다 다르고
문턱의 수도 다르므로, 일정이 관할권을 들고 걸림마다 문턱을 선택적으로 낸다.

**이 정의가 배제하는 사례:**
같은 관할권이 펀드 유형마다 다른 문턱을 두는 자리. 유럽의 규범이 만기 기준 유동자산의 하한을 펀드
유형마다 두 쌍으로 두므로 한 일정이 한 걸림에 문턱 둘을 내야 하는데, 이 구조는 걸림에서 문턱으로
가는 함수를 하나 들므로 그 갈림을 담지 못한다. 그 자리는 유형마다 일정을 따로 세우는 꼴로만
표현된다(유럽연합).
조달처: E-56 §3-6 「만기 기준 유동자산의 하한이 유럽에서 펀드 유형마다 10% 와 30% 이거나」

**기각한 대체 정의:**
걸림과 문턱의 쌍을 목록으로 두는 안. 그 꼴이 같은 걸림에 문턱 여럿을 담을 수 있으나 같은 걸림이
목록에 두 번 서는 것을 막지 못하고, 전량 판정이 그 중복을 두 번 돌아 같은 조건을 두 번 잰다. 함수로
두면 걸림마다 문턱이 하나로 정해지고 펀드 유형의 갈림은 일정을 둘로 두어 받는다.
-/
-- DD:CF-2574
structure PortfolioLimitSchedule where
  /-- 그 일정을 거는 관할권. -/
  jurisdiction : PortfolioLimitJurisdiction
  /-- 그 걸림에 이 관할권이 두는 문턱. 두지 않으면 없다. -/
  thresholdOf : PortfolioLimitBinding → Option PortfolioLimitThreshold

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `PortfolioLimitSchedule` 이 비어 있지 않음을 증거한다. 국제 기준을 들고
어느 걸림에도 문턱을 두지 않는 일정이며, 유동성 규제의 한도가 몫이 아니라 조정 금액의 배수로 서서
이 파일의 판정이 받지 않으므로 그 관할권의 일정이 이 꼴로 비는 것이 설계다.
-/
-- DD:CF-2574
def PortfolioLimitSchedule.baselEmpty : PortfolioLimitSchedule where
  jurisdiction := .basel
  thresholdOf := fun _ => none

/--
한 주체에 걸린 한도 전량이 충족됐는가.

**대응 비형식 개념:** 그 주체가 자기에게 걸린 한도를 하나도 어기지 않는가. 걸림의 목록이 한 주체에
걸린 한도 전량을 들고 일정이 그 걸림마다 문턱을 내므로, 그 둘을 받아 전량을 판정한다.

**이 정의가 배제하는 사례:**
어기는 결과가 문턱마다 다른 자리. 미국의 규칙이 만기 기준 유동자산의 하한보다 낮은 자리에 문턱을
하나 더 두어 어기는 결과를 취득 금지와 이사회 보고로 가르므로, 전량이 충족됐는가를 한 값으로 내는
이 함수는 어느 문턱이 어겨졌는지를 담지 못한다. 그 자리는 걸림마다 판정을 따로 내는 꼴로만
표현된다(미국 증권거래위원회).
조달처: E-56 §2-14 「그 다음 영업일에 그것을 다루고, 그 뒤 4영업일 안에 이사회에 그 사건을 낳은 사실과 정황의」

**기각한 대체 정의:**
문턱이 없는 걸림을 거짓으로 두는 안. 그러면 일정이 문턱을 두지 않은 걸림이 전량 판정을 거짓으로
만드는데, 한 관할권이 다른 관할권의 걸림에 문턱을 두지 않는 것은 그 한도가 그 관할권에서 서지 않는
것이고 어겨진 것이 아니다. 그래서 문턱이 없는 걸림을 참으로 두고 그 관할권의 일정이 드는 걸림만
판정한다.
-/
-- DD:CF-2574
def allPortfolioLimitsMet
    (s : PortfolioLimitSchedule) (bindings : List PortfolioLimitBinding)
    (amountOf : PortfolioLimitTarget → ℤ) (total : ℤ) : Bool :=
  bindings.all (fun b =>
    match s.thresholdOf b with
    | none => true
    | some th => portfolioLimitMet b.direction (amountOf b.target) total th)

/--
같은 걸림 목록과 같은 금액에 두 일정이 다른 판정을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 문턱이 관할권과 무관하게 정해져 어느 두 일정도
같은 장부에서 갈리지 못해야 한다. 그러면 만기 기준 유동자산의 하한이 유럽과 미국에서 다르다는 조문의
실측이 거짓이 되고, 하한을 구조에 박으면 한 관할권의 값만 담긴다는 기각 사유도 거짓이 된다.

**존재 형태로 진술하는 까닭(T-6):** 두 일정이 다른 판정을 내는 것은 그 둘의 문턱이 갈리는 걸림이
목록에 드는지와 그 대상의 금액이 두 문턱 사이에 드는지에 함께 걸리므로 전칭으로 세우면 거짓이다.
금액이 두 문턱을 함께 넘거나 함께 못 넘으면 두 일정이 같은 판정을 낸다.

**T-3 분류:** 보조 보정이 아니다. 문턱을 관할권을 색인으로 받는 함수로 담은 설계의 효력을 이 명제가
들며, 그 색인이 장식이 아니라 실물을 가른다는 것이 이 자리에서 선다.
-/
-- DD:CF-2574
theorem exists_schedules_differing_on_same_book :
    ∃ (s t : PortfolioLimitSchedule) (bindings : List PortfolioLimitBinding)
      (amountOf : PortfolioLimitTarget → ℤ) (total : ℤ),
      allPortfolioLimitsMet s bindings amountOf total
        ≠ allPortfolioLimitsMet t bindings amountOf total := by
  exact ⟨PortfolioLimitSchedule.baselEmpty,
    { jurisdiction := .europeanUnion, thresholdOf := fun _ => some ⟨1, 10⟩ },
    [PortfolioLimitBinding.dailyLiquidityFloor], fun _ => 0, 1, by decide⟩

end CrisisFramework.Accounting
