/-
회계층 — 상환과 조정

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(총액 기준으로 닫고 순액으로 닫지 않는다),
      C-9(전면 `simp` 금지), A-6(기준선 차분), T-2(반증 조건), T-4(가정의 명시),
      T-6(존재 형태).

**수 체계: `ℤ`.** 정의층의 `Claim` 이 수 체계를 매개변수로 받으므로 이 파일이 그 자리에 `ℤ` 를
넣는다. 금액이 `Term ℤ Obs` 이고 그 값을 그 시점의 판독에서 얻으므로 두 총계가 환경을 받는다.

**두 판정이 총액을 받고 총계를 받지 않는다.** 지급능력과 인출 충족의 판정이 각각 정수 둘을
받는다. 통화로 색인된 총계를 받아 판정 안에서 합하면 그 합이 통화를 가로지르므로 L-12 가 막는
환산이 함수 안에 숨는다. 가로지르지 않았음을 호출하는 쪽이 보장하며, 가로지르는 판정이 환산 없이
설 수 있는지는 구멍으로 등재되어 있다.

**비율은 정본이 아니다.** 원 문헌이 지급능력을 자기자본의 부호로 쓰고 인출 충족을 곱셈 부등식으로
쓰며, 회수율 문턱과 유동성 비율은 비교정학의 자리에서만 나온다. L-15 의 실무 조항이 그 둘을 유도
표현으로 둔다.

**자산 측의 구성이 이 파일에 서지 않는다.** 두 판정이 자산 총액과 당장 내줄 수 있는 것의 액수를
받을 뿐이고 그 값을 무엇으로 짓는지는 구멍으로 등재되어 있다. 현금성을 가르는 축과 자산을
구성하는 축이 뭉치의 편마다 달라 하나를 박으면 나머지가 표현되지 않는다.

**부채 총계는 통화로 색인된다.** 담보 장부의 총계들이 그 관례로 서 있으므로 같은 형을 쓴다.
만기는 둘로만 가르며 구간을 더 두는 것은 구멍이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Algebra.Order.BigOperators.Group.Finset
import CrisisFramework.Definition.Claim
import CrisisFramework.Definition.Hierarchy
import CrisisFramework.Definition.Trigger

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
지급능력.

**대응 비형식 개념:** 한 시점에 어느 주체의 자산 총액이 부채 총액에 모자라지 않은 상태. 원
문헌이 그 조건을 자기자본의 부호로 쓰고, 현금과 위험자산의 기재값을 더한 것이 단기 부채와 장기
부채를 더한 것에 미치지 못하면 지급불능이라 적는다.

**이 정의가 배제하는 사례:**
2020년 3월 미국 국채시장의 혼란(E-04 §2). 발원한 자산이 신용위험 없는 국채였으므로 보유 주체의
자산 총액이 부채 총액에 미치지 못한 자리가 없었고, 이 판정은 그 구간 내내 참을 낸다. 자산 총액을
어느 가격으로 재는가가 이 판정 밖에 있으므로, 조달이 조여 매각이 일어나는 것과 이 판정이 거짓으로
바뀌는 것이 같은 시점에 서지 않는다.

**기각한 대체 정의:**
회수율이 문턱을 넘는가로 쓰는 안. 그 문턱이 부채와 보유량의 비이므로 나눗셈이 들고, 위험자산의
기재값을 회수율과 보유량으로 쪼개어 보유량이 선언에 서게 되는데 그 측정 대응이 서지 않았다.
통화별 총계를 받아 판정 안에서 합하는 안도 기각했다. 그 합이 통화를 가로지르므로 L-12 가 막는
환산이 함수 안에 숨는다.

**수 체계를 받지 않는다.** 두 인자가 `ℤ` 이며 회계층의 기본 수 체계다.
-/
-- DD:CF-1258
def isSolvent (assetTotal liabilityTotal : ℤ) : Bool :=
  decide (liabilityTotal ≤ assetTotal)

/--
인출 충족.

**대응 비형식 개념:** 한 구간에 돌려달라는 요구로 빠져나간 액수를 당장 내줄 수 있는 것으로 전부
맞출 수 있는 상태. 원 문헌이 인출 비율과 단기 부채의 곱을 보유 현금과 맞대어 그 부등식이 깨지면
매각이 일어난다고 적는다.

