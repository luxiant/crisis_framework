/-
관측층 — 부채 통화와 자산 통화의 공존을 묻는 항의 답

규율: L-14(관측층은 값을 담지 않고 사상의 명세만 담는다), L-10(무차원), L-9(import 방향은
      단방향), A-8(논리 결합마다 홀로 값을 가르는 자리의 증거), C-9(전면 `simp` 금지),
      D-1·D-2(docstring 3항목), D-3(배제 사례는 실제 문면), T-2(반증 조건), T-3(기여 분류),
      T-4(가정의 명시), T-6(존재 형태).

**이 파일이 세우는 것은 이 아크가 내릴 항의 답이다.** 고정 절이 그 항의 서명을 들고 그 서명이
매개변수를 추상 타입으로 받으므로, 그 서명을 크기의 공시 경로 목록과 두 잔액을 읽는 함수로 채운
답이 이 파일에 선다. 고정 뒤의 개변이 들어가는 길이 새 항을 더하는 것과 답이 받는 열거에 원소를
더하는 것과 판정 불가의 까닭을 세분하는 것인데, 이 파일이 그 가운데 어느 길도 쓰지 않으므로 고정
절을 움직이지 않는다.

**답이 값을 내는 자리를 경로의 칸에서 유도한다.** 그 주체를 덮고 그 쌍을 총액으로 답하며 값이
당국의 공식 자료인 경로가 목록에 있으면 두 잔액을 내고, 없으면 두 값을 측정 소스 없음으로 접는다.
값의 성질을 묻는 것은 추정과 합성으로 선 값이 답의 금액으로 서면 실측된 금액과 갈리지 않기
때문이다.

**값을 담지 않는다.** 금액도 잔액도 이 파일에 서지 않고 두 잔액을 읽는 함수를 매개변수로 받는다.

**정리의 증명과 적재 선언은 집행 증분이다.** 정리마다 미완 표지를 두고 그 자리를 집행이 채우며, 이
파일이 딛는 적재 선언도 집행이 쓴다. 그 진술이 증명 가능함을 결정 세션의 사전 검사가 확인했고 결론을
부정한 사본이 컴파일에 실패하는 것도 함께 확인했으나, 쓴 전술은 싣지 않는다.

원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.
-/

import CrisisFramework.Observation.CompetencyQuestion
import CrisisFramework.Observation.FundingSizeChannel

namespace CrisisFramework.Observation

/--
그 경로가 그 주체에 대해 공식 자료로 선 쌍을 내는가.

**대응 비형식 개념:** 한 경로가 한 주체의 두 잔액을 답의 값으로 낼 수 있는가. 그 주체를 덮고 두
성분을 총액 기재로 함께 내며 그 값이 당국의 공식 자료여야 그 값이 실측으로 선다.

**이 정의가 배제하는 사례:**
합성 가중치로 메운 계열의 값을 답의 값으로 읽는 자리. 지목 참조로 연 편의 기록이 그 계열이 당국
설문의 실측과 합성 가중치로 메운 값을 이어 붙인 것이고 국제결제은행 자료가 국내에서 발행된 증권의
통화 구성을 내지 않아 신흥국의 자국통화 발행 비중이 과소추정된다고 적으므로, 그 값을 답으로 받으면
알려진 방향의 편향이 답의 값에 실린다. 이 판정은 값의 성질이 공식 자료일 때에만 참을 내어 그 계열을
답의 원천에서 뺀다(Bénétrix·Gautam·Juvenal·Schmitz 2019).
조달처: E-41 §2-2 「신흥국의 자국통화 발행 비중이 과소추정된다」

**기각한 대체 정의:**
값의 성질을 묻지 않고 주체의 덮임과 두 성분의 총액만 묻는 안. 크기가 관측되는가를 내는 판정과 같은
축이어서 선언이 줄어드나, 공표 자료에서 읽는 쪽이 유도한 추정이 답의 값으로 서고 그 값이 실측된
금액과 갈리지 않는다. 실측과 합성이 섞인 계열을 그 실측 몫 때문에 받는 안도 기각했다. 그 계열의 한
칸이 실측인지 합성인지가 공시에서 가려지지 않으므로 받으면 합성으로 메운 칸이 실측으로 선다.

**값을 담지 않는다.**
-/
-- DD:CF-4533
def FundingSizeChannel.answersReportedSizeFor {Party : Type}
    (c : FundingSizeChannel Party) (p : Party) : Bool :=
  c.coversParty p && c.answersGrossSize
    && (c.provenance == MeasurementProvenance.officialReport)

/--
`CQ-fin-13` 의 답 자리를 크기의 공시 경로 목록과 두 잔액을 읽는 함수로 채운다.

**대응 비형식 개념:** 한 주체가 부채 통화로 진 부채의 잔액과 자산 통화로 보유한 자산의 잔액을
함께 내는 답. 목록의 어느 경로가 그 주체에 대해 공식 자료로 선 쌍을 내면 두 잔액을 내고, 그런
경로가 없으면 두 값을 측정 소스 없음으로 접는다. 잔액을 읽는 함수는 매개변수로 받으며 관측층이 그
값을 담지 않는다.

