//
//  DetailNewsRelatedCell.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class DetailNewsRelatedCell: UITableViewCell {

    
    @IBOutlet weak var lblNewsNumber: UILabel!
    @IBOutlet weak var lblNewsTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         self.lblNewsNumber.backgroundColor = Constant().THEMECOLOR
        lblNewsNumber.font = UIFont.customMedium(17)
        lblNewsTitle.font = UIFont.customBold(13)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
