
//
//  AppDelegate.swift
//  Knackk
//
//  Created by wkasel on 7/29/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate /*ABNotifierDelegate*/ {
                            
    var window: UIWindow?
    var nav:UINavigationController?
    
    // MARK: - Application Methods
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        //Airbrake
        //let key : NSString = "060fa54d17f94efb7bf2d83d80ca9114"
        //let ID : NSString = "110120"
        //ABNotifier.startNotifierWithAPIKey(key, projectID: ID, environmentName: ABNotifierAutomaticEnvironment, useSSL: true); A
        //ABNotifier.startNotifierWithAPIKey(key, projectID: ID, environmentName: ABNotifierAdHocEnvironment, useSSL: true); B
        //ABNotifier.startNotifierWithAPIKey(key, projectID: ID, environmentName: ABNotifierDevelopmentEnvironment, useSSL: true); //C
        
        //ABNotifier.writeTestNotice();
        
        // define window
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.whiteColor()
        
        // create nav / vc
        nav = MyNavController()
        nav!.navigationBar.barTintColor = knackkOrange
        nav!.navigationBar.translucent = false
        nav!.navigationBarHidden = true
        self.window!.rootViewController = nav
        
        setVariables()
        pushNextTask(nil)
        
        // send it
        self.window!.makeKeyAndVisible()
        return true
    }
    
    //func notifier
    
    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        
        var forceTask:String?
        
        println("Calling Application Bundle ID: \(sourceApplication)")
        println("URL scheme: \(url.scheme!)")
        println("URL query: \(url.query)")
        println("annotation: \(annotation)")
        
        // GET COMPNENTS OF QUERY STRING ----------------------------------------------------------------------------------------------------
        let queryPairs = url.query?.componentsSeparatedByString("&")
        if queryPairs != nil {
            println(queryPairs)
            var dict = Dictionary<String, String>()
            for i in 0 ..< queryPairs!.count {
                let thisString = queryPairs?[i]
                if ((thisString) != nil) {
                    let thisArray = thisString?.componentsSeparatedByString("=")
                    if ((thisArray) != nil) {
                        dict[thisArray![0]] = thisArray![1]
                    }
                }
            }
            println("dict: \(dict)")
            
            // SAVE DATA FOR TASK ---------------------------------------------------------------------------------------------------------------
            let dbHelper = DatabaseHelper()
            if (dict["task"] != nil) {
                
                var saveDict = dbHelper.getUserData()
                //var saveDict = Dictionary<String,String>()
                
                // save registered user data
                if (dict["task"] == "validateLinkedinUser") {
                    
                    forceTask = "validateLinkedinUser"
                    
                    // user info
                    if (dict["userId"] != nil) {
                        saveDict["knackkId"] = dict["userId"]
                    }
                    if (dict["firstName"] != nil) {
                        saveDict["firstName"] = dict["firstName"]
                    }
                    if (dict["lastName"] != nil) {
                        saveDict["lastName"] = dict["lastName"]
                    }
                    
                    // user email
                    if (dict["linkedinEmail"] != nil) {
                        saveDict["linkedInEmail"] = dict["linkedinEmail"]
                    }
                    if (dict["companyEmail"] != nil) {
                        saveDict["email"] = dict["companyEmail"]
                    }
                    if (dict["userMustSetWorkEmail"] != nil) {
                        saveDict["userMustSetWorkEmail"] = dict["userMustSetWorkEmail"]
                    }
                    
                    // company info
                    if (dict["companyId"] != nil) {
                        saveDict["companyId"] = dict["companyId"]
                    }
                    if (dict["companyName"] != nil) {
                        saveDict["companyName"] = dict["companyName"]
                    }
                    
                    // linked in info
                    if (dict["linkedInToken"] != nil) {
                        saveDict["linkedInToken"] = dict["linkedInToken"]
                    }
                    saveDict["userType"] = "linkedIn"
                }
                
                println("application openedFromURL: dictToSave: \(saveDict)")
                
                dbHelper.saveUserData(saveDict)
            }
            
            pushNextTask(forceTask)
            
        }
    
        return true;
    }
    func application(application: UIApplication!, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        //println("willChangeStatusBarFrame was called")
        if (nav != nil) {
            let thisVC: AnyObject = nav!.viewControllers[nav!.viewControllers.count-1]
            if let currentVC = thisVC as? MyViewController {
                currentVC.adjustToStatusBarFrame(newStatusBarFrame)
            }
        }
    }
    
    
    // MARK: - Methods
    func setVariables() {
        if (screenHeight==548 || screenHeight==568) {
            screenHeight = 568
            windowFrame.origin.y = 0
            windowFrame.size.height = 568
        } else {
            screenHeight = 480
            windowFrame.origin.y = 0
            windowFrame.size.height = 480
        }
    }
    func pushNextTask(forceTask:String?) { // forceTask:String
        
        
        //let vc = OnboardingErrorVC()
        //nav!.pushViewController(vc, animated: true)
        
        
        
        // get user data
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        println("app delegate -> pushNextTask -> forceTask: \(forceTask), userDict: \(userDict)")
        
        // PRE-CHECKS ----------
        
        // if user must set linked in work email
        var shouldSetLinkedInWorkEmail = false
        if let userType = userDict["userType"] as? String {
            if userType == "linkedIn" {
                if let mustSetEmail = userDict["userMustSetWorkEmail"] as? String {
                    if mustSetEmail == "true" {
                        shouldSetLinkedInWorkEmail = true
                    }
                }
            }
        }
        
        // if logged in with linked in and need to authenticate
        var forceValidateLinkedIn = false
        if forceTask != nil {
            if forceTask! == "validateLinkedinUser" {
                forceValidateLinkedIn = true
            }
        }
        
        
        
        
        // RUN NEXT TASK ----------
        
        // set logged in cookie with linked in token
        if forceValidateLinkedIn == true {
            var parameters = parametersForTask("validateLinkedinUser")
            parameters["linkedinAccessToken"] = userDict.objectForKey("linkedInToken") as? String
            println("paramters: \(parameters)")
            request(.POST, apiURL, parameters: parameters)
                .responseSwiftyJSON { (request, response, JSON, error) in
                    println("JSON \(JSON)")
                    let status = JSON["status"].stringValue
                    if (status == "success") {
                        userDict["userImageURL"] = JSON["pictureUrl"].stringValue
                        userDict["firstName"] = JSON["firstName"].stringValue
                        userDict["lastName"] = JSON["lastName"].stringValue
                        userDict["title"] = JSON["title"].stringValue
                        if userDict["userMustSetWorkEmail"] as String == "false" {
                            // if they have already set their work email, assume they've already followed / invited
                            userDict["didFollow"] = "true"
                            userDict["didInvite"] = "true"
                        }
                        dbHelper.saveUserData(userDict)
                        self.pushNextTask(nil)
                    } else {
                        let alert = UIAlertView(title: "Error", message: "Could not login (setLItoken)", delegate: nil, cancelButtonTitle: "Okay")
                        alert.show()
                    }
            }
        }
        
        // userId not set, login/register
        else if (userDict["knackkId"]!.isEqualToString("")) {
            let vc = LoginVC()
            nav!.setViewControllers([vc], animated: false)
        }
            
        // registered via LinkedIn, haven't confirmed work email
        else if shouldSetLinkedInWorkEmail {
            let loginVC = LoginVC()
            let vc = RegisterWithLinkedInVC()
            nav!.setViewControllers([loginVC, vc], animated: false)
        }
        
        // haven't set company
        else if (userDict["companyId"]!.isEqualToString("")) {
            let vc = SelectCompanyNameVC()
            nav!.setViewControllers([vc], animated: false)
        }
        
        // haven't followed users
        else if (userDict["didFollow"]!.isEqualToString("false")) {
            let vc = FollowCoworkersVC()
            nav!.setViewControllers([vc], animated: false)
        }
        
        // haven't invited users
        else if (userDict["didInvite"]!.isEqualToString("false")) {
            if userDict["linkedInToken"] != nil {
                let vc = ImportCoworkersLinkedInVC(isOnboarding: true)
                nav!.setViewControllers([vc], animated: false)
            } else {
                let vc = ImportCoworkersAddressBookVC(isOnboarding: true)
                nav!.setViewControllers([vc], animated: false)
            }
        }
        
        // show feed
        else {
            
            let vc = FeedVC(segment:["All", "Following", "Me"], fetchCoworkers:true, navBarType: "feed")
            if forceTask != nil {
                if forceTask! == "notificationReceived" {
                    vc.shouldPushNotificationList = true
                }
            }
            nav!.setViewControllers([vc], animated: false)
            
        }
    }
    
    
    
    // MARK: - Push Notifications
    func attemptToRegisterForPushNotifications() {
        let application = UIApplication.sharedApplication()
        // register for notifications iOS 8
        if application.respondsToSelector(Selector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound|UIUserNotificationType.Alert|UIUserNotificationType.Badge, categories: nil))
            // register for notifications iOS 7
        } else {
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge)
        }
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
        let dbHelper = DatabaseHelper()
        let userId = dbHelper.getUserObjectForKey("knackkId")
        
        var parameters = parametersForTask("registerNotificationToken")
        parameters["token"] = token
        parameters["userId"] = userId
        
        println("paramters: \(parameters)")
        request(.POST, apiURL, parameters: parameters)
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("JSON \(JSON)")
                let status = JSON["status"].stringValue
                if (status == "success") {
                    let userDict = dbHelper.getUserData()
                    userDict["hasAskedToRegisterNotifications"] = "true"
                    dbHelper.saveUserData(userDict)
                } else {
                    if let messageArray = JSON["message"].array {
                        let message = messageArray[0].stringValue
                        if message == "Value Token with this value already saved for this user" {
                            let userDict = dbHelper.getUserData()
                            userDict["hasAskedToRegisterNotifications"] = "true"
                            dbHelper.saveUserData(userDict)
                        } else {
                            let alert = UIAlertView(title: "Error 1", message: "Failed to Register for Notifications\n\nToken: \(token)\n\nError: \(error)", delegate: nil, cancelButtonTitle: "Okay")
                            alert.show()
                        }
                    } else {
                        let alert = UIAlertView(title: "Error 2", message: "Failed to Register for Notifications\n\nToken: \(token)\n\nError: \(error)", delegate: nil, cancelButtonTitle: "Okay")
                        alert.show()
                    }
                }
        }
        
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // failure
    }
    
    
    // iOS 8
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        // handle it
        pushNextTask("notificationReceived")
    }
    
    // iOS 7
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // handle it
        pushNextTask("notificationReceived")
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.antiblank.asdf" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Knackk", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Knackk.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}