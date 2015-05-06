//
//  ForgotPasswordVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 11/18/14.
//  Copyright (c) 2014 antiblank. All rights reserved.
//


import UIKit

class ForgotPasswordVC: MyViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    let email = String()
    let workEmailField = UITextField()
    let sendResetLinkBtn = UIButton()
    let backBtn = UIButton()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    init(email:String) {
        super.init(nibName: nil, bundle: nil)
        self.email = email
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = knackkOrange
        
        var targetY = screenHeight - screenHeight + 10
        
        // instructions label
        let instructionsLbl = UILabel(frame: CGRectMake(20, targetY, 280, 24))
        instructionsLbl.font = UIFont(name: "Verdana", size: 14)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.text = "Enter your knackk email:"
        scroller.addSubview(instructionsLbl)
        targetY += 35
        
        // work email
        let workEmailBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        workEmailBg.image = UIImage(named: "TextField")
        scroller.addSubview(workEmailBg)
        targetY += 5
        workEmailField.frame = CGRectMake(40, targetY, 240, 32)
        workEmailField.delegate = self
        workEmailField.font = UIFont(name: "Verdana", size: 18)
        workEmailField.textColor = UIColor.darkGrayColor()
        workEmailField.placeholder = "Work Email"
        workEmailField.text = email
        workEmailField.userInteractionEnabled = true
        workEmailField.returnKeyType = UIReturnKeyType.Next
        workEmailField.keyboardType = UIKeyboardType.EmailAddress
        workEmailField.autocorrectionType = UITextAutocorrectionType.No
        workEmailField.autocapitalizationType = UITextAutocapitalizationType.None
        workEmailField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(workEmailField)
        targetY += 50
        
        // back button
        backBtn.frame = CGRectMake(20, targetY, 44, 44)
        backBtn.setBackgroundImage(UIImage(named: "backBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(backBtn)
        
        // send reset link button
        sendResetLinkBtn.frame = CGRectMake(74, targetY, 226, 44)
        sendResetLinkBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        sendResetLinkBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        sendResetLinkBtn.titleLabel?.textColor = UIColor.whiteColor()
        sendResetLinkBtn.setTitle("Send Reset PW Link", forState: UIControlState.Normal)
        sendResetLinkBtn.addTarget(self, action: "resetAction", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(sendResetLinkBtn)
        
        // activity indicator
        activityIndicator.center = CGPointMake(sendResetLinkBtn.frame.size.width - 25, 22)
        activityIndicator.hidesWhenStopped = true
        sendResetLinkBtn.addSubview(activityIndicator)
    }
    func keyboardDone() {
        scroller.setContentOffset(CGPointMake(0, -20), animated: true)
        workEmailField.resignFirstResponder()
    }
    
    
    // MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func startThinking() {
        // show indicator, disable buttons
        activityIndicator.startAnimating()
        backBtn.enabled = false
        sendResetLinkBtn.enabled = false
    }
    func stopThinking() {
        // hide indicator, enable buttons
        activityIndicator.stopAnimating()
        backBtn.enabled = true
        sendResetLinkBtn.enabled = true
    }
    func resetAction() {
        
        keyboardDone()
        scroller.setContentOffset(CGPointMake(0, -20), animated: false)
        
        if (!workEmailField.text.isEmpty) {
            
            startThinking()
            
            // query list of users
            var parameters = parametersForTask("resetPassword")
            parameters["email"] = workEmailField.text
            
            println("paramters: \(parameters)")
            
            
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
                        
                        let alert = UIAlertView(title: "Reset Link Sent", message: "A link to reset your password has been sent, please check your email account.", delegate: nil, cancelButtonTitle: "Login")
                        alert.show()
                    } else {
                        let message = JSON["message"].stringValue
                        println("failure, message: \(message)")
                        
                        if (message=="No user with this email found") {
                            let alert = UIAlertView(title: "Unknown Email", message: "There are no knackk users associated with this email address.", delegate: nil, cancelButtonTitle: "Okay")
                            alert.show()
                        }
                    }
            }
        } else {
            let alert = UIAlertView(title: "Email Required", message: "You must enter your knackk email address to reset your password.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "Login" {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
}