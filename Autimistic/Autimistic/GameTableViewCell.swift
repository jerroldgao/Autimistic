//
//  GameTableViewCell.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 2/17/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    @IBOutlet weak var gamePhoto: UIImageView!

    @IBOutlet weak var gameNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
