/-
관측층 — 외부 자산의 몫을 보는 공시 경로

규율: L-14(값을 담지 않고 사상의 명세만 담는다), L-10(수를 쓰지 않는다),
      C-3(판정은 계산으로 낸다), A-3(witness 의무), D-1·D-2(docstring 3항목),
      T-2(반증 조건), T-4(가정의 명시).

이 파일은 외부 자산의 몫을 공시에서 읽을 수 있는지를 담는다. 몫 자체는 정의층이 들고 그 두
합은 회계층이 들며, 이 파일은 그 값을 **무엇이 내는가와 내지 않는가**만 든다.

**두 경로가 교차로 비어 있다.** 거래소 경로는 자산을 특정하고 총량을 일별로 들되 보유자별 몫과
담보로 내놓은 몫을 들지 않고, 재무제표 경로는 내놓은 몫을 금액으로 들되 보유자별 몫의 비율을
들지 않고 자산을 특정하지 않는다. 그 교차가 이 페이즈의 산출이다.

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

**수를 담지 않는다.** 다섯 칸이 모두 판정이고 자산의 특정만 사상으로 받는다(L-14).
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

/-- witness (A-3). `ShareChannel` 이 비어 있지 않음을 보인다. 아무것도 들지 않는 경로. -/
-- DD:CF-31
def ShareChannel.noSource {Asset : Type} : ShareChannel Asset where
  reportsTotal := false
  reportsHolderShare := false
  reportsPledgedShare := false
  coversUnregistered := false
  coversBonded := false
  resolvesAsset := fun _ => false

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

**총량을 들고 두 몫을 들지 않는다.** 그래서 이 경로만으로는 답이 서지 않으며, 그 사실이 이
페이즈의 산출이다.
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

end CrisisFramework.Observation
