/-
관측층 — 통화별 담보 여력의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(무차원), L-9(import 방향은
      단방향), A-3(witness 의무), A-8(논리 결합마다 홀로 값을 가르는 자리의 증거),
      C-3(판정은 계산으로 낸다), D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면),
      D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시).

**이 파일이 세우는 것은 회계층의 통화별 담보 여력이 어느 공시에서 읽히는가의 명세다.** 그 값이 담보로
쓸 수 있는 보유 자산을 그 기재값이 서는 통화로 가르는 데서 서므로, 그 가름을 내는 경로가 있는가와 그
가름이 통화 전량을 덮는가와 그 공시가 누구에게 가는가를 칸으로 둔다.

**그 가름이 감독 당국에게만 가고 문턱을 넘는 통화에만 선다.** 유동성 감시 지표가 가용 미부담 자산을
유의한 통화별로 가르게 하고 그 수취인이 감독 당국이며, 공개 공시 서식은 고유동성자산을 한 행으로 둔다.

**값을 담지 않는다.** 금액도 통화의 구성비도 이 파일에 서지 않고 그것을 내는 경로가 있는가만 선다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.AssetCompositionChannel

namespace CrisisFramework.Observation

/--
통화별 담보 여력의 공시 경로.

**대응 비형식 개념:** 한 공시가 담보로 쓸 수 있는 보유 자산을 그 기재값이 서는 통화로 가르는가와, 그
가름이 문턱 아래의 통화까지 덮는가와, 그 공시가 누구에게 가는가.

**이 정의가 배제하는 사례:**
계상의 조건으로 그 담보를 환가하는 운영 절차를 요구하는 감독 지표. 그 지표가 가용 미부담 자산을 계상하려면
그 담보를 환가하는 운영 절차가 이미 서 있어야 한다고 정하므로, 그 절차가 서지 않은 자산은 들고 있어도 그
보고에서 빠진다(바젤 통합 프레임워크). 이 구조는 통화의 가름이 서는가만 칸으로 두고 그 계상의 조건을 받지 않으므로, 회계층의
통화별 담보 여력이 세는 몫과 그 지표가 세는 몫이 갈리는 자리가 이 칸들에 서지 않는다.
조달처: E-56 §2-7 「다만 계상하려면 그 담보를 환가하는 운영 절차가 이미 서 있어야 한다」

**기각한 대체 정의:**
같은 층의 자산 구성 경로에 통화의 칸을 더하는 안. 그 구조체가 같은 두 공시를 이미 경로로 들지만 그 축이
범주의 분할 체제이고 통화는 그 체제 넷에 들지 않으며, 칸을 더하면 그 구조체의 경로 전량의 뜻이 함께
바뀐다. 외부 자산의 몫을 보는 공시 경로에 통화의 칸을 더하는 안도 기각했다. 그 경로의 판정이 자산의
식별과 보유자별 몫을 함께 요구하는데 통화로 가르는 감독 지표는 금액과 유형과 소재를 보고하게 할 뿐 자산을
하나씩 식별하게 하지 않는다. 수취인의 칸을 두지 않는 안도 기각했다. 통화의 가름이 감독 당국에게만 가므로 그 칸이 없으면 공시를 읽는 쪽이 그 가름에 닿지 못한다는
결손이 구조에서 사라지며, 같은 축을 보는 두 경로가 수취인에서 갈리는 자리를 같은 층의 자산 구성 경로가
이미 그 칸으로 받는다.

**값을 담지 않는다.**
-/
-- DD:CF-4641
structure CollateralCurrencyChannel where
  /-- 담보로 쓸 수 있는 보유 자산을 그 기재값이 서는 통화로 가르는가. -/
  splitsByCurrency : Bool
  /-- 그 가름이 문턱 아래의 통화까지 덮는가. -/
  coversEveryCurrency : Bool
  /-- 그 공시가 누구에게 가는가. -/
  recipient : DisclosureRecipient

/--
witness (A-3).

**무엇을 증거하는가.** `CollateralCurrencyChannel` 이 비어 있지 않다. 통화로 가르지 않고 일반 관측자에게
가는 경로이며 그 값이 무엇인지는 우연이다.
-/
-- DD:CF-4641
def CollateralCurrencyChannel.noSource : CollateralCurrencyChannel where
  splitsByCurrency := false
  coversEveryCurrency := false
  recipient := DisclosureRecipient.publicReader

/--
그 경로가 통화 전량에서 통화별 담보 여력을 가르는가.

