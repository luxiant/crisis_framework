# 빌드 검증 로그 — CrisisFramework 첫 형식화 산출물

검증일: 2026-09-12
검증자: Claude Code (Opus 5)
결과: **3개 파일 전부 컴파일 통과. `sorry` 0개, `axiom` 0개, 진술 변경 0건.**

---

## 1. 환경 핀

| 항목 | 값 |
|---|---|
| Mathlib 태그 | `v4.32.2` (요청대로 존재 확인됨, 대체 불필요) |
| Mathlib 커밋 | `905b95818eb32af7874a58b427f50c1711a5e96c` |
| `lean-toolchain` | `leanprover/lean4:v4.32.2` |

`lean-toolchain` 은 독립 선택하지 않고
`https://raw.githubusercontent.com/leanprover-community/mathlib4/v4.32.2/lean-toolchain`
의 값을 그대로 따랐다. 기존 설치(`leanprover/lean4:v4.33.1`)는 건드리지 않았고,
elan 이 이 디렉터리에만 v4.32.2 를 내려받았다.


## 2. `lake exe cache get`

**성공 (전량 캐시 히트).** 8639/8639 파일 다운로드, 8639개 압축 해제.
재실행 시 `No files to download` / `Already decompressed 8639 file(s)`, exit 0.

첫 실행은 exit 1 로 끝났으나 원인은 다운로드가 전부 끝난 뒤의
`/root/.cache/mathlib/curl.cfg` 정리 단계 오류였다. 캐시 미스가 아니므로
태그 선택이 잘못된 신호는 아니다. 로컬 Mathlib 전체 빌드는 하지 않았다.

## 3. 파일별 결과

| 파일 | 결과 | 원본 대비 |
|---|---|---|
| `CrisisFramework/Glossary/Core.lean` | **통과** | 무수정 (byte-identical) |
| `CrisisFramework/Definition/Constraint.lean` | **통과** | 무수정 (byte-identical) |
| `CrisisFramework/Accounting/Aggregation.lean` | **통과** | import + 전술 3줄만 수정 |

`sorry` 를 둔 지점 없음.

## 4. 변경 내역 (Aggregation.lean 만)

### 4-1. import

- `Mathlib.Algebra.BigOperators.Basic` — **v4.32.2 에 존재하지 않는 모듈.**
  삭제·분할됨. 다음으로 교체:
  - `Mathlib.Algebra.BigOperators.Ring.Finset` — `Finset.sum_mul`, `Finset.mul_sum`
  - `Mathlib.Algebra.BigOperators.Fin` — `Fin.sum_univ_two`
- `Mathlib.Tactic.Ring` / `.Linarith` / `.NormNum` 추가.
  대수 모듈만 import 하면 `ring`·`linarith`·`norm_num` 이
  `unknown tactic` 으로 실패한다(전술 프론트엔드가 따라오지 않음).
  `import Mathlib` 통짜 대신 정확한 모듈을 썼다.

### 4-2. 보조정리 이름 — **교체 없음**

사전에 의심된 이름들을 v4.32.2 소스에서 전부 확인했고 모두 유효했다:

- `Finset.sum_sub_distrib` — 존재. `Finset.prod_div_distrib` 의 `to_additive` 생성물
  (그래서 소스에 리터럴 선언이 없어 grep 으로는 안 잡힌다)
- `Finset.sum_add_distrib` — 존재. `Finset.prod_mul_distrib` 의 `to_additive` 생성물
- `nsmul_eq_mul` — 존재 (`Mathlib/Algebra/Ring/Defs.lean`, `@[simp]`)
- `Fin.sum_univ_two` — 존재 (`Fin.prod_univ_two` 의 `to_additive` 생성물)
- `∑ i ∈ S,` 표기 — 그대로 동작

### 4-3. 전술

**(a) 주 정리 마지막 단계 — 실질 수정 1건.**

두 번째 `simp only` 의 `Finset.mul_sum`, `Finset.sum_mul` 을
`← Finset.mul_sum`, `← Finset.sum_mul` (역방향)으로 바꿨다.

정방향은 상수를 합 **안으로** 밀어넣어 아래 잔여 목표를 남겼다:

```
(∑ x ∈ S, ↑(#S) * cap x * equity x) * 2 - (∑ x ∈ S, ∑ y ∈ S, cap y * equity x) * 2 =
(∑ x ∈ S, ↑(#S) * cap x * equity x) * 2 - ∑ x ∈ S, ∑ y ∈ S, cap y * equity x
                                        - ∑ x ∈ S, ∑ y ∈ S, cap x * equity y
```

즉 `∑∑ cap y * equity x = ∑∑ cap x * equity y` (전치, `Finset.sum_comm`)가
추가로 필요해진 상태였다. 역방향으로 두면 상수가 합 **밖으로** 빠져나와
양변이 곧바로 닫힌 형태 `2·n·Σ(ab) − 2·(Σa)(Σb)` 에 도달하고 `ring` 이 닫는다.

사전 예측대로 **전개 순서 문제였고 진술 문제가 아니었다.**

**(b) 린터 경고 정리 1건.** `inner` 의 `simp only` 에서
`Finset.sum_add_distrib` 를 제거했다 (`unusedSimpArgs` 린터가 미사용으로 지적).
전개 결과에 덧셈 형태 합이 나오지 않아 실제로 쓰이지 않는다.

**(c) 예상됐으나 발생하지 않은 마찰:**

- `aggregationError_eq_zero_of_constant_cap` 의 `simp at h` 는 `h` 를 `True` 로
  만들지 않았다. 오히려 `h : aggregationError S (fun x => c) equity = 0` 으로
  정확히 목표와 같은 형태로 정리했고, 뒤이은 `linarith [h]` 가 그대로 통과했다.
  `aggregationError_eq_zero_of_constant_equity` 도 동일. **구조 변경 불필요.**
- `Core.lean` 의 `ConceptRel` 은 `List Concept` 를 품고도 `deriving Repr` 이
  문제없이 동작했다. `deriving` 절 조정 없음.
- `Constraint.assetEligible : Asset → Prop` 관련 — 애초에 `DecidableEq` 를
  요구하지 않았으므로 무관. `deriving` 절 없음.

### 4-4. 경고 1건 — 후속 커밋에서 해소

```
Aggregation.lean:78:0: automatically included section variable(s) unused in theorem
  `two_mul_aggregationError_eq_pairwise`: [DecidableEq ι]
```

`variable {ι : Type} [DecidableEq ι]` 의 `DecidableEq ι` 가 주 정리에서
실제로 쓰이지 않는다는 지적. 1차 세션에서는 정리의 선언 시그니처를 건드리는
일이라 손대지 않았다.

> **후속 (커밋 `43bb875`, 승인된 수정).** `[DecidableEq ι]` 가정을 `variable`
> 에서 아예 제거했다. 예상과 달리 따름정리·`example` 들도 이 가정을 필요로
> 하지 않았다 — `Fin 2` 의 `DecidableEq` 는 인스턴스 탐색으로 자동 해결되므로
> 섹션 변수가 불필요했다. 제거 후 `lake build` 는 **warning 0** 으로 통과한다.
> 산출물(olean)에 실제로 반영되었는지는 `Scratch/VerifyBuilt.lean` 이
> `DecidableEq` 없는 `ℕ` 인덱스로 주 정리를 적용해 확인한다.
> 이 수정으로 §4-4 의 경고는 **남은 경고가 아니라 해소된 경고**다.

## 5. `#print axioms`

```
'CrisisFramework.Accounting.two_mul_aggregationError_eq_pairwise' depends on axioms:
  [propext, Classical.choice, Quot.sound]
```

`Classical.choice` 가 나왔다. **추적 결과: 증명에서 들어온 것이 아니다.**

추적 경로:

```
creditSupply (증명 없는 순수 def `cap * equity`)  →  이미 Classical.choice 의존
  → Rat.instMul  →  Rat.mul  →  Rat.normalize
      → Rat.normalize.reduced        ← 여기서 유입
          → Int.natAbs_ediv_of_dvd   ← 최종 발원지 (Lean 4 core)
```

대조 실험:

- 증명에 쓴 Mathlib 보조정리는 **전부 깨끗하다** —
  `Finset.sum_sub_distrib`, `Finset.sum_add_distrib`, `Finset.sum_const`,
  `Finset.mul_sum`, `Finset.sum_mul`, `Finset.sum_congr` 모두 `[propext, Quot.sound]`.
  `nsmul_eq_mul` 은 `does not depend on any axioms`.
- **import 이 전혀 없는** 파일에 `def f (a b : Rat) : Rat := a * b` 만 써도
  `f` 가 `[propext, Classical.choice, Quot.sound]` 를 갖는다.
  Mathlib 과 무관하게 Lean 4 core 에 박혀 있다.

따라서 이 버전의 Lean 에서 **`ℚ` 의 산술을 언급하는 순간 `Classical.choice` 는
회피 불가능**하다. `Decidable` 인스턴스를 제공하는 방향으로는 해결되지 않는다.
문제가 `Decidable` 판정이 아니라 core 의 `Rat.normalize` 안에 있기 때문이다.

단 이것은 논리적 약화가 아니다. 배중률이 수학적 논증에 쓰인 것이 아니라
`Rat` 곱셈의 정의 안에 있는 의존이고, 모든 것이 계산 가능한 상태로 남아 있다
(`noncomputable` 없음, `#eval` 동작 확인).

금지 항목 준수 확인: `axiom` 선언 0, `sorry` 0, `Classical.choice`/`Classical.em`/
`open Classical` 직접 사용 0, `noncomputable` 0.
`Accounting/` 의 `ℝ` — import closure 에 `Real` 이 아예 없다
(`#check (0 : Real)` → `unknown identifier`). 파일 내 `ℝ` 는 규율 조항을
인용한 주석 텍스트(L-4) 한 곳뿐.

## 6. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 세 파일의 정의·정리·`example` 진술을 한 글자도 바꾸지 않고 전부 통과했다.
주 정리의 항등식은 손계산과 일치했고, 실패는 전개 순서(전술) 문제였다.

## 7. `example` 반례 3개 — 실제 검사 확인

3개 모두 `lake build` 에서 정식 elaboration 된다. 주석 처리·삭제 없음.

**변이 검사(mutation test)로 실검사 여부를 확증했다.** 첫 번째 `example` 의
`≠ 0` 을 `= 0` 으로 바꾼 사본을 컴파일하면 실패한다:

```
Mutant.lean:139:47: error: unsolved goals
```

통과가 공허하지 않다는 증거다. 원본 파일은 변경하지 않았다.

계산으로도 교차 확인:

| witness | `aggregationError` 값 | 진술 |
|---|---|---|
| cap·equity 둘 다 다름 | `1` | `≠ 0` ✓ |
| cap 동일, equity 다름 | `0` | `= 0` ✓ |
| cap 다름, equity 동일 | `0` | `= 0` ✓ |

## 재현 절차

```bash
export PATH=/root/.elan/bin:$PATH
cd <리포 루트>
lake exe cache get
lake build
```


---

# 2차 세션 기록 (2026-09-12)

## 8. 사고: "검증된 파일 ≠ 손에 든 파일"

검토자가 `Aggregation.lean` 을 열었더니 1차 보고가 기술한 수정(import 교체,
전술 역방향화)이 **하나도 들어 있지 않았다.** 1차 보고와 파일이 정면으로
모순됐고, 프로젝트 전체가 기계 검증을 근거로 서 있으므로 판정 전부가
무효가 될 수 있는 상황이었다.

### 8-1. 원인 — 저장소에 같은 이름의 파일이 두 벌 있었다

```
<상위 디렉터리>/
├── Aggregation.lean                                  ← 낡은 초안. 빌드 타깃 밖.
├── Constraint.lean                                   ← 낡은 초안. 빌드 타깃 밖.
├── Core.lean                                         ← 낡은 초안. 빌드 타깃 밖.
└── crisis-framework/
    └── CrisisFramework/
        ├── Accounting/Aggregation.lean               ← 실제 빌드 대상
        ├── Definition/Constraint.lean                ← 실제 빌드 대상
        └── Glossary/Core.lean                        ← 실제 빌드 대상
```

`lakefile.toml` 의 `globs = ["CrisisFramework.+"]` 때문에 루트 사본은 빌드에
전혀 참여하지 않는다. 검토자가 본 것은 루트의 낡은 초안이었다.

`diff` 결과로 확인:

| 사본 | 빌드 대상과의 차이 |
|---|---|
| 루트 `Core.lean` | **동일** (byte-identical) |
| 루트 `Constraint.lean` | **동일** (byte-identical) |
| 루트 `Aggregation.lean` | **다름** — 1차 보고가 기술한 import 6줄·전술 3줄 수정이 빠진 상태 |
| `/root/.claude/jobs/37c91f61/tmp/Aggregation.lean.bak` | `variable` 1줄만 차이 (작업 A 직전 백업) |

### 8-2. 판정 — 1차 보고가 옳았다

루트 사본이 낡은 초안이고, 빌드 대상 파일에는 1차 보고가 기술한 수정이
**정확히 그대로** 들어 있었다. 보고서의 import·전술 기술은 사실과 일치한다.
2차 보고의 997 job 전량 통과도 사실이다. 모순은 보고서의 오류가 아니라
**검토자와 빌드가 서로 다른 파일을 보고 있었다**는 경로 문제였다.

`.bak` 이 job 임시 디렉터리에 있었던 것도 정상이다 — 작업 A 직전 백업이고
빌드 대상과 `variable` 한 줄만 다르다.

### 8-3. 조치

1. **루트 사본 3개 삭제.** git 이력(`689a39c`)에 남아 있으므로 소실 없음.
   이제 각 모듈은 저장소에 단 하나의 경로로만 존재한다.
2. **`Aggregation.lean` 헤더 정정.** `**검증 상태: 미검증.**` 이 그대로 남아
   사실과 어긋났다. 툴체인 핀·`sorry`/`axiom` 0·변이 검사·재현 명령을 담은
   문구로 교체했다.
3. **`scripts/verify.sh` 신설.** 아래 5단계를 한 번에 돌리는 재현 스크립트.
   1단계가 바로 이 사고를 재발 방지한다 — 저장소 전체를 훑어 빌드 타깃과
   이름이 겹치는 사본이 있으면 실패시킨다.

## 9. 버전 관리

검토자 지적대로 붙였다. 저장소는 이미 존재하며 이 사고 이전 상태부터 기록되어 있다:

| 커밋 | 내용 |
|---|---|
| `689a39c` | 기준선: 1차 세션에서 기계 검증된 상태 |
| `43bb875` | 회계층: 미사용 `DecidableEq` 가정 제거 (승인된 수정) |
| `abae782` | 검사: ℤ 기준선 스크래치 (빌드 타깃 밖, 이식 아님) |

`.gitignore` 는 `.lake/` 를 제외한다 (Mathlib 포함 7GB+). 재현에는
`lake-manifest.json` + `lean-toolchain` + `lake exe cache get` 으로 충분하다.

## 10. 디스크 내용 기준 재검증 결과

1차 보고를 신뢰하지 않고, **프로젝트 olean 을 전부 삭제한 뒤** 지금 디스크에
있는 바이트로부터 다시 컴파일해 확인했다.

```
✔ [994/997] Built CrisisFramework.Glossary.Core (575ms)
✔ [995/997] Built CrisisFramework.Definition.Constraint (1.8s)
✔ [996/997] Built CrisisFramework.Accounting.Aggregation (2.5s)
Build completed successfully (997 jobs).
```

| 검사 | 결과 |
|---|---|
| `lake build` (olean 삭제 후) | 997 job 통과, **error 0 / warning 0** |
| `sorry` | 0 |
| `axiom` 선언 | 0 |
| `noncomputable` | 0 |
| `Classical` 직접 사용 | 0 |
| `ℝ` | 1건 — 규율 인용 주석(L-4)뿐, 코드 0건 |
| olean 기준 공리 의존 (정리 3개) | `[propext, Classical.choice, Quot.sound]` — §5 의 `Rat` core 유입, 변화 없음 |
| `DecidableEq` 없이 주 정리 적용 | 통과 (작업 A 가 산출물에 반영됨) |
| 변이 검사 5/5 | 전부 거부 — 공허한 검사 없음 |

### 10-1. 변이 검사를 5개로 확대

1차 세션은 `example` 1개만 수동 변이했다. 이제 `≠ 0` / `= 0` 형태의 진술
**5개 전부**를 자동으로 하나씩 뒤집어 컴파일이 반드시 실패함을 확인한다.
따름정리 2개까지 포함된다.

| 지점 | 진술 | 뒤집었을 때 |
|---|---|---|
| L109 | `aggregationError S (fun _ => c) equity = 0` | 거부 ✓ |
| L122 | `aggregationError S cap (fun _ => e) = 0` | 거부 ✓ |
| L139 | witness: cap·equity 둘 다 다름 → `≠ 0` | 거부 ✓ |
| L147 | witness: cap 동일 → `= 0` | 거부 ✓ |
| L155 | witness: equity 동일 → `= 0` | 거부 ✓ |

`linarith`/`norm_num` 이 목표를 실제로 판정하고 있다는 뜻이다.

## 재현 절차 (갱신)

```bash
export PATH=/root/.elan/bin:$PATH
cd <리포 루트>
lake exe cache get          # 최초 1회
bash scripts/verify.sh      # 중복 사본 탐지 + 강제 재빌드 + 정적 검사 + 공리 + 변이 5개
```

스크립트는 실패 항목이 하나라도 있으면 비-0 으로 종료한다.


---

# 3차 세션 기록 (2026-09-12) — 회계층 `ℚ → ℤ` 이행

작업 3. 회계층의 기본 수 체계를 `ℤ` 로 옮긴다. `ℚ` 강제 대상은 현재 없다.

## 11. 관측값

관측값만 적는다. 해석은 §12 에 분리해 둔다.

### 11-1. 빌드

| 파일 | 결과 |
|---|---|
| `CrisisFramework/Glossary/Core.lean` | 통과 (무수정) |
| `CrisisFramework/Definition/Constraint.lean` | 통과 (무수정) |
| `CrisisFramework/Accounting/Aggregation.lean` | 통과 |

프로젝트 olean 전부 삭제 후 재빌드: **978 job 전량 통과, error 0 / warning 0.**
`sorry` 0, `axiom` 선언 0, `noncomputable` 0, `Classical` 직접 사용 0, 코드 내 `ℝ` 0.

job 수가 2차 세션의 997 에서 978 로 줄었다. `Mathlib.Tactic.Linarith` 와
`Mathlib.Algebra.Order.Ring.Rat` 이 import 목록에서 빠진 결과다.

### 11-2. 변경 내역

**(a) import — 2건.**

- `Mathlib.Algebra.Order.Ring.Rat` 제거. 제거 후 빌드 통과.
- `import Mathlib.Tactic.Omega` — **v4.32.2 에 존재하지 않는 모듈.** 추가하면
  `bad import 'Mathlib.Tactic.Omega'` 로 빌드가 깨진다.

  ```
  error: no such file or directory (error code: 4294967294)
    file: .../mathlib/Mathlib/Tactic/Omega.lean
  error: CrisisFramework/Accounting/Aggregation.lean: bad import 'Mathlib.Tactic.Omega'
  ```

  `omega` 는 Mathlib 이 아니라 Lean core 에 있다 (`Init/Omega.lean`,
  toolchain `leanprover/lean4:v4.32.2` 에 포함). `Init` 은 프렐류드로 자동
  import 되므로 **omega 전용 import 는 필요 없다.** 해당 줄을 삭제했다.
  (`Scratch/TacticProbe.lean` 이 omega import 없이 `omega` 를 쓰고 통과하는 것과
  일치한다.)

최종 import 목록:

```lean
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import CrisisFramework.Definition.Constraint
```

**(b) 전술 — 따름정리 2곳.**

```lean
-- aggregationError_eq_zero_of_constant_cap
-  simp at h
+  simp only [sub_self, zero_mul, Finset.sum_const_zero] at h
   omega

-- aggregationError_eq_zero_of_constant_equity
-  simp at h
+  simp only [sub_self, mul_zero, Finset.sum_const_zero] at h
   omega
```

`linarith → omega` 는 첨부본에 이미 반영돼 있었고 그대로 통과했다.
`simp → simp only [...]` 는 §11-4 의 측정 결과로 추가한 것이다.

**(c) docstring.** 헤더 검증 상태를 사실에 맞게 갱신. 따름정리 2곳의
"전술 주의" 항목을 §11-4 측정값으로 교체. `def`/`theorem` 필수 항목은 삭제·축약 없음.

**(d) 진술 변경 — 0건.** 첨부본과의 diff 에서 `def`/`theorem`/`example` 의
진술 라인은 한 줄도 바뀌지 않았다. 바뀐 것은 docstring, import 1줄, 전술 2줄뿐이다.

**(e) 검사 하네스.**

- `Scratch/VerifyBuilt.lean` — 적용 예시의 수 타입을 `ℚ → ℤ` 로 맞췄다
  (`ℚ` 로 두면 `aggregationError` 에 적용되지 않아 이 파일이 컴파일되지 않는다).
  과제가 지정한 기준선 프로브 `baselineProbe` / `baselineProbeSum` 추가,
  `creditSupply` / `aggregationError` 의 `#print axioms` 추가,
  반례 3개의 `#eval` 추가.
- `scripts/verify.sh` 4단계 — 출력만 하던 것을 **기대 기준선 대조**로 바꿨다.
  `BASELINE='[propext, Quot.sound]'` 를 두고 프로브 실측값 및 정리 5개를
  차분한다. 초과하면 §5-2 추적을 요구하며 실패한다. 2단계 job 수 문구는
  하드코딩(`997`)을 `Build completed successfully (N jobs)` 파싱으로 교체했다.

### 11-3. 공리 감사 — 회계층 기준선

**기준선 측정값 (olean 기준, `Scratch/VerifyBuilt.lean`):**

| 프로브 | 갱신 전 (ℚ 회계층) | 갱신 후 (ℤ 회계층) |
|---|---|---|
| 자명한 곱 (`baselineProbe`) | `[propext, Classical.choice, Quot.sound]` | **`does not depend on any axioms`** |
| `Finset` 합 (`baselineProbeSum`) — **실효 기준선** | `[propext, Classical.choice, Quot.sound]` | **`[propext, Quot.sound]`** |

`scripts/verify.sh` 의 기대 기준선을 갱신 후 값으로 바꿨다.

**정리별 `#print axioms` (갱신 후):**

```
'baselineProbe'                                        does not depend on any axioms
'baselineProbeSum'                                     [propext, Quot.sound]
'CrisisFramework.Accounting.creditSupply'              does not depend on any axioms
'CrisisFramework.Accounting.aggregationError'          [propext, Quot.sound]
'CrisisFramework.Accounting.two_mul_aggregationError_eq_pairwise'
                                                       [propext, Quot.sound]
'CrisisFramework.Accounting.aggregationError_eq_zero_of_constant_cap'
                                                       [propext, Quot.sound]
'CrisisFramework.Accounting.aggregationError_eq_zero_of_constant_equity'
                                                       [propext, Quot.sound]
```

기준선 초과분 **0건.** 2차 세션까지 세 정리 전부에 있던 `Classical.choice` 가 사라졌다.

### 11-4. `Classical.choice` 유입원 추적 — `omega` 만으로는 부족했다

첨부본 그대로(`simp at h` + `omega`) 빌드하면 빌드는 통과하지만 따름정리 둘이
여전히 `[propext, Classical.choice, Quot.sound]` 였다. 즉 **`linarith → omega`
교체만으로는 기준선이 깨끗해지지 않는다.**

`simp?` 로 `simp at h` 가 실제 사용한 보조정리 집합을 뽑았다:

```
simp only [sub_self, zero_mul, Finset.sum_const_zero, mul_eq_zero,
           OfNat.ofNat_ne_zero, false_or] at h
```

각 보조정리의 공리 (전부 기준선 이하):

```
sub_self                 does not depend on any axioms
MulZeroClass.zero_mul    does not depend on any axioms
mul_eq_zero              does not depend on any axioms
Finset.sum_const_zero    [propext, Quot.sound]
OfNat.ofNat_ne_zero      [propext]
false_or                 [propext]
```

보조정리는 전부 깨끗하다. `mul_eq_zero` 를 `ℤ` 에 **적용**할 때 필요한
`NoZeroDivisors ℤ` 인스턴스 쪽이 발원지다:

```
theorem p_mulzero (a b : Int) (h : a * b = 0) : a = 0 ∨ b = 0 := mul_eq_zero.mp h
  → [propext, Classical.choice, Quot.sound]
```

2×2 대조 (따름정리 1 기준):

| `simp` 범위 | 마무리 전술 | 공리 |
|---|---|---|
| 전면 `simp` (`mul_eq_zero` 포함) | `linarith` | `[propext, Classical.choice, Quot.sound]` |
| 전면 `simp` (`mul_eq_zero` 포함) | `omega` | `[propext, Classical.choice, Quot.sound]` |
| 제한 `simp only` (`mul_eq_zero` 제외) | `linarith` | `[propext, Classical.choice, Quot.sound]` |
| 제한 `simp only` (`mul_eq_zero` 제외) | `omega` | **`[propext, Quot.sound]`** |

전술 프로브 (`Scratch/TacticProbe.lean`, 재실행 확인):

