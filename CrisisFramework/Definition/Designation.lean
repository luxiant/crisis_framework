/-
정의층 — 지정과 당국의 재량이 주체의 자리를 움직이는 자리

규율: L-10(무차원 + 시점 인덱스 `ℕ`), L-13(시점 족), D-2(docstring 3항목),
      D-3(실제 역사 사례), A-3(witness), A-8(논리 결합의 증거), C-3(판정은 `Bool`),
      T-2(반증 조건), T-3(분류), T-6(존재 형태).

**구조를 둘로 두고 뒤가 앞을 담는 꼴로 둔다.** 지정이 당국의 조작이 주체의 자리를 움직이는 한
사례이고 그 움직임의 일반 꼴은 자리의 타입을 매개변수로 받으므로, 지정을 그 일반 꼴의 사례로
내려 보내는 선언이 둘 사이에 선다. 그 일반 꼴을 지정에 박으면 액면가 약속의 강도를 묻는 자리에
쓸 수 없고, 꼴만 일반으로 두고 강도를 넣어 보지 않으면 그 꼴이 그 자리에 실제로 서는지가
재어지지 않는다.

**지정이 기준의 성립이 아니라 열거의 구성원임이다.** 구조가 받는 것은 당국이 어느 부에 넣었는가이고
기준의 성립은 바깥에서 받는 판정으로 선다. 그 둘이 한 주체에서 갈릴 수 있음이 이 파일의 기여다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Nat.Notation
import CrisisFramework.Definition.Hierarchy

namespace CrisisFramework.Definition

/--
지정의 사유.

**대응 비형식 개념:** 당국이 한 주체를 제재 목록의 어느 부에 넣었는가. 부마다 표제가 달리고 그
표제가 그 지정을 낳은 판정을 가른다.

**이 정의가 배제하는 사례:**
사유를 하나로 접고 지정을 단일 술어로 두는 읽기. 조문이 가리키는 부속서가 부를 셋으로 가르면서
부마다 표제를 두어 사유를 가르므로, 접으면 어느 사유로 지정됐는지가 그 값에서 사라진다.
조달처: E-68 §2-6 「지정이 단일 술어가 아니라 사유별 술어의 합이다」

**기각한 대체 정의:**
사유를 용어집의 분할로 등록하는 안. 세 사유의 이름이 한 부속서의 부 표제에서 그대로 오고 세
사유가 같은 칼럼에서 읽혀 측정 대응이 다르지 않으므로, 측정 대응이 다르지 않은 두 개념을 분할하지
말라는 요구가 그 분할을 막는다. 사유를 자유 문자열로 받는 안도 기각했다. 그러면 부의 수가 바뀔 때
구조가 조용히 넓어지고 판정이 열거 위의 계산으로 닫히지 않는다.

**수 체계를 받지 않는다.** 세 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4250
inductive DesignationGround where
  /-- 이 규칙과 다른 규칙의 금지가 추구하는 목적을 현저히 좌절시킨 것. -/
  | purposeFrustration
  /-- 침략 전쟁을 지원한 것. -/
  | aggressionSupport
  /-- 특정 조들의 금지를 현저히 좌절시킨 것. -/
  | listedProhibitionFrustration
  deriving DecidableEq, Repr

/--
한 시점의 지정 상태.

**대응 비형식 개념:** 당국이 어느 주체를 어느 사유의 부에 열거했고 그 가운데 어느 주체의 거래를
개별 허가로 풀었는가. 두 칸이 다 당국의 조작이며 구조가 그것을 계산하지 않고 받는다.

**이 정의가 배제하는 사례:**
기준의 성립을 칸으로 두고 구조가 그것을 계산하게 하는 읽기. 조문의 한 조가 공적 지배와 일정 몫을
넘는 공적 소유와 이익에 참가할 권리와 그 밖의 실질적 경제 관계를 기준으로 나란히 들면서 그 결과를
부속서의 열거로 닫으므로, 기준을 술어로 두면 그 구조가 당국이 실제로 하는 일과 어긋난다.
조달처: E-68 §2-3 「그 끝에 그 부속서에 열거된 것으로 범위를 닫는다」

**기각한 대체 정의:**
구성원임을 사유 없이 참거짓 하나로 두는 안. 그러면 사유별로 갈린 부가 그 값에서 사라지고 해제와
이의의 경로가 사유마다 다른 것이 담기지 않는다. 허가를 이 구조 밖의 다른 구조로 두는 안도
기각했다. 허가가 열거된 주체에만 서므로 그 정의역이 이 구조의 첫 칸에 매여 있고, 따로 두면 두
구조 사이에 그 매임을 드는 자리가 더 필요해진다.

**수 체계를 받지 않는다.** 두 칸이 판정과 열거이며 수를 들지 않는다.
-/
-- DD:CF-4248
structure Designation (Entity : Type) where
  /-- 그 주체가 그 사유의 부에 열거되어 있는가. 당국의 조작이다. -/
  listedUnder : Entity → DesignationGround → Bool
  /-- 그 주체의 거래가 개별 허가로 풀렸는가. 당국의 조작이다. -/
  relieved : Entity → Bool

