//
//  NewAndroidCell.swift
//  Ontin
//
//  Created by liemkk on 11/16/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class NewAndroidCell: UICollectionViewCell {
    @IBOutlet weak var lblNews: UILabel!
    @IBOutlet weak var imgFeatureNews: UIImageView!
    @IBOutlet weak var viewGradient: UIView!
    
    var gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.0).cgColor , UIColor.black.withAlphaComponent(0.7).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.size.width-15)/2, height: UIScreen.main.bounds.size.width*160/375)
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        viewGradient.layer.insertSublayer(gradientLayer, at: 0)
        
        lblNews.font = UIFont.customMedium(13)
        var deviceLanguage = ""
                
            if Constant().FORCE_RTL{
                    deviceLanguage = "ar"
                }
        
              if(deviceLanguage == "ar"){
                  UIView.appearance().semanticContentAttribute = .forceRightToLeft
                 
              } else{
                  UIView.appearance().semanticContentAttribute = .forceLeftToRight
              }
              
    }
    

    func bindingData(_ new: NewsData) {
        lblNews.text = new.title?.htmlDecoded
        imgFeatureNews.loadImageUsingCache(withUrl: new.featured_image_link ?? "")
    }
}
