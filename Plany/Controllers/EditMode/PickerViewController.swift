//
//  PickerViewController.swift
//  Plany
//
//  Created by Gianluca Dubioso on 31/01/21.
//

import UIKit

class PickerViewController: BaseViewController {
    
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet var popUp: UIView!
  
  var onDateSelected: ((_ date: String, _ time: String) -> Void)?
  
  override func viewDidLoad() {
           super.viewDidLoad()
    
    popUp.layer.cornerRadius = 9
    
    datePickerChanged(datePicker as Any)
    
    }
  
  
  @IBAction func datePickerChanged(_ sender: Any) {
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    dateFormatter.dateStyle = DateFormatter.Style.short
    dateFormatter.timeStyle = DateFormatter.Style.short
    
    dateFormatter.dateFormat = "yyyy-MM-dd"
    timeFormatter.dateFormat = "HH:mm"
    
    let stringDate = dateFormatter.string(from: datePicker.date)
    let secondDate = timeFormatter.string(from: datePicker.date)
      
    dateLabel.text = stringDate
    timeLabel.text = secondDate

  }


  @IBAction func returnOK(_ sender: Any) {
      if let callback = onDateSelected {
          let dateFormatter = DateFormatter()
          let timeFormatter = DateFormatter()
          
          dateFormatter.dateFormat = "yyyy-MM-dd"
          timeFormatter.dateFormat = "HH:mm"
          
          let stringDate = dateFormatter.string(from: datePicker.date)
          let secondDate = timeFormatter.string(from: datePicker.date)
          
          dismiss(animated: true) {
              callback(stringDate, secondDate)
          }
      } else {
          dismiss(animated: true, completion: nil)
      }
  }
  
  @IBAction func dismiss(_ sender: Any) {
    dismiss(animated: true, completion: nil)
    
  }
}