/-- witness (A-3). **무엇을 증거하는가.** `Designation` 이 비어 있지 않다. 어느 부에도 열거하지
않고 어느 허가도 내지 않은 지정 상태 하나를 든다. -/
-- DD:CF-4248
def Designation.trivial : Designation Unit where
  listedUnder := fun _ _ => false
  relieved := fun _ => false

/--
지정 상태의 시점 족.

**대응 비형식 개념:** 지정이 시점에 따라 달라지는 것. 개정의 사슬과 조문 본문의 날짜와 부속서의
발효일 칸이 그 달라짐을 낸다.

**이 정의가 배제하는 사례:**
지정을 시점 없는 하나로 두는 읽기. 같은 항에서 앞선 날에 걸리는 것과 뒤의 날에 걸리는 것이 다르고
뒤가 앞을 포함하면서 넓으므로, 시점을 떼면 한 문면이 시점에 따라 다른 것을 금지하는 것이 담기지
않는다.
조달처: E-68 §2-8 「앞선 날에 걸리는 것이 그 나라 중앙은행의 금융 전문 체계」

**기각한 대체 정의:**
시점을 구조의 칸으로 받는 안. 그러면 한 지정 상태가 여러 시점을 함께 들어 그 칸의 값이 어느 시점의
것인지가 서지 않으며, 정의층 대상을 시점 인덱스를 갖는 족으로 정의하라는 요구와도 갈린다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 인덱스를 뺀 나머지가 판정과 열거다.
-/
-- DD:CF-4248
abbrev DesignationFamily (Entity : Type) := ℕ → Designation Entity

/-- **무엇을 증거하는가.** 시점에 따라 변하지 않는 족을 만드는 수단이다. 받은 지정 상태를 모든
시점에 두는 상수 족을 낸다. -/
-- DD:CF-4248
def DesignationFamily.constant {Entity : Type} (D : Designation Entity) :
    DesignationFamily Entity := fun _ => D

/--
그 주체가 어느 사유로든 열거되어 있는가.

**대응 비형식 개념:** 사유를 묻지 않고 그 주체가 목록에 있는지만 묻는 것.

**이 정의가 배제하는 사례:**
세 사유의 논리곱으로 두는 읽기. 부마다 다른 주체를 들므로 한 주체가 세 부에 함께 서는 것이 통상이
아니며, 곱으로 두면 한 부에만 선 주체가 목록 밖으로 나온다.
조달처: E-68 §2-6 「부를 셋으로 가르고 부마다 다른 주체를 든다」

**기각한 대체 정의:**
사유의 목록을 내고 목록이 비어 있지 않음으로 두는 안. 그러면 판정이 목록 위의 계산을 지나 `Decidable`
인스턴스가 목록의 상등에 걸리고, 판정을 `Bool` 로 두어 그 인스턴스가 `Bool` 에서 나오게 하는 꼴과
갈린다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4248
def Designation.listedAnywhere {Entity : Type} (D : Designation Entity) (e : Entity) : Bool :=
  D.listedUnder e .purposeFrustration
    || D.listedUnder e .aggressionSupport
    || D.listedUnder e .listedProhibitionFrustration

/--
그 주체가 그 시점에 잘렸는가.

**대응 비형식 개념:** 목록에 있고 그 거래가 개별 허가로 풀리지 않은 것. 목록에 드는 것만으로는
금지가 서지 않는다.

**이 정의가 배제하는 사례:**
구성원임만으로 절단을 판정하는 읽기. 목록의 자료 명세가 열거된 당사자와의 거래가 허가될 수 있음을
자기 문면으로 적으므로, 구성원임만으로 두면 허가받은 주체가 잘린 것으로 나와 그 판정이 공표된
목록과 어긋난다.
조달처: E-69 §2-6 「열거의 구성원임이 금지의 성립과 같지 않다」

**기각한 대체 정의:**
허가를 사유별로 받는 안. 허가가 그 주체와의 거래에 걸리고 그 주체가 어느 부에 들었는지에 걸리지
않으므로, 사유별로 받으면 한 주체에 사유마다 다른 허가가 서는 구조가 되어 그 문면이 드는 것보다
넓어진다. 허가를 절단의 부정으로 두는 안도 기각했다. 허가받지 않았다는 것과 목록에 없다는 것이
다르므로 그 둘을 한 칸으로 접으면 목록 밖의 주체가 허가받은 것으로 읽힌다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4253
def Designation.cut {Entity : Type} (D : Designation Entity) (e : Entity) : Bool :=
  D.listedAnywhere e && !D.relieved e

/--
당국의 재량이 움직이는 자리.

**대응 비형식 개념:** 성문의 기준이 정하는 자리와 당국이 재량으로 놓은 자리가 갈리는 것. 재량이
놓이지 않은 주체에서는 성문의 자리가 그대로 서고, 놓인 주체에서는 그것이 앞의 것을 덮는다.

