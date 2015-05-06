//
//  RegisterCompanyVC.swift
//  Knackk
//
//  Created by wkasel on 7/29/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class RegisterCompanyVC: MyViewController, UITextFieldDelegate {
    
    let companyNameField = UITextField()
    let companyUrlField = UITextField()
    let industryKeywordsField = UITextField()
    let companySizeField = UITextField()
    let tickerSymbolField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var targetY = screenHeight - screenHeight + 20
        
        // instructions
        let welcomeLbl = UILabel(frame: CGRectMake(20, targetY-10, 280, 78)) // y = ( fontSize + lineHeight + 2 ) * numLines
        welcomeLbl.font = UIFont(name: "Verdana", size: 15)
        welcomeLbl.textColor = UIColor.whiteColor()
        welcomeLbl.numberOfLines = 0
        // add text and number of lines
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        var attrString = NSMutableAttributedString(string: "Congrats! You are the 1st user from your company.  Please help us set up your company's knackk feed:")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        welcomeLbl.attributedText = attrString
        scroller.addSubview(welcomeLbl)
        targetY += 78
        
        
        // company name
        let companyNameBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        companyNameBg.image = UIImage(named: "TextField")
        scroller.addSubview(companyNameBg)
        targetY += 5
        companyNameField.frame = CGRectMake(40, targetY, 240, 32)
        companyNameField.delegate = self
        companyNameField.font = UIFont(name: "Verdana", size: 18)
        companyNameField.textColor = UIColor.darkGrayColor()
        companyNameField.placeholder = "Company Name"
        companyNameField.userInteractionEnabled = true
        companyNameField.returnKeyType = UIReturnKeyType.Next
        companyNameField.autocorrectionType = UITextAutocorrectionType.No
        companyNameField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(companyNameField)
        targetY += 50
        
        // company url
        let companyUrlBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        companyUrlBg.image = UIImage(named: "TextField")
        scroller.addSubview(companyUrlBg)
        targetY += 5
        companyUrlField.frame = CGRectMake(40, targetY, 240, 32)
        companyUrlField.delegate = self
        companyUrlField.font = UIFont(name: "Verdana", size: 18)
        companyUrlField.textColor = UIColor.darkGrayColor()
        companyUrlField.placeholder = "Company URL"
        companyUrlField.userInteractionEnabled = true
        companyUrlField.returnKeyType = UIReturnKeyType.Next
        companyUrlField.keyboardType = UIKeyboardType.URL
        companyUrlField.autocorrectionType = UITextAutocorrectionType.No
        companyUrlField.autocapitalizationType = UITextAutocapitalizationType.None
        companyUrlField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(companyUrlField)
        targetY += 50
        
        // industry keywords
        let industryKeywordsBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        industryKeywordsBg.image = UIImage(named: "TextField")
        scroller.addSubview(industryKeywordsBg)
        targetY += 5
        industryKeywordsField.frame = CGRectMake(40, targetY, 240, 32)
        industryKeywordsField.delegate = self
        industryKeywordsField.font = UIFont(name: "Verdana", size: 18)
        industryKeywordsField.textColor = UIColor.darkGrayColor()
        industryKeywordsField.placeholder = "Industry Keywords"
        industryKeywordsField.userInteractionEnabled = true
        industryKeywordsField.returnKeyType = UIReturnKeyType.Go
        industryKeywordsField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(industryKeywordsField)
        targetY += 36
        
        // instructions label
        let instructionsLbl = UILabel(frame: CGRectMake(40, targetY, 220, 24))
        instructionsLbl.font = UIFont(name: "Verdana", size: 13)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.text = "e.g., cloud computing, big data"
        scroller.addSubview(instructionsLbl)
        targetY += 35
        
        /*/ company size
        let companySizeBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        companySizeBg.image = UIImage(named: "TextField")
        scroller.addSubview(companySizeBg)
        targetY += 5
        companySizeField.frame = CGRectMake(40, targetY, 240, 32)
        companySizeField.delegate = self
        companySizeField.font = UIFont(name: "Verdana", size: 18)
        companySizeField.textColor = UIColor.darkGrayColor()
        companySizeField.placeholder = "Company Size (optional)"
        companySizeField.userInteractionEnabled = true
        companySizeField.returnKeyType = UIReturnKeyType.Next
        companySizeField.autocorrectionType = UITextAutocorrectionType.No
        companySizeField.autocapitalizationType = UITextAutocapitalizationType.None
        companySizeField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(companySizeField)
        targetY += 50
        
        // ticker symbol
        let tickerSymbolBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        tickerSymbolBg.image = UIImage(named: "TextField")
        scroller.addSubview(tickerSymbolBg)
        targetY += 5
        tickerSymbolField.frame = CGRectMake(40, targetY, 240, 32)
        tickerSymbolField.delegate = self
        tickerSymbolField.font = UIFont(name: "Verdana", size: 18)
        tickerSymbolField.textColor = UIColor.darkGrayColor()
        tickerSymbolField.placeholder = "Ticker Symbol (optional)"
        tickerSymbolField.userInteractionEnabled = true
        tickerSymbolField.returnKeyType = UIReturnKeyType.Go
        tickerSymbolField.autocorrectionType = UITextAutocorrectionType.No
        tickerSymbolField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        tickerSymbolField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(tickerSymbolField)
        targetY += 50*/
        
        // login / register button
        let loginRegisterBtn = UIButton(frame: CGRectMake(74, targetY, 226, 44))
        loginRegisterBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        loginRegisterBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        loginRegisterBtn.titleLabel?.textColor = UIColor.whiteColor()
        loginRegisterBtn.setTitle("Register", forState: UIControlState.Normal)
        loginRegisterBtn.addTarget(self, action: "register", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(loginRegisterBtn)
        
        // back button
        let backBtn = UIButton(frame: CGRectMake(20, targetY, 44, 44))
        backBtn.setBackgroundImage(UIImage(named: "backBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(backBtn)
    }
    
    
    // MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: text field methods
    func textFieldDidBeginEditing(textField: UITextField!) {
        scroller.contentInset = UIEdgeInsetsMake(20, 0, 260+35, 0)
        scroller.contentSize = CGSizeMake(320, 270)
        scroller.scrollEnabled = true
    }
    func textFieldDidEndEditing(textField: UITextField!) {
        scroller.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        scroller.setContentOffset(CGPointMake(0, -20), animated: false)
        scroller.scrollEnabled = false
    }
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if (textField == companyNameField) {
            companyUrlField.becomeFirstResponder()
        }
        if (textField == companyUrlField) {
            industryKeywordsField.becomeFirstResponder()
        }
        if (textField == industryKeywordsField) {
            register()
        }
        /*if (textField == companySizeField) {
            tickerSymbolField.becomeFirstResponder()
        }
        if (textField == tickerSymbolField) {
            register()
        }*/
        return true
    }
    func keyboardDone() {
        scroller.setContentOffset(CGPointMake(0, -20), animated: true)
        companyNameField.resignFirstResponder()
        companyUrlField.resignFirstResponder()
        industryKeywordsField.resignFirstResponder()
        companySizeField.resignFirstResponder()
        tickerSymbolField.resignFirstResponder()
    }
    
    
    // MARK: methods
    func register() {
        
        if (!companyNameField.text.isEmpty && !companyUrlField.text.isEmpty && !industryKeywordsField.text.isEmpty) {
            
            let dbHelper = DatabaseHelper()
            let email = dbHelper.getUserObjectForKey("email")
            let emailArray:Array = email!.componentsSeparatedByString("@")
            let emailSuffix = emailArray[1]
            
            
            var parameters = parametersForTask("newCompany")
            parameters["userId"] = dbHelper.getUserObjectForKey("knackkId")
            parameters["name"] = companyNameField.text
            parameters["website"] = companyUrlField.text
            parameters["emailSuffix"] = emailSuffix
            parameters["keyphrase1"] = industryKeywordsField.text
            println("PARAMETERS \(parameters)")
            
            // send request to server
            request(.POST, apiURL, parameters: parameters)
                
                .responseSwiftyJSON { (request, response, JSON, error) in
                    println("REQUEST \(request)")
                    println("RESPONSE \(response)")
                    println("JSON \(JSON)")
                    println("ERROR \(error)")
                    
                    let status = JSON["status"].stringValue
                    if (status == "success") {
                        
                        // save results to plist
                        var mutDict = dbHelper.getUserData()
                        mutDict.setObject(JSON["companyId"].stringValue, forKey: "companyId")
                        mutDict.setObject(self.companyNameField.text, forKey: "companyName")
                        dbHelper.saveUserData(mutDict)
                        
                        // skip follow, we just created this company!
                        let vc = ImportCoworkersLinkedInVC(isOnboarding: true)
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    } else {
                        println("failure")
                        // TODO: handle failure
                    }
            }
            
        // if not all fields entered
        } else {
            let alert = UIAlertView(title: "Missing Fields", message: "You must enter all fields to register your company.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}