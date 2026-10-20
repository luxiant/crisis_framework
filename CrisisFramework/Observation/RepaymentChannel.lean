/-
관측층 — 상환과 조정의 측정 채널

규율: L-14(값을 담지 않고 사상의 명세만 담는다), L-9(의존 방향), L-10(관측층 무차원),
      G-1(측정 방법이 다르면 다른 개념), D-1·D-2(docstring 3항목),
      A-3(witness 의무), D-8(witness 예외), T-2(반증 조건), T-4(가정의 명시).

**이 파일은 답을 조립하지 않는다.** 채널이 무엇을 가를 수 있는지만 들고, 그 항의 답을 짓는
선언은 다음 페이즈가 세운다. 사유가 둘이다. 조립이 정의층의 판정 함수를 부르면 그 공리가 따라와
이 층의 기준선을 넘기는데 그 부류의 처분이 따로 서 있고, 자산이 줄어든 까닭을 가르는 축이 구멍으로
남아 그 칸의 답이 아직 서지 않는다.

**칸이 여섯이고 판정이 셋이다.** 어느 판정도 읽지 않는 필드를 두지 않는다는 원칙이 그 수를
정했다. 만기 분해의 칸을 처음에 두었는데 세 판정 어느 것도 그것을 읽지 않으며, 만기를 가르는
입도가 구멍으로 남아 그 칸이 설 근거가 아직 없다.

**세 판정이 읽는 칸의 집합이 겹치면서 같지 않다.** 그 겹침과 어긋남이 그 항의 답이 여러 축으로
서 있다는 구조의 반영이다. 한쪽만 서는 경로가 있으므로 판정을 하나로 묶지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

/--
상환과 조정의 측정 채널.

**대응 비형식 개념:** 어느 공표 경로가 한 주체의 상환 실패와 조정을 재는 데 필요한 값을 어디까지
가르는가. 재무제표와 감독 공시처럼 서로 다른 경로가 서로 다른 칸에서 막히므로 그 막힘의 자리를
칸으로 받는다.

**이 정의가 배제하는 사례:**
암묵적 유동성 풋(Claessens · Pozsar · Ratnovski · Singh 2012). 시장 조달이 마르자 은행이 법적
의무 없이 자기 기구를 되받은 자리인데, 그 받침이 어느 경로의 칸에도 서지 않는다. 이 구조는 공표
수치가 무엇을 가르는가만 받으므로 공표되지 않는 받침은 칸으로 서지 않고, 그 결손은 채널의 결손이
아니라 구조의 결손이다.

**기각한 대체 정의:**
칸을 하나로 두고 그 항에 답할 수 있는가만 받는 안. 답이 서지 않을 때 어느 자리에서 막혔는지가
사라지는데, 두 총액이 읽히지 않는 것과 인출액이 읽히지 않는 것과 자산 감소의 까닭이 갈리지 않는
것이 서로 다른 결손이다. L-14 가 관측층에 등재되는 소스 없음을 주요 산출물로 들므로 그 결손이
칸으로 갈려야 산출이 된다. 만기 분해를 칸으로 두는 안도 기각했다. 세 판정 어느 것도 그 칸을
읽지 않으며 만기를 가르는 입도가 구멍으로 남아 있다.

**값을 담지 않는다.** 모든 칸이 판정이며 금액을 들지 않는다.
-/
-- DD:CF-1264
structure RepaymentChannel (Entity : Type) where
  /-- 그 주체가 이 경로의 공표 대상에 드는가. -/
  coversEntity : Entity → Bool
  /-- 자산 총액과 부채 총액을 함께 가르는가. -/
  resolvesTotals : Bool
  /-- 그 두 총액을 통화별로 가르는가. 회계층이 통화 간 환산을 금지하므로 가르지 않으면 지급능력
      판정의 입력이 서지 않는다. -/
  resolvesCurrencySplit : Bool
  /-- 당장 내줄 수 있는 것의 액수를 가르는가. 그 범위가 무엇인지는 구멍으로 남아 있으므로, 이
      칸은 경로가 그 범위에 대응하는 값을 드는가를 묻는다. -/
  resolvesCashLike : Bool
  /-- 그 구간에 돌려달라는 요구로 빠져나간 액수를 가르는가. 기말 잔액의 차이가 아니라 구간 중의
      유출이다. -/
  resolvesWithdrawal : Bool
  /-- 자산이 줄어든 까닭을 가르는가. 강제 매각과 자발적 축소와 상환에 따른 소멸이 서로 다른
      까닭이며 그 축이 무엇인지는 구멍으로 남아 있다. -/
  resolvesReductionCause : Bool

