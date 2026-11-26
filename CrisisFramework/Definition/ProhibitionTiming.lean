/-
정의층 — 금지가 언제부터 어디까지 걸리는가가 읽히는 자리

규율: L-10(무차원 + 시점 인덱스 `ℕ`), L-13(시점 족), D-2(docstring 3항목),
      D-3(실제 역사 사례), A-3(witness), A-8(논리 결합의 증거), C-3(판정은 `Bool`),
      T-2(반증 조건), T-3(분류), T-6(존재 형태).

**시점을 값으로 두지 않고 구간과 확정성의 짝으로 둔다.** 조달된 공표 꼴의 하나가 기간 요소에 시작과
끝을 선택 자식으로 두고 연과 월과 일의 고정 여부를 각각 필수 속성으로 들므로, 시점을 시점 인덱스
하나로 받으면 그 구조가 담은 불확정성이 그 자리에서 버려진다. 비운 자리가 재지 않았음을 적는 것과
재지 않은 값을 적는 것을 가르는 꼴이 앞 페이즈의 관측 명세에 이미 섰고, 그 꼴을 이 층으로 옮겨 쓴다.

**시점의 축이 둘이고 한 인자로 접지 않는다.** 금지가 언제부터 걸리는가와 그 거래가 딛는 계약이 언제
맺어졌는가가 다른 사건을 가리키며, 조문이 어느 날 이전에 맺은 계약에는 다른 날까지 그 금지가 미치지
않는다고 적으므로 한 거래의 금지 여부가 그 거래의 시점만으로 정해지지 않는다. 접으면 같은 시점에
일어난 두 거래가 딛는 계약의 체결 시점이 달라 갈리는 자리가 그 값에서 사라진다.

**개정의 사슬을 구조가 담지 않는다.** 시점의 축이 개정의 사슬과 조문 본문의 날짜 둘로 서는데, 개정의
사슬은 어느 문면이 어느 문면을 고쳤는가의 관계이고 그것을 담으려면 문면의 동일성이 먼저 서야 한다.
법령 문면의 명명 규약이 한 조문을 판을 가로질러 가리키는 영구한 식별자를 작품에 매어 두고, 유럽연합의
작성 규칙이 끼워 넣은 조 뒤의 번호를 다시 매기지 않으며 다시 매기는 성문화와 재제정에서 대조표가 옛
번호와 새 번호를 잇는다(E-87). 그래서 동일성은 서지만 그 위에서 조문을 작품 단위로 가리키는 색인과
날짜를 단 개정 조작의 열을 세우는 꼴이 정해지지 않았으며, 그 설계를 이연이 받는다. 이 파일은 조문
본문의 날짜로 선 축만 담는다.

**판정 불가의 열거를 이 층에 따로 세운다.** 관측층에도 판정 불가를 품은 열거가 서 있으나 그것을
끌어오면 적재 방향이 뒤집힌다. 그 열거가 묻는 것은 그 물음을 내는 공표 경로가 있는가이고 이 열거가
묻는 것은 받은 구간이 그 시점을 가르는가이므로, 둘이 다른 층의 다른 물음을 든다.

**절단의 대상과 조치의 갈래를 매개변수로 받는다.** 그 대상이 금융 전문을 주고받는 망이고 그 망의
구조를 세우는 것이 이 아크의 뒤 페이즈의 몫이며, 조치 갈래의 이름을 조달된 기록이 열거하지 않으므로
열거로 두면 생성자의 이름을 지어내게 된다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Nat.Notation

namespace CrisisFramework.Definition

/--
시점이 어느 눈금까지 고정되어 있는가.

**대응 비형식 개념:** 공표된 시점이 연까지만 정해졌는지 월까지인지 일까지인지. 같은 칸이 세 눈금을
각각 고정하거나 고정하지 않으므로 그 셋이 함께 서지 않는 배치가 통상이다.

**이 정의가 배제하는 사례:**
세 눈금을 한 참거짓으로 접는 읽기. 공표 꼴의 하나가 기간 요소에 연과 월과 일의 고정 여부를 각각 필수
속성으로 두므로 연만 고정되고 월과 일이 고정되지 않은 자리가 그 스키마에 실제로 서며, 접으면 그 배치가
담기지 않는다.
조달처: E-69 §3-3 「기간 요소가 시작과 끝을 선택 자식으로 두고 최소 기간과 최대 기간을 함께 받으며」

**기각한 대체 정의:**
고정된 가장 작은 눈금을 열거로 두는 안. 그러면 연이 고정되지 않았는데 일이 고정된 배치가 그 열거에
서지 않아 구조가 그 스키마보다 좁아진다. 확정성을 시점 값의 밖에 두는 안도 기각했다. 그 속성이 그
기간 요소에 함께 실리므로 떼면 어느 시점의 확정성인지가 서지 않는다.

**수 체계를 받지 않는다.** 세 칸이 판정이며 수를 들지 않는다.
-/
-- DD:CF-4343
structure TimeDefiniteness where
  /-- 연이 고정되어 있는가. -/
  yearFixed : Bool
  /-- 월이 고정되어 있는가. -/
  monthFixed : Bool
  /-- 일이 고정되어 있는가. -/
  dayFixed : Bool
  deriving DecidableEq, Repr

/-- witness (A-3). **무엇을 증거하는가.** `TimeDefiniteness` 가 비어 있지 않다. 어느 눈금도
고정되지 않은 확정성 하나를 든다. -/
-- DD:CF-4343
def TimeDefiniteness.unfixed : TimeDefiniteness where
  yearFixed := false
  monthFixed := false
  dayFixed := false

/--
세 눈금이 모두 고정되어 있는가.

**대응 비형식 개념:** 그 시점이 하루까지 정해져 다른 시점과 맞댈 수 있는가. 한 눈금이라도 비면 그
맞댐이 그 눈금 아래에서 흔들린다.

**이 정의가 배제하는 사례:**
일의 고정만 묻는 읽기. 그 스키마가 세 속성을 각각 필수로 두어 일만 고정되고 연이 고정되지 않은 배치를
막지 않으므로, 일만 물으면 연이 비어 있는 시점이 맞댈 수 있는 것으로 나온다.
조달처: E-69 §3-3 「시점이 값이 아니라 구간과 확정성의 짝이다」

**기각한 대체 정의:**
고정되지 않은 눈금의 수를 내는 안. 그러면 판정이 수 위의 비교를 지나 이 층이 받지 않는 축이 들어오고,
판정을 참거짓으로 두어 `Decidable` 인스턴스가 `Bool` 에서 나오게 하는 꼴과 갈린다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4343
def TimeDefiniteness.allFixed (d : TimeDefiniteness) : Bool :=
  d.yearFixed && d.monthFixed && d.dayFixed

