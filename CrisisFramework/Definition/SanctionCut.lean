/-
정의층 — 금지되는 거래의 갈래와 제재에 따른 절단

규율: L-9(import 방향은 단방향), L-10(정의층은 무차원이며 시점 인덱스 `ℕ` 만 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족으로 정의한다), A-1(`axiom` 금지),
      A-3(witness 의무), A-8(변이 검사와 논리 결합의 증거), C-1·C-2(`noncomputable` 과
      `Classical` 금지), C-3(판정 술어는 `Decidable`), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-7(용어집 선행 등록),
      D-8(witness 의 서술), T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시),
      T-6(존재 형태).

**이 파일이 세우는 것은 한 조치가 어느 망의 변을 법으로 자르는가다.** 앞 페이즈들이 주체의 번짐과
금지의 구간과 절단의 대상을 각각 세웠고 망 종류의 열거도 섰는데, 어느 조치가 어느 종류의 망을
자르는지를 잇는 자리가 비어 있었다.

**금지되는 거래의 갈래를 새 열거로 두지 않고 조치에 붙는 술어로 둔다.** 조달된 조문이 그 갈래를
조마다 자기 본문에 두므로 갈래의 목록이 조문에서 유도되지 않으며, 열거를 세우면 그 원소를 지어내게
된다. 망 종류를 받아 참거짓을 내는 꼴로 두면 한 조가 여러 갈래를 자르는 것과 하나도 자르지 않는
것이 같은 꼴에 담긴다.

**그 사상의 값을 이 파일이 채우지 않는다.** 조마다의 갈래 목록을 조달된 기록이 들지 않고 그 기록이
드는 것은 그 갈래가 조의 본문에 선다는 구조뿐이므로, 값을 적으면 읽지 않은 자리의 성질을 근거로 쓰는
것이 된다. 증거의 열거는 가려야 할 결합과 그 사상이 전량 거짓으로 서는 조에서 유도한다.

**절단의 술어를 네 조건의 곱으로 둔다.** 주체가 지정과 소유의 번짐과 대리·지시의 어느 하나로 걸리고,
그 조치의 구간이 그 시점을 품으며, 그 조치가 그 망 종류를 자르고, 그 대상이 그 조치의 범위에 들어야
잘린다. 가운데 둘은 그 둘을 이미 곱으로 내는 선언이 서 있으므로 그것을 옮겨 쓰고 다시 쓰지 않는다.

**멤버십을 덮지 않고 그 위에 선 술어를 둔다.** 멤버십이 묻는 것은 그 쌍이 그 망에 드는가이고 절단이
묻는 것은 법이 그 변을 금지하는가여서 둘이 다른 것을 묻는다.

**문면이 자르지 않은 자리가 실제로 끊기는 것을 이 파일이 담지 못한다.** 내릴 항의 문서화 문면이
그 한계를 이미 적고 있으며, 그 한계를 드는 문면이 이 프로젝트의 뭉치에서 조달되지 않았으므로 이
자리가 그 사실만 적는다.

**이 파일은 수를 시점 인덱스로만 쓴다.** 그 밖의 자리에 수가 서지 않는다.

**정리의 증명은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며, 그 진술이 증명
가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나,
쓴 전술은 싣지 않는다.

**적재 선언은 진술이 딛는 것만 이 파일이 들고 증명이 더 요구하는 것은 집행이 더한다.** 진술과 타입을
결정 세션이 쓰므로 그 진술이 이름을 해소하는 데 필요한 적재가 이 파일의 몫이고, 전술이 더 요구하는
적재는 그 전술을 쓰는 쪽의 몫이다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.NetworkKind
import CrisisFramework.Definition.OwnershipReach
import CrisisFramework.Definition.ProhibitionTiming

namespace CrisisFramework.Definition
/--
그 조치가 금지하는 거래의 갈래.

**대응 비형식 개념:** 한 조가 어느 종류의 망에서 오가는 거래를 금지하는가. 조문이 금지되는 거래를
조마다 자기 본문에 들고 그 갈래가 망의 종류와 맞서므로, 조치를 받아 종류마다 참거짓을 내는 사상이
그 자리를 받는다.

**이 정의가 배제하는 사례:**
회피 금지의 조를 이 사상으로 담으려는 읽기. 그 조를 훑은 기록이 그 조가 거래의 갈래를 들지 않고
효과로 정의되므로 망 종류의 인자에도 걸리지 않는다고 적으므로, 그 조를 어느 갈래를 자르는 조로 담으면
그 성질이 사라진다.
조달처: E-68 §2-11 「그 조가 거래의 갈래를 들지 않고 효과로 정의되므로 망 종류의 인자에도 걸리지 않는다」

