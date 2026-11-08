/-
정의층 — 주체의 통화 축별 공적 유동성 풋 도달

규율: L-10(정의층은 무차원이며 시점 인덱스만 예외), L-13(시점 인덱스를 갖는 족),
      C-1·C-2(비구성적 요소 금지), C-3(판정 술어의 Decidable), A-3(witness 의무),
      D-1·D-2(docstring 3항목), D-3(배제 사례의 조달처), D-7(선행 등록),
      D-8(witness 예외), T-2(반증 조건), T-4(가정의 명시), T-6(존재 형태).

**이 파일이 공적 유동성 풋 도달을 주체와 통화의 쌍에 붙인다.** 단계가 통화를 받지 않고 제약의 부채
측 한도가 통화로 색인되므로 그 둘을 잇는 자리가 따로 선다. 자국통화 축의 조립과 중앙은행 사이 교환을
더한 조립을 가르고 앞이 뒤에 포함됨을 정리로 든다.

**수치 리터럴과 수 타입을 쓰지 않는다.** 주체와 통화의 타입을 매개변수로 받으며 약정의 수 체계도
매개변수다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.EmergencyFunding
import CrisisFramework.Definition.DomesticCurrency
import CrisisFramework.Definition.CentralBankSwapLine

namespace CrisisFramework.Definition

/--
주체의 통화 축별 공적 유동성 풋 도달.

**대응 비형식 개념:** 한 주체가 어느 통화에서 중앙은행이 집행하는 유동성 수단에 닿는가.
공적 풋에 닿는 것이 자국통화 축에서 바로 서고 외화 축에서는 중앙은행 사이의 교환을 거치므로, 그
도달이 주체와 통화의 쌍에 붙는다.

**이 정의가 배제하는 사례:**
한 중앙은행의 담보 정책이 담보의 통화가 대출의 통화와 다를 때 할인율에 가산을 붙이고 통화 쌍마다 그
가산을 따로 두는 것. 그 자리가 통화의 불일치를 적격성의 가름이 아니라 적격한 것의 값으로 받으므로,
이 구조가 받는 통화 축은 그 값의 축이 아니라 도달의 축이다. 그래서 이 구조는 어느 통화에서 얼마나
깎이는지를 담지 않는다.
조달처: E-49 §11-5 「담보의 통화가 대출의 통화와 다를 때」

**기각한 대체 정의:**
도달을 주체 하나에만 붙이고 통화를 받지 않는 안. 단계가 통화를 받지 않으므로 그 꼴이 짧아지나,
제약의 부채 측 한도가 통화로 색인되어 있어 통화를 받지 않으면 그 한도를 넓히는 분기가 통화 축을
잃는다. 도달을 통화 하나에만 붙이고 주체를 받지 않는 안도 기각했다. 같은 통화에서 어느 주체는 닿고
어느 주체는 닿지 않는 것이 단계 배정에서 오므로, 주체를 받지 않으면 그 가름이 사라진다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3078
structure PublicPutAccess (Entity Currency : Type) where
  /-- 그 주체가 그 통화 축에서 공적 유동성 풋에 닿는가. -/
  reachesIn : Entity → Currency → Bool

/--
witness 인스턴스 (A-3).

**무엇을 증거하는가.** `PublicPutAccess` 가 비어 있지 않음을 보인다. 어느 주체도 어느
통화에서도 공적 유동성 풋에 닿지 않는 배정이다.
-/
-- DD:CF-3078
def PublicPutAccess.trivial : PublicPutAccess Unit Unit where
  reachesIn := fun _ _ => false

/--
자국통화 축의 도달만으로 조립한 배정.

**대응 비형식 개념:** 한 주체가 자기 자국통화에서만 공적 유동성 풋에 닿는다고 볼 때의 배정.
최후대출자 접근이 그 관할권의 중앙은행에서 오고 통화 백스톱이 그 주권의 선택권이므로, 외화 축을
빼면 그 도달이 단계와 자국통화 배정의 논리곱으로 선다.

**이 정의가 배제하는 사례:**
한 중앙은행의 적격 담보 집합이 비영 위험가중 국가의 자국통화 국채를 범주로 드는 것. 발행자와 표시
통화의 관계가 적격성의 조건으로 서는 자리이며, 이 조립은 그 관계를 보유자 쪽에서 받아 보유자에게
그 통화가 자국통화인가로 둔다. 그래서 이 조립은 발행자 쪽의 그 관계를 담지 않는다.
조달처: E-49 §2-1 「비0% 위험가중 국가의 자국통화 국채」

**기각한 대체 정의:**
자국통화 배정의 관할권 기준을 이 조립이 고정하는 안. 기준이 소재지인가 설립지인가에 따라 같은 주체의
자국통화가 달라지므로 그 선택이 도달을 바꾸나, 그 기준은 자국통화 배정이 자기 필드로 이미 들고
이 조립이 그것을 고정하면 같은 축이 두 자리에 선다. 단계를 받지 않고 자국통화 배정만으로 조립하는
안도 기각했다. 그러면 어느 단계의 주체든 자기 자국통화에서 공적 풋에 닿게 되어, 머니펀드와 딜러가
어느 공적 풋에도 닿지 않는다는 원문의 묶음이 구조에서 사라진다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-3078
def PublicPutAccess.ofDomestic {Entity Currency : Type}
    (A : EmergencyFundingAccess Entity) (D : DomesticCurrencyMap Entity Currency) :
    PublicPutAccess Entity Currency where
  reachesIn := fun n c => A.reachesPublicPut n && D.isDomestic n c

