/-
정의층 — 조건부 청구권의 발동조건

규율: C-10(발동조건은 검증 가능 신호 위의 문법이고 의미는 `Bool` 반환 계산 함수다),
      L-10(정의층은 수를 쓰지 않는다. 시점 인덱스 `ℕ` 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족),
      A-3(witness 의무), D-1·D-2(docstring 3항목).

수 체계와 그 위의 연산을 전부 매개변수로 받는다. C-10 이 요구하는 것은 구체 타입 `ℤ` 가
아니라 나눗셈을 쓰지 않는 부등식의 모양이므로, `Term` 의 생성자와 `Env` 의 필드 어디에도
나눗셈이 없다. 나눗셈을 쓸 수단 자체가 타입에 없으므로 비율 제약은 분모를 양변에 곱해
쓸 수밖에 없다.

검증 가능 신호와 외생 확인 신호는 타입으로 갈린다. 앞은 `Term` 이 `Obs` 로 받아 부등식에
넣고, 뒤는 `ExtCheck` 가 `Ext` 와 `Lvl` 로 받아 명목값의 관계로 묻는다. 그래서 어느 조항이
밖에서 오는 판정에 기대는지가 타입에서 읽힌다.

산문층 대응: `docs/extractions/extraction-06-pozsar-adrian-ashcraft-boesky-2010.md` §10 (N-1).

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Finset.Basic
import CrisisFramework.Glossary.Core

namespace CrisisFramework.Definition

/--
외생 확인 신호 위의 판정.

**대응 비형식 개념:** 계약 조항이 밖에서 오는 판정을 인용하는 자리. 등급이나 소송 결과처럼
모형이 계산하지 않고 받는 값에 대해, 그 값의 수준을 조항이 묻는다.

**이 정의가 배제하는 사례:**
2007-08년에 담보가치가 떨어지면서 레포 헤어컷이 오른 것. 헤어컷은 감사된 회계수치로 판정되어
계약 당사자와 법원이 함께 확인할 수 있으므로 밖에서 오는 판정이 아니며, `Term` 이 `Obs` 로
읽는 검증 가능 신호에 든다.

**기각한 대체 정의:**
검증 불가능한 조항 전부를 여기에 담는 안. 값 집합조차 정해지지 않은 재량 조항은 `Lvl` 을
가질 수 없어 이 판정으로도 표현되지 않는다. 그런 조항은 문법 밖에 남으며, 남는다는 사실
자체를 관측층이 소스 없음으로 등재한다(C-10).
-/
-- DD:CF-42
inductive ExtCheck (Ext Lvl : Type) where
  /-- 그 외생 신호의 현재 명목값이 주어진 수준 이상이다. -/
  | atLeast : Ext → Lvl → ExtCheck Ext Lvl
  /-- 그 외생 신호의 현재 명목값이 주어진 수준과 같다. -/
  | eq : Ext → Lvl → ExtCheck Ext Lvl

/--
항.

**대응 비형식 개념:** 계약 조항의 부등식 한쪽에 서는 식. 상수와 검증 가능 신호를 곱하고
더해서 짠다.

**이 정의가 배제하는 사례:**
2007년 ABS CDO 에 대한 신용평가사의 등급 강등. 조항이 그것을 인용할 때 항으로 쓰지 못한다.
등급은 감사된 회계수치가 아니라 밖에서 오는 판정이므로 `ExtCheck` 가 받는다.

**기각한 대체 정의:**
나눗셈 생성자를 두어 비율을 직접 쓰는 안. 원 문헌의 원시 조건이 전부 곱셈 부등식이고 비율은
비교정학을 위해 나중에 재배열된 표현이므로, 나눗셈은 대상의 성질이 아니라 표현의 편의다.
생성자를 두지 않으면 분모를 양변에 곱하는 것 말고는 쓸 길이 없어 L-15 의 실무 조항이 관례가
아니라 구조로 선다.
-/
-- DD:CF-604
inductive Term (Num Obs : Type) where
  /-- 계약 문서에 적힌 상수. -/
  | const : Num → Term Num Obs
  /-- 검증 가능 신호 하나의 현재 값. -/
  | signal : Obs → Term Num Obs
  /-- 두 항의 곱. -/
  | mul : Term Num Obs → Term Num Obs → Term Num Obs
  /-- 두 항의 합. -/
  | add : Term Num Obs → Term Num Obs → Term Num Obs

