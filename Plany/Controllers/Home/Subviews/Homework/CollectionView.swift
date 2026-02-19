//
//  ProfVCCollectDataSource.swift
//  Plany
//
//  Created by Gianluca Dubioso on 25/02/25.
//

import SkeletonView
import UIKit

extension ViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath)
        -> Bool
    {
        return !viewModel.homework.isEmpty
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if viewModel.homework.isEmpty {
            return
        }

        let homework = viewModel.homework[indexPath.item]
        let alertCell = UIAlertController(
            title: homework.date + "\n",
            message: homework.description,
            preferredStyle: .alert)

        alertCell.title?.append(homework.title)

        alertCell.addAction(
            UIAlertAction(
                title: "homework.action.edit".localized,
                style: .default,
                handler: { _ in
                    TextEntryAlert.show(
                        in: self,
                        index: indexPath.item,
                        currentTitle: homework.title,
                        currentText: homework.description,
                        currentDate: homework.date,
                        currentTime: homework.time
                    ) { title, text, date, time in

                        var updatedHomework = homework
                        if let newTitle = title, !newTitle.isEmpty {
                            updatedHomework.title = newTitle
                        }
                        if let newText = text, !newText.isEmpty {
                            updatedHomework.description = newText
                        }
                        if let newDate = date, !newDate.isEmpty {
                            updatedHomework.date = newDate
                        }
                        if let newTime = time, !newTime.isEmpty {
                            updatedHomework.time = newTime
                        }
                        self.viewModel.updateHomework(at: indexPath.item, with: updatedHomework)
                        self.homeworkCollection.reloadData()
                        NotificationCenter.default.post(
                            name: NSNotification.Name(
                                rawValue: "updateArray"),
                            object: nil)

                    }

                }
            ))

        alertCell.addAction(
            UIAlertAction(
                title: "homework.action.duplicate".localized,
                style: .default,
                handler: { _ in
                    let homework = self.viewModel.homework[indexPath.item]
                    self.viewModel.addHomework(homework)

                    self.homeworkCollection.reloadData()
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: "updateArray"),
                        object: nil)
                }
            ))

        alertCell.addAction(
            UIAlertAction(
                title: "homework.action.remove".localized,
                style: .destructive,
                handler: { _ in
                    self.removeCollection(index: indexPath.item)
                }
            ))

        alertCell.addAction(
            UIAlertAction(
                title: "homework.action.dismiss".localized,
                style: .cancel,
                handler: nil
            ))

        present(alertCell, animated: true, completion: nil)
    }
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if isSearching {
            return min(
                filteredArrayText.count, filteredArrayTitle.count, filteredArrayDate.count,
                filteredArrayTime.count)
        } else {
            let itemCount = viewModel.homework.count
            return itemCount > 0 ? itemCount : 3
        }
    }

    //MARK: Swap Collection
    func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {

        viewModel.moveHomework(from: sourceIndexPath.item, to: destinationIndexPath.item)

        print("Start index :- \(String(describing: sourceIndexPath.item))")
        print("End index :- \(String(describing: destinationIndexPath.item))")
    }

}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {

        let cell: CollectionViewCell =
            homeworkCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            as! CollectionViewCell
        homeworkCollection.layer.cornerRadius = 5

        cell.isSkeletonable = true

        if viewModel.homework.isEmpty {
            cell.postTitleLabel.text = "Homework \(indexPath.item + 1)"
            cell.postTime.text = "yyyy/MM/DD"
            cell.postTimeHours.text = "hh:mm"
            cell.postText.text = "Tap +"
            cell.alpha = 0.5
        } else {
            let homework = viewModel.homework[indexPath.item]
            cell.postTitleLabel.text = homework.title
            cell.postTime.text = homework.date
            cell.postTimeHours.text = homework.time
            cell.postText.text = homework.description
            cell.alpha = 1.0
        }

        ThemeManager.shared.applyGradient(
            to: cell, cornerRadius: ThemeConstants.Dimensions.collectionCellCornerRadius)

        cell.clipsToBounds = true
        cell.layer.cornerRadius = ThemeConstants.Dimensions.collectionCellCornerRadius
        cell.layer.borderWidth = ThemeConstants.Dimensions.cellBorderWidth
        cell.layer.borderColor =
            ThemeConstants.Colors.cellBorder(for: ThemeManager.shared.currentTheme).cgColor
        return cell
    }
}