```
lin_probe      [propext, Classical.choice, Quot.sound]
omega_probe    [propext, Quot.sound]
ring_probe     [propext, Quot.sound]
normnum_probe  [propext]
simp_probe     [propext, Quot.sound]
```

제한된 `simp only` 는 `h : 2 * aggregationError ... = 0` 을 남기고, `omega` 가
정수 선형 추론으로 닫는다. `mul_eq_zero` 로 2를 소거하는 단계 자체가 사라진다.

**§5-2 분류.** 초과분 둘 다 **전술 구현의 의존** (표의 2행). 논증의 의존이 아니다 —
수학적 내용은 `2x = 0 → x = 0` 이고 `omega` 가 구성적으로 닫는다.
정확히는 `linarith` 쪽은 전술 구현, `mul_eq_zero` 쪽은 전술이 고른 보조정리의
**인스턴스** 의존이므로 "전술 구현의 의존"의 변종이다. 둘 다 전술 교체로 회피됐다.

### 11-5. 변이 검사

진술 5개(따름정리 2 + `example` 3) 전부 결론을 뒤집은 사본이 컴파일 실패.

| 지점 | 진술 | 뒤집었을 때 |
|---|---|---|
| L145 | `aggregationError S (fun _ => c) equity = 0` | 거부 (1 error) |
| L161 | `aggregationError S cap (fun _ => e) = 0` | 거부 (1 error) |
| L179 | witness: cap·equity 둘 다 다름 → `≠ 0` | 거부 (1 error) |
| L187 | witness: cap 동일 → `= 0` | 거부 (1 error) |
| L195 | witness: equity 동일 → `= 0` | 거부 (1 error) |

변이 사본은 임시 디렉터리에만 만들고 검사 후 삭제한다. 원본 무변경.

### 11-6. 반례 값 (`ℤ`)

`#eval` 직접 계산 — `ℚ` 판본과 동일하게 **1, 0, 0**.

| witness | `aggregationError` 값 | 진술 |
|---|---|---|
| cap·equity 둘 다 다름 | `1` | `≠ 0` ✓ |
| cap 동일, equity 다름 | `0` | `= 0` ✓ |
| cap 다름, equity 동일 | `0` | `= 0` ✓ |

### 11-7. 음성 대조 (§5-4)

`verify.sh` 가 공허하지 않은지 확인했다. **검증된 트리를 건드리지 않고**
`$CLAUDE_JOB_DIR/tmp/negctl` 에 사본을 만들어 위반을 주입했다 (§6).

| 대조 | 주입 | 기대 | 결과 |
|---|---|---|---|
| NC-0 | 없음 | 통과 | 통과 (rc=0) |
| NC-1 | 루트에 `Aggregation.lean` 사본 | 1단계 실패 | 잡음 (rc=1) |
| NC-2 | 미사용 `[DecidableEq ι]` 재주입 | 2단계 warning 실패 | 잡음 (rc=1) |
| NC-3 | `omega` → `sorry` | 3단계 실패 | 잡음 (rc=1) |
| NC-4 | 주석에 `sorry axiom noncomputable Classical ℝ` | **오탐 없어야 함** | 오탐 없음 (rc=0) |
| NC-5 | 제한 `simp only` → 전면 `simp` | 4단계 기준선 초과 | 잡음 (rc=1) |
| NC-6 | `example` 하나 제거 (docstring 포함) | 5단계 대상 수 불일치 | 잡음 — "5개를 기대했으나 4개 발견" |

NC-6 첫 시도는 `example` 본문만 주석 처리해 앞선 docstring 이 고아가 되면서
빌드가 깨졌고, 5단계에 도달하기 전 2단계에서 실패했다. 주입을 docstring 까지
포함하도록 고쳐 재시도한 결과가 위 표다. **검사 스크립트의 결함이 아니라
주입의 결함이었다.**

NC-4 는 3단계가 주석 제거 후 검사한다는 §5-4 요구를 확인한다.

### 11-8. 사본 검사 (§5-5)

`verify.sh` 1단계 통과 — 저장소 안에 빌드 타깃과 이름이 겹치는 파일 없음.

## 12. 해석 (관측값 아님)

- `ℤ` 이행의 실효는 **두 갈래**였다. 수 표현(`Rat.normalize` → `Classical.choice`)
  제거는 `ℚ → ℤ` 치환만으로 얻어졌으나, 따름정리의 오염은 수 표현이 아니라
  `mul_eq_zero` 적용 인스턴스에서 왔고 전술 스크립트를 좁혀야 사라졌다.
  과제 문서의 가설("`linarith` 가 유일한 오염원")은 측정으로 반증됐다.
- 전면 `simp` 는 공리 기준선 관점에서 불투명하다. 어떤 보조정리를 끌어올지
  파일이 말해주지 않으므로, 인스턴스 경유 오염이 조용히 들어온다.
  기준선을 유지하려는 곳에서는 `simp?` 로 집합을 확정한 뒤 `simp only` 로
  고정하는 편이 재현 가능하다. — **판단 사항이며 이번에 따름정리 2곳 밖으로
  일반화하지 않았다.**
- `Mathlib.Tactic.Omega` 가 v4.32.2 에 없다는 것은 결핍이 아니다. `omega` 가
  core 로 올라갔기 때문이며, 그 덕에 전술 하나를 쓰려고 Mathlib 전술 모듈을
  추가로 끌어올 필요가 없다.

## 13. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 진술 변경 0건으로 전량 통과했다.

## 14. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **`verify.sh` 의 `BASELINE` 상수 위치.** 지금은 스크립트에 `ℤ` 기준선이
   하드코딩돼 있다. 다른 층(`Dynamics/` 는 `ℝ`)이 들어오면 층별 기준선이
   필요해진다. 현재 구조는 회계층 단일 기준선을 가정한다.
2. **`simp only` 고정의 일반화 여부.** §12 두 번째 항목. 다른 파일의 전면
   `simp` 호출에도 같은 처리를 할지는 정하지 않았다.
3. **워크트리와 1단계 사본 검사의 상호작용.** 이 작업은 격리 워크트리
   (`.claude/worktrees/…`) 에서 수행했다. 워크트리가 저장소 안에 중첩되므로,
   워크트리가 살아 있는 동안 **메인 체크아웃에서** `verify.sh` 를 돌리면
   1단계가 워크트리 쪽 사본을 중복으로 잡아 실패한다 (워크트리 안에서 돌리면
   `git rev-parse --show-toplevel` 이 워크트리를 가리켜 문제없다).
   1단계 `find` 에 `.claude/worktrees` 제외를 넣을지는 사람의 결정 사항이다.
4. **`CLAUDE.md` 가 git 미추적 상태.** 저장소 루트에 있으나 `??` 다. 커밋 여부를
   정하지 않았다.

## 재현 절차 (갱신)

```bash
export PATH=/root/.elan/bin:$PATH
cd <repo>/crisis-framework
lake exe cache get          # 최초 1회
bash scripts/verify.sh      # 중복 사본 + 강제 재빌드 + 정적 검사 + 기준선 차분 + 변이 5개
```

---

## 15. 4차 세션 — 원장 검증기의 음성 대조

검증일: 2026-09-19. 대상은 `scripts/check_wiki.py` 이며 `docs/decisions/SPEC.md` §2 의 검사
스물넷을 구현한 것이다. 이 절은 그 검사들이 공허하지 않은지를 확인한 결과만 든다.

### 15-1. 주입 방법

주입 장치는 `scripts/wiki_negative_control.py` 이고 다음 순서로 돈다.

1. 리포 사본을 임시 디렉터리에 만든다. `.lake` 와 `.git` 은 뺀다
2. 사본에 위반을 하나 주입한다. **원장 파일을 건드리지 않는다**
3. `check_wiki.py --root <사본>` 을 돌린다
4. 기준선(주입하지 않은 사본)의 출력과 견준다
5. 사본을 지운다

**판정 기준이 검사의 종류에 따라 갈린다.** 실패시키는 검사는 주입한 사본에서 `FAIL` 이 나는
것만으로는 부족하고 **기준선에 없던 위반 줄이 새로 나야** 통과로 본다. 검사 7과 23이 기준선에서
이미 실패하고 있어 판정을 `FAIL` 여부에만 걸면 그 둘의 대조가 공허해지기 때문이다. 보고만 하는
검사 넷은 실패시키지 않으므로 **보고 줄이 기준선과 달라지고 주입한 항목이 그 안에 잡혀야**
통과로 본다.

### 15-2. 결과

| 검사 | 단계 id | 주입한 위반 | 기준선 | 주입 후 | 잡았는가 |
|---|---|---|---|---|---|
| 1 | `wiki1-id-unique` | 같은 id 를 두 파일에 넣는다 | OK | FAIL | 예 |
| 2 | `wiki2-origin-arc` | 없는 아크명을 적는다 | OK | FAIL | 예 |
| 3 | `wiki3-origin-phase` | 선언되지 않은 페이즈를 적는다 | OK | FAIL | 예 |
| 3-a | `wiki3a-phase-form` | 다른 아크의 페이즈명을 적는다 | OK | FAIL | 예 |
| 4 | `wiki4-patch-grant` | 패치 없이 페이즈를 늘린다 | OK | FAIL | 예 |
| 4-a | `wiki4a-patch-from` | 없는 페이즈를 `from` 에 적는다 | OK | FAIL | 예 |
| 5 | `wiki5-closed-arc` | 닫힌 아크로 항목을 쓴다 | OK | FAIL | 예 |
| 6 | `wiki6-tier-vocab` | `tactical` 을 적는다 | OK | FAIL | 예 |
| 7 | `wiki7-invariant-check` | 없는 단계명을 적는다 | FAIL | FAIL | 예 |
| 8 | `wiki8-retire-target` | 같은 대상을 두 번 폐기한다 | OK | FAIL | 예 |
| 9 | `wiki9-retire-reason` | `reason` 을 비운다 | OK | FAIL | 예 |
| 10 | `wiki10-ghost-ref` | 폐기된 id 를 `related` 에 넣는다 | OK | FAIL | 예 |
| 11 | `wiki11-reopen-kind` | `kind` 를 비운다 | OK | FAIL | 예 |
| 12 | `wiki12-reopen-ref` | 아크가 아닌 문자열을 `arc_phase` 에 적는다 | OK | FAIL | 예 |
| 13 | `wiki13-dd-target` | 없는 id 를 주석에 적는다 | OK | FAIL | 예 |
| 14 | `wiki14-dd-layer` | 회계층 파일에서 정의층 항목을 지목한다 | OK | FAIL | 예 |
| 15 | `wiki15-names-unique` | 같은 규율 ID 를 두 항목에 적는다 | OK | FAIL | 예 |
| 23 | `wiki23-rule-ghost` | 폐기된 규율 ID 를 근거로 적는다 | FAIL | FAIL | 예 |
| 16 | `wiki16-trigger-fired` | 충족된 트리거를 등재한다 | REPORT | REPORT | 예 |
| 17 | `wiki17-reopen-null` | `reopen_when` 을 `null` 로 둔 항을 늘린다 | REPORT | REPORT | 예 |
| 18 | `wiki18-blocking-disposition` | `blocking` 구멍을 등재한다 | REPORT | REPORT | 예 |
| 19 | `wiki19-id-gap` | 항목을 지워 결번을 만든다 | REPORT | REPORT | 예 |
| 20 | `wiki20-arc-holes` | 해소도 이관도 안 된 구멍을 든 채 닫는다 | OK | FAIL | 예 |
| 21 | `wiki21-arc-blocking` | 발화도 해소도 이월도 안 된 `blocking` 을 든다 | OK | FAIL | 예 |

**검사 스물넷 전부가 자기 주입을 잡았다. 놓친 것이 0건이다.**

주입이 실제로 무엇을 끌어냈는지는 아래 줄이 든다. 각 줄은 기준선에 없다가 주입 뒤에 새로
나타난 위반 줄이며, 보고만 하는 넷은 달라진 보고 줄이다.

```
검사 1: id 중복 — CF-1 가 decisions 와 rejected 양쪽에 있다
검사 2: CF-24: 아크 `nosucharc` 가 arcs.json 에 없다
검사 3: CF-24: 페이즈 `charter-99` 가 아크 `charter` 에 선언되지 않았고 패치도 없다
검사 3-a: CF-24: 페이즈 `primary-1` 가 아크 `charter` 의 형태가 아니다
검사 4: CF-24: 페이즈 `charter-9` 를 늘리는 패치가 arcs.json 에 없다
검사 4-a: 아크 `charter` 의 패치가 없는 페이즈 `charter-99` 에서 옮겼다고 적는다
검사 5: CF-24: 닫힌 아크 `primary` 로 항목이 쓰였다
검사 6: CF-24: tier 가 어휘 밖이다 — 'tactical'
검사 7: CF-29: check `step9-nonexistent` 가 verify.sh 의 선언된 단계에 없다
검사 8: CF-1 에 폐기가 둘이다 — CF-219 와 CF-9008
검사 9: CF-219: reason 가 비었다
검사 10: CF-24: related 가 폐기된 CF-1 를 든다
검사 11: CF-148: kind 가 넷 밖이다 — ''
검사 12: CF-166: arc_phase 의 ref `아크가 아닌 문자열` 가 arcs.json 의 아크가 아니다
검사 13: CrisisFramework/Glossary/Core.lean:93: 표지가 없는 항목 CF-9999 를 가리킨다
검사 14: CrisisFramework/Accounting/Aggregation.lean:203: CF-2 의 layer 가 `definition` 인데 파일이 그 층에 없다
검사 15: 규율 ID `D-6` 이 CF-1 와 CF-2 양쪽에 붙었다
검사 23: CF-24: basis 가 폐기된 규율 `D-6`(CF-1) 를 related 에 적지 않고 든다
검사 16: 발화한 트리거 7건
검사 17: reopen_when: null 6건
검사 18: blocking 구멍 1건, 아크 1개
검사 19: CF-1~CF-246, 계수 245, 결번 1건
검사 20: CF-165: 해소도 이관도 되지 않은 채 아크 `charter` 가 닫힌다
검사 21: CF-9021: 아크 `charter` 의 blocking 구멍이 발화도 해소도 이월도 되지 않았다
```

### 15-3. 주입의 결함이 드러난 자리

**검사 20 의 첫 주입이 공허했다.** 아크의 `holes` 에 넣을 구멍을 「`reopen_when` 이 `null` 인
이연 항목」으로만 골랐더니 `CF-18` 이 잡혔는데, 그 항목은 이미 폐기된 것이라 검사 20 이 해소된
것으로 보고 넘어갔다. 주입을 「폐기되지 않은 항목」으로 좁혀 다시 돌린 결과가 위 표의 값이다.
**검사의 결함이 아니라 주입의 결함이었으며, 3차 세션의 NC-6 과 같은 형이다.**

### 15-4. 재현 절차

```bash
python3 scripts/check_wiki.py              # 원장 검증
python3 scripts/wiki_negative_control.py   # 음성 대조 (사본에 주입하며 원장을 건드리지 않는다)
```

---

## 16. 4차 세션 — 관측값

검증일: 2026-09-19. 이 회차는 `charter` 아크 페이즈 7이며 원장을 세우고 그것을 검사하는 설비를
붙였다. **음성 대조의 결과는 §15 가 들고 이 절은 나머지를 든다.**

### 16-1. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다.

| 파일 | 결과 |
|---|---|
| `CrisisFramework/Glossary/Core.lean` | 통과 |
| `CrisisFramework/Definition/Constraint.lean` | 통과 |
| `CrisisFramework/Accounting/Aggregation.lean` | 통과 |

`Build completed successfully (978 jobs)` 이며 error 0 warning 0 이다.

### 16-2. 변경 내역

회차의 커밋은 아래와 같다. 기준 커밋은 `5a38bb9` 다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `a95cb0e` | C-01 | `CLAUDE.md` §1-6 에 카드 병합 예외를 잇고 §14 「원장 병합 절차」를 신설 |
| `1e50895` | (추가) | `SPEC.md` 수정분과 `charter-6-closure.md` 를 커밋으로 고정 |
| `9799d8d` | (추가) | 지시서와 엔트리 카드를 `.gitignore` 에 넣고 index 에서 뺀다 |
| `95ef424` | C-02 | 엔트리 카드 241건을 원장 넷에 병합 |
| `c6f600d` | (운영자) | `SPEC.md` 에 컨테이너 조항과 검사 12·23 의 개정 |
| `257e32a` | C-02 보정 | 해소된 미결 다섯(`CF-242`~`CF-246`)을 `decisions.json` 에 이음 |
| `e429a0b` | C-04 | 원장 검증기 `scripts/check_wiki.py` 를 세움 |
| `e414286` | C-05 | 음성 대조 장치와 그 결과(§15) |
| `6313c46` | (추가) | `SPEC.md` 의 검사 23·12 와 검사 3·4 조항의 갱신분을 고정 |
| `bd46cf7` | C-04 보정 | 검증기를 그 갱신분에 맞춤 |
| `ab22208` | C-06 | `verify.sh` 를 기준선 파일과 검증기에 이음. 단계 여섯 |
| `74bad37` | C-07 | CI 워크플로 `.github/workflows/verify.yml` |
| `5046b2c` | C-08 | Lean 선언 열다섯에 `DD:` 표지 |

**추가 커밋 셋은 지시서에 없던 조작이다.** `1e50895` 와 `9799d8d` 는 지시서를 쓴 쪽이 리포의 git
상태를 확인하지 않아 생긴 결손을 메운 것이고, `6313c46` 은 명세 갱신분을 구현보다 먼저 커밋으로
세운 것이다.

`verify.sh` 의 변경이 다섯이다. ① `step()` 이 `[step:<id>]` 를 출력에 내고 호출의 첫 인자가 단계
id 다. ② 4단계가 `docs/baseline.md` 의 기계 판독 블록에서 `ACCOUNTING_INT` 를 읽는다. 스크립트에
박혀 있던 `BASELINE` 상수가 사라졌다. ③ 3단계의 `ℝ` 금지를 층별로 갈랐고 동학층은 건너뛴다.
④ 6단계로 `check_wiki.py` 호출을 더했다. ⑤ 음성 대조 장치를 `Scratch/` 에서 `scripts/` 로 옮겼다.

Lean 파일의 변경은 표지 열다섯 줄과 머리말 한 줄씩이다. **docstring 은 한 글자도 바뀌지 않았다.**

### 16-3. 원장

계수는 `check_wiki.py` 의 출력에서 읽었고 손으로 세지 않았다.

```
레지스터 entry: decisions 190 · deferred 33 · retirements 23 · rejected 0 · 총계 246
```

병합은 두 차례였다. 첫 병합이 241건이고 결정 세션이 검사 23 으로 유령 하나를 잡은 뒤 보정 병합이
다섯을 더해 246건이 됐다.

**등가 검증은 카드 파일 삭제보다 앞에서 돌았다.** 양쪽 entry 를 같은 매개변수로 직렬화해
바이트열로 견주는 방식이며 차분으로 갈음하지 않았다. 246건 전부가 바이트로 같았고, 어느 한쪽에만
있는 entry 가 없음을 두 방향으로 확인했다. 그 뒤에 카드 파일을 지웠다.

| 축 | 값 |
|---|---|
| 카드 파일 md5 (첫 병합) | `90d948c844f662486148e0a22a8a3860` |
| 카드 파일 md5 (보정 병합) | `585d3f066dd784ed108f7945bf3821cb` |
| 바이트로 같음이 확인된 entry | 246건 |
| id 범위·결번·중복 | `CF-1`~`CF-246`, 결번 0, 중복 0 |

### 16-4. 공리 감사

기준선을 이제 `docs/baseline.md` 에서 읽으며 그 값이 `[propext, Quot.sound]` 다. 회차 내내
불변이었고 초과분이 없어 유입원 추적이 서지 않는다.

```
'baselineProbe' does not depend on any axioms
'baselineProbeSum' depends on axioms: [propext, Quot.sound]
'CrisisFramework.Accounting.creditSupply' does not depend on any axioms
'CrisisFramework.Accounting.aggregationError' depends on axioms: [propext, Quot.sound]
'CrisisFramework.Accounting.two_mul_aggregationError_eq_pairwise' depends on axioms: [propext, Quot.sound]
'CrisisFramework.Accounting.aggregationError_eq_zero_of_constant_cap' depends on axioms: [propext, Quot.sound]
'CrisisFramework.Accounting.aggregationError_eq_zero_of_constant_equity' depends on axioms: [propext, Quot.sound]
```

### 16-5. 변이 검사

진술 다섯을 검사했고 전부 거부됐다. 각각 error 1건이다. 표지와 머리말이 들어가 행 번호가 밀렸으며
대상 수는 다섯으로 같다.

| 행 | 결과 |
|---|---|
| 149 · 166 · 184 · 192 · 200 | 전부 거부 (각 1 error) |

### 16-6. `DD:` 표지

열다섯이 섰다. 이 회차 전에는 0이다.

| 파일 | 표지 |
|---|---|
| `Glossary/Core.lean` | CF-76 · CF-57 · CF-77 · CF-58 |
| `Definition/Constraint.lean` | CF-130 · CF-31 · CF-122 · CF-31 · CF-50 · CF-31 |
| `Accounting/Aggregation.lean` | CF-130 · CF-130 · CF-130 · CF-59 · CF-59 |

검사 13 이 열다섯을 보고 통과했고, 검사 14 는 `meta` 가 아닌 표지 **넷**을 판정해 통과했다.
`glossary` 셋(CF-76 · CF-77 · CF-58)과 `definition` 하나(CF-50)다. 나머지 열하나는 원장이 `layer`
를 `meta` 로 들어 검사 14 가 건너뛴다.

표지는 docstring 의 닫는 `-/` 와 선언 줄 사이에 둔다. 그 자리에 줄 주석이 들어가도 docstring
첨부가 끊기지 않음을 `Lean.findDocString?` 으로 미리 실측했다.

### 16-7. 음성 대조

§15 가 든다. **검사 스물넷 전부가 자기 주입을 잡았고 놓친 것이 0건이다.** 명세와 검증기와
`verify.sh` 가 달라질 때마다 다시 돌렸으며 이 절이 드는 값은 마지막 실행의 것이다.

### 16-8. CI 러너

워크플로를 세운 뒤 두 차례 돌았고 둘 다 통과했다.

| 실행 id | 커밋 | 결론 | 소요 | `DD:` 표지 |
|---|---|---|---|---|
| `35465603851` | `74bad37` | success | 1m51s | 0개 (표지 이전 판) |
| `35466416805` | `5046b2c` | success | 2m17s | **15개** |

`lake exe cache get` 이 러너에서 성공했다. 8639 파일을 받아 전부 풀었으며, 그 단계가 실패하면
거기서 멈추고 로컬 전량 빌드로 넘기지 않는다는 조항이 발동할 일이 없었다.

러너의 `verify.sh` 출력은 집행 환경의 것과 줄 단위로 같다. 다른 것은 뿌리 경로와 빌드 시간뿐이다.

### 16-9. 수록 문면이 스스로 걸린 자리

**Lean 세 파일의 머리말을 고치는 조작에서 검사 13 이 실패했다.** 처음 수록된 문면이 이랬다.

> 원장: 선언마다 `-- DD:<id>` 표지가 든다. 목록은 `docs/decisions/` 가 정본이다.

검사 13 이 `-- DD:<무엇>` 꼴을 표지로 잡으므로, **표지의 형태를 예시로 든 그 문장 자체가 표지로
읽혔다.** 표지 계수가 열다섯이 아니라 열여덟로 잡혔고 세 파일이 각각 한 줄씩 걸렸다.

