/-
정의층 — 자금조달 통화 등급

규율: L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외), L-13(정의층 대상은 시점 인덱스를 갖는
      족으로 선다), L-9(import 방향은 단방향), A-1(`axiom` 금지), A-3(witness 의무),
      C-1·C-2(`noncomputable` 과 `Classical` 금지), C-3(판정 술어는 `Decidable`),
      C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      D-5(식별자를 원문 저자 표기에서 가져오지 않는다), D-7(선행 등록),
      T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시), T-6(존재 형태).

이 파일은 수를 시점 인덱스로만 쓰고 금액도 비율도 담지 않는다. 등급은 통화가 역할을 받아 도달
범위를 내는 사상이며 그 비교는 참거짓만 낸다.

**이 파일이 세우는 것은 통화 사이의 순서가 무엇 위에 서는가다.** 제약 구조체가 부채 측 한도를
통화로 색인하면서 자산 측 적격성은 통화를 받지 않는데, 그 비대칭을 무엇이 만드는지가 이 아크의
물음이고 이 파일이 그 가운데 통화 쪽 축을 세운다.

**전체성을 주장하지 않는 것이 이 파일의 설계다.** 역할마다 도달 범위가 달라 어느 역할에서 앞서고
다른 역할에서 뒤지는 쌍이 비교되지 않으며, 그 비교되지 않음이 부분순서의 성질이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Nat.Notation
import CrisisFramework.Glossary.Core

namespace CrisisFramework.Definition

/--
통화가 국제적으로 맡는 역할.

**대응 비형식 개념:** 한 통화가 자기 발행 영역 밖에서 쓰이는 방식의 종류. 원 문헌이 그 종류를
셋으로 가르고 그 셋째를 부채 계약을 표시하는 통화로 세운다.

**이 정의가 배제하는 사례:**
한 통화가 어느 역할에서는 널리 쓰이고 다른 역할에서는 그렇지 않은 자리를 역할 없이 담는 읽기. 원
문헌이 달러와 유로를 글로벌 통화로 인정하는 것이 공적 준비통화의 역할이나 교역 표시통화의 역할을
넘지 않는 일이 흔하다고 적으면서 세 번째 역할이 간과된다고 적으므로, 역할을 접으면 그 간과가
구조에서 사라진다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-1 「그 인정이 공적 준비통화의 역할이나 교역 표시통화의 역할을 넘지 않는 일이 흔하다고 적는다」

**기각한 대체 정의:**
역할을 하나로 접고 통화의 국제성을 한 등급으로 두는 안. 공시가 통화별 집계를 하나로 내므로 조달이
쉬우나, 같은 통화가 한 역할에서 으뜸이고 다른 역할에서 그렇지 않은 자리가 사라지고 원 문헌이
자금조달 통화 역할에서 압도적으로 달러라고 적으면서 교역 표시에서는 그 비대칭을 그만큼 들지
않으므로 그 접음이 실물과 갈린다. 그리고 역할을 넷 이상으로 늘려 법정 통화의 역할을 더하는 안도
기각했다. 원 문헌이 셋만 들고 넷째를 들지 않으므로 그 원소가 문면에서 유도되지 않는다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2675
inductive CurrencyRole where
  /-- 공적 준비통화의 역할. -/
  | officialReserve
  /-- 교역 표시통화의 역할. -/
  | tradeInvoicing
  /-- 부채 계약을 표시하는 통화의 역할. -/
  | debtDenomination
  deriving DecidableEq, Repr

/--
한 역할에서 통화가 닿는 범위의 단계.

**대응 비형식 개념:** 그 역할에서 통화의 사용이 어디까지 미치는가. 원 문헌이 발행 영역에 갇히는
경우와 자국 관할권보다 넓은 영역을 갖는 경우를 가르고 국제 은행 체계에서 으뜸인 자리를 따로 든다.

