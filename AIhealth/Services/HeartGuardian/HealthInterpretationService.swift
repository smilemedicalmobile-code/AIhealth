import Foundation

class HealthInterpretationService {
    private let gptService = GptApiService.shared

    func getInterpretation(bpm: Double, hrv: Double) async -> String {
        let prompt = """
        당신은 생리학적 데이터를 기반으로 교육 정보를 제공하는 유용한 건강 도우미입니다.
        사용자의 측정 결과, 평균 심박수는 \(String(format: "%.1f", bpm)) BPM, 심박 변이도(HRV)는 \(String(format: "%.1f", hrv)) ms(SDNN)입니다.

        의료 지식이 없는 사용자를 위해 이 결과를 간단하고 이해하기 쉽게 해석해 주세요.
        1. 안정 시 심박수가 무엇인지 간략히 설명하고 일반적인 건강 범위(예: 60-100 BPM)를 알려주세요.
        2. 심박 변이도(HRV)가 무엇인지 간단한 용어로 설명해주세요(예: 심장 박동 사이의 시간 변화, 높을수록 좋음).
        3. 사용자의 데이터를 기반으로 일반적인 해석을 제공해주세요. 예를 들어, BPM이 정상 범위이고 HRV가 높으면 안정된 상태를 시사할 수 있습니다. BPM이 높고 HRV가 낮으면 스트레스나 최근 활동을 의미할 수 있습니다.
        4. 어떠한 의학적 조언, 진단 또는 예측도 제공하지 마세요.
        5. 이것은 의료 기기가 아니며 건강 문제가 있을 경우 의료 전문가와 상담해야 한다는 명확하고 강력한 면책 조항으로 마무리해주세요.

        응답은 명확하고 간결하며 격려하는 방식으로 구성해주세요. 한국어로 답변해주세요.
        """

        do {
            let messages = [GptMessage(role: "user", content: prompt)]
            let response = try await gptService.getChatCompletion(messages: messages, temperature: 0.7)
            return response
        } catch {
            print("GPT API Error: \(error)")
            return "hg_error_ai_unavailable".localized
        }
    }
}
