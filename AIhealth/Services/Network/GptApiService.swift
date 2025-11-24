//
//  GptApiService.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation

// MARK: - GPT Request/Response Models
struct GptMessage: Codable {
    let role: String
    let content: String
}

struct GptRequest: Codable {
    let model: String
    let messages: [GptMessage]
    let temperature: Double
}

struct GptChoice: Codable {
    let message: GptMessage
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct GptResponse: Codable {
    let choices: [GptChoice]
}

// MARK: - GPT API Service
class GptApiService {
    static let shared = GptApiService()

    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private var apiKey: String = ""

    private init() {}

    func setApiKey(_ key: String) {
        self.apiKey = key
    }

    func getChatCompletion(messages: [GptMessage], temperature: Double = 0.7) async throws -> String {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "GptApiService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key not set"])
        }

        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "GptApiService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let gptRequest = GptRequest(model: "gpt-4o", messages: messages, temperature: temperature)
        request.httpBody = try JSONEncoder().encode(gptRequest)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "GptApiService", code: (response as? HTTPURLResponse)?.statusCode ?? 500,
                         userInfo: [NSLocalizedDescriptionKey: "HTTP Error"])
        }

        let gptResponse = try JSONDecoder().decode(GptResponse.self, from: data)

        guard let firstChoice = gptResponse.choices.first else {
            throw NSError(domain: "GptApiService", code: 500, userInfo: [NSLocalizedDescriptionKey: "No response from GPT"])
        }

        return firstChoice.message.content
    }
}