**이 정의가 배제하는 사례:**
범위를 두 단계로 두고 넓은 쪽을 하나로 묶는 읽기. 삼중 일치의 둘째 가정이 각 영역이 자기 통화를
가지며 그 사용이 그 영역에 갇힌다고 적어 갇힌 단계를 세우고 국제통화가 자국 관할권보다 넓은
영역을 갖는다는 문면이 넘는 단계를 세우는데, 그 둘만으로는 달러와 유로가 자금조달 통화 역할에서
갈리지 않는다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §2-1 「각 영역이 자기 통화를 가지며 그 사용이 영역에 갇힌다」

**기각한 대체 정의:**
단계를 정수로 매겨 비교를 수의 대소로 두는 안. 단계가 늘어도 비교를 고치지 않아도 되므로 확장이
쉬우나, 정의층이 무차원이고 시점 인덱스만 수를 허용하므로 그 정수가 L-10 을 어긴다. 그리고 범위를
노드 색인의 유한 집합으로 두고 포함으로 순서를 유도하는 안도 기각했다. 포함 판정의 판정 가능성
인스턴스가 공리 기준선을 넘기는지를 결정 세션이 잴 수 없고 정의층이 유한 집합을 색인으로만 쓰며
집합 자체를 비교하는 선례가 없다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2675
inductive CurrencyReach where
  /-- 그 역할에서 사용이 발행 영역에 갇힌 단계. -/
  | confinedToIssueArea
  /-- 그 역할에서 사용이 자국 관할권보다 넓은 영역에 미치는 단계. -/
  | broaderThanHome
  /-- 그 역할에서 으뜸인 단계. -/
  | preEminent
  deriving DecidableEq, Repr

/--
한 단계가 다른 단계만큼 넓은가.

**대응 비형식 개념:** 두 단계 가운데 어느 쪽이 더 넓은 범위를 뜻하는가. 세 단계가 갇힌 쪽에서
으뜸 쪽으로 한 줄로 서므로 그 비교가 전순서다.

**이 정의가 배제하는 사례:**
두 단계가 비교되지 않는 자리. 원 문헌이 발행 영역에 갇히는 경우와 넘는 경우와 으뜸인 경우를 한
줄로 세워 달러가 국제 은행 체계에서 으뜸의 역할을 한다고 적으므로 그 셋 사이에 비교되지 않는 쌍이
없으며, 이 함수가 그 전순서를 담고 비교 불가를 담지 않는다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-2 「달러가 국제 은행 체계에서 으뜸의 역할을 한다고 적는다」

**기각한 대체 정의:**
비교를 `Prop` 으로 두고 판정 가능성 인스턴스를 따로 제공하는 안. 순서의 성질을 Mathlib 의 순서
클래스로 받을 수 있으나, 판정 술어가 `Decidable` 인스턴스를 갖도록 요구하는 조항을 타입 선택으로
충족하는 길이 더 좁으므로 `Bool` 을 반환한다. 그러면 판정이 `Bool` 의 상등에서 나오고 구성성
규율이 개입할 자리가 사라진다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2675
def CurrencyReach.atLeastAsWide : CurrencyReach → CurrencyReach → Bool
  | .preEminent, _ => true
  | .broaderThanHome, .preEminent => false
  | .broaderThanHome, _ => true
  | .confinedToIssueArea, .confinedToIssueArea => true
  | .confinedToIssueArea, _ => false

/--
한 단계는 자기만큼 넓다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어떤 단계가 자기와 비교했을 때 거짓을 내야 한다. 비교가 세 단계를 한 줄로 세운 패턴 매칭으로
서므로 그 거짓은 그 매칭의 어느 가지가 자기 자신을 빠뜨렸다는 뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 정의를 전개하면 세 경우의 계산으로 닫히므로 기여 목록에서 제외한다.
-/
-- DD:CF-2675
theorem CurrencyReach.atLeastAsWide_refl (r : CurrencyReach) :
    r.atLeastAsWide r = true := by
  cases r <;> rfl

/--
넓이 비교는 추이적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
갑이 을만큼 넓고 을이 병만큼 넓은데 갑이 병만큼 넓지 않은 세 단계가 있어야 한다. 세 단계가 한 줄로
서 있으므로 그 반례는 그 줄이 끊긴 자리를 뜻한다.

