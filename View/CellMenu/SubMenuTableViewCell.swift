//
//  SubMenuTableViewCell.swift
//  OnWP
//
//  Created by dong luong on 1/3/20.
//  Copyright © 2020 Patcell. All rights reserved.
//

import UIKit
protocol OnCLicSubMenuViewDelegate: class {
    func clickSubMenu(position: Int,section: Int)
}
class SubMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var lblSubMenu: UILabel!
    @IBOutlet weak var imgSubMenu: UIImageView!
    var delegate: OnCLicSubMenuViewDelegate?
    var position: Int = 0
    var section: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickSubMenu(_ sender: Any) {
        delegate?.clickSubMenu(position: position,section: section)
    }
}
