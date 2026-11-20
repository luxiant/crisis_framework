/-
정의층 — 주체의 식별이 두 축에서 단일하지 않은 것

규율: L-10(무차원 + 시점 인덱스 `ℕ`), L-13(시점 족), D-2(docstring 3항목),
      D-3(실제 역사 사례), A-3(witness), A-8(논리 결합의 증거), C-3(판정은 `Bool`),
      T-2(반증 조건), T-3(분류), T-6(존재 형태).

**표를 둘로 두고 접지 않는다.** 공표되는 목록이 대체 식별의 표와 주소의 표를 따로 세우고 둘 다 고유
식별자에 걸리므로, 한 구조로 접으면 이름이 없고 주소만 있는 항과 그 반대의 항이 한 타입에 들어와 어느
표에서 온 항인지가 그 값에서 사라진다.

**식별을 함수로 두지 않고 색인된 집합으로 둔다.** 두 표가 다 한 주체에 항을 여럿 내므로 주체에서 이름으로
가는 함수의 값이 하나일 수 없고, 그 비유일성을 받는 것이 이 파일의 몫이다.

**이름의 유형을 매개변수로 받는다.** 그 기록이 유형이 셋으로 갈린다는 것만 들고 세 유형의 이름을 들지
않으므로, 열거로 두면 그 생성자의 이름을 지어내게 된다.

**이름에서 식별자로 가는 집기를 이 파일이 두지 않는다.** 금지의 번짐을 판정하는 자리가 고유 식별자를
받고 이름을 받지 않으므로 그 집기는 구조 밖에 서며, 그 경로의 측정 명세는 관측층이 든다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Finset.Basic

namespace CrisisFramework.Definition

/--
대체 식별의 한 항.

**대응 비형식 개념:** 공표되는 목록이 한 주체의 고유 식별자에 걸어 두는 다른 이름과 그 이름의 유형.

**이 정의가 배제하는 사례:**
이름을 주체의 칸으로 두는 읽기. 그 표가 고유 식별자에 걸리는 다른 이름과 그 이름의 유형을 드는데 그
유형이 셋으로 갈리므로, 주체의 칸으로 두면 한 주체에 선 여러 이름이 한 값으로 접힌다.
조달처: E-69 §2-3 「대체 식별의 표가 고유 식별자에 걸리는 다른 이름과 그 이름의 유형을 드는데, 그 유형이 셋으로 갈린다」

**기각한 대체 정의:**
유형을 열거로 두는 안. 그 기록이 유형이 셋으로 갈린다는 것만 들고 세 유형의 이름을 들지 않으므로,
열거로 두면 생성자의 이름을 지어내게 되고 배제 사례를 실제 문면에서만 들라는 요구가 그것을 막는다.
이름과 유형을 한 칸으로 접는 안도 기각했다. 그 표가 두 칸을 따로 들고 유형이 그 이름의 처분을 가르므로
접으면 그 가름이 사라진다.

**수 체계를 받지 않는다.** 세 칸이 주체와 이름과 유형이며 수를 들지 않는다.
-/
-- DD:CF-4297
structure AltNameRow (Entity NameKind Name : Type) where
  /-- 그 이름이 걸리는 주체의 고유 식별자. -/
  subject : Entity
  /-- 그 주체의 다른 이름. -/
  name : Name
  /-- 그 이름의 유형. 기록이 셋으로 갈린다고 들 뿐 이름을 들지 않으므로 매개변수로 받는다. -/
  kind : NameKind

/-- witness (A-3). **무엇을 증거하는가.** `AltNameRow` 가 비어 있지 않다. 모든 자리가 `Unit` 인 항
하나를 든다. -/
-- DD:CF-31
def AltNameRow.trivial : AltNameRow Unit Unit Unit where
  subject := ()
  name := ()
  kind := ()

/--
한 시점의 대체 식별의 표.

**대응 비형식 개념:** 그 시점에 공표된 다른 이름 전부. 색인과 배정으로 준다.