**가정과 그 배제 사례(T-4·T-5):** 앞의 두 넓이 비교가 참이라는 가정 둘을 진술문에 둔다. 그 둘을 빼면 임의의 세 단계에 대한 전칭 진술이 되어 거짓이며, 그 가정이 배제하는 것은 앞의 비교가 서지 않는 세 단계의 줄이다.

**T-3 분류:** 보조 보정이다. 세 변수의 유한 경우로 닫히므로 기여 목록에서 제외한다.
-/
-- DD:CF-2675
theorem CurrencyReach.atLeastAsWide_trans (a b c : CurrencyReach)
    (hab : a.atLeastAsWide b = true) (hbc : b.atLeastAsWide c = true) :
    a.atLeastAsWide c = true := by
  revert hab hbc
  cases a <;> cases b <;> cases c <;> decide

/--
두 단계는 언제나 비교된다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 쪽도 다른 쪽만큼 넓지 않은 두 단계가 있어야 한다. 이 명제가 거짓이면 범위의 단계가 한 줄로
서지 않는다는 뜻이고, 그러면 등급 비교가 역할 하나에서도 비교되지 않는 자리를 갖는다.

**가정을 두지 않는다.**

**이 진술이 등급 비교의 전체성 부재를 역할의 수에 돌린다.** 단계 사이의 비교가 전체적이므로 등급
비교가 전체적이지 않은 것은 단계의 설계 탓이 아니라 역할이 셋이라는 데 있다.

**T-3 분류:** 보조 보정이 아니다. 전체성이 단계에서는 서고 등급에서는 서지 않는다는 것을 이 명제와
등급 쪽의 정리가 함께 가르며, 그 가름이 없으면 부분순서를 고른 사유가 설계 미비로 읽힌다.
-/
-- DD:CF-2675
theorem CurrencyReach.atLeastAsWide_total (a b : CurrencyReach) :
    a.atLeastAsWide b = true ∨ b.atLeastAsWide a = true := by
  cases a <;> cases b <;> decide

/--
서로 같은 넓이인 두 단계는 같은 단계다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
서로 상대만큼 넓은데 다른 단계인 두 값이 있어야 한다. 그 반례는 세 단계 가운데 둘이 같은 넓이를
뜻한다는 것이고, 그러면 그 둘을 가른 사유가 무너진다.

**가정과 그 배제 사례(T-4·T-5):** 서로 상대만큼 넓다는 가정 둘을 진술문에 둔다. 그 둘을 빼면 임의의 두 단계가 같다는 진술이 되어 거짓이며, 그 가정이 배제하는 것은 한쪽만 넓은 두 단계의 쌍이다.

**T-3 분류:** 보조 보정이다. 유한 경우로 닫히므로 기여 목록에서 제외한다.
-/
-- DD:CF-2675
theorem CurrencyReach.atLeastAsWide_antisymm (a b : CurrencyReach)
    (hab : a.atLeastAsWide b = true) (hba : b.atLeastAsWide a = true) :
    a = b := by
  revert hab hba
  cases a <;> cases b <;> decide

/--
한 시점의 자금조달 통화 등급.

**대응 비형식 개념:** 통화마다 역할별로 어디까지 닿는가를 주는 배정. 원 문헌이 국제통화를 자국
관할권보다 넓은 영역을 갖는 것으로 세우므로 그 영역의 넓이가 통화에 붙는다.

**이 정의가 배제하는 사례:**
한 통화의 지위가 역할과 무관하게 하나로 서는 자리. 원 문헌이 세 번째 역할이 간과된다고 적고 그
역할에서 달러가 으뜸이라고 적는데 교역 표시에서는 그 비대칭을 그만큼 들지 않으므로, 역할을
정의역으로 받지 않으면 그 갈림을 담지 못한다. 그리고 통화의 영역을 노드 집합으로 명시하는 자리도
배제한다. 그 집합이 어느 공시에서도 전수로 읽히지 않는다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-3 「국제통화가 자국 관할권보다 넓은 영역을 갖는다고 적는다」

