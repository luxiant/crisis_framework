/-
회계층 — 청구권의 집계

규율: L-4(`ℝ` 금지), L-15(회계층은 `ℤ`), L-12(총액 기준으로 닫고 순액으로 닫지 않는다),
      L-8(색인), C-9(전면 `simp` 금지), A-6(기준선 차분), T-2(반증 조건).

**수 체계: `ℤ`.** 정의층의 `Claim` 이 수 체계를 매개변수로 받으므로 이 파일이 그 자리에 `ℤ` 를
넣는다. 금액이 `Term ℤ Obs` 이고 그 값을 그 시점의 판독에서 얻으므로 두 정의가 환경을 받는다.

**자기 청구권을 집합에서 지우지 않고 세는 자리에서 거른다.** 지우면 그 청구권이 있었다는 사실이
사라져 총액과 순액의 차이를 셀 대상이 없어지며, 그것이 L-12 가 순액으로 닫는 것을 금지하는
취지다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Algebra.BigOperators.Ring.Finset
import CrisisFramework.Definition.Claim

open Finset
open CrisisFramework.Definition

namespace CrisisFramework.Accounting

/--
자기 청구권을 뺀 금액 합.

**대응 비형식 개념:** 그 청구권 집합이 나타내는 총액. 양쪽 끝이 같은 당사자에 있는 청구권은
세지 않는다.

**이 정의가 배제하는 사례:**
보유 청구권을 통화 색인 없이 하나로 더하는 읽기. 한 감독 보고를 다룬 문면이 대출의 표시 통화가 그
보고의 뒤 시기에 칸이 생겨 그 시점부터만 읽힌다고 적으므로, 색인 없이 더하면 그 칸이 없던 시기의
값과 생긴 뒤의 값이 같은 꼴로 서서 통화 색인의 부재가 집계에서 사라진다
(Niepmann·Schmidt-Eisenlohr 2019).
조달처: E-65 §3-1 「대출의 표시 통화는 그 보고의 뒤 시기에 칸이 생겨 그 시점부터만 읽힌다」

**혼동의 예외를 담지 않는다.** 채권에 질권이 설정되어 있으면 채권자와 채무자가 같아져도 채권이
소멸하지 않는데, 이 함수는 당사자의 같음만 보고 빼므로 그런 채권을 총액에서 잘못 뺀다. 담보로
제공된 채권을 채무자가 취득한 경우가 그것이며, 담보 덩어리가 다루는 재담보와 같은 축이다. 이것은
알려진 한계이고 뭉치의 문면에서 조달되지 않는다.

**통화를 인자로 받고 그 통화의 청구권만 센다.** 통화 간 환산을 금지하는 요구가 색인 없는 합을
막으므로, 통화를 받지 않으면 이 합이 통화를 가로지른 값이 된다.

**기각한 대체 정의:**
자기 청구권을 집합에서 지우고 남은 것을 더하는 안. 지우면 그 청구권이 있었다는 사실이 사라지고,
총액과 순액의 차이가 어디서 왔는지를 셀 대상이 없어진다. L-12 가 순액으로 닫는 것을 금지하는
취지가 그것이며, 집합에 남겨 두고 세는 자리에서 거르는 것이 그 취지에 맞는다. 그리고 통화를
받지 않고 통화별 합을 뒤에 쪼개는 안도 기각했다. 쪼개려면 통화를 가로지른 값이 한 번 서야 하고
그 값이 L-12 가 금지한 환산을 전제한다.

**금액이 항이므로 환경을 받는다.** 변동금리 청구권의 금액이 그 시점의 판독에 달려 있기 때문이다.
-/
-- DD:CF-3106
def grossTotal {ι Party Obs Ext Lvl Currency : Type} [DecidableEq Party] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (c : Currency)
    (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).currency = c ∧ (S.assign i).obligor ≠ (S.assign i).holder
     then evalTerm e (S.assign i).amount else 0)

