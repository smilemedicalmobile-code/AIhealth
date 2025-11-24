//
//  CommonCard.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI

struct CommonCard<Content: View>: View {
    let content: Content
    var useGradient: Bool = false

    init(useGradient: Bool = false, @ViewBuilder content: () -> Content) {
        self.useGradient = useGradient
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppTheme.spacingMedium)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if useGradient {
                        AppGradients.cardGradient
                    } else {
                        Color.backgroundSecondary
                    }
                }
            )
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(color: Color.black.opacity(AppTheme.shadowOpacity),
                   radius: AppTheme.shadowRadius,
                   x: 0,
                   y: AppTheme.shadowY)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingMedium) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.bluePrimary)

                Text(title)
                    .font(.system(size: AppTheme.fontSizeLarge, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(AppTheme.spacingLarge)
            .frame(maxWidth: .infinity)
            .background(AppGradients.cardGradient)
            .cornerRadius(AppTheme.cornerRadiusLarge)
            .shadow(color: Color.black.opacity(0.08),
                   radius: 8,
                   x: 0,
                   y: 4)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: AppTheme.fontSizeHeading, weight: .bold))
                .foregroundColor(.textPrimary)

            Text(title)
                .font(.system(size: AppTheme.fontSizeMedium))
                .foregroundColor(.textSecondary)
        }
        .padding(AppTheme.spacingMedium)
        .background(Color.backgroundSecondary)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(color: Color.black.opacity(AppTheme.shadowOpacity),
               radius: AppTheme.shadowRadius,
               x: 0,
               y: AppTheme.shadowY)
    }
}

#Preview {
    VStack(spacing: 16) {
        CommonCard {
            Text("Basic Card Content")
        }

        CommonCard(useGradient: true) {
            Text("Gradient Card Content")
        }

        FeatureCard(
            icon: "stethoscope",
            title: "AI 상담",
            description: "AI와 건강 상담하기"
        ) {}

        StatCard(
            title: "진료 기록",
            value: "12",
            icon: "doc.text.fill",
            color: .bluePrimary
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}
