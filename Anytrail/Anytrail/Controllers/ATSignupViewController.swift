//
//  ATSignupViewController.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Firebase

class ATSignupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var cells: [ATInputCell] = []
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Actions
    
    @IBAction func signup() {
        let name = cells[0].textField.text!
        let email = cells[1].textField.text!
        let password = cells[2].textField.text!
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if error == nil {
                if let user = user {
                    let changeRequest = user.profileChangeRequest()
                    changeRequest.displayName = name
                    
                    changeRequest.commitChangesWithCompletion({ (error) in
                        if error != nil {
                            print("Error updating user: \(error)")
                        }
                    })
                }
                
                let fullName = name.componentsSeparatedByString(" ")
                let first = fullName.first!
                
                ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Success, title: "Welcome!", text: "Welcome to Anytrail, \(first)!", callback: {
                    self.dismiss()
                })
                
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
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismiss()
    }
    
    // MARK: - Table
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath) as! ATInputCell
        
        if indexPath.row == 0 {
            cell.type = ATInputCell.ATInputCellType.Name
            cell.configure(cell.type)
            
            cell.textField.becomeFirstResponder()
            
        } else if indexPath.row == 1 {
            cell.type = ATInputCell.ATInputCellType.Email
            cell.configure(cell.type)
            
        } else if indexPath.row == 2 {
            cell.type = ATInputCell.ATInputCellType.Password
            cell.configure(cell.type)
        }
        
        if (!cells.contains(cell)) {
            cells.append(cell)
        }
        
        cell.textField.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Textfields
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag < 2 {
            let nextCell = cells[textField.tag + 1]
            nextCell.textField.becomeFirstResponder()
            
        } else {
            view.endEditing(true)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let cell = cells[textField.tag]
        
        if textField.tag < 2 {
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
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupKeyboardNotifcationListenerForScrollView(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //
    }
}

extension ATSignupViewController {
    
    func textFieldIsValid(cell: ATInputCell) -> Bool {
        let text = cell.textField.text
        var isValid = false
        
        if cell.type == .Name {
            if cell.textField.hasText() {
                isValid = true
            }
            
        } else if cell.type == .Email {
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", regex)
            
            isValid = emailTest.evaluateWithObject(text)
            
        } else if cell.type == .Password {
            if text?.characters.count >= 8 {
                isValid = true
            }
        }
        
        if isValid {
            cell.indicateTextField(cell.type, valid: true)
        } else {
            cell.indicateTextField(cell.type, valid: false)
        }
        
        return isValid
    }
    
    func allFieldsValid() -> Bool {
        var valid = true
        
        for cell in cells {
            if !textFieldIsValid(cell) {
                valid = false
            }
        }
        
        return valid
    }
}