**기각한 대체 정의:**
영역을 노드 색인의 유한 집합으로 두고 포함으로 순서를 유도하는 안. 넓이가 집합의 포함으로 직접
서므로 순서의 성질이 집합론에서 따라오나, 포함 판정의 판정 가능성 인스턴스가 공리 기준선을 넘기는지를
결정 세션이 잴 수 없고 정의층이 유한 집합을 색인으로만 쓰며 집합 자체를 비교하는 선례가 없다.
그리고 관할권 타입을 새로 세워 영역을 그 타입의 집합으로 두는 안도 기각했다. 그 타입이 형식층에
서 있지 않고 아크 값 정본이 그 신설을 이 페이즈에 배정하지 않았다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2675
structure CurrencyStanding (Currency : Type) where
  /-- 그 통화가 그 역할에서 닿는 범위의 단계. -/
  reachOf : Currency → CurrencyRole → CurrencyReach

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `CurrencyStanding` 이 비어 있지 않음을 보인다. 단위 타입의 유일한 통화가
모든 역할에서 발행 영역에 갇힌 등급이다.
-/
-- DD:CF-2675
def CurrencyStanding.trivial : CurrencyStanding Unit where
  reachOf := fun _ _ => .confinedToIssueArea

/--
시점마다의 자금조달 통화 등급.

**대응 비형식 개념:** 통화의 자금조달 지위가 시간에 따라 획득되거나 잃어진다는 사실. 원 문헌이
전후 달러의 역할 변화를 시대로 가르므로 그 변화가 이 족에 담긴다.

**이 정의가 배제하는 사례:**
등급을 시점과 무관한 상수로 두는 자리. 원 문헌이 달러의 으뜸 역할을 국제 은행 체계의 성질로 적되
그것이 언제나 그러했다고 적지 않으며, 역외 달러 시장이 네 역할을 역사적 시점마다 달리 했다고
적으므로 상수로 두면 그 변화가 사라진다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-2 「달러가 국제 은행 체계에서 으뜸의 역할을 한다고 적는다」

**기각한 대체 정의:**
시점 인덱스를 두 열거에 두고 등급 구조체를 상수로 두는 안. 그러면 역할과 단계가 시점마다 달라지는
것까지 담을 수 있으나, 정의층 대상이 시점 인덱스를 갖는 족으로 서야 하는 요구가 타입에 걸리고 그
위의 술어에는 걸리지 않으므로 열거에 인덱스를 두는 것이 그 요구를 넘는다. 액면가 약속 강도와 긴급
조달 단계가 인덱스 없이 선 선례가 그 꼴이다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-2675
abbrev CurrencyStandingFamily (Currency : Type) := ℕ → CurrencyStanding Currency

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `CurrencyStandingFamily` 가 비어 있지 않음을 보인다. 어느 시점에서나 같은
등급을 내는 족이다.
-/
-- DD:CF-2675
def CurrencyStandingFamily.constant {Currency : Type} (S : CurrencyStanding Currency) :
    CurrencyStandingFamily Currency := fun _ => S

/--
한 통화의 등급이 다른 통화만큼 높은가.

**대응 비형식 개념:** 두 통화 가운데 어느 쪽이 더 넓게 쓰이는가. 역할마다 도달 범위를 맞대어 그
전량이 한 방향일 때만 등급이 갈린다.

**이 정의가 배제하는 사례:**
어느 역할에서 앞서고 다른 역할에서 뒤지는 두 통화가 비교되는 자리. 원 문헌이 달러와 유로를 글로벌
통화로 함께 묶으면서 부채 표시에서 압도적으로 달러라고 적을 뿐 유로와 파운드와 엔 사이의 순서를
들지 않으므로, 그 쌍을 비교하면 문헌에 없는 순서를 지어내게 된다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-4 「갚아야 할 금액이 달러나 유로로 표시되는데 압도적으로 달러라고 적는다」

