/-
관측층 — 담보로 제공한 자산의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 수를 쓰지 않는다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 예외),
      V-7(분할의 완전성을 주장하면 어느 귀결인지 적는다), T-2(반증 조건),
      T-4(가정을 진술에 명시한다).

**이 파일이 보는 쪽은 담보를 내놓은 쪽이다.** 받은 담보를 보는 경로는 담보의 공시 경로가 따로
들며, 두 경로가 보는 주체가 달라서 그 구조에 칸을 더하지 않고 이 구조를 새로 세운다.

**경로를 법적 형식으로 색인한다.** 같은 기능을 담보권 설정으로도 소유권 이전으로도 짤 수 있고
공시가 그 둘을 함께 담지 않으므로, 어느 형식을 담는지가 답이 서는지를 가른다.

**답이 참 쪽으로만 선다.** 담보로 내놓지 않은 여력을 담는 대상이 형식층에 없으므로, 제공이
없다는 것을 의존이 없다는 것으로 싣지 않고 구조가 대상을 담지 않는 것으로 접는다.

**조립이 구조의 판정을 함수로 받는다.** 그래서 이 파일이 정의층을 `import` 하지 않고 `open` 도
두지 않으며, 호출하는 쪽이 구조의 술어를 넣을 수도 공시에서 읽은 값을 넣을 수도 있다.

시점과 주체와 상품의 타입은 전부 매개변수로 받는다. 금액을 드는지는 판정으로만 두고 금액
자체를 담지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/
import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

/--
담보 제공의 법적 형식.

**대응 비형식 개념:** 담보를 내놓는 거래가 담보권을 세우는 것인가 소유권을 넘기는 것인가.
재고 금융의 두 기법이 이 축으로 갈린다.

**이 정의가 배제하는 사례:**
같은 기능을 영국법은 소유권 이전으로 뉴욕법은 담보권 설정으로 짜는 두 양식이 도산 시 처리에서
일괄정산과 담보권 실행으로 갈리는데, 이 열거는 그 처리의 차이를 담지 않고 형식만 가른다
(ISDA Credit Support Annex 두 양식).

**기각한 대체 정의:**
형식을 묻지 않고 경로가 드는 금액만 묻는 안. 소유권을 넘기는 구조에서는 재고가 장부에서
제거되어 담보 제공 공시가 비는데(Minko 2016 §2.4.1), 형식을 묻지 않으면 그 어긋남이 상품
축과 여력의 결손에 섞여 해소 경로가 하나로 보인다. 형식을 담보 제공 자체의 필드로 두는 안도
기각했다. 그것은 정의층 대상인 `Pledge` 를 고치는 일이고, 그 구조가 둘을 같은 모양으로 두는
판정이 이미 서 있다.

**분할의 완전성을 주장하지 않는다**(V-7). 두 칸 밖의 형식이 법역마다 있을 수 있으며 이 열거는
공시 경로가 무엇을 보는지를 가르는 데 쓰인다.
-/
-- DD:CF-929
inductive PledgeLegalForm where
  /-- 담보권을 세우고 소유권은 제공자에게 남는다. -/
  | securityInterest
  /-- 소유권이 수취자에게 넘어가고 같은 종류의 것을 돌려줄 의무가 선다. -/
  | titleTransfer
  deriving DecidableEq, Repr

/--
담보로 제공한 자산의 공시 경로.

**대응 비형식 개념:** 밖의 관측자가 어느 주체의 담보 제공을 보는 자리. 경로는 어느 주체를
보는지와 어느 법적 형식을 담는지와 금액을 드는지와 어느 축을 가르는지와 그 값이 어느 시점의
것인지를 선언한다. 알려진 경로가 드는 칸은 다음과 같다.

| 경로 | 주체 | 형식 | 금액 | 상품별 | 미제공분 | 약정 | 시점 값 |
|---|---|---|---|---|---|---|---|
| 재무제표의 담보 제공 주석 | 작성자 전량 | 담보권만 | 예 | 아니오 | 아니오 | 금융자산만 | 예 |
| 감독 규범의 자산 부담 공시 | 신용기관만 | 둘 다 | 예 | 아니오 | **예** | 딸린 부채 | **아니오** |

**이 정의가 배제하는 사례:**
기준 설정 주체가 현행 공시로는 법적 제약이 아닌 사유로 쓸 수 없는 자산이 드러나지 않는다고
적고 재초안을 논의한 것(IASB 실무진 자료, CMAC·GPF 합동회의 2015년 6월). 시장 관행이나 위험
관리로 묶인 자산이 그 부류인데, 이 구조는 법적으로 제공된 것만 칸으로 받으므로 그 자산이 어느
칸에도 서지 않는다.

