//
//  ATErrorTranslator.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/9/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation

class ATErrorTranslator {
    
    class func translate(error: NSError) -> String {
        let code = error.code
        let string: String
        
        switch code {
        case 17009:
            string = "Invalid login credentials"
            break
        case 17007:
            string = "This email is already in use"
            break
        case 17011:
            string = "This account was not found"
            break
        default:
            string = "Unknown"
            break
        }
        
        return string
    }
}