**기각한 대체 정의:**
역할별 단계를 합쳐 하나의 값으로 접고 그 값으로 비교하는 안. 그러면 어느 두 통화도 비교되어
전순서가 서나 역할 사이의 무게를 정해야 하고 그 무게가 어느 문면에서도 유도되지 않으며, 접는
순간 한 역할에서 앞서고 다른 역할에서 뒤지는 쌍이 한 방향으로 강제된다. 그리고 세 역할 가운데
부채 표시 하나만 보고 비교하는 안도 기각했다. 등급이 그 역할의 자리인 것은 맞으나 다른 두 역할의
도달 범위가 등급의 축에 함께 서는 것이 원 문헌의 역할 열거이고, 하나만 보면 열거를 셋으로 둔
사유가 구조에서 사라진다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2675
def CurrencyStanding.atLeastAsHigh {Currency : Type} (S : CurrencyStanding Currency)
    (a b : Currency) : Bool :=
  (S.reachOf a CurrencyRole.officialReserve).atLeastAsWide
      (S.reachOf b CurrencyRole.officialReserve)
    && (S.reachOf a CurrencyRole.tradeInvoicing).atLeastAsWide
        (S.reachOf b CurrencyRole.tradeInvoicing)
    && (S.reachOf a CurrencyRole.debtDenomination).atLeastAsWide
        (S.reachOf b CurrencyRole.debtDenomination)

/--
한 통화의 등급은 자기만큼 높다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어떤 통화가 자기와 비교했을 때 거짓을 내야 한다. 역할마다 넓이 비교의 반사성이 서므로 그 거짓은
그 곱이 어느 역할을 빠뜨렸다는 뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 단계 쪽 반사성을 역할 셋에 먹이면 닫히므로 기여 목록에서 제외한다.
-/
-- DD:CF-2675
theorem CurrencyStanding.atLeastAsHigh_refl {Currency : Type}
    (S : CurrencyStanding Currency) (a : Currency) :
    S.atLeastAsHigh a a = true := by
  unfold CurrencyStanding.atLeastAsHigh
  rw [CurrencyReach.atLeastAsWide_refl, CurrencyReach.atLeastAsWide_refl,
    CurrencyReach.atLeastAsWide_refl]
  rfl

/--
등급 비교는 추이적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
갑의 등급이 을만큼 높고 을이 병만큼 높은데 갑이 병만큼 높지 않은 세 통화가 있어야 한다. 역할마다
단계의 추이성이 서므로 그 반례는 역할 사이에서 비교가 섞였다는 뜻이다.

**가정과 그 배제 사례(T-4·T-5):** 앞의 두 등급 비교가 참이라는 가정 둘을 진술문에 둔다. 그 둘을 빼면 임의의 세 통화에 대한 전칭 진술이 되어 거짓이며, 그 가정이 배제하는 것은 어느 역할에서 비교가 서지 않는 세 통화의 줄이다.

**T-3 분류:** 보조 보정이다. 단계 쪽 추이성을 역할마다 먹이면 닫히므로 기여 목록에서 제외한다.
-/
-- DD:CF-2675
theorem CurrencyStanding.atLeastAsHigh_trans {Currency : Type}
    (S : CurrencyStanding Currency) (a b c : Currency)
    (hab : S.atLeastAsHigh a b = true) (hbc : S.atLeastAsHigh b c = true) :
    S.atLeastAsHigh a c = true := by
  -- 역할 셋의 곱이 참이면 세 인자가 각각 참이다.
  have split : ∀ p q r : Bool, (p && q && r) = true → p = true ∧ q = true ∧ r = true := by
    intro p q r
    cases p <;> cases q <;> cases r <;> decide
  unfold CurrencyStanding.atLeastAsHigh at hab hbc ⊢
  obtain ⟨hab₁, hab₂, hab₃⟩ := split _ _ _ hab
  obtain ⟨hbc₁, hbc₂, hbc₃⟩ := split _ _ _ hbc
  rw [CurrencyReach.atLeastAsWide_trans _ _ _ hab₁ hbc₁,
    CurrencyReach.atLeastAsWide_trans _ _ _ hab₂ hbc₂,
    CurrencyReach.atLeastAsWide_trans _ _ _ hab₃ hbc₃]
  rfl

