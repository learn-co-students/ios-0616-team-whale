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
        dataLabel.textColor = UIColor(red: 80/225, green: 80/225, blue: 80/255, alpha: 1)
        self.userCellBackgroundView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.backgroundColor = UIColor.whiteColor()
        self.dataLabel.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    

}
