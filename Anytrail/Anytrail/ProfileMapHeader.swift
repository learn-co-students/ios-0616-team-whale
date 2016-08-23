//
//  ProfileMapHeader.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
class ProfileMapHeader: UIView {
    
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var userNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let profileImageView = profileImageView else {
            return
        }
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
    }
}