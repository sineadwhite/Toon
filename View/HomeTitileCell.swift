//
//  HomeTitileCell.swift
//  Ontin
//
//  Created by liemkk on 11/14/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class HomeTitileCell: UITableViewCell {
    @IBOutlet weak var btnAll: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    var clickAction: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = UIFont.customBold(21)
        btnAll.titleLabel?.font = UIFont.customMedium(15)
        btnAll.tintColor = Constant().THEMECOLOR
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickAction(_ sender: UIButton){
        clickAction?()
    }
}
