//
//  NotificationsVC.swift
//  Knackk
//
//  Created by wkasel on 8/4/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class NotificationsVC:MyFeedExtraBaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = "Notifications"
    }
    
    override func loadTableDataForTask(task: String, extra: String?) {
    //override func loadTableDataForAction(action:String) {
        
        println("task: \(task)")
        
        tableObjects.removeAll(keepCapacity: false)
        tableObjects.append(FeedObject(type: .Loading))
        table.reloadData()
        
        
        // get variables to send
        let dbHelper = DatabaseHelper()
        var parameters = parametersForTask("showNotifications") // showNotifications
        parameters["userId"] = dbHelper.getUserObjectForKey("knackkId")
        println("parameters: \(parameters)")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON NotificationsVC.swift - \(JSON)")
                println("ERROR \(error)")
                
                let status = JSON["status"].stringValue
                let thisError = JSON["error"].stringValue
                if (status == "success") {
                    if let notificationsArray = JSON["notifications"].array {
                        
                        self.tableObjects.removeAll(keepCapacity: false)
                        
                        // load saved notifications
                        for i in 0 ..< notificationsArray.count {
                            
                            // get variables
                            let thisNotification = notificationsArray[i]
                            let userId = thisNotification["fromUserId"].stringValue
                            let userName = thisNotification["fromUserName"].stringValue
                            let userImage = thisNotification["fromUserImageUrl"].stringValue
                            let type = thisNotification["notification_type"].stringValue
                            let postId = thisNotification["postId"].stringValue
                            
                            let obj = FeedObject(type: .Notification, username: userName, userImage:userImage)
                            obj.timeString = thisNotification["notificationTime"].stringValue
                            
                            // set type
                            if type == "Like" {
                                obj.contentText = "Liked your post."
                                obj.postId = postId
                            }
                            if type == "Comment" {
                                obj.contentText = "Commented on your post."
                                obj.postId = postId
                            }
                            if type == "Tag" {
                                obj.contentText = "Tagged you in a post."
                                obj.postId = postId
                            }
                            if type == "Follow" {
                                obj.contentText = "Followed you."
                                obj.userId = userId
                            }
                            
                            self.tableObjects.append(obj)
                        }
                        self.table.reloadData()
                    }
                } else {
                    let alert = UIAlertView(title: "Could Not Load Notifications", message: "Failed to load Notifications\n\nPlease try again later.", delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
        }
    }
}