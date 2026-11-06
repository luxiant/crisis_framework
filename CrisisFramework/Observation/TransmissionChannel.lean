/-
관측층 — 통화 불일치 전달의 측정 사상

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(관측층은 무차원),
      L-9(import 방향은 단방향), A-3(witness 의무), C-3(판정 술어는 `Decidable`),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), D-8(witness 의 서술),
      T-2(반증 조건), T-3(기여 분류), T-4(가정의 명시).

이 파일은 수를 한 번도 쓰지 않는다. 각 경로가 어느 축을 내는가만 `Bool` 로 들고 입도는 열거다.

**이 파일이 세우는 것은 통화 불일치의 전달이 공표 수치에서 어떻게 관측되는가 또는 관측되지
않는가다.** 축을 여섯으로 가르고 입도와 수신자를 함께 받으며, 그 여섯 가운데 다섯이 엣지의 자리를
가르고 여섯째가 그 전달의 세기를 내는 경로가 있는가다.

**세기의 칸을 두는 사유는 정의층이 그 갈림을 접었다는 데 있다.** 전달의 판정이 작다는 것과 서지
않는다는 것을 한 값으로 접으므로 그 갈림의 결손을 드는 자리가 관측층뿐이다.

**입도와 수신자 열거를 새로 세우지 않고 같은 층에서 재사용한다.** 같은 가름을 두 열거로 두면
어느 것이 정본인지가 서지 않는다.

**정리의 증명은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채운다. 그 진술이
증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을 부정한 사본이 컴파일에 실패하는 것도 함께
확인했으나, 쓴 전술은 싣지 않는다. 전술을 싣으면 집행이 그것을 옮겨 쓰게 되어 절단면을 넘으며,
사전 검사가 통과한 사실은 증거가 아니라 필터다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Definition.CurrencyMismatchTransmission
import CrisisFramework.Observation.CurrencyMismatchChannel

namespace CrisisFramework.Observation

open CrisisFramework.Definition


/--
통화 불일치의 전달을 읽는 공시 경로.

**대응 비형식 개념:** 관측층은 각 아크에서 병행하므로 정의층 대상을 세울 때 그 측정 사상 명세를
함께 쓰는 자리가 이 구조체다. 축 여섯 가운데 다섯이 엣지의 자리를 가르고 여섯째가 그 값을 가른다.

**이 정의가 배제하는 사례:**
한 경로가 전달의 축 전량을 낸다고 보는 자리. 지목 참조로 연 편의 자료가 은행이 보유한 대출만 담고
차입자의 대차대조표를 담지 않으므로, 같은 보고가 그 쌍과 그 청구권의 통화를 내면서 좌변 주체의 불일치를
내지 못한다. 이 구조체는 축마다 칸을 두어 그 갈림을 받으며, 한 칸으로 접으면 참인 축이 거짓인 축을
덮는다.
조달처: E-65 §3-2 「은행이 보유한 대출만 담고 기업의 대차대조표를 담지 않는다」

**기각한 대체 정의:**
축을 다섯으로 두어 전달의 세기를 내는 칸을 두지 않는 안. 다섯은 엣지의 자리를 가르는 축이고 세기는 그
엣지의 값이어서 성질이 다르므로 칸을 더하지 않는 것이 깔끔해 보이나, 정의층이 작다는 것과 서지 않는다는
것을 한 판정으로 접었으므로 그 갈림의 결손을 드는 자리가 관측층뿐이고 칸이 없으면 그 결손이 어디에도
등재되지 않는다.

**값을 담지 않는다.**
-/
-- DD:CF-2831
structure TransmissionChannel (Node : Type) where
  /-- 그 경로가 전달의 좌변 주체를 덮는가. -/
  coversSource : Node → Bool
  /-- 그 경로가 전달의 우변 주체를 덮는가. -/
  coversHolder : Node → Bool
  /-- 그 경로가 그 둘을 잇는 청구권을 내는가. -/
  readsClaim : Bool
  /-- 그 경로가 전달의 매개인 상환 실패를 내는가. -/
  readsRepaymentFailure : Bool
  /-- 그 경로가 우변의 제약 인자를 내는가. -/
  readsConstraintInput : Bool
  /-- 그 경로가 그 전달의 세기를 내는가. -/
  readsStrength : Bool
  /-- 그 경로가 값을 내는 입도. 어느 축도 내지 않는 경로는 이 자리가 비어 있다. -/
  granularity : Option MismatchGranularity
  /-- 그 경로의 공시를 받는 쪽. -/
  recipient : DisclosureRecipient

