/-
관측층 — 노드의 사건과 그 집계와 위계의 동급이 읽히는 경로

규율: L-14(값을 담지 않는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), T-2(반증 조건), T-3(분류), A-3(witness),
      A-8(논리 결합의 증거).

**값을 담지 않는다.** 이 파일은 어느 공시 경로가 무엇을 내는지의 명세만 담고 금액도 계수도 담지
않는다. 노드의 사건과 그 집계의 문턱과 위계의 동급에 소스가 없다는 것이 이 파일의 산출이다.

**판정 불가의 까닭이 셋으로 갈린다.** 실패가 어느 갈래인가는 런이 없던 세계의 값을 요구하므로 반사실
미평가를 들고, 집계의 문턱은 그 값을 내는 공표가 없으므로 측정 소스 없음을 들며, 위계의 동급을 가르는
것은 재야 할 것이 정해졌으나 그것을 담는 대상이 형식층에 없으므로 구조가 그 대상을 담지 않음을 든다.

**실패의 발생은 관측된다.** 네 물음이 같은 결손을 내지 않는다는 것이 이 파일의 가름이며, 그 가름이
없으면 이 파일이 소스 없음을 네 번 되풀이한 것이 된다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

/--
노드의 사건과 그 집계와 위계의 동급의 네 물음의 공시 경로.

**대응 비형식 개념:** 어느 노드가 상환에 실패했는가와, 그 실패가 지급능력을 잃은 것인가와, 그 사건을
몇 개 모으면 위기라 부르는가와, 보유 강도가 같은 두 주체 가운데 어느 쪽이 위인가를 공표 수치에서 읽을
수 있는가.

**이 정의가 배제하는 사례:**
롤오버 게임의 문턱 값이 그 경로가 된다는 읽기. 그 모형이 비유동성 위험을 런이 없었다면 생존했을 은행이
런으로 실패할 확률로 두므로 그 값이 모형의 출력이고 공표 수치가 아니며, 모형 출력을 경로로 넣으면 공시
경로와 모형 출력이 한 목록에 섞인다.
조달처: E-17 §2-3 「런이 없었다면 생존했을 은행이 런으로 실패할 확률」

**기각한 대체 정의:**
경로의 이름만 담고 무엇에 답하는지를 담지 않는 안. 그러면 소스 없음이 무엇에 대한 없음인지가 서지
않아 관측층에 등재되는 소스 없음이 산출로 읽히지 않는다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정이며 수를 들지 않는다.
-/
-- DD:CF-4118
structure EventAggregationChannel (Node : Type) where
  /-- 그 경로를 내는 쪽. -/
  publisher : Node
  /-- 어느 노드가 상환에 실패했는가를 그 경로가 내는가. -/
  showsFailureEvent : Bool
  /-- 그 실패가 지급능력을 잃은 것인가를 그 경로가 내는가. -/
  showsEventKind : Bool
  /-- 그 사건을 몇 개 모으면 그 판정이 서는가를 그 경로가 내는가. -/
  showsThreshold : Bool
  /-- 보유 강도가 같은 두 주체 가운데 어느 쪽이 위인가를 그 경로가 내는가. -/
  showsHierarchyTie : Bool

/-- witness (A-3). **무엇을 증거하는가.** `EventAggregationChannel` 이 비어 있지 않다. 어느 칸도
내지 않는 경로 하나를 든다. -/
-- DD:CF-4118
def EventAggregationChannel.noSource : EventAggregationChannel Unit where
  publisher := ()
  showsFailureEvent := false
  showsEventKind := false
  showsThreshold := false
  showsHierarchyTie := false

/--
그 경로가 실패의 발생을 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 어느 노드가 상환에 실패했는지를 말할 수 있는가.

**이 정의가 배제하는 사례:**
실패의 발생도 관측되지 않는다고 보는 읽기. 레버리지 제약을 다룬 편이 이름을 든 기관들의 런을 채권자
각자가 자기 제약에 따라 합리적으로 익스포저를 줄인 결과로 재해석하므로 그 실패가 일어났다는 사실은 그
재해석의 전제이고 관측된 것이다.
조달처: E-03 §3-4 「채권자 각자가 자기 제약에 따라 합리적으로 익스포저를 줄인 결과」