/--
witness (A-3).

**무엇을 증거하는가.** 어느 칸도 가르지 못하는 경로가 이 구조에 담긴다는 것. 소스가 전무한
자리를 구조가 표현할 수 있어야 L-14 의 소스 없음이 값으로 등재된다.
-/
-- DD:CF-1264
def RepaymentChannel.noSource {Entity : Type} : RepaymentChannel Entity where
  coversEntity := fun _ => false
  resolvesTotals := false
  resolvesCurrencySplit := false
  resolvesCashLike := false
  resolvesWithdrawal := false
  resolvesReductionCause := false

/--
지급능력을 답할 수 있는가.

**대응 비형식 개념:** 이 경로가 그 주체의 지급능력 조건이 성립했는지를 낼 수 있는가. 회계층의
판정이 통화로 색인된 두 총액을 받으므로 총액과 통화 분해가 함께 서야 한다.

**이 정의가 배제하는 사례:**
2020년 3월 미국 국채시장의 혼란(E-04 §2). 그 구간에 보유 주체의 두 총액이 공시되고 있었으므로
이 판정이 참을 내는데, 지급능력이 깨지지 않은 채 조달이 조인 것이 그 사건의 요지다. 이 판정은
답을 낼 수 있는가만 묻고 그 답이 위기를 설명하는가를 묻지 않는다.

**기각한 대체 정의:**
인출 충족의 판정과 하나로 묶어 그 항에 답할 수 있는가만 내는 안. 두 판정이 읽는 칸이 다르고
서로를 함의하지 않으므로, 묶으면 한쪽만 서는 경로에서 어느 쪽이 섰는지가 사라진다. 재무제표
경로가 바로 그 경우여서 두 총액은 읽히고 인출액은 읽히지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-1264
def RepaymentChannel.answersSolvency {Entity : Type}
    (C : RepaymentChannel Entity) (n : Entity) : Bool :=
  C.coversEntity n && C.resolvesTotals && C.resolvesCurrencySplit

/--
인출 충족을 답할 수 있는가.

**대응 비형식 개념:** 이 경로가 그 구간에 돌려달라는 요구를 당장 내줄 수 있는 것으로 맞추었는지를
낼 수 있는가. 회계층의 판정이 빠져나간 액수와 당장 내줄 수 있는 것의 액수를 받는다.

**이 정의가 배제하는 사례:**
노던록의 도매 조달이 마른 것(Adrian · Shin 2010 · E-03 §3-4). 그 자리에서 빠져나간 것이 롤오버 거부였고
만기가 와서 돌려준 것과 요구를 받아 돌려준 것이 공시에서 갈리지 않으므로, 이 판정이 참을 내는
경로에서도 그 둘이 섞인 값이 나온다. 요구인가를 가르는 칸은 이 구조에 없다.

**기각한 대체 정의:**
두 총액의 칸을 함께 요구하는 안. 인출 충족이 두 총액을 받지 않으므로 함께 요구하면 인출액과
현금성은 읽히는데 두 총액이 읽히지 않는 경로가 답하지 못하는 것으로 접히며, 그 접힘의 까닭이
판정의 과잉 요구라서 경로의 결손과 구별되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-1264
def RepaymentChannel.answersWithdrawalCoverage {Entity : Type}
    (C : RepaymentChannel Entity) (n : Entity) : Bool :=
  C.coversEntity n && C.resolvesCashLike && C.resolvesWithdrawal

/--
자산 감소를 답할 수 있는가.

**대응 비형식 개념:** 이 경로가 그 주체의 대차대조표가 줄었는지와 왜 줄었는지를 함께 낼 수
있는가. 조정이 일어났다는 답이 그 둘을 함께 요구한다.

**이 정의가 배제하는 사례:**
2007-08년 손실의 대차대조표 배분(Greenlaw · Hatzius · Kashyap · Shin 2008). 손실이 어디에
얼마나 앉았는지를 추적한 자리인데, 그 추적이 공표 수치가 아니라 저자들의 추정으로 메워졌다. 그
추정을 경로로 두면 이 판정이 참을 내지만 공표 수치가 그 까닭을 가른 것이 아니다.

