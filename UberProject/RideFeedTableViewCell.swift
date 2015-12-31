//
//  RideFeedTableViewCell.swift
//  Uber
//
//  Created by Anil Allewar on 12/29/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class RideFeedTableViewCell: UITableViewCell {

    @IBOutlet var riderImageView: UIImageView!
    
    @IBOutlet var riderNameLabel: UILabel!
    
    @IBOutlet var riderPickUpAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