**이 정의가 배제하는 사례:**
노던록의 런을 채권자 측 제약의 타이트닝으로 재해석한 것(Adrian · Shin 2010 · E-03 §3-4).
그 자리에서 빠져나간 것이 예금자의 인출이
아니라 도매 채권자의 롤오버 거부였고, 만기가 와서 돌려준 것과 요구를 받아 돌려준 것이 금액으로
같아 이 판정은 둘을 가르지 않는다. 롤오버 거부가 요구인가는 이 판정 밖에 있다.

**기각한 대체 정의:**
보유 현금을 단기 부채로 나눈 비율이 인출 비율을 넘는가로 쓰는 안. 나눗셈이 둘 들고, 단기 부채가
영일 때 그 비율이 정의되지 않아 판정이 전 영역에서 서지 않는다. 두 액수를 받으면 그 자리에서
영이 정상값이다.

**수 체계를 받지 않는다.** 두 인자가 `ℤ` 이며 회계층의 기본 수 체계다.
-/
-- DD:CF-1260
def meetsWithdrawal (withdrawn cashLike : ℤ) : Bool :=
  decide (withdrawn ≤ cashLike)

/--
상환 실패.

**대응 비형식 개념:** 한 구간에 지급 의무가 선 액수를 그 구간에 내준 액수가 다 맞추지 못한 상태.
초석 명제의 넷째 절이 실제 상환 실패를 위계 하단에 두고 상단은 디폴트하지 않고 조정한다고 적으므로,
그 절이 가르는 두 상태 가운데 앞의 것이다.

**이 정의가 배제하는 사례:**
신용장에서 제시 서류가 조건과 불일치하여 개설은행이 지급을 거절한 것(UCP 600 제16조). 조건이
충족되지 않아 지급 의무가 발생하지 않았으므로 의무액이 영이고 이 판정이 거짓을 낸다. 그리고 은행이
정기예금의 조기 인출을 위약금 없이 허용해 약정 만기 전에 내준 것(바젤 III LCR 제83절)도 배제한다.
계약이 요구하지 않은 것을 내준 것이므로 내준 액수가 의무액을 넘어 이 판정이 거짓을 낸다.

**기각한 대체 정의:**
상환 실패를 세 경로로 분할하는 안. V-5 가 측정 대응이 다르지 않은 둘을 가르지 못하게 하고, 실패의
세 경로가 같은 데이터로 측정되어 그 분기가 확인되지 않은 것으로 남아 있다. 분할하면 판정이 셋으로
쪼개져 각각이 자기 인자를 받았을 것이므로 그 기각이 이 판정의 수를 정한다. 지급능력 판정을 부르는
안도 기각했다. 두 판정이 읽는 값이 다르고 서로를 함의하지 않으므로 부르면 자산 총액과 부채 총액이
이 판정의 서명에 들어오고, 그 둘이 읽히지 않는 자리에서 이 판정이 설 수 없게 된다.

**수 체계를 받지 않는다.** 두 인자가 `ℤ` 이며 회계층의 기본 수 체계다.
-/
-- DD:CF-1316
def failsRepayment (dueAmount paidAmount : ℤ) : Bool :=
  decide (paidAmount < dueAmount)

/--
부채 총계.

**대응 비형식 개념:** 한 시점에 어느 주체가 의무를 지는 청구권의 금액을 통화 c 로 모은 것.
지급능력 판정이 받는 뒤쪽 인자의 조달처다.

**이 정의가 배제하는 사례:**
암묵적 유동성 풋(Claessens · Pozsar · Ratnovski · Singh 2012). 시장 조달이 마르자 은행이
법적 의무 없이 자기 기구를 대차대조표로 되받은 자리인데, 그 받침이 청구권으로 서 있지 않으므로
이 합이 세지 못한다. 의무가 계약으로 서지 않는 받침은 구조 밖에 있다.

**기각한 대체 정의:**
통화를 받지 않는 단일 총계를 두는 안. 그 값이 통화를 가로지른 합이거나 통화가 하나인 경우로
접히는데, 앞은 L-12 가 금지하고 뒤는 통화 축을 별도 축으로 둔 결정이 배제한다. 담보 장부의
총계들이 통화를 받는 관례로 서 있어 리포 안에서 관례가 갈리기도 한다.
-/
-- DD:CF-1261
def liabilityTotalOf {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (c : Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).obligor = p ∧ (S.assign i).currency = c
     then evalTerm e (S.assign i).amount else 0)