**대응 비형식 개념:** 회계층의 통화별 담보 여력이 모든 통화에서 재어지려면 그 경로가 통화로 가르고 그
가름이 문턱 아래의 통화까지 덮어야 한다. 한쪽만 서면 문턱 아래의 통화에서 그 값이 서지 않는다.

**이 정의가 배제하는 사례:**
유의한 통화의 문턱을 관련 총액의 몫으로 둔 감독 지표의 가름. 그 지표가 그 통화의 가용 미부담 담보가 관련
총액의 5% 이상일 때만 그 통화를 따로 가르게 하므로, 그 문턱 아래의 통화는 총액에 섞여 통화별로 서지
않는다(바젤 통합 프레임워크). 이 판정은 그 문턱의 값을 받지 않고 가름이 통화 전량을 덮는가만 묻는다.
조달처: E-56 §2-7 「그 통화의 가용 미부담 담보가 관련 총액의 5% 이상인 것으로 둔다」

**기각한 대체 정의:**
통화로 가르는가만 보는 안. 문턱을 넘는 통화만 가르는 경로가 통화별 담보 여력을 내는 것으로 세어져, 문턱
아래의 통화에서 그 값이 서지 않는다는 결손이 판정에서 사라진다. 수취인을 그 판정의 결합에 넣는 안도
기각했다. 무엇을 가르는가와 누가 받는가가 다른 축이어서, 결합에 넣으면 감독 당국이 전량을 받는 경로와
아무것도 가르지 않는 경로가 같은 값으로 접힌다.

**값을 담지 않는다.**
-/
-- DD:CF-4641
def CollateralCurrencyChannel.answersEveryCurrency (ch : CollateralCurrencyChannel) : Bool :=
  ch.splitsByCurrency && ch.coversEveryCurrency

/--
가용 미부담 자산의 감독 지표를 통화별 담보 여력의 경로로 읽은 것.

**대응 비형식 개념:** 감독 지표가 이차시장에서 담보가 될 수 있는 가용 미부담 자산과 중앙은행 상시 제도에
적격인 것을 따로 보고하게 하고, 총액에 더해 유의한 통화별로 가르게 하며 그 보고가 감독 당국에 가는 경로.
같은 지표를 자산 구성의 경로로 읽은 선언이 같은 층에 따로 서고, 이 선언은 그 지표의 통화의 가름을 읽는다.

**이 정의가 배제하는 사례:**
이미 수취됐으나 쓰이지 않은 담보를 그 지표가 계상하는 자리. 그 지표가 중앙은행 상시 제도에 적격인 것을
적게 하면서 이미 수취됐으나 쓰이지 않은 담보를 포함하므로, 그 계상이 그 주체가 보유한 몫에 한정되지
않는다(바젤 통합 프레임워크). 이 경로는 그 가름이 서는가만 들고 그 계상의 범위를 받지 않아, 회계층의 통화별 담보 여력이 보유한
몫만 모으는 것과 그 지표의 총액이 갈리는 자리가 이 칸에 서지 않는다.
조달처: E-56 §2-7 「중앙은행 상시 제도에 적격인 것도 같은 꼴로 적게 하며 이미 수취됐으나 쓰이지 않은 담보를」

**기각한 대체 정의:**
그 지표가 통화 전량을 가른다고 두는 안. 유의성의 문턱을 넘는 통화만 따로 가르고 나머지는 총액에 섞으므로,
그렇게 두면 문턱 아래 통화의 담보 여력이 그 지표에서 읽히는 것으로 세어진다.

**값을 담지 않는다.**
-/
-- DD:CF-4641
def unencumberedAssetCurrencyChannel : CollateralCurrencyChannel where
  splitsByCurrency := true
  coversEveryCurrency := false
  recipient := DisclosureRecipient.supervisor

/--
유동성 비율의 공시 서식을 통화별 담보 여력의 경로로 읽은 것.

**대응 비형식 개념:** 공시의 장이 유동성 비율의 서식을 고정 형식으로 두고 그 첫 행을 고유동성자산 총계
하나로 두는 경로. 그 서식이 일반 관측자에게 가며 자산 쪽을 통화로 가르지 않는다. 같은 서식을 자산 구성의
경로로 읽은 선언이 같은 층에 따로 서고, 이 선언은 그 서식의 통화의 가름을 읽는다.

