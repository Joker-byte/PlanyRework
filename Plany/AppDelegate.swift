//
//  AppDelegate.swift
//  Plany
//
//  Created by Gianluca Dubioso on 22/10/2020.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Load saved persistence type before anything else
        let savedType = PersistenceManager.shared.loadSavedPersistenceType()
        PersistenceManager.shared.persistenceType = savedType

        print(
            "STARTED: Storage method = \(PersistenceManager.shared.getCurrentStorageMethodName())"
        )

        ThemeManager.shared.applyTheme()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNavigationBackButtonTitles),
            name: LocalizationManager.languageDidChangeNotification,
            object: nil
        )

        return true
    }

    @objc private func updateNavigationBackButtonTitles() {
        UINavigationController.updateAllBackButtonTitles()
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}
