//
//  SetNotificationSettingsVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 1/7/15.
//  Copyright (c) 2015 antiblank. All rights reserved.
//

import UIKit

class SetNotificationSettingsVC:MyFeedExtraBaseVC {
    
    let saveBtn = UIButton()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = "Notification Settings"
        titleLbl.frame.origin.x -= 10
        
        // add save button
        saveBtn.frame = CGRectMake(self.view.frame.size.width-60, 23, 60, 41)
        saveBtn.setBackgroundImage(buttonImage(CGSizeMake(280, 44), 3, 1, knackkOrange, knackkOrange), forState: UIControlState.Normal)
        saveBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        saveBtn.titleLabel?.textColor = UIColor.whiteColor()
        saveBtn.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 15)
        saveBtn.setTitle("Save", forState: UIControlState.Normal)
        saveBtn.addTarget(self, action: "saveAction", forControlEvents: UIControlEvents.TouchUpInside)
        navBG.addSubview(saveBtn)
        
        // activity indicator
        activityIndicator.center = CGPointMake(saveBtn.frame.size.width/2, 22)
        activityIndicator.hidesWhenStopped = true
        saveBtn.addSubview(activityIndicator)
    }
    override func loadTableDataForTask(task: String, extra: String?) {
        
        tableObjects.removeAll(keepCapacity: false)
        
        let obj = FeedObject(type: .Instructions)
        obj.contentText = "Notify me when..."
        //obj.height = 64
        tableObjects.append(obj)
        
        let dbHelper = DatabaseHelper()
        let userDict = dbHelper.getUserData()
        let serverKeys = ["notificationSettingTagging", "notificationSettingComments", "notificationSettingLikes", "notificationSettingFollows"]
        
        let array = ["Somebody Tags Me in a Post", "Somebody Comments on my Post", "Somebody Likes my Post", "Somebody Follows Me"]
        for i in 0 ..< array.count {
            let obj = FeedObject(type: .NotificationSetting)
            obj.contentText = array[i]
            
            // load notification settings to userDict
            let boolString = userDict.objectForKey(serverKeys[i]) as NSString
            println("\(serverKeys[i]): \(boolString)")
            obj.isEnabled = boolString.isEqualToString("true") ? true : false
            
            tableObjects.append(obj)
        }
        
        table.reloadData()
    }
    
    
    func startThinking() {
        // show indicator, disable buttons
        activityIndicator.startAnimating()
        backBtn.enabled = false
        saveBtn.enabled = false
        table.userInteractionEnabled = false
    }
    func stopThinking() {
        // hide indicator, enable buttons
        activityIndicator.stopAnimating()
        backBtn.enabled = true
        saveBtn.enabled = true
        table.userInteractionEnabled = true
    }
    func saveAction() {
        
        startThinking()
        
        // get variables to send
        let dbHelper = DatabaseHelper()
        var parameters = parametersForTask("setNotificationSettings")
        let serverKeys = ["tagging", "comments", "likes", "follows"]
        for i in 0..<serverKeys.count {
            let obj = tableObjects[i+1]
            let thisBool = obj.isEnabled ? "true" : "false"
            parameters[serverKeys[i]] = obj.isEnabled // thisBool
        }
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
                    
                    self.stopThinking()
                    
                    // save notification settings to userDict
                    let dbHelper = DatabaseHelper()
                    let userDict = dbHelper.getUserData()
                    let serverKeys = ["notificationSettingTagging", "notificationSettingComments", "notificationSettingLikes", "notificationSettingFollows"]
                    for i in 0..<serverKeys.count {
                        let obj = self.tableObjects[i+1]
                        let boolString = obj.isEnabled ? "true" : "false"
                        userDict.setObject(boolString, forKey: serverKeys[i])
                    }
                    dbHelper.saveUserData(userDict)
                    
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    self.stopThinking()
                    let alert = UIAlertView(title: "Could not save Settings", message: "Notification settings could\nnot be saved at this time.\n\nPlease try again later.", delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
        }
    }
}