**이 정의가 배제하는 사례:**
그 서식의 동반 서술이 고유동성자산의 구성과 통화 불일치를 논의하는 자리. 그 요건이 논의할 수 있는 것의
예로 그 구성과 통화 불일치를 들지만 예시여서 그 공시가 의무가 아니므로, 이 경로는 그 서술이 통화의 가름을
내는 것으로 세지 않는다(바젤 통합 프레임워크).
조달처: E-56 §2-3 「논의할 수 있는 것의 예로 비율 결과의 주된 동인과 기간 내 변화와」

**기각한 대체 정의:**
그 동반 서술이 통화로 가른다고 두는 안. 그 요건의 문면이 논의할 수 있는 것의 예시여서 은행마다 그 서술을
두지 않을 수 있으므로, 그렇게 두면 공시되지 않을 수 있는 가름이 공시되는 것으로 세어진다.

**값을 담지 않는다.**
-/
-- DD:CF-4641
def liquidityRatioCurrencyChannel : CollateralCurrencyChannel where
  splitsByCurrency := false
  coversEveryCurrency := false
  recipient := DisclosureRecipient.publicReader

/--
서 있는 두 경로가 어느 것도 통화 전량에서 통화별 담보 여력을 가르지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 감독 지표의 보고나 공개 공시 서식 가운데 하나가 담보로
쓸 수 있는 보유 자산을 문턱 없이 통화 전량으로 가르는 것. 그러면 회계층의 통화별 담보 여력이 그 경로에서
모든 통화로 재어진다.

**가정을 두지 않는다.** 두 경로의 칸이 전부 고정값이다.

**T-3 분류:** 기여다. 회계층에 세운 통화별 담보 여력이 어느 공시에서도 통화 전량으로 재어지지 않는다는
소스 없음을 드는 유일한 자리이며, 그 결손이 데이터 공백이 아니라 관측 명세의 결손이다.
-/
-- DD:CF-4641
theorem no_channel_answers_every_currency :
    unencumberedAssetCurrencyChannel.answersEveryCurrency = false
      ∧ liquidityRatioCurrencyChannel.answersEveryCurrency = false := by
  -- 두 경로의 칸이 고정값이어서 논리곱이 거짓 항을 품으므로 정의적 동등으로 닫는다.
  exact ⟨rfl, rfl⟩

/--
통화로 가르는 경로의 수취인은 감독 당국이고 일반 관측자에게 가는 경로는 통화로 가르지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 일반 관측자에게 가는 공시가 담보로 쓸 수 있는 보유
자산을 통화로 가르는 것. 그러면 문턱을 넘는 통화의 담보 여력이 공시를 읽는 쪽에서도 재어진다.

**가정을 두지 않는다.** 두 경로의 칸이 전부 고정값이다.

**T-3 분류:** 기여다. 통화의 가름이 서는 자리와 그것을 받는 쪽이 갈린다는 것을 드는 유일한 자리이며, 그
결손이 소스 없음이 아니라 관측자의 위치다.
-/
-- DD:CF-4641
theorem currency_split_reaches_only_supervisor :
    unencumberedAssetCurrencyChannel.splitsByCurrency = true
      ∧ unencumberedAssetCurrencyChannel.recipient = DisclosureRecipient.supervisor
      ∧ liquidityRatioCurrencyChannel.splitsByCurrency = false
      ∧ liquidityRatioCurrencyChannel.recipient = DisclosureRecipient.publicReader := by
  -- 네 칸이 전부 고정값이므로 정의적 동등으로 닫는다.
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
통화 전량의 판정이 두 칸을 각각 고정한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 판정이 통화로 가르되 문턱 아래를 덮지 않는 경로나
문턱 아래를 덮되 통화로 가르지 않는 경로에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는
뜻이며, 그러면 문턱 아래의 통화에서 서지 않는 값이 서는 것으로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 판정 반환
함수의 논리 결합마다 홀로 값을 가르는 경로를 증거로 드는 정리를 같은 파일에 두라는 A-8 의 요구를 이
명제가 받는다.
-/
-- DD:CF-4641
theorem answersEveryCurrency_pins_each_conjunct :
    unencumberedAssetCurrencyChannel.answersEveryCurrency = false
      ∧ ({ splitsByCurrency := false, coversEveryCurrency := true,
           recipient := DisclosureRecipient.supervisor } : CollateralCurrencyChannel).answersEveryCurrency
          = false
      ∧ ({ splitsByCurrency := true, coversEveryCurrency := true,
           recipient := DisclosureRecipient.supervisor } : CollateralCurrencyChannel).answersEveryCurrency
          = true := by
  exact ⟨rfl, rfl, rfl⟩

end CrisisFramework.Observation
