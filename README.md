# 기록 (ADHDLog)

ADHD 특성에 맞춰 **부담 없이, 빠르게** 일상을 남기는 iOS 기록 앱.
일기 · 사진 · 책 · 영화 · 뮤지컬 · 음악 · 공연을 **하나의 타임라인**에 모으고,
홈/잠금화면 **위젯**으로 "기록하는 습관"을 눈앞에 둔다.

> SwiftUI + SwiftData(+ iCloud 동기화) + WidgetKit · iOS 17+

---

## ADHD를 위한 설계 원칙

- **초간단 빠른 입력** — 위젯 탭 한 번 → 카테고리 → 한 줄/사진이면 끝. 비어 있어도(사진·기분만 있어도) 저장 가능.
- **위젯 스트릭 & 리마인드** — 홈/잠금화면에서 "오늘 기록했나?"가 항상 보임. 연속 기록(🔥)과 이번 주 점 표시.
- **시각적 보상** — 카테고리별 색/아이콘, 채워지는 주간 점, 쌓이는 타임라인으로 도파민 피드백.
- **부담 없는 톤** — 끊겨도 비난하지 않음("오늘도 한 줄이면 이어져요"). 빈 날에 죄책감을 주지 않는 문구.

---

## 빌드 방법 (Mac + Xcode 필요)

> ⚠️ 이 저장소는 소스 코드만 들어 있습니다. 실제 빌드/실행은 **macOS의 Xcode**에서 해야 합니다.
> (이 환경은 Linux라 컴파일은 Mac에서 진행하세요.)

### 1. Xcode 프로젝트 생성 (XcodeGen)

`.xcodeproj`는 `project.yml`로부터 생성합니다.

```bash
brew install xcodegen      # 처음 한 번
cd adhd_log
xcodegen generate
open ADHDLog.xcodeproj
```

### 2. 서명 & 기능(Capabilities) 설정 — 한 번만

Xcode에서 두 타깃(`ADHDLog`, `ADHDLogWidget`) 모두에 대해:

1. **Signing & Capabilities** 탭 → 본인 **Team** 선택 (`project.yml`의 `DEVELOPMENT_TEAM`에 미리 넣어도 됨).
2. **Bundle Identifier**를 본인 것으로 변경 (예: `com.<나>.adhdlog` / 위젯은 `....widget`).
3. **+ Capability** 로 다음을 추가하고 두 타깃이 **같은 값**을 쓰도록 맞춥니다:
   - **App Groups**: `group.com.adhdlog.shared` (원하는 이름으로 바꿔도 됨)
   - **iCloud → CloudKit**: 컨테이너 `iCloud.com.adhdlog.app`

> Bundle ID / App Group / iCloud 컨테이너 이름을 바꾸면 아래 파일들의 값도 같이 바꿔야 합니다:
> - `Shared/PersistenceController.swift` → `AppGroup.identifier`
> - `ADHDLog/ADHDLog.entitlements`, `ADHDLogWidget/ADHDLogWidget.entitlements`
> - `project.yml` (선택)

### 3. 실행

- 실기기 또는 시뮬레이터에서 `ADHDLog` 스킴 실행.
- 홈 화면 길게 누르기 → 위젯 추가 → **기록 위젯(연속 기록 / 빠른 기록)** 배치.
- 잠금화면 위젯: 잠금화면 편집 → 위젯 추가에서 같은 위젯 선택.

> iCloud 동기화는 기기가 **같은 Apple ID로 로그인** & iCloud 켜짐 상태에서 자동 작동합니다.
> 시뮬레이터에서도 로그인하면 테스트 가능.

---

## 프로젝트 구조

```
adhd_log/
├─ project.yml                  # XcodeGen 프로젝트 정의 (.xcodeproj 의 원본)
├─ Shared/                      # 앱 + 위젯 공용 코드
│  ├─ LogEntry.swift            # SwiftData 모델 (모든 기록의 단일 모델)
│  ├─ LogCategory.swift         # 카테고리(색/아이콘/필드 규칙)
│  ├─ Mood.swift                # 기분 + 진행 상태(LogStatus)
│  ├─ PersistenceController.swift  # App Group + iCloud ModelContainer
│  ├─ StreakCalculator.swift    # 스트릭/주간 현황 계산
│  ├─ Theme.swift               # 디자인 토큰 + 위젯 딥링크(DeepLink)
│  ├─ WidgetReloader.swift      # 데이터 변경 시 위젯 갱신
│  └─ SampleData.swift          # 미리보기/데모 데이터
├─ ADHDLog/                     # 메인 앱
│  ├─ ADHDLogApp.swift          # 진입점 + 딥링크 처리
│  ├─ Info.plist / *.entitlements
│  ├─ Assets.xcassets
│  └─ Views/
│     ├─ RootView.swift         # 최상위 + 빠른 입력 시트 관리
│     ├─ TimelineView.swift     # 날짜별 타임라인 + 필터
│     ├─ StreakHeaderView.swift # 상단 스트릭 카드
│     ├─ EntryRowView.swift     # 타임라인 한 줄
│     ├─ CategoryChooserSheet.swift # 카테고리 선택 그리드
│     ├─ EntryEditView.swift    # 입력/편집 폼
│     ├─ EntryDetailView.swift  # 상세 보기
│     └─ Components/ (RatingView, MoodPicker)
└─ ADHDLogWidget/               # 위젯 익스텐션
   ├─ ADHDLogWidgetBundle.swift
   ├─ Provider.swift            # 공유 저장소에서 읽어 스트릭 계산
   ├─ StreakWidget.swift        # 스트릭 위젯 (홈/잠금화면)
   └─ QuickAddWidget.swift      # 빠른 입력 위젯 (탭 → 앱의 입력 화면)
```

---

## 데이터 & 동기화

- **저장**: 기기 로컬(App Group 컨테이너 내 SwiftData 저장소) → 위젯도 같은 데이터를 읽음.
- **동기화**: SwiftData의 CloudKit 통합으로 기기 간 자동 동기화(서버 불필요, 무료, 프라이버시 보호).
- 사진은 `@Attribute(.externalStorage)`로 효율적으로 저장.

---

## 다음에 추가하면 좋은 것 (로드맵 아이디어)

- 알림 리마인더(저녁에 부드러운 알림) + 설정 화면
- 음성 메모 / 받아쓰기로 기록
- 검색 & 통계(이번 달 본 영화 수, 기분 추이 그래프)
- 책/영화 제목 자동완성(외부 API)
- App Intents 기반 위젯 즉시 입력(기분 한 탭 저장), Siri 단축어
- 잠금화면에서 더 풍부한 한 줄 회고
```