/--
금지가 걸려 있는 구간.

**대응 비형식 개념:** 한 조치가 언제부터 언제까지 효력을 갖는가. 시작이나 끝이 공표되지 않는 자리가
있고 그 빔이 구간이 없다는 뜻이 아니라 그 경계가 공표되지 않았다는 뜻이다.

**이 정의가 배제하는 사례:**
시작과 끝을 둘 다 필수로 두는 읽기. 그 공표 꼴이 기간 요소의 시작과 끝을 선택 자식으로 두므로, 필수로
두면 경계가 공표되지 않은 항을 구조가 받지 못하거나 그 자리에 지어낸 값이 선다.
조달처: E-69 §3-3 「기간 요소가 시작과 끝을 선택 자식으로 두고 최소 기간과 최대 기간을 함께 받으며」

**기각한 대체 정의:**
구간을 시작 하나로 두고 끝을 해제의 사건으로 돌리는 안. 그 꼴은 해제가 공표된 뒤에야 구간이 닫히게
하는데 그 공표 꼴이 최소 기간과 최대 기간을 함께 받아 끝이 미리 적히는 자리를 두므로, 돌리면 그 자리가
담기지 않는다. 확정성을 구간의 두 경계에 각각 두는 안도 기각했다. 그 속성이 기간 요소에 하나씩 실리고
경계마다 실리지 않으므로, 둘로 두면 조달된 기록이 내지 않는 값을 구조가 요구하게 된다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 두 경계가 시점 인덱스이고 나머지가 판정이다.
-/
-- DD:CF-4343
structure SanctionPeriod where
  /-- 구간이 시작하는 시점. 공표되지 않았으면 `none`. -/
  onset : Option ℕ
  /-- 구간이 끝나는 시점. 공표되지 않았으면 `none`. -/
  terminus : Option ℕ
  /-- 그 두 경계가 어느 눈금까지 고정되어 있는가. -/
  definiteness : TimeDefiniteness

/-- witness (A-3). **무엇을 증거하는가.** `SanctionPeriod` 가 비어 있지 않다. 두 경계가 다
공표되지 않고 어느 눈금도 고정되지 않은 구간 하나를 든다. -/
-- DD:CF-4343
def SanctionPeriod.unbounded : SanctionPeriod where
  onset := none
  terminus := none
  definiteness := .unfixed

/--
구간이 그 시점을 가르지 못하는 까닭.

**대응 비형식 개념:** 받은 구간으로 그 시점의 안팎을 정할 수 없을 때 그것이 왜인가. 경계가 공표되지
않아 가를 것이 없는 것과 경계는 있으나 눈금이 거칠어 그 비교가 흔들리는 것이 다른 사실이다.

**이 정의가 배제하는 사례:**
두 까닭을 하나로 접는 읽기. 그 공표 꼴이 경계를 선택 자식으로 두는 것과 눈금의 고정 여부를 속성으로
두는 것을 따로 들고 그 둘이 한 항에서 각각 비거나 거칠 수 있으므로, 접으면 어느 쪽이 가린 것인지가 그
값에서 사라진다.
조달처: E-69 §3-3 「기간 요소가 시작과 끝을 선택 자식으로 두고 최소 기간과 최대 기간을 함께 받으며」

**기각한 대체 정의:**
관측층의 판정 불가 열거를 그대로 쓰는 안. 그 열거가 관측층에 살고 이 층이 그것을 끌어오면 적재 방향이
뒤집히며, 그 칸이 묻는 것이 그 값을 내는 공표 경로가 있는가여서 받은 구간이 그 시점을 가르는가와 다른
물음을 든다. 까닭을 세 칸 이상으로 가르는 안도 기각했다. 그 둘을 가른 근거가 해소 경로이고 조달된
기록에서 읽히는 경로가 그 둘뿐이므로, 더하면 그 근거가 그 자리에서 무너진다.

**수 체계를 받지 않는다.** 두 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4343
inductive PeriodUndetermined where
  /-- 그 시점의 쪽을 가를 경계가 공표되지 않았다. -/
  | boundaryAbsent
  /-- 경계는 있으나 눈금이 거칠어 그 비교가 그 눈금 아래에서 흔들린다. -/
  | granularityCoarse
  deriving DecidableEq, Repr

/--
한 시점이 그 구간의 어느 쪽에 서는가.

**대응 비형식 개념:** 받은 구간과 받은 시점으로 그 시점이 금지 안인지 밖인지를 정한 결과. 정해지지
않는 자리가 있고 그 자리가 안도 밖도 아니다.

**이 정의가 배제하는 사례:**
판정을 참거짓으로 닫는 읽기. 경계가 비거나 눈금이 거친 항이 그 공표 꼴에 실제로 서므로, 참거짓으로
닫으면 가려지지 않은 자리가 밖으로 떨어져 금지가 걸리지 않은 것으로 읽힌다.
조달처: E-69 §3-3 「시점이 값이 아니라 구간과 확정성의 짝이다」

**기각한 대체 정의:**
정해지지 않는 자리를 선택으로 두고 까닭을 떼는 안. 그러면 경계가 없는 것과 눈금이 거친 것이 한 값으로
접히고 해소 경로가 다른 둘이 같은 자리에 선다.

**수 체계를 받지 않는다.** 세 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4343
inductive PeriodVerdict where
  /-- 그 시점이 구간 안에 선다. -/
  | inside
  /-- 그 시점이 구간 밖에 선다. -/
  | outside
  /-- 그 시점의 쪽이 정해지지 않는다. -/
  | undetermined (reason : PeriodUndetermined)
  deriving DecidableEq, Repr

/--
그 판정이 구간 안인가.

**대응 비형식 개념:** 세 값 가운데 안인 것만을 참으로 접는 것. 정해지지 않는 자리를 안으로 세지
않는다.

**이 정의가 배제하는 사례:**
밖이 아닌 것을 참으로 두는 읽기. 정해지지 않는 자리가 밖이 아니므로 그렇게 두면 경계가 공표되지 않은
항이 금지 안으로 들어오고, 공표되지 않았음을 적는 것과 금지가 걸렸음을 적는 것이 한 값이 된다.
조달처: E-69 §2-2 「그 가운데 어느 칸도 그 지정이 언제부터 효력을 갖는지를 들지 않는다」