**이 정의가 배제하는 사례:**
자리를 한 칸으로 두고 당국의 조작을 그 칸의 값으로만 받는 읽기. 규제당국이 은행을 정리할 때 늘
재량을 쥐며 주권의 재정 능력과 의지가 실제 순위를 좌우하는 것이 원 문헌의 각주가 드는 것이고
2013년 사이프러스에서 대형 무부보 예금자가 손실을 입은 것이 그 사례인데, 한 칸으로 두면 어느
쪽이 쓰였는지가 그 값에서 사라진다.
조달처: E-68 §4-2 「당국의 조작이 주체의 자리를 움직이고 구조가 그것을 계산하지 않는다」

**기각한 대체 정의:**
두 칸을 다 필수로 두는 안. 그러면 재량이 놓이지 않은 주체에 값이 둘 서고 어느 것이 그 주체의
자리인지가 구조에서 서지 않는다. 자리를 참거짓으로 박는 안도 기각했다. 이 구멍이 묻는 것이 액면가
약속의 강도이고 그 강도가 참거짓이 아니므로, 박으면 그 자리에 쓸 수 없다.

**수 체계를 받지 않는다.** 두 칸이 자리의 타입을 매개변수로 받고 수를 들지 않는다.
-/
-- DD:CF-4251
structure DiscretionaryStanding (Subject Standing : Type) where
  /-- 성문의 기준이 정하는 자리. -/
  statutory : Subject → Standing
  /-- 당국이 재량으로 놓은 자리. 놓지 않았으면 `none`. -/
  determined : Subject → Option Standing

/-- witness (A-3). **무엇을 증거하는가.** `DiscretionaryStanding` 이 비어 있지 않다. 성문의
자리가 거짓이고 재량이 어디에도 놓이지 않은 배치 하나를 든다. -/
-- DD:CF-4251
def DiscretionaryStanding.trivial : DiscretionaryStanding Unit Bool where
  statutory := fun _ => false
  determined := fun _ => none

/--
재량이 움직이는 자리의 시점 족.

**대응 비형식 개념:** 당국의 재량이 시점에 따라 달라지는 것. 지정과 해제와 수정이 한 항 안에서
사건 갈래로 갈리므로 그 자리가 시점에 매여 있다.

**이 정의가 배제하는 사례:**
재량을 시점 없는 하나로 두는 읽기. 공표 꼴의 하나가 제재 항마다 사건을 하나 이상 두고 사건마다
날짜를 필수로 들므로, 시점을 떼면 그 항에 쌓인 사건의 열이 한 값으로 접힌다.
조달처: E-69 §3-1 「한 주체가 언제 잘렸는가는 단일 값이 아니라 그 항에 쌓인 사건의 열이다」

**기각한 대체 정의:**
성문의 자리만 시점 족으로 두고 재량의 자리를 시점 없이 두는 안. 그러면 재량이 놓인 시점과 풀린
시점이 갈리지 않아 해제가 담기지 않는다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 인덱스를 뺀 나머지가 자리의 타입을 매개변수로 받는다.
-/
-- DD:CF-4251
abbrev DiscretionaryStandingFamily (Subject Standing : Type) :=
  ℕ → DiscretionaryStanding Subject Standing

/-- **무엇을 증거하는가.** 시점에 따라 변하지 않는 족을 만드는 수단이다. 받은 배치를 모든 시점에
두는 상수 족을 낸다. -/
-- DD:CF-4251
def DiscretionaryStandingFamily.constant {Subject Standing : Type}
    (S : DiscretionaryStanding Subject Standing) :
    DiscretionaryStandingFamily Subject Standing := fun _ => S

/--
그 주체의 자리.

**대응 비형식 개념:** 재량이 놓였으면 그것이고 놓이지 않았으면 성문의 자리인 것.

**이 정의가 배제하는 사례:**
성문의 자리를 늘 쓰는 읽기. 기준이 성문으로 서 있어도 그 기준의 적용이 열거로 닫히므로, 성문의
자리를 늘 쓰면 당국의 조작이 그 값에 닿지 않는다.
조달처: E-68 §4-2 「기준이 성문으로 서 있어도 그 기준의 적용이 열거로 닫히므로」

**기각한 대체 정의:**
재량이 놓이지 않은 자리를 판정 불가로 내는 안. 그 자리에 성문의 기준이 실제로 서 있으므로 판정이
불가한 것이 아니며, 판정 불가로 내면 재량이 아직 쓰이지 않은 주체가 자리를 갖지 않는 것으로 읽힌다.

**수 체계를 받지 않는다.** 자리의 타입을 매개변수로 받고 수를 들지 않는다.
-/
-- DD:CF-4251
def DiscretionaryStanding.resolve {Subject Standing : Type}
    (S : DiscretionaryStanding Subject Standing) (s : Subject) : Standing :=
  (S.determined s).getD (S.statutory s)

/--
그 주체에 재량이 놓였는가.

**대응 비형식 개념:** 당국이 그 주체의 자리를 손댔는가. 놓인 값이 성문의 값과 같은지는 묻지 않는다.

