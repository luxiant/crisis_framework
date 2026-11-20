/-
관측층 — 지정이 읽히는 경로와 그 경로가 답하지 않는 물음

규율: L-14(값을 담지 않는다), L-10(관측층은 무차원), D-2(docstring 3항목),
      D-3(실제 역사 사례), T-2(반증 조건), T-3(분류), T-6(존재 형태),
      A-3(witness), A-8(논리 결합의 증거).

**값을 담지 않는다.** 이 파일은 어느 공시 경로가 무엇을 내는지의 명세만 담고 수를 담지 않는다.
열거의 구성원임을 뒤집는 개별 허가에 측정 소스가 없다는 것이 이 파일의 산출이다.

**경로를 넷으로 두고 물음을 넷으로 둔다.** 같은 목록을 읽는 경로가 꼴마다 갈리고 조문의 통합본이
또 하나의 경로를 내므로 경로를 하나로 접으면 꼴마다 갈린 답이 사라지며, 네 물음이 정의층이 세운
칸과 하나씩 맞선다. 앞 페이즈의 채널이 구조 하나에 판정 여럿을 둔 것이 선례다.

**증명의 닫음을 상수 목록 위의 계산으로 둔다.** 이 층의 공리 기준선이 공리 없음이고 목록의
멤버십을 접는 전술이 명제 외연성을 끌어오므로, 그 꼴을 쓰지 않고 증거를 생성자로 직접 든다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion

namespace CrisisFramework.Observation

/--
지정을 읽는 경로.

**대응 비형식 개념:** 제재를 부과하는 당국이나 그 목록을 공표하는 주체가 내는 하나의 꼴. 그 꼴이
주체를 식별하고 시점과 사유와 허가를 내거나 내지 않는다.

**이 정의가 배제하는 사례:**
한 발행 주체에 경로 하나를 두는 읽기. 같은 명세가 한 공표에 딸린 파일을 고정 길이와 쉼표 구분과
표지 언어의 두 꼴로 열거하므로, 발행 주체마다 사상을 하나 두면 꼴 사이의 갈림이 사라진다.
조달처: E-69 §2-1 「같은 목록을 읽는 경로가 넷이고 그 넷이 같은 구조를 내지 않는다」

**기각한 대체 정의:**
경로의 이름만 담고 무엇에 답하는지를 담지 않는 안. 그러면 소스 없음이 무엇에 대한 없음인지가 서지
않아 관측층에 등재되는 소스 없음이 산출로 읽히지 않는다. 칸의 열거를 고정으로 두고 경로마다 그
칸을 복제하는 안도 기각했다. 그 명세가 자료 구조의 형식 변경을 미리 알리는 것이 늘 가능하지는 않다고
적으므로 칸을 고정으로 두면 그 명세가 발행 주체의 조작으로 조용히 낡는다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거이며 수를 들지 않는다.
-/
-- DD:CF-4255
structure DesignationChannel (Node : Type) where
  /-- 그 경로를 내는 쪽. -/
  publisher : Node
  /-- 지정된 주체를 그 경로가 식별하는가. -/
  showsSubject : Bool
  /-- 그 지정이 언제부터 효력을 갖는지를 그 경로가 내는가. -/
  showsTime : Bool
  /-- 그 지정이 어느 사유로 섰는지를 그 경로가 내는가. -/
  showsGround : Bool
  /-- 그 주체의 거래가 개별 허가로 풀렸는지를 그 경로가 내는가. -/
  showsRelief : Bool

/-- witness (A-3). **무엇을 증거하는가.** `DesignationChannel` 이 비어 있지 않다. 어느 칸도
내지 않는 경로 하나를 든다. -/
-- DD:CF-4255
def DesignationChannel.noSource : DesignationChannel Unit where
  publisher := ()
  showsSubject := false
  showsTime := false
  showsGround := false
  showsRelief := false

/--
그 경로가 지정된 주체의 식별에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 어느 주체가 지정됐는지를 말할 수 있는가.

**이 정의가 배제하는 사례:**
이름으로 주체를 찾는 경로가 그 답을 유일하게 준다는 읽기. 대체 식별의 표가 고유 식별자에 걸리는
다른 이름을 세 유형으로 들므로 이름으로 찾으면 한 주체에 여럿이 선다.
조달처: E-69 §2-3 「이름으로 주체를 찾는 경로가 한 주체에 여럿을 낸다」

