//
//  HomeScreenButtonCell.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class HomeScreenButtonCell: UICollectionViewCell {

    @IBOutlet weak var lblFeatureNewsName: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblFeatureNewsName.backgroundColor = Constant().THEMECOLOR
        lblFeatureNewsName.font = UIFont.customBold(13)
    }

}
