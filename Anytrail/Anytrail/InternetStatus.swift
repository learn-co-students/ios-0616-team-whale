//
//  InternetStatus.swift
//  Anytrail
//
//  Created by Sergey Nevzorov on 8/19/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation

class InternetStatus {
    
    var hasInternet: Bool = false
    
    static let shared = InternetStatus()
    private init() {}
    
}