**기각한 대체 정의:**
답함을 다섯 칸의 논리합으로 두는 안. 그러면 다른 물음에 답하는 경로가 이 물음에도 답하는 것으로
세어진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4255
def DesignationChannel.answersSubject {Node : Type}
    (C : DesignationChannel Node) : Bool :=
  C.showsSubject

/--
그 경로가 지정의 시점에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 그 지정이 언제부터 효력을 갖는지를 말할 수 있는가.

**이 정의가 배제하는 사례:**
고정 길이의 주 표가 그 답을 준다는 읽기. 그 표가 드는 칸이 고유 식별자와 이름과 유형과 제재 계획의
이름과 직함과 선박 관련 칸들과 비고인데 그 가운데 어느 칸도 시점을 들지 않는다.
조달처: E-69 §2-2 「그 가운데 어느 칸도 그 지정이 언제부터 효력을 갖는지를 들지 않는다」

**기각한 대체 정의:**
시점을 발행 주체마다 하나로 두는 안. 같은 발행 주체의 한 꼴이 시점을 내고 다른 꼴이 내지 않으므로
발행 주체로 접으면 그 갈림이 사라진다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4257
def DesignationChannel.answersTime {Node : Type}
    (C : DesignationChannel Node) : Bool :=
  C.showsTime

/--
그 경로가 지정의 사유에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 그 주체가 어느 사유로 지정됐는지를 말할 수 있는가.

**이 정의가 배제하는 사례:**
제재 계획의 이름이 그 답을 준다는 읽기. 그 이름은 어느 계획 아래의 지정인지를 들고 그 계획 안에서
부를 가르는 표제를 들지 않으므로, 사유의 가름이 그 칸에서 나오지 않는다.
조달처: E-68 §2-6 「부를 셋으로 가르면서 부마다 표제를 두어」

**기각한 대체 정의:**
사유를 시점과 한 칸으로 묶는 안. 사유를 내는 경로와 시점을 내는 경로가 같지 않으므로 묶으면 한
경로가 둘 가운데 하나만 낼 때 그 칸의 값이 서지 않는다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4257
def DesignationChannel.answersGround {Node : Type}
    (C : DesignationChannel Node) : Bool :=
  C.showsGround

/--
그 경로가 개별 허가에 답하는가.

**대응 비형식 개념:** 그 경로 하나만 보고 어느 지정된 주체의 거래가 허가로 풀렸는지를 말할 수
있는가.

**이 정의가 배제하는 사례:**
목록에 그 주체가 남아 있는 것이 허가가 없다는 뜻이라는 읽기. 그 명세가 열거된 당사자와의 거래가
허가될 수 있음을 적으면서 허가를 드는 칸을 어느 표에도 두지 않으므로, 목록에 남아 있다는 것이
허가의 유무를 말해 주지 않는다.
조달처: E-69 §2-6 「열거된 당사자와의 거래가 허가될 수 있음을 적는다」

**기각한 대체 정의:**
허가를 절단의 판정에서 빼고 허가의 물음을 세우지 않는 안. 그러면 구성원임이 금지의 성립과 같지 않다는
구조가 정의층에 서 있는데 그 차이를 내는 값의 소스가 어디에도 묻히지 않아 그 결손이 산출로 서지
않는다.

**수 체계를 받지 않는다.** 판정이 참거짓이며 수를 들지 않는다.
-/
-- DD:CF-4256
def DesignationChannel.answersRelief {Node : Type}
    (C : DesignationChannel Node) : Bool :=
  C.showsRelief

/--
고정 길이의 주 표.

**대응 비형식 개념:** 그 목록을 고정 길이의 꼴로 내는 파일의 주된 표. 주체를 고유 식별자로
식별하고 시점과 사유와 허가를 들지 않는다.

**이 정의가 배제하는 사례:**
이 표가 시점을 낸다는 읽기. 그 명세가 이 표의 칸을 열거하는데 그 가운데 어느 칸도 그 지정이
언제부터 효력을 갖는지를 들지 않는다.
조달처: E-69 §2-2 「쉼표로 구분한 꼴의 주 표도 같은 칸을 든다」

