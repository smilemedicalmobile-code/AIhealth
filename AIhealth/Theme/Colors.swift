//
//  Colors.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI
import UIKit

extension Color {
    // MARK: - Primary Colors (Blue Pastel + Light Mint)
    static let bluePrimary = Color(
        light: Color(hex: "42A5F5"),
        dark: Color(hex: "64B5F6")
    )
    static let blueLight = Color(
        light: Color(hex: "E3F2FD"),
        dark: Color(hex: "1E3A5F")
    )
    static let blueDark = Color(
        light: Color(hex: "1E88E5"),
        dark: Color(hex: "42A5F5")
    )

    static let mintAccent = Color(
        light: Color(hex: "66BB6A"),
        dark: Color(hex: "81C784")
    )
    static let mintLight = Color(
        light: Color(hex: "E8F5E9"),
        dark: Color(hex: "1B3A1F")
    )
    static let mintDark = Color(
        light: Color(hex: "4CAF50"),
        dark: Color(hex: "66BB6A")
    )

    // MARK: - Gradient Colors
    static let gradientStart = Color(
        light: Color(hex: "42A5F5"),
        dark: Color(hex: "64B5F6")
    )
    static let gradientEnd = Color(
        light: Color(hex: "66BB6A"),
        dark: Color(hex: "81C784")
    )

    static let cardGradientStart = Color(
        light: Color(hex: "E3F2FD"),
        dark: Color(hex: "1E3A5F")
    )
    static let cardGradientEnd = Color(
        light: Color(hex: "F1F8E9"),
        dark: Color(hex: "1B3A1F")
    )

    // MARK: - Background Colors
    static let backgroundPrimary = Color(
        light: Color(hex: "FAFAFA"),
        dark: Color(hex: "121212")
    )
    static let backgroundSecondary = Color(
        light: .white,
        dark: Color(hex: "1E1E1E")
    )

    // MARK: - Text Colors
    static let textPrimary = Color(
        light: Color(hex: "212121"),
        dark: Color(hex: "E0E0E0")
    )
    static let textSecondary = Color(
        light: Color(hex: "757575"),
        dark: Color(hex: "B0B0B0")
    )
    static let textTertiary = Color(
        light: Color(hex: "BDBDBD"),
        dark: Color(hex: "757575")
    )

    // MARK: - Status Colors
    static let successColor = Color(
        light: Color(hex: "4CAF50"),
        dark: Color(hex: "66BB6A")
    )
    static let errorColor = Color(
        light: Color(hex: "F44336"),
        dark: Color(hex: "EF5350")
    )
    static let warningColor = Color(
        light: Color(hex: "FF9800"),
        dark: Color(hex: "FFA726")
    )
    static let infoColor = Color(
        light: Color(hex: "2196F3"),
        dark: Color(hex: "42A5F5")
    )

    // MARK: - Helpers
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    // Initialize with different colors for light and dark mode
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Gradients
struct AppGradients {
    static let primaryGradient = LinearGradient(
        colors: [.gradientStart, .gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let secondaryGradient = LinearGradient(
        colors: [.blueLight, .mintLight],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardGradient = LinearGradient(
        colors: [.cardGradientStart, .cardGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