**기각한 대체 정의:**
금지되는 거래의 갈래를 새 열거로 두는 안. 갈래가 이름으로 보이나 그 원소가 조문에서 유도되지 않아
지어내게 되고, 한 조가 여러 갈래를 자르는 자리에서 그 열거의 원소 하나를 고를 수 없다. 조마다 자르는
종류의 목록을 필드로 두는 안도 기각했다. 하나도 자르지 않는 조와 목록이 아직 채워지지 않은 조가 같은
값으로 서고, 판정이 목록의 상등에 걸려 판정 술어가 판정 인스턴스를 갖는 자리가 그 상등으로 옮겨 간다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4419
structure ProhibitedDealKind (Measure : Type) where
  /-- 그 조치가 그 종류의 망에서 오가는 거래를 금지하는가. -/
  cutsKind : Measure → NetworkKind → Bool

/--
시점마다의 갈래 사상 (L-13).

**대응 비형식 개념:** 어느 시점에 그 조치가 어느 종류의 망을 자르는가. 같은 문면 아래에서 절단의
대상이 시점에 따라 넓어지므로 그 사상이 시점의 족으로 선다.

**이 정의가 배제하는 사례:**
한 조문이 같은 항에서 앞선 날과 뒤의 날에 걸리는 대상을 다르게 든 것. 사상을 시점과 무관한 상수로
두면 그 넓어짐이 구조에서 사라지고 한번 선 금지가 처음부터 그 범위로 섰던 것으로 읽힌다.
조달처: E-68 §2-8 「뒤의 날에 걸리는 것이 그 중앙은행의 체계 전량과 그 나라 법으로 세워진 어느 법인이든 금융 전문 기능을 품은 체계다」

**기각한 대체 정의:**
사상 구조체 안에 시점을 받는 필드를 더하는 안. 필드를 더하면 그 구조체를 받는 선언이 전부 그 필드를
채워야 하고 시점을 쓰지 않는 자리까지 값을 지어 넣게 되며, 족으로 올리면 기존 구조체가 그대로 서고
시점을 쓰지 않는 자리가 상수 축약으로 닫힌다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-4419
abbrev ProhibitedDealKindFamily (Measure : Type) := ℕ → ProhibitedDealKind Measure

/-- witness (A-3). **무엇을 증거하는가.** 갈래 사상이 비어 있지 않다. 어느 조치도 어느 종류도
자르지 않는 사상 하나를 든다. -/
-- DD:CF-4419
def ProhibitedDealKind.trivial : ProhibitedDealKind Unit where
  cutsKind := fun _ _ => false

/-- 한 사상을 모든 시점에 두는 족. 선례가 같은 꼴을 둔다. -/
-- DD:CF-4419
def ProhibitedDealKind.constant {Measure : Type} (P : ProhibitedDealKind Measure) :
    ProhibitedDealKindFamily Measure := fun _ => P

/--
그 조치가 어느 종류의 망도 자르지 않는가.

**대응 비형식 개념:** 그 조가 금지를 세우면서도 어느 망의 변도 가리지 않는 것. 효과로 정의된 조가
그 자리에 서며, 자르는 갈래가 없는 조와 값이 아직 채워지지 않은 조를 구조가 갈라야 한다.

**이 정의가 배제하는 사례:**
회피 금지의 조를 그 사상에서 빼는 읽기. 그 조를 훑은 기록이 참여자의 인식이 조건이고 거래의 갈래가
들리지 않으므로 주체와 시점과 망 종류를 받는 술어가 그것을 담지 못한다고 적으므로, 빼면 그 조가
구조 밖에 서고 어느 망도 자르지 않는 조가 실재한다는 사실이 사라진다.
조달처: E-68 §4-3 「참여자의 인식이 조건이고 거래의 갈래가 들리지 않으므로」

**기각한 대체 정의:**
어느 망도 자르지 않는지의 판정을 자르는 종류의 목록이 비는지로 두는 안. 목록을 두지 않기로 한 판정이 앞 선언의 기각 문단에
이미 서 있으므로 그 자리가 없다. 열거 전량의 전칭으로 두는 안도 기각했다. 그 꼴이 명제여서 판정
가능성이 따로 서야 하고 그 인스턴스가 목록 멤버십을 푸는 증명을 지나 명제 외연성을 끌어온다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4420
def ProhibitedDealKind.cutsNoKind {Measure : Type} (P : ProhibitedDealKind Measure)
    (m : Measure) : Bool :=
  !(P.cutsKind m NetworkKind.collateralPledge || P.cutsKind m NetworkKind.ownershipShare
      || P.cutsKind m NetworkKind.centralBankSwap
      || P.cutsKind m NetworkKind.currencyMismatchTransmission
      || P.cutsKind m NetworkKind.tradeFinanceLink
      || P.cutsKind m NetworkKind.financialMessaging)

