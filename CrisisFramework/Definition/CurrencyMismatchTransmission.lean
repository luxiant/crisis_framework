/-
정의층 — 통화 불일치가 상환 실패 가능성으로 전달되는 엣지

규율: L-10(정의층은 무차원, 시점 인덱스 `ℕ` 만 예외), L-13(정의층 대상은 시점 인덱스를 갖는
      족으로 선다), L-9(import 방향은 단방향), A-1(`axiom` 금지), A-3(witness 의무),
      C-1·C-2(비구성적 요소 금지), C-3(판정 술어는 `Decidable`), D-1·D-2(docstring 3항목),
      D-3(배제 사례는 실제 문면), D-5(식별자를 저자 표기에서 가져오지 않는다),
      D-7(선행 등록), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시), T-6(존재 형태).

이 파일은 수를 한 번도 쓰지 않는다. 전달이 서는가만 `Bool` 로 들고 그 크기는 담지 않는다.

**이 파일이 세우는 것은 비금융 주체의 통화 불일치가 그 주체의 상환 실패 가능성을 높이는 경로가
어느 주체 쌍에서 어느 불일치 축을 지나 어느 표시 통화의 청구권에서 서는가다.** 그 상환 실패가 보유자의
제약 인자로 옮겨 가는 뒤 고리는 이 파일에 서지 않으며, 그 결손이 구멍으로 등재된다.

**불일치의 축과 청구권의 표시 통화를 따로 받는다.** 순노출형 불일치는 통화 하나로 색인되고 조달형
불일치는 부채 통화와 자산 통화의 쌍으로 색인되므로, 그 두 꼴을 생성자로 갖는 열거가 전달이 지나는
축을 든다. 청구권의 표시 통화는 그 축과 다른 축이어서 인자를 따로 두며, 불일치를 진 채무자에 대한
청구권을 세는 회계층 선언과 `CQ-fin-11` 이 불일치 통화와 표시 통화를 따로 받는 것과 같은 축이다.

**전달의 매개를 이름으로 부르지 않는다.** 상환 실패의 판정이 회계층에 살고 import 방향이
단방향이므로 정의층 선언이 그것을 부를 수 없다. 그래서 이 파일은 엣지의 존재만 받고 그 뜻을
문서화 문면이 산문으로 든다.

**그 쌍 사이에 청구권이 있다는 것을 호출하는 쪽이 보장한다.** 청구권 구조체가 매개변수 일곱을
받아 그것을 이 파일이 받으면 같은 층의 다른 구조체가 둘만 받는 꼴에서 크게 벗어나므로, 회계층의
지급능력 판정이 통화를 가로지르지 않았음을 호출하는 쪽에 맡긴 선례를 옮긴다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.CurrencyMismatch

namespace CrisisFramework.Definition


/--
전달 엣지의 증거가 서는 주체의 열거.

**대응 비형식 개념:** 전달이 주체 둘을 받으므로 그 양변이 서로 다른 값으로 서야 비금융 주체에서
금융 주체로 가는 배치가 증거로 선다. 이 열거의 원소 이름이 원 문헌의 문면에서 오므로 용어집의
선행 등록을 요구하지 않는 색인이다.

**이 정의가 배제하는 사례:**
전달의 양변을 같은 주체로 두어도 그 엣지가 뜻을 갖는다고 보는 자리. 지목 참조로 연 편이 은행
부문을 완전경쟁으로 두고 통화별 자금 시장이 분리된 아래에서 은행이 외화 대출의 자금을 같은 통화로
조달하므로 자기 장부에 통화의 불일치를 남기지 않는다고 적어, 불일치를 가진 주체와 그 청구권을
보유한 주체가 다른 주체로 선다. 이 열거는 그 둘을 다른 원소로 두며, 한 원소로 접으면 자기 전달만
표현되고 그 배치가 원 문헌이 세운 구조와 어긋난다.
조달처: E-65 §2-1 「불일치가 금융 주체에 서지 않고 비금융 주체에만 선다」

