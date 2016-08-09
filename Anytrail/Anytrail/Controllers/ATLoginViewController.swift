//
//  ATLoginViewController.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Firebase

class ATLoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var cells: [ATInputCell] = []
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
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
                
                ATAlertView.alertWithTitle(self, title: "Whoa!", text: "\(errorString)", callback: {
                    self.cells[1].textField.text = ""
                    self.cells[1].textField.becomeFirstResponder()
                    
                    self.textFieldIsValid(self.cells[1])
                    self.nextButton.enabled = false
                })
            }
        })
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath) as! ATInputCell
        
        if indexPath.row == 0 {
            cell.type = .Email
            cell.iconImageView.image = UIImage(named: "email")
            cell.textField.tag = 0
            cell.textField.placeholder = "john@email.com"
            cell.textField.autocorrectionType = .No
            cell.textField.keyboardType = .EmailAddress
            cell.textField.returnKeyType = .Next
            
            cell.textField.becomeFirstResponder()
            
        } else {
            cell.type = .Password
            cell.iconImageView.image = UIImage(named: "password")
            cell.textField.tag = 1
            cell.textField.placeholder = "•••••••••"
            cell.textField.secureTextEntry = true
            cell.textField.returnKeyType = .Done
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
        if textField.tag < 1 {
            let nextCell = cells[textField.tag + 1]
            nextCell.textField.becomeFirstResponder()
            
            return true
        }
        
        view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let cell = cells[textField.tag]
        
        if !cells.contains(cell) {
            cells.append(cell)
        }
        
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
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //
    }
}

extension ATLoginViewController {
    
    func textFieldIsValid(cell: ATInputCell) -> Bool {
        let text = cell.textField.text
        var isValid = false
        
        if cell.type == .Email {
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
