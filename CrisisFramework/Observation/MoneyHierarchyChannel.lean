/-
관측층 — 화폐성 위계의 공시 경로

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 수를 쓰지 않는다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 예외),
      T-2(반증 조건), T-4(가정의 명시).

**받침을 두 칸으로 가른다.** 공적 백스톱이 명시적으로 받치는 것은 예금보험 가입 여부로 관측되고
묵시적으로만 받치는 것은 그렇지 않다. 한 칸으로 두면 앞쪽에 소스가 있는 것이 뒤쪽의 결손을 덮으며,
그 결손이 이 파일의 산출이다.

**주체와 시점의 타입을 매개변수로 받는다.** 강도를 드는 칸이 없으므로 이 파일에는 수 타입도
수치 리터럴도 없다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/
import CrisisFramework.Definition.Hierarchy
import CrisisFramework.Observation.CompetencyQuestion

open CrisisFramework.Definition

namespace CrisisFramework.Observation

/--
화폐성 위계의 공시 경로.

**대응 비형식 개념:** 어느 공시가 한 주체의 화폐자산과 그 액면가 약속 강도를 읽을 재료를
내는가. 강도가 떠받치는 자산의 종류와 공적 백스톱의 받침에서 나오므로 경로가 그 셋을 가르는지를
칸으로 받는다.

**이 정의가 배제하는 사례:**
2013년 사이프러스에서 대형 무부보 예금자가 손실을 입은 것. 원문의 각주가 규제당국이 은행을
정리할 때 늘 재량을 쥔다고 적는데(Pozsar 2014 각주 13), 이 구조는 공시가 무엇을 가르는지만
받으므로 그 재량이 어느 공시에도 서지 않는 것을 담지 않는다. 가르는 칸이 없다는 것과 그 값이
재량으로 정해진다는 것이 같은 거짓을 낸다.

**기각한 대체 정의:**
공적 백스톱의 받침을 한 칸으로 두는 안. 명시적 받침은 예금보험 가입 여부로 관측되고 묵시적
받침은 그렇지 않으므로, 한 칸으로 두면 앞쪽에 소스가 있는 것이 뒤쪽의 결손을 덮고 소스 없음의
등재를 잃는다. 경로가 그 청구권의 강도를 직접 드는 칸을 두는 안도 기각했다. 강도는 관측의
산출이고 경로는 그 산출을 낼 수 있는지를 드는 자리이므로, 강도를 직접 드는 칸을 두면 관측층이
값을 담는 것이 된다.

**값을 담지 않는다.**
-/
-- DD:CF-1168
structure HierarchyChannel (Entity : Type) where
  /-- 그 주체의 화폐자산을 이 경로가 보는가. -/
  coversEntity : Entity → Bool
  /-- 이 경로가 그 화폐자산을 떠받치는 것이 공적 자산인지 가르는가. -/
  resolvesAssetSide : Bool
  /-- 이 경로가 공적 백스톱의 명시적 받침을 가르는가. 예금보험 가입과 할인창구 접근이 그것이다. -/
  resolvesExplicitBackstop : Bool
  /-- 이 경로가 공적 백스톱의 묵시적 받침을 가르는가. 담보가 공개시장조작 적격이고 신용위험이
      없다는 데서 나오는 받침이며, 계약 문면에 없다. -/
  resolvesImplicitBackstop : Bool

/--
아무 주체도 보지 않는 경로. witness 이며 소스 없음의 기본값이다(A-3, D-8, L-14).

**무엇을 증거하는가.** `HierarchyChannel` 이 비어 있지 않음을 보인다. 어느 주체도 보지 않고
세 축을 하나도 가르지 않는 경로다.
-/
-- DD:CF-31
def HierarchyChannel.noSource {Entity : Type} : HierarchyChannel Entity where
  coversEntity := fun _ => false
  resolvesAssetSide := false
  resolvesExplicitBackstop := false
  resolvesImplicitBackstop := false

/--
이 경로가 두 주체의 상대 위치 판정의 입력을 낼 수 있는가.

**대응 비형식 개념:** 위계의 순서를 묻는 항이 한 시점에 주체 둘의 상대 위치를 묻는다. 그 판정이
서려면 경로가 두 주체를 보고 자산 측을 가르고 명시적 받침과 묵시적 받침을 모두 가르는 것이 함께
서야 한다.

