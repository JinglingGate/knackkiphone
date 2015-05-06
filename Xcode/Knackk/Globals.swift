//
//  Globals.swift
//  Knackk
//
//  Created by wkasel on 7/29/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit
import CoreData

// window
var windowFrame = UIScreen.mainScreen().bounds
var screenHeight = UIScreen.mainScreen().bounds.size.height

// api url
//var apiURL = "http://knackk-staging.herokuapp.com/api"    //staging
var apiURL = "http://knackk-server.herokuapp.com/api"       //production

// colors
let knackkOrange = UIColor(red: 255.0/255.0, green: 137.0/255.0, blue: 3.0/255.0, alpha: 1)
let knackkLightOrange = UIColor(red: 255.0/255.0, green: 176.0/255.0, blue: 84.0/255.0, alpha: 1)
let knackkTextBlue = UIColor(red: 72.0/255.0, green: 124.0/255.0, blue: 184.0/255.0, alpha: 1)
let knackkLightGray = UIColor(white: 0.87, alpha: 1)
let linkedInBlue = UIColor(red: 0.0/255.0, green: 123.0/255.0, blue: 182.0/255.0, alpha: 1)
let addressBookBlue = UIColor(red: 185.0/255.0, green: 205.0/255.0, blue: 229.0/255.0, alpha: 1)



// MARK: heightForText
func heightForView(text:NSMutableAttributedString, font:UIFont, width:CGFloat) -> CGFloat {
    let label:UITextView = UITextView(frame: CGRectMake(0, 0, width, CGFloat.max))
    //label.numberOfLines = 0
    //label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    label.font = font
    label.attributedText = text
    label.sizeToFit()
    return label.frame.height
}
func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
    let label:UITextView = UITextView(frame: CGRectMake(0, 0, width, CGFloat.max))
    //label.numberOfLines = 0
    //label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    label.font = font
    label.text = text
    label.sizeToFit()
    return label.frame.height
}

