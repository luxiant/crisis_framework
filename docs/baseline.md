# baseline.md

이 파일은 **값의 정본**이다. 층별 공리 기준선(A-6)과 툴체인 핀과 오염 어간 목록이 여기에 산다.

행동을 정하는 문면은 `CLAUDE.md`가 들고, 판단을 정하는 문면은 세션 지시가 든다. 이 파일은 그
둘이 지목하는 값만 담으며 규율을 새로 세우지 않는다.

**`scripts/verify.sh`와 CI는 이 파일의 §5 기계 판독 블록을 읽는다.** 값을 스크립트에 전사하지
않는 이유는 전사가 이루어지면 문서를 고쳐도 검사가 낡은 값으로 돌기 때문이다. 값을 고칠 때는
이 파일만 고친다.

---

## 1. 툴체인 핀

| 항목 | 값 |
|---|---|
| Mathlib 태그 | `v4.32.2` |
| Mathlib 커밋 | `905b95818eb32af7874a58b427f50c1711a5e96c` |
| `lean-toolchain` | `leanprover/lean4:v4.32.2` |

**이 표는 전사이며 원 정본은 `lean-toolchain`과 `lake-manifest.json`이다.** 표를 두는 이유는
§2의 기준선이 이 핀에서만 유효하기 때문이며, 기준선과 핀을 갈라 두면 둘 중 하나가 낡았을 때
그 사실이 문면에 드러나지 않는다.

핀을 바꾸는 것은 사람의 결정이다. 근거와 갱신 절차는 세션 지시 §5.2가 든다.

---

## 2. 층별 공리 기준선 (A-6)

기준선은 핀된 커밋에서 **그 층이 쓰는 최소 수 체계만 언급하는 자명한 정의의 출력**이며,
`Finset` 합을 포함한 것이 실효 기준선이다.

| 층 | 수 체계 | 기준선 | 측정 시점 |
|---|---|---|---|
| 회계층 | `ℤ` | `[propext, Quot.sound]` | `hierarchy-6` (2026-10-24, `676607e`) |
| 회계층 | `ℚ` | `[propext, Classical.choice, Quot.sound]` | 1차 세션 |
| 정의층 | 무차원 + `ℕ` | `[propext, Quot.sound]` | `propagation-5` (2026-10-31, `7933c15`) |
| 관측층 | 무차원 | `[]` | `propagation-5` (2026-10-31, `7933c15`) |
| 용어집 | 없음 | `[]` | `propagation-5` (2026-10-31, `7933c15`) |
| 동학층 | `ℝ` | **미측정** | |

**미측정 칸에 값을 채우지 않는다.** 재지 않았음을 적는 것과 재지 않은 값을 적는 것은 다른
사실인데, 뒤는 문면상 앞과 구별되지 않는다.

회계층 `ℚ`의 행을 남겨 두는 이유는 L-15가 `ℚ`를 강제되는 경우에만 허용하기 때문이다. `ℚ`
파일이 생기면 그 디렉터리의 기준선이 이 행이 된다.

**측정 시점 칸은 그 층의 선언이 마지막으로 감사된 회차를 든다.** 기준선 값이 바뀐 회차가
아니다. 공리 감사가 매 실행마다 선언 전량을 훑으므로(§2-1) 그 층의 감사 대상이 달라지면 값이
그대로라는 것도 그때 새로 잰 결과가 된다. 그러므로 어느 회차가 그 층의 감사 대상을 바꾸었으면
값이 움직이지 않아도 이 칸이 움직이며, 괄호 안은 그 변경을 담은 커밋을 든다. 핀을 갱신해 값이
달라진 경우도 같은 칸이 받으므로 둘을 가르는 열을 따로 두지 않는다.

**축은 선언의 수가 아니라 공리 의존을 바꿀 수 있는 변경이다.** 선언이 하나도 늘지 않아도 그
층의 공리 의존이 달라질 수 있으면 이 칸이 움직인다. 열거를 더하거나 목록에 항을 더하는 것이 그
형이며, 열거의 생성자가 늘면 그것을 받는 선언의 공리 의존이 달라질 수 있기 때문이다. **반면
docstring 만 바뀐 회차는 이 칸을 움직이지 않는다.** 그 문면이 공리 의존에 닿지 않으므로 감사
대상이 달라지지 않으며, 그 자리에서 이 칸을 움직이면 값이 어느 변경에서 나온 것인지가 흐려진다.
**앞 판의 문면이 「선언을 더했으면」으로 적혀 있어 그 경우를 받지 못했다.** 용어집 행이 선언을
더하지 않은 회차에 움직인 것이 실측이며, 그때 그 축을 드는 문면이 지시서의 지시문에만 있었다.

