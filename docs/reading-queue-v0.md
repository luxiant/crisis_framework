# 읽기 대기열 v0 (2026-09-12)

O-1 ★ 구간 종료 시점에 보류된 논문 목록. 뭉치 전체는 `bundle-inventory-v0`에 있고, 이 문서는 **무엇을 언제 다시 꺼낼지**만 기록한다.

전제: 뭉치의 논문은 대부분 결국 읽는다. 이 문서는 배제 목록이 아니라 **순서 문서**다.

**폐기 지목:** S-1, S-5. S-1 은 이 문서 §0 이 그 폐기의 원 기록이고, S-5 는 §0 이 그 조항이 섰을 때의 문면을 든다. 역사 서술이므로 검사 24 가 면제한다.

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

## 1. 지목 참조 대기 (S-7) — 구멍이 열릴 때 즉시

| 논문 | 대상 구멍 | 기대 재료 |
|---|---|---|
| Danielsson · Shin · Zigrand (2012), *Procyclical Leverage and Endogenous Risk* | **H-02** (실제 위험에 측정 대응 없음) | 측정 위험 ↔ 실제 위험의 되먹임을 정면으로 다루는 유일한 편. H-03(부도확률 불변 ≠ VaR/E 불변)도 여기 걸림 |
| Morris · Shin (2016), *Illiquidity Component of Credit Risk* | **H-22** (해소됨) · 기록 소실 복구 · **소진** | 지급불능 / 유동성 분해. **소진됐다.** 다시 읽어 S-7 에 따라 세운 추출 기록이 `docs/extractions/extraction-17-morris-shin-2016.md` (E-17) 이다 |
| Danielsson · Shin · Zigrand (2004), *The Impact of Risk Regulation on Price Dynamics* | H-09 (되먹임이 가정에 의존) | 규제 제약 → 가격 동학. 동학층 진입 시 |
| Clack · McGonagle (2019), *Smart Derivatives Contracts* | **H-66** (관측자 상대성) · **소진** | 사건이 일어나는 층위 넷과 그 관측의 어려움. `claim-5` 가 읽고 E-35 를 세웠다 |
| Brammertz (2018 무렵), *Smart Financial Contracts Revisited* | **H-66** · **소진** | Szabo 의 관측 가능성 · 검증 가능성 · 비밀성의 구분. `claim-5` 가 읽고 E-36 을 세웠다 |
| Byrne (2007), *UCP600: An Exercise in International Private Sector Self Regulation* | **H-60** (검증 가능성의 상대성) · **소진** | 사기 예외와 선의의 판정이 지역법에 있다. `claim-5` 가 읽고 E-34 를 세웠다 |
| **세관 신고 서식의 칸 열거** (콜롬비아 · 칠레 · 터키 가운데 어느 하나. 당국의 서식이거나 그 자료의 칸을 열거한 편) | `CF-699` (세관 경로가 송장 통화를 담는지 미확인) | 송장의 통화가 신고의 칸으로 서는가. 서면 UCP 600 제18조 (a) 가 신용장 칸에서 송장 통화와 청구권 통화를 묶으므로 세관 경로 하나로 CQ-fin-2 의 네 축이 다 선다. E-38 이 콜롬비아 자료의 칸을 열거하는데 통화가 없다 |

---

## 2. D-3 사례 공급원 (상시 참조)

정의를 작성할 때마다 배제 사례를 여기서 조달한다. 추출 기록이 있는 편은 그 기록을 지목하고, 없는 편은
사례 단위로 인용한다. S-7 이 지목 참조한 편에도 추출 기록을 남기게 하므로 두 부류가 함께 든다.