**기각한 대체 정의:**
답함을 네 칸의 논리합으로 두는 안. 그러면 다른 물음에 답하는 경로가 이 물음에도 답하는 것으로 세어진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4118
def EventAggregationChannel.answersFailureEvent {Node : Type}
    (C : EventAggregationChannel Node) : Bool :=
  C.showsFailureEvent

/--
그 경로가 실패의 갈래를 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 그 실패가 지급능력을 잃은 것인지 잃지 않은 것인지를 말할 수
있는가.

**이 정의가 배제하는 사례:**
사후에 자료가 쌓이면 그 가름이 풀린다고 보는 읽기. 그 편을 읽은 기록이 저자들이 사후에도 구별이 쉽지
않다고 적는 대목을 들어 그 막힘을 반사실 쪽으로 돌리므로, 자료의 축적이 그 가름을 풀지 않는다.
조달처: E-17 §3-2 「반사실 미평가는 소스의 문제가 아니라 대상의 문제이므로」

**기각한 대체 정의:**
답함을 실패의 발생과 같은 칸으로 두는 안. 발생은 공표되고 갈래는 공표되지 않으므로 한 칸에 두면 있는
소스가 없는 소스를 가린다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4118
def EventAggregationChannel.answersEventKind {Node : Type}
    (C : EventAggregationChannel Node) : Bool :=
  C.showsEventKind

/--
그 경로가 집계의 문턱을 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 그 사건을 몇 개 모으면 그 판정이 서는지를 말할 수 있는가.

**이 정의가 배제하는 사례:**
단일 노드 모형의 확률이 그 답을 준다는 읽기. 그 편을 읽은 기록이 위기가 노드별 사건의 어떤 집계인지는
이 편에서 나오지 않는다고 적으므로, 한 노드의 실패 확률이 공표되어도 그 문턱이 거기서 나오지 않는다.
조달처: E-17 §4-4 「위기가 노드별 사건의 어떤 집계인지는 이 편에서 나오지 않으며」

**기각한 대체 정의:**
답함을 실패의 갈래와 같은 칸으로 두는 안. 갈래는 재야 할 대상이 실현되지 않아 막히고 문턱은 재야 할
대상이 정해졌는데 그것을 내는 자리가 없어 막히므로, 한 칸에 두면 풀리지 않는 막힘과 조달로 풀리는
막힘이 접힌다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4118
def EventAggregationChannel.answersThreshold {Node : Type}
    (C : EventAggregationChannel Node) : Bool :=
  C.showsThreshold

/--
그 경로가 위계의 동급을 가르는 것을 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 보유 강도가 같은 두 주체 가운데 어느 쪽이 위인지를 말할 수
있는가.

**이 정의가 배제하는 사례:**
원문의 표가 그 답을 준다는 읽기. 그 표가 네 사분면을 액면가 약속의 강도가 감소하는 순서로 두고 주체마다
그 주체에게 화폐인 것을 하나씩 드는데, 두 주체가 같은 사분면에 들면 그 표가 둘을 가르지 않는다.
조달처: E-07 §2-1 「네 사분면은 "액면가 약속의 강도"가 감소하는 순서를 이룬다」

**기각한 대체 정의:**
답함을 집계의 문턱과 같은 칸으로 두는 안. 문턱은 재야 할 것을 담는 대상이 형식층에 있고 그것을 내는
공표가 없어 막히는데 동급은 그 대상 자체가 형식층에 없어 막히므로, 한 칸에 두면 조달로 풀리는 막힘과
구조를 더해야 풀리는 막힘이 접힌다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4118
def EventAggregationChannel.answersHierarchyTie {Node : Type}
    (C : EventAggregationChannel Node) : Bool :=
  C.showsHierarchyTie

/--
감독 당국의 실패 기록.

**대응 비형식 개념:** 어느 기관이 상환에 실패했는지가 남는 공적 기록. 그 실패가 일어났다는 것은 거기
서나 그것이 어느 갈래인지는 거기 서지 않는다.

**이 정의가 배제하는 사례:**
그 기록이 갈래를 낸다는 읽기. 그 편을 읽은 기록이 저자들이 사후에도 구별이 쉽지 않다고 적는 대목을 들어
그 막힘을 반사실 쪽으로 돌리므로, 같은 기록이 두 읽기를 함께 받는다.
조달처: E-17 §3-2 「반사실 미평가는 소스의 문제가 아니라 대상의 문제이므로」

