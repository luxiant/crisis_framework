# CLAUDE.md

이 리포지터리는 경제 위기 해석 프레임워크를 Lean 4 로 형식화해 **정의의 구멍을 드러내는** 연구
리포지터리다. 증명되지 않는 진술은 고칠 버그가 아니라 산출물이며, 빌드를 통과시키려고 진술을 바꾸지
않는다.

**이 문서는 조항을 두지 않는다.** 이 리포를 조작하는 규율은 리포 밖에 있는 결정 세션의 세션 지시와
그 부록이 든다. 이 문서는 리포를 처음 여는 사람과 도구에게 리포의 구성과 검증을 돌리는 길을 알린다.

## 구성

| 자리 | 드는 것 |
|---|---|
| `CrisisFramework/` | 형식층. 디렉터리가 층을 정한다 |
| `docs/baseline.md` | 값의 정본. 툴체인 핀과 층별 공리 기준선과 층별 금지 표와 검사가 읽는 기계 판독 블록 |
| `docs/arcs.json` | 아크와 페이즈와 패치의 값 정본 |
| `docs/decisions/` | 원장. 스키마와 검사 목록은 `docs/decisions/SPEC.md` 가 든다 |
| `docs/phases/` | 페이즈 종료 문서 |
| `docs/extractions/` | 추출 기록 |
| `docs/reading-queue-v0.md` · `docs/bundle-inventory-v0.md` | 참고자료 목록 |
| `scripts/` | 검증 설비와 결정 세션의 설비 |
| `Scratch/` | 검사와 탐색에 쓰는 코드. 빌드 타깃 밖이다 |
| `BUILD_LOG.md` | 회차별 역사 기록 |

## 검증

`bash scripts/verify.sh` 가 전량 검증의 진입점이며 CI 가 같은 것을 돌린다. 아크를 닫는 커밋에서는 그
아크의 이름을 첫 인자로 준다. 단계의 목록은 `scripts/vrun.py` 가 들고 원장 검증기의 검사 목록은
`docs/decisions/SPEC.md` 가 든다. 툴체인의 판은 `lean-toolchain` 이 들고 Mathlib 의 판은
`lakefile.toml` 과 `lake-manifest.json` 이 든다.
