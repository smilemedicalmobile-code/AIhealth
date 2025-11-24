//
//  Theme.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI

struct AppTheme {
    // MARK: - Corner Radius
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXLarge: CGFloat = 24

    // MARK: - Spacing
    static let spacingXSmall: CGFloat = 4
    static let spacingSmall: CGFloat = 8
    static let spacingMedium: CGFloat = 16
    static let spacingLarge: CGFloat = 24
    static let spacingXLarge: CGFloat = 32

    // MARK: - Font Sizes
    static let fontSizeSmall: CGFloat = 12
    static let fontSizeMedium: CGFloat = 14
    static let fontSizeLarge: CGFloat = 16
    static let fontSizeXLarge: CGFloat = 20
    static let fontSizeTitle: CGFloat = 24
    static let fontSizeHeading: CGFloat = 28

    // MARK: - Shadow
    static let shadowRadius: CGFloat = 4
    static let shadowY: CGFloat = 2
    static let shadowOpacity: Double = 0.1
}

// MARK: - View Modifiers
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.backgroundSecondary)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(color: Color.black.opacity(AppTheme.shadowOpacity),
                   radius: AppTheme.shadowRadius,
                   x: 0,
                   y: AppTheme.shadowY)
    }
}

struct GradientCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppGradients.cardGradient)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(color: Color.black.opacity(AppTheme.shadowOpacity),
                   radius: AppTheme.shadowRadius,
                   x: 0,
                   y: AppTheme.shadowY)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }

    func gradientCardStyle() -> some View {
        modifier(GradientCardModifier())
    }
}
