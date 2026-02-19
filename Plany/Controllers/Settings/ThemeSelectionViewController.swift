//
//  ThemeSelectionViewController.swift
//  Plany
//
//  Created by Gianluca Dubioso on 26/01/2026.
//

import UIKit

@available(iOS 13.0, *)
class ThemeSelectionViewController: BaseViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let themes = Theme.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "theme.title".localized
        navigationItem.backButtonTitle = "navigation.theme".localized
        setupTableView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLabelsForLanguage),
            name: LocalizationManager.languageDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func updateLabelsForLanguage() {
        navigationItem.backButtonTitle = "navigation.theme".localized
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ThemeCell")
    }

    override func updateUIForTheme() {
        tableView.applyTheme()
        tableView.reloadData()
    }
}

@available(iOS 13.0, *)
extension ThemeSelectionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath)
        let theme = themes[indexPath.row]
        let currentTheme = ThemeManager.shared.selectedTheme

        cell.textLabel?.text = theme.displayName
        cell.textLabel?.applyTheme(style: .body)
        cell.accessoryType = theme == currentTheme ? .checkmark : .none
        cell.backgroundColor = ThemeManager.shared.colors.cardBackground
        cell.tintColor = ThemeManager.shared.colors.text

        return cell
    }
}

@available(iOS 13.0, *)
extension ThemeSelectionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedTheme = themes[indexPath.row]
        ThemeManager.shared.selectedTheme = selectedTheme

        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "theme.header".localized
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "theme.footer".localized
    }

    func tableView(
        _ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int
    ) {
        if let header = view as? UITableViewHeaderFooterView {
            let theme = ThemeManager.shared.colors
            header.textLabel?.textColor = theme.text
            header.textLabel?.font = ThemeFonts.semiBold(size: 15)
        }
    }

    func tableView(
        _ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int
    ) {
        if let footer = view as? UITableViewHeaderFooterView {
            let theme = ThemeManager.shared.colors
            footer.textLabel?.textColor = theme.secondaryText
            footer.textLabel?.font = ThemeFonts.regular(size: 13)
        }
    }
}
