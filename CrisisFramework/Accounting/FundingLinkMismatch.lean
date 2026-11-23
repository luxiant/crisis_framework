/-
회계층 — 조달형 통화 불일치의 크기와 그 총액을 복원하는 사슬

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(총액 기준으로 닫고 통화 간 환산을 금지한다),
      L-9(import 방향은 단방향), A-1(`axiom` 금지), A-3(witness 의무), A-6(기준선 차분),
      A-8(변이 검사와 논리 결합의 증거), C-1·C-2(`noncomputable` 과 `Classical` 금지),
      C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지), D-1·D-2(docstring 3항목),
      D-3(배제 사례는 실제 문면), D-4(한 정의에 한 개념), D-8(witness 의 서술),
      T-1(최소 단위), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시), T-6(존재 형태).

**수 체계: `ℤ`.** 정의층의 청구권이 수 체계를 매개변수로 받으므로 이 파일이 그 자리에 `ℤ` 를
넣는다.

**이 파일이 세우는 것은 조달형 불일치의 크기가 어느 꼴로 서고 그 총액을 공표 수치에서 복원하는
사슬이 어떤 가정 위에 서는가다.** 정의층이 그 불일치를 부채 통화와 자산 통화의 쌍으로 색인하고
연결의 존재만 받으며 그 크기를 회계층으로 보냈으므로 그 크기가 이 파일에 선다.

**크기를 두 잔액의 쌍으로 두고 차나 작은 쪽으로 두지 않는다.** 통화 간 환산이 금지되어 두 통화를
가로지른 연산이 설 수 없고, 지목 참조로 연 편이 한 축의 차를 재면 조달한 통화로 무엇을 샀는지가
그 값에 들어가지 않는다고 적는다.

**복원된 값을 금액 타입으로 내지 않는다.** 그 사슬이 단계마다 가정을 받으므로 복원값이 금액으로
서면 실측된 금액과 타입이 같아 둘이 갈리지 않으며, 그 가름이 이 파일이 받은 결손의 요지다.

**정리의 증명과 적재 선언은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며, 이
파일이 딛는 적재 선언도 집행이 쓴다. 그 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을
부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다. 전술을 싣으면 집행이
그것을 옮겨 쓰게 되어 절단면을 넘으며, 사전 검사가 통과한 사실은 증거가 아니라 필터다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.Claim
import CrisisFramework.Definition.Trigger
import CrisisFramework.Definition.CurrencyMismatch
import CrisisFramework.Accounting.Repayment
import CrisisFramework.Accounting.CurrencyMismatch

namespace CrisisFramework.Accounting

open CrisisFramework.Definition

/--
조달형 통화 불일치의 크기.

**대응 비형식 개념:** 한 주체가 어느 통화로 진 부채로 다른 통화의 자산을 조달한 자리에서 그 부채의
잔액과 그 자산의 잔액. 정의층이 그 연결의 존재만 받고 크기를 회계층으로 보냈으므로 그 크기가 이
선언이며, 두 잔액을 쌍으로 내고 하나의 수로 접지 않는다.

**이 정의가 배제하는 사례:**
불일치의 크기를 한 통화 축의 순 포지션으로 재는 읽기. 지목 참조로 연 편이 취약성이 부채 자체가
아니라 그 부채로 조달한 자산과 결합하여 온다고 적고 순포지션 하나로는 그 꼴이 서지 않는다고
적으므로, 차를 재면 조달한 통화로 무엇을 샀는지가 그 값에서 사라진다. 이 선언은 두 잔액을 각각
내므로 그 읽기를 담지 않으며, 두 성분을 더하거나 빼면 통화 간 환산이 선다(Bruno·Shin 2018).
조달처: E-64 §2-1 「한 축의 자산과 부채의 차를 재면 조달한 통화로 무엇을 샀는지가 그 값에 들어가지 않는다」

**기각한 대체 정의:**
두 잔액의 차나 작은 쪽을 내는 안. 한 수로 서므로 주체 사이의 비교가 쉬우나 두 성분이 서로 다른
통화의 합이고 통화 간 환산을 금지하는 요구가 색인 없는 합과 차를 막으므로, 그 연산이 그 금지에
걸린다. 연결의 존재를 가드에 두지 않고 두 잔액을 그대로 내는 안도 기각했다. 그러면 그 값이 조달
연결과 무관해져 순노출형을 재는 것과 구별되지 않고, 정의층이 두 개념을 가른 근거가 회계층에서
사라진다.

