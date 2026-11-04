/-
관측층 — 외부 자산의 몫을 보는 공시 경로

규율: L-14(값을 담지 않고 사상의 명세만 담는다), L-10(수를 쓰지 않는다),
      C-3(판정은 계산으로 낸다), A-3(witness 의무), D-1·D-2(docstring 3항목),
      T-2(반증 조건), T-4(가정의 명시).

이 파일은 외부 자산의 몫을 공시에서 읽을 수 있는지를 담는다. 몫 자체는 정의층이 들고 그 두
합은 회계층이 들며, 이 파일은 그 값을 **무엇이 내는가와 내지 않는가**만 든다.

**두 경로가 교차로 비어 있다.** 거래소 경로는 자산을 특정하고 총량을 일별로 들되 보유자별 몫과
담보로 내놓은 몫을 들지 않고, 재무제표 경로는 내놓은 몫을 금액으로 들되 보유자별 몫의 비율을
들지 않고 자산을 특정하지 않는다. 그 교차가 `collateral` 아크의 산출이다.

**적격성의 축이 그 위에 더해졌다.** 담보 여력의 금액 판본이 제약의 자산 측 적격성으로 자산을
거르므로 기재값만으로는 그 총계가 재어지지 않는데, **적격성을 드는 경로가 하나도 없다.** 적격
증권의 목록이 공개되는 체계에서도 그 목록을 내는 쪽이 자기 목록에 구속되지 않는다고 스스로 적으므로
그 칸이 그 경로에서도 거짓이며, **공시가 적격성을 쥐고도 확정하지 않는 자리가 그 산출이다.**

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

namespace CrisisFramework.Observation

/--
외부 자산의 몫을 보는 공시 경로.

**대응 비형식 개념:** 하나의 공시 규범이나 공표 체계가 외부 자산의 몫에 대해 무엇을 드는가.

**이 정의가 배제하는 사례:**
거래소가 등록되지 않은 보관분을 2019년 11월부터 월별로 받다가 2025년 4월부터 일별로 공표하고
무료 열람은 사흘을 늦추므로, 같은 경로가 시점에 따라 다른 주기와 지연을 갖는 것이 이 칸들에
담기지 않는다. 공시의 지연이 그 값을 쓸 수 있는지를 가르는데 이 구조는 드는가와 들지 않는가만
든다.

**기각한 대체 정의:**
주기와 지연을 칸으로 두는 안. 어느 판정도 그 칸을 읽지 않으므로 읽지 않는 필드를 두지 않는다는
원칙에 걸린다. 경로마다 규범의 조문 번호를 칸으로 두는 안도 기각했다. 문면의 지목은 docstring 이
들고 구조가 들면 조문이 개정될 때 그 값이 조용히 낡는다.

**분할의 완전성을 주장하지 않는다(V-7).** 이 칸들이 공시가 드는 것 전부를 덮는다는 근거가 없으며,
새 규범이 다른 축을 가르면 칸이 늘어난다(V-7).

**수를 담지 않는다.** 칸이 판정이거나 자산의 특정이며 어느 쪽도 수 타입을 들지 않는다(L-14).
-/
-- DD:CF-977
structure ShareChannel (Asset : Type) where
  /-- 그 자산의 총량이나 총 몫을 드는가. -/
  reportsTotal : Bool
  /-- 보유자별 몫을 드는가. -/
  reportsHolderShare : Bool
  /-- 담보로 내놓은 몫을 드는가. -/
  reportsPledgedShare : Bool
  /-- 등록되지 않은 보관분을 드는가. -/
  coversUnregistered : Bool
  /-- 보세창고의 보관분을 드는가. -/
  coversBonded : Bool
  /-- 그 자산을 특정하는가. -/
  resolvesAsset : Asset → Bool
  /-- 그 자산의 기재값을 금액으로 드는가. 담보 여력의 금액 판본이 보유한 몫에 기재값을 걸어
      금액으로 서므로, 그 값이 공시에서 읽히지 않으면 그 총계가 재어지지 않는다. -/
  reportsCarryingAmount : Bool
  /-- 그 자산이 제약의 자산 측 적격성을 통과하는가를 확정하는가. 담보 여력의 금액 판본이 그
      적격성으로 자산을 거르므로, 그 가름이 공시에서 확정되지 않으면 그 총계가 재어지지 않는다.
      목록을 내면서 그 목록에 구속되지 않는다고 적는 경로는 이 칸을 채우지 않는다. -/
  reportsEligibility : Bool

