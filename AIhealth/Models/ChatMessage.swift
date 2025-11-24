//
//  ChatMessage.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: String
    let isUser: Bool
    let message: String
    let timestamp: Date

    init(id: String = UUID().uuidString, isUser: Bool, message: String, timestamp: Date = Date()) {
        self.id = id
        self.isUser = isUser
        self.message = message
        self.timestamp = timestamp
    }
}