| 문헌 | 공급 사례 |
|---|---|
| Shin (2009), *Reflections on Northern Rock* | 도매조달 은행의 런. E-03 §3-4의 "제약 타이트닝형 런" 정본 사례 |
| Greenlaw · Hatzius · Kashyap · Shin (2008), *Leveraged Losses* | 2007-08 손실의 대차대조표 배분. 손실 배분처 추적의 사례 |
| Eichengreen, *Golden Fetters* (뭉치 · 배제 사례와 관측 과제의 보조) | 금본위제 = 중앙은행의 외화 축 제약. J-4·K-3 정본 사례 |
| Aramonte · Schrimpf · Shin (2023) §2 (E-04, 추출 완료) | 2020년 3월 국채시장. 신용위험 없는 자산에서 발원한 위기 |
| Pozsar · Adrian · Ashcraft · Boesky (2010), FRBNY SR 458 부록 (E-06, 추출 완료 · §10 덧붙임) | 계약상 크레딧 라인을 통한 유동성 풋. 담보가치 하락에서 ABCP 롤 실패와 헤어컷 상승을 거쳐 풋이 발동한 연쇄. C-10 의 검증 가능 신호 위 발동조건의 정본 사례 |
| Claessens · Pozsar · Ratnovski · Singh (2012), *Shadow Banking: Economics and Policy* (IMF SDN/12/12, 추출 기록 없음 · S-7 로 사례만 인용) | 암묵적 유동성 풋. 시장 조달이 마르자 은행이 기구를 대차대조표로 받거나 무너뜨리고 풋을 이행하지 않은 사례. 위 행과 짝을 이루어 신호 분할의 V-4 사례가 된다 |
| ICC, *UCP 600* (뭉치 · zip 밖 구성원, 추출 기록 E-21) | 화환신용장의 조문. 제7조 (b)의 개설 시점과 제6조 (d)의 유효기일 명시와 제30조의 허용 편차가 청구권 타입의 시점 축과 금액 항의 정본 사례다. 제36조의 불가항력이 `Claim.wellFormed` 의 배제 사례다 |
| Flood · Goodenough, *Contract as Automaton* (뭉치 · 계약 표현, 추출 기록 E-22) | 계약을 결정적 유한 오토마톤으로 옮기는 설계. 청구권 타입이 기각한 대체 정의의 원전이며 D-3 의 역사 사례가 아니라 D-2 3항의 공급원이다 |
| Peyton Jones · Eber · Seward, *Composing Contracts* (뭉치 · 계약 표현, 추출 기록 E-23) | 지급을 축으로 삼고 조건을 부속으로 두는 조합자 설계. 위와 같이 D-2 3항의 공급원이고 `Obs` 를 계약과 다른 타입으로 두는 선택의 선례다 |
| CGFS, *Trade Finance: Developments and Issues* (뭉치 · 교역 금융, 추출 기록 E-24) | 업계가 새로 도입한 은행지급확약(BPO). 은행이 서류 없이 자료 대조로 지급을 확약하므로, 결제 방식 열거가 확약의 조건을 가르지 못하는 배제 사례다. 결제 방식이 시점에 따라 새로 생긴 K-8 의 실례이기도 하다 |
| Antràs · Foley (2015), *Poultry in Motion* (뭉치 · 교역 금융, 추출 기록 E-25) | 2008-09년 위기에 매출이 크게 줄었는데 방식별 몫은 거의 그대로였고, 그 아래에서 이탈과 진입이 상쇄됐다. 몫 판정의 배제 사례다. 선지급 절반과 신용장 절반이 섞인 조건이 선지급으로 분류되는 것은 분류 규칙의 배제 사례다 |
| Niepmann · Schmidt-Eisenlohr (2014), *International Trade, Risk and the Role of Banks* (뭉치 · 교역 금융, 추출 기록 E-26) | 은행 설문이 추정한 은행 개입 교역의 비중이 SWIFT 로 잰 비중보다 훨씬 컸다. 경로 명세가 칸만 선언하고 값의 편향을 걸러 내지 못하는 배제 사례다 |
| Byrne (2007), *UCP600: An Exercise in International Private Sector Self Regulation* (뭉치 · 교역 금융, 추출 기록 E-34) | 서류 아닌 조건을 개설은행이 심사하게 바꾼 약정이 보증채무로 취급된 미국 항소법원의 판결. 신용장 칸의 경계가 C-10 의 선과 겹친다는 사례다 |
| Ahn (2014), *Understanding Trade Finance* (뭉치 · 교역 금융 · zip 밖, 추출 기록 E-37) | 한국이 1998년 완전 자유화에 이르기까지 외환 관리를 단계적으로 풀었고 그때마다 신용장 비중이 떨어졌으며, 자유화 뒤로도 비중이 다른 나라보다 높게 남았다. **결제 방식의 분포가 당사자의 경제적 비교만으로 정해진다고 보는 정의의 배제 사례다.** 행정 조치와 그 관행이 분포를 가른다 |
| Ahn · Sarmiento (2019), *Letter-of-Credit Import Transactions in Colombia* (뭉치 · 교역 금융 · zip 밖, 추출 기록 E-38) | 콜롬비아에서 신용장이 수입 전체에서 차지하는 몫은 작은데, 신용장을 쓰는 수입자는 자기 수입의 대부분을 신용장으로 치른다. **전체 비중으로 칸의 크기를 재는 판정의 배제 사례다.** 몫이 작다는 것과 그 칸에 걸린 당사자가 적다는 것이 다르다 |
| Demir · Javorcik (2018), *Don't throw in the towel, throw in trade credit!* (뭉치 · 교역 금융 · zip 밖, 추출 기록 E-39) | 신용장에 고정 수수료가 붙어 금액이 작은 거래에서는 수지가 맞지 않고, 그래서 큰 선적이 신용장으로 간다. **신용장 경로로 관측한 값을 교역 전체의 표본으로 읽는 명세의 배제 사례다.** 그 칸이 금액으로 쏠려 있다 |
| Casas · Meleshchuk · Timmer (2022), *The Dominant Currency Financing Channel* (뭉치 · 교역 금융 · zip 밖, 추출 기록 E-40) | 콜롬비아 페소가 크게 절하됐을 때 외화부채를 진 기업 가운데 수출하는 기업과 외화자산을 보유한 기업과 외환 파생을 쓰는 기업에서는 수입 압축이 나타나지 않았다. **통화 불일치를 외화부채만으로 정의하는 것의 배제 사례다.** 자산과 수익과 파생이 함께 들어야 한다 |
| Bénétrix · Gautam · Juvenal · Schmitz (2019), *Cross-Border Currency Exposures* (뭉치 · 교역 금융 · zip 밖, 추출 기록 E-41) | 증권투자 채무의 통화 구성을 국제결제은행 발행 통계로 메우는데 그 통계가 국내 발행분을 담지 않아, 신흥국의 자국통화 발행 비중이 과소추정된다. **경로가 값을 내면 그 값이 실측이라고 보는 명세의 배제 사례다.** E-26 행과 짝을 이루며, 앞은 값의 편향이고 이것은 값의 출처다 |
| SWIFT, *Category 7 Message Reference Guide* (뭉치 · 교역 금융 · zip 밖, 추출 기록 E-42) | MT 700 에서 통화와 금액을 담는 32B 는 필수이고 어휘가 ISO 4217 로 닫혀 있는데, 물품을 담는 45A 는 선택이고 자유 서술이라 분류 코드가 없다. **한 경로가 모든 축을 같은 정도로 가른다고 보는 명세의 배제 사례다** |
| BCBS · IOSCO, *Margin requirements for non-centrally cleared derivatives* (뭉치 · 증거금과 담보의 규범 · zip 밖, 추출 기록 E-43) | 개시증거금의 재담보를 원칙으로 금지하고 열두 조건 아래 1회만 허용하며 분리보관을 요구하는데, 변동증거금에는 그 제한이 없다. **재담보 권리를 불린 하나로 두는 정의의 배제 사례다.** 그 권리가 조건부이고 조건이 자산의 취급과 당사자의 행위와 상대의 자격 셋에 걸린다 |
| ISDA, *Credit Support Annex* 영국법 이전형과 뉴욕법 담보권형 (뭉치 · 증거금과 담보의 규범 · zip 밖, 추출 기록 E-43) | 같은 기능을 영국법은 소유권 이전으로 뉴욕법은 담보권 설정으로 짜고, 반환 대상이 등가물과 그 물건으로 갈린다. **소유권이 넘어가는 제공과 담보권만 서는 제공을 같은 모양으로 두는 정의의 배제 사례다.** 도산 시 처리도 일괄정산과 담보권 실행으로 갈린다 |

