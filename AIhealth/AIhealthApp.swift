//
//  AIhealthApp.swift
//  AIhealth
//
//  Created by 채동주 on 10/28/25.
//

import SwiftUI
import FirebaseCore

@main
struct AIhealthApp: App {
    init() {
        FirebaseApp.configure()

        // Fetch Remote Config for OpenAI API Key
        Task {
            do {
                try await FirebaseManager.shared.fetchRemoteConfig()
                let apiKey = FirebaseManager.shared.getOpenAIApiKey()
                GptApiService.shared.setApiKey(apiKey)
            } catch {
                print("Failed to fetch remote config: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
