//  ViewController.swift
//  Plany
//  Created by Gianluca Dubioso on 22/10/2020.

import AudioToolbox
import SkeletonView
import UIKit

class ViewController: BaseViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addHomeworkButton: UIButton!
    @IBOutlet weak var homeworkLabel: UILabel!
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var calendar: UIImageView!
    @IBOutlet weak var homeworkCollection: UICollectionView!
    @IBOutlet weak var sharedTable: UITableView!
    @IBOutlet weak var addTasksButton: UIButton!

    var viewModel: HomeViewModel!

    var longPressedEnabled: Bool!
    var datePicker: UIDatePicker!
    var isSearching: Bool = false

    var filteredArrayDate = [String]()
    var filteredArrayTime = [String]()
    var filteredArrayText = [String]()
    var filteredArrayTitle = [String]()
    var filteredSharedArray = [Task]()

    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewModel()

        self.homeworkCollection.delegate = self
        self.homeworkCollection.dataSource = self

        self.sharedTable.delegate = self
        self.sharedTable.dataSource = self

        self.searchBar.delegate = self

        headersAndSections()

        recognizer()

        updateLabelsForLanguage()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadAllData),
            name: NSNotification.Name("sharedUpdated"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadAllData),
            name: NSNotification.Name("AllDataCleared"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLabelsForLanguage),
            name: LocalizationManager.languageDidChangeNotification,
            object: nil
        )

    }

    private func setupViewModel() {
        viewModel = HomeViewModel()
        viewModel.delegate = self
    }

    @objc func reloadAllData() {
        viewModel.loadHomework()
        viewModel.loadTasks()

        homeworkCollection.reloadData()
        sharedTable.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()

        viewModel.loadHomework()
        viewModel.loadTasks()

        homeworkCollection.reloadData()
        sharedTable.reloadData()
    }

    deinit {
        removeThemeObserver()
    }

    override func updateUIForTheme() {
        let theme = ThemeManager.shared.colors

        tasksLabel.textColor = theme.text
        tasksLabel.font = ThemeFonts.semiBold(size: 17)

        homeworkCollection.backgroundColor = theme.background
        sharedTable.backgroundColor = theme.background
        homeworkCollection.applyTheme()
        sharedTable.applyTheme()
        addHomeworkButton.tintColor = theme.primary
        addTasksButton.tintColor = theme.primary

        let isDarkMode =
            ThemeManager.shared.currentTheme == .dark
            || (ThemeManager.shared.currentTheme == .system
                && traitCollection.userInterfaceStyle == .dark)
        calendar.tintColor = isDarkMode ? theme.primary : .white

        if let rightBarButtonItems = navigationItem.rightBarButtonItems,
            let barButtonItem = rightBarButtonItems.first,
            let customView = barButtonItem.customView as? UIButton
        {
            customView.tintColor = theme.text
        }

        homeworkCollection.reloadData()
        sharedTable.reloadData()
    }

    @objc func updateLabelsForLanguage() {
        homeworkLabel.text = "home.homework".localized
        tasksLabel.text = "home.tasks".localized
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.homeworkCollection.isSkeletonable = true
        self.sharedTable.isSkeletonable = true
        //FAKE LOADING DATA
        enableSkeleton(view: homeworkCollection)
        enableSkeleton(view: sharedTable)

        //FAKE TRIGGER Of DATA RETRIVED
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.disableSkeleton(view: self?.homeworkCollection)
            self?.disableSkeleton(view: self?.sharedTable)

            self?.sharedTable.reloadData()
        }
    }

    func headersAndSections() {
        setlayout()
        observerItems()
        userDefaultSet()

    }
}

extension ViewController: UINavigationControllerDelegate {

    //MARK: Searchbar
    func updateSearchResults(

        for searchController: UISearchController
    ) {
        guard let text = searchController.searchBar.text else { return }

        text.isEmpty ? sharedTable.reloadData() : sharedTable.reloadData()
        print(String(describing: " [RICERCA]: \(text)"))
    }

    //MARK: Layout
    func setlayout() {

        searchBar.layer.cornerRadius = 8
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear

        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            searchBar.searchTextField.leftView?.tintColor = .white
        } else {
            return
        }

