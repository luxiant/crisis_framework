# 읽기 대기열 v0 (2026-09-12)

O-1 ★ 구간 종료 시점에 보류된 논문 목록. 뭉치 전체는 `bundle-inventory-v0`에 있고, 이 문서는 **무엇을 언제 다시 꺼낼지**만 기록한다.

전제: 뭉치의 논문은 대부분 결국 읽는다. 이 문서는 배제 목록이 아니라 **순서 문서**다.

---

## 0. 규율 개정 기록 — 탐구 방향 §7

- **~~S-1~~ 폐기** (O-1 ★ 종료 시점)
  - 원문: "연속 3편의 논문이 §5 템플릿에 새 원소를 추가하지 않고 기존 원소의 사례만 추가하면 해당 단계의 읽기를 종료한다."
  - 폐기 사유: 필독(★) 지정과 충돌한다. ★는 뭉치 구조상 반드시 읽어야 하는 편이므로 포화 판정의 대상이 될 수 없고, 실제로 ★ 5편이 모두 새 원소를 추가해 포화가 성립할 여지가 없었다. 규율이 작동하지 않는 구간에 걸려 있었다.
  - 대체: **S-4**.
- **S-4 (신규)** — 포화 판정은 **비★ 구간에만** 적용한다. ★는 포화와 무관하게 전부 읽는다. 비★ 구간에서 연속 3편이 새 원소를 추가하지 않으면 해당 O-구간의 읽기를 종료한다.
- **S-5 (신규)** — 특정 구멍의 해결에 직결되는 논문은 O-구간 순서와 무관하게 **지목 참조**한다. 지목 참조한 편은 해당 구멍의 추출 기록에 붙이고, 별도 추출 기록을 만들지 않는다.

→ 다음 탐구 방향 개정 시 §7과 §11(폐기 레지스터)에 반영한다.

---

## 1. 지목 참조 대기 (S-5) — 구멍이 열릴 때 즉시

| 논문 | 대상 구멍 | 기대 재료 |
|---|---|---|
| Danielsson · Shin · Zigrand (2012), *Procyclical Leverage and Endogenous Risk* | **H-02** (실제 위험에 측정 대응 없음) | 측정 위험 ↔ 실제 위험의 되먹임을 정면으로 다루는 유일한 편. H-03(부도확률 불변 ≠ VaR/E 불변)도 여기 걸림 |
| Morris · Shin (2016), *Illiquidity Component of Credit Risk* | **H-22** (위기의 두 정의 충돌) | 지급불능 / 유동성 분해. 실패 양태 분할의 정본 재료 |
| Danielsson · Shin · Zigrand (2004), *The Impact of Risk Regulation on Price Dynamics* | H-09 (되먹임이 가정에 의존) | 규제 제약 → 가격 동학. 동학층 진입 시 |

---

## 2. D-3 사례 공급원 (상시 참조)

정의를 작성할 때마다 배제 사례를 여기서 조달한다. 추출 기록을 만들지 않고 사례 단위로 인용한다.

| 문헌 | 공급 사례 |
|---|---|
| Shin (2009), *Reflections on Northern Rock* | 도매조달 은행의 런. E-03 §3-4의 "제약 타이트닝형 런" 정본 사례 |
| Greenlaw · Hatzius · Kashyap · Shin (2008), *Leveraged Losses* | 2007-08 손실의 대차대조표 배분. 손실 배분처 추적의 사례 |
| Eichengreen, *Golden Fetters* (뭉치 밖, B-1 기록 대상) | 금본위제 = 중앙은행의 외화 축 제약. J-4·K-3 정본 사례 |
| Aramonte · Schrimpf · Shin (2023) §2 (E-04, 추출 완료) | 2020년 3월 국채시장. 신용위험 없는 자산에서 발원한 위기 |

---

## 3. O-1 잔여 (12편) — S-4 재판정 대상

O-2·O-3 종료 후 미해결 구멍이 남아 있으면 이 순서로 재개한다.

| 우선 | 논문 | 예상 기여 |
|---|---|---|
| 상 | Adrian · Colla · Shin (2012), *Which Financial Frictions?* | 마찰 유형 판별. 은행 대 시장 경로의 구분 기준 |
| 상 | Plantin · Sapra · Shin (2007), *Marking-to-Market* | 가격 → 제약 경로의 회계적 근거. L-4(회계층 `ℝ` 금지) 판단에 직접 관련 |
| 상 | Aramonte · Schrimpf · Shin (2021), *Non-bank Financial Intermediaries* | 비은행 노드 유형 목록. K-2(단계 열거) 보조 |
| 중 | Shin (2009), *Securitisation and Financial Stability* | 증권화가 총 부채를 확장하는 메커니즘. K-5 보조 |
| 중 | Adrian · Shin (2010), *The Changing Nature of Financial Intermediation* (SR 439) | 시장성 조달의 부상 |
| 중 | Adrian · Etula · Muir, *Financial Intermediaries and the Cross-Section of Asset Returns* | 레버리지가 가격 인자. PH-5 접속점 |
| 하 | Adrian · Boyarchenko (2012), *Intermediary Leverage Cycles* | DSGE. 대표주체라 노드 없음 — B-3 주의 |
| 하 | Adrian · Shin (2008), SR 346 | SR 328(E-02)과 중복 큼 |
| 하 | Adrian · Shin (2009), SR 360 | 14쪽 요약판 |
| 하 | Adrian · Shin (2008), *Liquidity and Financial Contagion* (FSR 챕터) | 위 셋과 중복 |
| 하 | Adrian · Shin (2009), SR 382, *The Shadow Banking System* | O-2 보조로 재배치 |

---

## 4. 다른 단계에서 필요해질 것

현 단계(PH-0~3) 범위 밖이지만 뭉치에 있고 나중에 쓴다.

| 단계 | 문헌군 |
|---|---|
| PH-3 (동학층) | Morris·Shin 전략적 보완성 8편 — 신념·조정 primitive. 대차대조표 primitive와 다른 계통이므로 층 진입 시 별도 판정 필요 |
| PH-4 (전파) | di Iasio·Pozsar 2편(형식 모형), Cifuentes·Ferrucci·Shin *Liquidity Risk and Contagion* |
| PH-5 (예측) | Adrian·Boyarchenko·Giannone *Vulnerable Growth*, Adrian 외 *Term Structure of Growth-at-Risk* |
| 노드 유형 확장 | Kim·Shin *Theory of Supply Chains*, Banerjee·Shin·Vidal Pastor *Elasticity of Money in Production Networks* — 비금융기업 대차대조표 |
| J-3 관측 과제 | BIS 2025 Triennial 계열 3편 (뭉치 밖, B-1 기록 대상) — FX 스왑 총액 복원 데이터 |
| 제약의 규제적 원천 | 규제·정책 9편. B-5에 따라 처방은 비추출, 제약의 근거만 확인 |

---

## 5. 현 시점 읽기 순서

1. **O-2 ★ 4편** — Pozsar·Adrian·Ashcraft·Boesky (지도) → Pozsar 2014 (위계) → Pozsar·Singh 2011 (담보 연쇄) → Pozsar 2011 (현금풀)
2. O-2 비★ 7편 — S-4 적용
3. O-3 ★ 4편
4. O-3 비★ 12편 — S-4 적용
5. 미해결 구멍 점검 → §1·§3에서 지목 재개