**한 회차가 그 층의 감사 대상을 여러 커밋에서 바꾸었으면 괄호는 마지막 것을 든다.** 이 칸이
드는 것이 마지막 감사이므로 괄호도 그 감사가 딛는 자리를 든다. 앞선 커밋에서 잰 값은 그때의 더
작은 집합을 상대로 선 것이고, 적힌 값이 참인 범위는 마지막 변경 뒤의 집합이다. **그 회차가 그
층을 몇 번 바꾸었는지는 `BUILD_LOG.md` 의 회차 절이 구간마다 든다.** 그러므로 괄호가 하나만
들어도 따라갈 것이 줄지 않으며, 여러 커밋으로 늘리면 이 열의 길이가 회차마다 달라진다.

**각 행은 회차와 커밋만 든다.** 어느 층이 선언의 수 없이 내용만으로 움직였다는 사실은 위 문단이
축으로 들므로 행마다 다시 적지 않는다. 한 행만 메모를 달면 다른 행의 칸이 다른 것을 뜻하는
것처럼 읽히고, 같은 사실이 문단과 칸의 두 자리에 살게 된다. **그 회차의 관측은 `BUILD_LOG.md`
의 기준선 감사 절이 받는다.**

### 2-1. 측정 프로브

기준선은 프로브 정의의 `#print axioms` 출력으로 잰다. 프로브는 `Scratch/VerifyBuilt.lean`에
있으며 층마다 둘씩이다. 뒤가 그 층이 실제로 쓰는 용기를 포함하는 실효 기준선을 낸다.

| 층 | 최소 | 실효 |
|---|---|---|
| 회계층 | `baselineProbe` | `baselineProbeSum` (`Finset` 합) |
| 용어집 | `glossaryProbe` | `glossaryProbeList` (`List`) |
| 정의층 | `definitionProbe` | `definitionProbeFamily` (`ℕ → Finset`) |
| 관측층 | `observationProbe` | `observationProbeProd` (`Prod`) |

**용어집에서는 두 프로브가 같은 값을 낸다.** `List` 가 공리를 하나도 더하지 않기 때문이며 실효
기준선이라는 지위는 그대로다. 최소와 실효의 구별이 값으로 드러나는 것은 그 층의 용기가 공리를
더할 때뿐이고 정의층의 `Finset` 이 그 경우다.

**공리 감사의 대상은 `CrisisFramework` 아래 최상위 선언 전량이다.** 목록을 이 파일에도
`verify.sh` 에도 박지 않고 매 실행마다 훑어 잡으며, 각 층의 선언을 그 층의 실효 기준선과
차분한다. 계수와 층별 내역은 `verify.sh` 의 보고 줄이 낸다. 박아 두면 새 선언이 그물 밖에 남고,
`lakefile.toml` 의 glob 이 빌드는 하므로 그 사실이 빌드로 드러나지 않는다. 그 전에는 회계층
다섯만 재고 나머지 열은 그물 밖에 있었으며, 그 사실이 이 표의 「미측정」 칸으로만 서 있었다.
동학층은 파일이 아직 없다.

### 2-2. 기준선을 초과했을 때

초과분은 **유입원을 추적해 기록한다.** 추적 없이 통과시키지 않는다. 유입원의 분류는
C-8이 정하며 세 가지다. 분류의 판정은 결정 세션이 하고 Claude Code는 관측값만 보고한다.

**두 번째 종류(전술·인스턴스 해결의 의존)는 보조정리를 하나씩 감사해서는 찾지 못할 수 있다.**
실측 사례에서 `mul_eq_zero` 자체는 무의존이었고 오염은 그것이 요구하는 `NoZeroDivisors ℤ`
인스턴스에 있었다. 기준선 차분으로만 드러난다.

**기준선을 넘기는 것이 확인된 Mathlib 보조정리.** 핀된 커밋에서 실측한 값이며, 핀을 갱신하면
§2-3 에 따라 다시 잰다.

| 보조정리 | 실측 | 잰 회차 |
|---|---|---|
| `Finset.sum_le_sum` | `[propext, Classical.choice, Quot.sound]` | `collateral-4` |
| `Finset.sum_nonneg` | `[propext, Classical.choice, Quot.sound]` | `collateral-4` |
| `Finset.sum_le_sum_of_subset_of_nonneg` | `[propext, Classical.choice, Quot.sound]` | `collateral-4` |

**분류는 둘째 종류다.** 수학적 내용이 요구하지 않는다는 것이 실측으로 섰다. 같은 부분합 부등식을
`Finset.cons_induction` 으로 세우니 쓰는 부품 다섯이 전부 기준선 이하였고, 그 길에서 쓴 것이
`Finset.sum_empty` 와 `Finset.sum_cons` 와 `Finset.cons_induction` 과 `Finset.mem_cons_self` 와
`Finset.mem_cons_of_mem` 과 무의존인 `add_le_add` 다.

