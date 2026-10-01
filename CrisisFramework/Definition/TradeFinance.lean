/-
정의층 — 교역 금융의 대응과 통화

규율: L-10(정의층은 구체 수 타입을 쓰지 않는다), L-13(시점 인덱스), C-3(판정은 계산으로 낸다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), T-2(반증 조건).

청구권과 교역을 잇는 대응을 청구권 타입 밖에 둔다. 한 교역이 청구권 여럿을 낳고 한 청구권이 교역
여럿을 금융하므로 대응이 다대다인데, 필드는 함수이고 함수는 하나만 내므로 필드로는 담기지 않는다.

교역의 결제 조건은 그 교역 건에 붙박이며 시점에 따라 변하지 않는다. 시점에 따라 변하는 것은 그
조건으로 치러진 교역의 가치이고, 그 값은 관측층의 공시 경로가 시점을 매개변수로 받아 든다. 결제
방식이 같은 사유로 시점 인덱스를 갖지 않는 것과 같은 자리다(L-13).

이 파일은 금액을 담지 않는다. 통화의 동일성만 묻고 금액은 관측층이 매개변수로 받는다(L-10).

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/
import CrisisFramework.Definition.TradePayment

namespace CrisisFramework.Definition

/--
교역 한 건의 결제 조건.

**대응 비형식 개념:** 한 건의 교역이 어느 방식으로 치러지고 상업송장이 어느 통화로 발행되는가. 둘을
한 대상에 묶는 까닭은 신용장 칸에서 그 둘이 제도로 묶이기 때문이다. 상업송장은 신용장과 같은 통화로
발행해야 한다(UCP 600 제18조 a). 다른 칸에서는 둘이 갈리며, 갈리는 것이 그 칸의 정상이다.

**이 정의가 배제하는 사례:**
한 선적을 선지급 절반과 신용장 절반으로 치른 조건(Antràs · Foley 2015). 이 구조는 방식을 하나만
들므로 섞인 조건이 `TradePaymentMethod` 의 분류 규칙을 거쳐 한 칸으로 들어오고, 그 규칙이 보낸 칸이
신용장이 아니면 통화 일치가 걸리지 않는다. 절반을 덮던 신용장이 통화에서도 보이지 않는다.
2022년 3월 러시아가 이른바 불우호국에 가스 대금의 루블 결제를 요구한 것. 송장 통화가 계약이 사는
동안 바뀌었는데 이 구조는 한 건의 조건을 고정으로 두므로 그 변경을 담지 못한다.

**기각한 대체 정의:**
송장 통화를 `TradePaymentMethod` 의 생성자 인자로 두는 안. 방식은 칸의 이름이고 통화는 그 건의
속성이라 색인이 다르다(G-1).
송장 통화를 시점 족으로 여는 안. 한 건의 송장은 한 번 발행되고, 시점에 따라 변하는 것은 그 조건으로
치러진 교역의 가치다.
-/
-- DD:CF-692
structure TradeTerms (Currency : Type) where
  /-- 이 교역이 치러지는 방식. -/
  method : TradePaymentMethod
  /-- 상업송장이 발행된 통화. -/
  invoiceCurrency : Currency

/-- witness (A-3). -/
-- DD:CF-31
def TradeTerms.trivial : TradeTerms Unit where
  method := .otherTerms
  invoiceCurrency := ()

/--
청구권과 교역을 잇는 대응.

**대응 비형식 개념:** 어느 청구권이 어느 교역을 금융하는가. 청구권 타입 밖에 둔다. 한 교역이 청구권
여럿을 낳고(개설은행의 확약 · 확인은행의 보증 · 수출자의 운전자금 대출 · 수입자의 약속어음), 한
청구권이 교역 여럿을 금융한다(회전 신용장 · 운전자금 한도). 대응이 다대다이므로 어느 쪽의 필드로도
담기지 않는다. 정의역을 교역 당사자 쌍으로 묶지 않으므로 당사자 쌍 밖에 선 금융도 이어진다.

**이 정의가 배제하는 사례:**
선지급으로 치른 교역에서 수입자가 선적 전에 낼 돈을 은행에서 빌린 경우. 그 대출은 통화가 붙은 금전
청구권이되 교역 당사자 쌍 밖에 선다. 이 대응은 당사자 쌍을 묻지 않으므로 그 대출을 이을 수 있으나,
어느 대출이 어느 선적을 금융했는지는 돈이 대체 가능해서 차입자 단위에서 끊긴다
(Casas · Meleshchuk · Timmer 2022). 이 구조는 그 끊김을 담지 않고 참과 거짓만 낸다.

**기각한 대체 정의:**
청구권에 「이 청구권이 금융하는 교역」 필드를 더하는 안. 다대일까지만 담기고 고정한 청구권 타입을
건드린다.
교역에 「이 교역을 금융하는 청구권」 필드를 더하는 안. 방향만 뒤집었을 뿐 같은 자리에서 막힌다.
-/
-- DD:CF-691
structure TradeFinanceLink (ClaimIx TradeIx : Type) where
  /-- 이 청구권이 그 교역을 금융하는가. 판정은 계산으로 낸다(C-3). -/
  finances : ClaimIx → TradeIx → Bool

/-- witness (A-3). 아무것도 잇지 않는 대응이며 대응이 서지 않는 자리의 기본값이다. -/
-- DD:CF-31
def TradeFinanceLink.empty {ClaimIx TradeIx : Type} :
    TradeFinanceLink ClaimIx TradeIx where
  finances := fun _ _ => false

/--
신용장 칸의 통화 일치.

