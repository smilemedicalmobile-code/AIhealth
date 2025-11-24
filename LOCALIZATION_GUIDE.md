# iOS 다국어 지원 구현 가이드

## 개요
AIhealth 앱을 여러 언어로 지원하기 위한 구현 방법입니다.

## 1. UI 텍스트 다국어화

### 1.1 Localizable.strings 파일 생성

**Xcode에서:**
1. File → New → File → Strings File
2. 파일명: `Localizable.strings`
3. 파일 선택 → File Inspector → Localize 버튼 클릭
4. 지원할 언어 선택 (Korean, English, Japanese 등)

### 1.2 각 언어별 번역 작성

**ko.lproj/Localizable.strings**
```swift
// 탭바
"tab_home" = "홈";
"tab_consultation" = "AI 상담";
"tab_reservation" = "예약";
"tab_records" = "내 기록";

// 홈 화면
"home_title" = "예약 방식 선택";
"ai_consultation_with_reservation" = "AI 상담 + 예약";
"ai_consultation_description" = "AI와 상담 후 병원 예약하기";
"direct_reservation" = "바로 예약하기";
"direct_reservation_description" = "증상을 알고 있다면 바로 예약";

// 예약 화면
"patient_info" = "환자 정보";
"name_placeholder" = "이름";
"phone_placeholder" = "연락처";
"hospital_type" = "병원 유형";
"private_hospital" = "개인병원";
"major_hospital" = "상급병원";
"select_region" = "희망 지역";
"select_date" = "희망 날짜";
"select_time" = "희망 시간";
"main_symptoms" = "주요 증상";
"additional_notes" = "기타 요청사항";
"submit_reservation" = "예약 제출";

// 버튼
"confirm" = "확인";
"cancel" = "취소";
"delete" = "삭제";
"save" = "저장";

// 메시지
"reservation_success" = "예약이 성공적으로 제출되었습니다.";
"reservation_error" = "예약 제출 중 오류가 발생했습니다.";
```

**en.lproj/Localizable.strings**
```swift
// Tabs
"tab_home" = "Home";
"tab_consultation" = "AI Consultation";
"tab_reservation" = "Reservation";
"tab_records" = "My Records";

// Home Screen
"home_title" = "Choose Reservation Method";
"ai_consultation_with_reservation" = "AI Consultation + Reservation";
"ai_consultation_description" = "Consult with AI and reserve hospital";
"direct_reservation" = "Direct Reservation";
"direct_reservation_description" = "Quick reservation if you know symptoms";

// Reservation Screen
"patient_info" = "Patient Information";
"name_placeholder" = "Name";
"phone_placeholder" = "Phone Number";
"hospital_type" = "Hospital Type";
"private_hospital" = "Private Hospital";
"major_hospital" = "Major Hospital";
"select_region" = "Select Region";
"select_date" = "Select Date";
"select_time" = "Select Time";
"main_symptoms" = "Main Symptoms";
"additional_notes" = "Additional Notes";
"submit_reservation" = "Submit Reservation";

// Buttons
"confirm" = "Confirm";
"cancel" = "Cancel";
"delete" = "Delete";
"save" = "Save";

// Messages
"reservation_success" = "Reservation submitted successfully.";
"reservation_error" = "Error occurred while submitting reservation.";
```

### 1.3 코드에서 사용

**방법 1: String Extension 사용 (권장)**

```swift
// Extensions/String+Localization.swift
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// 사용
Text("home_title".localized)
Button("submit_reservation".localized) { }
Text("welcome_message".localized(with: userName))
```

**방법 2: LocalizedStringKey 사용**

```swift
Text("home_title")  // SwiftUI가 자동으로 localize
```

## 2. AI 프롬프트 다국어화

### 2.1 SystemPrompt 클래스 수정

