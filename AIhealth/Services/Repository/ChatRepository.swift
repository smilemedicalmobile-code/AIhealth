//
//  ChatRepository.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation

class ChatRepository {
    private let apiService = GptApiService.shared

    func getAiResponse(messages: [ChatMessage]) async throws -> String {
        let gptMessages = [
            GptMessage(role: "system", content: SystemPrompt.defaultPrompt)
        ] + messages.map { msg in
            GptMessage(role: msg.isUser ? "user" : "assistant", content: msg.message)
        }

        return try await apiService.getChatCompletion(messages: gptMessages, temperature: 0.7)
    }

    func summarizeReport(chatHistory: [ChatMessage]) async throws -> String {
        var conversationText = "대화 내용:\n\n"

        for message in chatHistory {
            let speaker = message.isUser ? "환자" : "AI 상담사"
            conversationText += "\(speaker): \(message.message)\n\n"
        }

        let messages = [
            GptMessage(role: "system", content: SystemPrompt.summaryPrompt),
            GptMessage(role: "user", content: conversationText)
        ]

        return try await apiService.getChatCompletion(messages: messages, temperature: 0.5)
    }
}
