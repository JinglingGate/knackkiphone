//
//  LoginVC.swift
//  Knackk
//
//  Created by wkasel on 7/29/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class LoginVC: MyViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    let workEmailField = UITextField()
    let passwordField = UITextField()
    let connectLinkedIn = UIButton()
    let loginRegisterBtn = UIButton()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // logo
        let logoView = UIImageView(frame: CGRect(x: 20, y: 105, width: 280, height: 70)) // x: 0, y: 90, width: 320, height: 80
        logoView.image = UIImage(named: "logo")
        scroller.addSubview(logoView)
        
        var targetY = screenHeight - 289 // 310 + 21
        
        // linked in button
        connectLinkedIn.frame = CGRectMake(20, targetY, 280, 53)
        connectLinkedIn.setImage(UIImage(named: "ConnectLinkedIn"), forState: UIControlState.Normal)
        connectLinkedIn.addTarget(self, action: "regWithLinkedIn", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(connectLinkedIn)
        targetY += 60
        
        // or
        let orLabel = UILabel(frame: CGRectMake(20, targetY, 280, 24))
        orLabel.font = UIFont(name: "Verdana-Bold", size: 11)
        orLabel.textColor = UIColor.whiteColor()
        orLabel.text = "- or -"
        orLabel.textAlignment = NSTextAlignment.Center
        scroller.addSubview(orLabel)
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
        passwordField.placeholder = "knackk Password"
        passwordField.userInteractionEnabled = true
        passwordField.returnKeyType = UIReturnKeyType.Go
        passwordField.secureTextEntry = true
        passwordField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(passwordField)
        targetY += 50
        
        // login / register button
        loginRegisterBtn.frame = CGRectMake(20, targetY, 280, 44)
        loginRegisterBtn.setBackgroundImage(buttonImage(CGSizeMake(280, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        loginRegisterBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        loginRegisterBtn.titleLabel?.textColor = UIColor.whiteColor()
        loginRegisterBtn.setTitle("Login or Register", forState: UIControlState.Normal)
        loginRegisterBtn.addTarget(self, action: "loginRegister", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(loginRegisterBtn)
        
        // activity indicator
        activityIndicator.center = CGPointMake(loginRegisterBtn.frame.size.width - 25, 22)
        activityIndicator.hidesWhenStopped = true
        loginRegisterBtn.addSubview(activityIndicator)
        
        // MARK: skip button
        let skipBtn = UIButton(frame: CGRectMake(220, -20, 100, 100))
        skipBtn.backgroundColor = UIColor(white: 1, alpha: 0.1)
        skipBtn.addTarget(self, action: "skipAction", forControlEvents: UIControlEvents.TouchUpInside)
        //scroller.addSubview(skipBtn)
    }
    
    
    // MARK: text field methods
    func textFieldDidBeginEditing(textField: UITextField!) {
        scroller.setContentOffset(CGPointMake(0, 240), animated: true)
    }
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if (textField == workEmailField) {
            passwordField.becomeFirstResponder()
        }
        if (textField == passwordField) {
            loginRegister()
        }
        return true
    }
    func keyboardDone() {
        scroller.setContentOffset(CGPointMake(0, -20), animated: true)
        workEmailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    
    // MARK: methods
    func startThinking() {
        // show indicator, disable buttons
        activityIndicator.startAnimating()
        connectLinkedIn.enabled = false
        loginRegisterBtn.enabled = false
    }
    func stopThinking() {
        // hide indicator, enable buttons
        activityIndicator.stopAnimating()
        connectLinkedIn.enabled = true
        loginRegisterBtn.enabled = true
    }
    func regWithLinkedIn() {
        
        let urlString = "https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=75558rdvj6bf2g&scope=r_fullprofile%20r_emailaddress%20r_network%20w_messages&state=changemelater&redirect_uri=http://knackk-server.herokuapp.com/oauth2callback?"
        
        //let urlString = "https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=75558rdvj6bf2g&scope=r_fullprofile%20r_emailaddress%20r_network%20w_messages&state=changemelater&redirect_uri=http://knackk-staging.herokuapp.com/oauth2callback?"
        println("login attempt via LinkedIn: \(urlString)")
        
        UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
        
    }
    /*func containsBadEmailAddress(email: String) -> Bool {
        return  email.lowercaseString.rangeOfString("gmail") != nil ||
                email.lowercaseString.rangeOfString("yahoo") != nil ||
                email.lowercaseString.rangeOfString("hotmail") != nil
    }*/
    func loginRegister() {
        
        keyboardDone()
        scroller.setContentOffset(CGPointMake(0, -20), animated: false)
        
        if (!workEmailField.text.isEmpty && !passwordField.text.isEmpty) {
            if EmailHelper.containsBadEmailAddress(workEmailField.text) {
                let alert = UIAlertView(title: "Unacceptable Domain", message: "You cannot use a Gmail, Yahoo, or Hotmail account.", delegate: nil, cancelButtonTitle: "Okay")
                alert.show()
            } else {
            
                startThinking()
                
                //let alert = UIAlertView(title: "DEVELOPMENT SKIP", message: "Normally, this will 1) try to login a user, 2) if user email is not found, go to register screen, 3) if user email is found but password incorrect, say 'password does not match.' In development, until login is working, this screen just goes directly to register screen.", delegate: self, cancelButtonTitle: "Okay")
                //alert.show()
                
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
                            mutDict.setObject(JSON["pictureUrl"].stringValue, forKey: "userImageURL")
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
                            
                            if JSON["error"].stringValue == "User already logged in" {
                                self.logoutUserAndRetryLogin()
                            }
                            
                        }
                } //responseSwiftyJSON
            }// endof if valid email
            
        } else {
            let alert = UIAlertView(title: "Missing Fields", message: "You must enter a username and password to login or register.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
    }
    func logoutUserAndRetryLogin() {
        
        startThinking()
        
        // get variables to send
        let dbHelper = DatabaseHelper()
        var parameters = parametersForTask("logOut")
        println("parameters: \(parameters)")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON \(JSON)")
                println("ERROR \(error)")
                
                self.stopThinking()
                
                let status = JSON["status"].stringValue
                let thisError = JSON["error"].stringValue
                if (status == "success" || thisError == "You must log in to access that information") {
                    // logout user in app as well
                    dbHelper.logoutUser()
                    self.loginRegister()
                }
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let vc = RegisterVC(email: self.workEmailField.text, password: self.passwordField.text)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func skipAction() {
        let vc = FeedVC(segment:["All", "Following", "Me"], fetchCoworkers:true, navBarType: "feed")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}