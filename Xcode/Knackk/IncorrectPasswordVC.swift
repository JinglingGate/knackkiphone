//
//  IncorrectPasswordVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 11/18/14.
//  Copyright (c) 2014 antiblank. All rights reserved.
//

import UIKit

class IncorrectPasswordVC: MyViewController, UITextFieldDelegate {
    
    let email = String()
    let workEmailField = UITextField()
    let passwordField = UITextField()
    let loginBtn = UIButton()
    let forgotPWBtn = UIButton()
    let registerBtn = UIButton()
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
        instructionsLbl.text = "Incorrect password, please try again:"
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
        
        // password
        let passwordBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        passwordBg.image = UIImage(named: "TextField")
        scroller.addSubview(passwordBg)
        targetY += 5
        passwordField.frame = CGRectMake(40, targetY, 240, 32)
        passwordField.delegate = self
        passwordField.font = UIFont(name: "Verdana", size: 18)
        passwordField.textColor = UIColor.darkGrayColor()
        passwordField.placeholder = "Password"
        passwordField.userInteractionEnabled = true
        passwordField.returnKeyType = UIReturnKeyType.Next
        passwordField.secureTextEntry = true
        passwordField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(passwordField)
        targetY += 50
        
        // back button
        backBtn.frame = CGRectMake(20, targetY, 44, 44)
        backBtn.setBackgroundImage(UIImage(named: "backBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(backBtn)
        
        // login  button
        loginBtn.frame = CGRectMake(74, targetY, 226, 44)
        loginBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        loginBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        loginBtn.titleLabel?.textColor = UIColor.whiteColor()
        loginBtn.setTitle("Login", forState: UIControlState.Normal)
        loginBtn.addTarget(self, action: "loginAction", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(loginBtn)
        targetY += 48
        
        // activity indicator
        activityIndicator.center = CGPointMake(loginBtn.frame.size.width - 25, 22)
        activityIndicator.hidesWhenStopped = true
        loginBtn.addSubview(activityIndicator)
        
        // forgot PW  button
        forgotPWBtn.frame = CGRectMake(20, targetY, 280, 44)
        //forgotPWBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        forgotPWBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        forgotPWBtn.titleLabel?.textColor = UIColor.whiteColor()
        forgotPWBtn.setTitle("Forgot Password?", forState: UIControlState.Normal)
        forgotPWBtn.titleLabel?.font = UIFont(name: "Verdana", size: 14)
        forgotPWBtn.addTarget(self, action: "forgotPWAction", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(forgotPWBtn)
        
        // register  button
        registerBtn.frame = CGRectMake(20, screenHeight - 84, 280, 44)
        registerBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        registerBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        registerBtn.titleLabel?.textColor = UIColor.whiteColor()
        registerBtn.setTitle("I Need to Register", forState: UIControlState.Normal)
        registerBtn.addTarget(self, action: "registerAction", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(registerBtn)
    }
    func keyboardDone() {
        scroller.setContentOffset(CGPointMake(0, -20), animated: true)
        workEmailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    
    // MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func startThinking() {
        // show indicator, disable buttons
        activityIndicator.startAnimating()
        loginBtn.enabled = false
        forgotPWBtn.enabled = false
        registerBtn.enabled = false
        backBtn.enabled = false
    }
    func stopThinking() {
        // hide indicator, enable buttons
        activityIndicator.stopAnimating()
        loginBtn.enabled = true
        forgotPWBtn.enabled = true
        registerBtn.enabled = true
        backBtn.enabled = true
    }
    func loginAction() {
        
        keyboardDone()
        scroller.setContentOffset(CGPointMake(0, -20), animated: false)
        
        if (!workEmailField.text.isEmpty && !passwordField.text.isEmpty) {
            
            startThinking()
            
            // query list of users
            var parameters = parametersForTask("validateEmailUser")
            parameters["email"] = workEmailField.text
            parameters["password"] = passwordField.text
            
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
                        
                        // save results to plist
                        let dbHelper = DatabaseHelper()
                        var mutDict = dbHelper.getUserData()
                        mutDict.setObject(JSON["userId"].stringValue, forKey: "knackkId")
                        mutDict.setObject(JSON["companyId"].stringValue, forKey: "companyId")
                        mutDict.setObject(JSON["companyName"].stringValue, forKey: "companyName")
                        mutDict.setObject(self.workEmailField.text, forKey: "email")
                        mutDict.setObject(JSON["firstName"].stringValue, forKey: "firstName")
                        mutDict.setObject(JSON["lastName"].stringValue, forKey: "lastName")
                        mutDict.setObject("email", forKey: "userType")
                        dbHelper.saveUserData(mutDict)
                        
                        let companyName = JSON["companyName"].stringValue
                        if (companyName == "null" || companyName == "") {
                            let vc = SelectCompanyNameVC()
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            
                            // assume already followed / invited
                            mutDict.setObject("true", forKey: "didFollow")
                            mutDict.setObject("true", forKey: "didInvite")
                            dbHelper.saveUserData(mutDict)
                            
                            let vc = FeedVC(segment:["All", "Following", "Me"], fetchCoworkers:true, navBarType: "feed")
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    } else {
                        let message = JSON["message"].stringValue
                        println("failure, message: \(message)")
                        
                        if (message=="No user with this email found") {
                            let vc = RegisterVC(email: self.workEmailField.text, password: self.passwordField.text)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        if (message=="Incorrect password") {
                            let vc = IncorrectPasswordVC(email: self.workEmailField.text)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
            }
        } else {
            let alert = UIAlertView(title: "Missing Fields", message: "You must enter a username and password to login or register.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
    }
    func forgotPWAction() {
        let vc = ForgotPasswordVC(email: self.workEmailField.text)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func registerAction() {
        let vc = RegisterVC(email: self.workEmailField.text, password: self.passwordField.text)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