```
· CrisisFramework/Accounting/Aggregation.lean:28: 표지 `<id>`` 가 CF-<n> 형식이 아니다
· CrisisFramework/Definition/Constraint.lean:8: 표지 `<id>`` 가 CF-<n> 형식이 아니다
· CrisisFramework/Glossary/Core.lean:10: 표지 `<id>`` 가 CF-<n> 형식이 아니다
```

**이 형태는 이 프로젝트에서 두 번째다.** `CLAUDE.md` §5-5 가 근거로 든 첫 사례는 3차 세션에서
헤더에 적은 「`sorry` 0」 같은 설명 문구가 금지 구문 검사에 스스로 걸린 것이었다. 그때는 검사가
주석을 제거한 뒤에 돌게 해서 해소됐는데, **검사 13 은 표지 자체가 주석이라 주석 제거로는 같은
해소가 되지 않는다.**

집행은 문면도 검증기도 고치지 않고 그 자리에서 멈춰 보고했다. 결정 세션이 문면을 표지 꼴이
들어가지 않는 문장으로 바꾸어 해소했다.

> 원장: 선언마다 표지가 붙는다. 표지가 가리키는 항목의 정본은 `docs/decisions/` 다.

검사 13 이 열다섯으로 돌아왔다. **검사 13 의 유니버스를 줄 주석으로 좁히는 정밀화는 이 해소와
별개로 따로 이루어진다.** R-6 의 문면이 이미 줄 주석 형태를 들고 있어 그것이 명세를 정확히
구현하는 것이며, 문면 교체로 이미 통과한 뒤에 하므로 통과를 위한 조치가 아니다.

## 17. 해석 (관측값 아님)

- **원장이 수정 불가라는 규율이 이 회차에서 두 번 값을 치렀다.** 첫 병합 뒤에 검사 23 이 유령을
  잡았을 때 고칠 수 있는 길이 「항목을 더하는 것」뿐이었고, 첫 적재의 `related` 가 전량 비어
  있다는 것이 드러났을 때도 채우는 길이 막혀 명세에 예외를 두는 쪽으로 갔다. **수정 불가의 비용이
  실측으로 드러난 자리이며 그 비용을 치를 값어치가 있는지는 이 문서가 판정하지 않는다.**
- **사전 검사와 증거의 구별이 실증됐다.** 결정 세션이 검사 열다섯을 미리 돌려 전량 통과를 얻었으나
  그 구현이 검사 23 의 조항을 절반만 담고 있었고, 집행 환경에서 처음 돌렸을 때 43줄이 걸렸다.
  W-8 이 사전 검사를 필터로만 두는 근거가 여기서 실증됐다.
- **문면이 검사의 대상이 되는 자리가 늘었다.** 검사가 소스를 문자열로 읽는 한 설명 문구와 검사
  대상이 같은 표면에 있고, 그 둘을 가르는 것이 검사 설계의 상시 항목이 된다. §16-9 가 두 번째
  사례다.
- **CI 가 이제 원장까지 본다.** 6단계가 `check_wiki.py` 를 부르므로 원장의 정합이 빌드와 같은
  자리에서 판정된다. 원장이 코드가 아닌데 코드와 같은 관문을 지나는 것이 이 설계의 요지다.

## 18. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 이 회차는 `theorem` 과 `def` 의 진술을 하나도 세우지 않았고 기존 진술도 건드리지 않았다.
변경은 주석 열다섯 줄과 머리말 세 줄이며 진술 변경 0건이다.

## 19. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **검사 14 의 대상이 넷이다.** 지시서의 기대는 다섯이었다. 다섯째가 되려면 `Core.lean` 의
   `SourceTag` 가 지목하는 CF-57(D-5)이 `glossary` 여야 하는데 원장이 그것을 `meta` 로 든다.
   배정을 바꾸는 것은 원장 수정이라 폐기 레코드를 요구한다.
2. **`docs/baseline.md` §2 의 미측정 칸.** 4단계가 그 문서를 읽는데 블록의 키가 `ACCOUNTING_INT`
   와 `ACCOUNTING_RAT` 둘뿐이다. 정의층·관측층·용어집·동학층이 미측정이라 그 층의 파일이 서면
   차분할 기준선이 없다. 지금은 대상 파일 셋이 전부 회계층 기준선으로 판정된다.
3. **검사 16 이 `artifact` 여섯의 발화를 보고한다.** 전부 `CrisisFramework/Glossary/Core.lean`
   을 가리키며 그 파일이 이미 실재한다. 발화 탐지가 그것을 읽는 쪽을 요구하는데 지금은 보고만
   난다.
4. **검사 3 과 검사 4 가 같은 조건을 다른 각도에서 본다.** `SPEC.md` 가 그 관계를 명문화했으므로
   결손은 아니나, 둘을 독립으로 실패시킬 입력이 없다는 사실은 남는다.

## 재현 절차 (4차 세션)

```bash
export PATH=/root/.elan/bin:$PATH
cd <리포 루트>
lake exe cache get                          # 최초 1회
bash scripts/verify.sh                      # 여섯 단계 전량
python3 scripts/check_wiki.py               # 원장 검증만 따로
python3 scripts/wiki_negative_control.py    # 음성 대조 (사본에 주입하며 원장을 건드리지 않는다)
```

---

## 20. 5차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 8이며 **판별선은 검사의 유니버스를 넓히는
것**이다. 원장이 보는 범위가 원장 안으로 닫혀 있어 상주 문서와 Lean 주석의 규율 지목이 검사되지
않았고 그 자리를 열었다.

### 20-1. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차의 Lean 변경은 `Core.lean` 의 docstring 두 자리뿐이다.

### 20-2. 변경 내역

받은 커밋은 `bcf1eeb` 다. 카드마다 커밋을 갈랐다. `SPEC.md` 를 다섯 카드가 세 구간에 걸쳐
만지고 `check_wiki.py` 를 네 카드가 만지므로, 한 커밋에 두 카드를 담으면 역순 되돌림이
성립하지 않기 때문이다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `428717e` | CD-01 | 엔트리 카드 서른(`CF-247`~`CF-276`)을 `decisions.json` 에 병합 |
| `264de65` | CD-02 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |
| `1c2d03e` | CD-03 | 검사 23 의 승인 경로를 폐기 레코드 지목으로 바꿈 |
| `0f724fc` | CD-04 | 검사 4 를 폐기하고 검사 3 하나로 둠 |
| `8cc8981` | CD-05 | 상주 문서와 Lean 주석을 보는 검사 24 를 세움 |
| `580e61e` | CD-06 | 낡은 규율 지목의 처분. 정정 셋과 선언 둘 |
| `dafaef8` | CD-07 | 표지 누락을 보는 검사 25 를 세움. 지시서 밖 조작 둘을 포함 |
| `33f410c` | CD-08 | 새 검사 둘의 음성 대조 |

### 20-3. 원장

계수는 `check_wiki.py` 의 출력에서 읽었고 손으로 세지 않았다.

```
레지스터 entry: decisions 220 · deferred 33 · retirements 23 · rejected 0 · 총계 276
```

병합은 한 차례이고 `decisions` 만 늘었다. 카드의 나머지 세 레지스터가 빈 배열이라 그 세 파일을
열지 않았다. 총계 246 이 276 으로 늘었고 늘린 것이 그 서른이다.

**등가 검증은 카드 파일 삭제보다 앞에서 돌았다.** 계수나 차분으로 갈음하지 않고 양쪽 entry 를
같은 매개변수로 직렬화해 바이트열로 서른 번 견주었다. 불일치 0 이고, id 배열이 순서까지 같으며,
어느 한쪽에만 있는 entry 가 없고, 병합 전 190건이 `bcf1eeb` 판과 바이트로 같다.

### 20-4. 검사 계수의 이동

세 자리에서 움직였다. 아크 종료 검사 둘은 계속 `SKIP` 이다.

| 시점 | 검사 수 | 수행 | 무엇이 움직였나 |
|---|---|---|---|
| 시작 | 24 | 22 | |
| CD-04 뒤 | 23 | 21 | 검사 4 를 폐기 |
| CD-05 뒤 | 24 | 22 | 검사 24 를 신설 |
| CD-07 뒤 | **25** | **23** | 검사 25 를 신설 |

### 20-5. 검사 24 — 상주 문서와 Lean 주석

유니버스는 상주 문서 여섯(`CLAUDE.md` · `docs/baseline.md` · `docs/decisions/SPEC.md` ·
`docs/reading-queue-v0.md` · `docs/bundle-inventory-v0.md` · `docs/arcs.json`)과 Lean 세 파일의
주석이다. 유니버스 밖은 `BUILD_LOG.md` 와 `docs/phases/` 와 `docs/extractions/` 와
`docs/arcs.json` 의 `patches` 배열이다.

**첫 실행이 실물의 낡은 지목 21 자리를 잡았다.** 실물이 양성 대조를 겸했으며 0 이 나왔다면
검사가 공허한 것이었다.

| 문서 | 폐기 지목 | 처분 |
|---|---|---|
| `docs/decisions/SPEC.md` | 17 | 머리의 선언으로 면제 |
| `docs/reading-queue-v0.md` | 1 | 머리의 선언으로 면제 |
| `CrisisFramework/Glossary/Core.lean` | 2 | 정정 (`V-3` → `V-7`) |
| `docs/bundle-inventory-v0.md` | 1 | 정정 (`S-1` → `S-4`) |

21 이 18(면제)과 3(정정)으로 갈렸고 CD-06 뒤에 **미실재 0 · 선언 없는 폐기 지목 0 · 면제 18** 로
돌아왔다.

**뺀 자리에 폐기 토큰 89 건이 있다.** 그것이 잡히지 않는다는 것이 유니버스가 실제로 좁혀졌음을
든다. 뺀 자리를 빼지 않았다면 검사 24 가 21 이 아니라 110 을 냈을 것이다.

### 20-6. 검사 25 — 표지 누락

```
- 최상위 선언 15 · 표지 15 · 누락 0
```

유니버스는 최상위 `def`·`theorem`·`inductive`·`structure` 다. 앞 선언과 이 선언 사이에 선 표지를
이 선언의 것으로 보며, 표지의 유니버스는 검사 13 과 같아 블록 주석 안의 문면은 들지 않는다.
`example` 셋은 대상이 아니다.

### 20-7. 공리 감사와 변이 검사

기준선이 회차 내내 `[propext, Quot.sound]` 로 불변이고 초과분이 없다. 변이 검사는 진술 다섯
(`Aggregation.lean` 의 149·166·184·192·200행)을 검사했고 전부 거부됐다. `Core.lean` 의 docstring
한 줄이 두 줄이 됐으나 `Aggregation.lean` 을 손대지 않아 행 번호가 회차 내내 같다.

### 20-8. 음성 대조

주입 항 27 개가 검사 25 개에 걸린다. 한 검사가 주입 둘을 받는 자리가 둘이다(검사 3 과 검사 24).

**항의 표기를 `<단계 id>#<차례>` 로 바꿨다.** 검사 번호에 접미를 붙이면 실재하는 검사 `3-a`·`4-a`
와 같은 꼴이 되어 항인지 검사인지 갈리지 않는다. 단계 id 는 `wiki` 접두를 가져 네임스페이스가
다르다.

| 주입 항 | 검사 | 주입한 위반 |
|---|---|---|
| `wiki3-origin-phase#2` | 3 | 권한을 준 패치를 지운다 |
| `wiki24-doc-rule-ghost#1` | 24 | 상주 문서에 없는 규율 ID 를 적는다 |
| `wiki24-doc-rule-ghost#2` | 24 | 선언되지 않은 폐기 규율을 적는다 |
| `wiki25-marker-missing#1` | 25 | 최상위 선언 하나의 표지를 지운다 |

**주입 항 27 개 전부가 자기 주입을 잡았고 놓친 것이 0 이다.**

검사 23 의 승인 경로가 바뀐 자리는 CD-08 이 아니라 CD-03 에서 **양방향으로** 쟀다. 지시서가 음성
대조를 CD-08 에 배정했으나 그것은 새 검사 둘만 들어 그 자리가 비었다.

| 주입 | 결과 |
|---|---|
| `CF-254` 의 `related` 에서 폐기 레코드 id 를 뺀다 | 검사 23 이 잡는다 |
| 그 자리에 폐기된 항목의 id 를 넣는다 | 검사 10 이 잡고 검사 23 도 승인으로 인정하지 않는다 |

앞이 승인 경로가 산 것임을 들고 뒤가 그 경로가 좁다는 것을 든다. 한 방향만 쟀으면 넓혀서
통과시킨 것과 갈리지 않는다.

### 20-9. 주입이 조건을 만들지 못한 자리

**검사 24 의 첫 주입이 공허했다.** 토큰을 `Z-9924` 로 두었는데 `Z` 가 검사 23·24 의 계열 밖이라
애초에 규율 ID 로 읽히지 않았고, 주입한 사본에서도 위반이 나지 않았다. 계열에 들면서 `names` 에
없는 `Q-99` 로 바꿔 해소했다. **검사의 결함이 아니라 주입의 결함이며 3차 세션의 NC-6 및 4차
세션의 검사 20 과 같은 형이다.**

주입이 조건을 만드는지를 먼저 재라는 조항이 이 자리에서 값을 냈다.

### 20-10. CI 러너

여덟 커밋 가운데 여섯이 러너를 돌았다. 둘은 같은 push 에 묶여 단독 실행을 받지 않았다.

| 실행 id | 커밋 | 결론 | 사유 |
|---|---|---|---|
| `35487652540` | `428717e` | **failure** | 검사 23 이 네 줄로 실패. 병합이 CD-03 보다 앞선다 |
| `35487834783` | `264de65` | **failure** | 같은 네 줄 |
| `35488499418` | `0f724fc` | success | CD-03 이 해소 |
| `35489199352` | `8cc8981` | **failure** | 검사 24 가 21 자리를 잡는다 |
| `35489894119` | `580e61e` | success | CD-06 이 해소 |
| `35490505808` | `33f410c` | success | |

**실패 셋은 전부 기대된 것이다.** 구간 1·2 의 실패는 병합이 승인 경로 변경보다 앞서기 때문이고,
구간 4 의 실패는 검사 24 가 실물에서 양성 대조를 받는 자리이기 때문이다.

## 21. 해석 (관측값 아님)

- **검사를 세우는 구간과 고치는 구간을 가른 설계가 값을 냈다.** 검사 24 가 구간 4에서 21 을
  잡고 구간 5에서 0 이 됐다. 한 구간에 묶었으면 검사가 실제로 잡았는지와 고친 뒤 통과하는지가
  한 번의 보고에 섞였을 것이다.
- **수록 문면 자신이 검사의 대상이 되는 자리가 또 났다.** 검사 24 의 토큰 기대가 203 인데 실측이
  205 였고, 차이 둘이 그 구간에 넣은 §7-6 (b) 문면이 드는 `R-6` 둘이었다. 4차 세션의 검사 13
  사건과 같은 축이며, 검사가 소스를 문자열로 읽는 한 설명 문구와 검사 대상이 같은 표면에 있다.
- **「차이가 0인 어긋남은 보고되지 않는다」가 실증됐다.** `arcs.json` 을 파일 전체로 뺀 구현과
  `patches` 만 빼는 명세의 차이가 실측상 0 이어서 두 구간의 보고에 드러나지 않았고, 명세와 구현을
  문면 단위로 맞대어서 드러났다. 계수를 견주는 것으로는 잡히지 않는 종류다.
- **검사 10 과 검사 23 이 부딪힌 자리가 명세를 읽어서는 갈리지 않았다.** 승인 경로가 문면으로
  서 있었고 첫 적재의 면제 뒤에 가려 한 번도 밟힌 적이 없었다. 면제가 걸리지 않는 첫 페이즈가
  그것을 밟았고 그때 부딪혔다. 처분이 문면으로 서 있다는 것과 실행 가능하다는 것이 다른 사실이다.

## 22. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 이 회차는 `theorem` 과 `def` 의 진술을 하나도 세우지 않았고 기존 진술도 건드리지
않았다. Lean 변경은 `Core.lean` 의 docstring 두 자리이며 진술 변경 0건이다.

## 23. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **`BUILD_LOG.md` 의 미실재 토큰 아홉.** 이 파일이 검사 24 의 유니버스 밖이라 잡히지 않는다.
   앞 회차의 종료 문서가 일곱으로 들었고 이 회차의 §15 가 더해져 아홉이 됐다. 카드 번호인지
   규율 지목인지 판별이 남아 있다.
2. **검사 16 이 `artifact` 발화 여섯을 계속 보고한다.** 전부 `Glossary/Core.lean` 을 가리키고
   그 파일이 이미 실재한다. 발화 탐지를 읽는 쪽이 없다.
3. **`docs/baseline.md` §2 의 미측정 층 넷.** 그 층의 파일이 서면 차분할 기준선이 없다.
4. **`dynamics` 둘과 `observation` 하나의 `layer`.** 대응 디렉터리가 아직 없어 검사 14 가 닿지
   않는다.

## 24. 6차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 9이며 **판별선은 공리 감사의 대상을 회계층
다섯에서 선언 열다섯 전량으로 넓히는 것**이다. 용어집 넷과 정의층 여섯이 그물 밖에 있었고 그
사실이 `docs/baseline.md` §2 의 「미측정」 칸으로만 서 있었다.

### 24-1. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차가 바꾼 Lean 파일은 빌드 타깃 밖의 `Scratch/VerifyBuilt.lean`
하나뿐이라 빌드 계수가 움직이지 않았다.

### 24-2. 변경 내역

받은 커밋은 `ad99680` 이다. 카드마다 커밋을 갈랐다. `scripts/verify.sh` 를 `CD-05` 와 `CD-06`
둘이 두 구간에 걸쳐 만지므로, 한 커밋에 두 카드를 담으면 역순 되돌림이 성립하지 않기 때문이다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `08ec809` | CD-01 | 엔트리 카드 열여섯(`CF-277`~`CF-292`)을 `decisions.json` 에 병합 |
| `3b6e3a5` | CD-02 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |
| `a687631` | 없음 | `.gitignore` 가 파이썬 바이트코드를 잡고 추적에서 뺌 |
| `6c8511d` | CD-04 | 층별 프로브 넷과 선언 열의 공리 출력을 냄 |
| `264dd0c` | CD-05 | 층별 기준선을 값의 정본에 적고 공리 감사를 열다섯으로 넓힘 |
| `fdfb9b0` | 없음 | `docs/baseline.md` §2-1 에 용어집의 두 프로브가 같은 값을 내는 사유를 적음 |
| `e87330b` | CD-06 | `verify.sh` 가 자기 출력의 정규화 해시를 냄 |

`CD-03` 은 커밋을 세우지 않았다. 24-9 가 그 경위를 든다.

### 24-3. 원장

계수는 `check_wiki.py` 의 출력에서 읽었고 손으로 세지 않았다.

```
레지스터 entry: decisions 236 · deferred 33 · retirements 23 · rejected 0 · 총계 292
```

병합은 한 차례이고 `decisions` 만 늘었다. 카드의 나머지 세 레지스터가 빈 배열이라 그 세 파일을
열지 않았다. 총계 276 이 292 로 늘었고 늘린 것이 그 열여섯이다.

**등가 검증은 카드 파일 삭제보다 앞에서 돌았다.** 계수나 차분으로 갈음하지 않고 양쪽 entry 를
같은 매개변수로 직렬화해 바이트열로 열여섯 번 견주었다. 불일치 0 이고, id 배열이 순서까지 같으며,
병합 전 220건이 `ad99680` 판과 바이트로 같고, 레지스터를 통째로 잰 sha256 이 양쪽 다
`3a8d0ae1782ea37ea3d95ff1450dbecd57d8227705299c31d3330528c39b74ee` 다.

### 24-4. 공리 감사의 확대

**이 회차의 판별선이며 충족됐다.** 감사 대상이 다섯에서 열다섯으로 넓어졌다. 계수는 검증기의
보고 줄에서 읽었다.

```
공리 감사 대상 선언 15 (회계층 5 · 용어집 4 · 정의층 6)
```

| 시점 | 감사 대상 | 무엇이 움직였나 |
|---|---|---|
| 시작 | 5 | 회계층만 본다 |
| CD-04 뒤 | 5 | 출력을 열넷 더 냈으나 차분하지 않는다 |
| CD-05 뒤 | **15** | 용어집 넷과 정의층 여섯을 각 층의 기준선과 차분한다 |

`CD-04` 가 출력을 내고 `CD-05` 가 차분을 거는 것으로 카드를 가른 이유는, 차분을 걸기 전에
층별 선언의 출력이 그 층의 실효 프로브를 넘는지를 먼저 보아야 했기 때문이다. 넘으면 그 자리에서
멈추고 유입원의 분류를 결정 세션이 받는 갈래가 서 있었다.

### 24-5. 층별 기준선

용어집과 정의층은 이 회차에 처음 재어졌다. 그 전에는 재어진 적이 없었으므로 무엇이 나올지
정해져 있지 않았고, **재는 것 자체가 이 회차의 산출이다.**

| 층 | 최소 프로브 | 실효 프로브 | 실측 기준선 |
|---|---|---|---|
| 회계층 | `baselineProbe` `[]` | `baselineProbeSum` | `[propext, Quot.sound]` |
| 용어집 | `glossaryProbe` `[]` | `glossaryProbeList` | `[]` |
| 정의층 | `definitionProbe` `[]` | `definitionProbeFamily` | `[propext, Quot.sound]` |

선언 열다섯의 차분 결과다. **층을 넘은 선언이 0 이고 초과 공리 토큰이 0 개다.**

| 층 | 선언 | 기준선과 동일 | 기준선 이하 | 초과 |
|---|---|---|---|---|
| 회계층 | 5 | 4 | 1 | 0 |
| 용어집 | 4 | 4 | 0 | 0 |
| 정의층 | 6 | 2 | 4 | 0 |

**용어집에서는 최소 프로브와 실효 프로브가 같은 값을 냈다.** `List` 라는 용기가 공리를 하나도
더하지 않기 때문이다. 정의층은 `Finset` 이 `[propext, Quot.sound]` 를 더해 두 프로브가 갈린다.
`fdfb9b0` 이 그 사유를 `docs/baseline.md` §2-1 에 적었다.

정의층 선언 여섯 가운데 넷이 무의존이라 「기준선 이하」로 선다. 차분을 부분집합 대조로 구현한
덕에 그 넷이 통과하며, 정확한 상등 대조로 구현했으면 거짓 실패가 났을 자리다.

### 24-6. 정규화 해시

`verify.sh` 가 출력의 마지막 줄에 `OUTPUT_DIGEST=<sha256 의 앞 열두 자>` 를 낸다. 그 줄 자신은
해시의 입력에서 뺐다. 착지 상태의 값은 `c7d2ae33b42d` 다.

정규화가 지우는 것은 넷이며 터미널 색 코드와 절대 경로와 소요 시간 표기와 빌드 진행 표시다.
같은 환경의 두 판에서 실제로 움직이는 것은 뒤의 둘이고 앞의 둘은 환경이 다를 때 움직인다.

**같은 상태에서 두 번 돌린 값이 같았고 그때 출력 원문은 같지 않았다.** 다른 줄이 빌드 진행
표시와 소요 시간 표기뿐이었다. 원문이 같아서 값이 같았던 것이 아니라 정규화가 그 변동을
흡수했다는 뜻이며, 이 설비의 근거가 실측으로 섰다.

종료 코드를 이 값으로 가르지 않는다. 음성 대조에서 검사가 실패했을 때 값이 `dc71e033df5b` 로
달라졌고 종료 코드 1 이 그대로 나갔다.

### 24-7. 변이 검사

다섯 진술을 검사했고 전부 거부됐다.

```
L149 변이 거부됨 (1 error) — 실검사 확인
L166 변이 거부됨 (1 error) — 실검사 확인
L184 변이 거부됨 (1 error) — 실검사 확인
L192 변이 거부됨 (1 error) — 실검사 확인
L200 변이 거부됨 (1 error) — 실검사 확인
```

### 24-8. 음성 대조

이 회차가 세운 검사는 층별 차분이다. 주입 넷을 걸었고 넷 다 잡혔다.

| 주입 | 잡은 줄 | 종료 코드 |
|---|---|---|
| `DEFINITION` 을 `[]` 로 좁힌다 | 정의층 기준선 불일치와 `NodeFamily` · `NodeFamily.empty` 의 초과 | 1 |
| `GLOSSARY` 키를 지운다 | `GLOSSARY 를 읽지 못함` | 1 |
| 요약 줄을 고친 뒤 같은 주입을 되건다 | 같은 줄에 더해 요약이 `용어집 0` 으로 선다 | 1 |
| `GLOSSARY=[]` 를 `GLOSSARY=` 로 값만 비운다 | `GLOSSARY 를 읽지 못함` | 1 |

첫 주입에서 무의존인 정의층 선언 넷은 걸리지 않았다. 부분집합 대조가 기준선 이하를 통과시키는
것이 그 자리에서 확인됐다. 넷째 주입은 값의 정본이 「빈 값을 두면 검사가 그것을 기준선으로
읽는다」로 경계한 자리이며, 키 삭제와 다른 조건인데도 같은 줄로 걸린다.

주입 뒤에는 매번 원본을 되살려 md5 가 돌아오는 것을 확인했다.

### 24-9. 지시서 밖 조작 셋

지시서가 들지 않는 자리이고 사용자 지시가 그것을 메웠다. 셋 다 대상 지점이 지시서 §2 의 카드
표에 없으므로 카드 번호를 붙이지 않았다.

| 조작 | 커밋 | 사유 |
|---|---|---|
| `.gitignore` 가 파이썬 바이트코드를 잡게 함 | `a687631` | 검증기 실행의 산출물이 추적에 들어가 있었다 |
| `scripts/__pycache__` 를 추적에서 뺌 | `a687631` | 디스크의 파일은 지우지 않았다 |
| `docs/baseline.md` §2-1 에 문단을 이음 | `fdfb9b0` | 용어집에서 두 프로브가 같은 값을 내는 사유를 적었다 |

`CD-03` 은 조작 없이 닫혔다. 아크 레지스터의 네 번째 패치가 이 회차의 집행보다 앞서 커밋
`c0ca25f` 에 담겨 있었고, 그 객체가 지시서 §7-1 의 원천과 바이트로 같음을 확인했다. 등가 검증의
두 값인 `patches` 넷과 검사 4-a 의 `move·split 패치 4건` 이 충족돼 있었으므로 커밋을 세우지
않았다.

### 24-10. 전달 상태의 어긋남

**시작 전 대조에서 지시서 §10 이 한 자리 어긋났고 작업을 시작하지 않고 보고했다.**
`docs/arcs.json` 의 md5 가 `47b063539f896bc448c498db4b9faeef` (5385 바이트)로 §10 의
`add48f8db47bdcd053ca9d3c6e3046e5` (4368 바이트)와 달랐다. 나머지 일곱 파일은 같았다.

받은 커밋 `ad99680` 에 든 판은 §10 과 같았고 어긋남은 커밋되지 않은 작업 트리에 있었다. 그
변경이 지시서 §7-1 의 패치 객체를 잇는 것 하나뿐임을 파싱해 확인했다. 운영자가 그것을 커밋
`c0ca25f` 로 올린 뒤에 작업을 재개했다.

