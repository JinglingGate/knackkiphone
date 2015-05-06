//
//  MyFeedBaseVC.swift
//  Knackk
//
//  Created by wkasel on 8/4/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit
import CoreData

class MyFeedBaseVC:UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate {
    
    //var parent:MyFeedBaseVC?
    
    
    
    
    
    // NAV BAR ----------
    let navBG = UIView()
    var navBarType = String()
    
    // for navBarType = "feed"
    var notificationsBtn = UIButton()
    var inviteBtn = UIButton()
    var settingsBtn = UIButton()
    var segmentControl:UISegmentedControl?
    var segmentArray:NSArray?
    
    // for navBarType = "child"
    var navBackBtn = UIButton()
    var navTitleLbl = UILabel()
    
    
    var shouldPushNotificationList = false;
    
    var imageCacheManager = ImageCacheManager()
    var imageViewerShell:UIScrollView?
    var imageViewer:UIImageView?
    
    var companyUsersArray:[CompanyUsers]? // for tagging in posts
    
    // check if profile picture has changed.
    var firstLoad = true
    var myImageUrl:String?
    
    
    // load posts
    var canSubmitLoadRequest = false
    var loadPostsTask = "listPosts"
    var loadPostsExtra = "All"
    var loadPostsStart = 0
    var loadPostsCount = 25
    
    
    // table
    var table = UITableView()
    var tableObjects:[FeedObject] = Array()
    var currentlyPostingUserPostObject:FeedObject?
    var currentlyPostingUserPostCommentObject:FeedObject?
    //var thisUpdateStatusCell:UpdateStatusCell?
    
    var uploadImageProgressView:UIView?
    
    var feedObjectToFlag:FeedObject?
    