**이 정의가 배제하는 사례:**
같은 주체에 같은 이름이 두 유형으로 걸린 항을 색인이 구별하므로, 그 둘을 합쳐야 하는지를 이 구조가
말하지 않는다. 그 표가 유형을 셋으로 가르면서 같은 이름이 둘 이상의 유형을 받는 것을 자기 문면으로
막지 않으므로 그 합침 규칙이 담기지 않는다.
조달처: E-69 §2-3 「이름으로 주체를 찾는 경로가 한 주체에 여럿을 낸다」

**기각한 대체 정의:**
항의 유한 집합으로 두는 안. 같은 디렉터리의 청구권 집합과 제공 집합과 몫 집합이 색인 방식을 쓰므로
리포 안에서 관례가 갈린다. 주체에서 이름의 목록으로 가는 함수로 두는 안도 기각했다. 그러면 비유일성이
목록의 길이로만 서서 색인 둘이 다름을 묻는 판정을 쓸 수 없고, 항이 없는 주체와 빈 목록을 가진 주체가
같아진다.

**수 체계를 받지 않는다.** 색인과 배정이 수를 들지 않는다.
-/
-- DD:CF-4297
structure AltNameTable (NIdx Entity NameKind Name : Type) where
  /-- 항의 색인. -/
  index : Finset NIdx
  /-- 색인에서 항으로의 배정. -/
  assign : NIdx → AltNameRow Entity NameKind Name

/-- witness (A-3). **무엇을 증거하는가.** `AltNameTable` 이 비어 있지 않다. 색인이 빈 표 하나를
든다. -/
-- DD:CF-31
def AltNameTable.trivial : AltNameTable Unit Unit Unit Unit where
  index := ∅
  assign := fun _ => AltNameRow.trivial

/--
대체 식별의 표의 시점 족.

**대응 비형식 개념:** 공표된 다른 이름이 시점에 따라 달라지는 것. 지정과 해제와 수정이 그 달라짐을
낸다.

**이 정의가 배제하는 사례:**
표를 시점 없는 하나로 두는 읽기. 공표 꼴의 하나가 제재 항마다 사건을 하나 이상 두고 사건마다 날짜를
필수로 들므로, 시점을 떼면 그 항에 쌓인 사건의 열이 한 값으로 접힌다.
조달처: E-69 §3-1 「한 주체가 언제 잘렸는가는 단일 값이 아니라 그 항에 쌓인 사건의 열이다」

**기각한 대체 정의:**
시점을 항의 칸으로 받는 안. 그러면 한 표가 여러 시점의 항을 함께 들어 그 색인이 어느 시점의 것인지가
서지 않으며, 정의층 대상을 시점 인덱스를 갖는 족으로 정의하라는 요구와도 갈린다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**

**수 체계를 받지 않는다.** 인덱스를 뺀 나머지가 표이고 그것이 수를 들지 않는다.
-/
-- DD:CF-4297
abbrev AltNameFamily (NIdx Entity NameKind Name : Type) :=
  ℕ → AltNameTable NIdx Entity NameKind Name

/-- **무엇을 증거하는가.** 시점에 따라 변하지 않는 족을 만드는 수단이다. 받은 표를 모든 시점에 두는
상수 족을 낸다. -/
-- DD:CF-31
def AltNameFamily.constant {NIdx Entity NameKind Name : Type}
    (T : AltNameTable NIdx Entity NameKind Name) : AltNameFamily NIdx Entity NameKind Name :=
  fun _ => T

/--
그 주체에 다른 이름이 둘 이상 서 있는가.

**대응 비형식 개념:** 이름으로 그 주체를 찾는 경로가 하나로 서지 않는가.

**이 정의가 배제하는 사례:**
참이 곧 오식별이 아니다. 한 주체에 약칭과 이전 이름이 함께 걸린 적법한 배치도 이 술어가 참을 내므로,
이 술어가 가리키는 것은 이름으로 가는 경로가 단일하지 않다는 사실이고 그 이름들이 다른 주체를 가리킨다는
것이 아니다. 거꾸로 거짓을 낼 때 그것이 이름이 하나인 것인지 그 주체가 표에 없는 것인지는 이 술어가
가르지 않는다.
조달처: E-69 §2-4 「주체의 식별이 이름에서도 주소에서도 단일하지 않다」

