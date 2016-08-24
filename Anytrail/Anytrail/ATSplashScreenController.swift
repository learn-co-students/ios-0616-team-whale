//
//  ATSplashScreenController.swift
//  Anytrail
//
//  Created by Sergey Nevzorov on 8/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import RevealingSplashView

class ATSplashScreenController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize a revealing Splash with with the iconImage, the initial size and the background color
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "liberty")!,iconInitialSize: CGSizeMake(130, 130), backgroundColor: UIColor(red: 89/255.0, green: 90/255.0, blue: 92/255.0, alpha: 0.9))
        
        revealingSplashView.useCustomIconColor = true
        revealingSplashView.iconColor = UIColor.whiteColor()
        
        revealingSplashView.animationType = SplashAnimationType.SwingAndZoomOut
        
        //Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)
        
        //Starts animation
        revealingSplashView.startAnimation(){
            print("Completed")
        }
    }
}
