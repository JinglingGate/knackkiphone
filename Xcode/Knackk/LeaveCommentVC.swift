//
//  LeaveCommentVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 12/3/14.
//  Copyright (c) 2014 antiblank. All rights reserved.
//

import UIKit

class LeaveCommentVC: MyFeedBaseVC, UITextViewDelegate {
    
    var parent:MyFeedBaseVC?
    var parentTableObjects:[FeedObject] = Array()
    var postId:String?
    var insertIndex = Int()
    var shouldShowKeyboard = Bool()
    
    var threadTopPostIndex:Int?
    var threadTopPostObj:FeedObject?
    
    var titleLbl = UILabel()
    let backBtn = UIButton()
    
    var inputTextShell = UIView()
    let inputText = UITextView()
    let inputTextBorder = UIImageView()
    var keyboardFrame = CGRect()
    let postBtn = UIButton()
    
    //let postBtn = UIButton()
    var originalInputTextHeight:CGFloat?
    let placeHolderTextView = UITextView()
    let bottomBar = UIView()
    
    var imageView:UIImageView?
    var imageURL:String?
    var imageData:NSData?
    var imageDeleteBtn:UIButton?
    
    convenience init(parent:MyFeedBaseVC?, tableObjs:[FeedObject], postId:String, showKeyboard:Bool) {
        self.init()
        if (parent != nil) {
            self.parent = parent
        }
        self.parentTableObjects = tableObjs
        self.postId = postId
        self.shouldShowKeyboard = showKeyboard
        //println("postId: \(postId)")
        //println("tableObjs: \(tableObjs)")
    }
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        if (self.respondsToSelector("edgesForExtendedLayout")) {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        self.table.frame.size.height = self.view.frame.size.height - 64 - 44
        
        imageData = nil
        
        createNavBarAndTextField()
        showPostThread()
    }
    
    
    func createNavBarAndTextField() {
        // add nav bar
        let navBG = UIView(frame: CGRectMake(0, 0, 320, 64))
        navBG.backgroundColor = knackkOrange
        self.view.addSubview(navBG)
        
        // add back button
        backBtn.frame = CGRectMake(-3, 17, 44, 44)
        backBtn.backgroundColor = knackkOrange
        backBtn.setBackgroundImage(UIImage(named: "backNavBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        navBG.addSubview(backBtn)
        
        // title label
        titleLbl.frame = CGRectMake(50, 20, 220, 44)
        titleLbl.backgroundColor = knackkOrange
        titleLbl.textColor = UIColor.whiteColor()
        titleLbl.font = UIFont(name: "Verdana-Bold", size: 18)
        titleLbl.textAlignment = NSTextAlignment.Center
        titleLbl.text = "Leave a Comment"
        navBG.addSubview(titleLbl)
        
        
        // INPUT TEXT
        // shell
        inputTextShell = UIView(frame: CGRectMake(0, self.view.frame.size.height-44, 320, 200))
        inputTextShell.backgroundColor = UIColor(white: 0.98, alpha: 1)
        self.view.addSubview(inputTextShell)
        // top border
        let topBorder = UIView(frame: CGRectMake(0, 0, 320, 1))
        topBorder.backgroundColor = UIColor(white: 0.84, alpha: 1)
        inputTextShell.addSubview(topBorder)
        // text background border
        inputTextBorder.frame = CGRectMake(5, 5, self.view.frame.size.width - 70, 34)
        inputTextBorder.image = buttonImage(inputTextBorder.frame.size, 3, 1, UIColor(white: 0.9, alpha: 1), UIColor(white: 0.95, alpha: 1))
        inputTextShell.addSubview(inputTextBorder)
        // input text
        inputText.frame = inputTextBorder.frame
        inputText.frame.origin.x += 4
        inputText.frame.size.width -= 8
        inputText.delegate = self
        inputText.font = UIFont(name: "Verdana", size: 12)
        inputText.textColor = UIColor(white: 0.32, alpha: 1)
        inputText.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0)
        inputText.backgroundColor = UIColor.clearColor()
        inputTextShell.addSubview(inputText)
        // place holder text view
        placeHolderTextView.frame = inputText.frame
        placeHolderTextView.userInteractionEnabled = false
        placeHolderTextView.font = UIFont(name: "Verdana", size: 12)
        placeHolderTextView.textColor = UIColor(white: 0.5, alpha: 1)
        placeHolderTextView.backgroundColor = UIColor.clearColor()
        placeHolderTextView.text = "Leave a Comment"
        inputTextShell.addSubview(placeHolderTextView)
        // post button
        postBtn.frame = CGRectMake(self.view.frame.size.width-66, 0, 66, 44) // 5, 17, 44, 44
        postBtn.backgroundColor = UIColor.clearColor()
        postBtn.setTitleColor(knackkOrange, forState: UIControlState.Normal)
        postBtn.setTitle("Post", forState: UIControlState.Normal)
        postBtn.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)
        postBtn.titleLabel?.textAlignment = NSTextAlignment.Right
        postBtn.addTarget(self, action: "postAction", forControlEvents: UIControlEvents.TouchUpInside)
        inputTextShell.addSubview(postBtn)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "showKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameChanged:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        if shouldShowKeyboard {
            inputText.becomeFirstResponder()
        }
    }
    func showPostThread() {
        
        // SHOW QUICK THREAD FROM HANDOFF ----------
        var hasFoundPostThread = false
        for (var i=0; i < self.parentTableObjects.count; i++) {
            let thisObj = self.parentTableObjects[i]
            println("obj id:\(thisObj.postId), type:\(thisObj.type), text:\(thisObj.contentText)")
            if thisObj.postId == self.postId {
                if !hasFoundPostThread {
                    hasFoundPostThread = true
                    tableObjects.removeAll(keepCapacity: false)
                    tableObjects.append(FeedObject(type: .Separator))
                }
                if thisObj.type == .UserPost || thisObj.type == .NewsArticle {
                    threadTopPostIndex = i
                    let int = thisObj.numComments!.toInt()! + 1
                    thisObj.numComments = "\(int)"
                    threadTopPostObj = thisObj
                }
                if thisObj.type != .PostAComment {
                    tableObjects.append(thisObj)
                }
            } else {
                if hasFoundPostThread {
                    insertIndex = i - 1
                    tableObjects.append(FeedObject(type: .Separator))
                    tableObjects.append(FeedObject(type: .Loading))
                    table.reloadData()
                    break
                }
            }
        }
        
        
        let dbHelper = DatabaseHelper()
        
        // RELOAD FULL THREAD FROM SERVER ----------
        var parameters = parametersForTask("showPost")
        parameters["postId"] = postId!
        println("PARAMETERS: \(parameters)")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON LeaveCommentVC.swift - \(JSON)")
                println("ERROR \(error)")
                
                
                
                // HANDLE RESULTS ----------
                
                let status = JSON["status"].stringValue
                if (status == "success") {
                    
                    self.tableObjects.removeAll(keepCapacity: false)
                    
                    // post separator
                    self.tableObjects.append(FeedObject(type: .Separator))
                    
                    var titleForHeight:String? = nil
                    var usernameText = JSON["userName"].stringValue
                    if usernameText.isEmpty {
                        usernameText = JSON["title"].stringValue
                        titleForHeight = usernameText
                    }
                    
                    let obj = FeedObject(type: .UserPost, username: usernameText, userImage: JSON["pictureUrl"].stringValue)
                    obj.postId = JSON["postId"].stringValue
                    if JSON["userId"].stringValue.isEmpty {
                        obj.type = .NewsArticle
                    } else {
                        obj.userIdToFollow = JSON["userId"].stringValue
                    }
                    
                    //let test = JSON["activeDisplayedUser"]
                    //println("\n\n LeaveCommentVC activeDisplayedUser: \(test) \n\n")
                    if JSON["activeDisplayedUser"].stringValue == "true" { obj.activeDisplayedUser = true }
                    
                    if JSON["userHasFollowed"].stringValue == "true" { obj.userHasFollowed = true }
                    if JSON["userHasFollowed"].stringValue == "false" { obj.userHasFollowed = false }
                    
                    obj.timeString = JSON["timeAgo"].stringValue
                    obj.contentText = JSON["text"].stringValue
                    obj.postImageURL = JSON["imageUrl"].stringValue
                    obj.numComments = JSON["commentsCount"].stringValue
                    obj.numLikes = JSON["likes"].stringValue
                    obj.setUserPostHeightWithText(titleForHeight, text: obj.contentText!, hasImage: !obj.postImageURL!.isEmpty, isComment:false, hasNewsUrl:JSON["url"].stringValue, postParent:self.parent!)
                    self.tableObjects.append(obj)
                    
                    
                    // loop comments
                    if let rawCommentsArray = JSON["comments"].array {
                        println("rawCommentsArray: \(rawCommentsArray)")
                        for j in 0 ..< rawCommentsArray.count {
                            let thisCommentArray = rawCommentsArray[j]
                            println("thisCommentArray: \(thisCommentArray)")
                            let commentObj = FeedObject(type: .UserComment, username: thisCommentArray["userName"].stringValue, userImage: thisCommentArray["pictureUrl"].stringValue)
                            commentObj.postId = JSON["postId"].stringValue
                            commentObj.userId = dbHelper.getUserObjectForKey("knackkId")
                            commentObj.userIdToFollow = thisCommentArray["userId"].stringValue
                            commentObj.timeString = thisCommentArray["timeAgo"].stringValue
                            commentObj.contentText = thisCommentArray["text"].stringValue
                            commentObj.setUserPostHeightWithText(nil, text: commentObj.contentText!, hasImage: false, isComment:true, hasNewsUrl:nil, postParent:self.parent!)
                            self.tableObjects.append(commentObj)
                        }
                    }
                    
                    // post separator
                    self.tableObjects.append(FeedObject(type: .Separator))
                    
                    // reload
                    self.table.reloadData()
                    
                } else {
                    println("failure")
                    // TODO: handle failure
                }
        }
    }
    override func popNav() {
        inputText.resignFirstResponder()
        self.navigationController!.popViewControllerAnimated(true)
    }
    func postAction() {
        if !inputText.text.isEmpty {
            
            // get variables to send
            let dbHelper = DatabaseHelper()
            var userDict = dbHelper.getUserData()
            var parameters = parametersForTask("newComment")
            parameters["userId"] = (userDict["knackkId"] as String)
            parameters["postId"] = self.postId
            parameters["body"] = inputText.text
            
            // send request to server
            request(.POST, apiURL, parameters: parameters)
                .responseSwiftyJSON { (request, response, JSON, error) in
                    println("JSON \(JSON)")
                    let status = JSON["status"].stringValue
                    if (status == "success") {
                        // success
                    } else {
                        println("failure")
                        // TODO: handle failure (unlike post, show error)
                    }
            }
            
            
            
            //parent!.postWithObject(inputText.text, imageData: imageData?)
            
            println("insertIndex: \(insertIndex), tableObjects.count: \(self.tableObjects.count)")
            
            let commenterFirst = userDict["firstName"] as String
            let commenterLast = userDict["lastName"] as String
            let commenterUsername = "\(commenterFirst) \(commenterLast)"
            let commentObj = FeedObject(type: .UserComment, username: commenterUsername, userImage: userDict["userImageURL"] as String)
            commentObj.postId = self.postId
            commentObj.timeString = "just now"
            commentObj.contentText = inputText.text
            commentObj.setUserPostHeightWithText(nil, text: commentObj.contentText!, hasImage: false, isComment:true, hasNewsUrl:nil, postParent:self.parent!)
            self.parentTableObjects.insert(commentObj, atIndex: insertIndex)
            self.parentTableObjects[threadTopPostIndex!] = threadTopPostObj!
            parent?.tableObjects = parentTableObjects
            parent?.table.reloadData()
            
            
            popNav()
            
        } else {
            let alert = UIAlertView(title: "Missing Text", message: "Your status text cannot be blank. Please include some text and try again.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
    }
    
    
    // MARK: text methods
    func adjustCommentBar() {
        
        // get height of text
        var height = heightForView(inputText.text, inputText.font, inputText.frame.size.width-10) + 10
        if height < 34 {
            height = 34
        } else if height > 100 {
            height = 100
        }
        
        // resize input text and border on text height
        inputTextBorder.frame.size.height = height
        inputTextBorder.image = buttonImage(inputTextBorder.frame.size, 3, 1, UIColor(white: 0.9, alpha: 1), UIColor(white: 0.95, alpha: 1))
        inputText.frame.size.height = height
        
        // resize input text shell and table
        inputTextShell.frame.origin.y = keyboardFrame.origin.y - inputText.frame.size.height - 10
        postBtn.frame.origin.y = inputText.frame.size.height - 34
        table.frame.size.height = self.view.frame.size.height - 64 - keyboardFrame.size.height - inputText.frame.size.height - 10
    }
    func keyboardFrameChanged(notification:NSNotification) {
        // get keyboard height
        let keyboardInfo = notification.userInfo
        if let thisKeyboardFrame = keyboardInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
            keyboardFrame = thisKeyboardFrame
            println("adjustingTextViewSize, keyboardFrame: \(keyboardFrame)")
        } else {
            keyboardFrame = CGRectZero
        }
        self.adjustCommentBar()
    }
    func textViewDidChange(textView: UITextView!) {
        if (textView == inputText) {
            if inputText.text.utf16Count > 0 {
                placeHolderTextView.hidden = true
            } else {
                placeHolderTextView.hidden = false
            }
            self.adjustCommentBar()
        }
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        textView.scrollRangeToVisible(range)
        return true
    }
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        //inputText.frame.size.height = originalInputTextHeight! - 216 - 44
        return true
    }
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