/--
발동조건.

**대응 비형식 개념:** 조건부 청구권이 요구를 발생시키는 조건. 항 사이의 부등식과 외생 판정을
논리곱과 논리합으로 엮은 것이다.

**이 정의가 배제하는 사례:**
SIV 와 도관에 대해 은행이 제공한 암묵적 유동성 풋. 조건이 계약 문서에 없어 이 문법으로
표현되지 않는다. 그리고 2007-08년에 시장 조달이 마르자 일부 은행이 기구를 무너뜨리고 그
풋을 이행하지 않았으므로, 문법이 배제하는 것을 제도도 배제했다.

**기각한 대체 정의:**
`Prop` 상의 술어로 두는 안. 그러면 발동 여부가 계산으로 나오지 않아 C-3 이 요구하는 결정
가능성을 인스턴스로 따로 공급해야 하고, 계약 제도가 갖지 않는 표현력을 문법이 갖게 된다.
법원이 검증할 수 있는 정보가 감사된 회계수치라는 것이 그 근거다(C-10).
-/
-- DD:CF-42
inductive Trigger (Num Obs Ext Lvl : Type) where
  /-- 왼쪽 항이 오른쪽 항 이하다. -/
  | le : Term Num Obs → Term Num Obs → Trigger Num Obs Ext Lvl
  /-- 왼쪽 항이 오른쪽 항보다 작다. -/
  | lt : Term Num Obs → Term Num Obs → Trigger Num Obs Ext Lvl
  /-- 외생 확인 신호의 판정을 인용한다. -/
  | check : ExtCheck Ext Lvl → Trigger Num Obs Ext Lvl
  /-- 둘 다 성립한다. -/
  | and : Trigger Num Obs Ext Lvl → Trigger Num Obs Ext Lvl → Trigger Num Obs Ext Lvl
  /-- 둘 중 하나가 성립한다. -/
  | or : Trigger Num Obs Ext Lvl → Trigger Num Obs Ext Lvl → Trigger Num Obs Ext Lvl

/--
수 체계와 명목값 순서의 해석.

**대응 비형식 개념:** 계약 조항을 읽을 때 쓰는 산술과 비교의 뜻. 곱한다는 것이 무엇이고
이하라는 것이 무엇인가.

**이 정의가 배제하는 사례:** 없다. 오히려 이 정의는 다음을 배제하기 위해 갈라져 나왔다.
시점이 바뀌면 곱셈도 바뀔 수 있다고 타입이 주장하는 것. `Env` 를 통째로 시점 족으로 두면
그 주장이 서며, 재지 않은 것을 적지 않는다는 이 프로젝트의 태도와 어긋난다.

**기각한 대체 정의:**
`Env` 를 쪼개지 않고 `ℕ → Env` 로 두면서 연산의 시점 무관성을 정리의 가정으로 다는 안.
T-4 를 충족하고 실제로 막히기는 하나, 그 가정을 쓸 때마다 적어야 하고 한 번 잊으면 조용히
틀린 정리가 선다. A-1 이 `axiom` 을 막고 C-10 이 `Prop` 대신 `Bool` 을 고른 것이 전부 구조가
막게 하는 수법이므로 여기서만 사람의 주의에 맡기지 않는다.

**연산을 타입클래스가 아니라 필드로 받는 것은 `CF-605` 를 따른다.**
-/
-- DD:CF-618
structure Ops (Num Lvl : Type) where
  /-- 수 체계의 곱셈. -/
  mul : Num → Num → Num
  /-- 수 체계의 덧셈. -/
  add : Num → Num → Num
  /-- 이하 비교. 판정이 계산으로 나오므로 `Bool` 을 낸다(C-3). -/
  le : Num → Num → Bool
  /-- 미만 비교. -/
  lt : Num → Num → Bool
  /-- 명목값 사이의 순서. -/
  lvlAtLeast : Lvl → Lvl → Bool
  /-- 명목값 사이의 같음. -/
  lvlEq : Lvl → Lvl → Bool

/-- witness (A-3). 모든 자리가 `Unit` 이고 모든 판정이 참인 해석. -/
-- DD:CF-31
def Ops.trivial : Ops Unit Unit where
  mul := fun _ _ => ()
  add := fun _ _ => ()
  le := fun _ _ => true
  lt := fun _ _ => true
  lvlAtLeast := fun _ _ => true
  lvlEq := fun _ _ => true

