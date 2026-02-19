//
//  ThemeManager.swift
//  Plany
//
//  Created by Gianluca Dubioso on 26/01/2026.
//

import UIKit

class ThemeManager {
    
    static let shared = ThemeManager()
    
    private let themeKey = "selectedTheme"
    
    static let themeDidChangeNotification = Notification.Name("ThemeDidChange")
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemThemeDidChange),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    var selectedTheme: Theme {
        get {
            if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
               let theme = Theme(rawValue: savedTheme) {
                return theme
            }
            return .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeKey)
            applyTheme()
        }
    }
    
    var currentTheme: Theme {
        switch selectedTheme {
        case .system:
            if #available(iOS 13.0, *) {
                return UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
            } else {
                return .light
            }
        case .light, .dark:
            return selectedTheme
        }
    }
    
    var colors: ThemeColors {
        return currentTheme == .dark ? ThemeColors.dark : ThemeColors.light
    }
    
    func applyTheme() {
        let style: UIUserInterfaceStyle
        
        switch selectedTheme {
        case .light:
            style = .light
        case .dark:
            style = .dark
        case .system:
            style = .unspecified
        }
        
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = style
                }
            }
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = colors.background
            appearance.titleTextAttributes = [
                .foregroundColor: colors.text,
                .font: ThemeFonts.semiBold(size: 18)
            ]
            appearance.largeTitleTextAttributes = [
                .foregroundColor: colors.text,
                .font: ThemeFonts.bold(size: 34)
            ]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().tintColor = colors.tint
        } else {
            UINavigationBar.appearance().barTintColor = colors.background
            UINavigationBar.appearance().tintColor = colors.tint
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: colors.text,
                .font: ThemeFonts.semiBold(size: 18)
            ]
            UINavigationBar.appearance().isTranslucent = false
        }
        
        UITabBar.appearance().barTintColor = colors.background
        UITabBar.appearance().tintColor = colors.tint
        UITabBar.appearance().unselectedItemTintColor = colors.secondaryText
        
        UITableView.appearance().backgroundColor = colors.background
        UITableView.appearance().separatorColor = colors.separator
        
        UICollectionView.appearance().backgroundColor = colors.background
        
        UITextField.appearance().textColor = colors.text
        UITextField.appearance().tintColor = colors.primary
        
        UITextView.appearance().textColor = colors.text
        UITextView.appearance().tintColor = colors.primary
        
        UILabel.appearance().textColor = colors.text
        
        UISearchBar.appearance().tintColor = colors.primary
        
        NotificationCenter.default.post(name: ThemeManager.themeDidChangeNotification, object: nil)
    }
    
    func applyGradient(to view: UIView, cornerRadius: CGFloat = 10) {
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            ThemeConstants.Colors.gradientStart(for: currentTheme).cgColor,
            ThemeConstants.Colors.gradientEnd(for: currentTheme).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc private func systemThemeDidChange() {
        if selectedTheme == .system {
            applyTheme()
        }
    }
    
    func textColor(for backgroundColor: UIColor) -> UIColor {
        var white: CGFloat = 0
        backgroundColor.getWhite(&white, alpha: nil)
        return white > 0.5 ? colors.text : .white
    }
}
