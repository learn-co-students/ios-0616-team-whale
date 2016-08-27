//
//  ATDropdownView.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import CoreLocation
import SnapKit

protocol ATDropdownViewDelegate {
    func dropdownDidUpdateOrigin(location: String?)
    func dropdownDidUpdateDestination(location: String?)
    
    func dropdownDidStartRoute()
    func dropdownDidEndRoute()
}

class ATDropdownView: UIView, UITextFieldDelegate {
    
    var delegate: ATDropdownViewDelegate?
    var originString: String {
        return originTextField.text ?? ""
    }
    
    var destinationString: String {
        return originTextField.text ?? ""
    }
    
    
    private let view: UIView!
    
    private var originPinImageView: UIImageView!
    private var destinationPinImageView: UIImageView!
    
    private var originTextField: UITextField!
    private var destinationTextField: UITextField!
    
    private var hintLabel: UILabel!
    
    private var startButton: UIButton!
    private var stopButton: UIButton!
    
    enum ATDropownViewType: Int {
        case Default
        case Label
        case Activity
    }
    
    // MARK: - Initialization
    
    init(view: UIView) {
        self.view = view
        
        super.init(frame: CGRectMake(view.frame.origin.x, view.frame.origin.y - 75, view.frame.size.width, 100))
        configureDefaultView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    func show() {
        view.addSubview(self)
        
        UIView.animateWithDuration(0.2) {
            self.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 75, self.view.frame.size.width, 85)
        }
    }
    
