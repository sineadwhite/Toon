//
//  HomeScreenCell.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class HomeScreenCell: UICollectionViewCell {

    @IBOutlet weak var lblNameFeatureNews: UILabel!
    @IBOutlet weak var lblDescFeatureNews: UILabel!
    @IBOutlet weak var lblDateFeatureNews: UILabel!
    @IBOutlet weak var imgFeatureNews: UIImageView!
    @IBOutlet weak var viewGradient: UIView!
    
    var gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.lblNameFeatureNews.backgroundColor = Constant().THEMECOLOR
        
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.0).cgColor , UIColor.black.withAlphaComponent(0.7).cgColor]
//        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.0).cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.viewGradient.frame.size.width, height: self.viewGradient.frame.size.height)
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        viewGradient.layer.insertSublayer(gradientLayer, at: 0)
        
        lblNameFeatureNews.font = UIFont.customMedium(13)
        lblDescFeatureNews.font = UIFont.customMedium(13)
        lblDateFeatureNews.font = UIFont.customMedium(12)
    }
}
