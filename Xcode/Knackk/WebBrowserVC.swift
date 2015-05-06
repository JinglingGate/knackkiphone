//
//  WebBrowserVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 1/13/15.
//  Copyright (c) 2015 antiblank. All rights reserved.
//

import UIKit

class WebBrowserVC:UIViewController, UIWebViewDelegate {
    
    //var parent:MyFeedBaseVC?
    
    
    let navBG = UIView()
    var backBtn = UIButton()
    var titleLbl = UILabel()
    
    var url = String()
    var navTitle = String()
    let webView = UIWebView()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    //var uploadImageProgressView:UIView?
    
    convenience init(url:String, title:String) { // , thisParent:MyFeedBaseVC
        self.init()
        self.url = url
        self.navTitle = title
    }
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.view.backgroundColor = knackkOrange
        if (self.respondsToSelector("edgesForExtendedLayout")) {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        
        let dbHelper = DatabaseHelper()
        let companyName = dbHelper.getUserObjectForKey("companyName")!
        
        // add nav bar
        let navBG = UIView(frame: CGRectMake(0, 0, 320, 64))
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
        titleLbl.text = navTitle
        navBG.addSubview(titleLbl)
        
        // web view
        webView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        self.view.addSubview(webView)
        
        // activity indicator
        activityIndicator.center = CGPointMake(webView.frame.size.width/2, 22)
        activityIndicator.hidesWhenStopped = true
        webView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        
        
        
        println("looking for VC file")
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    // MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}