//
//  ShowProfileVC.swift
//  Knackk
//
//  Created by Erik Wetterskog on 1/6/15.
//  Copyright (c) 2015 antiblank. All rights reserved.
//

import UIKit

class ShowProfileVC:MyFeedBaseVC {
    
    var tempUserName = "Loading"
    var tempUserImageUrl = ""
    
    convenience init(segment:NSArray?, fetchCoworkers:Bool, navBarType:String, userName:String, userImageUrl:String, toViewProfileId:String) {
        self.init(segment:segment, fetchCoworkers:fetchCoworkers, navBarType:navBarType)
        
        self.tempUserName = userName
        self.tempUserImageUrl = userImageUrl
        
        self .loadTableDataForTask("showProfile", extra: toViewProfileId)
    }
    convenience init(segment:NSArray?, fetchCoworkers:Bool, navBarType:String, userName:String, userImageUrl:String) {
        self.init(segment:segment, fetchCoworkers:fetchCoworkers, navBarType:navBarType)
        
        self.tempUserName = userName
        self.tempUserImageUrl = userImageUrl
    }
    override func loadTableDataForTask(task: String, extra: String?) {
        
        // FETCH POSTS FOR ACTION ----------
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        let firstName = userDict["firstName"] as String
        let lastName = userDict["lastName"] as String
        let fullName = "\(firstName) \(lastName)"
        let savedProfilePicUrl = userDict["userImageURL"] as String
        
        // remove all posts to reload, re-add approrpriate cells for action
        navTitleLbl.text = tempUserName
        tableObjects.removeAll(keepCapacity: false)
        
        tableObjects.append(FeedObject(type: .ProfileBadge, username: tempUserName, userImage: tempUserImageUrl))
        tableObjects.append(FeedObject(type: .Separator))
        tableObjects.append(FeedObject(type: .Loading))
        table.reloadData()
        
        
        
        
        var parameters = parametersForTask(task)
        parameters["toDisplayUserId"] = extra!.lowercaseString
        parameters["requestingUserId"] = (userDict["knackkId"] as String)
        println("FeedVC -> loadTableData -> PARAMETERS \(parameters)")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            
            .responseSwiftyJSON { (request, response, JSON, error) in
                //println("REQUEST \(request)")
                //println("RESPONSE \(response)")
                println("JSON ShowProfileVC.swift \(JSON)")
                //println("ERROR \(error)")
                
                // HANDLE RESULTS ----------
                
                let status = JSON["status"].stringValue
                if (status == "success") {
                    
                    if let rawPostsArray = JSON["posts"].array {
                        
                        // remove all posts to reload
                        self.tableObjects.removeAll(keepCapacity: false)
                        
                        // get name
                        let firstName = JSON["firstName"].stringValue
                        let lastName = JSON["lastName"].stringValue
                        let fullName = "\(firstName) \(lastName)"
                        
                        
                        // show profile badge
                        self.navTitleLbl.text = fullName
                        let badgeObj = FeedObject(type: .ProfileBadge, username: fullName, userImage: JSON["pictureUrl"].stringValue)
                        badgeObj.userId = extra!.lowercaseString
                        badgeObj.userTitle = JSON["title"].stringValue
                        badgeObj.numFollowers = JSON["numberFollowers"].stringValue
                        badgeObj.numFollowing = JSON["numberFollowing"].stringValue
                        self.tableObjects.append(badgeObj)
                        self.tableObjects.append(FeedObject(type: .Separator))
                        
                        
                        
                        
                        
                        
                        
                        for i in 0 ..< rawPostsArray.count {
                            
                            let thisPostArray = rawPostsArray[i]
                            //println("thisPostArray: \(thisPostArray)")
                            
                            let obj = FeedObject(type: .UserPost, username: thisPostArray["userName"].stringValue, userImage: thisPostArray["pictureUrl"].stringValue, parent:self)
                            obj.postId = thisPostArray["id"].stringValue
                            obj.userId = userDict.objectForKey("knackkId") as? String
                            obj.userIdToFollow = thisPostArray["userId"].stringValue
                            
                            let test = thisPostArray["activeDisplayedUser"]
                            println("\n\n ShowProfileVC activeDisplayedUser: \(test) \n\n")
                            if thisPostArray["activeDisplayedUser"].stringValue == "true" { obj.activeDisplayedUser = true }
                            
                            obj.timeString = thisPostArray["timeAgo"].stringValue
                            obj.contentText = thisPostArray["text"].stringValue
                            obj.postImageURL = thisPostArray["imageUrl"].stringValue
                            obj.numComments = thisPostArray["comments_count"].stringValue
                            obj.numLikes = thisPostArray["likes"].stringValue
                            println("--- \(obj.userHasFollowed) ---")
                            if thisPostArray["userHasFollowed"].stringValue == "true" { obj.userHasFollowed = true }
                            if thisPostArray["userHasFollowed"].stringValue == "false" { obj.userHasFollowed = false }
                            if thisPostArray["userHasLiked"].stringValue == "true" { obj.userHasLikedPost = true }
                            if thisPostArray["userHasLiked"].stringValue == "false" { obj.userHasLikedPost = false }
                            obj.setUserPostHeightWithText(nil, text: obj.contentText!, hasImage: !obj.postImageURL!.isEmpty, isComment:false, hasNewsUrl:nil, postParent:self)
                            self.tableObjects.append(obj)
                            
                            // add show more button if more than two comments
                            if obj.numComments!.toInt() > 2 {
                                let showMoreObj = FeedObject(type: .ShowEntirePost)
                                showMoreObj.postId = obj.postId
                                self.tableObjects.append(showMoreObj)
                            }
                            
                            
                            // loop comments
                            if let rawCommentsArray = thisPostArray["comments"].array {
                                //println("rawCommentsArray: \(rawCommentsArray)")
                                for j in 0 ..< rawCommentsArray.count {
                                    let thisCommentArray = rawCommentsArray[j]
                                    //println("thisCommentArray: \(thisCommentArray)")
                                    let commentObj = FeedObject(type: .UserComment, username: thisCommentArray["userName"].stringValue, userImage: thisCommentArray["pictureUrl"].stringValue)
                                    commentObj.postId = thisPostArray["id"].stringValue
                                    commentObj.userId = dbHelper.getUserObjectForKey("knackkId")
                                    commentObj.userIdToFollow = thisCommentArray["userId"].stringValue
                                    commentObj.timeString = thisCommentArray["timeAgo"].stringValue
                                    commentObj.contentText = thisCommentArray["text"].stringValue
                                    commentObj.setUserPostHeightWithText(nil, text: commentObj.contentText!, hasImage: false, isComment:true, hasNewsUrl:nil, postParent:self)
                                    self.tableObjects.append(commentObj)
                                }
                            }
                            
                            // add comment box
                            let commenterFirst = userDict["firstName"] as String
                            let commenterLast = userDict["lastName"] as String
                            let commenterUsername = "\(commenterFirst) \(commenterLast)"
                            let commentBoxObj = FeedObject(type: .PostAComment, username: commenterUsername, userImage: userDict["userImageURL"] as String)
                            commentBoxObj.postId = thisPostArray["id"].stringValue
                            commentBoxObj.userId = (userDict["knackkId"] as String)
                            self.tableObjects.append(commentBoxObj)
                            
                            // post separator
                            self.tableObjects.append(FeedObject(type: .Separator))
                            
                        }
                        self.table.reloadData()
                    }
                    
                } else {
                    println("failure")
                    // TODO: handle failure
                }
        }
    }
}