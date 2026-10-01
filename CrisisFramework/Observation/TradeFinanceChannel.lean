/-
관측층 — 교역 금융의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 수를 쓰지 않는다),
      A-3(witness 의무), D-1·D-2(docstring 3항목).

**명세를 소스로 색인하지 않고 소스와 축의 짝으로 색인한다.** 한 소스 안에서 축마다 관측 가능성이
갈리기 때문이다. SWIFT MT 700 은 통화와 금액과 시점을 필수 칸으로 담으면서 품목을 선택이고 자유
서술인 칸으로 담는다.

색인이 둘이다. 청구권과 교역을 잇는 **대응의 입도**가 하나이고, CQ 의 축 가운데 **무엇을 가르는가**가
다른 하나다. 둘은 독립이며 입도는 천장이고 해상도는 그 아래에서 그 경로가 실제로 하는 일이다. 신용장은
대응이 거래 단위인데도 품목을 가르지 못한다.

금액과 시점과 영역의 타입은 전부 매개변수로 받는다. 금액의 수 체계는 회계층이 정한다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/
import CrisisFramework.Definition.TradeFinance
import CrisisFramework.Observation.CompetencyQuestion

open CrisisFramework.Definition

namespace CrisisFramework.Observation

/--
청구권과 교역을 잇는 대응의 입도.

**대응 비형식 개념:** 밖의 관측자가 「이 청구권이 이 교역을 금융했다」를 무엇으로 세우는가. 신용장은
발행된 그 거래의 대금에만 쓰여 비대체적이므로 대응이 거래 하나에 붙는다(Ahn · Sarmiento 2019). 그
밖의 대출은 돈이 대체 가능해서 차입자 식별자로만 붙는다(Casas · Meleshchuk · Timmer 2022). 나라
전체의 대외차입 통화 구성만 있는 자리에서는 교역과의 대응이 아예 없다(Bénétrix 외 2019).

**이 정의가 배제하는 사례:**
콜롬비아에서 세관의 신용장 거래 자료와 신용등록부를 은행명과 수입자 번호로 이은 병합
(Ahn · Sarmiento 2019). 거래 쪽은 거래 단위이고 대출 쪽은 차입자 단위라 입도가 둘인데, 이 열거는
경로마다 하나만 든다. 그런 병합은 경로 하나가 아니므로 이 명세가 담지 않는다.

**기각한 대체 정의:**
입도를 축의 해상도로 대신하는 안. 신용장은 대응이 거래 단위인데도 품목을 가르지 못하므로(MT 700 의
45A 가 선택이고 자유 서술이다) 둘이 독립이다.
입도에 「대응 없음」 칸을 더하는 안. 대응이 아예 없는 경로는 그 교역을 보지 않는 것과 같고, 그것은
`covers` 가 이미 가른다.
-/
-- DD:CF-694
inductive FinanceLinkage where
  /-- 거래 단위. 청구권 하나가 선적 하나에 붙는다. 비대체성이 조건이다. -/
  | transaction
  /-- 차입자 단위. 차입자 식별자로만 붙으며 선적으로 내려가지 않는다. -/
  | borrower
  /-- 나라 총계. 교역과의 대응이 서지 않는다. -/
  | aggregate
  deriving DecidableEq, Repr

/--
교역 금융의 공시 경로.

**대응 비형식 개념:** 밖의 관측자가 교역을 금융한 청구권을 보는 자리. 경로는 어느 교역을 보는지와,
청구권을 교역에 무엇으로 잇는지와, CQ-fin-2 의 축 가운데 무엇을 따로 가르는지를 선언한다. 알려진
경로가 드는 칸은 다음과 같다.

| 경로 | 대응의 입도 | 통화 | 품목 | 나라 쌍 |
|---|---|---|---|---|
| SWIFT MT 700 | 거래 | ISO 4217 전부. 32B 가 필수다 | 아니오. 45A 가 선택이고 자유 서술이다 | 아니오. 당사자가 이름과 주소의 자유 텍스트다 |
| 콜롬비아 세관 신고 | 거래 | **확인되지 않았다.** 품목과 상대국과 결제 방식은 든다 | 10자리 품목 코드 | 수출국 |
| 콜롬비아 신용등록부 | 차입자 | 외화와 자국통화 둘 | 아니오 | 아니오 |
| 국제투자대조표 | 나라 총계 | SDR 다섯과 자국통화와 기타 묶음 | 아니오 | 아니오 |

