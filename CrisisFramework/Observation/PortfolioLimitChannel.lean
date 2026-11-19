/-
관측층 — 포트폴리오 한도의 문턱과 걸림이 읽히는 경로

규율: L-14(값을 담지 않는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), T-2(반증 조건), T-3(분류), A-3(witness),
      A-8(논리 결합의 증거).

**값을 담지 않는다.** 이 파일은 어느 공시 경로가 무엇을 내는지의 명세만 담고 금액도 계수도 담지
않는다. 정의층이 그 한도의 방향과 대상을 담고 회계층이 문턱과 걸림의 판정을 담았으나 그것을 읽는
자리가 관측층에 서지 않았던 것이 이 파일이 받는 결손이다.

**두 물음이 한 칸에 들지 않는다.** 문턱은 값이고 걸림은 판정이어서 그 둘이 다른 소스를 가질 수
있으며, 한 칸에 묶으면 문턱이 공표되지 않는 것과 걸림이 공표되지 않는 것이 같은 결손으로 세어진다.

**규범이 자기 불완전성을 명시하는 것이 이 파일의 산출이다.** 공시가 범주별 문턱을 내면서 주체별로
가르지 않고, 담보 정책 문서가 공표된 목록에 구속되지 않는다고 스스로 적는다. 그래서 두 물음의 답이
측정 소스 없음으로 서는 것이 자료의 결손이 아니라 규범의 성질이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

/--
포트폴리오 한도의 문턱과 걸림의 두 물음의 공시 경로.

**대응 비형식 개념:** 한 주체의 한 시점의 한 대상에 걸린 한도의 문턱이 얼마이고 그 한도가 걸렸는지를
공표 수치에서 읽을 수 있는가. 어느 주체의 어느 한도가 당장 누르고 있는지를 가려 감시 대상으로 올릴지
정하는 데 복무한다.

**이 정의가 배제하는 사례:**
공표된 적격 담보 목록이 그 문턱을 확정한다는 읽기. 중앙은행의 담보 정책 문서가 어떤 증권이나 대출
포트폴리오든 담보로 제공된 것을 어떤 사유로든 언제든 거절할 권리를 유보하고 그 결과로 그 목록에
구속되지 않는다고 스스로 적으므로, 목록을 문턱으로 받으면 그 유보가 담지 않는 자리가 확정된 것으로
읽힌다.
조달처: E-49 §11-2 「공표된 적격 증권 목록에 구속되지 않는다고 적는다」

**기각한 대체 정의:**
문턱의 값과 걸림의 사실을 한 칸으로 묶는 안. 감독 공시가 걸림의 사실을 드는 자리와 문턱의 값을 드는
자리가 갈리므로 그 둘이 다른 소스를 가질 수 있고, 묶으면 어느 쪽이 없어서 답이 서지 않는지가 그 칸에서
읽히지 않는다. 경로마다 관할을 색인으로 받는 안도 기각했다. 관할은 정의층이 그 한도에 이미 붙이는
성질이고 경로의 성질이 아니므로, 경로에 다시 붙이면 같은 축이 두 층에 선다.

**수 체계를 받지 않는다.** 네 칸이 전부 판정이며 수를 들지 않는다.
-/
-- DD:CF-4151
structure PortfolioLimitChannel where
  /-- 그 경로가 문턱의 값을 내는가. -/
  givesThresholdValue : Bool
  /-- 그 경로가 그 한도가 걸렸는지를 내는가. -/
  givesBindingHeld : Bool
  /-- 그 경로가 주체별로 가르는가. 범주별로만 내면 거짓이다. -/
  splitsByEntity : Bool
  /-- 그 경로가 자기 불완전성을 문면으로 적는가. -/
  reservesDiscretion : Bool
  deriving DecidableEq, Repr

