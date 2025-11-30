//
//  HomeScreenListCell.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class HomeScreenListCell: UITableViewCell {

    @IBOutlet weak var lblFeatureTitle: UILabel!
    @IBOutlet weak var lblFeatureNews: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imageFeatureNews: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblFeatureTitle.textColor = Constant().THEMECOLOR
        lblFeatureTitle.font = UIFont.customMedium(12)
        lblFeatureNews.font = UIFont.customMedium(13)
        lblDate.font = UIFont.customMedium(10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
