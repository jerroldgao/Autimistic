//
//  DoctorNotificationsTableViewCell.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 2/22/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import ChameleonFramework

class DoctorNotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var notiPhoto: UIImageView!
    
    @IBOutlet weak var notiLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.notiPhoto.layer.borderWidth = 1
        self.notiPhoto.layer.borderColor = FlatGray().CGColor
        self.notiPhoto.layer.cornerRadius = CGRectGetWidth(self.notiPhoto.frame)/10.0
        self.notiPhoto.clipsToBounds = true
        
        self.contentView.backgroundColor = FlatBlackDark()
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = FlatGrayDark().CGColor
        self.contentView.layer.cornerRadius = CGRectGetWidth(self.notiPhoto.frame)/10.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