**기각한 대체 정의:**
정해지지 않는 자리를 참으로 접는 안. 그 접기가 금지를 넓히는 방향이라 안전해 보이나, 그러면 소스가
없다는 것이 금지가 걸렸다는 것과 구별되지 않아 이 프레임워크가 드러내려는 결손이 그 자리에서 사라진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4343
def PeriodVerdict.isInside : PeriodVerdict → Bool
  | .inside => true
  | .outside => false
  | .undetermined _ => false

/--
그 시점이 구간의 시작에 이르렀는가.

**대응 비형식 개념:** 시작이 공표되었으면 그 시점이 그 이후인가이고, 공표되지 않았으면 시작 쪽에서
막을 것이 없다는 것.

**이 정의가 배제하는 사례:**
시작이 공표되지 않은 항을 거짓으로 두는 읽기. 그 공표 꼴이 시작을 선택 자식으로 두어 끝만 적힌 항을
두므로, 거짓으로 두면 끝이 적힌 그 항이 어느 시점에서도 구간 안에 서지 않는다.
조달처: E-69 §3-3 「기간 요소가 시작과 끝을 선택 자식으로 두고 최소 기간과 최대 기간을 함께 받으며」

**기각한 대체 정의:**
시작의 빔을 판정 불가로 내는 안. 그러면 이 선언이 세 값을 내게 되어 두 경계를 묶는 자리가 세 값의
곱 위에 서고, 경계 하나만 공표된 항이 가려지는 자리가 그 곱에서 사라진다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 인덱스를 뺀 나머지가 판정이다.
-/
-- DD:CF-4343
def SanctionPeriod.onsetReached (P : SanctionPeriod) (t : ℕ) : Bool :=
  match P.onset with
  | none => true
  | some a => decide (a ≤ t)

/--
그 시점이 구간의 끝을 넘지 않았는가.

**대응 비형식 개념:** 끝이 공표되었으면 그 시점이 그 이전인가이고, 공표되지 않았으면 끝 쪽에서 막을
것이 없다는 것.

**이 정의가 배제하는 사례:**
끝이 공표되지 않은 항을 거짓으로 두는 읽기. 그 공표 꼴이 끝을 선택 자식으로 두어 해제가 적히지 않은
항을 두므로, 거짓으로 두면 지금 걸려 있는 금지가 어느 시점에서도 구간 안에 서지 않는다.
조달처: E-69 §3-1 「한 주체가 언제 잘렸는가는 단일 값이 아니라 그 항에 쌓인 사건의 열이다」

**기각한 대체 정의:**
끝의 빔을 판정 불가로 내는 안. 시작의 빔에 그 안을 기각한 것과 같은 사유로 기각했다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 인덱스를 뺀 나머지가 판정이다.
-/
-- DD:CF-4343
def SanctionPeriod.terminusNotPassed (P : SanctionPeriod) (t : ℕ) : Bool :=
  match P.terminus with
  | none => true
  | some b => decide (t ≤ b)

/--
그 시점이 두 경계 안에 함께 서는가.

**대응 비형식 개념:** 시작 쪽에서도 끝 쪽에서도 막히지 않는 것. 경계가 비어 있는 쪽은 막지 않는다.

**이 정의가 배제하는 사례:**
두 경계 가운데 하나만 보는 읽기. 그 공표 꼴이 최소 기간과 최대 기간을 함께 받아 한 항에 두 경계가 다
적히는 자리를 두므로, 하나만 보면 해제된 조치가 해제 뒤에도 걸려 있는 것으로 읽힌다.
조달처: E-69 §3-3 「기간 요소가 시작과 끝을 선택 자식으로 두고 최소 기간과 최대 기간을 함께 받으며」

**기각한 대체 정의:**
두 경계를 논리합으로 묶는 안. 그러면 시작에 이르지 않은 시점이 끝을 넘지 않았다는 것만으로 구간 안에
서고, 발효 전의 거래가 금지 안으로 들어온다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 인덱스를 뺀 나머지가 판정이다.
-/
-- DD:CF-4343
def SanctionPeriod.withinBounds (P : SanctionPeriod) (t : ℕ) : Bool :=
  P.onsetReached t && P.terminusNotPassed t

/--
그 시점이 구간의 어느 쪽에 서는가의 판정.

**대응 비형식 개념:** 받은 구간과 받은 시점으로 안과 밖과 정해지지 않음 가운데 하나를 내는 것.

**이 정의가 배제하는 사례:**
눈금의 고정 여부를 보지 않고 경계만으로 가르는 읽기. 그 공표 꼴이 연과 월과 일의 고정 여부를 기간
요소의 필수 속성으로 두어 연까지만 고정된 항이 서므로, 보지 않으면 그 비교가 그 눈금 아래에서 흔들리는
자리가 확정된 판정으로 나온다.
조달처: E-69 §3-3 「시점이 값이 아니라 구간과 확정성의 짝이다」

**기각한 대체 정의:**
경계가 둘 다 비었을 때를 밖으로 내는 안. 그러면 경계가 공표되지 않았음이 금지가 걸리지 않았음과 한
값이 되어 이 프레임워크가 드러내려는 결손이 사라진다. 눈금이 거친 항을 경계의 비교로 가르고 그 거칢을
따로 내지 않는 안도 기각했다. 그러면 연까지만 고정된 항의 안팎이 그 연의 어느 날을 고르는가에 매이고
구조가 그 고르기를 숨긴다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 인덱스를 뺀 나머지가 판정과 열거다.
-/
-- DD:CF-4343
def SanctionPeriod.contains (P : SanctionPeriod) (t : ℕ) : PeriodVerdict :=
  if P.definiteness.allFixed then
    match P.onset, P.terminus with
    | none, none => .undetermined .boundaryAbsent
    | _, _ => if P.withinBounds t then .inside else .outside
  else
    .undetermined .granularityCoarse

/--
한 조치가 자르는 대상의 집합.

**대응 비형식 개념:** 그 조치가 어느 대상에 걸리는가. 대상이 금융 전문을 주고받는 망이고 그 망의
원소가 무엇인지는 이 파일이 들지 않는다.

**이 정의가 배제하는 사례:**
대상을 집합이 아니라 하나로 두는 읽기. 같은 항에서 앞선 날에 걸리는 것이 한 나라 중앙은행의 체계와 그
중앙은행이 세운 동등한 서비스이고 뒤의 날에 걸리는 것이 그 체계 전량과 그 나라 법으로 세워진 어느
법인이든 금융 전문 기능을 품은 체계이므로, 하나로 두면 그 넓어짐이 담기지 않는다.
조달처: E-68 §2-8 「같은 항에서 앞선 날에 걸리는 것이 그 나라 중앙은행의 금융 전문 체계」