/--
단기 부채 총계.

**대응 비형식 개념:** 부채 총계가 세는 것 가운데 유효기일이 기준 시점에서 지평 안에 드는 것만
모은 것. 원 문헌이 단기 부채와 장기 부채를 가르는 자리이며, 인출 충족 판정이 받는 액수가 그
가운데 실제로 빠져나간 몫이다.

**이 정의가 배제하는 사례:**
화환신용장의 유효기일(UCP 600 제7조 (b) · 제6조 (d)). 개설 시점에 의무가 서고 유효기일이
명시되어야 하나 실제로 언제 결제되는가는 서류가 언제 제시되는가에 달려 있으므로, 이 합이 가르는
것은 계약상 기일이고 유출이 일어나는 시점이 아니다. 지평 안에 드는 신용장이 그 구간에 결제되지
않을 수 있고 그 반대도 선다.

**기각한 대체 정의:**
만기를 구간 열거로 받는 안. 구간을 셋 이상으로 열거하면 그 열거가 비형식 개념에 대응하는 분할이
되어 용어집에 등록될 대상이 되는데, 그 구간이 공시의 다른 칸에서 읽히는지가 확인되지 않아 V-5 가
금지한 분할이 설 수 있다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.** 기준 시점과 지평이 그 자리에 선다.
-/
-- DD:CF-1261
def shortTermLiabilityOf {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (c : Currency) (t horizon : ℕ) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).obligor = p ∧ (S.assign i).currency = c
          ∧ (S.assign i).expiry ≤ t + horizon
     then evalTerm e (S.assign i).amount else 0)

/--
단기 부채는 부채 총계를 넘지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 유효기일이 지평 안에 드는 청구권의 금액을
모은 값이 그 주체의 같은 통화 부채 전량의 금액을 모은 값보다 큰 청구권 배치. 지평 안에 드는
청구권이 그 주체의 부채의 부분집합이므로 금액이 음수가 아닌 동안은 그런 배치가 설 수 없고,
반증은 음수 금액을 지닌 배치에서 온다.

**가정과 그 배제 사례(T-4·T-5):** 청구권의 금액이 음수가 아니라는 가정을 진술에 명시한다.
담보 계약의 두 양식이 신용보전금액을 익스포저에 독립금액을 더하고 문턱을 뺀 값으로 두고 음수가
되면 영으로 본다고 적으므로(ISDA Credit Support Annex), 그 식의 값은 음수가 될 수 있다. 그 식을
청구권의 금액으로 옮겨 적으면 가정이 깨지며, 가정은 그 자리를 배제한다.

**이 정리가 두 판정이 받는 인자를 잇는다.** 지급능력 판정이 부채 총계를 받고 인출 충족 판정이
그 가운데 단기 몫에서 나온 액수를 받으므로, 이 부등식이 없으면 두 판정이 서로 무관한 양을 받는
것으로 읽힌다.