/--
당사자 사상으로 새로 내부화되는 청구권의 금액 합.

**대응 비형식 개념:** 두 당사자를 하나로 묶었을 때 그 사이에서 사라지는 총액. 연결재무제표의
내부거래 제거액이 그것이다.

**이 정의가 배제하는 사례:**
내부화되는 금액을 통화 색인 없이 하나로 더하는 읽기. 한 감독 보고를 다룬 문면이 대출의 표시 통화가
그 보고의 뒤 시기에 칸이 생겨 그 시점부터만 읽힌다고 적으므로, 색인 없이 더하면 앞의 합과 이 합이
서로 다른 유니버스를 세어 그 차이가 항등식으로 닫히지 않는다(Niepmann·Schmidt-Eisenlohr 2019).
조달처: E-65 §3-1 「대출의 표시 통화는 그 보고의 뒤 시기에 칸이 생겨 그 시점부터만 읽힌다」

**옮기기 전에 이미 자기 청구권이던 것을 담지 않는다.** 그것은 사라지는 것이 아니라 처음부터 세지
않았으므로 이 합에 들지 않는다. 한 법인이 자기 사채를 사들여 보유하는 경우가 그 사례이며, 실무에서도
그 사채는 자산으로 잡지 않는다. 이것은 알려진 한계이고 뭉치의 문면에서 조달되지 않는다.

**기각한 대체 정의:**
옮긴 뒤에 자기 청구권인 것을 전부 세는 안. 그러면 처음부터 자기 청구권이던 것이 함께 들어와
총액의 차이와 어긋난다.

**통화를 인자로 받고 그 통화의 청구권만 센다.** 앞의 합과 같은 사유이며, 두 합이 같은 통화 색인
위에 서야 그 차이가 항등식으로 닫힌다.

**금액은 옮기기 전 것을 쓴다.** `Claim.mapParty` 가 금액을 건드리지 않으므로 옮긴 뒤 것과 같으며,
증명에서 그 사실이 쓰인다. 표시 통화도 건드리지 않으므로 통화 색인이 옮김에 보존된다.
-/
-- DD:CF-3106
def newlyInternalized {ι Party Node Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Node] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (c : Currency) (f : Party → Node)
    (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).currency = c ∧ (S.assign i).obligor ≠ (S.assign i).holder ∧
        f (S.assign i).obligor = f (S.assign i).holder
     then evalTerm e (S.assign i).amount else 0)

/--
집계가 총액에서 빼는 것은 새로 내부화된 청구권의 금액뿐이다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
두 당사자를 하나로 묶었을 때 총액의 감소분이 그 사이에 선 청구권의 금액 합과 다른 사례가
관측되어야 한다. 재담보가 그 후보다. 같은 담보가 여러 청구권을 떠받치면 상계의 단위가 청구권
단위와 어긋날 수 있고, J-3 이 소유권 장부와 담보 장부의 분리로 그것을 다루기로 정해 두었다.
이 정리는 담보를 담지 않으므로 그 사례가 반례가 되는지는 담보 덩어리가 판정한다.

**형식층 배정:** 회계층. `ℤ` 와 `Finset` 합을 쓴다(L-8 의 색인, L-15).

**가정을 두지 않는다.** 그 서명이 결정 가능 등식의 인스턴스 바인더와 환경과 통화와
사상과 청구권 집합만 받고 명제 가정을 받지 않으므로, 이 항등식은 어느 가정 아래에서도
아니라 그 타입이 서는 자리 전량에서 성립한다.

**T-3 분류:** 기여다. 집계가 총액에서 빼는 것이 무엇인지를 항등식으로 고정하는 자리이고 정의를
전개하기만 해서는 서지 않으므로 기여 목록에 든다.

