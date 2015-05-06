//
//  OnboardingErrorVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 2/2/15.
//  Copyright (c) 2015 antiblank. All rights reserved.
//

import UIKit

class OnboardingErrorVC: MyViewController, UITextFieldDelegate, UITextViewDelegate {
    
    let workEmailField = UITextField()
    let saveBtn = UIButton()
    
    var inputTextShell = UIView()
    let inputText = UITextView()
    let inputTextBorder = UIImageView()
    let placeHolderTextView = UITextView()
    let ticketBtn = UIButton()
    let backBtn = UIButton()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var targetY = screenHeight - screenHeight + 20
        
        // instructions label
        let instructionsLbl = UILabel(frame: CGRectMake(20, targetY-10, 280, 160)) // y = ( fontSize + lineHeight + 2 ) * numLines
        instructionsLbl.font = UIFont(name: "Verdana", size: 16)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.numberOfLines = 0
        // add text and number of lines
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        var attrString = NSMutableAttributedString(string: "According to our system, your email address doesn't match the company of record. If you feel this is an error, please submit a ticket below. Otherwise, you may edit your email address below.")
        //var attrString = NSMutableAttributedString(string: "According to our system, your email address doesn't match the company of record. If you feel this is an error, please submit a ticket below. Otherwise, you may go back and edit your email address.")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        instructionsLbl.attributedText = attrString
        scroller.addSubview(instructionsLbl)
        targetY += 170
        
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
        let dbHelper = DatabaseHelper()
        workEmailField.text = dbHelper.getUserObjectForKey("email")
        workEmailField.userInteractionEnabled = true
        workEmailField.returnKeyType = UIReturnKeyType.Next
        workEmailField.keyboardType = UIKeyboardType.EmailAddress
        workEmailField.autocorrectionType = UITextAutocorrectionType.No
        workEmailField.autocapitalizationType = UITextAutocapitalizationType.None
        workEmailField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(workEmailField)
        targetY += 50
        
