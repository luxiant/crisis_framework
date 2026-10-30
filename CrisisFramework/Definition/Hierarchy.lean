/-
정의층 — 화폐성 위계

규율: L-10(정의층은 수를 쓰지 않는다. 시점 인덱스 ℕ 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족), C-3(판정은 계산으로 낸다),
      A-3(witness 의무), D-1·D-2(docstring 3항목), D-8(witness 예외),
      T-2(반증 조건), T-4(가정의 명시).

이 파일은 수를 한 번도 쓰지 않는다. 네 범주 위의 비교를 패턴 매칭의 `Bool` 반환 함수로 적으므로
순위의 공역이 설 자리가 없고, 그래서 무차원이 관례가 아니라 구조로 지켜진다.

**위계가 셋이고 색인이 셋이다.** 화폐의 위계는 청구권의 네 범주에 붙고, 유동성 풋의 위계는 주체에
붙고, 신용 풋의 위계는 청구권의 수단 종류에 붙는다. 이 파일이 세우는 것은 첫째와 그것에서 유도한
주체 순서이며, 둘째는 같은 층의 긴급 조달 모듈이 세우고 셋째는 구조에 서지 않고 구멍으로 등재되어
있다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Nat.Notation

namespace CrisisFramework.Definition

/--
액면가 약속의 강도.

**대응 비형식 개념:** 한 화폐 청구권이 액면가를 지급하겠다는 약속을 얼마나 강하게 하는가.
정부로부터의 근접성이며, 그 청구권을 떠받치는 자산의 종류와 공적 유동성 풋과 신용 풋이 그것을
명시적으로 받치는가 묵시적으로만 받치는가 받치지 않는가의 함수다.

**이 정의가 배제하는 사례:**
250,000 달러를 넘는 무부보예금. 그것을 발행하는 도매은행은 공적 유동성 풋에 접근하므로 원문의
매트릭스에서 공적 백스톱 열에 서는데, 명시적 공적 신용 풋이 없어 그 예금은 순수 사적 화폐다
(Pozsar 2014). 이 열거는 청구권을 가르므로 발행 기관의 배치를 담지 않으며, 한 기관이 서로 다른
범주의 청구권을 함께 발행하는 것이 그 자리에서 드러난다.

**기각한 대체 정의:**
자산의 종류를 드는 축과 공적 백스톱의 받침을 드는 축을 각각 열거로 세우고 네 범주를 그 두 축의
쌍으로 유도하는 안. 받침의 값이 자기 자신이 공적 주체인 것과 명시적인 것과 묵시적인 것과 전무인
것으로 넷이므로 곱이 여덟이 되어 네 범주 밖의 칸을 구조가 허용하며, 그 칸에 들어갈 청구권이
원문에 없다. 받침만 넷으로 세우고 자산의 종류를 그 받침에서 유도하는 안도 기각했다. 부보 화폐가
사적 자산을 떠받침으로 두고 공적 그림자 화폐가 공적 자산을 떠받침으로 두므로 두 축의 값이 서로를
정하지 않으며, 유도하면 그 어긋남이 구조에서 보이지 않게 된다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-1163
inductive ParStrength where
  /-- 순수 공적 화폐. 공적 자산이 떠받치며 중앙은행과 정부가 발행한다. -/
  | publicMoney
  /-- 부보 화폐. 사적 자산이 떠받치고 공적 유동성 풋과 신용 풋이 명시적으로 받친다. -/
  | insuredMoney
  /-- 공적 그림자 화폐. 공적 자산이 떠받치고 두 풋에 묵시적으로만 접근한다. -/
  | publicShadowMoney
  /-- 순수 사적 화폐. 사적 자산이 떠받치고 묵시적 접근조차 없다. -/
  | privateShadowMoney
  deriving DecidableEq, Repr

/--
앞의 강도가 뒤의 강도보다 약하지 않은가.

