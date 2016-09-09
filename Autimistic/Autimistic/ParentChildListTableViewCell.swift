//
//  ParentChildListTableViewCell.swift
//  Autimistic
//
//  Created by Yiru Gao on 4/4/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import ChameleonFramework

class ParentChildListTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var progressID: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    
    
    
    var email : String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.avatar.layer.cornerRadius = self.avatar.frame.size.height/2
        self.avatar.layer.borderWidth = 1
        self.avatar.layer.borderColor = FlatGray().CGColor
        self.avatar.layer.cornerRadius = CGRectGetWidth(self.avatar.frame)/10.0
        self.avatar.clipsToBounds = true
        
        self.contentView.backgroundColor = FlatBlackDark()
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = FlatGrayDark().CGColor
        self.contentView.layer.cornerRadius = CGRectGetWidth(self.avatar.frame)/10.0

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