**기각한 대체 정의:**
쉼표로 구분한 꼴을 고정 길이의 꼴과 한 항으로 묶는 안. 두 꼴이 같은 칸을 들어 답이 같으므로 묶으면
계수가 줄어 편하나, 꼴마다 답이 갈리는지를 묻는 것이 이 파일의 축이어서 묶으면 그 축이 꼴을
세지 않는 것이 된다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거다.
-/
-- DD:CF-4255
def fixedWidthPrimaryTable : DesignationChannel Unit where
  publisher := ()
  showsSubject := true
  showsTime := false
  showsGround := false
  showsRelief := false

/--
쉼표로 구분한 주 표.

**대응 비형식 개념:** 같은 목록을 쉼표로 구분한 꼴로 내는 파일의 주된 표.

**이 정의가 배제하는 사례:**
이 꼴이 고정 길이의 꼴과 다른 칸을 든다는 읽기. 그 명세가 이 꼴의 주 표도 같은 칸을 든다고
적으므로 두 꼴의 답이 갈리지 않는다.
조달처: E-69 §2-2 「쉼표로 구분한 꼴의 주 표도 같은 칸을 든다」

**기각한 대체 정의:**
쉼표로 구분한 주 표를 목록에서 빼는 안. 같은 발행 주체의 네 꼴 가운데 둘이 같은 답을 내고 둘이 다른 답을 내는
것이 이 파일의 관측이므로, 빼면 그 둘이 같다는 사실이 사라진다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거다.
-/
-- DD:CF-4255
def delimitedPrimaryTable : DesignationChannel Unit where
  publisher := ()
  showsSubject := true
  showsTime := false
  showsGround := false
  showsRelief := false

/--
진보된 표지 언어의 꼴.

**대응 비형식 개념:** 같은 목록을 진보된 표지 언어로 내는 파일. 제재 항마다 사건을 두고 사건마다
날짜와 법적 근거의 지목을 든다.

**이 정의가 배제하는 사례:**
이 꼴이 허가를 낸다는 읽기. 그 스키마가 제재 항 아래에 사건과 조치를 두고 각각 날짜와 기간을
필수로 들되 허가를 드는 요소를 두지 않는다.
조달처: E-69 §3-2 「조치 갈래의 식별자를 속성으로 든다」

**기각한 대체 정의:**
기본 표지 언어의 꼴을 진보된 꼴과 묶는 안. 그 명세가 표지 언어를 기본과 진보된 것의 둘로 가르고 이
파일이 연 것이 뒤의 것이므로, 묶으면 읽지 않은 편의 성질을 근거로 쓰는 것이 된다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거다.
-/
-- DD:CF-4257
def advancedMarkupForm : DesignationChannel Unit where
  publisher := ()
  showsSubject := true
  showsTime := true
  showsGround := true
  showsRelief := false

/--
통합본의 부속서 표.

**대응 비형식 개념:** 제재를 부과하는 당국의 조문을 따라 편집된 문서가 드는 부속서의 표. 부로
갈려 사유를 내고 항마다 발효일 칸을 든다.

**이 정의가 배제하는 사례:**
이 경로가 정본이라는 읽기. 그 문서의 머리가 이 문면을 순전히 문서화 도구로 두고 관련 행위의 정본이
관보에 공표된 것이라고 적으므로, 이 경로로 읽는 쪽이 손에 쥐는 것은 정본의 사본이 아니다.
조달처: E-68 §2-1 「이 문면을 순전히 문서화 도구로 두고 법적 효력이 없다고 적으며」

**기각한 대체 정의:**
통합본의 부속서 표를 관보의 경로와 한 항으로 묶는 안. 이 파일이 연 것이 통합본이고 관보는 열지 않았으므로,
묶으면 열지 않은 편의 성질이 이 항의 칸으로 선다.

**수 체계를 받지 않는다.** 다섯 칸이 전부 판정과 열거다.
-/
-- DD:CF-4255
def consolidatedAnnexTable : DesignationChannel Unit where
  publisher := ()
  showsSubject := true
  showsTime := true
  showsGround := true
  showsRelief := false

/--
이 회차가 든 경로의 목록.

**대응 비형식 개념:** 네 물음에 답할 법한 경로를 모은 것.

**이 정의가 배제하는 사례:**
전신 규약의 메시지를 이 목록에 넣는 읽기. 그 규약의 메시지는 통화와 금액을 내고 지정의 네 물음
가운데 어느 것도 내지 않으므로, 넣으면 목록이 답하지 않는 경로로 불어난다.
조달처: E-42 §2-2 「32B 가 통화 코드와 금액을 함께 담고 필수다」

