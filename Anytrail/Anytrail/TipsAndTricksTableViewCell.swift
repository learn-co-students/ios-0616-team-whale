//
//  TipsAndTricksTableViewCell.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/18/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//



import UIKit

class TipsAndTricksTableViewCell: UITableViewCell {
    @IBOutlet weak var dataLabel: UITextView!
    @IBOutlet weak var userCellBackgroundView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    

}