/-- witness (A-3). **무엇을 증거하는가.** `PortfolioLimitChannel` 이 비어 있지 않다. 어느 칸도
내지 않는 경로 하나를 든다. -/
-- DD:CF-4151
def PortfolioLimitChannel.noSource : PortfolioLimitChannel where
  givesThresholdValue := false
  givesBindingHeld := false
  splitsByEntity := false
  reservesDiscretion := false

/--
그 경로가 문턱의 값을 주체별로 내는가.

**대응 비형식 개념:** 그 공시를 읽어 한 주체에 걸린 문턱의 값을 적을 수 있는가.

**이 정의가 배제하는 사례:**
범주별 문턱을 내는 공시가 이 물음에 답한다는 읽기. 감독 규범의 유동성 기준이 고유동성자산을 세 단으로
가르고 가중을 범주에 붙이므로 그 값이 범주의 성질이고 주체의 성질이 아니다.
조달처: E-49 §2-1 「적격 RMBS 가 75%, A+ 부터 BBB- 회사채가 50%」

**기각한 대체 정의:**
값을 내는 것만 묻고 주체별로 가르는지는 묻지 않는 안. 그러면 범주별 공시가 이 물음에 답하는 것으로
서고, 어느 주체의 한도가 누르는지를 가리는 데 복무한다는 이 물음의 쓰임이 사라진다.

**수 체계를 받지 않는다.** 두 판정의 곱이며 수를 들지 않는다.
-/
-- DD:CF-4152
def PortfolioLimitChannel.answersThreshold (C : PortfolioLimitChannel) : Bool :=
  C.givesThresholdValue && C.splitsByEntity

/--
그 경로가 걸림의 사실을 주체별로 내는가.

**대응 비형식 개념:** 그 공시를 읽어 한 주체의 한 한도가 걸렸는지를 적을 수 있는가.

**이 정의가 배제하는 사례:**
감독 당국이 그 걸림을 볼 수 있다는 것이 이 물음에 답한다는 읽기. 유동성 규범이 감독 당국이 미조정
기준의 크기를 따로 볼 수 있다고 적으므로 그 관측자가 감독 당국이고 공표 수치의 독자가 아니다.
조달처: E-49 §10-6 「그 요건의 내용은 규범이 정하지 않고 당국에 남긴다」

**기각한 대체 정의:**
걸림을 문턱의 값과 보유량에서 유도하는 안. 그 유도가 회계층의 판정이고 이 층은 그 두 입력이 읽히는지만
묻는데, 유도를 이 층에 두면 값을 담지 않는다는 요구가 깨진다.

**수 체계를 받지 않는다.** 두 판정의 곱이며 수를 들지 않는다.
-/
-- DD:CF-4152
def PortfolioLimitChannel.answersBinding (C : PortfolioLimitChannel) : Bool :=
  C.givesBindingHeld && C.splitsByEntity

/--
감독 규범의 유동성 기준.

**대응 비형식 개념:** 고유동성자산의 단별 상한과 유출률을 범주로 드는 공표된 기준.

**이 정의가 배제하는 사례:**
그 기준이 주체별 문턱을 낸다는 읽기. 그 규범이 구간과 유출률을 관할권이 올릴 수 있다고 적으므로 그
값이 관할권의 성질이고, 한 주체의 값은 그 관할권의 선택을 알아야 서는데 그 선택이 그 기준의 문면에
없다.
조달처: E-49 §9-5 「각 관할권이 자기 관할의 스트레스기 예금자 행동을 담기 위해 더 높은」

**기각한 대체 정의:**
그 기준이 자기 불완전성을 적는다고 두는 안. 그 유보를 적는 것은 중앙은행의 담보 정책 문서이고 이
기준은 그 유보를 적지 않으므로, 그렇게 두면 두 경로가 같은 성질을 가진 것으로 서서 이 파일의 가름이
사라진다.

**수 체계를 받지 않는다.** 네 판정의 리터럴이며 수를 들지 않는다.
-/
-- DD:CF-4153
def supervisoryLiquidityStandard : PortfolioLimitChannel where
  givesThresholdValue := true
  givesBindingHeld := false
  splitsByEntity := false
  reservesDiscretion := false