    convenience init(segment:NSArray?, fetchCoworkers:Bool, navBarType:String) { // , thisParent:MyFeedBaseVC
        self.init()
        if (segment != nil) {
            segmentArray = segment
        }
        if fetchCoworkers {
            syncCompanyUsersToCoreData()
        }
        self.navBarType = navBarType
        //self.parent = thisParent
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad {
            firstLoad = false
            
            // for first load, init imageCacheManager & load self image
            let dbHelper = DatabaseHelper()
            if let newImageUrl = dbHelper.getUserObjectForKey("userImageURL") {
                if newImageUrl != myImageUrl {
                    imageCacheManager = ImageCacheManager()
                    for obj in tableObjects {
                        if obj.userImage == myImageUrl {
                            obj.userImage = newImageUrl
                        }
                    }
                    myImageUrl = newImageUrl
                    table.reloadData()
                }
            }
            
        } else {
            
            // refresh user title
            if segmentControl?.selectedSegmentIndex == 2 {
                let dbHelper = DatabaseHelper()
                let obj = tableObjects[0]
                obj.userTitle = dbHelper.getUserObjectForKey("title")
                table.reloadData()
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // register for notifications
        let dbHelper = DatabaseHelper()
        if let isRegistered = dbHelper.getUserObjectForKey("hasAskedToRegisterNotifications") {
            if isRegistered == "false" {
                let delegate = UIApplication.sharedApplication().delegate as AppDelegate
                delegate.attemptToRegisterForPushNotifications()
            }
        }
        
        // push notification list (from push notification interation)
        if shouldPushNotificationList {
            shouldPushNotificationList = false
            let vc = NotificationsVC(segment: nil, showSearchBar:false, parent:self)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    override func viewDidLoad()  {
        super.viewDidLoad()
        
        println("---\nMyFeedBaseVC\n---")
        self.view.backgroundColor = knackkOrange
        if (self.respondsToSelector("edgesForExtendedLayout")) {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        
        // print image cache
        //imageCacheManager.printCache()
        
        
        let dbHelper = DatabaseHelper()
        myImageUrl = dbHelper.getUserObjectForKey("userImageURL")
        
        // add nav bar
        navBG.frame = CGRectMake(0, 0, 320, 64)
        navBG.backgroundColor = knackkOrange
        self.view.addSubview(navBG)
        
        if navBarType == "feed" {
            
            // add notifications button
            notificationsBtn.frame = CGRectMake(5, 17, 44, 44)
            notificationsBtn.backgroundColor = knackkOrange
            notificationsBtn.setBackgroundImage(UIImage(named: "notificationsBtn"), forState: UIControlState.Normal)
            notificationsBtn.setTitleColor(knackkOrange, forState: UIControlState.Normal)
            notificationsBtn.setTitle("0", forState: UIControlState.Normal)
            notificationsBtn.titleLabel?.font = UIFont(name: "Verdana", size: 12)
            notificationsBtn.titleLabel?.textAlignment = NSTextAlignment.Center
            notificationsBtn.addTarget(self, action: "notificationsAction", forControlEvents: UIControlEvents.TouchUpInside)
            navBG.addSubview(notificationsBtn)
            
            // invite button
            inviteBtn.frame = CGRectMake(310-39-39, 17, 44, 44) // 310-39-39-39
            inviteBtn.setBackgroundImage(UIImage(named: "FollowBtn"), forState: UIControlState.Normal)
            inviteBtn.addTarget(self, action: "inviteAction", forControlEvents: UIControlEvents.TouchUpInside)
            navBG.addSubview(inviteBtn)
            
            /*/ search button
            searchBtn.frame = CGRectMake(310-39-39, 17, 44, 44)
            searchBtn.setBackgroundImage(UIImage(named: "magnifyingGlass"), forState: UIControlState.Normal)
            navBG.addSubview(searchBtn)*/
            
            // settings button
            settingsBtn.frame = CGRectMake(310-39, 17, 44, 44)
            settingsBtn.setBackgroundImage(UIImage(named: "settingsBtn"), forState: UIControlState.Normal)
            settingsBtn.addTarget(self, action: "settingsAction", forControlEvents: UIControlEvents.TouchUpInside)
            navBG.addSubview(settingsBtn)
            
            // load table data
            if (segmentArray != nil) {
                loadPostsTask = "listPosts"
                loadPostsExtra = segmentArray![0] as String
                loadTableDataForTask(loadPostsTask, extra: loadPostsExtra)
            } else {
                loadPostsTask = "listPosts"
                loadPostsExtra = "All"
                loadTableDataForTask(loadPostsTask, extra: loadPostsExtra)
            }
            
            // add segmented array
            if (segmentArray != nil) {
                navBG.frame.size.height += 35
                segmentControl = UISegmentedControl(items: segmentArray)
                segmentControl!.frame = CGRectMake(5, 64, 310, 30)
                segmentControl!.tintColor = UIColor.whiteColor()
                segmentControl!.selectedSegmentIndex = 0
                segmentControl!.addTarget(self, action: "segmentUpdate:", forControlEvents: UIControlEvents.ValueChanged)
                navBG.addSubview(segmentControl!)
            }
            
        } else if navBarType == "child" {
            
            // add notifications button
            navBackBtn.frame = CGRectMake(-3, 17, 44, 44)
            navBackBtn.backgroundColor = knackkOrange
            navBackBtn.setBackgroundImage(UIImage(named: "backNavBtn"), forState: UIControlState.Normal)
            navBackBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
            navBG.addSubview(navBackBtn)
            
            // title label
            navTitleLbl.frame = CGRectMake(50, 20, 220, 44)
            navTitleLbl.backgroundColor = knackkOrange
            navTitleLbl.textColor = UIColor.whiteColor()
            navTitleLbl.font = UIFont(name: "Verdana", size: 18)
            navTitleLbl.textAlignment = NSTextAlignment.Center
            navBG.addSubview(navTitleLbl)
            
        }
        
        // table
        table.frame = CGRectMake(0, 64, 320, screenHeight - 64)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = knackkLightGray
        table.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(table)
        
        // adjust for segmented array
        if (segmentArray != nil) {
            table.frame.origin.y += 35
            table.frame.size.height -= 35
        }
    }
    
    // MARK: - Nav Bar Methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func segmentUpdate(sender:UISegmentedControl) {
        loadPostsStart = 0
        loadPostsTask = "listPosts"
        loadPostsExtra = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!
        loadTableDataForTask(loadPostsTask, extra: loadPostsExtra)
        table.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    func notificationsAction() {
        let vc = NotificationsVC(segment: nil, showSearchBar:false, parent:self)
        self.navigationController?.pushViewController(vc, animated: true)
        self.notificationsBtn.setTitle("0", forState: UIControlState.Normal)
    }
    func inviteAction() {
        let vc = InviteCoworkersVC(segment: ["Follow", "Invite"], showSearchBar:true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func settingsAction() {
        let vc = SettingsVC(segment: nil, showSearchBar:false)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Methods
    func syncCompanyUsersToCoreData() {
        //println("syncing company users to core data")
        
        // get variables to send
        let dbHelper = DatabaseHelper()
        let myKnackkId = dbHelper.getUserObjectForKey("knackkId")
        var parameters = parametersForTask("listUsers")
        parameters["companyId"] = dbHelper.getUserObjectForKey("companyId")
        
        //println("parameters: \(parameters)")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            .responseSwiftyJSON { (request, response, JSON, error) in
                
                let status = JSON["status"].stringValue
                if (status == "success") {
                    
                    // LOOP USERS AND SAVE TO CORE DATA
                    if let rawUsersArray = JSON["users"].array {
                        
                        // init core data
                        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                        let context = appDelegate.managedObjectContext
                        let entity = NSEntityDescription.entityForName("CompanyUsers", inManagedObjectContext: context!)
                        self.companyUsersArray = Array()
                        var error:NSError?
                        
                        // delete previous users
                        var fetchRequest = NSFetchRequest()
                        fetchRequest.entity = entity
                        let result:NSArray = context!.executeFetchRequest(fetchRequest, error: &error)!
                        for i in 0 ..< result.count {
                            let companyUser = result[i] as CompanyUsers
                            context?.deleteObject(companyUser)
                        }
                        
                        for i in 0 ..< rawUsersArray.count {
                            let thisUserArray = rawUsersArray[i]
                            //if (thisUserArray["userId"].stringValue != myKnackkId) {
                                
                                let companyUser = CompanyUsers(entity:entity!, insertIntoManagedObjectContext:context!)
                                companyUser.emailPrefix = thisUserArray["emailPrefix"].stringValue
                                companyUser.pictureUrl = thisUserArray["pictureUrl"].stringValue
                                companyUser.userId = thisUserArray["userId"].stringValue
                                companyUser.userName = thisUserArray["userName"].stringValue
                                if context!.save(&error) {
                                    self.companyUsersArray?.append(companyUser)
                                } else {
                                    println("couldn't save company user, \(error!.localizedDescription)")
                                }
                            //}
                        }
                        self.table.reloadData()
                    }
                    
                } else {
                    let alert = UIAlertView(title: "Error", message: "Could not fetch co-workers", delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
        }
    }
    func adjustFollowButtonsForFollowedUser(user:String) {
        // hide follow buttons for the followed user
        for i in 0..<tableObjects.count {
            let tableObject = tableObjects[i]
            println("adjusting follow buttons, id: \(tableObject.postId), title: \(tableObject.contentText)")
            if (tableObject.type == .UserPost && tableObject.userIdToFollow == user) {
                tableObject.userHasFollowed = true
            }
        }
        table.reloadData()
    }
    func postWithObject(bodyText:String, imageData:NSData?) {
        
        // GET VARIABLES
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        var parameters = parametersForTask("newPost")
        parameters["userId"] = (userDict["knackkId"] as String)
        parameters["body"] = bodyText
        
        
        // ADD POST TO TABLE DURING UPLOAD
        let firstName = userDict["firstName"] as String
        let lastName = userDict["lastName"] as String
        let fullName = "\(firstName) \(lastName)"
        let userImageURL = userDict["userImageURL"] as String
        
        
        /*/ create post obj
        let obj = FeedObject(type: .UserPost)
        obj.timeString = "just now"
        obj.attributedContentText = obj.checkForTagsAndHyperlink(bodyText, newsUrl:nil, thisParent: self)
        //obj.contentText = bodyText
        if imageData != nil {
            println("has image")
            obj.postImageData = imageData!
        }
        obj.numComments = "0"
        obj.numLikes = "0"
        obj.username = fullName
        obj.userImage = userImageURL*/
        
        
        let obj = FeedObject(type: .UserPost, username: fullName, userImage: userImageURL, parent:self)
        obj.userId = userDict.objectForKey("knackkId") as? String
        obj.userIdToFollow = obj.userId!
        var hasImage = false
        if imageData != nil {
            println("has image")
            obj.postImageData = imageData!
            hasImage = true
        }
        obj.timeString = "just now"
        obj.attributedContentText = obj.checkForTagsAndHyperlink(bodyText, newsUrl:nil, thisParent: self)
        obj.numComments = "0"
        obj.numLikes = "0"
        obj.userHasLikedPost = false
        obj.setUserPostHeightWithText(nil, text: bodyText, hasImage: hasImage, isComment:false, hasNewsUrl:nil, postParent:self)
        
        
        
        
        
        
        
        
        
        // create comment obj
        let commentBoxObj = FeedObject(type: .PostAComment, username: fullName, userImage: userImageURL)
        
        
        // find correct spot to insert temp post
        // self.tableObjects.insert(obj, atIndex: 3)
        var hasFoundPostThread = false
        for (var i=0; i < self.tableObjects.count; i++) {
            let thisObj = self.tableObjects[i]
            println("obj id:\(thisObj.postId), type:\(thisObj.type), text:\(thisObj.contentText)")
            if thisObj.type == .UpdateStatus {
                self.tableObjects.insert(FeedObject(type: .Separator), atIndex: i+2)
                self.tableObjects.insert(commentBoxObj, atIndex: i+2)
                self.tableObjects.insert(obj, atIndex: i+2)
                self.currentlyPostingUserPostObject = obj
                self.currentlyPostingUserPostCommentObject = commentBoxObj
                break
            }
        }
        
        
        
        
        // reload table
        self.table.reloadData()
        
        
        
        
        // UPLOAD FUNCTIONS ----------
        
        // function to create urlRequestConvertible for Alamofire.upload
        func urlRequestWorksWithDotRequest() -> (URLRequestConvertible, NSData) {
            
            let boundaryConstant = "boundsxx7n32dn8xx";
            let contentType = "multipart/form-data;boundary="+boundaryConstant
            
            var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: apiURL)!)
            mutableURLRequest.HTTPMethod = Method.POST.rawValue
            mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            
            // Prepare the HTTPBody for the request.
            let requestBodyData : NSMutableData = NSMutableData()
            
            // add image
            requestBodyData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData(imageData!)
            
            // add variables
            for (key, value) in parameters {
                requestBodyData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                requestBodyData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
            requestBodyData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            mutableURLRequest.HTTPBody = requestBodyData
            
            return (ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, requestBodyData)
            
        }
        // progress block
        let setProgress = { (percent:CGFloat) -> () in
            dispatch_async(dispatch_get_main_queue(),{
                self.uploadImageProgressView?.frame.size.width = 245 * percent
                if (percent == 1.0) {
                    UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.uploadImageProgressView!.alpha = 0
                        return
                        }, completion: {
                            (value: Bool) in
                            self.uploadImageProgressView!.removeFromSuperview()
                            self.uploadImageProgressView = nil
                    })
                }
            });
        }
        
        
        // UPLOAD ----------
        
        // IF HAS IMAGE
        if (imageData != nil) {
            
            parameters["task"] = "newPostPhoto"
            
            let urlRequest = urlRequestWorksWithDotRequest()
            upload(urlRequest.0, urlRequest.1)
                .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                    setProgress(CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite))
                }
                .responseSwiftyJSON { (request, response, JSON, error) in
                    println("REQUEST \(request)")
                    println("RESPONSE \(response)")
                    println("JSON 1 \(JSON)")
                    println("ERROR \(error)")
                    
                    let status = JSON["status"].stringValue
                    if (status == "success") {
                        if self.currentlyPostingUserPostObject != nil && self.currentlyPostingUserPostCommentObject != nil {
                            self.currentlyPostingUserPostObject?.postId = JSON["postId"].stringValue
                            self.currentlyPostingUserPostCommentObject?.postId = JSON["postId"].stringValue
                            self.currentlyPostingUserPostObject = nil
                            self.currentlyPostingUserPostCommentObject = nil
                        }
                    } else {
                        let alert = UIAlertView(title: "Could Not Post", message: "An error occurred trying save this post. Please try again later.", delegate: nil, cancelButtonTitle: "Okay")
                        alert.show()
                    }
            }
            
            // IF DOES NOT HAVE IMAGE
        } else {
            
            // send request to server
            request(.POST, apiURL, parameters: parameters)
                
                
                .responseSwiftyJSON { (request, response, JSON, error) in
                    //println("REQUEST \(request)")
                    //println("RESPONSE \(response)")
                    println("JSON 2 \(JSON)")
                    //println("ERROR \(error)")
                    
                    let status = JSON["status"].stringValue
                    if (status == "success") {
                        if self.currentlyPostingUserPostObject != nil && self.currentlyPostingUserPostCommentObject != nil {
                            self.currentlyPostingUserPostObject?.postId = JSON["postId"].stringValue
                            self.currentlyPostingUserPostCommentObject?.postId = JSON["postId"].stringValue
                            self.currentlyPostingUserPostObject = nil
                            self.currentlyPostingUserPostCommentObject = nil
                        }
                    } else {
                        let alert = UIAlertView(title: "Could Not Post", message: "An error occurred trying save this post. Please try again later.", delegate: nil, cancelButtonTitle: "Okay")
                        alert.show()
                    }
            }
        }
    }
    func incrementFollowingCount(increment:Int) {
        let obj = tableObjects[0]
        var followingCount = obj.numFollowing!.componentsSeparatedByString(" ")[0].toInt()!
        //var followingCount = (followingArray.objectAtIndex(0) as NSString).toInt()
        followingCount += increment
        obj.numFollowing = "\(followingCount)"
        table.reloadData()
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.buttonTitleAtIndex(buttonIndex) == "Flag It" {
            
            // get variables to send
            let dbHelper = DatabaseHelper()
            var userDict = dbHelper.getUserData()
            var parameters = parametersForTask("postFlag")
            parameters["userId"] = (userDict["knackkId"] as String)
            parameters["postId"] = feedObjectToFlag?.postId
            
            // send request to server
            request(.POST, apiURL, parameters: parameters)
                .responseSwiftyJSON { (request, response, JSON, error) in
                    println("JSON 3 \(JSON)")
                    let status = JSON["status"].stringValue
                    if (status == "success") {
                        
                        // remove flagged thread
                        var hasFoundPostThread = false
                        var indexesToRemove:[Int] = Array()
                        for (var i=0; i < self.tableObjects.count; i++) {
                            let thisObj = self.tableObjects[i]
                            if thisObj.postId == self.feedObjectToFlag!.postId {
                                hasFoundPostThread = true
                            }
                            if hasFoundPostThread {
                                indexesToRemove.append(i)
                                if thisObj.type == .Separator {
                                    break
                                }
                            }
                        }
                        for (var i = indexesToRemove.count-1; i>=0; i--) {
                            self.tableObjects.removeAtIndex(indexesToRemove[i])
                        }
                        self.table.reloadData()
                        
                    } else {
                        let alert = UIAlertView(title: "Could Not Flag Post", message: "An error occurred trying to flag this post. Please try again later.", delegate: nil, cancelButtonTitle: "Okay")
                        alert.show()
                    }
            }
        }
    }
    
    
    // MARK: Image Viewer Methods
    func showImageViewerWithImage(image:UIImage) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        if imageViewerShell == nil {
            imageViewerShell = UIScrollView(frame: self.view.frame)
            imageViewerShell!.delegate = self
            imageViewerShell!.backgroundColor = UIColor.blackColor()
            imageViewerShell!.minimumZoomScale = 1.0
            imageViewerShell!.maximumZoomScale = 3.0
            imageViewerShell!.contentSize = self.view.frame.size
            self.view.addSubview(imageViewerShell!)
            
            imageViewer = UIImageView(frame: self.view.frame)
            imageViewer!.contentMode = UIViewContentMode.ScaleAspectFit
            imageViewerShell!.addSubview(imageViewer!)
            
            var tapRecognizer = UITapGestureRecognizer(target: self, action: "hideImageViewer")
            tapRecognizer.numberOfTapsRequired = 1
            tapRecognizer.numberOfTouchesRequired = 1
            imageViewerShell!.addGestureRecognizer(tapRecognizer)
        }
        imageViewerShell!.hidden = false
        imageViewerShell!.zoomScale = 1.0
        imageViewer!.image = image
    }
    func hideImageViewer() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        imageViewerShell!.hidden = true
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageViewer!
    }
    
    
    // MARK: - Text Methods
    func keyboardDone() {
        self.view.endEditing(true)
    }
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        println("\n\nurl: \(URL)\n\n")
        
        let urlArray = URL.absoluteString!.componentsSeparatedByString(":::")
        if urlArray[0] == "knackk" {
            let taskArray = urlArray[1].componentsSeparatedByString("===")
            if taskArray[0] == "viewProfileId" {
                let userId = taskArray[1]
                
                var username = "Loading"
                var imageUrl = ""
                for i in 0..<companyUsersArray!.count {
                    let thisUser = companyUsersArray![i]
                    if thisUser.userId == userId {
                        username = thisUser.userName
                        imageUrl = thisUser.pictureUrl
                        break
                    }
                }
                let vc = ShowProfileVC(segment: nil, fetchCoworkers: false, navBarType: "child", userName: username, userImageUrl: imageUrl, toViewProfileId: userId)
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if taskArray[0] == "showNewsArticle" {
                let url = taskArray[1]
                let dbHelper = DatabaseHelper()
                let companyName = dbHelper.getUserObjectForKey("companyName")!
                let vc = WebBrowserVC(url: url, title: "News for \(companyName)")
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = WebBrowserVC(url: URL.absoluteString!, title: URL.absoluteString!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return false
    }
    
    
    // MARK: - Table Methods
    func reloadFromServer() {
        //if canSubmitLoadRequest {
        //    canSubmitLoadRequest = false
            reloadTableDataForTask(loadPostsTask, extra: loadPostsExtra)
        //}
    }
    func loadTableDataForTask(task:String, extra:String?) {
        // subclass method
    }
    func reloadTableDataForTask(task:String, extra:String?) {
        // subclass method
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableObjects.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // get feed object
        let obj:FeedObject = tableObjects[indexPath.row]
        
        
        if (obj.type == .Separator) {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "separatorCell")
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = knackkLightGray
            return cell
            
        } else if (obj.type == .Loading) {
            
            let cell = LoadingCell(style: UITableViewCellStyle.Default, reuseIdentifier: "loadingCell", obj:obj, parent:self)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else if (obj.type == .VerifyEmail) {
            
            let cell = VerifyEmailCell(style: UITableViewCellStyle.Default, reuseIdentifier: "verifyEmailCell")
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else if (obj.type == .UpdateStatus) {
            
            let cell = WillPresentStatusUpdateCell(style: UITableViewCellStyle.Default, reuseIdentifier: "updateStatusCell", parent: self)
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!) }
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            //let cell = UpdateStatusCell(style: UITableViewCellStyle.Default, reuseIdentifier: "updateStatusCell", parent: self)
            //cell.configureCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            //self.thisUpdateStatusCell = cell
            return cell
            
        } else if (obj.type == .ProfileBadge) {
            
            let cell = ProfileBadgeCell(style: UITableViewCellStyle.Default, reuseIdentifier: "updateStatusCell", parent: self)
            cell.configureCell(obj)
            if (obj.userTitle != nil) { cell.setUserTitle(obj.userTitle!) }
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!) }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else if (obj.type == .UserPost) {
            
            let cell = UserPostCell(style: UITableViewCellStyle.Default, reuseIdentifier: "userPost", parent:self)
            cell.obj = obj
            println("---\nFollow state: \(obj.userHasFollowed)\n---")
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!) }
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            if (obj.timeString != nil) { cell.setTimeAgo(obj.timeString!) }
            if (obj.attributedContentText != nil) { cell.setContentText(obj.attributedContentText!) }
            if (obj.postImageData != nil) { cell.setPostImageData(obj.postImageData!) }
            if (obj.postImageURL != nil) { cell.setPostImage(obj.postImageURL!) }
            if (obj.numLikes != nil) { cell.setLikesCount(obj.numLikes!) }
            if (obj.numComments != nil) { cell.setCommentsCount(obj.numComments!) }
            cell.formatCell(obj, parent: self)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else if (obj.type == .NewsArticle) {
            
            let cell = NewsArticleCell(style: UITableViewCellStyle.Default, reuseIdentifier: "newsArticle", parent:self)
            cell.obj = obj
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            if (obj.timeString != nil) { cell.setTimeAgo(obj.timeString!) }
            if (obj.attributedContentText != nil) { cell.setContentText(obj.attributedContentText!) }
            if (obj.numLikes != nil) { cell.setLikesCount(obj.numLikes!) }
            if (obj.numComments != nil) { cell.setCommentsCount(obj.numComments!) }
            cell.formatCell(obj, parent: self)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else if (obj.type == .UserComment) {
            
            let cell = UserCommentCell(style: UITableViewCellStyle.Default, reuseIdentifier: "userComment")
            cell.obj = obj
            cell.parent = self
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!) }
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            if (obj.timeString != nil) { cell.setTimeAgo(obj.timeString!) }
            if (obj.contentText != nil) { cell.setContentText(obj.contentText!) }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else if (obj.type == .ShowEntirePost) {
            
            let cell = ShowEntirePostCell(style: UITableViewCellStyle.Default, reuseIdentifier: "showEntirePost")
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            return cell
            
        } else if (obj.type == .PostAComment) {
            
            let cell = PostACommentCell(style: UITableViewCellStyle.Default, reuseIdentifier: "userComment", parent:self, obj:obj)
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!) }
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else if (obj.type == .Notification) {
            
            let cell = NotificationCell(style: UITableViewCellStyle.Default, reuseIdentifier: "notification")
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!) }
            if (obj.timeString != nil) { cell.setTimeAgo(obj.timeString!) }
            if (obj.contentText != nil) { cell.setNotificationText(obj.contentText!) }
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            return cell
            
        }  else if (obj.type == .Instructions) {
            
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
            
        }  else if (obj.type == .SearchBar) {
            
            let cell = SearchBarCell(style: UITableViewCellStyle.Default, reuseIdentifier: "searchBar")
            cell.configureCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        }  else if (obj.type == .FollowCoworker) {
            
            let cell = FollowCoworkerCell(style: UITableViewCellStyle.Default, reuseIdentifier: "followCoworker")
            cell.parent = self
            cell.feedObj = obj
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!, cacheManager:imageCacheManager) }
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            if (obj.userId != nil) { cell.followerId = obj.userId }
            if (obj.userIdToFollow != nil) { cell.leaderId = obj.userIdToFollow }
            if (obj.userHasFollowed) { cell.setFollowingButton(obj.userHasFollowed) }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
            /*let cell = FollowCoworkerCell(style: UITableViewCellStyle.Default, reuseIdentifier: "followCoworker")
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!) }
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell*/
            
        } else {
            
            let cell = UITableViewCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = knackkLightGray // UIColor.clearColor()
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // get feed object
        let obj:FeedObject = tableObjects[indexPath.row]
        
        if (obj.type == .ShowEntirePost) {
            let vc = LeaveCommentVC(parent: self, tableObjs: tableObjects, postId: obj.postId!, showKeyboard:false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let obj:FeedObject = tableObjects[indexPath.row]
        return obj.height
    }
}


// MARK: - Custom Table Cells
class VerifyEmailCell: UITableViewCell {
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = knackkLightGray // UIColor.clearColor()
        
        // white background
        let bgView = UIView(frame: CGRectMake(8, 0, 304, 88))
        bgView.backgroundColor = UIColor(white: 0.6, alpha: 1)
        self.contentView.addSubview(bgView)
        
        // place holder text view
        let instructionsLbl = UILabel(frame: CGRectMake(10, 0, 284, 88)) // 3 lines = 45 height.
        instructionsLbl.userInteractionEnabled = false
        instructionsLbl.font = UIFont(name: "Verdana", size: 13)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.backgroundColor = UIColor(white: 0.6, alpha: 1) // UIColor.clearColor()
        instructionsLbl.numberOfLines = 0
        // set text
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        var attrString = NSMutableAttributedString(string: "Please check your inbox for an email with a link to verify your email address. You will be unable to see posts from co-workers or write posts until it is verified. Thanks!") // You have not verified your email address.
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        instructionsLbl.attributedText = attrString
        bgView.addSubview(instructionsLbl)
        
    }
}
class LoadingCell: UITableViewCell {
    
