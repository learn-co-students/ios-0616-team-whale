//
//  ATInputCell.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ATInputCell: UITableViewCell {
    
    enum ATInputCellType: Int {
        case Name = 1
        case Email = 2
        case Password = 3
    }
    
    var type: ATInputCellType!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Animation
    
    func indicateTextField(type: ATInputCellType, valid: Bool) {
        var imageName: String = ""
        
        if valid {
            if type == .Name {
                imageName = "person"
                
            } else if type == .Email {
                imageName = "email"
                
            } else if type == .Password {
                imageName = "password"
            }
            
            self.iconImageView.image = UIImage(named: "\(imageName)-valid")
            
        } else {
            if type == .Name {
                imageName = "person"
                
            } else if type == .Email {
                imageName = "email"
                
            } else if type == .Password {
                imageName = "password"
            }
            
            self.iconImageView.image = UIImage(named: "\(imageName)-error")
        }
    }
    
    // MARK: - View

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
