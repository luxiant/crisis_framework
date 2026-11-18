/-
관측층 — 신호의 출처와 조달 실패의 기제가 읽히는 경로

규율: L-14(값을 담지 않는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), T-2(반증 조건), T-3(분류), A-3(witness),
      A-8(논리 결합의 증거).

**값을 담지 않는다.** 이 파일은 어느 공시 경로가 무엇을 내는지의 명세만 담고 금액을 담지 않는다.
어느 청구권의 발동이 어느 신호를 움직이는지와 조달의 철회가 어느 기제에서 왔는지에 소스가 없다는 것이
이 파일의 산출이다.

**판정 불가의 까닭이 두 축에서 갈린다.** 신호의 출처는 그 값을 내는 공시 경로가 없는 것이므로 측정
소스 없음을 들고, 조달 실패의 기제는 재야 할 대상이 런이 없던 세계의 값이므로 반사실 미평가를 든다.
소스가 없는 것과 대상이 실현되지 않은 것이 다른 막힘이고, 뒤를 소스 없음으로 적으면 뜻이 달라진다.

**철회의 발생은 관측된다.** 세 물음이 같은 결손을 내지 않는다는 것이 이 파일의 가름이며, 그 가름이
없으면 이 파일이 소스 없음을 세 번 되풀이한 것이 된다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

/--
신호의 출처와 조달 실패의 세 물음의 공시 경로.

**대응 비형식 개념:** 어느 청구권의 발동이 어느 외생 신호를 움직이는가와, 조달의 철회가 채권자 사이의
조정 실패에서 왔는가 각자의 제약이 조인 데서 왔는가와, 그 철회가 일어났는가를 공표 수치에서 읽을 수
있는가.

**이 정의가 배제하는 사례:**
계약의 문면이 그 경로가 된다는 읽기. 원 문헌이 계약을 사건을 소비하고 방출하는 오토마톤으로 두고 한
계약의 출력 사건이 다른 계약의 입력 사건이 된다고 적으나, 그 입출력의 짝은 그 두 계약의 문면을 함께
읽어야 서고 그 문면이 당사자 사이에만 선다.
조달처: E-22 §2-3 「한 계약의 출력 사건이 다른 계약의 입력 사건이 된다」

**기각한 대체 정의:**
경로의 이름만 담고 무엇에 답하는지를 담지 않는 안. 그러면 소스 없음이 무엇에 대한 없음인지가 서지
않아 관측층에 등재되는 소스 없음이 산출로 읽히지 않는다.

**수 체계를 받지 않는다.** 네 칸이 전부 판정과 열거이며 수를 들지 않는다.
-/
-- DD:CF-4058
structure SignalOriginChannel (Node : Type) where
  /-- 그 경로를 내는 쪽. -/
  publisher : Node
  /-- 어느 청구권의 발동이 어느 신호를 움직이는가를 그 경로가 내는가. -/
  showsSignalOrigin : Bool
  /-- 조달의 철회가 어느 기제에서 왔는가를 그 경로가 내는가. -/
  showsFailureMechanism : Bool
  /-- 조달의 철회가 일어났는가를 그 경로가 내는가. -/
  showsWithdrawalEvent : Bool

/-- witness (A-3). **무엇을 증거하는가.** `SignalOriginChannel` 이 비어 있지 않다. 어느 칸도
내지 않는 경로 하나를 든다. -/
-- DD:CF-4058
def SignalOriginChannel.noSource : SignalOriginChannel Unit where
  publisher := ()
  showsSignalOrigin := false
  showsFailureMechanism := false
  showsWithdrawalEvent := false

/--
그 경로가 신호의 출처를 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 어느 청구권의 발동이 어느 신호를 움직이는지를 말할 수 있는가.

**이 정의가 배제하는 사례:**
디폴트의 공표가 그 답을 준다는 읽기. 원 문헌이 한 계약이 다른 계약의 디폴트 상태로의 전이를 듣고
있고 그것이 기한이익 상실을 부른다고 적으므로, 디폴트가 일어났다는 것과 그것이 어느 계약의 입력이
되는지가 다른 사실이다.
조달처: E-22 §2-3 「계약망을 타고 디폴트가 전파되는 법적 기제」

**기각한 대체 정의:**
답함을 세 칸의 논리합으로 두는 안. 그러면 다른 물음에 답하는 경로가 이 물음에도 답하는 것으로 세어진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4058
def SignalOriginChannel.answersSignalOrigin {Node : Type}
    (C : SignalOriginChannel Node) : Bool :=
  C.showsSignalOrigin

