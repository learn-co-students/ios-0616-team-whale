//
//  ProfileMapHeader.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
class ProfileMapHeader: UIView {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var stepsWalkedLabel: UILabel!
    @IBOutlet weak var pathsTakenLabel: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}