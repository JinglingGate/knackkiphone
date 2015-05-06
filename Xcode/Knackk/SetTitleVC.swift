//
//  SetTitleVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 1/12/15.
//  Copyright (c) 2015 antiblank. All rights reserved.
//

import UIKit

class SetTitleVC:MyFeedExtraBaseVC, UITextFieldDelegate {
    
    var titleField = UITextField()
    let saveBtn = UIButton()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = "Set Title"
        
        table.removeFromSuperview()
        
        self.view.backgroundColor = knackkOrange
        
        // get current title
        let dbHelper = DatabaseHelper()
        let title = dbHelper.getUserObjectForKey("title")
        
        // company name
        let titleFieldBg = UIImageView(frame: CGRectMake(20, 74, 280, 42))
        titleFieldBg.image = UIImage(named: "TextField")
        self.view.addSubview(titleFieldBg)
        titleField.frame = CGRectMake(40, 79, 240, 32)
        titleField.delegate = self
        titleField.font = UIFont(name: "Verdana", size: 18)
        titleField.textColor = UIColor.darkGrayColor()
        titleField.placeholder = "Your Title"
        if title != nil {
            titleField.text = title!
        }
        titleField.userInteractionEnabled = true
        titleField.returnKeyType = UIReturnKeyType.Go
        titleField.autocorrectionType = UITextAutocorrectionType.No
        titleField.becomeFirstResponder()
        self.view.addSubview(titleField)
        
        // next button
        saveBtn.frame = CGRectMake(20, 136, 280, 44)
        saveBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        saveBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        saveBtn.titleLabel?.textColor = UIColor.whiteColor()
        saveBtn.setTitle("Save", forState: UIControlState.Normal)
        saveBtn.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveBtn)
        
        // activity indicator
        activityIndicator.center = CGPointMake(saveBtn.frame.size.width - 25, 22)
        activityIndicator.hidesWhenStopped = true
        saveBtn.addSubview(activityIndicator)
    }
    
    
    
    // MARK: methods
    func save() {
        
        if (!titleField.text.isEmpty) {
            
            startThinking()
            titleField.resignFirstResponder()
            
            // query list of users
            var parameters = parametersForTask("setTitle")
            parameters["title"] = titleField.text
            
            println("paramters: \(parameters)")
            
            // send request to server
            request(.POST, apiURL, parameters: parameters)
                
                .responseSwiftyJSON { (request, response, JSON, error) in
                    println("JSON \(JSON)")
                    
                    self.stopThinking()
                    
                    let status = JSON["status"].stringValue
                    if (status == "success") {
                        
                        // save results to plist
                        let dbHelper = DatabaseHelper()
                        var mutDict = dbHelper.getUserData()
                        mutDict.setObject(JSON["userTile"].stringValue, forKey: "title")
                        dbHelper.saveUserData(mutDict)
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    } else {
                        let message = JSON["message"].stringValue
                        println("error: \(message)")
                        let alert = UIAlertView(title: "Error", message: "Your title could not be updated at this time.", delegate: nil, cancelButtonTitle: "Okay")
                        alert.show()
                    }
            }
        } else {
            let alert = UIAlertView(title: "Missing Fields", message: "You must enter a username and password to login or register.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
    }
    func startThinking() {
        // show indicator, disable buttons
        activityIndicator.startAnimating()
        titleField.enabled = false
        saveBtn.enabled = false
    }
    func stopThinking() {
        // hide indicator, enable buttons
        activityIndicator.stopAnimating()
        titleField.enabled = true
        saveBtn.enabled = true
    }
}