**대응 비형식 개념:** 두 화폐 청구권 가운데 어느 쪽의 액면가 약속이 더 강한가. 원문이 네 범주를
순수 공적과 부보와 공적 그림자와 순수 사적의 차례로 들면서 액면가 약속의 강도가 그 차례로
감소한다고 적고 그것을 화폐의 위계라 부른다(Pozsar 2014).

**이 정의가 배제하는 사례:**
레포와 머니펀드 사이의 더 정밀한 순위. 원문의 각주가 국채레포를 맨 위에 두고 정부전용 머니펀드와
프라임 머니펀드를 그 다음에 두고 민간레포를 맨 아래에 두는데(Pozsar 2014 각주 12), 그 넷 가운데
앞의 둘이 공적 그림자 화폐이고 뒤의 둘이 순수 사적 화폐이므로 이 비교가 범주 안의 순서를 담지
않는다.

**기각한 대체 정의:**
네 범주에 순위 함수를 두어 그 공역의 값으로 비교하는 안. 순위의 공역이 시점 인덱스가 아닌 자리의
자연수가 되어 정의층의 수 체계 제한을 어기며, 패턴 매칭으로 적으면 수를 쓸 수단 자체가 없다.
그리고 순위를 두면 그 값이 범주 사이의 간격을 뜻하는 것처럼 읽히는데 원문은 차례만 든다. 네 범주
위의 순서를 부분순서로 두고 비교 불가능한 쌍을 남기는 안도 기각했다. 두 축의 곱 순서로 읽으면
대각선의 두 범주가 비교 불가능해지는데, 원문은 백스톱이 공적인 둘을 자산이 사적인 쪽까지 앞세우는
차례를 본문으로 들고 그 근거를 정부 보험이 없으면 예금이 맨 위에서 맨 아래로 떨어진다는 데 둔다.
-/
-- DD:CF-1163
def ParStrength.atLeastAsStrong : ParStrength → ParStrength → Bool
  | .publicMoney, .publicMoney => true
  | .publicMoney, .insuredMoney => true
  | .publicMoney, .publicShadowMoney => true
  | .publicMoney, .privateShadowMoney => true
  | .insuredMoney, .publicMoney => false
  | .insuredMoney, .insuredMoney => true
  | .insuredMoney, .publicShadowMoney => true
  | .insuredMoney, .privateShadowMoney => true
  | .publicShadowMoney, .publicMoney => false
  | .publicShadowMoney, .insuredMoney => false
  | .publicShadowMoney, .publicShadowMoney => true
  | .publicShadowMoney, .privateShadowMoney => true
  | .privateShadowMoney, .publicMoney => false
  | .privateShadowMoney, .insuredMoney => false
  | .privateShadowMoney, .publicShadowMoney => false
  | .privateShadowMoney, .privateShadowMoney => true

/--
강도의 비교는 반사적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
같은 범주의 청구권 둘 가운데 한쪽의 액면가 약속이 다른 쪽보다 약하다고 원문이 적어야 한다.
그러면 범주가 강도를 정하지 않으므로 이 열거가 강도의 열거가 아니다.

**가정을 두지 않는다.**
-/
-- DD:CF-1163
theorem ParStrength.atLeastAsStrong_refl (s : ParStrength) :
    s.atLeastAsStrong s = true := by
  cases s <;> rfl

/--
강도의 비교는 추이적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
범주 셋이 있어 첫째가 둘째보다 약하지 않고 둘째가 셋째보다 약하지 않은데 첫째가 셋째보다 약한
것이 관측되어야 한다. 원문이 네 범주를 한 차례로 들고 그 차례로 강도가 감소한다고 적으므로,
그런 셋이 서면 그 차례가 순서가 아니다.

