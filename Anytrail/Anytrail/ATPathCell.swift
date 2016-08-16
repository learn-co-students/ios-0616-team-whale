//
//  ATPathCell.swift
//  Anytrail
//
//  Created by Sergey Nevzorov on 8/15/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ATPathCell: UITableViewCell {
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
