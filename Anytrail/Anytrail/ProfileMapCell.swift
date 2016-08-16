//
//  ProfileMapCell.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ProfileMapCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var stepsWalkedLabel: UILabel!
    @IBOutlet weak var pathsTakenLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
