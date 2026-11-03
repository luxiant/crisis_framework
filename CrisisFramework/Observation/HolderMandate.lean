/-
관측층 — 보유자 위임과 가중의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 수를 쓰지 않는다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 예외),
      T-2(반증 조건), T-4(가정의 명시).

**칸을 셋으로 가른다.** 주체가 어느 위임에 서는지와 개별 자산의 가중과 위임별 보유분이 전부 다른
공시에서 나오거나 어느 공시에서도 나오지 않으므로, 한 칸으로 두면 한쪽에 소스가 있는 것이 다른 쪽의
결손을 덮는다. **그 결손이 이 파일의 산출이다.**

**가중의 소스 없음이 이 파일의 중심이다.** 감독 공시가 자산군별 가중자산 총액과 밀도와 부도확률
대역별 가중평균까지만 요구하므로 외부 관측자가 개별 자산의 가중을 복원할 수 없고, 그 값을 추정하는
일이 구멍으로 등재되어 있다. **회계층이 그 값을 외생 매개변수로 받는 사유가 이 결손이다.**

**공시 경로는 비형식 개념에 대응하지 않는다.** 측정 사상을 담는 그릇이므로 형식화의 표현 수단이며
용어집의 선행 등록을 요구하지 않는다(D-7). 용어집에 서는 것은 그 경로가 측정하는 개념과 공시 자신
이고, 이 층의 구조는 그 둘을 잇는 명세다.

**주체의 타입을 매개변수로 받는다.** 금액을 드는 칸이 없으므로 이 파일에는 수 타입도 수치 리터럴도
없다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/
import CrisisFramework.Definition.HolderMandate

open CrisisFramework.Definition

namespace CrisisFramework.Observation

/--
보유자 위임과 가중의 공시 경로.

**대응 비형식 개념:** 어느 공시가 한 주체의 보유자 위임과 그 위임이 묶이는 제약의 재료를 내는가.
위임의 배정과 개별 자산의 가중과 위임별 보유분이 서로 다른 공시에서 나오므로 경로가 그 셋을 가르는
지를 칸으로 받는다.

**이 정의가 배제하는 사례:**
자금순환표가 레포를 다루는 방식. 그 표가 레포를 순액으로만 주고 증권대차를 사실상 제외하므로 딜러가
자기 재고를 대려고 조달한 몫만 잡히고 현금풀에서 레버리지 채권 포트폴리오로 중개하는 훨씬 큰 총액이
빠지며(Pozsar 2015), 이 구조의 칸이 보는 것은 주체와 가중이어서 그 표로는 어느 칸도 채워지지 않는다.
조달처: E-53 §2-4 「자금순환표가 레포를 순액으로만 주고 증권대차를 사실상 제외하므로」

**기각한 대체 정의:**
칸을 하나만 두어 위임의 재료 전체를 내는지로 받는 안. 위임의 배정과 가중과 보유분이 소스가 서로 다르고
그 가운데 배정만 부분적으로 읽히므로, 한 칸으로 두면 읽히는 몫이 읽히지 않는 둘의 결손을 덮는다.
긴급 조달 접근의 공시 경로가 받침을 두 칸으로 가른 사유가 이 자리에 그대로 걸린다. 위임 셋마다 칸을
하나씩 두어 셋으로 받는 안도 기각했다. 세 위임의 배정이 같은 공시에서 나오거나 어느 공시에서도
나오지 않으므로, 셋으로 두면 같은 소스를 세 칸이 나누어 받고 그 가름의 근거가 어디에도 없다.

**값을 담지 않는다.**
-/
-- DD:CF-2195
structure HolderMandateChannel (Entity : Type) where
  /-- 그 주체가 어느 보유자 위임에 서는지를 이 경로가 보는가. -/
  coversMandateAssignment : Entity → Bool
  /-- 이 경로가 개별 자산의 가중을 내는가. 자산군별 가중평균은 이 칸을 채우지 않는다. -/
  resolvesAssetWeight : Bool
  /-- 이 경로가 위임별 보유분을 내는가. 보유자 부문별 금액만으로는 이 칸이 채워지지 않는다. -/
  resolvesHolderShare : Bool

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `HolderMandateChannel` 이 비어 있지 않음을 보인다. 어느 주체도 보지 않고
세 칸을 하나도 내지 않는 경로다.
-/
-- DD:CF-2195
def HolderMandateChannel.noSource {Entity : Type} : HolderMandateChannel Entity where
  coversMandateAssignment := fun _ => false
  resolvesAssetWeight := false
  resolvesHolderShare := false

/--
감독 공시를 보유자 위임과 가중의 경로로 읽은 것.

**대응 비형식 개념:** 감독 규범이 요구하는 자본과 위험가중자산의 공시를 보유자 위임과 가중을 읽는
경로로 세운 것. 그 공시가 가중자산의 재료로 보이나 자산군별 총계와 밀도까지만 내므로 개별 자산의
가중을 가르지 않는다.

**세 칸이 모두 거짓인 것이 이 선언의 산출이다.** 소스 없음을 경로마다 등재하는 자리이며, 아무 주체도
보지 않는 경로가 비어 있지 않음을 보이는 witness 와 값이 같아도 드는 것이 다르다. 앞은 구조가 비어
있지 않음을 보이고 이것은 실재하는 공시가 그 칸을 내지 못함을 보인다.

