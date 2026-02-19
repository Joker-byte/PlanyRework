//
//  UISearchBAr.swift
//  Plany
//
//  Created by Gianluca Dubioso on 02/03/25.
//
import UIKit

extension UISearchBar {
    
    func setMagnifyingGlassColorTo(color: UIColor) {
        // Search Icon
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        
        glassIconView?.image = glassIconView?.image?.withRenderingMode(
            .alwaysTemplate
        )
        
        glassIconView?.tintColor = color
    }
    
    func setClearButtonColorTo(color: UIColor) {
        // Clear Button
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        
        let crossIconView = textFieldInsideSearchBar?.value(forKey: "clearButton") as? UIButton
        
        crossIconView?.setImage(
            crossIconView?.currentImage?.withRenderingMode(.alwaysTemplate),
            for: .normal)
        
        crossIconView?.tintColor = color
    }
    
    func setPlaceholderTextColorTo(color: UIColor) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = color
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        
        textFieldInsideSearchBarLabel?.textColor = color
    }
}