/--
그 조치가 그 시점에 그 주체의 그 종류의 변을 자르는가.

**대응 비형식 개념:** 법이 한 변을 금지하는 네 조건이 함께 서는 것. 주체가 금지의 안에 서고, 그
조치의 구간이 그 시점을 품고, 그 조치가 그 종류의 망을 자르고, 그 대상이 그 조치의 범위에 들어야
잘린다.

**이 정의가 배제하는 사례:**
주체만 보고 갈래를 보지 않는 읽기. 그 조문을 훑은 기록이 금융 전문 체계가 절단의 대상이면서 지정의
기준이기도 하여 한 대상이 두 지위를 함께 갖는다고 적으므로, 갈래를 보지 않으면 그 체계에의 연결만
금지하는 조가 그 주체와의 모든 거래를 금지하는 조와 같은 값으로 선다.
조달처: E-68 §2-10 「한 대상이 두 지위를 함께 갖는다」

**기각한 대체 정의:**
네 조건을 따로 내고 그 조건의 묶음을 부르는 쪽에 두는 안. 그러면 자르는가의 물음이 네 자리에서 각각
답해지고 그 넷을 묶는 자리가 구조 밖에 서서 어느 쪽이 가렸는지가 그 묶음에서 사라진다. 구간과 대상의
곱을 이 선언에서 다시 쓰는 안도 기각했다. 그 곱을 내는 선언이 이미 서 있고 그 판정 기준의 정본이
리포 안에 실물로 있으므로 다시 쓰면 같은 판정이 두 자리에 서고 그 둘이 갈릴 수 있다.

**수 체계를 매개변수로 받는다.** 주체의 번짐이 그 매개변수 위의 비교를 든다.
-/
-- DD:CF-4423
def cutsEdgeAt {EIdx Entity Num Lvl Measure Target : Type} [DecidableEq EIdx] [DecidableEq Entity]
    (ops : Ops Num Lvl) (N : StakeNet EIdx Entity Num) (C : ReachCriteria Entity Num)
    (Dg : Designation Entity) (chains : Finset (List EIdx))
    (actingFor : Entity → Entity → Bool) (principals : Finset Entity)
    (R : ProhibitionTiming Measure Target) (P : ProhibitedDealKind Measure)
    (m : Measure) (x : Target) (k : NetworkKind) (e : Entity) (t : ℕ) : Bool :=
  N.reaches ops C Dg chains actingFor principals e && P.cutsKind m k && R.cutAt m x t

/--
조치의 목록 가운데 어느 하나라도 그 변을 자르는가.

**대응 비형식 개념:** 한 주체가 잘렸는지를 조치 하나가 정하지 않고 그때 효력이 있는 조치 전량이
정하는 것. 사유가 다른 조가 각각 금지를 세우므로 그 가운데 하나라도 걸리면 잘린다.

**이 정의가 배제하는 사례:**
지정을 단일 술어로 두는 읽기. 그 조문을 훑은 기록이 부속서가 부로 갈려 부마다 표제를 두어 금지가
추구하는 목적을 좌절시키는 것과 침략 전쟁을 지원하는 것으로 사유를 가르므로 지정이 사유별 술어의
합이라고 적으며, 단일 술어로 두면 사유마다 다른 판정을 낳은 조들이 한 값으로 접힌다.
조달처: E-68 §2-6 「지정이 단일 술어가 아니라 사유별 술어의 합이다」

**기각한 대체 정의:**
조치 전량의 곱으로 두는 안. 그러면 모든 조치가 함께 자르는 주체만 잘린 것으로 서고, 한 조로만 걸린
주체가 금지의 밖으로 나온다. 조치의 목록을 받지 않고 조치를 하나만 받는 안도 기각했다. 답할 항의
서명이 조치의 자리를 갖지 않아 부르는 쪽이 그 하나를 고르게 되고 그 고름이 구조 밖에 선다.

**수 체계를 매개변수로 받는다.** 자르는 판정이 그 매개변수 위의 비교를 든다.
-/
-- DD:CF-4439
def cutByAnyMeasure {EIdx Entity Num Lvl Measure Target : Type}
    [DecidableEq EIdx] [DecidableEq Entity]
    (ops : Ops Num Lvl) (N : StakeNet EIdx Entity Num) (C : ReachCriteria Entity Num)
    (Dg : Designation Entity) (chains : Finset (List EIdx))
    (actingFor : Entity → Entity → Bool) (principals : Finset Entity)
    (R : ProhibitionTiming Measure Target) (P : ProhibitedDealKind Measure)
    (ms : List Measure) (x : Target) (e : Entity) (t : ℕ) (k : NetworkKind) : Bool :=
  ms.any (fun m => cutsEdgeAt ops N C Dg chains actingFor principals R P m x k e t)