**이 어긋남이 `CD-03` 의 처분을 낳았다.** 구간 3 의 카드 하나가 집행보다 앞서 서 있었고, 그
처분은 결정 세션이 정했다.

### 24-11. CI 러너

| 실행 id | 커밋 | 결론 |
|---|---|---|
| `35492901810` | `c0ca25f` | success |
| `35493232931` | `08ec809` | success |
| `35493439605` | `3b6e3a5` | success |
| `35493961977` | `264dd0c` | success |
| `35494173607` | `e87330b` | success |

`a687631` 과 `6c8511d` 는 `264dd0c` 와 같은 push 에 묶였고 `fdfb9b0` 은 `e87330b` 와 같은 push 에
묶여 단독 실행을 받지 않았다.

**실패가 하나도 없다.** 지시서 §3 이 이 페이즈에 의도적 실패 구간이 없다고 들었고 그대로 섰다.

## 25. 해석 (관측값 아님)

- **출력을 내는 카드와 차분을 거는 카드를 가른 설계가 값을 냈다.** `CD-04` 가 층별 출력만 내고
  멈추었기 때문에, 초과분이 있었다면 그것이 차분 코드의 결함인지 실제 의존인지 섞이지 않은
  채로 결정 세션에 올라갔을 것이다. 초과분이 0 으로 나온 지금도 그 구별은 유지된다.
- **초과분 0 은 기대의 충족이 아니라 이번에 얻은 관측이다.** 이 층들은 한 번도 재어진 적이
  없었으므로 값이 정해져 있지 않았다. 「미측정」이 「초과 없음」으로 바뀐 것이 산출이며, 그
  둘은 문면상 구별되지만 그 전에는 구별할 근거가 없었다.
- **정규화 해시의 근거가 첫 실행에서 실측으로 섰다.** 같은 상태의 두 판이 원문에서 갈리고
  해시에서 갈리지 않았다. 판 사이 대조를 원문 없이 기계로 세우는 것이 이 설비의 목적이며, 두
  판이 원문까지 같았다면 그 목적이 확인되지 않았을 것이다.
- **음성 대조가 검사가 아니라 보고 문면의 결손을 잡은 자리가 났다.** 요약 줄의 내역을
  하드코딩해 두어서 층 하나가 일찍 빠질 때 계수와 내역이 갈렸다. 검사의 판정은 옳았고 그것을
  적는 줄이 틀렸다. 주입 없이는 드러나지 않는 종류다.
- **전달 상태가 명세와 갈리는 형이 처음 났다.** 앞 회차들의 어긋남은 명세 안에 있었으나 이번
  것은 커밋되지 않은 작업 트리에 있었다. §10 이 파일의 검증값을 들었기 때문에 잡혔고, 커밋만
  대조했으면 지나갔을 자리다.

## 26. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 이 회차는 `theorem` 을 하나도 세우지 않았고 기존 진술을 건드리지 않았다. 세운 `def`
넷은 빌드 타깃 밖의 스크래치에 서고 진술은 지시서 §7-2 가 들었다. **컴파일이 확인되지 않은
문면이었으나 구문 오류가 나지 않았다.**

## 27. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **4단계의 대조 형이 둘로 갈려 있다.** 회계층이 상등 대조이고 용어집과 정의층이 부분집합
   대조다. 부분집합이 옳으나 정규화 해시를 세우는 구간에서 출력 문면을 바꾸면 첫 해시가 곧바로
   낡으므로 옮기지 않았다. 그 통일은 뒤 아크가 받는다.
2. **`OUTPUT_DIGEST` 가 `verify.sh` 자신의 판을 담지 않는다.** 스크립트를 고쳐도 출력이 같으면
   값이 같게 나온다. 스크립트의 판까지 앵커에 담을지는 정해져 있지 않다.
3. **`docs/baseline.md` §2 의 미측정 층이 넷에서 둘로 줄었다.** 남은 것은 관측층과 동학층이며
   그 층의 파일이 아직 없다.
4. **검사 16 이 `artifact` 발화 여섯을 계속 보고한다.** 앞 회차와 같은 자리이고 발화 탐지를 읽는
   쪽이 없다.
5. **`BUILD_LOG.md` 의 미실재 토큰이 이 절로 더 늘었다.** 이 파일이 검사 24 의 유니버스 밖이라
   잡히지 않는다. 카드 번호인지 규율 지목인지 판별이 남아 있다.

## 28. 7차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 10이며 **판별선은 아크를 닫는 것**이었다.
**아크 종료가 한 번 성립했다가 되돌려졌다.** 종료의 기술적 조건은 전부 충족됐고 물린 사유는
검사가 잡을 수 없는 것이었다.

### 28-1. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차는 Lean 파일을 하나도 건드리지 않았다.

### 28-2. 변경 내역

받은 커밋은 `27a4714` 다. 카드마다 커밋을 갈랐다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `ccade60` | CD-01 | 엔트리 카드 마흔일곱(`CF-293`~`CF-339`)을 `decisions.json` 에 병합 |
| `b4d0e5f` | CD-02 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |
| `f84071a` | CD-03 | 검사 5 의 판별을 날짜로 고치고 양방향 음성 대조를 검 |
| `05c2b2c` | 없음 | 음성 대조의 모듈 문면에서 검사 수 표기를 실물에 맞춤 |
| `83fe992` | CD-04 | 아크를 닫고 종료 검사 둘을 처음 돌림 |
| `2fe3ab6` | 없음 | `83fe992` 를 되돌림 |

### 28-3. 원장

계수는 `check_wiki.py` 의 출력에서 읽었고 손으로 세지 않았다.

```
레지스터 entry: decisions 283 · deferred 33 · retirements 23 · rejected 0 · 총계 339
```

총계 292 가 339 로 늘었고 늘린 것이 그 마흔일곱이다. 등가 검증은 카드 파일 삭제보다 앞에서
돌았고 차분으로 갈음하지 않았다. 레지스터를 통째로 잰 sha256 이 양쪽 다
`f89c126e899ba9983d1bad61e56113eda443df951ffe5355dc03089eeb724e07` 다.

**적재의 성격이 앞 회차들과 달랐다.** 마흔일곱 가운데 서른둘이 세션 지시 §5 의 조항이며 이미 선
것을 원장으로 옮기는 전사였다.

### 28-4. 검사 5 의 고침

검사 5 는 「`status: closed` 인 아크에 항목이 드는가」를 보는데, 닫힌 아크를 가리키는 항목을
전부 잡고 있었다. 아크를 닫는 순간 원장 전량이 걸리는 자리였다. **「새 항목」을 날짜로 가르도록
고쳤다.** 닫힌 아크의 항목 가운데 `origin.date` 가 그 아크의 `closed` 보다 뒤인 것만 잡는다.
같은 날의 항목은 빠져나가며 스키마의 입도가 날짜이므로 그 한계는 그대로 남는다.

**기존 주입이 고친 뒤에 잡지 못했다.** 고치기 전에 먼저 쟀고 읽은 줄이
「`wiki5-closed-arc#1: 새 위반 줄 없음`」이며 주입 항 스물일곱 가운데 스물여섯을 잡았다.
**검사의 결함이 아니라 주입이 조건을 만들지 못한 것이다.** 기존 주입이 아크와 페이즈만 옮기고
날짜를 두었는데, `CF-24` 의 날짜가 2026-09-19 이고 `primary` 아크의 `closed` 도 2026-09-19 이라
같은 날이 빠져나가는 자리에 정확히 걸렸다.

주입이 닫힌 아크의 `closed` 를 읽어 그보다 하루 뒤의 날짜를 만들게 고쳤다. 날짜를 코드에 박지
않고 아크에서 읽으므로 `closed` 가 바뀌어도 낡지 않는다.

**반대 방향을 더했다.** 닫힌 날보다 하루 앞의 날짜로 같은 항목을 쓰고 잡히지 않아야 통과다.
앞 방향만 재면 「날짜를 보지 않고 여전히 전량을 잡는다」와 갈리지 않는다.

```
| `wiki5-closed-arc#1` | 5 | 닫힌 날 뒤의 날짜로 항목을 쓴다 | OK | FAIL | 예 |
| `wiki5-closed-arc#2` | 5 | 닫힌 날 앞의 날짜로 항목을 쓴다 | OK | OK | 예 |

wiki5-closed-arc#1: CF-24: 닫힌 아크 `primary` 에 닫힌 날(2026-09-19) 뒤의 항목이 쓰였다 — 2026-09-20
wiki5-closed-arc#2: 잡히지 않았다 (기대대로)

주입 항 28개 가운데 기대대로인 것 28개, 어긋난 것 0개
```

주입은 사본에서만 했고 원장을 건드리지 않았다. 음성 대조의 판정 기준에 셋째(잡히지 않아야 하는
항)를 더했고 모듈 docstring 이 그것을 든다.

### 28-5. 아크 종료와 종료 검사 둘

`docs/arcs.json` 의 `charter` 레코드에서 `status` 를 `closed` 로, `closed` 를 `2026-09-20` 으로
두었다. `phases` 와 `patches` 와 `holes` 와 `cq` 는 그대로이고 다른 아크 셋도 움직이지 않았다.

**`python3 scripts/check_wiki.py --arc-close charter` 의 출력 전문이다.** 종료 코드는 0 이다.
`verify.sh` 와 CI 가 `--arc-close` 를 주지 않으므로 종료 검사 둘은 그 판에서 돌지 않으며,
**되돌림 뒤에는 리포의 어느 상태도 이 출력을 담지 않으므로 이 절이 유일한 자리다.**

```
원장 검증기 — 뿌리 /root/workspace/crisis_framework
레지스터 entry: decisions 283 · deferred 33 · retirements 23 · rejected 0 · 총계 339

[check:wiki1-id-unique] OK  검사 1 — id 가 CF-<n> 형식이고 전 파일에서 유일한가
    - id 339건
[check:wiki2-origin-arc] OK  검사 2 — origin.arc 가 arcs.json 의 아크 이름에 실재하는가
[check:wiki3-origin-phase] OK  검사 3 — origin.phase 가 그 아크의 phases 에 있거나, 없으면 patches 가 권한을 주는가
    - 패치가 권한을 준 항목 0건
[check:wiki3a-phase-form] OK  검사 3-a — origin.phase 가 origin.arc + "-" + <n> 형태인가
[check:wiki4a-patch-from] OK  검사 4-a — op 가 move·split 인 패치의 from 이 그 아크의 phases 에 있는가
    - move·split 패치 4건
[check:wiki5-closed-arc] OK  검사 5 — status: closed 인 아크에 새 항목이 드는가
    - 닫힌 아크를 가리키는 항목 339건
[check:wiki6-tier-vocab] OK  검사 6 — tier 가 invariant·policy·finding 중 하나인가
[check:wiki7-invariant-check] OK  검사 7 — tier: invariant 인 항목의 check 가 verify.sh 의 선언된 단계에 실재하는가
    - verify.sh 가 선언한 단계 id: ['step1-duplicate', 'step2-build', 'step3-forbidden', 'step4-baseline', 'step5-mutation', 'step6-ledger']
[check:wiki8-retire-target] OK  검사 8 — 폐기 레코드의 target 이 실재하고 한 대상에 폐기가 둘 이상이 아닌가
[check:wiki9-retire-reason] OK  검사 9 — 폐기 레코드에 original 과 reason 이 비어 있지 않은가
[check:wiki10-ghost-ref] OK  검사 10 — 폐기된 id 를 살아 있는 것처럼 참조하는 자리가 있는가
    - 폐기된 id 23건을 유니버스로 훑었다
[check:wiki11-reopen-kind] OK  검사 11 — deferred 항목에 reopen_when 이 있고 kind 가 넷 중 하나인가
[check:wiki12-reopen-ref] OK  검사 12 — reopen_when.ref 가 kind 별 형식을 만족하는가
[check:wiki13-dd-target] OK  검사 13 — Lean 줄 주석의 DD: 표지가 실재하고 폐기되지 않은 id 를 가리키는가
    - DD: 표지 15개
[check:wiki14-dd-layer] OK  검사 14 — DD: 항목의 layer 가 그 파일이 사는 층과 같은가
    - meta 가 아닌 표지 4개를 봤다
[check:wiki15-names-unique] OK  검사 15 — names 의 규율 ID 가 원장 전체에서 유일한가
    - 규율 ID 222건
[check:wiki23-rule-ghost] OK  검사 23 — statement·basis 의 규율 ID 토큰이 어느 항목의 names 에 실재하고, 폐기됐으면 그 폐기 레코드를 related 가 드는가
    - 규율 ID 토큰 122건을 봤다. 계열은 ['PH-R', 'P', 'A', 'C', 'L', 'D', 'T', 'R', 'N', 'V', 'W', 'Q', 'B', 'O', 'G', 'S', 'F', 'J', 'K']
    - 폐기 레코드는 유니버스 밖이다. 첫 적재(charter-6)의 related 면제 21건
[check:wiki24-doc-rule-ghost] OK  검사 24 — 상주 문서와 Lean 주석의 규율 ID 토큰이 실재하고, 폐기됐으면 그 문서가 선언했는가
    - 규율 ID 토큰 205건. 미실재 0 · 선언 없는 폐기 지목 0 · 선언으로 면제된 폐기 지목 18
    - 유니버스: 상주 문서 6 · Lean 3. 유니버스 밖: ['BUILD_LOG.md', 'docs/phases/', 'docs/extractions/', 'docs/arcs.json 의 patches 배열']
[check:wiki25-marker-missing] OK  검사 25 — Lean 의 최상위 def·theorem·inductive·structure 선언마다 DD: 표지가 붙었는가
    - 최상위 선언 15 · 표지 15 · 누락 0
    - example 은 정의도 정리도 아니므로 대상이 아니다(SPEC §2.1)
[check:wiki16-trigger-fired] REPORT  검사 16 — reopen_when 이 충족된 이연 항목
    - 발화한 트리거 6건
    - CF-153 (artifact) — 경로 `CrisisFramework/Glossary/Core.lean` 가 실재한다
    - CF-159 (artifact) — 경로 `CrisisFramework/Glossary/Core.lean` 가 실재한다
    - CF-176 (artifact) — 경로 `CrisisFramework/Glossary/Core.lean` 가 실재한다
    - CF-177 (artifact) — 경로 `CrisisFramework/Glossary/Core.lean` 가 실재한다
    - CF-193 (artifact) — 경로 `CrisisFramework/Glossary/Core.lean` 가 실재한다
    - CF-194 (artifact) — 경로 `CrisisFramework/Glossary/Core.lean` 가 실재한다
[check:wiki17-reopen-null] REPORT  검사 17 — reopen_when: null 인 항의 계수
    - reopen_when: null 5건
    - CF-18 — names ['K-12']
    - CF-165 — names ['H-12']
    - CF-169 — names ['H-16']
    - CF-183 — names ['H-30']
    - CF-216 — names ['H-63']
[check:wiki18-blocking-disposition] REPORT  검사 18 — 아크별 blocking 구멍의 처분 내역
    - blocking 구멍 0건, 아크 0개
[check:wiki19-id-gap] REPORT  검사 19 — CF-<n> 번호의 결번
    - CF-1~CF-339, 계수 339, 결번 0건
[check:wiki20-arc-holes] OK  검사 20 — 그 아크에 걸린 구멍마다 해소됐거나 이관됐는가
    - 아크 `charter` 의 구멍 0건
[check:wiki21-arc-blocking] OK  검사 21 — 그 아크에 걸린 blocking 구멍마다 발화했거나 해소됐거나 이월됐는가
    - 아크 `charter` 의 blocking 구멍 0건

