/-
정의층 — 긴급 조달 접근의 위계

규율: L-10(정의층은 수를 쓰지 않는다. 시점 인덱스 ℕ 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족), C-3(판정은 계산으로 낸다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 예외),
      T-2(반증 조건), T-4(가정의 명시).

이 파일은 수를 한 번도 쓰지 않는다. 네 단계 위의 비교를 패턴 매칭의 `Bool` 반환 함수로 적으므로
순위의 공역이 설 자리가 없다.

**이 파일이 세우는 것은 주체에 붙는 위계다.** 화폐의 위계가 청구권의 네 범주에 붙고 그것에서
유도한 주체 순서가 같은 파일에 서 있는데, 그 유도 순서에서 동급이 되는 두 주체를 이 위계가
가른다. 두 순서는 독립이며 어느 것도 화폐의 위계가 아니다.

**단계마다의 풋 접근은 시점을 받지 않는다.** 그 접근이 공적 조치로 바뀐 사례가 있으므로 그
결손을 구멍으로 등재해 두었다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Nat.Notation
import CrisisFramework.Definition.Hierarchy

namespace CrisisFramework.Definition

/--
긴급 조달 접근의 단계.

**대응 비형식 개념:** 만기 불일치를 운영하는 기관이 공황에서 추가 유동성을 조달할 수 있는 여지의
단계. 원문이 그 여지가 모두에게 같지 않다고 적고 그것을 유동성 풋의 위계라 부르며, 머니펀드를 맨
아래에 두고 딜러를 그 다음에 두고 소매·도매 은행을 그 위에 두고 주권의 통화 백스톱을 맨 위에
든다(Pozsar 2014).

**이 정의가 배제하는 사례:**
머니펀드의 차입이 운용자산의 30 퍼센트를 넘지 못하는 것. 원문의 각주가 그 한도를 들면서 머니펀드의
만기 불일치가 다른 중개기관보다 작은 데 비해 공황에서 규모 있게 유동성에 닿을 여지는 은행보다
적다고 적는다(Pozsar 2014 각주 11). 이 열거는 단계만 담으므로 그 한도의 크기를 담지 않으며, 같은
단계에 선 두 기관의 여지가 얼마나 다른지도 담지 않는다.

**기각한 대체 정의:**
단계를 기관 유형의 열거로 세우는 안. 기관 유형은 의사결정 단위에 대한 관측 투영이므로 노드가
아니며, 유형으로 세우면 한 법인 안의 두 데스크가 서로 다른 여지를 갖는 것이 구조에서 보이지 않게
된다. 여지의 크기를 순서가 아니라 등급의 수로 세우는 안도 기각했다. 원문이 그 여지를 「더 많은
여지」와 「제한된 접근」 같은 비교로만 들고 어느 등급에도 수를 주지 않으므로, 수를 주면 그 값이
단계 사이의 간격을 뜻하는 것처럼 읽힌다. 네 단계를 용어집의 개념으로 등재하고 그 사이의 순서를
용어집의 관계로 등록하는 안도 기각했다. 단계가 기관 유형에 걸려 비형식 개념에 대응하지 않으므로
용어집이 등재하는 대상이 아니며, 원문 표의 주체 열거가 이미 같은 사유로 표현 수단으로 서 있다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-1618
inductive EmergencyFundingTier where
  /-- 머니펀드. 증권대여와 은행이 제공한 약정·비약정 크레딧 라인으로만 추가 유동성에 닿는다. -/
  | moneyFund
  /-- 딜러. 자산을 담보로 빌릴 여지가 더 많으나 공황에서의 접근은 여전히 제한된다. -/
  | dealer
  /-- 소매·도매 은행. 자산을 담보로 빌리거나 최후의 수단으로 중앙은행에 넘긴다. -/
  | bank
  /-- 주권. 통화 백스톱을 갖는다. -/
  | sovereign
  deriving DecidableEq, Repr

/--
앞의 단계가 뒤의 단계보다 낮지 않은가.

