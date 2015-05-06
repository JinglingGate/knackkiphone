//
//  SettingsVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 9/19/14.
//  Copyright (c) 2014 antiblank. All rights reserved.
//

import UIKit

class SettingsVC:MyFeedExtraBaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = "Settings"
        
        table.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
    }
    override func loadTableDataForTask(task: String, extra: String?) {
    //override func loadTableDataForAction(action:String) {
        
        tableObjects.removeAll(keepCapacity: false) //
        
        var array = ["Change Profile Picture", "Change Title", "Connect LinkedIn Account", "Notification Settings", "Feedback", "Logout"]
        
        let dbHelper = DatabaseHelper()
        if dbHelper.getUserObjectForKey("linkedInToken") != nil {
            array = ["Change Profile Picture", "Change Title", "Notification Settings", "Feedback", "Logout"]
        }
        
        for i in 0 ..< array.count {
            let obj = FeedObject(type: .Notification)
            obj.contentText = array[i]
            tableObjects.append(obj)
        }
        
        table.reloadData()
    }
}