/--
그 거래가 유예에 덮이지 않고 잘리는가.

**대응 비형식 개념:** 한 거래가 금지되는지가 그 거래의 시점만으로 정해지지 않고 그것이 딛는 계약의
체결 시점에 함께 걸리는 것. 유예의 창이 열리면 그 거래가 잘리지 않는다.

**이 정의가 배제하는 사례:**
거래의 시점만 보는 읽기. 그 조문을 훑은 기록이 어느 날 이전에 맺은 계약과 그 이행에 필요한 부수
계약에 다른 날까지 금지가 미치지 않음을 들고 한 거래가 금지되는지가 그 거래의 시점만으로 정해지지
않는다고 적으므로, 시점만 보면 같은 날에 일어난 두 거래가 딛는 계약의 체결 시점이 달라 갈리는 자리가
사라진다.
조달처: E-68 §2-9 「그것이 딛는 계약의 체결 시점에 함께 걸린다」

**기각한 대체 정의:**
유예를 절단의 술어 안에 넣지 않고 부르는 쪽에 두는 안. 그러면 잘렸는가의 물음이 두 자리에서 각각
답해지고, 유예가 금지의 밖에 서는 창이라는 것이 그 묶음에서 사라진다. 유예를 한 구간의 포함으로
접는 안도 기각했고 그 기각이 유예의 창을 세운 선언의 기각 문단에 이미 서 있으므로, 이 선언은 그
자리를 비켜 그 창을 인자로 받는다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-4424
def cutsDealAt {EIdx Entity Num Lvl Measure Target : Type}
    [DecidableEq EIdx] [DecidableEq Entity]
    (ops : Ops Num Lvl) (N : StakeNet EIdx Entity Num) (C : ReachCriteria Entity Num)
    (Dg : Designation Entity) (chains : Finset (List EIdx))
    (actingFor : Entity → Entity → Bool) (principals : Finset Entity)
    (R : ProhibitionTiming Measure Target) (P : ProhibitedDealKind Measure)
    (G : GraceWindow) (m : Measure) (x : Target) (k : NetworkKind) (e : Entity)
    (effective concluded performed : ℕ) : Bool :=
  cutsEdgeAt ops N C Dg chains actingFor principals R P m x k e performed
    && !G.exempts effective concluded performed

/--
그 쌍이 그 망에서 이어지고 법이 그 변을 자르지 않는가.

**대응 비형식 개념:** 법적으로 남아 있는 변. 그 쌍이 그 종류의 망에 들고 어느 끝도 그 종류에서
잘리지 않았을 때 그 변이 선다.

**이 정의가 배제하는 사례:**
절단을 주체에 붙이고 쌍에 붙이지 않는 읽기. 그 망을 훑은 기록이 그 망의 변이 두 주체 사이에 서고 한
주체와 전체 사이에 서지 않는다고 적으므로, 주체에만 붙이면 한 주체가 잘릴 때 그 주체의 변 전량이
한꺼번에 사라지고 남는 상대와의 변이 있는 배치가 표현되지 않는다.
조달처: E-71 §2-1 「그 망의 변이 두 주체 사이에 서고 한 주체와 전체 사이에 서지 않는다」

**기각한 대체 정의:**
멤버십의 값을 절단으로 덮는 안. 선언이 하나 줄어드나 그 쌍이 그 망에 드는가와 법이 그 변을
금지하는가가 다른 물음이어서, 덮으면 법이 자른 변과 애초에 서지 않은 변이 같은 값으로 선다. 절단을
한쪽 끝에만 묻는 안도 기각했다. 금지가 열거된 주체와의 거래를 드는 자리에서 보내는 쪽과 받는 쪽이
갈리지 않으므로 한쪽만 물으면 다른 쪽이 잘린 변이 남는다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4425
def NetworkMembership.legallyLinked {Node : Type} (M : NetworkMembership Node)
    (cut : NetworkKind → Node → Bool) (k : NetworkKind) (a b : Node) : Bool :=
  M.linked k a b && !cut k a && !cut k b

/--
증거를 드는 조의 열거.

**대응 비형식 개념:** 없다. 이 열거는 증거를 들기 위한 색인이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
조문의 조 번호를 생성자로 두는 읽기. 그 조문을 훑은 기록이 개정 행위가 본문의 각 자리에 표지로
박히고 한 조 안에서 항마다 다른 개정 표지가 서는 자리가 있다고 적으므로, 번호를 박으면 그 번호가
가리키는 문면이 개정으로 바뀔 때 그 열거가 거짓이 된다.
조달처: E-68 §2-2 「같은 조 안에서 항마다 다른 개정 표지가 서는 자리가 있다」

