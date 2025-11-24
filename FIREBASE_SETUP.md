# Firebase Remote Config - OpenAI API 키 설정 가이드

## 🔑 OpenAI API 키 설정 단계

### 1단계: OpenAI API 키 발급 (아직 없다면)

1. https://platform.openai.com/ 접속
2. 로그인 또는 회원가입
3. 우측 상단 프로필 클릭 → **API keys** 선택
4. **Create new secret key** 클릭
5. 이름 입력 (예: "AIhealth-iOS")
6. **Create secret key** 클릭
7. ⚠️ **중요**: 생성된 키를 복사해서 안전한 곳에 저장
   - 형식: `sk-proj-...` 또는 `sk-...`
   - 이 키는 다시 볼 수 없으니 반드시 복사!

---

## 2단계: Firebase Console 접속

1. https://console.firebase.google.com/ 접속
2. **AIhealth** 프로젝트 선택 (또는 생성한 프로젝트)

---

## 3단계: Remote Config 설정

### 방법 A: Firebase Console에서 직접 설정 (권장)

#### 1. Remote Config 메뉴 열기
```
Firebase Console → 좌측 메뉴
→ Engage (또는 "참여")
→ Remote Config
```

#### 2. 첫 구성 만들기
- 처음이면 **"구성 만들기"** 또는 **"Create configuration"** 버튼이 보임
- 클릭!

#### 3. 매개변수 추가
**"매개변수 추가"** 또는 **"Add parameter"** 클릭

다음 정보 입력:
```
┌─────────────────────────────────────────────────────┐
│ 매개변수 키 (Parameter key)                          │
│ openai_api_key                                      │
│                                                     │
│ ⚠️ 정확히 이 이름으로 입력! (소문자, 언더스코어)       │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ 기본값 (Default value)                               │
│ sk-proj-xxxxxxxxxxxxxxxxxxxx                        │
│                                                     │
│ ← 여기에 1단계에서 복사한 OpenAI API 키 붙여넣기     │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ 설명 (Description) - 선택사항                        │
│ OpenAI GPT-4 API Key for AI Health Consultation    │
└─────────────────────────────────────────────────────┘
```

#### 4. 저장 및 게시
- **"저장"** 버튼 클릭
- **"변경사항 게시"** 또는 **"Publish changes"** 클릭
- 확인 팝업에서 **"게시"** 클릭

✅ 완료!

---

## 4단계: 확인

Firebase Console에서 다음과 같이 보여야 함:

```
Remote Config
┌──────────────────────────────────────────────────┐
│ 매개변수                                          │
├──────────────────────────────────────────────────┤
│ openai_api_key                                   │
│ 기본값: sk-proj-****************                 │
│ 설명: OpenAI GPT-4 API Key...                    │
└──────────────────────────────────────────────────┘
```

---

## 5단계: iOS 앱에서 확인

앱 코드에서 자동으로 가져옵니다:

```swift
// AIhealthApp.swift에서 이미 구현됨
init() {
    FirebaseApp.configure()

    Task {
        try await FirebaseManager.shared.fetchRemoteConfig()
        let apiKey = FirebaseManager.shared.getOpenAIApiKey()
        GptApiService.shared.setApiKey(apiKey)
    }
}
```

---

## 🚨 문제 해결

### Q1: Remote Config 메뉴가 안 보여요
**A**: Firebase 콘솔 좌측 메뉴를 아래로 스크롤
- "Engage" 섹션 찾기
- "Remote Config" 클릭

### Q2: API 키가 앱에서 작동하지 않아요
**A**: 확인 사항:
1. 매개변수 키가 정확히 `openai_api_key`인지 확인 (오타 체크)
2. 변경사항을 **게시**했는지 확인
3. API 키가 유효한지 OpenAI 대시보드에서 확인
4. 앱을 재시작해보기

### Q3: "게시" 버튼이 비활성화되어 있어요
**A**: **"저장"** 버튼을 먼저 클릭한 후 "게시" 버튼 클릭

---

## 📱 로컬 테스트용 임시 설정 (선택사항)

Remote Config 설정 전에 로컬에서 테스트하려면:

### 방법: 코드에서 직접 설정

**⚠️ 주의: Git에 커밋하지 마세요!**

`AIhealthApp.swift` 파일 수정:

```swift
import SwiftUI
import FirebaseCore

@main
struct AIhealthApp: App {
    init() {
        FirebaseApp.configure()

        // 🔥 임시 개발용 - 프로덕션에서는 절대 사용 금지!
        GptApiService.shared.setApiKey("sk-proj-YOUR-ACTUAL-KEY-HERE")

        // Remote Config는 나중에 사용
        // Task {
        //     try await FirebaseManager.shared.fetchRemoteConfig()
        //     let apiKey = FirebaseManager.shared.getOpenAIApiKey()
        //     GptApiService.shared.setApiKey(apiKey)
        // }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
```

테스트 후 **반드시 원래대로 복구**하고 Remote Config 사용!

---

## ✅ 최종 체크리스트

- [ ] OpenAI API 키 발급 완료
- [ ] Firebase Console → Remote Config 접속
- [ ] `openai_api_key` 매개변수 추가
- [ ] OpenAI API 키를 기본값에 입력
- [ ] 변경사항 저장 및 게시
- [ ] 앱 실행하여 테스트

---

## 🎯 다음 단계

Remote Config 설정 완료 후:

1. **GoogleService-Info.plist** 파일이 프로젝트에 있는지 확인
2. Xcode에서 앱 실행 (⌘R)
3. AI 상담 화면에서 메시지 입력
4. GPT-4 응답 확인!

---

## 🔒 보안 팁

1. **API 키 보호**
   - 절대 Git에 커밋하지 마세요
   - Remote Config 사용 권장
   - 정기적으로 키 교체

2. **Firebase 규칙 설정**
   ```javascript
   // Remote Config는 클라이언트에서 읽기만 가능
   // Firebase Console에서만 수정 가능
   ```

3. **사용량 모니터링**
   - OpenAI Dashboard에서 API 사용량 확인
   - 예산 한도 설정 권장

---

완료하셨나요? 이제 앱에서 AI 상담 기능을 사용할 수 있습니다! 🎉
