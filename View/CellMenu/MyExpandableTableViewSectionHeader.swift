//
//  MyExpandableTableViewSectionHeader.swift
//  OnWP
//
//  Created by dong luong on 1/4/20.
//  Copyright © 2020 Patcell. All rights reserved.
//

import UIKit

final class MyExpandableTableViewSectionHeader: LUExpandableTableViewSectionHeader {
    // MARK: - Properties
     @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var imgHome: UIImageView!
    @IBOutlet weak var label: UILabel!
    override var isExpanded: Bool {
        didSet {
            // Change the title of the button when section header expand/collapse
           // expandCollapseButton?.setTitle(isExpanded ? "Collapse" : "Expand", for: .normal)
            if(isExpanded){
            expandCollapseButton?.setImage(UIImage(named: "ic_down_menu"), for: .normal)
            } else {
                 expandCollapseButton?.setImage(UIImage(named: "ic_right_menu"), for: .normal)
            }
        }
    }
    
    // MARK: - Base Class Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnLabel)))
        label?.isUserInteractionEnabled = true
    }
    
    // MARK: - IBActions
    
    @IBAction func expandCollapse(_ sender: UIButton) {
        // Send the message to his delegate that shold expand or collapse
        delegate?.expandableSectionHeader(self, shouldExpandOrCollapseAtSection: section)
    }
    
    // MARK: - Private Functions
    
    @objc private func didTapOnLabel(_ sender: UIGestureRecognizer) {
        // Send the message to his delegate that was selected
        delegate?.expandableSectionHeader(self, wasSelectedAtSection: section)
    }
}