**기각한 대체 정의:**
증거를 `Unit` 위에서만 드는 안. 가려야 할 것이 한 조가 한 종류를 자름과 여러 종류를 자름과 어느
종류도 자르지 않음이어서 조치마다 그것만 참인 자리가 필요하므로, `Unit` 로 두면 그 증거가 한 조치에
접혀 그 갈림을 뒤집은 변이가 통과한다. 조의 수를 미리 적는 안도 기각했다. 줄이 값을 들지 말고 그
값을 재는 자리만 들라는 요구가 그 자리에 걸리고, 가려야 할 결합이 늘면 그 값이 낡는다.

**수 체계를 받지 않는다.** 생성자가 열거이며 수를 들지 않는다.
-/
-- DD:CF-4421
inductive SanctionClauseWitness where
  /-- 그 체계에 연결하는 것을 금지하는 조. -/
  | messagingAccess
  /-- 열거된 주체와의 거래를 금지하는 조. -/
  | listedCounterparty
  /-- 소유를 탄 번짐으로 금지를 넓히는 조. -/
  | ownershipReach
  /-- 회피를 효과로 금지하는 조. -/
  | evasion
  deriving DecidableEq, Repr

/--
증거를 드는 갈래 사상.

**대응 비형식 개념:** 없다. 이 선언은 증거를 들기 위한 값이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
회피 금지의 조에 어느 갈래를 주는 읽기. 그 조를 훑은 기록이 그 조가 거래의 갈래를 들지 않고 효과로
정의되므로 망 종류의 인자에도 걸리지 않는다고 적으므로, 어느 갈래를 주면 그 조가 담기지 않는 성질이
구조에서 사라지고 어느 망도 자르지 않는 조가 실재한다는 증거가 없어진다.
조달처: E-68 §2-11 「그 조가 거래의 갈래를 들지 않고 효과로 정의되므로 망 종류의 인자에도 걸리지 않는다」

**기각한 대체 정의:**
조마다 자르는 종류를 전량 열거하는 안. 값이 명시로 보이나 조달된 기록이 조마다의 갈래 목록을 들지
않으므로 그 열거가 읽지 않은 자리의 성질을 근거로 쓰는 것이 된다. 포괄 분기로 나머지를 거짓으로
접는 안도 기각했다. 그 분기가 희소 분기 보조정리를 거쳐 공리를 끌어오는 자리가 같은 층에서
실측됐으므로, 종류의 상등 판정으로 두어 그 경로를 끊는다.

**수 체계를 받지 않는다.**
-/
-- DD:CF-4421
def clauseWitnessDealKind : ProhibitedDealKind SanctionClauseWitness where
  cutsKind := fun m k =>
    match m with
    | .messagingAccess => decide (k = NetworkKind.financialMessaging)
    | .listedCounterparty =>
        decide (k = NetworkKind.collateralPledge) || decide (k = NetworkKind.tradeFinanceLink)
    | .ownershipReach => decide (k = NetworkKind.ownershipShare)
    | .evasion => false

/--
효과로 정의된 조가 어느 망도 자르지 않고 다른 조는 자른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 조가 어느 종류를 자르거나, 갈래를 드는 조가 어느 종류도 자르지 않아야 한다. 앞의 관측은 효과로
정의된 조가 망 종류의 인자에 걸린다는 뜻이고 뒤의 관측은 그 판정이 조치를 가르지 않는다는 뜻이며,
둘 다 자르는 갈래가 없는 조와 값이 채워지지 않은 조를 구조가 가린다는 설계가 무너졌음을 가리킨다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 진술이 판정의 정의를 넘어 드는 몫을 갖는다. 어느 망도 자르지 않는 조가
실재한다는 것이 조문의 성질이고 그것을 구조 안의 명제로 드는 자리가 여기뿐이며, 그 자리가 구조의
결손이 아니라 그 조의 성질임을 이 정리가 든다.
-/
-- DD:CF-4430
theorem cuts_no_kind_pins_evasion_clause :
    clauseWitnessDealKind.cutsNoKind SanctionClauseWitness.evasion = true
      ∧ clauseWitnessDealKind.cutsNoKind SanctionClauseWitness.messagingAccess = false
      ∧ clauseWitnessDealKind.cutsNoKind SanctionClauseWitness.listedCounterparty = false
      ∧ clauseWitnessDealKind.cutsNoKind SanctionClauseWitness.ownershipReach = false := by
  -- 증거 사상이 조치마다 분기 하나로 계산되므로 네 등식이 정의를 펼친 계산으로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