**기각한 대체 정의:**
증거의 주체 타입을 앞 페이즈처럼 단위 타입으로 두는 안. 선언이 하나 줄지만 전달이 주체 둘을 받으므로
단위 타입에서는 두 주체가 같아지고 자기 전달만 표현되어, 비금융 주체에서 금융 주체로 가는 배치가
증거로 서지 않는다. 앞 페이즈의 불일치 증거가 주체를 하나만 받아 그 타입으로 족했던 것이고 이 회차의
구조체는 그렇지 않다.
-/
-- DD:CF-2830
inductive TransmissionWitnessNode where
  /-- 통화 불일치를 가진 비금융 주체. -/
  | nonfinancial
  /-- 그 주체에 대한 청구권을 보유한 금융 주체. -/
  | financial
  deriving DecidableEq, Repr

/--
전달이 지나는 좌변 주체의 통화 불일치가 선 축.

**대응 비형식 개념:** 통화 불일치가 순노출형과 조달형으로 갈리고 앞은 통화 하나로, 뒤는 부채 통화와
자산 통화의 쌍으로 색인되므로, 전달이 어느 불일치를 지나는지를 드는 자리가 그 두 꼴을 생성자로 갖는
이 열거다. 생성자의 이름이 용어집에 이미 선 두 개념에서 오므로 용어집의 선행 등록을 요구하지 않는
색인이다.

**이 정의가 배제하는 사례:**
불일치를 한 통화 축의 순포지션으로만 색인하는 자리. 지목 참조로 연 편이 달러로 빌린 돈을 자국통화
금융자산으로 바꾸어 든 상태를 불일치로 들고 부채의 표시 통화와 그 부채가 조달한 자산의 표시 통화가
짝을 이루어야 불일치가 선다고 보므로, 순포지션 하나로는 그 꼴이 서지 않는다. 이 열거는 조달형을 쌍으로
받는 생성자를 두며, 통화 하나로 접으면 조달한 통화로 무엇을 샀는지가 색인에서 사라진다.
조달처: E-64 §2-1 「그래서 순포지션 하나로는 그 꼴이 서지 않는다」

**기각한 대체 정의:**
통화 하나와 선택적인 둘째 통화의 쌍으로 두어 둘째가 비면 순노출형으로 읽는 안. 같은 값을 담으나 둘째
통화의 빔이 축의 이름이 되어, 그 빔을 자산 통화가 정해지지 않은 조달형으로 읽는 자리와 갈리지 않는다.
축의 갈래를 드는 꼬리표와 통화 둘을 따로 받는 안도 기각했다. 순노출 축에서 둘째 통화가 뜻을 갖지 않는
칸으로 남고, 그 칸의 값만 다른 두 색인이 같은 축을 가리키게 된다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4617
inductive MismatchAxis (Currency : Type) where
  /-- 순노출 불일치가 선 통화 축. -/
  | position (c : Currency)
  /-- 조달 연결 불일치가 선 부채 통화와 자산 통화의 쌍. 두 통화가 같은 값도 받으며 그 값에서는
      불일치가 서지 않는다. -/
  | fundingLink (debt asset : Currency)
  deriving DecidableEq, Repr

/--
비금융 주체의 통화 불일치가 그 주체의 상환 실패 가능성을 높이는 경로.

**대응 비형식 개념:** 원 문헌이 기업의 환위험이 은행의 신용위험으로 옮겨 간다고 세우는 그 경로이며,
좌변이 불일치를 가진 주체이고 우변이 그 청구권을 보유한 주체다. 색인에 좌변의 불일치가 선 축과 그
청구권의 표시 통화가 따로 든다.