**이 정의가 배제하는 사례:**
250,000 달러를 넘는 무부보예금. 그 청구권은 사적 자산이 떠받치고 발행 기관이 공적 유동성 풋에
접근하는데 명시적 신용 풋이 없어 순수 사적 화폐이므로(Pozsar 2014), 자산 측과 명시적 받침만 보는
경로는 그것을 부보 화폐와 가르지 못한다. 그래서 네 칸 가운데 하나라도 빠지면 이 판정이 서지 않고,
그 비대칭이 이 판정을 참 쪽으로만 서게 한다.

**기각한 대체 정의:**
판정 함수가 묵시적 받침을 가르는 칸을 요구하지 않는 안. 네 범주 가운데 둘이 묵시적 받침의 유무로
갈리므로 그 칸이 없으면 공적 그림자 화폐와 순수 사적 화폐를 가르지 못하고, 강도가 둘로만 서서
순서가 네 범주 위에 서지 않는다.
-/
-- DD:CF-1168
def HierarchyChannel.answersOrder {Entity : Type}
    (ch : HierarchyChannel Entity) (m n : Entity) : Bool :=
  ch.coversEntity m && ch.coversEntity n && ch.resolvesAssetSide
    && ch.resolvesExplicitBackstop && ch.resolvesImplicitBackstop

/--
자금순환표를 보는 경로.

**대응 비형식 개념:** 부문별 금융자산과 부채의 잔액을 수단별로 드는 공표 수치. 어느 부문이 어느
수단을 자산으로 드는지가 서므로 주체와 자산 측을 가르고, 예금의 부보 여부가 별도 공시에서 서므로
명시적 받침도 가른다.

**이 정의가 배제하는 사례:**
공적 그림자 화폐의 묵시적 받침. 원문이 그 받침을 담보가 공개시장조작 적격이고 신용위험이 없다는
데서 끌어내므로 계약 문면에 없고 공시가 그것을 가르는 칸을 갖지 않는다(Pozsar 2014). 그래서 이
경로는 네 칸 가운데 셋만 들고 상대 위치 판정의 입력을 내지 못한다. **구조는 섰고 그것을 재는
경로가 없다.**

**기각한 대체 정의:**
자금순환표 경로가 묵시적 받침을 가르는 칸을 참으로 드는 안. 그 칸을 참으로 두면 판정 함수가 참을
내고 답이 구조의 판정을 그대로 실어, 재는 경로가 없다는 사실이 소스 있음으로 바뀐다. 묵시적 받침은
그 자산이 실제로 담보로 받아들여지는지를 중앙은행이 그때 정하므로 공시의 칸이 아니라 재량의
결과다.

**이 값이 공시의 현행 입도에 매인다.** 묵시적 받침을 범주별로 가르는 공시가 서면 이 값이 낡고,
그 낡음이 해소를 알리는 신호다.
-/
-- DD:CF-1168
def flowOfFundsStrengthChannel {Entity : Type} : HierarchyChannel Entity where
  coversEntity := fun _ => true
  resolvesAssetSide := true
  resolvesExplicitBackstop := true
  resolvesImplicitBackstop := false

/--
`CQ-fin-8` 의 답 자리를 공시 경로 하나의 판독과 정의층의 보유 유도 순서로 채운다.

**대응 비형식 개념:** 그 항이 한 시점에 주체 둘의 상대 위치를 묻는다. 경로가 그 판정의 입력을
내지 못하면 답이 접히고, 입력을 내면 보유 유도 순서가 셋 가운데 하나를 낸다. 앞이 위에 있는
것과 아래에 있는 것과 둘이 동급인 것이다.

**동급을 거짓으로 내지 않는다.** 보유 유도 순서에서 동급이 되는 두 주체를 가르는 후보가 둘인데
어느 것도 구조에 서지 않으므로, 동급을 거짓으로 내면 구조가 재지 못하는 것을 재었다고 주장한다.
그 둘은 주체에 붙는 유동성 풋의 위계와 자산에 붙는 담보 설계의 상태 의존성이며, 색인이 달라
뒤를 쓰려면 보유로 한 겹 더 유도해야 한다. 그래서 그 자리는 구조가 그 대상을 담지 않는다는
까닭으로 접는다. 그 동급이 실제로 서는 쌍은 정의층의 반대칭성 부정 정리가 이미 든다.

**이 물음이 인자에 따라 두 축으로 갈린다.** 동급이 아닌 쌍에 대해서는 무엇을 재야 하는지가
전부 정해졌고 구조가 그것을 내므로 정의 공백을 벗어나며, 접히는 것은 공시가 묵시적 받침을
가르지 않기 때문이라 조달로 풀린다. 동급인 쌍에 대해서는 그것을 가를 순서가 형식층에 없으므로
정의 공백에 남는다.

