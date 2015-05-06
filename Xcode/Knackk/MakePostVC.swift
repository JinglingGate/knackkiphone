//
//  MakePostVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 11/6/14.
//  Copyright (c) 2014 antiblank. All rights reserved.
//

import UIKit
import Foundation

class MakePostVC: UIViewController, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var parent:MyFeedBaseVC?
    
    var companyUsersArray:[CompanyUsers]?
    
    // user tag table
    var cursorIndex:String.Index?
    var cursorTagLength:Int?
    var inputKeyboardFrame:CGRect?
    var table = UITableView()
    var tableObjects:[CompanyUsers] = Array()
    var searchBar = UISearchBar()
    
    let cancelBtn = UIButton()
    let postBtn = UIButton()
    let inputText = UITextView()
    var originalInputTextHeight:CGFloat?
    let placeHolderTextView = UITextView()
    let bottomBar = UIView()
    
    var imageView:UIImageView?
    var imageURL:String?
    var imageData:NSData?
    var imageDeleteBtn:UIButton?
    
    convenience init(parent:MyFeedBaseVC?, userArray:[CompanyUsers]?) {
        self.init()
        if (parent != nil) {
            self.parent = parent
            self.companyUsersArray = userArray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        if (self.respondsToSelector("edgesForExtendedLayout")) {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        
        imageData = nil
        
        createNavBar()
    }
    
    
    // MARK: nav bar
    func createNavBar() {
        // add nav bar
        let navBG = UIView(frame: CGRectMake(0, 0, 320, 64))
        navBG.backgroundColor = knackkOrange
        self.view.addSubview(navBG)
        
        // add notifications button
        cancelBtn.frame = CGRectMake(0, 20, 90, 44) // 5, 17, 44, 44
        cancelBtn.backgroundColor = knackkOrange
        cancelBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        cancelBtn.setTitle("Cancel", forState: UIControlState.Normal)
        cancelBtn.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 16)
        cancelBtn.titleLabel?.textAlignment = NSTextAlignment.Left
        cancelBtn.addTarget(self, action: "cancelAction", forControlEvents: UIControlEvents.TouchUpInside)
        navBG.addSubview(cancelBtn)
        
        // add notifications button
        postBtn.frame = CGRectMake(320-70, 20, 70, 44) // 5, 17, 44, 44
        postBtn.backgroundColor = knackkOrange
        postBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        postBtn.setTitle("Post", forState: UIControlState.Normal)
        postBtn.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 16)
        postBtn.titleLabel?.textAlignment = NSTextAlignment.Right
        postBtn.addTarget(self, action: "postAction", forControlEvents: UIControlEvents.TouchUpInside)
        navBG.addSubview(postBtn)
        
        // keyboard bar
        let keyboardBar = UIView(frame: CGRectMake(0, 0, 320, 44))
        keyboardBar.backgroundColor = UIColor(white: 0.98, alpha: 1)
        // top border
        let topBorder = UIView(frame: CGRectMake(0, 0, 320, 1))
        topBorder.backgroundColor = UIColor(white: 0.84, alpha: 1)
        keyboardBar.addSubview(topBorder)
        // camera button
        let cameraBtn = UIButton(frame: CGRectMake(5, 1, 44, 44))
        cameraBtn.setImage(UIImage(named: "StatusCamera"), forState: UIControlState.Normal)
        cameraBtn.addTarget(self, action: "cameraBtnPressed", forControlEvents: UIControlEvents.TouchUpInside)
        keyboardBar.addSubview(cameraBtn)
        // tag button
        let tagBtn = UIButton(frame: CGRectMake(49, 1, 44, 44))
        tagBtn.setImage(UIImage(named: "StatusTagCoworker"), forState: UIControlState.Normal)
        tagBtn.addTarget(self, action: "tagBtnPressed", forControlEvents: UIControlEvents.TouchUpInside)
        keyboardBar.addSubview(tagBtn)
        
        // status text view
        originalInputTextHeight = self.view.frame.size.height - 64
        inputText.frame = CGRectMake(2, 64, 316, originalInputTextHeight!)
        inputText.delegate = self
        inputText.font = UIFont(name: "Verdana", size: 11)
        inputText.textColor = UIColor(white: 0.5, alpha: 1)
        inputText.backgroundColor = UIColor.whiteColor()
        inputText.becomeFirstResponder()
        inputText.inputAccessoryView = keyboardBar
        self.view.addSubview(inputText)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangeNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextViewDidChangeNotification:", name: UITextViewTextDidChangeNotification, object: nil)
        
        // place holder text view
        placeHolderTextView.frame = CGRectMake(2, 64, 304, 90)
        placeHolderTextView.userInteractionEnabled = false
        placeHolderTextView.font = UIFont(name: "Verdana", size: 11)
        placeHolderTextView.textColor = UIColor(white: 0.5, alpha: 1)
        placeHolderTextView.backgroundColor = UIColor.clearColor()
        placeHolderTextView.text = "What's happening in your company?\n\nE.g. Achievements, news, events, product updates, new recruits, new clients, funding round, etc.\n\n(Tag Co-workers with @name or button below)"
        self.view.addSubview(placeHolderTextView)
        
        
        // bottom bar
        bottomBar.frame = CGRectMake(0, self.view.frame.size.height-44, 320, 44)
        bottomBar.backgroundColor = UIColor(white: 0.98, alpha: 1)
        // top border
        let botTopBorder = UIView(frame: CGRectMake(0, 0, 320, 1))
        botTopBorder.backgroundColor = UIColor(white: 0.84, alpha: 1)
        bottomBar.addSubview(botTopBorder)
        // camera button
        let botCameraBtn = UIButton(frame: CGRectMake(5, 1, 44, 44))
        botCameraBtn.setImage(UIImage(named: "StatusCamera"), forState: UIControlState.Normal)
        botCameraBtn.addTarget(self, action: "cameraBtnPressed", forControlEvents: UIControlEvents.TouchUpInside)
        bottomBar.addSubview(botCameraBtn)
        // tag button
        let botTagBtn = UIButton(frame: CGRectMake(49, 1, 44, 44))
        botTagBtn.setImage(UIImage(named: "StatusTagCoworker"), forState: UIControlState.Normal)
        botTagBtn.addTarget(self, action: "tagBtnPressed", forControlEvents: UIControlEvents.TouchUpInside)
        bottomBar.addSubview(botTagBtn)
        self.view.addSubview(bottomBar)
        
        // add tag table
        inputKeyboardFrame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 0)
        table.frame = CGRectMake(0, bottomBar.frame.origin.y, self.view.frame.size.width, 0)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = knackkLightGray
        //table.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(table)
        
        searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 38)
        searchBar.placeholder = "Start typing to filter co-workers"
        searchBar.inputAccessoryView = keyboardBar
        searchBar.delegate = self
        table.tableHeaderView = searchBar
    }
    func cancelAction() {
        inputText.resignFirstResponder()
        parent!.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    func postAction() {
        if !inputText.text.isEmpty {
            
            var uploadText = inputText.text
            
            if companyUsersArray != nil {
                
                println("MakePostVC -> postAction -> checkingTags")
                
                // ----------
                // replace tags with :::@emailPrefix:::
                // (make sure only an exact match is replaced (ie @priya should not convert in @priya11))
                // 1) explode string by @, check if @ exists
                // 2) if so, sort all emailPrefixes by descending length.
                // 3) check beginning of each string for matches of emailPrefix (starting with longest).
                // 4) if so, replace emailPrefix with delimitered tag go to next @ sign. if not, reduce range by one and repeat.
                // ----------
                
                
                // 1) explode string by @, check if @ exists
                let rawTagArray = inputText.text.componentsSeparatedByString("@") as NSArray
                if rawTagArray.count > 0 {
                    
                    // 2) sort all emailPrefixes by descneding length
                    let sortedArray = NSMutableArray()
                    for i in 0 ..< companyUsersArray!.count {
                        let user = companyUsersArray![i] as CompanyUsers
                        sortedArray.addObject(user.emailPrefix)
                    }
                    let sortDescriptor = NSSortDescriptor(key: "length", ascending: false)
                    let sortDescriptors = NSArray(object: sortDescriptor)
                    sortedArray.sortUsingDescriptors(sortDescriptors)
                    println("sorted: \(sortedArray)")
                    
                    // 3) check beginning of each string for matches of emailPrefix (starting with longest).
                    let tagArray = NSMutableArray(array: rawTagArray)
                    for i in 1 ..< tagArray.count {
                        let thisString = NSMutableString(string: (tagArray.objectAtIndex(i) as String))
                        for j in 0 ..< sortedArray.count {
                            let thisTag = sortedArray.objectAtIndex(j) as NSString
                            // 4) if so, replace emailPrefix with delimitered tag.
                            if thisString.hasPrefix(thisTag) {
                                let newTag = ":::@\(thisTag):::"
                                thisString.replaceOccurrencesOfString(thisTag, withString: newTag, options: NSStringCompareOptions.CaseInsensitiveSearch, range: NSMakeRange(0, thisString.length))
                                tagArray.replaceObjectAtIndex(i, withObject: thisString)
                                break
                            }
                        }
                    }
                    uploadText = tagArray.componentsJoinedByString("")
                }
            }
            
            println("uploadText: \(uploadText)")
            
            parent!.postWithObject(uploadText, imageData: imageData?)
            cancelAction()
        } else {
            let alert = UIAlertView(title: "Missing Text", message: "Your status text cannot be blank. Please include some text and try again.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
    }
    
    
    // MARK: text methods
    func keyboardChangeNotification(notification:NSNotification) {
        // get keyboard height
        let keyboardInfo = notification.userInfo
        inputKeyboardFrame = keyboardInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        adjustInputTextAndTagTableFrames(self.table.frame.size.height)
    }
    func adjustInputTextAndTagTableFrames(targetTableHeight:CGFloat) {
        var newHeight = originalInputTextHeight! - inputKeyboardFrame!.height - targetTableHeight
        if (imageData != nil) {
            newHeight = originalInputTextHeight! - 364 // pic (310), 10, bottom bar (44)
        }
        UIView.animateWithDuration(0.3, animations:{
            self.inputText.frame.size.height = newHeight
            self.table.frame.origin.y = self.inputKeyboardFrame!.origin.y - targetTableHeight
            self.table.frame.size.height = targetTableHeight
        })
        
        UIView.animateWithDuration(0.3,
            animations: {
                self.inputText.frame.size.height = newHeight
                self.table.frame.origin.y = self.inputKeyboardFrame!.origin.y - targetTableHeight
                self.table.frame.size.height = targetTableHeight
            },
            completion: {
                (value: Bool) in
                self.scrollToCursorPosition()
        })
    }
    func scrollToCursorPosition() {
        var rect = inputText.caretRectForPosition(inputText.selectedTextRange?.end)
        rect.size.height += inputText.textContainerInset.bottom
        inputText.scrollRectToVisible(rect, animated: true)
    }
    func textViewDidChange(textView: UITextView!) {
        if (textView == inputText) {
            if inputText.text.utf16Count > 0 {
                
                placeHolderTextView.hidden = true
                
                if inputText.text.rangeOfString("@") != nil {
                    suggestTagsInText(inputText.text, cursorPos: inputText.selectedRange)
                }
                
            } else {
                placeHolderTextView.hidden = false
            }
        }
    }
    func suggestTagsInText(text:NSString, cursorPos:NSRange) {
        
        // define character sets
        let startCharSet = NSCharacterSet(charactersInString: "@")
        let validCharSet = NSMutableCharacterSet.alphanumericCharacterSet()
        validCharSet.addCharactersInString("@.!#$%&'*+-/=?^_`{|}~")
        let invalidCharSet = validCharSet.invertedSet
        
        // define cursor position and get ranges (checks backwards from cursor position until character in charSet is found)
        cursorIndex      = advance(inputText.text.startIndex, cursorPos.location) // index of cursorPosition
        var thisRange    = Range<String.Index>(start: inputText.text.startIndex, end: cursorIndex!)
        let atSymbRange  = inputText.text.rangeOfCharacterFromSet(startCharSet, options: NSStringCompareOptions.BackwardsSearch, range: thisRange)
        let validRange   = inputText.text.rangeOfCharacterFromSet(validCharSet, options: NSStringCompareOptions.BackwardsSearch, range: thisRange)
        let invalidRange = inputText.text.rangeOfCharacterFromSet(invalidCharSet, options: NSStringCompareOptions.BackwardsSearch, range: thisRange)
        
        // check if tag symbol is in the correct range
        if (atSymbRange?.startIndex > invalidRange?.startIndex && atSymbRange?.startIndex < validRange?.startIndex) { // || atSymbRange?.endIndex == cursorIndex) {
            let tagRange    = Range<String.Index>(start: atSymbRange!.endIndex, end: cursorIndex!)
            let tagString   = inputText.text.substringWithRange(tagRange)
            searchBar.text = tagString
            cursorTagLength = tagString.utf16Count
            loadUsersForTable(tagString.lowercaseString)
            adjustInputTextAndTagTableFrames(125) // 87
        } else {
            adjustInputTextAndTagTableFrames(0)
            cursorTagLength = nil
        }
        // 01234567890123
        // Hi, I am @erik
        //               ^ cursorPos
        //          ^ atSymbRange start
        //           ^ validRange start
        //         ^ invalidRange start
    }
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        inputText.frame.size.height = originalInputTextHeight! - 216 - 44
        return true
    }
    
    
    // MARK: tag / search bar functions
    func tagBtnPressed() {
        cursorIndex = advance(inputText.text.endIndex, 0) // index of cursorPosition
        adjustInputTextAndTagTableFrames(125) // 87
        searchBar.text = ""
        searchBar.becomeFirstResponder()
    }
    func searchBarShouldBeginEditing(searchBar: UISearchBar!) -> Bool {
        return true
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        loadUsersForTable(searchText.lowercaseString)
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        adjustInputTextAndTagTableFrames(0)
    }
    
    
    // MARK: picture methods
    func cameraBtnPressed() {
        inputText.resignFirstResponder()
        let action = UIActionSheet(title: "Select Image", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "From Camera", "From Library")
        action.showInView(self.view)
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (actionSheet.buttonTitleAtIndex(buttonIndex) == "From Camera") {
            dispatch_after(10, dispatch_get_main_queue(), { self.takeNewPicture() })
        } else if (actionSheet.buttonTitleAtIndex(buttonIndex) == "From Library") {
            dispatch_after(10, dispatch_get_main_queue(), { self.selectExistingPicture() })
        }
    }
    func takeNewPicture() {
        println("From Camera")
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    func selectExistingPicture() {
        println("From Library")
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let filePath = documentsPath.stringByAppendingPathComponent("image.png")
        let image = scaleImage(info[UIImagePickerControllerOriginalImage] as UIImage)
        var imageData = UIImagePNGRepresentation(image)
        imageData.writeToFile(filePath, atomically: true)
        let thisImage = UIImage(contentsOfFile: filePath)
        imageData = UIImagePNGRepresentation(thisImage)
        self.imageData = imageData
        self.imageURL = filePath
        
        
        imageView = UIImageView(frame: CGRectMake(10, self.view.frame.size.height - 310 - 44, 300, 300))
        imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        imageView?.clipsToBounds = true
        imageView?.image = image
        self.view.addSubview(imageView!)
        
        imageDeleteBtn = UIButton(frame: CGRectMake(288 - 5, self.view.frame.size.height - 310 - 44 - 22 + 5, 44, 44))
        imageDeleteBtn?.setImage(UIImage(named: "imageDeleteBtn"), forState: UIControlState.Normal)
        imageDeleteBtn?.addTarget(self, action: "deleteImage", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(imageDeleteBtn!)
        
        inputText.frame.size.height = originalInputTextHeight! - 364 // pic (310), 10, bottom bar (44)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func scaleImage(image:UIImage) -> (UIImage) {
        let newSize = CGSizeMake(900, 900 * image.size.height / image.size.width)
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    func deleteImage() {
        
        self.view.bringSubviewToFront(bottomBar)
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.imageView?.frame.origin.y = self.view.frame.size.height
                self.imageView?.alpha = 0
            return
            }, completion: {
                (value: Bool) in
                
                self.imageDeleteBtn?.removeFromSuperview()
                self.imageDeleteBtn = nil
                
                self.imageView?.removeFromSuperview()
                self.imageView = nil
                
                self.imageData = nil
                self.imageURL = nil
        })
    }
    
    
    // MARK: table methods
    func loadUsersForTable(tagString:String) {
        
        tableObjects.removeAll(keepCapacity: false)
        
        for i in 0 ..< companyUsersArray!.count {
            let user = companyUsersArray![i] as CompanyUsers
            if user.emailPrefix.lowercaseString.hasPrefix(tagString) || user.userName.lowercaseString.hasPrefix(tagString) {
                tableObjects.append(user)
            }
        }
        
        table.reloadData()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableObjects.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user:CompanyUsers = tableObjects[indexPath.row]
        let cell = TagUserCell(style: UITableViewCellStyle.Default, reuseIdentifier: "tagUserPost", user:user)
        cell.user = user
        if (user.pictureUrl != "") { cell.setUserImage(user.pictureUrl) }
        if (user.userName != "") { cell.setUsername(user.userName) }
        if (user.emailPrefix != "") { cell.setEmailPrefix(user.emailPrefix) }
        //cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        adjustInputTextAndTagTableFrames(0)
        
        let user:CompanyUsers = tableObjects[indexPath.row]
        var thisRange    = Range<String.Index>(start: inputText.text.startIndex, end: cursorIndex!)
        let startCharSet = NSCharacterSet(charactersInString: "@")
        let atSymbRange  = inputText.text.rangeOfCharacterFromSet(startCharSet, options: NSStringCompareOptions.BackwardsSearch, range: thisRange)
        
        if (cursorTagLength != nil) {
            // if initiated by typing in input text
            let replaceString = Range<String.Index>(start: atSymbRange!.endIndex, end: advance(atSymbRange!.endIndex, cursorTagLength!))
            inputText.text.replaceRange(replaceString, with: user.emailPrefix)
            cursorTagLength = nil
        } else {
            // if initated through tag button
            inputText.text = inputText.text+" @"+user.emailPrefix
            placeHolderTextView.hidden = true
            inputText.becomeFirstResponder()
        }
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
class TagUserCell:UITableViewCell {
    
    //var parent:MyFeedBaseVC?
    var user:CompanyUsers?
    
    var myContentView = UIView()
    var usernameLbl = UILabel()
    var emailPrefixLbl = UILabel()
    var userImageView = UIImageView()
    
    convenience init (style: UITableViewCellStyle, reuseIdentifier: String!, user:CompanyUsers) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        //self.parent = parent
        self.user = user
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        
        // white background
        myContentView.frame = CGRectMake(0, 0, 320, 44) //8, 0, 304, 53
        myContentView.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(myContentView)
        
        // user image
        userImageView.frame = CGRectMake(10, 5, 34, 34)
        userImageView.image = UIImage(named: "defaultUser")
        myContentView.addSubview(userImageView)
        
        // username label
        usernameLbl.frame = CGRectMake(54, 4, 256, 16)
        usernameLbl.textColor = UIColor.blackColor()
        usernameLbl.font = UIFont(name: "Verdana-Bold", size: 12)
        myContentView.addSubview(usernameLbl)
        
        // emailPrefix label
        emailPrefixLbl.frame = CGRectMake(54, 20, 256, 20)
        emailPrefixLbl.textColor = UIColor.blackColor()
        emailPrefixLbl.font = UIFont(name: "Verdana", size: 14)
        myContentView.addSubview(emailPrefixLbl)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // methods
    func setUserImage (userImage:String) {
        println("set image called")
        userImageView.image = UIImage(named: userImage)
    }
    func setText(userName:String, emailPrefix:String) {
        
        let wholeString = userName+" (@"+emailPrefix+")"
        
        var formattedString = NSMutableAttributedString()
        
        formattedString.beginEditing()
        formattedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSMakeRange(0, 4))
        //                formattedString.addAttribute(NSUnderlineStyleAttributeName, value: NSNumber(1), range: NSMakeRange(0,4))
        formattedString.endEditing()
        
        usernameLbl.attributedText = formattedString
    }
    func setUsername (username:String) {
        usernameLbl.text = username
    }
    func setEmailPrefix (emailPrefix:String) {
        emailPrefixLbl.text = emailPrefix
    }
}