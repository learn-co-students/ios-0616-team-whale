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
        
        // TODO: Convert to switch
        if valid {
            switch type {
            case .Name:
                imageName = "person"
                break
            case .Email:
                imageName = "email"
                break
            case .Password:
                imageName = "password"
                break
            }
            
            self.iconImageView.image = UIImage(named: "\(imageName)-valid")
            
        } else {
            switch type {
            case .Name:
                imageName = "person"
                break
            case .Email:
                imageName = "email"
                break
            case .Password:
                imageName = "password"
                break
            }
            
            self.iconImageView.image = UIImage(named: "\(imageName)-error")
        }
    }
    
    func configure(type: ATInputCellType) {
        if type == .Name {
            self.textField.tag = 0
            self.textField.placeholder = "John Doe"
            self.iconImageView.image = UIImage(named: "person")
            self.textField.autocorrectionType = .No
            self.textField.autocapitalizationType = .Words
            self.textField.returnKeyType = .Next
            
        } else if type == .Email {
            self.textField.tag = 1
            self.textField.placeholder = "john@email.com"
            self.iconImageView.image = UIImage(named: "email")
            self.textField.autocorrectionType = .No
            self.textField.keyboardType = .EmailAddress
            self.textField.returnKeyType = .Next
            
        } else if type == .Password {
            self.textField.tag = 2
            self.textField.placeholder = "•••••••••"
            self.iconImageView.image = UIImage(named: "password")
            self.textField.secureTextEntry = true
            self.textField.returnKeyType = .Done
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
