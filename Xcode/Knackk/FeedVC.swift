//
//  FeedVC.swift
//  Knackk
//
//  Created by wkasel on 8/4/14.
//  Copyright (c) 2014 William Kasel. All rights reserved.
//

import UIKit

class FeedVC:MyFeedBaseVC {
    
    var isFirstLoad = Bool() // (means tableObjects contains extra .append)
    
    override func loadTableDataForTask(task: String, extra: String?) {
        
        isFirstLoad = true
        
        // FETCH POSTS FOR ACTION ----------
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        let firstName = userDict["firstName"] as String
        let lastName = userDict["lastName"] as String
        let fullName = "\(firstName) \(lastName)"
        let savedProfilePicUrl = userDict["userImageURL"] as String
        
        // remove all posts to reload, re-add approrpriate cells for action
        tableObjects.removeAll(keepCapacity: false)
        if task=="listPosts" && extra=="Me" {
            tableObjects.append(FeedObject(type: .ProfileBadge, username: fullName, userImage: savedProfilePicUrl))
            tableObjects.append(FeedObject(type: .Separator))
        }
        tableObjects.append(FeedObject(type: .Loading))
        table.reloadData()
        
        makeTheRequest()
    }
    override func reloadTableDataForTask(task: String, extra: String?) {
        isFirstLoad = false
        makeTheRequest()
    }
    func makeTheRequest() {
        
        let dbHelper = DatabaseHelper()
        var userDict = dbHelper.getUserData()
        let firstName = userDict["firstName"] as String
        let lastName = userDict["lastName"] as String
        let fullName = "\(firstName) \(lastName)"
        
        let savedProfilePicUrl = userDict["userImageURL"] as String
        
        
        
        var parameters = parametersForTask(loadPostsTask)
        parameters["filter"] = loadPostsExtra.lowercaseString
        parameters["userId"] = userDict["knackkId"] as String
        parameters["start"] = loadPostsStart
        parameters["count"] = loadPostsCount
        
        println("FeedVC -> loadTableData -> PARAMETERS \(parameters)")
        
        // send request to server
        request(.POST, apiURL, parameters: parameters)
            
            .responseSwiftyJSON { (request, response, JSON, error) in
                println("JSON FeedVC.swift \(JSON)")
                
                let status = JSON["status"].stringValue
                if (status == "success") {
                    
                    self.notificationsBtn.setTitle(JSON["unseenNotificationCount"].stringValue, forState: UIControlState.Normal)
                    
                    var userMustValidate = userDict["userMustValidateWorkEmail"] as String == "true" ? true : false
                    
                    if userMustValidate {
                        userDict["userMustValidateWorkEmail"] = JSON["userMustValidateWorkEmail"].stringValue
                        userMustValidate = userDict["userMustValidateWorkEmail"] as String == "true" ? true : false
                        dbHelper.saveUserData(userDict)
                    }
                    
                    if let rawPostsArray = JSON["posts"].array {
                        
                        if rawPostsArray.count > 0 {
                            // there were posts, so enable reload and set start point
                            self.canSubmitLoadRequest = true
                            self.loadPostsStart += self.loadPostsCount
                        } else {
                            // there were no posts, so remove loading indicator
                            self.tableObjects.removeLast()
                            self.table.reloadData()
                        }
                        
                        // remove loading indicator
                        //if self.isFirstLoad {
                        if self.tableObjects.count > 0 {
                            self.tableObjects.removeLast()
                        }
                        //}
                        
                        
                        
                        
                        
                        // ADD TABLE HEADINGS FOR CURRENT TASK ----------
                        
                        if (userMustValidate && self.tableObjects.count <= 5) || (!userMustValidate && self.tableObjects.count <= 3) {
                            
                            // re-add 'profile badge' if me tab
                            if self.loadPostsTask=="listPosts" && self.loadPostsExtra=="Me" {
                                self.tableObjects.removeLast() // remove old profile badge
                                if self.tableObjects.count > 0 {
                                    self.tableObjects.removeLast() // remove old separator
                                }
                                let badgeObj = FeedObject(type: .ProfileBadge, username: fullName, userImage: savedProfilePicUrl)
                                badgeObj.userId = userDict["knackkId"] as? String
                                badgeObj.userTitle = JSON["title"].stringValue
                                badgeObj.numFollowers = JSON["numberFollowers"].stringValue
                                badgeObj.numFollowing = JSON["numberFollowing"].stringValue
                                self.tableObjects.append(badgeObj)
                                self.tableObjects.append(FeedObject(type: .Separator))
                                
                                if userMustValidate {
                                    self.tableObjects.append(FeedObject(type: .VerifyEmail))
                                    self.tableObjects.append(FeedObject(type: .Separator))
                                }
                                
                            // add 'post status' cell if all / following tab
                            } else {
                                
                                // show 'validate email' message if needed
                                if userMustValidate {
                                    self.tableObjects.append(FeedObject(type: .Separator))
                                    self.tableObjects.append(FeedObject(type: .VerifyEmail))
                                }
                                
                                self.tableObjects.append(FeedObject(type: .Separator))
                                
                                //let dbHelper = DatabaseHelper()
                                //let userDict = dbHelper.userDict
                                let firstName = userDict.objectForKey("firstName") as String
                                let lastName = userDict.objectForKey("lastName") as String
                                let username = "\(firstName) \(lastName)"
                                let userImage = userDict.objectForKey("userImageURL") as String
                                let obj = FeedObject(type: .UpdateStatus, username: username, userImage: userImage)
                                self.tableObjects.append(obj)
                                
                                self.tableObjects.append(FeedObject(type: .Separator))
                            }
                        }
                        
                        
                        // LIST POSTS AND COMMENTS ----------
                        
                        for i in 0 ..< rawPostsArray.count {
                            
                            let thisPostArray = rawPostsArray[i]
                            
                            var titleForHeight:String? = nil
                            var usernameText = thisPostArray["userName"].stringValue
                            if usernameText.isEmpty {
                                usernameText = thisPostArray["title"].stringValue
                                titleForHeight = usernameText
                            }
                            
                            let obj = FeedObject(type: .UserPost, username: usernameText, userImage: thisPostArray["pictureUrl"].stringValue, parent:self)
                            obj.postId = thisPostArray["id"].stringValue
                            obj.userId = userDict.objectForKey("knackkId") as? String
                            if thisPostArray["userId"].stringValue.isEmpty {
                                obj.type = .NewsArticle
                            } else {
                                obj.userIdToFollow = thisPostArray["userId"].stringValue
                            }
                            
                            let test = thisPostArray["activeDisplayedUser"]
                            println("\n\n FeedVC activeDisplayedUser: \(test) \n\n")
                            if thisPostArray["activeDisplayedUser"].stringValue == "true" { obj.activeDisplayedUser = true }
                            
                            obj.timeString = thisPostArray["timeAgo"].stringValue
                            obj.contentText = thisPostArray["text"].stringValue
                            obj.postImageURL = thisPostArray["imageUrl"].stringValue
                            obj.numComments = thisPostArray["commentsCount"].stringValue
                            obj.numLikes = thisPostArray["likes"].stringValue
                            if thisPostArray["userHasFollowed"].stringValue == "true" { obj.userHasFollowed = true }
                            if thisPostArray["userHasFollowed"].stringValue == "false" { obj.userHasFollowed = false }
                            if thisPostArray["userHasLiked"].stringValue == "true" { obj.userHasLikedPost = true }
                            if thisPostArray["userHasLiked"].stringValue == "false" { obj.userHasLikedPost = false }
                            obj.setUserPostHeightWithText(titleForHeight, text: obj.contentText!, hasImage: !obj.postImageURL!.isEmpty, isComment:false, hasNewsUrl:thisPostArray["url"].stringValue, postParent:self)
                            self.tableObjects.append(obj)
                            
                            // add show more button if more than two comments
                            if obj.numComments!.toInt() > 2 {
                                let showMoreObj = FeedObject(type: .ShowEntirePost)
                                showMoreObj.postId = obj.postId
                                self.tableObjects.append(showMoreObj)
                            }
                            
                            // add comment box
                            if !userMustValidate {
                                
                                // loop comments
                                if let rawCommentsArray = thisPostArray["comments"].array {
                                    //println("rawCommentsArray: \(rawCommentsArray)")
                                    for j in 0 ..< rawCommentsArray.count {
                                        let thisCommentArray = rawCommentsArray[j]
                                        //println("thisCommentArray: \(thisCommentArray)")
                                        let commentObj = FeedObject(type: .UserComment, username: thisCommentArray["userName"].stringValue, userImage: thisCommentArray["pictureUrl"].stringValue)
                                        commentObj.postId = thisPostArray["id"].stringValue
                                        commentObj.userId = userDict.objectForKey("knackkId") as? String
                                        commentObj.userIdToFollow = thisCommentArray["userId"].stringValue
                                        commentObj.timeString = thisCommentArray["timeAgo"].stringValue
                                        commentObj.contentText = thisCommentArray["text"].stringValue
                                        commentObj.setUserPostHeightWithText(nil, text: commentObj.contentText!, hasImage: false, isComment:true, hasNewsUrl:nil, postParent:self)
                                        self.tableObjects.append(commentObj)
                                    }
                                }
                                let commenterFirst = userDict["firstName"] as String
                                let commenterLast = userDict["lastName"] as String
                                let commenterUsername = "\(commenterFirst) \(commenterLast)"
                                let commentBoxObj = FeedObject(type: .PostAComment, username: commenterUsername, userImage: userDict["userImageURL"] as String)
                                commentBoxObj.postId = thisPostArray["id"].stringValue
                                commentBoxObj.userId = (userDict["knackkId"] as String)
                                self.tableObjects.append(commentBoxObj)
                            }
                            
                            // post separator
                            self.tableObjects.append(FeedObject(type: .Separator))
                            
                        }
                        
                        
                        if rawPostsArray.count >= self.loadPostsCount {
                            // there were posts, so there may be more
                            let loadingObj = FeedObject(type: .Loading)
                            loadingObj.thisLoadingCellCanRequestFromServer = true
                            self.tableObjects.append(loadingObj)
                        } else if rawPostsArray.count > 0 {
                            // do nothing
                        } else {
                            // there weren't any posts, so we can just show the bottom separator
                            self.tableObjects.append(FeedObject(type: .Separator))
                        }
                        self.table.reloadData()
                    }
                    
                } else {
                    let alert = UIAlertView(title: "Error", message: "Could not fetch data.\nPlease try again later.", delegate: nil, cancelButtonTitle: "Okay")
                    alert.show()
                }
        }
    }
}