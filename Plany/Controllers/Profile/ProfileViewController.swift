//  ProfileViewController.swift
//  Plany
//  Created by Gianluca Dubioso on 27/10/2020.

import UIKit

class ProfileViewController: BaseViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var changeImage: UIButton!
    @IBOutlet var profileTable: UITableView!

    let imagePicker = UIImagePickerController()
    private let viewModel = ProfileViewModel()

    struct SettingSection {
        let title: String
        let options: [SettingOption]
    }

    struct SettingOption {
        let title: String
        let type: OptionType
        var subtitle: String? = nil
    }

    enum OptionType {
        case themeSelector
        case toggle(key: String)
        case navigation(destination: String)
        case action
    }

    var settingSections: [SettingSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewModel()
        setupSettings()
        loadProfile()
        setLayout()
        updateLabelsForLanguage()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChange),
            name: LocalizationManager.languageDidChangeNotification,
            object: nil)
    }

    private func setupViewModel() {
        viewModel.delegate = self
    }

    private func loadProfile() {
        viewModel.loadProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfile()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.profileTable.delegate = self
        self.profileTable.dataSource = self
    }

    override func updateUIForTheme() {
        let theme = ThemeManager.shared.colors

        view.backgroundColor = theme.background
        profileTable.backgroundColor = theme.background
        profileTable.applyTheme()

        // Style text fields
        nameField.textColor = theme.text
        nameField.backgroundColor = theme.cardBackground
        nameField.layer.cornerRadius = 8
        nameField.layer.borderWidth = 1
        nameField.layer.borderColor = theme.separator.cgColor
        nameField.attributedPlaceholder = NSAttributedString(
            string: nameField.placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: theme.secondaryText]
        )

        surnameField.textColor = theme.text
        surnameField.backgroundColor = theme.cardBackground
        surnameField.layer.cornerRadius = 8
        surnameField.layer.borderWidth = 1
        surnameField.layer.borderColor = theme.separator.cgColor
        surnameField.attributedPlaceholder = NSAttributedString(
            string: surnameField.placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: theme.secondaryText]
        )

        profileTable.reloadData()

        if let rightBarButtonItems = navigationItem.rightBarButtonItems,
            let barButtonItem = rightBarButtonItems.first,
            let customView = barButtonItem.customView as? UIButton
        {
            let isDarkMode =
                ThemeManager.shared.currentTheme == .dark
                || (ThemeManager.shared.currentTheme == .system
                    && traitCollection.userInterfaceStyle == .dark)
            customView.tintColor = isDarkMode ? ThemeManager.shared.colors.text : .white
        }
    }

    private func setupSettings() {
        // Inizializza impostazioni di default se non esistono tramite viewModel
        let settings = viewModel.settings
        if settings["animationsEnabled"] == nil {
            viewModel.saveSetting(key: "animationsEnabled", value: true)
        }
        if settings["taskReminders"] == nil {
            viewModel.saveSetting(key: "taskReminders", value: true)
        }

        settingSections = [
            SettingSection(
                title: "settings.theme".localized,
                options: [
                    SettingOption(title: "settings.theme.select".localized, type: .themeSelector)
                ]),
            SettingSection(
                title: "settings.storage".localized,
                options: [
                    SettingOption(
                        title: "settings.storageMethod".localized,
                        type: .navigation(destination: "storageMethod"),
                        subtitle:
                            "settings.storage.current".localized(
                                with: PersistenceManager.shared.getCurrentStorageMethodName())
                    )
                ]),
            SettingSection(
                title: "settings.notifications".localized,
                options: [
                    SettingOption(
                        title: "settings.notifications.taskReminders".localized,
                        type: .toggle(key: "taskReminders"))
                ]),
            SettingSection(
                title: "settings.interface".localized,
                options: [
                    SettingOption(
                        title: "settings.interface.animations".localized,
                        type: .toggle(key: "animationsEnabled"))
                ]),
            SettingSection(
                title: "settings.language".localized,
                options: [
                    SettingOption(
                        title: "settings.language.select".localized,
                        type: .navigation(destination: "languageSelection"),
                        subtitle: LocalizationManager.shared.currentLanguage.displayName
                    )
                ]),
            SettingSection(
                title: "settings.data".localized,
                options: [
                    SettingOption(title: "settings.clearAllData".localized, type: .action)
                ]),
        ]
    }

    @IBAction func didTapAddPhotoButton(_ sender: Any) {
        //MARK: Alert
        let alert = UIAlertController(
            title: nil, message: nil,
            preferredStyle: .actionSheet)
        pickImage(
            alert: alert, title: "profile.imageSource.gallery".localized, sourceType: .photoLibrary)
        pickImage(alert: alert, title: "profile.imageSource.camera".localized, sourceType: .camera)

        alert.addAction(
            UIAlertAction(
                title: "profile.imageSource.cancel".localized,
                style: .cancel,
                handler: nil))

        present(
            alert, animated: true,
            completion: nil)
    }

    @objc func pickImage(
        alert: UIAlertController, title: String,
        sourceType: UIImagePickerController.SourceType
    ) {
        alert.addAction(
            UIAlertAction(
                title: title,
                style: .default,
                handler: { (button) in
                    self.imagePicker.sourceType = sourceType
                    self.present(
                        self.imagePicker,
                        animated: true,
                        completion: nil)
                }
            ))
    }

    //MARK: Button Save
    func customNavigationButtonSave(
        selector: Selector? = nil,
        named: String,
        tintColor: UIColor? = nil,
        useLightColorInLightMode: Bool = false
    ) {

        let saveButton = UIButton(
            frame: CGRect(
                x: 0, y: 0,
                width: 28,
                height: 28))

        if let image = UIImage(named: named) {
            let templateImage = image.withRenderingMode(.alwaysTemplate)
            saveButton.setImage(templateImage, for: .normal)
        }

        if let ciSta = selector {
            saveButton.addTarget(
                self, action: ciSta,
                for: .touchUpInside)

            if let highlightImage = UIImage(named: "SavedIcon") {
                let templateHighlight = highlightImage.withRenderingMode(.alwaysTemplate)
                saveButton.setImage(templateHighlight, for: UIControl.State.highlighted)
                saveButton.setImage(templateHighlight, for: UIControl.State.selected)
            }
        }

        if useLightColorInLightMode {
            let isDarkMode =
                ThemeManager.shared.currentTheme == .dark
                || (ThemeManager.shared.currentTheme == .system
                    && traitCollection.userInterfaceStyle == .dark)
            saveButton.tintColor = isDarkMode ? ThemeManager.shared.colors.text : .white
        } else if let cistaColor = tintColor {
            saveButton.tintColor = cistaColor
        }

        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: saveButton)]
    }

    @objc func saveNameSurname() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let surname = surnameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Save even if one field is empty (allow partial updates)
        viewModel.updateName(
            firstName: name.isEmpty ? nil : name,
            lastName: surname.isEmpty ? nil : surname
        )
    }

    //MARK: Layout
    func setLayout() {
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.height / 2

        navigationItem.backButtonTitle = "navigation.settings".localized

        customNavigationButtonSave(
            selector: #selector(saveNameSurname),
            named: "SaveIcon",
            useLightColorInLightMode: true)
    }

    // MARK: - Helpers
    private func createChevronAccessory(color: UIColor) -> UIView {
        let chevronView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 13))

        let chevronLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 8, y: 6.5))
        path.addLine(to: CGPoint(x: 0, y: 13))

        chevronLayer.path = path.cgPath
        chevronLayer.strokeColor = color.cgColor
        chevronLayer.fillColor = UIColor.clear.cgColor
        chevronLayer.lineWidth = 2.0
        chevronLayer.lineJoin = .round
        chevronLayer.lineCap = .round

        chevronView.layer.addSublayer(chevronLayer)
        return chevronView
    }
}

