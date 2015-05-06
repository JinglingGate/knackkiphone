//
//  MyFeedExtraBaseVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 9/19/14.
//  Copyright (c) 2014 antiblank. All rights reserved.
//

import UIKit
import MessageUI

class MyFeedExtraBaseVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MFMailComposeViewControllerDelegate {
    
    var parent:MyFeedBaseVC?
    
    let navBG = UIView()
    var backBtn = UIButton()
    var titleLbl = UILabel()
    
    var segmentArray:NSArray?
    var segmentControl:UISegmentedControl?
    var shouldShowSearchBar = Bool()
    let searchBar = UISearchBar()
    
    var table = UITableView()
    var tableObjects:[FeedObject] = Array()
    var originalTableObjectsFromServer:[FeedObject] = Array()
    var startingTableHeight:CGFloat = 310.0 - 44
    
    let imageCacheManager = ImageCacheManager()
    
    convenience init(segment:NSArray?, showSearchBar:Bool, parent:MyFeedBaseVC) {
        self.init()
        if (segment != nil) {
            segmentArray = segment
        }
        self.parent = parent
        shouldShowSearchBar = showSearchBar;
    }
    convenience init(segment:NSArray?, showSearchBar:Bool) {
        self.init()
        if (segment != nil) {
            segmentArray = segment
        }
        shouldShowSearchBar = showSearchBar;
    }
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.view.backgroundColor = knackkOrange
        if (self.respondsToSelector("edgesForExtendedLayout")) {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        
        // add nav bar
        navBG.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        navBG.backgroundColor = knackkOrange
        self.view.addSubview(navBG)
        
        // add notifications button
        backBtn.frame = CGRectMake(-3, 17, 44, 44)
        backBtn.backgroundColor = knackkOrange
        backBtn.setBackgroundImage(UIImage(named: "backNavBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        navBG.addSubview(backBtn)
        
        // title label
        titleLbl.frame = CGRectMake(50, 20, 220, 44)
        titleLbl.backgroundColor = knackkOrange
        titleLbl.textColor = UIColor.whiteColor()
        titleLbl.font = UIFont(name: "Verdana", size: 18)
        titleLbl.textAlignment = NSTextAlignment.Center
        titleLbl.text = "TITLE"
        navBG.addSubview(titleLbl)
        
        
        // load table data
        if (segmentArray != nil) {
            loadTableDataForTask(segmentArray![0] as String, extra: nil)
            //loadTableDataForAction(segmentArray![0] as String)
        } else {
            loadTableDataForTask("All", extra: nil)
            //loadTableDataForAction("All")
        }
        
        // table
        table.frame = CGRectMake(0, 64, 320, screenHeight - 64)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = knackkLightGray
        table.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(table)
        
        // add segmented array
        if (segmentArray != nil) {
            navBG.frame.size.height += 35
            table.frame.origin.y += 35
            table.frame.size.height -= 35
            segmentControl = UISegmentedControl(items: segmentArray)
            segmentControl!.frame = CGRectMake(5, 64, 310, 30)
            segmentControl!.tintColor = UIColor.whiteColor()
            segmentControl!.selectedSegmentIndex = 0
            segmentControl!.addTarget(self, action: "segmentUpdate:", forControlEvents: UIControlEvents.ValueChanged)
            navBG.addSubview(segmentControl!)
        }
        
        if (shouldShowSearchBar) {
            // search bar
            navBG.frame.size.height += 44
            table.frame.origin.y += 44
            table.frame.size.height -= 44
            searchBar.frame = CGRectMake(0, navBG.frame.size.height-44, 320, 44)
            searchBar.delegate = self
            searchBar.placeholder = "Search for people you know"
            searchBar.inputAccessoryView = KeyboardBar(parent: self)
            navBG.addSubview(searchBar)
        }
    }
    
    // MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: email methods
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailer = MFMailComposeViewController()
            mailer.mailComposeDelegate = self
            let toRecipients = NSArray(object: "support@knackk.com")
            mailer.setToRecipients(toRecipients)
            mailer.setSubject("knackk Feedback")
            mailer.modalPresentationStyle = UIModalPresentationStyle.PageSheet
            self.presentViewController(mailer, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "mailto:support@knackk.com")!)
        }
    }
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            println("Mail cancelled")
        case MFMailComposeResultSaved.value:
            println("Mail saved")
        case MFMailComposeResultSent.value:
            println("Mail sent")
        case MFMailComposeResultFailed.value:
            println("Mail sent failure: \(error.localizedDescription)")
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: segment methods
    func segmentUpdate(sender:UISegmentedControl) {
        loadTableDataForTask(sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!, extra: nil)
        //loadTableDataForAction(sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!)
        table.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    
    // MARK: search bar functions
    func searchBarShouldBeginEditing(searchBar: UISearchBar!) -> Bool {
        
        println("search began")
        
        startingTableHeight = table.frame.size.height
        UIView.animateWithDuration(0.3, animations: {
            self.table.frame.size.height = screenHeight - self.table.frame.origin.y - 216-44
        })
        
        return true
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        tableObjects.removeAll(keepCapacity: false)
        for feedObj in originalTableObjectsFromServer {
            if (feedObj.username!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || searchText.isEmpty) {
                self.tableObjects.append(feedObj)
            }
        }
        table.reloadData()
    }
    func keyboardDone() {
        self.table.frame.size.height = self.startingTableHeight
        self.view.endEditing(true)
    }
    
    
    // MARK: table methods
    func loadTableDataForTask(task:String, extra:String?) {
        // subclass method
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableObjects.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // get feed object
        let obj:FeedObject = tableObjects[indexPath.row]
        
        switch (obj.type) {
        case .Separator:
            let cell = UITableViewCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = UIColor.clearColor()
            return cell
        /*case .UserPost:
            let cell = UserPostCell(style: UITableViewCellStyle.Default, reuseIdentifier: "userPost")
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!) }
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            if (obj.timeString != nil) { cell.setTimeAgo(obj.timeString!) }
            if (obj.contentText != nil) { cell.setContentText( obj.contentText!) }
            cell.setFollowBtn(true)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell*/
        /*case .UserComment:
            let cell = UserCommentCell(style: UITableViewCellStyle.Default, reuseIdentifier: "userComment")
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!) }
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            if (obj.timeString != nil) { cell.setTimeAgo(obj.timeString!) }
            if (obj.contentText != nil) { cell.setContentText(obj.contentText!) }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell*/
        case .Notification:
            let cell = NotificationCell(style: UITableViewCellStyle.Default, reuseIdentifier: "notification", parent:self)
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!) }
            if (obj.username != nil) { cell.setUserNameText(obj.username!) }
            if (obj.contentText != nil) { cell.setNotificationText(obj.contentText!) }
            if (obj.timeString != nil) { cell.setTimeAgo(obj.timeString!) }
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            return cell
        case .NotificationSetting:
            let cell = NotificationSettingCell(style: UITableViewCellStyle.Default, reuseIdentifier: "notificationSettings")
            if (obj.contentText != nil) { cell.setNotificationText(obj.contentText!) }
            cell.setSwitchState(obj.isEnabled)
            
            obj.parentExtra = self
            obj.cellIndex = indexPath.row
            cell.feedObj = obj
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case .Instructions:
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Instructions")
            cell.backgroundColor = knackkOrange
            if (obj.contentText != nil) {
                cell.textLabel?.text = obj.contentText
                cell.textLabel?.font = UIFont(name: "Verdana", size: 15)
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.textLabel?.numberOfLines = 0
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case .SearchBar:
            let cell = SearchBarCell(style: UITableViewCellStyle.Default, reuseIdentifier: "searchBar")
            cell.configureCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case .FollowCoworker:
            let cell = FollowCoworkerCell(style: UITableViewCellStyle.Default, reuseIdentifier: "followCoworker")
            cell.feedObj = obj
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!, cacheManager:imageCacheManager) }
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            if (obj.userId != nil) { cell.followerId = obj.userId }
            if (obj.userIdToFollow != nil) { cell.leaderId = obj.userIdToFollow }
            if (obj.userHasFollowed) { cell.setFollowingButton(obj.userHasFollowed) }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        default:
            let cell = UITableViewCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let obj = tableObjects[indexPath.row]
        
        
        // if notification selected from notifications page
        if obj.type == .Notification {
            
            println("postId: \(obj.postId), userId: \(obj.userId)")
            
            if obj.postId != nil { // show post
                let vc = LeaveCommentVC(parent: self.parent, tableObjs: [], postId: obj.postId!, showKeyboard:false)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            if obj.userId != nil { // show profile of follower
                let vc = ShowProfileVC(segment: nil, fetchCoworkers: false, navBarType: "child", userName: obj.username!, userImageUrl: obj.userImage!)
                vc.loadTableDataForTask("showProfile", extra: obj.userId!)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
        
        
        // SETTINGS PAGE ----------
        
        // Change Profile Picture
        if (obj.contentText == "Change Profile Picture") {
            let vc = UploadProfilePicVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        // Change Title
        if (obj.contentText == "Change Title") {
            let vc = SetTitleVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        // Connect LinkedIn Account
        if (obj.contentText == "Connect LinkedIn Account") {
            let dbHelper = DatabaseHelper()
            let knackkId = dbHelper.getUserObjectForKey("knackkId")!
            let urlString = "https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=75558rdvj6bf2g&scope=r_fullprofile%20r_emailaddress%20r_network%20w_messages&state=changemelater&redirect_uri=http://knackk-server.herokuapp.com/oauth2callback?userId=\(knackkId)"
            println(urlString)
            UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
        }
        // Notification Settings
        if (obj.contentText == "Notification Settings") {
            let vc = SetNotificationSettingsVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        // Feedback
        if (obj.contentText == "Feedback") {
            sendEmail()
        }
        // Logout
        if (obj.contentText == "Logout") {
            
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
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let obj:FeedObject = tableObjects[indexPath.row]
        return obj.height
    }
}