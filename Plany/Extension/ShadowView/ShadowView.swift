//
//  ShadowView.swift
//  Plany
//
//  Created by Gianluca Dubioso on 16/04/25.
//
import UIKit

class ShadowView: UIView {
    
    var setupShadowDone: Bool = false
    
    public func setupShadow() {
        if setupShadowDone { return }
        print("Setup shadow!")
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.black.cgColor
       
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: 8, height: 8)).cgPath
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        setupShadowDone = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("Layout subviews!")
        setupShadow()
    }
}