**이 목록은 완전하지 않다.** 넘기는 것이 확인된 것만 들며, 들지 않은 보조정리가 깨끗하다는 뜻이
아니다. 완전한 탐지는 `step4-baseline` 의 차분이고 이 목록은 그 앞에 서는 사람의 참고다.

### 2-3. 핀을 갱신했을 때

기준선을 재측정하고, 변화가 있으면 **전 정리를 재감사한다.** 이것이 갱신의 실제 비용이며,
비용을 명시하는 이유는 불필요한 갱신을 억제하기 위해서다.

---

## 3. 오염 어간 목록 (D-5)

아래 어간을 포함하는 식별자는 반드시 한정어를 동반한다. **어간 단독 사용을 금지한다.**
`liquidity`는 금지이고 `liquidityBalanceSheetCapacity`는 허용이다.

| 어간 | 확인된 분기 수 | 출처 |
|---|---|---|
| `liquidity` | 3 | 대차대조표 여력 / 수단별 조달 접근성 / 위험선호 |
| `leverage` | 4 | 장부 / 기업가치 / 합성 / 위험가중 |
| `capital` | 5 | 장부자본 / 시가총액 / 시가평가 장부자본 / 규제자본 / 경제적 자본 |
| `risk` | 2+ | 자사 측정 / 시장 측정 / (실제 위험은 미해결) |
| `collateral` | 3 | 원천 / 재담보된 / 재담보 가능 |
| `margin` | 3 | 레포 헤어컷 / 개시증거금 / 변동증거금 |
| `money` | 4+2 | 공적 / 부보 / 공적 그림자 / 사적 그림자 + 거래용 / 유동성관리용 |
| `funding` | 3 | 핵심(최종 채권자) / 중간(최종성 미판정) / 비핵심(비최종 채권자) |
| `intermediation` | 2 | 공적 보증 강도 기준 / 만기 불일치 기준 |
| `discount` | 3 | 차선 소유자 할인 / 헤어컷 / 할인율 |
| `impairment` | 2 | 손상 기울기 / 회계상 손상차손 |
| `core` | 3 | 핵심(최종 채권자) / 중간(최종성 미판정) / 비핵심(비최종 채권자) |

끝의 두 어간은 v5에서 추가됐다. Plantin·Sapra·Shin과 Morris·Shin이 같은 기호 `δ`로 서로 다른
대상을 가리키는 것이 확인됐기 때문이다.

---

## 4. 이 파일을 고칠 때

- 값을 고치면 §5의 기계 판독 블록을 함께 고친다. 표와 블록이 갈리면 검사가 블록을 읽으므로
  표만 고친 것은 반영되지 않는다.
- 기준선을 고칠 때는 측정 시점을 함께 적는다. 값만 바꾸면 그 값이 어느 핀에서 나온 것인지
  갈리지 않는다.
- 어간을 추가할 때는 분기 수와 출처를 함께 적는다. 근거 없는 어간은 다음 회차가 지울지 남길지
  판정할 수 없다.

---

## 5. 기계 판독 블록

아래의 블록은 `scripts/verify.sh`와 CI가 읽는다. **형식을 바꾸지 않는다.** 주석 표지와
`KEY=VALUE` 형태를 유지하며, 한 줄에 하나씩 적는다.

<!-- BASELINE:BEGIN -->
MATHLIB_TAG=v4.32.2
MATHLIB_SHA=905b95818eb32af7874a58b427f50c1711a5e96c
TOOLCHAIN=leanprover/lean4:v4.32.2
ACCOUNTING_INT=[propext, Quot.sound]
ACCOUNTING_RAT=[propext, Classical.choice, Quot.sound]
GLOSSARY=[]
DEFINITION=[propext, Quot.sound]
OBSERVATION=[]
<!-- BASELINE:END -->

미측정 층은 위 블록에 키를 두지 않는다. 키가 없는 것과 값이 빈 것은 다른 사실이며, 빈 값을
두면 검사가 그것을 기준선으로 읽는다.

<!-- STEMS:BEGIN -->
liquidity
leverage
capital
risk
collateral
margin
money
funding
intermediation
discount
impairment
core
<!-- STEMS:END -->