// MARK: - ProfileViewModelDelegate
extension ProfileViewController: ProfileViewModelDelegate {

    func didUpdateProfile() {
        // Show placeholder if name/surname are empty
        if viewModel.firstName.isEmpty {
            nameField.text = ""
            nameField.placeholder = "profile.firstName.placeholder".localized
        } else {
            nameField.text = viewModel.firstName
            nameField.placeholder = nil
        }

        if viewModel.lastName.isEmpty {
            surnameField.text = ""
            surnameField.placeholder = "profile.lastName.placeholder".localized
        } else {
            surnameField.text = viewModel.lastName
            surnameField.placeholder = nil
        }

        if let imageData = viewModel.profileImageData {
            profileImage.image = UIImage(data: imageData)
        } else {
            profileImage.image = UIImage(named: "PersonIcon")
        }

        profileTable.reloadData()

        // Post notification to update home screen
        NotificationCenter.default.post(name: NSNotification.Name("updateName"), object: nil)
    }

    func didClearProfile() {
        nameField.text = ""
        nameField.placeholder = "profile.firstName.placeholder".localized
        surnameField.text = ""
        surnameField.placeholder = "profile.lastName.placeholder".localized
        profileImage.image = UIImage(named: "PersonIcon")
        profileTable.reloadData()
    }
}