**가정과 그 배제 사례(T-4·T-5):** 두 비교가 참이라는 것을 가정으로 진술에 명시한다. 그 가정을
떼면 어느 두 범주 사이에서도 비교가 참이어야 하는데, 원문이 네 범주를 공적 화폐에서 순수 사적
화폐까지 정부로부터의 근접성 한 차례로 들므로(Pozsar 2014) 맨 뒤가 맨 앞보다 약하지 않다는 것은
거짓이다. 가정은 그 자리를 배제한다.
-/
-- DD:CF-1163
theorem ParStrength.atLeastAsStrong_trans (a b c : ParStrength)
    (hab : a.atLeastAsStrong b = true) (hbc : b.atLeastAsStrong c = true) :
    a.atLeastAsStrong c = true := by
  revert hab hbc
  cases a <;> cases b <;> cases c <;> decide

/--
강도의 비교는 전체적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
범주 둘이 서로 비교되지 않는 것이 관측되어야 한다. 두 축의 곱 순서로 읽으면 부보 화폐와 공적
그림자 화폐가 그런 쌍이 되는데, 원문이 그 둘의 차례를 본문으로 들므로 이 명제가 거짓이면 그
본문을 잘못 읽은 것이다.

**가정을 두지 않는다.**
-/
-- DD:CF-1163
theorem ParStrength.atLeastAsStrong_total (a b : ParStrength) :
    a.atLeastAsStrong b = true ∨ b.atLeastAsStrong a = true := by
  cases a <;> cases b <;> decide

/--
강도의 비교는 반대칭적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
서로 다른 범주 둘이 양방향으로 약하지 않은 것이 관측되어야 한다. 그러면 그 둘의 액면가 약속이
같은 강도이므로 범주를 둘로 가른 근거가 사라진다.

**가정과 그 배제 사례(T-4·T-5):** 양방향의 비교가 둘 다 참이라는 것을 가정으로 진술에 명시한다.
그 가정을 떼면 두 범주가 언제나 같아야 하는데, 원문의 매트릭스가 공적 화폐를 공적 백스톱과 공적
자산이 함께 선 칸에 두고 순수 사적 화폐를 그 둘이 모두 없는 칸에 두므로(Pozsar 2014) 그 둘이
같다는 것은 거짓이다. 가정은 그 자리를 배제한다.
-/
-- DD:CF-1163
theorem ParStrength.atLeastAsStrong_antisymm (a b : ParStrength)
    (hab : a.atLeastAsStrong b = true) (hba : b.atLeastAsStrong a = true) :
    a = b := by
  revert hab hba
  cases a <;> cases b <;> decide

/--
그 주체에게 화폐인 것.

**대응 비형식 개념:** 한 주체가 자기보다 위계가 높은 주체의 화폐부채로 보유하는 것. 원문이
중앙은행을 뺀 모든 화폐 발행 기관이 위계에서 더 위에 있는 기관의 화폐부채를 자산으로 보유해야
한다고 적고, 은행에게는 지급준비금이고 딜러에게는 도매은행과 타 딜러와의 익일물 국채레포라고
표로 든다(Pozsar 2014).

**이 정의가 배제하는 사례:**
2013년 사이프러스에서 대형 무부보 예금자가 손실을 입은 것. 원문의 각주가 규제당국이 은행을
정리할 때 늘 재량을 쥐며 주권의 재정 능력과 의지가 실제 순위를 좌우한다고 적고 그 사례를
든다(Pozsar 2014 각주 13). 이 구조는 강도를 입력으로 받으므로 그 재량이 값을 움직이는 것을
담지 않는다.

**기각한 대체 정의:**
그 주체에게 화폐인 것을 강도의 집합으로 받는 안. 집합으로 받으면 그 주체의 위계 위치를 집합에서
대표값으로 접는 선택이 구조 안으로 들어오는데 그 선택의 근거가 원문에 없으며, 사상으로 받으면 그
결손이 구멍으로 선다. 보유를 두 주체 사이의 이항 판정으로 받고 그 판정에서 순서를 바로 유도하는
안도 기각했다. 이항 판정은 누가 누구의 화폐부채를 보유하는가만 들고 그것이 어느 강도의
청구권인지를 들지 않으므로, 서로를 보유하지 않는 두 주체의 상대 위치가 서지 않는다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-1164
structure MoneyAsset (Entity : Type) where
  /-- 그 주체에게 화폐인 것의 액면가 약속 강도. 더 위에 있는 주체의 화폐부채를 보유하지 않는
      주체는 값을 갖지 않으며, 원문이 그 자리를 중앙은행 하나로 한정한다. -/
  heldStrength : Entity → Option ParStrength

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `MoneyAsset` 이 비어 있지 않음을 보인다. 주체가 하나이고 그 주체가
화폐자산을 갖지 않는 사상이다.
-/
-- DD:CF-31
def MoneyAsset.trivial : MoneyAsset Unit where
  heldStrength := fun _ => none