**이 정의가 배제하는 사례:**
전달이 보유자의 포지션을 직접 바꾼다고 보는 자리. 지목 참조로 연 편의 모형에서 은행이 외화 대출의
자금을 정확히 그 금액만큼 외화로 조달하므로 환율이 움직여도 은행의 장부에 불일치가 서지 않으며,
바뀌는 것은 차입자가 갚을 수 있는가다. 이 구조체는 그 판정만 받고 보유자의 포지션을 받지 않는다.
조달처: E-65 §2-1 「환율이 움직일 때 바뀌는 것은 은행의 포지션이 아니라 차입자가 갚을 수 있는가다」

**기각한 대체 정의:**
엣지를 청구권으로 색인하는 안. 앞 페이즈가 불일치 경로의 입도를 가르면서 청구권이 표시 통화를 필드
하나로 받아 한 청구권은 불일치를 가질 수 없으므로 거래 입도에서는 불일치가 구조적으로 서지 않는다고
적고 그 입도의 생성자를 두지 않았으며, 전달의 좌변이 그 불일치여서 같은 사유가 걸린다. 전달의 세기를
필드로 받는 안도 기각했다. 정의층이 무차원이고 시점 인덱스만 예외이므로 금액이나 확률을 받을 수 없어
막힌다. 조달형의 전달을 따로 세운 구조체로 받는 안과 같은 구조체에 조달형의 판정 필드를 하나 더 두는
안도 기각했다. 용어집의 통화 불일치 전달이 불일치의 갈래를 가리지 않는 한 개념으로 서 있는데 측정
대응의 다름 없이 그것을 둘로 가르고, 같은 주체 쌍과 표시 통화를 두 자리가 따로 받아 그 둘이 갈릴 수
있다. 조달형의 자산 통화만 색인에 더하는 안도 기각했다. 덧붙인 통화가 순노출형에서는 불일치의 축이고
조달형에서는 자산 통화여서 한 인자가 두 뜻을 든다. 조달형 전달의 표시 통화를 부채 통화로 고정하는
안도 기각했다. 그 주체가 부채 통화와 다른 통화로 진 청구권을 지나는 전달이 표현되지 않으며, 불일치를
진 채무자에 대한 청구권을 세는 회계층 선언이 표시 통화 하나를 합의 색인과 불일치 판정의 색인에 함께
쓰는 안을 두 축을 따로 받는 꼴의 대각선이라는 사유로 이미 기각했다.

**좌변이 보유한 금융자산을 지나는 경로는 이 구조체에 서지 않는다.** 우변이 좌변에 대한 청구권을
보유한 주체이고 매개가 좌변의 상환 실패 가능성이므로, 좌변이 보유한 자산을 거두어 그 자산을 발행한
주체의 조달이 주는 경로는 이 구조체가 받지 않으며 그 결손이 구멍으로 등재된다.

**값을 담지 않는다.**
-/
-- DD:CF-4617
structure CurrencyMismatchTransmission (Node Currency : Type) where
  /-- 좌변 주체의 그 축의 불일치가 우변 주체에 대한 그 표시 통화의 청구권을 지나 좌변의 상환 실패
      가능성을 높이는 경로가 서는가. 그 쌍 사이에 그 통화의 청구권이 있다는 것은 호출하는 쪽이
      보장한다. -/
  transmits : Node → Node → MismatchAxis Currency → Currency → Bool

/--
구조가 비어 있지 않음을 보이는 인스턴스.

**무엇을 증거하는가.** `CurrencyMismatchTransmission` 이 비어 있지 않음을 보인다. 어느 쌍에서도 전달이
서지 않는 값이며 그 값이 무엇인지는 우연이므로 존재 정리가 이것을 증거로 쓰지 않는다.
-/
-- DD:CF-4617
def CurrencyMismatchTransmission.trivial :
    CurrencyMismatchTransmission Unit Unit where
  transmits := fun _ _ _ _ => false

/--
그 전달이 시점마다 달라지는 것을 담는 족.

