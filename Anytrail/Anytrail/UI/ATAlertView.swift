//
//  ATAlertView.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/9/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import JSSAlertView

class ATAlertView {
    
    struct ATAlertViewColor {
        static let GREY = UIColorFromHex(0xE3E7EA, alpha: 0.9)
        static let RED = UIColorFromHex(0xE74C3C, alpha: 0.9)
        static let GREEN = UIColorFromHex(0x27AE60, alpha: 0.9)
    }
    
    internal enum ATAlertViewType: Int {
        case Normal = 1
        case Error = 2
        case Success = 3
    }
    
    class func alertWithTitle(controller: UIViewController, type: ATAlertViewType, title: String, text: String, callback: () -> Void) {
        let color: UIColor
        
        if type == .Normal {
            color = ATAlertViewColor.GREY
        } else if type == .Error {
            color = ATAlertViewColor.RED
        } else {
            color = ATAlertViewColor.GREEN
        }
        
        let alert = JSSAlertView().show(
            controller,
            title: title,
            text: text,
            buttonText: "Dismiss",
            color: color
        )
        
        alert.addAction(callback)
        alert.setTextTheme(.Light)
    }
}