**이 정의가 배제하는 사례:**
2013년 사이프러스에서 대형 무부보 예금자가 손실을 입은 것. 원문의 각주가 규제당국이 은행을
정리할 때 늘 재량을 쥐며 주권의 재정 능력과 의지가 실제 순위를 좌우한다고 적는다
(Pozsar 2014 각주 13). 이 조립은 경로의 칸과 강도의 비교만 읽으므로 그 재량이 순위를 뒤집는
것을 담지 않는다.

**기각한 대체 정의:**
동급을 거짓으로 접는 안. 물음이 앞의 주체가 위에 있는가를 묻고 동급이면 위에 있지 않은 것이
사실이나, 그 거짓은 뒤의 주체가 위에 있다는 것을 뜻하지 않으며 실물에서 그 둘은 동급이 아니다.
그 둘을 가르는 것이 구조 밖에 있으므로 거짓으로 접으면 구조가 재지 못하는 것을 재었다고
주장한다. 경로의 판정을 묻지 않고 구조의 판정만 내는 안도 기각했다. 경로가 묵시적 받침을
가르지 않으면 강도가 둘로만 서서 네 범주 위의 순서가 서지 않으므로, 그 판정을 앞에 두지 않으면
재는 자리가 없는 답이 값으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-1221
def monetaryHierarchyOrderFrom {Time Entity : Type}
    (ch : HierarchyChannel Entity) (M : Time → MoneyAsset Entity) :
    CQ.MonetaryHierarchyOrder Time Entity where
  answer := fun m n t =>
    if ch.answersOrder m n then
      if (M t).aboveOrEqual m n then
        if (M t).aboveOrEqual n m then .undetermined .structureLacksTarget
        else .holds
      else .fails
    else .undetermined .noMeasurementSource

/--
경로가 상대 위치 판정의 입력을 내지 못하면 답이 소스 없음으로 접힌다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
경로가 네 칸 가운데 하나라도 가르지 못하는데 답이 값을 내는 것이 관측되어야 한다. 그러면 그
답이 경로가 내지 않은 입력을 쓴 것이므로 이 조립이 경로를 읽지 않는다.

**가정과 그 배제 사례(T-4·T-5):** 경로가 두 주체에 대해 입력을 내지 못한다는 것을 가정으로
진술에 명시한다. 그 가정을 떼면 어느 경로에서도 답이 접혀야 하는데, 네 칸을 모두 가르는 경로가
서면 구조의 판정이 답으로 올라오므로 거짓이다. 가정은 그 자리를 배제한다.
-/
-- DD:CF-1221
theorem monetaryHierarchyOrderFrom_undetermined_of_no_source
    {Time Entity : Type} (ch : HierarchyChannel Entity) (M : Time → MoneyAsset Entity)
    (m n : Entity) (t : Time) (h : ch.answersOrder m n = false) :
    (monetaryHierarchyOrderFrom ch M).answer m n t
      = .undetermined .noMeasurementSource := by
  show (if ch.answersOrder m n = true then _ else _) = _
  rw [h]
  rfl

/--
경로가 입력을 내고 앞의 주체가 엄격히 위에 있으면 답이 참이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
앞의 주체가 뒤보다 아래에 있지 않고 뒤가 앞보다 아래에 있는데 답이 참이 아닌 것이 관측되어야
한다. 그러면 이 조립이 보유 유도 순서의 판정을 답으로 올리지 않는다.

**가정과 그 배제 사례(T-4·T-5):** 경로가 입력을 낸다는 것과 한 방향의 비교가 참이고 반대
방향이 거짓이라는 것을 가정으로 진술에 명시한다. 반대 방향의 가정을 떼면 동급인 쌍이 참을
내야 하는데 이 조립이 그 자리를 구조의 결손으로 접으므로 거짓이다. 가정은 그 자리를 배제한다.
-/
-- DD:CF-1221
theorem monetaryHierarchyOrderFrom_holds_of_strictly_above
    {Time Entity : Type} (ch : HierarchyChannel Entity) (M : Time → MoneyAsset Entity)
    (m n : Entity) (t : Time) (hch : ch.answersOrder m n = true)
    (hmn : (M t).aboveOrEqual m n = true) (hnm : (M t).aboveOrEqual n m = false) :
    (monetaryHierarchyOrderFrom ch M).answer m n t = .holds := by
  show (if ch.answersOrder m n = true then
          if (M t).aboveOrEqual m n = true then
            if (M t).aboveOrEqual n m = true then _ else _
          else _
        else _) = _
  rw [hch, hmn, hnm]
  rfl

