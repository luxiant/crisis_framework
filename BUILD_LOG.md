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

프로젝트 루트: `/root/workspace/jjabtir_macro_model/crisis-framework`

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
cd /root/workspace/jjabtir_macro_model/crisis-framework
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
jjabtir_macro_model/
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
cd /root/workspace/jjabtir_macro_model/crisis-framework
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