**이 정의가 배제하는 사례:**
딜러가 누구에게 자금을 대는지의 정보가 제한적이라고 원전이 적은 자리. 모기지 리츠의 규모만 자금순환표에
서고 그 밖의 헤지펀드와 뮤추얼펀드와 분리계정이 딜러 대차대조표의 큰 소비자라는 것을 그 통계가 전혀
시사하지 않는다고 적으므로(Pozsar 2015), 이 선언이 드는 결손은 감독 공시 쪽의 것이고 자금순환표
쪽의 것이 아니다.
조달처: E-53 §2-4 「딜러가 자기 재고를 대려고 조달한 몫은 잡히고」

**기각한 대체 정의:**
가중 칸을 참으로 두는 안. 감독 공시가 자산군별 가중자산 총액과 그것을 노출액으로 나눈 밀도와 부도확률
대역별 가중평균을 내므로 가중의 재료가 있는 것으로 보이나, 그것은 군 단위의 평균이고 가중 함수가
비선형이어서 그 평균에서 개별 가중이 되돌려지지 않는다. 위임 배정 칸을 참으로 두는 안도 기각했다. 그
공시의 보고 주체가 감독 대상 기관이므로 그 주체가 어느 부류인지는 공시의 존재로 읽히나, 그 부류가 세
위임 가운데 어느 것에 드는지는 원전의 등가 서술이 세운 것이고 공시가 세운 것이 아니다.

**값을 담지 않는다.**
-/
-- DD:CF-2196
def supervisoryCapitalDisclosureChannel {Entity : Type} : HolderMandateChannel Entity where
  coversMandateAssignment := fun _ => false
  resolvesAssetWeight := false
  resolvesHolderShare := false

/--
보유자 통계를 보유자 위임과 가중의 경로로 읽은 것.

**대응 비형식 개념:** 국채의 보유자를 부문별로 드는 표를 보유자 위임과 가중을 읽는 경로로 세운 것.
그 표가 누가 얼마를 들었는지의 재료로 보이나 부문이 위임으로 갈리지 않으므로 위임별 보유분을 내지
않는다.

**세 칸이 모두 거짓인 것이 이 선언의 산출이다.** 감독 공시의 경로와 값이 같아도 드는 것이 다르다.
앞은 가중을 내지 못하는 공시이고 이것은 보유분을 위임으로 가르지 못하는 공시이며, 두 결손이 서로를
덮지 않게 경로를 둘로 둔다.

**이 정의가 배제하는 사례:**
그 표가 낳는 오독. 표를 보면 국채의 최대 레버리지 투자자가 글로벌 은행과 브로커딜러로 보이면서
자산운용 복합체의 훨씬 큰 레버리지 채권 투자자 집단이 빠지므로(Pozsar 2015), 이 선언이 드는 것은
그 표에 금액이 없다는 것이 아니라 **그 금액이 위임으로 갈리지 않는다**는 것이다.
조달처: E-53 §2-4 「그 표를 보면 국채의 최대 레버리지 투자자가 글로벌 은행과 브로커딜러로 보이면서」

**기각한 대체 정의:**
보유분 칸을 참으로 두는 안. 그 표가 부문별 금액을 내므로 보유분의 재료가 있는 것으로 보이나, 부문의
가름이 기관 유형이고 위임이 아니어서 한 부문에 위임이 다른 주체가 함께 들며 그 표의 오독이 바로 그
어긋남에서 난다. 이 경로를 세우지 않고 감독 공시의 경로 하나로 갈음하는 안도 기각했다. 두 공시의
결손이 서로 다른 칸에 서므로 하나로 갈음하면 한 결손이 다른 결손을 덮는다.

**값을 담지 않는다.**
-/
-- DD:CF-2197
def holderStatisticsChannel {Entity : Type} : HolderMandateChannel Entity where
  coversMandateAssignment := fun _ => false
  resolvesAssetWeight := false
  resolvesHolderShare := false

/--
감독 공시와 보유자 통계는 보유자 위임의 어느 칸도 내지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
감독 공시가 개별 자산의 가중을 자산마다 내거나, 보유자 통계의 부문이 보유자 위임으로 갈리거나, 둘
가운데 하나가 주체를 세 위임에 배정하는 재료를 내야 한다. 그 공시들이 자산군별 평균과 기관 유형별
금액까지만 내므로, 이 명제가 거짓이면 그 공시가 지금 드는 것보다 가는 색인을 든다는 뜻이다.

**가정을 두지 않는다.**

**이 진술이 회계층의 가중 매개변수를 받친다.** 가중이 외생으로 들어오는 것이 형식화의 편의가 아니라
이 결손의 귀결이며, 그 값을 추정하는 일이 구멍으로 서 있다.
-/
-- DD:CF-2197
theorem holderMandateChannels_resolve_nothing {Entity : Type} :
    (∀ e : Entity,
      (supervisoryCapitalDisclosureChannel (Entity := Entity)).coversMandateAssignment e
        = false)
    ∧ (supervisoryCapitalDisclosureChannel (Entity := Entity)).resolvesAssetWeight = false
    ∧ (supervisoryCapitalDisclosureChannel (Entity := Entity)).resolvesHolderShare = false
    ∧ (∀ e : Entity,
        (holderStatisticsChannel (Entity := Entity)).coversMandateAssignment e = false)
    ∧ (holderStatisticsChannel (Entity := Entity)).resolvesAssetWeight = false
    ∧ (holderStatisticsChannel (Entity := Entity)).resolvesHolderShare = false := by
  -- 여섯 항이 전부 두 선언의 칸을 정의대로 펼친 값과 `false` 의 비교이므로 정의적 동등으로
  -- 닫는다. 두 전칭 항은 주체를 받아 상수 함수를 적용한 자리다. 전면 `simp` 를 쓰지 않는다.
  exact ⟨fun _ => rfl, rfl, rfl, fun _ => rfl, rfl, rfl⟩

end CrisisFramework.Observation
