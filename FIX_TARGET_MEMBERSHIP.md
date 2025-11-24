# Target Membership 문제 해결 가이드

## 문제
"Cannot find type 'DiagnosisRecord' in scope" 오류는 파일이 타겟에 포함되지 않았음을 의미합니다.

## 빠른 해결 (Xcode)

### 방법 1: 개별 파일 수정
1. 오류가 난 타입의 파일 선택 (예: `DiagnosisRecord.swift`)
2. 우측 **File Inspector** (⌘⌥1)
3. **Target Membership** → **AIhealth** 체크
4. 빌드 (⌘B)

### 방법 2: 폴더 전체 재추가
1. 좌측에서 **Models** 폴더 우클릭 → Delete → **Remove Reference**
2. **AIhealth** 폴더 우클릭 → Add Files to "AIhealth"
3. `Models` 폴더 선택
4. 옵션 확인:
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to targets: AIhealth
5. Add 클릭

### 방법 3: 모든 Swift 파일 확인
다음 폴더들의 모든 파일이 타겟에 포함되어야 합니다:
- ✅ Models/
- ✅ ViewModels/
- ✅ Views/
- ✅ Services/
- ✅ Utilities/
- ✅ Theme/

각 폴더에서:
1. 모든 Swift 파일 선택 (⌘A)
2. 우측 File Inspector (⌘⌥1)
3. Target Membership → AIhealth 체크

## Clean Build
항상 마지막에:
1. Product → Clean Build Folder (⇧⌘K)
2. Product → Build (⌘B)

## 여전히 오류가 나면

다른 타입도 같은 오류가 있는지 확인:
- ChatMessage
- Reservation
- 기타 커스텀 타입들

모두 같은 방법으로 해결하세요.
