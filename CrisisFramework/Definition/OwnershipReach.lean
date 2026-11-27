/-
정의층 — 지정된 주체의 지분이 금지를 번지게 하는 고리

규율: L-10(무차원 + 시점 인덱스 `ℕ`), L-13(시점 족), D-2(docstring 3항목),
      D-3(실제 역사 사례), A-3(witness), A-8(논리 결합의 증거), C-3(판정은 `Bool`),
      T-2(반증 조건), T-3(분류), T-6(존재 형태).

**번짐의 경로를 셋으로 두고 한 판정의 합으로 묶는다.** 조문의 한 항이 열거된 주체와 그 주체가 몫을
넘게 소유한 주체와 그 주체를 대신하거나 그 지시에 따라 행동하는 주체를 세 갈래로 들므로, 그 셋을
하나로 접으면 어느 갈래로 금지에 들었는지가 그 값에서 사라진다. 앞 갈래는 다른 파일이 세운 절단이
그대로 받고 이 파일은 뒤의 둘을 세운다.

**설립지와 사슬과 본인의 열거를 구조가 계산하지 않고 받는다.** 설립지 조건은 조마다 정의역이 반대여서
한 술어가 두 조를 담으려면 그것을 인자로 받아야 하고, 간선의 열은 구조가 그것을 계산하면 모형이 값을
계산하는 자리가 되어 이 층에 머물 수 없으며, 본인의 열거는 주체 전량의 열거를 요구하는데 그것이 공시에서
나오지 않는다.

**몫의 곱과 비교를 연산 구조에서 받는다.** 이 층이 무차원이어서 수 체계를 매개변수로 받으므로 곱과
비교를 그 매개변수 위에서 할 수단이 필요하고, 같은 층의 발동조건이 타입클래스를 걸지 않고 그 연산을
필드로 든 구조를 받는 꼴을 이미 세웠다. 그 꼴은 추상 수 체계에 나눗셈을 쓸 수단 자체를 주지 않는다.

**경로가 여럿일 때의 합산을 구조가 강제하지 않는다.** 조문이 직접이나 간접의 소유를 들 뿐 한 주체에
이르는 경로가 여럿일 때 그 몫을 더하는지 가장 큰 것을 쓰는지를 들지 않으므로, 이 파일의 판정은 한 경로가
문턱을 넘는지만 묻는다. 유럽연합 사법재판소가 자산동결이 열거되지 않은 법인의 사슬을 거친 간접의
보유에도 미친다고 판결했으나 사슬 위의 몫을 어떻게 셈하는지와 여러 경로를 합치는지를 들지 않으므로
(E-85), 그 판정의 꼴이 그대로 선다.

**미국과 영국의 문면은 사슬의 곱과 한 경로의 판정을 쓰지 않는다.** 해외자산통제실과 산업안보국은 차단된
자들이 합쳐 절반 이상 소유한 중간 주체를 그 자체로 걸린 주체로 세워 그 주체가 가진 몫을 깎지 않고 세며
경로와 보유자의 몫을 더하고, 영국의 규정은 과반 지분의 사슬 끝이 가진 몫을 깎지 않고 한 사람의 간접
보유로 세워 그 사람의 경로를 더한다(E-94). 그래서 이 파일의 곱과 한 경로의 판정이 두 체제의 셈과
어긋나며, 그 셈을 체제마다 받는 꼴의 설계를 이연이 든다. 유럽연합의 지정된 주체를 드는 동결에서 그 셈은
여전히 서지 않는다.

**지분 절반이 낳는 지배의 추정을 소유의 갈래가 기준의 문턱으로 받고 그 반박을 재량 지위가 받는다.** 같은
판결이 열거된 주체가 지분 절반을 가진 회사의 자금을 그 주체가 보유하거나 지배하는 것으로 반박 가능하게
추정하는데(E-85), 그 추정이 지분의 몫으로 서므로 소유의 갈래와 같은 자료로 측정되고 지분으로 재어지지 않는
관계를 받는 대리의 갈래와는 측정이 갈린다. 소유의 갈래는 문턱을 기준의 칸으로 받으므로 절반 이상을 드는
규정은 그 칸에 절반 바로 앞의 값을 넣고, 반박은 성문의 자리를 당국이 놓은 자리가 덮는 꼴이어서 지정 파일의
재량 지위가 받는다. 이 파일의 판정은 그 성문의 자리를 낸다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Finset.Basic
import CrisisFramework.Definition.Designation
import CrisisFramework.Definition.Trigger

namespace CrisisFramework.Definition

/--
한 주체가 다른 주체에 둔 지분.

**대응 비형식 개념:** 보유 주체가 발행 주체의 자본에서 갖는 몫. 공적 지배와 나란히 들리는 기준의
하나이며 그 몫이 일정 선을 넘는지가 금지의 번짐을 가른다.

**이 정의가 배제하는 사례:**
의결권과 이익에 참가할 권리를 몫과 같은 칸으로 두는 읽기. 조문이 공적 지배와 일정 몫을 넘는 공적
소유와 이익에 참가할 권리를 기준으로 나란히 들어 그 셋을 같은 자리에 두지 않으므로, 한 칸으로 접으면
지분이 없이 이익에만 참가하는 배치가 지분을 가진 것으로 읽힌다.
조달처: E-68 §2-3 「그 끝에 그 부속서에 열거된 것으로 범위를 닫는다」

**기각한 대체 정의:**
외부 자산의 몫을 드는 구조를 그대로 쓰는 안. 그 구조는 당사자가 외부 자산 하나에서 갖는 지분이고 그
측정 대응이 담보 공시인데 이 지분은 주체가 다른 주체에 둔 몫이고 그 측정 대응이 소유 공시이므로, 두
측정 대응이 갈려 같은 개념이 아니다. 지분을 주체의 쌍에서 몫으로 가는 함수로 두는 안도 기각했다. 같은
쌍에 직접 지분이 둘 기록되는 것을 공시가 막지 않으므로 함수의 값이 하나일 수 없고, 기록되지 않은 쌍에
영이 놓이면 몫이 영인 보유와 기록되지 않은 것이 같아진다.

**수 체계를 매개변수로 받는다.** 몫은 스케일된 정수로 두며 회계층이 `ℤ` 를 넣는다(L-15).
-/
-- DD:CF-4292
structure StakeEdge (Entity Num : Type) where
  /-- 그 지분을 갖는 주체. -/
  holder : Entity
  /-- 그 지분이 걸리는 주체. -/
  issuer : Entity
  /-- 보유 주체가 발행 주체에 둔 몫. 스케일된 정수다. -/
  share : Num

