/-
관측층 — 단기 부채 총계의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 수를 쓰지 않는다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 예외),
      T-2(반증 조건), T-4(가정의 명시).

**칸을 넷으로 가른다.** 계약 만기로 자른 총계와 행동 가정으로 자른 총계와 그 둘의 차이가 서로 다른
자료에서 나오고, 그 자료가 공개 공시로 서는가는 그 셋과 또 다른 물음이다. 앞의 셋을 한 칸으로
접으면 셋이 다 참이라는 것이 넷째의 거짓을 덮으며, 그 거짓이 이 파일의 산출이다.

**이 파일이 드는 결손은 소스 없음이 아니라 관측자의 위치다.** 감독 규범이 그 세 자료를 요구하므로
자료가 실재하는데, 그 수신자가 감독 당국이어서 밖에서 보는 관측자가 닿지 못한다. 그 둘이 다른
결손이며 앞의 것은 그 수가 어디에도 없다는 뜻이고 뒤의 것은 그 수가 있으나 감독 당국과 은행 사이에만
있다는 뜻이다.

**보유자의 타입을 매개변수로 받는다.** 그 보고가 은행마다 서고 회계층의 단기 부채 총계도 주체마다
서므로 두 자리의 색인이 맞는다. 이 파일에는 수 타입도 수치 리터럴도 없다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

namespace CrisisFramework.Observation

/--
단기 부채 총계의 공시 경로.

**대응 비형식 개념:** 어느 자료가 한 주체의 단기 부채 총계를 읽을 재료를 내는가. 그 총계를 자르는
축이 계약 만기와 행동 가정으로 갈리고 그 둘의 차이가 또 다른 자료에서 나오므로, 경로가 그 셋을
가르는지를 칸으로 받고 그 자료가 공개 공시로 서는가를 넷째 칸으로 받는다.

**이 정의가 배제하는 사례:**
특정 만기가 없는 수단의 잔여. 감독 규범이 그 수단을 따로 보고하게 하고 그 세부를 함께 들게 하면서
만기가 언제 오는지에 대해 어떤 가정도 적용하지 않는다고 적으므로(바젤 III LCR 제178절), 계약 만기로
자른 총계가 전량을 덮지 않고 그 수단이 구간 밖에 따로 선다. 이 구조의 칸은 총계를 내는가만 받으므로
그 잔여를 담지 않으며, 그 총계를 쓰는 쪽이 잔여를 함께 읽어야 한다는 것도 담지 않는다.
조달처: E-49 §8-3 「특정 만기가 없는 수단은 따로 보고하고 그 수단의 세부를 함께 들며, 만기가 언제
오는지에 대해 어떤 가정도 적용하지 않는다」

**구간의 수를 이 구조가 들지 않는다.** 감독 규범이 서식과 요구되는 시점 구간을 각 관할권이 정하게
하고 가능한 구간의 예시를 열 넘게 드므로 그 수가 관할권마다 다르며, 관측층이 값을 담지 않으므로 그
수가 칸이 아니다. 한 이름이 관할권마다 다른 분할을 가리키는 그 결손은 구멍으로 등재되어 있다.

**측정 대응을 등록하지 않는다.** 용어집의 소스 표지가 규제 공시와 은행 감독 보고를 이미 다른 항으로
가르고 있으므로 측정 대응을 등록하면 그 표지가 넷째 칸이 드는 것을 함께 들어 전사가 되며, 등록하지
않으면 그 칸이 유일한 자리다. 긴급 조달의 등재가 측정 대응을 붙이지 않은 것이 그 선례다.

**기각한 대체 정의:**
앞의 셋을 한 칸으로 접어 자료가 서는가만 받는 안. 셋이 다 참이므로 접으면 그 참이 넷째 칸의 거짓을
덮으며, 긴급 조달의 공시 경로가 한 칸으로 두면 한쪽의 소스가 다른 쪽의 결손을 덮는다는 사유로 칸을
둘로 가른 것이 같은 자리에 걸린다. 넷째 칸을 보유자로 색인하는 안도 기각했다. 그 자료가 공개 공시로
서는가는 보고 제도의 성질이고 은행의 성질이 아니므로, 색인하면 한 은행의 보고가 공개이고 다른 은행의
보고가 공개가 아닌 구조를 허용하는데 규범이 그 가름의 근거를 주지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-1745
structure MaturityMismatchChannel (Party : Type) where
  /-- 이 경로가 그 주체의 계약 만기로 자른 총계를 내는가. 잔존 계약 만기로 구간에 배정한 유입과
      유출의 격차가 그것이다. -/
  coversContractualMaturityTotal : Party → Bool
  /-- 이 경로가 그 주체의 행동 가정으로 자른 총계를 내는가. 계속기업 가정 아래의 자체 만기 불일치
      분석이 그것이다. -/
  coversBehaviouralMaturityTotal : Party → Bool
  /-- 이 경로가 그 두 총계의 차이와 그 가정이 계약 조항과 다른 까닭을 내는가. -/
  coversAssumptionDivergence : Party → Bool
  /-- 이 경로의 자료가 공개 공시로 서는가. 밖에서 보는 관측자가 그 자료에 닿는가가 그것이다. -/
  standsAsPublicDisclosure : Bool

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `MaturityMismatchChannel` 이 비어 있지 않음을 보인다. 어느 주체의 총계도
내지 않고 공개 공시로도 서지 않는 경로다.
-/
-- DD:CF-31
def MaturityMismatchChannel.noSource {Party : Type} : MaturityMismatchChannel Party where
  coversContractualMaturityTotal := fun _ => false
  coversBehaviouralMaturityTotal := fun _ => false
  coversAssumptionDivergence := fun _ => false
  standsAsPublicDisclosure := false

