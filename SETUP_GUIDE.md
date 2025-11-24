# AIhealth iOS 앱 설정 가이드

이 가이드는 안드로이드 AIHealthApp을 iOS로 포팅한 프로젝트의 초기 설정을 도와줍니다.

## 1. 필수 준비물

- Xcode 15.0 이상
- macOS Sonoma 이상
- Apple Developer 계정 (실제 기기 테스트용)
- Firebase 프로젝트
- OpenAI API 키

---

## 2. Firebase 설정 (중요!)

### 2-1. Firebase 프로젝트 생성

1. https://console.firebase.google.com/ 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름: `AIhealth` (또는 원하는 이름)
4. Google Analytics 활성화 (선택사항)

### 2-2. iOS 앱 추가

1. Firebase 콘솔에서 iOS 앱 추가
2. **번들 ID**: `com.yourcompany.AIhealth`
   - ⚠️ Xcode의 Bundle Identifier와 정확히 일치해야 함
3. `GoogleService-Info.plist` 다운로드
4. **중요**: 다운로드한 파일을 Xcode 프로젝트에 추가
   - Xcode에서 `AIhealth` 폴더에 드래그
   - "Copy items if needed" 체크
   - Target: AIhealth 선택

### 2-3. Firebase 서비스 활성화

#### Firestore Database
1. Firebase 콘솔 → Build → Firestore Database
2. "데이터베이스 만들기" 클릭
3. **테스트 모드**로 시작 (개발용)
4. 위치: `asia-northeast3` (서울) 선택