        UITextField.appearance(
            whenContainedInInstancesOf: [
                UISearchBar.self
            ]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        //        homeworkCollection.layer.cornerRadius = 5

        navigationItem.backButtonTitle = "navigation.calendar".localized
        if #available(iOS 13.0, *) {
            calendar.image = UIImage(systemName: "calendar.badge.plus")?.withRenderingMode(
                .alwaysTemplate)
        } else {
            calendar.image = UIImage(named: "CalendarIcon")
        }
        let isDarkMode =
            ThemeManager.shared.currentTheme == .dark
            || (ThemeManager.shared.currentTheme == .system
                && traitCollection.userInterfaceStyle == .dark)
        calendar.tintColor = isDarkMode ? ThemeManager.shared.colors.primary : .white
        calendar.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openCalendar))
        calendar.addGestureRecognizer(tapGesture)

        addHomeworkButton.frame = CGRect(
            x: 0, y: 0,
            width: 12, height: 12
        )
        addHomeworkButton.setImage(
            UIImage(named: "Add"),
            for: .normal)
        addHomeworkButton.addTarget(
            self,
            action: #selector(pushHomework),
            for: .touchUpInside)

        addTasksButton.addTarget(
            self,
            action: #selector(pushTask),
            for: .touchUpInside)

    }

    @objc func openCalendar() {

        guard let url = URL(string: "calshow://") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)

    }
    //MARK: Observer
    func observerItems() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rewritingArrays),
            name: NSNotification.Name(
                rawValue: "updateArray"),
            object: nil)

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("updateName"),
            object: nil,
            queue: .main
        ) { (notification) in

            if let nameNotification = notification.object as? String {
                self.labelNavigation(
                    textColor: .white,
                    text: "Hello \n" + nameNotification)

                let profile = self.viewModel.getProfile()
                self.customNavigationButton(
                    selector: #selector(
                        self.pushProfile),
                    dataButton: profile.profileImage)
            }
        }
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("sharedUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            // Tasks are now managed by viewModel
            self.viewModel.loadTasks()
            self.sharedTable.reloadData()
            if let task = notification.object as? Task {
                print("Shared updated:", task.taskName, "isDone:", task.isDone)
            }
        }
    }

    //MARK: UserDefault
    func userDefaultSet() {
        // Recupera dati profilo dal viewModel
        let profile = viewModel.getProfile()
        customNavigationButton(
            selector: #selector(pushProfile),
            named: "PersonIcon",
            dataButton: profile.profileImage)

        let displayText: String
        if let firstName = profile.firstName, !firstName.isEmpty {
            if let lastName = profile.lastName, !lastName.isEmpty {
                displayText = "Hello \n\(firstName) \(lastName)"
            } else {
                displayText = "Hello \n\(firstName)"
            }
        } else {
            displayText = "profile.welcome.default".localized
        }

        labelNavigation(
            textColor: .white,
            text: displayText)
    }

    //MARK: GESTURE
    func recognizer() {

        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(
                self.longTap(_:)))

        homeworkCollection.addGestureRecognizer(
            longPressGesture)
    }

    @objc func longTap(_ gesture: UIGestureRecognizer) {

        switch gesture.state {
        case .began:
            guard
                let selectedIndexPath = homeworkCollection.indexPathForItem(
                    at: gesture.location(in: homeworkCollection))
            else {
                return
            }
            homeworkCollection.beginInteractiveMovementForItem(
                at: selectedIndexPath)

            AudioServicesPlayAlertSound(
                kSystemSoundID_Vibrate)

        case .changed:
            homeworkCollection.updateInteractiveMovementTargetPosition(
                gesture.location(in: gesture.view!))

        case .ended:
            homeworkCollection.endInteractiveMovement()
            //  doneBtn.isHidden = false
            longPressedEnabled = true
            self.homeworkCollection.reloadData()

        default:
            homeworkCollection.cancelInteractiveMovement()
        }
    }

}
// MARK: Handle Arrays
extension ViewController {

    @objc func load() {
        enableSkeleton(view: homeworkCollection)
        enableSkeleton(view: sharedTable)
        viewModel.loadTasks()
        sharedTable.reloadData()
    }

    func getTasksForSection(_ section: Int) -> [Task] {
        return section == 0 ? viewModel.todoTasks : viewModel.doneTasks
    }

    //  Rewrite Array Retrived
    @objc func rewritingArrays(
        notification: NSNotification
    ) {

        // Questi sono dati temporanei passati da CalendarViewController tramite UserDefaults
        // Non sono dati persistenti, quindi è accettabile accedervi direttamente
        guard let retrievedDate = UserDefaults.standard.string(forKey: "DateText"),
            let retrievedTime = UserDefaults.standard.string(forKey: "DateTime"),
            let retrievedTitle = UserDefaults.standard.string(forKey: "TitleText"),
            let retrievedText = UserDefaults.standard.string(forKey: "TagText")

        else { return }

        let homework = Homework(
            title: retrievedTitle, description: retrievedText, date: retrievedDate,
            time: retrievedTime)
        viewModel.addHomework(homework)

        if viewModel.homework.count == 1 {
            self.homeworkCollection.reloadData()
        } else {
            let index = IndexPath.init(
                item: viewModel.homework.count - 1,
                section: 0)
            self.homeworkCollection.insertItems(at: [index])
        }
    }

    func removeCollection(index: Int) {
        guard index >= 0, index < viewModel.homework.count else {
            print("Index out of range in removeCollection: \(index)")
            return
        }

        viewModel.removeHomework(at: index)
        homeworkCollection.reloadData()
    }
}

extension ViewController: HomeViewModelDelegate {
    func didUpdateTasks() {
        sharedTable.reloadData()
    }

    func didUpdateHomework() {
        homeworkCollection.reloadData()
    }

    func didLoadData() {
        sharedTable.reloadData()
        homeworkCollection.reloadData()
    }
}
