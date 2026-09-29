/-
관측층 — 결제 방식의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 수를 쓰지 않는다),
      A-3(witness 의무), D-1·D-2(docstring 3항목).

관측 명세를 관측자가 아니라 공시 경로로 색인한다. 밖의 관측자는 법이 공시를 강제하거나 중개자가
기록을 남기는 자리에서만 계약을 본다. 경로마다 따로 가르는 결제 방식이 다르며, 가르지 못하는 방식의
답은 판정 불가로 접는다.

금액과 시점과 영역의 타입은 전부 매개변수로 받는다. 금액의 수 체계는 회계층이 정한다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/
import CrisisFramework.Definition.TradePayment
import CrisisFramework.Observation.CompetencyQuestion

open CrisisFramework.Definition

namespace CrisisFramework.Observation

/--
결제 방식의 공시 경로.

**대응 비형식 개념:** 밖의 관측자가 교역의 결제 방식을 보는 자리. 세관 신고처럼 법이 공시를 강제하는
자리와, SWIFT 메시지처럼 중개자가 기록을 남기는 자리가 있다. 경로는 어느 교역을 보는지와 어느 결제
방식을 따로 가르는지를 선언한다. 알려진 경로가 가르는 칸은 다음과 같다.

| 경로 | 따로 가르는 칸 |
|---|---|
| 칠레 세관 신고 | 선지급 · 신용장 · 후지급 · 그 밖. 추심을 어느 칸에 두는지는 서 있지 않다 |
| SWIFT MT700 · MT400 | 신용장 · 추심. 자료에 품목 축이 없다 |
| 미국 FFIEC 009 | 신용장. 청구권의 잔액이다 |
| 한국 외환 통계 | 신용장 · 추심 · 그 밖. 송금 칸에 선지급과 후지급이 섞인다 |
| 세계은행 기업조사 | 선지급. 나라 쌍과 품목을 가르지 않는다 |

**이 정의가 배제하는 사례:**
IMF 와 BAFT 가 2009년에 은행들을 설문해 얻은 은행 개입 교역의 비중이, 미국 은행의 청구권과 SWIFT
자료로 잰 비중보다 훨씬 컸다(Niepmann · Schmidt-Eisenlohr 2014). 경로 명세는 경로가 따로 가르는
칸만 선언하므로, 칸은 맞게 가르면서 값이 치우친 경로를 걸러 내지 못한다. 값의 정확성은 이
프로젝트가 아니라 실제 자료를 다루는 재유입처의 몫이다.

**기각한 대체 정의:**
관측자로 색인하는 안. 관측자마다 닿는 기록이 다르다는 것만 말할 뿐 무엇을 보는지를 정하지 못한다.
관측자가 보는 것은 그가 닿는 경로의 합이다.
경로마다 값을 담는 안. 관측층은 값을 담지 않는다(L-14).
-/
-- DD:CF-662
structure PaymentMethodChannel (Country Commodity : Type) where
  /-- 보내는 나라와 받는 나라와 품목의 교역을 이 경로가 보는가. -/
  covers : Country → Country → Commodity → Bool
  /-- 이 경로가 그 결제 방식을 따로 가르는가. -/
  resolves : TradePaymentMethod → Bool

/--
아무 교역도 보지 않는 경로. witness 이며 소스 없음의 기본값이다(A-3, L-14).

**대응 비형식 개념:** 결제 방식을 공시하는 자리가 없는 교역. 대부분의 나라 쌍이 그렇다.

**이 정의가 배제하는 사례:**
칠레와 터키와 콜롬비아에는 교역 거래 전량을 덮으며 결제 정보를 가진 세관 자료가 있다(Ma ·
Schmidt-Eisenlohr 2023). 그런 경로가 있는 교역에 이 기본값을 쓰면 있는 소스를 없다고 적게 된다.

**기각한 대체 정의:**
경로가 없는 교역을 답의 타입에서 따로 가르는 안. 답의 타입은 고정되어 있고, 판정 불가의 까닭이
이미 소스 없음을 든다.
-/
-- DD:CF-662
def PaymentMethodChannel.noSource {Country Commodity : Type} :
    PaymentMethodChannel Country Commodity where
  covers := fun _ _ _ => false
  resolves := fun _ => false

/--
공시 경로의 판독으로 결제 방식별 몫의 변화를 낸다.

