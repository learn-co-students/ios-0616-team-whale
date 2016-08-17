//
//  ATPathDetailedController.swift
//  Anytrail
//
//  Created by Sergey Nevzorov on 8/15/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ATPathDetailedController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageDetail = UIImage()
    var dateDetail = String()
    var locationDetail = String()
    var distanceDetail = String()
    var stepsDetail = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = imageDetail
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
