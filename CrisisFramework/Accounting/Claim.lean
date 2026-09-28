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
혼동의 예외. 채권에 질권이 설정되어 있으면 채권자와 채무자가 같아져도 채권이 소멸하지 않는데,
이 함수는 당사자의 같음만 보고 빼므로 그런 채권을 총액에서 잘못 뺀다. 담보로 제공된 채권을
채무자가 취득한 경우가 그것이며, 담보 덩어리가 다루는 재담보와 같은 축이다.

**기각한 대체 정의:**
자기 청구권을 집합에서 지우고 남은 것을 더하는 안. 지우면 그 청구권이 있었다는 사실이 사라지고,
총액과 순액의 차이가 어디서 왔는지를 셀 대상이 없어진다. L-12 가 순액으로 닫는 것을 금지하는
취지가 그것이며, 집합에 남겨 두고 세는 자리에서 거르는 것이 그 취지에 맞는다.

**금액이 항이므로 환경을 받는다.** 변동금리 청구권의 금액이 그 시점의 판독에 달려 있기 때문이다.
-/
-- DD:CF-627
def grossTotal {ι Party Obs Ext Lvl Currency : Type} [DecidableEq Party]
    (e : Env ℤ Obs Ext Lvl) (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).obligor = (S.assign i).holder then 0
     else evalTerm e (S.assign i).amount)

/--
당사자 사상으로 새로 내부화되는 청구권의 금액 합.

**대응 비형식 개념:** 두 당사자를 하나로 묶었을 때 그 사이에서 사라지는 총액. 연결재무제표의
내부거래 제거액이 그것이다.

**이 정의가 배제하는 사례:**
옮기기 전에 이미 자기 청구권이던 것. 그것은 사라지는 것이 아니라 처음부터 세지 않았으므로 이
합에 들지 않는다. 한 법인이 자기 사채를 사들여 보유하는 경우가 그 사례이며, 실무에서도 그
사채는 자산으로 잡지 않는다.

**기각한 대체 정의:**
옮긴 뒤에 자기 청구권인 것을 전부 세는 안. 그러면 처음부터 자기 청구권이던 것이 함께 들어와
총액의 차이와 어긋난다.

**금액은 옮기기 전 것을 쓴다.** `Claim.mapParty` 가 금액을 건드리지 않으므로 옮긴 뒤 것과 같으며,
증명에서 그 사실이 쓰인다.
-/
-- DD:CF-627
def newlyInternalized {ι Party Node Obs Ext Lvl Currency : Type}
    [DecidableEq Party] [DecidableEq Node]
    (e : Env ℤ Obs Ext Lvl) (f : Party → Node)
    (S : ClaimSet ι Party ℤ Obs Ext Lvl Currency) : ℤ :=
  ∑ i ∈ S.index,
    (if (S.assign i).obligor ≠ (S.assign i).holder ∧
        f (S.assign i).obligor = f (S.assign i).holder
     then evalTerm e (S.assign i).amount else 0)

end CrisisFramework.Accounting