**이 정의가 배제하는 사례:**
국제투자대조표의 통화 구성은 당국이 보고한 실측과 합성 가중치로 메운 값이 한 계열에 이어 붙은
것이고, 신흥국의 자국통화 발행 비중이 과소추정된다(Bénétrix 외 2019). 이 구조는 경로가 축을
가르는지만 선언하므로 **가른 값이 실측인지 추정인지를 담지 못한다.**

**기각한 대체 정의:**
경로를 소스로만 색인하는 안. 한 소스 안에서 축마다 관측 가능성이 갈리므로 소스 하나에 참과 거짓을
하나만 붙이면 그 갈림이 사라진다.
입도를 빼고 해상도만 두는 안. 차입자 단위 경로가 통화를 가르더라도 그 금액을 특정 교역에 귀속시킬 수
없는데, 해상도만으로는 그 사실이 서지 않는다.
경로마다 값을 담는 안. 관측층은 값을 담지 않는다(L-14).
-/
-- DD:CF-694
structure TradeFinanceChannel (Country Commodity Currency : Type) where
  /-- 보내는 나라와 받는 나라와 품목의 교역을 금융한 청구권을 이 경로가 보는가. -/
  covers : Country → Country → Commodity → Bool
  /-- 이 경로가 청구권을 교역에 잇는 입도. -/
  linkage : FinanceLinkage
  /-- 이 경로가 그 표시 통화를 따로 가르는가. -/
  resolvesCurrency : Currency → Bool
  /-- 이 경로가 품목을 가르는가. -/
  resolvesCommodity : Bool
  /-- 이 경로가 보내는 나라와 받는 나라의 쌍을 가르는가. -/
  resolvesCountryPair : Bool

/--
아무 교역도 보지 않는 경로. witness 이며 소스 없음의 기본값이다(A-3, L-14).

**대응 비형식 개념:** 교역을 금융한 청구권을 공시하는 자리가 없는 교역. 대부분의 나라 쌍이 그렇다.

**이 정의가 배제하는 사례:**
신용장으로 치러진 교역에는 SWIFT 메시지가 통화와 금액을 필수 칸으로 담는다. 그 교역에 이 기본값을
쓰면 있는 소스를 없다고 적게 된다.

**기각한 대체 정의:**
입도를 `transaction` 으로 두고 `covers` 만 거짓으로 두는 안. 보지 않는 경로의 입도를 가장 고운 칸으로
적으면 그 값이 거짓말을 한다.
-/
-- DD:CF-694
def TradeFinanceChannel.noSource {Country Commodity Currency : Type} :
    TradeFinanceChannel Country Commodity Currency where
  covers := fun _ _ _ => false
  linkage := .aggregate
  resolvesCurrency := fun _ => false
  resolvesCommodity := false
  resolvesCountryPair := false

/--
이 경로가 그 자리에서 답을 낼 수 있는가.

**대응 비형식 개념:** CQ-fin-2 는 나라 쌍과 품목과 통화와 시점을 모두 받아 금액 하나를 낸다. 그러므로
경로가 그 축을 **전부** 가르고 대응이 거래 단위로 서야 답이 선다. 하나라도 비면 그 경로가 내는 수는
묻지 않은 자리를 함께 더한 값이므로 답이 아니다.

**이 정의가 배제하는 사례:**
콜롬비아 신용등록부는 대출마다 통화를 가르고 차입자를 이름으로 든다. 그러나 대응이 차입자 단위라
그 기업이 여러 나라로 보낸 선적 가운데 어느 몫이 그 대출에 걸리는지가 서지 않는다. 통화를 가르는데도
답이 서지 않는 경로이며, 이 판정은 그 경우를 거짓으로 보낸다.