/--
어느 축도 내지 않는 경로.

**대응 비형식 개념:** 소스 없음을 등재하는 자리이며 구조가 비어 있지 않음을 함께 보인다.

**이 정의가 배제하는 사례:**
어느 축도 내지 않는 경로가 실재하지 않는다고 보는 자리. 지목 참조로 연 편이 쓰는 자료의 수신자가 감독
당국이고 같은 축을 공개 공시에서 읽는 길이 그 편에 서지 않으므로, 밖에서 보는 관측자에게는 아무것도
내지 않는 경로가 실재한다. 이 인스턴스는 그 자리를 명시적으로 두며, 두지 않으면 소스 없음이 칸으로
보이지 않는다.
조달처: E-65 §3-4 「공개 공시로 같은 축을 읽는 길이 그 편에 서지 않는다」

**기각한 대체 정의:**
소스 없음 인스턴스를 두지 않고 실재 경로만 두는 안. 실재 경로 둘이 이미 구조가 비어 있지 않음을
보이므로 그 인스턴스가 없어도 witness 의무가 충족되는 것처럼 보이나, 어느 축도 내지 않는 경로를
명시적으로 두는 것이 소스 없음을 등재하는 자리이고 앞 페이즈의 불일치 경로 파일과 제약 인자 경로
파일이 모두 그 인스턴스를 둔다.

**값을 담지 않는다.**
-/
-- DD:CF-2831
def TransmissionChannel.noSource {Node : Type} : TransmissionChannel Node where
  coversSource := fun _ => false
  coversHolder := fun _ => false
  readsClaim := false
  readsRepaymentFailure := false
  readsConstraintInput := false
  readsStrength := false
  granularity := none
  recipient := DisclosureRecipient.publicReader

/--
그 경로가 전달의 축 여섯을 모두 내는가.

**대응 비형식 개념:** 축 여섯 전량을 내는 경로가 하나도 없다는 것을 한 명제로 세우려면 그 합성
술어가 필요하다.

**이 정의가 배제하는 사례:**
축 하나가 서면 전달이 관측된다고 보는 자리. 지목 참조로 연 편이 한 은행에서 외화로 빌렸는가를 그 기업의
전체 부채 통화 구성의 대리변수로만 쓴다고 적으므로, 청구권의 통화를 읽는 것이 좌변 주체의 불일치를 읽는
것을 갈음하지 못한다. 이 판정은 축 전량의 논리곱을 받아 그 갈음을 막는다.
조달처: E-65 §3-2 「한 은행에서 외화로 빌렸는가가 그 기업의 전체 부채 통화 구성의 대리변수일 뿐이며」

**기각한 대체 정의:**
축마다 따로 판정을 내고 합성하지 않는 안. 어느 축이 서는지를 각각 읽으므로 세밀하나 축 여섯 전량을
내는 경로가 하나도 없다는 것을 한 명제로 세울 수 없고, 앞 페이즈가 같은 자리에서 합성 술어를 두고
그것이 전량 거짓임을 정리로 보인 선례가 섰다.

**값을 담지 않는다.**
-/
-- DD:CF-2831
def TransmissionChannel.answersAllAxes {Node : Type}
    (C : TransmissionChannel Node) (src holder : Node) : Bool :=
  C.coversSource src && C.coversHolder holder && C.readsClaim
    && C.readsRepaymentFailure && C.readsConstraintInput && C.readsStrength

/--
감독 당국에 제출되는 스트레스 시험 보고를 전달의 경로로 읽은 것.

**대응 비형식 개념:** 지목 참조로 연 편이 그 보고로 전달의 네 축을 갈랐으므로 실재하는 경로가 어디까지
내는지를 드는 자리가 이 선언이다.