**기각한 대체 정의:**
대상의 집합을 원소의 열로 두는 안. 그러면 포함의 판정이 열 위의 상등에 걸려 대상의 타입에 상등 판정을
요구하게 되고, 대상의 타입을 매개변수로 받는 꼴이 좁아진다. 대상의 이름을 이 파일의 열거로 두는 안도
기각했다. 그 망의 구조를 세우는 것이 이 아크의 뒤 페이즈의 몫이므로 먼저 두면 두 자리가 같은 것을
가르게 된다.

**수 체계를 받지 않는다.** 한 칸이 대상의 타입을 매개변수로 받는 판정이다.
-/
-- DD:CF-4342
structure CutScope (Target : Type) where
  /-- 그 대상이 이 조치에 걸리는가. -/
  covers : Target → Bool

/-- witness (A-3). **무엇을 증거하는가.** `CutScope` 가 비어 있지 않다. 어느 대상도 걸지 않는
집합 하나를 든다. -/
-- DD:CF-4342
def CutScope.empty : CutScope Unit where
  covers := fun _ => false

/--
한 시점의 금지 읽기.

**대응 비형식 개념:** 그 조문을 한 시점에 읽었을 때 조치마다 그것이 걸려 있는 구간과 자르는 대상이
무엇인가. 조치의 갈래가 색인이고 구간과 대상이 그 색인에 붙는 배정이다.

**이 정의가 배제하는 사례:**
한 주체에 구간 하나를 붙이는 읽기. 그 공표 꼴이 제재 항의 타입 아래에 조치 요소를 최소 하나로 두고
요소마다 기간을 필수 자식으로 들며 조치 갈래의 식별자를 속성으로 두므로, 하나로 붙이면 갈래마다 다른
기간이 한 값으로 접힌다.
조달처: E-69 §3-2 「한 주체에 걸린 금지가 하나가 아니라 갈래마다 다른 기간으로 설 수」

**기각한 대체 정의:**
대상의 집합을 색인에서 대상으로 가는 함수가 아니라 구조가 계산하는 자리로 두는 안. 그러면 구조가 모형이
받는 것만 담는 꼴과 갈리고, 어느 조치가 무엇을 자르는가를 읽는 쪽이 계산하게 되어 그 열거가 당국의
조작이라는 사실이 사라진다. 조치의 갈래를 이 파일의 열거로 두는 안도 기각했다. 조달된 기록이 그
식별자가 속성으로 선다는 것만 들고 갈래의 이름을 열거하지 않으므로, 열거로 두면 생성자의 이름을 지어내게
된다.

**수 체계를 받지 않는다.** 두 칸이 색인에서 가는 배정이며 수를 들지 않는다.
-/
-- DD:CF-4342
structure ProhibitionTiming (Measure Target : Type) where
  /-- 그 조치가 걸려 있는 구간. -/
  period : Measure → SanctionPeriod
  /-- 그 조치가 자르는 대상의 집합. -/
  scope : Measure → CutScope Target

/-- witness (A-3). **무엇을 증거하는가.** `ProhibitionTiming` 이 비어 있지 않다. 어느 조치도
경계를 갖지 않고 어느 대상도 자르지 않는 읽기 하나를 든다. -/
-- DD:CF-4342
def ProhibitionTiming.trivial : ProhibitionTiming Unit Unit where
  period := fun _ => .unbounded
  scope := fun _ => .empty

/--
금지 읽기의 시점 족.

**대응 비형식 개념:** 같은 조문이 시점에 따라 다른 것을 금지하는 것. 문면이 바뀌지 않아도 조문 본문의
날짜가 그 달라짐을 낸다.

**이 정의가 배제하는 사례:**
읽기를 시점 없는 하나로 두는 읽기. 한 조가 금지를 세우면서 어느 날부터 적용되는지를 두 자리에 각각
날짜로 적어 문면이 바뀌지 않아도 시점에 따라 다른 것을 금지하므로, 시점을 떼면 그 갈림이 사라진다.
조달처: E-68 §2-7 「시점의 축이 개정의 사슬과 조문 본문의 날짜 둘로 선다」

**기각한 대체 정의:**
시점을 읽기의 칸으로 받는 안. 그러면 한 읽기가 여러 시점을 함께 들어 그 칸의 값이 어느 시점의 것인지가
서지 않으며, 정의층 대상을 시점 인덱스를 갖는 족으로 정의하라는 요구와도 갈린다. 개정의 사슬을 족의
색인으로 두는 안도 기각했다. 그 사슬이 어느 문면이 어느 문면을 고쳤는가의 관계이고, 조문을 판을
가로질러 가리키는 작품 단위의 동일성은 서지만 그 위에서 사슬을 색인으로 세우는 꼴이 정해지지
않았으므로, 색인으로 두면 그 꼴을 지어내게 된다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 인덱스를 뺀 나머지가 색인에서 가는 배정이다.
-/
-- DD:CF-4342
abbrev ProhibitionTimingFamily (Measure Target : Type) := ℕ → ProhibitionTiming Measure Target

/-- **무엇을 증거하는가.** 시점에 따라 변하지 않는 족을 만드는 수단이다. 받은 읽기를 모든 시점에
두는 상수 족을 낸다. -/
-- DD:CF-4342
def ProhibitionTimingFamily.constant {Measure Target : Type}
    (R : ProhibitionTiming Measure Target) : ProhibitionTimingFamily Measure Target := fun _ => R

/--
그 조치가 그 시점에 그 대상을 자르는가.

**대응 비형식 개념:** 그 조치의 구간이 그 시점을 품고 그 조치의 대상 집합이 그 대상을 거는 것. 둘
가운데 하나만 서면 자르지 않는다.

**이 정의가 배제하는 사례:**
구간만 보고 대상을 보지 않는 읽기. 같은 항에서 두 날에 걸리는 대상이 다르고 뒤가 앞을 포함하면서
넓으므로, 대상을 보지 않으면 뒤의 날에 들어온 대상이 앞의 날부터 잘린 것으로 읽힌다.
조달처: E-68 §3-5 「망 종류를 받는 인자가 시점에 매인 족이어야 하고」

