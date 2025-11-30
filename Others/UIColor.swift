//
//  UIColor.swift
//  OnWP
//
//  Created by dong luong on 1/4/20.
//  Copyright © 2020 Patcell. All rights reserved.
//

import UIKit

extension UIColor {

    // custom color methods
    class func colorWithHex(rgbValue: UInt32) -> UIColor {
        return UIColor( red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: CGFloat(1.0))
    }
    
  
    
    func changeImageColor(theImageView: UIImageView, newColor: UIColor) {
            theImageView.image = theImageView.image?.withRenderingMode(.alwaysOriginal)
            theImageView.tintColor = newColor;
    }
}