**대응 비형식 개념:** 정의층 대상이 시점 인덱스를 갖는 족으로 서야 하므로 자연수에서 그 구조체로
가는 함수가 그 자리다.

**이 정의가 배제하는 사례:**
전달의 경로가 시점에 무관하게 서거나 서지 않는다고 보는 자리. 지목 참조로 연 편이 쓰는 감독 보고에서
대출의 표시 통화를 담는 칸이 보고 서식의 뒤 시기에 생겼으므로, 같은 쌍에 대해 그 축을 읽을 수 있는
시점과 읽을 수 없는 시점이 갈린다. 이 족은 그 갈림을 인덱스로 받으며, 한 값으로 접으면 그 쌍의
전달이 언제 섰는지가 사라진다.
조달처: E-65 §3-1 「대출의 표시 통화는 그 보고의 뒤 시기에 칸이 생겨 그 시점부터만 읽힌다」

**기각한 대체 정의:**
시점 인덱스를 구조체의 필드로 두는 안. 인덱스를 필드로 넣으면 정의층 대상이 시점 인덱스를 갖는 족으로
서야 하는 요구는 충족되나 같은 시점의 값을 읽는 자리마다 꼴이 갈린다. 앞 페이즈의 두 구조체와 통화
등급 구조체가 모두 인덱스를 구조체 밖에 두고 족을 축약으로 세웠으므로 그 관례가 하나로 서 있다.
-/
-- DD:CF-2830
abbrev CurrencyMismatchTransmissionFamily (Node Currency : Type) :=
  ℕ → CurrencyMismatchTransmission Node Currency

/--
시점에 따라 변하지 않는 전달을 족으로 올린다.

**무엇을 증거하는가.** 족의 축약이 비어 있지 않음을 보이고 상수 전달을 그 꼴로 쓰는 자리를 낸다.
-/
-- DD:CF-2830
def CurrencyMismatchTransmissionFamily.constant {Node Currency : Type}
    (T : CurrencyMismatchTransmission Node Currency) :
    CurrencyMismatchTransmissionFamily Node Currency :=
  fun _ => T

/--
그 주체 쌍과 그 불일치 축과 그 표시 통화에서 전달이 서는지의 판정.

**대응 비형식 개념:** 전달의 존재를 묻는 자리이며 그 세기를 묻지 않는다. 판정이 반환값에서 나오므로
판정 가능성 인스턴스를 따로 세우지 않는다.

**이 정의가 배제하는 사례:**
전달의 세기가 작은 자리를 전달이 서지 않는 자리와 같게 보는 것을 이 판정이 피한다고 여기는 자리.
지목 참조로 연 편이 결론에서 그 신용위험 성분이 대형 미국 은행에서 비교적 작다고 적는데, 작다는 것과
서지 않는다는 것이 다른 사실이므로 이 판정이 그 둘을 한 값으로 접는다. 이 판정은 그 접음을 숨기지 않고
그 갈림을 관측층이 등재한다.
조달처: E-65 §5-1 「대형 미국 은행에서는 그 신용위험 성분이 비교적 작다」

**기각한 대체 정의:**
공역을 열거로 두어 전달의 세기에 눈금을 두는 안. 그 편이 성분의 크기를 말하므로 눈금을 두고 싶어지나,
작다와 크다를 가르는 경계가 어느 편에도 서지 않아 그 눈금이 자의적이다. 불일치의 방향을 세 값의 열거로
둔 선례는 방향이 자료에서 직접 읽히는 것이어서 이 자리와 다르다.
-/
-- DD:CF-4617
def CurrencyMismatchTransmission.transmitted {Node Currency : Type}
    (T : CurrencyMismatchTransmission Node Currency) (from_ to : Node)
    (axis : MismatchAxis Currency) (d : Currency) : Bool :=
  T.transmits from_ to axis d

