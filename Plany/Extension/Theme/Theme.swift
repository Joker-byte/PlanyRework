//
//  Theme.swift
//  Plany
//
//  Created by Gianluca Dubioso on 26/01/2026.
//

import UIKit

enum Theme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var displayName: String {
        switch self {
        case .light:
            return "theme.light".localized
        case .dark:
            return "theme.dark".localized
        case .system:
            return "theme.system".localized
        }
    }
}

struct ThemeColors {
    let background: UIColor
    let secondaryBackground: UIColor
    let cardBackground: UIColor
    let primary: UIColor
    let secondary: UIColor
    let text: UIColor
    let secondaryText: UIColor
    let separator: UIColor
    let tint: UIColor

    static let light = ThemeColors(
        background: UIColor(red: 0.102, green: 0.220, blue: 0.424, alpha: 1.0),
        secondaryBackground: UIColor(red: 0.122, green: 0.240, blue: 0.444, alpha: 1.0),
        cardBackground: UIColor(red: 0.142, green: 0.260, blue: 0.464, alpha: 1.0),
        primary: UIColor(red: 0.102, green: 0.220, blue: 0.424, alpha: 1.0),
        secondary: UIColor(red: 0.7, green: 0.4, blue: 0.95, alpha: 1.0),
        text: .white,
        secondaryText: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0),
        separator: UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0),
        tint: UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
    )

    static let dark = ThemeColors(
        background: UIColor(red: 0.118, green: 0.118, blue: 0.118, alpha: 1.0),
        secondaryBackground: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0),
        cardBackground: UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0),
        primary: UIColor(red: 0.2, green: 0.65, blue: 1.0, alpha: 1.0),
        secondary: UIColor(red: 0.6, green: 0.35, blue: 0.8, alpha: 1.0),
        text: .white,
        secondaryText: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0),
        separator: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0),
        tint: UIColor(red: 0.2, green: 0.65, blue: 1.0, alpha: 1.0)
    )
}

struct ThemeFonts {
    static let interRegular = "Inter-Regular"
    static let interMedium = "Inter-Medium"
    static let interSemiBold = "Inter-SemiBold"
    static let interBold = "Inter-Bold"

    static func regular(size: CGFloat) -> UIFont {
        return UIFont(name: interRegular, size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func medium(size: CGFloat) -> UIFont {
        return UIFont(name: interMedium, size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func semiBold(size: CGFloat) -> UIFont {
        return UIFont(name: interSemiBold, size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func bold(size: CGFloat) -> UIFont {
        return UIFont(name: interBold, size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
}
