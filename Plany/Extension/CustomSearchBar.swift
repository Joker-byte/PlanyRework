//
//  CustomSearchBar.swift
//  Plany
//
//  Created by Gianluca Dubioso on 03/03/25.
//


import UIKit

public class CustomSearchBar: UISearchBar, UITextFieldDelegate {
    
    public var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        }
        
        guard let textField = subviews
            .compactMap({ $0 as? UITextField })
            .first else {
            return nil
        }
        
        return textField
    }
    
    static var closeIcon : UIImage? {
        let image = UIImage(named: "MAFAButtonIcon-close")
        return image?.scalePreservingAspectRatio(targetSize: CGSize(width: 30, height: 15))
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        textField?.delegate = self
            // Remove left icon
        textField?.leftView = nil
            // Add custom
        showsBookmarkButton = true
        
        self.setImage(CustomSearchBar.closeIcon, for: .clear, state: .normal)
        self.setImage(UIImage(named: "search"), for: .bookmark, state: .normal)
        textField?.backgroundColor = .white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