/--
전달이 서는 배치를 존재 정리에 내주는 증거.

**대응 비형식 개념:** 비금융 주체에서 금융 주체로 가는 쌍에서만 전달이 서고 다른 쌍에서는 서지 않는
배치이며, 존재 정리가 모두 이 값을 딛는다. **불일치 축과 표시 통화를 가리지 않는 것이 설계다.** 순노출
축의 정리가 불일치가 균형인 축과 균형이 아닌 축에서 함께 서는 배치를 요구하고, 조달형 축의 정리가
조달 연결이 선 쌍과 서지 않은 쌍에서 함께 서는 배치를 요구하므로, 축 전량에서 참인 값이 그 요구를
함께 받는다.

**이 정의가 배제하는 사례:**
전달이 서면 모든 주체 쌍에서 같은 세기로 선다고 보는 자리. 지목 참조로 연 편이 결론에서 다른 나라의
은행이 그만큼 감시되고 규제되지 않아 그 성분이 훨씬 클 수 있다고 적으므로, 전달의 엣지가 쌍마다 다르게
선다. 이 증거는 한 쌍에서만 참인 값을 두어 그 비균일을 담으며, 모든 쌍에서 참인 값을 쓰면 그 사실이
증거에서 지워진다.
조달처: E-65 §5-1 「다른 나라의 은행은 그만큼 감시되고 규제되지 않아 그 성분이 훨씬 클 수 있다고 적는다」

**기각한 대체 정의:**
구조가 비어 있지 않음을 보이는 인스턴스를 존재 정리의 증거로 쓰는 안. 앞 페이즈가 같은 안을 기각하면서
그 인스턴스가 구조가 비어 있지 않음을 보이는 자리여서 그 값이 무엇인지가 우연이고 존재 정리가 그것을
증거로 쓰면 그 정리가 그 값에 매달린다고 적었으며, 그 값을 뒤에 고치면 정리가 조용히 다른 것을 말하게
된다. 그 사유가 이 자리에 그대로 걸린다.
-/
-- DD:CF-2830
def transmittingWitness :
    CurrencyMismatchTransmission TransmissionWitnessNode MismatchWitnessCurrency where
  transmits := fun a b _ _ =>
    match a, b with
    | TransmissionWitnessNode.nonfinancial, TransmissionWitnessNode.financial => true
    | _, _ => false

/--
전달의 주체 열거 위에 선 순노출 불일치의 증거.

**대응 비형식 개념:** 한 주체가 한 통화 축에서 균형이고 다른 축에서 부채 초과인 배치이며, 정리 둘이
이 한 값을 함께 딛는다.

**이 정의가 배제하는 사례:**
한 주체의 불일치가 통화 축 전량에서 같은 방향으로 선다고 보는 자리. 지목 참조로 연 편이 유한책임 아래의
디폴트 문턱을 대출의 통화와 수익의 통화 구성의 관계로 세우므로 같은 주체가 어느 통화에서는 노출되고
어느 통화에서는 노출되지 않는다. 이 증거는 두 축에 다른 방향을 두며, 한 방향으로 접으면 그 갈림이
증거에서 사라지고 정리 둘이 서로 다른 인스턴스를 딛게 된다.
조달처: E-65 §2-2 「그 문턱이 대출의 통화와 수익의 통화 구성의 관계로 정해지므로 통화마다 다른 값이 된다」

**기각한 대체 정의:**
불일치 증거를 둘로 세워 균형인 것과 균형이 아닌 것을 따로 두는 안. 증거용 통화 열거가 부채 측과 자산
측 둘이므로 한 인스턴스가 한 통화에서 균형이고 다른 통화에서 부채 초과이면 정리 둘의 증거가 그 하나로
서며, 둘로 늘리면 선언이 하나 늘고 두 정리가 서로 다른 인스턴스를 딛게 되어 그 쌍이 같은 배치에서
섰다는 것이 흐려진다.
-/
-- DD:CF-2830
def transmissionPositionWitness :
    CurrencyPositionMismatch TransmissionWitnessNode MismatchWitnessCurrency where
  directionOf := fun _ c =>
    match c with
    | MismatchWitnessCurrency.debtSide => MismatchDirection.liabilityHeavy
    | MismatchWitnessCurrency.assetSide => MismatchDirection.balanced