**기각한 대체 정의:**
구간의 판정을 그대로 내고 대상의 포함을 바깥에 두는 안. 그러면 자르는가의 물음이 두 자리에서 각각
답해지고 그 둘을 묶는 자리가 구조 밖에 서서, 어느 쪽이 가렸는지가 그 묶음에서 사라진다. 정해지지 않는
구간 판정을 자르는 것으로 두는 안도 기각했다. 공표되지 않았음이 금지가 걸렸음과 한 값이 된다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 인덱스를 뺀 나머지가 판정이다.
-/
-- DD:CF-4342
def ProhibitionTiming.cutAt {Measure Target : Type} (R : ProhibitionTiming Measure Target)
    (m : Measure) (x : Target) (t : ℕ) : Bool :=
  ((R.period m).contains t).isInside && (R.scope m).covers x

/--
이미 맺은 계약에 주어지는 유예의 창.

**대응 비형식 개념:** 어느 날 이전에 맺은 계약과 그 이행에 필요한 부수 계약에는 다른 날까지 그 금지가
미치지 않는 것. 두 날이 다른 사건에 걸린다.

**이 정의가 배제하는 사례:**
유예를 한 기한으로 두는 읽기. 조문이 어느 날 이전에 맺은 계약에 다른 날까지 금지가 미치지 않는다고
적고 또 다른 항이 어느 날까지 발생한 지급의 수령을 또 다른 날까지 이행된 계약에 묶으므로, 하나로 두면
체결의 기한과 이행의 기한이 접힌다.
조달처: E-68 §2-9 「제5ac조 제3항이 어느 날 이전에 맺은 계약과 그 이행에 필요한 부수 계약」

**기각한 대체 정의:**
유예를 구간으로 두고 그 구간이 금지의 구간을 덮게 하는 안. 그러면 체결과 이행이 같은 축에서 재어져 한
축의 기한이 다른 축의 기한과 비교되고, 두 날이 다른 사건을 가리킨다는 것이 그 꼴에서 사라진다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 두 칸이 시점 인덱스다.
-/
-- DD:CF-4344
structure GraceWindow where
  /-- 계약이 그 이전에 맺어져야 하는 시점. -/
  conclusionCutoff : ℕ
  /-- 그 이행이 그때까지여야 하는 시점. -/
  performanceDeadline : ℕ
  deriving DecidableEq, Repr

/-- witness (A-3). **무엇을 증거하는가.** `GraceWindow` 가 비어 있지 않다. 두 기한이 다 가장 이른
시점에 선 창 하나를 든다. -/
-- DD:CF-4344
def GraceWindow.immediate : GraceWindow where
  conclusionCutoff := 0
  performanceDeadline := 0

/--
그 이행이 유예에 덮이는가.

**대응 비형식 개념:** 금지가 이미 발효한 뒤의 이행인데도 그 계약이 기한 전에 맺어지고 그 이행이 기한
안에 끝나 금지가 미치지 않는 것. 발효 전의 이행은 유예가 덮을 것이 없다.

**이 정의가 배제하는 사례:**
시점을 둘만 받는 읽기. 그 조문이 체결의 기한과 이행의 기한을 따로 두고 그 둘과 별도로 금지 자체의
발효 시점이 서므로, 둘만 받으면 발효 뒤에 맺은 계약이 기한 안에 이행된 자리와 발효 전에 맺은 계약이
기한 뒤에 이행된 자리가 한 값으로 접힌다.
조달처: E-68 §3-4 「금지의 발효 시점과 계약의 체결 시점이 다른 사건을 가리키므로」

**기각한 대체 정의:**
계약의 체결 시점을 금지의 발효 시점으로 갈음하는 안. 그러면 한 거래의 금지 여부가 그 거래의 시점만으로
정해지고, 같은 시점에 일어난 두 거래가 딛는 계약의 체결 시점이 달라 갈리는 자리가 사라진다. 세 시점을
한 구간의 포함으로 접는 안도 기각했다. 체결의 기한과 이행의 기한이 한 축의 두 경계가 아니라 다른 사건의
기한이므로, 접으면 체결이 이행보다 늦은 배치가 구조에서 막히지 않는데 그 배치의 판정이 그 접기에서
사라진다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 인덱스를 뺀 나머지가 판정이다.
-/
-- DD:CF-4344
def GraceWindow.exempts (G : GraceWindow) (effective concluded performed : ℕ) : Bool :=
  decide (effective ≤ performed) && decide (concluded ≤ G.conclusionCutoff) &&
    decide (performed ≤ G.performanceDeadline)

/--
증거를 드는 시점의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거를 들기 위한 색인이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
실재하는 날짜를 생성자로 두는 읽기. 그 조문의 날짜가 개정으로 바뀌고 부속서의 발효 시점 칸이 한 표
안에서 두 표기 꼴로 섞이므로, 박으면 그 값이 박는 순간 낡고 실증 결과를 추출하지 않는다는 요구에도
걸린다.
조달처: E-68 §2-12 「그 칸의 표기 꼴이 한 표 안에서 둘로 섞인다」

**기각한 대체 정의:**
시점을 세 생성자로 두는 안. 유예의 판정이 세 시점을 받고 그 셋마다 홀로 값을 가르는 자리를 들려면 기한
둘과 그 둘의 앞뒤에 서는 시점 둘이 필요하므로, 셋으로 두면 그 증거가 한 자리에 접힌다.

**수 체계를 받지 않는다.** 네 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4346
inductive TimingWitnessInstant where
  /-- 두 기한보다 앞선 시점. -/
  | early
  /-- 체결의 기한에 선 시점. -/
  | cutoff
  /-- 이행의 기한에 선 시점. -/
  | deadline
  /-- 두 기한보다 뒤의 시점. -/
  | late
  deriving DecidableEq, Repr

/--
증거의 시점에 붙는 인덱스.

**대응 비형식 개념:** 없다. 이 선언은 증거의 열거를 시점 인덱스로 보내는 수단이며 비형식 개념에
대응하지 않는다.

**이 정의가 배제하는 사례:**
실재하는 날짜의 일련번호를 값으로 두는 읽기. 그 부속서의 표가 주체의 이름 옆에 발효 시점의 칸을 두고
항마다 값을 채우므로 그 값이 당국의 조작으로 바뀌며, 두면 그 증거가 박는 순간 낡는다.
조달처: E-68 §2-12 「부속서 XLIV 의 표가 주체의 이름 옆에 발효 시점의 칸을 두고 항마다 값을 채운다」

**기각한 대체 정의:**
열거의 순서를 쓰지 않고 증거마다 인덱스를 직접 적는 안. 그러면 같은 시점을 가리키는 자리가 여럿이 되어
한 자리를 고칠 때 나머지가 낡는다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 값이 시점 인덱스다.
-/
-- DD:CF-4346
def TimingWitnessInstant.index : TimingWitnessInstant → ℕ
  | .early => 0
  | .cutoff => 1
  | .deadline => 2
  | .late => 3