**유한집합의 합 보조정리를 쓰지 않는다.** 핀된 판의 그 보조정리들이 선택공리를 끌어오는 것이
실측됐으므로 `Finset.cons_induction` 으로 세운다. 같은 형의 선례가 이 층에 이미 있다.
-/
-- DD:CF-1261
theorem shortTermLiabilityOf_le_liabilityTotalOf
    {Idx Party Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl)
    (S : ClaimSet Idx Party ℤ Obs Ext Lvl Currency)
    (p : Party) (c : Currency) (t horizon : ℕ)
    (hnn : ∀ i ∈ S.index, 0 ≤ evalTerm e (S.assign i).amount) :
    shortTermLiabilityOf e S p c t horizon ≤ liabilityTotalOf e S p c := by
  -- 두 총계가 같은 색인 위의 합이고 단기 쪽의 조건이 총계 쪽의 조건에 유효기일 판정을 하나 더
  -- 얹은 것이므로, 색인의 항마다 부등식을 세워 부분합으로 올린다. `linarith` 를 쓰지 않는다.
  -- 그 전술이 `ℤ` 위의 자명한 목표에서도 `Classical.choice` 를 끌어오는 것이 실측된 자리이고,
  -- 회계층 기준선이 `[propext, Quot.sound]` 이므로 그 한 번으로 A-6 의 초과가 선다.
  simp only [shortTermLiabilityOf, liabilityTotalOf]
  -- `Finset.sum_le_sum` 을 쓰지 않고 부분합 부등식을 색인의 귀납으로 직접 세운다. 그 보조정리가
  -- 선택공리에 의존하는 것이 실측돼 있고(`docs/baseline.md` §2-2), 쓰는 자리가 `ℤ` 위의 비음수
  -- 항 비교뿐이라 고전논리가 요구되지 않는다. 쓰는 부품 다섯이 전부 기준선 이하다.
  have key : ∀ (s : Finset Idx) (F G : Idx → ℤ),
      (∀ i ∈ s, F i ≤ G i) → ∑ i ∈ s, F i ≤ ∑ i ∈ s, G i := by
    intro s F G h
    induction s using Finset.cons_induction with
    | empty => rw [Finset.sum_empty, Finset.sum_empty]
    | cons a u ha ih =>
        rw [Finset.sum_cons, Finset.sum_cons]
        exact add_le_add (h a (Finset.mem_cons_self a u))
          (ih fun i hi => h i (Finset.mem_cons_of_mem hi))
  refine key _ _ _ fun i hi => ?_
  -- 세 조건이 다 서면 양변이 같은 금액이고, 유효기일 판정만 거짓이면 왼쪽이 영이어서 비음수
  -- 가정이 받는다. 배중률을 쓰지 않고 판정 명제를 `by_cases` 로 가르므로 기준선이 오르지 않는다.
  by_cases h₁ : (S.assign i).obligor = p ∧ (S.assign i).currency = c
      ∧ (S.assign i).expiry ≤ t + horizon
  · rw [if_pos h₁, if_pos (And.intro h₁.1 h₁.2.1)]
  · rw [if_neg h₁]
    by_cases h₂ : (S.assign i).obligor = p ∧ (S.assign i).currency = c
    · rw [if_pos h₂]
      exact hnn i hi
    · rw [if_neg h₂]

/--
인출을 맞추지 못했는데도 지급능력을 잃지 않고 자산이 줄어드는 자리가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 인출 충족 판정이 거짓을 내는 모든 배치에서
자산이 줄면 지급능력 판정이 거짓으로 바뀐다는 것. 그것이 관측되면 상단의 노드가 조정으로 살아
남는 자리가 없고 초석 명제의 뒷절이 무너진다. 원 문헌이 인출 요구가 보유 현금을 넘으면 매각이
일어나고 그 매각액이 한도 안이면 생존하며 그때 대차대조표가 매각 손실만큼 준다고 적으므로, 그
중간 상태가 이 진술이 주장하는 자리다.

**존재 형태로 진술하는 까닭(T-6):** 매각 손실의 크기와 부채가 얼마나 줄어드는가가 둘 다 외생이고
구조가 그 값을 담지 않는다. 전칭으로 세우면 그 외생값에 대한 가정을 진술에 얹어야 하고 T-4 가
그것을 명시하게 하므로 가정이 늘어 진술이 원 문헌의 모형 하나에 매인다. 존재로 세우면 그 상태가
실현 가능하다는 것만 주장하므로 모형에 매이지 않으며, 그 상태가 어느 조건에서 서는지는 전파를
다루는 아크가 받는다.

**가정을 두지 않는다.**

**조정이 무엇을 줄이는지는 이 진술이 들지 않는다.** 뭉치의 편마다 그 대상이 갈리고 B-7 이 그
갈림을 봉합하지 말라 하므로, 이 진술은 자산이 줄었다는 것과 지급능력이 유지됐다는 것만 든다.
그 감소의 까닭을 가르는 축은 구멍으로 등재되어 있다.