/--
전달의 주체 열거 위에서 순노출이 통화 축 전량에서 균형인 증거.

**대응 비형식 개념:** 조달형 축 위의 전달이 순노출 축 전량에서 균형인 주체에서 서는 배치를 정리가
요구하므로, 그 주체의 순노출을 어느 통화에서나 균형으로 두는 자리가 이 선언이다.

**이 정의가 배제하는 사례:**
순노출이 통화 축 전량에서 균형이면 그 주체에 불일치가 없다고 읽는 자리. 지목 참조로 연 편을 읽은 기록이
한 축의 자산과 부채의 차를 재면 조달한 통화로 무엇을 샀는지가 그 값에 들어가지 않는다고 적으므로,
순노출이 어느 통화에서나 균형인 주체도 조달형 불일치를 질 수 있다. 이 증거는 그 균형만 들고 불일치가
없다고 주장하지 않으며, 같은 주체의 조달 연결은 다른 증거가 든다.
조달처: E-64 §2-1 「한 축의 자산과 부채의 차를 재면 조달한 통화로 무엇을 샀는지가 그 값에 들어가지 않는다」

**기각한 대체 정의:**
전달의 주체 열거 위에 선 순노출 증거를 그대로 쓰는 안. 그 증거가 부채 측 통화에서 부채 초과여서
순노출 축 전량에서 균형인 주체가 그 위에 서지 않는다. 그 증거의 부채 측 방향을 균형으로 바꾸는 안도
기각했다. 순노출 축의 정리 가운데 하나가 균형이 아닌 축에서 전달이 서는 배치를 요구하므로, 바꾸면 그
정리의 증거가 사라진다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4617
def transmissionBalancedPositionWitness :
    CurrencyPositionMismatch TransmissionWitnessNode MismatchWitnessCurrency where
  directionOf := fun _ _ => MismatchDirection.balanced

/--
전달의 주체 열거 위에 선 조달 연결 불일치의 증거.

**대응 비형식 개념:** 비금융 주체가 한 통화의 부채로 다른 통화의 자산을 조달한 배치이며, 조달형 축 위의
정리가 모두 이 값을 딛는다.

**이 정의가 배제하는 사례:**
조달형 불일치가 그 청구권을 보유한 금융 주체의 장부에 선다고 보는 자리. 지목 참조로 연 편을 읽은 기록이
그 편이 결판낸 것을 불일치가 서는 장부로 들고, 그 장부가 은행이 아니라 비금융 기업이라고 적는다. 이
증거는 그 연결을 비금융 주체에만 두며, 금융 주체에도 두면 그 문면과 어긋나는 배치가 증거로 선다.
조달처: E-64 §0 「은행이 아니라 비금융 기업이며, 그 꼴이 한 통화 축의 순포지션이 아니라」

**기각한 대체 정의:**
단위 타입의 주체 위에 선 조달 연결 증거를 그대로 쓰는 안. 그 증거의 주체 타입이 전달의 주체 열거와
갈리므로, 전달의 좌변과 같은 주체에 그 연결을 둘 수 없다. 조달 연결을 두 주체 모두에 두는 안도
기각했다. 금융 주체의 장부에 불일치가 서지 않는다는 문면이 그 연결을 금융 주체에서 막으며, 두 주체에
같은 값을 두면 좌변을 가린 정리가 우변에서도 선다는 것이 흐려진다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4617
def transmissionFundingLinkWitness :
    CurrencyFundingLinkMismatch TransmissionWitnessNode MismatchWitnessCurrency where
  fundsAssetIn := fun n debt asset =>
    match n, debt, asset with
    | TransmissionWitnessNode.nonfinancial, MismatchWitnessCurrency.debtSide,
        MismatchWitnessCurrency.assetSide => true
    | _, _, _ => false