/--
중앙은행의 담보 정책 문서.

**대응 비형식 개념:** 적격 담보의 범주와 범주별 할인율을 드는 공표된 정책 문면.

**이 정의가 배제하는 사례:**
그 문서가 범주별 할인율을 내므로 문턱의 값을 낸다는 읽기. 그 문서가 어느 개별 증권에든 언제든 추가
할인율을 적용할 권리를 유보하고 이미 인도된 거래의 담보에도 그렇게 한다고 적으므로, 공표된 격자가 그
값을 확정하지 않는다.
조달처: E-49 §2-13 「어느 개별 증권에든 언제든 추가 할인율을 적용할 권리를 유보하며」

**기각한 대체 정의:**
그 문서를 경로로 두지 않는 안. 그러면 자기 불완전성을 명시하는 경로가 이 목록에서 사라지고, 두 물음의
답이 자료의 결손으로 읽혀 규범의 성질이라는 이 파일의 산출이 서지 않는다.

**수 체계를 받지 않는다.** 네 판정의 리터럴이며 수를 들지 않는다.
-/
-- DD:CF-4153
def centralBankCollateralPolicy : PortfolioLimitChannel where
  givesThresholdValue := false
  givesBindingHeld := false
  splitsByEntity := false
  reservesDiscretion := true

/--
포트폴리오 한도를 읽을 수 있는 경로의 열.

**대응 비형식 개념:** 그 한도의 문턱과 걸림을 묻는 자리에서 열어 볼 수 있는 공표된 문면 전량.

**이 정의가 배제하는 사례:**
모형의 출력을 이 열에 넣는 읽기. 한도의 걸림을 내는 모형이 서 있어도 그 출력이 공표 수치가 아니므로,
넣으면 공시 경로와 모형 출력이 한 목록에 섞인다.
조달처: E-49 §0 「둘 다 성문이며 날짜와
발행자가 붙는다」

**기각한 대체 정의:**
관할권마다 열을 따로 두는 안. 두 경로가 같은 네 칸으로 서술되고 그 칸이 관할을 받지 않으므로, 열을
가르면 어느 열에도 없는 경로가 생길 때 그 자리가 어디인지가 서지 않는다.

**수 체계를 받지 않는다.** 두 경로의 열이며 수를 들지 않는다.
-/
-- DD:CF-4153
def portfolioLimitChannels : List PortfolioLimitChannel :=
  [supervisoryLiquidityStandard, centralBankCollateralPolicy]

/--
문턱의 값이 그 열에서 관측되는가.

**대응 비형식 개념:** 그 열의 어느 경로가 문턱의 값을 주체별로 내면 성립하고, 하나도 내지 않으면
측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
어느 경로가 값을 내기만 하면 성립한다고 두는 읽기. 감독 규범이 범주별 값을 내므로 그렇게 두면 이
물음이 성립으로 서는데, 그 값에서 한 주체의 문턱이 유도되지 않는다.
조달처: E-49 §9-5 「각 관할권이 자기 관할의 스트레스기 예금자 행동을 담기 위해 더 높은」

**기각한 대체 정의:**
답하는 경로의 수를 내는 안. 이 층이 담는 것은 사상의 명세이고 계수가 아니므로, 수를 내면 값을 담지
않는다는 요구가 깨진다.

**수 체계를 받지 않는다.** 판정과 까닭을 내며 수를 들지 않는다.
-/
-- DD:CF-4154
def thresholdValueObserved (Cs : List PortfolioLimitChannel) : ObservedTruth :=
  if Cs.any PortfolioLimitChannel.answersThreshold then .holds
  else .undetermined .noMeasurementSource

/--
걸림의 사실이 그 열에서 관측되는가.

**대응 비형식 개념:** 그 열의 어느 경로가 걸림의 사실을 주체별로 내면 성립하고, 하나도 내지 않으면
측정 소스 없음을 낸다.