**대응 비형식 개념:** 두 주체 가운데 어느 쪽이 공황에서 유동성에 닿을 여지가 더 큰가. 원문이 네
단계를 머니펀드에서 주권까지 한 차례로 들면서 아래에서 위로 올라가는 순서임을 맨 아래와 그 다음과
마지막이라는 말로 적는다(Pozsar 2014).

**이 정의가 배제하는 사례:**
딜러가 머니펀드보다 위에 서는 근거. 원문이 그 근거를 자산을 담보로 빌릴 여지가 더 많다는 데 두는데
(Pozsar 2014) 그것은 여지의 크기를 비교한 것이다. 이 비교는 차례만 담으므로 그 크기를 담지 않으며,
두 단계 사이의 거리가 다른 두 단계 사이의 거리와 같은지도 담지 않는다.

**기각한 대체 정의:**
네 단계에 순위 함수를 두어 그 공역의 값으로 비교하는 안. 순위의 공역이 시점 인덱스가 아닌 자리의
자연수가 되어 정의층의 수 체계 제한을 어기며, 패턴 매칭으로 적으면 수를 쓸 수단 자체가 없다. 액면가
약속의 강도 위의 비교가 이미 같은 사유로 같은 길을 갔다. 각 단계가 닿는 풋의 집합을 포함 관계로
비교해 순서를 유도하는 안도 기각했다. 원문이 머니펀드와 딜러에 같은 두 풋을 주고 그 둘을 가르는
것을 여지의 크기에 두므로 포함으로는 그 쌍이 갈리지 않으며, 주권에는 통화 백스톱 하나만 주어 그
집합이 은행의 집합을 포함하지 않는다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-1618
def EmergencyFundingTier.atLeastAsHigh : EmergencyFundingTier → EmergencyFundingTier → Bool
  | .moneyFund, .moneyFund => true
  | .moneyFund, .dealer => false
  | .moneyFund, .bank => false
  | .moneyFund, .sovereign => false
  | .dealer, .moneyFund => true
  | .dealer, .dealer => true
  | .dealer, .bank => false
  | .dealer, .sovereign => false
  | .bank, .moneyFund => true
  | .bank, .dealer => true
  | .bank, .bank => true
  | .bank, .sovereign => false
  | .sovereign, .moneyFund => true
  | .sovereign, .dealer => true
  | .sovereign, .bank => true
  | .sovereign, .sovereign => true

/--
단계의 비교는 반사적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
같은 단계의 주체 둘 가운데 한쪽의 조달 여지가 다른 쪽보다 작다고 원문이 적어야 한다. 그러면 단계가
여지를 정하지 않으므로 이 열거가 여지의 단계가 아니다.

**가정을 두지 않는다.**
-/
-- DD:CF-1618
theorem EmergencyFundingTier.atLeastAsHigh_refl (t : EmergencyFundingTier) :
    t.atLeastAsHigh t = true := by
  cases t <;> rfl

/--
단계의 비교는 추이적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
단계 셋이 있어 첫째가 둘째보다 낮지 않고 둘째가 셋째보다 낮지 않은데 첫째가 셋째보다 낮은 것이
관측되어야 한다. 원문이 네 단계를 한 차례로 들므로 그런 셋이 서면 그 차례가 순서가 아니다.

**가정과 그 배제 사례(T-4·T-5):** 두 비교가 참이라는 것을 가정으로 진술에 명시한다. 그 가정을
떼면 어느 두 단계 사이에서도 비교가 참이어야 하는데, 원문이 머니펀드를 맨 아래에 두고 주권을 맨
위에 두므로(Pozsar 2014) 맨 아래가 맨 위보다 낮지 않다는 것은 거짓이다. 가정은 그 자리를 배제한다.
-/
-- DD:CF-1618
theorem EmergencyFundingTier.atLeastAsHigh_trans (a b c : EmergencyFundingTier)
    (hab : a.atLeastAsHigh b = true) (hbc : b.atLeastAsHigh c = true) :
    a.atLeastAsHigh c = true := by
  revert hab hbc
  cases a <;> cases b <;> cases c <;> decide

