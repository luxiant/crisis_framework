/-
관측층 — 담보의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 수를 쓰지 않는다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 예외).

**경로를 공시의 입도로 색인한다.** 담보의 공시는 받은 담보의 가치를 총액으로 들고 개별 담보물을
식별하지 않는다. 그래서 같은 담보물이 몇 번 겹쳤는지는 서지 않고, 겹친 몫이 총액의 비로만 드러난다.

**공시가 재는 것과 물음이 묻는 것이 갈린다.** 재무제표의 담보 주석은 받은 담보의 가치를 들고,
`CQ-fin-10` 은 그 담보가 떠받치는 청구권의 금액을 묻는다. 두 대상이 다르므로 경로가 어느 쪽을
드는지를 칸으로 따로 둔다.

**답이 쌍인 두 물음을 받는다.** 그래서 답을 낼 수 있는가의 판정을 칸마다 따로 둔다. 한 경로가
쌍의 두 칸을 다 내지 못하는 것이 정상이다.

금액과 시점과 영역의 타입은 전부 매개변수로 받는다. 금액의 수 체계는 회계층이 정한다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/
import CrisisFramework.Definition.Collateral
import CrisisFramework.Observation.CompetencyQuestion

open CrisisFramework.Definition

namespace CrisisFramework.Observation

/--
담보 공시의 입도.

**대응 비형식 개념:** 그 공시가 담보를 금액 총계로 드는가, 개별 담보물을 식별해 드는가. 총계로만
들면 같은 담보물에 제공이 여럿 붙어 있는지가 서지 않고, 식별해 들면 그것이 선다.

**이 정의가 배제하는 사례:**
미국 삼자 레포의 담보가 수탁기관에 분리 보관되어 제공자의 도산 시에도 분리되고 식별 가능한 것
(Singh 2011). 그 자리는 식별이 되는데 재담보가 금지되어 중복이 애초에 서지 않으므로, 식별 여부가
중복 관측을 결정한다는 읽기를 이 열거만으로는 할 수 없다. 식별과 재담보 허용이 함께 서는 공시를
뭉치에서 확인하지 못했다.

**기각한 대체 정의:**
집계의 주체로 가르는 안. 공시 주체별로 서면 중복이 묶이지 않는다고 보았으나 실측이 그 반대였다.
재사용이 허용된 담보는 부외 항목이어서 여러 주체의 각주에 동시에 나타나며, 그래서 받은 담보의
합이 원천을 넘는 것으로 중복이 총액 수준에서 드러난다(Singh·Aitken 2010 §V). 법역별 분해 가능성을
칸으로 두는 안도 기각했다. 그 결손이 실재하나(같은 편의 각주 11) 두 물음이 법역을 축으로 받지
않으므로 이 판정에 걸리지 않는다.
-/
-- DD:CF-847
inductive PledgeDisclosureGrain where
  /-- 금액 총계로만 든다. 어느 담보물이 몇 번 제공됐는지는 서지 않는다. -/
  | aggregateAmount
  /-- 개별 담보물을 식별해 든다. 같은 담보물에 붙은 제공을 묶을 수 있다. -/
  | identifiedAsset
  deriving DecidableEq, Repr

/--
담보의 공시 경로.

**대응 비형식 개념:** 밖의 관측자가 담보 제공을 보는 자리. 경로는 어느 담보물을 보는지와 어떤
입도로 드는지와 세 값 가운데 무엇을 드는지와 어느 축을 따로 가르는지를 선언한다. 알려진 경로가
드는 칸은 다음과 같다.

| 경로 | 입도 | 받은 담보의 가치 | 떠받쳐진 청구권 | 실물의 가치 | 담보물 종류 |
|---|---|---|---|---|---|
| 재무제표의 담보 주석 | 총계 | 예. 재사용이 허용된 몫과 실제로 재사용한 몫을 따로 든다 | 아니오 | 아니오 | **금융상품만** |
| 1차 원천의 업계 집계 | 총계 | 예. 다만 수탁기관 단위로 집계된다 | 아니오 | 아니오 | 아니오 |

