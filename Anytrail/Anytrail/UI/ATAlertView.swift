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
    
    class func alertWithTitle(controller: UIViewController, title: String, text: String, callback: () -> Void) {
        let alert = JSSAlertView().show(
            controller,
            title: title,
            text: text,
            buttonText: "Dismiss",
            color: UIColorFromHex(0xE3E7EA, alpha: 0.9)
        )
        
        alert.addAction(callback)
        alert.setTextTheme(.Light)
    }
}