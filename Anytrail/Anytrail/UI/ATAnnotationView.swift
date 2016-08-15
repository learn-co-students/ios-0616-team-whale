//
//  ATAnnotationView.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/12/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Mapbox

class ATAnnotationView: MGLAnnotationView {
    
    enum ATAnnotationType: Int {
        case Origin
        case PointOfInterest
        case Destination
    }
    
    var type: ATAnnotationType?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scalesWithViewingDistance = false
        
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        
        layer.borderWidth = selected ? frame.width / 4 : 2
        layer.addAnimation(animation, forKey: "borderWidth")
    }
}