    func hide() {
        UIView.animateWithDuration(0.2, animations: {
            self.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 170, self.view.frame.size.width, 85)
            }, completion: { _ in
                self.removeFromSuperview()
        })
    }
    
    func changeDropdownView(type: ATDropownViewType) {
        if type == .Default {
            configureDefaultView()
        } else if type == .Label {
            configureHintsView()
        } else {
            configureActivityView()
        }
    }
    
    func dropdownDidStartRoute() {
        stopButton.enabled = true
        startButton.enabled = false
        
        delegate?.dropdownDidStartRoute()
    }
    
    func dropdownDidEndRoute() {
        stopButton.enabled = false
        startButton.enabled = true
        
        delegate?.dropdownDidEndRoute()
    }
    
    // MARK: - Textfields
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField == originTextField {
            updateOrigin(textField.text)
        } else if textField == destinationTextField {
            updateDestination(textField.text)
        }
        return true
    }
    
    func updateOrigin(originString: String?) {
        guard let text = originString where text.characters.count > 2 else {
            return
        }
        delegate?.dropdownDidUpdateOrigin(text)
    }
    
    func updateDestination(destinationString: String?) {
        guard let text = destinationString where text.characters.count > 2 else {
            return
        }
        delegate?.dropdownDidUpdateDestination(text)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == originTextField {
            destinationTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        
        return true
    }
    
    // MARK: - Labels
    
    func updateHintLabel(text: String) {
        hintLabel.text = text
    }
    
    func updateActivityDistanceLabel(text: String) {
        originTextField.text = text
    }
    
    func updateActivityTimeLabel(text: String) {
        destinationTextField.text = text
    }
    
    // MARK: - Configuration
    
    func configureDefaultView() {
        self.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 0.7)
        
        clearView()
        
        originPinImageView = UIImageView(frame: CGRectMake(0, 0, 10, 10))
        originPinImageView.image = UIImage(named: "origin-dot")
        
        destinationPinImageView = UIImageView(frame: CGRectMake(0, 0, 10, 10))
        destinationPinImageView.image = UIImage(named: "destination-dot")
        
        originTextField = UITextField(frame: CGRectMake(self.view.frame.origin.x + 10, self.view.center.y - 265, self.frame.size.width - 20, 30))
        originTextField = configureTextField(originTextField)
        originTextField.returnKeyType = .Next
        originTextField.text = ""
        originTextField.placeholder = "123 West 42nd St"
        //originTextField.becomeFirstResponder()
        
        destinationTextField = UITextField(frame: CGRectMake(self.view.frame.origin.x + 10, self.view.center.y - 230, self.frame.size.width - 20, 30))
        destinationTextField = configureTextField(destinationTextField)
        destinationTextField.returnKeyType = .Done
        destinationTextField.text = ""
        destinationTextField.placeholder = "Central Park"
        
        addSubview(originPinImageView)
        addSubview(destinationPinImageView)
        
        addSubview(originTextField)
        addSubview(destinationTextField)
        
        makeDefaultConstraints()
    }
    
    func configureHintsView() {
        self.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 0.7)
        
        clearView()
        
        hintLabel = UILabel(frame: CGRectMake(self.center.x, self.center.y, self.frame.size.width, 25))
        hintLabel = configureHintLabel(hintLabel)
        
        addSubview(hintLabel)
        makeHintLabelConstraints()
    }
    
    func configureTextField(textField: UITextField) -> UITextField {
        textField.backgroundColor = UIColor.whiteColor()
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 4
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        textField.textColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        textField.font = UIFont.systemFontOfSize(13)
        textField.autocapitalizationType = .Words
        textField.autocorrectionType = .No
        textField.clearButtonMode = .WhileEditing
        textField.delegate = self
        
        return textField
    }
    
    func configureActivityView() {
        configureDefaultView()
        
        originPinImageView.image = UIImage(named: "activity-time")
        destinationPinImageView.image = UIImage(named: "activity-distance")
        
        originTextField.backgroundColor = UIColor.clearColor()
        originTextField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        originTextField.placeholder = ""
        originTextField.text = "00:00:00"
        originTextField.userInteractionEnabled = false
        
        destinationTextField.backgroundColor = UIColor.clearColor()
        destinationTextField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        destinationTextField.placeholder = ""
        destinationTextField.text = "0 mi"
        destinationTextField.userInteractionEnabled = false
        
        startButton = UIButton(type: .Custom)
        startButton.setTitle("Start", forState: .Normal)
        startButton.setTitleColor(ATConstants.Colors.BLUE, forState: .Normal)
        startButton.setTitleColor(ATConstants.Colors.GRAY, forState: .Disabled)
        startButton.addTarget(self, action: #selector(dropdownDidStartRoute), forControlEvents: .TouchUpInside)
        startButton.showsTouchWhenHighlighted = true
        
        stopButton = UIButton(type: .Custom)
        stopButton.setTitle("Stop", forState: .Normal)
        stopButton.setTitleColor(ATConstants.Colors.RED, forState: .Normal)
        stopButton.setTitleColor(ATConstants.Colors.GRAY, forState: .Disabled)
        stopButton.addTarget(self, action: #selector(dropdownDidEndRoute), forControlEvents: .TouchUpInside)
        stopButton.showsTouchWhenHighlighted = true
        stopButton.enabled = false
        
        addSubview(startButton)
        addSubview(stopButton)
        
        makeActivityViewConstraints()
    }
    
    func configureHintLabel(label: UILabel) -> UILabel {
        label.textColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        label.textAlignment = .Center
        label.font = UIFont.boldSystemFontOfSize(13.5)
        label.numberOfLines = 0
        
        return label
    }
    
    func clearView() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    // MARK: - Constraints
    
    func makeDefaultConstraints() {
        originTextField.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(30)
            make.right.equalTo(self.snp.right).offset(-5)
            make.top.equalTo(self.snp.top).offset(15)
            make.height.equalTo(30)
        }
        
        destinationTextField.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(30)
            make.right.equalTo(self.snp.right).offset(-5)
            make.bottom.equalTo(self.snp.bottom).offset(-5)
            make.height.equalTo(30)
        }
        
        originPinImageView.snp.makeConstraints { (make) in
            make.top.equalTo(originTextField.snp.top).offset(4)
            make.bottom.equalTo(originTextField.snp.bottom).offset(-4)
            make.left.equalTo(self.snp.left).offset(4)
            make.right.equalTo(originTextField.snp.left).offset(-4)
        }
        
        destinationPinImageView.snp.makeConstraints { (make) in
            make.top.equalTo(destinationTextField.snp.top).offset(4)
            make.bottom.equalTo(destinationTextField.snp.bottom).offset(-4)
            make.left.equalTo(self.snp.left).offset(4)
            make.right.equalTo(destinationTextField.snp.left).offset(-4)
        }
    }
    
    func makeHintLabelConstraints() {
        hintLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(7)
        }
    }
    
    func makeActivityViewConstraints() {
        originTextField.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(30)
            make.top.equalTo(self.snp.top).offset(15)
            make.height.equalTo(30)
        }
        
        destinationTextField.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(30)
            make.bottom.equalTo(self.snp.bottom).offset(-5)
            make.height.equalTo(30)
        }
        
        startButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-10)
            make.top.equalTo(originTextField.snp.top)
        }
        
        stopButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-10)
            make.top.equalTo(destinationTextField.snp.top)
        }
    }
}
