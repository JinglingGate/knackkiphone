//
//  InviteManuallyVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 2/2/15.
//  Copyright (c) 2015 antiblank. All rights reserved.
//

import UIKit

class InviteManuallyVC: MyViewController, UITextFieldDelegate {
    
    let nameField = UITextField()
    let workEmailField = UITextField()
    let registerBtn = UIButton()
    let backBtn = UIButton()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scroller.scrollEnabled = false
        
        var targetY = screenHeight - screenHeight + 20
        
        // instructions label
        let instructionsLbl = UILabel(frame: CGRectMake(20, targetY-10, 280, 52)) // y = ( fontSize + lineHeight + 2 ) * numLines
        instructionsLbl.font = UIFont(name: "Verdana", size: 16)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.numberOfLines = 0
        // add text and number of lines
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        var attrString = NSMutableAttributedString(string: "Enter the name and email of the co-worker you would like to invite:")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        instructionsLbl.attributedText = attrString
        scroller.addSubview(instructionsLbl)
        targetY += 52
        
        // first name
        let firstNameBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        firstNameBg.image = UIImage(named: "TextField")
        scroller.addSubview(firstNameBg)
        targetY += 5
        nameField.frame = CGRectMake(40, targetY, 240, 32)
        nameField.delegate = self
        nameField.font = UIFont(name: "Verdana", size: 18)
        nameField.textColor = UIColor.darkGrayColor()
        nameField.placeholder = "First Name"
        nameField.userInteractionEnabled = true
        nameField.returnKeyType = UIReturnKeyType.Next
        nameField.keyboardType = UIKeyboardType.EmailAddress
        nameField.autocorrectionType = UITextAutocorrectionType.No
        nameField.autocapitalizationType = UITextAutocapitalizationType.Words
        nameField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(nameField)
        targetY += 50
        
        // work email
        let workEmailBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        workEmailBg.image = UIImage(named: "TextField")
        scroller.addSubview(workEmailBg)
        targetY += 5
        workEmailField.frame = CGRectMake(40, targetY, 240, 32)
        workEmailField.delegate = self
        workEmailField.font = UIFont(name: "Verdana", size: 18)
        workEmailField.textColor = UIColor.darkGrayColor()
        workEmailField.placeholder = "Email Address"
        workEmailField.userInteractionEnabled = true
        workEmailField.returnKeyType = UIReturnKeyType.Go
        workEmailField.keyboardType = UIKeyboardType.EmailAddress
        workEmailField.autocorrectionType = UITextAutocorrectionType.No
        workEmailField.autocapitalizationType = UITextAutocapitalizationType.None
        workEmailField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(workEmailField)
        targetY += 50
        
        // login / register button
        registerBtn.frame = CGRectMake(74, targetY, 226, 44)
        registerBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        registerBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        registerBtn.titleLabel?.textColor = UIColor.whiteColor()
        registerBtn.setTitle("Invite", forState: UIControlState.Normal)
        registerBtn.addTarget(self, action: "register", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(registerBtn)
        
        // activity indicator
        activityIndicator.center = CGPointMake(registerBtn.frame.size.width - 25, 22)
        activityIndicator.hidesWhenStopped = true
        registerBtn.addSubview(activityIndicator)
        
        // back button
        backBtn.frame = CGRectMake(20, targetY, 44, 44)
        backBtn.setBackgroundImage(UIImage(named: "backBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(backBtn)
        
    }
    
    
    // MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func startThinking() {
        // show indicator, disable buttons
        activityIndicator.startAnimating()
        registerBtn.enabled = false
        backBtn.enabled = false
    }
    func stopThinking() {
        // hide indicator, enable buttons
        activityIndicator.stopAnimating()
        registerBtn.enabled = true
        backBtn.enabled = true
    }
    
    
    // MARK: text field methods
    func textFieldDidBeginEditing(textField: UITextField!) {
        scroller.contentInset = UIEdgeInsetsMake(20, 0, 260, 0)
        scroller.scrollEnabled = true
        /*if (screenHeight > 480) {
        scroller.setContentOffset(CGPointMake(0, 0), animated: true)
        } else {
        scroller.frame = CGRectMake(0, 0, 320, screenHeight-216)
        scroller.contentInset = UIEdgeInsetsMake(0, 0, 44, 0)
        scroller.scrollEnabled = true
        }*/
    }
    func textFieldDidEndEditing(textField: UITextField!) {
        scroller.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        scroller.setContentOffset(CGPointMake(0, -20), animated: false)
        scroller.scrollEnabled = false
        /*if (screenHeight <= 480) {
        scroller.frame = CGRectMake(0, 0, 320, screenHeight)
        scroller.contentInset = UIEdgeInsetsZero
        scroller.scrollEnabled = false
        }*/
    }
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if (textField == nameField) {
            workEmailField.becomeFirstResponder()
        }
        if (textField == workEmailField) {
            register()
        }
        return true
    }
    func keyboardDone() {
        nameField.resignFirstResponder()
        workEmailField.resignFirstResponder()
    }
    
    
    // MARK: methods
    func register() {
        
        if (!nameField.text.isEmpty && !workEmailField.text.isEmpty) {
            
            startThinking()
            
            let dbHelper = DatabaseHelper()
            let userDict = dbHelper.getUserData()
            
            
            // build string of invitees
            var inviteeEmailPairs = "\(workEmailField.text):\(nameField.text)"
            
            // parameters to send
            var parameters = parametersForTask("invite")
            parameters["userId"] = userDict["knackkId"] as? String
            parameters["inviteeEmailPairs"] = inviteeEmailPairs
            println("PARAMETERS \(parameters)")
            
            // send request to server
            request(.POST, apiURL, parameters: parameters)
                
                .responseSwiftyJSON { (request, response, JSON, error) in
                    println("REQUEST \(request)")
                    println("RESPONSE \(response)")
                    println("JSON \(JSON)")
                    println("ERROR \(error)")
                    
                    self.stopThinking()
                    
                    let status = JSON["status"].stringValue
                    if (status == "success") {
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    } else {
                        let alert = UIAlertView(title: "Connection Error", message: "Could not invite at this time. Please try again later.", delegate: nil, cancelButtonTitle: "Okay")
                        alert.show()
                    }
            }
            
        // if not all fields entered
        } else {
            let alert = UIAlertView(title: "Missing Fields", message: "You must enter all fields to invite a friend.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}