**이 정의가 배제하는 사례:**
감독 당국이 볼 수 있으므로 성립한다고 두는 읽기. 그 관측자가 공표 수치의 독자가 아니므로 이 층의
물음에 답하지 않는다.
조달처: E-49 §10-6 「그 요건의 내용은 규범이 정하지 않고 당국에 남긴다」

**기각한 대체 정의:**
문턱이 관측되지 않으면 걸림도 관측되지 않는다고 유도하는 안. 걸림의 사실을 직접 공표하는 경로가 서면
문턱 없이도 이 물음이 성립하므로, 유도로 두면 그 경로가 설 자리가 사라진다.

**수 체계를 받지 않는다.** 판정과 까닭을 내며 수를 들지 않는다.
-/
-- DD:CF-4154
def bindingHeldObserved (Cs : List PortfolioLimitChannel) : ObservedTruth :=
  if Cs.any PortfolioLimitChannel.answersBinding then .holds
  else .undetermined .noMeasurementSource

/--
문턱의 값이 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 열의 어느 경로가 문턱의 값을 주체별로 내는 것이 관측되어야 한다. 그 관측은 공표된 문면 하나가
범주를 넘어 주체까지 내려간다는 뜻이며, 그러면 그 한도의 문턱이 공시에서 확정된다.

**형식층 배정:** 관측층. 판정과 까닭만 쓰고 수를 쓰지 않는다(L-14, L-10).

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 포트폴리오 한도의 관측층 명세가 서지 않았던 결손이 이 명제와 다음 명제로
답해지고, 그 답이 소스 있음이 아니라 소스 없음이라는 것이 이 층의 산출이다.
-/
-- DD:CF-4154
theorem threshold_value_observed_undetermined :
    thresholdValueObserved portfolioLimitChannels
      = ObservedTruth.undetermined .noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
걸림의 사실도 측정 소스 없음으로 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 열의 어느 경로가 걸림의 사실을 주체별로 내는 것이 관측되어야 한다. 그 관측은 감독 당국이 아닌
독자가 한 주체의 한도가 걸렸는지를 공표 문면에서 읽을 수 있다는 뜻이다.

**형식층 배정:** 관측층. 판정과 까닭만 쓰고 수를 쓰지 않는다(L-14, L-10).

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 문턱과 걸림이 같은 까닭으로 서지 않는다는 것을 이 명제가 앞 명제와 함께
들며, 두 물음을 한 칸으로 묶지 않은 사유가 이 자리에서 형식층에 선다.
-/
-- DD:CF-4154
theorem binding_held_observed_undetermined :
    bindingHeldObserved portfolioLimitChannels
      = ObservedTruth.undetermined .noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
어느 경로도 주체별로 가르지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 열의 어느 경로가 주체별로 가르는 것이 관측되어야 한다. 그 관측은 앞의 두 명제가 소스 없음을 내는
까닭이 사라진다는 뜻이며, 두 물음의 답이 그 경로의 다른 칸에만 걸린다.

**형식층 배정:** 관측층. 판정만 쓰고 수를 쓰지 않는다(L-14, L-10).

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 앞의 두 명제가 같은 결손을 내는 까닭이 한 칸에 몰려 있음을 이 명제가 들고,
그 몰림이 없으면 두 물음이 각각 다른 사유로 막힌 것으로 읽힌다.
-/
-- DD:CF-4155
theorem no_channel_splits_by_entity :
    ∀ C ∈ portfolioLimitChannels, C.splitsByEntity = false := by
  -- 열의 멤버십을 생성자로 갈라 경로마다 그 칸을 계산한다. 두 경로가 그 칸을 모두
  -- 거짓으로 두므로 갈래마다 `rfl` 로 닫히고, 빈 목록의 멤버십은 생성자가 없어
  -- 마지막 갈래가 사라진다.
  intro C hC
  unfold portfolioLimitChannels at hC
  cases hC with
  | head => rfl
  | tail _ hC => cases hC with
    | head => rfl
    | tail _ hC => cases hC

