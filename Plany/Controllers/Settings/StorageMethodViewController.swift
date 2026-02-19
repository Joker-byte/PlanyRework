//
//  StorageMethodViewController.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import UIKit

class StorageMethodViewController: BaseViewController {

    private var tableView: UITableView!
    private var viewModel: ProfileViewModel!

    private var storageMethods:
        [(type: PersistenceType, name: String, description: String, available: Bool)]
    {
        return [
            (
                .userDefaults, "storage.userDefaults.name".localized,
                "storage.userDefaults.description".localized, true
            ),
            (
                .coreData, "storage.coreData.name".localized,
                "storage.coreData.description".localized, true
            ),
            (
                .swiftData, "storage.swiftData.name".localized,
                "storage.swiftData.description".localized, false
            ),
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "settings.storageMethod".localized
        navigationItem.backButtonTitle = "navigation.storage".localized
        setupTableView()
        applyCustomTheme()

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

    private func setupTableView() {
        if #available(iOS 13.0, *) {
            tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        } else {
            tableView = UITableView(frame: view.bounds, style: .grouped)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StorageCell")
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func applyCustomTheme() {
        let theme = ThemeManager.shared.colors
        view.backgroundColor = theme.background
        tableView.backgroundColor = theme.background
        tableView.reloadData()
    }

    @objc func updateLabelsForLanguage() {
        title = "settings.storageMethod".localized
        navigationItem.backButtonTitle = "navigation.storage".localized
        tableView.reloadData()
    }

    func configure(with viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    private func getCurrentStorageMethod() -> PersistenceType {
        return PersistenceManager.shared.persistenceType
    }

    private func showConfirmationAlert(for newMethod: PersistenceType, methodName: String) {
        let alert = UIAlertController(
            title: "storage.changeMethod.title".localized,
            message: "storage.changeMethod.message".localized(with: methodName),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "common.cancel".localized, style: .cancel))
        alert.addAction(
            UIAlertAction(title: "storage.migrate".localized, style: .default) {
                [weak self] _ in
                self?.performMigration(to: newMethod, methodName: methodName)
            })

        present(alert, animated: true)
    }

    private func performMigration(to newMethod: PersistenceType, methodName: String) {
        // Show loading indicator
        let loadingAlert = UIAlertController(
            title: "storage.migrating.title".localized,
            message: "storage.migrating.message".localized,
            preferredStyle: .alert
        )
        present(loadingAlert, animated: true)

        // Perform migration on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let currentMethod = PersistenceManager.shared.persistenceType
            let success = PersistenceManager.shared.migrateData(from: currentMethod, to: newMethod)

            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if success {
                        self?.showRestartAlert(methodName: methodName)
                    } else {
                        self?.showErrorAlert()
                    }
                }
            }
        }
    }

    private func showRestartAlert(methodName: String) {
        let alert = UIAlertController(
            title: "storage.success.title".localized,
            message: "storage.success.message".localized(with: methodName),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "common.ok".localized, style: .default) { _ in
                // User will manually close the app
                // The new storage method will be loaded on next launch
            })

        present(alert, animated: true)
    }

    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "storage.error.title".localized,
            message: "storage.error.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "common.ok".localized, style: .default))
        present(alert, animated: true)
    }

    private func showUnavailableAlert(for methodName: String) {
        let alert = UIAlertController(
            title: "storage.comingSoon".localized(with: methodName),
            message: "storage.unavailable.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "common.ok".localized, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension StorageMethodViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storageMethods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StorageCell", for: indexPath)
        let method = storageMethods[indexPath.row]
        let currentMethod = getCurrentStorageMethod()
        let theme = ThemeManager.shared.colors

        cell.textLabel?.text = method.name
        cell.detailTextLabel?.text = method.description
        cell.backgroundColor = theme.cardBackground
        cell.textLabel?.textColor = theme.text
        cell.detailTextLabel?.textColor = theme.secondaryText

        // Show checkmark for current method
        if method.type == currentMethod {
            cell.accessoryType = .checkmark
            cell.tintColor = theme.text
        } else {
            cell.accessoryType = .none
            cell.tintColor = theme.primary
        }

        // Disable unavailable methods
        if !method.available {
            cell.textLabel?.textColor = theme.secondaryText
            cell.detailTextLabel?.text = "storage.comingSoon".localized
            cell.selectionStyle = .none
        } else {
            cell.selectionStyle = .default
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "storage.footer".localized
    }
}

// MARK: - UITableViewDelegate
extension StorageMethodViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let method = storageMethods[indexPath.row]
        let currentMethod = getCurrentStorageMethod()

        // Show feedback for unavailable methods
        guard method.available else {
            showUnavailableAlert(for: method.name)
            return
        }

        // Can't select current method
        guard method.type != currentMethod else { return }

        // Show confirmation
        showConfirmationAlert(for: method.type, methodName: method.name)
    }
}
