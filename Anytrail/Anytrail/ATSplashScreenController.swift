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
        self.mask?.contents = UIImage(named: "liberty")!.CGImage
        self.mask?.contentsGravity = kCAGravityResizeAspect
        self.mask?.bounds = CGRect(x: 0, y: 0, width: 220, height: 220)
        self.mask?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.mask?.position = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        whaleImageView.layer.mask = mask
        self.view.backgroundColor = UIColor(red: 89/255.0, green: 90/255.0, blue: 92/255.0, alpha: 0.9)

        animate()
    }
    
    func animate() {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 1
        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1
        
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        
        let initialBounds = NSValue(CGRect: mask!.bounds)
        let middleBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 90, height: 90))
        let finalBounds =  NSValue(CGRect: CGRect(x: 0, y: 0, width: 3000, height: 3000))
        
        keyFrameAnimation.values = [initialBounds, middleBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.3, 1.1]
        
        self.mask?.addAnimation(keyFrameAnimation, forKey: "bounds")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.whaleImageView.layer.mask = nil
    }
}