**기각한 대체 정의:**
받은 담보를 보는 기존 경로 구조에 칸을 더하는 안. 그 구조가 보는 것은 담보를 받은 쪽의 공시이고
이 경로가 보는 것은 내놓은 쪽의 공시여서 보는 주체가 다르며, 칸을 더하면 그 구조의 판정 셋이
뜻을 유지하는지 전수로 확인해야 한다. 시점 축의 칸을 두지 않는 안도 기각했다. 감독 공시의 값이
분기 자료의 이동 중위값이라 어느 시점의 값도 아니므로, 시점을 인자로 받는 물음과 단위가 갈린다.
**제공하지 않은 자산을 가르는가와 약정 사항을 드는가를 칸으로 두는 안도 기각했다.** 규범에서는
그 둘이 갈리나 아래의 어느 판정도 그 칸을 읽지 않는다. 여력은 구조가 담지 않으므로 경로가 들어도
받을 자리가 없고, 약정 사항은 금융자산에만 걸려 상품을 묻는 이 물음에 닿지 않는다. 어느 검사도
읽지 않는 필드를 두지 않는 것이 이 프로젝트의 원칙이며(J-34), 그 둘이 드는 사실은 경로 값의
docstring 과 원장이 받는다.

**값을 담지 않는다**(L-14). 모든 칸이 판정이거나 열거이며 금액을 들지 않는다.
-/
-- DD:CF-928
structure CollateralizedBorrowingChannel (Entity Commodity : Type) where
  /-- 그 주체의 담보 제공을 이 경로가 보는가. -/
  coversEntity : Entity → Bool
  /-- 그 법적 형식으로 선 제공을 이 경로가 담는가. -/
  coversLegalForm : PledgeLegalForm → Bool
  /-- 이 경로가 담보로 제공된 자산의 금액을 드는가. -/
  reportsPledgedAmount : Bool
  /-- 이 경로가 제공된 자산을 그 상품 종류로 가르는가. -/
  resolvesCommodity : Commodity → Bool
  /-- 이 경로가 드는 값이 한 시점의 값인가. -/
  pointInTime : Bool

/--
아무 제공도 보지 않는 경로. witness 이며 소스 없음의 기본값이다(A-3, D-8, L-14).

**무엇을 증거하는가.** `CollateralizedBorrowingChannel` 이 비어 있지 않음을 보인다. 어느 주체도
어느 형식도 보지 않고 금액을 들지 않으며 어느 축도 가르지 않는 경로다.
-/
-- DD:CF-31
def CollateralizedBorrowingChannel.noSource {Entity Commodity : Type} :
    CollateralizedBorrowingChannel Entity Commodity where
  coversEntity := fun _ => false
  coversLegalForm := fun _ => false
  reportsPledgedAmount := false
  resolvesCommodity := fun _ => false
  pointInTime := false

/--
이 경로가 그 주체와 그 상품에 대한 의존 판정의 입력을 낼 수 있는가.

**대응 비형식 개념:** `CQ-fin-4` 가 주체 m 의 부채수용력이 상품 k 에 걸렸는지를 묻는다. 그
판정이 서려면 경로가 그 주체를 보고 금액을 들고 상품을 종류별로 가르고 시점 값을 들며 **두 법적
형식을 모두 담는 것**이 함께 서야 한다.

**이 정의가 배제하는 사례:**
감독 규범의 자산 부담 공시가 제공된 자산과 제공되지 않은 자산을 가르는데 적용 대상이 신용기관
이므로 교역 주체가 그 범위에 들지 않는다(EBA/GL/2014/03 제1편 3항). 가르는 칸이 실재하는데도
이 판정이 거짓을 내는 자리이며, 칸의 존재와 그 칸이 물음의 주체에 걸리는 것이 다르다.

**기각한 대체 정의:**
법적 형식 가운데 하나만 담으면 서는 것으로 두는 안. 소유권을 넘기는 구조로 한 금융이 담보 제공
공시에서 사라지므로, 한쪽만 보는 경로는 의존의 일부를 조용히 빠뜨린 채 참을 낸다. 제공하지 않은
여력을 이 판정의 조건에 넣는 안도 기각했다. 그 여력은 구조가 담지 않으므로 경로가 그것을 들어도
받을 자리가 없고, 판정이 거짓을 내는 까닭이 경로의 결손인지 구조의 결손인지가 섞인다.
-/
-- DD:CF-913
def CollateralizedBorrowingChannel.answersDependence {Entity Commodity : Type}
    (ch : CollateralizedBorrowingChannel Entity Commodity)
    (m : Entity) (k : Commodity) : Bool :=
  ch.coversEntity m && ch.reportsPledgedAmount && ch.resolvesCommodity k
    && ch.pointInTime
    && ch.coversLegalForm PledgeLegalForm.securityInterest
    && ch.coversLegalForm PledgeLegalForm.titleTransfer