**이 정의가 배제하는 사례:**
자산의 표시 통화를 공시가 내지 않는 주체. 지목 참조로 연 편이 현금과 단기투자의 표시 통화를 알 수
없고 그 자료가 공개되지 않는다고 적고 그 자료를 한 체제의 상장기업에 대해서만 따로 얻었다고
적으므로, 그 체제 밖의 주체에서는 자산 성분을 내는 경로가 없어 이 조립이 두 값을 함께 접는다. 그
접힘은 무엇을 재야 하는지가 서지 않은 것이 아니라 재야 할 것을 내는 공시가 없는 것이다
(Bruno·Shin 2018).
조달처: E-64 §2-3 「현금과 단기투자의 표시 통화를 알 수 없고 그 자료가 공개되지 않는다」

**기각한 대체 정의:**
성분마다 따로 판정하여 한 경로가 한 성분만 내도 그 성분의 값을 내는 안. 답 타입이 두 값을 따로
받으므로 그 꼴이 설 수 있으나, 그 쌍을 답한다는 판정이 두 성분을 함께 내는 경로를 요구한다고 크기의
공시 경로 명세가 이미 정했고, 성분마다 가르면 딜러가 보고하는 파생상품 잔액처럼 한 변의 명목 잔액만
내는 경로가 그 주체의 부채 잔액을 낸 것으로 선다. 두 잔액을 한 수로 접어 주체 사이의 순서를 세우는
안도 기각했다. 두 성분이 서로 다른 통화의 잔액이어서 접으려면 환율이 필요하고, 그 환율을 외생으로
두면 자료여서 이 산출이 낼 것이 없고 내생화하면 동학층이어서 재유입의 범위에서 빠진다.

**값을 담지 않는다.**
-/
-- DD:CF-4533
def debtAssetCurrencyPairingVia {Time Entity Currency Amount : Type}
    (chs : List (FundingSizeChannel Entity))
    (debtBalance assetBalance : Entity → Currency → Time → Amount) :
    CQ.DebtAssetCurrencyPairing Time Entity Currency Amount where
  answer := fun e d a t =>
    if chs.any (fun c => c.answersReportedSizeFor e) then
      (.value (debtBalance e d t), .value (assetBalance e a t))
    else
      (.undetermined .noMeasurementSource, .undetermined .noMeasurementSource)

/--
공식 자료로 선 쌍의 판정이 세 인자를 각각 고정한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 판정이 어느 인자 하나만 거짓인 자리에서 참을 내야 한다. 그 관측은 그 판정이 논리곱이 아니라는
뜻이며, 그러면 그 주체를 덮지 않는 경로나 총액의 쌍을 내지 않는 경로나 공식 자료가 아닌 경로가 답의
원천으로 선다.

**가정을 두지 않는다.**

**T-3 분류:** 보조 보정이다. 경로의 값을 전개하면 증명이 닫히므로 기여 목록에 들지 않는다. 판정
반환 함수의 논리 결합마다 홀로 값을 가르는 경로를 증거로 드는 정리를 같은 파일에 두라는 A-8 의
요구를 이 명제가 받으며, 각 인자가 홀로 값을 가르는 자리를 대외 포지션의 통화 구성을 내는 계열의
칸만 바꾼 리터럴로 든다.
-/
-- DD:CF-4533
theorem answers_reported_size_for_pins_each_conjunct :
    (FundingSizeChannel.answersReportedSizeFor
      ({ externalPositionCurrencyCompositionChannel with
           coversParty := fun _ => false
           basis := MeasurementBasis.grossBasis
           provenance := MeasurementProvenance.officialReport } : FundingSizeChannel Unit)
      () = false)
    ∧ (FundingSizeChannel.answersReportedSizeFor
      ({ externalPositionCurrencyCompositionChannel with
           provenance := MeasurementProvenance.officialReport } : FundingSizeChannel Unit)
      () = false)
    ∧ (FundingSizeChannel.answersReportedSizeFor
      ({ externalPositionCurrencyCompositionChannel with
           basis := MeasurementBasis.grossBasis } : FundingSizeChannel Unit)
      () = false)
    ∧ (FundingSizeChannel.answersReportedSizeFor
      ({ externalPositionCurrencyCompositionChannel with
           basis := MeasurementBasis.grossBasis
           provenance := MeasurementProvenance.officialReport } : FundingSizeChannel Unit)
      () = true) := by
  exact ⟨rfl, rfl, rfl, rfl⟩

/--
목록의 어느 경로가 그 주체에 대해 공식 자료로 선 쌍을 내면 답이 두 잔액을 낸다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
공식 자료로 선 쌍을 내는 경로가 목록에 있는데 답이 판정 불가를 내거나 다른 값을 내야 한다. 그 관측은
그 쌍을 내는 공시가 실재해도 답이 서지 않는다는 뜻이며, 그러면 남는 결손이 공시의 부재가 아니라 답이
딛는 정의의 결손이다.