/--
불일치가 균형인 순노출 축에서도 전달이 서는 배치가 존재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 명제가 거짓이려면 순노출 축 위에서 전달이 서는 모든 주체 쌍과 축과 표시 통화에서 좌변 주체의 그 축의
순노출 불일치가 균형이 아니어야 한다. 그러려면 전달 구조체가 불일치 구조체를 필드나 가정으로 받아야
하는데 이 파일은 그것을 받지 않으므로, 두 구조체를 독립으로 둔 설계를 바꾸는 것이 그 반증의 조건이다.

**T-3 분류:** 보조 보정이 아니다. **전달의 정의가 불일치를 참조하지 않아 두 구조체가 독립이고,
전달이 불일치에서 나와야 하는데 구조가 그것을 강제하지 않는다는 것이 이 정리의 산출이다.** 그
독립이 정의 구멍이며 그것을 명제로 세우는 것이 이 파일의 기여다.

**가정을 두지 않는다.** 증거를 직접 들어 존재를 보인다.
-/
-- DD:CF-2830
theorem exists_transmission_without_mismatch :
    ∃ a b : TransmissionWitnessNode, ∃ c d : MismatchWitnessCurrency,
      transmittingWitness.transmitted a b (MismatchAxis.position c) d = true
      ∧ transmissionPositionWitness.mismatched a c = false := by
  exact ⟨TransmissionWitnessNode.nonfinancial, TransmissionWitnessNode.financial,
    MismatchWitnessCurrency.assetSide, MismatchWitnessCurrency.assetSide, rfl, rfl⟩

/--
불일치가 균형이 아닌 순노출 축에서 전달이 서는 배치가 존재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 명제가 거짓이려면 좌변 주체가 부채 초과인 순노출 축에서 전달이 서는 쌍이 하나도 없어야 한다.
증거가 그 쌍을 직접 내므로 그 반증은 증거의 값을 바꾸는 것으로만 선다.

**T-3 분류:** 보조 보정이다. 증거의 값을 전개하면 증명이 닫히므로 이 명제는 기여 목록에 들지 않는다.
의도된 배치가 구조에서 구성됨을 보이는 자리이며, 앞 정리가 드는 독립의 반대쪽을 짝으로 세운다.

**가정을 두지 않는다.**
-/
-- DD:CF-2830
theorem exists_transmission_with_mismatch :
    ∃ a b : TransmissionWitnessNode, ∃ c d : MismatchWitnessCurrency,
      transmittingWitness.transmitted a b (MismatchAxis.position c) d = true
      ∧ transmissionPositionWitness.mismatched a c = true := by
  exact ⟨TransmissionWitnessNode.nonfinancial, TransmissionWitnessNode.financial,
    MismatchWitnessCurrency.debtSide, MismatchWitnessCurrency.debtSide, rfl, rfl⟩

/--
순노출이 통화 축 전량에서 균형인 주체에서 조달형 축 위의 전달이 서는 배치가 존재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 명제가 거짓이려면 조달형 축 위에서 전달이 서는 주체마다 순노출이 어느 통화 축에서 균형이 아니거나
그 축의 조달 연결 불일치가 서지 않아야 한다. 그러면 조달형 불일치를 지나는 전달이 순노출만 읽는 판정으로
언제나 가려지므로, 불일치 축을 색인으로 받게 한 설계가 그 자리에서 쓸모를 잃는다.

