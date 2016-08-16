//
//  ATSplashScreenController.swift
//  Anytrail
//
//  Created by Sergey Nevzorov on 8/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import QuartzCore

class ATSplashScreenController: UIViewController {
    
    var mask: CALayer?
    
    @IBOutlet weak var whaleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mask = CALayer()
        self.mask?.contents = UIImage(named: "shoePrint")!.CGImage
        self.mask?.contentsGravity = kCAGravityResizeAspect
        self.mask?.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.mask?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.mask?.position = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        
        whaleImageView.layer.mask = mask
        //self.view.backgroundColor = UIColor(red: 107/255.0, green: 176/255.0, blue: 62/255.0, alpha: 1)
      
//        self.view.backgroundColor = UIColor(red: 41/255.0, green: 111/255.0, blue: 126/255.0, alpha: 1)
        self.view.backgroundColor = UIColor(red: 32/255.0, green: 32/255.0, blue: 32/255.0, alpha: 0.9)
        
        animate()
        
    }
    
    func animate() {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 1
        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1
        
        let initialBounds = NSValue(CGRect: mask!.bounds)
        
        let middleBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 90, height: 90))
        let finalBounds =  NSValue(CGRect: CGRect(x: 0, y: 0, width: 1500, height: 1500))
        
        keyFrameAnimation.values = [initialBounds, middleBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.3, 1.8]
        
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        
        self.mask?.addAnimation(keyFrameAnimation, forKey: "bounds")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.whaleImageView.layer.mask = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
