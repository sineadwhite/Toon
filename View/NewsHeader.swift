//
//  NewsHeader.swift
//  OnWP
//
//  Created by Patcell on 15/07/19.
//  Copyright © 2019 Patcell. All rights reserved.
//

import UIKit

class NewsHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var lblAbbriviation: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var viewCategoryName: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.viewCategoryName.backgroundColor = Constant().THEMECOLOR
        self.lblAbbriviation.textColor = Constant().THEMECOLOR
    }
    
    var row: Int?
    var onClick: ((Int) -> ())?
    @IBAction func actionClick(_ sender: Any) {
        if let row = self.row {
            onClick?(row)
        }
    }
}
