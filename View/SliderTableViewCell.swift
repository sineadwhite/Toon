//
//  SliderTableViewCell.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class SliderTableViewCell: UITableViewCell {

    @IBOutlet weak var sliderLbl: UILabel!
    @IBOutlet weak var sliderImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        sliderLbl.font = UIFont.customMedium(17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