    //var parent:MyFeedBaseVC?
    //var thisObj:FeedObject?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init (style: UITableViewCellStyle, reuseIdentifier: String!, obj:FeedObject, parent:MyFeedBaseVC) {
        self.init(style:style, reuseIdentifier:reuseIdentifier)
        
        if obj.thisLoadingCellCanRequestFromServer {
            parent.reloadFromServer()
        }
        
        /*self.parent = parent
        if parent.canSubmitLoadRequest {
            parent.reloadFromServer()
        }*/
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = knackkLightGray
        
        // white background
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.center = CGPointMake(self.frame.size.width/2, 25)
        activityIndicator.startAnimating()
        self.contentView.addSubview(activityIndicator)
    }
}
class WillPresentStatusUpdateCell: UITableViewCell {
    
    var parent:MyFeedBaseVC?
    let userImageView = UIImageView()
    let usernameLbl = UILabel()
    let updateStatusBtn = UIButton()
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String!, parent:MyFeedBaseVC) {
        self.init(style:style, reuseIdentifier:reuseIdentifier)
        self.parent = parent
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = knackkLightGray
        
        // white background
        let bgView = UIView(frame: CGRectMake(8, 0, 304, 68))
        bgView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(bgView)
        
        // user image
        userImageView.frame = CGRectMake(5, 5, 44, 44)
        userImageView.image = UIImage(named: "defaultUser.jpg")
        bgView.addSubview(userImageView)
        
        // username label
        usernameLbl.frame = CGRectMake(54, 1, 230, 20)
        usernameLbl.textColor = UIColor.blackColor()
        usernameLbl.font = UIFont(name: "Verdana-Bold", size: 13)
        bgView.addSubview(usernameLbl)
        
        // place holder text view
        let instructionsLbl = UILabel(frame: CGRectMake(54, 20, 245, 40)) // 3 lines = 45 height.
        instructionsLbl.userInteractionEnabled = false
        instructionsLbl.font = UIFont(name: "Verdana", size: 11)
        instructionsLbl.textColor = UIColor(white: 0.5, alpha: 1)
        instructionsLbl.backgroundColor = UIColor.whiteColor() // UIColor.clearColor()
        instructionsLbl.numberOfLines = 0
        // set text
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        var attrString = NSMutableAttributedString(string: "What's happening in your company?\nTap here to update your status.")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        instructionsLbl.attributedText = attrString
        bgView.addSubview(instructionsLbl)
        
        
        
        // button
        updateStatusBtn.frame = CGRectMake(0, 0, 304, 68)
        updateStatusBtn.backgroundColor = UIColor.clearColor()
        updateStatusBtn.addTarget(self, action: "presentUpdateStatusViewController", forControlEvents: UIControlEvents.TouchUpInside)
        updateStatusBtn.addTarget(self, action: "buttonPressed", forControlEvents: UIControlEvents.TouchDown)
        updateStatusBtn.addTarget(self, action: "buttonPressed", forControlEvents: UIControlEvents.TouchDragInside)
        updateStatusBtn.addTarget(self, action: "buttonReleased", forControlEvents: UIControlEvents.TouchUpOutside)
        updateStatusBtn.addTarget(self, action: "buttonReleased", forControlEvents: UIControlEvents.TouchDragOutside)
        bgView.addSubview(updateStatusBtn)
    }
    func setUserImage (userImageString:String) {
        if userImageString == "" || userImageString == "null" || userImageString.isEmpty {
            userImageView.image = UIImage(named: "defaultUser.jpg")
        } else {
            // load from cache if cached; if not, load from internet
            if let cacheImage = self.parent!.imageCacheManager.imageFromCacheForUrl(userImageString) {
                self.userImageView.image = cacheImage
            } else {
                var url = NSURL(string: userImageString)
                var image: UIImage?
                var request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    self.userImageView.image = UIImage(data: data)
                    self.parent!.imageCacheManager.cacheImageForUrl(userImageString, type: "profilePicture", imageData: data)
                })
            }
        }
    }
    func setUsername (username:String) {
        usernameLbl.text = username
    }
    
    // button functions
    func presentUpdateStatusViewController() {
        buttonReleased()
        let dbHelper = DatabaseHelper()
        if dbHelper.getUserObjectForKey("userMustValidateWorkEmail") == "false" {
            let makePost = MakePostVC(parent: parent!, userArray:parent!.companyUsersArray)
            parent!.navigationController!.presentViewController(makePost, animated: true, completion: nil)
        } else {
            let alert = UIAlertView(title: "Please Verify Email", message: "You must verify your email address before you are able to post anything. Please check your email for a verification link. Thank you!", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
    }
    func buttonPressed() {
        updateStatusBtn.backgroundColor = UIColor(white: 0, alpha: 0.6)
    }
    func buttonReleased() {
        updateStatusBtn.backgroundColor = UIColor.clearColor()
    }
}



class ProfileBadgeCell:UITableViewCell {
    
    var parent:MyFeedBaseVC?
    
    var myContentView = UIView()
    var backgroundImageView = UIImageView()
    var thumbnailView = UIImageView()
    let titleLbl = UILabel()
    var followSegmentControl = UISegmentedControl(items: ["My Posts", "Followers", "Following"])
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String!, parent:MyFeedBaseVC) {
        self.init(style:style, reuseIdentifier:reuseIdentifier)
        self.parent = parent
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        
        // myContentView
        myContentView.frame = CGRectMake(0, 0, 320, 125+20)
        myContentView.backgroundColor = UIColor.whiteColor()
        myContentView.clipsToBounds = true
        self.contentView.addSubview(myContentView)
        
        // image background view
        backgroundImageView.frame = myContentView.frame
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImageView.image = UIImage(named: "defaultUser.jpg")
        myContentView.addSubview(backgroundImageView)
        /*/ add blur
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        visualEffectView.frame = myContentView.frame
        backgroundImageView.addSubview(visualEffectView)*/
        
        let bgAlphaView = UIView(frame: myContentView.frame)
        bgAlphaView.backgroundColor = UIColor(white: 0, alpha: 0.16)
        backgroundImageView.addSubview(bgAlphaView)
        
        // thumbnail
        let thumbnailBorder = UIView(frame: CGRectMake(132, 17, 56, 56))
        thumbnailBorder.backgroundColor = UIColor.whiteColor()
        myContentView.addSubview(thumbnailBorder)
        thumbnailView.frame = CGRectMake(135, 20, 50, 50)
        thumbnailView.contentMode = UIViewContentMode.ScaleAspectFill
        thumbnailView.image = UIImage(named: "defaultUser.jpg")
        thumbnailView.clipsToBounds = true
        myContentView.addSubview(thumbnailView)
        
        // user title
        titleLbl.frame = CGRectMake(20, 79, 280, 20)
        titleLbl.text = ""
        titleLbl.textColor = UIColor.whiteColor()
        titleLbl.font = UIFont(name: "Verdana", size: 13)
        titleLbl.textAlignment = NSTextAlignment.Center
        myContentView.addSubview(titleLbl)
        
        // followers segmented controll
        //var followSegmentControl = UISegmentedControl(items: ["My Posts", "100 Followers", "89 Following"])
        followSegmentControl.setTitle("0 Followers", forSegmentAtIndex: 1)
        followSegmentControl.setTitle("0 Following", forSegmentAtIndex: 2)
        followSegmentControl.frame = CGRectMake(10, 86+20, 300, 30)
        followSegmentControl.tintColor = UIColor.whiteColor()
        followSegmentControl.selectedSegmentIndex = 0
        followSegmentControl.addTarget(self, action: "segmentUpdate:", forControlEvents: UIControlEvents.ValueChanged)
        myContentView.addSubview(followSegmentControl)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUserTitle(title:String) {
        titleLbl.text = title
    }
    
    func setUserImage (userImageString:String) {
        if userImageString == "" || userImageString == "null" || userImageString.isEmpty {
            // keep default
        } else {
            // load from cache if cached; if not, load from internet
            if let cacheImage = self.parent!.imageCacheManager.imageFromCacheForUrl(userImageString) {
                self.backgroundImageView.image = cacheImage
                self.thumbnailView.image = cacheImage
            } else {
                var url = NSURL(string: userImageString)
                var image: UIImage?
                var request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    self.backgroundImageView.image = UIImage(data: data)
                    self.thumbnailView.image = UIImage(data: data)
                    self.parent!.imageCacheManager.cacheImageForUrl(userImageString, type: "profilePicture", imageData: data)
                })
            }
        }
    }
    
    
    // methods
    func segmentUpdate(sender:UISegmentedControl) {
        
        // get task from selected index
        let segmentTitle = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!.componentsSeparatedByString(" ")[1]
        var task = "listPosts"
        var selectedInt = 0
        if segmentTitle == "Followers" {
            task = "listFollowers"
            selectedInt = 1
        }
        if segmentTitle == "Following" {
            task = "listFollowing"
            selectedInt = 2
        }
        
        // remove everything but profile badge
        let profileBadge = parent!.tableObjects[0] as FeedObject
        println("profileBadge, userId:\(profileBadge.userId), userName:\(profileBadge.username)")
        profileBadge.setSelectedIndex = selectedInt
        parent!.tableObjects.removeAll(keepCapacity: false)
        parent!.tableObjects.append(profileBadge)
        parent!.table.reloadData()
        
        // get variables to send
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        
        if userDict["knackkId"] as? String != profileBadge.userId && task == "listPosts" {
            task = "showProfile"
        }
        
        // create parameters
        var parameters = parametersForTask(task)
        parameters["userId"] = profileBadge.userId
        if userDict["knackkId"] as? String == profileBadge.userId {
            parameters["filter"] = "me"
        } else {
            parameters["toDisplayUserId"] = profileBadge.userId
            parameters["requestingUserId"] = userDict["knackkId"] as? String
        }
        println("paramters: \(parameters)\n")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("JSON 4 \(JSON)")
                let status = JSON["status"].stringValue
                if (status == "success") {
                    // success
                    
                    if task != "listPosts" && task != "showProfile" {
                        
                        var dictKey = "followers"
                        if task == "listFollowing" {
                            dictKey = "following"
                        }
                        
                        // add each follower / following
                        if let rawUsersArray = JSON[dictKey].array {
                            println(" ---> A <---")
                            for i in 0 ..< rawUsersArray.count {
                                let thisUserArray = rawUsersArray[i]
                                
                                let username = thisUserArray["userName"].stringValue
                                println(" ---> A\(i), userName:\(username) <---")
                                
                                if (thisUserArray["userId"].stringValue != userDict["knackkId"] as? String || userDict["knackkId"] as? String != profileBadge.userId) {
                                    let obj = FeedObject(type: .FollowCoworker, username: thisUserArray["userName"].stringValue, userImage: thisUserArray["pictureUrl"].stringValue)
                                    obj.userId = userDict["knackkId"] as? String
                                    obj.userIdToFollow = thisUserArray["userId"].stringValue
                                    let hasFollowed = thisUserArray["userHasFollowed"].stringValue == "true" ? true : false
                                    obj.userHasFollowed = hasFollowed
                                    self.parent!.tableObjects.append(obj)
                                }
                            }
                        }
                        
                    } else {
                        
                        if let rawPostsArray = JSON["posts"].array {
                            
                            // post separator
                            self.parent!.tableObjects.append(FeedObject(type: .Separator))
                            
                            // list posts
                            for i in 0 ..< rawPostsArray.count {
                                
                                let thisPostArray = rawPostsArray[i]
                                //println("thisPostArray: \(thisPostArray)")
                                
                                let obj = FeedObject(type: .UserPost, username: thisPostArray["userName"].stringValue, userImage: thisPostArray["pictureUrl"].stringValue)
                                obj.postId = thisPostArray["id"].stringValue
                                obj.timeString = thisPostArray["timeAgo"].stringValue
                                obj.contentText = thisPostArray["text"].stringValue
                                obj.postImageURL = thisPostArray["imageUrl"].stringValue
                                obj.numComments = "0"
                                obj.numLikes = thisPostArray["likes"].stringValue
                                obj.setUserPostHeightWithText(nil, text: obj.contentText!, hasImage: !obj.postImageURL!.isEmpty, isComment:false, hasNewsUrl:nil, postParent:self.parent!)
                                self.parent!.tableObjects.append(obj)
                                
                                
                                // loop comments
                                if let rawCommentsArray = thisPostArray["comments"].array {
                                    for j in 0 ..< rawCommentsArray.count {
                                        let thisCommentArray = rawCommentsArray[j]
                                        let commentObj = FeedObject(type: .UserComment, username: thisCommentArray["userName"].stringValue, userImage: thisCommentArray["pictureUrl"].stringValue)
                                        commentObj.postId = thisPostArray["id"].stringValue
                                        commentObj.timeString = thisCommentArray["timeAgo"].stringValue
                                        commentObj.contentText = thisCommentArray["text"].stringValue
                                        commentObj.setUserPostHeightWithText(nil, text: commentObj.contentText!, hasImage: false, isComment:true, hasNewsUrl:nil, postParent:self.parent!)
                                        self.parent!.tableObjects.append(commentObj)
                                    }
                                }
                                
                                // add comment box
                                let commenterFirst = userDict["firstName"] as String
                                let commenterLast = userDict["lastName"] as String
                                let commenterUsername = "\(commenterFirst) \(commenterLast)"
                                let commentBoxObj = FeedObject(type: .PostAComment, username: commenterUsername, userImage: userDict["userImageURL"] as String)
                                commentBoxObj.postId = thisPostArray["id"].stringValue
                                commentBoxObj.userId = (userDict["knackkId"] as String)
                                self.parent!.tableObjects.append(commentBoxObj)
                                
                                // post separator
                                self.parent!.tableObjects.append(FeedObject(type: .Separator))
                            }
                        }
                    }
                    
                    self.parent!.table.reloadData()
                    for i in 0..<self.parent!.tableObjects.count {
                        let obj = self.parent!.tableObjects[i] as FeedObject
                        println("FeedObject username: \(obj.username)")
                    }
                    
                    println("# cells: \(self.parent!.table.numberOfRowsInSection(0)), tableFrame: \(self.parent!.table.frame)")
                    
                } else {
                    let alert = UIAlertView(title: "Error", message: "Could not fetch data.\nPlease try again later.", delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
        }
    }
    func configureCell(obj:FeedObject) {
        if (parent != nil) {
            if obj.setSelectedIndex != nil {
                followSegmentControl.selectedSegmentIndex = obj.setSelectedIndex!
            }
        }
        if obj.numFollowers != nil && obj.numFollowing != nil {
            followSegmentControl.setTitle("\(obj.numFollowers!) Followers", forSegmentAtIndex: 1)
            followSegmentControl.setTitle("\(obj.numFollowing!) Following", forSegmentAtIndex: 2)
        }
    }
}