**가정과 그 배제 사례(T-4·T-5):** 목록의 어느 경로가 그 주체에 대해 공식 자료로 선 쌍을 낸다는
가정을 둔다. 그 가정을 빼면 이 아크가 조달한 경로 목록처럼 그런 경로가 없는 자리에서도 두 잔액이
서야 하는데, 그 자리에서 답이 두 값을 측정 소스 없음으로 접으므로 진술이 거짓이 된다.

**T-3 분류:** 기여다. 답이 값을 내는 자리가 공시 경로의 칸에서만 정해진다는 것을 구조 안의 명제로
드는 유일한 자리이며, 내리는 항이 정의 공백을 벗어났다는 주장이 이 자리와 다음 자리의 짝으로 선다.
-/
-- DD:CF-4533
theorem debtAssetCurrencyPairingVia_eq_values_of_reported
    {Time Entity Currency Amount : Type}
    (chs : List (FundingSizeChannel Entity))
    (debtBalance assetBalance : Entity → Currency → Time → Amount)
    (e : Entity) (d a : Currency) (t : Time)
    (h : chs.any (fun c => c.answersReportedSizeFor e) = true) :
    (debtAssetCurrencyPairingVia chs debtBalance assetBalance).answer e d a t
      = (ObservedValue.value (debtBalance e d t), ObservedValue.value (assetBalance e a t)) := by
  exact if_pos h

/--
이 아크가 조달한 경로 목록에서 답이 두 값을 측정 소스 없음으로 접는다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 목록의 어느 경로가 어느 주체에 대해 공식 자료로 선 쌍을 내야 한다. 그 관측은 두 잔액을 총액으로
함께 내는 공식 공시가 실재한다는 뜻이며, 그러면 내리는 항의 답이 지금 그 자리에서 선다.

**가정을 두지 않는다.**

**T-3 분류:** 기여다. 그 답이 어디서도 서지 않는 까닭이 측정 소스의 부재임을 구조 안의 명제로 드는
유일한 자리이며, 소스 없음이 관측층의 주된 산출물이므로 전개로 닫히는 증명이어도 그 몫이 있다.
-/
-- DD:CF-4533
theorem debt_asset_pairing_lacks_measurement_source
    {Time Currency Amount : Type}
    (debtBalance assetBalance : Unit → Currency → Time → Amount) :
    ∀ (e : Unit) (d a : Currency) (t : Time),
      (debtAssetCurrencyPairingVia fundingSizeChannels debtBalance assetBalance).answer e d a t
        = (ObservedValue.undetermined UndeterminedReason.noMeasurementSource,
           ObservedValue.undetermined UndeterminedReason.noMeasurementSource) := by
  intro e d a t
  rfl

/--
크기가 관측되는데 답이 값을 내지 않는 경로 목록이 실재한다.

**이 명제가 거짓이려면 무엇이 관측되어야 하는가:**
그 쌍을 총액으로 답하는 경로가 있는 목록에서는 답이 언제나 값을 내야 한다. 그 관측은 값의 성질이
답에 걸리지 않는다는 뜻이며, 그러면 합성으로 메운 값이나 추정이 실측된 금액과 같은 칸으로 답에 선다.

**가정을 두지 않는다.**

**존재 형태로 진술하는 까닭(T-6):** 관측과 답이 갈린다는 것을 전칭으로 세우면 크기가 관측되는 모든
목록에서 답이 접혀야 하는데, 공식 자료로 선 쌍을 내는 경로가 있는 목록에서는 답이 서므로 그 전칭은
거짓이다. 그 갈림의 주장은 갈리는 목록이 하나라도 있다는 것이므로 존재 형태가 그 주장의 꼴이다.

**T-3 분류:** 기여다. 답이 값의 성질을 묻는다는 설계가 크기의 관측과 답의 값을 가른다는 것을 증인의
존재로 세우는 자리이며, 그 갈림이 알려진 방향의 편향이 답에 실리지 않는 근거다. 증인은 대외 포지션의
통화 구성을 내는 계열이 총액 기재를 읽는다고 둔 경로로 선 목록이다.
-/
-- DD:CF-4533
theorem exists_observed_size_without_reported_answer
    {Time Currency Amount : Type} :
    ∃ chs : List (FundingSizeChannel Unit),
      fundingSizeObserved chs = ObservedTruth.holds
      ∧ ∀ (debtBalance assetBalance : Unit → Currency → Time → Amount)
          (e : Unit) (d a : Currency) (t : Time),
          (debtAssetCurrencyPairingVia chs debtBalance assetBalance).answer e d a t
            = (ObservedValue.undetermined UndeterminedReason.noMeasurementSource,
               ObservedValue.undetermined UndeterminedReason.noMeasurementSource) := by
  -- 증인은 대외 포지션의 통화 구성을 내는 계열이 총액 기재를 읽는다고 둔 경로 하나로 선 목록이다.
  exact ⟨[{ externalPositionCurrencyCompositionChannel with basis := MeasurementBasis.grossBasis }],
    rfl, fun _ _ _ _ _ _ => rfl⟩

end CrisisFramework.Observation