/--
시점 인덱스를 갖는 화폐자산 사상의 족 (L-13).

**대응 비형식 개념:** 어느 시점에 각 주체에게 무엇이 화폐인가. 예금보험의 유무와 담보의
적격성이 시점에 따라 바뀌므로 같은 청구권의 강도가 옮겨 간다.

**이 정의가 배제하는 사례:**
한 주체가 시점 사이에 사라지거나 생기는 것. 이 족은 주체 타입을 시점과 무관하게 받으므로
노드 집합 자체가 바뀌는 것을 담지 않으며, 그것은 노드 집합의 족이 받는다.

**기각한 대체 정의:**
그 주체에게 화폐인 것을 시점과 무관한 하나의 사상으로 두는 안. 원문이 정부 보험이 없으면 예금이
위계의 맨 위에서 맨 아래로 떨어진다고 적으므로 같은 청구권의 강도가 시점에 따라 옮겨 가며,
시점을 받지 않으면 그 이동이 구조에 담기지 않는다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-1164
abbrev MoneyAssetFamily (Entity : Type) := ℕ → MoneyAsset Entity

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `MoneyAssetFamily` 가 비어 있지 않음을 보인다. 모든 시점에 같은 사상을
내는 상수 족이다.
-/
-- DD:CF-31
def MoneyAssetFamily.constant {Entity : Type} (M : MoneyAsset Entity) :
    MoneyAssetFamily Entity := fun _ => M

/--
앞의 주체가 뒤의 주체보다 아래에 있지 않은가.

**대응 비형식 개념:** 두 주체 가운데 어느 쪽이 화폐성 위계에서 더 위에 있는가. 원문이 유도의
방향을 보유로 주므로, 더 강한 화폐를 자기 화폐자산으로 드는 주체가 더 위에 선다. 화폐자산을 갖지
않는 주체가 최상단이다.

**이 정의가 배제하는 사례:**
은행이 지급준비금과 국채를 함께 보유하는 것. 원문의 표가 노드마다 그 노드에게 화폐인 것을 하나씩
드는데 실물에서는 한 주체가 서로 다른 강도의 화폐자산을 함께 들며, 이 판정은 사상이 내는 한 값만
읽으므로 그 선택이 구조 밖에 있다.

**기각한 대체 정의:**
주체의 순서를 그 주체가 발행하는 청구권의 위계 위치에서 유도하는 안. 같은 딜러 법인의
정부데스크와 크레딧데스크가 매트릭스의 서로 다른 사분면에 놓이므로 발행으로 유도하면 한 주체가 두
자리를 차지하며, 보유로 유도하면 각 데스크가 보유하는 것으로 정렬되어 그 벽에 걸리지 않는다.
보유하는 것이 없는 자리를 최하단으로 두는 안도 기각했다. 원문이 중앙은행만 더 위에 있는 기관의
화폐부채를 보유하지 않는다고 적으므로 그 자리가 최상단이며, 최하단으로 두면 순서가 뒤집힌다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-1164
def MoneyAsset.aboveOrEqual {Entity : Type} (M : MoneyAsset Entity) (m n : Entity) : Bool :=
  match M.heldStrength m, M.heldStrength n with
  | none, none => true
  | none, some _ => true
  | some _, none => false
  | some a, some b => a.atLeastAsStrong b