**이 정의가 배제하는 사례:**
Singh 2011 이 1차 원천을 헤지펀드 운용자산에 레버리지 추정을 곱해 얻고 증권대여는 업계 협회의
집계를 쓴 것. 그 값은 공시가 아니라 추정과 설문이 섞인 것인데, 이 구조는 경로가 무엇을 드러내는지만
선언하고 그 값이 실측인지 추정인지를 담지 않는다. 같은 결손이 교역 금융의 경로에서도 섰다.

**기각한 대체 정의:**
받은 담보의 가치와 떠받쳐진 청구권을 한 칸으로 받는 안. 재무제표 주석이 앞을 들고 `CQ-fin-10` 이
뒤를 묻는데 둘이 다른 대상이므로, 한 칸으로 두면 공시가 드는 것과 물음이 묻는 것의 어긋남이
사라진다. 경로를 소스 이름으로만 색인하는 안도 기각했다. 한 소스 안에서 담보물의 종류마다 공시
여부가 갈린다.
-/
-- DD:CF-848
structure PledgeChannel (Asset Currency : Type) where
  /-- 그 담보물을 담보로 한 제공을 이 경로가 보는가. -/
  coversAsset : Asset → Bool
  /-- 이 경로가 담보를 드는 입도. -/
  grain : PledgeDisclosureGrain
  /-- 이 경로가 받은 담보 자체의 가치를 드는가. -/
  reportsReceivedValue : Bool
  /-- 이 경로가 그 담보가 떠받치는 청구권의 금액을 드는가. -/
  reportsBackedClaims : Bool
  /-- 이 경로가 담보물 실물의 가치를 드는가. -/
  reportsStock : Bool
  /-- 이 경로가 담보물을 종류별로 가르는가. -/
  resolvesAsset : Bool
  /-- 이 경로가 그 표시 통화를 따로 가르는가. -/
  resolvesCurrency : Currency → Bool

/--
아무 담보도 보지 않는 경로. witness 이며 소스 없음의 기본값이다(A-3, D-8, L-14).

**무엇을 증거하는가.** `PledgeChannel` 이 비어 있지 않음을 보인다. 모든 담보물에 대해 보지 않고
세 값을 다 들지 않으며 어느 축도 가르지 않는 경로다.
-/
-- DD:CF-31
def PledgeChannel.noSource {Asset Currency : Type} : PledgeChannel Asset Currency where
  coversAsset := fun _ => false
  grain := .aggregateAmount
  reportsReceivedValue := false
  reportsBackedClaims := false
  reportsStock := false
  resolvesAsset := false
  resolvesCurrency := fun _ => false

/--
이 경로가 담보물 종류별로 떠받쳐진 청구권의 합을 낼 수 있는가.

**대응 비형식 개념:** `CQ-fin-10` 이 상품 k 를 담보로 한 청구권의 합을 묻는다. 그 값이 서려면
경로가 그 담보물을 보고 **떠받쳐진 청구권의 금액을 들고** 담보물을 종류별로 가르고 표시 통화를
가르는 것이 함께 서야 한다. 개별 담보물의 식별은 요구하지 않는다. 종류별로 모으는 것만으로
답이 선다.

**이 정의가 배제하는 사례:**
재무제표의 담보 주석은 받은 담보의 공정가치를 금액으로 들되 그 담보가 떠받치는 부채를 같은 자리에
들지 않으며, 드는 것이 「담보로 받은 금융상품」이라 상품 재고를 담보로 받은 것은 그 칸에 서지 않는다
(Singh·Aitken 2010 상자 1 이 인용한 재무제표 문면). 금액을 드는데도 이 판정이 거짓을 내는 자리이며,
공시가 재는 것과 물음이 묻는 것이 다르다는 것이 그 까닭이다.

**기각한 대체 정의:**
받은 담보의 가치를 떠받쳐진 청구권으로 읽는 안. 담보의 가치와 그것이 떠받치는 부채는 평가율만큼
갈리고 그 율이 제공마다 다르므로, 한쪽에서 다른 쪽을 유도하면 확인되지 않은 환산을 넣게 된다.
입도를 함께 묻는 안도 기각했다. 종류별 합은 개별 담보물을 식별하지 않아도 서므로 그 칸이 이 판정에
걸리지 않는다.
-/
-- DD:CF-849
def PledgeChannel.answersAssetCoverage {Asset Currency : Type}
    (ch : PledgeChannel Asset Currency) (k : Asset) (c : Currency) : Bool :=
  ch.coversAsset k && ch.reportsBackedClaims && ch.resolvesAsset && ch.resolvesCurrency c

