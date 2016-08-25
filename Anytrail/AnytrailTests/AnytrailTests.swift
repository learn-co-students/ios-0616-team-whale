//
//  AnytrailTests.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/25/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Quick
import Nimble

@testable import Anytrail

class SplashViewControllerSpec: QuickSpec {
    
    override func spec() {
        var launchController: ATSplashViewController!
        
        beforeEach {
            launchController = ATSplashViewController()
            
            expect(launchController.view).toNot(beNil())
        }
        
        describe("User login functionality") {
            
            it("should automatically login users") {
                //
            }
        }
    }
}