**대응 비형식 개념:** 한 청구권과 한 교역을 받아, 그 교역이 신용장으로 치러지고 그 청구권이 그 교역을
금융한다면 둘의 통화가 같은가를 묻는다. 신용장이 아니거나 그 청구권이 그 교역을 금융하지 않으면
참으로 둔다. UCP 600 제18조 (a) 가 상업송장을 신용장과 같은 통화로 발행하게 하므로, 그 칸에서는
송장의 통화와 청구권의 통화가 갈리지 않는다.

**이 정의가 배제하는 사례:**
후지급으로 치른 교역에서 수출자가 달러로 운전자금을 빌려 유로 송장의 선적을 금융한 경우. 교역의 표시
통화와 교역 금융의 조달 통화가 갈리는 것이 그 칸의 정상이다(Bruno · Kim · Shin 2018). 이 술어는
신용장 칸 밖에서 참을 내므로 그 갈림을 가르지 못한다. 가르지 못하는 것이 이 술어의 범위이지 결손이
아니며, 그 갈림을 재는 것은 CQ-fin-2 의 답이 맡는다.

**기각한 대체 정의:**
통화 일치를 모든 결제 방식에 거는 안. 후지급과 선지급에서는 성립하지 않으며, 성립하지 않는 것이 이
프로젝트가 재려는 바로 그 현상이다.
통화 일치를 청구권의 적격 조건(`Claim.wellFormed`)에 넣는 안. 그 조건은 청구권 하나만 보고 교역을
보지 않는다.
-/
-- DD:CF-693
def lcCurrencyAgrees {Currency : Type} [DecidableEq Currency]
    (terms : TradeTerms Currency) (claimCurrency : Currency) (financesThis : Bool) : Bool :=
  match terms.method with
  | .letterOfCredit => !financesThis || claimCurrency == terms.invoiceCurrency
  | _ => true

/--
한 청구권이 송장 통화가 다른 두 신용장 교역을 함께 금융할 수 없다.

**대응 비형식 개념:** 청구권 하나는 단일 통화로 표시된다. 신용장 칸에서는 교역의 송장 통화와 그것을
금융한 청구권의 통화가 같다(UCP 600 제18조 a). 둘을 이으면 한 청구권이 신용장 교역 둘을 함께 금융할
때 그 둘의 송장 통화가 같아야 한다. **대응이 다대다이되 신용장 칸에서는 통화가 그 다수를 묶는다.**

**이 명제가 거짓이려면 무엇이 관측되어야 하는가 (T-2):** 한 청구권이 송장 통화가 다른 두 신용장
교역을 함께 금융하는 사례. 한 신용장이 여러 통화로 이용될 수 있거나, 한 확약이 통화가 다른 선적
둘을 덮는 경우가 그 후보다. SWIFT MT 700 의 금액 필드(32B)가 통화 코드를 하나만 받으므로 메시지 한
건은 반례가 되지 못하며, 반례는 한 청구권이 메시지 여럿에 걸치는 자리에서 찾아야 한다.

**가정의 자리 (T-4):** 통화 일치는 전제로 받는다. 제도가 보증하는 것이지 이 형식층이 증명할 수 있는
것이 아니며, 전제를 진술문에 명시해 두면 그것이 깨지는 자리가 그대로 드러난다.
-/
-- DD:CF-693
theorem lcTradesSharingClaim_sameInvoiceCurrency
    {ClaimIx TradeIx Currency : Type} [DecidableEq Currency]
    (terms : TradeIx → TradeTerms Currency) (claimCurrency : ClaimIx → Currency)
    (link : TradeFinanceLink ClaimIx TradeIx)
    (c : ClaimIx) (t₁ t₂ : TradeIx)
    (h₁ : (terms t₁).method = TradePaymentMethod.letterOfCredit)
    (h₂ : (terms t₂).method = TradePaymentMethod.letterOfCredit)
    (f₁ : link.finances c t₁ = true)
    (f₂ : link.finances c t₂ = true)
    (a₁ : lcCurrencyAgrees (terms t₁) (claimCurrency c) (link.finances c t₁) = true)
    (a₂ : lcCurrencyAgrees (terms t₂) (claimCurrency c) (link.finances c t₂) = true) :
    (terms t₁).invoiceCurrency = (terms t₂).invoiceCurrency := by
  -- 통화 일치를 교역마다 한 번씩 꺼내 쓰므로 그 꺼내는 일을 보조 사실로 묶는다. 신용장 칸이고 그
  -- 청구권이 그 교역을 금융하면 `lcCurrencyAgrees` 의 갈래가 하나로 접히고, 남는 것은 청구권의
  -- 통화와 송장 통화를 맞대는 `==` 판정이다. `Bool` 의 값을 갈라 접으므로 배중률을 거치지 않으며
  -- 기준선이 오르지 않는다(A-6). 두 교역이 모두 청구권의 통화와 같으므로 대칭과 추이로 잇는다.
  have key : ∀ t : TradeIx, (terms t).method = TradePaymentMethod.letterOfCredit →
      link.finances c t = true →
      lcCurrencyAgrees (terms t) (claimCurrency c) (link.finances c t) = true →
      claimCurrency c = (terms t).invoiceCurrency := by
    intro t hm hf ha
    rw [hf] at ha
    unfold lcCurrencyAgrees at ha
    rw [hm] at ha
    simp only [Bool.not_true, Bool.false_or, beq_iff_eq] at ha
    exact ha
  exact (key t₁ h₁ f₁ a₁).symm.trans (key t₂ h₂ f₂ a₂)

end CrisisFramework.Definition