**이 정의가 배제하는 사례:**
그 보고를 공개 공시로 읽는 자리. 지목 참조로 연 편이 그 자료가 스트레스 시험을 위해 감독 당국에
제출되는 것이어서 밖에서 보는 관측자가 닿지 못한다고 적으므로 그 수신자가 감독 당국이다. 이 경로는
수신자를 그 당국으로 들며, 공개로 두면 밖에서 보는 관측자가 닿지 못하는 자료를 닿는 것으로 적게 된다.
조달처: E-65 §3-4 「스트레스 시험을 위해 감독 당국에 제출되는 것이므로 밖에서 보는 관측자가 닿지 못한다」

**기각한 대체 정의:**
그 자료의 수신자를 일반 관측자로 두는 안. 그 자료를 연구자가 쓰는 것과 그 자료가 공개 공시로 서는 것이
다른 사실이며, 앞 페이즈가 감독 당국의 신용등록부를 받는 경로를 세우면서 같은 가름을 이미 두었다. 그
경로가 전달의 세기를 낸다고 두는 안도 기각했다. 그 편이 결론에서 그 성분의 크기를 말할 때 쓰는 근거가
외화 대출의 비중과 연체의 절대 비중이고 그 둘이 전달의 세기 자체가 아니므로, 그 칸을 참으로 두면 세기를
내는 경로가 실재한다는 거짓이 선다.

**값을 담지 않는다.**
-/
-- DD:CF-2831
def supervisoryStressTestChannel {Node : Type} : TransmissionChannel Node where
  coversSource := fun _ => true
  coversHolder := fun _ => true
  readsClaim := true
  readsRepaymentFailure := true
  readsConstraintInput := false
  readsStrength := false
  granularity := some MismatchGranularity.nodeLevel
  recipient := DisclosureRecipient.supervisor

/--
공개 공시를 전달의 경로로 읽은 것.

**대응 비형식 개념:** 같은 축이 공개 공시에서 서지 않는다는 것이 이 파일의 산출이므로 그 경로를 따로
세운다.

**이 정의가 배제하는 사례:**
공개 공시가 차입자의 외화 수익 몫을 낸다고 보는 자리. 지목 참조로 연 편이 외화 수익의 몫을 기업 수준에서
관측하지 못해 그 기업이 속한 나라와 산업의 국외 매출 비중으로 대신한다고 적으므로, 공개 공시에서 그 축이
주체 단위로 서지 않는다. 이 경로는 좌변 주체를 덮지 않는 것으로 들며, 덮는 것으로 두면 대리변수를 직접
관측과 같게 적게 된다.
조달처: E-65 §3-2 「외화 수익의 몫도 기업 수준에서 관측되지 않아」

**기각한 대체 정의:**
공개 공시 경로를 두지 않고 감독 당국 경로만 두는 안. 실재하는 경로만 두면 인스턴스가 하나로 줄지만 같은
축이 공개 공시에서 서지 않는다는 것이 이 파일의 산출이므로 그 경로를 따로 세워야 그 거짓이 칸으로
보이며, 앞 페이즈가 다국 상장기업의 공개 공시를 그 사유로 따로 세운 선례가 있다.

**값을 담지 않는다.**
-/
-- DD:CF-2831
def publicDisclosureTransmissionChannel {Node : Type} : TransmissionChannel Node where
  coversSource := fun _ => false
  coversHolder := fun _ => true
  readsClaim := false
  readsRepaymentFailure := false
  readsConstraintInput := true
  readsStrength := false
  granularity := some MismatchGranularity.nodeLevel
  recipient := DisclosureRecipient.publicReader

/--
전달을 읽는 경로를 모은 목록.

**대응 비형식 개념:** 경로 전량을 재는 정리가 그 목록을 받으므로 경로가 늘 때 정리마다 고치지 않아도
되게 한다.