/--
그 경로가 조달 실패의 기제를 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 그 철회가 조정 실패에서 왔는지 제약의 타이트닝에서 왔는지를
말할 수 있는가.

**이 정의가 배제하는 사례:**
철회의 규모가 그 답을 준다는 읽기. 원 문헌이 그 런을 채권자 각자가 자기 제약에 따라 합리적으로
익스포저를 줄인 결과로 재해석하면서 두 견해를 배타적으로 두지 않으므로, 규모가 크다는 것이 어느
기제인지를 말해 주지 않는다.
조달처: E-03 §3-4 「채권자 각자가 자기 제약에 따라 합리적으로 익스포저를 줄인 결과」

**기각한 대체 정의:**
답함을 철회의 발생과 같은 칸으로 두는 안. 발생은 공표되고 기제는 공표되지 않으므로 한 칸에 두면 있는
소스가 없는 소스를 가린다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4058
def SignalOriginChannel.answersFailureMechanism {Node : Type}
    (C : SignalOriginChannel Node) : Bool :=
  C.showsFailureMechanism

/--
그 경로가 철회의 발생을 내는가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 그 철회가 일어났는지를 말할 수 있는가.

**이 정의가 배제하는 사례:**
그 발생도 관측되지 않는다고 보는 읽기. 원 문헌이 이름을 든 세 기관의 런을 재해석의 대상으로 삼으므로
그 철회가 일어났다는 사실은 그 재해석의 전제이고 관측된 것이다.
조달처: E-03 §3-4 「시스템 전체에 대한 런은 조정 실패만으로 설명되지 않는다」

**기각한 대체 정의:**
발생을 기제와 한 칸에 두는 안. 그 재해석이 그 둘을 가르는 데서 출발하므로 한 칸에 두면 그 출발점이
구조에서 사라진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4058
def SignalOriginChannel.answersWithdrawalEvent {Node : Type}
    (C : SignalOriginChannel Node) : Bool :=
  C.showsWithdrawalEvent

/--
조달의 철회 기록.

**대응 비형식 개념:** 조달이 끊긴 사건이 남는 기록. 그 철회가 일어났다는 것은 거기 서나 그것이 어느
기제에서 왔는지는 거기 서지 않는다.

**이 정의가 배제하는 사례:**
그 기록이 기제를 낸다는 읽기. 원 문헌이 그 런을 제약의 타이트닝으로 재해석하면서 조정 실패를 배제하지
않고 심각도를 키운다는 것만 인정하므로, 같은 기록이 두 읽기를 함께 받는다.
조달처: E-03 §3-4 「조정 실패가 심각도를 키운다는 것은 인정하되」

**기각한 대체 정의:**
기제의 칸을 참으로 두는 안. 그 기록이 철회의 금액과 시점을 담고 채권자가 왜 철회했는지는 담지 않으므로,
참으로 두면 공표되지 않은 판정이 그 기록에서 나오는 것으로 읽힌다. 이 경로를 목록에서 빼는 안도
기각했다. 그 기록이 철회의 발생을 실제로 내므로 빼면 세 물음이 전부 결손으로 접히고 그 가름이 사라진다.

**수 체계를 받지 않는다.** 네 칸이 전부 판정과 열거다.
-/
-- DD:CF-4058
def fundingWithdrawalRecord : SignalOriginChannel Unit where
  publisher := ()
  showsSignalOrigin := false
  showsFailureMechanism := false
  showsWithdrawalEvent := true

/--
교차 디폴트 조항의 문면.

**대응 비형식 개념:** 한 계약이 다른 계약의 디폴트를 듣고 있다고 적은 조항. 그 문면이 출처의 짝을
들지만 그 문면이 공표되지 않는다.

**이 정의가 배제하는 사례:**
그 조항이 공표되므로 출처가 관측된다는 읽기. 원 문헌이 그 조항을 계약망을 타고 디폴트가 전파되는 법적
기제의 정본 사례로 들면서 계약이 인지하는 입력의 유한 집합을 그 계약의 설계로 두므로, 그 집합이 그
계약의 문면에 있고 그 문면은 당사자 사이에만 선다.
조달처: E-22 §2-3 「계약망을 타고 디폴트가 전파되는 법적 기제」

**기각한 대체 정의:**
출처의 칸을 참으로 두는 안. 그 짝을 알려면 두 계약의 문면을 함께 읽어야 하고 어느 공표도 그 짝을
집계하지 않으므로, 참으로 두면 관측층이 받을 소스 없음이 해소된 것으로 읽힌다. 이 경로를 목록에서 빼는
안도 기각했다. 칸이 전부 거짓인 경로가 목록에 서는 것이 그 물음에 답하는 자리가 없다는 관측을 드는
유일한 꼴이다.

