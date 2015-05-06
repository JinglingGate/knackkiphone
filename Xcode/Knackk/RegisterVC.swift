//
//  RegisterVC.swift
//  Knackk
//
//  Created by wkasel on 7/29/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class RegisterVC: MyViewController, UITextFieldDelegate {
    
    let email = String()
    let password = String()
    
    init(email:String, password:String) {
        super.init(nibName: nil, bundle: nil)
        self.email = email
        self.password = password
    }
    
    let workEmailField = UITextField()
    let passwordField = UITextField()
    let passwordConfirmField = UITextField()
    let firstNameField = UITextField()
    let lastNameField = UITextField()
    let registerBtn = UIButton()
    let backBtn = UIButton()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var targetY = screenHeight - screenHeight + 20
        
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
        passwordField.text = password
        passwordField.userInteractionEnabled = true
        passwordField.returnKeyType = UIReturnKeyType.Next
        passwordField.secureTextEntry = true
        passwordField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(passwordField)
        targetY += 50
        
        // cofirm password
        let confirmPasswordBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        confirmPasswordBg.image = UIImage(named: "TextField")
        scroller.addSubview(confirmPasswordBg)
        targetY += 5
        passwordConfirmField.frame = CGRectMake(40, targetY, 240, 32)
        passwordConfirmField.delegate = self
        passwordConfirmField.font = UIFont(name: "Verdana", size: 18)
        passwordConfirmField.textColor = UIColor.darkGrayColor()
        passwordConfirmField.placeholder = "Confirm Password"
        passwordConfirmField.text = ""
        passwordConfirmField.userInteractionEnabled = true
        passwordConfirmField.returnKeyType = UIReturnKeyType.Next
        passwordConfirmField.secureTextEntry = true
        passwordConfirmField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(passwordConfirmField)
        targetY += 50
        
        // first name
        let firstNameBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        firstNameBg.image = UIImage(named: "TextField")
        scroller.addSubview(firstNameBg)
        targetY += 5
        firstNameField.frame = CGRectMake(40, targetY, 240, 32)
        firstNameField.delegate = self
        firstNameField.font = UIFont(name: "Verdana", size: 18)
        firstNameField.textColor = UIColor.darkGrayColor()
        firstNameField.placeholder = "First Name"
        firstNameField.userInteractionEnabled = true
        firstNameField.returnKeyType = UIReturnKeyType.Next
        firstNameField.keyboardType = UIKeyboardType.EmailAddress
        firstNameField.autocorrectionType = UITextAutocorrectionType.No
        firstNameField.autocapitalizationType = UITextAutocapitalizationType.Words
        firstNameField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(firstNameField)
        targetY += 50
        
        // last name
        let lastNameBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        lastNameBg.image = UIImage(named: "TextField")
        scroller.addSubview(lastNameBg)
        targetY += 5
        lastNameField.frame = CGRectMake(40, targetY, 240, 32)
        lastNameField.delegate = self
        lastNameField.font = UIFont(name: "Verdana", size: 18)
        lastNameField.textColor = UIColor.darkGrayColor()
        lastNameField.placeholder = "Last Name"
        lastNameField.userInteractionEnabled = true
        lastNameField.returnKeyType = UIReturnKeyType.Go
        lastNameField.keyboardType = UIKeyboardType.EmailAddress
        lastNameField.autocorrectionType = UITextAutocorrectionType.No
        lastNameField.autocapitalizationType = UITextAutocapitalizationType.Words
        lastNameField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(lastNameField)
        targetY += 50
        
        // login / register button
        registerBtn.frame = CGRectMake(74, targetY, 226, 44)
        registerBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        registerBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        registerBtn.titleLabel?.textColor = UIColor.whiteColor()
        registerBtn.setTitle("Register", forState: UIControlState.Normal)
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
        if (textField == workEmailField) {
            passwordField.becomeFirstResponder()
        }
        if (textField == passwordField) {
            passwordConfirmField.becomeFirstResponder()
        }
        if (textField == passwordConfirmField) {
            firstNameField.becomeFirstResponder()
        }
        if (textField == firstNameField) {
            lastNameField.becomeFirstResponder()
        }
        if (textField == lastNameField) {
            register()
        }
        return true
    }
    func keyboardDone() {
        scroller.setContentOffset(CGPointMake(0, -20), animated: true)
        workEmailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        passwordConfirmField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
    }
    
    
    // MARK: methods
    func register() {
        
        if (!workEmailField.text.isEmpty && !passwordField.text.isEmpty && !passwordConfirmField.text.isEmpty && !firstNameField.text.isEmpty && !lastNameField.text.isEmpty) {
            
            // if password / confirm password match
            if (passwordField.text == passwordConfirmField.text) {
                
                startThinking()
                
                var parameters = parametersForTask("newEmailUser")
                parameters["firstName"] = firstNameField.text
                parameters["lastName"] = lastNameField.text
                parameters["email"] = workEmailField.text
                parameters["password"] = passwordField.text
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
                            
                            // save results to plist
                            let dbHelper = DatabaseHelper()
                            var mutDict = dbHelper.getUserData()
                            mutDict.setObject(JSON["userId"].stringValue, forKey: "knackkId")
                            mutDict.setObject(JSON["companyId"].stringValue, forKey: "companyId")
                            mutDict.setObject(JSON["companyName"].stringValue, forKey: "companyName")
                            mutDict.setObject(self.firstNameField.text, forKey: "firstName")
                            mutDict.setObject(self.lastNameField.text, forKey: "lastName")
                            mutDict.setObject(self.workEmailField.text, forKey: "email")
                            mutDict.setObject("email", forKey: "userType")
                            dbHelper.saveUserData(mutDict)
                            
                            let companyName = JSON["companyName"].stringValue
                            
                            // we don't have this company email domain in our database
                            if (companyName == "null" || companyName == "") {
                                let vc = SelectCompanyNameVC()
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            // we have it, let's verify
                            else {
                                let vc = VerifyWorkLocationVC(companyName: companyName)
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        } else {
                            println("failure")
                            // TODO: handle failure
                        }
                }
                
                
            // if password / confirm password do not match
            } else {
                let alert = UIAlertView(title: "Password Mismatch", message: "Password and Confirm\nPassword do not match.", delegate: nil, cancelButtonTitle: "Okay")
                alert.show()
                passwordField.text = ""
                passwordConfirmField.text = ""
            }
        
        // if not all fields entered
        } else {
            let alert = UIAlertView(title: "Missing Fields", message: "You must enter all fields to register.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
        
        
        //let vc = CompanyNameVC()
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}