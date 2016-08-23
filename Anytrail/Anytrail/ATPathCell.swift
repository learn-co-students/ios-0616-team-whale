//
//  ATPathCell.swift
//  Anytrail
//
//  Created by Sergey Nevzorov on 8/15/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ATPathCell: UITableViewCell {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseView.layer.masksToBounds = true
        baseView.layer.cornerRadius = 6
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