---

## 3. O-1 잔여 (12편) — S-4 재판정 대상

O-2·O-3 종료 후 미해결 구멍이 남아 있으면 이 순서로 재개한다.

| 우선 | 논문 | 예상 기여 |
|---|---|---|
| 상 | Adrian · Colla · Shin (2012), *Which Financial Frictions?* | 마찰 유형 판별. 은행 대 시장 경로의 구분 기준 |
| 상 | Plantin · Sapra · Shin (2007), *Marking-to-Market* | **소진.** 가격 → 제약 경로의 회계적 근거. L-4(회계층 `ℝ` 금지) 판단에 직접 관련. 읽고 E-16 을 세웠으며 새 원소 셋을 더해 S-4 의 포화 카운트가 0 이 됐다 |
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
| 노드 유형 확장 | Banerjee·Shin·Vidal Pastor *Elasticity of Money in Production Networks*. 비금융기업 대차대조표를 든다. **Kim·Shin *Theory of Supply Chains* 는 이 배정에서 빠졌다.** `claim-4` 가 E-19 와 짝으로 당겨 읽었고 그 추출 기록이 E-20 이다 |
| J-3 관측 과제 | BIS 2025 Triennial 계열 3편 (뭉치. 둘은 관측 과제의 보조이고 하나는 Tier C) — FX 스왑 총액 복원 데이터 |
| 제약의 규제적 원천 | 규제·정책 10편. B-5에 따라 처방은 비추출, 제약의 근거만 확인 |
| 뒤 아크의 CQ | 뭉치 인벤토리의 「다른 CQ 덩어리의 재료」 일곱 편. 연결은 그 아크를 열 때 다시 판정한다 |

