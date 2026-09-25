/-
용어집 — 핵심 개념

규율: V-1(개념의 존재와 관계만), V-2(관계 4종), V-6(A-3 적용 제외).
이 파일은 성질을 담지 않는다. 성질을 갖는 정의는 Definition/ 이하에 둔다(D-7).

이 파일은 네 형식층 전체의 선행 조건이며 어떤 층도 아니다.
따라서 수를 쓰지 않고, 다른 어떤 CrisisFramework 모듈도 import 하지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

namespace CrisisFramework.Glossary

/--
개념 식별자.

집계 정리(J-9)에 필요한 최소 집합만 등재한다. 확장은 사용처가 생길 때 한다.
-/
-- DD:CF-76
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
  /-- 신호. 발동조건이 읽는 것. 아래 둘의 상위 개념이며 형식층 대상을 갖지 않는다. -/
  | signal
  /-- 검증 가능 신호. 계약 당사자와 법원이 함께 확인할 수 있는 감사된 회계수치. -/
  | verifiableSignal
  /-- 외생 확인 신호. 모형이 계산하지 않고 밖에서 받는 판정. -/
  | exogenousSignal
  /-- 발동조건. 조건부 청구권이 요구를 발생시키는 조건. -/
  | triggerCondition
  deriving DecidableEq, Repr

/--
측정 소스 태그.

**이름만 둔다.** 실제 측정 사상의 명세는 관측층(Observation/)이 보유한다.

L-9의 의존 방향이 관측층 → 정의층이므로, 용어집이 관측층을 참조할 수 없다.
그래서 태그와 명세가 분리된다. 이 분리는 층 구조가 강제한 것이지 설계 선택이 아니다.
-/
-- DD:CF-57
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
-- DD:CF-77
inductive ConceptRel where
  /-- 정제: `special` 은 `general` 의 특수 사례다. -/
  | refines (special general : Concept)
  /-- 배타: 두 개념은 겹치지 않는다. -/
  | excludes (a b : Concept)
  /-- 분할: `whole` 이 `parts` 로 나뉜다. 완전성은 증명되지 않는다(V-7). 정의만으로 따라 나오는 분할은 예외이며 그 경우 어느 귀결인지를 명시한다. -/
  | partitions (whole : Concept) (parts : List Concept)
  /-- 측정 대응: 해당 개념이 이 소스로 측정된다. 명세는 관측층. -/
  | measuredBy (c : Concept) (s : SourceTag)
  deriving Repr

/--
등록된 관계.

**주의:** `partitions` 의 완전성은 V-7에 따라 가정이며 기여 목록에 계상하지 않는다.
정의만으로 따라 나오는 분할은 예외인데 아래 등록분은 거기에 들지 않는다.
제약이 부채 측과 자산 측 둘로 나뉜다는 것은 현재까지 확인된 두 종류일 뿐,
셋째가 없다는 증명이 아니다.

**신호 분할의 V-4 사례.** 2007-08년에 같은 기능을 하던 두 종류의 유동성 풋이 갈렸다. 은행이
도관에 계약상 크레딧 라인으로 제공한 풋은 담보가치 하락과 ABCP 롤 실패와 헤어컷 상승을 거쳐
실제로 발동했고, SIV 와 도관에 대한 암묵적 풋은 이행되지 않았다. 갈린 자리가 조건이 문서에
있었는가이며, 그것이 검증 가능 신호와 외생 확인 신호를 가르는 축과 같다.
`docs/extractions/extraction-06-pozsar-adrian-ashcraft-boesky-2010.md` §10 이 그 대비를 든다.

**`measuredBy` 를 신호에 붙이지 않는다.** 신호에 측정 소스를 대응시키는 일은 관측 명세를
세우는 페이즈의 몫이고, 그 자리에서 관측자 상대성의 구멍이 발화하기 때문이다.
-/
-- DD:CF-58
def registry : List ConceptRel :=
  [ .partitions .constraint [.constraintLiabilityCap, .constraintAssetEligibility]
  , .excludes .constraintLiabilityCap .constraintAssetEligibility
  , .refines .equity .balanceSheet
  , .measuredBy .equity .regulatoryFiling
  , .measuredBy .balanceSheet .regulatoryFiling
  , .measuredBy .creditSupply .flowOfFunds
  , .partitions .signal [.verifiableSignal, .exogenousSignal]
  , .excludes .verifiableSignal .exogenousSignal
  ]

end CrisisFramework.Glossary
