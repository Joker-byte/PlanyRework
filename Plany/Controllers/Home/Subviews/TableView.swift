//
//  ProfileTableView.swift
//  Plany
//
//  Created by Gianluca Dubioso on 25/02/25.
//
//MARK: TABLE VIEW

import SkeletonView
import UIKit

extension ViewController: UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        }
        if viewModel.allTasks.isEmpty {
            return 1
        }
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching || viewModel.allTasks.isEmpty {
            return nil
        }
        return section == 0 ? "To Do" : "Done"
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearching || viewModel.allTasks.isEmpty {
            return 0
        }
        let tasksInSection = getTasksForSection(section)
        return tasksInSection.isEmpty ? 0 : 36
    }

    func tableView(
        _ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int
    ) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .white
            header.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            header.contentView.backgroundColor = .clear
        }
    }

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

        if isSearching {
            filteredSharedArray.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        } else if viewModel.allTasks.isEmpty {
            return
        } else {
            if sourceIndexPath.section == destinationIndexPath.section {
                let task = getTasksForSection(sourceIndexPath.section)[sourceIndexPath.row]
                viewModel.moveTask(task, from: sourceIndexPath.row, to: destinationIndexPath.row)
            }
        }
    }

    func tableView(
        _ tableView: UITableView,
        editActionsForRowAt indexPath: IndexPath
    ) -> [UITableViewRowAction]? {
        if viewModel.allTasks.isEmpty {
            return []
        }

        //MARK: DELETE ACTION
        let action = UITableViewRowAction.init(
            style: .normal,
            title: "task.action.delete".localized
        ) { (action, index) in
            print("🤖 Delete", index.row)

            if self.isSearching {
                let taskToRemove = self.filteredSharedArray[index.row]
                self.viewModel.deleteTask(taskToRemove)
            } else {
                let task = self.getTasksForSection(index.section)[index.row]
                self.viewModel.deleteTask(task)
            }

            self.sharedTable.reloadData()
        }
        action.backgroundColor = #colorLiteral(
            red: 0.173355639, green: 0.1415168047, blue: 0.1407646239, alpha: 1)

        let pushBackAction = UITableViewRowAction.init(
            style: .normal,
            title: "task.action.pushBack".localized
        ) { (action, index) in
            print("🤖 Push Back", index.row)

            let taskToReturn: Task

            if self.isSearching {
                taskToReturn = self.filteredSharedArray[index.row]
            } else {
                taskToReturn = self.getTasksForSection(index.section)[index.row]
            }

            self.viewModel.pushBackTask(taskToReturn)
            self.sharedTable.reloadData()

            print("🤖 Task isDone:", taskToReturn.isDone)
        }
        pushBackAction.backgroundColor = #colorLiteral(
            red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)

        return [action, pushBackAction]
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 70
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if isSearching {
            return filteredSharedArray.count
        }

        if viewModel.allTasks.isEmpty {
            return 4
        }

        return getTasksForSection(section).count
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        if viewModel.allTasks.isEmpty {
            return
        }

        sharedTable.deselectRow(
            at: indexPath, animated: true)

        if isSearching {
            var task = filteredSharedArray[indexPath.row]
            task.isDone.toggle()
            filteredSharedArray[indexPath.row] = task
            viewModel.toggleTaskStatus(task)
        } else {
            let task = getTasksForSection(indexPath.section)[indexPath.row]
            viewModel.toggleTaskStatus(task)
        }

        sharedTable.reloadData()
    }

    //MARK: VIEW CONTROLLER EXTENSION
}
extension ViewController: UITableViewDataSource {
    func collectionSkeletonView(
        _ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath
    ) -> ReusableCellIdentifier {
        return "tasksSharedCell"
    }
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = sharedTable.dequeueReusableCell(
            withIdentifier: "tasksSharedCell", for: indexPath)

        let spacing: CGFloat = 10
        let containerTag = 100

        cell.selectionStyle = .none
        cell.tintColor = UIColor.white
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        var containerView: UIView!

        if let existingContainer = cell.contentView.viewWithTag(containerTag) {
            containerView = existingContainer
        } else {
            containerView = UIView()
            containerView.tag = containerTag
            containerView.layer.cornerRadius = 10
            containerView.layer.masksToBounds = true
            containerView.isSkeletonable = true
            cell.contentView.insertSubview(containerView, at: 0)
        }

        containerView.frame = CGRect(
            x: spacing / 2,
            y: spacing / 2,
            width: cell.bounds.width - spacing,
            height: 60 - spacing
        )

        ThemeManager.shared.applyGradient(
            to: containerView, cornerRadius: ThemeConstants.Dimensions.cellCornerRadius)

        containerView.layer.borderWidth = ThemeConstants.Dimensions.cellBorderWidth
        containerView.layer.borderColor =
            ThemeConstants.Colors.cellBorder(for: ThemeManager.shared.currentTheme).cgColor

        let checkmarkTag = 200
        containerView.viewWithTag(checkmarkTag)?.removeFromSuperview()

        if let textLabel = cell.textLabel {
            textLabel.textColor = .white
            textLabel.backgroundColor = .clear

            if viewModel.allTasks.isEmpty {
                textLabel.text = "task.empty.placeholder".localized(with: "\(indexPath.row + 1)")
                textLabel.alpha = 0.5
            } else {
                let taskArray =
                    self.isSearching
                    ? self.filteredSharedArray : self.getTasksForSection(indexPath.section)

                if let task = taskArray[safe: indexPath.row] {
                    textLabel.text = task.taskName
                    textLabel.alpha = 1.0

                    if task.isDone {
                        let customCheckMark = self.customCheckMark(
                            tag: checkmarkTag, containerView: containerView)
                        containerView.addSubview(customCheckMark)
                    }
                }
            }
        }

        return cell
    }

    func customCheckMark(tag: Int, containerView: UIView) -> UILabel {
        let checkmark = UILabel()
        checkmark.tag = tag
        checkmark.text = "✓"
        checkmark.textColor = .white
        checkmark.textAlignment = .center
        checkmark.font = UIFont.boldSystemFont(ofSize: 20)
        checkmark.backgroundColor = .clear
        checkmark.frame = CGRect(
            x: containerView.bounds.width - 35,
            y: 0,
            width: 30,
            height: containerView.bounds.height
        )
        return checkmark
    }
}