class UserPostCell:UITableViewCell {
    
    var parent:MyFeedBaseVC?
    
    var obj:FeedObject?
    var myContentView = UIView()
    var userImageView = UIImageView()
    var usernameBtn = UIButton()
    //var usernameLbl = UILabel()
    var timeLbl = UILabel()
    var contentTextView = UITextView()
    var followBtn = UIButton()
    var inActiveBtn = UIButton()
    
    var postImageView = UIImageView()
    let postImageActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    //var postImageUploadIndicator:UIView?
    
    // like / comment indicators
    var likeCommentShell = UIView()
    var likeLbl = UILabel()
    var likePic = UIImageView()
    var commentLbl = UILabel()
    var commentPic = UIImageView()
    var likePostBtn = UIButton()
    
    
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String!, parent:MyFeedBaseVC) {
        self.init(style:style, reuseIdentifier:reuseIdentifier)
        self.parent = parent
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        
        // white background
        myContentView.frame = CGRectMake(8, 0, 304, 79)
        myContentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(myContentView)
        
        // user image
        userImageView.frame = CGRectMake(5, 5, 44, 44)
        myContentView.addSubview(userImageView)
        
        // follow button
        followBtn.frame = CGRectMake(5, 54, 44, 20)
        followBtn.setBackgroundImage(buttonImage(followBtn.frame.size, 2, 0, knackkLightGray, knackkLightGray), forState: UIControlState.Normal)
        followBtn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        followBtn.setTitle("Follow", forState: UIControlState.Normal)
        followBtn.titleLabel?.font = UIFont(name: "Verdana", size: 10)
        followBtn.addTarget(self, action: "followAction", forControlEvents: UIControlEvents.TouchUpInside)
        myContentView.addSubview(followBtn)
        
        //inactive button
        inActiveBtn.frame = CGRectMake(5, 54, 44, 20)
        inActiveBtn.setBackgroundImage(buttonImage(followBtn.frame.size, 2, 0, knackkLightGray, knackkLightGray), forState: UIControlState.Normal)
        inActiveBtn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        inActiveBtn.setTitle("Inactive", forState: UIControlState.Normal)
        inActiveBtn.titleLabel?.font = UIFont(name: "Verdana", size: 10)
        inActiveBtn.addTarget(self, action: "doNothing", forControlEvents: UIControlEvents.TouchUpInside)
        myContentView.addSubview(inActiveBtn)
        inActiveBtn.hidden = true
        
        
        // content text view
        contentTextView.frame = CGRectMake(50, 12, 253, 20) // 54, 20, 245, 20
        contentTextView.editable = false
        contentTextView.scrollEnabled = false
        contentTextView.font = UIFont(name: "Verdana", size: 11)
        contentTextView.textColor = UIColor(white: 0.5, alpha: 1)
        contentTextView.backgroundColor = UIColor.whiteColor()
        contentTextView.dataDetectorTypes = UIDataDetectorTypes.All
        myContentView.addSubview(contentTextView)
        
        // username label
        usernameBtn.frame = CGRectMake(54, 1, 155, 20)
        usernameBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        usernameBtn.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)
        usernameBtn.titleLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        usernameBtn.addTarget(self, action: "showProfileAction", forControlEvents: UIControlEvents.TouchUpInside)
        myContentView.addSubview(usernameBtn)
        
        // username label
        //usernameLbl.frame = CGRectMake(54, 1, 155, 20)
        //usernameLbl.textColor = UIColor.blackColor()
        //usernameLbl.font = UIFont(name: "Verdana-Bold", size: 13)
        //myContentView.addSubview(usernameLbl)
        
        // time label
        timeLbl.frame = CGRectMake(myContentView.frame.size.width-90, 1, 85, 20)
        timeLbl.textColor = UIColor.lightGrayColor()
        timeLbl.font = UIFont(name: "Verdana", size: 10)
        timeLbl.textAlignment = NSTextAlignment.Right
        myContentView.addSubview(timeLbl)
        
        // post image view
        postImageView.frame = CGRectMake(54, 54, 245, 245)
        postImageView.hidden = true
        postImageView.contentMode = UIViewContentMode.ScaleAspectFill
        postImageView.clipsToBounds = true
        myContentView.addSubview(postImageView)
        
        
        // like / comment indicator
        likeCommentShell.frame = CGRectMake(54, 54, 245, 20)
        likeCommentShell.backgroundColor = UIColor.whiteColor()
        myContentView.addSubview(likeCommentShell)
        // like label
        likeLbl.frame = CGRectMake(0, 0, 6, 20)
        likeLbl.font = UIFont(name: "Verdana", size: 10)
        likeLbl.textAlignment = NSTextAlignment.Right
        likeLbl.textColor = UIColor.darkGrayColor()
        likeLbl.text = "0"
        likeCommentShell.addSubview(likeLbl)
        // like pic
        likePic.frame = CGRectMake(6, 0, 20, 20)
        likePic.image = UIImage(named: "likeIndicator")
        likeCommentShell.addSubview(likePic)
        // comment label
        commentLbl.frame = CGRectMake(30, 0, 6, 20)
        commentLbl.font = UIFont(name: "Verdana", size: 10)
        commentLbl.textAlignment = NSTextAlignment.Right
        commentLbl.textColor = UIColor.darkGrayColor()
        commentLbl.text = "0"
        likeCommentShell.addSubview(commentLbl)
        // comment pic
        commentPic.frame = CGRectMake(36, 0, 20, 20)
        commentPic.image = UIImage(named: "commentIndicator")
        likeCommentShell.addSubview(commentPic)
        // like button
        likePostBtn.frame = CGRectMake(60, 2, 36, 16)
        likePostBtn.setBackgroundImage(buttonImage(likePostBtn.frame.size, 2, 0, knackkLightGray, knackkLightGray), forState: UIControlState.Normal)
        likePostBtn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        likePostBtn.setTitle("Like", forState: UIControlState.Normal)
        likePostBtn.titleLabel?.font = UIFont(name: "Verdana", size: 10)
        likePostBtn.addTarget(self, action: "likeAction", forControlEvents: UIControlEvents.TouchUpInside)
        likeCommentShell.addSubview(likePostBtn)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUserImage (userImageString:String) {
        if userImageString == "" || userImageString == "null" || userImageString.isEmpty {
            userImageView.image = UIImage(named: "defaultUser.jpg")
        } else {
            // load from cache if cached; if not, load from internet
            if let cacheImage = self.parent!.imageCacheManager.imageFromCacheForUrl(userImageString) {
                self.userImageView.image = cacheImage
            } else {
                var url = NSURL(string: userImageString)
                var image: UIImage?
                var request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    self.userImageView.image = UIImage(data: data)
                    self.parent!.imageCacheManager.cacheImageForUrl(userImageString, type: "profilePicture", imageData: data)
                })
            }
        }
    }
    func setUsername (username:String) {
        usernameBtn.setTitle(username, forState: UIControlState.Normal)
        // resize
        let dict = [NSFontAttributeName:usernameBtn.titleLabel!.font]
        let stringsize = (username as NSString).sizeWithAttributes(dict)
        var width = stringsize.width
        if width > 180 {
            width = 180
        }
        usernameBtn.frame.size.width = width
    }
    func setTimeAgo (timeAgo:String) {
        timeLbl.text = timeAgo
    }
    func setContentText (contentText:NSMutableAttributedString) {
        contentTextView.attributedText = contentText
        contentTextView.delegate = parent!
    }
    func setPostImageData (postImageData:NSData) {
        postImageView.image = UIImage(data: postImageData)
        postImageView.hidden = false
    }
    func setPostImage (postImageUrl:String?) {
        
        if (postImageUrl != "" && postImageUrl != nil) {
            
            // load from cache if cached; if not, load from internet
            if let cacheImage = self.parent!.imageCacheManager.imageFromCacheForUrl(postImageUrl!) {
                self.postImageView.image = cacheImage
            } else {
                postImageView.addSubview(postImageActivityIndicator)
                postImageActivityIndicator.startAnimating()
                postImageActivityIndicator.center = CGPointMake(postImageView.frame.size.width/2, postImageView.frame.size.height/2)
                
                var url = NSURL(string: postImageUrl!)
                var image: UIImage?
                var request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    self.postImageActivityIndicator.removeFromSuperview()
                    
                    self.postImageView.image = UIImage(data: data)
                    self.parent!.imageCacheManager.cacheImageForUrl(postImageUrl!, type: "postPicture", imageData: data)
                })
            }
            postImageView.hidden = false
        } else {
            postImageView.hidden = true
        }
    }
    func formatCell(feedObj:FeedObject, parent:MyFeedBaseVC) {
        
        let minContentViewHeight = followBtn.frame.origin.y + followBtn.frame.size.height + 5
        let minLikeCommentShellY = followBtn.frame.origin.y
        
        // calculate text height
        var height = heightForView(feedObj.attributedContentText!, contentTextView.font, contentTextView.frame.size.width-10)
        if (height < 20) { height = 20 }
        contentTextView.frame.size.height = height
        postImageView.frame.origin.y = contentTextView.frame.origin.y + contentTextView.frame.size.height + 5
        
        // calculate contentViewHeight & obj.height
        var shouldAddImageBtn = false
        var contentViewHeight = contentTextView.frame.origin.y + height + 25 + 5 // 25 = likeCommentShell.height + 5 bottom padding, 10 = a buffer
        if (obj?.postImageURL != nil && obj?.postImageURL != "") {
            println("has postImageURL, adding image height")
            contentViewHeight += 255
            shouldAddImageBtn = true
        } else if (obj?.postImageData != nil) {
            println("has postImageData, adding image height")
            contentViewHeight += 255
            shouldAddImageBtn = true
        }
        contentViewHeight = contentViewHeight >= minContentViewHeight ? contentViewHeight : minContentViewHeight
        myContentView.frame.size.height = contentViewHeight
        obj?.height = contentViewHeight
        
        if shouldAddImageBtn {
            let imageViewerBtn = UIButton(frame: postImageView.frame)
            imageViewerBtn.backgroundColor = UIColor.clearColor()
            imageViewerBtn.addTarget(self, action: "showImageViewer", forControlEvents: UIControlEvents.TouchUpInside)
            myContentView.addSubview(imageViewerBtn)
        }
        
        // calculate likeCommentShellHeight
        var likeCommentShellY = contentTextView.frame.origin.y + contentTextView.frame.size.height
        if (obj?.postImageURL != nil && obj?.postImageURL != "" || obj?.postImageData != nil) { likeCommentShellY += 255 }
        likeCommentShellY = likeCommentShellY >= minLikeCommentShellY ? likeCommentShellY : minLikeCommentShellY
        likeCommentShell.frame.origin.y = likeCommentShellY
        
        
        if (obj?.postImageData != nil) {
            parent.uploadImageProgressView = UIView(frame: CGRectMake(postImageView.frame.origin.x, postImageView.frame.origin.y - 3, 0, 3))
            parent.uploadImageProgressView!.backgroundColor = knackkOrange
            myContentView.addSubview(parent.uploadImageProgressView!)
        }
        
        
        // set like button
        if let hasLiked = obj?.userHasLikedPost {
            if hasLiked == true {
                likePostBtn.setTitle("Unlike", forState: UIControlState.Normal)
            } else {
                likePostBtn.setTitle("Like", forState: UIControlState.Normal)
            }
        }
        
        // set follow button
        var hasFollowed = false
        if let hasFollowedCheck = obj?.userHasFollowed {
            hasFollowed = hasFollowedCheck
        }
        if hasFollowed == true {
            followBtn.hidden = true
        } else {
            if obj?.userId == obj?.userIdToFollow {
                followBtn.hidden = true
            } else {
                followBtn.hidden = false
            }
        }
        
        // set active button
        var isActiveUser = true
        if let isActiveCheck = obj?.activeDisplayedUser {
            isActiveUser = isActiveCheck
            //println("\n Checking if User is Active: \(isActiveUser) and \(obj?.userHasFollowed) \n")
        }
        if isActiveUser == true {
            inActiveBtn.hidden = true
        } else {
            inActiveBtn.hidden = false
        }
    }
    func showImageViewer() {
        parent?.showImageViewerWithImage(postImageView.image!)
    }
    func setLikesCount (likeCount:String) {
        likeLbl.text = likeCount
        adjustLikesCommentsFrames()
    }
    func setCommentsCount (commentCount:String) {
        commentLbl.text = commentCount
        adjustLikesCommentsFrames()
    }
    func adjustLikesCommentsFrames() {
        var moreLikeSpace:CGFloat = 0
        var moreCommentSpace:CGFloat = 0
        if obj!.numLikes!.toInt() > 9 {
            moreLikeSpace = 7
        }
        if obj!.numComments!.toInt() > 9 {
            moreCommentSpace = 7
        }
        likeLbl.frame.size.width = 6 + moreLikeSpace
        likePic.frame.origin.x = 6 + moreLikeSpace
        commentLbl.frame.size.width = 6 + moreCommentSpace
        commentLbl.frame.origin.x = 30 + moreLikeSpace
        commentPic.frame.origin.x = 36 + moreLikeSpace + moreCommentSpace
        likePostBtn.frame.origin.x = 60 + moreLikeSpace + moreCommentSpace
        
        //likeLbl.frame = CGRectMake(0, 0, 6, 20)
        //likePic.frame = CGRectMake(6, 0, 20, 20)
        //commentLbl.frame = CGRectMake(30, 0, 6, 20)
        //commentPic.frame = CGRectMake(36, 0, 20, 20)
        //likePostBtn.frame = CGRectMake(60, 2, 36, 16)
    }
    func likeAction() {
        
        var newLikeTask = String()
        var newLikeIncrementer = Int()
        var newUserHasLikedPost = Bool()
        var newLikeButtonTitle = String()
        if let hasLiked = obj?.userHasLikedPost {
            if hasLiked == true {
                newLikeTask = "unlike"
                newLikeIncrementer = -1
                newUserHasLikedPost = false
                newLikeButtonTitle = "Like"
            } else {
                newLikeTask = "postLike"
                newLikeIncrementer = 1
                newUserHasLikedPost = true
                newLikeButtonTitle = "Unlike"
            }
        }
        
        // find the post and toggle Like/Unlike text, increase/decrease like count
        for (var i = 0; i < parent?.tableObjects.count; ++i) {
            let tableObject:FeedObject = parent!.tableObjects[i]
            if (tableObject.postId == obj?.postId) {
                var numLikes = tableObject.numLikes?.toInt()
                let newTotal = numLikes! + newLikeIncrementer
                tableObject.numLikes = "\(newTotal)"
                tableObject.userHasLikedPost = newUserHasLikedPost
                self.setLikesCount("\(newTotal)")
                self.likePostBtn.setTitle(newLikeButtonTitle, forState: UIControlState.Normal)
                break
            }
        }
        
        // get variables to send
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        var parameters = parametersForTask(newLikeTask)
        parameters["userId"] = (userDict["knackkId"] as String)
        parameters["postId"] = obj?.postId
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("JSON 5 \(JSON)")
                let status = JSON["status"].stringValue
                if (status == "success") {
                    // success
                } else {
                    let alert = UIAlertView(title: "Could Not Like/Unlike Post", message: "An error occurred trying to like/unlike this post. Please try again later.", delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
        }
    }
    func flagAction() {
        parent!.feedObjectToFlag = obj
        let actionSheet = UIActionSheet(title: "Flag Irrelevant?", delegate: parent!, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Flag It")
        actionSheet.showInView(parent!.view)
    }
    func doNothing() {
        
    }
    
    func followAction() {
        
        var newFollowTask = String() // follow / unfollow
        var newUserHasFollowed = Bool()
        var newFollowButtonHidden = Bool()
        if let hasFollowed = obj?.userHasFollowed {
            if hasFollowed == true {
                newFollowTask = "unfollow"
                newUserHasFollowed = false
                newFollowButtonHidden = false
            } else {
                newFollowTask = "follow"
                newUserHasFollowed = true
                newFollowButtonHidden = true
            }
        }
        
        // hide follow button for the followed user
        for (var i = 0; i < parent?.tableObjects.count; ++i) {
            let tableObject:FeedObject = parent!.tableObjects[i]
            println("iterating through parent.tableObjects, id: \(tableObject.postId), title: \(tableObject.contentText)")
            if (tableObject.postId == obj?.postId) {
                tableObject.userHasFollowed = newUserHasFollowed
                self.followBtn.hidden = newFollowButtonHidden
                break
            }
        }
        
        // get variables to send
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        var parameters = parametersForTask(newFollowTask)
        let followerId = userDict["knackkId"] as String
        let leaderId = obj!.userIdToFollow!
        parameters["followerId"] = followerId
        parameters["leaderId"] = leaderId
        
        println("parameters: \(parameters)")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("JSON 6 \(JSON)")
                let status = JSON["status"].stringValue
                if (status == "success") {
                    // success
                    self.parent!.adjustFollowButtonsForFollowedUser(self.obj!.userIdToFollow!)
                } else {
                    self.followBtn.hidden = !newFollowButtonHidden
                    let alert = UIAlertView(title: "Could Not Follow / Unfollow", message: "\nAn error occurred trying to\nfollow / unfollow this user.\n\nPlease try again later.\n\nError: L\(leaderId)F\(followerId)", delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
        }
    }
    func showProfileAction() {
        var profileId = obj?.userId
        if obj?.userIdToFollow != nil {
            profileId = obj?.userIdToFollow
        }
        
        if !obj!.userIdToFollow!.isEmpty {
            var username = ""
            var imageUrl = ""
            for i in 0..<parent!.companyUsersArray!.count {
                let thisUser = parent!.companyUsersArray![i]
                if thisUser.userId == profileId {
                    username = thisUser.userName
                    imageUrl = thisUser.pictureUrl
                }
            }
            let vc = ShowProfileVC(segment: nil, fetchCoworkers: false, navBarType: "child", userName: username, userImageUrl: imageUrl, toViewProfileId: profileId!)
            parent!.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = LeaveCommentVC(parent: parent, tableObjs: parent!.tableObjects, postId: obj!.postId!, showKeyboard:true)
            parent?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class NewsArticleCell:UITableViewCell {
    
    var parent:MyFeedBaseVC?
    
    var obj:FeedObject?
    var myContentView = UIView()
    var userImageView = UIImageView()
    var usernameBtn = UIButton()
    var timeLbl = UILabel()
    var contentTextView = UITextView()
    
    // like / comment indicators
    var likeCommentShell = UIView()
    var likeLbl = UILabel()
    var likePic = UIImageView()
    var commentLbl = UILabel()
    var commentPic = UIImageView()
    var likePostBtn = UIButton()
    var flagBtn = UIButton()
    
    
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String!, parent:MyFeedBaseVC) {
        self.init(style:style, reuseIdentifier:reuseIdentifier)
        self.parent = parent
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        
        // white background
        myContentView.frame = CGRectMake(8, 0, 304, 79)
        myContentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(myContentView)
        
        // user image
        userImageView.frame = CGRectMake(5, 5, 44, 44)
        userImageView.image = UIImage(named: "Icon")
        myContentView.addSubview(userImageView)
        
        // content text view
        contentTextView.frame = CGRectMake(50, 28, 253, 20) // 50, 12, 253, 20
        contentTextView.editable = false
        contentTextView.scrollEnabled = false
        contentTextView.font = UIFont(name: "Verdana", size: 11)
        contentTextView.textColor = UIColor(white: 0.5, alpha: 1)
        contentTextView.backgroundColor = UIColor.whiteColor()
        contentTextView.dataDetectorTypes = UIDataDetectorTypes.All
        myContentView.addSubview(contentTextView)
        
        // username label
        usernameBtn.frame = CGRectMake(52, 1, 242, 20) // 54, 1, 155, 20
        usernameBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        usernameBtn.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)
        usernameBtn.titleLabel!.numberOfLines = 0
        //usernameBtn.addTarget(self, action: "showProfileAction", forControlEvents: UIControlEvents.TouchUpInside)
        myContentView.addSubview(usernameBtn)
        
        // time label
        timeLbl.frame = CGRectMake(64, 18, 85, 20) // myContentView.frame.size.width-90, 1, 85, 20
        timeLbl.textColor = UIColor.lightGrayColor()
        timeLbl.font = UIFont(name: "Verdana", size: 10)
        timeLbl.textAlignment = NSTextAlignment.Left
        myContentView.addSubview(timeLbl)
        
        // like / comment indicator
        likeCommentShell.frame = CGRectMake(54, 54, 245, 20)
        likeCommentShell.backgroundColor = UIColor.whiteColor()
        myContentView.addSubview(likeCommentShell)
        // like label
        likeLbl.frame = CGRectMake(0, 0, 6, 20)
        likeLbl.font = UIFont(name: "Verdana", size: 10)
        likeLbl.textAlignment = NSTextAlignment.Right
        likeLbl.textColor = UIColor.darkGrayColor()
        likeLbl.text = "0"
        likeCommentShell.addSubview(likeLbl)
        // like pic
        likePic.frame = CGRectMake(6, 0, 20, 20)
        likePic.image = UIImage(named: "likeIndicator")
        likeCommentShell.addSubview(likePic)
        // comment label
        commentLbl.frame = CGRectMake(30, 0, 6, 20)
        commentLbl.font = UIFont(name: "Verdana", size: 10)
        commentLbl.textAlignment = NSTextAlignment.Right
        commentLbl.textColor = UIColor.darkGrayColor()
        commentLbl.text = "0"
        likeCommentShell.addSubview(commentLbl)
        // comment pic
        commentPic.frame = CGRectMake(36, 0, 20, 20)
        commentPic.image = UIImage(named: "commentIndicator")
        likeCommentShell.addSubview(commentPic)
        // like button
        likePostBtn.frame = CGRectMake(60, 2, 36, 16)
        likePostBtn.setBackgroundImage(buttonImage(likePostBtn.frame.size, 2, 0, knackkLightGray, knackkLightGray), forState: UIControlState.Normal)
        likePostBtn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        likePostBtn.setTitle("Like", forState: UIControlState.Normal)
        likePostBtn.titleLabel?.font = UIFont(name: "Verdana", size: 10)
        likePostBtn.addTarget(self, action: "likeAction", forControlEvents: UIControlEvents.TouchUpInside)
        likeCommentShell.addSubview(likePostBtn)
        // flag button
        flagBtn.frame = CGRectMake(245-36, 2, 36, 16)
        flagBtn.setBackgroundImage(buttonImage(flagBtn.frame.size, 2, 0, knackkLightGray, knackkLightGray), forState: UIControlState.Normal)
        flagBtn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        flagBtn.setTitle("Flag", forState: UIControlState.Normal)
        flagBtn.titleLabel?.font = UIFont(name: "Verdana", size: 10)
        flagBtn.addTarget(self, action: "flagAction", forControlEvents: UIControlEvents.TouchUpInside)
        likeCommentShell.addSubview(flagBtn)
        
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUserImage (userImageString:String) {
        if userImageString == "" || userImageString == "null" || userImageString.isEmpty {
            userImageView.image = UIImage(named: "defaultUser.jpg")
        } else {
            // load from cache if cached; if not, load from internet
            if let cacheImage = self.parent!.imageCacheManager.imageFromCacheForUrl(userImageString) {
                self.userImageView.image = cacheImage
            } else {
                var url = NSURL(string: userImageString)
                var image: UIImage?
                var request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    self.userImageView.image = UIImage(data: data)
                    self.parent!.imageCacheManager.cacheImageForUrl(userImageString, type: "profilePicture", imageData: data)
                })
            }
        }
    }
    func setUsername (username:String) {
        usernameBtn.setTitle(username, forState: UIControlState.Normal)
        // resize
        let dict = [NSFontAttributeName:usernameBtn.titleLabel!.font]
        let stringsize = (username as NSString).sizeWithAttributes(dict)
        var width = stringsize.width
        if width > 240 {
            width = 240
        }
        usernameBtn.frame.size.width = width
        usernameBtn.frame.size.width = usernameBtn.titleLabel!.frame.size.width + 8
        //usernameBtn.frame.size.height = usernameBtn.titleLabel!.frame.size.height + 8
    }
    func setTimeAgo (timeAgo:String) {
        timeLbl.text = timeAgo
    }
    func setContentText (contentText:NSMutableAttributedString) {
        contentTextView.attributedText = contentText
        contentTextView.delegate = parent!
    }
    func formatCell(feedObj:FeedObject, parent:MyFeedBaseVC) {
        
        let minContentViewHeight:CGFloat = 79
        let minLikeCommentShellY:CGFloat = 54
        
        
        
        // calculate title height
        var titleHeight = heightForView(feedObj.username!, usernameBtn.titleLabel!.font, usernameBtn.titleLabel!.frame.size.width)
        //println("newsArticleCell -> formatCell -> titleHeight: \(titleHeight)")
        if (titleHeight < 40) { titleHeight = 40 }
        usernameBtn.frame.size.height = titleHeight - 20
        usernameBtn.frame.size.height = usernameBtn.titleLabel!.frame.size.height + 8
        
        
        // adjust time label and content view text from title height
        timeLbl.frame.origin.y = usernameBtn.frame.origin.y + usernameBtn.frame.size.height - 5
        contentTextView.frame.origin.y = usernameBtn.frame.origin.y + usernameBtn.frame.size.height + 7
        
        
        // calculate text height
        var height = heightForView(feedObj.attributedContentText!, contentTextView.font, contentTextView.frame.size.width-10)
        if (height < 20) { height = 20 }
        contentTextView.frame.size.height = height
        
        // calculate contentViewHeight & obj.height
        /*var contentViewHeight = contentTextView.frame.origin.y + height + 25 + 5 // 25 = likeCommentShell.height + 5 bottom padding, 10 = a buffer
        contentViewHeight = contentViewHeight >= minContentViewHeight ? contentViewHeight : minContentViewHeight
        myContentView.frame.size.height = contentViewHeight
        obj?.height = contentViewHeight*/
        
        myContentView.frame.size.height = obj!.height
        
        // calculate likeCommentShellHeight
        var likeCommentShellY = contentTextView.frame.origin.y + contentTextView.frame.size.height
        if (obj?.postImageURL != nil && obj?.postImageURL != "" || obj?.postImageData != nil) { likeCommentShellY += 255 }
        likeCommentShellY = likeCommentShellY >= minLikeCommentShellY ? likeCommentShellY : minLikeCommentShellY
        likeCommentShell.frame.origin.y = likeCommentShellY
        
        // set like button
        if let hasLiked = obj?.userHasLikedPost {
            if hasLiked == true {
                likePostBtn.setTitle("Unlike", forState: UIControlState.Normal)
            } else {
                likePostBtn.setTitle("Like", forState: UIControlState.Normal)
            }
        }
    }
    func setLikesCount (likeCount:String) {
        likeLbl.text = likeCount
        adjustLikesCommentsFrames()
    }
    func setCommentsCount (commentCount:String) {
        commentLbl.text = commentCount
        adjustLikesCommentsFrames()
    }
    func adjustLikesCommentsFrames() {
        var moreLikeSpace:CGFloat = 0
        var moreCommentSpace:CGFloat = 0
        if obj!.numLikes!.toInt() > 9 {
            moreLikeSpace = 7
        }
        if obj!.numComments!.toInt() > 9 {
            moreCommentSpace = 7
        }
        likeLbl.frame.size.width = 6 + moreLikeSpace
        likePic.frame.origin.x = 6 + moreLikeSpace
        commentLbl.frame.size.width = 6 + moreCommentSpace
        commentLbl.frame.origin.x = 30 + moreLikeSpace
        commentPic.frame.origin.x = 36 + moreLikeSpace + moreCommentSpace
        likePostBtn.frame.origin.x = 60 + moreLikeSpace + moreCommentSpace
        
        //likeLbl.frame = CGRectMake(0, 0, 6, 20)
        //likePic.frame = CGRectMake(6, 0, 20, 20)
        //commentLbl.frame = CGRectMake(30, 0, 6, 20)
        //commentPic.frame = CGRectMake(36, 0, 20, 20)
        //likePostBtn.frame = CGRectMake(60, 2, 36, 16)
    }
    func likeAction() {
        
        var newLikeTask = String()
        var newLikeIncrementer = Int()
        var newUserHasLikedPost = Bool()
        var newLikeButtonTitle = String()
        if let hasLiked = obj?.userHasLikedPost {
            if hasLiked == true {
                newLikeTask = "unlike"
                newLikeIncrementer = -1
                newUserHasLikedPost = false
                newLikeButtonTitle = "Like"
            } else {
                newLikeTask = "postLike"
                newLikeIncrementer = 1
                newUserHasLikedPost = true
                newLikeButtonTitle = "Unlike"
            }
        }
        
        // find the post and toggle Like/Unlike text, increase/decrease like count
        for (var i = 0; i < parent?.tableObjects.count; ++i) {
            let tableObject:FeedObject = parent!.tableObjects[i]
            if (tableObject.postId == obj?.postId) {
                var numLikes = tableObject.numLikes?.toInt()
                let newTotal = numLikes! + newLikeIncrementer
                tableObject.numLikes = "\(newTotal)"
                tableObject.userHasLikedPost = newUserHasLikedPost
                self.setLikesCount("\(newTotal)")
                self.likePostBtn.setTitle(newLikeButtonTitle, forState: UIControlState.Normal)
                break
            }
        }
        
        // get variables to send
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        var parameters = parametersForTask(newLikeTask)
        parameters["userId"] = (userDict["knackkId"] as String)
        parameters["postId"] = obj?.postId
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("JSON 7 \(JSON)")
                let status = JSON["status"].stringValue
                if (status == "success") {
                    // success
                } else {
                    let alert = UIAlertView(title: "Could Not Like/Unlike Post", message: "An error occurred trying to like/unlike this post. Please try again later.", delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
        }
    }
    func flagAction() {
        parent!.feedObjectToFlag = obj
        let actionSheet = UIActionSheet(title: "Flag Irrelevant?", delegate: parent!, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Flag It")
        actionSheet.showInView(parent!.view)
    }
    func showProfileAction() {
        let vc = LeaveCommentVC(parent: parent, tableObjs: parent!.tableObjects, postId: obj!.postId!, showKeyboard:false)
        parent?.navigationController?.pushViewController(vc, animated: true)
    }
}

class UserCommentCell:UITableViewCell {
    
    var parent:MyFeedBaseVC?
    var obj:FeedObject?
    
    var myContentView = UIView()
    var userImageView = UIImageView()
    var usernameBtn = UIButton()
    //var usernameLbl = UILabel()
    var timeLbl = UILabel()
    var contentTextView = UITextView()
    
    // like / comment indicators
    var likeShell = UIView()
    var likeLbl = UILabel()
    var likePic = UIImageView()
    
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String!, parent:MyFeedBaseVC) {
        self.init(style:style, reuseIdentifier:reuseIdentifier)
        self.parent = parent
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        
        // white background
        myContentView.frame = CGRectMake(8, 0, 304, 44) // h: 75
        myContentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(myContentView)
        
        // user image
        userImageView.frame = CGRectMake(54, 5, 34, 34)
        myContentView.addSubview(userImageView)
        
        // username label
        usernameBtn.frame = CGRectMake(93, 1, 130, 20)
        usernameBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        usernameBtn.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)
        usernameBtn.addTarget(self, action: "showProfileAction", forControlEvents: UIControlEvents.TouchUpInside)
        myContentView.addSubview(usernameBtn)
        
        // username label
        //usernameLbl.frame = CGRectMake(93, 1, 130, 20)
        //usernameLbl.textColor = UIColor.blackColor()
        //usernameLbl.font = UIFont(name: "Verdana-Bold", size: 12)
        //myContentView.addSubview(usernameLbl)
        
        // time label
        timeLbl.frame = CGRectMake(myContentView.frame.size.width-65, 1, 60, 20)
        timeLbl.textColor = UIColor.lightGrayColor()
        timeLbl.font = UIFont(name: "Verdana", size: 10)
        timeLbl.textAlignment = NSTextAlignment.Right
        myContentView.addSubview(timeLbl)
        
        // content text view CGRectMake(50, 12, 253, 20) // 54, 20, 245, 20
        contentTextView.frame = CGRectMake(89, 12, 214, 44 - 20) // 93, 20, 206, 44 - 20
        contentTextView.editable = false
        contentTextView.scrollEnabled = false
        //contentTextView.numberOfLines = 0
        contentTextView.font = UIFont(name: "Verdana", size: 11)
        contentTextView.textColor = UIColor(white: 0.5, alpha: 1)
        contentTextView.backgroundColor = UIColor.clearColor()
        contentTextView.dataDetectorTypes = UIDataDetectorTypes.All
        myContentView.addSubview(contentTextView)
        
        /*/ like / comment indicator
        likeShell.frame = CGRectMake(93, 50, 100, 20)
        likeShell.backgroundColor = UIColor.whiteColor()
        myContentView.addSubview(likeShell)
        // like label
        likeLbl.frame = CGRectMake(0, 0, 6, 20)
        likeLbl.font = UIFont(name: "Verdana", size: 10)
        likeLbl.textAlignment = NSTextAlignment.Right
        likeLbl.textColor = UIColor.darkGrayColor()
        likeLbl.text = "0"
        likeShell.addSubview(likeLbl)
        // like pic
        likePic.frame = CGRectMake(6, 0, 20, 20)
        likePic.image = UIImage(named: "likeIndicator")
        likeShell.addSubview(likePic)*/
    }
    
    // methods
    func setUserImage (userImageString:String) {
        if userImageString == "" || userImageString == "null" || userImageString.isEmpty {
            userImageView.image = UIImage(named: "defaultUser.jpg")
        } else {
            // load from cache if cached; if not, load from internet
            if let cacheImage = parent!.imageCacheManager.imageFromCacheForUrl(userImageString) {
                self.userImageView.image = cacheImage
            } else {
                var url = NSURL(string: userImageString)
                var request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    self.userImageView.image = UIImage(data: data)
                    self.parent!.imageCacheManager.cacheImageForUrl(userImageString, type: "profilePicture", imageData: data)
                })
            }
        }
    }
    func setUsername (username:String) {
        usernameBtn.setTitle(username, forState: UIControlState.Normal)
        // resize
        let dict = [NSFontAttributeName:usernameBtn.titleLabel!.font]
        let stringsize = (username as NSString).sizeWithAttributes(dict)
        usernameBtn.frame.size.width = stringsize.width
    }
    func setTimeAgo (timeAgo:String) {
        timeLbl.text = timeAgo
    }
    func setContentText (contentText:String) {
        contentTextView.text = contentText
        contentTextView.delegate = parent!
        contentTextView.frame.size.height = heightForView(contentText, contentTextView.font, contentTextView.frame.size.width)
        myContentView.frame.size.height = obj!.height
    }
    func showProfileAction() {
        var profileId = obj?.userId
        if obj?.userIdToFollow != nil {
            profileId = obj?.userIdToFollow
        }
        
        var username = "Loading"
        var imageUrl = ""
        for i in 0..<parent!.companyUsersArray!.count {
            let thisUser = parent!.companyUsersArray![i]
            if thisUser.userId == obj?.userIdToFollow {
                username = thisUser.userName
                imageUrl = thisUser.pictureUrl
                break
            }
        }
        let vc = ShowProfileVC(segment: nil, fetchCoworkers: false, navBarType: "child", userName: username, userImageUrl: imageUrl, toViewProfileId: profileId!)
        parent!.navigationController?.pushViewController(vc, animated: true)
    }
}