**기각한 대체 정의:**
갈래의 칸을 참으로 두는 안. 그 기록이 실패의 날짜와 규모를 담고 그 기관이 지급능력을 잃었는지는 담지
않으므로, 참으로 두면 공표되지 않은 판정이 그 기록에서 나오는 것으로 읽힌다. 이 경로를 목록에서 빼는
안도 기각했다. 그 기록이 실패의 발생을 실제로 내므로 빼면 네 물음이 전부 결손으로 접히고 그 가름이
사라진다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정이다.
-/
-- DD:CF-4118
def supervisoryFailureRecord : EventAggregationChannel Unit where
  publisher := ()
  showsFailureEvent := true
  showsEventKind := false
  showsThreshold := false
  showsHierarchyTie := false

/--
원문의 화폐 매트릭스 표.

**대응 비형식 개념:** 주체마다 그 주체에게 화폐인 것을 하나씩 든 표. 그 강도는 거기 서나 같은 강도를
드는 두 주체를 가르는 것은 거기 서지 않는다.

**이 정의가 배제하는 사례:**
그 표가 동급을 가른다는 읽기. 그 표가 네 사분면을 액면가 약속의 강도가 감소하는 순서로 두는데 딜러
정부데스크와 정부전용 머니펀드가 같은 사분면에 들어 그 표의 값으로는 둘이 갈리지 않는다.
조달처: E-07 §2-1 「네 사분면은 "액면가 약속의 강도"가 감소하는 순서를 이룬다」

**기각한 대체 정의:**
동급의 칸을 참으로 두는 안. 그 가름을 알려면 발행자를 한 겹 더 유도해야 하고 그 사상이 구조에 없으므로,
참으로 두면 관측층이 받을 구조의 결손이 해소된 것으로 읽힌다. 이 경로를 목록에서 빼는 안도 기각했다.
칸이 전부 거짓인 경로가 목록에 서는 것이 그 물음에 답하는 자리가 없다는 관측을 드는 유일한 꼴이다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정이다.
-/
-- DD:CF-4118
def moneyMatrixTable : EventAggregationChannel Unit where
  publisher := ()
  showsFailureEvent := false
  showsEventKind := false
  showsThreshold := false
  showsHierarchyTie := false

/--
이 회차가 든 경로의 목록.

**대응 비형식 개념:** 네 물음을 낼 수 있을 법한 경로를 모은 것.

**이 정의가 배제하는 사례:**
단일 노드 모형의 분해를 이 목록에 넣는 읽기. 그 편을 읽은 기록이 위기가 노드별 사건의 어떤 집계인지는
이 편에서 나오지 않는다고 적으므로, 그 분해를 경로로 넣으면 모형의 출력이 공시 경로와 한 목록에 섞인다.
조달처: E-17 §4-4 「위기가 노드별 사건의 어떤 집계인지는 이 편에서 나오지 않으며」

**기각한 대체 정의:**
목록을 물음마다 따로 두는 안. 그러면 한 경로가 여러 목록에 들고 그 중복이 관측 결과의 계산에서
되풀이되며, 경로를 더하는 회차가 어느 목록에 더할지를 매번 고르게 된다.

**수 체계를 받지 않는다.** 목록이 경로를 들며 수를 들지 않는다.
-/
-- DD:CF-4118
def eventAggregationChannels : List (EventAggregationChannel Unit) :=
  [supervisoryFailureRecord, moneyMatrixTable]

/--
실패의 발생이 한 경로에서 관측된다.

**대응 비형식 개념:** 그 목록의 어느 경로가 그 물음에 답하는 것.

**이 정의가 배제하는 사례:**
한 경로라도 답하지 않으면 관측되지 않은 것으로 보는 읽기. 이 물음은 그 목록 전체에 대한 것이고 한
경로의 성질이 아니므로, 경로 하나로 판정하면 목록의 나머지가 읽히지 않는다.
조달처: E-03 §3-4 「채권자 각자가 자기 제약에 따라 합리적으로 익스포저를 줄인 결과」