**존재 형태로 진술하는 까닭(T-6):** 순노출이 균형인 주체에서는 조달형 축 위의 전달이 언제나 선다는
전칭은 거짓이다. 전달은 주체 쌍마다 따로 서고 불일치를 참조하지 않으므로 그 둘이 함께 서는 배치와 그렇지
않은 배치가 모두 실재하며, 이 명제가 드는 것은 앞의 배치가 하나라도 있다는 것이다.

**T-3 분류:** 보조 보정이 아니다. **순노출만 읽는 판정이 그 주체에서 불일치를 하나도 내지 않는데 전달이
조달형 축에서 서는 배치를 구조 안의 명제로 드는 유일한 자리다.** 색인이 표시 통화 하나만 받던 꼴에서는
그 전달이 어느 불일치를 지나는지를 적을 자리가 없었으므로, 이 배치가 구조에서 서는 것이 색인을 넓힌
설계의 산출이다.

**가정을 두지 않는다.** 증거를 직접 들어 존재를 보인다.
-/
-- DD:CF-4617
theorem exists_transmission_via_funding_link_at_balanced_position :
    ∃ a b : TransmissionWitnessNode, ∃ debt asset d : MismatchWitnessCurrency,
      transmittingWitness.transmitted a b (MismatchAxis.fundingLink debt asset) d = true
      ∧ transmissionFundingLinkWitness.mismatched a debt asset = true
      ∧ ∀ c : MismatchWitnessCurrency,
          transmissionBalancedPositionWitness.mismatched a c = false := by
  exact ⟨TransmissionWitnessNode.nonfinancial, TransmissionWitnessNode.financial,
    MismatchWitnessCurrency.debtSide, MismatchWitnessCurrency.assetSide,
    MismatchWitnessCurrency.debtSide, rfl, rfl, fun _ => rfl⟩

/--
조달 연결 불일치가 서지 않는 쌍을 든 조달형 축에서도 전달이 서는 배치가 존재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 명제가 거짓이려면 조달형 축 위에서 전달이 서는 모든 주체 쌍과 통화 쌍과 표시 통화에서 좌변 주체의 그
쌍의 조달 연결 불일치가 서야 한다. 그러려면 전달 구조체가 조달 연결 구조체를 필드나 가정으로 받아야
하는데 이 파일은 그것을 받지 않으므로, 두 구조체를 독립으로 둔 설계를 바꾸는 것이 그 반증의 조건이다.

**존재 형태로 진술하는 까닭(T-6):** 조달형 축 위의 전달이 조달 연결이 서지 않는 쌍에서 언제나 선다는
전칭은 거짓이고 언제나 서지 않는다는 전칭도 거짓이다. 이 명제가 드는 것은 그 축에서도 전달이 불일치와
따로 서는 배치가 하나라도 있다는 것이다.

**T-3 분류:** 보조 보정이 아니다. **불일치 축을 색인에 넣은 것이 전달을 그 축의 불일치에 묶었다고 읽히는
자리를 막는 것이 이 명제의 산출이다.** 순노출 축에서 독립을 드는 정리만 두면 조달형 축의 전달이 그
축의 불일치에서 나오는 것처럼 읽히며, 그 독립이 두 축에서 같은 정의 구멍이라는 것을 이 명제가 든다.

**가정을 두지 않는다.** 증거를 직접 들어 존재를 보인다.
-/
-- DD:CF-4617
theorem exists_transmission_via_funding_link_without_link :
    ∃ a b : TransmissionWitnessNode, ∃ debt asset d : MismatchWitnessCurrency,
      transmittingWitness.transmitted a b (MismatchAxis.fundingLink debt asset) d = true
      ∧ transmissionFundingLinkWitness.mismatched a debt asset = false := by
  exact ⟨TransmissionWitnessNode.nonfinancial, TransmissionWitnessNode.financial,
    MismatchWitnessCurrency.assetSide, MismatchWitnessCurrency.debtSide,
    MismatchWitnessCurrency.assetSide, rfl, rfl⟩

end CrisisFramework.Definition
