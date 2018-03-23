//
//  CurrentTableViewCell.swift
//  csci571_HW9
//
//  Created by Shiqi Wei on 5/1/16.
//  Copyright © 2016 Shiqi Wei. All rights reserved.
//

import UIKit

class CurrentTableViewCell: UITableViewCell {

    @IBOutlet weak var current_data: UILabel!
    @IBOutlet weak var current_header: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