/-- witness (A-3). `ShareChannel` 이 비어 있지 않음을 보인다. 아무것도 들지 않는 경로. -/
-- DD:CF-31
def ShareChannel.noSource {Asset : Type} : ShareChannel Asset where
  reportsTotal := false
  reportsHolderShare := false
  reportsPledgedShare := false
  coversUnregistered := false
  coversBonded := false
  resolvesAsset := fun _ => false
  reportsCarryingAmount := false
  reportsEligibility := false

/--
그 경로가 그 자산의 보유 몫과 내놓은 몫을 함께 내는가.

**대응 비형식 개념:** 이 공시로 「누가 그 자산의 몫을 얼마나 갖고 그 가운데 얼마를 담보로
내놓았는가」를 읽을 수 있는가. 중복의 판정이 두 합을 맞대므로 둘을 함께 요구한다.

**이 정의가 배제하는 사례:**
거래소가 보유 집중도를 자기에게 보고하게 하고 일정 비율을 넘으면 대출 의무를 지우되 보유자를
공개 공시에서 식별하지 않으므로(LME 고시 01/122 A122), 규범이 그 값을 쥐고 있으면서 공표하지
않는 자리가 이 판정에서 「들지 않는다」와 같아진다. 쥐고 있으나 공표하지 않는 것과 애초에 재지
않는 것이 밖에서 같아 보인다.

**기각한 대체 정의:**
두 몫을 판정 둘로 가르는 안. 중복의 판정이 두 합을 함께 요구하므로 한쪽만 서는 경로는 그 물음에
답하지 못하며, 가르면 어느 쪽이 답을 세우는지가 호출하는 쪽의 몫이 된다. 총량을 드는 것만으로
참을 내는 안도 기각했다. 총량에서 보유자별 몫이 유도되지 않으므로 그 판정이 참을 내면 낼 수 없는
값을 내게 된다. 보세창고를 묻지 않는 안도 기각했다. 2014년 칭다오항의 금속이 보세창고에 있었으므로
중복 계상의 정본 사례가 바로 그 칸에서 빠진다.

**다섯 칸을 모두 요구한다.** 두 몫을 들고 등록되지 않은 보관분과 보세창고를 덮고 그 자산을
특정해야 선다.
-/
-- DD:CF-977
def ShareChannel.answersShare {Asset : Type} (ch : ShareChannel Asset) (a : Asset) : Bool :=
  ch.reportsHolderShare && ch.reportsPledgedShare
    && ch.coversUnregistered && ch.coversBonded && ch.resolvesAsset a

/--
거래소 창고 공표의 경로 값.

**대응 비형식 개념:** 금속 거래소가 등록 창고의 재고를 공표하는 체계. 등록분과 등록되지 않은
보관분을 모두 일별로 들되 보유자를 식별하지 않는다.

**이 정의가 배제하는 사례:**
거래소에 등록되지 않은 창고의 보관분. 공표의 범위가 등록 창고 안의 금속이므로 보세창고의
재고가 그 밖에 있고, 2014년 칭다오항의 금속이 거기 있었다(LME 2025년 4월 공표분과
Minko 2016 §2.5).

**기각한 대체 정의:**
등록분과 등록되지 않은 보관분을 경로 둘로 가르는 안. 같은 체계가 같은 규범으로 둘을 공표하고
보유자를 식별하지 않는 성질이 둘에 같이 걸리므로, 가르면 측정 대응이 다르지 않은 둘이 선다
(V-5). 공표의 지연을 칸으로 받는 안도 기각했다. 어느 판정도 그 칸을 읽지 않는다.

**총량을 들고 두 몫을 들지 않는다.** 그래서 이 경로만으로는 답이 서지 않으며, 그 사실이 `collateral`
아크의 산출이다.
-/
-- DD:CF-978
def exchangeWarehouseChannel {Asset : Type} (resolves : Asset → Bool) :
    ShareChannel Asset where
  reportsTotal := true
  reportsHolderShare := false
  reportsPledgedShare := false
  coversUnregistered := true
  coversBonded := false
  resolvesAsset := resolves
  reportsCarryingAmount := false
  reportsEligibility := false