```swift
import Foundation

class SystemPrompt {
    // 현재 시스템 언어 감지
    static var currentLanguage: String {
        Locale.current.language.languageCode?.identifier ?? "ko"
    }

    // 언어별 프롬프트 가져오기
    static func getPrompt() -> String {
        switch currentLanguage {
        case "ko":
            return koreanPrompt
        case "en":
            return englishPrompt
        case "ja":
            return japanesePrompt
        case "zh":
            return chinesePrompt
        default:
            return englishPrompt  // 기본값: 영어
        }
    }

    // 요약 생성용 프롬프트
    static func getSummaryPrompt() -> String {
        switch currentLanguage {
        case "ko":
            return koreanSummaryPrompt
        case "en":
            return englishSummaryPrompt
        case "ja":
            return japaneseSummaryPrompt
        default:
            return englishSummaryPrompt
        }
    }

    // MARK: - Korean Prompts
    private static let koreanPrompt = """
    당신은 친절하고 전문적인 AI 건강 상담 어시스턴트입니다.

    역할:
    - 환자의 증상을 경청하고 이해합니다
    - 적절한 질문을 통해 더 자세한 정보를 수집합니다
    - 가능한 원인과 권장사항을 제시합니다

    주의사항:
    - 진단을 내리지 마세요 (의사만 가능)
    - "~일 수 있습니다", "~가능성이 있습니다" 등의 표현 사용
    - 심각한 증상인 경우 즉시 병원 방문 권장

    답변 형식:
    1. 공감과 이해 표현
    2. 추가 질문 (필요시)
    3. 가능한 원인 설명
    4. 권장 사항 및 진료과 추천
    """

    private static let koreanSummaryPrompt = """
    다음 대화 내용을 바탕으로 상담 결과를 요약해주세요.

    포함 내용:
    1. 주요 증상 (불릿 포인트)
    2. 증상 지속 기간 및 특이사항
    3. 추천 진료과
    4. 권장 사항 (생활 습관, 주의사항 등)

    형식: 마크다운으로 작성, 명확하고 간결하게
    """

    // MARK: - English Prompts
    private static let englishPrompt = """
    You are a friendly and professional AI health consultation assistant.

    Your Role:
    - Listen to and understand patient symptoms
    - Ask appropriate follow-up questions for more details
    - Suggest possible causes and recommendations

    Important Notes:
    - Do NOT provide medical diagnoses (only doctors can diagnose)
    - Use phrases like "it could be", "it's possible that"
    - For serious symptoms, recommend immediate medical attention

    Response Format:
    1. Show empathy and understanding
    2. Ask follow-up questions (if needed)
    3. Explain possible causes
    4. Provide recommendations and suggest medical departments
    """

    private static let englishSummaryPrompt = """
    Please summarize the consultation based on the following conversation.

    Include:
    1. Main Symptoms (bullet points)
    2. Duration and notable characteristics
    3. Recommended Medical Department
    4. Recommendations (lifestyle, precautions, etc.)

    Format: Write in markdown, clear and concise
    """

    // MARK: - Japanese Prompts
    private static let japanesePrompt = """
    あなたは親切で専門的なAI健康相談アシスタントです。

    役割:
    - 患者の症状を傾聴し理解する
    - 適切な質問を通じてより詳細な情報を収集する
    - 可能な原因と推奨事項を提示する

    注意事項:
    - 診断を下さないでください（医師のみ可能）
    - 「〜の可能性があります」などの表現を使用
    - 深刻な症状の場合、すぐに病院を訪問することを推奨

    回答形式:
    1. 共感と理解の表現
    2. 追加質問（必要に応じて）
    3. 可能な原因の説明
    4. 推奨事項と診療科の推薦
    """

    private static let japaneseSummaryPrompt = """
    次の会話内容に基づいて相談結果を要約してください。

    含める内容:
    1. 主な症状（箇条書き）
    2. 症状の持続期間と特記事項
    3. 推奨診療科
    4. 推奨事項（生活習慣、注意事項など）

    形式: Markdownで作成、明確かつ簡潔に
    """
}
```

### 2.2 ChatRepository에서 사용

```swift
class ChatRepository {
    private let gptService = GptApiService.shared

    func getAiResponse(messages: [ChatMessage]) async throws -> String {
        // 현재 언어에 맞는 시스템 프롬프트 사용
        var gptMessages = [
            GptMessage(role: "system", content: SystemPrompt.getPrompt())
        ]

        // 대화 히스토리 추가
        for message in messages {
            let role = message.isUser ? "user" : "assistant"
            gptMessages.append(GptMessage(role: role, content: message.message))
        }

        return try await gptService.getChatCompletion(messages: gptMessages)
    }

    func summarizeReport(chatHistory: [ChatMessage]) async throws -> String {
        let conversation = chatHistory.map { message in
            let speaker = message.isUser ? "환자" : "AI"
            return "\(speaker): \(message.message)"
        }.joined(separator: "\n\n")

        let messages = [
            GptMessage(role: "system", content: SystemPrompt.getSummaryPrompt()),
            GptMessage(role: "user", content: conversation)
        ]

        return try await gptService.getChatCompletion(messages: messages, temperature: 0.3)
    }
}
```