/--
자국통화 축과 중앙은행 사이 교환의 도달을 함께 받아 조립한 배정.

**대응 비형식 개념:** 한 주체가 자기 자국통화에서 바로 닿거나 중앙은행 사이의 교환이
공급하는 외화의 도달 범위 안에 있을 때의 배정. 공급하는 쪽의 질의응답이 공급의 층과 재대출의 층을
가르고 그 조건을 수취자가 정하므로, 외화 축의 도달이 약정과 전대 적격성의 합으로 선다.

**이 정의가 배제하는 사례:**
공급하는 쪽의 질의응답이 공급의 층과 재대출의 층을 가르고 그 조건을 정하는 주체와 공표하는 주체가
둘 다 수취자라고 적는 것. 그래서 외화 축의 도달이 공급자의 공시로는 서지 않고 수취자의 공시를 거치며,
이 조립은 그 두 층을 약정의 도달 술어에 맡기고 자기가 다시 가르지 않는다.
조달처: E-61 §6 「그래서 공급의 층과 재대출의 층이 갈리고, 조건을 정하는 주체와 그 조건을 공표하는 주체가 둘 다 수취자다」

**기각한 대체 정의:**
약정의 집합을 색인을 가진 구조로 받는 안. 그 꼴이 한 시점의 약정 전량을 드는 구조와 맞으나, 그
색인이 유한 집합이어서 그 위의 존재를 Bool 로 접으려면 판정 인스턴스가 따로 서야 하고 그 자리가
관측층의 공시 경로가 목록으로 접은 선례와 갈린다. 공급되는 통화가 묻는 통화와 같은지를 보지 않고
약정의 도달 술어만 쓰는 안도 기각했다. 그 술어가 수취자와 전대 적격만 보고 공급 통화를 보지 않으므로,
같은지를 보지 않으면 다른 통화를 공급하는 약정이 그 통화의 도달을 내게 된다.

**수 체계를 매개변수로 받는다.**
-/
-- DD:CF-3078
def PublicPutAccess.ofDomesticAndSwap {Entity Currency Num Obs : Type}
    [DecidableEq Entity] [DecidableEq Currency]
    (A : EmergencyFundingAccess Entity) (D : DomesticCurrencyMap Entity Currency)
    (lines : List (CentralBankSwapLine Entity Currency Num Obs))
    (E : OnlendingEligibility Entity Currency) :
    PublicPutAccess Entity Currency where
  reachesIn := fun n c =>
    A.reachesPublicPut n &&
      (D.isDomestic n c ||
        lines.any (fun s => decide (s.suppliedCurrency = c) && s.reaches E n))

/--
자국통화 축의 도달이 교환을 더한 도달에 포함된다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
자기 자국통화에서 공적 풋에 닿는 주체가 교환을 더한 조립에서는 닿지 않아야 한다. 뒤의 조립이 앞의
조건을 논리합의 왼쪽으로 그대로 들므로, 이 명제가 거짓이면 그 논리합의 왼쪽이 참일 때도 전체가
거짓이라는 뜻이다.

**가정과 그 배제 사례(T-4·T-5):** 자국통화 축의 조립에서 그 주체가 그 통화에 닿는다는 가정을 둔다.
그 가정이 배제하는 것은 닿지 않는 자리이며, 거기서는 교환을 더한 조립이 참일 수도 거짓일 수도 있어
포함이 한 방향으로만 선다.

**T-3 분류:** 기여다. 통화 축의 비대칭이 구조에 서는 자리이며, 외화 축을 더하는 것이 자국통화 축의
도달을 좁히지 않는다는 것을 이 진술이 든다.
-/
-- DD:CF-3078
theorem PublicPutAccess.ofDomestic_reaches_imp {Entity Currency Num Obs : Type}
    [DecidableEq Entity] [DecidableEq Currency]
    (A : EmergencyFundingAccess Entity) (D : DomesticCurrencyMap Entity Currency)
    (lines : List (CentralBankSwapLine Entity Currency Num Obs))
    (E : OnlendingEligibility Entity Currency) (n : Entity) (c : Currency)
    (h : (PublicPutAccess.ofDomestic A D).reachesIn n c = true) :
    (PublicPutAccess.ofDomesticAndSwap A D lines E).reachesIn n c = true := by
  have hAD : (A.reachesPublicPut n && D.isDomestic n c) = true := h
  rw [Bool.and_eq_true] at hAD
  show (A.reachesPublicPut n &&
      (D.isDomestic n c ||
        lines.any (fun s => decide (s.suppliedCurrency = c) && s.reaches E n))) = true
  rw [Bool.and_eq_true, Bool.or_eq_true]
  exact ⟨hAD.1, Or.inl hAD.2⟩

end CrisisFramework.Definition