**기각한 대체 정의:**
주체를 가리키는 항의 수를 세어 둘 이상인지 보는 안. 개수가 `ℕ` 이고 이 층은 시점 인덱스 밖의
자연수를 쓰지 못하므로 그 셈은 회계층의 몫이며, 같은 축의 판정이 같은 디렉터리의 다른 선언에 이미 그
꼴로 서 있다. 이름의 유형이 다름을 함께 묻는 안도 기각했다. 같은 유형의 이름이 둘 걸린 배치도 경로를
여럿 내므로 유형을 묻으면 그 배치가 단일한 것으로 읽힌다.

**색인의 같음을 묻는다.** 항 색인 둘이 다름을 요구하므로 그 타입에 판정 가능한 같음이 붙고, 주체의
같음을 묻으므로 주체 타입에도 붙는다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4297
def AltNameTable.hasMultipleNames {NIdx Entity NameKind Name : Type}
    [DecidableEq NIdx] [DecidableEq Entity]
    (T : AltNameTable NIdx Entity NameKind Name) (e : Entity) : Bool :=
  decide (∃ i ∈ T.index, ∃ j ∈ T.index, i ≠ j
    ∧ (T.assign i).subject = e ∧ (T.assign j).subject = e)

/--
주소의 한 항.

**대응 비형식 개념:** 공표되는 목록이 한 주체의 고유 식별자에 걸어 두는 주소.

**이 정의가 배제하는 사례:**
주소를 주체의 칸으로 두는 읽기. 그 표가 고유 식별자에 걸리는 주소를 드는데 한 주체에 주소가 여럿 설 수
있으므로, 주체의 칸으로 두면 그 여럿이 한 값으로 접힌다.
조달처: E-69 §2-4 「주소의 표가 고유 식별자에 걸리는 주소를 드는데, 한 주체에 주소가 여럿 설 수 있다」

**기각한 대체 정의:**
주소를 대체 식별의 항에 칸으로 더하는 안. 두 표가 따로 서고 이름이 없이 주소만 걸린 항이 있을 수
있으므로, 한 항에 두면 그 배치가 표현되지 않거나 이름의 칸이 비는 꼴을 더 두어야 한다. 주소를 나라와
도시와 거리로 가르는 안도 기각했다. 그 표의 칸 구성이 공표 꼴마다 갈리고 이 층이 그 칸을 세는 자리가
아니다.

**수 체계를 받지 않는다.** 두 칸이 주체와 주소이며 수를 들지 않는다.
-/
-- DD:CF-4298
structure AddressRow (Entity Addr : Type) where
  /-- 그 주소가 걸리는 주체의 고유 식별자. -/
  subject : Entity
  /-- 그 주체의 주소. -/
  address : Addr

/-- witness (A-3). **무엇을 증거하는가.** `AddressRow` 가 비어 있지 않다. 두 자리가 `Unit` 인 항
하나를 든다. -/
-- DD:CF-31
def AddressRow.trivial : AddressRow Unit Unit where
  subject := ()
  address := ()

/--
한 시점의 주소의 표.

**대응 비형식 개념:** 그 시점에 공표된 주소 전부. 색인과 배정으로 준다.

**이 정의가 배제하는 사례:**
같은 주체에 같은 주소가 두 항으로 걸린 것을 색인이 구별하므로, 그 둘을 합쳐야 하는지를 이 구조가
말하지 않는다. 그 표가 중복을 자기 문면으로 막지 않으므로 그 합침 규칙이 담기지 않는다.
조달처: E-69 §2-4 「주체의 식별이 이름에서도 주소에서도 단일하지 않다」

**기각한 대체 정의:**
항의 유한 집합으로 두는 안. 대체 식별의 표가 색인 방식을 쓰므로 한 파일 안에서 관례가 갈린다. 두 표를
한 색인으로 묶는 안도 기각했다. 두 표의 항 수가 다르고 한 주체에 이름만 있거나 주소만 있는 배치가 있을
수 있으므로, 한 색인으로 묶으면 그 배치에 빈 칸을 두어야 한다.

