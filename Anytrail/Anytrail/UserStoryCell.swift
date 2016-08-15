//
//  UserStoryCell.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/15/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class UserStoryCell: UITableViewCell {
    
    @IBOutlet weak var dataIconView: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var userCellBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        print("awake from nib")
        userCellBackgroundView.layer.cornerRadius = 8
        self.dataIconView.image = UIImage(named: "steps-taken")
    
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