<!-- CQFIN:BEGIN -->
CQFIN=1|TradePaymentComposition|Country → Country → Commodity → Time → Time → PaymentMethodShareChange TradePaymentMethod|60e31a0b1efc
CQFIN=2|TradeFinanceCurrency|Country → Country → Commodity → Currency → Time → ObservedValue Amount|d4f8833587eb
CQFIN=3|SanctionTextCut|Entity → (t : Time) → NetworkKind t → ObservedTruth|1a127b9fc7e7
CQFIN=4|DebtCapacityCollateralDependence|Entity → Commodity → Time → ObservedTruth|1e6be6292736
CQFIN=5|ClaimsByHolderConstraintKind|Country → HolderConstraintKind → Currency → Time → ObservedValue Amount|2ee0dc125a36
CQFIN=6|SwapLineReach|Entity → CentralBankSwapLine → Time → ObservedTruth|229bc5c1aa41
CQFIN=7|ClaimsByDecisionUnit|Country → Node → Currency → Time → ObservedValue Amount|b332bdcb6eb9
CQFIN=8|MonetaryHierarchyOrder|Entity → Entity → Time → ObservedTruth|e3e114f404c3
CQFIN=9|RepaymentAndAdjustment|Entity → Time → Time → RepaymentOutcome|fb94926a3bbc
CQFIN=10|PledgedClaimsAndStock|Commodity → Currency → Time → ObservedValue Amount × ObservedValue Amount|ccf0c693f75e
CQFIN=11|ClaimsOnMismatchedDebtors|Entity → Currency → Currency → Time → ObservedValue Amount|5a4185e7b233
CQFIN=12|ClaimPledgeMultiple|Claim → Currency → Time → ObservedValue Amount × ObservedValue Amount|39a1bec9d4e8
<!-- CQFIN:END -->

<!-- HEADING:BEGIN -->
HEADING_SINCE=957
HEADING=대응 비형식 개념|D-2|대응 비형식 개념:
HEADING=배제하는 사례|D-2|이 정의가 배제하는 사례:
HEADING=기각한 대체 정의|D-2|기각한 대체 정의:
HEADING=거짓이려면|T-2|이 명제가 거짓이려면 무엇이 관측되어야 하는가:
HEADING=가정|T-4|가정과 그 배제 사례(T-4·T-5):
HEADING=가정|T-4|가정을 두지 않는다.
HEADING=존재 형태|T-6|존재 형태로 진술하는 까닭(T-6):
HEADING=T-3 분류|T-3|T-3 분류:
HEADING=V-4 사례|V-4|* 분할의 V-4 사례.
HEADING=완전성|V-7|분할의 완전성은 *의 귀결이다(V-7).
HEADING=완전성|V-7|분할의 완전성을 주장하지 않는다(V-7).
HEADING=증거|D-8|무엇을 증거하는가.
HEADING=인덱스|L-13|인덱스가 `ℕ` 인 것은 L-13 의 명시적 예외다.
HEADING=수 체계|L-10|수 체계를 매개변수로 받는다.
HEADING=수 체계|L-10|수 체계를 받지 않는다.
HEADING=값을 담지 않는다|L-14|값을 담지 않는다.
HEADING=배타적|V-8|* 분할의 모든 쌍이 배타적이다.
HEADING=배타적|V-8|* 분할에 배타적이지 않은 쌍이 있다.
<!-- HEADING:END -->

<!-- DOCFORM:BEGIN -->
DOCFORM=.|name|arcs.json
DOCFORM=.|name|baseline.md
DOCFORM=.|name|bundle-inventory-v0.md
DOCFORM=.|name|reading-queue-v0.md
DOCFORM=decisions|name|SPEC.md
DOCFORM=decisions|name|decisions.json
DOCFORM=decisions|name|deferred.json
DOCFORM=decisions|name|rejected.json
DOCFORM=decisions|name|retirements.json
DOCFORM=extractions|pattern|extraction-(?P<docnum>[0-9]{2})-[a-z0-9-]+\.md
DOCFORM=phases|pattern|<ARC>-[1-9][0-9]*-closure\.md
<!-- DOCFORM:END -->

<!-- R11:BEGIN -->
R11_DIST=30
R11_EXEMPT=CF-252
R11_EXEMPT=CF-601
R11_EXEMPT=CF-602
R11_EXEMPT=CF-613
R11_EXEMPT=CF-653
R11_EXEMPT=CF-678
R11_EXEMPT=CF-715
R11_EXEMPT=CF-720
R11_EXEMPT=CF-907
R11_EXEMPT=CF-935
R11_EXEMPT=CF-993
R11_EXEMPT=CF-1054
R11_EXEMPT=CF-1055
R11_EXEMPT=CF-1095
R11_EXEMPT=CF-1163
R11_EXEMPT=CF-1166
R11_EXEMPT=CF-1193
R11_EXEMPT=CF-1202
<!-- R11:END -->