**수 체계를 받지 않는다.** 네 칸이 전부 판정과 열거다.
-/
-- DD:CF-4058
def crossDefaultClauseText : SignalOriginChannel Unit where
  publisher := ()
  showsSignalOrigin := false
  showsFailureMechanism := false
  showsWithdrawalEvent := false

/--
이 회차가 든 경로의 목록.

**대응 비형식 개념:** 세 물음을 낼 수 있을 법한 경로를 모은 것.

**이 정의가 배제하는 사례:**
롤오버 게임의 모형 수치를 이 목록에 넣는 읽기. 그 모형의 문턱이 비원장이고 비유동성의 정의가 반사실이어서
두 막힘이 서로 다르다는 것이 그 기록의 산출이므로, 모형 수치를 경로로 넣으면 공시 경로와 모형 출력이
한 목록에 섞인다.
조달처: E-17 §3-2 「반사실 미평가는 소스의 문제가 아니라 대상의 문제이므로」

**기각한 대체 정의:**
목록을 물음마다 따로 두는 안. 그러면 한 경로가 여러 목록에 들고 그 중복이 관측 결과의 계산에서
되풀이되며, 경로를 더하는 회차가 어느 목록에 더할지를 매번 고르게 된다.

**수 체계를 받지 않는다.** 목록이 경로를 들며 수를 들지 않는다.
-/
-- DD:CF-4058
def signalOriginChannels : List (SignalOriginChannel Unit) :=
  [fundingWithdrawalRecord, crossDefaultClauseText]

/--
신호의 출처가 어느 경로에서도 관측되지 않는다.

**대응 비형식 개념:** 그 목록의 어느 경로도 그 물음에 답하지 않는 것.

**이 정의가 배제하는 사례:**
한 경로라도 답하면 관측된 것으로 보는 읽기. 이 물음은 그 목록 전체에 대한 것이고 한 경로의 성질이
아니므로, 경로 하나로 판정하면 목록의 나머지가 읽히지 않는다.
조달처: E-22 §2-3 「한 계약의 출력 사건이 다른 계약의 입력 사건이 된다」

