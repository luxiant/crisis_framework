/-
용어집 — 핵심 개념

규율: V-1(개념의 존재와 관계만), V-2(관계 4종), V-6(A-3 적용 제외).
이 파일은 성질을 담지 않는다. 성질을 갖는 정의는 Definition/ 이하에 둔다(D-7).

이 파일은 네 형식층 전체의 선행 조건이며 어떤 층도 아니다.
따라서 수를 쓰지 않고, 다른 어떤 CrisisFramework 모듈도 import 하지 않는다.

원장: (미배정 — R-1에 따라 첫 병합 전 발행 필요)
-/

namespace CrisisFramework.Glossary

/--
개념 식별자.

집계 정리(J-9)에 필요한 최소 집합만 등재한다. 확장은 사용처가 생길 때 한다.
-/
inductive Concept where
  /-- 의사결정 단위. 대차대조표 관리의 결정이 하나로 내려지는 최소 단위. 노드의 정의. -/
  | decisionUnit
  /-- 대차대조표. 통화로 색인된 족(L-12). -/
  | balanceSheet
  /-- 자기자본. 대차대조표의 잔여 항목. -/
  | equity
  /-- 제약. 노드가 무엇을 할 수 있는지의 한계. -/
  | constraint
  /-- 부채 측 한도. 얼마나 빌릴 수 있는가. -/
  | constraintLiabilityCap
  /-- 자산 측 적격성. 무엇을 보유할 수 있는가. -/
  | constraintAssetEligibility
  /-- 신용공급. 노드가 공여할 수 있는 신용의 양. -/
  | creditSupply
  deriving DecidableEq, Repr

/--
측정 소스 태그.

**이름만 둔다.** 실제 측정 사상의 명세는 관측층(Observation/)이 보유한다.

L-9의 의존 방향이 관측층 → 정의층이므로, 용어집이 관측층을 참조할 수 없다.
그래서 태그와 명세가 분리된다. 이 분리는 층 구조가 강제한 것이지 설계 선택이 아니다.
-/
inductive SourceTag where
  /-- 규제 공시 (10-K, 10-Q 등). -/
  | regulatoryFiling
  /-- BIS 소재지 기준 은행통계. -/
  | bisLocational
  /-- 자금순환표. -/
  | flowOfFunds
  deriving DecidableEq, Repr

/--
개념 간 관계.

V-2에 따라 정확히 넷이다. 다섯 번째 생성자를 추가하려면 규율 개정이 선행되어야 하며,
그 필요 자체를 P-1의 수확으로 기록해야 한다.

**알려진 미해결:** 화폐성이 배타적 분할이 아니라 스펙트럼이라는 사실이 이 넷으로
표현되지 않는다. 현재 구멍 목록에 등재되어 있고, 집계 정리는 이 문제에 걸리지 않으므로
이번 단계에서는 개정하지 않는다.
-/
inductive ConceptRel where
  /-- 정제: `special` 은 `general` 의 특수 사례다. -/
  | refines (special general : Concept)
  /-- 배타: 두 개념은 겹치지 않는다. -/
  | excludes (a b : Concept)
  /-- 분할: `whole` 이 `parts` 로 나뉜다. 완전성은 증명되지 않는다(V-3). -/
  | partitions (whole : Concept) (parts : List Concept)
  /-- 측정 대응: 해당 개념이 이 소스로 측정된다. 명세는 관측층. -/
  | measuredBy (c : Concept) (s : SourceTag)
  deriving Repr

/--
등록된 관계.

**주의:** `partitions` 의 완전성은 V-3에 따라 가정이며 기여 목록에 계상하지 않는다.
제약이 부채 측과 자산 측 둘로 나뉜다는 것은 현재까지 확인된 두 종류일 뿐,
셋째가 없다는 증명이 아니다.
-/
def registry : List ConceptRel :=
  [ .partitions .constraint [.constraintLiabilityCap, .constraintAssetEligibility]
  , .excludes .constraintLiabilityCap .constraintAssetEligibility
  , .refines .equity .balanceSheet
  , .measuredBy .equity .regulatoryFiling
  , .measuredBy .balanceSheet .regulatoryFiling
  , .measuredBy .creditSupply .flowOfFunds
  ]

end CrisisFramework.Glossary