어느 망도 자르지 않는지의 판정이 열거의 원소마다 홀로 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
한 종류만 자르는 사상에서 그 판정이 참을 내야 한다. 그 관측은 그 판정이 열거의 원소 전량에 걸리지
않는다는 뜻이며, 그러면 어느 종류를 자르는 조가 아무것도 자르지 않는 조로 세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 그 진술이 그 판정의 정의를 넘어 드는 몫을 갖지 않고 A-8 이 요구하는
증거를 드는 자리다. 조달된 기록이 조마다의 갈래 목록을 들지 않아 조를 드는 증거가 종류 전량을 덮지
못하므로, 그 결합을 가리는 증거를 조가 아니라 정리 안의 리터럴로 든다. 열거의 원소마다 한 항을
두므로 원소를 더하는 아크가 이 진술을 함께 넓히지 않으면 그 원소의 결합이 어느 명제에도 걸리지
않는다.
-/
-- DD:CF-4420
theorem cuts_no_kind_pins_each_disjunct :
    (ProhibitedDealKind.mk
        (fun (_ : Unit) k => decide (k = NetworkKind.collateralPledge))).cutsNoKind () = false
      ∧ (ProhibitedDealKind.mk
        (fun (_ : Unit) k => decide (k = NetworkKind.ownershipShare))).cutsNoKind () = false
      ∧ (ProhibitedDealKind.mk
        (fun (_ : Unit) k => decide (k = NetworkKind.centralBankSwap))).cutsNoKind () = false
      ∧ (ProhibitedDealKind.mk
        (fun (_ : Unit) k =>
          decide (k = NetworkKind.currencyMismatchTransmission))).cutsNoKind () = false
      ∧ (ProhibitedDealKind.mk
        (fun (_ : Unit) k => decide (k = NetworkKind.tradeFinanceLink))).cutsNoKind () = false
      ∧ (ProhibitedDealKind.mk
        (fun (_ : Unit) k => decide (k = NetworkKind.financialMessaging))).cutsNoKind ()
          = false := by
  -- 사상마다 한 종류에서만 참을 내므로 여섯 등식이 계산으로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/--
한 조가 어떤 종류를 자르고 다른 종류를 자르지 않는 배치가 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 배치에서도 한 조가 망 종류 전량에 같은 값을 내야 한다. 그 관측은 금지가 망의 종류를 가리지
않는다는 뜻이며, 그러면 갈래를 조치에 붙는 술어로 둔 것이 아무것도 가르지 않는다.

**존재 형태로 진술하는 까닭(T-6):**
조달된 기록이 열거된 주체와의 거래를 통째로 금지하는 조를 들어 그 금지가 담보의 사슬에도 닿을 수
있으므로, 어느 종류가 비는지를 전칭으로 세우면 조문을 다시 읽어야 서는 주장이 된다. 시스템 수준의
문면이 개별 종류의 값을 결정하지 않는 자리다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 사상이 종류마다 다른 값을 낼 수 있다는 것이 망 종류의 열거가 이 축에 닿는
근거이고, 그것을 구조 안의 명제로 드는 자리가 여기뿐이므로 기여 목록에 든다.
-/
-- DD:CF-4422
theorem exists_clause_splitting_kinds :
    ∃ (P : ProhibitedDealKind SanctionClauseWitness) (m : SanctionClauseWitness)
      (k₁ k₂ : NetworkKind), P.cutsKind m k₁ = true ∧ P.cutsKind m k₂ = false := by
  -- 전문 체계에의 연결을 금지하는 조가 금융 전문의 고리를 자르고 담보의 사슬을 자르지 않는다.
  exact ⟨clauseWitnessDealKind, SanctionClauseWitness.messagingAccess,
    NetworkKind.financialMessaging, NetworkKind.collateralPledge, rfl, rfl⟩

/--
증거를 드는 조치의 구간과 범위.

**대응 비형식 개념:** 없다. 이 선언은 증거를 들기 위한 값이며 비형식 개념에 대응하지 않는다.

**이 정의가 배제하는 사례:**
구간의 경계를 비우고 증거를 드는 읽기. 그 구간의 판정을 세운 선언이 경계가 둘 다 없는 자리를
정해지지 않음으로 내므로, 비우면 그 조치가 어느 시점도 품지 않아 절단의 곱이 전량 거짓으로 서고 각
인자가 홀로 값을 가르는 자리가 재어지지 않는다.
조달처: E-68 §2-7 「시점의 축이 개정의 사슬과 조문 본문의 날짜 둘로 선다」

**기각한 대체 정의:**
구간을 열린 것으로 두고 확정성만 채우는 안. 경계가 없으면 그 판정이 정해지지 않음을 내므로 증거가
서지 않는다. 날짜의 확정성을 비우는 안도 기각했다. 그 판정이 확정성을 먼저 보고 거친 자리에서
정해지지 않음을 내므로 같은 자리에 선다.

**인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.**
-/
-- DD:CF-4423
def clauseWitnessTiming : ProhibitionTiming SanctionClauseWitness Bool where
  period := fun _ =>
    { onset := some 1, terminus := some 3,
      definiteness := { yearFixed := true, monthFixed := true, dayFixed := true } }
  scope := fun _ => { covers := fun x => x }