/-- witness (A-3). **무엇을 증거하는가.** `StakeEdge` 가 비어 있지 않다. 모든 자리가 `Unit` 인
지분 하나를 든다. -/
-- DD:CF-31
def StakeEdge.trivial : StakeEdge Unit Unit where
  holder := ()
  issuer := ()
  share := ()

/--
한 시점의 소유의 망.

**대응 비형식 개념:** 그 시점에 주체들 사이에 선 지분 전부. 색인과 배정으로 준다.

**이 정의가 배제하는 사례:**
같은 쌍에 선 지분 둘을 합쳐야 하는지를 이 구조가 말하지 않는다. 조문이 직접이나 간접의 소유를 함께
들면서 그 합산의 기준을 자기 문면에 두지 않으므로, 색인이 그 둘을 구별한 채 남고 합산 규칙이 담기지
않는다.
조달처: E-68 §2-4 「두 조가 넓히는 정의역이 서로 반대다」

**기각한 대체 정의:**
간선의 유한 집합으로 두는 안. 청구권 집합과 제공 집합과 몫 집합이 색인 방식을 쓰므로 리포 안에서
관례가 갈린다. 간선의 열거를 이 구조의 칸으로 함께 받는 안도 기각했다. 그 열거는 망을 읽는 한 방식이고
망 자체가 아니므로, 칸으로 두면 같은 망에 다른 열거를 넣어 보는 일이 구조를 새로 세우는 일이 된다.

**수 체계를 매개변수로 받는다.** 간선이 그 매개변수를 들고 색인과 배정은 수를 들지 않는다.
-/
-- DD:CF-4292
structure StakeNet (EIdx Entity Num : Type) where
  /-- 간선의 색인. -/
  index : Finset EIdx
  /-- 색인에서 간선으로의 배정. -/
  assign : EIdx → StakeEdge Entity Num

/-- witness (A-3). **무엇을 증거하는가.** `StakeNet` 이 비어 있지 않다. 색인이 빈 망 하나를
든다. -/
-- DD:CF-31
def StakeNet.trivial : StakeNet Unit Unit Unit where
  index := ∅
  assign := fun _ => StakeEdge.trivial

/--
소유의 망의 시점 족.

**대응 비형식 개념:** 지분이 시점에 따라 달라지는 것. 지분의 이전과 증자와 감자가 그 달라짐을 낸다.

**이 정의가 배제하는 사례:**
망을 시점 없는 하나로 두는 읽기. 같은 항에서 앞선 날에 걸리는 것과 뒤의 날에 걸리는 것이 다르고 뒤가
앞을 포함하면서 넓으므로, 시점을 떼면 한 문면이 시점에 따라 다른 것을 금지하는 것이 담기지 않는다.
조달처: E-68 §2-8 「앞선 날에 걸리는 것이 그 나라 중앙은행의 금융 전문 체계」

**기각한 대체 정의:**
시점을 간선의 칸으로 받는 안. 그러면 한 망이 여러 시점의 간선을 함께 들어 그 색인이 어느 시점의 것인지가
서지 않으며, 정의층 대상을 시점 인덱스를 갖는 족으로 정의하라는 요구와도 갈린다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 매개변수로 받는다.** 인덱스를 뺀 나머지가 망이고 그것이 그 매개변수를 든다.
-/
-- DD:CF-4292
abbrev StakeNetFamily (EIdx Entity Num : Type) := ℕ → StakeNet EIdx Entity Num

/-- **무엇을 증거하는가.** 시점에 따라 변하지 않는 족을 만드는 수단이다. 받은 망을 모든 시점에 두는
상수 족을 낸다. -/
-- DD:CF-31
def StakeNetFamily.constant {EIdx Entity Num : Type} (N : StakeNet EIdx Entity Num) :
    StakeNetFamily EIdx Entity Num := fun _ => N

/--
간선의 열이 내는 값.

**대응 비형식 개념:** 간접 소유의 몫. 지분이 사슬로 이어질 때 그 몫은 사슬 위의 지분의 곱이며, 사슬의
머리가 그 몫을 쥔 주체이고 꼬리가 그 몫이 걸린 주체다.

**이 정의가 배제하는 사례:**
사슬이 아닌 열에 값을 주는 읽기. 조문이 직접이나 간접으로 소유한 것을 들어 그 간접이 지분의 이음을
뜻하므로, 이음이 끊긴 열에 값을 주면 소유가 아닌 자리에 몫이 선다. 색인이 망에 들지 않은 열도 같은
자리에 서므로 값을 내지 않는다.
조달처: E-68 §2-4 「그 열거된 주체가 직접이나 간접으로 일정 몫을 넘게 소유한 것」

**기각한 대체 정의:**
경로의 길이를 상한으로 가두는 안. 그 상한이 시점 인덱스 밖의 자연수여서 이 층이 들 수 없고, 같은 축의
셈이 회계층의 몫이라는 판정이 같은 디렉터리의 다른 선언에 이미 서 있다. 사슬을 이루는지를 따로 판정하고
곱을 무조건 내는 안도 기각했다. 그러면 사슬이 아닌 열에도 값이 서서 그 값을 쓰는 자리마다 그 판정을
함께 들어야 한다.

**미국과 영국의 문면이 이 곱과 다른 셈을 든다.** 해외자산통제실과 산업안보국은 사슬의 중간 주체가 차단된
자들에게 합쳐 절반 이상 소유되어 그 자체로 걸리면 그 주체가 다음 고리에 가진 몫을 깎지 않고 세며, 영국의
규정은 각 고리가 과반 지분인 사슬의 끝이 가진 몫을 깎지 않고 그 사람의 간접 보유로 센다. 그래서 문턱에 닿은
고리를 거친 사슬에서 이 정의의 곱이 두 체제의 몫보다 작고, 문턱에 닿지 않은 고리를 거친 사슬에서 두 체제는
그 몫을 영으로 센다. 이 정의를 전개하는 정리들이 반증 조건으로 든 관측 가운데 사슬의 몫이 간선의 몫들의
곱으로 재어지지 않는다는 것이 그 두 체제에서 서며, 그 정리들의 진술은 이 정의에 대해 참으로 남는다. 그 셈을
받는 설계는 이 정의를 고치지 않고 뒤를 잇는 아크를 가리키는 이연 `CF-4912` 가 기다린다.
조달처: E-94 §5-1 「어느 쪽도 고리의 몫을 곱하지 않으므로」