/--
이 경로가 담보물 하나에 붙은 제공들의 떠받쳐진 청구권 합을 낼 수 있는가.

**대응 비형식 개념:** `CQ-fin-12` 가 청구권 j 를 담보로 한 청구권의 합을 묻는다. 그 값이 서려면
종류별 합의 조건에 **개별 담보물의 식별**이 더해져야 한다. 같은 담보물에 붙은 제공을 묶어야 하므로
총계만 드는 경로로는 서지 않는다.

**이 정의가 배제하는 사례:**
재사용이 허용된 담보가 여러 주체의 각주에 동시에 나타나 받은 담보의 합이 1차 원천을 넘는 것
(Singh·Aitken 2010 §V). 그 넘는 몫이 중복의 크기이므로 중복은 총액 수준에서 관측되는데, 어느
담보물이 몇 번 겹쳤는지는 그 합에서 나오지 않는다. 중복이 보이는데도 이 판정이 거짓을 내는
자리다.

**기각한 대체 정의:**
총액의 비로 개별 배수를 가름하는 안. 그 비는 체계 전체의 평균이고 담보물마다 배수가 다르므로,
평균을 개별 값으로 읽으면 묻지 않은 자리를 함께 평균한 수를 답으로 적게 된다. 법역별 분해를
함께 묻는 안도 기각했다. 그 결손이 실재하나 이 물음이 법역을 축으로 받지 않는다.
-/
-- DD:CF-849
def PledgeChannel.answersIdentifiedCoverage {Asset Currency : Type}
    (ch : PledgeChannel Asset Currency) (k : Asset) (c : Currency) : Bool :=
  ch.answersAssetCoverage k c && (ch.grain == PledgeDisclosureGrain.identifiedAsset)

/--
이 경로가 담보물 실물의 가치를 낼 수 있는가.

**대응 비형식 개념:** 실물의 가치는 담보물 자체에 붙는 값이므로 제공을 묶는 입도에 걸리지 않는다.
경로가 그 담보물을 보고 실물의 가치를 들고 종류와 통화를 가르면 선다.

**이 정의가 배제하는 사례:**
2014년 칭다오항의 금속에 대해 실물 가치가 사후 조사로 집계된 것(Reuters 2014년 6월 보도). 그 값은
사건이 드러난 뒤에 나온 것이고 정기 공시가 아니므로, 이 판정이 보는 경로에 그런 자리가 없다.

**기각한 대체 정의:**
입도를 함께 묻는 안. 실물의 가치가 제공마다 더해지는 값이 아니라 담보물 하나에 붙는 값이므로
입도가 그 판정에 걸리지 않는다. 가격과 수량을 따로 묻는 안도 기각했다. 관측층은 값을 담지 않으며
(L-14) 그 둘이 곱으로 묶이는지는 그 경로의 성질이 아니다.
-/
-- DD:CF-849
def PledgeChannel.answersStock {Asset Currency : Type}
    (ch : PledgeChannel Asset Currency) (k : Asset) (c : Currency) : Bool :=
  ch.coversAsset k && ch.reportsStock && ch.resolvesAsset && ch.resolvesCurrency c

/--
`CQ-fin-10` 의 답 자리를 공시 경로 하나의 판독으로 채운다.

**대응 비형식 개념:** 앞값은 경로가 종류별 커버리지를 낼 수 있으면 내고 그렇지 않으면 소스 없음으로
접는다. 뒷값은 경로와 무관하게 접힌다. 담보 실물의 수량을 담는 대상이 형식층에 없으므로 경로가 그
값을 들어도 구조가 받을 자리가 없다.

**뒷값의 까닭이 둘 가운데 앞의 것이다.** 수량이 구조에 없는 것과 가격의 결정이 동학층에 있는 것이
둘 다 걸리나, 수량이 먼저 막으므로 관측이 보는 것은 구조의 결손이다.

