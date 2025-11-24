//
//  CommonTextField.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI

enum TextFieldVariant {
    case outlined
    case filled
}

struct CommonTextField: View {
    let placeholder: String
    @Binding var text: String
    var variant: TextFieldVariant = .outlined
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var leadingIcon: String? = nil
    var returnKeyType: UIReturnKeyType = .default
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: AppTheme.spacingSmall) {
            if let icon = leadingIcon {
                Image(systemName: icon)
                    .foregroundColor(.textSecondary)
                    .frame(width: 20)
            }

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .foregroundColor(.textPrimary)
                    .submitLabel(.done)
                    .onSubmit {
                        onSubmit?()
                    }
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .foregroundColor(.textPrimary)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        onSubmit?()
                    }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .stroke(borderColor, lineWidth: variant == .outlined ? 1 : 0)
        )
    }

    private var submitLabel: SubmitLabel {
        switch returnKeyType {
        case .next:
            return .next
        case .done:
            return .done
        default:
            return .return
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .outlined:
            return .backgroundSecondary
        case .filled:
            return .blueLight
        }
    }

    private var borderColor: Color {
        switch variant {
        case .outlined:
            return Color.textTertiary
        case .filled:
            return .clear
        }
    }
}

struct CommonTextEditor: View {
    let placeholder: String
    @Binding var text: String
    var height: CGFloat = 120

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }

            TextEditor(text: $text)
                .frame(height: height)
                .padding(4)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .foregroundColor(.textPrimary)
        }
        .padding(8)
        .background(Color.backgroundSecondary)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .stroke(Color.textTertiary, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        CommonTextField(placeholder: "이름", text: .constant(""), variant: .outlined)
        CommonTextField(placeholder: "이메일", text: .constant(""), variant: .filled, leadingIcon: "envelope")
        CommonTextField(placeholder: "비밀번호", text: .constant(""), isSecure: true)
        CommonTextEditor(placeholder: "증상을 입력하세요", text: .constant(""))
    }
    .padding()
}