**이 정의가 배제하는 사례:**
놓인 값이 성문의 값과 다른지로 판정하는 읽기. 그러면 당국이 성문의 자리를 그대로 확인한 조작이
재량이 놓이지 않은 것으로 나오고, 그 확인이 해제의 밑이 되는 자리에서 그 사실이 사라진다.
조달처: E-69 §3-1 「지정과 해제와 수정이 한 항 안에서 사건 갈래로 갈린다」

**기각한 대체 정의:**
자리의 타입에 상등 판정을 요구하는 안. 그러면 이 선언이 그 인스턴스를 받는 자리가 되고 자리의
타입을 매개변수로 받는 꼴이 좁아진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4251
def DiscretionaryStanding.isDetermined {Subject Standing : Type}
    (S : DiscretionaryStanding Subject Standing) (s : Subject) : Bool :=
  (S.determined s).isSome

/--
지정을 재량이 움직이는 자리로 내려 보낸 것.

**대응 비형식 개념:** 성문의 기준이 내는 판정을 받아, 당국의 열거가 그것을 덮는 배치로 두는 것.
그 열거가 주체마다 금지의 안과 밖을 정하므로 당국이 손대지 않은 자리가 없고, 그래서 이 사상은
재량의 칸을 모든 주체에서 채운다. 그 칸이 비는 배치는 같은 꼴에 액면가 약속의 강도를 넣은 증거가
들며, 이 사상의 포화는 같은 파일의 전칭 정리가 든다.

**이 정의가 배제하는 사례:**
기준의 성립을 구조가 계산하게 하고 열거를 그 귀결로 두는 읽기. 기준이 성립하는 주체 가운데 그
열거에 들지 않은 것은 금지의 밖에 서므로, 열거를 귀결로 두면 금지의 범위가 실제보다 넓어진다.
조달처: E-68 §3-1 「읽는 쪽이 계산할 수 있는 것은 구성원임이고 기준의 성립이 아니므로」

**기각한 대체 정의:**
성문의 기준을 지정 구조의 칸으로 받는 안. 그 기준이 읽는 쪽의 계산으로 판정되지 않으므로 그 구조의
칸으로 두면 구조가 계산할 수 없는 값을 자기 칸으로 들게 된다. 당국이 손대지 않은 주체의 자리를
성문의 기준이 정하게 두는 안도 기각했다. 액면가 약속의 강도를 넣은 자리에서는 그 꼴이 서지만,
지정에서는 그 열거에 들지 않은 주체가 금지의 밖에 서므로 그 꼴로 두면 그 주체가 금지의 안으로
들어온다.

**수 체계를 받지 않는다.** 두 칸이 판정이며 수를 들지 않는다.
-/
-- DD:CF-4249
def Designation.asStanding {Entity : Type} (D : Designation Entity)
    (statutoryCriteria : Entity → Bool) : DiscretionaryStanding Entity Bool where
  statutory := statutoryCriteria
  determined := fun e => some (D.cut e)

/--
증거를 드는 주체의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거를 들기 위한 색인이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
실재하는 지정 주체의 이름을 생성자로 두는 읽기. 그 열거가 당국의 조작으로 바뀌므로 이름을 박으면
그 값이 박는 순간 낡으며, 실증 결과를 추출하지 않는다는 요구에도 걸린다.
조달처: E-68 §2-3 「그 열거에 넣는 것이 당국의 조작이다」

**기각한 대체 정의:**
증거를 `Unit` 위에서만 드는 안. 사유마다 홀로 참인 자리와 허가가 선 자리와 어느 부에도 들지 않은
자리를 함께 들려면 주체가 다섯 필요하므로, `Unit` 로 두면 그 증거가 한 주체에 접힌다.

**수 체계를 받지 않는다.** 다섯 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4259
inductive DesignationWitnessEntity where
  /-- 목적의 현저한 좌절로만 열거된 주체. -/
  | purposeOnly
  /-- 침략 전쟁의 지원으로만 열거된 주체. -/
  | aggressionOnly
  /-- 특정 조의 금지를 현저히 좌절시킨 것으로만 열거된 주체. -/
  | listedOnly
  /-- 열거되었으나 개별 허가로 풀린 주체. -/
  | relievedOne
  /-- 기준이 성립하나 어느 사유의 부에도 열거되지 않은 주체. -/
  | criteriaOnly
  deriving DecidableEq, Repr

/-- **무엇을 증거하는가.** 사유마다 홀로 참인 배치와 허가가 선 배치와 어느 부에도 들지 않은 배치가
한 지정 상태에 함께 선다. 네 주체에 사유를 하나씩 주고 그 가운데 하나에만 허가를 두며, 다섯째
주체는 어느 부에도 넣지 않아 구성원임이 거짓인 자리를 든다. -/
-- DD:CF-4259
def designationWitness : Designation DesignationWitnessEntity where
  listedUnder := fun e g =>
    match e, g with
    | .purposeOnly, .purposeFrustration => true
    | .aggressionOnly, .aggressionSupport => true
    | .listedOnly, .listedProhibitionFrustration => true
    | .relievedOne, .purposeFrustration => true
    | _, _ => false
  relieved := fun e =>
    match e with
    | .relievedOne => true
    | _ => false

