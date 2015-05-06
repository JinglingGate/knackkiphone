//
//  ImportContactsAddressBook.swift
//  Knackk
//
//  Created by wkasel on 7/29/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit
import AddressBook

class ImportCoworkersAddressBookVC: MyViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIAlertViewDelegate {
    
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
    let preContactArray = NSMutableArray()
    let existingEmailsArray = NSMutableArray()
    let contactArray = NSMutableArray()
    let contactArrayForTable = NSMutableArray()
    let selectDeselectBtn = UIButton()
    var emailDomain = NSString()
    let continueBtn = UIButton()
    
    //let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("ImportContactsAddressBook");
        
        
        var targetY = screenHeight - screenHeight + 20
        
        // instructions label
        let instructionsLbl = UILabel(frame: CGRectMake(20, targetY, 280, 24))
        instructionsLbl.font = UIFont(name: "Verdana", size: 15)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.text = "Co-workers from your address book:"
        scroller.addSubview(instructionsLbl)
        targetY += 35
        
        // invite button
        selectDeselectBtn.frame = CGRectMake(20, targetY, 280, 44)
        selectDeselectBtn.setBackgroundImage(buttonImage(CGSizeMake(280, 44), 3, 1, addressBookBlue, addressBookBlue), forState: UIControlState.Normal)
        selectDeselectBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        selectDeselectBtn.setTitle("Select All", forState: UIControlState.Normal)
        selectDeselectBtn.addTarget(self, action: "selectDeselectAll", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(selectDeselectBtn)
        
        // activity indicator
        /*activityIndicator.center = CGPointMake(self.view.frame.size.width/2, targetY + 20.0 )
        activityIndicator.hidesWhenStopped = true
        scroller.addSubview(activityIndicator)
        activityIndicator.startAnimating()*/
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
        
        
        
        // GET ADDRESS BOOK
        let dbHelper = DatabaseHelper()
        let email = dbHelper.getUserObjectForKey("email")! as NSString
        let array = email.componentsSeparatedByString("@") as NSArray
        emailDomain = array.objectAtIndex(1) as NSString
        getAddressBookNames()
        /*for i in 0..<contactArray.count {
            let thisContact = contactArray.objectAtIndex(i) as Contact
            println("name: \(thisContact.name), emails: \(thisContact.emails)")
        }*/
        
        
        // REMOVE CURRENT CONTACTS
        getCurrentKnackkUsers()

        println("end of view did load")
    }
    
    
    // MARK: address book methods
    func getAddressBookNames() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if (authorizationStatus == ABAuthorizationStatus.NotDetermined) {
            NSLog("requesting access...")
            var emptyDictionary: CFDictionaryRef?
            var addressBook = !(ABAddressBookCreateWithOptions(emptyDictionary, nil) != nil)
            ABAddressBookRequestAccessWithCompletion(addressBook,{success, error in
                if success {
                    self.processContactNames();
                }
                else {
                    NSLog("unable to request access")
                }
            })
        }
        else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            NSLog("access denied")
        }
        else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            NSLog("access granted")
            processContactNames()
        }
    }
    func processContactNames() {
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        println("records in the array \(contactList.count)")
        
        for record:ABRecordRef in contactList {
            //println("a")
            processAddressbookRecord(record)
        }
    }
    func processAddressbookRecord(addressBookRecord: ABRecordRef) {
        //println("b")
        if let recordName = ABRecordCopyCompositeName(addressBookRecord) {
            let contactName = recordName.takeRetainedValue() as NSString
            let thisContact = Contact()
            //println("c")
            thisContact.name = contactName
            processEmail(addressBookRecord, thisContact: thisContact)
            //println("d")
        }
    }
    func processEmail(addressBookRecord: ABRecordRef, thisContact:Contact) {
        let emailArray:ABMultiValueRef = extractABEmailRef(ABRecordCopyValue(addressBookRecord, kABPersonEmailProperty))!
        for (var j = 0; j < ABMultiValueGetCount(emailArray); ++j) {
            //println("e")
            var emailAdd = ABMultiValueCopyValueAtIndex(emailArray, j)
            let myString = extractABEmailAddress(emailAdd)! as NSString
            let array = myString.componentsSeparatedByString("@") as NSArray
            //println("f")
            if (array.count > 1) {
                //println("g")
                let thisEmailDomain = array.objectAtIndex(1) as NSString
                //println("thisEmailDoman: " + thisEmailDomain + " and my domain is: " + emailDomain)
                if (thisEmailDomain == emailDomain) {
                    println("h: adding myString " + myString)
                    thisContact.emails.addObject(myString)
                }
            }
        }
        if thisContact.emails.count > 0 {
            preContactArray.addObject(thisContact)
            //contactArray.addObject(thisContact)
            //contactArrayForTable.addObject(thisContact)
        }
    }
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    func extractABEmailRef (abEmailRef: Unmanaged<ABMultiValueRef>!) -> ABMultiValueRef? {
        if let ab = abEmailRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    func extractABEmailAddress (abEmailAddress: Unmanaged<AnyObject>!) -> String? {
        if let ab = abEmailAddress {
            return Unmanaged.fromOpaque(abEmailAddress.toOpaque()).takeUnretainedValue() as CFStringRef
        }
        return nil
    }
    func getCurrentKnackkUsers() {
        
        // get variables to send
        let dbHelper = DatabaseHelper()
        let myKnackkId = dbHelper.getUserObjectForKey("knackkId")
        var parameters = parametersForTask("listUsers")
        parameters["companyId"] = dbHelper.getUserObjectForKey("companyId")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            .responseSwiftyJSON { (request, response, JSON, error) in
                let status = JSON["status"].stringValue
                if (status == "success") {
                    if let rawUsersArray = JSON["users"].array {
                        let emailArray = dbHelper.getUserObjectForKey("email")?.componentsSeparatedByString("@")
                        let emailSuffix = "\(emailArray![1])"
                        for i in 0 ..< rawUsersArray.count {
                            let thisUserArray = rawUsersArray[i]
                            let thisPrefix = thisUserArray["emailPrefix"].stringValue
                            self.existingEmailsArray.addObject("\(thisPrefix)@\(emailSuffix)")
                        }
                        self.removeCurrentKnackkUsers()
                    }
                } else {
                    let alert = UIAlertView(title: "Error", message: "Could not fetch co-workers", delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
                println("ending request")
        }
    }
    func removeCurrentKnackkUsers() {
        println(existingEmailsArray)
        for i in 0 ..< preContactArray.count {
            let thisContact = preContactArray.objectAtIndex(i) as Contact
            let thisEmail = thisContact.emails.objectAtIndex(0) as NSString
            var shouldAdd = true
            for j in 0 ..< existingEmailsArray.count {
                if existingEmailsArray.objectAtIndex(j).isEqualToString(thisEmail) {
                    shouldAdd = false
                    break
                }
            }
            if shouldAdd {
                contactArray.addObject(thisContact)
                contactArrayForTable.addObject(thisContact)
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
        let vc = FeedVC(segment:["All", "Following", "Me"], fetchCoworkers:true, navBarType: "feed")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func startThinking() {
        // show indicator, disable buttons
        //activityIndicator.startAnimating()
        continueBtn.enabled = false
    }
    func stopThinking() {
        // hide indicator, enable buttons
        //activityIndicator.stopAnimating()
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
                inviteeEmailPairs += "\(emailsToInvite.objectAtIndex(i)):\(namesToInvite.objectAtIndex(i))"
                if i < emailsToInvite.count - 1 {
                    inviteeEmailPairs += ","
                }
            }
            
            // parameters to send
            var parameters = parametersForTask("invite")
            parameters["userId"] = userDict["knackkId"] as? String
            parameters["inviteeEmailPairs"] = inviteeEmailPairs
            println("PARAMETERS \(parameters)")
            
            // send request to server
            request(.POST, apiURL, parameters: parameters)
                
                .responseSwiftyJSON { (request, response, JSON, error) in
                    println("REQUEST \(request)")
                    println("RESPONSE \(response)")
                    println("JSON \(JSON)")
                    println("ERROR \(error)")
                    
                    self.stopThinking()
                    
                    let status = JSON["status"].stringValue
                    if (status == "success") {
                        
                        // save results to plist
                        userDict["didInvite"] = "true"
                        dbHelper.saveUserData(userDict)
                        
                        let vc = FeedVC(segment:["All", "Following", "Me"], fetchCoworkers:true, navBarType: "feed")
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    } else {
                        println("failure")
                        // TODO: handle failure
                    }
            }
        } else {
            let alert = UIAlertView(title: "Are you sure?", message: "You haven't invited any contacts! knackk works much better when you invite your co-workers!", delegate: self, cancelButtonTitle: "Wait", otherButtonTitles: "I'm Sure")
            alert.show()
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "I'm Sure" || alertView.buttonTitleAtIndex(buttonIndex) == "Okay" {
            
            // save results to plist
            let dbHelper = DatabaseHelper()
            let userDict = dbHelper.getUserData()
            userDict["didInvite"] = "true"
            dbHelper.saveUserData(userDict)
            
            let vc = FeedVC(segment:["All", "Following", "Me"], fetchCoworkers:true, navBarType: "feed")
            self.navigationController?.pushViewController(vc, animated: true)
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
        //activityIndicator.hidden = true
        return contactArrayForTable.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thisContact = contactArrayForTable.objectAtIndex(indexPath.row) as Contact
        let cell = InviteCoworkerAddressBookCell(style: UITableViewCellStyle.Default, reuseIdentifier: "inviteCoworker")
        cell.setUserName(thisContact.name)
        cell.setUserEmail(thisContact.emails.objectAtIndex(0) as String)
        if thisContact.checked {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        //stop indicator after first cell is ready
        /*if indexPath.row == 0 {
            activityIndicator.stopAnimating()
        }*/
        return cell
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
        return 60.0
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

class InviteCoworkerAddressBookCell: UITableViewCell {
    var userNameLbl:UILabel?
    var userEmailLbl:UILabel?
    var userEmail:String?
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = knackkOrange
        
        // username label
        userNameLbl = UILabel(frame: CGRectMake(15, 8, 246, 20))
        userNameLbl!.textColor = UIColor.whiteColor()
        userNameLbl!.font = UIFont(name: "Verdana-Bold", size: 14)
        self.contentView.addSubview(userNameLbl!)
        
        // user email label
        userEmailLbl = UILabel(frame: CGRectMake(15, 32, 246, 20))
        userEmailLbl!.textColor = UIColor.whiteColor()
        userEmailLbl!.font = UIFont(name: "Verdana", size: 14)
        self.contentView.addSubview(userEmailLbl!)
        
        /*/ follow button
        let inviteBtn = UIButton(frame: CGRectMake(261, 14, 44, 32)) // 230, 14, 74, 32
        inviteBtn.setBackgroundImage(buttonImage(CGSizeMake(44, 32), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal) // 74, 32
        inviteBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        inviteBtn.titleLabel?.textColor = UIColor.whiteColor()
        inviteBtn.setTitle("Chk", forState: UIControlState.Normal)
        inviteBtn.addTarget(self, action: "continueAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.contentView.addSubview(inviteBtn)*/
        
        /*/ bottom border
        let botBorder = UIView(frame: CGRectMake(0, 59, 320, 1)) // 0,60
        botBorder.backgroundColor = knackkLightOrange
        self.contentView.addSubview(botBorder)*/
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUserName (username:String) {
        userNameLbl!.text = username
    }
    func setUserEmail (userEmail:String) {
        userEmailLbl!.text = userEmail
    }
}