/--
보유 유도 순서는 반사적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
한 주체가 자기보다 아래에 있다고 판정되어야 한다. 그러면 그 판정이 한 주체의 화폐자산을 두 값으로
읽은 것이므로 사상이 함수가 아니다.

**가정을 두지 않는다.**
-/
-- DD:CF-1165
theorem MoneyAsset.aboveOrEqual_refl {Entity : Type} (M : MoneyAsset Entity) (m : Entity) :
    M.aboveOrEqual m m = true := by
  unfold MoneyAsset.aboveOrEqual
  cases h : M.heldStrength m with
  | none => rfl
  | some a => cases a <;> rfl

/--
보유 유도 순서는 추이적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
주체 셋이 있어 첫째가 둘째보다 아래에 있지 않고 둘째가 셋째보다 아래에 있지 않은데 첫째가
셋째보다 아래에 있는 것이 관측되어야 한다. 그러면 강도 위의 비교가 추이적이지 않다.

**가정과 그 배제 사례(T-4·T-5):** 세 주체 사이의 두 비교가 참이라는 것을 가정으로 진술에
명시한다. 그 가정을 떼면 보유하는 것이 있는 주체가 보유하는 것이 없는 주체보다 위에 있어야
하는데, 이 판정이 보유하는 것이 없는 자리를 최상단으로 두므로 그 자리를 아래에 둔 비교는 거짓을
낸다. 중앙은행이 그 자리이고 원문이 위계 최상단을 그 기능으로 가른다(Pozsar 2014). 가정은 그
자리를 배제한다.
-/
-- DD:CF-1165
theorem MoneyAsset.aboveOrEqual_trans {Entity : Type} (M : MoneyAsset Entity)
    (a b c : Entity) (hab : M.aboveOrEqual a b = true) (hbc : M.aboveOrEqual b c = true) :
    M.aboveOrEqual a c = true := by
  revert hab hbc
  unfold MoneyAsset.aboveOrEqual
  cases ha : M.heldStrength a with
  | none =>
    intro _ _
    cases hc : M.heldStrength c with
    | none => rfl
    | some _ => rfl
  | some x =>
    cases hb : M.heldStrength b with
    | none => intro h _; exact Bool.noConfusion h
    | some y =>
      cases hc : M.heldStrength c with
      | none => intro _ h; exact Bool.noConfusion h
      | some z => exact ParStrength.atLeastAsStrong_trans x y z

/--
보유 유도 순서는 전체적이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
주체 둘이 서로 비교되지 않는 것이 관측되어야 한다. 그러면 그 둘의 화폐자산 가운데 적어도 하나가
강도의 네 범주 밖에 있다.

**가정을 두지 않는다.**
-/
-- DD:CF-1165
theorem MoneyAsset.aboveOrEqual_total {Entity : Type} (M : MoneyAsset Entity)
    (m n : Entity) :
    M.aboveOrEqual m n = true ∨ M.aboveOrEqual n m = true := by
  unfold MoneyAsset.aboveOrEqual
  cases hm : M.heldStrength m with
  | none =>
    cases hn : M.heldStrength n with
    | none => exact Or.inl rfl
    | some _ => exact Or.inl rfl
  | some a =>
    cases hn : M.heldStrength n with
    | none => exact Or.inr rfl
    | some b => exact ParStrength.atLeastAsStrong_total a b

/--
원문의 화폐 매트릭스가 드는 주체.

**대응 비형식 개념:** 없다. 이 열거는 원문의 표를 그대로 옮겨 반례의 재료로 쓰는 표현 수단이며,
기관 유형은 노드에 대한 관측 투영이므로(J-1) 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
역외 달러 수단과 무부보예금 밖의 사적 어음. 원문이 그 둘을 매트릭스에서 빼면서 온쇼어 투자자의
관점에서 안전자산 위계의 부차적 수단이라 적고 수익을 높이려고 신용위험을 지는 수단이라
적는다(Pozsar 2014). 이 열거는 그 표의 핵심 기관만 담으므로 뺀 수단의 발행자가 서지 않는다.