**수 체계를 받지 않는다.** 색인과 배정이 수를 들지 않는다.
-/
-- DD:CF-4298
structure AddressTable (AIdx Entity Addr : Type) where
  /-- 항의 색인. -/
  index : Finset AIdx
  /-- 색인에서 항으로의 배정. -/
  assign : AIdx → AddressRow Entity Addr

/-- witness (A-3). **무엇을 증거하는가.** `AddressTable` 이 비어 있지 않다. 색인이 빈 표 하나를
든다. -/
-- DD:CF-31
def AddressTable.trivial : AddressTable Unit Unit Unit where
  index := ∅
  assign := fun _ => AddressRow.trivial

/--
그 주체에 주소가 둘 이상 서 있는가.

**대응 비형식 개념:** 주소로 그 주체를 찾는 경로가 하나로 서지 않는가.

**이 정의가 배제하는 사례:**
참이 곧 다른 주체가 아니다. 한 주체가 본점과 지점의 주소를 함께 공표된 적법한 배치도 이 술어가 참을
내므로, 이 술어가 가리키는 것은 주소로 가는 경로가 단일하지 않다는 사실이다. 거꾸로 거짓을 낼 때 그것이
주소가 하나인 것인지 그 주체가 표에 없는 것인지는 이 술어가 가르지 않는다.
조달처: E-69 §4-4 「이름으로도 주소로도 한 주체에 여럿이 서므로, 발행자 식별을 드는 정의층 선언이 그 비유일성을 받아야 한다」

**기각한 대체 정의:**
주체를 가리키는 항의 수를 세어 둘 이상인지 보는 안. 개수가 `ℕ` 이고 이 층은 시점 인덱스 밖의
자연수를 쓰지 못하므로 그 셈은 회계층의 몫이다. 두 주소가 다름을 함께 묻는 안도 기각했다. 같은 주소가
두 항으로 걸린 배치도 경로를 여럿 내므로 주소의 다름을 묻으면 그 배치가 단일한 것으로 읽힌다.

**색인의 같음을 묻는다.** 항 색인 둘이 다름을 요구하므로 그 타입에 판정 가능한 같음이 붙고, 주체의
같음을 묻으므로 주체 타입에도 붙는다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4298
def AddressTable.hasMultipleAddresses {AIdx Entity Addr : Type}
    [DecidableEq AIdx] [DecidableEq Entity]
    (T : AddressTable AIdx Entity Addr) (e : Entity) : Bool :=
  decide (∃ i ∈ T.index, ∃ j ∈ T.index, i ≠ j
    ∧ (T.assign i).subject = e ∧ (T.assign j).subject = e)

/--
증거를 드는 주체의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거를 들기 위한 색인이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
실재하는 주체의 이름을 생성자로 두는 읽기. 그 목록이 당국의 조작으로 바뀌므로 이름을 박으면 그 값이
박는 순간 낡으며, 실증 결과를 추출하지 않는다는 요구에도 걸린다.
조달처: E-69 §2-3 「이름으로 주체를 찾는 경로가 한 주체에 여럿을 낸다」

**기각한 대체 정의:**
증거를 `Unit` 위에서만 드는 안. 항이 둘 선 주체와 하나만 선 주체와 서지 않은 주체를 함께 들어야 색인의
다름과 주체의 같음이 각각 홀로 가르는 자리가 서므로, `Unit` 로 두면 그 증거가 한 주체에 접힌다.

**수 체계를 받지 않는다.** 세 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4298
inductive AltIdentityWitnessEntity where
  /-- 이름과 주소가 둘씩 걸린 주체. -/
  | twoRows
  /-- 이름과 주소가 하나씩 걸린 주체. -/
  | oneRow
  /-- 어느 표에도 서지 않은 주체. -/
  | noRow
  deriving DecidableEq, Repr

/--
증거를 드는 항의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거의 두 표에 색인을 주는 자리이며 비형식 개념에 대응하지
않는다.