**기각한 대체 정의:**
참거짓을 내는 안. 한 파일의 네 판정이 한 꼴을 써야 그 결손이 한 기준에서 읽히고, 이 판정만 참거짓으로
두면 소스가 있는 자리와 없는 자리가 다른 타입으로 갈린다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4118
def failureEventObserved {Node : Type}
    (chs : List (EventAggregationChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersFailureEvent) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
실패의 갈래가 어느 경로에서도 관측되지 않으며 그 까닭이 반사실 미평가다.

**대응 비형식 개념:** 그 목록의 어느 경로도 그 물음에 답하지 않으며, 답할 경로를 더해도 답하지 않는 것.
재야 할 대상이 런이 없던 세계에서 그 기관이 생존했을지이고 그 세계가 실현되지 않았다.

**이 정의가 배제하는 사례:**
사후에 자료가 쌓이면 그 가름이 풀린다고 보는 읽기. 그 편을 읽은 기록이 그 막힘을 소스의 문제가 아니라
대상의 문제로 돌리므로, 자료의 축적이 그 가름을 풀지 않는다.
조달처: E-17 §3-2 「반사실 미평가는 소스의 문제가 아니라 대상의 문제이므로」

**기각한 대체 정의:**
까닭을 측정 소스 없음으로 두는 안. 소스가 없는 것이 아니라 재야 할 대상이 실현되지 않은 세계의 값이므로
소스 없음으로 적으면 뜻이 달라지고, 사후에 풀릴 수 있는 막힘과 풀리지 않는 막힘이 한 칸으로 접힌다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4118
def eventKindObserved {Node : Type}
    (chs : List (EventAggregationChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersEventKind) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.counterfactualUnevaluated

/--
집계의 문턱이 어느 경로에서도 관측되지 않는다.

**대응 비형식 개념:** 그 목록의 어느 경로도 그 물음에 답하지 않는 것. 재야 할 것은 정해졌으나 그것을
내는 자리가 없다.

**이 정의가 배제하는 사례:**
단일 노드 모형의 확률이 그 답을 준다는 읽기. 그 편을 읽은 기록이 그 집계가 이 편에서 나오지 않는다고
적으므로 그 확률이 공표되어도 문턱이 거기서 나오지 않는다.
조달처: E-17 §4-4 「위기가 노드별 사건의 어떤 집계인지는 이 편에서 나오지 않으며」

**기각한 대체 정의:**
까닭을 구조가 그 대상을 담지 않음으로 두는 안. 문턱을 담는 대상이 이 회차에 정의층으로 섰으므로 구조의
결손이 아니라 그 값을 내는 공표의 결손이며, 구조 쪽으로 적으면 조달로 풀릴 수 있는 막힘이 풀리지 않는
것으로 읽힌다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4118
def aggregationThresholdObserved {Node : Type}
    (chs : List (EventAggregationChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersThreshold) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
위계의 동급을 가르는 것이 어느 경로에서도 관측되지 않으며 그 까닭이 구조의 결손이다.

**대응 비형식 개념:** 그 목록의 어느 경로도 그 물음에 답하지 않으며, 재야 할 것을 담는 대상이 형식층에
없는 것. 보유 사상이 강도만 내고 발행자를 내지 않는다.

**이 정의가 배제하는 사례:**
원문의 표가 그 답을 준다는 읽기. 그 표가 주체마다 그 주체에게 화폐인 것을 하나씩 드는데 두 주체가 같은
사분면에 들면 그 표의 값으로는 둘이 갈리지 않는다.
조달처: E-07 §2-1 「네 사분면은 "액면가 약속의 강도"가 감소하는 순서를 이룬다」

**기각한 대체 정의:**
까닭을 측정 소스 없음으로 두는 안. 소스를 더해도 그 가름이 서지 않고 보유 사상에 발행자의 자리가 서야
풀리므로, 소스 없음으로 적으면 조달로 풀리는 막힘으로 읽혀 그 결손의 성격이 바뀐다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4118
def hierarchyTieObserved {Node : Type}
    (chs : List (EventAggregationChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersHierarchyTie) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.structureLacksTarget

/--
실패의 발생은 한 경로에서 관측된다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
감독 당국의 실패 기록이 그 발생을 내지 않아야 한다. 그 관측은 그 실패가 어디에도 남지 않는다는 뜻이며,
그러면 네 물음이 같은 결손을 내어 판정을 넷으로 가른 것이 값을 잃는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 네 물음이 같은 결손을 내지 않는다는 것을 드는 유일한 자리이고, 그 가름이 없으면
이 파일이 결손을 네 번 되풀이한 것이 된다.
-/
-- DD:CF-4118
theorem failure_event_observed_determined :
    failureEventObserved eventAggregationChannels = ObservedTruth.holds := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
실패의 갈래가 반사실 미평가로 판정 불가다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 측정 소스 없음을 내거나 성립을 내야 한다. 앞은 그 막힘이 소스의 문제라는 뜻이고 뒤는 그
가름이 자료에서 선다는 뜻이며, 어느 쪽이든 그 두 사건을 용어집의 분할로 등재하지 않는다는 판정의 근거가
바뀐다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 지급능력을 잃은 실패와 잃지 않은 실패의 측정 대응이 판정 불가의 까닭에서만
갈린다는 것을 구조 안의 값으로 드는 유일한 자리이고, 그 까닭이 이 회차의 등재 판정을 정한다.
-/
-- DD:CF-4118
theorem event_kind_observed_counterfactual :
    eventKindObserved eventAggregationChannels
      = ObservedTruth.undetermined UndeterminedReason.counterfactualUnevaluated := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
집계의 문턱에 측정 소스가 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 회차가 든 경로 가운데 하나가 그 사건을 몇 개 모으면 그 판정이 서는지를 내야 한다. 그 관측은 그
문턱이 공표되는 자리가 있다는 뜻이며, 그러면 집계의 꼴 선택이 자료에서 정해진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 이 프레임워크의 주요 산출 가운데 하나이고, 이
회차가 세운 집계가 가를 수 있는 것을 자료가 정하지 못한다는 사실을 드는 유일한 자리다.
-/
-- DD:CF-4118
theorem aggregation_threshold_observed_undetermined :
    aggregationThresholdObserved eventAggregationChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
위계의 동급을 가르는 것이 구조의 결손으로 판정 불가다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 측정 소스 없음을 내거나 성립을 내야 한다. 앞은 소스를 더하면 그 가름이 선다는 뜻이고 뒤는 그
가름이 이미 자료에서 선다는 뜻이며, 어느 쪽이든 그 동급을 가르는 것이 보유 사상의 입도 밖에 있다는
성격 확정이 무너진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 성격 확정이 형식층의 두 정리에 이어 측정의 자리에서도 선다는 것을 드는 유일한
자리이고, 그 까닭이 조달로 풀리는 결손과 갈린다는 것이 이 파일의 가름이다.
-/
-- DD:CF-4118
theorem hierarchy_tie_observed_structure_lacks :
    hierarchyTieObserved eventAggregationChannels
      = ObservedTruth.undetermined UndeterminedReason.structureLacksTarget := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
네 답함이 각 칸에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 답함이 자기 칸이 아닌 칸을 읽어야 한다. 그 관측은 네 답함이 같은 칸을 읽는다는 뜻이며, 그러면
판정을 넷으로 가른 것이 이름만 다른 넷이 된다.

**존재 형태로 진술하는 까닭(T-6):**
칸마다 그 하나만 참인 경로를 들어야 보인다. 임의의 경로에서 각 칸이 홀로 가르는 것이 아니라 나머지가
거짓인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 답함의 정의를 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 논리
결합마다 각 인자가 홀로 값을 가르는 경로를 증거로 들라는 A-8 의 요구가 이 자리에 걸린다.
-/
-- DD:CF-4118
theorem event_channel_answers_pin_each_field :
    ∃ C₁ C₂ C₃ C₄ : EventAggregationChannel Unit,
      C₁.answersFailureEvent = true ∧ C₁.answersEventKind = false ∧
        C₁.answersThreshold = false ∧ C₁.answersHierarchyTie = false ∧
      C₂.answersFailureEvent = false ∧ C₂.answersEventKind = true ∧
        C₂.answersThreshold = false ∧ C₂.answersHierarchyTie = false ∧
      C₃.answersFailureEvent = false ∧ C₃.answersEventKind = false ∧
        C₃.answersThreshold = true ∧ C₃.answersHierarchyTie = false ∧
      C₄.answersFailureEvent = false ∧ C₄.answersEventKind = false ∧
        C₄.answersThreshold = false ∧ C₄.answersHierarchyTie = true := by
  -- 칸마다 하나만 참인 경로 넷을 든다. 답함이 자기 칸을 그대로 읽으므로 칸마다 계산하면 값이
  -- 나와 `rfl` 로 닫힌다.
  exact ⟨⟨(), true, false, false, false⟩, ⟨(), false, true, false, false⟩,
    ⟨(), false, false, true, false⟩, ⟨(), false, false, false, true⟩,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Observation