**기각한 대체 정의:**
참거짓을 내는 안. 소스가 없다는 것과 그 명제가 거짓이라는 것이 다르므로 판정 불가의 칸이 따로
필요하며, 삼분을 드는 열거가 그 칸을 받는다. 그 까닭을 반사실 미평가로 두는 안도 기각했다. 그 짝은
실현된 세계의 사실이고 공표되지 않을 뿐이어서 대상의 문제가 아니라 소스의 문제다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4058
def signalOriginObserved {Node : Type}
    (chs : List (SignalOriginChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersSignalOrigin) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
조달 실패의 기제가 어느 경로에서도 관측되지 않으며 그 까닭이 반사실 미평가다.

**대응 비형식 개념:** 그 목록의 어느 경로도 그 물음에 답하지 않으며, 답할 경로를 더해도 답하지 않는 것.
재야 할 대상이 런이 없던 세계에서 각 채권자가 무엇을 했을지이고 그 세계가 실현되지 않았다.

**이 정의가 배제하는 사례:**
사후에 자료가 쌓이면 그 가름이 풀린다고 보는 읽기. 그 기록이 저자들이 사후에도 구별이 쉽지 않다고
적는 대목을 들어 그 막힘을 반사실 쪽으로 돌리므로, 자료의 축적이 그 가름을 풀지 않는다.
조달처: E-17 §3-2 「사후에도 구별이 쉽지 않다고 적는 대목」

**기각한 대체 정의:**
까닭을 측정 소스 없음으로 두는 안. 소스가 없는 것이 아니라 재야 할 대상이 실현되지 않은 세계의 값이므로
소스 없음으로 적으면 뜻이 달라지고, 사후에 풀릴 수 있는 막힘과 풀리지 않는 막힘이 한 칸으로 접힌다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4059
def failureMechanismObserved {Node : Type}
    (chs : List (SignalOriginChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersFailureMechanism) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.counterfactualUnevaluated

/--
철회의 발생이 한 경로에서 관측된다.

**대응 비형식 개념:** 그 목록의 어느 경로가 그 물음에 답하는 것.

**이 정의가 배제하는 사례:**
그 발생도 어디서도 관측되지 않는다고 보는 읽기. 원 문헌이 이름을 든 세 기관의 런을 재해석의 대상으로
삼으므로 그 철회가 일어났다는 사실이 그 재해석의 전제다.
조달처: E-03 §3-4 「시스템 전체에 대한 런은 조정 실패만으로 설명되지 않는다」

**기각한 대체 정의:**
참거짓을 내는 안. 한 파일의 세 판정이 한 꼴을 써야 그 결손이 한 기준에서 읽히고, 이 판정만 참거짓으로
두면 소스가 있는 자리와 없는 자리가 다른 타입으로 갈린다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4058
def withdrawalEventObserved {Node : Type}
    (chs : List (SignalOriginChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersWithdrawalEvent) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
신호의 출처에 측정 소스가 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 회차가 든 경로 가운데 하나가 어느 청구권의 발동이 어느 신호를 움직이는지를 내야 한다. 그 관측은 그
짝이 공표되는 자리가 있다는 뜻이며, 그러면 상관의 둘째 기제가 자료에서 재어진다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 이 프레임워크의 주요 산출 가운데 하나이고, 이
회차가 세운 출처 구조가 가를 수 있는 것을 자료가 가르지 못한다는 사실을 드는 유일한 자리다.
-/
-- DD:CF-4058
theorem signal_origin_observed_undetermined :
    signalOriginObserved signalOriginChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
조달 실패의 기제가 반사실 미평가로 판정 불가다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 측정 소스 없음을 내거나 성립을 내야 한다. 앞은 그 막힘이 소스의 문제라는 뜻이고 뒤는 그
가름이 자료에서 선다는 뜻이며, 어느 쪽이든 두 유형을 분할하지 않는다는 판정의 근거가 바뀐다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 런의 두 유형을 분할하지 않는 까닭이 측정의 부재가 아니라 대상의 미실현이라는
것을 구조 안의 값으로 드는 유일한 자리이고, 그 까닭이 이 회차의 처분을 정한다.
-/
-- DD:CF-4059
theorem failure_mechanism_observed_counterfactual :
    failureMechanismObserved signalOriginChannels
      = ObservedTruth.undetermined UndeterminedReason.counterfactualUnevaluated := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
철회의 발생은 한 경로에서 관측된다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
조달의 철회 기록이 그 발생을 내지 않아야 한다. 그 관측은 그 철회가 어디에도 남지 않는다는 뜻이며,
그러면 세 물음이 같은 결손을 내어 판정을 셋으로 가른 것이 값을 잃는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 세 물음이 같은 결손을 내지 않는다는 것을 드는 유일한 자리이고, 그 가름이
없으면 이 파일이 결손을 세 번 되풀이한 것이 된다.
-/
-- DD:CF-4058
theorem withdrawal_event_observed_determined :
    withdrawalEventObserved signalOriginChannels = ObservedTruth.holds := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
세 답함이 각 칸에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 답함이 자기 칸이 아닌 칸을 읽어야 한다. 그 관측은 세 답함이 같은 칸을 읽는다는 뜻이며, 그러면
판정을 셋으로 가른 것이 이름만 다른 셋이 된다.

**존재 형태로 진술하는 까닭(T-6):**
칸마다 그 하나만 참인 경로를 들어야 보인다. 임의의 경로에서 각 칸이 홀로 가르는 것이 아니라 나머지가
거짓인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 답함의 정의를 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 논리
결합마다 각 인자가 홀로 값을 가르는 경로를 증거로 들라는 A-8 의 요구가 이 자리에 걸린다.
-/
-- DD:CF-4058
theorem signal_channel_answers_pin_each_field :
    ∃ C₁ C₂ C₃ : SignalOriginChannel Unit,
      C₁.answersSignalOrigin = true ∧
      C₁.answersFailureMechanism = false ∧ C₁.answersWithdrawalEvent = false ∧
      C₂.answersSignalOrigin = false ∧
      C₂.answersFailureMechanism = true ∧ C₂.answersWithdrawalEvent = false ∧
      C₃.answersSignalOrigin = false ∧
      C₃.answersFailureMechanism = false ∧ C₃.answersWithdrawalEvent = true := by
  -- 칸마다 하나만 참인 경로 셋을 든다. 답함이 자기 칸을 그대로 읽으므로 칸마다 계산하면 값이
  -- 나와 `rfl` 로 닫힌다.
  exact ⟨⟨(), true, false, false⟩, ⟨(), false, true, false⟩, ⟨(), false, false, true⟩,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Observation