/--
한 시점의 신호 판독.

**대응 비형식 개념:** 그 시점에 조항이 읽어 들이는 값. 감사된 회계수치와 외생 확인 신호의
명목값이다.

**이 정의가 배제하는 사례:**
2007년 8월 BNP Paribas 가 세 펀드의 환매를 중단하면서 일부 자산의 가치를 신뢰성 있게 평가할
수 없다고 밝힌 경우. 판독이 전 함수이므로 「값이 없다」가 표현되지 않고, 신호가 정의되지
않는 것과 어떤 값을 갖는 것이 이 구조에서 구별되지 않는다.

**기각한 대체 정의:**
판독을 `Obs → Option Num` 으로 두어 값 없음을 담는 안. `evalTerm` 이 항마다 없음을 전파해야
하고 그 전파 규칙이 계약 문서에 없으므로, 제도가 갖지 않는 표현력을 문법이 갖게 된다(C-10).
값 없음은 조항의 성질이 아니라 관측의 결손이므로 관측층이 소스 없음으로 등재하는 것이 거처다
(L-14).
-/
-- DD:CF-618
structure Reading (Num Obs Ext Lvl : Type) where
  /-- 검증 가능 신호의 그 시점 값. -/
  obs : Obs → Num
  /-- 외생 확인 신호의 그 시점 명목값. -/
  extLvl : Ext → Lvl

/-- witness (A-3). -/
-- DD:CF-31
def Reading.trivial : Reading Unit Unit Unit Unit where
  obs := fun _ => ()
  extLvl := fun _ => ()

/--
시점 인덱스를 갖는 판독 족 (L-13).

**대응 비형식 개념:** 시간에 따라 변하는 신호의 값. 조항이 그대로여도 이것이 바뀌면 발동
여부와 금액이 바뀐다.

**이 정의가 배제하는 사례:**
변동금리 대출의 금리가 바뀌는 것과 신용장의 조건변경이 수락되는 것이 이 구조에서 같은 종류로
보이지 않아야 하는데, 이 족만으로는 뒤를 담지 못한다. UCP 600 제10조 (c)는 변경 내용에
부합하는 제시가 있으면 수락으로 간주하고 그때부터 신용장이 변경된 것으로 보므로, 판독의 값이
조항의 족을 바꾼다. 이 족과 `TriggerFamily` 가 서로 독립이라 그 의존이 표현되지 않는다.

**기각한 대체 정의:**
판독과 조항을 한 족으로 묶어 `ℕ → (Reading × Trigger)` 로 두는 안. 묶으면 둘이 같은 이유로
바뀌는 것처럼 읽히는데, 변동금리는 조항이 그대로이고 판독만 바뀌므로 사태와 어긋난다.
-/
-- DD:CF-618
abbrev ReadingFamily (Num Obs Ext Lvl : Type) := ℕ → Reading Num Obs Ext Lvl

/-- witness (A-3). 모든 시점에 같은 판독을 주는 상수 족. -/
-- DD:CF-31
def ReadingFamily.constant {Num Obs Ext Lvl : Type} (r : Reading Num Obs Ext Lvl) :
    ReadingFamily Num Obs Ext Lvl := fun _ => r

/--
조항을 평가하는 환경.

**대응 비형식 개념:** 조항을 읽는 데 필요한 것 전부. 산술과 비교의 뜻과, 그 시점의 신호 값이다.

**이 정의가 배제하는 사례:**
같은 시점에 두 당사자가 서로 다른 값을 읽는 경우. 개설은행과 수익자가 같은 서류를 놓고 일치
여부를 달리 판단하는 것이 UCP 600 제16조의 분쟁 구조인데, 이 구조는 환경이 하나이므로 판독이
당사자에 상대적인 것을 담지 못한다. `CF-213` 이 같은 결손을 검증 가능성의 관계 상대성으로
들고 있다.

**기각한 대체 정의:**
분할 전의 여덟 필드 구조. 수 체계의 해석과 그 시점의 판독이라는 두 개념에 대응하므로 D-4 가
분할을 요구하며, 분할하지 않으면 시점을 붙일 자리가 하나로 좁혀지지 않는다.
-/
-- DD:CF-618
structure Env (Num Obs Ext Lvl : Type) where
  /-- 수 체계와 명목값 순서의 해석. 시점이 붙지 않는다. -/
  ops : Ops Num Lvl
  /-- 그 시점의 신호 판독. -/
  reading : Reading Num Obs Ext Lvl