/-- **무엇을 증거하는가.** 액면가 약속의 강도가 재량이 움직이는 자리에 실제로 선다. 성문이 공적
화폐의 강도를 주는데 당국이 한 주체에 사적 그림자 화폐의 강도를 놓은 배치를 든다. -/
-- DD:CF-4252
def strengthStanding : DiscretionaryStanding DesignationWitnessEntity (Option ParStrength) where
  statutory := fun _ => some .publicMoney
  determined := fun e =>
    match e with
    | .relievedOne => some (some .privateShadowMoney)
    | _ => none

/--
사유마다 그 하나만으로 구성원임이 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 사유의 부에만 열거된 주체가 구성원임을 얻지 못하거나, 어느 부에도 들지 않은 주체가 구성원임을
얻어야 한다. 그 관측은 구성원임이 세 사유의 논리합이 아니라는 뜻이며, 앞은 한 부에만 선 주체가 목록
밖으로 나오는 것이고 뒤는 어느 부에도 없는 주체가 목록 안으로 들어오는 것이다.

**존재 형태로 진술하는 까닭(T-6):**
사유마다 그 하나만 참인 주체와 셋 다 거짓인 주체를 들어야 보인다. 임의의 배치에서 각 사유가 홀로
가르는 것이 아니라 나머지가 거짓인 자리에서만 그 가름이 보이고, 그 논리합이 거짓이 되는 자리도 셋이
함께 거짓인 주체에서만 서기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 구성원임을 사유의 논리합으로 둔 결합마다 그 인자가 홀로 값을 가르는 증거를
드는 유일한 자리이고, 그 증거가 없으면 그 결합을 뒤집은 변이가 통과한다.
-/
-- DD:CF-4259
theorem listedAnywhere_pins_each_ground :
    designationWitness.listedUnder .purposeOnly .purposeFrustration = true ∧
      designationWitness.listedUnder .purposeOnly .aggressionSupport = false ∧
      designationWitness.listedUnder .purposeOnly .listedProhibitionFrustration = false ∧
      designationWitness.listedAnywhere .purposeOnly = true ∧
      designationWitness.listedUnder .aggressionOnly .purposeFrustration = false ∧
      designationWitness.listedUnder .aggressionOnly .aggressionSupport = true ∧
      designationWitness.listedAnywhere .aggressionOnly = true ∧
      designationWitness.listedUnder .listedOnly .aggressionSupport = false ∧
      designationWitness.listedUnder .listedOnly .listedProhibitionFrustration = true ∧
      designationWitness.listedAnywhere .listedOnly = true ∧
      designationWitness.listedUnder .criteriaOnly .purposeFrustration = false ∧
      designationWitness.listedUnder .criteriaOnly .aggressionSupport = false ∧
      designationWitness.listedUnder .criteriaOnly .listedProhibitionFrustration = false ∧
      designationWitness.listedAnywhere .criteriaOnly = false := by
  -- 증거의 지정 상태가 상수이고 구성원임이 열거 위의 계산이므로 각 등식이 계산으로
  -- 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
절단의 두 인자가 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
열거되지 않은 주체가 잘린 것으로 나오거나 허가받은 주체가 잘린 것으로 나와야 한다. 그 관측은 절단이
구성원임과 허가의 부정의 곱이 아니라는 뜻이다.

**존재 형태로 진술하는 까닭(T-6):**
한 인자만 뒤집힌 배치를 인자마다 들어야 보인다. 두 인자가 함께 참인 자리와 함께 거짓인 자리만 들면
곱과 합의 값이 그 둘에서 같아 그 결합을 뒤집은 변이가 통과하므로, 허가만 선 주체와 구성원임만 거짓인
주체를 함께 들어 인자마다 그 홀로 가름을 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 절단의 결합을 가리는 증거를 드는 유일한 자리다.
-/
-- DD:CF-4259
theorem cut_pins_each_conjunct :
    designationWitness.cut .purposeOnly = true ∧
      designationWitness.listedAnywhere .purposeOnly = true ∧
      designationWitness.relieved .purposeOnly = false ∧
      designationWitness.cut .relievedOne = false ∧
      designationWitness.listedAnywhere .relievedOne = true ∧
      designationWitness.relieved .relievedOne = true ∧
      designationWitness.cut .criteriaOnly = false ∧
      designationWitness.listedAnywhere .criteriaOnly = false ∧
      designationWitness.relieved .criteriaOnly = false := by
  -- 절단이 구성원임과 허가의 부정의 곱이고 세 주체에서 그 두 인자가 상수이므로 각
  -- 등식이 계산으로 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
기준이 성립하는 주체가 열거에 들지 않아 금지의 밖에 서는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
성문의 기준이 내는 판정과 열거가 내는 판정이 늘 같아야 한다. 그 관측은 당국의 조작이 기준의 귀결로
닫힌다는 뜻이며, 그러면 그 열거에 넣는 일이 읽는 쪽의 계산이 되고 이 구멍이 묻는 축이 사라진다.