/--
재무제표 공시의 경로 값.

**대응 비형식 개념:** 회계기준이 분류별 재고자산의 장부금액과 담보로 제공된 재고자산의
장부금액을 요구하는 체계. 내놓은 몫을 금액으로 들되 자산을 특정하지 않는다.

**이 정의가 배제하는 사례:**
소유권을 넘기는 구조로 금융한 재고. 그 재고가 장부에서 제거되므로 담보로 제공된 재고자산의
공시에 들지 않으며, 2014년 칭다오항 금융의 상당 부분이 그 구조였다(IAS 2 제36조 (h)와
Minko 2016 §2.4). 같은 경제적 실질이 회계 분류 하나로 공시에서 사라진다.

**기각한 대체 정의:**
금액을 드는 것을 보유자별 몫을 드는 것으로 읽는 안. 금액은 그 기업의 보유에 가격을 곱한 값이고
그 자산의 총량에 대한 비율이 아니므로, 참으로 두면 유도되지 않는 값이 서게 된다. 자산의 특정을
참으로 두는 안도 기각했다. 그 기준이 담보 제공분에 종류별 분해를 요구하지 않으므로(E-45 §2-2)
상품을 가르는 축이 그 공시에 없다.

**내놓은 몫은 들고 보유 몫은 들지 않는다.** 분류별 재고자산이 금액으로 나오나 그것은 그 기업의
보유이고 자산 전체에 대한 몫이 아니다. 그래서 두 경로가 교차로 비어 있다.

**보관 장소를 가리지 않는다.** 회계기준이 장소로 범위를 가르지 않으므로 등록되지 않은 보관분과
보세창고가 모두 참이다.
-/
-- DD:CF-978
def financialStatementShareChannel {Asset : Type} : ShareChannel Asset where
  reportsTotal := false
  reportsHolderShare := false
  reportsPledgedShare := true
  coversUnregistered := true
  coversBonded := true
  resolvesAsset := fun _ => false
  reportsCarryingAmount := false
  reportsEligibility := false

/--
거래소 창고 경로에 보유자별 몫과 내놓은 몫과 보세창고가 더해지면 답이 선다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 그 세 칸이 참이 되었는데도 답이 서지 않는
것. 그러려면 `answersShare` 가 다섯 칸 밖의 것을 요구해야 하는데 그 판정이 다섯 칸의 논리곱이
므로, 거짓이 되려면 자산의 특정이 거짓인 자리가 있어야 한다. 그래서 진술이 그 특정을 가정으로
든다.

**가정과 그 배제 사례(T-4·T-5):** 그 경로가 그 자산을 특정한다는 것을 진술에 명시한다. 거래소가
브랜드와 창고 단위로 금속을 가르므로 보통은 성립하나, 같은 브랜드가 여러 창고에 흩어져 있으면
특정의 단위가 물음의 단위와 갈린다. 그 자리에서 가정이 깨진다.

**이 정리가 재개 트리거의 몫을 받는다.** 보유자별 몫의 공표를 요구하는 결손에 재개 조건을 쓸 수
없으므로, 규범이 바뀌어 경로 값이 낡으면 이 정리가 깨지고 그 깨짐이 해소를 알린다.
-/
-- DD:CF-979
theorem exchangeWarehouseChannel_answersShare_when_resolved
    {Asset : Type} (resolves : Asset → Bool) (a : Asset) (hres : resolves a = true) :
    ({ exchangeWarehouseChannel resolves with
        reportsHolderShare := true,
        reportsPledgedShare := true,
        coversBonded := true } : ShareChannel Asset).answersShare a = true := by
  -- 갱신이 다섯 칸 가운데 셋을 참으로 두고 거래소 경로가 등록되지 않은 보관분을 이미 참으로
  -- 들므로, 판정의 논리곱이 자산의 특정 하나로 줄어든다. 그 줄어든 꼴을 `show` 로 드러내고
  -- 가정을 그대로 쓴다. 전면 `simp` 를 부르지 않으며 보조정리도 쓰지 않는다.
  show resolves a = true
  exact hres

