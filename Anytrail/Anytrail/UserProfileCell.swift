//
//  UserProfileCell.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/15/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class UserProfileCell: UITableViewCell {
    
    @IBOutlet weak var dataIconView: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var userCellBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userCellBackgroundView.backgroundColor = ATConstants.Colors.GRAY
        self.userCellBackgroundView.layer.cornerRadius = 10.0
        dataLabel.textColor = UIColor(red: 80/225, green: 80/225, blue: 80/255, alpha: 1)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func giveCellData(dataIconStringName: UIImage, dataLabel: String) {
        dataIconView.image = dataIconStringName
        self.dataLabel?.text = dataLabel
    }
    
    
}