**수 체계를 매개변수로 받는다.** 곱이 그 매개변수 위의 연산이며 그 연산을 연산 구조에서 받는다.
-/
-- DD:CF-4293
def StakeNet.chainValue {EIdx Entity Num Lvl : Type} [DecidableEq EIdx] [DecidableEq Entity]
    (ops : Ops Num Lvl) (N : StakeNet EIdx Entity Num) :
    List EIdx → Option (Entity × Entity × Num)
  | [] => none
  | [k] =>
    if k ∈ N.index then some ((N.assign k).holder, (N.assign k).issuer, (N.assign k).share)
    else none
  | k :: ks =>
    if k ∈ N.index then
      match StakeNet.chainValue ops N ks with
      | none => none
      | some (h, i, s) =>
        if (N.assign k).issuer = h then
          some ((N.assign k).holder, i, ops.mul (N.assign k).share s)
        else none
    else none

/--
번짐의 기준.

**대응 비형식 개념:** 조문이 소유의 번짐에 붙이는 두 조건. 몫이 넘어야 할 선과 그 주체가 어디에
설립되어 있어야 하는가다.

**이 정의가 배제하는 사례:**
설립지 조건을 이 구조에 박는 읽기. 한 조는 그 나라에 설립된 주체를 들고 다른 조는 연합 밖에 설립된
주체를 들어 두 조가 넓히는 정의역이 서로 반대이므로, 박으면 한 술어가 두 조를 함께 담지 못한다.
조달처: E-68 §3-2 「한 술어가 두 조를 함께 담으려면 설립지를 받아야 하고」

**기각한 대체 정의:**
설립지를 나라의 열거로 받는 안. 그 열거가 조마다 다르고 조문이 그 목록을 자기 문면에 두지 않으므로
열거로 두면 그 원소를 지어내게 된다. 문턱을 참거짓으로 접어 넘었는지만 받는 안도 기각했다. 그 판정이
망 위의 몫에서 나오므로 접으면 몫을 비교하는 자리가 구조 밖으로 나가고, 이 구조가 조문의 기준을 드는
자리라는 성격을 잃는다.

**이상의 문턱은 그 몫 바로 앞의 값으로 받는다.** 지정된 주체를 드는 규정이 소유를 일정 몫 이상의 보유로
정의하고 사법재판소가 지분 절반에서 지배를 추정하는데, 경로의 판정이 몫을 문턱과 엄격한 비교로 맞대므로 그
규정의 기준은 문턱의 칸에 그 몫 바로 앞의 값을 넣는다. 그 꼴은 몫이 이산의 눈금 위에 있을 때만 서며, 회계층이
몫을 스케일된 정수로 넣으므로 그 눈금이 선다. 문턱을 칸으로 받는 꼴이 규정마다 다른 기준을 쓰게 하여, 초과를
드는 조문의 기준과 이상을 드는 규정의 기준이 한 술어로 접히지 않는다.
조달처: E-70 §6-2 「지정된 주체를 드는 규정 쪽에서 이상을 들고」

**수 체계를 매개변수로 받는다.** 문턱이 그 매개변수의 값이다.
-/
-- DD:CF-4294
structure ReachCriteria (Entity Num : Type) where
  /-- 몫이 넘어야 할 선. -/
  threshold : Num
  /-- 설립지 조건. 조마다 정의역이 반대이므로 구조가 이것을 받는다. -/
  established : Entity → Bool

/-- witness (A-3). **무엇을 증거하는가.** `ReachCriteria` 가 비어 있지 않다. 문턱이 `Unit` 이고
설립지 조건이 어디서나 거짓인 기준 하나를 든다. -/
-- DD:CF-31
def ReachCriteria.trivial : ReachCriteria Unit Unit where
  threshold := ()
  established := fun _ => false

/--
그 열이 그 주체에 이르는 번짐의 경로인가.

**대응 비형식 개념:** 그 간선의 열이 열거된 주체에서 시작하여 이 주체에 이르고 그 몫이 문턱을 넘는가.

**이 정의가 배제하는 사례:**
문턱과 같은 몫을 넘은 것으로 받는 읽기. 조문이 일정 몫을 넘게 소유한 것을 대상으로 들어 그 문면이
초과를 가리키므로, 같은 몫을 넘은 것으로 받으면 금지의 범위가 조문보다 넓어진다.
조달처: E-68 §2-3 「일정 몫을 넘는 공적 소유가 있거나」

**기각한 대체 정의:**
사슬의 머리가 열거되었는지를 묻지 않고 몫만 보는 안. 그러면 열거되지 않은 주체가 몫을 넘게 소유한
주체가 번짐에 들어와 금지의 범위가 조문보다 넓어진다. 꼬리가 이 주체인지를 묻지 않는 안도 기각했다.
그러면 망의 아무 사슬이나 이 주체의 번짐을 세워 판정이 주체를 가리지 않는다.

**수 체계를 매개변수로 받는다.** 문턱과 몫의 비교가 그 매개변수 위의 연산이다.
-/
-- DD:CF-4294
def StakeNet.chainQualifies {EIdx Entity Num Lvl : Type} [DecidableEq EIdx] [DecidableEq Entity]
    (ops : Ops Num Lvl) (N : StakeNet EIdx Entity Num) (C : ReachCriteria Entity Num)
    (D : Designation Entity) (e : Entity) (p : List EIdx) : Bool :=
  match N.chainValue ops p with
  | none => false
  | some (h, i, s) => D.cut h && decide (i = e) && ops.lt C.threshold s

/--
소유를 통한 번짐.

**대응 비형식 개념:** 그 주체가 설립지 조건을 채우고, 열거된 주체에서 그 주체에 이르는 사슬 가운데
몫이 문턱을 넘는 것이 있는가.

**이 정의가 배제하는 사례:**
설립지 조건을 묻지 않고 사슬만 보는 읽기. 두 조가 그 조건으로 서로 반대의 정의역을 넓히므로, 묻지
않으면 한 조가 금지의 밖에 둔 주체가 안으로 들어온다.
조달처: E-68 §2-4 「소유의 망 위에서 번지는 변을 설립지를 받지 않는 한 술어로 세우면 그 둘이 함께 담기지 않는다」