**기각한 대체 정의:**
목록을 물음마다 따로 두는 안. 그러면 한 경로가 여러 목록에 들고 그 중복이 관측 결과의 계산에서
되풀이되며, 경로를 더하는 회차가 어느 목록에 더할지를 매번 고르게 된다.

**수 체계를 받지 않는다.** 목록이 경로를 들며 수를 들지 않는다.
-/
-- DD:CF-4255
def designationChannels : List (DesignationChannel Unit) :=
  [fixedWidthPrimaryTable, delimitedPrimaryTable, advancedMarkupForm, consolidatedAnnexTable]

/--
지정된 주체의 식별이 어느 경로에서 관측되는가.

**대응 비형식 개념:** 그 목록의 어느 경로가 그 물음에 답하는 것.

**이 정의가 배제하는 사례:**
그 식별이 유일하다고 보는 읽기. 대체 식별의 표가 한 고유 식별자에 여러 이름을 걸고 주소의 표가 한
주체에 여러 주소를 거므로, 그 식별이 관측되는 것과 유일한 것이 다르다.
조달처: E-69 §2-4 「주체의 식별이 이름에서도 주소에서도 단일하지 않다」

**기각한 대체 정의:**
참거짓을 내는 안. 소스가 없다는 것과 그 명제가 거짓이라는 것이 다르므로 판정 불가의 칸이 따로
필요하며, 삼분을 드는 열거가 그 칸을 받는다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4255
def designatedSubjectObserved {Node : Type}
    (chs : List (DesignationChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersSubject) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
지정의 시점이 어느 경로에서 관측되는가.

**대응 비형식 개념:** 그 목록의 어느 경로가 그 물음에 답하는 것.

**이 정의가 배제하는 사례:**
시점이 확정된 날짜로 관측된다고 보는 읽기. 그 스키마의 기간 요소가 연과 월과 일의 고정 여부를
각각 필수 속성으로 두므로, 날짜를 확정된 값으로 읽는 경로에서 그 불확정성이 버려진다.
조달처: E-69 §3-3 「시점이 값이 아니라 구간과 확정성의 짝이다」

**기각한 대체 정의:**
시점을 소스 없음으로 두는 안. 진보된 표지 언어의 꼴과 통합본의 부속서가 시점을 내므로 소스가 없는
것이 아니라 꼴마다 갈리는 것이다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4257
def designationTimeObserved {Node : Type}
    (chs : List (DesignationChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersTime) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
지정의 사유가 어느 경로에서 관측되는가.

**대응 비형식 개념:** 그 목록의 어느 경로가 그 물음에 답하는 것.

**이 정의가 배제하는 사례:**
사유가 어느 경로에서도 관측되지 않는다고 보는 읽기. 부속서가 부마다 표제를 두어 사유를 가르고 그
스키마가 법적 근거의 식별자를 사건의 속성으로 들므로 두 경로가 그 물음에 답한다.
조달처: E-69 §3-5 「사건 요소가 그 근거의 식별자를 지목한다」

**기각한 대체 정의:**
사유를 내는 경로의 수를 내는 안. 이 층이 담는 것이 사상의 명세이고 계수가 아니므로 수를 내면 값을
담지 않는다는 요구가 깨진다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4257
def designationGroundObserved {Node : Type}
    (chs : List (DesignationChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersGround) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
개별 허가가 어느 경로에서도 관측되지 않는다.

**대응 비형식 개념:** 그 목록의 어느 경로도 그 물음에 답하지 않는 것.

**이 정의가 배제하는 사례:**
한 경로라도 답하면 관측된 것으로 보는 읽기. 이 물음은 그 목록 전체에 대한 것이고 한 경로의 성질이
아니므로, 경로 하나로 판정하면 목록의 나머지가 읽히지 않는다.
조달처: E-69 §5-2 「잘렸는가의 판정이 열거의 구성원임만으로 서지 않는다」

**기각한 대체 정의:**
판정 불가의 까닭을 구조가 대상을 담지 않는 쪽으로 두는 안. 이 회차가 허가를 정의층 구조의 칸으로 담았으므로
결손이 구조의 결손이 아니라 소스의 결손이다. 참거짓을 내는 안도 기각했다. 소스가 없다는 것과 그
명제가 거짓이라는 것이 다르다.

**수 체계를 받지 않는다.** 판정이 열거를 내며 수를 들지 않는다.
-/
-- DD:CF-4256
def designationReliefObserved {Node : Type}
    (chs : List (DesignationChannel Node)) : ObservedTruth :=
  if chs.any (fun C => C.answersRelief) then ObservedTruth.holds
  else ObservedTruth.undetermined UndeterminedReason.noMeasurementSource

/--
개별 허가에 측정 소스가 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 회차가 든 경로 가운데 하나가 어느 지정된 주체의 거래가 허가로 풀렸는지를 내야 한다. 그 관측은
그 허가가 공표되는 자리가 있다는 뜻이며, 그러면 관측층이 그 소스를 명세로 들 수 있고 절단의 판정이
공표 수치에서 닫힌다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 관측층에 등재되는 소스 없음이 이 프레임워크의 주요 산출 가운데 하나이고,
정의층이 세운 허가의 칸이 어느 경로에서도 채워지지 않는다는 것을 드는 유일한 자리다.
-/
-- DD:CF-4256
theorem designation_relief_observed_undetermined :
    designationReliefObserved designationChannels
      = ObservedTruth.undetermined UndeterminedReason.noMeasurementSource := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
지정의 시점은 한 경로 이상에서 관측된다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 회차가 든 경로 가운데 어느 것도 시점을 내지 않아야 한다. 그 관측은 네 물음이 같은 결손을 내어
물음을 넷으로 가른 것이 이름만 다른 넷이 된다는 뜻이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 소스의 결손이 축 전량에 걸리지 않고 물음마다 갈린다는 것을 드는 자리다.
-/
-- DD:CF-4257
theorem designation_time_observed_holds :
    designationTimeObserved designationChannels = ObservedTruth.holds := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
지정의 사유는 한 경로 이상에서 관측된다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 회차가 든 경로 가운데 어느 것도 사유를 내지 않아야 한다. 그 관측은 사유별로 갈린 부가 공표
경로에 서지 않는다는 뜻이며, 그러면 정의층이 사유를 열거로 둔 것이 관측되지 않는 가름이 된다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 정의층의 사유 열거가 공표 경로에서 실제로 채워진다는 것을 드는 자리다.
-/
-- DD:CF-4257
theorem designation_ground_observed_holds :
    designationGroundObserved designationChannels = ObservedTruth.holds := by
  -- 목록이 상수이고 판정이 그 위의 계산이므로 `rfl` 로 닫힌다.
  rfl

/--
네 답함이 각 칸에서 홀로 값을 가른다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
어느 답함이 자기 칸이 아닌 칸을 읽어야 한다. 그 관측은 네 답함이 같은 칸을 읽는다는 뜻이며, 그러면
물음을 넷으로 가른 것이 이름만 다른 넷이 된다.

**존재 형태로 진술하는 까닭(T-6):**
칸마다 그 하나만 참인 경로를 들어야 보인다. 임의의 경로에서 각 칸이 홀로 가르는 것이 아니라
나머지가 거짓인 자리에서만 그 가름이 보이기 때문이다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 네 답함이 각각 자기 칸만 읽는다는 것을 구조 안의 명제로 드는 유일한
자리이고, 그 증거가 없으면 물음을 넷으로 가른 것이 이름만 다른 넷인지 재어지지 않는다.
-/
-- DD:CF-4255
theorem designation_channel_answers_pin_each_field :
    ∃ (C₁ C₂ C₃ C₄ : DesignationChannel Unit),
      C₁.answersSubject = true ∧ C₁.answersTime = false ∧
        C₁.answersGround = false ∧ C₁.answersRelief = false ∧
      C₂.answersSubject = false ∧ C₂.answersTime = true ∧
        C₂.answersGround = false ∧ C₂.answersRelief = false ∧
      C₃.answersSubject = false ∧ C₃.answersTime = false ∧
        C₃.answersGround = true ∧ C₃.answersRelief = false ∧
      C₄.answersSubject = false ∧ C₄.answersTime = false ∧
        C₄.answersGround = false ∧ C₄.answersRelief = true := by
  -- 칸마다 그 칸 하나만 참인 경로를 든다. 답함이 그 칸을 그대로 읽으므로 경로마다
  -- 계산하면 값이 나와 `rfl` 로 닫힌다.
  exact ⟨⟨(), true, false, false, false⟩, ⟨(), false, true, false, false⟩,
    ⟨(), false, false, true, false⟩, ⟨(), false, false, false, true⟩,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

end CrisisFramework.Observation