/--
`CQ-fin-4` 의 답 자리를 공시 경로 하나의 판독으로 채운다.

**대응 비형식 개념:** 경로가 의존 판정의 입력을 낼 수 있으면 구조가 낸 판정을 그대로 싣고,
내지 못하면 소스 없음으로 접는다. **구조가 거짓을 낼 때 그것을 거짓으로 싣지 않는다.** 담보로
내놓지 않은 여력이 구조에 없으므로 제공이 없다는 것이 의존이 없다는 뜻이 아니며, 그 자리는
구조가 대상을 담지 않는 것으로 접는다.

**이 물음의 답이 참 쪽으로만 선다.** 그 비대칭의 근거가 둘이고 둘이 같은 모양이다. 구조 쪽에서는
보유를 담는 대상이 없고, 공시 쪽에서는 제공하지 않은 자산을 가르는 경로가 교역 주체를 보지
않는다. 기준 설정 주체 자신이 그 구별이 서지 않는다고 적었다.

**이 정의가 배제하는 사례:**
2014년 산둥성 두 항구에서 같은 금속에 여러 창고증권이 발급되어 은행 스물다섯 곳이 걸린 것
(Minko 2016 §3). 그 사실이 다른 사건의 수사 과정에서 드러났고 정기 공시가 아니므로, 경로가 든
칸만 보는 이 조립에 그런 자리가 없다.

**기각한 대체 정의:**
구조의 판정을 이 조립이 직접 계산하는 안. 관측층은 사상의 명세를 담고 계산을 담지 않으므로
(L-14) 판정을 함수로 받으며, 그렇게 하면 호출하는 쪽이 구조의 술어를 넣을 수도 공시에서 읽은
값을 넣을 수도 있어 둘을 맞댈 자리가 열린다. 구조가 거짓을 낼 때 그대로 거짓을 싣는 안도
기각했다. 제공이 없다는 것과 의존이 없다는 것이 다르므로, 그 둘을 한 칸에 두면 답이 거짓을
낸 자리에서 무엇이 확인된 것인지가 사라진다.
-/
-- DD:CF-931
def debtCapacityCollateralDependenceFrom {Time Entity Commodity : Type}
    (ch : CollateralizedBorrowingChannel Entity Commodity)
    (depends : Entity → Commodity → Time → Bool) :
    CQ.DebtCapacityCollateralDependence Time Entity Commodity where
  answer := fun m k t =>
    if ch.answersDependence m k then
      (if depends m k t then .holds else .undetermined .structureLacksTarget)
    else .undetermined .noMeasurementSource

/--
재무제표가 요구하는 담보 제공 공시를 보는 경로.

**대응 비형식 개념:** 회계기준이 작성자 전량에 요구하는 담보 제공 공시. 재고자산과 금융자산과
유형자산에 각각 다른 조항이 걸리며 기준일 시점의 장부금액을 든다.

**이 정의가 배제하는 사례:**
소유권을 넘기는 구조로 한 재고 금융. 그 구조에서는 새 부채가 생기지 않고 자산 측에서 재고가
현금으로 옮겨가므로 재고가 장부에서 제거되고, 제거된 것은 「담보로 제공된 재고자산」이 아니어서
이 경로에 서지 않는다(Minko 2016 §2.4.1). 2008년에 한 투자은행이 헤어컷을 표준보다 키워 실효
지배를 포기한 것으로 처리하고 자산을 제거한 것이 그 남용이며, 그렇게 옮긴 부채가 순 레버리지를
눈에 띄게 낮췄다. **같은 경제적 실질이 법적 형식에 따라 이 경로에서 보이거나 사라진다.**

**기각한 대체 정의:**
자산의 종류마다 걸리는 조항이 다른 것을 칸으로 가르는 안. 이 물음이 상품만 묻고 상품은 재고자산
하나의 조항에 걸리므로 가를 실익이 없으며, 가르면 어느 판정도 읽지 않는 칸이 는다. 약정 사항을
드는 것으로 두는 안도 기각했다. 그 요구가 금융자산에만 걸려 재고자산인 상품에 닿지 않으므로
이 물음에 대해서는 참이 아니다.

**이 값이 규범의 현행 판에 매인다.** 조문이 바뀌면 이 값이 낡고 아래 정리가 깨지며, 그 깨짐이
해소를 알리는 신호다.
-/
-- DD:CF-910
def financialStatementChannel {Entity Commodity : Type} :
    CollateralizedBorrowingChannel Entity Commodity where
  coversEntity := fun _ => true
  coversLegalForm := fun f => f == PledgeLegalForm.securityInterest
  reportsPledgedAmount := true
  resolvesCommodity := fun _ => false
  pointInTime := true