**대응 비형식 개념:** 한 경로가 보는 교역에서 두 시점의 총액과 방식별 가치를 읽어 CQ-fin-1 의 답을
조립한다. 경로가 그 교역을 보지 않으면 소스 없음으로, 앞 시점의 총액이 영이면 교역이 없었음으로, 뒤
시점의 총액이 영이면 교역이 사라짐으로 답한다. 그 밖에는 방식마다, 경로가 그 방식을 가르면 몫의
감소를 판정하고 가르지 못하면 소스 없음으로 접는다.

결정을 돕는 대응은 다음과 같다. 신용장의 몫이 줄면 은행의 신용장 공급 충격과 양립한다
(Niepmann · Schmidt-Eisenlohr 2017). 신용장의 몫이 늘면 상대방 위험의 상승과 양립하며, 미국 은행의
교역금융 청구권이 1998년과 2008년에 정점을 찍었다(Niepmann · Schmidt-Eisenlohr 2014). 선지급
거래가 줄면 수입자의 유동성 충격과 양립한다(Antràs · Foley 2015). 금융 위기가 난 나라의 기업이
금융하던 방식은 몫이 준다(Schmidt-Eisenlohr 2012).

**이 정의가 배제하는 사례:**
2008-09년 위기에 국가 자료로는 신용장의 가치가 교역보다 더 줄었는데, 설문은 후지급에서 은행이
개입하는 결제로 옮겨 갔다고 답했다(CGFS 50). 경로 하나의 판독만으로 답을 조립하므로 두 경로가 다른
방향을 가리키는 경우를 한 답에 담지 못한다.

**기각한 대체 정의:**
방식별 가치의 합을 총액으로 쓰는 안. 경로가 방식 일부를 가르지 못해도 총액은 내므로 그런 경로의
답이 서지 않는다.
여러 경로를 한 번에 받아 합치는 안. 경로마다 칸이 달라 합치는 규칙이 판정을 요구한다. 경로 하나를
받는 조립으로 두고 합치는 일은 뒤로 미룬다.
-/
-- DD:CF-662
def paymentMethodShareChangeFrom {Time Country Commodity Amount : Type}
    (ch : PaymentMethodChannel Country Commodity) (a : ShareArith Amount)
    (value : Country → Country → Commodity → TradePaymentMethod → Time → Amount)
    (total : Country → Country → Commodity → Time → Amount) :
    Country → Country → Commodity → Time → Time →
      PaymentMethodShareChange TradePaymentMethod :=
  fun x y k t₀ t₁ =>
    if !(ch.covers x y k) then .undetermined .noMeasurementSource
    else if a.le (total x y k t₀) a.zero && a.le a.zero (total x y k t₀) then .noTradeAtStart
    else if a.le (total x y k t₁) a.zero && a.le a.zero (total x y k t₁) then .tradeVanished
    else .shares fun m =>
      if ch.resolves m then
        (if shareFell a (value x y k m t₀) (value x y k m t₁) (total x y k t₀) (total x y k t₁)
          then .holds else .fails)
      else .undetermined .noMeasurementSource

/--
`CQ-fin-1` 의 답 자리를 공시 경로 하나의 판독으로 채운다.

**대응 비형식 개념:** 고정된 `CQ-fin-1` 구조물의 답 함수를 위의 조립으로 채운 것. 결제 방식의 타입은
정의층의 열거다.

**이 정의가 배제하는 사례:**
한국의 외환 통계는 송금 칸에 선지급과 후지급을 함께 담는다(CGFS 50). 이 경로를 넣으면 두 방식의
답은 소스 없음으로 접힌다.

**기각한 대체 정의:**
답 함수의 본문을 고정 선언의 파일에 두는 안. 그 파일은 서명을 고정하는 자리이고 아무것도 import 하지
않는다. 채우는 자리를 따로 두어야 고정이 유지된다.
-/
-- DD:CF-662
def tradePaymentCompositionFrom {Time Country Commodity Amount : Type}
    (ch : PaymentMethodChannel Country Commodity) (a : ShareArith Amount)
    (value : Country → Country → Commodity → TradePaymentMethod → Time → Amount)
    (total : Country → Country → Commodity → Time → Amount) :
    CQ.TradePaymentComposition Time Country Commodity TradePaymentMethod where
  answer := paymentMethodShareChangeFrom ch a value total

end CrisisFramework.Observation