**이 정의가 배제하는 사례:**
경로가 하나뿐이라고 보는 자리. 지목 참조로 연 편이 쓰는 자료가 차입자의 식별자와 대출의 금액과 은행의
내부 등급을 분기마다 내는 감독 보고이고 그것과 공개 공시가 서로 다른 축을 내므로, 전달을 읽는 경로가
둘 이상이다. 이 목록은 그 둘을 함께 받으며, 하나로 두면 어느 축이 어디서 비는지가 서지 않는다.
조달처: E-65 §3-1 「차입자의 식별자와 대출의 금액과 은행의 내부 등급이 분기마다 들어오며」

**기각한 대체 정의:**
경로를 목록으로 모으지 않고 정리마다 인스턴스를 열거하는 안. 목록을 두지 않으면 선언이 하나 줄지만
경로가 늘 때 정리마다 그 열거를 고쳐야 하고 두 정리가 서로 다른 경로 집합을 딛게 될 수 있으며, 앞
페이즈가 같은 자리에서 경로를 목록으로 모아 전량을 재는 꼴을 세웠다.

**값을 담지 않는다.**
-/
-- DD:CF-2831
def transmissionChannels {Node : Type} : List (TransmissionChannel Node) :=
  [supervisoryStressTestChannel, publicDisclosureTransmissionChannel,
   TransmissionChannel.noSource]

/--
그 경로들 가운데 전달의 축 여섯을 모두 내는 것이 하나도 없다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 명제가 거짓이려면 목록의 어느 경로가 좌변 주체와 우변 주체를 모두 덮으면서 청구권과
상환 실패와 제약 인자와 세기를 모두 내야 한다. 그러려면 한 공시가 차입자의 대차대조표와 은행의 규제
보고와 그 전달의 크기를 함께 담아야 하고, 그 공시가 실재한다는 것이 이 명제의 반증이다.

**T-3 분류:** 보조 보정이다. 세 경로의 칸을 전개하고 논리곱을 분기하면 증명이 닫히므로 이 명제는 기여
목록에 들지 않는다. 축을 여섯으로 가른 사유를 받치는 자리이며, 한 칸으로 접으면 어느 축이 어디서 비는지가
서지 않는다.

**가정을 두지 않는다.** 목록에 든 경로 전량을 전칭으로 받으므로 경로가 늘면 그 정리가
새 경로까지 함께 받는다.
-/
-- DD:CF-2831
theorem no_channel_answers_all_transmission_axes {Node : Type} (src holder : Node) :
    ∀ C ∈ (transmissionChannels : List (TransmissionChannel Node)),
      C.answersAllAxes src holder = false := by
  intro C hC
  cases hC
  · rfl
  · rename_i hC
    cases hC
    · rfl
    · rename_i hC
      cases hC
      · rfl
      · rename_i hC
        cases hC

/--
전달의 세기를 내는 칸이 어느 경로에서도 서지 않는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
이 명제가 거짓이려면 목록의 어느 경로가 세기를 내는 칸을 참으로 들어야 한다. 그러려면
그 전달의 크기를 재는 공시가 실재해야 하고, 지목 참조로 연 편이 그 성분의 크기를 말할 때 쓰는 근거가
외화 대출의 비중과 연체의 절대 비중이어서 그 둘은 전달의 세기가 아니다.

**T-3 분류:** 보조 보정이 아니다. **축 여섯 가운데 이 축만 전량이 비는 것이 이 명제의 요지다.**
다른 다섯은 경로마다 참인 자리가 있어 어느 공시가 그것을 내는지를 적을 수 있는데, 세기는 어느 경로에서도
서지 않으므로 정의층이 작다는 것과 서지 않는다는 것을 한 판정으로 접은 자리가 관측에서도 메워지지
않는다. 그 비어 있음이 이 파일의 산출이다.

**가정을 두지 않는다.** 목록에 든 경로 전량을 전칭으로 받는다.
-/
-- DD:CF-2831
theorem strength_unread_by_every_channel {Node : Type} :
    ∀ C ∈ (transmissionChannels : List (TransmissionChannel Node)),
      C.readsStrength = false := by
  intro C hC
  cases hC
  · rfl
  · rename_i hC
    cases hC
    · rfl
    · rename_i hC
      cases hC
      · rfl
      · rename_i hC
        cases hC

end CrisisFramework.Observation