검사 25개 가운데 25개 수행, 실패 0개
원장 검증 전량 통과
```

**이 프로젝트에서 검사 전량이 수행된 것이 처음이고 종료 검사 둘이 처음 돌았다.**

검사 5 의 두 값을 갈라 적는다. **대상이 0건에서 339건으로 늘었고 그 가운데 걸린 것이 0건이다.**
앞이 아크가 실제로 닫혔음을 들고 뒤가 날짜 판별이 값을 냈음을 든다. 날짜로 가르지 않았으면 그
339건이 전부 걸려 이 커밋이 원장 전량으로 실패했을 것이다.

`verify.sh` 의 판은 25개 가운데 23개 수행이다. 두 판의 수행 수가 갈리는 것이 정상이다.

### 28-6. 되돌림

`83fe992` 를 `git revert` 했다. `docs/arcs.json` 의 md5 가
`47b063539f896bc448c498db4b9faeef` · 5385 바이트로 돌아왔고 `charter` 가 `status: "open"` 과
`closed: null` 로 돌아갔다. 검사 5 의 대상 계수가 339건에서 0건으로 돌아갔다.

**사유는 아크의 마지막 페이즈가 새 낙착을 낳지 않아야 한다는 요건이다.** 이 페이즈가 집행 중에
미전사분을 둘 낳았는데 그것을 세지 않고 닫았다. 닫힌 아크가 원장에 실리지 않은 낙착을 남기면
그 종료가 무의미하다.

**`05c2b2c` 와 `f84071a` 는 물리지 않았다.** 되돌림이 아크의 상태만 물리고 검사 설비와 그 실측을
남겼다. `CD-03` 이 `CD-04` 보다 앞선 구간에 놓여 카드마다 커밋을 가른 덕이며, 두 카드를 한
커밋에 담았다면 되돌림이 검사 5 의 고침까지 물렸을 것이다.

### 28-7. 해시

| 시점 | `OUTPUT_DIGEST` |
|---|---|
| CD-01 · CD-02 | `437d975939aa` |
| CD-03 | `2d95e696b05c` |
| CD-04 (아크 종료) | `a9e7e1e83b68` |
| 되돌림 뒤 | `2d95e696b05c` |

아크 종료가 값을 움직인 자리에서 달라진 검사 줄이 하나뿐이며, 검사 5 의 대상 계수가 0건에서
339건으로 바뀐 것이다.

### 28-8. CI 러너

| 실행 id | 커밋 | 결론 |
|---|---|---|
| `35493232931` | `ccade60` | success |
| `35493439605` | `b4d0e5f` | success |
| `35493961977` | `264dd0c` (앞 회차 마지막) | success |
| `35494173607` | `e87330b` (앞 회차) | success |
| `35494339637` | `27a4714` (앞 회차) | success |

이 회차의 뒤쪽 커밋들은 같은 push 에 묶이거나 되돌림과 함께 올라가 단독 실행을 받지 않았다.

---

## 29. 8차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 11이며 **판별선은 미전사분 아홉을 원장에
싣는 것**이다. **이 회차는 아크를 닫지 않는다.**

### 29-1. 지시서가 두 번 재발행됐다

**그 경위가 리포 안에 남는 자리가 이 절뿐이다.**

| 판 | 집행이 잡은 것 | 재발행이 반영한 것 |
|---|---|---|
| 초판 | 시작 전 대조에서 §10 의 `docs/arcs.json` 이 어긋났다. 운영자의 커밋이 `CD-01` 을 통째로 앞질러 그 카드에 남은 조작이 없었다 | `CD-01` 을 확인 카드로 바꾸고 §10 의 검증값을 현행 HEAD 로 다시 냄 |
| 1차 재발행 | 구간 1 을 완주해 보고하면서 계수가 여덟 자리에서 갈린 것을 잡았다. 카드가 여덟 항으로 자랐는데 대장의 지시문과 등가 검증이 일곱·290·346 으로 남아 있었다 | 계수를 카드 파일에서 유도하게 고치고 카드에 아홉째 항을 더함 |
| 2차 재발행 | 갈림이 남지 않은 것을 확인하고 집행 | — |

**두 자리 다 되돌릴 수 없는 조작보다 앞에서 잡혔다.** 첫째를 잡지 않았으면 아크 레지스터에 같은
값이 두 벌 들어갔을 것이고, 둘째를 잡지 않았으면 병합이 그 문서가 든 등가 검증을 통과하지 못한
채로 섰을 것이다.

1차 재발행 판으로 구간 1 을 완주한 뒤 2차 재발행이 와서 같은 구간을 새 판으로 다시 수행했다.
**그 구간이 확인만 하고 조작을 낳지 않는 구간이라 재수행이 성립했다.**

### 29-2. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차도 Lean 파일을 건드리지 않았다.

### 29-3. 변경 내역

받은 커밋은 `c06f05c` 다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `09dee36` | CD-02 | 엔트리 카드 아홉(`CF-340`~`CF-348`)을 `decisions.json` 에 병합 |
| `9265a66` | CD-03 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |

`CD-01` 과 `CD-04` 는 조작도 커밋도 낳지 않았다. 앞은 운영자의 커밋이 앞질러 확인만 했고 뒤는
열거하고 멈추는 카드다.

### 29-4. 원장

```
레지스터 entry: decisions 292 · deferred 33 · retirements 23 · rejected 0 · 총계 348
```

총계 339 가 348 로 늘었고 늘린 것이 그 아홉이다. 레지스터를 통째로 잰 sha256 이 양쪽 다
`476d648c2598fe106ba60695d056247d17cd0bc45b39fdec8afa421275493681` 다.

**아홉 가운데 여덟이 앞 회차의 미전사분이고 아홉째가 이 회차의 계획을 바꾼 발견이다.** 세션 지시
§0·§2·§6·§7 의 조항이 원장 밖에 있다는 것이며, 특히 §6 이 통째로 빠져 이 프로젝트의 왕복 구조
전체가 그물 밖이다. 「정지점」이라는 낱말이 원장 전체에 한 번도 나오지 않는다.

### 29-5. 아크 레지스터의 확인

운영자의 커밋 `af4cda7` 이 `CD-01` 의 두 조작을 앞질러 세웠다. `phases` 가 열하나이고
`patches` 가 다섯이며, 더해진 값이 지시서 §7-1 과 키 순서까지 바이트로 같다. `CF-325` 가
「운영자의 커밋이 카드의 조작을 앞지르면 그 카드는 조작 없이 닫고 커밋을 세우지 않는다」를 들어
조작도 커밋도 세우지 않았다.

### 29-6. 미전사분의 열거

`CD-04` 가 이 회차의 새로운 자리이며 **조작도 커밋도 없이 열거하고 멈춘다.** 앞 회차에서 그
세기가 사람의 머릿속에만 있어 아크 종료가 물렸으므로 조작으로 세웠다.

| 구간 | 미전사분 |
|---|---|
| 1 | 0건 |
| 2 | 0건 |
| 3 | 0건 |
| 4 | 2건 |
| 합계 | **2건** |

남은 둘은 ① 미전사분이 0 이 될 때까지 페이즈를 잇는다는 종료 조건과 ② 지시서가 구간 집행 중에
재발행되면 이미 수행한 구간을 어떻게 하는가이다. 원장을 낱말로 훑어 부재를 확인했으며 `수렴` 과
`앞 판` 과 `앞서 받은` 이 전부 0건이다.

**계수가 0 이 아닌 것은 어긋남이 아니다.** 이 회차는 아크를 닫지 않으므로 그 값이 관문이 아니라
뒤 페이즈의 재료다.

### 29-7. 해시

| 시점 | `OUTPUT_DIGEST` |
|---|---|
| 구간 1 (CD-01) | `2d95e696b05c` |
| 구간 2 (CD-02) | `721bdc00a2ad` |
| 구간 3 (CD-03) | `721bdc00a2ad` |
| 구간 4 (CD-04) | `721bdc00a2ad` |

**값이 움직인 구간이 병합 하나다.** 그 자리에서 달라진 검사 줄이 셋이고 전부 원장 계수를 내는
줄이다. 레지스터 entry 줄과 검사 1 의 id 계수와 검사 19 의 결번 줄이며 그 밖의 줄은 움직이지
않았다.

---

## 30. 해석 (관측값 아님)

- **아크 종료가 성립했다가 물린 것 자체가 7차의 관측이다.** 종료의 기술적 조건은 전부
  충족됐다. 검사 25개 전량이 수행되고 실패가 0 이었으며 종료 검사 둘이 구멍 0 건과 blocking
  구멍 0 건을 냈다. 물린 사유는 「그 페이즈가 새 낙착을 낳지 않았는가」인데 **그것을 재는 검사가
  없다.** 검사 20 과 21 은 구멍의 처분을 보고 검사 5 는 닫힌 뒤에 쓰인 항목을 보며, 셋 다 닫는
  시점에 이미 원장에 있는 것만 본다.
- **「통과」와 「대상이 비어서 통과」가 갈리는 자리를 보고 줄이 만들었다.** 검사 5 를 고친 구간에서
  그 검사는 통과했으나 대상이 0 건이었다. 고침이 옳다는 증거가 아니었고, 대상 계수를 보고 줄로
  내게 한 덕에 그 둘이 보고서에서 갈렸다. 같은 `OK` 판정이 두 경우에 전혀 다른 것을 뜻한다.
- **주입이 조건을 만드는지를 먼저 재라는 조항이 또 값을 냈다.** 검사 5 를 고치자 기존 주입이
  공허해졌는데, 그것이 검사의 결함으로 읽힐 수 있는 자리였다. 고치기 전에 재고 사유를 캐서
  주입이 날짜를 옮기지 않는다는 것을 특정했다.
- **카드마다 커밋을 가른 것이 되돌림의 범위를 정했다.** 아크 종료만 물리고 검사 설비와 그 실측을
  남길 수 있었던 것이 그 덕이다. 한 커밋에 담았으면 고침까지 물렸을 것이다.
- **8차에서 집행이 잡은 둘은 전부 되돌릴 수 없는 조작보다 앞에 있었다.** 시작 전 대조와 구간 1 의
  보고가 그 자리이며, 둘 다 병합 전이라 지시서를 고칠 수 있었다. 정지점이 조작의 앞에 서 있다는
  것이 여기서 값을 냈다.
- **계수를 문서에 박으면 그 문서가 자랄 때 따라오지 않는다.** 1차 재발행 판이 카드 대장에 수를
  박아 두어 카드가 여덟으로 자랐는데 등가 검증이 일곱으로 남았다. 2차 재발행이 계수를 카드
  파일에서 유도하게 고쳤다.

---

## 31. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 두 회차 다 `theorem` 과 `def` 를 하나도 세우지 않았고 기존 진술을 건드리지 않았다.
Lean 파일의 변경이 0 건이다. **검증기와 CI 워크플로를 고쳐 통과시킨 자리가 하나도 없다.**

---

## 32. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **미전사분 둘이 남아 있다.** 29-6 이 그 둘을 든다. 뒤 페이즈가 받는다.
2. **아크 종료의 요건 가운데 「새 낙착을 낳지 않았는가」를 재는 검사가 없다.** `CF-344` 가 그
   발견을 들고 `CF-345` 가 처분을 드나, 그 처분이 조작이지 검사가 아니다.
3. **4단계의 대조 형이 둘로 갈려 있다.** 회계층이 상등 대조이고 용어집과 정의층이 부분집합
   대조다. 정규화 해시를 세운 회차에서 출력 문면을 바꾸지 않으려고 미뤘다.
4. **`OUTPUT_DIGEST` 가 `verify.sh` 자신의 판을 담지 않는다.** 스크립트를 고쳐도 출력이 같으면
   값이 같게 나온다.
5. **검사 16 이 `artifact` 발화 여섯을 계속 보고한다.** 앞 회차들과 같은 자리이고 읽는 쪽이 없다.
6. **`BUILD_LOG.md` 의 미실재 토큰이 이 두 절로 더 늘었다.** 이 파일이 검사 24 의 유니버스 밖이라
   잡히지 않는다.

## 33. 9차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 12이며 **판별선은 미전사분 다섯과 계획 변경
하나를 원장에 싣는 것**이다. **이 회차도 아크를 닫지 않는다.**

세션 지시 §0·§1·§2 의 조항 마흔둘 가운데 원장에 있는 것이 여섯 안팎이고 §6·§7 이 그보다 커서
합치면 백에 가깝다. 그 적재를 한 카드에 담으면 작성 도중의 재발행을 처분할 조항이 그 적재에
갇히므로 **작은 것을 먼저 싣는다.**

### 33-1. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차도 Lean 파일을 건드리지 않았다.

### 33-2. 변경 내역

받은 커밋은 `87190e0` 다. 카드마다 커밋을 갈랐다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `f0ebe6e` | CD-01 | 아크 레지스터에 열두 번째 페이즈와 여섯 번째 패치를 세움 |
| `58d87b7` | CD-02 | 엔트리 카드 여섯(`CF-349`~`CF-354`)을 `decisions.json` 에 병합 |
| `d114657` | CD-03 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |

`CD-04` 는 열거하고 멈추는 카드라 조작도 커밋도 낳지 않았다.

### 33-3. 원장

```
레지스터 entry: decisions 298 · deferred 33 · retirements 23 · rejected 0 · 총계 354
```

총계 348 이 354 로 늘었고 늘린 것이 그 여섯이다. 레지스터를 통째로 잰 sha256 이 양쪽 다
`222812dc5334677d157d593cc233704d2046e0570486388c20eb65579bdd598b` 다.

**여섯 가운데 다섯이 앞 페이즈의 미전사분이고 여섯째가 이 페이즈의 계획 변경이다.** 그 다섯
가운데 `CF-350` 이 지시서 재발행의 처분이며, 그것이 서지 않은 채로 백 항 규모의 적재를 하면 그
도중의 재발행을 처분할 조항이 그 적재에 갇힌다.

### 33-4. `CD-01` 의 갈래 — 세 번째 상태

**이 회차의 핵심 자리다.** 지시서가 `CD-01` 에 갈래를 두었고 두 팔이 「문면이 이미 같다」와
「문면이 다르다」였다. **실제 상태는 그 둘 사이였다.**

| 잰 것 | 값 |
|---|---|
| `phases` 끝 세 줄이 §7-1 (a) 와 같은가 | 예 |
| 여섯째 `patch` 가 §7-1 (b) 와 키 순서까지 같은가 | 예 |
| 앞의 열하나와 다섯이 보존됐는가 | 예 |
| **그 변경이 커밋돼 있는가** | **아니오** |

**문면은 이미 같았고 커밋되지 않은 작업 트리에 있었다.** 앞 두 페이즈는 운영자의 커밋이 카드를
앞질렀고 이번에는 커밋이 아니다.

`CF-325` 가 「운영자의 커밋이 카드의 조작을 앞지르면 조작 없이 닫는다」를 드는데 그 근거가
**「조작의 결과가 이미 추적 커밋에 서 있다」**는 것이다. 추적 커밋에 서 있지 않으므로 그 조항의
조건이 서지 않는다.

**집행이 커밋만 했다.** 문면을 잇는 일은 남지 않았고 커밋하는 일이 남았다. 커밋하지 않고 닫으면
그 변경이 작업 트리에 남아 다음 카드의 커밋에 딸려 들어가는데, 다음 카드가 되돌릴 수 없는
병합이므로 카드마다 커밋을 가르는 형이 거기서 깨진다.

**같은 형에 두 번 다른 처분이 나왔다.** charter-9 에서 같은 상태가 났을 때 집행이 멈춰 보고했고
운영자가 커밋한 뒤에 재개했다. 이번에는 지시서가 「멈추지 말라」를 들어 집행이 커밋했다.

| 페이즈 | 상태 | 처분 |
|---|---|---|
| charter-9 | 아크 레지스터의 변경이 미커밋 | 멈추고 운영자의 커밋을 받음 |
| charter-12 | 같음 | 집행이 커밋함 |

**그 처분을 드는 조항이 원장에 없다.** §9-3 의 구간 1 기대가 「갈래를 탔으면 조작 0건 · 커밋
0건」인데 실측이 조작 0건 · 커밋 1건이며, 그 어긋남을 조정하지 않고 그대로 실었다.

### 33-5. 미전사분의 열거

`CD-04` 가 조작도 커밋도 없이 열거하고 멈춘다.

| 구간 | 미전사분 |
|---|---|
| 1 | 1건 |
| 2 | 0건 |
| 3 | 0건 |
| 4 | 0건 |
| 합계 (집행의 몫) | **1건** |

남는 하나가 33-4 의 자리이며 **운영자의 변경이 커밋되지 않은 작업 트리에 놓였을 때의 처분**이다.
정해져 있지 않은 팔이 셋이고, ⓐ 집행이 커밋한다 ⓑ 멈추고 운영자에게 커밋을 받는다 ⓒ 문면만
확인하고 닫아 다음 커밋에 딸려 보낸다 이다.

**낱말 훑기의 적중을 실물로 걸러 판정했다.** `작업 트리` 와 `추적 커밋` 과 `운영자` 가 낱말로는
적중했으나 다섯 항목 전부가 다른 조건을 걸고 있었다. `CF-352` 가 이 회차의 병합으로 원장에 섰고
그 조항이 요구하는 전량 열람이 같은 회차에서 곧바로 값을 냈다.

**`CF-277` 의 `basis` 가 집행의 근거와 같은 문장을 든다.** 「미루면 그 조작이 작업 트리에 남아 뒤
카드의 커밋에 휩쓸리고 카드마다 커밋을 가르는 형이 더 크게 깨진다」이며, 그 항목의 `statement` 가
걸리는 조건이 「지시서가 검증 실패를 기대로 두는 구간」 하나로 좁혀져 있다. **같은 논증이 더 넓은
조건에서도 성립한다는 것이 이 자리에서 드러났다.**

**이 계수는 집행이 본 것의 전부다.** `CF-353` 이 드는 대로 결정 세션의 작업은 집행이 볼 수 없으므로
그쪽이 따로 세어 합친다. 결정 세션이 둘을 더해 이 회차의 미전사분은 셋이다.

### 33-6. 해시

| 시점 | `OUTPUT_DIGEST` |
|---|---|
| 구간 1 (CD-01) | `721bdc00a2ad` |
| 구간 2 (CD-02) | `3f85997324c0` |
| 구간 3 (CD-03) | `3f85997324c0` |
| 구간 4 (CD-04) | `3f85997324c0` |

**값이 움직인 구간이 병합 하나다.** 그 자리에서 달라진 검사 줄이 셋이고 전부 원장 계수를 내는
줄이다. 레지스터 entry 줄과 검사 1 의 id 계수와 검사 19 의 결번 줄이며 그 밖의 줄은 움직이지
않았다.

### 33-7. 불변 축

| 축 | 값 |
|---|---|
| 검사 23 의 토큰 | 122건 |
| 검사 24 의 토큰 | 205건. 미실재 0 · 선언 없는 폐기 지목 0 · 면제 18 |
| 검사 25 | 최상위 선언 15 · 표지 15 · 누락 0 |
| 공리 감사 대상 | 선언 15 (회계층 5 · 용어집 4 · 정의층 6) |
| 변이 검사 | 다섯 전부 거부 |
| 아크의 상태 | `open` |

병합한 여섯이 규율 ID 토큰을 하나도 더하지 않았다.

---

## 34. 해석 (관측값 아님)

- **갈래가 둘로 갈렸는데 실제 상태가 셋이었다.** 지시서가 「같다」와 「다르다」를 물었으나 실제로
  갈려야 할 축이 둘이었다. 문면이 같은가와 그것이 커밋됐는가이며, 앞 두 페이즈에서는 그 둘이 함께
  움직여 한 축으로 보였다. **조항의 근거가 그 둘을 이미 갈라 놓고 있었다.** `CF-325` 가 커밋을
  조건으로 들고 근거에서 추적 커밋을 명시했으므로, 조항을 읽으면 세 번째 상태가 그 밖임을 알 수
  있다.
- **같은 형에 두 번 다른 처분이 나온 것이 그 자리를 세울 이유다.** charter-9 의 ⓑ 와 이번의 ⓐ 가
  둘 다 그 시점의 지시에 맞았다. 조항이 없으면 다음에 또 갈리며, 갈리는 것 자체보다 **무엇을 근거로
  갈렸는지가 기록되지 않는 것**이 문제다.
- **낱말 훑기의 거짓 양성을 경계하는 조항이 선 회차에 곧바로 값을 냈다.** `CF-352` 가 이 회차의
  병합으로 섰고, 같은 회차의 `CD-04` 가 낱말로 다섯을 적중시켰으나 실물을 열자 전부 다른 조건이었다.
  적중 수만 보았으면 그 자리가 이미 덮인 것으로 읽혔을 것이다.
- **작은 것을 먼저 싣는 설계가 이 회차에서 검증됐다.** `CF-350` 이 재발행의 처분을 드는데 그것이
  이번 병합으로 섰다. 백 항 규모의 적재를 먼저 했다면 그 작성 도중에 재발행이 와도 처분할 조항이
  그 적재 안에 갇혀 있었을 것이다.

---

## 35. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 이 회차는 `theorem` 과 `def` 를 하나도 세우지 않았고 Lean 파일의 변경이 0 건이다.
**검증기와 CI 워크플로를 고쳐 통과시킨 자리가 없다.**

---

## 36. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **운영자의 변경이 커밋되지 않은 작업 트리에 놓였을 때의 처분이 원장에 없다.** 33-4 와 33-5 가
   그 자리를 든다. 세 팔 가운데 무엇을 세울지와, `CF-277` 의 조건을 넓힐지 새 항목을 세울지가
   남아 있다. 원장이 수정 불가이므로 넓히려면 폐기와 재발행이 필요하다.
2. **세션 지시 §0·§1·§2·§6·§7 의 적재가 남아 있다.** 백에 가까우며 뒤 페이즈가 받는다.
3. **아크 종료의 요건 가운데 「새 낙착을 낳지 않았는가」를 재는 검사가 없다.** `CF-344` 가 발견을
   들고 `CF-345` 가 처분을 드나 그 처분이 조작이지 검사가 아니다.
4. **4단계의 대조 형이 둘로 갈려 있다.** 회계층이 상등 대조이고 용어집과 정의층이 부분집합 대조다.
5. **`OUTPUT_DIGEST` 가 `verify.sh` 자신의 판을 담지 않는다.**
6. **검사 16 이 `artifact` 발화 여섯을 계속 보고한다.** 앞 회차들과 같은 자리이고 읽는 쪽이 없다.

## 37. 10차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 13이며 **판별선은 세션 지시 §0 과 §2 의 조항
스물여덟과 앞 페이즈의 미전사분 셋을 원장에 싣는 것**이다. **이 회차도 아크를 닫지 않는다.**

**적재의 성격이 앞 페이즈들과 다르다.** 스물여덟은 새 낙착이 아니라 **이미 선 조항을 원장으로
옮기는 전사**다. 세션 지시의 문면이 정본이고 원장이 그것이 선 경위를 든다.

### 37-1. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차도 Lean 파일을 건드리지 않았다.

### 37-2. 변경 내역

받은 커밋은 `834a68a` 다. 카드마다 커밋을 갈랐다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `f0e23db` | CD-01 | 아크 레지스터에 열세 번째 페이즈와 일곱 번째 패치를 세움 |
| `492c8df` | CD-02 | 엔트리 카드 서른둘(`CF-355`~`CF-386`)을 `decisions.json` 에 병합 |
| `3cbf825` | CD-03 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |

`CD-04` 는 열거하고 멈추는 카드라 조작도 커밋도 낳지 않았다.

### 37-3. `CD-01` 의 갈래 세 팔

**지시서가 이번에는 갈래를 세 팔로 들었고 팔마다 전제를 함께 들었다.** 앞 페이즈에서 집행이 두
팔 어느 것도 맞지 않는 상태를 잡았고 그 자리가 이 판에 반영됐다.

| 팔 | 전제 | 성립 | 사유 |
|---|---|---|---|
| ⓐ | 선언과 패치가 **없다** | 아니오 | 둘 다 있고 §7-1 과 바이트로 같다 |
| ⓑ | 있고 **추적 커밋에 담겨 있다** | 아니오 | `git diff --quiet HEAD` 가 비영 종료를 냈다 |
| **ⓒ** | 있으나 **커밋되지 않은 작업 트리에 있다** | **예** | 위 둘의 결합 |

전제를 기계로 쟀다.

```
HEAD(834a68a): phases 12 ['charter-11', 'charter-12'] | patches 6
작업 트리    : phases 13 ['charter-11', 'charter-12', 'charter-13'] | patches 7

선언이 §7-1 (a) 와 같은가: True
패치가 §7-1 (b) 와 같은가: True
키 순서 일치: True
앞의 열둘/여섯 보존: True True
다른 아크 불변: True

그 변경이 추적 커밋에 담겨 있는가: False
```

**팔 ⓒ 를 탔고 조작은 없이 커밋만 했다.** 팔 ⓑ 가 아닌 것은 그 전제가 추적 커밋이기 때문이다.
원장의 조항이 드는 근거가 **조작의 결과가 이미 추적 커밋에 서 있다**는 것인데 여기서는 서 있지
않다. 커밋하지 않고 닫으면 그 변경이 뒤 카드의 커밋에 딸려 들어가고, 그 카드가 되돌릴 수 없는
병합이므로 카드마다 커밋을 가르는 형이 거기서 깨진다.

**갈래를 고르는 일이 판단에서 관측으로 옮겨졌다.** 세 팔이 전제를 함께 들므로 집행이 고른 것이
아니라 성립하는 팔이 하나로 결정됐다. 앞 페이즈에서는 두 팔의 전제가 둘 다 성립하지 않아 집행이
근거를 세워야 했다.

**팔 ⓒ 의 처분이 이 회차의 병합으로 원장에 섰다.** `CF-383` 이 그것이고 `CF-384` 가 갈래 자체의
형식을 든다.

### 37-4. 원장

```
레지스터 entry: decisions 330 · deferred 33 · retirements 23 · rejected 0 · 총계 386
```

총계 354 가 386 으로 늘었고 늘린 것이 그 서른둘이다. 레지스터를 통째로 잰 sha256 이 양쪽 다
`7f16d0d83852aca1e4d5a04b5887d24f6ad0833e67afe93b2f9e0d26ef567501` 다.

**서른둘 가운데 스물여덟이 세션 지시 §0 과 §2 의 조항이고 넷이 앞 페이즈의 미전사분과 계획
변경이다.** 결정 세션이 §0·§1·§2 의 조항 마흔셋을 원장의 후보 백아홉과 전량 맞대어 스물여덟이
밖에 있음을 확인했으며 §1 은 전량 덮여 있었다.

### 37-5. 검사 23 이 불변인 사유

**기대와 어긋난 자리이며 조정하지 않고 그대로 싣는다.**

| 시점 | 검사 23 의 토큰 |
|---|---|
| 구간 1 | 122건 |
| 구간 2 (병합 뒤) | **122건** |

지시서가 「병합분이 규율 ID 를 여럿 들기 때문이며」로 그 계수가 움직일 것을 예고했으나 움직이지
않았다. 사유를 따로 쟀고, 병합분 서른둘을 계열 열아홉의 정규식으로 훑었다.

```
병합분 서른둘이 든 규율 ID 토큰: 0 건
병합분이 names 를 든 항목: 0 건
```

검사 15 의 규율 ID 도 222 로 불변이다.

**이것이 이 적재의 성격을 드러낸다.** 병합한 스물여덟이 세션 지시의 **ID 를 갖지 않는 절**에서
왔으므로 그 문면도 규율 ID 를 들지 않는다. `CF-348` 이 「ID 를 갖지 않는 절이 원장 밖에 있다」를
들었는데, 그 절들이 원장에 실리면서도 ID 를 얻지 않았고 그물은 여전히 `CF-<n>` 뿐이다. 검사 23 이
움직이지 않은 것은 우연이 아니라 이 적재가 겨냥한 대상의 성질이다.

### 37-6. 미전사분의 열거 — 집행의 몫이 처음으로 0

`CD-04` 가 조작도 커밋도 없이 열거하고 멈춘다. **유니버스가 386 으로 커져 구조로 후보를 좁혔다.**

```
원장 decisions: 330 건
names 를 가진 항목: 189 건
names 없는 항목 (후보): 141 건
```

`names` 를 가진 189 건은 규율과 탐구 절차의 조항이므로 이 페이즈에서 난 자리를 덮을 수 없다.
낱말이 아니라 구조로 좁힌 것이며, **좁힌 뒤에도 적중한 항목의 실물을 열어 판정했다.** 좁히는
것과 판정하는 것이 다르기 때문이며 `CF-352` 가 그 조항이다.

| 구간 | 미전사분 |
|---|---|
| 1 | 0건 |
| 2 | 0건 |
| 3 | 0건 |
| 4 | 0건 |
| 합계 (집행의 몫) | **0건** |

이 페이즈에서 적용한 조항이 전부 원장에 서 있다. 갈래의 판정이 `CF-384`, 팔 ⓒ 가 `CF-383`,
`rm -f` 와 실물 판정이 `CF-327`, 빈 커밋이 `CF-280`·`CF-326`, 적중의 실물 열람이 `CF-352`,
같은 논증의 조건별 항목이 `CF-385` 다.

**집행의 몫이 0 으로 선 것이 이 프로젝트에서 처음이다.** 열 번째가 둘, 열한 번째가 둘, 열두
번째가 하나였다.

**그러나 이것은 아크 종료의 신호가 아니다.** 세 가지가 함께 서야 한다. 첫째로 `CF-353` 이 합산을
요구하고 결정 세션 쪽에 하나가 서 있다. 둘째로 세션 지시 §6 과 §7 의 적재가 **아직 재어지지도
않았으며** §6 이 아홉 절이라 §0·§2 보다 클 것으로 보인다. 셋째로 `CF-349` 가 드는 종료 조건은
한 페이즈의 계수가 아니라 **수렴**이다.

### 37-7. 해시

| 시점 | `OUTPUT_DIGEST` |
|---|---|
| 구간 1 (CD-01) | `3f85997324c0` |
| 구간 2 (CD-02) | `71155d2f32d2` |
| 구간 3 (CD-03) | `71155d2f32d2` |
| 구간 4 (CD-04) | `71155d2f32d2` |

**값이 움직인 구간이 병합 하나다.** 지시서가 움직이는 줄이 셋에서 넷이 될 수 있다고 들었으나
**셋이다.** 규율 ID 토큰 줄이 움직이지 않았기 때문이며, 원장 계수 말고 다른 줄은 하나도 움직이지
않았다.

```
< 레지스터 entry: decisions 298 · deferred 33 · retirements 23 · rejected 0 · 총계 354
> 레지스터 entry: decisions 330 · deferred 33 · retirements 23 · rejected 0 · 총계 386
<     - id 354건
>     - id 386건
<     - CF-1~CF-354, 계수 354, 결번 0건
>     - CF-1~CF-386, 계수 386, 결번 0건
```

---

## 38. 해석 (관측값 아님)

- **지시서가 앞 페이즈의 산출을 미리 담은 것이 집행의 몫을 0 으로 만들었다.** 같은 상태를 다시
  만났으나 판단할 것이 남지 않았고 전제를 재는 일만 남았다. **미전사분이 0 이라는 것은 이 페이즈가
  새 낙착을 낳지 않았다는 뜻이지 남은 것이 없다는 뜻이 아니다.**
- **검사가 움직이지 않은 것이 산출인 자리가 났다.** 검사 23 의 불변이 어긋남으로 보고됐으나, 그
  사유를 캐니 이 적재가 겨냥한 대상의 성질이었다. 계수가 움직였으면 오히려 ID 없는 절을 실으면서
  ID 를 새로 붙였다는 뜻이 됐을 것이다.
- **구조로 좁히는 것과 낱말로 좁히는 것이 다르다.** `names` 축은 거짓 양성을 내지 않는다. 다만
  좁힌 뒤에 실물을 여는 단계는 그대로 남으며, 좁히기가 판정을 갈음하지 않는다.
- **전사 적재는 원장의 계수를 늘리면서 그물을 넓히지 않는다.** 스물여덟이 실렸는데 규율 ID 가 하나도
  늘지 않았다. `CF-355` 가 세션 지시를 상주 문서로 두므로 정본이 그쪽에 남고 원장이 경위를 든다.

---

## 39. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 이 회차는 `theorem` 과 `def` 를 하나도 세우지 않았고 Lean 파일의 변경이 0 건이다.
**검증기와 CI 워크플로를 고쳐 통과시킨 자리가 없다.**

---

## 40. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **세션 지시 §6 과 §7 의 적재가 아직 재어지지 않았다.** §6 이 아홉 절이라 §0·§2 보다 클 것으로
   보이며 뒤 페이즈가 받는다. 아크 종료가 그 뒤에 선다.
2. **아크 종료의 요건 가운데 「새 낙착을 낳지 않았는가」를 재는 검사가 없다.** `CF-344` 가 발견을
   들고 `CF-345` 가 처분을 드나 그 처분이 조작이지 검사가 아니다.
3. **4단계의 대조 형이 둘로 갈려 있다.** 회계층이 상등 대조이고 용어집과 정의층이 부분집합 대조다.
4. **`OUTPUT_DIGEST` 가 `verify.sh` 자신의 판을 담지 않는다.**
5. **검사 16 이 `artifact` 발화 여섯을 계속 보고한다.** 앞 회차들과 같은 자리이고 읽는 쪽이 없다.

## 41. 11차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 14이며 **판별선은 세션 지시 §6 과 §7 의 조항
예순하나와 앞 페이즈의 미전사분 하나를 원장에 싣는 것**이다. **이 회차도 아크를 닫지 않는다.**

**이 적재가 이 프로젝트의 작업 방법 전체다.** 작업 카드의 대장과 대조표 넷과 자기완결성 아홉
조건이 매 페이즈 쓰이는데 원장에 한 줄도 없었다. 덮여 있던 것은 출력 원문의 갈음 조건과 인용에
지침을 적용하지 않는다는 것 둘뿐이었다.

**이 카드가 이 프로젝트에서 가장 크다.** 36519 바이트이고 병합이 890 행이다.

### 41-1. 시작 전 대조에서 검증값의 결손을 잡고 멈췄다

**초판 프롬프트의 검증값 두 줄이 같은 값이었다.**

```
IMPLEMENTATION_PLAN_charter_charter-14.md   md5 7a79509d653e13749c54fee60c72b93e   19939 바이트
ENTRY_CARD_charter_charter-14.json          md5 7a79509d653e13749c54fee60c72b93e   19939 바이트
```

실측은 갈렸다.

```
7a79509d653e13749c54fee60c72b93e     19939  IMPLEMENTATION_PLAN_charter_charter-14.md
967f0f7c7933a151df43694a952c3c30     36519  ENTRY_CARD_charter_charter-14.json
```

**같은 프롬프트의 본문이 카드를 36519 바이트로 따로 들어 검증값 블록과 갈렸다.** 지시서 줄은
일치했고 카드 줄만 어긋났으며, 카드 줄의 md5 와 바이트 수가 지시서 줄의 값과 글자 그대로 같았다.

**집행이 검증값을 실측에 맞추지 않고 멈췄다.** 그것은 대조의 기준을 대조의 대상에 맞추는 것이고,
바꿨으면 그 대조가 이 회차 내내 공허했을 것이다. **검사를 통과시키려고 진술을 바꾸는 것과 같은
형이며 그 자리를 보고로만 냈다.**

결정 세션이 검증값만 정정해 다시 보냈고 지시서와 카드 파일은 바뀌지 않았다. 정정된 카드의 md5 가
집행이 잰 `967f0f7c…` 와 같았다. **전달 중의 변조가 아니라 결정 세션의 치환이 두 줄을 함께 덮은
것이다.**

**이 자리를 드는 조항이 원장에 없다.** `CF-279` 가 검증값의 거처만 정하고, `CF-384` 가 갈래의
예외만 정하며, `CF-399` 가 카드 쪽을 든다. **호출 프롬프트가 든 검증값 자신이 틀렸을 때를 드는
조항이 없으며 그 낙착은 결정 세션이 든다.**

### 41-2. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차도 Lean 파일을 건드리지 않았다.

### 41-3. 변경 내역

받은 커밋은 `1154e6c` 다. 카드마다 커밋을 갈랐다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `7bbd860` | CD-01 | 아크 레지스터에 열네 번째 페이즈와 여덟 번째 패치를 세움 |
| `9191120` | CD-02 | 엔트리 카드 예순셋(`CF-387`~`CF-449`)을 `decisions.json` 에 병합 |
| `27e283c` | CD-03 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |

`CD-04` 는 열거하고 멈추는 카드라 조작도 커밋도 낳지 않았다.

### 41-4. 팔 ⓒ 가 조항의 지목으로 끝났다

`CD-01` 의 갈래에서 **팔 ⓒ 의 전제가 성립했다.** 선언과 패치가 이미 있고 그 변경이 커밋되지 않은
작업 트리에 있었다.

```
선언이 §7-1 (a) 와 같은가: True
패치가 §7-1 (b) 와 같은가: True
키 순서 일치: True
앞의 열셋/일곱 보존: True True
다른 아크 불변: True