<!-- FIRED:BEGIN -->
FIRED_FIRSTLOAD_EXEMPT=4
<!-- FIRED:END -->

`R11` 블록은 원장의 산문 필드가 조항에 붙은 특정 주석을 지목하는 것을 보는 검사가 읽는다.
`R11_DIST` 는 규율 ID 토큰과 「주석」 사이에 허용하는 거리이고 `R11_EXEMPT` 는 면제하는 항목의
ID 다. 면제를 두는 까닭은 원장이 수정 불가여서 이미 실린 위반을 고칠 수단이 폐기 레코드뿐인
것이며, 갈래와 그 사유는 원장이 든다. **목록에 항을 더하는 것은 결정 세션의 조작이고 집행이
그것을 고쳐 통과시키지 않는다.**

`FIRED` 블록은 발화한 이연 항목이 어느 아크에도 배정되지 않은 것을 보는 검사가 읽는다. 첫 적재의
항은 그 검사가 면제하는데 그 면제가 영구적이므로, 면제되는 항의 수를 값으로 고정해 새로 발화하는
항이 그 안에 조용히 들어오는 자리를 막는다. **그 값은 줄어들 수 있고 늘어날 수 없다.** 줄어드는
것은 그 항이 처분된 것이고 늘어나는 것은 면제가 자란 것이다.

<!-- POINTER:BEGIN -->
POINTER_COMMENT=34
POINTER_EPHEMERAL=22
POINTER_SECTION=205
<!-- POINTER:END -->

`POINTER` 블록은 리포의 영구 문면이 리포 밖에서만 뜻을 갖는 식별자를 지목하는지 보는 검사가
읽는다. 금지 갈래가 셋이고 키마다 그 갈래의 적발 계수를 든다. 그 조항이 소급하지 않으므로 이미
쓰인 문면이 전량 적발로 나오며, **그 계수를 값으로 고정해 앞으로 쓰는 문면이 그 수를 늘리는
자리를 막는다.** 그 값은 줄어들 수 있고 늘어날 수 없다. 줄어드는 것은 그 자리가 정리된 것이고
늘어나는 것은 금지된 지목이 새로 선 것이다. **갈래마다 계수를 가르는 근거는 한 갈래를 고치고
다른 갈래를 더하면 합이 같아 통과한다는 것이다.** 유니버스와 갈래별 판별은 `SPEC.md` §2.1 이
든다. 그 값은 이 검사가 처음 설 때 이 검사 자신이 낸 것이다.

<!-- SOURCING:BEGIN -->
SOURCING_SINCE=1712
SOURCING_MINLEN=16
<!-- SOURCING:END -->

`SOURCING` 블록은 배제 사례 문단의 조달처 지목을 보는 검사가 읽는다. `SOURCING_SINCE` 는 그
요구가 걸리기 시작하는 경계이며 원장 ID 의 숫자 부분을 든다. docstring 이 영구 문면이고 소급하지
않는 요구가 걸리므로 경계 이전의 문면을 고치지 않으며, **경계 이후의 선언이 경계 이전의 문면을
복제하면 걸리므로 그 복제 경로가 막힌다.**

**그 경계가 조달처 줄의 요구에만 걸린다.** 그 검사가 두 가지를 재는데, 추출 기록 지목이 실재하는
절에 닿는가는 형식층 docstring 전량을 유니버스로 받고 경계를 걸지 않으며, 배제 사례 문단이 조달처
줄을 드는가만 이 경계 안의 선언을 유니버스로 받는다. **「그 값보다 작은 표지를 가진 선언은
유니버스 밖이다」로 적으면 두 유니버스가 같은 경계를 받는 읽기가 함께 서고**, 그 읽기로는 경계
이전 선언의 지목이 실재하지 않는 절에 닿아도 걸리지 않게 된다. 지목의 착지는 그 docstring 의 뜻이
서는가의 문제여서 소급의 경계와 축이 다르다.

`SOURCING_MINLEN` 은 낫표로 감싼 구절의 최소 길이이며 공백을 접은 뒤의 글자 수를 든다. 구절이
짧으면 그 기록의 다른 절에도 우연히 서서 지목이 느슨해지고, 길면 지목이 깨지기 쉬우나 **추출
기록이 덧붙이기만 허용하여 앞 문면이 고쳐지지 않으므로 길어도 안전하다.** 그래서 이 블록이 하한만
들고 상한을 두지 않는다.

**두 값을 고쳐 통과시키지 않는다.** 경계를 올리면 그 사이의 선언이 조용히 유니버스에서 빠지고,
최소 길이를 내리면 그 지목이 느슨해진다. 유니버스와 판정 셋은 `SPEC.md` §2.1 이 든다.

---

## 6. CQ 고정 절 (CF-571)