/--
단계의 비교는 전체적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
단계 둘이 서로 비교되지 않는 것이 관측되어야 한다. 각 단계가 닿는 풋의 집합을 포함 관계로 읽으면
은행과 주권이 그런 쌍이 되는데, 원문이 주권의 통화 백스톱을 마지막으로 들어 그 차례를 본문으로
들므로 이 명제가 거짓이면 그 본문을 잘못 읽은 것이다.

**가정을 두지 않는다.**
-/
-- DD:CF-1618
theorem EmergencyFundingTier.atLeastAsHigh_total (a b : EmergencyFundingTier) :
    a.atLeastAsHigh b = true ∨ b.atLeastAsHigh a = true := by
  cases a <;> cases b <;> decide

/--
단계의 비교는 반대칭적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
서로 다른 단계 둘이 양방향으로 낮지 않은 것이 관측되어야 한다. 그러면 그 둘의 조달 여지가 같으므로
단계를 둘로 가른 근거가 사라진다.

**가정과 그 배제 사례(T-4·T-5):** 양방향의 비교가 둘 다 참이라는 것을 가정으로 진술에 명시한다.
그 가정을 떼면 두 단계가 언제나 같아야 하는데, 원문이 머니펀드의 추가 유동성 조달을 증권대여와
크레딧 라인으로 한정하고 은행에는 중앙은행에 자산을 넘기는 길을 주므로(Pozsar 2014) 그 둘이 같다는
것은 거짓이다. 가정은 그 자리를 배제한다.
-/
-- DD:CF-1618
theorem EmergencyFundingTier.atLeastAsHigh_antisymm (a b : EmergencyFundingTier)
    (hab : a.atLeastAsHigh b = true) (hba : b.atLeastAsHigh a = true) :
    a = b := by
  revert hab hba
  cases a <;> cases b <;> decide

/--
유동성 풋의 기능.

**대응 비형식 개념:** 유동성에 닿는 수단의 종류. 원문이 자산을 담보로 빌리는 것과 자산을 파는 것을
각각 자금조달 유동성과 시장 유동성에 대한 접근이라 부르고 그 둘을 사적 풋으로 묶으며, 중앙은행에
자산을 넘기는 것과 주권의 통화 백스톱을 공적 풋으로 묶는다(Pozsar 2014).

**이 정의가 배제하는 사례:**
국채가 정부의 전적인 신뢰와 신용과 과세 권한으로 받쳐지는 것. 원문이 그것을 신용 풋의 위계 맨 위에
두는데(Pozsar 2014) 신용 풋은 유동성에 닿는 수단이 아니라 액면가 약속의 신용 보호를 받치는
것이므로, 이 열거는 그것을 담지 않는다. 신용 풋이 그 자리를 받으며 그 위계가 청구권의 수단 종류에
붙어 색인이 다르다.

**기각한 대체 정의:**
사적과 공적을 별도 축으로 세우고 기능을 그 축과의 쌍으로 유도하는 안. 기능이 그 풋을 누가
집행하는지를 이미 정하므로 두 축이 독립이 아니며, 쌍으로 유도하면 곱이 여덟이 되어 원문에 없는
칸을 구조가 허용한다. 명시성을 축으로 더하는 안도 기각했다. 명시성은 풋에 붙지 않고 그 풋의
발동조건에 붙으므로 색인이 다르고, 용어집의 신호 분할이 조건이 문서에 있는가를 축으로 이미 쓴다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-1619
inductive LiquidityPutKind where
  /-- 자금조달 유동성 접근. 자산을 담보로 빌려 유동성에 닿는다. 사적 풋이다. -/
  | fundingLiquidityAccess
  /-- 시장 유동성 접근. 자산을 팔아 유동성에 닿는다. 사적 풋이다. -/
  | marketLiquidityAccess
  /-- 최후대출자 접근. 자산을 중앙은행에 넘겨 유동성에 닿는다. 공적 풋이다. -/
  | lastResortLendingAccess
  /-- 통화 백스톱 접근. 주권이 갖는 선택권이며 중앙은행이 집행한다. 공적 풋이다. -/
  | currencyBackstopAccess
  deriving DecidableEq, Repr