        // save button
        saveBtn.frame = CGRectMake(20, targetY, 280, 44)
        saveBtn.setBackgroundImage(buttonImage(CGSizeMake(280, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        saveBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        saveBtn.titleLabel?.textColor = UIColor.whiteColor()
        saveBtn.setTitle("Save", forState: UIControlState.Normal)
        saveBtn.addTarget(self, action: "saveAction", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(saveBtn)
        targetY += 59
        
        // activity indicator
        activityIndicator.center = CGPointMake(saveBtn.frame.size.width - 25, 22)
        activityIndicator.hidesWhenStopped = true
        saveBtn.addSubview(activityIndicator)
        
        
        
        
        // INPUT TEXT
        // shell
        inputTextShell = UIView(frame: CGRectMake(0, targetY, 320, 200))
        inputTextShell.backgroundColor = knackkOrange
        scroller.addSubview(inputTextShell)
        // top border
        let topBorder = UIView(frame: CGRectMake(0, 0, 320, 1))
        topBorder.backgroundColor = knackkLightOrange
        inputTextShell.addSubview(topBorder)
        // text background border
        inputTextBorder.frame = CGRectMake(20, 15, self.view.frame.size.width - 40, 160)
        inputTextBorder.image = buttonImage(inputTextBorder.frame.size, 3, 1, UIColor(white: 0.9, alpha: 1), UIColor.whiteColor())
        inputTextShell.addSubview(inputTextBorder)
        // input text
        inputText.frame = inputTextBorder.frame
        inputText.frame.origin.x += 4
        inputText.frame.size.width -= 8
        inputText.delegate = self
        inputText.font = UIFont(name: "Verdana", size: 14)
        inputText.textColor = UIColor(white: 0.32, alpha: 1)
        inputText.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0)
        inputText.backgroundColor = UIColor.clearColor()
        inputText.inputAccessoryView = KeyboardBar(parent:self)
        inputTextShell.addSubview(inputText)
        // place holder text view
        placeHolderTextView.frame = inputText.frame
        placeHolderTextView.userInteractionEnabled = false
        placeHolderTextView.font = UIFont(name: "Verdana", size: 14)
        placeHolderTextView.textColor = UIColor(white: 0.5, alpha: 1)
        placeHolderTextView.backgroundColor = UIColor.clearColor()
        placeHolderTextView.text = "Please submit an error ticket, and our user support team will get back to you as soon as possible."
        inputTextShell.addSubview(placeHolderTextView)
        targetY += 185
        
        
        // save button
        ticketBtn.frame = CGRectMake(74, targetY, 226, 44)//(20, targetY, 280, 44)
        ticketBtn.setBackgroundImage(buttonImage(CGSizeMake(280, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        ticketBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        ticketBtn.titleLabel?.textColor = UIColor.whiteColor()
        ticketBtn.setTitle("Submit Ticket", forState: UIControlState.Normal)
        ticketBtn.addTarget(self, action: "ticketAction", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(ticketBtn)
        
        // back button
        backBtn.frame = CGRectMake(20, targetY, 44, 44)
        backBtn.setBackgroundImage(UIImage(named: "backBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(backBtn)
    }
    
    //MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: text field methods
    func textFieldDidBeginEditing(textField: UITextField!) {
        if (self.view.frame.size.height > 500) {
            scroller.setContentOffset(CGPointMake(0, 8), animated: true)
        } else {
            scroller.setContentOffset(CGPointMake(0, 86), animated: true)
        }
    }
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if (textField == workEmailField) {
            saveAction()
        }
        return true
    }
    func keyboardDone() {
        scroller.setContentOffset(CGPointMake(0, -20), animated: true)
        workEmailField.resignFirstResponder()
        inputText.resignFirstResponder()
    }
    
    
    // MARK: text field methods
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        scroller.setContentOffset(CGPointMake(0, inputTextShell.frame.origin.y-20), animated: true)
        return true
    }
    func textViewDidChange(textView: UITextView!) {
        if (textView == inputText) {
            if inputText.text.utf16Count > 0 {
                placeHolderTextView.hidden = true
            } else {
                placeHolderTextView.hidden = false
            }
        }
    }
    
    
    // MARK: methods
    func startThinking() {
        // show indicator, disable buttons
        activityIndicator.startAnimating()
        saveBtn.enabled = false
        inputText.userInteractionEnabled = false
        ticketBtn.enabled = false
        backBtn.enabled = false
    }
    func stopThinking() {
        // hide indicator, enable buttons
        activityIndicator.stopAnimating()
        saveBtn.enabled = true
        inputText.userInteractionEnabled = true
        ticketBtn.enabled = true
        backBtn.enabled = true
    }
    func saveAction () {
        
        keyboardDone()
        
        let dbHelper = DatabaseHelper()
        let existingWorkEmail = dbHelper.getUserObjectForKey("email")
        
        if workEmailField.text.isEmpty {
            let alert = UIAlertView(title: "Work Email Required", message: "You must enter an email address.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        } else if (workEmailField.text == existingWorkEmail) {
            let alert = UIAlertView(title: "Matching Work Email", message: "You have entered the same email address. Please correct your email address or submit a trouble ticket.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        } else {
            
            var parameters = parametersForTask("confirmLinkedInWorkEmail")
            parameters["email"] = workEmailField.text
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
                        mutDict.setObject(self.workEmailField.text, forKey: "email") // workEmail
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
    }
    func ticketAction() {
        
        keyboardDone()
        
        if inputText.text.isEmpty {
            let alert = UIAlertView(title: "Trouble Ticket Empty", message: "Please explain why you are submitting a trouble ticket.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        } else {
            
            startThinking()
            
            // query list of users
            let dbHelper = DatabaseHelper()
            let userDict = dbHelper.getUserData()
            var parameters = parametersForTask("submitTroubleTicket")
            parameters["userId"] = userDict["knackkId"]
            parameters["userEmail"] = userDict["email"]
            parameters["ticketText"] = inputText.text
            
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
                        
                        let dbHelper = DatabaseHelper()
                        dbHelper.logoutUser()
                        
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        
                        let alert = UIAlertView(title: "Ticket Submitted", message: "\nYour ticket has been submitted.\n\nWe will email you as soon as possible.", delegate: nil, cancelButtonTitle: "Okay")
                        alert.show()
                        
                    } else {
                        let message = JSON["message"].stringValue
                        println("failure, message: \(message)")
                        
                        let alert = UIAlertView(title: "Error Submitting Ticket", message: "Your ticket could not be submitted at this time, please try again later. If the problem persists, please email us at support@knackk.com. Thank you!", delegate: nil, cancelButtonTitle: "Okay")
                        alert.show()
                    }
            }
        }
    }


    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}