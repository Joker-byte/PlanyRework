//
//  TasksViewController.swift
//  Plany
//
//  Created by Gianluca Dubioso on 12/12/20.
//

import SkeletonView
import UIKit

class TasksViewController: BaseViewController {

  @IBOutlet var inputTextField: UITextField!
  @IBOutlet var tableView: UITableView!

    @IBOutlet weak var add_button: UIButton!
    private var viewModel: TasksViewModel!

  var sharedArrayTask: [Task] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    setupViewModel()
    self.tableView.dataSource = self
    self.tableView.delegate = self
    mio()
    DispatchQueue.main.asyncAfter(
      deadline: .now() + 5,
      execute: {

      })
    tableView.reloadData()

    // Observer for data cleared
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDataCleared),
      name: NSNotification.Name("AllDataCleared"),
      object: nil
    )
  }

  private func setupViewModel() {
    viewModel = TasksViewModel()
    viewModel.delegate = self
  }

  @objc private func handleDataCleared() {
    viewModel.loadSections()
    tableView.reloadData()
  }

  deinit {
    removeThemeObserver()
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.loadSections()
    let theme = ThemeManager.shared.colors
    view.backgroundColor = theme.background
    tableView.backgroundColor = theme.background
    tableView.applyTheme()

    inputTextField.backgroundColor = theme.cardBackground
    inputTextField.textColor = theme.text
    inputTextField.tintColor = theme.primary

    tableView.reloadData()
  }

  //    func enableSkeleton(view: UIView? = nil) {
  //
  //        view?.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .silver),
  //                                           animation: nil,
  //                                           transition: .crossDissolve(0.25))
  //    }
  //
  //    func disableSkeleton(view: UIView? = nil) {
  //        if let view = view {
  //
  //            view.stopSkeletonAnimation()
  //            view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
  //        }
  //    }
  //MARK: ViewController Action

  @IBAction func addButton_clicked(_ sender: UIButton) {
      

    if inputTextField.text == "" {

      alertPresent(
        textTitle: "Hey Dude",
        mexText: "Text Field can't be Empty",
        actTitle: "Cancel")

    } else {

      guard let text = self.inputTextField.text else {

        return
      }
      viewModel.addTask(name: text, toSection: 0, shared: false)
      self.tableView.reloadData()
    }
    inputTextField.text = ""
  }

  // Edit Button
  @objc func editButton_clicked() {

    self.tableView.setEditing(
      !self.tableView.isEditing,
      animated: true)
  }

  @objc func mio() {
    let editButton = UIButton(
      frame: CGRect(
        x: 0, y: 0,
        width: 50, height: 32))

    editButton.setTitle(
        "task.action.edit".localized, for: .normal)

    editButton.setTitleColor(
      .white, for: .normal)

    editButton.addTarget(
      self,
      action: #selector(
        editButton_clicked),
      for: .touchUpInside)

    inputTextField.layer.cornerRadius = inputTextField.frame.height / 2
    let theme = ThemeManager.shared.colors
    inputTextField.backgroundColor = theme.cardBackground
    inputTextField.textColor = theme.text
    inputTextField.tintColor = theme.primary

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      customView: editButton)
      
      add_button.setTitle("task.action.add".localized, for: .normal)
  }

  // save2() rimosso - gli shared task sono gestiti dal viewModel
}
//MARK: TableView DataSource
extension TasksViewController: UITableViewDataSource {
  func tableView(
    _ tableView: UITableView,
    heightForHeaderInSection section: Int
  ) -> CGFloat {

    if viewModel.sections[section].tasks.isEmpty {
      return 0
    } else {
      return 36
    }
  }

  func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    tableView.deselectRow(
      at: indexPath,
      animated: true)

    viewModel.toggleTaskStatus(at: indexPath)
    self.tableView.reloadData()
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //let theme = ThemeManager.shared.colors
    let label = UILabel()
    label.text = viewModel.sections[section].name
    label.textColor = .white
    label.textAlignment = .center
    //TODO: CHANGE THIS HEADER COLOR
    label.backgroundColor = #colorLiteral(
      red: 0.173355639, green: 0.1415168047, blue: 0.1407646239, alpha: 1)
    label.isHidden = viewModel.sections[section].tasks.isEmpty

    return label
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.sections.count
  }

  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {

    return viewModel.sections[section].tasks.count

  }
  //MARK: Reusable Cell
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(
      withIdentifier: "taskCell", for: indexPath)

    let theme = ThemeManager.shared.colors
    cell.backgroundColor = theme.cardBackground
    cell.textLabel?.textColor = theme.text
    cell.textLabel?.font = ThemeFonts.regular(size: 16)
    cell.tintColor = theme.primary
    cell.textLabel?.text = viewModel.sections[indexPath.section].tasks[indexPath.row].taskName

    if viewModel.sections[indexPath.section].name != "To Do" {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }

    tableView.isSkeletonable = true
    return cell
  }
}
//MARK: TableView Delegate
extension TasksViewController: UITableViewDelegate {

  func tableView(
    _ tableView: UITableView,
    editingStyleForRowAt indexPath: IndexPath
  ) -> UITableViewCell.EditingStyle {
    return .none

  }

  func tableView(
    _ tableView: UITableView,
    shouldIndentWhileEditingRowAt indexPath: IndexPath
  ) -> Bool {

    return false

  }

  func tableView(
    _ tableView: UITableView,
    moveRowAt sourceIndexPath: IndexPath,
    to destinationIndexPath: IndexPath
  ) {

    viewModel.moveTask(from: sourceIndexPath, to: destinationIndexPath)

  }

  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath)
    -> [UITableViewRowAction]?
  {
    //MARK: DELETE ACTION

    let action = UITableViewRowAction.init(
      style: .normal,
      title: "Delete"
    ) { (action, index) in
      print("🤖 Delete", index.row)
      self.viewModel.deleteTask(at: index)

      tableView.deleteRows(at: [index], with: .right)
      self.tableView.reloadData()
    }
    action.backgroundColor = #colorLiteral(
      red: 0.9267585874, green: 0.367726624, blue: 0.3804723024, alpha: 1)

    //MARK: SHARE ACTION

    let actionShare = UITableViewRowAction.init(
      style: .normal,
      title: "Share"
    ) { (action, index) in

      self.viewModel.shareTask(at: index)

      // Just reload the whole table since the task moved to shared section
      self.tableView.reloadData()

      print("🤖 Share", index.row)
    }
    actionShare.backgroundColor = #colorLiteral(
      red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)

    return [action, actionShare]
  }
}

extension TasksViewController: TasksViewModelDelegate {
  func didUpdateSections() {
    tableView.reloadData()
  }

  func didAddTask() {
    tableView.reloadData()
  }

  func didDeleteTask() {
    tableView.reloadData()
  }
}
