//
//  UINavigationController+Localization.swift
//  Plany
//
//  Created by Gianluca Dubioso on 05/02/2026.
//

import UIKit

extension UINavigationController {
    
    static func updateAllBackButtonTitles() {
        let window: UIWindow?
        
        if #available(iOS 13.0, *) {
            window = UIApplication.shared.connectedScenes
                .flatMap({ ($0 as? UIWindowScene)?.windows ?? [] })
                .first(where: { $0.isKeyWindow })
        } else {
            window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
        
        guard let window = window else { return }
        updateNavigationHierarchy(window.rootViewController)
    }

    func updateBackButtonTitlesForLanguage() {
        for viewController in self.viewControllers {
            updateBackButtonTitle(for: viewController)
        }
    }

    private static func updateNavigationHierarchy(_ viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        
        if let navController = viewController as? UINavigationController {
            navController.updateBackButtonTitlesForLanguage()
        } else if let tabController = viewController as? UITabBarController {
            tabController.viewControllers?.forEach { updateNavigationHierarchy($0) }
        } else if let navController = viewController.navigationController {
            navController.updateBackButtonTitlesForLanguage()
        }
    }

    private func updateBackButtonTitle(for viewController: UIViewController) {
        switch viewController {
        case is ViewController:
            viewController.navigationItem.backButtonTitle = "navigation.calendar".localized
        case is ProfileViewController:
            viewController.navigationItem.backButtonTitle = "navigation.settings".localized
        case is LanguageSelectionViewController:
            viewController.navigationItem.backButtonTitle = "navigation.language".localized
        case is StorageMethodViewController:
            viewController.navigationItem.backButtonTitle = "navigation.storage".localized
        default:
            if #available(iOS 13.0, *) {
                if viewController is ThemeSelectionViewController {
                    viewController.navigationItem.backButtonTitle = "navigation.theme".localized
                }
            }
        }
    }
}
