//
//  ImportCoworkersLinkedInVC.swift
//  Knackk
//
//  Created by wkasel on 8/3/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class ImportCoworkersLinkedInVC: MyViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIAlertViewDelegate {
    
    var isOnboarding = false
    convenience init (isOnboarding:Bool) {
        self.init()
        self.isOnboarding = isOnboarding
    }
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    var startingTableHeight:CGFloat = 310.0
    var table = UITableView()
    let searchBar = UISearchBar()
    let contactArray = NSMutableArray()
    let contactArrayForTable = NSMutableArray()
    let selectDeselectBtn = UIButton()
    var emailDomain = NSString()
    let continueBtn = UIButton()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingContact = Contact()
        loadingContact.name = "LOADING"
        contactArrayForTable.addObject(loadingContact)
        
        var targetY = screenHeight - screenHeight + 20
        
        // instructions label
        let instructionsLbl = UILabel(frame: CGRectMake(20, targetY-10, 280, 78)) // y = ( fontSize + lineHeight + 2 ) * numLines
        instructionsLbl.font = UIFont(name: "Verdana", size: 16)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.numberOfLines = 0
        // add text and number of lines
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        var attrString = NSMutableAttributedString(string: "Co-workers from your first degree\nnetwork on LinkedIn:")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        instructionsLbl.attributedText = attrString
        scroller.addSubview(instructionsLbl)
        targetY += 78
        
        // invite button
        selectDeselectBtn.frame = CGRectMake(20, targetY, 280, 44)
        selectDeselectBtn.setBackgroundImage(buttonImage(CGSizeMake(280, 44), 3, 1, linkedInBlue, linkedInBlue), forState: UIControlState.Normal)
        selectDeselectBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        selectDeselectBtn.setTitle("Select All", forState: UIControlState.Normal)
        selectDeselectBtn.addTarget(self, action: "selectDeselectAll", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(selectDeselectBtn)
        targetY += 64
        
        
        // search bar
        searchBar.frame = CGRectMake(0, targetY, 320, 44)
        searchBar.delegate = self
        searchBar.placeholder = "Search for people you know"
        searchBar.inputAccessoryView = KeyboardBar(parent: self)
        //table.tableHeaderView = searchBar
        scroller.addSubview(searchBar)
        targetY += 44
        
        // table
        startingTableHeight = screenHeight-targetY-104
        table = UITableView(frame: CGRectMake(0, targetY, 320, startingTableHeight), style: UITableViewStyle.Plain)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = knackkOrange
        //table.separatorStyle = UITableViewCellSeparatorStyle.None
        table.separatorColor = knackkLightOrange
        scroller.addSubview(table)
        
        // continue button
        var continueWidth:CGFloat = 226.0
        if isOnboarding {
            continueWidth = 172.0
        }
        continueBtn.frame = CGRectMake(74, screenHeight-84, continueWidth, 44)
        continueBtn.setBackgroundImage(buttonImage(CGSizeMake(continueWidth, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        continueBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        continueBtn.titleLabel?.textColor = UIColor.whiteColor()
        continueBtn.setTitle("Invite Selected", forState: UIControlState.Normal)
        continueBtn.addTarget(self, action: "continueAction", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(continueBtn)
        
        // activity indicator
        activityIndicator.center = CGPointMake(continueBtn.frame.size.width - 25, 22)
        activityIndicator.hidesWhenStopped = true
        continueBtn.addSubview(activityIndicator)
        
        // back button
        let backBtn = UIButton(frame: CGRectMake(20, screenHeight-84, 44, 44))
        backBtn.setBackgroundImage(UIImage(named: "backBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(backBtn)
        
        // forward button
        if isOnboarding {
            let forwardBtn = UIButton(frame: CGRectMake(256, screenHeight-84, 44, 44))
            forwardBtn.setBackgroundImage(UIImage(named: "forwardBtn"), forState: UIControlState.Normal)
            forwardBtn.addTarget(self, action: "skip", forControlEvents: UIControlEvents.TouchUpInside)
            scroller.addSubview(forwardBtn)
        }
        
        
        
        // GET LINKED IN CONTACTS
        
        // query list of users
        var parameters = parametersForTask("getLinkedinConnections")
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
                    
                    self.contactArrayForTable.removeLastObject()
                    
                    if let rawUsersArray = JSON["nameUrlPairs"].array {
                        
                        for i in 0 ..< rawUsersArray.count {
                            let thisUserArray = rawUsersArray[i]
                            let thisContact = Contact()
                            thisContact.name = thisUserArray[0].stringValue
                            thisContact.emails = NSMutableArray(object:thisUserArray[1].stringValue)
                            self.contactArray.addObject(thisContact)
                            self.contactArrayForTable.addObject(thisContact)
                        }
                        self.table.reloadData()
                    }
                    
                } else {
                    println("failure")
                    // TODO: handle failure
                }
        }
        
        table.reloadData()
    }
    
    
    // MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func skip() {
        let dbHelper = DatabaseHelper()
        let userDict = dbHelper.getUserData()
        userDict["didInvite"] = "true"
        dbHelper.saveUserData(userDict)
        let vc = ImportCoworkersAddressBookVC(isOnboarding: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func startThinking() {
        // show indicator, disable buttons
        activityIndicator.startAnimating()
        continueBtn.enabled = false
    }
    func stopThinking() {
        // hide indicator, enable buttons
        activityIndicator.stopAnimating()
        continueBtn.enabled = true
    }
    func selectDeselectAll() {
        if self.selectDeselectBtn.titleLabel!.text == "Select All" {
            self.selectDeselectBtn.setTitle("Deselect All", forState: UIControlState.Normal)
            for i in 0..<contactArray.count {
                let thisContact = contactArray.objectAtIndex(i) as Contact
                thisContact.checked = true
            }
        } else {
            self.selectDeselectBtn.setTitle("Select All", forState: UIControlState.Normal)
            for i in 0..<contactArray.count {
                let thisContact = contactArray.objectAtIndex(i) as Contact
                thisContact.checked = false
            }
        }
        table.reloadData()
    }
    func continueAction() {
        let namesToInvite = NSMutableArray()
        let emailsToInvite = NSMutableArray()
        for i in 0..<contactArray.count {
            let thisContact = contactArray.objectAtIndex(i) as Contact
            if thisContact.checked {
                namesToInvite.addObject(thisContact.name)
                emailsToInvite.addObject(thisContact.emails.objectAtIndex(0))
            }
        }
        if emailsToInvite.count > 0 {
            
            startThinking()
            
            let dbHelper = DatabaseHelper()
            let userDict = dbHelper.getUserData()
            
            
            // build string of invitees
            var inviteeEmailPairs = String()
            for i in 0 ..< emailsToInvite.count {
                inviteeEmailPairs += "\(namesToInvite.objectAtIndex(i)):\(emailsToInvite.objectAtIndex(i))"
                if i < emailsToInvite.count - 1 {
                    inviteeEmailPairs += ","
                }
            }
            
            // parameters to send
            var parameters = parametersForTask("inviteLinkedinConnections")
            parameters["nameUrlPairs"] = inviteeEmailPairs
            println("PARAMETERS \(parameters)")
            
            // send request to server
            request(.POST, apiURL, parameters: parameters)
                
                .responseSwiftyJSON { (request, response, JSON, error) in
                    
                    println("JSON: \(JSON)")
                    
                    self.stopThinking()
                    
                    if self.isOnboarding {
                        // save results to plist
                        userDict["didInvite"] = "true"
                        dbHelper.saveUserData(userDict)
                        let vc = ImportCoworkersAddressBookVC(isOnboarding: true)
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = FeedVC(segment:["All", "Following", "Me"], fetchCoworkers:true, navBarType: "feed")
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
            }
        } else {
            let alert = UIAlertView(title: "Are you sure?", message: "You haven't invited any contacts! knackk works much better when you invite your co-workers!", delegate: self, cancelButtonTitle: "Wait", otherButtonTitles: "I'm Sure")
            alert.show()
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "I'm Sure" || alertView.buttonTitleAtIndex(buttonIndex) == "Okay" {
            if self.isOnboarding {
                // save results to plist
                let dbHelper = DatabaseHelper()
                let userDict = dbHelper.getUserData()
                userDict["didInvite"] = "true"
                dbHelper.saveUserData(userDict)
                let vc = ImportCoworkersAddressBookVC(isOnboarding: true)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = FeedVC(segment:["All", "Following", "Me"], fetchCoworkers:true, navBarType: "feed")
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    // MARK: search bar methods
    func searchBarShouldBeginEditing(searchBar: UISearchBar!) -> Bool {
        
        println("search began")
        startingTableHeight = self.table.frame.size.height
        UIView.animateWithDuration(0.3, animations: {
            self.scroller.frame.origin.y = -(self.table.frame.origin.y-44)
            self.table.frame.size.height = screenHeight-240-44
        })
        
        return true
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        updateSuggestionsFromText()
    }
    func updateSuggestionsFromText() {
        contactArrayForTable.removeAllObjects()
        if (contactArray.count > 0) {
            if searchBar.text.isEmpty {
                for i in 0..<contactArray.count {
                    let thisContact = contactArray.objectAtIndex(i) as Contact
                    contactArrayForTable.addObject(thisContact)
                }
            } else {
                let needle = searchBar.text.lowercaseString
                for i in 0..<contactArray.count {
                    let thisContact = contactArray.objectAtIndex(i) as Contact
                    let name = thisContact.name
                    if name.lowercaseString.rangeOfString(needle) != nil {
                        contactArrayForTable.addObject(thisContact)
                    }
                }
            }
            table.reloadData()
        }
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
        return contactArrayForTable.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thisContact = contactArrayForTable.objectAtIndex(indexPath.row) as Contact
        
        if thisContact.name == "LOADING" {
            
            let cell = LoadingCell(style: UITableViewCellStyle.Default, reuseIdentifier: "loadingCell")
            cell.backgroundColor = knackkOrange
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else {
            
            let cell = InviteCoworkerLinkedInCell(style: UITableViewCellStyle.Default, reuseIdentifier: "inviteCoworker")
            cell.setUserName(thisContact.name)
            if thisContact.checked {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            return cell
            
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let thisContact = contactArrayForTable.objectAtIndex(indexPath.row) as Contact
        thisContact.checked = !thisContact.checked
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if thisContact.checked {
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

class Contact {
    var name = NSString()
    var emails = NSMutableArray()
    var checked = false
}

class InviteCoworkerLinkedInCell: UITableViewCell {
    var userNameLbl:UILabel?
    var userEmailLbl:UILabel?
    var userEmail:String?
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = knackkOrange
        
        // username label
        userNameLbl = UILabel(frame: CGRectMake(15, 0, 246, 40))
        userNameLbl!.textColor = UIColor.whiteColor()
        userNameLbl!.font = UIFont(name: "Verdana-Bold", size: 14)
        self.contentView.addSubview(userNameLbl!)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUserName (username:String) {
        userNameLbl!.text = username
    }
}