**금액이 항이므로 환경을 받는다.** 판정을 정의층에서 받으므로 이 선언은 그것을 인자로 받고 다시
정의하지 않는다.
-/
-- DD:CF-4503
def fundingLinkMismatchSize {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (M : CurrencyFundingLinkMismatch Party Currency)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (debt asset : Currency) : ℤ × ℤ :=
  if M.mismatched p debt asset = true
  then (liabilityTotalOf e S p debt, claimTotalOfHolder e S p asset)
  else (0, 0)

/--
총액을 복원하는 사슬이 받는 가정.

**대응 비형식 개념:** 통화를 건너는 조달의 총액을 공표 수치에서 복원하는 길이 단계마다 두는 가정.
그 가정이 형식층의 구조에 서지 않으면 복원된 값이 무엇을 내는지가 재어지지 않으므로 그 자리가 이
구조체다.

**이 정의가 배제하는 사례:**
복원된 값을 가정 없이 선 수로 읽는 자리. 지목 참조로 연 편이 복원의 단계를 넷으로 들면서 각 단계가
무엇을 가정하는지를 함께 적고 그 사슬의 각 단계가 가정이며 그 가정이 값을 바꾼다고 적으므로, 가정을
구조에서 빼면 그 값이 어느 가정 위에 섰는지가 사라진다. 이 구조체는 그 넷을 칸으로 두며, 한 칸으로
접으면 어느 가정이 서고 어느 가정이 서지 않는지가 판정에서 사라진다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-5 「각 단계가 가정이고 그 가정이 값을 바꾼다」

**기각한 대체 정의:**
가정의 문면을 문서화 문면에만 적고 구조에 두지 않는 안. 선언이 줄고 읽기 쉬우나 그 문면이 판정에
걸리지 않아 복원값을 쓰는 자리가 그 가정을 보지 않고 쓸 수 있으며, 복원된 값과 실측된 값이 같은
타입으로 서서 둘이 갈리지 않는다는 결손이 그대로 남는다. 가정과 그 사슬의 입력을 한 구조체에 담는
안도 기각했다. 한 정의가 둘 이상의 비형식 개념에 대응하면 분할하라는 요구가 걸리고, 담으면 가정이
전부 서는지를 묻는 판정이 수치 칸을 함께 받아 그 판정의 유니버스가 흐려진다.

**은행 부문이 그 통화의 순 차입자인지는 이 묶음에 들지 않는다.** 그 값의 참거짓이 복원의 경로를
가르는 분기이고 그 사슬이 옳게 서는지를 가르는 가정이 아니므로 입력의 묶음이 그것을 든다.
-/
-- DD:CF-4503
structure GrossReconstructionAssumptions where
  /-- 파생상품 통계의 고객 칸을 비은행의 대리로 두는가. -/
  customerIsNonbankProxy : Bool
  /-- 고객 쪽이 대출과 차입을 맞추었다고 두는가. -/
  customerSideBalanced : Bool
  /-- 보고 딜러가 부문으로서도 균형이라고 두는가. -/
  dealerSectorBalanced : Bool
  /-- 비거주자가 보유한 몫의 비중을 추정으로 두는가. -/
  nonresidentShareEstimated : Bool
  deriving DecidableEq, Repr

/-- witness (A-3). **무엇을 증거하는가.** `GrossReconstructionAssumptions` 가 비어 있지
않다. 그 넷을 전부 두는 묶음 하나를 든다. -/
-- DD:CF-4503
def GrossReconstructionAssumptions.allAssumed : GrossReconstructionAssumptions where
  customerIsNonbankProxy := true
  customerSideBalanced := true
  dealerSectorBalanced := true
  nonresidentShareEstimated := true

/--
그 묶음의 가정이 전부 서는가.

**대응 비형식 개념:** 복원된 값이 그 편이 적은 사슬 그대로 선 것인지를 한 판정으로 묻는 자리. 네
칸 가운데 하나라도 서지 않으면 그 값이 그 사슬의 값이 아니다.

**이 정의가 배제하는 사례:**
가정 가운데 하나가 서면 그 사슬이 선 것으로 보는 읽기. 지목 참조로 연 편이 둘째 단계의 가정이
보고 딜러가 부문으로서도 균형이라는 것을 함께 요구한다고 적어 한 단계의 가정이 다른 단계의 가정을
끌어오므로, 하나만 요구하면 끌려오는 가정이 판정에서 사라진다. 이 판정은 넷을 모두 요구하며, 그
가운데 하나를 빼면 그 사슬이 받는 가정의 수가 구조와 갈린다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-5 「고객이 대출과 차입을 맞추었다고 가정하면 그 잔액을 둘로 나눈다」

**기각한 대체 정의:**
서는 가정의 수를 내는 안. 어느 가정이 비는지를 세밀하게 읽으나 그 수가 금액이 아닌 계수여서 회계층의
수 체계가 그것을 받을 자리가 없고, 그 수로는 어느 칸이 비었는지가 서지 않는다. 칸마다 판정을 따로
내고 합성하지 않는 안도 기각했다. 복원값이 그 사슬 그대로 선 것인지를 한 명제로 세울 자리가 없어지며,
축을 다섯으로 가른 관측 채널이 합성 술어를 둔 선례가 그 자리를 합성에 둔다.

**판정이 `Bool` 을 내므로 C-3 이 타입 선택으로 충족된다.**
-/
-- DD:CF-4503
def GrossReconstructionAssumptions.allHold (A : GrossReconstructionAssumptions) : Bool :=
  A.customerIsNonbankProxy && A.customerSideBalanced
    && A.dealerSectorBalanced && A.nonresidentShareEstimated

/--
총액을 복원하는 사슬의 입력.

**대응 비형식 개념:** 그 사슬이 공표에서 받는 수치와 경로를 가르는 분기. 파생상품 통계의 고객 잔액과
은행 부문의 순 차입액과 비거주자 보유 비중의 분자와 분모가 그 수치이고, 은행 부문이 그 통화의 순
차입자인지가 그 분기다.

**이 정의가 배제하는 사례:**
비중을 하나의 비율 값으로 받는 읽기. 지목 참조로 연 편이 넷째 단계를 비거주자가 보유한 몫의 비중을
추정하는 것으로 적고 그 값을 내는 소스가 없어 추정으로 둔다고 적으므로 그 비중이 공표의 칸이
아니며, 회계층의 수 체계가 정수이고 비율을 스케일된 정수로 표현하라는 요구가 걸려 분자와 분모의
쌍으로 받는다. 이 구조체는 그 쌍을 들며, 비율을 한 값으로 받으면 유리수가 강제되고 그 층의 기준선이
달라진다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-6 「그 값을 내는 소스가 없어 추정으로 둔다」

**기각한 대체 정의:**
은행 부문의 순 차입액을 받지 않고 고객 잔액에서 이미 빠진 값으로 두는 안. 칸이 하나 줄지만 그 편의
셋째 단계가 은행이 전체로서 그 통화의 순 차입자이면 그 금액을 총계에서 뺀 뒤에 나눈다고 적어 그
빼기가 조건에 걸리므로, 빠진 값으로 두면 그 조건이 거짓인 자리와 참인 자리가 입력에서 같아 보인다.
그 조건을 가정의 묶음에 넣는 안도 기각했다. 그 값이 거짓인 자리에서도 복원이 적법하게 서므로 그
묶음의 뜻이 흐려진다.

**금액이 정수이므로 최소 화폐단위의 정수배로 받는다.**
-/
-- DD:CF-4503
structure GrossReconstructionInputs where
  /-- 파생상품 통계가 드는 고객에 대한 그 통화 표시 선물과 스왑의 잔액. -/
  reportedCustomerStock : ℤ
  /-- 은행 부문이 그 통화의 순 차입자인가. 거짓이면 아래의 값이 총계에서 빠지지 않는다. -/
  bankSectorIsNetBorrower : Bool
  /-- 은행 부문의 그 통화 순 차입액. -/
  bankSectorNetBorrowing : ℤ
  /-- 비거주자 보유 몫의 비중의 분자. -/
  nonresidentShareNum : ℤ
  /-- 비거주자 보유 몫의 비중의 분모. 영이면 스케일이 영이어서 복원값이 정해지지 않는다. -/
  nonresidentShareDen : ℤ
  deriving DecidableEq, Repr

/-- witness (A-3). **무엇을 증거하는가.** `GrossReconstructionInputs` 가 비어 있지 않다. 잔액이
영이고 비중이 전부인 입력 하나를 든다. -/
-- DD:CF-4503
def GrossReconstructionInputs.trivial : GrossReconstructionInputs where
  reportedCustomerStock := 0
  bankSectorIsNetBorrower := false
  bankSectorNetBorrowing := 0
  nonresidentShareNum := 1
  nonresidentShareDen := 1

/--
복원된 총액.

**대응 비형식 개념:** 그 사슬이 낸 값과 그 값이 선 스케일과 그 사슬이 받은 가정을 함께 드는 것.
복원된 총액에 스케일을 곱한 것이 스케일된 값이며, 그 관계가 교차곱으로 서므로 나눗셈을 쓸 자리가
없다.

**이 정의가 배제하는 사례:**
복원된 값을 금액으로 내어 실측된 금액과 같은 자리에 두는 읽기. 지목 참조로 연 편이 그 복원의 둘째
소스가 순 포지션을 스왑의 순 사용으로 두므로 그 값이 총 부채 포지션을 과소추정한다고 적어 복원값과
실측값이 다른 것을 재므로, 같은 타입으로 두면 그 둘을 섞어 쓰는 자리가 열린다. 이 구조체는 가정을
함께 들어 금액과 타입이 갈리며, 금액으로 내면 그 가름이 사라진다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-4 「그 값이 총 부채 포지션을 과소추정한다」

**기각한 대체 정의:**
복원된 총액을 몫으로 내고 스케일을 두지 않는 안. 값이 하나여서 쓰기 쉬우나 그 몫이 정수 나눗셈이어서
버림이 생기고 둘째 단계의 이분과 넷째 단계의 비중이 각각 나눗셈을 부르므로, 비율을 스케일된 정수로
표현하라는 요구가 그 꼴을 막는다. 가정을 이 구조체에 두지 않고 부르는 쪽이 따로 들게 하는 안도
기각했다. 그 값과 가정이 떨어져 서면 그 값을 넘겨받은 자리가 가정을 잃고, 복원값이 가정에 매인다는
것이 타입에서 사라진다.

**스케일이 양이어야 그 값이 유일하게 정해진다.** 그 요구를 타입이 담지 않으므로 그 판정은 그 값을
쓰는 자리가 가정으로 든다.
-/
-- DD:CF-4503
structure ReconstructedGross where
  /-- 스케일된 복원값. 복원된 총액에 아래의 스케일을 곱한 것이 이 값이다. -/
  scaledAmount : ℤ
  /-- 그 스케일. 둘째 단계의 이분과 넷째 단계의 비중 분모의 곱이다. -/
  scale : ℤ
  /-- 이 값을 낸 사슬이 받은 가정. -/
  assumptions : GrossReconstructionAssumptions
  deriving DecidableEq, Repr

/-- witness (A-3). **무엇을 증거하는가.** `ReconstructedGross` 가 비어 있지 않다. 값과 스케일이
영이 아니고 가정을 전부 둔 복원값 하나를 든다. -/
-- DD:CF-4503
def ReconstructedGross.trivial : ReconstructedGross where
  scaledAmount := 0
  scale := 1
  assumptions := GrossReconstructionAssumptions.allAssumed

/--
그 입력과 그 가정에서 복원된 총액.

**대응 비형식 개념:** 그 편이 드는 네 단계를 그대로 지나 복원값을 내는 사상. 첫째 단계가 고객 잔액을
받고 셋째 단계가 조건이 서면 은행 부문의 순 차입액을 빼며 넷째 단계가 비중의 분자를 곱하고, 둘째
단계의 이분과 그 비중의 분모가 스케일로 묶인다.

**이 정의가 배제하는 사례:**
은행 부문의 순 차입액을 조건 없이 빼는 읽기. 지목 참조로 연 편이 셋째 단계를 은행이 전체로서 그
통화의 순 차입자이면 그 금액을 총계에서 뺀 뒤에 나눈다고 적어 그 빼기를 조건에 걸므로, 조건 없이
빼면 그 부문이 순 대출자인 자리에서 그 값이 반대 방향으로 움직인다. 이 사상은 그 조건을 분기로
받으며, 조건을 지우면 그 편의 문면과 갈린다(Borio·McCauley·McGuire 2017).
조달처: E-72 §2-5 「은행이 전체로서 그 통화의 순 차입자이면 그 금액을 총계에서 뺀 뒤에 나눈다」

**기각한 대체 정의:**
단계마다 중간 값을 내는 사상을 따로 두고 그 사상 넷을 이어 붙이는 안. 단계가 하나씩 보이므로 읽기 쉬우나
중간 값이 금액 타입으로 서서 그 자리에서 복원값과 실측값이 섞이고, 이 파일이 그 섞임을 막으려고
타입을 가른 것이 그 설계의 요지다. 가정을 받지 않고 값만 내는 안도 기각했다. 그러면 복원값이 가정에
매인다는 것이 그 사상의 치역에서 사라지고, 그 가정을 구조가 담지 않는다는 결손이 그대로 남는다.

**스케일을 둘과 비중의 분모의 곱으로 두는 것이 두 나눗셈을 한 자리에 묶는 꼴이다.**
-/
-- DD:CF-4503
def reconstructGross (I : GrossReconstructionInputs)
    (A : GrossReconstructionAssumptions) : ReconstructedGross where
  scaledAmount :=
    (if I.bankSectorIsNetBorrower = true
     then I.reportedCustomerStock - I.bankSectorNetBorrowing
     else I.reportedCustomerStock) * I.nonresidentShareNum
  scale := 2 * I.nonresidentShareDen
  assumptions := A

/--
조달 연결이 서지 않으면 그 크기가 영 쌍이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 배정과 어느 주체와 어느 통화 쌍에서 조달 연결 판정이 거짓인데 그 크기의 어느 성분이 영이
아니어야 한다. 그러면 그 크기가 조달 연결과 무관하게 서는 것이므로, 연결의 존재를 가드에 두어
조달형을 순노출형과 가른 설계가 그 자리에서 깨진다.

**가정과 그 배제 사례(T-4·T-5):** 연결 판정이 거짓이라는 가정을 진술문에 둔다. 그 가정을 빼면
연결이 선 자리에서도 영을 주장하게 되어 거짓이며, 그 가정이 배제하는 것은 그 통화 쌍에 조달
연결이 선 배정이다.

**T-3 분류:** 보조 보정이다. 가드의 조건절을 전개하면 증명이 닫히므로 이 명제가 새 내용을 더하지
않는다. 그럼에도 두는 사유는 그 가름이 정의 본문의 조건절에만 있어 소스를 읽지 않으면 보이지
않는데 이 명제가 그것을 진술로 끌어올린다는 것이다.
-/
-- DD:CF-4503
theorem fundingLinkMismatchSize_eq_zero_of_not_mismatched
    {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (M : CurrencyFundingLinkMismatch Party Currency)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (debt asset : Currency)
    (h : M.mismatched p debt asset = false) :
    fundingLinkMismatchSize e M S p debt asset = (0, 0) := by
  unfold fundingLinkMismatchSize
  rw [h]
  rfl

/--
같은 통화로 조달한 자산에서 그 크기가 영 쌍이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 배정과 어느 주체와 어느 통화에서 부채 통화와 자산 통화가 같은데 그 크기의 어느 성분이 영이
아니어야 한다. 그러면 자산의 통화가 부채의 통화와 같으면 상쇄라는 지목 참조의 문면이 회계층에서
받히지 않으므로, 조달형 불일치의 크기를 두 통화의 쌍으로 색인한 설계가 그 자리에서 깨진다.

**가정과 그 배제 사례(T-4·T-5):** 통화 타입에 판정 가능 동등성을 요구한다. 두 통화가 같은지를 묻는
자리가 정의층의 판정에 이미 서 있고 이 명제가 그 판정을 지나므로 그 요구가 진술에 든다. 그 요구를
빼면 같음을 명제로만 쓸 수 있고 판정 술어가 명제로 밀려 구성성 규율이 요구하는 판정 가능성이 서지
않는다.

**T-3 분류:** 보조 보정이다. 정의층이 같은 통화에서 그 판정이 거짓임을 이미 정리로 들고 앞의 명제가
그 거짓에서 영 쌍을 내므로 이 명제가 그 둘의 합성이다. 그럼에도 두는 사유는 뒤의 아크가 상쇄를 쓰는
자리에서 정의층의 판정을 지나지 않고 회계층의 크기만 보는 일이 있고 그때 이 명제가 그 교환의
근거라는 것이다.
-/
-- DD:CF-4503
theorem fundingLinkMismatchSize_same_currency
    {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (M : CurrencyFundingLinkMismatch Party Currency)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (c : Currency) :
    fundingLinkMismatchSize e M S p c c = (0, 0) := by
  exact fundingLinkMismatchSize_eq_zero_of_not_mismatched e M S p c c
    (same_currency_not_mismatched M p c)

/--
부채 성분이 영이 아니면서 자산 성분이 영인 배치가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 배정에서도 조달 연결이 선 통화 쌍의 두 성분이 함께 영이거나 함께 영이 아니어야 한다. 그러면
한 성분에서 다른 성분이 유도되고, 두 잔액을 쌍으로 두어 각각 내는 설계가 과한 것이 된다. 공시
경로가 부채의 표시 통화를 내면서 자산의 표시 통화를 내지 못한다는 관측층의 결손도 그때는 한 축의
결손으로 접힌다.

**존재 형태로 진술하는 까닭(T-6):** 두 성분이 서로를 유도하지 않는다는 것을 전칭으로 주장하면 두
성분이 같은 배정에서도 그 주장이 서야 하는데 그런 배정이 실재하므로 그 전칭은 거짓이다. 유도되지
않음의 주장은 둘이 갈리는 배정이 하나라도 있다는 것이므로 존재 형태가 그 주장의 꼴이며, 시스템
수준 제약이 개별 노드 상태를 결정하지 않는 자리에 존재 형태를 요구하는 조항이 이 자리에 걸린다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 크기를 쌍으로 두는 설계가 필요하다는 것을 반례의 부재가 아니라 증인의 존재로
세우는 자리이며, 이것이 없으면 두 성분이 각각 선다는 것만 서고 그 둘이 서로 다른 것을 재는 것이
서지 않는다.
-/
-- DD:CF-4503
theorem exists_fundingLinkMismatchSize_debtOnly :
    ∃ (e : Env ℤ Unit Unit Unit)
      (M : CurrencyFundingLinkMismatch Unit MismatchWitnessCurrency)
      (S : ClaimSet Unit Unit ℤ Unit Unit Unit MismatchWitnessCurrency),
      (fundingLinkMismatchSize e M S () MismatchWitnessCurrency.debtSide
        MismatchWitnessCurrency.assetSide).1 = 1
      ∧ (fundingLinkMismatchSize e M S () MismatchWitnessCurrency.debtSide
        MismatchWitnessCurrency.assetSide).2 = 0 := by
  -- 증인은 청구권 하나가 부채 쪽 통화로 표시된 그 주체의 부채인 배치다. 그 주체가 그 청구권을
  -- 보유하기도 하지만, 표시 통화가 자산 쪽 통화가 아니므로 자산 성분에는 세어지지 않는다.
  refine ⟨{ ops := { mul := fun a b => a * b
                     add := fun a b => a + b
                     le := fun a b => decide (a ≤ b)
                     lt := fun a b => decide (a < b)
                     lvlAtLeast := fun _ _ => true
                     lvlEq := fun _ _ => true }
            reading := { obs := fun _ => 0, extLvl := fun _ => () } },
          linkedFundingWitness,
          { index := Finset.univ
            assign := fun _ =>
              { obligor := ()
                holder := ()
                currency := MismatchWitnessCurrency.debtSide
                amount := Term.const 1
                trigger :=
                  TriggerFamily.constant (Trigger.le (Term.const 0) (Term.const 1))
                inception := 0
                expiry := 0
                exercisable := fun _ => true } },
          ?_, ?_⟩
  · decide
  · decide

/--
두 주체의 크기가 서로 비교되지 않는 배치가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 배정에서도 두 주체의 크기가 성분마다 같은 방향으로 서야 한다. 그러면 그 크기에 전순서가 서고
어느 주체를 먼저 볼지가 그 순서에서 정해지므로, 내리려는 항이 금융 주체의 감시 대상을 가리는 데
복무한다는 그 항의 문면이 그 순서로 충족된다. 그때는 통화 간 환산 없이도 두 축을 묶는 비교가 선다.

**존재 형태로 진술하는 까닭(T-6):** 전순서가 서지 않음을 전칭으로 주장하면 모든 주체 쌍이 비교되지
않아야 하는데 성분이 같은 방향으로 서는 쌍도 실재하므로 그 전칭은 거짓이다. 순서의 부재는 비교되지
않는 쌍이 하나라도 있다는 것이므로 존재 형태가 그 주장의 꼴이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 잔액을 쌍으로 둔 설계의 대가를 형식층이 드는 자리이며, 그 대가가 내리려는
항의 착지에 걸리므로 그 결손이 이 명제에서 구멍으로 선다.
-/
-- DD:CF-4503
theorem exists_fundingLinkMismatchSize_incomparable :
    ∃ (e : Env ℤ Unit Unit Unit)
      (M : CurrencyFundingLinkMismatch Bool MismatchWitnessCurrency)
      (S : ClaimSet Bool Bool ℤ Unit Unit Unit MismatchWitnessCurrency) (p q : Bool),
      (fundingLinkMismatchSize e M S p MismatchWitnessCurrency.debtSide
        MismatchWitnessCurrency.assetSide).1
        < (fundingLinkMismatchSize e M S q MismatchWitnessCurrency.debtSide
          MismatchWitnessCurrency.assetSide).1
      ∧ (fundingLinkMismatchSize e M S q MismatchWitnessCurrency.debtSide
        MismatchWitnessCurrency.assetSide).2
        < (fundingLinkMismatchSize e M S p MismatchWitnessCurrency.debtSide
          MismatchWitnessCurrency.assetSide).2 := by
  -- 증인은 청구권 둘이 모두 `true` 의 부채이고 `false` 가 보유하며, 색인이 참인 것은 부채 쪽 통화로,
  -- 거짓인 것은 자산 쪽 통화로 표시되는 배치다. `false` 의 크기는 부채 성분이 영이고 자산 성분이
  -- 하나이며 `true` 의 크기는 그 반대이므로, 두 주체의 대소가 성분마다 반대 방향으로 갈린다.
  refine ⟨{ ops := { mul := fun a b => a * b
                     add := fun a b => a + b
                     le := fun a b => decide (a ≤ b)
                     lt := fun a b => decide (a < b)
                     lvlAtLeast := fun _ _ => true
                     lvlEq := fun _ _ => true }
            reading := { obs := fun _ => 0, extLvl := fun _ => () } },
          { fundsAssetIn := fun _ _ _ => true },
          { index := Finset.univ
            assign := fun i =>
              { obligor := true
                holder := false
                currency :=
                  bif i then MismatchWitnessCurrency.debtSide
                  else MismatchWitnessCurrency.assetSide
                amount := Term.const 1
                trigger :=
                  TriggerFamily.constant (Trigger.le (Term.const 0) (Term.const 1))
                inception := 0
                expiry := 0
                exercisable := fun _ => true } },
          false, true, ?_, ?_⟩
  · decide
  · decide

/--
수치가 같고 가정이 갈리는 복원값이 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 입력에서도 가정의 묶음이 갈리면 스케일된 값이나 스케일도 함께 갈려야 한다. 그러면 복원된 값이
그 수치만으로 정해지고 가정을 구조가 담을 까닭이 사라지므로, 그 가정을 형식층의 구조가 담지 않으면
복원된 값이 무엇을 내는지가 재어지지 않는다는 결손의 요지가 그 자리에서 뒤집힌다.

**존재 형태로 진술하는 까닭(T-6):** 복원값이 가정에 매인다는 것을 전칭으로 주장하면 가정이 갈릴
때마다 값이 갈려야 하는데 수치가 같으면 스케일된 값이 같으므로 그 전칭은 거짓이다. 그 매임의 주장은
수치가 같은데도 두 복원값이 다른 배치가 하나라도 있다는 것이므로 존재 형태가 그 주장의 꼴이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 가정을 구조체의 필드로 둔 설계가 복원값을 가정에 매는 것을 값으로 보이는
자리이며, 그 매임이 복원된 값과 실측된 값을 타입으로 가른 근거다.
-/
-- DD:CF-4503
theorem exists_reconstructGross_sameAmount_differentAssumptions :
    ∃ (I : GrossReconstructionInputs) (A B : GrossReconstructionAssumptions),
      (reconstructGross I A).scaledAmount = (reconstructGross I B).scaledAmount
      ∧ (reconstructGross I A).scale = (reconstructGross I B).scale
      ∧ reconstructGross I A ≠ reconstructGross I B := by
  -- 증인은 같은 입력 위에서 가정을 전부 둔 묶음과 그 첫 칸만 거짓으로 바꾼 묶음이다.
  exact ⟨GrossReconstructionInputs.trivial, GrossReconstructionAssumptions.allAssumed,
    { GrossReconstructionAssumptions.allAssumed with customerIsNonbankProxy := false },
    rfl, rfl, by decide⟩

/--
은행 부문의 순 차입 판정이 복원값을 가르는 배치가 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
수치가 같고 그 판정만 갈리는 두 입력에서 스케일된 값이 언제나 같아야 한다. 그러면 그 판정이 복원의
경로를 가르지 않으므로, 그 편의 셋째 단계가 그 빼기를 조건에 걸었다는 문면이 형식층에서 받히지
않는다. 그때는 그 판정을 입력의 묶음에 둘 까닭이 사라진다.

**존재 형태로 진술하는 까닭(T-6):** 그 판정이 값을 가른다는 것을 전칭으로 주장하면 순 차입액이 영인
입력에서도 값이 갈려야 하는데 그 자리에서 두 값이 같으므로 그 전칭은 거짓이다. 가름의 주장은 갈리는
입력이 하나라도 있다는 것이므로 존재 형태가 그 주장의 꼴이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 판정을 가정의 묶음이 아니라 입력의 묶음에 둔 가름이 값에서 확인되는
자리이며, 그 가름이 없으면 그 판정이 가정과 같은 자리에 접힌다.
-/
-- DD:CF-4503
theorem exists_reconstructGross_differs_by_netBorrower :
    ∃ (I J : GrossReconstructionInputs) (A : GrossReconstructionAssumptions),
      I.reportedCustomerStock = J.reportedCustomerStock
      ∧ I.bankSectorNetBorrowing = J.bankSectorNetBorrowing
      ∧ I.nonresidentShareNum = J.nonresidentShareNum
      ∧ I.nonresidentShareDen = J.nonresidentShareDen
      ∧ (reconstructGross I A).scaledAmount ≠ (reconstructGross J A).scaledAmount := by
  -- 증인은 순 차입액이 하나인 두 입력이 순 차입자 판정에서만 갈리는 배치다. 판정이 참인 쪽은 그
  -- 금액을 빼므로 스케일된 값이 음이 되고 거짓인 쪽은 영으로 남는다.
  exact ⟨{ reportedCustomerStock := 0
           bankSectorIsNetBorrower := true
           bankSectorNetBorrowing := 1
           nonresidentShareNum := 1
           nonresidentShareDen := 1 },
         { reportedCustomerStock := 0
           bankSectorIsNetBorrower := false
           bankSectorNetBorrowing := 1
           nonresidentShareNum := 1
           nonresidentShareDen := 1 },
         GrossReconstructionAssumptions.allAssumed,
         rfl, rfl, rfl, rfl, by decide⟩

/--
그 판정의 네 인자가 각각 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
가정을 전부 둔 묶음에서 어느 한 칸만 거짓으로 바꾸었는데 그 판정이 참으로 남아야 한다. 그러면 그
칸이 그 논리곱에서 값을 가르지 않으므로, 넷을 모두 요구한 판정이 실은 셋 이하를 요구하는 것이 되고
그 칸을 구조에 둔 까닭이 사라진다.

**가정을 두지 않는다.** 증인을 리터럴로 들고 네 등식이 전부 결정 가능하므로 가정이 설 자리가 없다.

**T-3 분류:** 기여다. 판정 반환 함수를 새로 세우면 그 논리 결합마다 홀로 값을 가르는 경로를 증거로
드는 정리를 같은 파일에 두라는 A-8 의 요구를 이 명제가 받으며, 결론을 부정한 사본이 컴파일에 실패하는 것만
으로는 그 사본이 어느 증거 위에서 재어졌는지가 서지 않으므로 각 인자가 홀로 값을 가르는 자리를 이
명제가 든다.
-/
-- DD:CF-4503
theorem allHold_each_clause_decides :
    GrossReconstructionAssumptions.allAssumed.allHold = true
    ∧ { GrossReconstructionAssumptions.allAssumed with
        customerIsNonbankProxy := false }.allHold = false
    ∧ { GrossReconstructionAssumptions.allAssumed with
        customerSideBalanced := false }.allHold = false
    ∧ { GrossReconstructionAssumptions.allAssumed with
        dealerSectorBalanced := false }.allHold = false
    ∧ { GrossReconstructionAssumptions.allAssumed with
        nonresidentShareEstimated := false }.allHold = false := by
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Accounting