class ShowEntirePostCell:UITableViewCell {
    
    //var myContentView = UIView()
    //var contentTextView = UITextView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        
        // white background
        let myContentView = UIView(frame: CGRectMake(8, 0, 304, 44)) // h: 75
        myContentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(myContentView)
        
        // content label
        let contentLbl = UILabel(frame: CGRectMake(96, 0, 150, 44))
        contentLbl.userInteractionEnabled = false
        contentLbl.font = UIFont(name: "Verdana", size: 11)
        contentLbl.textColor = UIColor(white: 0.5, alpha: 1)
        contentLbl.backgroundColor = UIColor.clearColor()
        contentLbl.text = "Show All Comments"
        myContentView.addSubview(contentLbl)
        
        let topBorder = UIView(frame: CGRectMake(49, 5, 250, 1))
        topBorder.backgroundColor = knackkLightGray
        myContentView.addSubview(topBorder)
        
        let botBorder = UIView(frame: CGRectMake(49, 38, 250, 1))
        botBorder.backgroundColor = knackkLightGray
        myContentView.addSubview(botBorder)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PostACommentCell:UITableViewCell {
    
    var parent:MyFeedBaseVC?
    var obj:FeedObject?
    
    var myContentView = UIView()
    var userImageView = UIImageView()
    var usernameLbl = UILabel()
    var leaveCommentBtn = UIButton()
    
    convenience init (style: UITableViewCellStyle, reuseIdentifier: String!, parent:MyFeedBaseVC, obj:FeedObject) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        self.parent = parent
        self.obj = obj
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        
        // white background
        myContentView.frame = CGRectMake(8, 0, 304, 53)
        myContentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(myContentView)
        
        // user image
        userImageView.frame = CGRectMake(54, 5, 34, 34)
        myContentView.addSubview(userImageView)
        
        // username label
        usernameLbl.frame = CGRectMake(93, 1, 130, 20)
        usernameLbl.textColor = UIColor.blackColor()
        usernameLbl.font = UIFont(name: "Verdana-Bold", size: 12)
        myContentView.addSubview(usernameLbl)
        
        // input text btn
        leaveCommentBtn.frame = CGRectMake(93, 22, 206, 26)
        leaveCommentBtn.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        leaveCommentBtn.titleLabel?.font = UIFont(name: "Verdana", size: 11)
        leaveCommentBtn.setTitle("Leave a Comment                     ", forState: UIControlState.Normal)
        leaveCommentBtn.titleLabel?.textAlignment = NSTextAlignment.Left
        leaveCommentBtn.backgroundColor = UIColor(white: 0.95, alpha: 1)
        leaveCommentBtn.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        leaveCommentBtn.layer.borderWidth = 1
        leaveCommentBtn.layer.cornerRadius = 3
        leaveCommentBtn.clipsToBounds = true
        leaveCommentBtn.addTarget(self, action: "leaveCommentAction", forControlEvents: UIControlEvents.TouchUpInside)
        myContentView.addSubview(leaveCommentBtn)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*convenience init (feedObject:FeedObject, style: UITableViewCellStyle, reuseIdentifier: String!) {
    self.init(style: style, reuseIdentifier: reuseIdentifier)
    self.obj = feedObject
    }*/
    
    func setUserImage (userImageString:String) {
        //userImageView.image = UIImage(named: userImage)
        if userImageString == "" || userImageString == "null" || userImageString.isEmpty {
            userImageView.image = UIImage(named: "defaultUser.jpg")
        } else {
            // load from cache if cached; if not, load from internet
            if let cacheImage = self.parent!.imageCacheManager.imageFromCacheForUrl(userImageString) {
                self.userImageView.image = cacheImage
            } else {
                var url = NSURL(string: userImageString)
                var image: UIImage?
                var request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    self.userImageView.image = UIImage(data: data)
                    self.parent!.imageCacheManager.cacheImageForUrl(userImageString, type: "profilePicture", imageData: data)
                })
            }
        }
    }
    func setUsername (username:String) {
        usernameLbl.text = username
    }
    func leaveCommentAction() {
        let vc = LeaveCommentVC(parent: parent, tableObjs: parent!.tableObjects, postId: obj!.postId!, showKeyboard:true)
        parent?.navigationController?.pushViewController(vc, animated: true)
    }
}