/--
적격 증권 목록 공표의 경로 값.

**대응 비형식 개념:** 중앙은행이 자기 대출 제도의 담보로 받는 증권의 목록을 월별로 공표하는 체계.
증권을 식별번호로 특정하되 그 목록에 구속되지 않는다고 스스로 적는다.

**이 정의가 배제하는 사례:**
같은 증권이 보유자에 따라 다른 등급을 받는 자리. 그 중앙은행의 담보 정책이 참가자가 조성한 자산을
담은 커버드본드와 증권화를 그 등급에서 빼고 한 등급 아래에서 고려하므로(영란은행 2026년 6월 18일
Level B 담보 목록), 적격성이 증권에만 붙지 않고 증권과 보유자의 쌍에 붙는다. 이 구조의 칸은 자산을
받고 보유자를 받지 않으므로 그 쌍을 담지 못한다.
조달처: E-49 §2-9 「참가자가 originate 한 자산을 담은 커버드본드와 증권화는 Level B 로 받지 않고」

**기각한 대체 정의:**
적격성 칸을 참으로 두는 안. 그 목록이 적격 증권을 월별로 열거하므로 적격성의 재료가 있는 것으로
보이나, 같은 문서의 말미가 어떤 담보든 어떤 사유로든 언제든 거절할 권리를 유보하고 그 결과로 공표된
목록에 구속되지 않는다고 적는다. **그 유보가 목록을 참고 자료로 만들고 확정으로 만들지 않는다.**
이 경로를 세우지 않고 재무제표 경로의 칸으로 갈음하는 안도 기각했다. 적격성을 아예 쥐지 않는 공시와
쥐고도 확정하지 않는 공시가 다른 사실인데, 갈음하면 그 둘이 한 경로의 거짓 칸으로 접혀 구별되지
않는다.

**기재값을 들지 않는다.** 그 목록이 증권의 식별번호와 범주를 들고 금액을 들지 않으므로, 적격성이
확정되더라도 금액 판본의 입력이 서지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-2521
def eligibleSecuritiesListChannel {Asset : Type} (resolves : Asset → Bool) :
    ShareChannel Asset where
  reportsTotal := false
  reportsHolderShare := false
  reportsPledgedShare := false
  coversUnregistered := false
  coversBonded := false
  resolvesAsset := resolves
  reportsCarryingAmount := false
  reportsEligibility := false

/--
자산의 기재값을 적격성으로 가려 금액으로 읽을 수 있는가.

**대응 비형식 개념:** 그 경로가 특정 자산을 식별하고 보유자별 몫을 들고 그 자산의 기재값을 금액으로
들고 그 자산이 제약의 적격성을 통과하는가를 확정하는가. 넷이 함께 서야 담보 여력의 금액 판본이
재어지며, 하나라도 없으면 그 총계의 입력이 서지 않는다.

**이 정의가 배제하는 사례:**
적격성의 판정이 신청과 심사의 산물인 자리. 그 중앙은행이 적격성 요청을 정해진 서식으로 받고 어느
자산이 적격인지를 판정하려고 실사를 해야 했던 경우에 그 비용을 참가자에게 청구할 수 있다고 적으므로
(영란은행 2026년 6월 18일 Level B 담보 목록), 적격성이 사전에 공시된 성질이 아니라 절차의 결과다.
이 판정은 그 절차의 존재를 담지 않고 공시가 그 값을 확정하는가만 묻는다.
조달처: E-49 §11-3 「적격성 요청을 정해진 서식으로 받고 실사 비용을 청구할 수 있다」

**기각한 대체 정의:**
적격성 칸을 빼고 셋만 요구하는 안. 담보 여력의 금액 판본이 제약의 자산 측 적격성으로 자산을 거른
뒤에 기재값을 걸므로, 셋만 요구하면 그 판본이 재어진다는 결론이 그 적격성을 건너뛴 것이 된다. 그
어긋남이 앞 판의 반증 조건에 실제로 서 있었다. 적격성 판정을 별도 함수로 가르는 안도 기각했다. 그
금액 판본이 넷을 한 자리에서 요구하므로 가르면 어느 조합이 답을 세우는지가 호출하는 쪽의 몫이 된다.

