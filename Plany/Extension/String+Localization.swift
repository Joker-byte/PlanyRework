//
//  String+Localization.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

extension String {

    /// Returns the localized string for the current key
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }

    /// Returns the localized string with formatted arguments
    /// - Parameter arguments: Arguments to format the localized string
    /// - Returns: Formatted localized string
    func localized(with arguments: CVarArg...) -> String {
        let localizedString = self.localized
        return String(format: localizedString, arguments: arguments)
    }
}
