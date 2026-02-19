//  UiViewController+.swift
//  Plany
//  Created by Gianluca Dubioso on 26/10/2020.
//  Extension UIView Controller

import UIKit
import SkeletonView
extension UIViewController {
  
    //MARK: Function
    @objc func pushHomework () {
        navigate(storyName: "HomeworkView", idf: "peppe2", controller: CalendarViewController.self)
    }
    
    @objc func pushProfile () {
        navigate(storyName: "ProfileView", idf: "Profile", controller: ProfileViewController.self)
    }
    @objc func presentPicker () {
        present(storyName: "PickerView", idf: "Picker", controller: PickerViewController.self,
                transition: .crossDissolve)

    }
    
   
    
    @objc func pushTask () {
        navigate(storyName: "TasksView", idf: "Tasks", controller: TasksViewController.self)

    }
  
    // MARK: Alert
    func alertPresent(textTitle: String, mexText : String, actTitle: String) {
        
        let alert = UIAlertController(title: textTitle ,
                                      message: mexText,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: actTitle,
            style: .cancel,
            handler: nil))
        present(alert,
                animated: true,
                completion: nil)
    }
     func presentPickerWithCallback(onDateSelected: @escaping (String, String) -> Void) {
        present(
            storyName: "PickerView",
            idf: "Picker",
            controller: PickerViewController.self,
            presentation: .overCurrentContext,
            transition: .crossDissolve
        ) { pickerVC in
            pickerVC.onDateSelected = onDateSelected
        }
    }
    
    func enableSkeleton(view: UIView? = nil) {
        
//        let gradient = SkeletonGradient(baseColor: UIColor.white, secondaryColor: UIColor.lightGray)
//        let animation = GradientDirection.topLeftBottomRight.slidingAnimation()
//            //errorView.isHidden = true
//        view?.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        
        view?.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .silver),
                                           animation: nil,
                                           transition: .crossDissolve(0.25))
    }
    
    func disableSkeleton(view: UIView? = nil) {
        if let view = view {
//            view.hideSkeleton(transition: .crossDissolve(1.0))
            
            view.stopSkeletonAnimation()
// self.tableView.hideSkeleton()
            view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        }
    }

    
    //MARK: finire change datepicker
    //
    //  @objc func showDatePicker(){
    //     //Formate Date
    //      datePicker.datePickerMode = .date
    //
    //      //ToolBar
    //     let toolbar = UIToolbar();
    //     toolbar.sizeToFit()
    
    
    
    
    //MARK: UserDefaults handler
    
    //  @objc func Defaultset(data: String? = nil, key: String) {
    //    UserDefaults.standard.set(data, forKey: key)
    //  }
    //  @objc func DefaultObj(key: String){
    //    UserDefaults.standard.object(forKey: key)
    //  }
    //  @objc func DefaultString(key: String){
    //    UserDefaults.standard.string(forKey: key)
    //  }
    
    
}
