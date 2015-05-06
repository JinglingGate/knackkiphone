//
//  VerifyWorkLocationVC.swift
//  Knackk
//
//  Created by wkasel on 7/29/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class VerifyWorkLocationVC: MyViewController {
    
    let companyName = String()
    let workEmailField = UITextField()
    
    init(companyName:String) {
        super.init(nibName: nil, bundle: nil)
        self.companyName = companyName
        println("VerifyWorkLocationVC -> companyName: \(self.companyName)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var targetY = screenHeight - screenHeight + 20
        
        // instructions label
        let instructionsLbl = UILabel(frame: CGRectMake(20, targetY-10, 280, 78)) // y = ( fontSize + lineHeight + 2 ) * numLines
        instructionsLbl.font = UIFont(name: "Verdana", size: 16)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.numberOfLines = 0
        // add text and number of lines
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        var attrString = NSMutableAttributedString(string: "According to our system you\ncurrently work at:")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        instructionsLbl.attributedText = attrString
        scroller.addSubview(instructionsLbl)
        targetY += 108
        
        // instructions label
        let workEmailLbl = UILabel(frame: CGRectMake(20, targetY-10, 280, 20))
        workEmailLbl.font = UIFont(name: "Verdana-Bold", size: 16)
        workEmailLbl.textColor = knackkTextBlue
        workEmailLbl.text = companyName
        scroller.addSubview(workEmailLbl)
        targetY += 64
        
        // next button
        let yesBtn = UIButton(frame: CGRectMake(20, targetY, 280, 44))
        yesBtn.setBackgroundImage(buttonImage(CGSizeMake(280, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        yesBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        yesBtn.titleLabel?.textColor = UIColor.whiteColor()
        yesBtn.setTitle("Yes, this is correct", forState: UIControlState.Normal)
        yesBtn.addTarget(self, action: "correct", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(yesBtn)
        targetY += 54
        
        // next button
        let noBtn = UIButton(frame: CGRectMake(74, targetY, 226, 44))
        noBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        noBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        noBtn.titleLabel?.textColor = UIColor.whiteColor()
        noBtn.setTitle("No, this is incorrect", forState: UIControlState.Normal)
        noBtn.addTarget(self, action: "incorrect", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(noBtn)
        
        // back button
        let backBtn = UIButton(frame: CGRectMake(20, targetY, 44, 44))
        backBtn.setBackgroundImage(UIImage(named: "backBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(backBtn)
        
    }
    
    
    // MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: methods
    func correct() {
        let vc = FollowCoworkersVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func incorrect() {
        let vc = OnboardingErrorVC()
        //let vc = SelectCompanyNameVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}