**이 진술 바깥에 서는 조정이 있다.** 자산이 줄었다는 조건을 요구하므로, 조정이 부채 구성의
변화로만 일어나고 자산 총액이 움직이지 않는 자리를 이 진술이 담지 못한다. 한 편이 자기자본과
예금을 고정으로 두고 비핵심 부채만 움직이는 모형을 세우며, 그 편의 추출 기록이 조정을 자산이
아니라 부채 측에서 특정하는 첫 논문이라 적는다(Hahm · Shin · Shin 2012 · E-05 §1). 그 조정을
담으려면 부채의 구성을 가르는 구조가 서야 하고 이 페이즈에 그것이 없으므로, 그 자리를 넓히지
않고 구멍으로 등재했다.
-/
-- DD:CF-1262
theorem exists_adjustmentWithoutInsolvency :
    ∃ (withdrawn cashLike assetBefore liabilityBefore assetAfter liabilityAfter : ℤ),
      meetsWithdrawal withdrawn cashLike = false ∧
      assetAfter < assetBefore ∧
      isSolvent assetBefore liabilityBefore = true ∧
      isSolvent assetAfter liabilityAfter = true := by
  -- 존재 진술이므로 그 상태를 하나 들면 닫힌다. 요구가 1 이고 당장 내줄 수 있는 것이 영이면
  -- 인출 충족이 거짓이고, 자산이 1 에서 영으로 줄어도 부채가 영이면 지급능력이 두 시점에서
  -- 모두 참이다. 네 판정이 전부 `ℤ` 위의 닫힌 리터럴 비교라 `decide` 가 기준선 이하에서 닫는다.
  exact ⟨1, 0, 1, 0, 0, 0, by decide, by decide, by decide, by decide⟩

/--
위계가 엄격히 갈리는 두 주체에 대해 상단이 조정하고 하단이 실패하는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 위계가 엄격히 갈린 두 주체에서 상단이 조정으로
살아남고 하단이 상환에 실패하는 배치가 하나도 서지 않는다는 것. 그것이 관측되면 초석 명제의 넷째
절이 자리를 잃는다. 앞선 존재 진술이 조정으로 살아남는 자리를 세우되 위계 위치를 들지 않았으므로,
이 진술은 그 자리에 위계를 색인으로 더한다.

**존재 형태로 진술하는 까닭(T-6):** 위계 위치와 두 총액이 독립이고 둘을 잇는 고리가 구조에 없으므로
전칭으로 세우면 그 고리를 가정으로 얹어야 하고 T-4 가 그것을 명시하게 한다. 존재로 세우면 그 배치가
실현 가능하다는 것만 주장하며, 어느 조건에서 서는지는 전파를 다루는 아크가 받는다.

**가정을 두지 않는다.**

**위계는 액면가 약속의 강도로만 들어온다.** 두 주체의 강도를 받아 앞이 뒤보다 엄격히 강한 배치를
세우며, 그 강도가 주체의 위계 위치를 유도한다. 강도 밖의 축은 이 진술이 들지 않는다.
-/
-- DD:CF-1316
theorem exists_upperAdjustsLowerFails :
    ∃ (upper lower : CrisisFramework.Definition.ParStrength)
      (dueUpper paidUpper dueLower paidLower : ℤ)
      (assetUpperBefore assetUpperAfter liabilityUpper : ℤ),
      upper.atLeastAsStrong lower = true ∧
      lower.atLeastAsStrong upper = false ∧
      failsRepayment dueUpper paidUpper = false ∧
      failsRepayment dueLower paidLower = true ∧
      assetUpperAfter < assetUpperBefore ∧
      isSolvent assetUpperBefore liabilityUpper = true ∧
      isSolvent assetUpperAfter liabilityUpper = true := by
  -- 존재 진술이므로 배치를 하나 들면 닫힌다. 강도를 순수 공적과 부보로 두면 앞이 뒤보다
  -- 엄격히 강하고, 상단의 의무액과 지급액을 둘 다 영으로 두면 상환 실패가 거짓이며 하단의
  -- 의무액 1 에 지급액 영을 두면 참이다. 상단의 자산이 1 에서 영으로 줄어도 부채가 영이면
  -- 지급능력이 두 시점에서 모두 참이다. 아홉 값이 전부 닫힌 리터럴이고 일곱 판정이 유한 열거와
  -- `ℤ` 위의 비교라 `decide` 가 기준선 이하에서 닫는다.
  exact ⟨.publicMoney, .insuredMoney, 0, 0, 1, 0, 1, 0, 0,
    by decide, by decide, by decide, by decide, by decide, by decide, by decide⟩

end CrisisFramework.Accounting