이 절이 잠그는 것은 `CQ-fin` 열둘의 **서명과 docstring** 이며, 그 선언의 거처는
`CrisisFramework/Observation/CompetencyQuestion.lean` 이다. 고정 절의 값은 §5 의 `CQFIN` 블록이
든다.

한 줄의 형식은 `CQFIN=<번호>|<구조물 이름>|<답 함수의 타입>|<docstring 다이제스트>` 다.

**서명은 값으로 싣고 docstring 은 다이제스트로만 싣는다.** 산문을 두 벌 두면 전사가 되어 한쪽을
고칠 때 나머지가 낡는다. 다이제스트를 실으면 문면이 바뀌는 순간 그 자리에서 대조가 어긋남을
잡는다.

고정한 뒤의 개변은 세 자리에서만 들어간다. 새 CQ 를 더하는 것과, 답이 함수로 받는 열거에 원소를
더하는 것과, 판정 불가의 까닭을 세분하는 것이다.

대조는 `scripts/verify.sh` 의 `step7-cqfin` 단계가 수행한다.

---

## 7. docstring 문단 머리말의 예약 낱말 (D-2 · T 계열 · V 계열 · L 계열)

Lean docstring 의 문단 머리말 가운데 **예약 낱말**을 든 것은 아래 표의 형을 맞춘다. 예약
낱말을 하나도 들지 않는 머리말은 그 선언에 고유한 사유를 드는 자리이므로 자유이며, 실측하면
자유 머리말이 92 형이고 예약 낱말과 하나도 겹치지 않는다. 값의 정본은 §5 의 `HEADING` 블록이
들고 이 표는 사람이 읽는 자리다.

| 상황 | 예약 낱말 | 형 | 조항 |
|---|---|---|---|
| 대응하는 비형식 개념 | `대응 비형식 개념` | `대응 비형식 개념:` | D-2 1항 |
| 배제하는 구체 사례 | `배제하는 사례` | `이 정의가 배제하는 사례:` | D-2 2항 |
| 기각한 대체 정의 | `기각한 대체 정의` | `기각한 대체 정의:` | D-2 3항 |
| 반증 조건 | `거짓이려면` | `이 명제가 거짓이려면 무엇이 관측되어야 하는가:` | T-2 |
| 가정이 있을 때 | `가정` | `가정과 그 배제 사례(T-4·T-5):` | T-4 · T-5 |
| 가정이 없을 때 | `가정` | `가정을 두지 않는다.` | T-4 |
| 존재 형태로 진술한 까닭 | `존재 형태` | `존재 형태로 진술하는 까닭(T-6):` | T-6 |
| 보조 보정 분류 | `T-3 분류` | `T-3 분류:` | T-3 |
| 분할의 배제 사례 | `V-4 사례` | `<무엇> 분할의 V-4 사례.` | V-4 |
| 완전성이 따라 나올 때 | `완전성` | `분할의 완전성은 <귀결>의 귀결이다(V-7).` | V-7 |
| 완전성을 주장하지 않을 때 | `완전성` | `분할의 완전성을 주장하지 않는다(V-7).` | V-7 |
| witness 의 증거 대상 | `증거` | `무엇을 증거하는가.` | A-3 · D-8 |
| 시점 인덱스의 예외 | `인덱스` | `인덱스가 ℕ 인 것은 L-13 의 명시적 예외다.` | L-13 |
| 수 체계를 받을 때 | `수 체계` | `수 체계를 매개변수로 받는다.` | L-10 |
| 수 체계를 받지 않을 때 | `수 체계` | `수 체계를 받지 않는다.` | L-10 |
| 관측층의 값 금지 | `값을 담지 않는다` | `값을 담지 않는다.` | L-14 |
| 분할의 모든 쌍이 배타적일 때 | `배타적` | `<무엇> 분할의 모든 쌍이 배타적이다.` | V-8 |
| 배타적이지 않은 쌍이 있을 때 | `배타적` | `<무엇> 분할에 배타적이지 않은 쌍이 있다.` | V-8 |

**배타성 문단의 둘째 형은 쌍을 들지 않는다.** 어느 쌍이 배타적이지 않은지는 그 문단의 본문이
들고 머리말은 두 꼴 가운데 어느 것인지만 가른다. 가변 구간을 하나로 두는 것이 위 표의 다른 행과
같은 제한이며, 쌍의 판정은 배타 관계의 실물이 낸다(V-8).

**첫 문단은 머리말을 두지 않는다.** 그 자리는 선언의 한 줄 서술이며 실측하면 178 선언 전량이
그 형이다.

### 7-1. 축 셋

