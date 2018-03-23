//
//  NewsTableViewCell.swift
//  csci571_HW9
//
//  Created by Shiqi Wei on 5/2/16.
//  Copyright © 2016 Shiqi Wei. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var tabledate: UILabel!
    @IBOutlet weak var tablecontent: UILabel!
    @IBOutlet weak var tabletitle: UILabel!
    @IBOutlet weak var tablepublisher: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