프로덕션 보안 규칙 (나중에 적용):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /reservations/{reservationId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Storage
1. Firebase 콘솔 → Build → Storage
2. "시작하기" 클릭
3. **테스트 모드**로 시작
4. 위치: `asia-northeast3` (서울) 선택

프로덕션 보안 규칙 (나중에 적용):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /reservations/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Remote Config
1. Firebase 콘솔 → Engage → Remote Config
2. "구성 만들기" 클릭
3. 매개변수 추가:
   - **키**: `openai_api_key`
   - **값**: `sk-your-openai-api-key-here`
   - 설명: OpenAI API Key for GPT-4
4. "게시" 클릭

---

## 3. Swift Package Manager 의존성 추가

### 3-1. Firebase SDK 추가

1. Xcode에서 프로젝트 열기
2. File → Add Package Dependencies...
3. URL 입력: `https://github.com/firebase/firebase-ios-sdk`
4. Version: Up to Next Major Version `10.0.0`
5. Add to Project: `AIhealth` 선택
6. 다음 패키지 선택:
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
   - ✅ FirebaseRemoteConfig
   - ✅ FirebaseCore
7. "Add Package" 클릭

---

## 4. Info.plist 설정

Xcode에서 `Info.plist` 파일을 열고 다음 권한 추가:

### 방법 1: Source Code로 추가
Info.plist를 오른쪽 클릭 → Open As → Source Code
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>진료 관련 사진을 첨부하기 위해 사진 라이브러리 접근이 필요합니다.</string>

<key>NSCameraUsageDescription</key>
<string>진료 관련 사진을 촬영하기 위해 카메라 접근이 필요합니다.</string>

<key>NSUserNotificationsUsageDescription</key>
<string>예약 및 상담 완료 알림을 받기 위해 알림 권한이 필요합니다.</string>

<key>UIUserInterfaceStyle</key>
<string>Light</string>
```

### 방법 2: Property List로 추가
Info.plist → 오른쪽 클릭 → Add Row
- Privacy - Photo Library Usage Description
- Privacy - Camera Usage Description
- Privacy - User Notifications Usage Description
- Appearance (UIUserInterfaceStyle) → Light

---

## 5. OpenAI API 키 설정

### 옵션 A: Firebase Remote Config (권장)
이미 2-3단계에서 설정 완료

### 옵션 B: 로컬 개발용 (테스트만)
`AIhealthApp.swift` 파일 수정:
```swift
init() {
    FirebaseApp.configure()

    // 개발용 임시 설정
    GptApiService.shared.setApiKey("sk-your-actual-api-key-here")
}
```
⚠️ **주의**: 절대 Git에 커밋하지 마세요!

---

## 6. Xcode 프로젝트 설정

### 6-1. Bundle Identifier 확인
1. Xcode에서 프로젝트 선택
2. Targets → AIhealth → General
3. Bundle Identifier: `com.yourcompany.AIhealth`
4. Firebase에 등록한 번들 ID와 일치하는지 확인

### 6-2. Deployment Target
- iOS Deployment Target: **iOS 16.0** 이상

### 6-3. Signing & Capabilities
1. Targets → AIhealth → Signing & Capabilities
2. Automatically manage signing 체크
3. Team 선택 (Apple Developer 계정)

---

## 7. 빌드 및 실행

### 7-1. 시뮬레이터에서 실행
1. Xcode 상단에서 시뮬레이터 선택 (iPhone 15 Pro 권장)
2. Cmd + R 또는 Play 버튼 클릭
3. 앱이 실행되면 성공!

### 7-2. 실제 기기에서 실행
1. iPhone을 Mac에 연결
2. Xcode 상단에서 연결된 기기 선택
3. Signing & Capabilities에서 Team 설정
4. Cmd + R 실행

---

## 8. 문제 해결

### 문제 1: "GoogleService-Info.plist not found"
**해결**:
- GoogleService-Info.plist가 프로젝트에 제대로 추가되었는지 확인
- Xcode 좌측 네비게이터에서 파일이 보이는지 확인
- Target Membership이 AIhealth로 설정되었는지 확인

### 문제 2: "Module 'Firebase' not found"
**해결**:
- File → Add Package Dependencies에서 Firebase SDK 추가
- Package.resolved 파일 삭제 후 재빌드
- Clean Build Folder (Cmd + Shift + K)

### 문제 3: "API key not set" 오류
**해결**:
- Firebase Remote Config에 `openai_api_key` 추가 확인
- Remote Config가 활성화되었는지 확인
- 네트워크 연결 확인

### 문제 4: 카메라/사진 권한 오류
**해결**:
- Info.plist에 권한 설명 추가 (4단계 참조)
- 시뮬레이터는 카메라 미지원 (실제 기기 필요)

### 문제 5: Firestore 쓰기 권한 거부
**해결**:
- Firebase 콘솔에서 Firestore 규칙이 테스트 모드인지 확인
- 규칙 예시:
```javascript
allow read, write: if true; // 테스트용
```

---

## 9. 테스트 체크리스트

프로젝트 설정이 완료되면 다음 기능을 테스트하세요:

- [ ] 앱이 정상적으로 빌드되고 실행됨
- [ ] 홈 화면이 표시됨
- [ ] AI 상담 화면으로 이동 가능
- [ ] 메시지 입력 시 AI 응답 수신 (네트워크 필요)
- [ ] 상담 종료 시 요약 생성
- [ ] 예약 화면에서 정보 입력 가능
- [ ] 사진 선택 기능 작동
- [ ] 예약 제출 시 Firestore에 저장됨
- [ ] 내 기록 화면에서 저장된 진단 확인

---

## 10. 다음 단계

설정이 완료되면:

1. **사용자 인증 추가**:
   - Firebase Authentication 활성화
   - 로그인/회원가입 화면 구현

2. **푸시 알림**:
   - Firebase Cloud Messaging 설정
   - APNs 인증서 등록

3. **프로덕션 배포**:
   - App Store Connect 등록
   - 보안 규칙 강화
   - TestFlight 베타 테스트

---

## 도움이 필요하신가요?

- Firebase 공식 문서: https://firebase.google.com/docs/ios/setup
- OpenAI API 문서: https://platform.openai.com/docs
- 이슈 제보: GitHub Issues

즐거운 개발 되세요! 🚀
