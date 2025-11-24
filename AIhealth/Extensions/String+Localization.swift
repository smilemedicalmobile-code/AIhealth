//
//  String+Localization.swift
//  AIhealth
//
//  Created on 2025-10-29.
//

import Foundation

extension String {
    /// Returns localized string for the current key
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// Returns localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}