**존재 형태로 진술하는 까닭(T-6):**
기준이 참이고 구성원임이 거짓인 주체를 들어야 보이며, 그 갈림이 기준의 성립 자체에서 오지 않는다는
것은 기준이 참이고 구성원임도 참인 주체를 나란히 들어야 보인다. 시스템 수준의 성문 기준이 개별
주체의 열거를 결정하지 않으므로 전칭으로는 서지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 이 파일이 세우는 두 구조가 한 주체에서 갈린다는 것을 드는 유일한 자리이고,
그 갈림이 없으면 재량의 자리를 둘로 둔 것이 이름만 다른 둘이 된다.
-/
-- DD:CF-4249
theorem exists_criteria_met_but_not_listed :
    ∃ (statutoryCriteria : DesignationWitnessEntity → Bool),
      statutoryCriteria .aggressionOnly = true ∧
        designationWitness.listedAnywhere .aggressionOnly = true ∧
        (designationWitness.asStanding statutoryCriteria).statutory .aggressionOnly = true ∧
        (designationWitness.asStanding statutoryCriteria).resolve .aggressionOnly = true ∧
        statutoryCriteria .criteriaOnly = true ∧
        designationWitness.listedAnywhere .criteriaOnly = false ∧
        (designationWitness.asStanding statutoryCriteria).statutory .criteriaOnly = true ∧
        (designationWitness.asStanding statutoryCriteria).resolve .criteriaOnly = false := by
  -- 성문의 기준을 모든 주체에서 참으로 두면 두 주체에서 기준이 서고, 자리는 그 기준이
  -- 아니라 열거가 낸 절단의 값으로 덮이므로 각 등식이 계산으로 닫힌다.
  exact ⟨fun _ => true, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
지정을 내려 보낸 자리는 모든 주체에서 재량이 놓인 것으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 주체에서 재량의 칸이 비어야 한다. 그 관측은 그 열거가 금지의 안과 밖을 주체마다 정하지 않고
당국이 손대지 않은 자리를 남긴다는 뜻이며, 그러면 그 주체의 자리를 성문의 기준이 정하게 된다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 지정이 재량의 칸을 모든 주체에서 채운다는 것을 드는 유일한 자리이고, 그
포화가 적히지 않으면 칸을 둘로 둔 꼴이 지정에서도 두 자리를 쓰는 것처럼 읽힌다.
-/
-- DD:CF-4249
theorem asStanding_isDetermined_everywhere
    (statutoryCriteria : DesignationWitnessEntity → Bool) :
    ∀ e, (designationWitness.asStanding statutoryCriteria).isDetermined e = true := by
  -- 지정을 내려 보낸 자리의 재량 칸이 주체마다 절단의 값을 든 `some` 이므로, 주체를
  -- 하나 들면 그 판정이 계산으로 참이 나와 `rfl` 로 닫힌다.
  intro e
  rfl

/--
재량이 놓이지 않은 주체의 자리가 성문의 자리다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
재량이 놓이지 않은 주체의 자리가 성문의 자리와 달라야 한다. 그 관측은 자리를 내는 계산이 성문의
칸을 읽지 않는다는 뜻이다.

**가정과 그 배제 사례(T-4·T-5):**
재량의 칸이 그 주체에서 비어 있음을 가정한다. 그 가정 없이는 명제가 거짓이며, 당국이 한 주체에만
다른 강도를 놓은 배치가 그 배제 사례다.

**T-3 분류:** 보조 보정이다. 자리를 내는 계산의 정의를 전개하면 증명이 닫히고, 그 사실을 구조 안의
명제로 드는 몫이 따로 없으므로 기여 목록에 들지 않는다.
-/
-- DD:CF-4251
theorem resolve_eq_statutory_of_determined_none {Subject Standing : Type}
    (S : DiscretionaryStanding Subject Standing) (s : Subject)
    (h : S.determined s = none) :
    S.resolve s = S.statutory s := by
  -- 자리를 내는 계산을 전개하고 재량의 칸이 비었다는 가정으로 바꾸면 기본값인 성문의
  -- 자리가 나온다.
  unfold DiscretionaryStanding.resolve
  rw [h]
  rfl

/--
액면가 약속의 강도가 재량으로 움직이는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
재량이 움직이는 자리에 강도를 넣은 배치에서 그 자리의 값이 성문의 값과 늘 같아야 한다. 그 관측은
강도가 재량의 함수가 되지 않는다는 뜻이며, 그러면 이 파일이 그 구멍이 묻는 자리에 닿지 못한다.

**존재 형태로 진술하는 까닭(T-6):**
당국이 강도를 놓은 주체를 들어야 보인다. 재량이 모든 주체의 강도를 움직이는 것이 아니라 당국이
손댄 주체에서만 움직이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 재량이 움직이는 자리의 일반 꼴이 액면가 약속의 강도에 실제로 선다는 것을
드는 유일한 자리이고, 그 구멍이 요구한 재량을 재는 대상이 그 자리에서 선다.
-/
-- DD:CF-4252
theorem exists_par_strength_moved_by_discretion :
    strengthStanding.resolve .purposeOnly = some ParStrength.publicMoney ∧
      strengthStanding.isDetermined .purposeOnly = false ∧
      strengthStanding.resolve .relievedOne = some ParStrength.privateShadowMoney ∧
      strengthStanding.isDetermined .relievedOne = true ∧
      strengthStanding.statutory .relievedOne = some ParStrength.publicMoney := by
  -- 배치가 상수이고 자리와 재량의 판정이 그 위의 계산이므로 각 등식이 계산으로 값이
  -- 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

