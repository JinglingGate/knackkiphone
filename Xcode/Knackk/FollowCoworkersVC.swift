//
//  FollowCoworkersVC.swift
//  Knackk
//
//  Created by wkasel on 7/29/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class FollowCoworkersVC: MyViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    let startingTableHeight:CGFloat = 310.0 - 44 // (search bar)
    var table = UITableView()
    var tableObjects:[FeedObject] = Array()
    var originalTableObjectsFromServer:[FeedObject] = Array()
    //var tableObjects = NSMutableArray()
    //var originalTableObjectsFromServer = NSMutableArray()
    let searchBar = UISearchBar()
    var myKnackkId = String()
    
    let imageCacheManager = ImageCacheManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableObjects.append(FeedObject(type: .Loading))
        
        let dbHelper = DatabaseHelper()
        let userDict = dbHelper.getUserData()
        myKnackkId = userDict.objectForKey("knackkId") as String
        
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
                        
                        self.tableObjects.removeLast()
                        
                        for i in 0 ..< rawUsersArray.count {
                            
                            let thisUserArray = rawUsersArray[i]
                            //println("thisUserArray: \(thisUserArray)")
                            
                            if (thisUserArray["userId"].stringValue != self.myKnackkId) {
                                let obj = FeedObject(type: .FollowCoworker, username: thisUserArray["userName"].stringValue, userImage: "defaultUser.jpg")
                                obj.userId = self.myKnackkId
                                obj.userIdToFollow = thisUserArray["userId"].stringValue
                                let hasFollowed = thisUserArray["userHasFollowed"].stringValue == "true" ? true : false
                                obj.userHasFollowed = hasFollowed
                                self.tableObjects.append(obj)
                                self.originalTableObjectsFromServer.append(obj)
                            }
                            
                            /*if (thisUserArray["userId"].stringValue != self.myKnackkId) {
                                var thisUserDict = NSMutableDictionary()
                                thisUserDict.setObject(thisUserArray["userId"].stringValue, forKey: "userId")
                                thisUserDict.setObject(thisUserArray["userName"].stringValue, forKey: "userName")
                                thisUserDict.setObject(thisUserArray["userHasFollowed"].stringValue, forKey: "userHasFollowed")
                                self.originalTableObjectsFromServer.addObject(thisUserDict)
                                self.tableObjects.addObject(thisUserDict)
                            }*/
                            
                        }
                        self.table.reloadData()
                    }
                    
                } else {
                    println("failure")
                    // TODO: handle failure
                }
        }
        
        
        
        
        
        var targetY = screenHeight - screenHeight + 20
        
        // instructions label
        let instructionsLbl = UILabel(frame: CGRectMake(20, targetY-10, 280, 78)) // y = ( fontSize + lineHeight + 2 ) * numLines
        instructionsLbl.font = UIFont(name: "Verdana", size: 16)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.numberOfLines = 0
        // add text and number of lines
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        var attrString = NSMutableAttributedString(string: "Follow co-workers on knackk to\nfilter news involving them:")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        instructionsLbl.attributedText = attrString
        scroller.addSubview(instructionsLbl)
        targetY += 78
        
        
        // search bar
        searchBar.frame = CGRectMake(0, targetY, 320, 44)
        searchBar.delegate = self
        searchBar.placeholder = "Search for people you know"
        searchBar.inputAccessoryView = KeyboardBar(parent: self)
        //table.tableHeaderView = searchBar
        scroller.addSubview(searchBar)
        targetY += 44
        
        // table
        table = UITableView(frame: CGRectMake(0, targetY, 320, startingTableHeight), style: UITableViewStyle.Plain)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = knackkOrange
        table.separatorStyle = UITableViewCellSeparatorStyle.None
        scroller.addSubview(table)
        
        
        
        // blue instructions label
        let blueInstructionsLbl = UILabel(frame: CGRectMake(20, screenHeight-151, 280, 52)) // y = ( fontSize + lineHeight + 2 ) * numLines
        blueInstructionsLbl.font = UIFont(name: "Verdana", size: 15)
        blueInstructionsLbl.textColor = knackkTextBlue
        blueInstructionsLbl.numberOfLines = 0
        // add text and number of lines
        var paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.lineSpacing = 9
        var attrString2 = NSMutableAttributedString(string: "You can follow or invite co-workers\nanytime using the        button.")
        attrString2.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle2, range:NSMakeRange(0, attrString2.length))
        blueInstructionsLbl.attributedText = attrString2
        scroller.addSubview(blueInstructionsLbl)
        
        // follow button image
        let followBtnImg = UIImageView(frame: CGRectMake(155, screenHeight-132, 44, 44))
        followBtnImg.image = UIImage(named: "FollowBtn")
        scroller.addSubview(followBtnImg)
        
        // continue button
        let continueBtn = UIButton(frame: CGRectMake(74, screenHeight-84, 172, 44)) // w: 226
        continueBtn.setBackgroundImage(buttonImage(CGSizeMake(172, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        continueBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        continueBtn.titleLabel?.textColor = UIColor.whiteColor()
        continueBtn.setTitle("Continue", forState: UIControlState.Normal)
        continueBtn.addTarget(self, action: "continueAction", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(continueBtn)
        
        // back button
        let backBtn = UIButton(frame: CGRectMake(20, screenHeight-84, 44, 44))
        backBtn.setBackgroundImage(UIImage(named: "backBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(backBtn)
        
        // forward button
        let forwardBtn = UIButton(frame: CGRectMake(256, screenHeight-84, 44, 44))
        forwardBtn.setBackgroundImage(UIImage(named: "forwardBtn"), forState: UIControlState.Normal)
        forwardBtn.addTarget(self, action: "continueAction", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(forwardBtn)
        
    }
    
    
    // MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: methods
    func continueAction() {
        
        let dbHelper = DatabaseHelper()
        let userDict = dbHelper.getUserData()
        userDict.setObject("true", forKey: "didFollow")
        dbHelper.saveUserData(userDict)
        
        if userDict["linkedInToken"] != nil {
            let vc = ImportCoworkersLinkedInVC(isOnboarding: true)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ImportCoworkersAddressBookVC(isOnboarding: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    // MARK: search bar functions
    func searchBarShouldBeginEditing(searchBar: UISearchBar!) -> Bool {
        UIView.animateWithDuration(0.3, animations: {
            self.scroller.frame.origin.y = -(self.table.frame.origin.y-44)
            self.table.frame.size.height = screenHeight - 64 - 215 - 44
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
        
        
        /*tableObjects.removeAllObjects()
        for userDict in originalTableObjectsFromServer {
            let username = userDict.objectForKey("userName") as NSString
            if (username.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || searchText.isEmpty) {
                tableObjects.addObject(userDict)
            }
        }
        table.reloadData()*/
    }
    func keyboardDone() {
        UIView.animateWithDuration(0.3, animations: {
            self.scroller.frame.origin.y = 0.0
            self.table.frame.size.height = self.startingTableHeight
        })
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: table methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableObjects.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let obj:FeedObject = tableObjects[indexPath.row]
        
        if (obj.type == .Loading) {
            
            let cell = LoadingCell(style: UITableViewCellStyle.Default, reuseIdentifier: "loadingCell")
            cell.backgroundColor = knackkOrange
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else {
            
            let cell = FollowCoworkerCell(style: UITableViewCellStyle.Default, reuseIdentifier: "followCoworker")
            cell.feedObj = obj
            if (obj.userImage != nil) { cell.setUserImage(obj.userImage!, cacheManager:imageCacheManager) }
            if (obj.username != nil) { cell.setUsername(obj.username!) }
            if (obj.userId != nil) { cell.followerId = obj.userId }
            if (obj.userIdToFollow != nil) { cell.leaderId = obj.userIdToFollow }
            if (obj.userHasFollowed) { cell.setFollowingButton(obj.userHasFollowed) }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            /*let cell = FollowCoworkerCell(style: UITableViewCellStyle.Default, reuseIdentifier: "followCoworker")
            let dictionary:NSDictionary = tableObjects.objectAtIndex(indexPath.row) as NSDictionary
            cell.followerId = self.myKnackkId
            cell.leaderId = (dictionary.objectForKey("userId") as String)
            cell.setUserImage("defaultUser.jpg")
            cell.setUsername(dictionary.objectForKey("userName") as String)
            let hasFollowed = dictionary.objectForKey("userHasFollowed") as String == "true" ? true : false
            cell.setFollowingButton(hasFollowed)
            cell.selectionStyle = UITableViewCellSelectionStyle.None*/
            return cell
            
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 61.0
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}