/--
그 단계가 그 풋에 닿는가.

**대응 비형식 개념:** 각 단계의 주체가 공황에서 실제로 쓰는 유동성 수단. 원문이 머니펀드와 딜러에
자금조달과 시장 유동성을 주고, 은행에 자금조달과 최후대출자 접근을 주며, 주권에 통화 백스톱을
준다(Pozsar 2014).

**누적으로 읽지 않는다.** 원문이 단계마다 그 단계를 특징짓는 수단을 들고 아래 단계의 수단을 함께
갖는다고 적지 않는다. 은행이 자산을 파는 일이 드물다고 적는 것이 그 자리이며, 팔 수 있는가가 아니라
팔 필요가 있는가를 든다.

**이 정의가 배제하는 사례:**
소매·도매 은행이 자산을 급매로 파는 일이 드물다고 원문이 적은 것(Pozsar 2014). 팔 수 있는가가
아니라 팔 필요가 있는가를 드는 문면이므로, 이 사상이 은행의 시장 유동성 칸을 거짓으로 두는 것은
접근의 부재가 아니라 그 단계가 공황에서 쓰는 수단의 목록이다. 그래서 이 사상은 닿을 수 있으나 쓰지
않는 풋을 담지 않는다.

**통화 백스톱의 발동이 시점에 걸린다.** 원문이 그 선택권을 전시에 주로 쓰이고 더 최근에는 금융
위기에 쓰였다고 적으므로(Pozsar 2014) 단계와 풋의 대응이 시점에 따라 달라지는데, 이 사상은 시점을
받지 않으므로 그 변화를 담지 않는다. 그 결손은 구멍으로 등재되어 있다.

**기각한 대체 정의:**
이 사상을 시점 인덱스를 갖는 족으로 세우는 안. 시점 인덱스를 요구하는 조항이 타입에 걸리고 그 타입
위의 술어에는 걸리지 않으므로 족으로 둘 의무가 없으며, 족으로 두면 그 시점마다 어느 단계가 어느
풋에 닿는지를 정하는 입력이 필요한데 그 값의 출처가 원문에 없다. 단계를 받지 않고 주체를 바로 받는
안도 기각했다. 원문이 접근을 단계의 성질로 들고 주체는 단계에 배정되므로, 주체를 바로 받으면 같은
단계의 두 주체가 다른 접근을 갖는 것을 구조가 허용하면서 그 차이의 근거를 아무 데서도 받지 않는다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-1619
def EmergencyFundingTier.reaches : EmergencyFundingTier → LiquidityPutKind → Bool
  | .moneyFund, .fundingLiquidityAccess => true
  | .moneyFund, .marketLiquidityAccess => true
  | .moneyFund, .lastResortLendingAccess => false
  | .moneyFund, .currencyBackstopAccess => false
  | .dealer, .fundingLiquidityAccess => true
  | .dealer, .marketLiquidityAccess => true
  | .dealer, .lastResortLendingAccess => false
  | .dealer, .currencyBackstopAccess => false
  | .bank, .fundingLiquidityAccess => true
  | .bank, .marketLiquidityAccess => false
  | .bank, .lastResortLendingAccess => true
  | .bank, .currencyBackstopAccess => false
  | .sovereign, .fundingLiquidityAccess => false
  | .sovereign, .marketLiquidityAccess => false
  | .sovereign, .lastResortLendingAccess => false
  | .sovereign, .currencyBackstopAccess => true

/--
접근 사상이 같은 두 단계가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
원문이 네 단계마다 서로 다른 풋의 묶음을 주어야 한다. 머니펀드와 딜러가 둘 다 자금조달 유동성과
시장 유동성에 닿고 그 둘을 가르는 것이 여지의 크기이므로, 이 명제가 거짓이면 두 단계 가운데 하나의
풋을 잘못 옮긴 것이다.