/--
서로 등급이 같은 두 통화는 역할마다 도달 범위가 같다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
서로 상대만큼 등급이 높은데 어느 역할에서 도달 범위가 다른 두 통화가 있어야 한다. 그 반례는 역할
하나에서 넓이의 반대칭성이 깨졌다는 뜻이다.

**가정과 그 배제 사례(T-4·T-5):** 서로 상대만큼 등급이 높다는 가정 둘을 진술문에 둔다. 그 둘을 빼면 임의의 두 통화가 역할마다 도달 범위가 같다는 진술이 되어 거짓이며, 그 가정이 배제하는 것은 한쪽만 등급이 높은 두 통화의 쌍이다.

**결론을 통화 색인의 같음으로 두지 않는 것이 이 진술의 설계다.** 그 결론을 색인의 같음으로 두면
서로 위인 두 통화가 같은 통화가 되어 거짓이 되며, 보유 유도 순서가 반대칭이 아님을 정리로 든 선례가
같은 자리에서 색인의 같음을 결론으로 두었기 때문에 그 반증이 섰다. 등급은 통화에서 도달 범위로 가는
사상이므로 그 사상이 같다는 것까지만 따라 나오고 정의역의 원소가 같다는 것은 따라 나오지 않는다.

**T-3 분류:** 보조 보정이 아니다. 부분순서가 요구하는 반대칭성을 이 결론 꼴로 충족한다는 것이 이
파일의 설계이며, 그 꼴을 색인의 같음으로 두면 거짓이 되는 자리를 이 명제가 가른다.
-/
-- DD:CF-2675
theorem CurrencyStanding.atLeastAsHigh_antisymm {Currency : Type}
    (S : CurrencyStanding Currency) (a b : Currency)
    (hab : S.atLeastAsHigh a b = true) (hba : S.atLeastAsHigh b a = true) :
    ∀ r : CurrencyRole, S.reachOf a r = S.reachOf b r := by
  -- 역할 셋의 곱이 참이면 세 인자가 각각 참이다.
  have split : ∀ p q r : Bool, (p && q && r) = true → p = true ∧ q = true ∧ r = true := by
    intro p q r
    cases p <;> cases q <;> cases r <;> decide
  unfold CurrencyStanding.atLeastAsHigh at hab hba
  obtain ⟨hab₁, hab₂, hab₃⟩ := split _ _ _ hab
  obtain ⟨hba₁, hba₂, hba₃⟩ := split _ _ _ hba
  intro r
  cases r
  · exact CurrencyReach.atLeastAsWide_antisymm _ _ hab₁ hba₁
  · exact CurrencyReach.atLeastAsWide_antisymm _ _ hab₂ hba₂
  · exact CurrencyReach.atLeastAsWide_antisymm _ _ hab₃ hba₃

/--
원 문헌이 글로벌 통화로 명시해 묶은 둘.

**대응 비형식 개념:** 국제적으로 쓰이는 통화 가운데 원 문헌이 이름으로 들어 함께 묶은 것. 그 편이
달러와 유로를 글로벌 통화로 인정하는 자리를 적고 갚아야 할 금액이 그 둘로 표시된다고 적는다.

**이 정의가 배제하는 사례:**
파운드와 엔을 이 열거에 넣는 자리. 원 문헌이 그 둘을 국경 간 은행업의 통화 구성에서만 달러와
맞대고 공적 준비통화 역할과 교역 표시통화 역할의 도달 범위를 적지 않으므로, 넣으면 그 두 역할의
칸을 채울 근거가 없고 채우면 지어내는 것이 된다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-4 「갚아야 할 금액이 달러나 유로로 표시되는데 압도적으로 달러라고 적는다」

