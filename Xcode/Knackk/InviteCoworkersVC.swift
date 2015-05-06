//
//  InviteCoworkersVC.swift
//  Knackk
//
//  Created by wkasel on 8/4/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class InviteCoworkersVC:MyFeedExtraBaseVC {
    
    var linkedInBtn:UIButton?
    var addressBookBtn:UIButton?
    var manualBtn:UIButton?
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = "Follow Co-workers"
    }
    
    override func loadTableDataForTask(task: String, extra: String?) {
    //override func loadTableDataForAction(action:String) {
        
        println("task: \(task)")
        
        tableObjects.removeAll(keepCapacity: false)
        
        if (task=="Follow") {
            
            titleLbl.text = "Follow Co-workers"
            
            if (linkedInBtn != nil) {
                linkedInBtn!.hidden = true
                addressBookBtn!.hidden = true
                manualBtn!.hidden = true
            }
            
            table.frame.origin.y += 44
            table.frame.size.height -= 44
            
            
            let obj = FeedObject(type: .Instructions)
            obj.contentText = "Follow co-workers on knackk to\nfilter news involving them:"
            obj.height = 64
            tableObjects.append(obj)
            table.reloadData()
            
            let dbHelper = DatabaseHelper()
            let userDict = dbHelper.getUserData()
            let myKnackkId = userDict.objectForKey("knackkId") as String
            
            // query list of users
            var parameters = parametersForTask("listUsers")
            parameters["companyId"] = (userDict.objectForKey("companyId") as String)
            
            println("paramters: \(parameters)")
            
            // send request to server
            request(.POST, apiURL, parameters: parameters)
                
                .responseSwiftyJSON { (request, response, JSON, error) in
                    println("REQUEST \(request)")
                    println("RESPONSE \(response)")
                    println("JSON \(JSON)")
                    println("ERROR \(error)")
                    
                    let status = JSON["status"].stringValue
                    if (status == "success") {
                        
                        if let rawUsersArray = JSON["users"].array {
                            
                            for i in 0 ..< rawUsersArray.count {
                                
                                let thisUserArray = rawUsersArray[i]
                                if (thisUserArray["userId"].stringValue != myKnackkId) {
                                    let obj = FeedObject(type: .FollowCoworker, username: thisUserArray["userName"].stringValue, userImage: thisUserArray["pictureUrl"].stringValue)
                                    obj.userId = myKnackkId
                                    obj.userIdToFollow = thisUserArray["userId"].stringValue
                                    let hasFollowed = thisUserArray["userHasFollowed"].stringValue == "true" ? true : false
                                    obj.userHasFollowed = hasFollowed
                                    self.tableObjects.append(obj)
                                    self.originalTableObjectsFromServer.append(obj)
                                }
                                
                            }
                            self.table.reloadData()
                        }
                        
                    } else {
                        println("failure")
                        // TODO: handle failure
                    }
            }
        }
        
        if (task=="Invite") {
            
            titleLbl.text = "Invite Co-workers"
            
            table.frame.origin.y -= 44
            table.frame.size.height += 44
            
            let obj = FeedObject(type: .Instructions)
            obj.contentText = "Invite co-workers to use knackk:"
            obj.height = 64
            tableObjects.append(obj)
            table.reloadData()
            
            
            if (linkedInBtn == nil) {
                // linked in button
                linkedInBtn = UIButton(frame: CGRectMake(20, 84, 280, 44))
                linkedInBtn!.setImage(UIImage(named: "ImportLinkedIn"), forState: UIControlState.Normal)
                linkedInBtn!.addTarget(self, action: "linkedInAction", forControlEvents: UIControlEvents.TouchUpInside)
                table.addSubview(linkedInBtn!)
                
                // address book button
                addressBookBtn = UIButton(frame: CGRectMake(20, 148, 280, 44))
                addressBookBtn!.setBackgroundImage(UIImage(named: "ImportAddressBook"), forState: UIControlState.Normal)
                addressBookBtn!.setTitleColor(linkedInBlue, forState: UIControlState.Normal)
                addressBookBtn!.setTitle("Invite via Address Book", forState: UIControlState.Normal)
                addressBookBtn!.addTarget(self, action: "addressBookAction", forControlEvents: UIControlEvents.TouchUpInside)
                table.addSubview(addressBookBtn!)
                
                // activity indicator
                /*activityIndicator.center = CGPointMake(self.view.frame.size.width/2, 168 )
                activityIndicator.hidesWhenStopped = true
                table.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                activityIndicator.hidden = true*/
                
                
                // manual button button
                manualBtn = UIButton(frame: CGRectMake(20, 212, 280, 44))
                manualBtn!.setBackgroundImage(buttonImage(CGSizeMake(280, 44), 3, 1, knackkOrange, knackkOrange), forState: UIControlState.Normal)
                manualBtn!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                manualBtn!.setTitle("Invite by Manual Entry", forState: UIControlState.Normal)
                manualBtn!.addTarget(self, action: "manualAction", forControlEvents: UIControlEvents.TouchUpInside)
                table.addSubview(manualBtn!)
            } else {
                linkedInBtn!.hidden = false
                addressBookBtn!.hidden = false
                manualBtn!.hidden = false
            }
        }
    }
    func linkedInAction() {
        let dbHelper = DatabaseHelper()
        if dbHelper.getUserObjectForKey("linkedInToken") != nil {
            let vc = ImportCoworkersLinkedInVC()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            // TODO: connect to linked in
        }
    }
    func addressBookAction() {
        let vc = ImportCoworkersAddressBookVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func manualAction() {
        let vc = InviteManuallyVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}