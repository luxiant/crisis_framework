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
