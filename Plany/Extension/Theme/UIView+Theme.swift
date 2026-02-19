//
//  UIView+Theme.swift
//  Plany
//
//  Created by Gianluca Dubioso on 26/01/2026.
//

import UIKit

extension UIView {
    
    func applyCardStyle() {
        let theme = ThemeManager.shared.colors
        backgroundColor = theme.cardBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
    }
    
    func applySeparatorStyle() {
        let theme = ThemeManager.shared.colors
        backgroundColor = theme.separator
    }
}

extension UILabel {
    
    func applyTheme(style: LabelStyle = .body) {
        let theme = ThemeManager.shared.colors
        
        switch style {
        case .title:
            font = ThemeFonts.bold(size: 24)
            textColor = theme.text
        case .subtitle:
            font = ThemeFonts.semiBold(size: 18)
            textColor = theme.text
        case .body:
            font = ThemeFonts.regular(size: 16)
            textColor = theme.text
        case .caption:
            font = ThemeFonts.regular(size: 14)
            textColor = theme.secondaryText
        case .small:
            font = ThemeFonts.regular(size: 12)
            textColor = theme.secondaryText
        }
    }
    
    enum LabelStyle {
        case title
        case subtitle
        case body
        case caption
        case small
    }
}

extension UIButton {
    
    func applyTheme(style: ButtonStyle = .primary) {
        let theme = ThemeManager.shared.colors
        
        switch style {
        case .primary:
            backgroundColor = theme.primary
            setTitleColor(.white, for: .normal)
            titleLabel?.font = ThemeFonts.semiBold(size: 16)
            layer.cornerRadius = 8
        case .secondary:
            backgroundColor = .clear
            setTitleColor(theme.primary, for: .normal)
            titleLabel?.font = ThemeFonts.medium(size: 16)
            layer.borderColor = theme.primary.cgColor
            layer.borderWidth = 1.5
            layer.cornerRadius = 8
        case .text:
            backgroundColor = .clear
            setTitleColor(theme.primary, for: .normal)
            titleLabel?.font = ThemeFonts.medium(size: 16)
        }
        
        tintColor = theme.tint
    }
    
    enum ButtonStyle {
        case primary
        case secondary
        case text
    }
}

extension UITextField {
    
    func applyTheme() {
        let theme = ThemeManager.shared.colors
        backgroundColor = theme.cardBackground
        textColor = theme.text
        font = ThemeFonts.regular(size: 16)
        tintColor = theme.primary
        layer.cornerRadius = 8
        layer.borderColor = theme.separator.cgColor
        layer.borderWidth = 1
        
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: theme.secondaryText,
                    .font: ThemeFonts.regular(size: 16)
                ]
            )
        }
    }
}

extension UITextView {
    
    func applyTheme() {
        let theme = ThemeManager.shared.colors
        backgroundColor = theme.cardBackground
        textColor = theme.text
        font = ThemeFonts.regular(size: 16)
        tintColor = theme.primary
        layer.cornerRadius = 8
        layer.borderColor = theme.separator.cgColor
        layer.borderWidth = 1
    }
}

extension UITableView {
    
    func applyTheme() {
        let theme = ThemeManager.shared.colors
        backgroundColor = theme.background
        separatorColor = theme.separator
    }
}

extension UICollectionView {
    
    func applyTheme() {
        let theme = ThemeManager.shared.colors
        backgroundColor = theme.background
    }
}