class NotificationCell:UITableViewCell {
    
    var parent:MyFeedExtraBaseVC?
    var myContentView = UIView()
    var userImageView = UIImageView()
    var usernameLbl = UILabel()
    var notificationLbl = UILabel()
    var timeLbl = UILabel()
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String!, parent:MyFeedExtraBaseVC) {
        self.init(style:style, reuseIdentifier:reuseIdentifier)
        self.parent = parent
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        
        // white background
        myContentView.frame = CGRectMake(0, 0, 320, 56) // 056.0
        myContentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(myContentView)
        
        // user image
        userImageView.frame = CGRectMake(0, 0, 56, 56)
        myContentView.addSubview(userImageView)
        
        // username label
        usernameLbl.frame = CGRectMake(66, 2, 220, 20)
        usernameLbl.textColor = UIColor.blackColor()
        usernameLbl.font = UIFont(name: "Verdana-Bold", size: 12)
        myContentView.addSubview(usernameLbl)
        
        // notification label
        notificationLbl.frame = CGRectMake(66, 22, 170, 16)
        notificationLbl.textColor = UIColor.blackColor()
        notificationLbl.font = UIFont(name: "Verdana", size: 12)
        myContentView.addSubview(notificationLbl)
        
        // time label
        timeLbl.frame = CGRectMake(72, 38, 160, 14)
        timeLbl.textColor = UIColor.lightGrayColor()
        timeLbl.font = UIFont(name: "Verdana", size: 10)
        myContentView.addSubview(timeLbl)
        
        /*/ bottom border
        let bottomBorder = UIView(frame: CGRectMake(0, 56, 320, 1))
        bottomBorder.backgroundColor = UIColor(white: 0.84, alpha: 1)
        myContentView.addSubview(bottomBorder)*/
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUserImage (userImageString:String) {
        if userImageString == "" || userImageString == "null" || userImageString.isEmpty {
            userImageView.image = UIImage(named: "defaultUser.jpg")
        } else {
            // load from cache if cached; if not, load from internet
            if let cacheImage = parent!.imageCacheManager.imageFromCacheForUrl(userImageString) {
                self.userImageView.image = cacheImage
            } else {
                var url = NSURL(string: userImageString)
                var request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    self.userImageView.image = UIImage(data: data)
                    self.parent!.imageCacheManager.cacheImageForUrl(userImageString, type: "profilePicture", imageData: data)
                })
            }
        }
    }
    func setUserNameText (usernameText:String) {
        usernameLbl.text = usernameText
    }
    func setNotificationText (contentText:String) {
        notificationLbl.text = contentText
    }
    func setTimeAgo (timeAgo:String) {
        timeLbl.text = timeAgo
    }
}

