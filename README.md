# AIhealth iOS App

AI 기반 건강 상담 및 병원 예약 iOS 애플리케이션입니다.

## 주요 기능

### 1. AI 건강 상담
- GPT-4를 활용한 실시간 건강 상담
- 증상 분석 및 진료과 추천
- 상담 내용 자동 요약 및 저장

### 2. 병원 예약 시스템
- 개인병원 / 대형병원 예약 지원
- 환자 정보 관리
- 파일 첨부 기능 (사진, 문서)
- Firebase Storage를 통한 안전한 파일 업로드

### 3. 진단 기록 관리
- 로컬 저장소를 통한 상담 기록 보관
- PDF 생성 및 공유 기능
- 예약 내역 조회

### 4. 사용자 친화적 UI
- SwiftUI 기반 모던한 인터페이스
- 파스텔 블루 + 민트 테마
- 직관적인 탭 기반 네비게이션

---

## 기술 스택

- **언어**: Swift 5.x
- **프레임워크**: SwiftUI, Combine
- **아키텍처**: MVVM (Model-View-ViewModel)
- **백엔드 서비스**:
  - Firebase (Firestore, Storage, Remote Config)
  - OpenAI GPT-4 API
- **로컬 저장소**: UserDefaults
- **의존성 관리**: Swift Package Manager (SPM)

---

## 프로젝트 구조

```
AIhealth/
├── Models/
│   ├── ChatMessage.swift
│   ├── Reservation.swift
│   └── DiagnosisRecord.swift
├── ViewModels/
│   ├── ChatViewModel.swift
│   ├── ReservationViewModel.swift
│   └── ReportViewModel.swift
├── Views/
│   ├── Home/
│   │   └── DashboardHomeScreen.swift
│   ├── Chat/
│   │   └── ChatScreen.swift
│   ├── Reservation/
│   │   └── ReservationScreen.swift
│   ├── Report/
│   │   ├── ReportPreviewScreen.swift
│   │   └── ReportListScreen.swift
│   ├── Components/
│   │   ├── CommonButton.swift
│   │   ├── CommonTextField.swift
│   │   ├── CommonCard.swift
│   │   └── LoadingView.swift
│   └── MainTabView.swift
├── Services/
│   ├── Network/
│   │   ├── GptApiService.swift
│   │   ├── FirebaseManager.swift
│   │   └── SystemPrompt.swift
│   └── Repository/
│       ├── ChatRepository.swift
│       ├── ReservationRepository.swift
│       └── DiagnosisRepository.swift
├── Utilities/
│   ├── PDFGenerator.swift
│   └── NotificationManager.swift
├── Theme/
│   ├── Colors.swift
│   └── Theme.swift
└── AIhealthApp.swift
```

---

## 설정 방법

### 1. Firebase 설정

1. [Firebase Console](https://console.firebase.google.com/)에서 새 프로젝트 생성
2. iOS 앱 추가 (Bundle ID: `com.yourcompany.AIhealth`)
3. `GoogleService-Info.plist` 다운로드
4. Xcode 프로젝트의 `AIhealth` 폴더에 추가
5. Firebase Console에서 다음 서비스 활성화:
   - **Firestore Database**: 예약 데이터 저장
   - **Storage**: 파일 업로드
   - **Remote Config**: OpenAI API 키 관리

#### Firestore 컬렉션 구조
```
reservations/
  └── {reservationId}/
      ├── patientName: String
      ├── patientPhone: String
      ├── selectedHospital: String
      ├── symptoms: String
      ├── status: String
      └── ...
```

#### Remote Config 설정
- Key: `openai_api_key`
- Value: `sk-...` (본인의 OpenAI API 키)

### 2. Firebase 패키지 설치 (SPM)

Xcode에서:
1. File → Add Package Dependencies
2. 다음 URL 입력: `https://github.com/firebase/firebase-ios-sdk`
3. 필요한 제품 선택:
   - FirebaseFirestore
   - FirebaseStorage
   - FirebaseRemoteConfig

### 3. OpenAI API 키 설정

Firebase Remote Config에 OpenAI API 키를 저장:
```
Key: openai_api_key
Value: sk-your-openai-api-key-here
```

또는 로컬 개발용으로 코드에서 직접 설정:
```swift
// AIhealthApp.swift의 init()에서
GptApiService.shared.setApiKey("sk-your-key-here")
```

### 4. Info.plist 권한 설정

다음 권한을 `Info.plist`에 추가:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>진료 관련 사진을 첨부하기 위해 사진 라이브러리 접근이 필요합니다.</string>

<key>NSCameraUsageDescription</key>
<string>진료 관련 사진을 촬영하기 위해 카메라 접근이 필요합니다.</string>

<key>NSUserNotificationsUsageDescription</key>
<string>예약 및 상담 완료 알림을 받기 위해 알림 권한이 필요합니다.</string>
```

### 5. 빌드 및 실행

1. Xcode에서 프로젝트 열기
2. 시뮬레이터 또는 실제 기기 선택
3. Cmd + R 실행

---

## 주요 기능 사용법

### AI 상담 시작
1. 홈 화면에서 "AI 상담 + 예약" 선택
2. 증상을 채팅으로 입력
3. AI가 질문하고 분석
4. "상담 종료" 버튼으로 요약 생성
5. 결과 확인 후 병원 예약 진행

### 병원 예약
1. 환자 정보 입력
2. 병원 유형 선택 (개인병원/대형병원)
3. 병원 및 진료과 선택
4. 증상 입력
5. 필요시 사진/파일 첨부
6. 예약 제출

### 진단 기록 보기
1. 하단 탭에서 "내 기록" 선택
2. 저장된 상담 기록 조회
3. 기록 선택 시 상세 내용 확인
4. PDF 생성 또는 삭제 가능

---

## 안드로이드 프로젝트와의 차이점

| 기능 | Android (Kotlin) | iOS (Swift) |
|------|------------------|-------------|
| UI 프레임워크 | Jetpack Compose | SwiftUI |
| 의존성 주입 | Hilt | 없음 (직접 싱글톤) |
| 비동기 처리 | Coroutines | async/await |
| 로컬 저장소 | SharedPreferences | UserDefaults |
| 네트워크 | Retrofit + Gson | URLSession + Codable |
| 이미지 선택 | Activity Result API | PhotosUI |

---

## 주의사항

1. **API 키 보안**:
   - 프로덕션에서는 반드시 Firebase Remote Config 사용
   - 코드에 직접 하드코딩 금지

2. **Firebase 규칙**:
   - Firestore 및 Storage 보안 규칙 설정 필요
   - 테스트 모드는 프로덕션에 부적합

3. **의료 면책**:
   - AI 상담은 의료진 진단을 대체할 수 없음
   - 앱 내 모든 곳에 명시 필요

4. **개인정보 처리**:
   - 환자 정보는 민감 정보로 처리
   - GDPR/개인정보보호법 준수 필요

---

## 향후 개선 사항

- [ ] 사용자 인증 (Firebase Auth)
- [ ] 푸시 알림 (FCM)
- [ ] 다국어 지원
- [ ] 다크 모드 지원
- [ ] 오프라인 모드
- [ ] Apple Health 연동
- [ ] 위젯 지원
- [ ] iPad 최적화

---

## 라이선스

이 프로젝트는 개인 학습 및 포트폴리오 목적으로 제작되었습니다.

---

## 연락처

문의사항이 있으시면 이슈를 등록해주세요.
