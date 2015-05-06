//
//  UploadProfilePicVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 12/18/14.
//  Copyright (c) 2014 antiblank. All rights reserved.
//

import UIKit

class UploadProfilePicVC: MyFeedExtraBaseVC, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageView = UIImageView()
    var imageURL:String?
    var imageData:NSData?
    var autoOnce = true
    
    let saveBtn = UIButton()
    
    var uploadImageProgressViewShell:UIView?
    var uploadImageProgressView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = "Change Profile Picture"
        
        // add image view
        imageView.frame = CGRectMake(10, 74, 300, 300)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        self.view.addSubview(imageView)
        
        // select button
        let selectBtn = UIButton(frame: CGRectMake(10, 384, 145, 44))
        selectBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 5, 0, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        selectBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        selectBtn.titleLabel?.textColor = UIColor.whiteColor()
        selectBtn.setTitle("Select", forState: UIControlState.Normal)
        selectBtn.addTarget(self, action: "cameraBtnPressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(selectBtn)
        
        // save button
        saveBtn.frame = CGRectMake(165, 384, 145, 44)
        saveBtn.setBackgroundImage(buttonImage(CGSizeMake(226, 44), 5, 0, UIColor.whiteColor(), knackkOrange), forState: UIControlState.Normal)
        saveBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        saveBtn.titleLabel?.textColor = UIColor.whiteColor()
        saveBtn.setTitle("Save", forState: UIControlState.Normal)
        saveBtn.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
        saveBtn.enabled = false
        self.view.addSubview(saveBtn)
        
        
        // set current image
        let dbHelper = DatabaseHelper()
        let userDict = dbHelper.getUserData()
        let userImageURL = userDict["userImageURL"] as String
        if userImageURL.isEmpty {
            imageView.image = UIImage(named: "defaultUser.jpg")
        } else {
            // get image saved to app
            
            if userImageURL == "" || userImageURL == "null" || userImageURL.isEmpty {
                // keep default
            } else {
                // load from cache if cached; if not, load from internet
                if let cacheImage = self.imageCacheManager.imageFromCacheForUrl(userImageURL) {
                    self.imageView.image = cacheImage
                } else {
                    var url = NSURL(string: userImageURL)
                    var image: UIImage?
                    var request: NSURLRequest = NSURLRequest(URL: url!)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                        self.imageView.image = UIImage(data: data)
                        self.imageCacheManager.cacheImageForUrl(userImageURL, type: "profilePicture", imageData: data)
                    })
                }
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if autoOnce {
            cameraBtnPressed()
        }
    }
    
    // MARK: picture methods
    func save() {
        
        // add upload indicator
        uploadImageProgressViewShell = UIView(frame: self.view.frame)
        uploadImageProgressViewShell!.alpha = 0
        uploadImageProgressViewShell!.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.addSubview(uploadImageProgressViewShell!)
        uploadImageProgressView = UIView(frame: CGRectMake(0, 100, 0, 3))
        uploadImageProgressView!.backgroundColor = knackkOrange
        uploadImageProgressViewShell!.addSubview(uploadImageProgressView!)
        let uploadingText = UILabel(frame: CGRectMake(0, 103, self.view.frame.size.width, 20))
        uploadingText.backgroundColor = UIColor.clearColor()
        uploadingText.textColor = UIColor.whiteColor()
        uploadingText.font = UIFont(name: "Verdana", size: 12)
        uploadingText.text = "Uploading..."
        uploadingText.textAlignment = NSTextAlignment.Center
        uploadImageProgressViewShell!.addSubview(uploadingText)
        UIView.animateWithDuration(0.3, animations:{ self.uploadImageProgressViewShell!.alpha = 1 })
        
        // get variables
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        var parameters = parametersForTask("newUserPhoto")
        parameters["userId"] = (userDict["knackkId"] as String)
        
        
        
        // UPLOAD FUNCTIONS ----------
        
        // function to create urlRequestConvertible for Alamofire.upload
        func urlRequestWorksWithDotRequest() -> (URLRequestConvertible, NSData) {
            
            let boundaryConstant = "boundsxx7n32dn8xx";
            let contentType = "multipart/form-data;boundary="+boundaryConstant
            
            var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: apiURL)!)
            mutableURLRequest.HTTPMethod = Method.POST.rawValue
            mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            
            // Prepare the HTTPBody for the request.
            let requestBodyData : NSMutableData = NSMutableData()
            
            // add image
            requestBodyData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData("Content-Disposition: form-data; name=\"uploadedPhoto\"; filename=\"image.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData(imageData!)
            
            // add variables
            for (key, value) in parameters {
                requestBodyData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                requestBodyData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
            requestBodyData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            mutableURLRequest.HTTPBody = requestBodyData
            
            return (ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, requestBodyData)
            
        }
        // progress block
        let setProgress = { (percent:CGFloat) -> () in
            dispatch_async(dispatch_get_main_queue(),{
                self.uploadImageProgressView?.frame.size.width = (self.view.frame.size.width - 50) * percent
                if (percent == 1.0) {
                    /*UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.uploadImageProgressView!.alpha = 0
                        return
                        }, completion: {
                            (value: Bool) in
                            //self.uploadImageProgressView!.removeFromSuperview()
                            //self.uploadImageProgressView = nil
                    })*/
                }
            });
        }
        
        
        // UPLOAD ----------
        
        let urlRequest = urlRequestWorksWithDotRequest()
        upload(urlRequest.0, urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                setProgress(CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite))
            }
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON \(JSON)")
                println("ERROR \(error)")
                
                let status = JSON["status"].stringValue
                if (status == "success") {
                    
                    // save image url to user dict
                    userDict["userImageURL"] = JSON["uploadedPhoto"].stringValue
                    dbHelper.saveUserData(userDict)
                    
                    // fade upload indicator
                    self.saveBtn.enabled = false
                    self.uploadImageProgressView?.frame.size.width = self.view.frame.size.width
                    UIView.animateWithDuration(0.3, animations:{ self.uploadImageProgressViewShell!.alpha = 0 })
                    
                    // cahce image for immediate use
                    let newImageUrl = JSON["uploadedPhoto"].stringValue
                    println("cached image: \(newImageUrl)")
                    self.imageCacheManager.cacheImageForUrl(newImageUrl, type: "profilePicture", imageData: self.imageData!)
                    
                    
                } else {
                    println("failure")
                    // TODO: handle failure
                }
        }
    }
    func cameraBtnPressed() {
        autoOnce = false
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
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    func selectExistingPicture() {
        println("From Library")
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let filePath = documentsPath.stringByAppendingPathComponent("image.png")
        let image = scaleImage(info[UIImagePickerControllerEditedImage] as UIImage)
        var imageData = UIImagePNGRepresentation(image)
        imageData.writeToFile(filePath, atomically: true)
        let thisImage = UIImage(contentsOfFile: filePath)
        imageData = UIImagePNGRepresentation(thisImage)
        self.imageData = imageData
        self.imageURL = filePath
        
        
        imageView.image = image
        saveBtn.enabled = true
        
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
}