class NotificationSettingCell:UITableViewCell {
    
    var feedObj:FeedObject?
    var myContentView = UIView()
    var usernameLbl = UILabel()
    var notificationLbl = UILabel()
    var settingSwitch = UISwitch()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        
        // white background
        myContentView.frame = CGRectMake(0, 0, 320, 45)
        myContentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(myContentView)
        
        // notification label
        notificationLbl.frame = CGRectMake(12, 0, 260, 44)
        notificationLbl.textColor = UIColor.blackColor()
        notificationLbl.font = UIFont(name: "Verdana", size: 13)
        myContentView.addSubview(notificationLbl)
        
        // settings switch
        settingSwitch.frame = CGRectMake(259, 6, 51, 31)
        settingSwitch.on = true
        settingSwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        myContentView.addSubview(settingSwitch)
        
        // bottom border
        let bottomBorder = UIView(frame: CGRectMake(0, 44, 320, 1))
        bottomBorder.backgroundColor = UIColor(white: 0.84, alpha: 1)
        myContentView.addSubview(bottomBorder)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setNotificationText (contentText:String) {
        notificationLbl.text = contentText
    }
    func setSwitchState(isOn:Bool) {
        settingSwitch.on = isOn
    }
    func stateChanged(switchState: UISwitch) {
        if switchState.on {
            feedObj!.isEnabled = true
        } else {
            feedObj!.isEnabled = false
        }
        feedObj!.parentExtra!.tableObjects[feedObj!.cellIndex!] = feedObj!
    }
}

class SearchBarCell:UITableViewCell {
    
    var parent:MyFeedBaseVC?
    var searchBar = UISearchBar()
    
    convenience init (style: UITableViewCellStyle, reuseIdentifier: String!, parent:MyFeedBaseVC) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        self.parent = parent
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        
        // search bar
        searchBar.frame = CGRectMake(0, 0, 320, 44)
        searchBar.placeholder = "Search for people you know"
        searchBar.barTintColor = knackkOrange
        self.contentView.addSubview(searchBar)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configureCell() {
        if (parent != nil) {
            searchBar.delegate = self.parent!
            searchBar.inputAccessoryView = KeyboardBar(parent: self.parent!)
        }
    }
}