/--
재량을 지난 액면가 약속의 강도로 세운 화폐자산.

**대응 비형식 개념:** 성문이 정하는 강도를 당국의 결정이 덮은 뒤에 그 주체에게 화폐인 것의 강도.
용어집의 당국의 재량이 성문의 기준이 정하는 자리를 당국의 조작이 덮는 것이고, 예금보험의 조문이 부보
몫을 넘는 예금을 보호하지 못하게 하는 기본값을 체계적 위험 예외의 결정이 덮으므로, 한 주체의 강도가
성문의 자리와 결정으로 놓인 자리에서 온다.

**이 정의가 배제하는 사례:**
한 보유자가 한 펀드에 든 지분이 기준일에서 둘로 갈리는 자리. 머니마켓펀드에 대한 임시 보증은 기준일의
영업 종료 시점에 보유한 지분 수까지만 덮으므로 한 보유자의 한 펀드 지분이 보증된 몫과 보증되지 않은
몫으로 갈리는데, 이 결합은 보유자마다 강도 하나를 받으므로 그 둘을 함께 담지 못한다.
조달처: E-98 §5-3 「한 청구권의 한 보유가 두 강도를 갖는 자리이며」

**기각한 대체 정의:**
화폐자산의 칸을 재량 지위로 바꾸는 안. 그러면 그 칸을 받는 선언 전량의 서명이 바뀌는데, 칸이 주체에서
강도로 가는 함수이고 재량 지위의 자리를 내는 함수가 같은 타입이므로 그 함수를 칸에 넣는 결합으로
서명을 건드리지 않고 같은 것을 담는다. 발행 기관을 색인으로 더해 결정이 걸리는 갈래를 담는 안도
기각했다. 보유 사상이 발행자를 받지 않기로 한 결정과 갈리고, 원문의 표가 그 값을 주지 않는다.

**결정이 걸리는 주체가 보유자보다 가늘다.** 체계적 위험 예외의 결정은 관재인이 지정된 기관 하나의
예금의 갈래에 걸리고 같은 기관의 주식과 일부 무담보 채무를 덮지 않으므로, 한 보유자의 강도는 그가
어느 기관의 어느 갈래를 들었는가에서 나온다. 여러 기관의 청구권을 함께 든 보유자에게서 그 가운데
하나를 고르는 선택은 이 결합의 밖에 서며, 화폐자산의 비교가 은행이 지급준비금과 국채를 함께 드는
자리로 든 한계와 같은 축이다.
조달처: E-98 §5-2 「한 보유자의 자리는 그가 어느 기관의 어느 갈래를 들었는가에서 따라 나온다」

**수 체계를 받지 않는다.** 자리의 타입이 강도의 선택이며 수를 들지 않는다.
-/
-- DD:CF-4927
def MoneyAsset.ofStanding {Entity : Type}
    (S : DiscretionaryStanding Entity (Option ParStrength)) : MoneyAsset Entity :=
  ⟨S.resolve⟩

/--
결정이 놓이지 않은 두 주체에서 재량을 지난 화폐자산의 순서는 성문의 강도로 세운 순서와 같다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
당국이 두 주체 어느 쪽에도 결정을 놓지 않았는데 그 둘의 위계 순서가 성문의 강도가 주는 순서와 달라야
한다. 그 관측은 결정이 놓이지 않은 자리에서도 재량이 순서를 움직인다는 뜻이며, 그러면 재량을 성문의
자리를 덮는 결정으로 받는 꼴이 그 순서를 담지 못한다.

**가정과 그 배제 사례(T-4·T-5):**
두 주체의 재량의 칸이 비어 있음을 가정한다. 그 가정 없이는 명제가 거짓이며, 체계적 위험 예외를 본떠
예금의 보유자에게만 부보 화폐의 자리를 놓은 배치가 그 배제 사례다.

**T-3 분류:** 기여다. 재량이 놓이지 않은 자리에서 순서를 움직이지 않는다는 것을 모든 배치에서 드는
유일한 자리이며, 결합의 정의를 펼친 뒤에도 자리를 내는 계산이 성문의 자리를 낸다는 진술을 거쳐야
닫힌다.
-/
-- DD:CF-4927
theorem aboveOrEqual_ofStanding_eq_statutory {Entity : Type}
    (S : DiscretionaryStanding Entity (Option ParStrength)) (m n : Entity)
    (hm : S.determined m = none) (hn : S.determined n = none) :
    (MoneyAsset.ofStanding S).aboveOrEqual m n =
      (⟨S.statutory⟩ : MoneyAsset Entity).aboveOrEqual m n := by
  -- 두 주체의 재량의 칸이 비어 있으므로 결합이 내는 강도가 성문의 강도와 같다. 순서의 판정을
  -- 펼친 자리의 강도를 그 두 등식으로 바꾸면 양변이 같은 꼴이 된다.
  have hm' : (MoneyAsset.ofStanding S).heldStrength m = S.statutory m :=
    resolve_eq_statutory_of_determined_none S m hm
  have hn' : (MoneyAsset.ofStanding S).heldStrength n = S.statutory n :=
    resolve_eq_statutory_of_determined_none S n hn
  unfold MoneyAsset.aboveOrEqual
  rw [hm', hn']