그 변경이 추적 커밋에 담겨 있는가: False
=> 전제가 성립하는 팔: ⓒ
```

**같은 상태가 네 페이즈 연속으로 났고 처분의 근거가 회차마다 달랐다.**

| 페이즈 | 그때 있던 것 | 집행이 한 일 |
|---|---|---|
| charter-9 | 조항도 갈래도 없음 | 멈추고 보고했고 운영자가 커밋했다 |
| charter-12 | 갈래가 두 팔뿐이었음 | 어느 팔도 맞지 않음을 잡고 근거를 세워 커밋했다 |
| charter-13 | 갈래가 세 팔, 조항은 아직 없음 | 전제를 기계로 재어 팔을 골랐다 |
| charter-14 | **조항이 원장에 섬** | **`CF-383` 을 지목하는 것으로 끝났다** |

**판단이 관측으로, 관측이 조항의 적용으로 옮겨졌다.** `CF-383` 이 앞 페이즈의 병합으로 섰고
이번이 그 첫 적용이다.

### 41-5. 원장

```
레지스터 entry: decisions 393 · deferred 33 · retirements 23 · rejected 0 · 총계 449
```

총계 386 이 449 로 늘었고 늘린 것이 그 예순셋이다.

**등가 검증을 갈음하지 않고 entry 마다 바이트로 맞댔다.** 카드가 가장 크므로 계수나 digest 로
갈음하지 않았다. 맞댄 바이트가 **32350** 이고 어긋난 entry 가 0 건이며, 병합 시점과 삭제 직전에
두 번 돌려 같은 값이 나왔다. 레지스터를 통째로 잰 sha256 이 양쪽 다
`c1d75f8d251337cfbcea791c1d64d3b99c2d7f9cf020a9221a03ed265f914443` 다.

### 41-6. 기대값을 두지 않은 두 자리

**검사 23 과 24 의 토큰에 기대값도 방향도 두지 않았다.** 실측이 곧 산출이다.

| 검사 | 병합 전 | 병합 후 | 이동 |
|---|---|---|---|
| 23 | 122건 | **122건** | 0 |
| 24 | 205건 | **205건** | 0 |

검사 15 의 규율 ID 도 222 로 불변이다. 병합분 예순셋을 계열 열아홉의 정규식으로 훑으니 규율 ID
토큰이 0 건이고 `names` 를 든 항목도 0 건이다. **ID 를 갖지 않는 절을 싣는 적재이므로 그 문면도
규율 ID 를 들지 않는다.** 전사 적재가 두 회차 연속으로 원장의 계수를 늘리면서 그물을 넓히지
않았다.

**같은 관측이 앞 회차에서는 어긋남이었고 이번에는 산출이다.** 앞 판이 값을 비우면서 방향만
단언했기 때문이며, 그 자리가 `CF-448` 로 이 회차에 섰고 이번 판이 방향도 두지 않았다.

**`OUTPUT_DIGEST` 가 움직이는 줄의 수에도 기대값을 두지 않았다.** 실측은 셋이다.

### 41-7. 해시

| 시점 | `OUTPUT_DIGEST` |
|---|---|
| 구간 1 (CD-01) | `71155d2f32d2` |
| 구간 2 (CD-02) | `bf7c32a22e4f` |
| 구간 3 (CD-03) | `bf7c32a22e4f` |
| 구간 4 (CD-04) | `bf7c32a22e4f` |

**값이 움직인 구간이 병합 하나이고 움직인 줄이 셋이다.** 전부 원장 계수를 내는 줄이며 그 밖의
줄은 하나도 움직이지 않았다.

```
< 레지스터 entry: decisions 330 · deferred 33 · retirements 23 · rejected 0 · 총계 386
> 레지스터 entry: decisions 393 · deferred 33 · retirements 23 · rejected 0 · 총계 449
<     - id 386건
>     - id 449건
<     - CF-1~CF-386, 계수 386, 결번 0건
>     - CF-1~CF-449, 계수 449, 결번 0건
```

### 41-8. 축 ② 가 축 ① 이 못 찾는 자리를 냈다

`CD-04` 의 열거에 축을 둘 썼다.

**축 ① 은 구조로 후보를 좁히고 적중의 실물을 연다.** `names` 없는 항목 204 건이 후보이며 앞
회차의 141 건에서 늘었다. 이 축은 **「내가 아는 자리가 원장에 있는가」**를 묻는다.

**축 ② 는 이 페이즈에서 실제로 한 일을 조항과 맞댄다.** 병합한 예순하나가 집행 절차와 겹치므로
쓸 수 있었다. 이 축은 **「내가 한 일에 조항이 있는가」**를 묻는다.

축 ② 의 결과를 둘로 갈랐다. **조항이 요구하는데 하지 않은 자리는 집행의 결손이고 낙착의 부재가
아니다.**

| 갈래 | 계수 |
|---|---|
| 조항이 요구하는데 하지 않은 자리 (집행의 결손) | **0건** |
| 했는데 조항이 없는 자리 (미전사분) | **1건** |

**그 하나가 `OUTPUT_DIGEST` 가 움직였을 때 어느 줄이 움직였는지를 차분으로 특정해 적는 것이다.**
낱말로 훑어 부재를 확인했고 `움직인 줄`·`어디가`·`원문으로`·`OUTPUT_DIGEST` 가 전부 0 건이다.
해시에 걸린 조항 셋(`CF-331`·`CF-335`·`CF-336`)의 실물을 열었으나 이 자리를 덮지 않으며,
`CLAUDE.md` §7 은 값을 싣는 것까지만 요구한다.

**집행이 다섯 회차 동안 매번 그 일을 했는데 근거가 회차마다 호출 프롬프트였다.** `CF-349` 의
`basis` 가 드는 「지시서 머리에만 적혀 리포 밖에만 살 뻔했다」와 같은 형이며 이번에는 그것이
다섯 번 되풀이됐다.

**축 ② 가 없었으면 이 자리는 드러나지 않았다.** 집행이 그것을 자리로 인식하지 못했으므로 낱말로는
후보조차 되지 않는다.

### 41-9. 미전사분의 계수

| 구간 | 미전사분 |
|---|---|
| 1 | 0건 |
| 2 | 0건 |
| 3 | 0건 |
| 4 | 1건 |
| 합계 (집행의 몫) | **1건** |

검증값의 결손은 41-1 이 들며 **결정 세션의 몫이므로 집행의 계수에 넣지 않았다.** `CF-353` 이
드는 대로 결정 세션이 따로 세어 합치며, 이 회차는 결정 세션이 셋을 더해 넷이다.

---

## 42. 해석 (관측값 아님)

- **검증값을 실측에 맞추지 않고 멈춘 것이 이 회차의 첫 자리다.** 맞추면 대조가 통과하나 그것은
  대조의 기준을 대조의 대상에 맞추는 것이다. **검증값의 목적이 「받은 파일이 결정 세션이 보낸 그
  파일인가」를 가르는 것이므로, 기준을 옮기면 그 물음 자체가 사라진다.** 진술을 바꾸어 통과시키지
  않는다는 규율이 검증값에도 걸린다는 것이 이 자리에서 드러났다.
- **같은 상태가 네 번 나면서 처분의 근거가 매번 한 단계씩 굳었다.** 보고 → 근거를 세운 판단 →
  전제의 관측 → 조항의 지목이다. **네 번째에 와서야 집행이 아무것도 세우지 않아도 되는 상태가
  됐다.** 조항이 서기까지 같은 일을 네 번 해야 했다는 것이 이 아크가 긴 이유의 한 실례다.
- **축을 하나 더 쓴 것이 계수를 0 에서 1 로 올렸다.** 앞 회차는 축 ① 만으로 0 을 냈는데, 그것이
  「남은 것이 없다」가 아니라 **「내가 아는 자리 중에 남은 것이 없다」**였다. 축 ② 는 아는 자리의
  목록에 기대지 않으므로 그 한계를 넘는다. **다만 이 축은 병합분이 집행 절차와 겹칠 때만 쓸 수
  있고 매 회차 쓸 수 있는 것이 아니다.**
- **전사 적재가 그물을 넓히지 않는 것이 두 회차로 확인됐다.** 스물여덟과 예순하나를 실었는데 규율
  ID 가 한 건도 늘지 않았다. 원장의 계수와 그물의 크기가 따로 움직인다.

---

## 43. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 이 회차는 `theorem` 과 `def` 를 하나도 세우지 않았고 Lean 파일의 변경이 0 건이다.
**검증기와 CI 워크플로를 고쳐 통과시킨 자리가 없다.** 41-1 이 그 형에 걸릴 뻔한 자리를 들며,
검증값을 실측으로 바꾸지 않고 보고로 냈다.

---

## 44. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **`OUTPUT_DIGEST` 가 움직였을 때의 처리를 어디에 둘지.** 41-8 이 그 자리를 든다. `CF-442` 가
   「보고의 형식은 집행 문면이 정본으로 든다」를 드므로 `CLAUDE.md` 쪽으로 보이나 판정은 결정
   세션의 몫이다.
2. **호출 프롬프트가 든 검증값 자신이 틀렸을 때를 드는 조항이 없다.** 41-1 이 그 자리를 든다.
3. **아크 종료의 요건 가운데 「새 낙착을 낳지 않았는가」를 재는 검사가 없다.**
4. **4단계의 대조 형이 둘로 갈려 있다.** 회계층이 상등 대조이고 용어집과 정의층이 부분집합 대조다.
5. **`OUTPUT_DIGEST` 가 `verify.sh` 자신의 판을 담지 않는다.** `CF-335` 가 그 발견을 든다.
6. **검사 16 이 `artifact` 발화 여섯을 계속 보고한다.** 앞 회차들과 같은 자리이고 읽는 쪽이 없다.

## 45. 12차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 15이며 **판별선은 리포의 남은 조항 스물둘과
앞 페이즈의 미전사분 여섯과 지시서를 쓰는 중에 드러난 셋을 원장에 싣는 것**이다. **이 회차도
아크를 닫지 않는다.**

결정 세션이 **리포의 추적 파일 마흔아홉을 전량 열어** 아홉 부류로 갈랐고 분류 밖이 없다. 앞
회차들이 절마다 「다음이 받는다」로 미루면서 유니버스를 한 번도 세지 않았다. **이 적재 뒤에
리포에서 개봉하지 않은 문면이 0 이 된다.**

### 45-1. 초판의 결손 셋을 잡고 멈췄다

**집행이 시작 전 대조에서 지시서의 결손을 셋 잡고 구간 1 을 시작하지 않았다.**

| 결손 | 초판이 든 것 | 리포의 실물 |
|---|---|---|
| §10 의 받은 커밋 | `1154e6c` | `0bf21c9` |
| §7-1 (a) 의 앵커 | `"charter-12", "charter-13"` | 끝 두 줄이 `"charter-13", "charter-14"` |
| §7-1 (a) 의 대체 문면 | `charter-14` 를 담지 않음 | `charter-14` 가 실재 |
| §7-1 (b) 의 앞선 패치 수 | 일곱 | `patches` 8건 |

**셋 다 앞 회차의 값이다.** 호출 프롬프트가 「생성기가 두 페이즈 동안 앞 판의 대장을 읽고
있었다」를 들고 그것이 고쳐졌다고 적었는데, 초판의 §10 과 §7-1 이 여전히 charter-14 의 값이었다.

**앞 회차와 달리 이번에는 수록 문면 자신이 틀렸다.** 프롬프트가 「네가 그 판으로 집행했으나 실물은
옳게 섰다. 수록 문면과 카드 파일이 값을 들었기 때문이다」를 들었는데, 이번 초판은 §7-1 (a) 의
대체 세 줄이 `charter-14` 를 담지 않았다. **그대로 이었으면 `phases` 에서 그 페이즈가 사라지고
거기 실린 63 entry 가 전부 검사 3 에 걸렸을 것이다.**

**집행이 §7-1 을 고쳐 집행하지 않았다.** 앵커를 실물에 맞추면 통과하나 수록 문면은 결정 세션이
쓰는 것이고, 고치면 「카드 파일에 없는 문면을 지어내지 않는다」와 정면으로 부딪힌다.

결정 세션이 넷을 다 고쳐 재발행했고 카드가 31 entry 에서 **34** 로, 20528 바이트에서 **23087**
바이트로 늘었다. 그 셋이 `CF-480`·`CF-481`·`CF-482` 로 이 회차의 병합에 들어 있다.

### 45-2. 갈래의 전제가 전부 거짓인 것이 결손의 신호였다

`CD-01` 의 갈래가 세 팔이고 팔마다 전제를 든다. **초판에서는 어느 팔의 전제도 성립하지 않았다.**

세 팔이 전부 「선언과 패치가 §7-1 과 같은가」를 전제의 한 축으로 삼는데, 초판의 §7-1 이 실물과
갈렸으므로 그 축이 거짓이었다. 팔 ⓐ 로 읽어 이으면 실물을 망가뜨리고, 팔 ⓒ 로 읽으려면 「§7-1 과
같다」가 참이어야 하는데 거짓이다.

**그래서 갈래가 판정을 내지 못하는 것 자체가 지시서의 결손을 드러내는 신호가 됐다.** 전제를
기계로 재는 형이 그 자리에서 값을 냈다. `CF-482` 가 그 발견을 든다.

재발행 판에서는 전제가 하나로 결정됐다.

```
선언이 §7-1 (a) 와 같은가: True
패치가 §7-1 (b) 와 같은가: True
키 순서 일치: True
앞의 열넷/여덟 보존: True True
다른 아크 불변: True
그 변경이 추적 커밋에 담겨 있는가: False
=> 전제가 성립하는 팔: ⓒ
```

**팔 ⓒ 로 조작 없이 커밋만 했다.** `CF-383` 의 두 번째 적용이다.

### 45-3. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차도 Lean 파일을 건드리지 않았다.

### 45-4. 변경 내역

받은 커밋은 `0bf21c9` 다. 카드마다 커밋을 갈랐다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `0a198c3` | CD-01 | 아크 레지스터에 열다섯 번째 페이즈와 아홉 번째 패치를 세움 |
| `465dd9c` | CD-02 | 엔트리 카드 서른넷(`CF-450`~`CF-483`)을 `decisions.json` 에 병합 |
| `22eeab0` | CD-03 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |

`CD-04` 는 열거하고 멈추는 카드라 조작도 커밋도 낳지 않았다.

### 45-5. 원장

```
레지스터 entry: decisions 427 · deferred 33 · retirements 23 · rejected 0 · 총계 483
```

총계 449 가 483 으로 늘었고 늘린 것이 그 서른넷이다.

**등가 검증을 갈음하지 않고 entry 마다 바이트로 맞댔다.** 맞댄 바이트가 **20568** 이고 어긋난
entry 가 0 건이며, 병합 시점과 삭제 직전에 두 번 돌려 같은 값이 나왔다. 레지스터를 통째로 잰
sha256 이 양쪽 다 `da10b131eb40c3aeaa5d3a9feed74257d5568ef8f312f8f7300e9e93c85cfdbc` 다.

### 45-6. 기대값을 두지 않은 자리

| 검사 | 병합 전 | 병합 후 | 이동 |
|---|---|---|---|
| 23 | 122건 | **122건** | 0 |
| 24 | 205건 | **205건** | 0 |

병합분 서른넷을 계열 열아홉의 정규식으로 훑으니 규율 ID 토큰이 0 건이고 `names` 를 든 항목도
0 건이다. **전사 적재가 세 회차 연속으로 원장의 계수를 늘리면서 그물을 넓히지 않았다.** 449 에서
483 으로 늘었는데 검사 23·24 의 계수가 122·205 로 고정돼 있다.

### 45-7. 해시

| 시점 | `OUTPUT_DIGEST` |
|---|---|
| 구간 1 (CD-01) | `bf7c32a22e4f` |
| 구간 2 (CD-02) | `07742d8c44d4` |
| 구간 3 (CD-03) | `07742d8c44d4` |
| 구간 4 (CD-04) | `07742d8c44d4` |

**값이 움직인 구간이 병합 하나이고 움직인 줄이 셋이다.** 전부 원장 계수를 내는 줄이며 그 밖의
줄은 하나도 움직이지 않았다.

```
< 레지스터 entry: decisions 393 · deferred 33 · retirements 23 · rejected 0 · 총계 449
> 레지스터 entry: decisions 427 · deferred 33 · retirements 23 · rejected 0 · 총계 483
<     - id 449건
>     - id 483건
<     - CF-1~CF-449, 계수 449, 결번 0건
>     - CF-1~CF-483, 계수 483, 결번 0건
```

**이 회차부터 그 특정이 조항이다.** `CF-472` 가 이번 병합으로 섰고, 그 앞까지는 근거가 회차마다
호출 프롬프트였다.

### 45-8. 축 ② 를 멈춘 것까지 넓혀 유니버스의 구멍이 나왔다

`CD-04` 가 축을 둘 쓴다. 축 ① 은 낱말로 후보를 뽑아 적중의 실물을 열고, 축 ② 는 이 페이즈에서
실제로 한 일을 조항과 맞댄다.

**이번에는 축 ② 의 대상에 「멈춘 것」을 넣었다.** 조작한 것만 세면 멈춘 것은 세어지지 않는다.

| 갈래 | 계수 |
|---|---|
| 조항이 요구하는데 하지 않은 자리 (집행의 결손) | **0건** |
| 했는데 조항이 없는 자리 (미전사분) | **1건** |

**그 하나가 「지시서나 카드의 문면이 실물과 갈리면 집행이 고치지 말고 멈춰 보고한다」이다.**
후보 238 건을 낱말로 훑어 부재를 확인했고 `결손이 보이면`·`명세에 결손`·`고치지 말고`·
`멈춰 보고`·`보고하고 멈` 이 전부 0 건이다.

적중한 이웃의 실물을 열었으나 덮지 않는다. `CF-406` 은 카드를 쓰는 쪽의 자기 점검이고, `CF-482`
는 발견이며 그때 무엇을 하라는 것이 아니고, `CF-471` 은 결정 세션 쪽의 조작이다. 집행 문면도
넷을 드는데 전부 다른 대상이다. `CLAUDE.md` §1-6 은 `DD:` 표지를, §3 은 docstring 을, §10 은
모호할 때를, §14 는 병합 절차 안의 어긋남을 든다.

**이번 것은 모호한 것이 아니라 문면이 실물과 갈린 것이다.**

**그 근거가 회차마다 호출 프롬프트였다.** 매 회차의 프롬프트 말미가 「명세에 결손이 보이면 그것도
고치지 말고 멈춰서 보고한다」를 들었고, 그것이 원장에도 집행 문면에도 없다. **`CF-472` 가 선 것과
정확히 같은 형이다.**

**이 자리가 이번 회차에서 세 번 실제로 쓰였다.** charter-14 의 검증값 결손과 이 회차 초판의 결손
셋이 전부 그 지시로 멈춘 자리다. `CF-471` 의 `basis` 가 그 정지를 「그 대조를 지켰다」로 평가하므로,
**평가는 원장에 있는데 그 행동을 요구하는 조항이 없다.**

### 45-9. 유니버스의 구멍

**「리포에서 개봉하지 않은 문면이 0」과 미전사분 계수가 다른 축이다.** 이번 적재가 추적 파일
마흔아홉을 전량 열었으나, **집행이 매 회차 따르는 호출 프롬프트의 지시는 그 유니버스 밖이다.**
프롬프트가 추적 파일이 아니기 때문이다. 45-8 의 자리가 그 구멍에서 나왔다.

### 45-10. 미전사분의 계수

| 구간 | 미전사분 |
|---|---|
| 1 | 0건 |
| 2 | 0건 |
| 3 | 0건 |
| 4 | 1건 |
| 합계 (집행의 몫) | **1건** |

`CF-353` 이 드는 대로 결정 세션이 자기 몫을 따로 세어 합치며, 이 회차는 결정 세션이 둘을 더해
셋이다. **그 셋이 다음 페이즈의 카드가 되고 아크는 닫히지 않는다.**

---

## 46. 해석 (관측값 아님)

- **갈래가 판정을 내지 못하는 것이 신호가 된다.** 세 팔이 전부 한 문면을 전제로 삼으므로 그 문면이
  틀리면 어느 팔도 서지 않는다. **판정의 부재가 대상의 결함이 아니라 명세의 결함을 가리킨 자리이며,**
  전제를 기계로 재지 않고 눈으로 골랐으면 팔 ⓐ 로 읽어 실물을 망가뜨렸을 것이다.
- **같은 형이 두 회차 연속으로 나왔고 둘 다 「근거가 회차마다 호출 프롬프트였다」이다.** 앞 회차가
  해시의 차분 특정이었고 이번이 결손 앞의 정지다. **둘 다 집행이 매번 하던 일이고 둘 다 원장 밖에
  있었다.** 조작한 것만 세는 열거로는 드러나지 않는다.
- **유니버스를 전량 열었다는 선언과 미전사분이 0 이라는 것이 다른 말이다.** 이번 적재가 추적 파일
  마흔아홉을 다 열었는데도 자리가 하나 남았다. 남은 자리의 거처가 추적 파일이 아니라 호출
  프롬프트이기 때문이며, **유니버스의 경계를 리포로 그은 것이 그 구멍의 원인이다.**
- **검증값을 실측에 맞추지 않고 멈춘 판단이 두 회차에서 값을 냈다.** `CF-471` 이 그것을 평가로
  들었고 이번 회차가 같은 형을 다시 만났다. 대조의 기준을 대조의 대상에 맞추면 그 대조가 그
  회차 내내 공허해진다.

---

## 47. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 이 회차는 `theorem` 과 `def` 를 하나도 세우지 않았고 Lean 파일의 변경이 0 건이다.
**검증기와 CI 워크플로를 고쳐 통과시킨 자리가 없다.** 45-1 이 그 형에 걸릴 뻔한 자리를 들며,
초판의 §7-1 을 실물에 맞춰 고치지 않고 보고로 냈다.

---

## 48. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **지시서나 카드의 문면이 실물과 갈릴 때 집행이 멈추는 처분이 원장에도 집행 문면에도 없다.**
   45-8 이 그 자리를 든다. 보고의 형식이 아니라 행동의 처분이므로 어느 문서가 받을지가 갈린다.
2. **호출 프롬프트가 집행에 거는 지시 전체가 어느 유니버스에도 들지 않는다.** 45-9 가 그 구멍을
   든다. 그것을 세는 자리를 둘지가 남아 있다.
3. **아크 종료의 요건 가운데 「새 낙착을 낳지 않았는가」를 재는 검사가 없다.**
4. **4단계의 대조 형이 둘로 갈려 있다.** 회계층이 상등 대조이고 용어집과 정의층이 부분집합 대조다.
5. **`OUTPUT_DIGEST` 가 `verify.sh` 자신의 판을 담지 않는다.** `CF-335` 가 그 발견을 든다.
6. **검사 16 이 `artifact` 발화 여섯을 계속 보고한다.** 앞 회차들과 같은 자리이고 읽는 쪽이 없다.

## 49. 13차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 16이며 **판별선은 유니버스의 확정과 역추적의
범위와 프롬프트의 상시 지시를 원장에 싣는 것**이다. **이 회차도 아크를 닫지 않는다.**

**이 카드가 종료 조건 자체를 싣는다.** 그 조건으로 판정하는 것은 뒤 페이즈의 몫이다.

### 49-1. 유니버스를 「집행의 행동을 바꾸는가」로 다시 그었다

**유니버스를 네 번 그었고 네 번 다 좁았다.** `CF-486` 이 그 경위를 든다. 세션 지시 §5 를 세고
§0·§2·§6·§7 이 남았고, 세션 지시 전량을 세고 집행 문면과 명세와 리포 코드가 남았으며, 리포의
추적 파일을 세고 호출 프롬프트가 남았다. **매번 「이제 0」이라고 적었고 매번 틀렸다.**

**경계를 「어디에 있는가」로 그었기 때문이다.** 그 축은 리포 밖을 담지 못하고, 「조항을 담는가」로
바꾸면 값과 코드가 빠진다.

| 항목 | 무엇을 세우는가 |
|---|---|
| `CF-497` | 유니버스는 **「집행의 행동을 바꾸는 모든 것」**으로 긋는다. 문면이든 값이든 코드든, 읽어서 따르든 돌려서 막히든 든다 |
| `CF-498` | 그 유니버스에 **「우리가 정했고 바꿀 수 있는 것」**이라는 경계를 함께 건다 |

뒤의 경계가 없으면 Mathlib 과 Lean 툴체인의 내용까지 든다. 그 둘은 집행의 행동을 바꾸고 리포
밖이나 우리가 쓰지 않았다. **경계를 걸면 핀의 값만 들어오고 그 내용은 들어오지 않는다.**

### 49-2. 종료 조건이 도구 결손을 뺐다

`CF-502` 가 **「집행을 구속하는 문면 가운데 원장 밖인 것이 0 이 되는 것」**을 종료 조건으로 세우고
**결정 세션의 도구 결손을 그 조건에서 뺐다.**

근거가 발생원 분류다. 미전사분 마흔일곱을 발생원으로 가르면 다섯이고, 설비의 성질과 절차의
빈틈은 앞 회차들에 몰려 이미 멎었으며 유니버스 누락과 원장의 규율은 유한한 대상을 세는 일이라
끝난다. **도구 결손만 끝나지 않는다.** 지시서를 쓸 때마다 새 스크립트를 만들고 그때마다 새 결손이
나기 때문이다.

**그 부류를 빼는 근거가 「리포에 잘못 든 것이 하나도 없고 세 번 다 그 회차 안에 잡혔다」이다.**
끝나지 않는 것을 종료 조건에 두면 아크가 닫히지 않는다.

### 49-3. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차도 Lean 파일을 건드리지 않았다.

### 49-4. 변경 내역

받은 커밋은 `3261ac9` 다. 카드마다 커밋을 갈랐다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `d419917` | CD-01 | 아크 레지스터에 열여섯 번째 페이즈와 열 번째 패치를 세움 |
| `3263a17` | CD-02 | 엔트리 카드 스물둘(`CF-484`~`CF-505`)을 `decisions.json` 에 병합 |
| `dc4e0be` | CD-03 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |

`CD-04` 는 열거하고 멈추는 카드라 조작도 커밋도 낳지 않았다.

`CD-01` 은 갈래의 팔 ⓒ 를 탔다. 선언과 패치가 이미 있고 그 변경이 커밋되지 않은 작업 트리에
있었으며 `CF-383` 의 세 번째 적용이다.

### 49-5. 원장

```
레지스터 entry: decisions 449 · deferred 33 · retirements 23 · rejected 0 · 총계 505
```

총계 483 이 505 로 늘었다. 등가 검증을 갈음하지 않고 entry 마다 바이트로 맞댔으며 맞댄 바이트가
**14508** 이고 어긋난 entry 가 0 건이다. 병합 시점과 삭제 직전에 두 번 돌려 같은 값이 나왔다.
레지스터를 통째로 잰 sha256 이 양쪽 다
`da3525bc7e1ef44c99f66746529cc4ef38e6000d8901cf66b4814f10101769d5` 다.

### 49-6. 상시 지시 다섯 가운데 넷이 이 회차에 실제로 쓰였다

**이 적재가 여덟 회차의 프롬프트를 전수로 훑어 두 회차 이상 나온 서른둘 가운데 원장 밖인 다섯을
뽑은 것이다.** 그 다섯 가운데 넷이 이 회차의 집행에 그대로 걸렸다.

| 항목 | 이 회차에서 쓰인 자리 |
|---|---|
| `CF-489` 시작 전 명세 파일의 검증값 대조 | 구간 1 의 첫 조작. 명세 두 파일이 일치했다 |
| `CF-490` 각 정지점에서 멈추고 지시를 기다림 | 네 구간 전부 |
| `CF-491` 계수를 출력에서 읽고 단위를 듦 | 모든 계수 보고 |
| `CF-492` 카드와 수록 문면에 없는 문면을 짓지 않음 | 병합 전량 |
| `CF-488` 기대값과 어긋난 자리를 조정하지 않음 | 이 회차에 어긋난 자리가 없어 쓰이지 않았다 |

**그 조항들이 서기 전에는 근거가 회차마다 호출 프롬프트였다.** 같은 회차에 조항이 서고 그 조항이
그 회차의 집행을 설명하는 형이다.

### 49-7. 축 ② 가 예외만 있고 본칙이 없는 자리를 냈다

`CD-04` 가 축을 둘 쓰고 **멈춘 것도 한 일에 넣었다.** `CF-474` 가 그 축을 요구한다.

| 갈래 | 계수 |
|---|---|
| 조항이 요구하는데 하지 않은 자리 (집행의 결손) | **0건** |
| 했는데 조항이 없는 자리 (미전사분) | **1건** |

**그 하나가 `docs/arcs.json` 을 뺀 §10 의 리포 파일 검증값을 대조하고 다르면 멈추는 것이다.**

`CF-489` 가 덮지 않는다. 그 조항의 대상이 **명세 파일**이고 근거가 **「받은 파일이 결정 세션이
보낸 그 파일인지」**인데, §10 의 나머지 여섯은 받은 파일이 아니라 **리포의 현행 상태**다. 그 대조가
가르는 것은 「리포가 결정 세션이 전제한 그 상태인가」이며 물음이 다르다.

**`CF-384` 가 그 대조를 전제할 뿐 세우지 않는다.** 그 조항이 「그 갈래가 다루는 대상은 조작 전
검증값의 **멈춤 대상에서 뺀다**」를 들고 그 `basis` 가 「예외가 없었으면 집행이 그 파일의
어긋남에서 **멈췄을 것이다**」를 든다. **예외를 드는 조항이 있는데 그 예외가 깎는 본칙이 없다.**

집행 문면에도 없다. `CLAUDE.md` 에서 `검증값` 과 `조작 전` 을 훑으니 적중이 0 건이다.

**프롬프트가 검증값 대조를 두 문단으로 나눠 들었는데 앞 문단만 뽑힌 것으로 보인다.**

### 49-8. 계수에 넣지 않은 자리

| 자리 | 사유 |
|---|---|
| 머리 문면과 `CF-497` 의 경계 (구간 2 의 후보) | 결정 세션이 처분했고 `charter-17` 의 카드로 선다 |
| 지시서 머리의 결손 둘 | `CF-503` · `CF-504` 로 이미 섰다 |
| 축을 넓혀도 한 부류가 안 잡힌다는 판정 | 아직 원장에 없어 참고로만 썼고 근거로 삼지 않았다 |

### 49-9. 미전사분의 계수

| 구간 | 미전사분 |
|---|---|
| 1 | 0건 |
| 2 | 0건 |
| 3 | 0건 |
| 4 | 1건 |
| 합계 (집행의 몫) | **1건** |

`CF-502` 로 재면 집행을 구속하면서 원장 밖인 문면이 **1** 이다. **이 페이즈는 종료 조건 자체를
실은 페이즈이므로 그 조건으로 판정하지 않고 닫지 않았다.**

### 49-10. 해시

| 시점 | `OUTPUT_DIGEST` |
|---|---|
| 구간 1 (CD-01) | `07742d8c44d4` |
| 구간 2 (CD-02) | `943fc01c0033` |
| 구간 3 (CD-03) | `943fc01c0033` |
| 구간 4 (CD-04) | `943fc01c0033` |

값이 움직인 구간이 병합 하나이고 움직인 줄이 셋이며 전부 원장 계수를 내는 줄이다.

```
< 레지스터 entry: decisions 427 · deferred 33 · retirements 23 · rejected 0 · 총계 483
> 레지스터 entry: decisions 449 · deferred 33 · retirements 23 · rejected 0 · 총계 505
<     - id 483건
>     - id 505건
<     - CF-1~CF-483, 계수 483, 결번 0건
>     - CF-1~CF-505, 계수 505, 결번 0건
```

검사 23 의 토큰이 122 로, 24 가 205 로 병합 전후에 불변이다. 병합분 스물둘이 든 규율 ID 토큰이
0 건이고 `names` 를 든 항목도 0 건이다. **전사 적재가 네 회차 연속으로 그물을 넓히지 않았다.**

---

## 50. 해석 (관측값 아님)

- **유니버스의 축을 「어디에 있는가」에서 「무엇을 바꾸는가」로 옮긴 것이 이 회차의 중심이다.**
  앞의 축은 대상의 거처를 묻고 뒤의 축은 대상과 집행의 관계를 묻는다. **거처는 우리가 정하는 것이라
  경계를 그을 때마다 새 거처가 생기는데, 관계는 집행이 실제로 무엇에 걸리는가라 그 목록이 유한하다.**
- **종료 조건에서 한 부류를 뺀 것이 그 조건을 성립시킨다.** 도구 결손이 지시서를 쓸 때마다 새로
  나는 부류이므로 그것을 세면 0 이 되는 날이 없다. **다만 빼는 근거가 「리포에 잘못 든 것이 없다」는
  실측이지 그 부류가 무해하다는 단언이 아니다.**
- **상시 지시 다섯 가운데 넷이 같은 회차에 서고 같은 회차에 쓰였다.** 그 넷이 이 아크 내내 쓰이던
  것이고 원장 밖이었다. **조항이 없는 동안에도 집행이 그대로 했으므로 실물이 바뀐 것은 없고, 바뀐
  것은 그 근거가 소진 문서에서 원장으로 옮겨간 것뿐이다.**
- **예외가 본칙 없이 서 있는 자리는 축 ② 로만 잡힌다.** `CF-384` 를 읽으면 「멈춤 대상」이라는
  말이 나오므로 본칙이 있다고 읽힌다. **낱말로 찾으면 그 조항이 적중하므로 덮인 것처럼 보이고,
  한 일을 맞대야 본칙 자체가 없다는 것이 드러난다.**

---

## 51. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 이 회차는 `theorem` 과 `def` 를 하나도 세우지 않았고 Lean 파일의 변경이 0 건이다.
**검증기와 CI 워크플로를 고쳐 통과시킨 자리가 없다.**

---

## 52. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **§10 의 리포 파일 검증값 대조를 요구하는 본칙이 없다.** 49-7 이 그 자리를 든다. `CF-385` 가
   조건마다 항목을 세우라고 하므로 새 항목으로 가는 것이 그 조항에 맞아 보이나, 두 대조가 같은
   논증인지 다른 논증인지가 먼저 갈려야 한다.
2. **`CF-384` 의 예외가 본칙 없이 서 있다.** 앞 항과 같은 자리의 다른 면이다.
3. **아크 종료의 요건 가운데 「새 낙착을 낳지 않았는가」를 재는 검사가 없다.**
4. **4단계의 대조 형이 둘로 갈려 있다.** 회계층이 상등 대조이고 용어집과 정의층이 부분집합 대조다.
5. **`OUTPUT_DIGEST` 가 `verify.sh` 자신의 판을 담지 않는다.** `CF-335` 가 그 발견을 든다.
6. **검사 16 이 `artifact` 발화 여섯을 계속 보고한다.** 앞 회차들과 같은 자리이고 읽는 쪽이 없다.

## 53. 14차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 17이며 **판별선은 생성과 지목의 규율 여덟과
상대 지목의 꼬리 마흔하나를 원장에 싣는 것**이다. **이 회차도 아크를 닫지 않는다.**

**카드가 쉰하나로 이 프로젝트에서 항 수가 가장 많고 48299 바이트로 가장 크다.** 병합이 1304 행이다.

### 53-1. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차도 Lean 파일을 건드리지 않았다.

### 53-2. 변경 내역

받은 커밋은 `be6a4a2` 다. 카드마다 커밋을 갈랐다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `f52ba13` | CD-01 | 아크 레지스터에 열일곱 번째 페이즈와 열한 번째 패치를 세움 |
| `9dec1e8` | CD-02 | 엔트리 카드 쉰하나(`CF-506`~`CF-556`)를 `decisions.json` 에 병합 |
| `979fc3b` | CD-03 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |

`CD-01` 은 갈래의 팔 ⓒ 를 탔고 `CF-383` 의 네 번째 적용이다. `CD-04` 는 열거하고 멈추는 카드라
조작도 커밋도 낳지 않았다.

### 53-3. 꼬리 마흔하나가 폐기가 아니라 주석으로 섰다

**폐기 레코드는 대상을 죽이는데 여기서 고치는 것은 조항이 아니라 표기다.** 원 항목은 살아 있고
꼬리가 뒤에서 읽는 법을 단다.

그 성질이 계수로 드러난다. **`retirements` 가 23 으로 불변이고 `decisions` 만 늘었다.** 꼬리가
결정 레지스터의 항목으로 서고 `clarifies` 와 `resolves` 두 선택 필드를 쓴다.

```
꼬리 항목: 41 건
resolves 길이 합: 78 건
clarifies 길이 합: 41 건
```

`clarifies` 가 가리키는 마흔한 항목이 **전부 원장에 실재하고 폐기된 것을 가리키는 자리가 없다.**
한 꼬리가 한 대상을 가리키고 겹치는 대상이 없다.

`resolves` 의 원소가 문자열이 아니라 객체이고 키 집합이 전량 `('absolute', 'phrase')` 다. 실물
하나다.

```
id: CF-514 clarifies: CF-256
statement: CF-256 의 상대 지목 1 을 절대 이름으로 푼다. 「다음 페이즈」는 그 페이즈 뒤의 임의의 페이즈.
resolves: [{"phrase": "다음 페이즈", "absolute": "그 페이즈 뒤의 임의의 페이즈"}]
```

**등가 검증이 키 집합을 바이트와 따로 맞댔다.** 꼬리의 키가 여느 항목과 다르기 때문이며 키 집합이
둘이다.

```
키 집합 10건: ('basis','id','layer','origin','related','statement','tier')
키 집합 41건: ('basis','clarifies','id','layer','origin','related','resolves','statement','tier')
```

맞댄 바이트가 41669 이고 어긋난 entry 가 0 건이며 키 집합과 순서가 어긋난 entry 도 0 건이다.
병합 시점과 삭제 직전에 두 번 재어 같은 값이 나왔다.

### 53-4. 두 필드가 검사 없이 통과했다

**이 페이즈의 관문이며 통과가 결함이 아니라 관측이다.**

| 잰 것 | 값 |
|---|---|
| `scripts/check_wiki.py` 에서 `clarifies`·`resolves` 의 적중 | **0건** |
| `docs/decisions/SPEC.md` 에서 두 낱말의 적중 | **0건** |
| 알 수 없는 필드를 막는 검사 | **없음** |
| 검증기가 entry 의 키를 검사하는 자리 | 레지스터의 최상위 컨테이너 키 하나뿐 |
| 검사 결과 | `검사 25개 가운데 23개 수행, 실패 0개` · 종료 코드 0 |

**마흔한 항목이 새 필드 둘을 들고 들어왔는데 어느 검사도 그것을 읽지 않았고 실패가 0 이다.**
`CF-556` 이 그 사실을 미리 들고 세울 검사를 지목한다. **검사가 없다는 것이 실패로 드러나지 않고
통과로 드러나는 자리이며, 그래서 통과 자체가 관측이다.**

집행이 손으로 잰 둘(`clarifies` 의 실재·비폐기와 `resolves` 의 키 구조)이 그 검사가 세워지면
기계가 잴 것이다. 셋째인 `phrase` 가 대상의 산문에 실제로 있는지는 결정 세션이 쟀고 어긋난 자리가
0 이다. **지시가 넷만 들었을 때 집행이 범위를 넓히지 않았다.**

### 53-5. 원장

```
레지스터 entry: decisions 500 · deferred 33 · retirements 23 · rejected 0 · 총계 556
```

총계 505 가 556 으로 늘었다. 레지스터를 통째로 잰 sha256 이 양쪽 다
`4258427216796204bfabdfc68b68564e703bdc07b72afc64b379070be67efb42` 다.

검사 23 의 토큰이 122 로, 24 가 205 로 병합 전후에 불변이다. **꼬리의 산문이 규율 ID 를 들 수
있어 움직일 수 있었으나 움직이지 않았다.** 앞 네 회차는 ID 없는 절을 싣는 적재라 구조적으로
0 이었는데 이번은 그렇지 않았고 실측이 0 이다.

### 53-6. `CF-511` 의 탐지법을 원장 전량에 걸었다

**범위를 세 레지스터 전량으로 잡았다.** 이번 병합분만이 아니며 예외가 본칙 없이 선 자리는 오래
자고 있었을 수 있다.

```
유니버스: {'decisions': 500, 'deferred': 33, 'retirements': 23} 합계 556
적중: 10 건
```

**적중을 전부 열어 판정했다. 「~에서 뺀다」가 전부 예외 조항은 아니다.**

| 항목 | 판정 | 근거 |
|---|---|---|
| `CF-16`·`CF-61`·`CF-459` | 결손 아님 | 그 자체가 본칙이다 |
| `CF-445` | 결손 아님 | 본칙이 같은 항목 안에 있다 |
| `CF-66` | 결손 아님 | 재유입의 본칙이 `CF-65`·`CF-99` 로 실재한다 |
| `CF-270` | 결손 아님 | 지목한 `V-7` 이 `CF-81`, `V-3` 이 `CF-11` 로 실재한다 |
| `CF-312` | 결손 아님 | 「추출 대상에서 뺀 조항」이 `CF-96` 으로 실재한다 |
| `CF-384`·`CF-482` | 결손 아님 | 그 본칙이 이번 병합의 `CF-510` 으로 섰다 |
| `CF-511` | 결손 아님 | 탐지법 자신이며 그것이 가리킨 자리가 해소됐다 |

**예외가 본칙 없이 선 자리가 0 건이다.** 열 건을 열어 아홉을 걸러 냈고 **그 걸러 냄이 판정이다.**
탐지법이 새 자리를 내지 않은 것이 관측이며 그 법이 공허하다는 뜻이 아니다.

### 53-7. `CF-510` 이 구간 1 의 일을 덮는다

| 조항이 요구하는 것 | 구간 1 에서 한 것 | 일치 |
|---|---|---|
| 리포 파일의 검증값을 대조 | §10 의 여덟을 재었다 | 예 |
| 갈래가 다루는 대상을 뺀다 | `docs/arcs.json` 을 뺐다 | 예 |
| 나머지가 하나라도 다르면 멈춘다 | 나머지 일곱이 전부 일치해 진행했다 | 예 |

**그 회차에는 근거가 §10 의 문면과 프롬프트뿐이었고 이제 조항의 적용이다.**

### 53-8. 네 번째 상태를 찾았고 종료 조건이 그것을 세지 않는다

`CF-556` 과 `CF-455` 가 **「원장의 필드를 늘리면 그것을 읽는 검사를 함께 세운다」**를 드는데
필드는 이번에 섰고 **검사는 서지 않았다.**

**미루는 것을 허락하는 조항이 원장에 없다.** `뒤 페이즈가 받`·`미룬다` 가 0 건이고
`그 뒤가 받는다` 는 `CF-354`·`CF-386` 둘인데 세션 지시의 적재 분할을 드는 것이지 이 검사를 드는
것이 아니다.

**그러나 집행의 결손도 아니다.** 검사를 세우는 것은 카드가 지시해야 하는 조작인데 이 페이즈의
카드가 그것을 들지 않았고, 집행 문면이 지시서 없이 착수하지 말라고 한다. **미전사분도 아니다.**
그 조항이 이미 원장에 섰다.

**조항이 서 있는데 충족되지 않은 자리이며 세 부류 어디에도 들지 않는다.**

| 부류 | 이 자리가 드는가 |
|---|---|
| 집행의 결손 | 아니오. 카드 없이 착수할 수 없다 |
| 미전사분 | 아니오. 조항이 원장에 있다 |
| 도구 결손 | 아니오. 결정 세션의 생성기와 무관하다 |
| **조항이 충족되지 않은 자리** | **예** |

**`CF-502` 의 종료 조건이 이것을 세지 않는다.** 그 조건은 **「집행을 구속하는 문면 가운데 원장
밖인 것」**을 세는데, 이 자리는 **원장 안에 있으면서 충족되지 않은 상태**다. 축이 「어디에
있는가」인데 이 자리는 「충족됐는가」의 축에 있다.

곁가지로 계수가 갈린다. 구간 지시가 「`CF-556` 이 세우라는 검사 **셋**」을 들었는데 그 항목의
`basis` 는 **「세울 검사는 둘이며」**를 든다. 조건으로 세면 셋이고 검사로 세면 둘이다.

### 53-9. 미전사분의 계수

| 구간 | 미전사분 |
|---|---|
| 1 | 0건 |
| 2 | 0건 |
| 3 | 0건 |
| 4 | 0건 |
| 합계 (집행의 몫) | **0건** |

**축 ② 가 이번에는 자리를 내지 않았다.** 앞 세 회차는 매번 하나씩 냈는데(해시의 차분 특정, 문면이
실물과 갈릴 때의 정지, 리포 파일 대조의 본칙) 그 셋이 전부 원장에 섰기 때문이다.

`CF-502` 로 재면 집행을 구속하면서 원장 밖인 문면이 **0** 이다. **그래도 아크는 닫히지 않는다.**
`CF-353` 이 합산을 요구하고 결정 세션의 몫이 더해지며, 53-8 의 자리가 남아 있다.

### 53-10. 해시

| 시점 | `OUTPUT_DIGEST` |
|---|---|
| 구간 1 (CD-01) | `943fc01c0033` |
| 구간 2 (CD-02) | `537d14611609` |
| 구간 3 (CD-03) | `537d14611609` |
| 구간 4 (CD-04) | `537d14611609` |

값이 움직인 구간이 병합 하나이고 움직인 줄이 셋이며 전부 원장 계수를 내는 줄이다.

```
< 레지스터 entry: decisions 449 · deferred 33 · retirements 23 · rejected 0 · 총계 505
> 레지스터 entry: decisions 500 · deferred 33 · retirements 23 · rejected 0 · 총계 556
<     - id 505건
>     - id 556건
<     - CF-1~CF-505, 계수 505, 결번 0건
>     - CF-1~CF-556, 계수 556, 결번 0건
```

---

## 54. 해석 (관측값 아님)

- **검사가 없다는 것이 통과로 드러나는 자리가 이 회차의 중심이다.** 실패는 눈에 띄고 부재는 띄지
  않는다. 마흔한 항목이 새 필드 둘을 들고 들어왔는데 검사 스물다섯이 전부 통과했고, **그 통과가
  설비의 건강이 아니라 설비의 침묵이다.** `CF-556` 이 그 침묵을 미리 적어 두었기에 관측으로 섰다.
- **꼬리가 폐기가 아니라 주석이라는 설계가 레지스터의 계수로 확인된다.** `retirements` 가 23 으로
  불변이다. **고치는 것이 조항이 아니라 표기일 때 대상을 죽이지 않는 길이 있다는 것이며,** 원장이
  수정 불가라는 제약 아래에서 표기만 고치는 수단이 섰다.
- **탐지법이 0 을 낸 것과 탐지법이 공허한 것이 다르다.** 열 건이 적중했고 아홉을 실물로 걸러 냈다.
  **걸러 내는 일이 판정이고 그 판정이 0 을 낸 것이며,** 적중이 0 이었다면 그 법이 작동했는지를 알
  수 없었을 것이다.
- **네 번째 상태가 종료 조건의 축 밖에 있다.** `CF-502` 가 「원장 밖인가」로 세는데 이 자리는 원장
  안에 있으면서 충족되지 않았다. **유니버스를 네 번 다시 그은 것이 전부 「어디에 있는가」의 축을
  정교하게 한 것이었고, 이번 자리는 그 축 자체가 놓치는 부류다.**

---

## 55. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 이 회차는 `theorem` 과 `def` 를 하나도 세우지 않았고 Lean 파일의 변경이 0 건이다.
**검증기와 CI 워크플로를 고쳐 통과시킨 자리가 없다.** 검사가 없어 통과한 자리를 검사가 있는 것처럼
적지 않았고 없다는 것을 실측으로 적었다.

---

## 56. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **`CF-455` 와 `CF-556` 이 「함께 세운다」를 드는데 검사가 서지 않았다.** 53-8 이 그 자리를 든다.
   미룸을 허락하는 조항이 원장에 없다.
2. **`CF-502` 의 종료 조건이 「조항이 서 있는데 충족되지 않은 자리」를 세지 않는다.**
3. **`CF-556` 의 검사 수가 구간 지시와 갈린다.** 지시가 셋, 그 항목이 둘이다.
4. **아크 종료의 요건 가운데 「새 낙착을 낳지 않았는가」를 재는 검사가 없다.**
5. **4단계의 대조 형이 둘로 갈려 있다.** 회계층이 상등 대조이고 용어집과 정의층이 부분집합 대조다.
6. **`OUTPUT_DIGEST` 가 `verify.sh` 자신의 판을 담지 않는다.** `CF-335` 가 그 발견을 든다.
7. **검사 16 이 `artifact` 발화 여섯을 계속 보고한다.** 앞 회차들과 같은 자리이고 읽는 쪽이 없다.

---

## 57. 15차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 18이며 **판별선은 꼬리의 두 필드를 읽는 검사
둘을 세우는 것**이다. **이 회차도 아크를 닫지 않는다.**

**검증기에 검사를 신설한 첫 회차다.** 앞선 열네 회차는 원장과 문서만 움직였고 페이즈 3이 비어
있었다. 이번에는 그 자리가 조작을 낳아 `scripts/check_wiki.py` 와 `docs/decisions/SPEC.md` 가
바뀌었다.

### 57-1. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차도 Lean 파일을 건드리지 않았다.

### 57-2. 변경 내역

받은 커밋은 `7e581bf` 다. 카드마다 커밋을 갈랐다.

| 커밋 | 카드 | 무엇을 바꾸었나 |
|---|---|---|
| `5a111e3` | CD-01 | 아크 레지스터에 열여덟 번째 페이즈와 열두 번째 패치를 세움 |
| `fc68124` | CD-02 | 엔트리 카드 열(`CF-557`~`CF-566`)을 `decisions.json` 에 병합. 170 행 |
| `51918d9` | CD-03 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |
| `80ec18b` | CD-07 | 검사 26·27 을 검증기와 명세에 세움. 57 행 |

`CD-01` 은 갈래의 팔 ⓒ 를 탔고 `CF-383` 의 다섯 번째 적용이다. `CD-04` 는 열거하고 멈추는 카드라
조작도 커밋도 낳지 않았다.

**`CD-07` 은 조작이 넷인데 커밋을 하나로 세웠다.** 카드가 단위이고 §5-2 의 되돌림 결합 표가 두
파일을 다 그 카드 하나에 묶으므로, 커밋을 가르면 되돌림이 카드보다 잘게 갈린다. 지시서가 이
판정을 들지 않아 집행이 판정했고 결정 세션이 승인했다.

### 57-3. 검사 스물다섯이 스물일곱이 됐다

`CF-566` 이 요구한 검사 둘이 섰다. 검사 26 은 꼬리의 `clarifies` 가 실재하고 폐기되지 않은 항목을
가리키는지를, 검사 27 은 `resolves` 가 `phrase` 와 `absolute` 만 갖고 그 `phrase` 가 대상 항목의
산문 필드에 실제로 있는지를 본다.

```
검사 27개 가운데 25개 수행, 실패 0개
[check:wiki26-clarify-target] OK   - 꼬리 41건
[check:wiki27-clarify-resolves] OK - 꼬리 41건 · 지목 78건
```

**그 계수가 통과의 뜻을 가른다.** 꼬리가 41건이고 지목이 78건이므로 이 통과는 대상이 비어서 난
것이 아니다.

**검사 27 은 대상의 실재와 비폐기를 다시 보지 않고 검사 26 에 넘긴다.** `CF-563` 이 그 몫의 가름을
든다.

### 57-4. 음성 대조 여섯이 각각 하나만 잡았다

**사본에 원장만 옮기지 않고 검증 스크립트와 Lean 트리를 포함한 리포 전체를 옮겼다.** `CF-562` 가
그것을 든다. 사본 여섯 각각에서 주입 전에 `scripts/check_wiki.py` 와 `CrisisFramework/` 와
`decisions.json` 의 실재를 확인했고 전부 실재했다.

**판정은 종료 코드가 아니라 어느 검사가 실패했는지로 했다.**

| # | 주입 | 실패한 검사 | 종료 코드 |
|---|---|---|---|
| 1 | 주입하지 않는다 | 없음 | 0 |
| 2 | `clarifies` 를 없는 id 로 바꾼다 | 26 | 1 |
| 3 | `clarifies` 를 폐기된 항목으로 바꾼다 | 26 | 1 |
| 4 | `resolves` 를 빈 배열로 둔다 | 27 | 1 |
| 5 | `resolves` 의 항에 키를 더한다 | 27 | 1 |
| 6 | `phrase` 를 대상의 산문에 없는 값으로 바꾼다 | 27 | 1 |

**여섯이 각각 검사 하나만 실패시켰고 둘을 실패시킨 행이 0 건이다.** 조건 1 이 주입 없이 실패 0 을
냈으므로 나머지 다섯의 실패가 사본의 불완전함이 아니라 주입에서 났다.

### 57-5. `CF-566` 의 셋째 자리가 서지 않았다

그 조항은 검사 둘을 **명세와 검증기와 음성 대조** 셋에 함께 세우라고 한다. 명세와 검증기는 섰고
음성 대조는 서지 않았다. 여섯 조건을 **돌렸으나 세우지 않았다** — 임시 사본에서 돌았고 리포에
남지 않는다.

기계로 쟀다. **`scripts/wiki_negative_control.py` 의 항이 28개이고 덮는 검사 번호가 25개이며,
`ORDER` 의 스물일곱 가운데 항이 없는 것이 26 과 27 둘뿐이다.** 리포 안에서 검사가 항 없이 서 있는
자리가 이 둘이 전부다.

**`CF-455` 와 `CF-556` 은 충족됐다.** `clarifies` 를 검사 26 이, `resolves` 를 검사 27 이 읽고,
`CF-556` 의 근거가 든 검사 둘의 내용이 선 검사의 문면과 같다. 다만 「함께」가 깨진 구간은 지워지지
않는다 — `CF-558` 이 그 형을 든다.

결정 세션이 음성 대조의 항이 리포에 상주하지 않는다는 집행의 소견을 이연 없이 처분했다.
원장에 넣지 않으며 같은 자리가 다시 올라오면 그때 논의한다. 다만 그 처분은 「조작을
지금 하지 않는다」이지 `CF-566` 이 충족됐다는 것이 아니다. 그 조항이 명세와 검증기와
음성 대조 셋을 들고 셋째가 서지 않았으며, 집행이 그것을 구간 5 에서 판정해 사안으로
올렸다.

### 57-6. 미전사분 넷

**축 둘을 썼다.** 낱말로 후보를 좁혀 적중의 실물을 전량 연 축과, 이 회차에서 실제로 한 일을
조항과 맞댄 축이다. **멈춘 것도 한 일에 넣었다.** 넷이 전부 축 ② 에서 나왔다.

1. **카드 하나가 조작 여럿을 지시할 때 커밋을 카드 단위로 가른다** (구간 4). 원장에서 이 형을
   요구하는 statement 가 0 건이다. 다섯(`CF-277`·`CF-278`·`CF-286`·`CF-346`·`CF-383`)이 basis 에서
   전제로만 들고, `CF-286` 만 statement 에서 드는데 그것은 CI 와의 갈림이지 요구가 아니다. 가장
   가까운 문면인 `CLAUDE.md` §8 의 「한 커밋에 한 가지 변경만 담는다」는 원장 적중이 0 건이고 절
   끝 출처가 `← 자체` 이며, 「한 가지 변경」이 조작 단위로도 카드 단위로도 읽힌다.
2. **검증기 자신에 조작을 거는 회차의 판별** (구간 4). `CLAUDE.md` §5 가 「**CI 워크플로 파일**을
   고쳐 통과시키지 않는다」를 들고 그 대상이 워크플로 파일이라 검증기 자신은 그 밖이다. 원장에서
   「실패가 산출물」 적중이 0 건이다. 카드가 지시한 신설과 실패를 통과시키려는 고침을 가르는
   처분이 이 회차의 호출 프롬프트에만 있었다.
3. **해시의 차분은 상대의 보존을 요구한다** (구간 4). `CF-472` 가 움직인 줄의 특정을 요구하나 그
   차분의 상대인 조작 전 판의 출력을 보존하라는 조항이 없다. 커밋 메시지가 나르는 것은 해시 값
   하나뿐이고 줄이 아니다. 집행이 조작을 임시로 물려 전판을 다시 재고 사본에서 되살렸으며,
   산출물을 잃을 수 있는 경로인데 근거가 없다.
4. **재발행이 앞 판의 커밋을 무효화할 때의 수단** (구간 1). 원장의 되돌림 조항 넷
   (`CF-278`·`CF-399`·`CF-401`·`CF-402`)은 전부 카드가 드는 되돌림 명령을 대상으로 하고 이 자리를
   들지 않는다. 결정 세션의 지시는 「커밋을 되돌린다」까지였고 수단을 정하지 않았다.

**집행의 결손은 0 건이다.** `CF-566` 의 셋째 자리가 서지 않은 것은 집행의 결손이 아니다. 카드가
그 조작을 지시하지 않았고 카드 없이 착수하면 집행 문면을 어기기 때문이며, `CF-557` 이 그 논증을
그대로 든다. **그 자리는 `CF-557` 이 든 네 번째 상태이고 이번에는 그 회차를 지시한 조항 자신 위에
섰다.**

### 57-7. 미전사분의 계수

| 구간 | 카드 | 미전사분 |
|---|---|---|
| 1 | CD-01 | 1건 |
| 2 | CD-02 | 0건 |
| 3 | CD-03 | 0건 |
| 4 | CD-07 | 3건 |
| 5 | CD-04 | 0건 |
| 6 | CD-05 · CD-06 | 0건 |
| 합계 (집행의 몫) | | **4건** |

`CF-353` 에 따라 집행의 구간만 셌다. **결정 세션이 넷을 전부 받고 하나를 더해 다섯이다.** 그 하나는
모의가 정본을 부르지 않아 `scripts/wiki_negative_control.py` 가 대장에서 빠진 것이며, 그것이
`CF-566` 의 셋째 자리가 서지 않은 원인이다.

`CF-502` 로 재면 집행을 구속하면서 원장 밖인 문면이 **4** 다. 앞 회차는 0 이었다. **이 회차는 아크를
닫지 않으므로 그 계수가 관문이 아니라 뒤 페이즈의 재료다**(`CF-351`).

### 57-8. 해시

| 구간 | 카드 | `OUTPUT_DIGEST` |
|---|---|---|
| 1 | CD-01 | `537d14611609` |
| 2 | CD-02 | `f159ea44e910` |
| 3 | CD-03 | `f159ea44e910` |
| 4 | CD-07 | `2a78b22adb3d` |
| 5 | CD-04 | `2a78b22adb3d` |

**값이 움직인 구간이 둘이다.** 병합(구간 2)에서 움직인 줄이 셋이고 전부 원장 계수를 내는 줄이다.
검사 신설(구간 4)에서 움직인 자리가 셋이며, 조작 전후의 출력을 둘 다 재어 맞댔다.

```
> [check:wiki26-clarify-target] OK  검사 26 — ...
>     - 꼬리 41건
> [check:wiki27-clarify-resolves] OK  검사 27 — ...
>     - 꼬리 41건 · 지목 78건
< 검사 25개 가운데 23개 수행, 실패 0개
> 검사 27개 가운데 25개 수행, 실패 0개
< OUTPUT_DIGEST=f159ea44e910
> OUTPUT_DIGEST=2a78b22adb3d
```

정규화 뒤 빠진 줄이 2 이고 더해진 줄이 6 이다. 그 밖의 줄은 움직이지 않았다.

---

## 58. 해석 (관측값 아님)

- **검사를 세우는 것과 그 검사가 잡는지를 세우는 것이 다르다.** 검증기와 명세에 둘을 세우니 검사가
  스물일곱이 됐으나, 그 둘이 잡아야 할 위반을 만드는 항은 리포에 남지 않았다. **앞 회차가 「검사가
  없다는 것이 통과로 드러난다」를 관측했는데 이번 자리는 「항이 없다는 것이 통과로 드러난다」이고
  한 층 아래다.**
- **네 번째 상태가 자기를 지시한 조항 위에 섰다.** `CF-557` 이 앞 회차에서 그 부류를 처음 세웠고,
  그것을 해소하라고 선 `CF-566` 자신이 이번에 같은 상태가 됐다. **부류를 세운 것이 그 부류의
  재발을 막지 않는다.**
- **조작이 없는 자리에서 미전사분이 셋 나왔다.** 넷 가운데 셋이 구간 4 에서 났는데 그 구간이 이
  아크에서 처음으로 검증기를 건드린 자리다. **새 종류의 조작을 처음 하면 그 조작을 구속하는 문면이
  아직 원장에 없다**는 것이 계수로 드러난 셈이다.
- **`CF-502` 의 값이 0 에서 4 로 되돌아갔다.** 그 조건이 단조롭게 줄지 않는다. 앞 회차가 0 을 내어
  종료가 가까워 보였으나, 아크가 새 종류의 일을 하면 값이 다시 선다.

---

## 59. 진술을 바꿔야만 통과할 것 같은 지점

**없다.** 이 회차는 `theorem` 과 `def` 를 하나도 세우지 않았고 Lean 파일의 변경이 0 건이다.
**검증기와 CI 워크플로를 고쳐 통과시킨 자리가 없다.** 이 회차가 검증기를 바꾸지만 그것은 카드가
지시한 신설이며, 검사가 실패했을 때 그것을 통과시키려 고치는 것과 다르다. 음성 대조의 여섯이
전부 기대대로 잡혔고 값을 맞추려 고친 자리가 없다.

---

## 60. 사람의 판단이 필요해 보이는 것 (실행하지 않음)

1. **`CF-566` 의 셋째 자리가 서지 않았다.** 57-5 가 그 자리를 든다. 결정 세션이 조작을 지금 하지
   않기로 처분했으므로 그 조항은 충족되지 않은 채 선다.
2. **`CF-502` 의 종료 조건이 「조항이 서 있는데 충족되지 않은 자리」를 세지 않는다.** 앞 회차에서
   섰고 이번 회차가 그 사례를 하나 더 냈다.
3. **카드 단위 커밋을 요구하는 조항이 원장에 없다.** 57-6 의 첫째다. `CLAUDE.md` §8 의 문면이 조작
   단위로도 읽힌다.
4. **검증기 자신을 고치는 것과 통과시키려 고치는 것을 가르는 조항이 없다.** 57-6 의 둘째다.
5. **`OUTPUT_DIGEST` 의 차분에 쓸 전판의 출력을 보존할 자리가 없다.** 57-6 의 셋째다.
6. **아크 종료의 요건 가운데 「새 낙착을 낳지 않았는가」를 재는 검사가 없다.** 앞 회차와 같은
   자리다.
7. **4단계의 대조 형이 둘로 갈려 있다.** 회계층이 상등 대조이고 용어집과 정의층이 부분집합 대조다.
8. **`OUTPUT_DIGEST` 가 `verify.sh` 자신의 판을 담지 않는다.** `CF-335` 가 그 발견을 드는데, 이
   회차가 검증기를 바꾸고도 그 변경 자체는 해시에 담기지 않았다.
9. **검사 16 이 `artifact` 발화 여섯을 계속 보고한다.** 앞 회차들과 같은 자리이고 읽는 쪽이 없다.

---

## 61. 16차 세션 — 관측값

검증일: 2026-09-20. 이 회차는 `charter` 아크 페이즈 20이며 **판별선은 `charter-19` 를 아크
레지스터에 소급 선언하고 `CF-566` 을 폐기한 뒤 아크를 닫는 것**이다. **이 회차가 이 아크를
닫는다.**

**이 아크의 마지막 페이즈다.** 세션 지시 §2.2 가 「아크의 마지막 페이즈는 병합만 하고 새 낙착을
낳지 않는다」를 드는 그 자리이며, 카드가 둘이고 조작이 다섯이다.

### 61-1. 빌드

세 파일 전량 통과이고 `sorry` 와 실패가 없다. `Build completed successfully (978 jobs)` 이며
error 0 warning 0 이다. 이 회차도 Lean 파일을 건드리지 않았다.

### 61-2. 변경 내역

받은 커밋은 `062107b` 다. 구간마다 커밋을 갈랐고 되돌릴 수 없는 조작 둘은 그 안에서 또 갈랐다.

| 커밋 | 구간 | 무엇을 바꾸었나 |
|---|---|---|
| `8d72447` | 1 | 아크 레지스터에 페이즈 둘과 패치 둘을 세우고 카드 둘을 병합. 61 행 |
| `26435ca` | 2 | 등가 검증 뒤 카드 파일 삭제. 추적 대상이 아니라 빈 커밋 |
| `56d82a1` | 2 | `status` 를 `closed` 로, `closed` 를 `2026-09-20` 으로. 2 행 |
| `8712549` | 3 | `CLAUDE.md` §9 의 `decisions` 511 · `retirements` 24. 2 행 |

**시작 전에 작업 트리의 `docs/arcs.json` 변경을 버렸다.** 폐기된 `charter-19` 초판이 남긴 선언
하나와 패치 하나였고, 그 초판은 파일이 이미 지워져 리포에 없었다. **선언은 남고 그것을 낳은
문서는 없는 상태였다.** 그 변경이 어느 추적 커밋에도 없어 `git` 으로 복원할 수단이 없으므로
집행이 버리기 전에 문면 전량을 보고에 실어 보존했다.

**한 구간에 되돌릴 수 없는 조작이 둘인 자리가 처음 났다.** 카드 파일 삭제와 아크 종료이며 커밋을
갈랐다. 되돌림이 그 둘을 따로 걸 수 있어야 하기 때문이고, 삭제는 `git revert` 로 되살아나지
않으므로 한 커밋이었으면 되돌림이 비대칭이 됐을 것이다.

### 61-3. `charter-19` 와 `charter-20` 이 소급 선언됐다

`charter-19` 가 `CLAUDE.md` 에 소절 둘을 세웠으나 **아크 레지스터에 선언되지 않았다.** 그 페이즈가
원장에 아무것도 싣지 않아 검사 3 이 볼 것이 없었고 선언 없이도 통과했다.

**값 정본이 한 페이즈를 빠뜨린 채 아크가 닫히면 그 산출이 어느 페이즈의 것인지가 사라진다.**
그래서 닫기 전에 둘을 함께 세웠다. `phases` 가 열여덟에서 스물로, `patches` 가 열둘에서 열넷으로
늘었고 앞의 것이 순서까지 보존됐다.

**검사 3 이 선언 없는 페이즈를 잡는 것은 그 페이즈가 원장에 항목을 실을 때뿐이다.** 원장을
건드리지 않는 페이즈는 그 그물 밖이며, 이것이 `CF-348` 이 든 「ID 가 그물이고 ID 없는 문면이 그
그물 밖」과 같은 형이다.

### 61-4. `CF-566` 을 폐기했다

그 조항이 「검사 둘을 명세와 검증기와 음성 대조에 함께 세운다」를 드는데 **셋째 자리가 서지
않았다.** 음성 대조에 그 두 검사의 항이 없고, 그것을 세우려면 페이즈를 하나 더 열어야 한다.
**셋째 자리를 요구하지 않기로 하고 조항을 폐기했다.**

폐기는 대상을 죽이므로 `CF-566` 이 이제 살아 있는 조항이 아니다. **검사 10 이 폐기된 id 를
23 건에서 24 건으로 훑었고 그것을 살아 있는 것처럼 드는 자리를 0 건 잡았다.**

음성 대조가 덮지 않는 검사가 둘 남는 것은 그 값으로 받아들인다. **항이 없다는 것은 그 둘이 잡는
위반을 주입해 본 적이 없다는 뜻이지 그 둘이 돌지 않는다는 뜻이 아니다.** 검사 26 과 27 은 꼬리
41 건과 지목 78 건을 실제로 보고 있다.

### 61-5. 아크 종료 검사 둘이 처음 실제로 돌았다

`scripts/verify.sh` 는 검증기를 `--arc-close` 없이 부르므로 검사 20 과 21 이 언제나 건너뛰어진다.
`CF-339` 가 그 사실과 「그 증거가 집행의 보고에만 남는다」를 든다. 그래서 집행이 따로 불렀다.

```
python3 scripts/check_wiki.py --arc-close charter
```

```
[check:wiki20-arc-holes] OK  검사 20 — 그 아크에 걸린 구멍마다 해소됐거나 이관됐는가
    - 아크 `charter` 의 구멍 0건
