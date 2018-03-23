//
//  FavouritesTableViewCell.swift
//  csci571_HW9
//
//  Created by Shiqi Wei on 5/3/16.
//  Copyright © 2016 Shiqi Wei. All rights reserved.
//

import UIKit

class FavouritesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fav_table_symbol: UILabel!
    
    @IBOutlet weak var fav_table_company: UILabel!
    
    @IBOutlet weak var fav_table_price: UILabel!
    
    @IBOutlet weak var fav_table_change: UILabel!
    
    @IBOutlet weak var fav_table_marketcap: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