/--
증거를 드는 확정성의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거를 들기 위한 색인이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
고정되지 않은 축을 하나만 드는 읽기. 그 스키마가 연과 월과 일의 고정 여부를 각각 필수 속성으로 두므로
축마다 그것만 고정되지 않은 배치가 서고, 하나만 들면 나머지 축이 홀로 가르는 자리가 그 증거에서 빠진다.
조달처: E-69 §3-3 「기간 요소가 시작과 끝을 선택 자식으로 두고 최소 기간과 최대 기간을 함께 받으며」

**기각한 대체 정의:**
어느 축도 고정되지 않은 배치 하나만 드는 안. 그러면 세 축이 함께 거짓인 자리와 함께 참인 자리만 서서
그 곱과 합의 값이 그 둘에서 같아, 그 결합을 뒤집은 변이가 통과한다.

**수 체계를 받지 않는다.** 네 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4346
inductive TimingWitnessAxis where
  /-- 세 눈금이 다 고정된 배치. -/
  | allFixed
  /-- 연만 고정되지 않은 배치. -/
  | yearUnfixed
  /-- 월만 고정되지 않은 배치. -/
  | monthUnfixed
  /-- 일만 고정되지 않은 배치. -/
  | dayUnfixed
  deriving DecidableEq, Repr

/--
증거를 드는 조치의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거를 들기 위한 색인이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
실재하는 조치 갈래의 이름을 생성자로 두는 읽기. 조달된 기록이 조치 갈래의 식별자가 속성으로 선다는
것만 들고 그 갈래의 이름을 열거하지 않으므로, 두면 그 이름을 지어내게 된다.
조달처: E-69 §3-2 「한 주체에 걸린 금지가 하나가 아니라 갈래마다 다른 기간으로 설 수」

**기각한 대체 정의:**
조치를 하나만 두는 안. 갈래마다 기간이 따로 선다는 것을 드는 증거가 한 읽기에 조치 둘을 요구하므로,
하나로 두면 그 갈림이 그 증거에서 사라진다.

**수 체계를 받지 않는다.** 세 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4346
inductive TimingWitnessMeasure where
  /-- 두 경계가 다 공표되고 눈금이 다 고정된 조치. -/
  | boundedMeasure
  /-- 어느 경계도 공표되지 않은 조치. -/
  | unboundedMeasure
  /-- 경계는 공표되었으나 눈금이 거친 조치. -/
  | coarseMeasure
  deriving DecidableEq, Repr

/--
증거를 드는 대상의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거를 들기 위한 색인이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
실재하는 망의 이름을 생성자로 두는 읽기. 그 망의 구조를 세우는 것이 이 아크의 뒤 페이즈의 몫이므로,
두면 그 페이즈가 세울 열거와 이 자리의 열거가 같은 것을 두 번 가르게 된다.
조달처: E-68 §2-8 「같은 항에서 앞선 날에 걸리는 것이 그 나라 중앙은행의 금융 전문 체계」

**기각한 대체 정의:**
대상을 둘만 두는 안. 뒤의 시점에서 넓어짐을 들려면 앞뒤에 다 걸리는 대상과 뒤에만 걸리는 대상과 어느
시점에도 걸리지 않는 대상이 필요하므로, 둘로 두면 그 넓어짐이 전량을 거는 것과 구별되지 않는다.

**수 체계를 받지 않는다.** 세 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4346
inductive TimingWitnessTarget where
  /-- 앞선 시점부터 걸리는 대상. -/
  | inEarly
  /-- 뒤의 시점에만 걸리는 대상. -/
  | addedLater
  /-- 어느 시점에도 걸리지 않는 대상. -/
  | neverCovered
  deriving DecidableEq, Repr

/-- **무엇을 증거하는가.** 확정성의 세 축이 각각 홀로 거짓인 배치가 선다. 축마다 그것만 고정되지
않은 확정성을 내고 넷째 자리에 세 축이 다 고정된 확정성을 둔다. -/
-- DD:CF-4346
def timingDefiniteness : TimingWitnessAxis → TimeDefiniteness
  | .allFixed => { yearFixed := true, monthFixed := true, dayFixed := true }
  | .yearUnfixed => { yearFixed := false, monthFixed := true, dayFixed := true }
  | .monthUnfixed => { yearFixed := true, monthFixed := false, dayFixed := true }
  | .dayUnfixed => { yearFixed := true, monthFixed := true, dayFixed := false }

/-- **무엇을 증거하는가.** 체결의 기한과 이행의 기한이 다른 시점에 선 유예의 창이다. 앞의 기한을
체결의 기한 자리에 두고 뒤의 기한을 이행의 기한 자리에 둔다. -/
-- DD:CF-4346
def graceWitness : GraceWindow where
  conclusionCutoff := TimingWitnessInstant.cutoff.index
  performanceDeadline := TimingWitnessInstant.deadline.index

/-- **무엇을 증거하는가.** 한 읽기 안에서 조치마다 구간이 따로 서고 그 셋이 구간 판정의 세 값을
각각 낸다. 경계가 다 선 조치와 어느 경계도 없는 조치와 눈금이 거친 조치를 나란히 두고, 대상은 세
조치에서 같은 집합을 건다. -/
-- DD:CF-4346
def timingWitness : ProhibitionTiming TimingWitnessMeasure TimingWitnessTarget where
  period := fun m =>
    match m with
    | .boundedMeasure =>
        { onset := some TimingWitnessInstant.cutoff.index,
          terminus := some TimingWitnessInstant.deadline.index,
          definiteness := timingDefiniteness .allFixed }
    | .unboundedMeasure =>
        { onset := none, terminus := none, definiteness := timingDefiniteness .allFixed }
    | .coarseMeasure =>
        { onset := some TimingWitnessInstant.early.index,
          terminus := some TimingWitnessInstant.late.index,
          definiteness := timingDefiniteness .dayUnfixed }
  scope := fun _ => { covers := fun x => decide (x = .inEarly) }

/-- **무엇을 증거하는가.** 뒤의 시점에서 대상 집합이 앞의 시점의 것을 포함하면서 엄격히 넓은 읽기의
족이다. 앞의 시점에 한 대상만 걸고 뒤의 시점에 둘을 걸며, 셋째 대상은 어느 시점에도 걸지 않는다. -/
-- DD:CF-4345
def wideningWitness : ProhibitionTimingFamily TimingWitnessMeasure TimingWitnessTarget :=
  fun t =>
    { period := timingWitness.period,
      scope := fun _ =>
        { covers := fun x =>
            decide (x = .inEarly) ||
              (decide (x = .addedLater) &&
                decide (TimingWitnessInstant.cutoff.index ≤ t)) } }

