//
//  UIViewController+Extention.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 27/03/23.
//

import Foundation
import UIKit

extension UIViewController{
    @objc func dismissKeyboard(_ vc: UIViewController) {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
}
