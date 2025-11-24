import Foundation

// Test localization
print("=== Localization Test ===")
print("Current Language: \(Locale.current.language.languageCode?.identifier ?? "unknown")")
print("Preferred Languages: \(Locale.preferredLanguages)")
print("")

// Test NSLocalizedString
let testKeys = [
    "tab_home",
    "tab_consultation",
    "home_title",
    "ai_consultation_with_reservation"
]

for key in testKeys {
    let localized = NSLocalizedString(key, comment: "")
    print("\"\(key)\" = \"\(localized)\"")
}

print("")
print("If you see English values above but your system is in Korean,")
print("please check iPhone Settings > General > Language & Region")