// MARK: - Table View DataSource & Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return settingSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingSections[section].options.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingSections[section].title
    }

    func tableView(
        _ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int
    ) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = ThemeManager.shared.colors.text
            header.textLabel?.font = ThemeFonts.semiBold(size: 15)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = profileTable.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        let option = settingSections[indexPath.section].options[indexPath.row]
        let theme = ThemeManager.shared.colors

        cell.textLabel?.text = option.title
        cell.textLabel?.textColor = theme.text
        cell.textLabel?.font = ThemeFonts.regular(size: 16)
        cell.backgroundColor = theme.cardBackground
        cell.selectionStyle = .none

        // Set subtitle if available
        if let subtitle = option.subtitle {
            cell.detailTextLabel?.text = subtitle
            cell.detailTextLabel?.textColor = theme.secondaryText
            cell.detailTextLabel?.font = ThemeFonts.regular(size: 13)
        } else {
            cell.detailTextLabel?.text = nil
        }

        cell.accessoryView = nil
        cell.accessoryType = .none

        switch option.type {
        case .themeSelector:
            let currentTheme = ThemeManager.shared.selectedTheme.displayName
            cell.detailTextLabel?.text = currentTheme
            cell.detailTextLabel?.textColor = theme.secondaryText
            cell.accessoryView = createChevronAccessory(color: theme.text)

        case .navigation:
            cell.accessoryView = createChevronAccessory(color: theme.text)

        case .toggle(let key):
            let toggle = UISwitch()
            toggle.isOn = viewModel.settings[key] ?? false
            toggle.onTintColor = theme.tint
            toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
            toggle.tag = indexPath.section * 100 + indexPath.row
            cell.accessoryView = toggle

        case .action:
            cell.accessoryView = createChevronAccessory(color: theme.text)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = settingSections[indexPath.section].options[indexPath.row]

        switch option.type {
        case .themeSelector:
            if #available(iOS 13.0, *) {
                let themeVC = ThemeSelectionViewController()
                navigationController?.pushViewController(themeVC, animated: true)
            } else {
                let alert = UIAlertController(
                    title: "common.unavailable".localized,
                    message: "settings.theme.unavailable".localized,
                    preferredStyle: .alert)
                alert.addAction(
                    UIAlertAction(title: "common.ok".localized, style: .default))
                present(alert, animated: true)
            }

        case .navigation(destination: let dest):
            if dest == "storageMethod" {
                let storageVC = StorageMethodViewController()
                storageVC.configure(with: viewModel)
                navigationController?.pushViewController(storageVC, animated: true)
            } else if dest == "languageSelection" {
                let languageVC = LanguageSelectionViewController()
                navigationController?.pushViewController(languageVC, animated: true)
            }

        case .action:
            if option.title == "Clear All Data" {
                showClearAllDataAlert()
            }

        default:
            break
        }
    }

    @objc func toggleChanged(_ sender: UISwitch) {
        let section = sender.tag / 100
        let row = sender.tag % 100
        let option = settingSections[section].options[row]

        if case .toggle(let key) = option.type {
            viewModel.saveSetting(key: key, value: sender.isOn)
        }
    }

    func showClearAllDataAlert() {
        let alert = UIAlertController(
            title: "settings.clearAllData.confirm.title".localized,
            message: "settings.clearAllData.confirm.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "common.cancel".localized, style: .cancel))
        alert.addAction(
            UIAlertAction(title: "settings.clearAllData.delete".localized, style: .destructive) {
                _ in
                self.viewModel.clearAllData()

                // Post notification for app-wide update
                NotificationCenter.default.post(
                    name: NSNotification.Name("AllDataCleared"), object: nil)

                let successAlert = UIAlertController(
                    title: "settings.clearAllData.success.title".localized,
                    message: "settings.clearAllData.success.message".localized,
                    preferredStyle: .alert
                )
                successAlert.addAction(
                    UIAlertAction(title: "common.ok".localized, style: .default))
                self.present(successAlert, animated: true)
            })

        present(alert, animated: true)
    }

    // MARK: - Localization

    @objc private func handleLanguageChange() {
        updateLabelsForLanguage()
        // Refresh settings to update language subtitle
        setupSettings()
        profileTable.reloadData()
    }

    private func updateLabelsForLanguage() {
        nameLabel?.text = "profile.label.name".localized
        surnameLabel?.text = "profile.label.surname".localized
    }
}

// MARK: - UINavigationControllerDelegate
extension ProfileViewController: UINavigationControllerDelegate {
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        guard let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        else { return }

        profileImage.image = pickedImage
        viewModel.updateProfileImage(pickedImage.pngData())

        dismiss(animated: true, completion: nil)
    }
}