/--
재량이 순서를 뒤집는 증거를 드는 보유자의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거를 들기 위한 색인이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
실재하는 은행과 펀드의 이름을 생성자로 두는 읽기. 체계적 위험 예외의 결정은 기관이 실패해 관재인이
지정된 뒤에 그 기관 하나에 걸리므로, 이름을 박으면 그 증거가 한 사건의 기록이 되고 실증 결과를
추출하지 않는다는 요구에도 걸린다.
조달처: E-98 §2-3 「지금의 예외는 기관이 실패해 관재인이 지정된 뒤에만 쓰이고」

**기각한 대체 정의:**
지정의 증거에 쓰는 주체의 열거를 다시 쓰는 안. 그 열거의 강도 증거 배치는 성문이 모든 주체에 순수
공적 화폐를 주고 한 주체에만 순수 사적 화폐의 자리를 놓으므로, 결정이 동급을 가르는 것은 보이나
엄격한 순서가 뒤집히는 것은 보이지 못한다. 그 주체들이 제재 지정의 사유로 이름 붙어 있어 예금보험의
결정을 싣기에도 맞지 않는다.

**수 체계를 받지 않는다.** 두 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4927
inductive DiscretionWitnessHolder where
  /-- 부보 한도를 넘는 예금의 보유자. 성문에서 그 예금은 보호되지 않는다. -/
  | uninsuredDepositor
  /-- 공적 자산만 드는 정부전용 펀드의 지분 보유자. -/
  | governmentFundHolder
  deriving DecidableEq, Repr

/-- **무엇을 증거하는가.** 결정이 위계의 순서를 뒤집는 배치가 재량 지위에 선다. 성문에서 무부보 예금이
순수 사적 화폐이고 정부전용 펀드의 지분이 공적 그림자 화폐인데, 체계적 위험 예외를 본떠 예금의
보유자에게만 부보 화폐의 자리를 놓은 배치를 든다. -/
-- DD:CF-4927
def systemicRiskExceptionStanding :
    DiscretionaryStanding DiscretionWitnessHolder (Option ParStrength) where
  statutory := fun h =>
    match h with
    | .uninsuredDepositor => some .privateShadowMoney
    | .governmentFundHolder => some .publicShadowMoney
  determined := fun h =>
    match h with
    | .uninsuredDepositor => some (some .insuredMoney)
    | .governmentFundHolder => none

/--
결정이 위계의 순서를 두 방향 모두 뒤집는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
성문에서 아래에 선 보유자에게 당국이 더 강한 자리를 놓아도 그 보유자가 위에 서지 않아야 한다. 체계적
위험 예외의 결정이 두 은행의 예금자 전량을 덮어 그 예금의 자리를 사후에 명시적 신용 풋이 받쳤으므로,
그 관측은 그 결정이 순서에 닿지 않는다는 뜻이다.

**존재 형태로 진술하는 까닭(T-6):**
뒤집힘은 성문의 순서와 결정 뒤의 순서가 갈리는 배치를 들어야 보인다. 결정이 놓이지 않거나 성문의
강도와 같은 값을 놓은 배치에서는 두 순서가 같으므로 전칭으로는 서지 않는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 결정이 성문의 엄격한 순서를 뒤집을 수 있다는 것을 드는 유일한 자리이며, 지정의
강도 증거 배치는 결정이 동급을 가르는 것만 든다.
-/
-- DD:CF-4927
theorem exists_determination_reverses_order :
    (⟨systemicRiskExceptionStanding.statutory⟩ : MoneyAsset DiscretionWitnessHolder).aboveOrEqual
        .uninsuredDepositor .governmentFundHolder = false ∧
      (⟨systemicRiskExceptionStanding.statutory⟩ : MoneyAsset DiscretionWitnessHolder).aboveOrEqual
        .governmentFundHolder .uninsuredDepositor = true ∧
      (MoneyAsset.ofStanding systemicRiskExceptionStanding).aboveOrEqual
        .uninsuredDepositor .governmentFundHolder = true ∧
      (MoneyAsset.ofStanding systemicRiskExceptionStanding).aboveOrEqual
        .governmentFundHolder .uninsuredDepositor = false := by
  -- 배치가 상수이고 순서의 판정이 강도의 패턴 매칭이므로 각 등식이 계산으로 값이 나와 `rfl` 로
  -- 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl⟩

end CrisisFramework.Definition