**값을 담지 않는다.** 네 칸의 논리곱이며 수 타입을 언급하지 않는다.
-/
-- DD:CF-2522
def ShareChannel.answersCarryingAmount {Asset : Type}
    (ch : ShareChannel Asset) (a : Asset) : Bool :=
  ch.resolvesAsset a && ch.reportsHolderShare && ch.reportsCarryingAmount
    && ch.reportsEligibility

/--
서 있는 네 경로가 전부 기재값을 적격성으로 가려 읽지 못하며 적격성을 확정하는 경로가 하나도 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 소스가 전무한 경로나 거래소 창고 경로나 재무제표
몫 경로나 적격 증권 목록 경로 가운데 하나가 어느 자산에 대해 이 판정에서 참을 내거나 적격성 칸을
참으로 들어야 한다. 그러면 그 경로가 자산을 식별하고 보유자별 몫과 기재값과 적격성을 함께 드는 것이
므로 담보 여력의 금액 판본이 그 경로에서 재어진다.

**가정을 두지 않는다.** 네 경로의 칸이 전부 고정값이고 거래소 창고 경로와 적격 증권 목록 경로의 자산
식별만 인자로 받는데, 그 두 경로의 보유자별 몫 칸과 적격성 칸이 거짓이므로 논리곱이 그 인자와 무관
하게 거짓이다.

**T-3 분류:** 보조 보정이 아니다. 앞의 네 항을 각각 펼치면 정의의 전개로 닫히나 이 진술이 드는 것은
**적격성을 확정하는 경로가 하나도 없다**는 뒤의 네 항과 함께 선 전량 판정이며, 그 전량이 금액 판본의
입력 가운데 어느 것이 비었는지를 가른다. 적격 증권 목록이 적격성을 열거하면서도 그 칸을 채우지 않는
것이 이 페이즈의 산출이므로 기여 목록에 든다.

**이 정리가 L-14 의 소스 없음을 형식층에 드는 자리다.** 자산의 기재값을 적격성으로 가르는 공시가
없다는 것이 이 아크의 산출이며, 그 결손이 데이터 공백이 아니라 관측 명세의 결손이다. **적격 증권
목록이 그 결손의 성질을 바꾼다.** 적격성을 아예 쥐지 않는 공시와 쥐고도 확정하지 않는 공시가 다르고,
뒤의 자리에서 결손의 사유가 공시의 유보 자체다.
-/
-- DD:CF-2522
theorem answersCarryingAmount_eq_false_on_all_channels
    {Asset : Type} (resolves : Asset → Bool) (a : Asset) :
    (ShareChannel.noSource : ShareChannel Asset).answersCarryingAmount a = false ∧
      (exchangeWarehouseChannel resolves).answersCarryingAmount a = false ∧
      (financialStatementShareChannel : ShareChannel Asset).answersCarryingAmount a = false ∧
      (eligibleSecuritiesListChannel resolves).answersCarryingAmount a = false ∧
      (ShareChannel.noSource : ShareChannel Asset).reportsEligibility = false ∧
      (exchangeWarehouseChannel resolves).reportsEligibility = false ∧
      (financialStatementShareChannel : ShareChannel Asset).reportsEligibility = false ∧
      (eligibleSecuritiesListChannel resolves).reportsEligibility = false := by
  -- 네 경로의 칸을 `simp only` 로 펼치면 논리곱이 거짓 항을 품으므로 각 항이 거짓으로 접히고,
  -- 뒤의 네 항은 고정값 칸이므로 정의적 동등으로 닫는다. 전면 `simp` 를 부르지 않으며 여덟
  -- 자리를 `refine` 으로 갈라 각각 닫는다.
  refine ⟨?_, ?_, ?_, ?_, rfl, rfl, rfl, rfl⟩
  · simp only [ShareChannel.answersCarryingAmount, ShareChannel.noSource]
    rfl
  · simp only [ShareChannel.answersCarryingAmount, exchangeWarehouseChannel]
    rw [Bool.and_false]
  · simp only [ShareChannel.answersCarryingAmount, financialStatementShareChannel]
    rfl
  · simp only [ShareChannel.answersCarryingAmount, eligibleSecuritiesListChannel]
    rw [Bool.and_false]

end CrisisFramework.Observation