/--
경로가 입력을 내고 앞의 주체가 아래에 있으면 답이 거짓이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
앞의 주체가 뒤보다 아래에 있는데 답이 거짓이 아닌 것이 관측되어야 한다. 그러면 이 조립이 그
방향의 판정을 답으로 올리지 않는다.

**가정과 그 배제 사례(T-4·T-5):** 경로가 입력을 낸다는 것과 한 방향의 비교가 거짓이라는 것을
가정으로 진술에 명시한다. 그 가정을 떼면 동급인 쌍과 앞이 위인 쌍이 거짓을 내야 하는데 이
조립이 그 둘을 다른 칸으로 보내므로 거짓이다. 가정은 그 자리를 배제한다. 반대 방향의 비교가
참이라는 것을 가정으로 더 들지 않는 까닭은 보유 유도 순서의 전체성이 그것을 이미 주므로 그
가정이 쓰이지 않는 것이다.
-/
-- DD:CF-1221
theorem monetaryHierarchyOrderFrom_fails_of_below
    {Time Entity : Type} (ch : HierarchyChannel Entity) (M : Time → MoneyAsset Entity)
    (m n : Entity) (t : Time) (hch : ch.answersOrder m n = true)
    (hmn : (M t).aboveOrEqual m n = false) :
    (monetaryHierarchyOrderFrom ch M).answer m n t = .fails := by
  show (if ch.answersOrder m n = true then
          if (M t).aboveOrEqual m n = true then _ else _
        else _) = _
  rw [hch, hmn]
  rfl

/--
경로가 입력을 내고 두 주체가 동급이면 답이 구조의 결손으로 접힌다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
양방향의 비교가 둘 다 참인데 답이 구조의 결손을 내지 않는 것이 관측되어야 한다. 그러면 이
조립이 동급을 참이나 거짓으로 접은 것이므로, 구조가 가르지 못하는 두 주체의 상대 위치를
재었다고 주장한다.

**가정과 그 배제 사례(T-4·T-5):** 경로가 입력을 낸다는 것과 양방향의 비교가 둘 다 참이라는
것을 가정으로 진술에 명시한다. 그 가정을 떼면 엄격히 위이거나 아래인 쌍이 구조의 결손을 내야
하는데 이 조립이 그 둘을 참과 거짓으로 내므로 거짓이다. 가정은 그 자리를 배제한다. 그 가정이
충족되는 쌍이 실재하는 것은 정의층이 원문 표의 주체 다섯 위에서 반대칭성의 부정을 세워 이미
든다.
-/
-- DD:CF-1221
theorem monetaryHierarchyOrderFrom_tie_undetermined
    {Time Entity : Type} (ch : HierarchyChannel Entity) (M : Time → MoneyAsset Entity)
    (m n : Entity) (t : Time) (hch : ch.answersOrder m n = true)
    (hmn : (M t).aboveOrEqual m n = true) (hnm : (M t).aboveOrEqual n m = true) :
    (monetaryHierarchyOrderFrom ch M).answer m n t
      = .undetermined .structureLacksTarget := by
  show (if ch.answersOrder m n = true then
          if (M t).aboveOrEqual m n = true then
            if (M t).aboveOrEqual n m = true then _ else _
          else _
        else _) = _
  rw [hch, hmn, hnm]
  rfl

/--
자금순환표 경로에서는 어느 두 주체의 상대 위치도 소스 없음으로 접힌다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 경로가 공적 백스톱의 묵시적 받침을 가르는 칸을 참으로 드는 것이 관측되어야 한다. 그러면
묵시적 받침을 범주별로 가르는 공시가 선 것이므로 그 결손이 해소됐다.

**가정을 두지 않는다.**
-/
-- DD:CF-1222
theorem flowOfFundsStrengthChannel_order_undetermined
    {Time Entity : Type} (M : Time → MoneyAsset Entity) (m n : Entity) (t : Time) :
    (monetaryHierarchyOrderFrom flowOfFundsStrengthChannel M).answer m n t
      = .undetermined .noMeasurementSource := by
  exact monetaryHierarchyOrderFrom_undetermined_of_no_source
    flowOfFundsStrengthChannel M m n t rfl

end CrisisFramework.Observation