**기각한 대체 정의:**
사슬의 열거를 구조가 계산하게 하는 안. 그 계산은 망의 이음을 전량 훑는 일이고 모형이 값을 계산하는
자리가 되므로 이 층에 머물 수 없으며, 조문도 그 열거를 읽는 쪽에 주지 않는다. 경로가 여럿일 때 몫을
더해 문턱과 맞대는 안도 기각했다. 그 합산의 기준이 조문에 서지 않으므로 더하면 지어낸 기준이 판정에
들어간다.

**미국과 영국의 문면은 경로를 합친다.** 해외자산통제실과 산업안보국은 한 주체에 이르는 경로의 몫과 차단된
자들의 몫을 더해 문턱과 맞대고, 영국의 규정은 한 사람이 여러 경로로 가진 몫을 더하되 서로 다른 지정된
사람들의 몫은 공동 약정이 없으면 더하지 않는다. 경로를 더하는 안을 기각한 사유는 이 선언이 딛는 조문에
대해 그대로 서고, 그 합산을 체제마다 받는 꼴은 이 선언을 고치지 않고 `CF-4912` 가 기다린다.
조달처: E-94 §5-2 「보유자 사이의 합에서 유럽연합과 미국이 한쪽에 서고」

**수 체계를 매개변수로 받는다.** 문턱과 몫의 비교가 그 매개변수 위의 연산이다.
-/
-- DD:CF-4294
def StakeNet.reachedByOwnership {EIdx Entity Num Lvl : Type} [DecidableEq EIdx] [DecidableEq Entity]
    (ops : Ops Num Lvl) (N : StakeNet EIdx Entity Num) (C : ReachCriteria Entity Num)
    (D : Designation Entity) (chains : Finset (List EIdx)) (e : Entity) : Bool :=
  C.established e && decide (∃ p ∈ chains, N.chainQualifies ops C D e p = true)

/--
대리와 지시를 통한 번짐.

**대응 비형식 개념:** 그 주체가 금지에 든 어느 주체를 대신하여 또는 그 지시에 따라 행동하는가. 그
관계는 지분으로 재어지지 않는다.

**이 정의가 배제하는 사례:**
그 관계를 지분의 망에서 읽는 읽기. 조문의 그 항이 드는 관계가 행위로 재어지고 소유 공시가 그 값을
내지 않으므로, 망에서 읽으면 행위로만 선 관계가 통째로 사라진다.
조달처: E-68 §2-5 「그 관계는 지분으로 재어지지 않고 행위로 재어지며, 소유 공시가 그 값을 내지 않는다」

**기각한 대체 정의:**
본인의 열거를 앞의 두 갈래에서 구조가 계산하게 하는 안. 그 계산이 주체 전량의 열거를 요구하고 그
열거가 공시에서 나오지 않으므로, 구조가 그것을 계산하면 받을 수 없는 값을 자기 입력으로 들게 된다.
조문이 본인을 앞의 두 항에 든 주체로 묶는 것을 이 구조가 강제하지 않으며, 그 묶음은 이 선언을 부르는
쪽이 그 열거를 어떻게 채우는가에 걸린다. 관계를 주체에서 주체의 집합으로 가는 함수로 두는 안도
기각했다. 한 주체가 여럿을 대신하여 행동하는 배치를 조문이 막지 않으므로 그 값이 하나일 수 없고, 쌍에
붙는 판정으로 두면 그 배치가 그대로 선다.

**수 체계를 받지 않는다.** 두 인자가 판정과 열거이며 수를 들지 않는다.
-/
-- DD:CF-4295
def reachedByConduct {Entity : Type} (actingFor : Entity → Entity → Bool)
    (principals : Finset Entity) (e : Entity) : Bool :=
  decide (∃ f ∈ principals, actingFor e f = true)

/--
금지의 번짐.

**대응 비형식 개념:** 그 주체가 그 시점에 금지의 안에 서는가. 열거되어 잘린 것과 소유로 번진 것과
대리로 번진 것의 어느 하나라도 서면 안에 선다.

**이 정의가 배제하는 사례:**
세 갈래의 논리곱으로 두는 읽기. 조문의 항이 세 갈래를 나란히 들어 어느 하나로도 금지가 서므로, 곱으로
두면 한 갈래로만 든 주체가 금지의 밖으로 나온다.
조달처: E-68 §2-5 「앞의 두 항에 든 주체를 대신하여 또는 그 지시에 따라 행동하는 주체를 금지에 넣는다」

**기각한 대체 정의:**
갈래의 목록을 내고 목록이 비어 있지 않음으로 두는 안. 그러면 판정이 목록 위의 계산을 지나 `Decidable`
인스턴스가 목록의 상등에 걸리고, 판정을 `Bool` 로 두어 그 인스턴스가 `Bool` 에서 나오게 하는 꼴과
갈린다. 어느 갈래로 들었는지를 함께 내는 안도 기각했다. 그 갈래가 겹칠 수 있어 값이 하나일 수 없고,
갈래별 판정이 이미 따로 서 있으므로 부르는 쪽이 그것을 각각 물으면 된다.

**수 체계를 매개변수로 받는다.** 소유 갈래가 그 매개변수 위의 비교를 든다.
-/
-- DD:CF-4296
def StakeNet.reaches {EIdx Entity Num Lvl : Type} [DecidableEq EIdx] [DecidableEq Entity]
    (ops : Ops Num Lvl) (N : StakeNet EIdx Entity Num) (C : ReachCriteria Entity Num)
    (D : Designation Entity) (chains : Finset (List EIdx))
    (actingFor : Entity → Entity → Bool) (principals : Finset Entity) (e : Entity) : Bool :=
  D.cut e || N.reachedByOwnership ops C D chains e || reachedByConduct actingFor principals e

/--
증거를 드는 주체의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거를 들기 위한 색인이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
실재하는 주체의 이름을 생성자로 두는 읽기. 그 열거가 당국의 조작으로 바뀌므로 이름을 박으면 그 값이
박는 순간 낡으며, 실증 결과를 추출하지 않는다는 요구에도 걸린다.
조달처: E-68 §2-3 「그 열거에 넣는 것이 당국의 조작이다」

**기각한 대체 정의:**
증거를 `Unit` 위에서만 드는 안. 가려야 할 결합이 번짐의 두 합과 소유 경로의 곱 셋이고 인자마다 그것만
참인 자리가 필요하므로, `Unit` 로 두면 그 증거가 한 주체에 접혀 그 결합을 뒤집은 변이가 통과한다.

