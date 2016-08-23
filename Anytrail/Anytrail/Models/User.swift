//
//  User.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/23/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import Firebase
import Alamofire

extension FIRUser {
    
    func fetchUserProfileImage(completion: (UIImage?) -> ()) {
        if let user = FIRAuth.auth()?.currentUser {
            print("Name: \(user.displayName)")
            print("Photo URL: \(user.photoURL)")
            
            Alamofire.request(.GET, photoURL!).response { (request, response, data, error) in
                if error == nil {
                    if let data = data {
                        completion(UIImage(data: data))
                    }
                } else {
                    print("Error fetching image for user")
                    completion(nil)
                }
            }
        }
    }
}