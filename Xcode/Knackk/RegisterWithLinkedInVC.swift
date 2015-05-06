//
//  RegisterWithLinkedInVC.swift
//  Knackk
//
//  Created by wkasel on 7/29/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class RegisterWithLinkedInVC: MyViewController, UITextFieldDelegate {
    
    let workEmailField = UITextField()
    let nextBtn = UIButton()
    let backBtn = UIButton()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dbHelper = DatabaseHelper()
        
        var targetY = screenHeight - screenHeight + 20
        
        // instructions label
        let instructionsLbl = UILabel(frame: CGRectMake(20, targetY-10, 280, 78)) // y = ( fontSize + lineHeight + 2 ) * numLines
        instructionsLbl.font = UIFont(name: "Verdana", size: 16)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.numberOfLines = 0
        // add text and number of lines
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        var attrString = NSMutableAttributedString(string: "We found the following work\nemail associated with this\naccount:")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        instructionsLbl.attributedText = attrString
        scroller.addSubview(instructionsLbl)
        targetY += 108
        
        // instructions label
        let workEmailLbl = UILabel(frame: CGRectMake(20, targetY-10, 280, 20))
        workEmailLbl.font = UIFont(name: "Verdana-Bold", size: 16)
        workEmailLbl.textColor = knackkTextBlue
        workEmailLbl.text = dbHelper.getUserObjectForKey("linkedInEmail")
        scroller.addSubview(workEmailLbl)
        targetY += 50
        
        // instructions label
        let moreInstructionsLbl = UILabel(frame: CGRectMake(20, targetY-10, 280, 104)) // y = ( fontSize + lineHeight + 2 ) * numLines
        moreInstructionsLbl.font = UIFont(name: "Verdana", size: 15)
        moreInstructionsLbl.textColor = UIColor.whiteColor()
        moreInstructionsLbl.numberOfLines = 0
        // add text and number of lines
        var paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.lineSpacing = 9
        var attrString2 = NSMutableAttributedString(string: "If this is not your work email,\nplease provide your work email\nbelow so we can connect you\nwith your private company network.")
        attrString2.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle2, range:NSMakeRange(0, attrString2.length))
        moreInstructionsLbl.attributedText = attrString2
        scroller.addSubview(moreInstructionsLbl)
        targetY += 118
        
        
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
        workEmailField.returnKeyType = UIReturnKeyType.Go
        workEmailField.keyboardType = UIKeyboardType.EmailAddress
        workEmailField.autocorrectionType = UITextAutocorrectionType.No
        workEmailField.autocapitalizationType = UITextAutocapitalizationType.None
        workEmailField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(workEmailField)
        targetY += 60
        
        // next button
        nextBtn.frame = CGRectMake(74, targetY, 226, 44) // 74, targetY, 226, 44
        nextBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        nextBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        nextBtn.titleLabel?.textColor = UIColor.whiteColor()
        nextBtn.setTitle("Next", forState: UIControlState.Normal)
        nextBtn.addTarget(self, action: "next", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(nextBtn)
        
        // activity indicator
        activityIndicator.center = CGPointMake(nextBtn.frame.size.width - 25, 22)
        activityIndicator.hidesWhenStopped = true
        nextBtn.addSubview(activityIndicator)
        
        // back button
        let backBtn = UIButton(frame: CGRectMake(20, targetY, 44, 44))
        backBtn.setBackgroundImage(UIImage(named: "backBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(backBtn)
        
    }
    
    
    // MARK: methods
    func popNav() {
        
        // get variables to send
        let dbHelper = DatabaseHelper()
        var parameters = parametersForTask("logOut")
        parameters["userId"] = dbHelper.getUserObjectForKey("knackkId")
        println("parameters: \(parameters)")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON \(JSON)")
                println("ERROR \(error)")
                
                let status = JSON["status"].stringValue
                let thisError = JSON["error"].stringValue
                if (status == "success" || thisError == "You must log in to access that information") {
                    
                    // logout user in app as well
                    dbHelper.logoutUser()
                    println("logout, userdict: \(dbHelper.getUserData())")
                    
                    // push login screen
                    let vc = LoginVC()
                    let nav = self.navigationController
                    nav?.setViewControllers([vc, self], animated: false)
                    nav?.popToRootViewControllerAnimated(true)
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    println("failure")
                    // TODO: handle failure (unlike post, show error)
                }
        }
    }
    func startThinking() {
        // show indicator, disable buttons
        activityIndicator.startAnimating()
        nextBtn.enabled = false
    }
    func stopThinking() {
        // hide indicator, enable buttons
        activityIndicator.stopAnimating()
        nextBtn.enabled = true
    }
    
    
    // MARK: text field methods
    func textFieldDidBeginEditing(textField: UITextField!) {
        scroller.setContentOffset(CGPointMake(0, 138), animated: true)
    }
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if (textField == workEmailField) {
            next()
        }
        return true
    }
    func keyboardDone() {
        scroller.setContentOffset(CGPointMake(0, -20), animated: true)
        workEmailField.resignFirstResponder()
    }
    
    
    // MARK: methods
    func next() {
        
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        
        var emailString = userDict["linkedInEmail"] as String
        if (!workEmailField.text.isEmpty) {
            emailString = workEmailField.text
        }
        
        var parameters = parametersForTask("confirmLinkedInWorkEmail")
        parameters["email"] = emailString
        parameters["userId"] = (userDict["knackkId"] as String)
        println("PARAMETERS \(parameters)")
        
        startThinking()
        
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
                    mutDict.setObject("false", forKey: "userMustSetWorkEmail")
                    mutDict.setObject(emailString, forKey: "email") // workEmail
                    mutDict.setObject(JSON["companyName"].stringValue, forKey: "companyName") // workEmail
                    mutDict.setObject(JSON["companyId"].stringValue, forKey: "companyId") // workEmail
                    dbHelper.saveUserData(mutDict)
                    
                    let companyName = JSON["companyName"].stringValue
                    if (companyName == "null" || companyName == "") {
                        let vc = SelectCompanyNameVC()
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = VerifyWorkLocationVC(companyName: JSON["companyName"].stringValue)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    var errorMessage = "Undefined error"
                    if let message = JSON["message"].array {
                        if message[0].stringValue == "Email has already been taken" {
                            errorMessage = "This email address is already in use by another knackk account. Please enter a different email."
                        }
                    }
                    let alert = UIAlertView(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
        }
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}