**수 체계를 받지 않는다.** 열한 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4296
inductive ReachWitnessEntity where
  /-- 열거되어 잘린 주체. -/
  | listed
  /-- 열거된 주체가 몫을 넘게 소유한 주체. -/
  | ownedByListed
  /-- 열거된 주체의 소유가 문턱과 같은 주체. -/
  | ownedBelow
  /-- 몫을 넘게 소유되었으나 설립지 조건이 거짓인 주체. -/
  | ownedForeign
  /-- 열거되지 않은 주체가 몫을 넘게 소유한 주체. -/
  | ownedByOutsider
  /-- 열거된 주체가 몫을 넘게 소유하고 그 자신도 다른 주체를 소유한 주체. -/
  | intermediate
  /-- 사슬 둘을 거쳐 간접으로만 소유된 주체. -/
  | indirect
  /-- 열거된 주체의 지시에 따라 행동하는 주체. -/
  | agent
  /-- 어느 경로에도 들지 않는 주체. -/
  | outside
  /-- 중간 주체가 문턱에 못 미치는 몫으로만 소유한 주체. -/
  | thin
  /-- 그 주체가 다시 몫을 넘게 소유한 주체. -/
  | deep
  deriving DecidableEq, Repr

/--
증거를 드는 간선의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거의 망에 색인을 주는 자리이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
간선을 주체의 쌍으로 색인하는 읽기. 같은 쌍에 지분이 둘 기록되는 것을 공시가 막지 않으므로 쌍으로
색인하면 그 배치를 증거가 들 수 없다.
조달처: E-68 §2-4 「그 열거된 주체가 직접이나 간접으로 일정 몫을 넘게 소유한 것」

**기각한 대체 정의:**
간선을 하나만 두는 안. 사슬 하나로는 간선의 열이 몫을 합성하는 것이 보이지 않고 문턱과 같은 몫이 번짐을
낳지 않는다는 것도 보이지 않으므로, 가려야 할 자리마다 간선이 하나씩 필요하다. 몫이 모두 같은 간선으로만
두는 안도 기각했다. 그 사슬에서는 몫의 곱과 합과 머리의 몫과 꼬리의 몫이 같은 값을 내므로 그 넷이 갈리지
않고, 곱을 다른 연산으로 바꾼 판이 그대로 선다.

**수 체계를 받지 않는다.** 여덟 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4296
inductive ReachWitnessEdge where
  /-- 열거된 주체가 몫을 넘게 소유한 간선. -/
  | toOwned
  /-- 열거된 주체의 소유가 문턱과 같은 간선. -/
  | toBelow
  /-- 설립지 조건이 거짓인 주체를 향한 간선. -/
  | toForeign
  /-- 열거되지 않은 주체에서 나가는 간선. -/
  | toOutsiderOwned
  /-- 열거된 주체가 중간 주체를 소유한 간선. -/
  | toIntermediate
  /-- 중간 주체가 간접 소유의 끝을 소유한 간선. -/
  | toIndirect
  /-- 중간 주체가 문턱에 못 미치는 몫으로만 소유한 간선. -/
  | toThin
  /-- 그 주체가 다시 몫을 넘게 소유한 간선. -/
  | toDeep
  deriving DecidableEq, Repr

/--
증거를 드는 몫의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거에 비교 가능한 몫을 주는 자리이며 비형식 개념에 대응하지
않는다.

**이 정의가 배제하는 사례:**
몫을 자연수로 두는 읽기. 이 층이 무차원이고 시점 인덱스 밖의 자연수를 쓰지 못하므로, 자연수로 두면
그 층의 수 체계 요구에 걸린다.
조달처: E-68 §2-3 「일정 몫을 넘는 공적 소유가 있거나」

**기각한 대체 정의:**
증거의 몫을 `Unit` 로 두는 안. 같은 층의 연산 구조가 `Unit` 위에서 비교를 늘 참으로 내므로 문턱과 같은
몫이 번짐을 낳지 않는다는 것이 그 위에서 보이지 않는다. 생성자를 둘로 두는 안도 기각했다. 문턱과 같은
몫과 문턱을 넘는 몫과 문턱에 못 미치는 몫이 갈려야 비교가 세 자리에서 재어진다.

**수 체계를 받지 않는다.** 세 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4296
inductive ReachWitnessNum where
  /-- 문턱에 못 미치는 몫. -/
  | small
  /-- 문턱과 같은 몫. -/
  | bound
  /-- 문턱을 넘는 몫. -/
  | large
  deriving DecidableEq, Repr

/-- **무엇을 증거하는가.** 세 몫 위의 연산 구조다. 곱을 두 몫의 작은 쪽으로 두어 사슬의 몫이 가장
작은 간선의 몫으로 내려가는 것을 담고, 합을 큰 쪽으로 두며 비교를 열거의 순서로 둔다. -/
-- DD:CF-4296
def reachWitnessOps : Ops ReachWitnessNum Unit where
  mul := fun a b =>
    match a, b with
    | .small, _ => .small
    | _, .small => .small
    | .bound, _ => .bound
    | _, .bound => .bound
    | .large, .large => .large
  add := fun a b =>
    match a, b with
    | .large, _ => .large
    | _, .large => .large
    | .bound, _ => .bound
    | _, .bound => .bound
    | .small, .small => .small
  le := fun a b =>
    match a, b with
    | .small, _ => true
    | .bound, .small => false
    | .bound, _ => true
    | .large, .large => true
    | .large, _ => false
  lt := fun a b =>
    match a, b with
    | .small, .small => false
    | .small, _ => true
    | .bound, .large => true
    | .bound, _ => false
    | .large, _ => false
  lvlAtLeast := fun _ _ => true
  lvlEq := fun _ _ => true

/-- **무엇을 증거하는가.** 증거의 소유의 망이다. 열거된 주체가 셋을 몫을 넘게 소유하고 하나를 문턱과
같은 몫으로 소유하며, 열거되지 않은 주체가 하나를 몫을 넘게 소유한다. 중간 주체가 하나를 몫을 넘게
소유하고 하나를 문턱에 못 미치는 몫으로 소유하며, 그 못 미치는 주체가 다시 하나를 몫을 넘게 소유한다. -/
-- DD:CF-4296
def reachWitnessNet : StakeNet ReachWitnessEdge ReachWitnessEntity ReachWitnessNum where
  index := {.toOwned, .toBelow, .toForeign, .toOutsiderOwned, .toIntermediate, .toIndirect,
            .toThin, .toDeep}
  assign := fun k =>
    match k with
    | .toOwned => ⟨.listed, .ownedByListed, .large⟩
    | .toBelow => ⟨.listed, .ownedBelow, .bound⟩
    | .toForeign => ⟨.listed, .ownedForeign, .large⟩
    | .toOutsiderOwned => ⟨.outside, .ownedByOutsider, .large⟩
    | .toIntermediate => ⟨.listed, .intermediate, .large⟩
    | .toIndirect => ⟨.intermediate, .indirect, .large⟩
    | .toThin => ⟨.intermediate, .thin, .small⟩
    | .toDeep => ⟨.thin, .deep, .large⟩

