/-
정의층 — 제약과 노드

규율: L-10(정의층은 수를 쓰지 않는다. 시점 인덱스 ℕ 예외),
      L-13(정의층 대상은 시점 인덱스를 갖는 족),
      A-3(witness 의무), D-1·D-2(docstring 3항목).

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import Mathlib.Data.Finset.Basic
import CrisisFramework.Glossary.Core

namespace CrisisFramework.Definition

/--
제약.

**대응 비형식 개념:** 노드가 무엇을 할 수 있는지의 한계. 부채 측 한도와 자산 측 적격성의 쌍.

**이 정의가 배제하는 사례:**
2008년 이후 은행들이 대규모 자본확충으로 대응한 사례. 이 구조는 제약을 주어진 것으로
두고 자기자본을 외생으로 취급한다. 자기자본을 조정해 제약을 완화하는 경로가 표현되지 않는다.
원 논문들도 자기자본 경직성을 가정이라고 인정하며 그 사유는 범위 밖이라고 밝힌다.

**기각한 대체 정의:**
제약을 단일 상한으로 두는 안. 기관 현금풀의 예금보험 한도·익스포저 한도·수탁자 책임은
전부 "무엇을 보유할 수 있는가"이지 "얼마나 빌릴 수 있는가"가 아니다. 대출 심사 기준 완화도
같은 축이다. 단일 상한으로는 이 축이 표현되지 않아 기각했다.

**수치 타입:** `Num` 으로 추상화한다. 정의층은 구체 수 체계를 언급하지 않는다(L-10).
`Num` 의 실제 인스턴스화는 회계층에서 `ℚ` 로 이루어진다.
-/
-- DD:CF-130
structure Constraint (Num Currency Asset : Type) where
  /-- 부채 측 한도. 통화 축별로 다른 값을 갖는다(L-12, 중앙은행의 비대칭). -/
  liabilityCap : Currency → Num
  /-- 자산 측 적격성. 어떤 자산을 보유할 수 있는가. -/
  assetEligible : Asset → Prop

/--
witness 인스턴스 (A-3).

가장 단순한 비어 있지 않은 제약. 한도가 `Unit` 이고 모든 자산이 적격이다.
-/
-- DD:CF-31
def Constraint.trivial : Constraint Unit Unit Unit where
  liabilityCap := fun _ => ()
  assetEligible := fun _ => True

/--
노드의 자기자본과 제약을 묶은 상태.

**대응 비형식 개념:** 하나의 의사결정 단위가 특정 시점에 갖는 대차대조표 여력의 결정 요소.

**이 정의가 배제하는 사례:**
같은 법인 안에서 정부 데스크와 크레딧 데스크가 서로 다른 화폐성 위계에 놓이는 경우.
이 구조는 노드마다 제약이 하나이므로, 한 법인이 여러 노드로 갈리는 것은 표현되지만
한 노드 안에서 제약이 갈리는 것은 표현되지 않는다.

**기각한 대체 정의:**
노드를 법인으로 두는 안. 여러 법인의 현금을 단일 의사결정자가 관리하는 사례가 있어
법인과 노드가 다대다이며, 소유 구조와 무관하게 분석이 성립한다는 것이 확인되었다.
-/
-- DD:CF-122
structure NodeState (Num Currency Asset : Type) where
  /-- 자기자본. -/
  equity : Currency → Num
  /-- 이 노드에 걸린 제약. -/
  constraint : Constraint Num Currency Asset

/-- witness (A-3). -/
-- DD:CF-31
def NodeState.trivial : NodeState Unit Unit Unit where
  equity := fun _ => ()
  constraint := Constraint.trivial

/--
시점 인덱스를 갖는 노드 집합 족 (L-13).

**대응 비형식 개념:** 시스템에 존재하는 노드의 집합. 시간에 따라 변한다.

**이 정의가 배제하는 사례:** 없음 — 오히려 이 정의는 다음을 담기 위해 도입되었다.
위기 대응으로 손실 흡수용 법인이 신설되어 노드 집합 자체가 바뀌는 경우.
정태적 노드 집합으로는 이것이 표현되지 않는다.

**기각한 대체 정의:**
노드 집합을 시점 무관하게 두고 시간 의존을 회계층에서만 처리하는 안.
짭란티어가 시계열 시뮬레이션을 수행하므로 재유입 시 정의층에 시점이 필요하다.

**인덱스가 `ℕ` 인 것은 L-10 위반이 아니다.** L-13의 명시적 예외다.
-/
-- DD:CF-50
def NodeFamily (Node : Type) := ℕ → Finset Node

/-- witness (A-3). -/
-- DD:CF-31
def NodeFamily.empty (Node : Type) : NodeFamily Node := fun _ => ∅

end CrisisFramework.Definition
