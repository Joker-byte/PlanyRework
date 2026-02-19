//
//  Routing.swift
//  Plany
//
//  Created by Gianluca Dubioso on 09/03/25.
//

import Foundation
import UIKit
extension UIViewController {
    
    // Routing
    
    func navigate<T: UIViewController>(
        storyName: String , idf: String ,
        controller: T.Type,
        presentation: UIModalPresentationStyle? = nil,
        transition: UIModalTransitionStyle? = nil
    ) {
        guard let vc = UIStoryboard(name: storyName, bundle: nil).instantiateViewController(withIdentifier: idf) as? T  else {
            return
        }
        if let presentation = presentation {
            vc.modalPresentationStyle = presentation
        }
        if let transition = transition {
            vc.modalTransitionStyle = transition
            
        } else {
            vc.modalPresentationStyle = .overFullScreen
            
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func present<T: UIViewController>(
          storyName: String ,
          idf: String ,
          controller: T.Type,
          presentation: UIModalPresentationStyle? = nil,
          transition: UIModalTransitionStyle? = nil,
          configure: ((T) -> Void)? = nil
    ) {
        guard let vc = UIStoryboard(name: storyName, bundle: nil).instantiateViewController(withIdentifier: idf) as? T  else {
            return
        }
        if let presentation = presentation {
            vc.modalPresentationStyle = presentation
        }
        if let transition = transition {
            vc.modalTransitionStyle = transition
            
        } else {
            vc.modalPresentationStyle = .overFullScreen
            
        }
        
        configure?(vc)
        
        self.present(vc, animated: true)
    }
}