**조항 ID 는 조건부로 서는 항목만 든다.** 모든 선언에 서는 D-2 세 항목은 ID 를 들지 않고,
조건부로 서는 T 계열과 V 계열은 든다. 앞에 ID 를 넣으면 검사 24 의 토큰이 선언마다 셋씩 늘어
계수가 부풀고, 그 자리가 어느 조항 때문에 섰는지는 머리말이 이미 말해 준다.

**뒤에 내용이 따르는 항목 머리말은 쌍점으로 닫고 그 자체가 단정인 머리말은 마침표로 닫는다.**
종결어미로 끝내고 마침표를 빼지 않는다. 같은 뜻의 머리말이 마침표 유무로 둘이 된 자리가 V-7
에서 실제로 났다.

**같은 항목의 문단을 한 선언 안에서 쪼개지 않는다.** 후보가 여럿이면 한 문단 안에서 열거한다.
쪼개면 선언과 머리말의 쌍이 머리말로 갈리는데 기각 레지스터는 후보 단위로 이미 여럿이라 입도가
양쪽에서 또 갈린다.

### 7-2. 경계

**이 표는 `DD:` 표지가 `CF-957` 이상을 가리키는 선언에만 걸린다.** 그 앞의 머리말은 그대로
두고 다른 사유로 그 자리를 편집할 때 함께 정리한다. 경계를 번호로 가르는 것은 선언 단위로는
서지 않기 때문이다. 옛 선언에 새 문단이 더해진 자리와 옛 문단에 표지가 다시 가리켜진 자리가
반례로 양쪽에 선다.

### 7-2-1. V-8 이 걸리는 분할

**V-8 은 아래 블록이 든 분할에만 걸린다.** 등록 관계를 드는 선언이 하나라 표지가 하나이고 그
번호가 §7-2 의 경계보다 앞서므로, 머리말의 번호 경계로는 이 요구의 자리를 가를 수 없다. 그래서
분할의 이름을 레지스터로 닫는다. 블록에 들지 않는 분할은 소급되지 않고 미정리분의 크기만
보고된다.

<!-- EXCL:BEGIN -->
EXCL=moneyness
EXCL=pledge
<!-- EXCL:END -->

블록에 분할을 더하면 그 분할의 배타성 문단을 함께 세운다. 문단만 쓰고 블록에 더하지 않으면 검사가
그것을 보지 않으며, 블록에 더하고 문단을 쓰지 않으면 검사가 실패시킨다.

### 7-3. 이 절을 고칠 때

- 표를 고치면 §5 의 `HEADING` 블록을 함께 고친다. 검사가 블록을 읽으므로 표만 고친 것은
  반영되지 않는다.
- 예약 낱말을 더할 때는 그 낱말이 자유 머리말과 겹치지 않는지 먼저 센다. 겹치면 그 낱말이
  오탐을 낳는다.

