import UIKit

struct ThemeConstants {
    
    struct Colors {
        static func gradientStart(for theme: Theme) -> UIColor {
            switch theme {
            case .light:
                return UIColor(red: 0.102, green: 0.220, blue: 0.424, alpha: 1.0)
            case .dark:
                return UIColor(red: 0.173, green: 0.142, blue: 0.141, alpha: 1.0)
            case .system:
                return gradientStart(for: ThemeManager.shared.currentTheme)
            }
        }
        
        static func gradientEnd(for theme: Theme) -> UIColor {
            switch theme {
            case .light:
                return UIColor(red: 0.85, green: 0.87, blue: 0.95, alpha: 1.0)
            case .dark:
                return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            case .system:
                return gradientEnd(for: ThemeManager.shared.currentTheme)
            }
        }
        
        static func cellBorder(for theme: Theme) -> UIColor {
            switch theme {
            case .light:
                return UIColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1.0)
            case .dark:
                return UIColor(red: 0.333, green: 0.333, blue: 0.333, alpha: 1.0)
            case .system:
                return cellBorder(for: ThemeManager.shared.currentTheme)
            }
        }
        
        static func navigationBarTint(for theme: Theme) -> UIColor {
            return ThemeManager.shared.colors.tint
        }
        
        static func navigationBarBackground(for theme: Theme) -> UIColor {
            return ThemeManager.shared.colors.background
        }
    }
    
    struct Dimensions {
        static let cellCornerRadius: CGFloat = 10
        static let cellBorderWidth: CGFloat = 2
        static let cellSpacing: CGFloat = 8
        static let collectionCellCornerRadius: CGFloat = 8
    }
}