---

## 5. 현 시점 읽기 순서

**★ 열셋이 전부 읽혔다.** O-1 다섯(E-01 ~ E-05), O-2 넷(E-06 ~ E-09), O-3 넷(E-12 ~ E-15)이다.
S-4 가 포화 판정을 비★ 에만 걸므로 구간의 종료는 이제 비★ 에서만 판정된다.

**구간의 진행은 멈춰 있고 읽기를 S-7 의 지목 참조가 끌고 있다.** E-17 이후로 읽은 편이 전부 구멍이나
CQ 에 직결되어 구간 순서 밖에서 들어왔다. **지목 참조한 편은 S-4 의 포화 카운트에 들지 않으므로,
그 경로로 아무리 읽어도 구간이 종료되지 않는다.**

| 순위 | 무엇 | 상태 |
|---|---|---|
| 1 | **지목 참조 (S-7)** | 아크가 여는 구멍에서 조달하고 §1 의 대기 목록을 함께 본다. **현 아크의 읽기가 여기서 나온다** |
| 2 | **O-1 비★ 잔여** | §3 이 든다. 재개됐고 Plantin · Sapra · Shin (E-16) 이 첫 편이다. 그 편이 새 원소 셋을 더해 **S-4 의 포화 카운트가 0** 이다. 남은 우선 상은 Adrian · Colla · Shin (2012) 와 Aramonte · Schrimpf · Shin (2021) 둘 |
| 3 | O-2 비★ 잔여 | E-10 과 E-11 이 읽혔고 그 뒤로 구간의 진행이 없다. S-4 적용 |
| 4 | O-3 비★ 잔여 | E-18 과 E-19 가 읽혔으나 **둘 다 S-7 지목이라 포화 카운트에 들지 않는다.** 구간의 진행은 없다. S-4 적용 |

**비★ 구간 셋이 모두 열려 있고 어느 것도 S-4 로 종료되지 않았다.** 구멍이 지목으로 조달되는 동안
구간이 열린 채 남는 것은 정상이다. 종료 판정이 필요해지는 때는 **지목으로 조달할 구멍이 마르는 때**다.
