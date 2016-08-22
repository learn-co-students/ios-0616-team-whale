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
    @IBOutlet weak var dataLabel: UITextView!
    @IBOutlet weak var userCellBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //dataLabel.text = "DATA"
        print("awake from nib")
        self.configureCell()
        dataLabel.textColor = UIColor(red: 80/225, green: 80/225, blue: 80/255, alpha: 1)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configureCell(){
        self.userCellBackgroundView?.layer.cornerRadius = 8.0
        self.userCellBackgroundView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.dataLabel.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    }
    
    func giveCellData(dataIconStringName: UIImage, dataLabel: String) {
        dataIconView.image = dataIconStringName
        self.dataLabel?.text = dataLabel
    }
    
    
}