/--
감독 규범의 계약 만기 불일치 보고를 단기 부채 총계의 경로로 읽은 것.

**대응 비형식 개념:** 감독 규범이 유동성 모니터링 도구로 둔 계약 만기 불일치 보고를 단기 부채 총계를
읽는 경로로 세운 것. 그 보고가 잔존 계약 만기로 구간을 배정한 격차를 내고, 은행에게 계속기업 가정
아래의 자체 분석을 수행하여 감독 당국과 공유하게 하며, 적용한 가정이 계약 조항과 다른 까닭을 설명할
수 있게 한다(바젤 III LCR 제177절·제186절·제187절).

**앞의 세 칸이 참이고 넷째 칸이 거짓인 것이 이 선언의 산출이다.** 자료가 실재하면서 밖의 관측자가
닿지 못하는 자리이며, 아무것도 내지 않는 경로가 비어 있지 않음을 보이는 witness 와 값이 달라 드는
것도 다르다. 앞은 구조가 비어 있지 않음을 보이고 이것은 실재하는 보고가 셋을 내면서 넷째를 내지
못함을 보인다.

**이 정의가 배제하는 사례:**
구간의 수와 경계를 관할권이 정하는 것. 감독 규범이 각 관할권의 감독 당국에게 서식과 요구되는 시점
구간을 정하게 하고 익일물에서 5년 초과까지 열 넘는 예시만 드므로(바젤 III LCR 제178절), 이 경로가
내는 총계의 구간이 관할권마다 다르다. 이 선언은 총계를 내는가만 받으므로 그 구간의 수를 담지 않으며,
두 관할권의 같은 이름 총계가 같은 것을 세는지도 담지 않는다.
조달처: E-49 §8-2 「각 관할권의 감독 당국이 서식과 요구되는 시점 구간을 정한다」

**기각한 대체 정의:**
넷째 칸을 참으로 두는 안. 그 보고가 규범에 적혀 있으므로 공개된 것으로 보이나, 규범이 은행이 가정을
담지 않은 원자료를 감독 당국에 제공하는 것으로 두고 자체 분석을 감독 당국과 공유하여 논의하는 것으로
두므로(바젤 III LCR 제184절·제186절), 참으로 두면 감독 보고를 공개 공시로 읽었다고 주장하게 된다. 이 경로를 세우지 않고 아무것도
내지 않는 경로 하나로 갈음하는 안도 기각했다. 그 경로는 구조가 비어 있지 않음을 보이는 자리여서
실재하는 보고를 들지 않으므로, 갈음하면 실재하는 보고가 셋을 내면서도 넷째를 내지 못한다는 사실이
어디에도 남지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-1743
def supervisoryMaturityMismatchReportChannel {Party : Type} : MaturityMismatchChannel Party where
  coversContractualMaturityTotal := fun _ => true
  coversBehaviouralMaturityTotal := fun _ => true
  coversAssumptionDivergence := fun _ => true
  standsAsPublicDisclosure := false

/--
감독 보고 경로는 세 총계를 내면서 공개 공시로 서지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
감독 규범이 그 세 자료 가운데 하나를 요구하지 않거나, 그 자료를 감독 당국이 아니라 시장에 내게
해야 한다. 규범이 셋을 모두 요구하면서 수신자를 감독 당국으로 두므로, 이 명제가 거짓이면 그 요구나
그 수신자 가운데 하나를 잘못 읽은 것이다.

**가정을 두지 않는다.**
-/
-- DD:CF-1743
theorem supervisoryMaturityMismatchReportChannel_not_public {Party : Type} :
    (∀ p : Party,
      (supervisoryMaturityMismatchReportChannel (Party := Party)).coversContractualMaturityTotal p = true) ∧
    (∀ p : Party,
      (supervisoryMaturityMismatchReportChannel (Party := Party)).coversBehaviouralMaturityTotal p = true) ∧
    (∀ p : Party,
      (supervisoryMaturityMismatchReportChannel (Party := Party)).coversAssumptionDivergence p = true) ∧
    (supervisoryMaturityMismatchReportChannel (Party := Party)).standsAsPublicDisclosure = false := by
  exact ⟨fun _ => rfl, fun _ => rfl, fun _ => rfl, rfl⟩

end CrisisFramework.Observation
