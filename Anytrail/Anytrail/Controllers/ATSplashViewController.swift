//
//  ATSplashViewController.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ATSplashViewController: UIViewController {
    
    @IBOutlet weak var facebookSignUpButton: UIButton!
    @IBOutlet weak var emailSignUpButton: UIButton!
    
    // MARK: - Facebook Login
    
    @IBAction func loginWithFacebook() {
        let manager = FBSDKLoginManager()
        let permissions = ["email"]
        
        // TODO: Check facebook login errors
        
        manager.logInWithReadPermissions(permissions, fromViewController: self) { (result, error) in
            if error == nil {
                if let token = result.token {
                    let credential = FIRFacebookAuthProvider.credentialWithAccessToken(token.tokenString)
                    
                    FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                        if error == nil {
                            let photoURL = "http://graph.facebook.com/\(token.userID)/picture?type=large"
                            
                            if let user = user {
                                let changeRequest = user.profileChangeRequest()
                                changeRequest.photoURL = NSURL(string: photoURL)
                                
                                changeRequest.commitChangesWithCompletion({ (error) in
                                    if error != nil {
                                        print("Error updating user: \(error)")
                                    }
                                })
                            }
                            self.performSegueWithIdentifier("ToMap", sender: self)
                            
                        } else {
                            print("Firebase login error: \(error)")
                        }
                    })
                }
                
            } else {
                print("Facebook login error: \(error)")
            }
        }
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookSignUpButton.layer.cornerRadius = 4
        emailSignUpButton.layer.cornerRadius = 4
    }
    
    override func viewDidAppear(animated: Bool) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            if FIRAuth.auth()?.currentUser != nil {
                print("Welcome back, \(FIRAuth.auth()?.currentUser?.displayName)")
                print("Photo URL, \(FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)")
                
                self.performSegueWithIdentifier("ToMap", sender: self)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Animate segues from this controller since the
        // navigation bar is hidden. Prevent ugliness when possible!
        
        if segue.identifier == "ToEmailSignup" {
            // Signup
        } else if segue.identifier == "ToLogin" {
            // Login
        } else {
            // Facebook or user is already logged in
        }
    }
}