/-- witness (A-3). -/
-- DD:CF-31
def Env.trivial : Env Unit Unit Unit Unit where
  ops := Ops.trivial
  reading := Reading.trivial

/--
항의 평가.

**대응 비형식 개념:** 계약 조항의 한쪽 식을 그 시점의 수치로 접는 것.

**이 정의가 배제하는 사례:**
헤어컷 상승분을 밖에서 미리 계산해 상수로 집어넣는 처리. 그렇게 하면 그 계산이 어디에도
기록되지 않고 문법 밖으로 빠진다. 이 함수는 신호를 `Env.obs` 로 그 자리에서 읽으므로 계산이
문법 안에 남는다.

**기각한 대체 정의:**
평가를 `Prop` 으로 주고 `Decidable` 인스턴스를 따로 공급하는 안. C-10 이 의미를 계산 함수로
주라고 한 근거가 그것이며, 반환 타입을 고르는 것만으로 C-1 과 C-2 가 개입할 자리가 사라진다.
-/
-- DD:CF-42
def evalTerm {Num Obs Ext Lvl : Type} (e : Env Num Obs Ext Lvl) : Term Num Obs → Num
  | .const n => n
  | .signal o => e.reading.obs o
  | .mul a b => e.ops.mul (evalTerm e a) (evalTerm e b)
  | .add a b => e.ops.add (evalTerm e a) (evalTerm e b)

/--
발동 여부.

**대응 비형식 개념:** 그 시점의 수치와 외생 판정에 비추어 조항이 발동했는가.

**이 정의가 배제하는 사례:**
SIV 와 도관에 대한 암묵적 유동성 풋의 이행 여부. 조건이 문서에 없으므로 `Trigger` 를 세울 수
없고, 따라서 이 함수가 판정할 대상도 되지 못한다. 2007-08년에 그 풋이 실제로 이행되지 않은
것이 배제의 근거다.

**기각한 대체 정의:**
부정 생성자를 두어 문법을 논리적으로 닫는 안. 계약 조항에 부정이 실제로 나타나는지가 지금
읽은 범위에서는 서지 않으므로, 제도가 갖지 않는 표현력을 문법도 갖지 않는다는 C-10 의 근거에
따라 두지 않는다. 필요해지면 그때 세운다.
-/
-- DD:CF-42
def fires {Num Obs Ext Lvl : Type} (e : Env Num Obs Ext Lvl) : Trigger Num Obs Ext Lvl → Bool
  | .le a b => e.ops.le (evalTerm e a) (evalTerm e b)
  | .lt a b => e.ops.lt (evalTerm e a) (evalTerm e b)
  | .check (.atLeast x l) => e.ops.lvlAtLeast (e.reading.extLvl x) l
  | .check (.eq x l) => e.ops.lvlEq (e.reading.extLvl x) l
  | .and p q => fires e p && fires e q
  | .or p q => fires e p || fires e q

/--
시점 인덱스를 갖는 발동조건 족 (L-13).

**대응 비형식 개념:** 한 청구권의 발동조건이 시간에 따라 달라지는 것. 개정과 면제와 유예가
조항을 시점마다 다르게 만든다.

**이 정의가 배제하는 사례:**
2007-08년에 채권자와 다시 협상해 재무약정을 면제받은 차입자. 발동조건을 시점 무관하게 두면
면제 전후가 같은 조항으로 읽혀 그 협상이 표현되지 않는다.

**기각한 대체 정의:**
시간 의존을 회계층에서만 처리하고 정의층은 조항 하나를 고정으로 두는 안. 재유입처가 시계열
시뮬레이션을 수행하므로 재유입 시 정의층에 시점이 필요하다.

**인덱스가 `ℕ` 인 것은 L-10 위반이 아니다.** L-13 의 명시적 예외다.
-/
-- DD:CF-50
def TriggerFamily (Num Obs Ext Lvl : Type) := ℕ → Trigger Num Obs Ext Lvl

/-- witness (A-3). 시점과 무관하게 같은 조항을 내는 족. -/
-- DD:CF-31
def TriggerFamily.constant {Num Obs Ext Lvl : Type} (t : Trigger Num Obs Ext Lvl) :
    TriggerFamily Num Obs Ext Lvl := fun _ => t

end CrisisFramework.Definition
