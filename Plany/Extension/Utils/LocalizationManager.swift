//
//  LocalizationManager.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

enum AppLanguage: String, CaseIterable {
    case system = "system"
    case english = "en"
    case italian = "it"

    var displayName: String {
        switch self {
        case .system:
            return "System Default"
        case .english:
            return "English"
        case .italian:
            return "Italiano"
        }
    }
}

final class LocalizationManager {

    static let shared = LocalizationManager()

    private let languageKey = "AppLanguage"

    // Notification name for language changes
    static let languageDidChangeNotification = Notification.Name("LanguageDidChange")

    private init() {
        // Initialize bundle on first load
        updateCurrentBundle()
    }

    var currentLanguage: AppLanguage {
        get {
            guard let languageCode = UserDefaults.standard.string(forKey: languageKey),
                let language = AppLanguage(rawValue: languageCode)
            else {
                return .system
            }
            return language
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: languageKey)
            UserDefaults.standard.synchronize()

            // Update the bundle for localization
            updateCurrentBundle()

            // Post notification for UI update
            NotificationCenter.default.post(
                name: LocalizationManager.languageDidChangeNotification,
                object: nil
            )
        }
    }

    private var bundle: Bundle = Bundle.main

    private func updateCurrentBundle() {
        let languageCode = getLanguageCode()

        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        {
            self.bundle = bundle
        } else {
            self.bundle = Bundle.main
        }
    }

    private func getLanguageCode() -> String {
        switch currentLanguage {
        case .system:
            // Use device's preferred language
            return Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        case .english:
            return "en"
        case .italian:
            return "it"
        }
    }

    func localizedString(for key: String, comment: String = "") -> String {
        if currentLanguage == .system {
            // Use system localization
            return NSLocalizedString(key, comment: comment)
        } else {
            // Use custom bundle
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
    }

    // Reset to system language
    func resetToSystemLanguage() {
        currentLanguage = .system
    }
}
