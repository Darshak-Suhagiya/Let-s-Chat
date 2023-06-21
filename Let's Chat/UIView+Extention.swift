//
//  UIView+Extention.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 23/03/23.
//

import Foundation
import Foundation
import UIKit
extension UIView {
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func dropShadow(scale: Bool = true, width: Int, height: Int, shadowOpacity: Float, shadowRadius: CGFloat, shadowPathCornerRadius: CGFloat) {
          layer.masksToBounds = false
          layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
          layer.shadowOffset = CGSize(width: width, height: height)
          layer.shadowRadius = shadowRadius
          
//          layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: shadowPathCornerRadius).cgPath
          layer.shouldRasterize = true
          layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }
    func removeShadow(scale: Bool = true) {
          layer.shadowOpacity = 0
      }

}