/-- **무엇을 증거하는가.** 증거의 지정 상태다. 열거된 주체 하나만 어느 부에 넣고 어느 허가도 내지
않는다. -/
-- DD:CF-4296
def reachWitnessDesignation : Designation ReachWitnessEntity where
  listedUnder := fun e g =>
    match e, g with
    | .listed, .purposeFrustration => true
    | _, _ => false
  relieved := fun _ => false

/-- **무엇을 증거하는가.** 증거의 번짐 기준이다. 문턱을 문턱과 같은 몫으로 두고 설립지 조건을 한
주체에서만 거짓으로 둔다. -/
-- DD:CF-4296
def reachWitnessCriteria : ReachCriteria ReachWitnessEntity ReachWitnessNum where
  threshold := .bound
  established := fun e =>
    match e with
    | .ownedForeign => false
    | _ => true

/-- **무엇을 증거하는가.** 증거의 사슬 열거다. 간선 하나로 선 사슬 다섯과 간선 둘로 선 사슬 둘과
간선 셋으로 선 사슬 하나를 든다. -/
-- DD:CF-4296
def reachWitnessChains : Finset (List ReachWitnessEdge) :=
  {[.toOwned], [.toBelow], [.toForeign], [.toOutsiderOwned], [.toIntermediate],
   [.toIntermediate, .toIndirect], [.toThin, .toDeep],
   [.toIntermediate, .toThin, .toDeep]}

/-- **무엇을 증거하는가.** 증거의 대리 관계와 본인의 열거다. 한 주체만 열거된 주체의 지시에 따라
행동하고 본인의 열거가 그 열거된 주체 하나를 든다. -/
-- DD:CF-4296
def reachWitnessActingFor : ReachWitnessEntity → ReachWitnessEntity → Bool := fun e f =>
  match e, f with
  | .agent, .listed => true
  | _, _ => false

/-- **무엇을 증거하는가.** 증거의 본인 열거다. 열거된 주체 하나를 든다. -/
-- DD:CF-4296
def reachWitnessPrincipals : Finset ReachWitnessEntity := {.listed}

/-- **무엇을 증거하는가.** 이상의 문턱을 받는 증거의 번짐 기준이다. 문턱만 문턱과 같은 몫 바로 앞의 몫으로
바꾸고 설립지 조건은 증거의 번짐 기준의 것을 그대로 쓴다. -/
-- DD:CF-4909
def reachWitnessInclusiveCriteria : ReachCriteria ReachWitnessEntity ReachWitnessNum :=
  { reachWitnessCriteria with threshold := .small }

/-- **무엇을 증거하는가.** 지분 절반의 추정과 그 반박을 드는 재량 지위다. 성문의 자리를 이상의 문턱을 받은
소유 갈래로 두고, 문턱과 같은 몫으로 소유된 주체에만 반박을 받아들인 당국의 자리를 거짓으로 놓는다. -/
-- DD:CF-4909
def reachWitnessPresumption : DiscretionaryStanding ReachWitnessEntity Bool where
  statutory := fun e =>
    reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessInclusiveCriteria
      reachWitnessDesignation reachWitnessChains e
  determined := fun e =>
    match e with
    | .ownedBelow => some false
    | _ => none

/--
번짐의 세 갈래가 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
한 갈래로만 든 주체가 금지의 밖에 서거나, 어느 갈래에도 들지 않은 주체가 금지의 안에 서야 한다. 그
관측은 번짐이 세 갈래의 논리합이 아니라는 뜻이며, 앞은 한 갈래로 든 주체가 범위 밖으로 나오는 것이고
뒤는 어느 갈래에도 없는 주체가 범위 안으로 들어오는 것이다.

**존재 형태로 진술하는 까닭(T-6):**
갈래마다 그것만 참인 주체와 셋 다 거짓인 주체를 들어야 보인다. 임의의 배치에서 각 갈래가 홀로 가르는
것이 아니라 나머지가 거짓인 자리에서만 그 가름이 보이고, 그 논리합이 거짓이 되는 자리도 셋이 함께 거짓인
주체에서만 선다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 번짐을 세 갈래의 논리합으로 둔 결합마다 그 인자가 홀로 값을 가르는 증거를 드는
유일한 자리이고, 그 증거가 없으면 그 결합을 뒤집은 변이가 통과한다.
-/
-- DD:CF-4296
theorem reaches_pins_each_disjunct :
    reachWitnessDesignation.cut .listed = true ∧
      reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation reachWitnessChains .listed = false ∧
      reachedByConduct reachWitnessActingFor reachWitnessPrincipals .listed = false ∧
      reachWitnessNet.reaches reachWitnessOps reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals .listed = true ∧
      reachWitnessDesignation.cut .ownedByListed = false ∧
      reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation reachWitnessChains .ownedByListed = true ∧
      reachedByConduct reachWitnessActingFor reachWitnessPrincipals .ownedByListed = false ∧
      reachWitnessNet.reaches reachWitnessOps reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals .ownedByListed = true ∧
      reachWitnessDesignation.cut .agent = false ∧
      reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation reachWitnessChains .agent = false ∧
      reachedByConduct reachWitnessActingFor reachWitnessPrincipals .agent = true ∧
      reachWitnessNet.reaches reachWitnessOps reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals .agent = true ∧
      reachWitnessDesignation.cut .outside = false ∧
      reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation reachWitnessChains .outside = false ∧
      reachedByConduct reachWitnessActingFor reachWitnessPrincipals .outside = false ∧
      reachWitnessNet.reaches reachWitnessOps reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals .outside = false := by
  -- 증거의 망과 지정과 대리 관계가 상수이고 세 갈래의 판정과 그 논리합이 그 위의 계산이므로
  -- 각 등식이 계산으로 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
소유 갈래의 두 조건이 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
설립지 조건이 거짓인 주체가 소유로 번진 것으로 나오거나, 사슬이 없는 주체가 그렇게 나와야 한다. 그
관측은 소유 갈래가 설립지 조건과 사슬의 존재의 곱이 아니라는 뜻이다.