**이 정의가 배제하는 사례:**
항을 주체와 이름의 쌍으로 색인하는 읽기. 같은 주체에 같은 이름이 두 유형으로 걸린 항을 그 표가 막지
않으므로 쌍으로 색인하면 그 배치를 증거가 들 수 없다.
조달처: E-69 §2-3 「대체 식별의 표가 고유 식별자에 걸리는 다른 이름과 그 이름의 유형을 드는데, 그 유형이 셋으로 갈린다」

**기각한 대체 정의:**
항을 둘만 두는 안. 항이 둘 선 주체와 하나만 선 주체를 함께 들려면 항이 셋 필요하고, 둘로 두면 색인의
다름이 홀로 가르는 자리와 주체의 같음이 홀로 가르는 자리 가운데 하나가 선다.

**수 체계를 받지 않는다.** 세 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4298
inductive AltIdentityWitnessIdx where
  /-- 항이 둘 선 주체의 첫째 항. -/
  | firstOfTwo
  /-- 항이 둘 선 주체의 둘째 항. -/
  | secondOfTwo
  /-- 항이 하나만 선 주체의 항. -/
  | onlyOne
  deriving DecidableEq, Repr

/--
증거를 드는 이름 유형의 열거.

**대응 비형식 개념:** 없다. 이 선언은 증거에 유형의 자리를 주는 색인이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
세 유형에 실재하는 이름을 붙이는 읽기. 그 기록이 유형이 셋으로 갈린다는 것만 들고 세 유형의 이름을
들지 않으므로, 이름을 붙이면 지어낸 것이 선다. 그래서 이 열거는 자리로만 셋을 들고 그 이름을 들지
않는다.
조달처: E-69 §2-3 「그 이름의 유형을 드는데, 그 유형이 셋으로 갈린다」

**기각한 대체 정의:**
증거의 유형을 `Unit` 로 두는 안. 그러면 그 기록이 드는 유일한 수치인 유형의 수가 증거에서 사라진다.

**수 체계를 받지 않는다.** 세 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4298
inductive AltIdentityWitnessKind where
  /-- 첫째 자리의 유형. -/
  | firstKind
  /-- 둘째 자리의 유형. -/
  | secondKind
  /-- 셋째 자리의 유형. -/
  | thirdKind
  deriving DecidableEq, Repr

/-- **무엇을 증거하는가.** 증거의 대체 식별 표다. 한 주체에 이름 둘을 다른 유형으로 걸고 다른 주체에
이름 하나를 걸며, 세 주체 가운데 하나는 어느 항도 받지 않는다. -/
-- DD:CF-4298
def altNameWitness :
    AltNameTable AltIdentityWitnessIdx AltIdentityWitnessEntity AltIdentityWitnessKind
      AltIdentityWitnessIdx where
  index := {.firstOfTwo, .secondOfTwo, .onlyOne}
  assign := fun k =>
    match k with
    | .firstOfTwo => ⟨.twoRows, .firstOfTwo, .firstKind⟩
    | .secondOfTwo => ⟨.twoRows, .secondOfTwo, .secondKind⟩
    | .onlyOne => ⟨.oneRow, .onlyOne, .thirdKind⟩

/-- **무엇을 증거하는가.** 증거의 주소 표다. 한 주체에 주소 둘을 걸고 다른 주체에 주소 하나를 걸며,
세 주체 가운데 하나는 어느 항도 받지 않는다. -/
-- DD:CF-4298
def addressWitness :
    AddressTable AltIdentityWitnessIdx AltIdentityWitnessEntity AltIdentityWitnessIdx where
  index := {.firstOfTwo, .secondOfTwo, .onlyOne}
  assign := fun k =>
    match k with
    | .firstOfTwo => ⟨.twoRows, .firstOfTwo⟩
    | .secondOfTwo => ⟨.twoRows, .secondOfTwo⟩
    | .onlyOne => ⟨.oneRow, .onlyOne⟩

/--
식별의 두 축이 한 주체에서 함께 단일하지 않다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 표가 한 주체에 항을 여럿 내는 배치가 없어야 한다. 그 관측은 그 목록의 식별이 적어도 한 축에서는
단일하다는 뜻이며, 그러면 식별을 색인된 집합으로 둔 꼴이 쓰이지 않은 채 남고 그 비유일성을 받아야
한다는 요구가 사라진다.