**기각한 대체 정의:**
반례의 주체를 매개변수로 받고 원문 표의 값을 호출하는 쪽이 넣게 하는 안. 매개변수로 받으면 반례가
참인 까닭이 호출하는 쪽의 값에 걸려 그 값이 리포에 남지 않으며, 실제 사례를 요구하는 조항이 그
사실성을 확인한 쪽만 쓸 수 있게 하므로 열거로 세워야 그 값이 선언으로 남는다.
-/
-- DD:CF-1165
inductive MoneyMatrixEntity where
  /-- 중앙은행. 더 위에 있는 주체의 화폐부채를 보유하지 않는다. -/
  | centralBank
  /-- 소매·도매 은행. 중앙은행 지급준비금을 화폐자산으로 든다. -/
  | bank
  /-- 딜러 은행의 정부데스크. 익일물 국채레포를 화폐자산으로 든다. -/
  | governmentDesk
  /-- 정부전용 머니펀드. 딜러 정부데스크가 발행한 익일물 국채레포를 화폐자산으로 든다. -/
  | governmentOnlyFund
  /-- 프라임 머니펀드. 딜러 크레딧데스크가 발행한 익일물 민간레포를 화폐자산으로 든다. -/
  | primeFund
  deriving DecidableEq, Repr

/--
원문 표가 드는 주체별 화폐자산의 강도.

**대응 비형식 개념:** 원문이 노드마다 그 노드에게 화폐인 것을 하나씩 든 표. 그 표의 값을 강도로
옮긴 것이며, 은행의 지급준비금이 순수 공적이고 두 중간 주체의 익일물 국채레포가 공적 그림자이며
프라임 머니펀드의 익일물 민간레포가 순수 사적이다(Pozsar 2014).

**이 정의가 배제하는 사례:**
2008년 10월 연준이 기업어음 매입 기구를 세워 시장이 팔고 있는 것을 사겠다고 약속한 것. 최상단을
기능으로 정의한 결정이 그 기능을 드는데(J-4), 이 족은 중앙은행을 화폐자산을 갖지 않는 자리로만
담으므로 그 기능을 담지 못한다. 최상단이 위가 없는 주체로만 표현된다.

**기각한 대체 정의:**
반례를 이름 없는 진술 안에서만 구성하고 원문 표의 값을 선언으로 두지 않는 안. 값이 선언으로 서지
않으면 그 표를 뒤의 페이즈가 다시 쓸 수 없고, 변이 검사가 이름 없는 진술과 명명된 정리에서 서로
다른 것을 잡으므로 둘 다 두는 것이 값싸다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-1165
def moneyMatrixAssetFamily : MoneyAssetFamily MoneyMatrixEntity :=
  MoneyAssetFamily.constant
    { heldStrength := fun e =>
        match e with
        | .centralBank => none
        | .bank => some .publicMoney
        | .governmentDesk => some .publicShadowMoney
        | .governmentOnlyFund => some .publicShadowMoney
        | .primeFund => some .privateShadowMoney }

/--
보유 유도 순서는 반대칭적이지 않다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
원문의 표에서 서로 다른 두 주체가 같은 강도의 화폐자산을 드는 자리가 없어야 한다. 딜러
정부데스크와 정부전용 머니펀드가 둘 다 익일물 국채레포를 화폐자산으로 들므로, 이 명제가 거짓이면
그 둘 가운데 하나의 화폐자산을 잘못 옮긴 것이다.

**가정을 두지 않는다.**
-/
-- DD:CF-1165
theorem aboveOrEqual_not_antisymm :
    ¬ (∀ m n : MoneyMatrixEntity,
        (moneyMatrixAssetFamily 0).aboveOrEqual m n = true →
        (moneyMatrixAssetFamily 0).aboveOrEqual n m = true →
        m = n) := by
  intro h
  exact absurd (h .governmentDesk .governmentOnlyFund (by decide) (by decide))
    (by decide)

end CrisisFramework.Definition
