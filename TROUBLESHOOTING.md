# SwiftCompile 오류 해결 가이드

## 오류 메시지
```
Command SwiftCompile failed with a nonzero exit code
```

이 오류는 Swift 코드 컴파일 과정에서 발생하는 일반적인 오류입니다.

---

## 해결 방법 (순서대로 시도)

### 1단계: 정확한 오류 메시지 확인

1. Xcode에서 **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)
3. 왼쪽 상단 **⚠️ 아이콘** 또는 **중간 탭의 빌드 로그** 클릭
4. 빨간색 에러 메시지를 찾아서 읽기

**일반적인 에러 유형:**
- `Cannot find type 'FirebaseCore' in scope` → Firebase 패키지 문제
- `No such module 'FirebaseFirestore'` → 제품 선택 문제
- `Value of type 'X' has no member 'Y'` → 코드 오타
- `Use of unresolved identifier` → import 누락

---

### 2단계: Firebase 제품 확인 및 추가

#### 확인 방법:
1. Xcode 좌측 네비게이터에서 프로젝트 파일 선택 (최상단 AIhealth)
2. **Targets** → **AIhealth** 선택
3. **General** 탭 → 아래로 스크롤
4. **Frameworks, Libraries, and Embedded Content** 섹션 확인

#### 필요한 제품들이 있는지 확인:
- ✅ FirebaseCore
- ✅ FirebaseFirestore
- ✅ FirebaseStorage
- ✅ FirebaseRemoteConfig

#### 없다면 추가:
1. 왼쪽 네비게이터에서 **Package Dependencies** 확인
2. `firebase-ios-sdk` 우클릭 → **Update Package**
3. 프로젝트 설정 → **General** → **Frameworks...** 섹션
4. **+** 버튼 클릭
5. 위 4개 제품 선택 후 **Add**

---

### 3단계: 파일 Target Membership 확인

모든 Swift 파일이 AIhealth 타겟에 포함되어야 합니다.

#### 확인 방법:
1. Xcode 좌측에서 Swift 파일 하나 선택 (예: `AIhealthApp.swift`)
2. 우측 **File Inspector** (⌘⌥1)
3. **Target Membership** 섹션에서 **AIhealth** 체크박스 확인
4. 체크되지 않았다면 체크

#### 모든 파일 확인:
특히 다음 파일들이 중요합니다:
- `AIhealthApp.swift`
- `MainTabView.swift`
- `Models/` 폴더의 모든 파일
- `ViewModels/` 폴더의 모든 파일
- `Services/` 폴더의 모든 파일

---

### 4단계: GoogleService-Info.plist 추가

Firebase를 사용하려면 이 파일이 필수입니다.

#### 추가 방법:
1. Firebase 콘솔 → 프로젝트 설정 → iOS 앱
2. `GoogleService-Info.plist` 다운로드
3. Xcode에서 `AIhealth` 폴더에 드래그
4. **Copy items if needed** 체크
5. **Add to targets: AIhealth** 체크
6. **Finish**

#### 확인:
- 파일이 Xcode 좌측 네비게이터에 보여야 함
- 파일명이 정확히 `GoogleService-Info.plist`여야 함 (철자 확인)

---

### 5단계: Info.plist 권한 추가

iOS는 카메라, 사진 등 접근 시 권한 설명이 필수입니다.

#### 추가 방법:
1. Xcode에서 `Info.plist` 파일 선택
2. 우클릭 → **Open As** → **Source Code**
3. 다음 코드를 `<dict>` 태그 안에 추가:

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

---

### 6단계: Clean Build & Rebuild

모든 설정 후:

1. **Product → Clean Build Folder** (⇧⌘K)
2. Xcode 종료
3. Derived Data 삭제:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```
4. Xcode 재시작
5. **Product → Build** (⌘B)

---

### 7단계: 일반적인 코드 오류 수정

#### 오류 1: "Cannot find 'GptApiService' in scope"
**원인**: import 누락
**해결**: 파일 상단에 추가
```swift
import Foundation
```

#### 오류 2: "No such module 'FirebaseCore'"
**원인**: Firebase 제품이 타겟에 추가되지 않음
**해결**: 2단계 참조

#### 오류 3: "Use of unresolved identifier 'ChatScreen'"
**원인**: 파일이 타겟에 포함되지 않음
**해결**: 3단계 참조

#### 오류 4: "Type 'XXX' has no member 'YYY'"
**원인**: 코드 오타 또는 API 변경
**해결**: 오타 확인 또는 해당 줄의 코드 수정

---

## 특정 오류별 해결법

### "Missing required module 'FirebaseFirestore'"

**해결책:**
1. Package Dependencies에서 firebase-ios-sdk 확인
2. 프로젝트 설정 → General → Frameworks, Libraries
3. + 버튼 → FirebaseFirestore 추가
4. Clean Build Folder → Rebuild

---

### "Undefined symbols for architecture arm64"

**원인**: 링커 오류 (라이브러리 미연결)

**해결책:**
1. Build Settings 검색: "Other Linker Flags"
2. `-ObjC` 플래그가 있는지 확인
3. 없으면 추가: Build Settings → Other Linker Flags → + → `-ObjC`

---

### "The package product 'FirebaseCore' requires minimum platform version 13.0"

**해결책:**
1. 프로젝트 설정 → General
2. **Minimum Deployments** → iOS **16.0** 이상으로 설정
3. Clean Build Folder → Rebuild

---

## 빌드 성공 확인

빌드가 성공하면:
```
Build Succeeded
```

시뮬레이터에서 앱이 실행되고 홈 화면이 표시됩니다.

---

## 여전히 오류 발생 시

1. **정확한 오류 메시지 복사**
2. Xcode의 Issue Navigator (⌘5)에서 전체 오류 확인
3. 특정 파일과 줄 번호 확인
4. 해당 파일 열어서 코드 확인

### 디버깅 팁:
```bash
# Xcode 버전 확인
xcodebuild -version

# Swift 버전 확인
swift --version

# Package 상태 확인
cd /Users/chaedongjoo/DEVELOPER/AIhealth
swift package show-dependencies
```

---

## 마지막 수단: 프로젝트 재생성

모든 방법이 실패하면:

1. 새 Xcode 프로젝트 생성 (iOS App, SwiftUI)
2. Bundle ID: `com.yourcompany.AIhealth`
3. 기존 Swift 파일들을 새 프로젝트로 드래그
4. Firebase 패키지 다시 추가
5. 빌드

---

## 자주 묻는 질문

**Q: "Command SwiftCompile failed" 만 보이고 자세한 내용이 없어요**
A: Xcode의 Report Navigator (⌘9) → 최근 빌드 클릭 → 전체 로그 확인

**Q: 시뮬레이터에서는 되는데 실제 기기에서 안 돼요**
A: Signing & Capabilities → Team 설정 확인

**Q: Firebase 관련 오류가 계속 나요**
A: GoogleService-Info.plist 파일이 프로젝트에 정확히 추가되었는지 재확인

---

## 도움이 필요하면

오류 메시지 전체를 캡처하여 공유해주세요. 특히:
- 빨간색 에러 메시지
- 파일명과 줄 번호
- 오류가 발생한 코드 라인

이 정보가 있으면 정확한 해결책을 제시할 수 있습니다.
