//
//  View+HideKeyboard.swift
//  AIhealth
//
//  Created on 2025-10-30.
//

import SwiftUI

extension View {
    /// Hides the keyboard when tapping outside of text fields
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    /// Adds a toolbar with a "Done" button to dismiss the keyboard
    func keyboardToolbar() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }
}
