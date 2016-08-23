//
//  ATLoginViewController.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Firebase

class ATLoginViewController: ATSignupViewController {
    
    // MARK: - Actions
    
    @IBAction func login() {
        let email = cells[0].textField.text!
        let password = cells[1].textField.text!
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error == nil {
                self.view.endEditing(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let errorString = ATErrorTranslator.translate(error!)
                
                ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Error, title: "Whoa!", text: "\(errorString)", callback: {
                    self.cells[1].textField.text = ""
                    self.cells[1].textField.becomeFirstResponder()
                    
                    self.textFieldIsValid(self.cells[1])
                    self.nextButton.enabled = false
                })
            }
        })
    }
    
    // MARK: - Table
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath) as! ATInputCell
        
        if indexPath.row == 0 {
            cell.type = ATInputCell.ATInputCellType.Email
            cell.configure(cell.type)
            cell.textField.tag = 0
            
            cell.textField.becomeFirstResponder()
            
        } else {
            cell.type = ATInputCell.ATInputCellType.Password
            cell.configure(cell.type)
            cell.textField.tag = 1
        }
        
        if (!cells.contains(cell)) {
            cells.append(cell)
        }
        
        if !cells.contains(cell) {
            cells.append(cell)
        }
        
        cell.textField.delegate = self
        
        return cell
    }

    // MARK: - Textfields
    
    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag < 1 {
            let nextCell = cells[textField.tag + 1]
            nextCell.textField.becomeFirstResponder()
            
            return true
        }
        
        view.endEditing(true)
        return false
    }
    
    override func textFieldDidEndEditing(textField: UITextField) {
        let cell = cells[textField.tag]
        
        if textField.tag < 1 {
            let nextCell = cells[textField.tag + 1]
            
            if textField.tag == 0 || textField.tag == 1 {
                textFieldIsValid(cell)
                nextCell.textField.becomeFirstResponder()
            }
            
        } else {
            textFieldIsValid(cell)
        }
        
        if allFieldsValid() {
            nextButton.enabled = true
        } else {
            nextButton.enabled = false
        }
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}