**가정을 두지 않는다.**
-/
-- DD:CF-1619
theorem reaches_not_injective :
    ∃ a b : EmergencyFundingTier, a ≠ b ∧
      ∀ p : LiquidityPutKind, a.reaches p = b.reaches p := by
  -- 전칭을 `decide` 로 닫으려면 그 명제에 `Decidable` 인스턴스가 서야 하는데 풋의 열거가
  -- `DecidableEq` 만 derive 하므로 서지 않는다. 풋을 생성자마다 갈라 `rfl` 로 닫는다.
  exact ⟨.moneyFund, .dealer, by decide, fun p => by cases p <;> rfl⟩

/--
그 주체가 선 긴급 조달의 단계.

**대응 비형식 개념:** 각 주체가 공황에서 유동성에 닿을 여지의 단계. 원문이 유동성 풋의 위계를 들며
단계마다 기관을 드는데, 그 대응을 주체에서 단계로 가는 사상으로 받는다(Pozsar 2014).

**이 정의가 배제하는 사례:**
한 딜러 은행 안에 정부데스크와 크레딧데스크가 함께 있는 것. 원문의 매트릭스가 정부데스크를 주체로
들고 프라임 머니펀드의 화폐자산을 크레딧데스크가 발행한 익일물 민간레포로 드는데(Pozsar 2014), 두
데스크 가운데 하나만 표의 주체로 서므로 이 사상은 법인으로는 은행이고 데스크로는 딜러인 겹침을 담지
않는다. 그 겹침은 노드를 의사결정 단위로 둔 결정이 받으며, 기관 유형이 그 단위에 대한 관측 투영이다.

**기각한 대체 정의:**
단계를 주체의 필드가 아니라 단계에서 주체의 집합으로 가는 사상으로 받는 안. 집합으로 받으면 한
주체가 여러 단계에 드는 것을 구조가 허용하는데 원문이 단계마다 기관을 하나씩 들어 그 중복의 근거가
없으며, 주체에서 단계로 가면 그 결손이 값을 갖지 않는 자리로 선다. 값을 갖지 않는 자리를 두지 않고
모든 주체에 단계를 주는 안도 기각했다. 원문이 유동성 풋의 위계를 집행하는 쪽으로 중앙은행을 들고
접근하는 쪽으로 들지 않으므로, 모든 주체에 단계를 주면 집행자가 접근자의 위계에 서게 된다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-1620
structure EmergencyFundingAccess (Entity : Type) where
  /-- 그 주체가 선 긴급 조달의 단계. 접근자의 위계에 들지 않는 주체는 값을 갖지 않으며, 원문이
      그 자리를 위계를 집행하는 중앙은행으로 든다. -/
  tierOf : Entity → Option EmergencyFundingTier

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `EmergencyFundingAccess` 가 비어 있지 않음을 보인다. 주체가 하나이고 그
주체가 접근자의 위계에 들지 않는 사상이다.
-/
-- DD:CF-31
def EmergencyFundingAccess.trivial : EmergencyFundingAccess Unit where
  tierOf := fun _ => none

/--
시점 인덱스를 갖는 긴급 조달 접근 사상의 족 (L-13).

**대응 비형식 개념:** 어느 시점에 각 주체가 어느 단계에 서는가. 공황에서 기관의 법적 꼴이 바뀌어
중앙은행 대출 제도에 닿게 되는 일이 있으므로 같은 주체의 단계가 옮겨 간다.

**이 정의가 배제하는 사례:**
한 주체가 시점 사이에 사라지거나 생기는 것. 이 족은 주체 타입을 시점과 무관하게 받으므로 노드 집합
자체가 바뀌는 것을 담지 않으며, 그것은 노드 집합의 족이 받는다.