**존재 형태로 진술하는 까닭(T-6):**
한 조건만 뒤집힌 배치를 조건마다 들어야 보인다. 두 조건이 함께 참인 자리와 함께 거짓인 자리만 들면 곱과
합의 값이 그 둘에서 같아 그 결합을 뒤집은 변이가 통과하므로, 사슬은 있으나 설립지 조건이 거짓인 주체와
설립지 조건은 참이나 사슬이 없는 주체를 함께 들어 조건마다 그 홀로 가름을 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 설립지 조건이 두 조에서 반대의 정의역을 넓히는 것이 이 구조에 실제로 선다는 것을
드는 유일한 자리이고, 그 조건을 인자로 받은 꼴이 그 자리에서 값을 가린다.
-/
-- DD:CF-4294
theorem reachedByOwnership_pins_establishment :
    reachWitnessCriteria.established .ownedForeign = false ∧
      reachWitnessNet.chainQualifies reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation .ownedForeign [.toForeign] = true ∧
      reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation reachWitnessChains .ownedForeign = false ∧
      reachWitnessCriteria.established .ownedByListed = true ∧
      reachWitnessNet.chainQualifies reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation .ownedByListed [.toOwned] = true ∧
      reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation reachWitnessChains .ownedByListed = true ∧
      reachWitnessCriteria.established .outside = true ∧
      reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation reachWitnessChains .outside = false := by
  -- 설립지 조건과 사슬의 열거가 상수이고 경로의 판정과 소유 갈래가 그 위의 계산이므로 각
  -- 등식이 계산으로 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
경로의 세 조건이 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
열거되지 않은 주체에서 시작한 사슬이 번짐의 경로로 나오거나, 그 주체에 이르지 않는 사슬이 그렇게
나오거나, 문턱과 같은 몫의 사슬이 그렇게 나와야 한다. 그 관측은 경로의 판정이 세 조건의 곱이 아니라는
뜻이다.

**존재 형태로 진술하는 까닭(T-6):**
조건마다 그것만 거짓인 사슬을 들어야 보인다. 세 조건이 함께 참인 자리만 들면 어느 조건을 뒤집어도 값이
그대로이거나 함께 움직이므로, 머리가 열거되지 않은 사슬과 꼬리가 그 주체가 아닌 사슬과 몫이 문턱과 같은
사슬을 함께 들어 조건마다 그 홀로 가름을 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 문턱을 넘는 것이 엄격한 비교라는 것과 사슬의 머리가 열거되어야 한다는 것을 한
자리에서 드는 유일한 자리다.
-/
-- DD:CF-4294
theorem chainQualifies_pins_each_conjunct :
    reachWitnessDesignation.cut .listed = true ∧
      reachWitnessNet.chainQualifies reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation .ownedByListed [.toOwned] = true ∧
      reachWitnessDesignation.cut .outside = false ∧
      reachWitnessNet.chainQualifies reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation .ownedByOutsider [.toOutsiderOwned] = false ∧
      reachWitnessNet.chainQualifies reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation .ownedBelow [.toOwned] = false ∧
      reachWitnessOps.lt reachWitnessCriteria.threshold .bound = false ∧
      reachWitnessNet.chainQualifies reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation .ownedBelow [.toBelow] = false := by
  -- 사슬마다 그 값이 망 위의 계산으로 나오고 경로의 판정이 그 값의 세 조건의 곱이므로 각
  -- 등식이 계산으로 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
간접 소유가 사슬을 타고 서는 주체가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
간선 둘로 이어진 사슬이 값을 내지 못하거나, 그 값의 보유 주체가 사슬의 머리가 아니거나, 이음이 맞지 않는
열이 값을 내야 한다. 그 관측은 간접 소유가 이 구조에서 재어지지 않는다는 뜻이며, 그러면 조문이 직접과
간접을 함께 드는 것이 담기지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
간선 둘로 이어진 사슬을 들어야 보인다. 임의의 열이 사슬을 이루는 것이 아니라 이음이 맞는 열에서만 값이
서고, 그 이음이 열의 순서에 달렸다는 것도 간선이 둘 이상인 사슬에서만 보인다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 사슬이 이어져 간접 소유가 서고 그 사슬의 머리가 열거된 주체라는 것과 이음이 맞지
않는 열이 값을 내지 않는다는 것을 드는 유일한 자리이며, 직접 소유만으로는 그 이음이 재어지지 않는다. 그
값이 간선의 몫들의 곱이라는 것은 몫이 모두 같은 사슬에서 곱과 합과 머리의 몫과 꼬리의 몫이 갈리지 않으므로
이 자리가 들지 않는다.
-/
-- DD:CF-4293
theorem exists_indirect_reach_through_chain :
    reachWitnessNet.chainValue reachWitnessOps [.toIntermediate, .toIndirect]
        = some (.listed, .indirect, .large) ∧
      reachWitnessNet.chainQualifies reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation .indirect [.toIntermediate, .toIndirect] = true ∧
      reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation reachWitnessChains .indirect = true ∧
      reachWitnessNet.chainValue reachWitnessOps [.toIndirect, .toIntermediate] = none := by
  -- 간선의 열이 내는 값은 머리 간선의 발행 주체를 나머지 열이 낸 값의 보유 주체와 맞대는
  -- 재귀 계산이고 증거의 망이 상수이므로, 이음이 맞는 열과 끊긴 열 모두 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
설립지 조건을 서로 반대로 넣으면 번짐이 다른 주체를 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
설립지 조건을 서로 반대로 넣은 두 기준이 같은 주체를 번짐에 들여야 한다. 그 관측은 그 조건이 번짐의
정의역을 가르지 않는다는 뜻이며, 그러면 두 조가 서로 반대의 정의역을 넓히는 것이 이 구조에서 사라진다.