## 3. 날짜/시간 포맷 자동 현지화

```swift
// 날짜 포맷 - 자동으로 현지 언어 적용
let formatter = DateFormatter()
formatter.dateFormat = "yyyy년 MM월 dd일"  // ❌ 하드코딩
formatter.dateStyle = .long  // ✅ 자동 현지화
formatter.locale = Locale.current

// 한국: 2025년 10월 29일
// 영어: October 29, 2025
// 일본어: 2025年10月29日
```

## 4. 숫자 포맷 현지화

```swift
let numberFormatter = NumberFormatter()
numberFormatter.numberStyle = .decimal
numberFormatter.locale = Locale.current

// 한국: 1,234,567
// 미국: 1,234,567
// 유럽: 1.234.567
```

## 5. Firebase 데이터 다국어 처리

### 5.1 저장 시 언어 정보 포함

```swift
struct Reservation: Codable {
    // ... 기존 필드
    var preferredLanguage: String  // "ko", "en", "ja"
}

// 저장 시
var reservation = Reservation()
reservation.preferredLanguage = Locale.current.language.languageCode?.identifier ?? "ko"
```

### 5.2 병원 이름 다국어 지원

```swift
enum MajorHospital: String, CaseIterable {
    case snuh = "seoul_national_university_hospital"
    case amc = "asan_medical_center"

    var localizedName: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

// Localizable.strings
// ko: "seoul_national_university_hospital" = "서울대학교병원";
// en: "seoul_national_university_hospital" = "Seoul National University Hospital";
// ja: "seoul_national_university_hospital" = "ソウル大学校病院";
```

## 6. 테스트 방법

### 6.1 시뮬레이터에서 언어 변경
1. Settings → General → Language & Region
2. iPhone Language 변경
3. 앱 재시작

### 6.2 Xcode에서 언어별 미리보기
```swift
#Preview {
    Text("home_title")
        .environment(\.locale, Locale(identifier: "en"))
}
```

## 7. 주의사항

### 7.1 RTL (Right-to-Left) 언어 지원
아랍어, 히브리어 등을 지원하려면:
```swift
.environment(\.layoutDirection, .rightToLeft)
```

### 7.2 텍스트 길이 고려
- 영어가 가장 짧고, 독일어가 가장 김
- UI 레이아웃이 유연하게 대응하도록 설계

### 7.3 문화적 차이 고려
- 색상 의미 (한국: 빨간색=위험, 중국: 빨간색=행운)
- 의료 용어 차이
- 개인정보 수집 범위 차이

## 8. 구현 우선순위

1. **Phase 1: 핵심 UI 다국어화**
   - 탭바, 버튼, 레이블
   - 에러 메시지

2. **Phase 2: AI 프롬프트 다국어화**
   - 주요 언어 (한/영/일) 프롬프트 작성
   - 테스트 및 개선

3. **Phase 3: 데이터 다국어화**
   - 병원 이름, 진료과 이름
   - Firebase 데이터 구조 조정

4. **Phase 4: 고급 기능**
   - 앱 내 언어 전환 기능
   - 음성 인식 다국어 지원

## 9. 비용 고려사항

### OpenAI API 비용
- 언어별로 다른 프롬프트 사용
- 언어에 따라 토큰 수가 달라짐
  - 영어: 가장 효율적 (토큰 적음)
  - 한국어/일본어/중국어: 토큰 더 많이 사용
  - 비용 약 1.5~2배 증가 가능

## 10. 추천 구현 순서

```
1. Localizable.strings 파일 생성 (30분)
2. String Extension 작성 (10분)
3. 핵심 화면 5개 다국어화 (2시간)
4. SystemPrompt 다국어화 (1시간)
5. 테스트 (1시간)
---
Total: 약 5시간
```

## 결론

**시스템 언어를 자동으로 따라가게 만들 수 있습니다!**

- UI: `Localizable.strings` + `NSLocalizedString`
- AI: 언어별 프롬프트 작성 필요
- 날짜/숫자: iOS가 자동 처리
- 추가 비용: OpenAI API 사용량 약간 증가

구현하실까요?