<!-- SESSIONCLAUSE:BEGIN -->
SESSIONCLAUSE_SERIES=A B C D F G J L N O P Q R S T V W
SESSIONCLAUSE=A-1
SESSIONCLAUSE=A-2
SESSIONCLAUSE=A-3
SESSIONCLAUSE=A-5
SESSIONCLAUSE=A-6
SESSIONCLAUSE=A-8
SESSIONCLAUSE=B-3
SESSIONCLAUSE=B-5
SESSIONCLAUSE=B-6
SESSIONCLAUSE=B-7
SESSIONCLAUSE=C-1
SESSIONCLAUSE=C-2
SESSIONCLAUSE=C-3
SESSIONCLAUSE=C-5
SESSIONCLAUSE=C-6
SESSIONCLAUSE=C-8
SESSIONCLAUSE=C-9
SESSIONCLAUSE=C-10
SESSIONCLAUSE=D-1
SESSIONCLAUSE=D-2
SESSIONCLAUSE=D-3
SESSIONCLAUSE=D-4
SESSIONCLAUSE=D-5
SESSIONCLAUSE=D-7
SESSIONCLAUSE=D-8
SESSIONCLAUSE=F-1
SESSIONCLAUSE=F-2
SESSIONCLAUSE=F-4
SESSIONCLAUSE=F-5
SESSIONCLAUSE=G-1
SESSIONCLAUSE=G-2
SESSIONCLAUSE=G-3
SESSIONCLAUSE=G-4
SESSIONCLAUSE=G-5
SESSIONCLAUSE=J-1
SESSIONCLAUSE=J-2
SESSIONCLAUSE=J-3
SESSIONCLAUSE=J-4
SESSIONCLAUSE=J-5
SESSIONCLAUSE=J-6
SESSIONCLAUSE=J-7
SESSIONCLAUSE=J-8
SESSIONCLAUSE=J-9
SESSIONCLAUSE=J-10
SESSIONCLAUSE=J-12
SESSIONCLAUSE=J-13
SESSIONCLAUSE=J-14
SESSIONCLAUSE=J-15
SESSIONCLAUSE=J-16
SESSIONCLAUSE=J-18
SESSIONCLAUSE=J-19
SESSIONCLAUSE=J-20
SESSIONCLAUSE=J-21
SESSIONCLAUSE=J-22
SESSIONCLAUSE=J-24
SESSIONCLAUSE=J-26
SESSIONCLAUSE=J-27
SESSIONCLAUSE=J-28
SESSIONCLAUSE=J-29
SESSIONCLAUSE=J-30
SESSIONCLAUSE=J-31
SESSIONCLAUSE=J-32
SESSIONCLAUSE=J-33
SESSIONCLAUSE=J-34
SESSIONCLAUSE=J-36
SESSIONCLAUSE=J-37
SESSIONCLAUSE=L-4
SESSIONCLAUSE=L-5
SESSIONCLAUSE=L-8
SESSIONCLAUSE=L-9
SESSIONCLAUSE=L-10
SESSIONCLAUSE=L-11
SESSIONCLAUSE=L-12
SESSIONCLAUSE=L-13
SESSIONCLAUSE=L-14
SESSIONCLAUSE=L-15
SESSIONCLAUSE=N-1
SESSIONCLAUSE=N-2
SESSIONCLAUSE=N-3
SESSIONCLAUSE=N-4
SESSIONCLAUSE=N-5
SESSIONCLAUSE=O-1
SESSIONCLAUSE=O-2
SESSIONCLAUSE=O-3
SESSIONCLAUSE=P-1
SESSIONCLAUSE=P-2
SESSIONCLAUSE=P-3
SESSIONCLAUSE=P-4
SESSIONCLAUSE=P-5
SESSIONCLAUSE=Q-1
SESSIONCLAUSE=Q-2
SESSIONCLAUSE=Q-3
SESSIONCLAUSE=Q-4
SESSIONCLAUSE=R-4
SESSIONCLAUSE=R-5
SESSIONCLAUSE=R-6
SESSIONCLAUSE=R-7
SESSIONCLAUSE=R-8
SESSIONCLAUSE=R-9
SESSIONCLAUSE=R-10
SESSIONCLAUSE=R-11
SESSIONCLAUSE=R-12
SESSIONCLAUSE=S-2
SESSIONCLAUSE=S-4
SESSIONCLAUSE=S-6
SESSIONCLAUSE=S-7
SESSIONCLAUSE=T-1
SESSIONCLAUSE=T-2
SESSIONCLAUSE=T-3
SESSIONCLAUSE=T-4
SESSIONCLAUSE=T-5
SESSIONCLAUSE=T-6
SESSIONCLAUSE=V-1
SESSIONCLAUSE=V-2
SESSIONCLAUSE=V-4
SESSIONCLAUSE=V-5
SESSIONCLAUSE=V-6
SESSIONCLAUSE=V-7
SESSIONCLAUSE=V-8
SESSIONCLAUSE=W-1
SESSIONCLAUSE=W-3
SESSIONCLAUSE=W-4
SESSIONCLAUSE=W-5
SESSIONCLAUSE=W-6
SESSIONCLAUSE=W-7
SESSIONCLAUSE=W-8
SESSIONCLAUSE=W-9
SESSIONCLAUSE=W-10
SESSIONCLAUSE=W-11
SESSIONCLAUSE=W-12
<!-- SESSIONCLAUSE:END -->

`SESSIONCLAUSE` 블록은 세션 지시가 드는 규율 조항의 목록을 값으로 고정하고, 그 목록이 원장에서
유도되는 살아 있는 조항과 양방향으로 맞는지 보는 검사가 읽는다. `SESSIONCLAUSE_SERIES` 는
유니버스에 드는 계열이며, 구멍과 미결의 ID 가 같은 꼴을 쓰므로 그 둘을 빼는 자리가 그것이다.
세션 지시는 리포에 없어 검사의 대상이 아니고, 이 블록이 그 문서의 거울이 되는 것은 사람이 지킨다.
**전문을 고치는 회차의 카드가 이 블록도 함께 고치므로 둘이 한 카드에 들어 따로 서지 않는다.**

**이 블록이 §5 가 아니라 파일 말미에 서는 것은 블록을 말미에 덧붙이는 관례의 결과다.** §7 의
예약 낱말과 무관하며 `EXCL` 블록이 §7-2-1 에 서는 것과 같은 형이다. §5 머리말이 드는 것은
그 절 안의 블록이므로 이 블록과 `EXCL` 은 거기에 들지 않는다.