**이 정리가 E-19 의 관찰을 형식으로 옮긴다.** 같은 실물 흐름이 한 결정 단위 안에 있으면 재고로
총액에 한 번 서고 결정 단위 둘로 갈리면 매출채권으로 양쪽 총액에 두 번 선다는 것이며, 경계가
총액을 만든다는 그 관찰이 여기서 항등식이 된다.
-/
-- DD:CF-3106
theorem grossTotal_sub_mapParty_eq_newlyInternalized
    {ι Party Node Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Node] [DecidableEq Currency]
    (e : Env ℤ Obs Ext Lvl) (c : Currency) (f : Party → Node)
    (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) :
    grossTotal e c S - grossTotal e c (S.mapParty f) = newlyInternalized e c f S := by
  have hidx : (S.mapParty f).index = S.index := rfl
  unfold grossTotal newlyInternalized
  rw [hidx, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl ?_
  intro i _
  have ho : ((S.mapParty f).assign i).obligor = f (S.assign i).obligor := rfl
  have hh : ((S.mapParty f).assign i).holder = f (S.assign i).holder := rfl
  have hc' : ((S.mapParty f).assign i).currency = (S.assign i).currency := rfl
  have ha : ((S.mapParty f).assign i).amount = (S.assign i).amount := rfl
  rw [ho, hh, hc', ha]
  -- 통화가 다르면 세 조건이 모두 거짓이고, 같으면 받은 판의 세 갈래가 그대로 선다.
  by_cases hc : (S.assign i).currency = c
  · by_cases h : (S.assign i).obligor = (S.assign i).holder
    · have n₁ : ¬((S.assign i).currency = c ∧ (S.assign i).obligor ≠ (S.assign i).holder) :=
        fun hx => hx.2 h
      have n₂ : ¬((S.assign i).currency = c
          ∧ f (S.assign i).obligor ≠ f (S.assign i).holder) :=
        fun hx => hx.2 (congrArg f h)
      have n₃ : ¬((S.assign i).currency = c ∧ (S.assign i).obligor ≠ (S.assign i).holder
          ∧ f (S.assign i).obligor = f (S.assign i).holder) :=
        fun hx => hx.2.1 h
      rw [if_neg n₁, if_neg n₂, if_neg n₃, sub_zero]
    · have p₁ : (S.assign i).currency = c ∧ (S.assign i).obligor ≠ (S.assign i).holder :=
        And.intro hc h
      by_cases hf : f (S.assign i).obligor = f (S.assign i).holder
      · have n₂ : ¬((S.assign i).currency = c
            ∧ f (S.assign i).obligor ≠ f (S.assign i).holder) :=
          fun hx => hx.2 hf
        have p₃ : (S.assign i).currency = c ∧ (S.assign i).obligor ≠ (S.assign i).holder
            ∧ f (S.assign i).obligor = f (S.assign i).holder :=
          And.intro hc (And.intro h hf)
        rw [if_pos p₁, if_neg n₂, if_pos p₃, sub_zero]
      · have p₂ : (S.assign i).currency = c
            ∧ f (S.assign i).obligor ≠ f (S.assign i).holder :=
          And.intro hc hf
        have n₃ : ¬((S.assign i).currency = c ∧ (S.assign i).obligor ≠ (S.assign i).holder
            ∧ f (S.assign i).obligor = f (S.assign i).holder) :=
          fun hx => hf hx.2.2
        rw [if_pos p₁, if_pos p₂, if_neg n₃, sub_self]
  · have n₁ : ¬((S.assign i).currency = c ∧ (S.assign i).obligor ≠ (S.assign i).holder) :=
      fun hx => hc hx.1
    have n₂ : ¬((S.assign i).currency = c
        ∧ f (S.assign i).obligor ≠ f (S.assign i).holder) :=
      fun hx => hc hx.1
    have n₃ : ¬((S.assign i).currency = c ∧ (S.assign i).obligor ≠ (S.assign i).holder
        ∧ f (S.assign i).obligor = f (S.assign i).holder) :=
      fun hx => hc hx.1
    rw [if_neg n₁, if_neg n₂, if_neg n₃, sub_zero]

end CrisisFramework.Accounting
