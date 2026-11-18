/-
회계층 — 회계값에서 노드의 사건으로 가는 사상

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(총액 기준으로 닫고 순액으로 닫지 않는다),
      C-9(전면 `simp` 금지), A-6(기준선 차분), T-2(반증 조건), T-3(분류), T-6(존재 형태).

**수 체계: `ℤ`.** 다섯 인자가 전부 최소 화폐단위의 정수배이며 회계층의 기본 수 체계다.

**이 파일이 세우는 것은 회계값에서 노드의 사건으로 가는 사상이다.** 정의층이 노드에 일어난 일을
넷으로 열거하고 그 위의 집계를 세웠으나 그 사건이 무엇에서 오는지는 정의층이 담지 않는다. 금액은
회계층의 값이므로 그 사상이 이 자리에 선다.

**그 사상이 받는 것이 다섯이고 넷이 금액이며 하나가 참거짓이다.** 상환 실패의 판정이 의무액과
지급액을 받고 지급능력의 판정이 자산 총액과 부채 총액을 받으며, 대차대조표를 줄였는가는 뭉치의 편마다
그 대상이 갈려 봉합할 수 없으므로 밖에서 받는다.

**연결이 노출로 들어온다.** 생존자 자본이 지는 손실이 상대방에 대한 노출과 채무자가 맡긴 담보에서
나오고 그 노출이 곧 그 쌍의 이어짐이므로, 같은 배치에서 그 손실만 달리하면 연결의 유무가 집계에
무엇을 하는지가 재어진다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.LossBearer
import CrisisFramework.Definition.NodeEvent
import CrisisFramework.Accounting.LossTransmission
import CrisisFramework.Accounting.Repayment

namespace CrisisFramework.Accounting

open CrisisFramework.Definition

/--
회계값에서 노드의 사건으로 가는 사상.

**대응 비형식 개념:** 한 구간의 의무액과 지급액과 자산 총액과 부채 총액과 대차대조표의 감소 여부가
주어졌을 때 그 노드에 일어난 일의 갈래.

**이 정의가 배제하는 사례:**
상태 변수의 분산이 영으로 가도 남는 화재판매의 실패. 그 모형이 상태 변수가 지급능력 문턱 바로 위일 때
대차대조표 훼손만으로 실패가 난다고 적는데, 이 사상은 그 구간의 다섯 값만 읽고 그 실패가 매각의 손상을
거쳐 왔는지를 읽지 않으므로 그 경로가 여기서 사라진다.
조달처: E-17 §2-5 「대차대조표 훼손만으로 실패가 나므로」

**기각한 대체 정의:**
대차대조표의 감소를 자산 총액의 두 시점 값에서 계산하는 안. 뭉치의 편마다 조정이 줄이는 대상이 갈리고
한 편이 자기자본과 예금을 고정으로 두고 비핵심 부채만 움직이는 모형을 세우므로, 자산 쪽에서만 계산하면
그 편의 조정이 무변동으로 세어진다. 지급능력의 판정을 상환 실패의 판정 안에서 부르는 안도 기각했다. 두
판정이 읽는 값이 다르고 서로를 함의하지 않으므로 부르면 네 인자가 한 판정의 서명에 섞인다.

**수 체계를 받지 않는다.** 네 인자가 `ℤ` 이며 회계층의 기본 수 체계다.
-/
-- DD:CF-4125
def eventOf (dueAmount paidAmount assetTotal liabilityTotal : ℤ) (reduced : Bool) : NodeEvent :=
  if failsRepayment dueAmount paidAmount then
    (if isSolvent assetTotal liabilityTotal then NodeEvent.failedWhileSolvent
     else NodeEvent.failedWhileInsolvent)
  else
    (if reduced then NodeEvent.adjusted else NodeEvent.unchanged)

/--
그 사상이 네 갈래를 전부 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
다섯 값의 어느 배치에서도 어느 한 갈래가 나오지 않아야 한다. 그 관측은 그 갈래가 회계값에서 닿지 않는
자리에 있다는 뜻이며, 그러면 사건을 넷으로 가른 것 가운데 하나가 집계의 자리에서 설 수 없다.