/--
감독 규범이 신용기관에 요구하는 자산 부담 공시를 보는 경로.

**대응 비형식 개념:** 제공된 자산과 제공되지 않은 자산을 범주별로 가르는 공시. **그 규범이 자산
부담을 소유권 이전 같은 법적 정의가 아니라 경제적 원칙으로 정의하고** 환매조건부 계약과 증권대여를
명시로 담으므로, 법적 형식 둘이 모두 이 경로에 선다.

**이 정의가 배제하는 사례:**
교역 주체가 상품 재고를 담보로 차입한 것. 그 규범의 적용 대상이 자본요구규정의 「institutions」
이므로 비금융기업이 범위에 들지 않는다(EBA/GL/2014/03 제1편 3항). **제공하지 않은 자산을 가르는
유일한 경로인데 그 칸이 이 물음의 주체에 닿지 않는 자리다.**

**기각한 대체 정의:**
어느 주체가 적용 대상인지를 이 값에 박는 안. 주체의 분류는 관측 투영이고 구조가 그것을 담지
않으므로(J-1), 그 판정을 인자로 받아 경로가 자기 칸으로 쓴다. 범주별 분해를 상품 축의 분해로
읽는 안도 기각했다. 서식의 자산 범주에 상품도 재고자산도 자기 행이 없고 「기타 자산」이 무형자산과
유형자산과 파생상품자산을 함께 받는다.

**이 값이 규범의 현행 판에 매인다.** 위와 같다.
-/
-- DD:CF-910
def supervisoryEncumbranceChannel {Entity Commodity : Type}
    (isInstitution : Entity → Bool) :
    CollateralizedBorrowingChannel Entity Commodity where
  coversEntity := isInstitution
  coversLegalForm := fun _ => true
  reportsPledgedAmount := true
  resolvesCommodity := fun _ => false
  pointInTime := false

/--
재무제표 경로는 상품 축의 분해와 소유권 이전 형식 둘을 더하면 의존 판정을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 둘을 더했는데도 판정이 서지 않아야 한다.
그러면 모자란 칸이 둘이 아니라 셋 이상이라는 뜻이며, 이 경로가 금액을 들지 않거나 기준일 값을
들지 않는 것이 된다.

**이 진술이 해소의 조건을 든다.** 재개 트리거를 쓸 수 없는 자리에서 이 정리가 그 몫을 받는다.
회계기준이 담보 제공분의 상품별 분해를 요구하고 소유권 이전 구조를 담게 되면 이 경로의 값이
바뀌고, 그때 답이 실제로 서는지가 기계로 확인된다.

**가정을 두지 않는다**(T-4). 주체와 상품이 전칭이며 그 둘에 조건이 붙지 않는다.
-/
-- DD:CF-910
theorem financialStatementChannel_answers_when_resolved
    {Entity Commodity : Type} (m : Entity) (k : Commodity) :
    ({ (financialStatementChannel : CollateralizedBorrowingChannel Entity Commodity) with
         coversLegalForm := fun _ => true
         resolvesCommodity := fun _ => true } :
       CollateralizedBorrowingChannel Entity Commodity).answersDependence m k = true := by
  rfl

/--
감독 경로는 주체가 적용 대상일 때 상품 축의 분해와 시점 값 둘을 더하면 의존 판정을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 적용 대상인 주체에 대해 그 둘을 더했는데도
판정이 서지 않아야 한다. 그러면 이 경로가 법적 형식 둘을 담는다는 읽기가 틀렸다는 뜻이 된다.

**가정이 하나다**(T-4). 주체가 그 규범의 적용 대상이어야 한다. 그 가정이 빠지면 적용 대상이 아닌
주체에서 거짓이 되므로 진술이 성립하지 않으며, **그 가정 자체가 이 경로의 한계를 진술에 올린다.**

**앞 정리와 모자란 칸이 다르다.** 이 경로는 형식을 이미 담고 시점이 모자라며, 앞 경로는 시점을
이미 들고 형식이 모자라다. 상품 축만 둘에 공통이다.
-/
-- DD:CF-910
theorem supervisoryEncumbranceChannel_answers_when_resolved
    {Entity Commodity : Type} (isInstitution : Entity → Bool)
    (m : Entity) (k : Commodity) (hm : isInstitution m = true) :
    ({ (supervisoryEncumbranceChannel isInstitution :
         CollateralizedBorrowingChannel Entity Commodity) with
         resolvesCommodity := fun _ => true
         pointInTime := true } :
       CollateralizedBorrowingChannel Entity Commodity).answersDependence m k = true := by
  simp only [CollateralizedBorrowingChannel.answersDependence,
    supervisoryEncumbranceChannel, hm]
  rfl

end CrisisFramework.Observation