/--
확정성의 세 축이 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
한 축만 고정되지 않은 배치가 세 눈금이 다 고정된 것으로 나오거나, 세 축이 다 고정된 배치가 그렇지 않은
것으로 나와야 한다. 그 관측은 고정 여부의 판정이 세 축의 논리곱이 아니라는 뜻이며, 앞은 연까지만
고정된 시점이 하루까지 맞댈 수 있는 것으로 읽히는 것이고 뒤는 고정된 시점이 흔들리는 것으로 읽히는
것이다.

**존재 형태로 진술하는 까닭(T-6):**
축마다 그 하나만 거짓인 배치와 셋이 다 참인 배치를 들어야 보인다. 임의의 확정성에서 각 축이 홀로
가르는 것이 아니라 나머지가 참인 자리에서만 그 가름이 보이고, 그 논리곱이 참이 되는 자리도 셋이 함께
참인 배치에서만 서기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 고정 여부를 세 축의 논리곱으로 둔 결합마다 그 인자가 홀로 값을 가르는 증거를
드는 유일한 자리이고, 그 증거가 없으면 그 결합을 뒤집은 변이가 통과한다.
-/
-- DD:CF-4346
theorem allFixed_pins_each_axis :
    (timingDefiniteness .allFixed).allFixed = true ∧
      (timingDefiniteness .yearUnfixed).yearFixed = false ∧
      (timingDefiniteness .yearUnfixed).monthFixed = true ∧
      (timingDefiniteness .yearUnfixed).dayFixed = true ∧
      (timingDefiniteness .yearUnfixed).allFixed = false ∧
      (timingDefiniteness .monthUnfixed).yearFixed = true ∧
      (timingDefiniteness .monthUnfixed).monthFixed = false ∧
      (timingDefiniteness .monthUnfixed).dayFixed = true ∧
      (timingDefiniteness .monthUnfixed).allFixed = false ∧
      (timingDefiniteness .dayUnfixed).yearFixed = true ∧
      (timingDefiniteness .dayUnfixed).monthFixed = true ∧
      (timingDefiniteness .dayUnfixed).dayFixed = false ∧
      (timingDefiniteness .dayUnfixed).allFixed = false := by
  -- 네 축의 눈금이 상수이고 세 눈금의 논리곱이 그 위의 계산이므로 각 등식이 계산으로 값이
  -- 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
구간의 두 경계가 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
시작에 이르지 않은 시점이 구간 안에 서거나 끝을 넘은 시점이 구간 안에 서야 한다. 그 관측은 두 경계의
판정이 곱이 아니라 합이라는 뜻이며, 앞은 발효 전의 거래가 금지 안으로 들어오는 것이고 뒤는 해제된
조치가 해제 뒤에도 걸려 있는 것이다.

**존재 형태로 진술하는 까닭(T-6):**
한 경계만 막는 시점을 경계마다 들어야 보인다. 두 경계가 함께 막는 자리와 함께 막지 않는 자리만 들면
곱과 합의 값이 그 둘에서 같아 그 결합을 뒤집은 변이가 통과하므로, 시작에 이르지 않은 시점과 끝을 넘은
시점을 함께 들어 경계마다 그 홀로 가름을 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 경계를 묶은 결합을 가리는 증거를 드는 유일한 자리다.
-/
-- DD:CF-4346
theorem withinBounds_pins_each_bound :
    (timingWitness.period .boundedMeasure).withinBounds TimingWitnessInstant.cutoff.index = true ∧
      (timingWitness.period .boundedMeasure).onsetReached
        TimingWitnessInstant.early.index = false ∧
      (timingWitness.period .boundedMeasure).terminusNotPassed
        TimingWitnessInstant.early.index = true ∧
      (timingWitness.period .boundedMeasure).withinBounds
        TimingWitnessInstant.early.index = false ∧
      (timingWitness.period .boundedMeasure).onsetReached
        TimingWitnessInstant.late.index = true ∧
      (timingWitness.period .boundedMeasure).terminusNotPassed
        TimingWitnessInstant.late.index = false ∧
      (timingWitness.period .boundedMeasure).withinBounds
        TimingWitnessInstant.late.index = false := by
  -- 증거의 구간이 상수이고 두 경계의 판정과 그 논리곱이 그 위의 계산이므로 각 등식이 계산으로
  -- 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
구간 판정이 세 값을 내고 정해지지 않는 두 까닭이 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
경계가 공표되지 않은 구간과 눈금이 거친 구간이 같은 값을 내거나, 둘 가운데 하나가 안이나 밖으로
나와야 한다. 그 관측은 두 까닭의 해소 경로가 같다는 뜻이며, 앞은 조달로 풀리는 결손과 다른 문면을
읽어 풀리는 결손이 한 자리에 서는 것이고 뒤는 가려지지 않은 자리가 가려진 것으로 읽히는 것이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 구간 판정이 참거짓으로 닫히지 않는다는 것과 그 정해지지 않음이 두 까닭으로
갈린다는 것을 구조 안의 명제로 드는 유일한 자리다.
-/
-- DD:CF-4343
theorem contains_splits_three_verdicts :
    (timingWitness.period .boundedMeasure).contains
        TimingWitnessInstant.cutoff.index = .inside ∧
      (timingWitness.period .boundedMeasure).contains
        TimingWitnessInstant.late.index = .outside ∧
      (timingWitness.period .unboundedMeasure).contains
        TimingWitnessInstant.cutoff.index = .undetermined .boundaryAbsent ∧
      (timingWitness.period .coarseMeasure).contains
        TimingWitnessInstant.cutoff.index = .undetermined .granularityCoarse := by
  -- 세 조치의 구간이 상수이고 눈금의 판정과 경계의 유무에 따른 분기가 그 위의 계산이므로 각
  -- 등식이 계산으로 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
유예의 세 시점이 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
발효 전의 이행이 유예에 덮이거나, 기한 뒤에 맺은 계약의 이행이 덮이거나, 기한 뒤의 이행이 덮여야
한다. 그 관측은 유예가 세 시점의 논리곱이 아니라는 뜻이며, 셋 가운데 하나라도 합으로 서면 그 조문이
두 기한으로 세운 유예가 한 기한으로 넓어진다.

