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
        dataLabel.text = "DATA"
        print("awake from nib")
        self.configureCell()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configureCell(){
        self.userCellBackgroundView?.layer.cornerRadius = 8.0
        
    }
    
    func giveCellData(dataIconStringName: UIImageView, dataLabel: String) {
        dataIconView = dataIconStringName
        self.dataLabel?.text = dataLabel
    }
    
    
}
