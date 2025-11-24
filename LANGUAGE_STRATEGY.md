# AI 언어 전략 - 하이브리드 방식 추천

## 추천 방식: 스마트 언어 매칭

### 기본 원칙:
1. **시스템 언어를 기본값으로 사용**
2. **사용자가 다른 언어로 질문하면 그 언어로 대화 계속**
3. **새 대화 시작 시 다시 시스템 언어로 초기화**

### 구현 로직:

```swift
// ChatViewModel에 언어 감지 로직 추가
class ChatViewModel {
    @Published var conversationLanguage: String?  // 현재 대화 언어

    func detectLanguage(from text: String) -> String {
        // 간단한 언어 감지
        let koreanPattern = "[ㄱ-ㅎㅏ-ㅣ가-힣]"
        let japanesePattern = "[ぁ-ゔァ-ヴー一-龯]"

        if text.range(of: koreanPattern, options: .regularExpression) != nil {
            return "ko"
        } else if text.range(of: japanesePattern, options: .regularExpression) != nil {
            return "ja"
        } else {
            return "en"
        }
    }

    func getPromptLanguage() -> String {
        // 대화 중 언어가 설정되어 있으면 그것 사용
        if let lang = conversationLanguage {
            return lang
        }
        // 아니면 시스템 언어
        return SystemPrompt.currentLanguage
    }
}
```

### 사용자 경험:

#### 시나리오 1: 한국 사용자 (정상 사용)
```
시스템 언어: 한국어
사용자: "머리가 아파요"
AI: "머리가 아프시군요..." ✅
```

#### 시나리오 2: 외국인 관광객
```
시스템 언어: 한국어 (친구 폰 빌림)
사용자: "I have a fever"
AI: "I understand. A fever can indicate..." ✅
→ 이후 계속 영어로 대화
```

#### 시나리오 3: 새 상담 시작
```
상담 종료 후 새 상담 시작
→ 다시 시스템 언어(한국어)로 초기화 ✅
```

### 장점:
- ✅ 일반 사용자: 혼란 없음 (시스템 언어만 사용)
- ✅ 다국어 사용자: 자유롭게 전환 가능
- ✅ UI 일관성: 첫 인사는 항상 시스템 언어
- ✅ 실수 방지: 새 대화마다 초기화

## 구현 우선순위

### Option A: 시스템 언어만 (현재)
**난이도**: ⭐ (이미 구현됨)
**추천 대상**: MVP, 빠른 출시, 한국 시장만

### Option B: 질문 언어 따라가기
**난이도**: ⭐⭐
**추천 대상**: 글로벌 서비스

### Option C: 하이브리드 (추천) ⭐
**난이도**: ⭐⭐⭐
**추천 대상**: 완성도 높은 서비스

## 결론

**단기**: 시스템 언어만 사용 (현재 유지)
**장기**: 하이브리드 방식으로 업그레이드

사용자가 어떤 경험을 원하는지에 따라 결정하세요!