**존재 형태로 진술하는 까닭(T-6):**
조건을 서로 반대로 넣은 두 기준과 그 둘에서 갈리는 주체를 들어야 보인다. 시스템 수준의 성문 조건이 개별
주체의 번짐을 결정하지 않으므로 전칭으로는 서지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 한 술어가 두 조를 함께 담는다는 것을 드는 유일한 자리이고, 그 담음이 없으면
설립지를 인자로 받은 꼴이 쓰이지 않은 채 남는다.
-/
-- DD:CF-4294
theorem exists_establishment_flip_moves_reach :
    ∃ (inside outside_ : ReachWitnessEntity → Bool),
      (∀ e, inside e = ! outside_ e) ∧
        reachWitnessNet.reachedByOwnership reachWitnessOps
            { reachWitnessCriteria with established := inside }
            reachWitnessDesignation reachWitnessChains .ownedByListed = true ∧
        reachWitnessNet.reachedByOwnership reachWitnessOps
            { reachWitnessCriteria with established := outside_ }
            reachWitnessDesignation reachWitnessChains .ownedByListed = false ∧
        reachWitnessNet.reachedByOwnership reachWitnessOps
            { reachWitnessCriteria with established := outside_ }
            reachWitnessDesignation reachWitnessChains .ownedForeign = true := by
  -- 증거의 설립지 조건과 그 부정을 두 조건으로 든다. 앞은 한 주체에서만 거짓이고 뒤는 그
  -- 주체에서만 참이며, 둘이 서로 부정이라는 것은 부정을 두 번 걸면 원래 값이 된다는 것에서
  -- 나오고 나머지 등식은 계산으로 값이 나와 `rfl` 로 닫힌다.
  exact ⟨reachWitnessCriteria.established, fun e => ! reachWitnessCriteria.established e,
    fun e => (Bool.not_not (reachWitnessCriteria.established e)).symm, rfl, rfl, rfl⟩

/--
사슬의 몫이 가장 작은 간선의 몫으로 내려가 번짐이 끊기는 주체가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
간선 셋으로 이어진 사슬의 몫이 그 가운데 가장 작은 간선의 몫과 다르거나, 그 몫이 문턱에 못 미치는데도
번짐이 그 주체에 닿아야 한다. 앞의 관측은 사슬의 몫이 간선의 몫들의 곱으로 재어지지 않는다는 뜻이고 뒤의
관측은 문턱이 사슬의 끝에서 재어지지 않는다는 뜻이며, 둘 다 조문이 간접 소유에 문턱을 거는 것이 이 구조에
담기지 않는다는 것이다.

**존재 형태로 진술하는 까닭(T-6):**
몫이 갈리는 간선을 품은 사슬을 들어야 보인다. 몫이 모두 같은 사슬에서는 곱과 합과 머리의 몫과 꼬리의 몫이
같은 값을 내므로 그 넷이 갈리지 않으며, 시스템 수준의 문턱이 개별 사슬의 몫을 정하지 않으므로 전칭으로는
서지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 사슬의 몫이 간선의 몫들의 곱으로 선다는 것과 그 몫이 문턱에 못 미치면 번짐이
끊긴다는 것을 드는 유일한 자리이고, 그 갈림이 없으면 곱을 합이나 한 간선의 몫으로 바꾼 판이 그대로 선다.
-/
-- DD:CF-4293
theorem exists_thin_link_blocks_reach :
    reachWitnessNet.chainValue reachWitnessOps [.toThin, .toDeep]
        = some (.intermediate, .deep, .small) ∧
      reachWitnessNet.chainValue reachWitnessOps [.toIntermediate, .toThin, .toDeep]
        = some (.listed, .deep, .small) ∧
      reachWitnessOps.lt reachWitnessCriteria.threshold .small = false ∧
      reachWitnessNet.chainQualifies reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation .deep [.toIntermediate, .toThin, .toDeep] = false ∧
      reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation reachWitnessChains .deep = false := by
  -- 사슬의 값은 이음을 맞대며 간선의 몫을 곱하는 재귀 계산이고 증거의 곱이 두 몫의 작은 쪽을
  -- 내므로, 못 미치는 간선을 품은 사슬의 몫이 그 간선의 몫으로 내려가는 것을 포함해 각 등식이
  -- 계산으로 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

/--
이상의 문턱을 받은 기준이 문턱과 같은 몫으로 소유된 주체를 번짐에 들이고, 그 주체에 놓인 반박이 성문의
자리를 덮는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
문턱을 문턱과 같은 몫 바로 앞의 몫으로 둔 기준에서 문턱과 같은 몫으로 소유된 주체가 번짐에 들지 않거나, 반박이
놓인 그 주체의 자리가 성문의 자리로 나오거나, 반박이 놓이지 않은 주체의 자리가 성문의 자리와 달라야 한다. 앞은
기준의 칸이 이상의 규정을 받지 못한다는 뜻이고, 뒤의 둘은 재량 지위가 반박 가능한 추정의 꼴을 갖지 않는다는
뜻이다.

**존재 형태로 진술하는 까닭(T-6):**
엄격한 기준과 이상의 기준을 나란히 두고 반박이 놓인 주체와 놓이지 않은 주체를 함께 들어야 보인다. 성문의 기준이
개별 주체의 자리를 정하지 않고 당국이 사안마다 반박을 받아들이므로 전칭으로는 서지 않는다.

**가정을 두지 않는다.**

**소유의 번짐은 열거 없이 서므로 당국이 손대지 않은 주체의 자리를 성문의 자리가 정한다.** 지정을 재량 지위로
내려 보낸 사상은 당국의 열거가 모든 주체의 자리를 채우는 꼴이나, 지분의 몫으로 걸린 주체는 열거를 기다리지 않고
지분 절반의 자리는 추정되어 동결되어야 하므로, 이 증거는 반박이 놓인 주체에만 재량의 칸을 채운다.
조달처: E-85 §4-2 「그 주체가 보유하거나 지배하는 것으로 추정되어 동결되어야 한다」

**T-3 분류:** 기여다. 지분 절반의 추정을 기준의 문턱과 재량 지위가 받는다는 것을 구조 안의 명제로 드는 유일한
자리이고, 그 명제가 없으면 그 추정을 받는 갈래가 따로 서야 한다.
-/
-- DD:CF-4909
theorem inclusive_threshold_reaches_half_and_rebuttal_overrides :
    reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessCriteria
        reachWitnessDesignation reachWitnessChains .ownedBelow = false ∧
      reachWitnessNet.reachedByOwnership reachWitnessOps reachWitnessInclusiveCriteria
        reachWitnessDesignation reachWitnessChains .ownedBelow = true ∧
      reachWitnessPresumption.isDetermined .ownedBelow = true ∧
      reachWitnessPresumption.resolve .ownedBelow = false ∧
      reachWitnessPresumption.isDetermined .ownedByListed = false ∧
      reachWitnessPresumption.resolve .ownedByListed = true := by
  -- 두 기준과 재량의 배치가 상수이고 소유 갈래와 자리의 판정이 그 위의 계산이므로 각 등식이 계산으로
  -- 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Definition