// MARK: button images
func buttonImage(size: CGSize, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor:UIColor, bgColor:UIColor) -> UIImage {
    
    let buttonView = UIView(frame: CGRectMake(0, 0, size.width, size.height))
    buttonView.backgroundColor = bgColor
    buttonView.clipsToBounds = true
    buttonView.layer.cornerRadius = cornerRadius
    buttonView.layer.borderWidth = borderWidth
    buttonView.layer.borderColor = borderColor.CGColor
    
    UIGraphicsBeginImageContextWithOptions(buttonView.frame.size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    buttonView.layer.renderInContext(context)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image;
}

// MARK: custom classes
class MyViewController:UIViewController {
    
    let scroller = UIScrollView()
    let defaultScrollerInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = knackkOrange
        if (self.respondsToSelector("edgesForExtendedLayout")) {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        
        // scroll view
        scroller.frame = windowFrame
        scroller.contentInset = defaultScrollerInset
        scroller.backgroundColor = knackkOrange
        scroller.scrollEnabled = false
        scroller.showsVerticalScrollIndicator = false
        scroller.contentSize = CGSizeMake(320, screenHeight + 216)
        self.view.addSubview(scroller)
        
        //self.adjustToStatusBarFrame(UIApplication.sharedApplication().statusBarFrame)
    }
    func adjustToStatusBarFrame(statusBarFrame:CGRect) {
        println("status bar frame: \(statusBarFrame)")
        if (statusBarFrame.size.height==40) {
            UIView.animateWithDuration(0.3, animations: {
                self.scroller.frame = CGRectMake(0, -20, 320, windowFrame.size.height)
            })
            //scroller.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.scroller.frame = CGRectMake(0, 0, 320, windowFrame.size.height)
                })
            //scroller.contentInset = defaultScrollerInset
        }
    }
    
}
class KeyboardBar:UIView {
    init(parent:UIViewController) {
        
        let barFrame = CGRectMake(0, 0, 320, 44)
        super.init(frame: barFrame)
        
        let keyboardBar = UIView(frame: barFrame)
        self.backgroundColor = UIColor(white:1, alpha:1)
        //self.backgroundColor = UIColor(white:1, alpha:0.6)
        let doneBtn = UIButton(frame: CGRectMake(240, 0, 60, 44))
        doneBtn.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 18)
        doneBtn.setTitleColor(knackkOrange, forState: UIControlState.Normal)
        doneBtn.setTitle("Done", forState: UIControlState.Normal)
        doneBtn.addTarget(parent, action: "keyboardDone", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(doneBtn)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




// IMAGE CACHE
class ImageCacheManager:NSObject {
    
    var coreDataContext = NSManagedObjectContext()
    var cacheDict = [String: UIImage]()
    
    override init() {
        super.init()
        // init core data
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        coreDataContext = appDelegate.managedObjectContext!
        loadCacheDict()
    }
    
    // methods
    func loadCacheDict() {
        let entity = NSEntityDescription.entityForName("ImageCache", inManagedObjectContext: coreDataContext)
        var error:NSError?
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        if let fetchResults = coreDataContext.executeFetchRequest(fetchRequest, error: nil) as? [ImageCache] {
            for i in 0 ..< fetchResults.count {
                let imageCache = fetchResults[i]
                cacheDict[imageCache.urlString] = UIImage(data: imageCache.imageData)
            }
        }
    }
    
    func imageFromCacheForUrl(urlString:String) -> UIImage? {
        var returnImage:UIImage? = nil
        if let image = cacheDict[urlString] {
            returnImage = image
        }
        return returnImage
    }
    func cacheImageForUrl(urlString:String, type:String, imageData:NSData) {
        
        //println("attemptCache: urlString\(urlString), type:\(type)")
        
        // save image to cache
        var error:NSError?
        let entity = NSEntityDescription.entityForName("ImageCache", inManagedObjectContext: coreDataContext)
        let imageCache = ImageCache(entity:entity!, insertIntoManagedObjectContext:coreDataContext)
        imageCache.urlString = urlString
        imageCache.imageType = type
        imageCache.imageData = imageData
        imageCache.lastUsage = NSDate().timeIntervalSince1970
        coreDataContext.save(&error)
        
        // add to current cache dictionary
        cacheDict[imageCache.urlString] = UIImage(data: imageCache.imageData)
    }
    /*func printCache() {
    
        println("===============================================================================================================\nprinting image cache\n\n")
        
        let entity = NSEntityDescription.entityForName("ImageCache", inManagedObjectContext: coreDataContext)
        var error:NSError?
        
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        if let fetchResults = coreDataContext.executeFetchRequest(fetchRequest, error: nil) as? [ImageCache] {
            for i in 0 ..< fetchResults.count {
                let imageCache = fetchResults[i]
                println("url:\(imageCache.urlString), type:\(imageCache.imageType), lastUsage:\(imageCache.lastUsage)")
            }
        }
        println("\n\nend image cache\n===============================================================================================================")
    }*/
    func emptyCache() {
        // TODO: clear cache of any images older than a week, besides user's images
        // profilePicture, postPicture
    }
}






// API MANAGER
func parametersForTask(task:String) -> [String: AnyObject] {
    var parameters = [
        "task": task
    ]
    return parameters
}



// DATABASE HELPER
class DatabaseHelper: NSObject {
    
    var userDict = NSMutableDictionary();
    
    func getTempDict() -> NSDictionary {
        return NSDictionary(objectsAndKeys:
            // user settings
            "","knackkId", "","companyId", "true","userMustValidateWorkEmail", "false","didFollow", "false","didInvite", "","userImageURL", "false","hasAskedToRegisterNotifications",
            // notification settings
            "true","notificationSettingTagging", "true","notificationSettingComments", "true","notificationSettingLikes", "true","notificationSettingFollows")
    }
    
    override init() {
        super.init()
        // create user dict first time app loads
        if (!NSFileManager.defaultManager().fileExistsAtPath(plistPath())) {
            let tempDict = getTempDict()
            tempDict.writeToFile(plistPath(), atomically: true)
        }
        userDict = NSMutableDictionary(contentsOfFile: plistPath())!
    }
    func saveUserData(dict: NSMutableDictionary) {
        dict.writeToFile(plistPath(), atomically: true)
        userDict = NSMutableDictionary(contentsOfFile: plistPath())!
        println("dbHelper: savedUserData: \(userDict)")
    }
    func getUserData() -> NSMutableDictionary {
        return NSMutableDictionary(contentsOfFile: plistPath())!;
    }
    func getUserObjectForKey(key:String) -> String? {
        return userDict[key] as String?
    }
    func plistPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as NSString
        return documentsDirectory.stringByAppendingPathComponent("userData.plist")
    }
    func logoutUser() {
        let tempDict = getTempDict()
        tempDict.writeToFile(plistPath(), atomically: true)
        userDict = NSMutableDictionary(contentsOfFile: plistPath())!
    }
}



//Email helper

class EmailHelper: NSObject {
    override init() {
        super.init()
    }
    class func containsBadEmailAddress(email: String) -> Bool {
        println("checking to see if email contains: gmail, yahoo, or hotmail: \(email)")
        return  email.lowercaseString.rangeOfString("@gmail.com") != nil ||
            email.lowercaseString.rangeOfString("@yahoo.com") != nil ||
            email.lowercaseString.rangeOfString("@hotmail.com") != nil
    }
}