class FollowCoworkerCell: UITableViewCell {
    var parent:MyFeedBaseVC?
    var feedObj:FeedObject?
    var isFollowing = false
    var userImageView:UIImageView?
    var usernameLbl:UILabel?
    var leaderId:String?
    var followerId:String?
    var followBtn:UIButton?
    var followIndicator:UIActivityIndicatorView?
    //var followedView:UIImageView?
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = knackkOrange
        
        // user image
        userImageView = UIImageView(frame: CGRectMake(8, 8, 44, 44))
        self.contentView.addSubview(userImageView!)
        
        // username label
        usernameLbl = UILabel(frame: CGRectMake(68, 8, 194, 44))
        usernameLbl!.textColor = UIColor.whiteColor()
        usernameLbl!.font = UIFont(name: "Verdana-Bold", size: 14)
        self.contentView.addSubview(usernameLbl!)
        
        // follow button
        followBtn = UIButton(frame: CGRectMake(268, 8, 44, 44))
        followBtn!.setBackgroundImage(UIImage(named: "FollowBtn"), forState: UIControlState.Normal)
        followBtn!.addTarget(self, action: "followBtnAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.contentView.addSubview(followBtn!)
        
        // follow indicator
        followIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        followIndicator!.frame = CGRectMake(268, 8, 44, 44)
        followIndicator!.hidden = true
        self.contentView.addSubview(followIndicator!)
        
        /*/ followed view
        followedView = UIImageView(frame: CGRectMake(268, 8, 44, 44))
        followedView!.hidden = true
        followedView!.image = UIImage(named: "FollowedView")
        self.contentView.addSubview(followedView!)*/
        
        // bottom border
        let botBorder = UIView(frame: CGRectMake(0, 60, 320, 1))
        botBorder.backgroundColor = knackkLightOrange
        self.contentView.addSubview(botBorder)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setParent(parent:MyFeedBaseVC) {
        self.parent = parent
    }
    func setUserImage (userImage:String, cacheManager:ImageCacheManager) {
        if userImage == "" || userImage == "null" || userImage.isEmpty || userImage == "defaultUser.jpg" {
            userImageView!.image = UIImage(named: "defaultUser.jpg")
        } else {
            // load from cache if cached; if not, load from internet
            if let cacheImage = cacheManager.imageFromCacheForUrl(userImage) {
                userImageView!.image = cacheImage
            } else {
                var url = NSURL(string: userImage)
                var image: UIImage?
                var request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    self.userImageView!.image = UIImage(data: data)
                    cacheManager.cacheImageForUrl(userImage, type: "profilePicture", imageData: data)
                })
            }
        }
    }
    func setUsername (username:String) {
        usernameLbl!.text = username
        
        // hide button if self
        if feedObj?.userId == feedObj?.userIdToFollow {
            followBtn!.hidden = true
        } else {
            followBtn!.hidden = false
        }
    }
    func setFollowingButton (thisIsFollowing:Bool) {
        self.isFollowing = thisIsFollowing
        self.feedObj!.userHasFollowed = self.isFollowing
        if self.isFollowing {
            followBtn!.setBackgroundImage(UIImage(named: "FollowedView"), forState: UIControlState.Normal)
        } else {
            followBtn!.setBackgroundImage(UIImage(named: "FollowBtn"), forState: UIControlState.Normal)
        }
    }
    func followBtnAction() {
        
        followBtn!.hidden = true
        followIndicator!.hidden = false
        followIndicator!.startAnimating()
        
        var task = "follow"
        if isFollowing {
            task = "unfollow"
        }
        
        
        // follow
        var parameters = parametersForTask(task)
        parameters["followerId"] = followerId!
        parameters["leaderId"] = leaderId!
        println("paramters: \(parameters)")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON 8 \(JSON)")
                println("ERROR \(error)")
                
                let status = JSON["status"].stringValue
                if (status == "success") {
                    
                    //let alert = UIAlertView(title: "Followed", message: "Eventually, this will simply update the button to show followed, instead of show this alert.", delegate: nil, cancelButtonTitle: "Okay")
                    //alert.show()
                    
                    self.followIndicator!.hidden = true
                    self.followBtn!.hidden = false
                    
                    self.isFollowing = !self.isFollowing
                    self.setFollowingButton(self.isFollowing)
                    
                    if self.isFollowing {
                        self.parent?.incrementFollowingCount(1)
                    } else {
                        self.parent?.incrementFollowingCount(-1)
                    }
                    
                    //self.followedView!.hidden = false;
                    
                } else {
                    println("failure")
                    self.followIndicator!.hidden = true
                    //self.followedView!.hidden = false;
                    let alert = UIAlertView(title: "Could Not Follow", message: "An error occurred trying to follow this user. Please try again later.", delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
        }
    }
}

class FeedObject:NSObject {
    
    var parent:MyFeedBaseVC?
    var parentExtra:MyFeedExtraBaseVC?
    
    var height:CGFloat = 54.0
    var type:Type
    var postId:String?
    //var objectId:String?
    var userId:String?
    var userIdToFollow:String?
    var username:String?
    var userTitle:String?
    var userImage:String?
    var timeString:String?
    var contentText:String?
    var attributedContentText:NSMutableAttributedString?
    var postImageURL:String?
    var postImageData:NSData?
    var postImage:UIImage?
    var numComments:String?
    var numLikes:String?
    var numFollowers:String?
    var numFollowing:String?
    
    //revision
    var activeDisplayedUser = false
    
    var userHasFollowed = false
    var userHasLikedPost = false
    var isEditable = true
    var isEnabled = true
    var thisLoadingCellCanRequestFromServer = false
    var cellIndex:Int?
    var inviteeEmail:String?
    var selectionStyle = UITableViewCellSelectionStyle.None
    var setSelectedIndex:Int?
    
    init(type:Type) {
        self.type = type
        if (type == .Separator)             { height = 008.0 }
        if (type == .Loading)               { height =  50.0 }
        if (type == .VerifyEmail)           { height =  88.0 }
        if (type == .UpdateStatus)          { height =  68.0 } // 123.0
        if (type == .ProfileBadge)          { height = 145.0 } // 125.0
        if (type == .UserPost)              { height = 079.0 }
        if (type == .NewsArticle)           { height = 079.0 }
        if (type == .UserComment)           { height = 044.0 } // 075.0
        if (type == .ShowEntirePost)        { height = 044.0 }
        if (type == .PostAComment)          { height = 053.0 }
        if (type == .Notification)          { height = 056.0 }
        if (type == .NotificationSetting)   { height = 045.0 }
        if (type == .Instructions)          { height = 045.0 }
        if (type == .FollowCoworker)        { height = 061.0 }
        if (type == .InviteCoworker)        { height = 061.0 }
        if (type == .SearchBar)             { height = 044.0 }
    }
    convenience init(type:Type, username:String, userImage:String) {
        self.init(type:type)
        self.username = username
        self.userImage = userImage
    }
    convenience init(type:Type, username:String, userImage:String, parent:MyFeedBaseVC) {
        self.init(type:type)
        self.username = username
        self.userImage = userImage
        self.parent = parent
    }
    
    enum Type {
        case Separator, VerifyEmail, Loading, UpdateStatus, ProfileBadge, UserPost, NewsArticle, UserComment, ShowEntirePost, PostAComment, Notification, NotificationSetting, Instructions, SearchBar, FollowCoworker, InviteCoworker
    }
    
    func checkForTagsAndHyperlink(text:String, newsUrl:String?, thisParent:MyFeedBaseVC) -> NSMutableAttributedString {
        
        // if companyUsersArray == nil, attempt fetch
        if thisParent.companyUsersArray == nil {
            
            // init core data
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context = appDelegate.managedObjectContext
            let entity = NSEntityDescription.entityForName("CompanyUsers", inManagedObjectContext: context!)
            thisParent.companyUsersArray = Array()
            var error:NSError?
            
            // delete previous users
            var fetchRequest = NSFetchRequest()
            fetchRequest.entity = entity
            let result:NSArray = context!.executeFetchRequest(fetchRequest, error: &error)!
            for i in 0 ..< result.count {
                thisParent.companyUsersArray?.append(result.objectAtIndex(i) as CompanyUsers)
            }
        }
        
        var holderString = NSMutableString(string: text)
        var returnString = NSMutableAttributedString(string: text)
        returnString.addAttribute(NSFontAttributeName, value: UIFont(name: "Verdana", size: 11)!, range: NSMakeRange(0, returnString.length))
        returnString.addAttribute(NSForegroundColorAttributeName, value: UIColor(white: 0.5, alpha: 1), range: NSMakeRange(0, returnString.length))
        
        // find all tags (between :::@ and :::)
        let tags = NSMutableArray()
        let scanner = NSScanner(string: text)
        scanner.scanUpToString(":::@", intoString: nil)
        while !scanner.atEnd {
            var tagString:NSString?
            scanner.scanString(":::@", intoString: nil)
            if scanner.scanUpToString(":::", intoString: &tagString) {
                tags.addObject(tagString!)
            }
            scanner.scanUpToString(":::@", intoString: nil)
        }
        
        
        // using core data, replace occurances of tag with taggee's full name and link to id
        if tags.count > 0 {
            
            for i in 0 ..< tags.count {
                for j in 0 ..< thisParent.companyUsersArray!.count {
                    let user = thisParent.companyUsersArray![j] as CompanyUsers
                    if user.emailPrefix == tags.objectAtIndex(i) as NSString {
                        
                        let wholeTag = ":::@\(tags.objectAtIndex(i)):::" as NSString
                        let url = NSURL(string: "knackk:::viewProfileId===\(user.userId)")
                        
                        var range = holderString.rangeOfString(wholeTag)
                        holderString.replaceCharactersInRange(range, withString: user.userName)
                        returnString.replaceCharactersInRange(range, withString: user.userName)
                        range = NSMakeRange(range.location, user.userName.utf16Count)
                        returnString.addAttribute(NSLinkAttributeName, value: url!, range: range)
                        returnString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: range)
                        
                        break
                    }
                }
            }
        }
        
        // append "Read Full Article" if news article
        if newsUrl != nil && !newsUrl!.isEmpty {
            returnString.mutableString.setString("")
            let url = NSURL(string: "knackk:::showNewsArticle===\(newsUrl!)")
            let attributes = [NSLinkAttributeName:url!, NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue]
            let readMoreAttributedString = NSAttributedString(string: "Read", attributes: attributes)
            returnString.appendAttributedString(NSAttributedString(string: " "))
            returnString.appendAttributedString(readMoreAttributedString)
        }
        
        return returnString
    }
    
    func setUserPostHeightWithText(title:String?, text:String, hasImage:Bool, isComment:Bool, hasNewsUrl:String?, postParent:MyFeedBaseVC) {
        
        self.attributedContentText = checkForTagsAndHyperlink(text, newsUrl:hasNewsUrl, thisParent: postParent)
        
        // if post
        if !isComment {
            let width:CGFloat = 242 // contentTextView.frame.size.width - 10
            
            // calculate height
            let minContentViewHeight:CGFloat = 54 + 20 + 5 // followBtn.frame.origin.y + followBtn.frame.size.height + 5
            var height = heightForView(self.attributedContentText!, UIFont(name: "Verdana", size: 11)!, width)
            if (height < 20) { height = 20 }
            height += 12 // contentView.origin.y
            height += 25 + 5 // likeCommentShell.height + 5 bottom padding
            
            // with image
            if hasImage {
                height += 255.0
            }
            height = height >= minContentViewHeight ? height : minContentViewHeight
            
            if title != nil && title != "" {
                // calculate title height
                var titleHeight = heightForView(title!, UIFont(name: "Verdana-Bold", size: 12)!, width)
                //println("feedObject -> setUserPostHeight -> titleHeight: \(titleHeight)")
                if (titleHeight < 40) { titleHeight = 40 }
                height += titleHeight - 20 //- 20 // 15
            }
            
            self.height = height
            //println("FeedObject -> setUserPostHeightWithText ->    POST height: \(height)")
        }
        
        // if comment
        if isComment {
            let width:CGFloat = 214 // contentTextView.frame.size.width - 10
            
            // calculate height
            let minContentViewHeight:CGFloat = 54 + 20 + 5 // followBtn.frame.origin.y + followBtn.frame.size.height + 5
            var height = heightForView(self.attributedContentText!, UIFont(name: "Verdana", size: 11)!, width)
            if (height < 20) { height = 20 }
            height += 12 // contentView.origin.y
            height += 5  // 5 bottom padding
            
            self.height = height
            //println("FeedObject -> setUserPostHeightWithText -> comment height: \(height)")
        }
    }
}