**존재 형태로 진술하는 까닭(T-6):**
시점마다 그 하나만 어긋난 배치를 들어야 보인다. 세 시점이 함께 서는 자리와 함께 어긋나는 자리만 들면
곱과 합의 값이 그 둘에서 같아 그 결합을 뒤집은 변이가 통과하므로, 발효가 이행보다 뒤인 배치와 체결이
기한보다 뒤인 배치와 이행이 기한보다 뒤인 배치를 나란히 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 유예를 세 시점의 논리곱으로 둔 결합마다 그 인자가 홀로 값을 가르는 증거를 드는
유일한 자리이고, 그 증거가 없으면 그 결합을 뒤집은 변이가 통과한다.
-/
-- DD:CF-4346
theorem exempts_pins_each_conjunct :
    graceWitness.exempts TimingWitnessInstant.early.index TimingWitnessInstant.early.index
        TimingWitnessInstant.deadline.index = true ∧
      graceWitness.exempts TimingWitnessInstant.late.index TimingWitnessInstant.early.index
        TimingWitnessInstant.deadline.index = false ∧
      graceWitness.exempts TimingWitnessInstant.early.index TimingWitnessInstant.deadline.index
        TimingWitnessInstant.deadline.index = false ∧
      graceWitness.exempts TimingWitnessInstant.early.index TimingWitnessInstant.early.index
        TimingWitnessInstant.late.index = false := by
  -- 유예의 두 날이 상수이고 세 비교의 논리곱이 그 위의 계산이므로 각 등식이 계산으로 값이 나와
  -- `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
같은 이행 시점의 두 거래가 계약의 체결 시점으로 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이행 시점이 같은 두 거래가 체결 시점과 무관하게 같은 값을 내야 한다. 그 관측은 한 거래의 금지 여부가
그 거래의 시점만으로 정해진다는 뜻이며, 그러면 시점을 한 인자로 접어도 잃는 것이 없고 그 조문이 이미
맺은 계약에 둔 유예가 구조에서 사라진다.

**존재 형태로 진술하는 까닭(T-6):**
발효 시점과 이행 시점을 같게 두고 체결 시점만 다르게 둔 두 거래를 나란히 들어야 보인다. 임의의 배치
에서 체결 시점이 값을 가르는 것이 아니라 나머지 두 시점이 유예를 막지 않는 자리에서만 그 가름이
보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 시점 축을 한 인자로 접지 않은 까닭을 구조 안의 명제로 드는 유일한 자리이고,
그 명제가 없으면 인자를 둘로 둔 것이 이름만 다른 둘이 된다.
-/
-- DD:CF-4344
theorem conclusion_time_splits_equal_performance :
    graceWitness.exempts TimingWitnessInstant.early.index TimingWitnessInstant.early.index
        TimingWitnessInstant.deadline.index = true ∧
      graceWitness.exempts TimingWitnessInstant.early.index TimingWitnessInstant.late.index
        TimingWitnessInstant.deadline.index = false := by
  -- 유예의 두 날이 상수이고 판정이 세 비교의 논리곱이므로, 이행 시점이 같은 두 거래의 값이
  -- 각각 계산으로 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl⟩

/--
절단의 두 인자가 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
구간 밖의 시점에서 걸리는 대상이 잘린 것으로 나오거나, 구간 안의 시점에서 걸리지 않는 대상이 잘린
것으로 나와야 한다. 그 관측은 절단이 구간의 포함과 대상의 포함의 곱이 아니라는 뜻이다.

**존재 형태로 진술하는 까닭(T-6):**
한 인자만 뒤집힌 배치를 인자마다 들어야 보인다. 두 인자가 함께 참인 자리와 함께 거짓인 자리만 들면 곱과
합의 값이 그 둘에서 같아 그 결합을 뒤집은 변이가 통과하므로, 구간 밖의 시점에 걸리는 대상과 구간 안의
시점에 걸리지 않는 대상을 함께 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 절단의 결합을 가리는 증거를 드는 유일한 자리다.
-/
-- DD:CF-4346
theorem cutAt_pins_each_conjunct :
    timingWitness.cutAt .boundedMeasure .inEarly TimingWitnessInstant.cutoff.index = true ∧
      timingWitness.cutAt .boundedMeasure .inEarly TimingWitnessInstant.late.index = false ∧
      timingWitness.cutAt .boundedMeasure .addedLater
        TimingWitnessInstant.cutoff.index = false := by
  -- 증거의 구간과 대상의 판정이 상수이고 절단의 판정이 그 둘의 논리곱이므로 각 등식이 계산으로
  -- 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl⟩

/--
뒤의 시점에서 대상 집합이 앞의 것을 포함하면서 엄격히 넓은 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 읽기의 족에서도 두 시점의 대상 집합이 포함 관계로 서면서 그 포함이 엄격한 자리가 없어야 한다. 그
관측은 그 조문의 한 항이 두 날에 같은 것을 금지한다는 뜻이며, 그러면 절단의 대상을 시점에 매인 족으로
둔 꼴이 쓰이지 않은 채 남는다.

**존재 형태로 진술하는 까닭(T-6):**
시점이 흐르면 대상이 넓어지기만 한다는 것이 조문 일반의 성질이 아니고 해제가 그 반대 방향으로 서므로,
전칭으로 세우면 거짓이다. 시스템 수준의 제약이 개별 자리를 정하지 않을 때 존재 형태로 진술하라는 요구가
그 자리에 걸린다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 절단의 대상이 시점에 따라 넓어지는 것을 구조 안의 명제로 드는 유일한 자리다.
-/
-- DD:CF-4345
theorem exists_strictly_widening_scope :
    ∃ (F : ProhibitionTimingFamily TimingWitnessMeasure TimingWitnessTarget)
      (s t : ℕ) (m : TimingWitnessMeasure),
      s ≤ t ∧
        ((F s).scope m).covers .inEarly = true ∧
        ((F t).scope m).covers .inEarly = true ∧
        ((F s).scope m).covers .addedLater = false ∧
        ((F t).scope m).covers .addedLater = true ∧
        ((F s).scope m).covers .neverCovered = false ∧
        ((F t).scope m).covers .neverCovered = false := by
  -- 넓어지는 족을 증거로 들고 두 시점을 그 족이 대상을 더하는 날의 앞과 그 날로 둔다. 시점의
  -- 순서는 앞의 시점이 영이라는 것에서 나오고, 나머지 등식은 계산으로 값이 나와 `rfl` 로 닫힌다.
  exact ⟨wideningWitness, TimingWitnessInstant.early.index, TimingWitnessInstant.cutoff.index,
    .boundedMeasure, Nat.zero_le _, rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Definition
