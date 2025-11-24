//
//  LoadingView.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI

struct LoadingView: View {
    var message: String = "로딩 중..."

    var body: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .bluePrimary))
                .scaleEffect(1.5)

            Text(message)
                .font(.system(size: AppTheme.fontSizeMedium))
                .foregroundColor(.textSecondary)
        }
        .padding(AppTheme.spacingXLarge)
        .background(Color.backgroundSecondary)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(radius: AppTheme.shadowRadius)
    }
}

struct LoadingOverlay: View {
    var message: String = "처리 중..."

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            LoadingView(message: message)
        }
    }
}

struct TypingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.bluePrimary, Color.mintAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 10, height: 10)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.3)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LoadingView()
        LoadingView(message: "데이터를 불러오는 중...")
        TypingIndicator()
    }
    .padding()
    .background(Color.backgroundPrimary)
}
