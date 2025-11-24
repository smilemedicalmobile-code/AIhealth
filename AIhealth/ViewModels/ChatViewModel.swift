//
//  ChatViewModel.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    static let shared = ChatViewModel()

    @Published var messages: [ChatMessage] = []
    @Published var currentMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isGeneratingSummary: Bool = false
    @Published var errorMessage: String?
    @Published var generatedSummary: String?

    private let chatRepository = ChatRepository()
    private let diagnosisRepository = DiagnosisRepository()

    private init() {}

    func sendMessage() {
        guard !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage(isUser: true, message: currentMessage)
        messages.append(userMessage)

        let messageToSend = currentMessage
        currentMessage = ""

        Task {
            await getAiResponse(for: messageToSend)
        }
    }

    private func getAiResponse(for message: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await chatRepository.getAiResponse(messages: messages)
            let aiMessage = ChatMessage(isUser: false, message: response)
            messages.append(aiMessage)
        } catch {
            errorMessage = "오류가 발생했습니다: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func endConsultationAndGenerateSummary() {
        Task {
            await generateSummary()
        }
    }

    private func generateSummary() async {
        guard !messages.isEmpty else { return }

        isGeneratingSummary = true
        errorMessage = nil

        do {
            let summary = try await chatRepository.summarizeReport(chatHistory: messages)
            generatedSummary = summary

            // Save diagnosis record
            let symptoms = messages.filter { $0.isUser }.map { $0.message }.joined(separator: ", ")
            let record = DiagnosisRecord(
                summary: summary,
                symptoms: symptoms,
                recommendations: "의료진 상담 권장"
            )

            try diagnosisRepository.saveDiagnosisRecord(record)
        } catch {
            errorMessage = "요약 생성 중 오류가 발생했습니다: \(error.localizedDescription)"
        }

        isGeneratingSummary = false
    }

    func clearChat() {
        messages.removeAll()
        currentMessage = ""
        generatedSummary = nil
        errorMessage = nil
        isGeneratingSummary = false
    }
}