**존재 형태로 진술하는 까닭(T-6):**
두 축이 함께 선 주체와 둘 다 서지 않은 주체를 들어야 보인다. 임의의 주체에서 두 축이 함께 서는 것이
아니라 항이 둘 걸린 주체에서만 서고, 그 판정이 거짓이 되는 자리도 항이 하나이거나 없는 주체에서만
선다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 이름과 주소가 한 주체에서 함께 여럿이라는 것을 구조 안의 명제로 드는 유일한
자리이고, 두 판정을 따로 들면 그 둘이 같은 주체에서 함께 서는지가 재어지지 않는다.
-/
-- DD:CF-4298
theorem exists_identity_nonunique_on_both_axes :
    altNameWitness.hasMultipleNames .twoRows = true ∧
      addressWitness.hasMultipleAddresses .twoRows = true ∧
      altNameWitness.hasMultipleNames .noRow = false ∧
      addressWitness.hasMultipleAddresses .noRow = false := by
  -- 두 표가 상수이고 비유일성의 판정이 색인 위의 결정 가능한 존재 명제이므로 각 등식이
  -- 계산으로 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
비유일성의 두 조건이 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
항이 하나만 선 주체가 비유일한 것으로 나오거나, 다른 주체의 항이 이 주체의 비유일성을 세워야 한다. 그
관측은 그 판정이 색인의 다름과 주체의 같음의 곱이 아니라는 뜻이다.

**존재 형태로 진술하는 까닭(T-6):**
조건마다 그것만 거짓인 주체를 들어야 보인다. 두 조건이 함께 참인 자리와 함께 거짓인 자리만 들면 곱과
합의 값이 그 둘에서 같아 그 결합을 뒤집은 변이가 통과하므로, 항이 하나만 선 주체를 들어 색인의 다름이
홀로 가르는 자리와 주체의 같음이 홀로 가르는 자리를 함께 든다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 표의 판정이 든 결합마다 그 인자가 홀로 값을 가르는 증거를 드는 유일한
자리이고, 그 증거가 없으면 그 결합을 뒤집은 변이가 통과한다.
-/
-- DD:CF-4298
theorem hasMultiple_pins_each_conjunct :
    altNameWitness.hasMultipleNames .oneRow = false ∧
      addressWitness.hasMultipleAddresses .oneRow = false ∧
      (altNameWitness.assign .onlyOne).subject = AltIdentityWitnessEntity.oneRow ∧
      (altNameWitness.assign .firstOfTwo).subject = AltIdentityWitnessEntity.twoRows ∧
      (addressWitness.assign .onlyOne).subject = AltIdentityWitnessEntity.oneRow ∧
      (addressWitness.assign .firstOfTwo).subject = AltIdentityWitnessEntity.twoRows := by
  -- 판정은 색인 위의 결정 가능한 존재 명제의 계산이고 항의 주체는 배정의 전개이므로 각
  -- 등식이 계산으로 값이 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
같은 주체의 두 이름이 다른 유형을 받는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
한 주체에 걸린 이름들이 늘 같은 유형을 받아야 한다. 그 관측은 유형이 이름을 가르지 않는다는 뜻이며,
그러면 유형의 칸이 쓰이지 않은 채 남는다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 유형의 칸이 한 주체 안에서 값을 가른다는 것을 드는 유일한 자리이고, 유형을
매개변수로 받은 꼴이 그 자리에서 쓰인다.
-/
-- DD:CF-4297
theorem altName_kinds_differ_within_subject :
    (altNameWitness.assign .firstOfTwo).kind = AltIdentityWitnessKind.firstKind ∧
      (altNameWitness.assign .secondOfTwo).kind = AltIdentityWitnessKind.secondKind ∧
      (altNameWitness.assign .firstOfTwo).subject
        = (altNameWitness.assign .secondOfTwo).subject := by
  -- 표의 배정이 상수이므로 두 항의 유형과 주체가 전개만으로 나와 `rfl` 로 닫힌다.
  exact ⟨rfl, rfl, rfl⟩

end CrisisFramework.Definition
