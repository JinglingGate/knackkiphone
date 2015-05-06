//
//  SelectCompanyNameVC.swift
//  Knackk
//
//  Created by wkasel on 7/29/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class SelectCompanyNameVC: MyViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    let companyNameField = UITextField()
    var companyNamesArray:[String] = []
    let companyNamesDict = NSMutableDictionary()
    let companyNameSuggestions = NSMutableArray()
    
    var selectedCompanyId = NSString()
    
    let suggestionsView = UIView()
    let suggestionsTable = UITableView()
    
    var suggestionHeight:CGFloat?
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        companyNameField.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var targetY = screenHeight - screenHeight + 20
        
        // instructions label
        let instructionsLbl = UILabel(frame: CGRectMake(20, targetY, 280, 24))
        instructionsLbl.font = UIFont(name: "Verdana", size: 16)
        instructionsLbl.textColor = UIColor.whiteColor()
        instructionsLbl.text = "Please enter company name."
        scroller.addSubview(instructionsLbl)
        targetY += 35
        
        // suggestions view
        suggestionsView.frame = CGRectMake(20, targetY + 35, 280, 0)
        suggestionsView.backgroundColor = knackkLightOrange
        suggestionsView.layer.cornerRadius = 4
        suggestionsView.clipsToBounds = true
        scroller.addSubview(suggestionsView)
        suggestionHeight = screenHeight - 410
        // table
        suggestionsTable.frame = CGRectMake(0, 7, suggestionsView.frame.size.width, suggestionHeight!-7)
        suggestionsTable.delegate = self
        suggestionsTable.dataSource = self
        suggestionsTable.backgroundColor = UIColor.clearColor()
        suggestionsTable.separatorColor = UIColor.whiteColor()
        suggestionsView.addSubview(suggestionsTable)
        
        // company name
        let companyNameBg = UIImageView(frame: CGRectMake(20, targetY, 280, 42))
        companyNameBg.image = UIImage(named: "TextField")
        scroller.addSubview(companyNameBg)
        targetY += 5
        companyNameField.frame = CGRectMake(40, targetY, 240, 32)
        companyNameField.delegate = self
        companyNameField.font = UIFont(name: "Verdana", size: 18)
        companyNameField.textColor = UIColor.darkGrayColor()
        companyNameField.placeholder = "Company Name"
        companyNameField.userInteractionEnabled = true
        companyNameField.returnKeyType = UIReturnKeyType.Go
        companyNameField.autocorrectionType = UITextAutocorrectionType.No
        companyNameField.addTarget(self, action: "updateSuggestionsFromText", forControlEvents: UIControlEvents.EditingChanged)
        //companyNameField.inputAccessoryView = KeyboardBar(parent:self)
        scroller.addSubview(companyNameField)
        targetY += 50
        
        // next button
        let nextBtn = UIButton(frame: CGRectMake(74, screenHeight - 300, 226, 44))
        nextBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 3, 1, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        nextBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        nextBtn.titleLabel?.textColor = UIColor.whiteColor()
        nextBtn.setTitle("Next", forState: UIControlState.Normal)
        nextBtn.addTarget(self, action: "next", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(nextBtn)
        
        // back button
        let backBtn = UIButton(frame: CGRectMake(20, screenHeight - 300, 44, 44))
        backBtn.setBackgroundImage(UIImage(named: "backBtn"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: "popNav", forControlEvents: UIControlEvents.TouchUpInside)
        scroller.addSubview(backBtn)
        
        
        
        
        var parameters = parametersForTask("listCompanies")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON \(JSON)")
                println("ERROR \(error)")
                
                let status = JSON["status"].stringValue
                if (status == "success") {
                    
                    if let rawCompaniesArray = JSON["companies"].array {
                        for i in 0 ..< rawCompaniesArray.count {
                            let thisCompanyArray = rawCompaniesArray[i]
                            let companyId = thisCompanyArray["companyId"].stringValue
                            let companyName = thisCompanyArray["companyName"].stringValue
                            self.companyNamesArray.append(companyName)
                            self.companyNamesDict.setObject(companyId, forKey: companyName)
                        }
                    }
                    
                    func forwards(s1: String, s2: String) -> Bool {
                        return s1 < s2
                    }
                    self.companyNamesArray = sorted(self.companyNamesArray, forwards)
                    
                    println("companyNamesArray: \(self.companyNamesArray)")
                    println("companyNamesDict: \(self.companyNamesDict)")
                    
                    self.updateSuggestionsFromText()
                    
                } else {
                    println("failure")
                    // TODO: handle failure
                }
        }
    }
    
    
    // MARK: methods
    func popNav() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func next() {
        
        if (companyNameField.text.isEmpty) {
            let alert = UIAlertView(title: "Enter Company Name", message: "Your Company Name is required. Please try again.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        } else {
            
            // they have selected a known company, save their company id
            if let companyId = companyNamesDict.objectForKey(companyNameField.text) as? NSString {
                
                let vc = OnboardingErrorVC()
                self.navigationController?.pushViewController(vc, animated: true)
                
                
                
                /*/ TODO: what is the api task name for this call??
                var parameters = parametersForTask("listCompanies")
                
                // send request to server
                request(.POST, apiURL, parameters: parameters)
                    
                    .responseSwiftyJSON { (request, response, JSON, error) in
                        println("REQUEST \(request)")
                        println("RESPONSE \(response)")
                        println("JSON \(JSON)")
                        println("ERROR \(error)")
                        
                        let status = JSON["status"].stringValue
                        if (status == "success") {
                            
                            let vc = FollowCoworkersVC()
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        } else {
                            println("failure")
                            // TODO: handle failure
                        }
                }*/
            }
            
            // they have not selected a known company, register new
            else {
                let vc = RegisterCompanyVC()
                vc.companyNameField.text = companyNameField.text
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    // MARK: text field methods
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if (textField == companyNameField) {
            next()
        }
        return true
    }
    func keyboardDone() {
        scroller.setContentOffset(CGPointMake(0, -20), animated: true)
        companyNameField.resignFirstResponder()
    }
    func updateSuggestionsFromText() {
        companyNameSuggestions.removeAllObjects()
        if (companyNamesArray.count > 0) {
            let needle = companyNameField.text.lowercaseString
            for company in companyNamesArray {
                if company.lowercaseString.rangeOfString(needle) != nil {
                    companyNameSuggestions.addObject(company)
                }
            }
            println("suggestions: \(companyNameSuggestions)")
            suggestionsTable.reloadData()
            if (needle.isEmpty) {
                hideSuggestions()
            } else {
                showSuggestions()
            }
        } else {
            hideSuggestions()
        }
    }
    func showSuggestions() {
        UIView.animateWithDuration(0.15, animations: { self.suggestionsView.frame.size.height = self.suggestionHeight! })
    }
    func hideSuggestions() {
        UIView.animateWithDuration(0.15, animations: { self.suggestionsView.frame.size.height = 0 })
    }
    
    
    // MARK: table methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companyNameSuggestions.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "simpleCell")
        cell.textLabel?.text = companyNameSuggestions.objectAtIndex(indexPath.row) as NSString
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = UIFont(name: "Verdana", size: 16)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        companyNameField.text = companyNameSuggestions.objectAtIndex(indexPath.row) as NSString
        hideSuggestions()
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return suggestionHeight! / 4
    }
    
    
    // MARK: clean up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}