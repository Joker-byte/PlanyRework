//  CalendarViewController.swift
//  Plany
//  Created by Gianluca Dubioso on 22/10/2020.

import UIKit

class CalendarViewController: BaseViewController {

    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeLabel: UILabel!

    private let viewModel = HomeworkViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setView()

        // Observer for data cleared
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataCleared),
            name: NSNotification.Name("AllDataCleared"),
            object: nil
        )
    }

    private func setupViewModel() {
        viewModel.delegate = self
    }

    @objc private func handleDataCleared() {
        navigationController?.popViewController(animated: true)
    }
}

extension CalendarViewController: HomeworkViewModelDelegate {

    func didSaveHomework() {
        navigationController?.popViewController(animated: true)
    }

    func showError(_ message: String) {
        alertPresent(
            textTitle: "Hey Dude",
            mexText: message,
            actTitle: "Cancel")
    }
}

extension CalendarViewController {

    @objc func saveTitleAndTag() {
        guard let title = titleTextView.text,
            let description = tagTextField.text,
            let date = dateLabel.text,
            let time = timeLabel.text
        else {
            return
        }

        viewModel.saveHomework(
            title: title,
            description: description,
            date: date,
            time: time
        )
    }

    @IBAction func datePickerChanged(_ sender: Any) {
        let date = viewModel.formatDate(datePicker.date)
        let time = viewModel.formatTime(datePicker.date)

        dateLabel.text = date
        timeLabel.text = time
    }

    @objc func setView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(saveTitleAndTag))

        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        titleTextView.layer.cornerRadius = 8
        tagTextField.layer.cornerRadius = 8
        dateLabel.text = "homework.date.select".localized
        timeLabel.text = "homework.time.select".localized
    }
}