**이 물음의 두 값이 다른 축에서 접힌다.** 앞값은 공시가 그 대상을 들지 않아서 접히므로 조달로
풀리고, 뒷값은 구조에 자리가 없어서 접히므로 정의를 더해야 풀린다. §1.1 의 네 축으로 보면 앞이
데이터 공백이고 뒤가 정의 공백이다.

**이 정의가 배제하는 사례:**
교차통화 베이시스처럼 총액이 복원되지 않는 자리에서 제약의 그림자 가격이 매일 관측되는 것. 그런
대리 관측이 있다는 것과 소스가 아예 없다는 것이 `ObservedValue` 의 같은 칸에 드는데, 이 조립은
경로가 든 칸만 보고 대리 관측을 찾지 않는다.

**기각한 대체 정의:**
뒷값을 경로의 `reportsStock` 으로 판정해 내는 안. 경로가 그 값을 든다 해도 구조에 담을 자리가
없으므로 판정이 참을 내면 넣을 곳 없는 값을 내게 된다. 두 값을 한 판정으로 접는 안도 기각했다.
선 것과 막힌 것의 구별이 답에서 사라지고, 접히는 까닭이 칸마다 다르다는 것도 함께 사라진다.
-/
-- DD:CF-850
def pledgedClaimsAndStockFrom {Time Asset Currency Amount : Type}
    (ch : PledgeChannel Asset Currency)
    (backed : Asset → Currency → Time → Amount) :
    CQ.PledgedClaimsAndStock Time Asset Currency Amount where
  answer := fun k c t =>
    ( if ch.answersAssetCoverage k c then .value (backed k c t)
      else .undetermined .noMeasurementSource
    , .undetermined .structureLacksTarget )

/--
`CQ-fin-12` 의 답 자리를 공시 경로 하나의 판독으로 채운다.

**대응 비형식 개념:** 앞값은 경로가 개별 담보물을 식별해야 서므로, 총계만 드는 경로에서는 접힌다.
뒷값은 그 청구권 자신의 금액이고 물음이 청구권 j 를 인자로 받으므로 식별이 물음의 전제다. 그래서
구조가 그 값을 내고 접지 않는다.

**이 물음이 정의 공백 밖에 선다.** 두 값에 대해 무엇을 재야 하는지가 전부 정해졌고 구조가 그것을
낸다. 앞값이 접히는 것은 공시가 개별 담보물을 식별하지 않기 때문이므로 조달로 풀리는 공백이며,
§1.1 의 네 축으로는 데이터 공백이다. `CQ-fin-10` 의 뒷값이 정의 공백에 남는 것과 갈린다.

**이 정의가 배제하는 사례:**
2008년 Lehman Brothers 의 런던 법인이 도산 절차에 들어가 고객 자산이 동결된 것
(Singh·Aitken 2010). 그 자리에서 청구권의 금액은 기재된 값 그대로였으나 회수 가능성이 달라졌는데,
이 조립은 기재된 금액을 내고 회수 가능성을 담지 않는다.

**기각한 대체 정의:**
뒷값도 경로의 판정에 걸어 접는 안. 청구권의 금액은 담보 공시가 아니라 그 청구권 자신의 기재에서
나오므로 담보 경로의 칸이 그 값을 막을 근거가 없다. 뒷값을 담보 주석에서 읽는 안도 기각했다. 그
주석이 드는 것은 받은 담보의 공정가치이고 담보로 잡힌 청구권의 기재 금액과 평가 대상이 다르다.
-/
-- DD:CF-851
def claimPledgeMultipleFrom {Time Claim Asset Currency Amount : Type}
    (ch : PledgeChannel Asset Currency)
    (asAsset : Claim → Asset)
    (backed : Claim → Currency → Time → Amount)
    (face : Claim → Currency → Time → Amount) :
    CQ.ClaimPledgeMultiple Time Claim Currency Amount where
  answer := fun j c t =>
    ( if ch.answersIdentifiedCoverage (asAsset j) c then .value (backed j c t)
      else .undetermined .noMeasurementSource
    , .value (face j c t) )

end CrisisFramework.Observation