**기각한 대체 정의:**
가르는 축만 값으로 내고 나머지를 합산으로 메우는 안. 묻지 않은 자리를 더한 값을 답으로 적게 된다.
입도를 묻지 않고 해상도만 보는 안. 위 배제 사례가 통과해 버린다.
-/
-- DD:CF-694
def TradeFinanceChannel.answers {Country Commodity Currency : Type}
    (ch : TradeFinanceChannel Country Commodity Currency)
    (x y : Country) (k : Commodity) (c : Currency) : Bool :=
  ch.covers x y k && (ch.linkage == FinanceLinkage.transaction)
    && ch.resolvesCountryPair && ch.resolvesCommodity && ch.resolvesCurrency c

/--
공시 경로의 판독으로 교역 금융의 통화별 금액을 낸다.

**대응 비형식 개념:** 경로가 그 자리에서 답을 낼 수 있으면 금액을 내고, 그렇지 않으면 소스 없음으로
접는다. 금액을 읽는 함수는 매개변수로 받으며 관측층이 그 값을 담지 않는다(L-14).

결정을 돕는 대응은 다음과 같다. 교역을 대부분 수출자가 금융하므로 금융 경로는 수출국의 대외차입
통화 구성에 걸리고, 표시 통화 경로는 수입국에 걸린다. 두 경로가 서로 다른 나라에 붙는다
(Ma · Schmidt-Eisenlohr 2023). 수입 쪽에서는 차입기업의 외화부채 재평가가 수입을 압축하되 수출은
바꾸지 않는다(Casas · Meleshchuk · Timmer 2022).

**이 정의가 배제하는 사례:**
신용장 칸에서는 송장 통화와 청구권 통화가 같으므로(UCP 600 제18조 a) 세관 경로가 송장 통화를 담으면
품목과 상대국까지 함께 서서 답이 선다. 그런데 **세관 경로가 송장 통화를 담는지가 뭉치에서 확인되지
않았다.** 이 조립은 경로가 든 칸만 보고 그 다리를 스스로 놓지 않으므로, 다리가 놓이면 경로 선언을
고쳐야 하고 조립은 그대로다.

**기각한 대체 정의:**
여러 경로를 받아 합치는 안. 경로마다 칸이 달라 합치는 규칙이 판정을 요구한다. 결제 방식의 조립에서
같은 이유로 미뤘고 여기서도 미룬다.
통화 일치를 조립 안에 박아 세관 경로의 송장 통화를 청구권 통화로 읽는 안. 그러면 확인되지 않은 칸을
있는 것으로 적게 된다.
-/
-- DD:CF-694
def tradeFinanceAmountFrom {Time Country Commodity Currency Amount : Type}
    (ch : TradeFinanceChannel Country Commodity Currency)
    (amount : Country → Country → Commodity → Currency → Time → Amount) :
    Country → Country → Commodity → Currency → Time → ObservedValue Amount :=
  fun x y k c t =>
    if ch.answers x y k c then .value (amount x y k c t)
    else .undetermined .noMeasurementSource

/--
`CQ-fin-2` 의 답 자리를 공시 경로 하나의 판독으로 채운다.

**대응 비형식 개념:** 고정된 `CQ-fin-2` 구조물의 답 함수를 위의 조립으로 채운 것.

**이 정의가 배제하는 사례:**
알려진 경로 가운데 네 축을 모두 가르는 것이 없다. 그러므로 이 조립에 현 경로를 넣으면 답이 전부 소스
없음으로 접힌다. 접히는 자리가 어디인지는 경로 선언이 칸으로 들고 있으므로, 접힘이 공백이 아니라
**어느 칸이 비어 접혔는지의 기록**이 된다.

**기각한 대체 정의:**
답 함수의 본문을 고정 선언의 파일에 두는 안. 그 파일은 서명을 고정하는 자리이고 아무것도 import 하지
않는다. 채우는 자리를 따로 두어야 고정이 유지된다.
-/
-- DD:CF-694
def tradeFinanceCurrencyFrom {Time Country Commodity Currency Amount : Type}
    (ch : TradeFinanceChannel Country Commodity Currency)
    (amount : Country → Country → Commodity → Currency → Time → Amount) :
    CQ.TradeFinanceCurrency Time Country Commodity Currency Amount where
  answer := tradeFinanceAmountFrom ch amount

end CrisisFramework.Observation