**기각한 대체 정의:**
단계 배정을 시점과 무관한 하나의 사상으로 두는 안. 원문이 유동성 풋의 위계를 공황에서의 생존 조건으로
들고 그 조건이 기관의 꼴에 걸리므로, 시점을 받지 않으면 그 이동이 구조에 담기지 않는다. 화폐자산
사상의 족이 이미 같은 사유로 같은 길을 갔다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-1620
abbrev EmergencyFundingAccessFamily (Entity : Type) := ℕ → EmergencyFundingAccess Entity

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `EmergencyFundingAccessFamily` 가 비어 있지 않음을 보인다. 모든 시점에
같은 사상을 내는 상수 족이다.
-/
-- DD:CF-31
def EmergencyFundingAccessFamily.constant {Entity : Type} (A : EmergencyFundingAccess Entity) :
    EmergencyFundingAccessFamily Entity := fun _ => A

/--
원문 표가 드는 주체별 긴급 조달 단계.

**대응 비형식 개념:** 원문이 노드마다 그 노드에게 화폐인 것을 든 표의 주체를 유동성 풋의 위계가
드는 단계에 배정한 것. 소매·도매 은행이 은행 단계이고 딜러의 정부데스크가 딜러 단계이며 두 머니펀드가
머니펀드 단계이고 중앙은행이 접근자의 위계에 들지 않는다(Pozsar 2014).

**이 정의가 배제하는 사례:**
전시의 통화 백스톱. 원문이 그 선택권을 주권에 주면서 전시에 쓰인다고 적고 그 사례의 출처를 든다
(McCulley and Pozsar 2012). 전시의 통화 백스톱은 재정 주체가 먼저 결정하고 중앙은행이 그것을 받는데,
이 배정은 주권을 표의 주체로 담지 않으므로 그 순서를 담지 않는다.

**기각한 대체 정의:**
중앙은행을 주권 단계에 배정하는 안. 원문이 공적 풋 둘을 중앙은행이 집행한다고 적고 통화 백스톱은
주권이 갖는다고 적으므로 집행자와 보유자가 갈리며, 중앙은행을 주권 단계에 두면 그 가름이 사라진다.
표에 없는 주권을 열거에 더해 배정하는 안도 기각했다. 이 족이 받는 주체 열거는 원문 표의 주체이고
그 표에 주권이 없으므로, 더하면 그 열거가 두 출처를 섞는다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-1633
def moneyMatrixTierAccess : EmergencyFundingAccessFamily MoneyMatrixEntity :=
  EmergencyFundingAccessFamily.constant
    { tierOf := fun e =>
        match e with
        | .centralBank => none
        | .bank => some .bank
        | .governmentDesk => some .dealer
        | .governmentOnlyFund => some .moneyFund
        | .primeFund => some .moneyFund }

/--
보유 유도 순서에서 동급인 두 주체가 긴급 조달의 단계로는 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
원문의 표에서 같은 강도의 화폐자산을 드는 두 주체가 유동성 풋의 위계에서도 같은 단계에 서야 한다.
딜러의 정부데스크와 정부전용 머니펀드가 둘 다 익일물 국채레포를 화폐자산으로 드는데 원문이 딜러를
머니펀드보다 위에 두므로, 이 명제가 거짓이면 그 둘 가운데 하나의 단계를 잘못 배정한 것이다.

**가정을 두지 않는다.**
-/
-- DD:CF-1633
theorem tier_separates_aboveOrEqual_tie :
    ∃ m n : MoneyMatrixEntity, m ≠ n ∧
      (moneyMatrixAssetFamily 0).aboveOrEqual m n = true ∧
      (moneyMatrixAssetFamily 0).aboveOrEqual n m = true ∧
      ∃ s t : EmergencyFundingTier,
        (moneyMatrixTierAccess 0).tierOf m = some s ∧
        (moneyMatrixTierAccess 0).tierOf n = some t ∧
        s.atLeastAsHigh t = true ∧ t.atLeastAsHigh s = false := by
  exact ⟨.governmentDesk, .governmentOnlyFund, by decide, by decide, by decide,
    .dealer, .moneyFund, by rfl, by rfl, by decide, by decide⟩

end CrisisFramework.Definition