/--
절단의 판정이 각 인자에서 홀로 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 네 조건 가운데 하나가 거짓인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이
아니라는 뜻이며, 그러면 주체가 금지의 밖에 선 변이나 그 조치가 자르지 않는 종류의 변이 잘린 것으로
세어진다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 그 진술이 절단의 정의를 넘어 드는 몫을 갖지 않고 A-8 이 요구하는 증거를
드는 자리다. 결론을 부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서 재어졌는지가
서지 않으므로, 각 인자가 홀로 거짓인 자리를 이 정리가 든다. 구간과 대상의 곱이 홀로 갈리는 자리는 그
곱을 내는 선언의 증거가 이미 들고 있다. **주체의 번짐이 홀로 거짓인 자리는 금지의 밖에 선 주체가
든다.** 그 자리를 두지 않으면 그 인자를 상수로 바꾼 사본이 그대로 elaborate 되므로 네 항만으로는 이
문면의 주장이 서지 않는다.
-/
-- DD:CF-4423
theorem cuts_edge_pins_each_conjunct :
    cutsEdgeAt reachWitnessOps reachWitnessNet reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals clauseWitnessTiming
        clauseWitnessDealKind SanctionClauseWitness.messagingAccess true
        NetworkKind.financialMessaging ReachWitnessEntity.listed 2 = true
      ∧ cutsEdgeAt reachWitnessOps reachWitnessNet reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals clauseWitnessTiming
        clauseWitnessDealKind SanctionClauseWitness.messagingAccess true
        NetworkKind.collateralPledge ReachWitnessEntity.listed 2 = false
      ∧ cutsEdgeAt reachWitnessOps reachWitnessNet reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals clauseWitnessTiming
        clauseWitnessDealKind SanctionClauseWitness.messagingAccess true
        NetworkKind.financialMessaging ReachWitnessEntity.listed 9 = false
      ∧ cutsEdgeAt reachWitnessOps reachWitnessNet reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals clauseWitnessTiming
        clauseWitnessDealKind SanctionClauseWitness.messagingAccess false
        NetworkKind.financialMessaging ReachWitnessEntity.listed 2 = false
      ∧ cutsEdgeAt reachWitnessOps reachWitnessNet reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals clauseWitnessTiming
        clauseWitnessDealKind SanctionClauseWitness.messagingAccess true
        NetworkKind.financialMessaging ReachWitnessEntity.outside 2 = false := by
  -- 증거의 주체 번짐과 갈래와 구간과 대상이 모두 계산되므로 다섯 등식이 계산으로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

/--
조치의 목록이 비면 어느 변도 잘리지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
조치가 하나도 없는 자리에서 어떤 변이 잘려야 한다. 그 관측은 절단이 조치에서 오지 않는다는 뜻이며,
그러면 금지의 문면이 없는 자리에서도 법적 절단이 서게 된다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 그 진술이 접기의 정의를 넘어 드는 몫을 갖지 않는다. 빈 목록에서 거짓을
내는 것이 그 접기를 고른 선언의 기각 문단에 이미 서 있으므로 그 사실을 드는 유일한 자리가 아니다.
-/
-- DD:CF-4439
theorem cut_by_any_measure_nil_false :
    cutByAnyMeasure reachWitnessOps reachWitnessNet reachWitnessCriteria reachWitnessDesignation
      reachWitnessChains reachWitnessActingFor reachWitnessPrincipals clauseWitnessTiming
      clauseWitnessDealKind [] true ReachWitnessEntity.listed 2
      NetworkKind.financialMessaging = false := by
  -- 빈 목록 위의 접기가 거짓을 낸다.
  rfl

/--
유예의 창이 열리면 같은 거래가 잘리지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 창 안의 거래가 잘리거나, 그 창 밖의 같은 거래가 잘리지 않아야 한다. 앞의 관측은 유예가 금지의
밖에 서는 창이 아니라는 뜻이고 뒤의 관측은 그 창이 금지 자체를 지운다는 뜻이며, 둘 다 체결의 기한과
이행의 기한을 따로 받은 설계가 무너졌음을 가리킨다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 진술이 절단의 정의를 넘어 드는 몫을 갖는다. 한 거래가 금지되는지가 그
거래의 시점만으로 정해지지 않고 그것이 딛는 계약의 체결 시점에 함께 걸린다는 것이 조문의 성질이고,
그 두 시점이 실제로 답을 가르는 자리를 구조 안의 명제로 드는 자리가 여기뿐이다.
-/
-- DD:CF-4424
theorem cuts_deal_exempted_by_grace :
    cutsDealAt reachWitnessOps reachWitnessNet reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals clauseWitnessTiming
        clauseWitnessDealKind { conclusionCutoff := 1, performanceDeadline := 3 }
        SanctionClauseWitness.messagingAccess true NetworkKind.financialMessaging
        ReachWitnessEntity.listed 2 1 2 = false
      ∧ cutsDealAt reachWitnessOps reachWitnessNet reachWitnessCriteria reachWitnessDesignation
        reachWitnessChains reachWitnessActingFor reachWitnessPrincipals clauseWitnessTiming
        clauseWitnessDealKind { conclusionCutoff := 1, performanceDeadline := 3 }
        SanctionClauseWitness.messagingAccess true NetworkKind.financialMessaging
        ReachWitnessEntity.listed 2 2 2 = true := by
  -- 유예의 세 비교와 절단의 곱이 모두 계산되므로 두 등식이 계산으로 닫힌다.
  exact ⟨rfl, rfl⟩