[check:wiki21-arc-blocking] OK  검사 21 — 그 아크에 걸린 blocking 구멍마다 발화했거나 해소됐거나 이월됐는가
    - 아크 `charter` 의 blocking 구멍 0건

검사 27개 가운데 27개 수행, 실패 0개
원장 검증 전량 통과
```

**둘 다 `OK` 이고 본 것이 구멍 0 건과 blocking 구멍 0 건이다.** 종료 코드 0. `verify.sh` 는 평소대로
스물다섯을 수행했고 이 호출이 스물일곱을 수행했다. **두 출력의 수행 계수가 25 와 27 로 다른 것이
정상이며** 그 차이가 정확히 이 둘이다.

`CF-343` 이 「아크 종료 검사 둘의 음성 대조가 아크를 닫기 전까지 공허했다」를 들었고, 이번에
그 둘이 실물 위에서 돌았다.

### 61-6. 검사 5 가 처음으로 대상을 받았다

그 검사는 **날짜 축**으로 가른다. 닫힌 아크의 항목 가운데 `origin.date` 가 그 아크의 `closed` 보다
뒤인 것만 잡으며 `date > closed` 하나가 유일한 신호다.

조작 전에 예측하고 조작 뒤에 확인했다.

| | 예측 | 실측 |
|---|---|---|
| 검사 5 의 대상 | 0 + 568 = 568건 | **568건** |
| 그 가운데 걸리는 것 | 0건 | **0건** |

`charter` 항목 568 건의 `origin.date` 가 `2026-09-19` 가 246 건이고 `2026-09-20` 이 322 건이라
`closed` 보다 뒤인 것이 0 건이다. **같은 날의 항목 322 건이 그 검사를 빠져나가며** 스키마의 입도가
날짜이기 때문이다. 이 아크가 하루에 닫혀서이고 결함이 아니라 설계의 알려진 값이다.

`CF-338` 이 「닫힌 아크를 가리키는 항목이 없어 검사 5 가 한 번도 밟힌 적이 없었다」를 들었다.
`primary` 를 가리키는 원장 항목이 0 건이었기 때문이며, 오늘이 그 검사가 처음으로 실제 대상을
받은 날이다.

### 61-7. 이 아크의 종료 계수

| 축 | 값 |
|---|---|
| 페이즈 | **스물** |
| 패치 | **열넷** |
| 원장 | **568** (`decisions` 511 · `deferred` 33 · `retirements` 24 · `rejected` 0) |
| 검사 | **스물일곱** (아크 종료 모드에서 스물일곱 수행, 실패 0) |
| 구멍 | 0건 |
| blocking 구멍 | 0건 |
| 결번 | 0건 (`CF-1`~`CF-568`) |
| 아크 상태 | `closed` · `closed` 가 `2026-09-20` |

### 61-8. 해시

| 시점 | `OUTPUT_DIGEST` |
|---|---|
| 구간 1 (병합) | `fa062cb56913` |
| 구간 2 (카드 파일 삭제) | `fa062cb56913` |
| 구간 2 (아크 종료) | `be44a7d9cffc` |
| 구간 3 (`CLAUDE.md` §9) | `be44a7d9cffc` |

**값이 움직인 구간이 둘이다.** 병합에서 움직인 줄이 다섯이고 넷이 원장 계수를 내는 줄이다. 아크
종료에서 움직인 줄이 둘이고 하나가 검사 5 의 note 줄이다.

```
<     - 닫힌 아크를 가리키는 항목 0건
>     - 닫힌 아크를 가리키는 항목 568건
```

**`CLAUDE.md` §9 의 갱신은 값을 움직이지 않았다.** 그 파일이 검사 24 의 유니버스에 들지만 표의
숫자를 바꾸는 것이 규율 ID 토큰을 더하지도 줄이지도 않는다. **유니버스에 드는 것과 그 조작이
계수를 움직이는 것이 다르다.** `BUILD_LOG.md` 는 검사 24 의 유니버스 밖이다.

`charter` 아크가 스무 페이즈로 닫힌다. 마지막 세 페이즈가 이 아크의 성격을 드러낸다.
`charter-18` 이 검증기에 검사 둘을 세웠고, `charter-19` 가 그 과정에서 드러난 결함 여섯을
보고 「검증기가 잡을 수 있는 것이 하나도 없다」는 것을 확인해 원장의 문턱을 세웠으며,
`charter-20` 이 그 문턱을 처음 적용해 카드 둘로 닫았다. **조항을 세우는 것이 재발을 막지
못한다는 것이 이 아크의 실측이고, 그래서 마지막 조항이 「무엇을 조항으로 만들지 않을
것인가」를 정한 것이다.**

이 아크의 마지막 두 페이즈에서 검증기의 검사 둘이 처음으로 실제 대상을 받았다. 검사 5 는
열아홉 페이즈 동안 대상이 0 건이어서 한 번도 밟힌 적이 없었고, 검사 20 과 21 은 아크 종료
커밋이 아니라는 이유로 줄곧 건너뛰어졌다. **설비가 서 있는 것과 그 설비가 무언가를 재고
있는 것이 다르다는 것을 이 아크가 마지막에 실측으로 보였다.**