**존재 형태로 진술하는 까닭(T-6):**
갈래마다 그것을 내는 배치를 들어야 보인다. 임의의 배치에서 넷이 전부 나오는 것이 아니라 각 갈래를 내는
배치가 실재하는 것이 이 정리가 드는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 정의층의 열거가 회계값에서 닿는다는 것을 드는 유일한 자리이고, 닿지 않는 갈래가
있으면 그 열거가 집계의 자리에서 값을 잃는다.
-/
-- DD:CF-4125
theorem exists_eventOf_all_four :
    ∃ a b c d : ℤ × ℤ × ℤ × ℤ × Bool,
      eventOf a.1 a.2.1 a.2.2.1 a.2.2.2.1 a.2.2.2.2 = NodeEvent.unchanged ∧
      eventOf b.1 b.2.1 b.2.2.1 b.2.2.2.1 b.2.2.2.2 = NodeEvent.adjusted ∧
      eventOf c.1 c.2.1 c.2.2.1 c.2.2.2.1 c.2.2.2.2 = NodeEvent.failedWhileSolvent ∧
      eventOf d.1 d.2.1 d.2.2.1 d.2.2.2.1 d.2.2.2.2 = NodeEvent.failedWhileInsolvent := by
  -- 의무액 하나를 다 낸 배치 둘과 하나도 내지 못한 배치 둘을 든다. 다 낸 쪽은 대차대조표의 감소
  -- 여부로 무변동과 조정이 갈리고, 내지 못한 쪽은 부채 총액이 자산 총액을 넘는지로 두 실패가
  -- 갈린다. 정수 리터럴 위의 계산이므로 칸마다 `decide` 가 닫는다.
  exact ⟨(1, 1, 0, 0, false), (1, 1, 0, 0, true), (1, 0, 0, 0, false), (1, 0, 0, 1, false),
    by decide, by decide, by decide, by decide⟩

/--
같은 배치에서 생존자가 지는 손실만 달리하면 집계가 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
노출이 담보에 미치지 못해 생존자 손실이 영인 자리와 그 손실이 양인 자리가 어느 배치에서도 같은 집계
값을 내야 한다. 그 관측은 전달된 손실이 집계에 닿지 않는다는 뜻이며, 그러면 연결 구조가 전파 규모를
키우는지를 묻는 자리가 이 구조에서 재어지지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
손실의 크기와 부채가 얼마나 줄어드는가가 둘 다 외생이고 구조가 그 값을 담지 않으므로 전칭으로 세우면
그 외생값에 대한 가정을 진술에 얹어야 한다. 그리고 전파의 규모가 연결 구조에 비례한다는 절은 전칭으로
세우면 거짓이며 연결 없이도 여지가 주는 배치가 같은 층에 이미 서 있다.

**가정을 두지 않는다.** 존재 진술이므로 증인이 그 조건을 자기 값으로 든다.

**연결이 무관하다는 반대 전칭을 세우지 않는다.** 레버리지 제약을 다룬 편이 연쇄 디폴트가 필요하지
않다고만 적고 무관하다고 적지 않으므로 그 전칭을 받칠 근거가 없다. 이 진술과 같은 층의 연결 없는 존재
정리가 함께 서면 연결이 규모에 영향을 주되 비례하지 않는다는 것이 두 자리에서 읽힌다.

**T-3 분류:** 기여다. 연결 구조가 전파 규모를 키우는지를 묻는 구멍을 처분하는 자리이고, 집계가 그
물음에 닿는다는 것을 드는 유일한 자리다.
-/
-- DD:CF-4125
theorem exists_exposureRaisesAggregate :
    ∃ (A : EventAggregation Bool) (exposureFree exposureLinked obligorCollateral : ℤ)
      (dueAmount paidAmount assetTotal liabilityTotal : Bool → ℤ),
      lossBorneBy LossBearer.survivorCapital exposureFree obligorCollateral = 0 ∧
      0 < lossBorneBy LossBearer.survivorCapital exposureLinked obligorCollateral ∧
      A.fires (fun n => eventOf (dueAmount n)
        (paidAmount n - lossBorneBy LossBearer.survivorCapital exposureFree obligorCollateral)
        (assetTotal n) (liabilityTotal n) false) = false ∧
      A.fires (fun n => eventOf (dueAmount n)
        (paidAmount n - lossBorneBy LossBearer.survivorCapital exposureLinked obligorCollateral)
        (assetTotal n) (liabilityTotal n) false) = true := by
  -- 실패 둘을 세고 문턱이 하나인 집계와, 의무액 하나를 다 내고 지급능력 조건이 서는 두 노드를
  -- 든다. 노출이 영이면 담보가 그것을 덮어 생존자 손실이 영이므로 두 노드가 무변동이고 집계가 서지
  -- 않는다. 노출이 담보를 하나 넘으면 그 손실이 지급액을 깎아 두 노드가 실패하고 집계가 선다. 정수
  -- 리터럴 위의 계산이므로 칸마다 `decide` 가 닫는다.
  exact ⟨⟨[true, false], (fun e => match e with
      | .unchanged => false
      | .adjusted => false
      | .failedWhileSolvent => true
      | .failedWhileInsolvent => true), 1⟩,
    0, 2, 1, fun _ => 1, fun _ => 1, fun _ => 1, fun _ => 0,
    by decide, by decide, by decide, by decide⟩

end CrisisFramework.Accounting