/--
자기 불완전성을 적는 경로가 그 열에 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 열의 어느 경로도 자기 불완전성을 적지 않는 것이 관측되어야 한다. 그 관측은 두 물음의 답이 규범의
성질이 아니라 자료의 결손이라는 뜻이며, 그러면 자료를 모으면 그 답이 선다.

**존재 형태로 진술하는 까닭(T-6):**
그 유보를 적는 경로를 들어야 보인다. 전칭으로 두면 감독 규범의 유동성 기준이 그 유보를 적지 않으므로
거짓이며, 그 하나가 적는다는 것이 이 명제가 드는 것이다.

**형식층 배정:** 관측층. 판정만 쓰고 수를 쓰지 않는다(L-14, L-10).

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 물음의 답이 규범의 성질이라는 이 파일의 산출이 이 명제에 걸리고, 이것이
없으면 소스 없음이 조달로 메워질 수 있는 것으로 읽힌다.
-/
-- DD:CF-4155
theorem exists_channel_reserving_discretion :
    ∃ C ∈ portfolioLimitChannels, C.reservesDiscretion = true := by
  -- 담보 정책 문서가 그 열의 둘째 원소이므로 멤버십을 생성자로 직접 든다. 그
  -- 멤버십을 판정 전술로 닫으면 명제 외연성을 끌어와 이 층의 기준선을 넘는다.
  exact ⟨centralBankCollateralPolicy, List.Mem.tail _ (List.Mem.head _), rfl⟩

/--
두 답함이 각 칸을 홀로 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 답함의 곱에서 한 인자를 뒤집어도 값이 바뀌지 않는 배치가 관측되어야 한다. 그 관측은 그 인자가 그
답함에 들 자리가 없다는 뜻이며, 그러면 그 칸이 이 구조체에서 빠진다.

**존재 형태로 진술하는 까닭(T-6):**
인자마다 그것이 홀로 값을 가르는 배치를 들어야 보인다. 임의의 배치에서 가르는 것이 아니라 가르는
배치가 실재하는 것이 이 명제가 드는 것이다.

**형식층 배정:** 관측층. 판정만 쓰고 수를 쓰지 않는다(L-14, L-10).

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 두 답함이 곱으로 서므로 두 인자가 함께 참인 증거와 함께 거짓인 증거만 두면 그
결합을 뒤집은 변이가 통과하며, 그 통과를 막는 증거가 이 자리에서 선다(A-8).
-/
-- DD:CF-4155
theorem portfolio_channel_answers_pin_each_field :
    (∃ C : PortfolioLimitChannel, C.answersThreshold = true) ∧
    (∃ C : PortfolioLimitChannel, C.givesThresholdValue = true ∧ C.answersThreshold = false) ∧
    (∃ C : PortfolioLimitChannel, C.splitsByEntity = true ∧ C.answersThreshold = false) ∧
    (∃ C : PortfolioLimitChannel, C.answersBinding = true) ∧
    (∃ C : PortfolioLimitChannel, C.givesBindingHeld = true ∧ C.answersBinding = false) ∧
    (∃ C : PortfolioLimitChannel, C.splitsByEntity = true ∧ C.answersBinding = false) := by
  -- 칸마다 그 칸 하나가 답함의 값을 가르는 경로를 든다. 답함이 두 칸의 곱이므로
  -- 경로마다 계산하면 값이 나와 `rfl` 로 닫힌다.
  exact ⟨⟨⟨true, false, true, false⟩, rfl⟩,
    ⟨⟨true, false, false, false⟩, rfl, rfl⟩,
    ⟨⟨false, false, true, false⟩, rfl, rfl⟩,
    ⟨⟨false, true, true, false⟩, rfl⟩,
    ⟨⟨false, true, false, false⟩, rfl, rfl⟩,
    ⟨⟨false, false, true, false⟩, rfl, rfl⟩⟩

end CrisisFramework.Observation
