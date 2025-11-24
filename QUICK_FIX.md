# ⚡️ DiagnosisRecord 오류 빠른 해결 (2분)

## 문제
```
Cannot find type 'DiagnosisRecord' in scope
```

## 🎯 가장 빠른 해결법 (추천!)

### 방법: File Inspector에서 체크 (30초)

1. **Xcode 왼쪽 네비게이터**에서 다음 파일 클릭:
   ```
   AIhealth
     └─ Models
          └─ DiagnosisRecord.swift  ← 이 파일 클릭!
   ```

2. **오른쪽 패널** File Inspector 열기:
   - 단축키: `⌘⌥1` (Cmd + Option + 1)
   - 또는: 우측 상단의 📄 아이콘 클릭

3. **Target Membership** 섹션 찾기:
   ```
   Target Membership
   ☐ AIhealth          ← 여기 체크!
   ☐ AIhealthTests
   ☐ AIhealthUITests
   ```

4. **AIhealth** 체크박스를 ✅ 체크

5. **같은 방법으로** 다음 파일들도 체크:
   - ✅ `ChatMessage.swift`
   - ✅ `Reservation.swift`

6. **빌드 실행**:
   ```
   Product → Clean Build Folder (⇧⌘K)
   Product → Build (⌘B)
   ```

---

## 🔄 다른 오류가 나오면?

같은 패턴의 오류가 더 나올 수 있습니다:
- `Cannot find type 'ChatMessage'`
- `Cannot find type 'XXXViewModel'`
- `Cannot find 'FirebaseApp'`

**해결**: 위와 똑같은 방법으로 해당 파일의 Target Membership 체크!

---

## 📁 모든 파일 한번에 체크 (1분)

시간을 절약하려면 폴더 단위로 체크:

### Models 폴더 전체
1. `Models` 폴더 안의 모든 파일 선택 (⌘A)
2. 우측 File Inspector (⌘⌥1)
3. Target Membership → AIhealth 체크

### 다른 폴더들도 마찬가지
- ViewModels 폴더 → 전체 선택 → 체크
- Services 폴더 → 전체 선택 → 체크
- Views 폴더 → 전체 선택 → 체크
- Utilities 폴더 → 전체 선택 → 체크
- Theme 폴더 → 전체 선택 → 체크

---

## ✅ 성공 확인

빌드가 성공하면:
```
✅ Build Succeeded
```

앱이 시뮬레이터에서 실행되고 홈 화면이 표시됩니다!

---

## 🚨 여전히 오류?

### "No such module 'FirebaseCore'" 오류
→ `TROUBLESHOOTING.md` 2단계 참조

### 다른 타입을 찾을 수 없다는 오류
→ 해당 파일도 위와 같은 방법으로 체크

### Xcode가 느리거나 멈춤
→ Xcode 재시작 후 다시 시도

---

**소요 시간: 30초 ~ 2분**
**난이도: ⭐☆☆☆☆ (매우 쉬움)**
