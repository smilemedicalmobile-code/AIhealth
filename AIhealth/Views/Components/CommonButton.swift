//
//  CommonButton.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI

enum ButtonVariant {
    case primary
    case secondary
    case outlined
    case text
}

struct CommonButton: View {
    let title: String
    let variant: ButtonVariant
    let action: () -> Void
    var isLoading: Bool = false
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                } else {
                    Text(title)
                        .font(.system(size: AppTheme.fontSizeLarge, weight: .semibold))
                        .foregroundColor(textColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(borderColor, lineWidth: variant == .outlined ? 1.5 : 0)
            )
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.5)
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return .bluePrimary
        case .secondary:
            return .mintAccent
        case .outlined, .text:
            return .clear
        }
    }

    private var textColor: Color {
        switch variant {
        case .primary, .secondary:
            return .white
        case .outlined:
            return .bluePrimary
        case .text:
            return .bluePrimary
        }
    }

    private var borderColor: Color {
        switch variant {
        case .outlined:
            return .bluePrimary
        default:
            return .clear
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CommonButton(title: "Primary Button", variant: .primary) {}
        CommonButton(title: "Secondary Button", variant: .secondary) {}
        CommonButton(title: "Outlined Button", variant: .outlined) {}
        CommonButton(title: "Text Button", variant: .text) {}
        CommonButton(title: "Loading...", variant: .primary, action: {}, isLoading: true)
        CommonButton(title: "Disabled", variant: .primary, action: {}, isEnabled: false)
    }
    .padding()
}
