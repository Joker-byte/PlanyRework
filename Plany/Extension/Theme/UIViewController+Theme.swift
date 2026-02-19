//
//  UIViewController+Theme.swift
//  Plany
//
//  Created by Gianluca Dubioso on 26/01/2026.
//

import UIKit

extension UIViewController {
    
    func applyTheme() {
        let colors = ThemeManager.shared.colors
        
        view.backgroundColor = colors.background
        
        if let navigationBar = navigationController?.navigationBar {
            if #available(iOS 13.0, *) {
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
                
                navigationBar.standardAppearance = appearance
                navigationBar.scrollEdgeAppearance = appearance
                navigationBar.compactAppearance = appearance
            } else {
                navigationBar.barTintColor = colors.background
                navigationBar.titleTextAttributes = [
                    .foregroundColor: colors.text,
                    .font: ThemeFonts.semiBold(size: 18)
                ]
                navigationBar.isTranslucent = false
            }
            
            navigationBar.tintColor = colors.tint
        }
    }
    
    func observeThemeChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )
    }
    
    func removeThemeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func themeDidChange() {
        applyTheme()
        updateUIForTheme()
    }
    
    @objc func updateUIForTheme() {
    }
}

protocol Themed {
    func setupTheme()
}

extension Themed where Self: UIViewController {
    func setupTheme() {
        applyTheme()
        observeThemeChanges()
    }
}
