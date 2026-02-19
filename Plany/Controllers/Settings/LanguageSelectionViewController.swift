//
//  LanguageSelectionViewController.swift
//  Plany
//
//  Created by Gianluca Dubioso on 05/02/2026.
//

import UIKit

class LanguageSelectionViewController: BaseViewController {

    private lazy var tableView: UITableView = {
        if #available(iOS 13.0, *) {
            return UITableView(frame: .zero, style: .insetGrouped)
        } else {
            return UITableView(frame: .zero, style: .grouped)
        }
    }()
    private let languages = AppLanguage.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "settings.language".localized
        navigationItem.backButtonTitle = "navigation.language".localized
        setupTableView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChange),
            name: LocalizationManager.languageDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LanguageCell")
    }

    override func updateUIForTheme() {
        super.updateUIForTheme()
        tableView.applyTheme()
        tableView.reloadData()
    }

    @objc private func handleLanguageChange() {
        // Reload UI with new language
        title = "settings.language".localized
        navigationItem.backButtonTitle = "navigation.language".localized
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension LanguageSelectionViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath)
        let language = languages[indexPath.row]
        let theme = ThemeManager.shared.colors

        cell.textLabel?.text = language.displayName
        cell.textLabel?.textColor = theme.text
        cell.textLabel?.font = ThemeFonts.regular(size: 17)
        cell.backgroundColor = theme.cardBackground
        cell.selectionStyle = .none

        // Show checkmark for current language
        if language == LocalizationManager.shared.currentLanguage {
            cell.accessoryType = .checkmark
            cell.tintColor = theme.text
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "language.footer".localized
    }

    func tableView(
        _ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int
    ) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = ThemeManager.shared.colors.secondaryText
            footerView.textLabel?.font = ThemeFonts.regular(size: 13)
        }
    }
}

// MARK: - UITableViewDelegate
extension LanguageSelectionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLanguage = languages[indexPath.row]

        // Update language
        LocalizationManager.shared.currentLanguage = selectedLanguage

        // Reload table to update checkmarks
        tableView.reloadData()

        // Post notification for app-wide UI update
        NotificationCenter.default.post(
            name: LocalizationManager.languageDidChangeNotification,
            object: nil
        )
    }
}