**기각한 대체 정의:**
자산 감소의 까닭을 읽지 않고 두 총액의 변화만으로 판정하는 안. 자산 총액이 줄었다는 것과 조정이
일어났다는 것이 다르며, 상환으로 부채가 소멸하면 자산도 함께 주는데 그것은 의무의 이행이고
조정이 아니다. 까닭을 읽지 않으면 그 둘이 같은 답을 받는다.

**값을 담지 않는다.**
-/
-- DD:CF-1264
def RepaymentChannel.answersReduction {Entity : Type}
    (C : RepaymentChannel Entity) (n : Entity) : Bool :=
  C.coversEntity n && C.resolvesTotals && C.resolvesReductionCause

/--
재무제표 경로.

**대응 비형식 개념:** 공표 재무제표에서 읽는 경로. 자산 총액과 부채 총액을 들고 공시 대상인
주체를 인자로 받는다.

**이 정의가 배제하는 사례:**
화환신용장의 유효기일(UCP 600 제7조 (b)). 개설 시점에 의무가 서고 유효기일이 명시되나 실제
결제가 서류 제시에 달려 있으므로, 재무제표가 그 금액을 기재해도 그것이 어느 구간에 빠져나갈지는
그 공시에 서지 않는다. 그래서 이 경로의 인출액 칸이 거짓이다.

**기각한 대체 정의:**
모든 칸을 참으로 두는 안. 자산 감소의 까닭을 가르는 축이 서지 않았으므로 그 칸을 참으로 두면
재는 수단이 없는 것을 소스 있음으로 적는다. 공표 재무제표가 자산의 감소액을 들더라도 그것이
강제 매각인지 자발적 축소인지를 들지 않는다. 인출액의 칸도 같은 자리에 서는데 공시가 구간 중의
유출을 들지 않고 기말 잔액만 든다.

**값을 담지 않는다.**
-/
-- DD:CF-1264
def financialStatementRepaymentChannel {Entity : Type} (discloses : Entity → Bool) :
    RepaymentChannel Entity where
  coversEntity := discloses
  resolvesTotals := true
  resolvesCurrencySplit := false
  resolvesCashLike := false
  resolvesWithdrawal := false
  resolvesReductionCause := false

/--
재무제표 경로는 세 판정 어느 것에서도 답을 내지 못한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:** 공표 재무제표가 두 총액을 통화별로 가르거나,
당장 내줄 수 있는 것의 액수와 그 구간의 유출을 함께 들거나, 자산이 줄어든 까닭을 가르는 것.
셋 가운데 하나라도 관측되면 그 칸이 참으로 바뀌어 이 명제가 깨진다.

**가정과 그 배제 사례(T-4·T-5):** 그 주체가 공시 대상이라는 가정을 진술에 명시한다. 공시
대상이 아닌 주체에서는 대상 포괄의 칸이 거짓이어서 세 판정이 다른 까닭으로 거짓을 내므로, 이
명세가 재려는 것이 그 자리에서 흐려진다. 가정은 그 자리를 배제한다.

**이 정리가 소스 없음을 구조로 남긴다.** 두 총액이 공시되는데도 지급능력을 답하지 못하는 것이
이 진술의 요지이며, 회계층의 판정이 통화로 색인된 총액을 받기 때문이다. L-12 가 환산을 금지한
것이 관측의 자리에서 결손으로 되돌아온다.
-/
-- DD:CF-1264
theorem financialStatementRepaymentChannel_answers_none {Entity : Type}
    (discloses : Entity → Bool) (n : Entity) (hn : discloses n = true) :
    (financialStatementRepaymentChannel discloses).answersSolvency n = false ∧
    (financialStatementRepaymentChannel discloses).answersWithdrawalCoverage n = false ∧
    (financialStatementRepaymentChannel discloses).answersReduction n = false := by
  -- 세 판정이 전부 칸 셋의 `&&` 연쇄이므로, 경로의 칸 값을 그 자리에 넣고 대상 포괄의 칸을
  -- 가정으로 참으로 바꾼 뒤 `Bool` 의 계산으로 닫는다. 전면 `simp` 를 쓰지 않고 보조정리를
  -- 명시 고정한다(C-9). 세 갈래가 같은 꼴이므로 한 전술 블록을 셋에 함께 건다.
  refine ⟨?_, ?_, ?_⟩ <;>
    · simp only [RepaymentChannel.answersSolvency,
        RepaymentChannel.answersWithdrawalCoverage, RepaymentChannel.answersReduction,
        financialStatementRepaymentChannel]
      rw [hn]
      rfl

end CrisisFramework.Observation
