# 맥 없이 TestFlight 로 폰에 설치하기 📲

목표: **내 아이폰에서 위젯까지 포함해 진짜로 사용**하기. 맥은 필요 없고,
GitHub가 클라우드에서 대신 빌드해 **TestFlight**(애플 베타 앱)로 보내줍니다.

> 대부분 **아이패드/아이폰 브라우저**로 가능해요. 한 번만 설정하면 그 뒤로는 버튼 한 번이면 새 빌드가 올라갑니다.
> 처음 한 번은 시행착오로 빌드가 한두 번 실패할 수 있어요 — 로그 보고 같이 고치면 됩니다.

---

## 0. 준비물
- **애플 개발자 프로그램 등록**(연 약 13만원 / $99). 아이폰 **Apple Developer 앱**에서 가입 가능. 승인까지 보통 몇 시간~하루.
- 본인 소유의 **번들 ID 접두어**(reverse-domain) 하나 정하기. 도메인 없어도 됨.
  예: `com.나이름.adhdlog` (영문/숫자, 본인만의 고유한 값이면 OK)

---

## 1. App Store Connect API 키 만들기 (서명용 열쇠)
브라우저에서 [appstoreconnect.apple.com](https://appstoreconnect.apple.com) →
**사용자 및 액세스 → 통합(Integrations) → App Store Connect API → 키 생성**

- 역할: **App Manager** 로 생성
- 만들면 다음 3가지를 확보:
  - **Key ID** (예: `2X9ABC3DEF`)
  - **Issuer ID** (페이지 상단의 긴 UUID)
  - **`.p8` 키 파일** (딱 한 번만 다운로드됨 — 잘 보관)

### .p8 를 base64 로 바꾸기
GitHub 시크릿에는 파일을 못 넣으니 텍스트로 바꿔요.
- 아이폰/아이패드: **단축어(Shortcuts) 앱**에서 "파일 가져오기 → Base64 인코딩 → 결과 복사" 단축어로 변환
- 또는 맥/리눅스/온라인 도구에서 `base64 키파일.p8` 결과 문자열 복사
- 결과로 나온 긴 문자열을 통째로 복사해 둡니다 (아래 `ASC_KEY_P8_BASE64` 에 사용).

### 팀 ID 확인
[developer.apple.com/account](https://developer.apple.com/account) → **Membership details** 에
**Team ID** (10자리, 예: `ABCDE12345`).

---

## 2. GitHub 에 값 등록
저장소 → **Settings → Secrets and variables → Actions**

**Secrets(비밀)** 에 New repository secret 으로 4개:
| 이름 | 값 |
|------|-----|
| `APPLE_TEAM_ID` | 10자리 팀 ID |
| `ASC_KEY_ID` | API 키의 Key ID |
| `ASC_ISSUER_ID` | API 키의 Issuer ID |
| `ASC_KEY_P8_BASE64` | .p8 를 base64 로 바꾼 긴 문자열 |

**Variables(변수)** 탭에서 1개:
| 이름 | 값 |
|------|-----|
| `BUNDLE_ID` | 정한 번들 ID (예: `com.나이름.adhdlog`) |
| `APP_NAME` *(선택)* | 앱 이름 (기본값 `기록`) |

> ⚠️ `BUNDLE_ID` 는 **Variables**, 나머지는 **Secrets** 입니다. (탭이 달라요)

---

## 3. 빌드 실행
저장소 → **Actions 탭 → "TestFlight 빌드" → Run workflow**
(브랜치 `claude/adhd-diary-media-app-Br5KQ` 선택해서 실행)

- 약 10~20분 후 완료. 성공하면 App Store Connect 에서 빌드가 "처리 중"으로 보이고,
  몇 분 더 지나면 TestFlight 에서 사용 가능.
- 실패하면 빨간 X → 로그 확인. 보통 첫 실행은 권한/이름 문제라 한두 번 손보면 됩니다.

---

## 4. 폰에 설치
1. 아이폰에 **TestFlight** 앱 설치 (App Store에서 무료).
2. App Store Connect → **TestFlight → 테스터 → 내 자신(본인 Apple ID)** 추가
   (또는 "내부 테스터"로 본인 추가). 초대 메일/링크가 오면 TestFlight 에서 수락.
3. TestFlight 에서 **기록** 앱 설치 → 끝! 홈/잠금화면에 위젯도 추가해 보세요.

> 이후 코드가 바뀌면 3번(Run workflow)만 다시 누르면 새 버전이 폰으로 와요.
> TestFlight 빌드는 90일간 유효합니다.

---

## 자주 막히는 곳
- **번들 ID 중복**: `BUNDLE_ID` 가 이미 누가 쓰는 값이면 등록 실패 → 더 고유하게 바꾸기.
- **권한 부족**: API 키 역할을 **App Manager** 이상으로.
- **약관 미동의**: App Store Connect 에 처음 로그인하면 떠 있는 **계약/약관**에 동의해야 업로드돼요.
- **iCloud/App Group**: 자동 서명이 알아서 만들어 주지만, 처음엔 한 번 실패할 수 있어요. 로그 주면 고쳐드릴게요.