/--
법적으로 남은 변의 판정이 각 인자에서 홀로 갈린다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 멤버십이 서지 않는 쌍에서 참을 내거나 한쪽 끝이 잘린 쌍에서 참을 내야 한다. 앞의 관측은 그
판정이 멤버십을 보지 않는다는 뜻이고 뒤의 관측은 절단이 한쪽 끝에만 걸린다는 뜻이며, 둘 다 그 쌍이
그 망에 드는가와 법이 그 변을 금지하는가를 가른 설계가 무너졌음을 가리킨다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 그 진술이 그 판정의 정의를 넘어 드는 몫을 갖지 않고 A-8 이 요구하는
증거를 드는 자리다. 결론을 부정한 사본이 컴파일에 실패하는 것만으로는 그 사본이 어느 증거 위에서
재어졌는지가 서지 않으므로, 각 인자가 홀로 값을 가르는 자리를 이 정리가 든다.
-/
-- DD:CF-4425
theorem legally_linked_pins_each_conjunct :
    (NetworkMembership.mk (fun _ _ _ => true)).legallyLinked (fun _ _ => false)
        NetworkKind.financialMessaging () () = true
      ∧ (NetworkMembership.mk (fun _ _ _ => false)).legallyLinked (fun _ _ => false)
        NetworkKind.financialMessaging () () = false
      ∧ (NetworkMembership.mk (fun _ _ _ => true)).legallyLinked (fun _ (n : Bool) => n)
        NetworkKind.financialMessaging true false = false
      ∧ (NetworkMembership.mk (fun _ _ _ => true)).legallyLinked (fun _ (n : Bool) => n)
        NetworkKind.financialMessaging false true = false
      ∧ (NetworkMembership.mk (fun _ _ _ => true)).legallyLinked (fun _ (n : Bool) => n)
        NetworkKind.financialMessaging false false = true := by
  -- 멤버십과 절단이 상수나 항등으로 주어져 다섯 등식이 계산으로 닫힌다.
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

/--
멤버십이 서는데 법이 자른 쌍과 법이 자르지 않는데 멤버십이 서지 않는 쌍이 둘 다 있다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 배치에서도 두 판정이 함께 움직여야 한다. 그 관측은 멤버십과 절단이 같은 것을 묻는다는 뜻이며,
그러면 법적으로 남은 변을 두 인자의 곱으로 둔 것이 한 인자로 접힌다.

**존재 형태로 진술하는 까닭(T-6):**
두 판정이 다른 것을 묻는다는 것은 양쪽이 갈리는 쌍을 실제로 들어야 보이고, 임의의 배치에 대한
전칭으로는 그 갈림이 진술되지 않는다. 멤버십과 절단이 같은 값을 주는 배치를 가질 수 있으므로
전칭은 거짓이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 곱이 한쪽만으로 정해지지 않음을 보이고, 멤버십을 덮지 않기로 한 설계가
실제로 두 인자를 쓴다는 것을 구조 안의 명제로 드는 자리가 여기뿐이므로 기여 목록에 든다.
-/
-- DD:CF-4425
theorem exists_pair_split_by_membership_and_cut :
    ∃ (M : NetworkMembership Bool) (cut : NetworkKind → Bool → Bool) (k : NetworkKind)
      (a b c d : Bool),
      M.linked k a b = true ∧ M.legallyLinked cut k a b = false
        ∧ M.linked k c d = false ∧ cut k c = false ∧ cut k d = false := by
  -- 앞 끝이 참일 때만 이어지는 멤버십과 참인 끝만 자르는 절단을 둔다. 앞 쌍은 이어지나 앞 끝이
  -- 잘리고, 뒤 쌍은 어느 끝도 잘리지 않으나 이어지지 않는다.
  exact ⟨⟨fun _ a _ => a⟩, fun _ n => n, NetworkKind.financialMessaging,
    true, false, false, false, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Definition