**기각한 대체 정의:**
증거를 단위 타입 하나로 두고 구체 통화를 열거하지 않는 안. 그러면 구조가 비어 있지 않음은 보이나
두 통화의 등급이 다른 쌍이 서지 않아 등급이 자명하지 않음을 보일 수 없다. 그리고 통화를 문자열로
받아 열거를 두지 않는 안도 기각했다. 판정 술어가 판정 가능성 인스턴스를 갖도록 요구하는 조항이
그 정의역에 걸리고, 열거가 아니면 등급 사상의 전수가 문면에서 유도되지 않는다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-2675
inductive GlobalCurrency where
  /-- 미국 달러. -/
  | dollar
  /-- 유로. -/
  | euro
  deriving DecidableEq, Repr

/--
원 문헌의 두 글로벌 통화에 등급을 배정한 족.

**대응 비형식 개념:** 그 편이 적은 두 통화의 역할별 도달 범위. 달러를 국제 은행 체계에서 으뜸으로
적고 유로를 글로벌 통화로 인정하되 부채 표시에서 압도적으로 달러라고 적는다.

**이 정의가 배제하는 사례:**
유로를 어느 역할에서든 으뜸으로 두는 자리. 원 문헌이 으뜸이라는 표현을 달러에만 쓰고 유로에는
쓰지 않으며 그 둘을 글로벌 통화로 함께 묶을 때에도 부채 표시에서 압도적으로 달러라고 적으므로,
유로의 칸을 으뜸으로 두면 그 비대칭이 사라진다(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-2 「달러가 국제 은행 체계에서 으뜸의 역할을 한다고 적는다」

**기각한 대체 정의:**
시점마다 다른 등급을 주어 달러의 지위 변화를 담는 안. 역외 달러 시장이 네 역할을 역사적 시점마다
달리 했다는 문면이 그 변화를 받치나, 그 시점의 경계가 그 편에서 연도로 서지 않으므로 경계를
지어내게 된다. 시점을 상수로 두는 것이 그 지어냄을 막으며, 족의 자리는 등급이 시점에 따라 달라질
수 있다는 요구를 타입으로 받고 증거가 그 변화를 주장하지는 않는다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-2675
def globalCurrencyStandingFamily : CurrencyStandingFamily GlobalCurrency := fun _ =>
  { reachOf := fun c _ =>
      match c with
      | GlobalCurrency.dollar => CurrencyReach.preEminent
      | GlobalCurrency.euro => CurrencyReach.broaderThanHome }

/--
등급이 다른 두 통화가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
원 문헌이 글로벌 통화로 든 두 통화의 등급이 어느 시점에서도 같아야 한다. 그러면 통화 축을 별도로
두는 것이 뜻을 잃고 제약 구조체가 부채 측 한도를 통화로 색인하는 것도 뜻을 잃는다.

**존재 형태로 진술하는 까닭(T-6):**
어느 두 통화의 등급이 다른지를 전칭으로 주장하면 파운드와 엔을 포함한 모든 쌍에 대해 순서를
들어야 하는데 원 문헌이 그 순서를 들지 않는다. 등급이 자명하지 않다는 것은 다른 쌍이 하나라도
있다는 주장이므로 존재 형태가 그 주장의 꼴이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이 아니다. 통화 축이 대칭적 색인이 아니라는 확정 결정을 구조에서 받치는
것이 이 명제이며, 이것이 없으면 등급 구조체가 비어 있지 않다는 것만 서고 그 구조가 통화를 실제로
가른다는 것이 서지 않는다.
-/
-- DD:CF-2675
theorem exists_standing_strictly_higher :
    ∃ a b : GlobalCurrency, ∃ t : ℕ,
      (globalCurrencyStandingFamily t).atLeastAsHigh a b = true
      ∧ (globalCurrencyStandingFamily t).atLeastAsHigh b a = false := by
  -- 달러가 세 역할 모두에서 으뜸이고 유로가 넘는 단계이므로 한 방향으로만 참이다.
  exact ⟨GlobalCurrency.dollar, GlobalCurrency.euro, 0, rfl, rfl⟩
/--
한 통화의 의무를 다른 통화가 메울 후보인가.

**대응 비형식 개념:** 어느 통화 표시 의무를 어느 통화로 조달해 메울 수 있는가의 순서. 조달의
축과 준비의 축이 함께 서야 메울 수 있으므로 역할 둘의 넓이 비교를 곱으로 둔다.

**이 정의가 배제하는 사례:**
메울 후보를 규모의 비교로 재는 읽기. 한 편이 달러의 으뜸 역할을 적으면서 그 비교의 문턱을 들지
않으므로, 규모로 재면 그 단계를 공시에서 읽을 때 정도를 단계로 접는 임계를 지어내게 된다
(Avdjiev·McCauley·Shin 2016).
조달처: E-18 §8-2 「그 비교의 문턱을 그 편이 들지 않는다」

**기각한 대체 정의:**
메울 후보를 역할 전량의 넓이 비교로 두고 등급의 비교를 그대로 쓰는 안. 교역 표시통화의 역할이
의무를 메우는 일에 닿지 않으므로 그 역할을 넣으면 메울 수 있는 쌍이 교역 표시의 넓이 때문에
배제되고, 그 배제가 문면에서 유도되지 않는다. 그리고 부채 표시 역할 하나로 두는 안도 기각했다.
그 역할의 넓이 비교가 전순서여서 어느 쌍에서도 한 방향이 서고, 그러면 메울 후보가 없는 쌍이
구조적으로 서지 못한다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3104
def CurrencyStanding.coverCandidate {Currency : Type} (S : CurrencyStanding Currency)
    (target cover : Currency) : Bool :=
  (S.reachOf cover CurrencyRole.debtDenomination).atLeastAsWide
      (S.reachOf target CurrencyRole.debtDenomination)
    && (S.reachOf cover CurrencyRole.officialReserve).atLeastAsWide
        (S.reachOf target CurrencyRole.officialReserve)

/--
한 통화는 자기 의무를 메울 후보다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어떤 통화가 자기와 비교했을 때 거짓을 내야 한다. 역할마다 넓이 비교의 반사성이 서므로 그 거짓은
그 곱이 반사성이 서지 않는 역할을 끌어왔다는 뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 정의를 전개하면 역할 둘의 넓이 비교 반사성과 논리곱의 항등식으로
닫히므로 기여 목록에서 제외한다.
-/
-- DD:CF-3104
theorem CurrencyStanding.coverCandidate_self {Currency : Type} (S : CurrencyStanding Currency)
    (a : Currency) : S.coverCandidate a a = true := by
  unfold CurrencyStanding.coverCandidate
  rw [CurrencyReach.atLeastAsWide_refl, CurrencyReach.atLeastAsWide_refl]
  rfl

/--
어느 쪽도 다른 쪽을 메울 후보가 아닌 통화 쌍이 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
모든 통화 쌍에서 적어도 한 방향의 메울 후보 관계가 서야 한다. 그 관측은 메울 후보가 전순서라는
뜻이며, 그러면 역할 둘을 곱으로 둔 설계가 역할 하나로 접히고 비교되지 않는 쌍이 사라진다.

**존재 형태로 진술하는 까닭(T-6):**
메울 후보가 전순서가 아님은 어느 방향도 서지 않는 쌍 하나를 들어야 보이고, 임의의 쌍에 대한
전칭으로는 그 비교되지 않음이 진술되지 않는다. 시스템 수준의 등급이 개별 쌍의 메울 후보 관계를
결정하지 않는 자리다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 조달의 축과 준비의 축이 서로 독립임을 어느 쪽도 메울 수 없는 쌍으로
보이므로 기여 목록에 든다.
-/
-- DD:CF-3104
theorem exists_no_cover_either_way :
    ∃ S : CurrencyStanding Bool,
      S.coverCandidate true false = false ∧ S.coverCandidate false true = false := by
  exact ⟨{ reachOf := fun c r => match c, r with
      | true, .officialReserve => .confinedToIssueArea
      | true, .tradeInvoicing => .confinedToIssueArea
      | true, .debtDenomination => .preEminent
      | false, .officialReserve => .preEminent
      | false, .tradeInvoicing => .confinedToIssueArea
      | false, .debtDenomination => .confinedToIssueArea }, rfl, rfl⟩

end CrisisFramework.Definition
